class Tag < ActiveRecord::Base
  has_and_belongs_to_many :projects

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name,
    :with => /^([a-zA-Z0-9!@#\$%^&*()_=\-+\[\]{}?.][a-zA-Z0-9!@#\$%^&*()_=\-+\[\]{}?. ]?)+$/

  default_scope :order => :id

  def project_count
    @project_count ||= self.projects.count
  end

  def self.all_associations
    Tag.connection.select_value("Select count(*) from projects_tags").to_i
  end

  def self.max_associated_projects
    Tag.connection.
      select_value(
      "SELECT count(*)
       FROM projects_tags
       GROUP BY project_id
       ORDER BY 1 DESC
       LIMIT 1").to_i
  end

end
