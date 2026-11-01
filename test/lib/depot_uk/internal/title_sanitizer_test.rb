require_relative '../../../test_helper'

class DepotUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'Ghosts: The Possession of Button House', 'Ghosts: The Possession of Button House'
    assert_sanitized 'GIANT – The Play', 'GIANT – The Play'
  end

  def test_parent_and_baby_prefix
    assert_sanitized 'Wicker', 'Parent & Baby ONLY: Wicker'
  end

  def test_knitflicks_prefix
    assert_sanitized 'Little Women', 'KNITFLICKS: Little Women'
  end

  def test_preview_prefix
    assert_sanitized 'Dune: Part Three', 'See It First – Dune: Part Three'
  end

  def test_cinecity_suffix
    assert_sanitized 'King Auk', 'King Auk (Cinecity)'
  end

  def test_royal_ballet_and_opera
    assert_sanitized 'Royal Ballet and Opera: Carmen', 'RBO: Carmen (Opera)'
    assert_sanitized 'Royal Ballet and Opera: Swan Lake', 'RBO: Swan Lake (Ballet)'
    assert_sanitized 'Royal Ballet and Opera: La Fanciulla del West', 'RBO: La Fanciulla del West (MET Opera)'
  end

  def test_film_years
    assert_sanitized 'Misery', 'Misery (1990)'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, DepotUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
