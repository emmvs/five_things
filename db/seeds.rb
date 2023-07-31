# Seed data for Five Things App

# Gems
# require "faker"

# Clear existing data
Thing.destroy_all
User.destroy_all


# Create Users
users = []
users << User.create(
  first_name: 'Lea',
  last_name: 'Balkenhol',
  email: 'lea@test.com',
  password: 'password'
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
      body: "Happy Thing #{i + 1} for #{user.first_name} on Day #{i + 1}",
      date: Date.today - i,
      time: Time.now - (i * 2).hours
    )
  end
end
puts "Create HappyThings 🙌 🙌 🙌 🙌 🙌"

puts "Done ✅"
