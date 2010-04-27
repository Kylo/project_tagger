require_dependency 'project'

# Patches Redmine's Project dynamically. Adds a relationship
# Project +has_and_belongs_to_many+ Tags
module ProjectPatch

  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      has_and_belongs_to_many :tags
    end

  end

  module InstanceMethods
    def tag_list
      #      TODO pobranie wszystkich tagow projektu i zwrocenie w postaci listy
    end

    def tag_list=(list)
      #      TODO konwersja listy tagow na tagi i tworzenie nowych
    end
  end
end

Project.send(:include, ProjectPatch)
