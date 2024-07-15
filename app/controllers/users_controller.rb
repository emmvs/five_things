# frozen_string_literal: true

# UsersController for Users Page & Friend's profile
class UsersController < ApplicationController
  helper FriendshipsHelper

  def index
    @users = fetch_users
  end

  def show
    @user = User.find(params[:id])
    @happy_count = happy_count(@user)
    @words_for_wordcloud = words_for_wordcloud(@user)
    @visited_places_count = visited_places_count(@user)
    @markers = markers(@user)
  end

  private

  def fetch_users
    if params[:query].present?
      User.search(params[:query]).all_except(current_user)
    else
      User.all_except(current_user)
    end
  end

  def happy_count(user)
    user.happy_things.count
  end

  def words_for_wordcloud(user)
    WordAggregator.aggregated_words(user, 40)
  end

  def visited_places_count(user)
    HappyThing.where(user_id: user.id).distinct.count(:place)
  end

  def markers(user)
    user.happy_things.geocoded.map do |ht|
      { lat: ht.latitude, lng: ht.longitude }
    end
  end
end
