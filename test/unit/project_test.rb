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
    num=Tag.count
    p = Project.find 2
    p.tag_list='Java, C++, completely_new_tag'
    assert p.save, 'Project should save with "completely_new_tag"'
    tags_tab = p.tags(true).to_a.map{ |t| t.name }
    assert tags_tab.include?('Java'), 'Project should be tagged with "Java"'
    assert tags_tab.include?('C++'), 'Project should be tagged with "C++"'
    assert tags_tab.include?('completely_new_tag'),
      "New tag should be associated"
    assert tags_tab.length==3,
      "Project should have 3 tags in total"
    assert Tag.count==num+1,
      "New tag should be stored in database"
  end

  def test_removing_tag_from_list
    num=Tag.count
    p = Project.find 2
    p.tag_list='Java'
    assert p.save
    tags_tab = p.tags(true).to_a.map{ |t| t.name }
    assert tags_tab.include? 'Java'
    assert tags_tab.length==1, "C++ tag should be removed from associated tags"
    assert Tag.count==num, "Tags number shouldn't change"
  end

  def test_removing_all_tags_from_list
    num=Tag.count
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

  def test_adding_existing_tag
    p = Project.find 2
    t = Tag.find 3
    assert !(p.tags.include?(t))
    p.tag_list=t.name
    assert p.save, "Project should save"
    assert p.tags(true).include?(t), "New tag should be associated"
  end

  def test_repeated_tags
    p = Project.find 2
    p.tag_list='c++, c++, c++'
    assert p.save, "Project should save"
    #assert p.tags(true).count==1, "Repeated tags should be saved as one"
    assert_equal 1, p.tags(true).count
    
  end

  def test_filtering
    projects = Project.find_all_for_all_tags('Java')
    assert_equal 2, projects.length
    projects = Project.find_all_for_all_tags('ASM')
    assert_equal 2, projects.length
    projects = Project.find_all_for_all_tags('Nonexsistent')
    assert_equal 0, projects.length
    projects = Project.find_all_for_all_tags(['Java','C++'])
    assert_equal 2, projects.length
    projects = Project.find_all_for_all_tags(['Java','ASM'])
    assert_equal 1, projects.length
  end

  
end
