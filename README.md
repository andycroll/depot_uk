# DepotUk

A simple gem to pull the cinema and performances from the website of
[Depot](https://lewesdepot.org), the independent cinema in Lewes, and spit
out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'depot_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install depot_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing the parent
and baby, Knitflicks and See It First prefixes, the Cinecity suffix and
opera and ballet labels. Royal Ballet and Opera, National Theatre Live
and Exhibition on Screen series become the performance's `event`.

No token or setup is needed. The website runs WordPress with Jacro's
plugin, and tickets are sold through Jacro's booking site.

### Cinema

Depot is one venue, so the gem holds it: the address from the website's
travel page and the coordinates from OpenStreetMap. Its id is `'deplew'`,
the Jacro code in the website's booking links. Cinema methods make no
requests.

``` ruby
DepotUk::Cinema.all
#=> [<DepotUk::Cinema ...>]

cinema = DepotUk::Cinema.new('deplew')
#=> <DepotUk::Cinema ...>

cinema.adr
#=> {
  street_address:   'Pinwell Road',
  extended_address: nil,
  locality:         'Lewes',
  region:           'East Sussex',
  postal_code:      'BN7 2JS',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Independent'

cinema.name
#=> 'Depot'

cinema.latitude
#=> 50.8715417

cinema.url
#=> 'https://lewesdepot.org'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days.

The website's calendar holds every advertised date, so any range takes five
requests: the calendar, the home page for the full titles the calendar
shortens, and the descriptive subtitles, relaxed and autism friendly access
pages. A range with no performances takes one. The site is slow: expect
about five seconds.

``` ruby
DepotUk::Performance.at('deplew', from: Date.today, to: Date.today + 2)
#=> [<DepotUk::Performance ...>, <DepotUk::Performance ...>, ...]

performance = DepotUk::Performance.at('deplew').first
#=> <DepotUk::Performance ...>

performance.film_name
#=> 'Wicker' # from 'Parent & Baby ONLY: Wicker'

performance.film_year
#=> nil # from the title, e.g. 1990 for 'Misery (1990)'

performance.dimension
#=> '2d'

performance.variant
#=> ['baby', 'relaxed', 'subtitled']

performance.subtitled?
#=> true

performance.festival
#=> nil # e.g. #<data Cinebase::Festival name="Cinecity", year=2026>

performance.starting_at
#=> 2026-11-02 11:00:00 UTC

performance.booking_url
#=> 'https://lewesdepot.org/film/parent-baby-only-wicker/booknow/40631087'

performance.cinema_name
#=> 'Depot'

performance.cinema_id
#=> 'deplew'
```

Booking links are the website's own, to the page that holds Jacro's seat
selection.

Only films are returned. Films play in the numbered screens, so the gem
drops listings marked 'Depot event' or held in the studio: talks,
workshops, courses and tastings.

Variants come from the access pages and from titles: `subtitled`
(descriptive subtitles), `relaxed` (relaxed and autism friendly), `baby`
(parent and baby), `kids` (CBeebies and sensory friendly), `arts` (Royal
Ballet and Opera, National Theatre Live, Exhibition on Screen, musicals,
plays and pantomimes) and `q&a`. Films subtitled from another language are
not a variant.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live lewesdepot.org
```

The fixtures in `test/fixtures` are the website's pages, trimmed to the
parts the gem reads: a few calendar days, the home page's film list and the
access pages' listings. `test/support/api_shapes.rb` describes those parts.
The unit suite checks the fixtures against it and the live suite checks the
real pages, held only in memory. When the website changes, update the shape
first, then the fixtures.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
