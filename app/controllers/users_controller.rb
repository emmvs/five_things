class UsersController < ApplicationController
  helper FriendshipsHelper

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end
end
