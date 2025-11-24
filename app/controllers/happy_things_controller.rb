# frozen_string_literal: true

# Controller for creating & handling Happythings
class HappyThingsController < ApplicationController # rubocop:disable Metrics/ClassLength
  include WordAggregator
  include UserRelated

  before_action :set_happy_thing, only: %i[show]
  before_action :set_own_happy_thing, only: %i[edit update destroy]

  # TODO: rename when this replaces current root path after transition
  def future_root
    @happy_thing = HappyThing.new
    range = Time.zone.today.all_day
    @happy_things_today = happy_things_by_period(range, user_ids)
  end

  def recent_happy_things
    range = Time.zone.yesterday.beginning_of_day..Time.zone.today.end_of_day
    @happy_things_of_the_last_two_days = happy_things_by_period(range, user_ids)
  end

  def show
    @marker = @happy_thing.geocoded? ? { lat: @happy_thing.latitude, lng: @happy_thing.longitude } : nil
    @comment = Comment.new
  end

  def new
    @happy_thing = HappyThing.new
  end

  def create
    @happy_thing = current_user_happy_things.new(happy_thing_params)
    save_and_respond(@happy_thing)
    handle_visibility(@happy_thing) if @happy_thing.persisted?
  end

  def update
    if @happy_thing.update(happy_thing_params)
      @happy_thing.happy_thing_user_shares.destroy_all
      @happy_thing.happy_thing_group_shares.destroy_all
      handle_visibility(@happy_thing)
      redirect_to root_path, notice: 'Yay! 🎉 Happy Thing was updated 🥰'
    else
      render :edit, status: 422
    end
  end

  def destroy
    @happy_thing.destroy
    redirect_to root_path, notice: 'Happy Thing was destroyed 😕'
  end

  def analytics
    fetch_happy_count
    fetch_words_for_wordcloud
    fetch_visited_places_count
    fetch_label_count
    @markers = current_user.happy_things.geocoded.map { |ht| { lat: ht.latitude, lng: ht.longitude } }
  end

  def through_the_years
    today = Date.today
    @happy_things_of_the_past_years = HappyThing.where(
      'extract(month from start_time) = ? AND extract(day from start_time) = ? AND user_id IN (?)',
      today.month, today.day, user_ids
    ).reject { |ht| ht.start_time.year == today.year }
  end

  def calendar
    @user_ids = user_ids

    @happy_things_of_you_and_friends = HappyThing.where(user_id: @user_ids).order(created_at: :desc)
  end

  def show_by_date
    @date = begin
      Date.parse(params[:date])
    rescue ArgumentError
      Date.today
    end
    setup_happy_things_for_view
    @old_happy_thing = current_user.happy_things.new(start_time: @date)
  end

  def setup_happy_things_for_view
    @happy_things = HappyThing.where(user_id: user_ids, start_time: @date.all_day)
  end

  def old_happy_thing
    @old_happy_thing = current_user.happy_things.new
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

  def create_old_happy_thing
    @old_happy_thing = current_user.happy_things.build(happy_thing_params)
    if @old_happy_thing.save
      redirect_to root_path, notice: 'Happy Thing was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_happy_thing
    @happy_thing = HappyThing.where(user_id: user_ids).find(params[:id])
  end

  def set_own_happy_thing
    @happy_thing = current_user.happy_things.find(params[:id])
  end

  def save_and_respond(resource)
    respond_to do |format|
      if resource.save
        format.html { redirect_to root_path, notice: 'Happy Thing was successfully created.' }
        format.json { render json: { status: :created, happy_thing: resource } }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def handle_visibility(happy_thing) # rubocop:disable Metrics/MethodLength
    shared_ids = params[:happy_thing][:shared_with_ids] || []
    return if shared_ids.blank?

    shared_ids.each do |entry|
      type, id = entry.split('_')
      case type
      when 'group'
        happy_thing.happy_thing_group_shares.create!(group_id: id)
      when 'friend'
        happy_thing.happy_thing_user_shares.create!(friend_id: id)
      end
    end
  end

  def happy_thing_params
    params.require(:happy_thing).permit(:title, :photo, :body, :status, :start_time, :place, :longitude, :latitude,
                                        :category_id, :share_location, shared_with_ids: [])
  end

  def create_happy_thing
    respond_to do |format|
      if @happy_thing.save
        format.html { redirect_to root_path, notice: 'Happy Thing was successfully created.' }
        format.json { render json: { status: :created, happy_thing: @happy_thing } }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @happy_thing.errors, status: :unprocessable_entity }
      end
    end
  end

  def happy_things_by_period(period, friend_ids)
    HappyThing.where(start_time: period, user_id: friend_ids).order(created_at: :desc).group_by(&:user)
  end

  def user_ids(with_current_user: true)
    if with_current_user
      [current_user.id] + current_user.friends_and_friends_who_added_me_ids
    else
      current_user.friends_and_friends_who_added_me_ids
    end
  end
end
