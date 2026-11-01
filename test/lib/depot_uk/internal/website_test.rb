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
    assert_equal 'Depot HTTP error 500', error.message
  end

  def test_redirects_are_not_followed
    stub_request(:get, CALENDAR).to_return(status: 301, headers: { 'Location' => 'https://lewesdepot.org/' })

    assert_raises(RuntimeError) { @website.calendar }
  end

  def test_transient_errors_are_retried
    stub_request(:get, CALENDAR).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: 'calendar')

    @website.stub(:sleep, nil) { @website.calendar }

    assert_requested :get, CALENDAR, times: 2
  end

  def test_retries_give_up
    stub_request(:get, CALENDAR).to_raise(Net::ReadTimeout)

    assert_raises(Net::ReadTimeout) { @website.stub(:sleep, nil) { @website.calendar } }
    assert_requested :get, CALENDAR, times: 3
  end
end
