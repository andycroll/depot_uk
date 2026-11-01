# frozen_string_literal: true

module DepotUk
  # @api private
  module Internal
    module Parser
      # Turns one calendar entry into performance attributes
      class Showtime
        BOOKING_URL = 'https://lewesdepot.org/film/%<slug>s/booknow/%<id>s'

        # The calendar cuts long headings at a word and adds this
        TRUNCATION = '...'

        # Titles and the variants they mean. The access pages mark
        # subtitled and relaxed performances.
        TITLE_VARIANTS = {
          /\AParent (?:&|and) Baby\b/i => 'baby',
          /\ASensory Friendly\b/i => %w(relaxed kids),
          /\ACbeebies\b/i => 'kids',
          /\bQ\s?&\s?A\b/i => 'q&a',
          /\A(?:RBO|National Theatre Live|NT Live|Met Opera|Exhibition on Screen):/i => 'arts',
          /\bThe (?:Musical|Play)\z|\bLive On Stage\z|\bPanto\b/i => 'arts'
        }.freeze

        CINECITY = /\(Cinecity\)/i
        CINECITY_NAME = 'Cinecity'
        THREE_D = /\b3D\b/i

        # @param [DepotUk::Internal::Parser::Calendar::Entry] entry
        # @param [Array<String>] titles every advertised title in full
        # @param [Array<String>] variants from the access pages
        def initialize(entry, titles:, variants:)
          @entry = entry
          @titles = titles
          @variants = variants
        end

        # @return [Hash] options for DepotUk::Performance.new
        def to_hash
          {
            booking_url: format(BOOKING_URL, slug: @entry.slug, id: @entry.id),
            dimension: title.match?(THREE_D) ? '3d' : '2d',
            festival: festival,
            film_name: TitleSanitizer.new(title).sanitized,
            film_year: Cinebase::TitleSanitizer.film_year(title),
            starting_at: @entry.starting_at,
            variant: variant
          }
        end

        # WordPress's slug for a title, e.g. 'de-gaulle-liberte'
        # @param [String] title
        # @return [String]
        def self.slug(title)
          ascii = title.unicode_normalize(:nfkd).gsub(/\p{Mn}/, '').downcase.delete("'’")
          ascii.gsub(/[^a-z0-9]+/, '-').delete_prefix('-').delete_suffix('-')
        end

        private

        def festival
          year = @entry.date.year
          if title.match?(CINECITY)
            Cinebase::Festival.new(name: CINECITY_NAME, year: year)
          else
            Cinebase::Festival.from_title(title, year: year)
          end
        end

        def title
          @title ||= if @entry.heading.end_with?(TRUNCATION)
                       full_title(@entry.heading.delete_suffix(TRUNCATION))
                     else
                       @entry.heading
                     end
        end

        # The film's slug settles a shortened heading that starts several
        # titles, e.g. 'Exhibition on Screen:...'
        def full_title(start)
          matches = @titles.select { |candidate| candidate.start_with?(start) }
          if matches.one?
            matches.first
          else
            matches.find { |candidate| self.class.slug(candidate) == @entry.slug } || start
          end
        end

        def variant
          from_title = TITLE_VARIANTS.flat_map { |pattern, variants| title.match?(pattern) ? Array(variants) : [] }
          (from_title + @variants).uniq
        end
      end
    end
  end
end
