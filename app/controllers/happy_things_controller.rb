# frozen_string_literal: true

# Controller for creating & handling Happythings
class HappyThingsController < ApplicationController # rubocop:disable Metrics/ClassLength
  include WordAggregator
  include UserRelated

  YEARS_PER_PAGE = 30

  skip_before_action :authenticate_user!, only: %i[future_root]
  before_action :set_happy_thing, only: %i[show]
  before_action :set_own_happy_thing, only: %i[edit update destroy]
  before_action :disable_navbar_for_guests, only: %i[future_root]

  # TODO: rename when this replaces current root path after transition
  def future_root
    @happy_thing = HappyThing.new

    if current_user
      load_authenticated_user_data
    else
      load_guest_data
    end
  end

  def recent_happy_things
    range = Time.zone.yesterday.beginning_of_day..Time.zone.today.end_of_day
    @happy_things_of_the_last_two_days = happy_things_by_period(range, user_ids)
  end

  def show
    @marker = @happy_thing.geocoded? ? { lat: @happy_thing.latitude, lng: @happy_thing.longitude } : nil
  end

  def new
    @happy_thing = HappyThing.new
  end

  def create
    @happy_thing = current_user_happy_things.new(happy_thing_params)
    @happy_thing.start_time = Time.zone.now
    save_and_respond(@happy_thing)
    handle_visibility(@happy_thing) if @happy_thing.persisted?
  end

  def update
    if @happy_thing.update(happy_thing_params)
      @happy_thing.happy_thing_user_shares.destroy_all
      @happy_thing.happy_thing_group_shares.destroy_all
      handle_visibility(@happy_thing)
      redirect_to happy_thing_path(@happy_thing), notice: t('happy_things.updated')
    else
      render :edit, status: 422
    end
  end

  def destroy
    @happy_thing.destroy
    redirect_to root_path, notice: t('happy_things.destroyed')
  end

  def analytics
    fetch_happy_count
    fetch_words_for_wordcloud
    fetch_visited_places_count
    fetch_label_count
    @markers = current_user.happy_things.geocoded.map { |ht| { lat: ht.latitude, lng: ht.longitude } }
  end

  # Without a search: HappyThings from today's date in earlier years, yours and your friends'.
  # With a search: all of your own HappyThings that match.
  # Both can be narrowed down to one category and one year with the chips.
  def through_the_years
    @query = params[:query].to_s.strip.first(HappyThing::SEARCH_MAX_LENGTH)
    @query_too_short = @query.present? && @query.length < HappyThing::SEARCH_MIN_LENGTH
    happy_things = filter_by_year(filter_by_category(happy_things_for_through_the_years))
    @happy_things = happy_things.includes(:user, :category)
                                .order(start_time: :desc, id: :desc)
                                .page(params[:page]).per(YEARS_PER_PAGE)
  end

  def calendar
    @user_ids = user_ids

    @happy_things_of_you_and_friends = HappyThing.where(user_id: @user_ids).visible_to(current_user)
  end

  def show_by_date
    @comment = Comment.new
    @date = begin
      Date.parse(params[:date])
    rescue ArgumentError
      Date.today
    end
    setup_happy_things_for_view
    @own_count_for_date = current_user.happy_things.where(start_time: @date.all_day).count
    @old_happy_thing = current_user.happy_things.new(start_time: @date)
  end

  def setup_happy_things_for_view
    @happy_things = HappyThing.where(user_id: user_ids, start_time: @date.all_day)
                              .visible_to(current_user)
                              .includes(:happy_thing_user_shares, :happy_thing_group_shares)
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
      date_path = happy_things_by_date_path(date: @old_happy_thing.start_time.to_date)
      redirect_to date_path, notice: t('happy_things.created')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  # Nothing for a too short search, your matches for a search, otherwise today in earlier years
  def happy_things_for_through_the_years
    return HappyThing.none if @query_too_short
    return current_user.happy_things.search(@query) if @query.present?

    happy_things_on_this_day
  end

  def happy_things_on_this_day
    HappyThing.where(user_id: user_ids).visible_to(current_user).on_this_day_in_past_years(Date.today)
  end

  # Sets the category chips and keeps only the chosen category, if any.
  # Only a category that is on a chip is used, so any other value in the URL is ignored.
  def filter_by_category(happy_things)
    @categories = Category.where(id: happy_things.select(:category_id)).order(:name)
    @category = @categories.find { |category| category.id.to_s == params[:category] }
    @category ? happy_things.where(category: @category) : happy_things
  end

  # Sets the year chips and keeps only the chosen year, if any.
  # Only a year that is on a chip is used, so any other value in the URL is ignored.
  def filter_by_year(happy_things)
    @years = happy_things.years
    @year = @years.find { |year| year.to_s == params[:year] }
    @year ? happy_things.in_year(@year) : happy_things
  end

  def set_happy_thing
    @happy_thing = HappyThing.where(user_id: user_ids).visible_to(current_user).find(params[:id])
  end

  def set_own_happy_thing
    @happy_thing = current_user.happy_things.find(params[:id])
  end

  def save_and_respond(resource)
    respond_to do |format|
      if resource.save
        format.html { redirect_to root_path, notice: t('happy_things.created') }
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
      if entry == 'only_me'
        happy_thing.happy_thing_user_shares.create!(friend_id: happy_thing.user_id)
      else
        type, id = entry.split('_')
        case type
        when 'group'
          happy_thing.happy_thing_group_shares.create!(group_id: id)
        when 'friend'
          happy_thing.happy_thing_user_shares.create!(friend_id: id)
        end
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
        format.html { redirect_to root_path, notice: t('happy_things.created') }
        format.json { render json: { status: :created, happy_thing: @happy_thing } }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @happy_thing.errors, status: :unprocessable_entity }
      end
    end
  end

  def happy_things_by_period(period, friend_ids)
    HappyThing.where(start_time: period, user_id: friend_ids)
              .visible_to(current_user)
              .includes(:happy_thing_user_shares, :happy_thing_group_shares)
              .order(created_at: :desc)
              .group_by(&:user)
  end

  def user_ids(with_current_user: true)
    if with_current_user
      [current_user.id] + current_user.friends_and_friends_who_added_me_ids
    else
      current_user.friends_and_friends_who_added_me_ids
    end
  end

  def disable_navbar_for_guests
    disable_navbar unless current_user
  end

  def load_authenticated_user_data
    range = Time.zone.today.all_day
    @happy_things_today = happy_things_by_period(range, user_ids)
  end

  def load_guest_data
    @happy_things_today = {}
    @guest_happy_thing = session[:guest_onboarding]&.dig('happy_thing')
    @guest_emoji = session[:guest_onboarding]&.dig('emoji')
    @guest_name = session[:guest_onboarding]&.dig('name')
  end
end
