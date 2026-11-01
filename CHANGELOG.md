# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

### Added
- `DepotUk::Cinema.all` and `DepotUk::Cinema.new(id)` for Depot in Lewes, keyed by its Jacro code `'deplew'`, with the address from the website's travel page and coordinates from OpenStreetMap.
- `DepotUk::Performance.at(id, from:, to:)`, from the website's calendar, which holds every advertised date, with full titles from the home page's film list, variants from the access pages and titles, booking links, and Cinecity festival screenings. Talks, workshops and other non-film events are dropped.
- Fixtures trimmed from live pages, a live shape test that checks real pages without storing them, and GitHub Actions CI and release workflows.
