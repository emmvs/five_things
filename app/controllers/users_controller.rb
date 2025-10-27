# frozen_string_literal: true

# UsersController for Users Page & Friend's profile
class UsersController < ApplicationController
  helper FriendshipsHelper
  include WordAggregator

  attr_reader :user

  def index
    @users = fetch_users
  end

  def friends
    @friends = current_user.friends
    @pending_requests = current_user.pending_friends
    @friend_requests = fetch_incoming_friend_requests
    @users = fetch_users
  end

  def show
    @user = User.find(params[:id])
    @happy_count = happy_count(user)
    @words_for_wordcloud = words_for_wordcloud(user)
    @visited_places_count = visited_places_count(user)
    @markers = markers(user)
  end

  def profile
    fetch_happy_count
    fetch_words_for_wordcloud
    fetch_visited_places_count
    fetch_label_count
    @markers = fetch_markers_for_map
  end

  private

  def fetch_incoming_friend_requests
    User.joins(:friendships).where(friendships:
      {
        friend_id: current_user.id,
        accepted: false
      })
  end

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

  def fetch_happy_count
    @happy_count = HappyThing.where(user: current_user).size
  end

  def fetch_words_for_wordcloud
    @words_for_wordcloud = WordAggregator.aggregated_words(current_user, 40, period: :year)
    @words_for_wordcloud_month = WordAggregator.aggregated_words(current_user, 40, period: :month)
  end

  def fetch_visited_places_count
    @visited_places_count = current_user.happy_things.distinct.count(:place)
  end

  def fetch_label_count
    return @label_counts = @happy_things.group(:category).count if @happy_things.present?

    @label_counts = {}
  end

  def fetch_markers_for_map
    current_user.happy_things.geocoded.pluck(:latitude, :longitude).map { |lat, lng| { lat:, lng: } }
  end
end
