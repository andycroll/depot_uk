require_relative 'fixtures_helper'

# Serve the fixtures in place of lewesdepot.org
module WebsiteStubs
  include FixturesHelper

  SITE = 'https://lewesdepot.org'.freeze
  CALENDAR = "#{SITE}/whats-on/calendar".freeze
  HOME = "#{SITE}/".freeze
  PAGES = {
    CALENDAR => 'calendar.html',
    HOME => 'home.html',
    "#{SITE}/access/descriptive-subtitles" => 'access/descriptive-subtitles.html',
    "#{SITE}/access/relaxed" => 'access/relaxed.html',
    "#{SITE}/access/autism-friendly" => 'access/autism-friendly.html'
  }.freeze

  private

  def stub_website
    PAGES.each do |url, fixture|
      stub_request(:get, url).to_return(status: 200, body: read_fixture(fixture))
    end
  end
end
