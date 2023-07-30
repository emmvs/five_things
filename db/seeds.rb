# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all
Thing.destroy_all

puts "Creating Users ..."

lea = User.create(
  first_name: 'Lea',
  last_name: 'Balkenhol',
  email: 'lea.balkenhol@outlook.de'
)

emma = User.create(
  first_name: 'Emma',
  last_name: 'Rünzel',
  email: 'emma@test.com'
)

puts "Creating Things ..."

thing_one = Thing.create(
  date: DateTime.new(2023,9,1,17),
  first: '1. Coffee in the morning',
  second: '2. Three cats looking at me with big eyes',
  third: '3. Message from Lea',
  forth: '4. Tea with lemon',
  fifth: '5. Hugging someone after they lost somebody',
  user_id: emma.id
)

thing_two = Thing.create(
  date: DateTime.new(2023,9,1,17),
  first: '1. Run in the morning',
  second: '2. One dog looking at me with big eyes',
  third: '3. Message from Emma',
  forth: '4. Black Tea',
  fifth: '5. Hugging someone after a long day',
  user_id: lea.id
)

puts "Done ✅"
