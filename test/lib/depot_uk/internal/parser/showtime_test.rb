require_relative '../../../../test_helper'

class DepotUk::Internal::Parser::ShowtimeTest < Minitest::Test
  Entry = DepotUk::Internal::Parser::Calendar::Entry
  TITLES = ['Exhibition on Screen: MONET', 'Exhibition on Screen: Renoir & Love', 'Fjord'].freeze

  def test_booking_url_uses_the_film_slug
    assert_equal 'https://lewesdepot.org/film/fjord/booknow/7', to_hash('Fjord')[:booking_url]
  end

  def test_shortened_headings_match_the_only_title_they_start
    assert_equal 'Fjord', to_hash('Fj...')[:film_name]
  end

  def test_shortened_headings_matching_several_titles_use_the_slug
    assert_equal 'Exhibition on Screen: Monet',
                 to_hash('Exhibition on Screen:...', slug: 'exhibition-on-screen-monet')[:film_name]
  end

  def test_unmatched_shortened_headings_keep_their_start
    assert_equal 'Exhibition on Screen:', to_hash('Exhibition on Screen:...', slug: 'gone')[:film_name]
    assert_equal 'Unlisted', to_hash('Unlisted...')[:film_name]
  end

  def test_variants_from_titles_and_access_pages
    assert_equal %w(q&a subtitled), to_hash('Fjord + Q&A', variants: %w(subtitled))[:variant]
    assert_equal %w(arts), to_hash('Hadestown: The Musical')[:variant]
    assert_equal %w(arts), to_hash('National Theatre Live: Golden Boy')[:variant]
    assert_equal %w(relaxed kids), to_hash('Sensory Friendly Cinema – Interactive family cinema screenings')[:variant]
  end

  def test_performances_read_variants_from_the_raw_title
    performance = DepotUk::Performance.new(to_hash('Relaxed Screening: Fjord').merge(cinema_id: 'deplew', cinema_name: 'Depot'))

    assert_equal 'Fjord', performance.film_name
    assert_equal %w(relaxed), performance.variant
  end

  def test_three_d_titles
    performance = to_hash('Avatar 3D')

    assert_equal '3d', performance[:dimension]
    assert_equal 'Avatar', performance[:film_name]
  end

  def test_film_years_from_titles
    assert_equal 1990, to_hash('Misery (1990)')[:film_year]
  end

  def test_festival_prefixes
    assert_equal Cinebase::Festival.new(name: 'UKJFF', year: 2026), to_hash('UKJFF - Fjord')[:festival]
  end

  def test_slug
    assert_equal 'de-gaulle-liberte', DepotUk::Internal::Parser::Showtime.slug('De Gaulle: Liberté')
    assert_equal 'andrew-lloyd-webbers-starlight-express-live-on-stage',
                 DepotUk::Internal::Parser::Showtime.slug('Andrew Lloyd Webber’s Starlight Express – Live On Stage')
    assert_equal 'rbo-gotterdammerung-opera', DepotUk::Internal::Parser::Showtime.slug('RBO: Götterdämmerung (Opera)')
  end

  private

  def to_hash(heading, slug: 'fjord', variants: [])
    entry = Entry.new(id: '7', slug: slug, heading: heading, date: Date.new(2026, 11, 13),
                      starting_at: Time.utc(2026, 11, 13, 17))
    DepotUk::Internal::Parser::Showtime.new(entry, titles: TITLES, variants: variants).to_hash
  end
end
