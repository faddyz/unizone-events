class Account::PasswordsController < ApplicationController
  before_action :authenticate_user!

  def update
    if current_user.update_with_password(password_params)
      bypass_sign_in(current_user)
      redirect_to account_profile_path, notice: t("flash.password_updated")
    else
      @user = current_user
      render "account/profiles/show", status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation, :current_password)
  end
end
