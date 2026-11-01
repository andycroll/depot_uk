# frozen_string_literal: true

module DepotUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads the pages of lewesdepot.org that, together, describe every
    # advertised performance: the calendar, the home page's film list and
    # the access pages.
    class Website
      include Http

      CALENDAR_PATH = '/whats-on/calendar'
      HOME_PATH = '/'

      # Each access page lists every upcoming performance of its kind
      ACCESS_PAGES = {
        '/access/descriptive-subtitles' => 'subtitled',
        '/access/relaxed' => 'relaxed',
        '/access/autism-friendly' => 'relaxed'
      }.freeze

      FILM_SELECT = %r{<select[^>]*id="film_select"[^>]*>(.*?)</select>}m
      FILM_OPTION = %r{<option value="\d+">([^<]+)</option>}
      PERFORMANCE_ID = /perf-popup\.php\?id=(\d+)/

      # Yield a website, closing its connection afterwards
      # @yieldparam [DepotUk::Internal::Website] website
      # @return the block's result
      def self.open
        website = new
        yield website
      ensure
        website.close
      end

      # @return [String] the calendar page, every advertised date
      def calendar
        get(CALENDAR_PATH)
      end

      # The calendar shortens long titles, the home page's film list does
      # not
      # @return [Array<String>] every advertised title, e.g. 'Ghosts: The
      #   Possession of Button House'
      def titles
        films = get(HOME_PATH)[FILM_SELECT, 1].to_s
        films.scan(FILM_OPTION).map { |(title)| CGI.unescapeHTML(title).strip }
      end

      # @return [Hash{String => Array<String>}] variants by performance id,
      #   e.g. { '40631087' => ['subtitled', 'relaxed'] }
      def variants
        ACCESS_PAGES.each_with_object({}) do |(path, variant), variants|
          get(path).scan(PERFORMANCE_ID).each do |(id)|
            variants[id] = (variants[id] || []) | [variant]
          end
        end
      end
    end
  end
end
