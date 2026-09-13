# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EssenceMailer, type: :mailer do
  describe '#confirmation' do
    let(:subscriber) { create(:essence_subscriber, locale: 'en') }

    it 'sends a confirmation email with an accept link' do
      mail = described_class.confirmation(subscriber)

      expect(mail.to).to eq([subscriber.email])
      expect(mail.subject).to eq(I18n.t('essence.mailer.confirmation_subject'))
      expect(mail.body.encoded).to include('the_essence/confirm')
    end

    it 'uses the subscriber locale' do
      subscriber.update!(locale: 'de')

      mail = described_class.confirmation(subscriber)

      expect(mail.subject).to eq(I18n.t('essence.mailer.confirmation_subject', locale: :de))
    end
  end
end
