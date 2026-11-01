# Read fixtures from disk: the website's pages, trimmed to the parts the gem
# reads, a few calendar days and no synopses. They follow the shapes in
# api_shapes.rb.
module FixturesHelper
  private

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
