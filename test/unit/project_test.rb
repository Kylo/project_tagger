require File.dirname(__FILE__) + '/../test_helper'

class ProjectTest < ActiveSupport::TestCase
  fixtures :projects, :tags, :projects_tags
  should_have_and_belong_to_many :tags

  def test_project_tags
    p = Project.find 1
    tags_names = Tag.all.to_a.map { |t| t.name }.sort
    project_tags_names = p.tags.all.to_a.map { |t| t.name }.sort
    assert tags_names==project_tags_names
  end

  def test_tag_list
    p = Project.find 2
    assert p.tag_list == "Java, C++"
  end

  def test_adding_tag_to_list
    num=Tag.all.count
    p = Project.find 2
    p.tag_list='Java, C++, completely_new_tag'
    assert p.save
    tags_tab = p.tags(true).to_a.map{ |t| t.name }
    assert tags_tab.include? 'Java'
    assert tags_tab.include? 'C++'
    assert tags_tab.include?('completely_new_tag'),
      "New tag should be associated"
    assert tags_tab.length==3,
      "Project should have 3 tags in total"
    assert Tag.count==num+1,
      "New tag should be stored in database"
  end

  def test_removing_tag_from_list
    num=Tag.all.count
    p = Project.find 2
    p.tag_list='Java'
    assert p.save
    tags_tab = p.tags(true).to_a.map{ |t| t.name }
    assert tags_tab.include? 'Java'
    assert tags_tab.length==1, "C++ tag should be removed from associated tags"
    assert Tag.count==num, "Tags number shouldn't change"
  end

  def test_removing_all_tags_from_list
    num=Tag.all.count
    p = Project.find 1
    p.tag_list=''
    assert p.save
    tags_tab = p.tags(true).to_a.map{ |t| t.name }
    assert tags_tab.length==0, "All tags should be removed from associated tags"
    assert Tag.count==num, "Tags number shouldn't change"
  end

  def test_rejecting_project_with_invalid_tag
    p = Project.find 2
    p.tag_list='Ja   va'
    assert !p.save, "Project should be rejected during validation"
  end
end
