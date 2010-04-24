require_dependency 'project'

# Patches Redmine's Project dynamically. Adds a relationship
# Project +has_and_belongs_to_many+ Tags
module ProjectPatch

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      has_and_belongs_to_many :tags
    end

  end

  module ClassMethods
    
  end

  module InstanceMethods
    def tag_list

    end

    def tag_list=(list)
      
    end
  end
end

Project.send(:include, ProjectPatch)
