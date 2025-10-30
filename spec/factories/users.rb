# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  email                  :string           default(""), not null
#  email_opt_in           :boolean          default(FALSE)
#  emoji                  :string
#  encrypted_password     :string           default(""), not null
#  first_name             :string
#  last_name              :string
#  location_opt_in        :boolean          default(FALSE)
#  provider               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  uid                    :string
#  unconfirmed_email      :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    first_name { %w[Emmsi Leamaus Juanfairy].sample }
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
