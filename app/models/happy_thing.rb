class HappyThing < ApplicationRecord
  belongs_to :user
  validates :title, presence: true

  default_scope { order(created_at: :desc) }
  before_create :add_date_time_to_happy_thing, unless: :start_time_present?

  has_one_attached :photo

  def add_date_time_to_happy_thing
    self.start_time ||= DateTime.now
  end

  def ai_title
    Rails.cache.fetch("#{cache_key_with_version}/content") do
      client = OpenAI::Client.new
      chaptgpt_response = client.chat(
        parameters: {
          model: "gpt-4",
          messages: [{
            role: "user",
            content: "Give me a simple thing to do that would make someone happy who is suffering from depression. Give me only the title, without any of your own weird metaphors or answers like 'Here is a simple happy thing.' Please ensure that the things are unique and suitable for intelligent people who need their brains stimulated by good things. It should fit into a text like so: 'Something to make you happy is\n todo.'"}]
        })
      @ai_happy_thing = chaptgpt_response["choices"][0]["message"]["content"]
    end
  end

  private

  def start_time_present?
    start_time.present?
  end
end
