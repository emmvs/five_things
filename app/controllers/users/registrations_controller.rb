# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def update_resource(resource, _params)
    if updating_sensitive_info?
      resource.update_with_password(user_params)
    else
      resource.update_without_password(user_params.except(:current_password))
    end
  end

  def settings
    @user = current_user
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :avatar, :emoji, :email, :password, :password_confirmation,
                                 :current_password, :email_opt_in, :location_opt_in)
  end

  def updating_sensitive_info?
    user_params[:password].present?
  end
end
