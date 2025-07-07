require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do # rubocop:disable Metrics/BlockLength
  let(:user) { create(:user) }

  before do
    sign_in user
  end
  describe 'GET /' do # rubocop:disable Metrics/BlockLength
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

    it 'orders happy things by date by year descending for same month/day' do
      friend = create(:user)
      create(:friendship, user:, friend:)
      today = Date.current

      this_year_thing = create(:happy_thing, user:, start_time: today)
      last_year_thing = create(:happy_thing, user:, start_time: 1.year.ago)
      last_year_thing_two = create(:happy_thing, user:, start_time: 1.year.ago)
      two_years_ago_thing = create(:happy_thing, user:, start_time: 2.years.ago)

      friend_last_year_thing = create(:happy_thing, user: friend, start_time: 1.year.ago)

      different_day_thing = create(:happy_thing, user:, start_time: 1.day.ago)

      get root_path

      happy_things_by_date = assigns(:happy_things_by_date)

      # expect:
      # {
      #   1.year.ago.year => { user => [last_year_thing, last_year_thing_two], friend => [friend_last_year_thing] },
      #   2.years.ago.year => { user => [two_years_ago_thing] }
      # }

      expect(happy_things_by_date.keys).to eq([1.year.ago.year, 2.years.ago.year])

      expect(happy_things_by_date[1.year.ago.year][user]).to eq([last_year_thing, last_year_thing_two])
      expect(happy_things_by_date[1.year.ago.year][friend]).to eq([friend_last_year_thing])
      expect(happy_things_by_date[2.years.ago.year][user]).to eq([two_years_ago_thing])

      expect(happy_things_by_date[1.year.ago.year].keys).to eq([user, friend])

      happy_things_by_date_flattened = happy_things_by_date.map { |_, user_hash| user_hash.values.flatten }.flatten
      expect(happy_things_by_date_flattened).not_to include(different_day_thing)
      expect(happy_things_by_date_flattened).not_to include(this_year_thing)
    end
  end
end
