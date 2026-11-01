require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_calendar_fixture_matches_shape
    assert_calendar_shape(read_fixture('calendar.html'))
  end

  def test_home_fixture_matches_shape
    assert_titles_shape(read_fixture('home.html'))
  end

  def test_access_fixtures_match_shape
    %w(descriptive-subtitles relaxed autism-friendly).each do |page|
      html = read_fixture("access/#{page}.html")

      assert_access_shape(html)
      refute_empty html.scan(Website::PERFORMANCE_ID), page
    end
  end
end
