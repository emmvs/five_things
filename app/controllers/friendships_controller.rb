class FriendshipsController < ApplicationController
  before_action :set_friendship, only: [:update, :destroy]

  def index
    @users = User.all - [current_user]
    @should_render_navbar = true
    @friendships = current_user.friendships
  end

  def new
    @friendship = Friendship.new
  end

  def create
    @friendship = current_user.friendships.build(friend_id: params[:friendship][:friend_id])
    if @friendship.save
      redirect_to root_path, notice: "Yay! 🎉 You sent a friend request!"
    else
      render :new, status: 422
    end
  end

  def update
    if @friendship.update(accepted: true)
      redirect_to root_path, notice: "Yay! 🎉 You accepted a friend request!"
    else
      render :new, status: 422
    end
  end

  def destroy
    @friendship.destroy
    redirect_to root_path, notice: "Happy Thing was destroyed 😕"
  end

  private

  def set_friendship
    @friendship = Friendship.find(params[:id])
  end

  def friendship_params
    params.require(:friendship).permit(:status, :friend_id, :user_id)
  end
end
