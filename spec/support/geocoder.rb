# frozen_string_literal: true

require 'geocoder'

Geocoder.configure(lookup: :test)

# Default for any place string
Geocoder::Lookup::Test.set_default_stub(
  [{ 'coordinates' => [52.5173885, 13.3951309], 'address' => 'Berlin' }]
)

# Explicit Berlin stub for clarity
Geocoder::Lookup::Test.add_stub(
  'Berlin',
  [{ 'coordinates' => [52.5173885, 13.3951309], 'address' => 'Berlin' }]
)
