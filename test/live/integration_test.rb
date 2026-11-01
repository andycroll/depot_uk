require_relative 'live_helper'

class LiveIntegrationTest < Minitest::Test
  def test_depot_has_performances
    today = Date.today
    performances = DepotUk::Performance.at('deplew', from: today, to: today + 365)

    assert(performances.all? { |p| p.instance_of?(DepotUk::Performance) })
    assert_operator performances.count, :>, 20
    assert_operator performances.map(&:showing_on).max, :>, today + 30
    assert(performances.all? { |p| p.booking_url.match?(ApiShapes::BOOKING_URL) })
    refute(performances.any? { |p| p.film_name.end_with?(DepotUk::Internal::Parser::Showtime::TRUNCATION) })
    assert(performances.any?(&:subtitled?))
  end
end
