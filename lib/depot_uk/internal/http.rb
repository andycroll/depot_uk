# frozen_string_literal: true

require 'net/http'

module DepotUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Requests to lewesdepot.org over one kept-alive connection. The site is
    # slow, so timeouts are long.
    module Http
      HOST = 'lewesdepot.org'
      TIMEOUT = 40
      RETRIES = 2
      USER_AGENT = 'Mozilla/5.0 (compatible; depot_uk; +https://github.com/andycroll/depot_uk)'
      TRANSIENT_ERRORS = [
        EOFError, Errno::ECONNRESET, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, OpenSSL::SSL::SSLError
      ].freeze

      # Close the connection
      # @return [nil]
      def close
        @connection.finish if @connection&.started?
        @connection = nil
      end

      private

      def get(path)
        attempts = 0
        begin
          response = connection.request(Net::HTTP::Get.new(path, 'User-Agent' => USER_AGENT))
        rescue *TRANSIENT_ERRORS
          close
          attempts += 1
          raise if attempts > RETRIES

          sleep(attempts)
          retry
        end
        # Omit response bodies from errors, and never follow redirects.
        raise "Depot HTTP error #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        String.new(response.body, encoding: Encoding::UTF_8)
      end

      def connection
        @connection ||= Net::HTTP.start(HOST, 443, use_ssl: true, open_timeout: TIMEOUT, read_timeout: TIMEOUT)
      end
    end
  end
end
