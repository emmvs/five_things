class DashboardsController < ApplicationController
  before_action :authenticate_user!

  def index
    @should_render_navbar = true
    @happy_thing = HappyThing.new
    @happy_things = HappyThing.all
    @happy_things_today = HappyThing.where(start_time: Date.today..Date.tomorrow).reverse.group_by(&:user)
    @happy_things_one_year_ago = HappyThing.where("DATE(start_time) = ?", 1.year.ago.to_date).order(created_at: :desc)

    @random_poem = fetch_daily_poem

    client = OpenAI::Client.new
      chaptgpt_response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{
            role: "user",
            content: "Give me a simple thing to do that would make someone happy who is sufferring with depression. Give me only the title of the happy thing, without any of your own answer like 'Here is a simple happy thing'. Please make sure that the things are special and good for intelligent people who love, literature, cute animals, being outside and being surround by loved ones. It should fit into a text like so: 'Something to make you happy is\n todo.'"}]
        })
      @ai_happy_thing = chaptgpt_response["choices"][0]["message"]["content"]
  end

  private

  def fetch_daily_poem
    Rails.cache.fetch("random_poem", expires_in: 24.hours) do
      PoetryService.get_random_poem
    end
  end
end
