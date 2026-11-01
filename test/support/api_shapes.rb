# The parts of the website's pages the gem reads. Checked against the trimmed
# fixtures and, in the live suite, against real pages held only in memory.
module ApiShapes
  Calendar = DepotUk::Internal::Parser::Calendar
  Website = DepotUk::Internal::Website

  BOOKING_URL = %r{\Ahttps://lewesdepot\.org/film/[a-z0-9-]+/booknow/\d+\z}
  DETAIL_LINE = /\A(?:Cert: .+|Screen \d+(?: &amp; \d+)*|Studio|Depot event)\z/

  private

  def assert_calendar_shape(html)
    days = html.scan(Calendar::DAY)
    refute_empty days
    days.each do |weekday, day, month|
      assert_includes Date::ABBR_DAYNAMES, weekday
      assert_includes Date::MONTHNAMES, month
      assert_includes 1..31, day.to_i
    end

    listings = html.scan(Calendar::LISTING)
    refute_empty listings
    listings.each { |listing| assert_listing_shape(*listing) }
    assert_equal html.scan(Website::PERFORMANCE_ID).size, listings.sum { |listing| listing[3].scan(Calendar::PERFORMANCE).size }
  end

  def assert_listing_shape(slug, heading, details, buttons)
    assert_match(/\A[a-z0-9-]+\z/, slug)
    refute_empty heading.strip
    details.split(Calendar::LINE_BREAK).map(&:strip).reject(&:empty?).each do |line|
      assert_match DETAIL_LINE, line
    end
    refute_empty buttons.scan(Calendar::PERFORMANCE)
  end

  def assert_titles_shape(html)
    titles = html[Website::FILM_SELECT, 1].to_s.scan(Website::FILM_OPTION)
    refute_empty titles
  end

  # A page may list nothing, when no performance of its kind is coming up
  def assert_access_shape(html)
    buttons = html.scan(/data-remote="[^"]*perf-popup\.php\?id=\d+"[^>]*class="[^"]*btn-perf/)
    assert_equal html.scan(Website::PERFORMANCE_ID).size, buttons.size
  end
end
