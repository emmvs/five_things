class HappyThingsController < ApplicationController
  before_action :set_happy_thing, only: [:show, :edit, :update, :destroy]

  def index
    @happy_things = HappyThing.all
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
      redirect_to happy_things_path, notice: "Happy Thing was successfully created."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @happy_thing.update(happy_thing_params)
      redirect_to happy_things_path, notice: "Happy Thing was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @happy_thing.destroy
    redirect_to happy_things_path, notice: "Happy Thing was successfully destroyed."
  end

  private

  def set_happy_thing
    @happy_thing = HappyThing.find(params[:id])
  end

  def happy_thing_params
    params.require(:happy_thing).permit(:title, :body, :status, :date, :time)
  end
end
