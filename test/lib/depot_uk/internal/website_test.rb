require_relative '../../../test_helper'

class DepotUk::Internal::WebsiteTest < Minitest::Test
  include WebsiteStubs

  def setup
    @website = DepotUk::Internal::Website.new
  end

  def teardown
    @website.close
    super
  end

  def test_titles_are_in_full
    stub_website

    titles = @website.titles

    assert_equal 67, titles.size
    assert_includes titles, 'Ghosts: The Possession of Button House'
    assert_includes titles, 'Andrew Lloyd Webber’s Starlight Express – Live On Stage'
  end

  def test_variants_come_from_every_access_page
    stub_website

    variants = @website.variants

    assert_equal %w(subtitled relaxed), variants.fetch('40631087')
    assert_equal %w(relaxed), variants.fetch('40630531')
    assert_equal %w(subtitled), variants.fetch('40631100')
  end

  def test_open_yields_a_website_and_closes_it
    stub_website

    calendar = DepotUk::Internal::Website.open(&:calendar)

    assert_includes calendar, 'cal-day-films'
    assert_requested :get, CALENDAR, headers: { 'User-Agent' => DepotUk::Internal::Website::USER_AGENT }
  end

  def test_requests_share_one_connection
    stub_website
    starts = 0
    start = Net::HTTP.method(:start)

    Net::HTTP.stub(:start, ->(*args, **options) { starts += 1; start.call(*args, **options) }) do
      @website.calendar
      @website.titles
    end

    assert_equal 1, starts
  end

  def test_errors_name_the_status_but_not_the_body
    stub_request(:get, CALENDAR).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { @website.calendar }
    assert_equal 'HTTP error 500 from lewesdepot.org', error.message
  end

  def test_transient_errors_are_retried
    stub_request(:get, CALENDAR).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: 'calendar')

    Cinebase::Http.stub(:pause, nil) { @website.calendar }

    assert_requested :get, CALENDAR, times: 2
  end
end
