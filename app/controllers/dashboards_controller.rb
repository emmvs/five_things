class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true
    @happy_thing = HappyThing.new
    @happy_things = HappyThing.all
    @happy_things_bubbles = HappyThing.where(
      start_time: Time.zone.now.beginning_of_month.beginning_of_week..Time.zone.now.end_of_month.end_of_week
    )
    @random_poem = PoetryService.get_random_poem_by_author("Emily Dickinson")
  end

  # def retrieve_poem
  # @random_poem = PoetryService.get_random_poem_by_author("Emily Dickinson")
  #   render 'index'
  # end
end
