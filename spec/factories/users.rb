# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { %w[Emmsi Leamaus Juanfairy].sample }
    email { Faker::Internet.unique.email }
    username { Faker::Internet.username }
    password { 'Secret_pa$$word_1' }
    emoji { '👻' }
    email_opt_in { false }
    location_opt_in { false }
    created_at { Time.zone.now }
    updated_at { Time.zone.now }
    confirmed_at { Time.zone.now }
  end

  factory :oauth_auth_hash, class: 'OmniAuth::AuthHash' do
    initialize_with do
      OmniAuth::AuthHash.new({
                               provider: 'google_oauth2',
                               uid: '123456789',
                               info: {
                                 name: 'Emma Who',
                                 email: 'emmazing@gmail.com'
                               }
                             })
    end
  end
end
