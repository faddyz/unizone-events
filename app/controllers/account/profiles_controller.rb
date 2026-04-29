class Account::ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
  end

  def update
    @user = current_user

    if email_change_requires_password?
      if @user.update_with_password(profile_with_password_params)
        bypass_sign_in(@user)
        redirect_to account_profile_path, notice: t("flash.profile_updated")
      else
        render :show, status: :unprocessable_entity
      end
    elsif @user.update(profile_without_password_params)
      redirect_to account_profile_path, notice: t("flash.profile_updated")
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def email_change_requires_password?
    requested_email = profile_without_password_params[:email]
    requested_email.present? && requested_email != @user.email
  end

  def profile_without_password_params
    params.require(:user).permit(:name, :email)
  end

  def profile_with_password_params
    params.require(:user).permit(:name, :email, :current_password)
  end
end
