require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :chrome, screen_size: [1400, 1400] # With openening Browser
  driven_by :selenium, using: :headless_firefox, screen_size: [1400, 1400] # Without openening Browser
end
