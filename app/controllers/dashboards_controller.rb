class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true

    @happy_thing = HappyThing.new
    @happy_things = HappyThing.all
  end

  def get_poem
    author = params[:author]
    @random_poem = PoetryService.get_random_poem_by_author(author)
    render 'index'
  end
end
