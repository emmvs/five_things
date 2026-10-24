# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarHelper, type: :helper do
  describe '#calendar_month' do
    it 'uses the start_date param' do
      helper.params[:start_date] = '2026-03-15'

      expect(helper.calendar_month).to eq(Date.new(2026, 3, 15))
    end

    it 'falls back to today without a valid date' do
      helper.params[:start_date] = 'not-a-date'

      expect(helper.calendar_month).to eq(Date.current)
    end
  end

  describe '#calendar_day_label' do
    it 'names the day and how many people added something' do
      date = Date.new(2026, 10, 24)

      expect(helper.calendar_day_label(date, [double, double])).to eq('Saturday, 24 October, 2 people')
    end
  end
end
