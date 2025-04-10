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
  end

  def update
    if @happy_thing.update(happy_thing_params)
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
    @words_for_wordcloud = WordAggregator.aggregated_words(current_user, 40)
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

  def happy_thing_params
    params.require(:happy_thing).permit(:title, :photo, :body, :status, :start_time, :place, :longitude, :latitude,
                                        :category_id, :share_location)
  end

  def create_happy_thing
    respond_to do |format|
      if @happy_thing.save
        format.html { redirect_to root_path, notice: 'Happy Thing was successfully created.' }
        format.json { render json: { status: :created, happy_thing: @happy_thing } }
        # format.json
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @happy_thing.errors, status: :unprocessable_entity }
        # format.json
      end
    end
  end

  def happy_things_of_friends
    friend_ids = current_user.friends.pluck(:id) + current_user.friends_who_added_me.pluck(:id)
    HappyThing.where(user_id: friend_ids << current_user.id).reorder(start_time: :desc)
  end
end
