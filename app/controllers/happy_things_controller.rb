class HappyThingsController < ApplicationController
  before_action :set_happy_thing, only: [:show, :edit, :update, :destroy]

  def index
    @should_render_navbar = true

    @happy_thing = HappyThing.new
    @happy_things = HappyThing.all.order(start_time: :asc)
  end

  def show; end

  def new
    @happy_thing = HappyThing.new
  end

  def create
    # @happy_thing = HappyThing.new(happy_thing_params)
    # @happy_thing.user = current_user
    @happy_thing = current_user.happy_things.build(happy_thing_params)

    if @happy_thing.save!
      redirect_to root_path, notice: "Yay! 🎉 Happy Thing was successfully created."
    else
      render :new, status: 422
    end
  end

  def edit; end

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
    @words_for_wordcloud = get_aggregated_words(current_user, 50)
  end

  def show_by_date
    @date = Date.parse(params[:date])
    @happy_things = HappyThing.where(start_time: @date.beginning_of_day..@date.end_of_day)
  end

  def old_happy_thing
    @old_happy_thing = current_user.happy_things.new
  end

  def create_old_happy_thing
    @old_happy_thing = current_user.happy_things.build(happy_thing_params)
    if @old_happy_thing.save!
      redirect_to root_path, notice: "Yay! 🎉 Old Happy Thing was successfully created."
    else
      render :old, status: 422
    end
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

  def get_aggregated_words(user, word_limit)
    one_year_ago = Date.today - 1.year
    happy_things = happy_things_by_period(user, one_year_ago..Date.today)

    all_titles = happy_things.map(&:title).join(' ')
    words = clean_and_extract_words(all_titles)

    word_count = words.each_with_object(Hash.new(0)) { |word, counts| counts[word] += 1 }
    sorted_words = word_count.sort_by { |word, count| -count }.map(&:first)
    sorted_words.first(word_limit)
  end

  def happy_things_by_period(user, period)
    user.happy_things.where(start_time: period)
  end

  def clean_and_extract_words(text)
    words = text.downcase.gsub(/[^a-z0-2\s]/i, '').split
    stop_words = %w[und weil mit ohne the and but if or on as etc of else w to sth i]
    words.reject { |word| stop_words.include?(word) }
  end
end
