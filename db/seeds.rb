# frozen_string_literal: true

# Seed data for 5 Things App

require 'faker'

# Clean data
if Rails.env.development?
  HappyThing.destroy_all
  Friendship.destroy_all
  User.destroy_all
  Category.destroy_all
  puts "Let's clean this mess up 🧼"
end

EMOJIS = %w[🦊 🐝 🦙 🐳 🐼 🐧 🐨 🐰 🦄 🐯 🐥 🦩 🐺 🪐 🎈 🎨 🎵 🎮 📚 🍕 🍣 🍩]

# Create Users
users = []
users << User.create!(
  first_name: 'Leababy',
  last_name: 'Balkenhol',
  email: 'lea@test.com',
  emoji: "👻",
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

# Create Categories
category_names = %w[General Family Friends Nature Fitness Celebrations Spiritual Hobby]
categories = category_names.map { |name| Category.find_or_create_by!(name:) }
puts "#{categories.size} Categories created! 👻"

# Create 1–5 HappyThings per user for the last 30 days
all_users.each do |user|
  rand(1..5).times do
    day_offset = rand(0..30)
    created_day = Time.current - day_offset.days

    HappyThing.create!(
      user:,
      title: Faker::Hobby.activity,
      body: Faker::Lorem.paragraph(sentence_count: 2),
      start_time: created_day.change(hour: rand(8..22)),
      place: Faker::Address.city,
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      share_location: [true, false].sample,
      status: [0, 1, 2].sample,
      category: categories.sample,
      created_at: created_day,
      updated_at: created_day
    )
  end
end

puts 'HappyThings created for the past 30 days 🙌'
puts 'Seeding complete ✅'
