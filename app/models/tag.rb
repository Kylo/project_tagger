class Tag < ActiveRecord::Base
  has_and_belongs_to_many :projects

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
    }
  }

  # Returns number of projects associated with this tag.
  def project_count
    @project_count ||= attributes['project_count'] 
    @project_count ||= self.projects.count
  end

  def name=(new_name)
    if self.new_record?
      write_attribute :name, new_name
    elsif self.name != new_name
      if (t=Tag.find_by_name(new_name))
        t.project_ids = t.project_ids + self.project_ids
        t.project_ids.uniq!
        t.save
        self.destroy()
      else
        write_attribute :name, new_name
      end
    end
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
       GROUP BY project_id
       ORDER BY 1 DESC
       LIMIT 1").to_i
  end

end
