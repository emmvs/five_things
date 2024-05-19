# frozen_string_literal: true

# UsersController for Users Page & Friend's profile
class UsersController < ApplicationController
  helper FriendshipsHelper

  def index
    if params[:query].present?
      @users = User.search(params[:query]).all_except(current_user)
    else
      @users = User.all_except(current_user)
    end
  end

  def show
    @user = User.find(params[:id])
    @happy_count = @user.happy_things.count
    @words_for_wordcloud = WordAggregator.aggregated_words(@user, 40)
    @visited_places_count = HappyThing.where(user_id: @user.id).distinct.count(:place)
    @markers = @user.happy_things.geocoded.map { |ht| { lat: ht.latitude, lng: ht.longitude } }
  end
end
