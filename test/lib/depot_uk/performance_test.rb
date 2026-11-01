require_relative '../../test_helper'

class DepotUk::PerformanceTest < Minitest::Test
  include WebsiteStubs

  FROM = Date.new(2026, 11, 1)
  BOOKING = 'https://lewesdepot.org/film/'.freeze

  def setup
    stub_website
  end

  def test_at_returns_film_performances_in_time_order
    performances = performances_at('deplew')

    assert(performances.all? { |p| p.instance_of?(DepotUk::Performance) })
    assert_equal 41, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_every_date_from_five_requests
    performances_at('DEPLEW')

    PAGES.each_key { |url| assert_requested :get, url, times: 1 }
  end

  def test_at_keeps_to_the_range
    assert_equal 13, DepotUk::Performance.at('deplew', from: FROM + 1, to: FROM + 1).count
  end

  def test_a_range_without_performances_reads_only_the_calendar
    assert_empty DepotUk::Performance.at('deplew', from: Date.new(2027, 7, 1), to: Date.new(2027, 7, 31))
    assert_requested :get, CALENDAR, times: 1
    assert_not_requested :get, HOME
  end

  def test_at_sets_cinema_details
    performances = performances_at('deplew')

    assert_equal ['deplew'], performances.map(&:cinema_id).uniq
    assert_equal ['Depot'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at('deplew').first

    assert_equal 'The Devils', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 11, 1, 17, 30), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_equal %w(subtitled), performance.variant
    assert_nil performance.festival
    assert_equal "#{BOOKING}the-devils/booknow/40631100", performance.booking_url
  end

  def test_summer_times_are_converted_to_utc
    performance = performances_at('deplew').last

    assert_equal 'Royal Ballet and Opera: Romeo & Juliet', performance.film_name
    assert_equal Time.utc(2027, 5, 30, 13, 0), performance.starting_at
    assert_equal %w(arts), performance.variant
  end

  def test_events_and_workshops_are_dropped
    slugs = performances_at('deplew').map { |p| p.booking_url[%r{/film/([^/]+)/}, 1] }

    refute(slugs.any? { |slug| slug.start_with?('fast-furious', 'wines', 'making-your') })
  end

  def test_shortened_headings_have_full_titles
    assert_equal 'Ghosts: The Possession of Button House', find('40631075').film_name
    assert_equal 'Exhibition on Screen: Renoir & Love', find('40629079').film_name
    assert_equal 'Exhibition on Screen: MONET', find('40629077').film_name
  end

  def test_parent_and_baby_screenings
    performance = find('40631087')

    assert_equal 'Wicker', performance.film_name
    assert_equal %w(baby relaxed subtitled), performance.variant
  end

  def test_autism_friendly_screenings_are_relaxed
    assert_equal %w(arts kids relaxed), find('40630531').variant
  end

  def test_cinecity_screenings_are_a_festival
    performance = find('40630541')

    assert_equal 'The Archivist', performance.film_name
    assert_equal Cinebase::Festival.new(name: 'Cinecity', year: 2026), performance.festival
  end

  def test_previews_name_the_film
    assert_equal 'Dune: Part Three', find('40629921').film_name
  end

  def test_unknown_cinema_makes_no_request
    assert_empty DepotUk::Performance.at('zzz', from: FROM, to: FROM)
    assert_not_requested :get, /lewesdepot/
  end

  def test_to_must_not_precede_from
    assert_raises(ArgumentError) { DepotUk::Performance.at('deplew', from: FROM, to: FROM - 1) }
  end

  private

  def performances_at(cinema_id)
    DepotUk::Performance.at(cinema_id, from: FROM, to: FROM >> 12)
  end

  def find(id)
    performances_at('deplew').detect { |p| p.booking_url.end_with?("/#{id}") }
  end
end
