# Seed data for Five Things App

# Gems
# require "faker"

# Clear existing data
HappyThing.destroy_all
User.destroy_all

# Create Users
users = []
users << User.create(
  first_name: 'Lea',
  last_name: 'Balkenhol',
  email: 'lea.balkenhol@outlook.de',
  password: 'beehappy'
)
users << User.create(
  first_name: 'Emma',
  last_name: 'Rünzel',
  email: 'emma@test.com',
  password: '123456'
)
puts "Create #{users.first.first_name} 💁🏻‍♀️ & #{users.last.first_name} 🤷🏼‍♀️"


# Create HappyThings
happy_things = []
users.each do |user|
  5.times do |i|
    happy_things << HappyThing.create(
      user: user,
      body: "Happy Thing #{i + 1} for #{user.first_name} on Day #{i + 1}"
    )
  end
end
puts "Create HappyThings 🙌 🙌 🙌 🙌 🙌"

puts "\n== Seeding the database with fixtures, too =="
system("bin/rails db:fixtures:load")

puts "Done ✅"
