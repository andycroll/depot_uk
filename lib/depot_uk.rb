require 'cgi/escape'

require 'cinebase'

require_relative './depot_uk/version'

require_relative './depot_uk/internal/http'
require_relative './depot_uk/internal/website'
require_relative './depot_uk/internal/title_sanitizer'
require_relative './depot_uk/internal/parser/calendar'
require_relative './depot_uk/internal/parser/showtime'

require_relative './depot_uk/cinema'
require_relative './depot_uk/performance'

# depot_uk gem
module DepotUk
end
