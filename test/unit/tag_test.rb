require File.dirname(__FILE__) + '/../test_helper'

class TagTest < ActiveSupport::TestCase
  fixtures :tags, :projects

  should_validate_presence_of :name
  should_allow_values_for :name, '!@#$%^&*()-_=+[] {}?.'
  should_not_allow_values_for :name, 'c  ++', 'java,', ' ruby;', "c\t\#"
  should_have_and_belong_to_many :projects
  should_validate_uniqueness_of :name

  def test_project_count
    assert Tag.find(1).project_count==Tag.find(1).projects(true).count
    assert Tag.find(2).project_count==Tag.find(1).projects(true).count
    assert Tag.new(:name => 'new').project_count==0
  end

end
