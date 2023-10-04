class HappyThingsController < ApplicationController
  before_action :set_happy_thing, only: [:show, :edit, :update, :destroy]

  def index
    @should_render_navbar = true

    @happy_thing = HappyThing.new
    @happy_things = HappyThing.all
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
      redirect_to root_path, notice: "Yay! 🎉 Happy Thing was successfully updated. 🥰"
    else
      render :edit, status: 422
    end
  end

  def destroy
    @happy_thing.destroy
    redirect_to root_path, notice: "Oh no! Happy Thing was destroyed. 😕"
  end

  def show_by_date
    @date = Date.parse(params[:date])
    @happy_things = HappyThing.where(start_time: @date.beginning_of_day..@date.end_of_day)
  end

  private

  def set_happy_thing
    @happy_thing = HappyThing.find(params[:id])
  end

  def happy_thing_params
    params.require(:happy_thing).permit(:title, :body, :status, :date, :time)
  end
end
