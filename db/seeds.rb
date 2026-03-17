# frozen_string_literal: true

require 'faker'
# Seed data for 5 Things App

if Rails.env.development?
  puts 'Cleaning DB… 🧼'

  GroupMembership.destroy_all
  HappyThing.destroy_all
  Friendship.destroy_all
  Group.destroy_all
  Category.destroy_all
  User.destroy_all
end

EMOJIS = %w[🦊 🐝 🦙 🐳 🐼 🐧 🐨 🐰 🦄 🐯 🐥 🦩 🐺 🪐 🎈 🎨 🎵 🎮 📚 🍕 🍣 🍩].freeze

# --- Users ---
users = [
  { name: 'Leababy', email: 'lea@test.com', emoji: '🦙' },
  { name: 'Emmsiboom', email: 'emma@test.com', emoji: '👻' },
  { name: 'Bruno-no-no', email: 'bruno@test.com', emoji: '🤗' }
].map do |attrs|
  User.create!(
    **attrs,
    password: 'G1ggl3!Fluff',
    confirmed_at: Time.current
  )
end

puts "Created main users: #{users.map(&:name).join(', ')}"

more_users = %w[Joshy Nadieschka Hansibaby Lisita Juanfairy Nomnom Santimaus Florenke Maex].map do |user_name|
  User.create!(
    name: user_name,
    email: "#{user_name.downcase}@test.com",
    emoji: EMOJIS.sample,
    password: 'G1ggl3!Fluff',
    confirmed_at: Time.current
  )
end

puts "Created extra users: #{more_users.map(&:name).join(', ')}"

def u(name)
  User.find_by(name:)
end

# --- Friendships ---
Friendship.create!([
                     { user: u('Emmsiboom'), friend: u('Leababy'), accepted: true },
                     { user: u('Emmsiboom'), friend: u('Bruno-no-no'), accepted: true },
                     { user: u('Leababy'), friend: u('Bruno-no-no'), accepted: true },
                     { user: u('Emmsiboom'), friend: u('Joshy'), accepted: true },
                     { user: u('Emmsiboom'), friend: u('Hansibaby'), accepted: true },
                     { user: u('Emmsiboom'), friend: u('Juanfairy'), accepted: true },
                     { user: u('Maex'), friend: u('Emmsiboom'), accepted: false },
                     { user: u('Santimaus'), friend: u('Emmsiboom'), accepted: false },
                     { user: u('Emmsiboom'), friend: u('Florenke'), accepted: false },
                     { user: u('Joshy'), friend: u('Hansibaby'), accepted: true },
                     { user: u('Juanfairy'), friend: u('Santimaus'), accepted: true },
                     { user: u('Maex'), friend: u('Joshy'), accepted: false },
                     { user: u('Juanfairy'), friend: u('Maex'), accepted: false }
                   ])

puts 'Friendships created 🤝'

# --- Groups ---
emma = u('Emmsiboom')
favorites = emma.groups.create!(name: 'Favorites')
friends_group = emma.groups.create!(name: 'Friends')

favorites.group_memberships.create!(friend: u('Leababy'))
[u('Joshy'), u('Santimaus'), u('Nomnom')].each do |friend|
  friends_group.group_memberships.create!(friend:)
end

puts 'Groups created 🎉'

# --- Categories ---
categories = %w[General Family Friends Nature Fitness Celebrations Spiritual Hobby].map do |name|
  Category.create!(name:)
end

puts "#{categories.size} categories created!"

# --- HappyThings ---
def create_happy_thing(user:, categories:, date: nil)
  start = (date || Date.current).in_time_zone.change(hour: rand(8..22))
  attrs = {
    user:, title: Faker::Hobby.activity, body: Faker::Lorem.paragraph(sentence_count: 2),
    start_time: start,
    place: Faker::Address.city, latitude: Faker::Address.latitude, longitude: Faker::Address.longitude,
    share_location: [true, false].sample, status: [0, 1, 2].sample, category: categories.sample
  }
  attrs.merge!(created_at: start, updated_at: start) if date
  HappyThing.create!(**attrs)
end

today = Date.current
lea = User.find_by(name: 'Leababy')
emma = User.find_by(name: 'Emmsiboom')
bruno = User.find_by(name: 'Bruno-no-no')
daily_users = [lea, emma]
friend_today = User.where(name: %w[Joshy Hansibaby Juanfairy]).sample

User.all.each do |user|
  count = 0

  # Today: one happy thing each for the 3 main users + 1 friend
  if [lea, emma, bruno, friend_today].include?(user)
    create_happy_thing(user:, categories:)
    count += 1
  end

  # Past 14 days
  if daily_users.include?(user)
    (1..14).each do |days_ago|
      n = rand(1..2)
      n.times { create_happy_thing(user:, categories:, date: today - days_ago.days) }
      count += n
    end
  elsif user == bruno
    (1..14).each do |days_ago|
      next if rand < 0.6

      create_happy_thing(user:, categories:, date: today - days_ago.days)
      count += 1
    end
  end

  # Historical data for everyone
  [1.year.ago.to_date, *(2..5).map { |y| today - y.years }].each do |date|
    count += rand(1..3).times.count { create_happy_thing(user:, categories:, date:) }
  end

  puts "✅ Created #{count} happy things for #{user.name} in total."
end

puts 'HappyThings created 🎉'
puts 'Seeding complete ✅'
