# frozen_string_literal: true

# FriendshipsController for creating, updating and deleting a friendship
class FriendshipsController < ApplicationController
  before_action :set_friendship, only: %i[update destroy]

  def index
    @users = User.all_except(current_user)
    @friendships = current_user.friendships
  end

  def create
    @friendship = current_user.friendships.build(friend_id: params[:friend_id])
    flash[:notice] = if @friendship.save
                       t('friendships.created')
                     else
                       t('friendships.create_failed')
                     end
    redirect_to users_path
  end

  def update
    flash[:notice] = if @friendship.update(accepted: true)
                       t('friendships.accepted')
                     else
                       t('friendships.accept_failed')
                     end
    redirect_to users_path
  end

  def destroy
    @friendship.destroy
    flash[:notice] = t('friendships.destroyed')
    redirect_to friends_path
  end

  private

  # Ensures only friendships involving the current_user can be updated or destroyed.
  # This prevents users from accessing or manipulating friendships they are not part of,
  # which could otherwise happen via ID guessing (e.g. /friendships/42)
  def set_friendship
    @friendship = Friendship.where(id: params[:id])
                            .where('user_id = :user_id OR friend_id = :user_id', user_id: current_user.id)
                            .first
  end
end
