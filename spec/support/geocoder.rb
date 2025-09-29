# frozen_string_literal: true
require 'geocoder'

Geocoder.configure(lookup: :test)

Geocoder::Lookup::Test.add_stub(
  'Berlin', [{ 'coordinates' => [52.510885, 13.3989367] }]
)
