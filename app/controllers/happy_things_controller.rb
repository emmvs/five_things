class HappyThingsController < ApplicationController
  before_action :set_happy_thing, only: [:show, :edit, :update, :destroy]

  def index
    @happy_things = HappyThing.all
    @should_render_navbar = true
  end

  def show
  end

  def new
    @happy_thing = HappyThing.new
  end

  def create
    # @happy_thing = HappyThing.new(happy_thing_params)
    # @happy_thing.user = current_user
    @happy_thing = current_user.happy_things.build(happy_thing_params)

    if @happy_thing.save!
      redirect_to happy_things_path, notice: "Yay! 🎉 Happy Thing was successfully created."
    else
      redirect_to new_happy_thing_path, alert: @happy_thing.errors.full_messages.join(", ")
    end
  end

  def edit
  end

  def update
    if @happy_thing.update(happy_thing_params)
      redirect_to happy_things_path, notice: "Yay! 🎉 Happy Thing was successfully updated. 🥰"
    else
      redirect_to new_happy_thing_path, alert: @happy_thing.errors.full_messages.join(", ")
    end
  end

  def destroy
    @happy_thing.destroy
    redirect_to happy_things_path, notice: "Oh no! Happy Thing was destroyed. 😕"
  end

  private

  def set_happy_thing
    @happy_thing = HappyThing.find(params[:id])
  end

  def happy_thing_params
    params.require(:happy_thing).permit(:title, :body, :status, :date, :time)
  end
end
