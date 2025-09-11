# frozen_string_literal: true

# Controller for creating & handling Happythings
class HappyThingsController < ApplicationController # rubocop:disable Metrics/ClassLength
  include WordAggregator
  include UserRelated

  before_action :set_happy_thing, only: %i[show edit update destroy]

  def index
    @should_render_navbar = true
    @happy_things = happy_things_of_friends.page(params[:page]).per(10)
  end

  def show
    @marker = @happy_thing.geocoded? ? { lat: @happy_thing.latitude, lng: @happy_thing.longitude } : nil
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
    fetch_visited_places
    fetch_label_count
    @markers = current_user.happy_things.geocoded.map { |ht| { lat: ht.latitude, lng: ht.longitude } }
  end

  def calendar
    friend_ids = current_user.friends_and_friends_who_added_me_ids
    @user_ids = [current_user.id] + friend_ids

    @happy_things_of_you_and_friends = HappyThing.where(user_id: @user_ids).order(created_at: :desc)
  end

  def show_by_date
    @comment = Comment.new
    @date = begin
      Date.parse(params[:date])
    rescue ArgumentError
      Date.today
    end
    setup_happy_things_for_view
    @old_happy_thing = current_user.happy_things.new(start_time: @date)
  end

  def setup_happy_things_for_view
    friend_ids = current_user.friends.pluck(:id) + current_user.friends_who_added_me.pluck(:id)
    @happy_things = HappyThing.where(user_id: friend_ids + [current_user.id], start_time: @date.all_day)
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

  def fetch_visited_places
    @visited_places_count = @visited_places_count = HappyThing.where(user_id: current_user.id).distinct.count(:place)
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
    friend_ids = current_user.friends_and_friends_who_added_me_ids
    user_ids = friend_ids + [current_user.id]

    @happy_thing = HappyThing.where(user_id: user_ids).find(params[:id])
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

  def happy_things_of_friends # rubocop:disable Metrics/AbcSize
    own = HappyThing.where(user_id: current_user.id)

    shared_with_user = HappyThing.joins(:happy_thing_user_shares)
                                 .where(happy_thing_user_shares: { friend_id: current_user.id })

    shared_with_groups = HappyThing.joins(happy_thing_group_shares: { group: :group_memberships })
                                   .where(group_memberships: { friend_id: current_user.id })

    public_happy_things = HappyThing.left_joins(:happy_thing_user_shares, :happy_thing_group_shares)
                                    .where(happy_thing_user_shares: { id: nil }, happy_thing_group_shares: { id: nil })

    ids = (own.pluck(:id) + shared_with_user.pluck(:id) + shared_with_groups.pluck(:id) + public_happy_things.pluck(:id)).uniq # rubocop:disable Layout/LineLength

    HappyThing.where(id: ids).order(start_time: :desc)
  end
end
