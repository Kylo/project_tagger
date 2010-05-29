require File.dirname(__FILE__) + '/../test_helper'

class TagsHelperTest < HelperTestCase
  include TagsHelper

  def test_foo
    assert_equal "<strong>al</strong>a", tag_name_for_complete("ala", "al")
    assert_equal "<strong>Al</strong>a", tag_name_for_complete("Ala", "al")
    assert_equal "<strong>al</strong>a", tag_name_for_complete("ala", "Al")
    assert_equal "ala", tag_name_for_complete("ala", "ar")
    assert_equal "tro<strong>lo</strong>lo", tag_name_for_complete("trololo", "lo")
  end
end
