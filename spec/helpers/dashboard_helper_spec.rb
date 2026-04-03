# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardHelper, type: :helper do
  describe '#time_based_greeting' do
    before { I18n.locale = :en }

    it 'does not duplicate commas when the name has a leading comma' do
      allow(helper).to receive(:current_hour_in).and_return(8)

      expect(helper.time_based_greeting(', Emma')).to eq(
        I18n.t('dashboard.greetings.good_morning', name: 'Emma')
      )
    end

    it 'strips trailing commas from the name' do
      allow(helper).to receive(:current_hour_in).and_return(8)

      expect(helper.time_based_greeting('Emma,,')).to eq(
        I18n.t('dashboard.greetings.good_morning', name: 'Emma')
      )
    end
  end
end
