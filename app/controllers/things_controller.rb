class ThingsController < ApplicationController
  def index
    @things = Thing.all
  end

  def show
    @thing = Thing.find(params[:id])
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

end
