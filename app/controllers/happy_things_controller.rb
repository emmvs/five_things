class HappyThingsController < ApplicationController
  before_action :set_happy_thing, only: [:show, :edit, :update, :destroy]

  def index
    @should_render_navbar = true

    @happy_thing = HappyThing.new
<<<<<<< HEAD
    @happy_things = HappyThing.order(start_time: :asc)
=======
    @happy_things = HappyThing.all.order(start_time: :asc)
>>>>>>> b418fdb235d016a5b4a5f723e8103514e71d2899
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
end
