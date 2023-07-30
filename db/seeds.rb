# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

puts "Clean Database 🧼"
User.destroy_all
HappyThings.destroy_all

lea = User.create(
  first_name: 'Lea',
  last_name: 'Balkenhol',
  email: 'lea.balkenhol@outlook.de',
  password: '123456'
)

emma = User.create(
  first_name: 'Emma',
  last_name: 'Rünzel',
  email: 'emma@test.com',
  password: '123456'
)

puts "Create Users 🙌"

# Seed HappyThings for Lea for the last 5 days
5.times do |i|
  happy_thing = HappyThing.create(
    user: lea,
    content: "Theater spielen #{i + 1}!",
    date: Date.today - i,
    time: Time.now - (i * 2).hours
  )
end

# Seed HappyThings for Emma for the last 3 days
3.times do |i|
  happy_thing = HappyThing.create(
    user: emma,
    content: "Mit meinen Geschwistern sein #{i + 1}!",
    date: Date.today - i,
    time: Time.now - (i * 3).hours
  )
end

puts "Create HappyThings 🙌"
