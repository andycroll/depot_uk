module DepotUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [DepotUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\AParent (?:&|and) Baby ONLY:\s*/i,                  # parent and baby screening
          /\AKNITFLICKS:\s*/i,                                  # knit-along screening
          /\ASee It First\s*[–-]\s*/i,                          # preview
          /\s*\(Cinecity\)/i,                                   # festival suffix
          /\s*\((?:MET )?(?:Opera|Ballet)\)\z/i                 # event cinema genre
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\ARBO: (.*)/ => 'Royal Ballet and Opera: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
