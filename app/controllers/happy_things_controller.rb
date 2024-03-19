class HappyThingsController < ApplicationController
  include WordAggregator

  before_action :set_happy_thing, only: [:show, :edit, :update, :destroy]

  def index
    @should_render_navbar = true

    @happy_thing = HappyThing.new
    @happy_things = happy_things_of_friends.page(params[:page]).per(10)
    # @happy_things = HappyThing.order(start_time: :asc).page(params[:page]).per(10)
  end

  def new
    @happy_thing = HappyThing.new
  end

  def create
    @happy_thing = current_user.happy_things.build(happy_thing_params)
    create_happy_thing(@happy_thing)
  end

  def update
    if @happy_thing.update(happy_thing_params)
      redirect_to root_path, notice: "Yay! 🎉 Happy Thing was updated 🥰"
    else
      render :edit, status: 422
    end
  end

  def destroy
    @happy_thing.destroy
    redirect_to root_path, notice: "Happy Thing was destroyed 😕"
  end

  def analytics
    @happy_count = HappyThing.where(user: current_user).size
    @words_for_wordcloud = WordAggregator.get_aggregated_words(current_user, 40)
  end

  def show_by_date
    @date = Date.parse(params[:date])
    friend_ids = current_user.friends.pluck(:id) + current_user.inverse_friends.pluck(:id)
    # @happy_things = HappyThing.where(start_time: @date.beginning_of_day..@date.end_of_day)
    @happy_things = HappyThing.where(user_id: friend_ids << current_user.id, start_time: @date.beginning_of_day..@date.end_of_day)
  end

  def old_happy_thing
    @old_happy_thing = current_user.happy_things.new
  end

  def create_old_happy_thing
    @old_happy_thing = current_user.happy_things.build(happy_thing_params)
    create_happy_thing(@old_happy_thing)
  end

  private

  def set_happy_thing
    @happy_thing = HappyThing.find(params[:id])
  end

  def happy_thing_params
    params.require(:happy_thing).permit(
      :title,
      :photo,
      :body,
      :status,
      :start_time
    )
  end

  def create_happy_thing(happy_thing)
    if happy_thing.save
      redirect_to root_path, notice: "Yay! 🎉 #{happy_thing.class} was successfully created."
    else
      render :new, status: 422
    end
  end

  def happy_things_of_friends
    friend_ids = current_user.friends.pluck(:id) + current_user.inverse_friends.pluck(:id)
    HappyThing.where(user_id: friend_ids << current_user.id).order(start_time: :asc)
  end
end
