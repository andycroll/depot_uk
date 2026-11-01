# frozen_string_literal: true

module DepotUk
  # @api private
  module Internal
    module Parser
      # Reads the website's calendar: every advertised date, each with its
      # listings and their start times. Dates have no year.
      class Calendar
        # One performance of a film
        Entry = Data.define(:id, :slug, :heading, :date, :starting_at)

        DAY = %r{<h2>(\w{3})<br>(\d{1,2}) (\w+)</h2>}
        LISTING = %r{
          data-link="/film/([^"]+)"\s*><div\sclass="contents"><h3>(.*?)</h3>
          (.*?)<div\sclass="calendar-perf-buttons">(.*?)</div>
        }mx
        PERFORMANCE = %r{perf-popup\.php\?id=(\d+)"[^>]*>\s*(\d{1,2}):(\d{2})\s*</a>}
        LINE_BREAK = %r{<br\s*/?>}

        # Films play in numbered screens. Talks, workshops and tastings are
        # 'Depot event' or in the studio.
        FILM_SCREEN = /\AScreen \d/

        # A day and month falls on a different weekday in each of three
        # neighbouring years
        YEARS_AROUND = (-1..1)
        TIME_ZONE = 'Europe/London'

        # @param [String] html the calendar page
        # @param [Date] near a date within a year of the listings, which sets
        #   their years
        def initialize(html, near:)
          @html = html
          @near = near
        end

        # @return [Array<DepotUk::Internal::Parser::Calendar::Entry>] film
        #   performances in calendar order
        def entries
          date = nil
          @html.scan(Regexp.union(DAY, LISTING)).flat_map do |weekday, day, month, slug, heading, details, buttons|
            if weekday
              date = date_of(weekday, day.to_i, month)
              []
            elsif date && film?(details)
              performances(buttons, slug: slug, heading: CGI.unescapeHTML(heading).strip, date: date)
            else
              []
            end
          end
        end

        private

        def date_of(weekday, day, month_name)
          month = Date::MONTHNAMES.index(month_name)
          if month
            YEARS_AROUND.filter_map do |offset|
              year = @near.year + offset
              Date.new(year, month, day) if Date.valid_date?(year, month, day)
            end.find { |date| date.strftime('%a') == weekday }
          end
        end

        def film?(details)
          details.split(LINE_BREAK).any? { |line| line.strip.match?(FILM_SCREEN) }
        end

        def performances(buttons, slug:, heading:, date:)
          buttons.scan(PERFORMANCE).map do |id, hour, minute|
            local = Time.utc(date.year, date.month, date.day, hour.to_i, minute.to_i)
            starting_at = TZInfo::Timezone.get(TIME_ZONE).local_to_utc(local)
            Entry.new(id: id, slug: slug, heading: heading, date: date, starting_at: starting_at)
          end
        end
      end
    end
  end
end
