require_dependency 'project'

# Patches Redmine's Project dynamically. Adds a relationship
# Project +has_and_belongs_to_many+ Tags
module ProjectPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      has_and_belongs_to_many :tags
      validates_associated :tags, :message => :plural_invalid
    end

  end

  module InstanceMethods
    def tag_list
      @tag_list ||= self.tags.to_a.map{ |t| t.name }.join(", ")
    end

    def tag_list=(list)
      new_tag_list=list.split(/,/).map{ |name| name.strip }
      new_tag_list.each do |tag_name|
        unless self.tags.map(&:name).include?(tag_name)
          if t=Tag.find_by_name(tag_name)
            self.tags<<t
          else
            self.tags.build :name => tag_name
          end
        end
      end
      tmp=Array.new(self.tags.to_a)
      tmp.each do |tag|
        unless new_tag_list.include? tag.name
          self.tags.delete tag
        end
      end
      @tag_list=nil
    end
  end
end

Project.send(:include, ProjectPatch)

module ProjectsHelper
  def font_size_for_tag(tag)
    @max_count ||= Tag.max_associated_projects
    100+(200/@max_count)*tag.projects.length
  end
end
