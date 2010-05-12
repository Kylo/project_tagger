require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :tags

  should_validate_presence_of :name
  should_allow_values_for :name, '!@#$%^&*()-_=+[] {}?.'
  should_not_allow_values_for :name, 'c  ++', 'java,', ' ruby;', "c\t\#"
  should_have_and_belong_to_many :projects
  should_validate_uniqueness_of :name

end
