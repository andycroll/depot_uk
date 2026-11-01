module DepotUk
  # The object representing the Depot cinema in Lewes
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the cinema's Jacro code, 'deplew'

    # Depot is one venue. Its id is the Jacro code in the website's booking
    # links. The address is from the website's travel page, the coordinates
    # from the cinema's OpenStreetMap node 44767219.
    VENUES = {
      'deplew' => {
        name: 'Depot', street_address: 'Pinwell Road', locality: 'Lewes', region: 'East Sussex',
        postal_code: 'BN7 2JS', latitude: 50.8715417, longitude: 0.0120094
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze
    URL = 'https://lewesdepot.org'.freeze

    # Constructor
    # @param [String] id the cinema's Jacro code, 'deplew' or 'DEPLEW'
    # @return [DepotUk::Cinema]
    def initialize(id)
      @id = id.to_s.downcase
    end

    # Return basic cinema information for all cinemas
    # @return [Array<DepotUk::Cinema>]
    # @example
    #   DepotUk::Cinema.all
    #   #=> [<DepotUk::Cinema>]
    def self.all
      VENUES.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = DepotUk::Cinema.new('deplew')
    #   cinema.adr
    #   #=> {
    #         street_address:   'Pinwell Road',
    #         extended_address: nil,
    #         locality:         'Lewes',
    #         region:           'East Sussex',
    #         postal_code:      'BN7 2JS',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, venue[part]] }.merge(country_name: 'United Kingdom')
    end

    # Brand of the cinema
    # @return [String] which will always be 'Independent'
    def brand
      'Independent'.freeze
    end

    # @return [Float, nil]
    def latitude
      venue[:latitude]
    end

    # @return [Float, nil]
    def longitude
      venue[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   DepotUk::Cinema.new('deplew').name
    #   #=> 'Depot'
    def name
      venue[:name].to_s
    end

    # The url of the cinema's website
    # @return [String]
    # @example
    #   DepotUk::Cinema.new('deplew').url
    #   #=> 'https://lewesdepot.org'
    def url
      venue.empty? ? '' : URL
    end

    private

    def venue
      VENUES.fetch(id, {})
    end
  end
end
