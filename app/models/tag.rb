class Tag < ActiveRecord::Base
  has_and_belongs_to_many :projects

  attr_accessible :name
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name,
    :with => /^([a-zA-Z0-9!@#\$%^&*()_=\-+\[\]{}?.][a-zA-Z0-9!@#\$%^&*()_=\-+\[\]{}?. ]?)+$/

  default_scope :order => :id
  named_scope :for_projects, lambda { |p_ids| {
      :select => 'DISTINCT tags.*',
      :joins => :projects,
      :conditions => { :projects => { :id => p_ids } } }
  }
  named_scope :for_autocomplete, lambda { |stag| {
      :select => 'tags.*, count(projects_tags.tag_id) as project_count',
      :joins => 'INNER JOIN projects_tags ON tags.id = projects_tags.tag_id',
      :group => 'tags.id, tags.name',
      :conditions => ['LOWER(tags.name) LIKE ?', "%"+stag.downcase+"%" ],
      :order => 'project_count DESC',
      :limit => 10
  }}


  # Returns number of projects associated with this tag.
  def project_count
    @project_count ||= attributes['project_count'] 
    @project_count ||= self.projects.count
  end

  def self.merge_tags(tag_saved, tag_dropped)
    tag_saved.project_ids += tag_dropped.project_ids
    tag_saved.project_ids.uniq!
    tag_saved.save
    tag_dropped.destroy
  end

  # +all_associations+ class method is used to count all tag-project connections
  def self.all_associations
    Tag.connection.select_value("Select count(*) from projects_tags").to_i
  end

  # This class method returns maximum number of projects associated with tag
  # for all tags.
  def self.max_associated_projects
    Tag.connection.
      select_value(
      "SELECT count(*)
       FROM projects_tags
       GROUP BY tag_id
       ORDER BY 1 DESC
       LIMIT 1").to_i
  end

  def self.find_unused
    Tag.find_by_sql(
    "SELECT *
     FROM tags
     WHERE tags.id NOT IN (
       SELECT DISTINCT projects_tags.tag_id
       FROM projects_tags)")
  end

end
