# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.destroy_all

lea = User.create (
  first_name: 'Lea',
  last_name: 'Balkenhol',
  email: 'lea.balkenhol@outlook.de'
)

lea = User.create (
  first_name: 'Emma',
  last_name: 'Rünzel',
  email: 'emma@test.com'
)
