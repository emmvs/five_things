# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe '#happy_things_notification' do
    let(:user) { create(:user, email: 'test@example.com') }
    let(:mail) { described_class.happy_things_notification(user) }

    it 'renders the subject' do
      expect(mail.subject).to eq('Happy Things incoming!🎁')
    end

    it 'sends to the correct user' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['five@happythings.com'])
    end

    it 'includes user’s name or relevant info in body' do
      expect(mail.body.encoded).to include(user.name)
    end
  end

  describe '#confirmation_instructions' do
    let(:user) { create(:user, email: 'confirm@example.com') }

    it 'sends confirmation instructions' do
      mail = user.send_confirmation_instructions

      expect(mail.subject).to eq('Confirmation instructions 🫶🏻')
      expect(mail.to).to eq([user.email])
      expect(mail.body.encoded).to include(user.confirmation_token)
    end
  end
end
