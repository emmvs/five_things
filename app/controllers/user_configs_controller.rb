# frozen_string_literal: true

class UserConfigsController < ApplicationController
  def update
    @user_config = UserConfig.find_or_create_by(user: current_user)

    if @user_config.update(user_config_params)
      head :ok
    else
      head :unprocessable_entity
    end
  end

  private

  def user_config_params
    params.require(:user_config).permit(:install_prompt_shown)
  end
end
