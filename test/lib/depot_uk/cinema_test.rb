require_relative '../../test_helper'

class DepotUk::CinemaTest < Minitest::Test
  def test_all_returns_depot_without_requests
    cinemas = DepotUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(DepotUk::Cinema) })
    assert_equal %w(deplew), cinemas.map(&:id)
  end

  def test_new_stores_downcase_string_id
    assert_equal 'deplew', DepotUk::Cinema.new('DEPLEW').id
  end

  def test_name_full_name_and_slug
    cinema = DepotUk::Cinema.new('deplew')

    assert_equal 'Depot', cinema.name
    assert_equal 'Independent Depot', cinema.full_name
    assert_equal 'independent-depot', cinema.slug
  end

  def test_brand
    assert_equal 'Independent', DepotUk::Cinema.new('deplew').brand
  end

  def test_url
    assert_equal 'https://lewesdepot.org', DepotUk::Cinema.new('deplew').url
  end

  def test_adr
    expected = {
      street_address:   'Pinwell Road',
      extended_address: nil,
      locality:         'Lewes',
      region:           'East Sussex',
      postal_code:      'BN7 2JS',
      country_name:     'United Kingdom'
    }

    assert_equal expected, DepotUk::Cinema.new('deplew').adr
  end

  def test_coordinates
    cinema = DepotUk::Cinema.new('deplew')

    assert_in_delta 50.8715417, cinema.latitude
    assert_in_delta 0.0120094, cinema.longitude
  end

  def test_unknown_cinema_has_no_details
    cinema = DepotUk::Cinema.new('zzz')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    assert_nil cinema.latitude
  end
end
