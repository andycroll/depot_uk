# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [1.1.0] - 2026-11-03

### Changed
- Uses cinebase 5.9: performances take the raw `title:`, so audience labels become variants, and series prefixes such as `Met Opera:` become the performance's `event`.

## [1.0.1] - 2026-11-02

### Changed
- Requests and London times use cinebase 5.8's `Cinebase::Http` and `Cinebase::London`.
- HTTP errors read "HTTP error 500 from lewesdepot.org" in place of "Depot HTTP error 500".

## [1.0.0] - 2026-11-01

### Added
- `DepotUk::Cinema.all` and `DepotUk::Cinema.new(id)` for Depot in Lewes, keyed by its Jacro code `'deplew'`, with the address from the website's travel page and coordinates from OpenStreetMap.
- `DepotUk::Performance.at(id, from:, to:)`, from the website's calendar, which holds every advertised date, with full titles from the home page's film list, variants from the access pages and titles, booking links, and Cinecity festival screenings. Talks, workshops and other non-film events are dropped.
- Fixtures trimmed from live pages, a live shape test that checks real pages without storing them, and GitHub Actions CI and release workflows.
