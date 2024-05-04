# frozen_string_literal: true

require 'date'

# Initialize variables
current_date = nil
current_user = nil
created_count = 0

# Read file and process HappyThings
happy_things_string = File.read('fuenf_dinge_2023.txt')
happy_things_string.each_line do |line|
  line.strip!
  case line
  when %r{^\d{2}/\d{2}/\d{4}$}
    current_date = Date.strptime(line, '%d/%m/%Y')
    p '🎯 DATE happened'
    p current_date
  when 'E:'
    p '👻 E happened'
    current_user = User.find_by(email: 'emma@ruenzel.de')
  when 'L:'
    p '👻 L happened'
    current_user = User.find_by(email: 'lea.balkenhol@outlook.de')
  else
    next if line.empty?
    next if current_user.nil?

    ht = HappyThing.create!(
      title: line,
      start_time: DateTime.new(current_date.year, current_date.month, current_date.day, 12, 0),
      user: current_user
    )
    p ht
    created_count += 1
  end
end

# Output results
puts "#{created_count} HappyThings created 👻"
puts 'Happy Things imported successfully! ✨'
