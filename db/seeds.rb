# frozen_string_literal: true

# Seed data for 5 Things App

require 'faker'

# Clean data
if Rails.env.development?
  GroupMembership.destroy_all
  HappyThing.destroy_all
  Friendship.destroy_all
  User.destroy_all
  Category.destroy_all
  puts "Let's clean this mess up 🧼"
end

EMOJIS = %w[🦊 🐝 🦙 🐳 🐼 🐧 🐨 🐰 🦄 🐯 🐥 🦩 🐺 🪐 🎈 🎨 🎵 🎮 📚 🍕 🍣 🍩].freeze

# Create Users
users = []
users << User.create!(
  first_name: 'Leababy',
  last_name: 'Balkenhol',
  email: 'lea@test.com',
  emoji: '👻',
  password: 'G1ggl3!Fluff',
  confirmed_at: Time.current
)

users << User.create!(
  first_name: 'Emmsiboom',
  last_name: 'Rünzel',
  email: 'emma@test.com',
  emoji: EMOJIS.sample,
  password: 'G1ggl3!Fluff',
  confirmed_at: Time.current
)

puts "Created #{users.first.first_name} 💁🏻‍♀️ & #{users.last.first_name} 🤷🏼‍♀️"

# Create additional users
more_users = %w[Joshy Nadieschka Hansibaby Juanfairy Nomnom Santimaus Florenke Mäx].map do |name|
  User.create!(
    first_name: name,
    last_name: 'Testy',
    email: "#{name.downcase}@test.com",
    emoji: EMOJIS.sample,
    password: 'G1ggl3!Fluff',
    confirmed_at: Time.current
  )
end

puts "Created users: #{more_users.map(&:first_name).join(', ')} ✅"

all_users = User.all

# Helper to look up users by name
def u(name)
  User.find_by(first_name: name)
end

# -- Accepted Friendships for Emma --
Friendship.create!(user: u('Emmsiboom'), friend: u('Joshy'), accepted: true)
Friendship.create!(user: u('Joshy'), friend: u('Emmsiboom'), accepted: true)

Friendship.create!(user: u('Emmsiboom'), friend: u('Hansibaby'), accepted: true)
Friendship.create!(user: u('Hansibaby'), friend: u('Emmsiboom'), accepted: true)

Friendship.create!(user: u('Emmsiboom'), friend: u('Juanfairy'), accepted: true)
Friendship.create!(user: u('Juanfairy'), friend: u('Emmsiboom'), accepted: true)

# -- Pending incoming requests to Emma --
Friendship.create!(user: u('Mäx'), friend: u('Emmsiboom'), accepted: false)
Friendship.create!(user: u('Santimaus'), friend: u('Emmsiboom'), accepted: false)

# -- Emma sends a request to Florenke --
Friendship.create!(user: u('Emmsiboom'), friend: u('Florenke'), accepted: false)

# -- Other friendships --
Friendship.create!(user: u('Joshy'), friend: u('Hansibaby'), accepted: true)
Friendship.create!(user: u('Hansibaby'), friend: u('Joshy'), accepted: true)

Friendship.create!(user: u('Juanfairy'), friend: u('Santimaus'), accepted: true)
Friendship.create!(user: u('Santimaus'), friend: u('Juanfairy'), accepted: true)

Friendship.create!(user: u('Mäx'), friend: u('Joshy'), accepted: false)
Friendship.create!(user: u('Juanfairy'), friend: u('Mäx'), accepted: false)

puts 'Friendships created 🤝 (some still pending...)'

# Create Groups
emma = u('Emmsiboom')
lea  = u('Leababy')

favorites = emma.groups.find_or_create_by!(name: 'Favorites')
friends_group = emma.groups.find_or_create_by!(name: 'Friends')

# Add Lea to Favorites
favorites.group_memberships.create!(friend: lea)

# Add a few users to the Friends group
[u('Joshy'), u('Santimaus'), u('Nomnom')].each do |friend|
  friends_group.group_memberships.create!(friend:)
end

puts "Emma's groups created 🎉"
puts "Favorites: #{favorites.friends.pluck(:first_name).join(', ')}"
puts "Friends: #{friends_group.friends.pluck(:first_name).join(', ')}"

# Create Categories
category_names = %w[General Family Friends Nature Fitness Celebrations Spiritual Hobby]
categories = category_names.map { |name| Category.find_or_create_by!(name:) }
puts "#{categories.size} Categories created! 👻"

# Create 1–5 HappyThings per user for each of today, and same date 1–5 years ago
all_users.each do |user|
  (0..5).each do |year_offset|
    date = Time.current - year_offset.years
    rand(1..3).times do
      HappyThing.create!(
        user:,
        title: Faker::Hobby.activity,
        body: Faker::Lorem.paragraph(sentence_count: 2),
        start_time: date.change(hour: rand(8..22)),
        place: Faker::Address.city,
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude,
        share_location: [true, false].sample,
        status: [0, 1, 2].sample,
        category: categories.sample,
        created_at: date,
        updated_at: date
      )
    end
  end
end

puts 'HappyThings created for today and past 1–5 years 🎉'
puts 'Seeding complete ✅'
