require_relative 'live_helper'

# The calendar, the home page and the three access pages: five requests.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_pages_are_readable
    DepotUk::Internal::Website.open do |website|
      assert_calendar_shape(website.calendar)
      assert_titles_shape(website.send(:get, Website::HOME_PATH))
      Website::ACCESS_PAGES.each_key { |path| assert_access_shape(website.send(:get, path)) }
    end
  end
end
