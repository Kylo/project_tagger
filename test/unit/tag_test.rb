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

  def test_all_associations
    assert Tag.all_associations==6
  end

  def test_max_associations
    assert Tag.max_associated_projects==4
  end

  def test_for_projects_scope
    p = Project.find(1)
    assert Tag.for_projects(p).count==4
    p = Project.find(2)
    assert Tag.for_projects(p).count==2
    p = Project.find(3)
    assert Tag.for_projects(p).count==0
  end

  def test_for_autocomplete_scope
    tags = Tag.for_autocomplete('a')
    assert_equal 2, tags.length
    tags2 = Tag.for_autocomplete('A')
    assert_equal tags, tags2
    tags2 = tags2.to_a.sort { |a,b| b.project_count <=> a.project_count }
    assert_equal tags, tags2
    tags2 = Tag.for_autocomplete('C')
    assert_not_equal tags, tags2
  end
end
