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

end
