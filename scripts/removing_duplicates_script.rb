# frozen_string_literal: true

# This script is designed to deduplicate HappyThing records within a specified date range by ensuring that only one
# unique HappyThing with the same title exists per day.

# Fetches HappyThing records within the specified date range.
# @param start_date [Date] - The starting date of the range to fetch records.
# @param end_date [Date] - The ending date of the range to fetch records.
# @return [ActiveRecord::Relation] - Returns the ActiveRecord relation containing HappyThing records within the range.
def fetch_happy_things(start_date, end_date)
  HappyThing.where(start_time: start_date..end_date)
end

# Processes the fetched HappyThing records to remove duplicates based on title, keeping only one unique title per day.
# @param start_date [Date] - The start date for the deduplication process.
# @param end_date [Date] - The end date for the deduplication process.
# @return [Array] - Returns an array containing the count of HappyThings after deduplication and a completion message.
def process_happy_things(start_date, end_date)
  happy_things = fetch_happy_things(start_date, end_date)

  p HappyThing.count

  # Retrieve IDs of HappyThings that should be kept (one per unique title)
  keeper_ids = happy_things.uniq(&:title).pluck(:id)

  # Iterate through all fetched HappyThings and destroy those not in the keeper_ids list
  happy_things.each do |ht|
    ht.destroy unless keeper_ids.include?(ht.id)
  end

  [happy_things.count, 'Done!']
end

# Example usage of the script with specified date range for all time
puts process_happy_things(Date.new(2020, 1, 1), Date.new(2024, 5, 4))

p HappyThing.count
