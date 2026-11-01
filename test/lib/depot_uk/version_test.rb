require_relative '../../test_helper'

class DepotUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil DepotUk::VERSION
  end
end
