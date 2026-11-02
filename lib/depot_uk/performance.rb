module DepotUk
  # A single screening of a film at the Depot cinema
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL on the cinema website
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year from the film's title
    #   @option options [Time] :starting_at listed start time of the performance

    # Performances within an inclusive range of showing dates. The calendar
    # holds every advertised date, so any range takes five requests: the
    # calendar, the home page for titles the calendar shortens, and three
    # access pages. A range with no performances takes one.
    # @param [String] cinema_id the cinema's Jacro code, 'deplew'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<DepotUk::Performance>]
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      if cinema.name.empty?
        []
      else
        performances = Internal::Website.open { |website| read(website, cinema, from..to) }
        performances.sort_by(&:starting_at)
      end
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (arts, baby, kids, q&a, relaxed, subtitled)
    #   @return <Array[String]>

    def self.read(website, cinema, dates)
      entries = Internal::Parser::Calendar.new(website.calendar, near: dates.first).entries
      entries = entries.select { |entry| dates.cover?(entry.date) }
      if entries.empty?
        []
      else
        titles = website.titles
        variants = website.variants
        entries.map do |entry|
          showtime = Internal::Parser::Showtime.new(entry, titles: titles, variants: variants.fetch(entry.id, []))
          new(showtime.to_hash.merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
      end
    end
    private_class_method :read
  end
end
