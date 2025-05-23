class PagesController < ApplicationController
  include Devise::Controllers::Helpers
  
  def faq
    
  end
  
  def account
    authenticate_user! 
    @user = current_user
  end
  
  def update_profile
    authenticate_user!
    @user = current_user
    
    if @user.update(profile_params)
      flash[:profile_notice] = "Profil bilgileriniz başarıyla güncellendi."
      redirect_to account_path
    else
      flash[:profile_error] = "Profil bilgileriniz güncellenirken bir hata oluştu: #{@user.errors.full_messages.join(', ')}"
      redirect_to account_path
    end
  end
  
  def update_password
    authenticate_user!
    @user = current_user
    
    
    if params[:password].present? && params[:password_confirmation].present?
      if @user.valid_password?(params[:current_password])
        if params[:password] == params[:password_confirmation]
          if @user.update(password: params[:password])
            sign_out(@user)
            flash[:notice] = "Şifreniz başarıyla güncellendi. Lütfen yeni şifrenizle giriş yapın."
            redirect_to new_user_session_path
          else
            flash[:password_error] = "Şifreniz güncellenirken bir hata oluştu: #{@user.errors.full_messages.join(', ')}"
            redirect_to account_path
          end
        else
          flash[:password_error] = "Yeni şifre ve onay şifresi eşleşmiyor."
          redirect_to account_path
        end
      else
        flash[:password_error] = "Mevcut şifreniz doğru değil."
        redirect_to account_path
      end
    else
      flash[:password_error] = "Yeni şifre ve onay şifresi girilmelidir."
      redirect_to account_path
    end
  end
  
  private
  
  def profile_params
    params.permit(:name, :email)
  end
end 