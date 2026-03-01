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

more_users = %w[Joshy Nadieschka Hansibaby Lisita Juanfairy Nomnom Santimaus Florenke Mäx].map do |user_name|
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
                     { user: u('Emmsiboom'), friend: u('Joshy'), accepted: true },
                     { user: u('Emmsiboom'), friend: u('Hansibaby'), accepted: true },
                     { user: u('Emmsiboom'), friend: u('Juanfairy'), accepted: true },
                     { user: u('Mäx'), friend: u('Emmsiboom'), accepted: false },
                     { user: u('Santimaus'), friend: u('Emmsiboom'), accepted: false },
                     { user: u('Emmsiboom'), friend: u('Florenke'), accepted: false },
                     { user: u('Joshy'), friend: u('Hansibaby'), accepted: true },
                     { user: u('Juanfairy'), friend: u('Santimaus'), accepted: true },
                     { user: u('Mäx'), friend: u('Joshy'), accepted: false },
                     { user: u('Juanfairy'), friend: u('Mäx'), accepted: false }
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
User.all.each do |user|
  total_for_user = 0
  today = Date.current

  # Create 1-3 happy things for today
  rand(1..3).times do
    HappyThing.create!(
      user:,
      title: Faker::Hobby.activity,
      body: Faker::Lorem.paragraph(sentence_count: 2),
      start_time: Time.current.change(hour: rand(8..22)),
      place: Faker::Address.city,
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      share_location: [true, false].sample,
      status: [0, 1, 2].sample,
      category: categories.sample
    )
    total_for_user += 1
  end

  # Create 1-3 happy things for exactly 1 year ago (same month/day)
  one_year_ago = today - 1.year
  rand(1..3).times do
    HappyThing.create!(
      user:,
      title: Faker::Hobby.activity,
      body: Faker::Lorem.paragraph(sentence_count: 2),
      start_time: one_year_ago.to_time.change(hour: rand(8..22)),
      place: Faker::Address.city,
      latitude: Faker::Address.latitude,
      longitude: Faker::Address.longitude,
      share_location: [true, false].sample,
      status: [0, 1, 2].sample,
      category: categories.sample,
      created_at: one_year_ago,
      updated_at: one_year_ago
    )
    total_for_user += 1
  end

  # Create 1-3 happy things for 1-5 years ago (same month/day)
  (2..5).each do |years_ago|
    years_ago_date = today - years_ago.years
    rand(1..3).times do
      HappyThing.create!(
        user:,
        title: Faker::Hobby.activity,
        body: Faker::Lorem.paragraph(sentence_count: 2),
        start_time: years_ago_date.to_time.change(hour: rand(8..22)),
        place: Faker::Address.city,
        latitude: Faker::Address.latitude,
        longitude: Faker::Address.longitude,
        share_location: [true, false].sample,
        status: [0, 1, 2].sample,
        category: categories.sample,
        created_at: years_ago_date,
        updated_at: years_ago_date
      )
      total_for_user += 1
    end

  end

  puts "✅ Created #{total_for_user} happy things for #{user.name} in total."
end

puts 'HappyThings created 🎉'
puts 'Seeding complete ✅'
