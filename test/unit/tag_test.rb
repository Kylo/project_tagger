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
    assert_equal 8, Tag.all_associations
  end

  def test_max_associations
    assert_equal 2, Tag.max_associated_projects
  end

  def test_for_projects_scope
    p = Project.find(1)
    assert_equal 4, Tag.for_projects(p).count
    p = Project.find(2)
    assert_equal 2, Tag.for_projects(p).count
    p = Project.find(3)
    assert_equal 2, Tag.for_projects(p).count
    p = Project.find(4)
    assert_equal 0, Tag.for_projects(p).count
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

  def test_find_unused
    assert Tag.find_unused.empty?
    t = Tag.find(1)
    t.project_ids = []
    t.save
    assert_equal 1, Tag.find_unused.length
  end

  def test_merging_tags_with_common_tags
    t1 = Tag.find(1)
    t2 = Tag.find(2)
    p_ids = t1.projects.to_a.map(&:id) + t2.projects.to_a.map(&:id)
    p_ids.uniq!.sort!
    assert Tag.merge_tags(t1,t2)
    assert t2.frozen?, "Tag 2 should be frozen"
    assert_raise (ActiveRecord::RecordNotFound) { Tag.find(2) }
    assert_nothing_raised(Exception) { t1 = Tag.find(1) }
    assert_equal p_ids, t1.projects.to_a.map(&:id).sort
  end

  def test_merging_tags_without_common_tags
    t2 = Tag.find(2)
    t3 = Tag.find(3)
    p_ids = t2.projects.to_a.map(&:id) + t3.projects.to_a.map(&:id)
    p_ids.uniq!.sort!
    assert Tag.merge_tags(t2,t3)
    assert t3.frozen?, "Tag 2 should be frozen"
    assert_raise (ActiveRecord::RecordNotFound) { Tag.find(3) }
    assert_nothing_raised(Exception) { t2 = Tag.find(2) }
    assert_equal p_ids, t2.projects.to_a.map(&:id).sort
  end

  def test_changing_tag_name
    t = Tag.find(1)
    assert t.update_attributes(:name => 'completely_new_name'), "Tag should be saved"
    assert_equal 'completely_new_name', t.name
  end
end
