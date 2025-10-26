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
  { first_name: 'Leababy', last_name: 'Balkenhol', email: 'lea@test.com', emoji: '🦙' },
  { first_name: 'Emmsiboom', last_name: 'Rünzel', email: 'emma@test.com', emoji: '👻' },
  { first_name: 'Bruno-no-no', last_name: 'Thormählen', email: 'bruno@test.com', emoji: '🤗' }
].map do |attrs|
  User.create!(
    **attrs,
    password: 'G1ggl3!Fluff',
    confirmed_at: Time.current
  )
end

puts "Created main users: #{users.map(&:first_name).join(', ')}"

more_users = %w[Joshy Nadieschka Hansibaby Lisita Juanfairy Nomnom Santimaus Florenke Mäx].map do |name|
  User.create!(
    first_name: name,
    last_name: 'Testy',
    email: "#{name.downcase}@test.com",
    emoji: EMOJIS.sample,
    password: 'G1ggl3!Fluff',
    confirmed_at: Time.current
  )
end

puts "Created extra users: #{more_users.map(&:first_name).join(', ')}"

def u(name)
  User.find_by(first_name: name)
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

  (0..5).each do |year_offset|
    date = Time.current - year_offset.years
    count = rand(1..3)

    count.times do
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

    # puts "  • #{user.first_name}: #{count} happy things for #{date.year}"
    total_for_user += count
  end

  puts "✅ Created #{total_for_user} happy things for #{user.first_name} in total."
end

puts 'HappyThings created 🎉'
puts 'Seeding complete ✅'
