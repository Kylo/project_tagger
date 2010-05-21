require_dependency 'project'

# Patches Redmine's Project dynamically. Adds a relationship
# Project +has_and_belongs_to_many+ Tags and validation for associated tags.
module ProjectPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      has_and_belongs_to_many :tags
      validates_associated :tags, :message => :tags_invalid
    end

  end

  module ClassMethods
    # Returns all projects which are tagged with all +tags+ on provided list.
    # === Parameters
    # * _tags_ - array of tag names
    def find_all_for_all_tags(tags)
      joins=[]
      tags.each_with_index do |tag, idx|
        tags_alias = "tags_#{idx}"
        projects_tags_alias = "projects_tags_#{idx}"
        join = <<-EOS
          INNER JOIN "projects_tags" #{projects_tags_alias}
            ON #{projects_tags_alias}.project_id = "projects".id
          INNER JOIN "tags" #{tags_alias}
            ON #{projects_tags_alias}.tag_id = #{tags_alias}.id
              AND #{tags_alias}.name = ?
        EOS

        joins << sanitize_sql([join, tag])
      end
      joins = joins.join(" ")

      find(:all,
        :select => 'DISTINCT "projects".*',
        :joins => joins,
        :order => 'lft'
      )
    end
  end

  module InstanceMethods
    # Returns comma-separated list of +tags+ associated with this project
    def tag_list
      @tag_list ||= self.tags.to_a.map{ |t| t.name }.join(", ")
    end

    # This method is used to assign tags to the project.
    # === Parameters
    # * _list_ - list of comma-separated tags
    #
    # If any of provided tags does not yet exists, it is automaticly created.
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
