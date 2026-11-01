require_relative '../../../../test_helper'

class DepotUk::Internal::Parser::CalendarTest < Minitest::Test
  include FixturesHelper

  NEAR = Date.new(2026, 11, 1)

  def test_entries_are_film_performances_in_calendar_order
    entries = entries_in(read_fixture('calendar.html'))

    assert_equal 41, entries.size
    assert_equal %w(40631100 the-devils The\ Devils), entries.first.to_h.values_at(:id, :slug, :heading)
  end

  def test_shortened_headings_are_kept_as_they_are
    entry = entries_in(read_fixture('calendar.html')).detect { |e| e.id == '40631087' }

    assert_equal 'Parent & Baby ONLY:...', entry.heading
  end

  def test_years_come_from_the_weekday
    assert_equal Date.new(2027, 1, 19), only_entry(day('Tue', '19 January')).date
    assert_equal Date.new(2026, 11, 1), only_entry(day('Sun', '1 November')).date
  end

  def test_leap_days_are_read
    entry = DepotUk::Internal::Parser::Calendar.new(day('Tue', '29 February'), near: Date.new(2027, 6, 1)).entries.first

    assert_equal Date.new(2028, 2, 29), entry.date
  end

  def test_days_that_match_no_year_are_skipped
    assert_empty entries_in(day('Fri', '1 November'))
    assert_empty entries_in(day('Sun', '1 Brumaire'))
  end

  def test_listings_before_any_day_are_skipped
    assert_empty entries_in(listing)
  end

  def test_times_are_london_times_in_utc
    assert_equal Time.utc(2026, 11, 1, 17, 30), only_entry(day('Sun', '1 November')).starting_at
    assert_equal Time.utc(2027, 5, 30, 16, 30), only_entry(day('Sun', '30 May')).starting_at
  end

  def test_only_numbered_screens_are_films
    assert_empty entries_in(day('Sun', '1 November', details: 'Depot event<br/>'))
    assert_empty entries_in(day('Sun', '1 November', details: 'Cert: 18<br/>Studio<br/>'))
    refute_empty entries_in(day('Sun', '1 November', details: 'Cert: U<br/>Screen 2 &amp; 3<br/>'))
  end

  private

  def entries_in(html)
    DepotUk::Internal::Parser::Calendar.new(html, near: NEAR).entries
  end

  def only_entry(html)
    entries = entries_in(html)
    assert_equal 1, entries.size
    entries.first
  end

  def day(weekday, date, details: 'Cert: 18<br/>Screen 3<br/>')
    %(<span class="cal-day-films"><div class="film-calendar-day bg-scheme"><div class="contents"><h2>#{weekday}<br>#{date}</h2></div></div>#{listing(details)}</span>)
  end

  def listing(details = 'Cert: 18<br/>Screen 3<br/>')
    %(<div class="film-calendar-film" data-sid="1" data-link="/film/the-devils" ><div class="contents"><h3>The Devils</h3>#{details}) +
      %(<div class="calendar-perf-buttons"><a data-remote="/wp-content/themes/lewesdepot/perf-popup.php?id=1" class="btn-depot bold btn-perf" data-toggle="modal" data-target="#perfModal" >17:30</a></div></div></div>)
  end
end
