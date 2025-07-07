require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end
  describe 'GET /' do
    it 'orders happy things by time of occurance over time of creation' do
      today_thing = create(:happy_thing,
                           title: 'Today thing',
                           user:)
      yesterday_thing = create(:happy_thing,
                               title: 'Yesterday thing',
                               user:,
                               start_time: Time.zone.now - 1.day)
      yesterday_thing_two = create(:happy_thing,
                                   title: 'Yesterday thing 2',
                                   user:,
                                   start_time: Time.zone.now - 1.day)
      today_thing_two = create(:happy_thing,
                               title: 'Today thing 2',
                               user:)
      get root_path

      last_two_days = assigns(:happy_things_of_the_last_two_days)[user]
      expect(last_two_days[0]).to eq(today_thing_two)
      expect(last_two_days[1]).to eq(today_thing)
      expect(last_two_days[2]).to eq(yesterday_thing_two)
      expect(last_two_days[3]).to eq(yesterday_thing)
    end
  end
end
