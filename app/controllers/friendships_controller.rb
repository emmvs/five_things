# frozen_string_literal: true

# FriendshipsController for creating, updating and deleting a friendship
class FriendshipsController < ApplicationController
  before_action :set_friendship, only: %i[update destroy]

  def index
    @should_render_navbar = true
    @users = User.all_except(current_user)
    @friendships = current_user.friendships
  end

  def create
    @friendship = current_user.friendships.build(friend_id: params[:friend_id])
    flash[:notice] = if @friendship.save
                       'Friend request sent. 👻'
                     else
                       'Unable to send friend request. 🤔'
                     end
    redirect_to users_path
  end

  def update
    flash[:notice] = if @friendship.update(accepted: true)
                       'Friend request accepted. 🫱🏻‍🫲🏾'
                     else
                       'Unable to accept friend request. 🙈'
                     end
    redirect_to users_path
  end

  def destroy
    @friendship.destroy
    flash[:notice] = 'Friendship removed. 😭'
    redirect_to users_path
  end

  private

  def set_friendship
    @friendship = current_user.friendships.find_by(friend_id: params[:id]) ||
                  current_user.inverse_friendships.find_by(user_id: params[:id])
  end
end
