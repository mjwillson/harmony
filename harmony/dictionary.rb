module Harmony
  class Dictionary
    def initialize
      @name_to_objects = {}
      @namespace_and_name_to_object = {}
      @class_and_name_to_object = {}
      @object_to_names = {}
    end
    
    def name_object(object, *names)
      name_in_namespace(object, nil, *names)
    end
    
    def name_object_in_namespace(object, namespace, *names)
      namespace = namespace.to_s
      downcased_namespace = namespace.downcase
      names.map! {|name| name.to_s.strip}.uniq!
      names.each do |name|
        downcased = name.downcase
        @name_to_objects[downcased] ||= []
        @name_to_objects[downcased] |= [object]
        if namespace
          @namespace_and_name_to_object[downcased_namespace] ||= {}
          @namespace_and_name_to_object[downcased_namespace][downcased] ||= object
        end
        @class_and_name_to_object[object.class] ||= {}
        @class_and_name_to_object[object.class][downcased] ||= object
        @object_to_names[object] ||= []
        @object_to_names[object] |= [[namespace, name]]
      end
    end
    
    def name_objects_in_namespace(namespace, objects)
      objects.each {|object, names| name_object_in_namespace(object, namespace, *names)}
    end
    
    def name_objects(objects)
      name_objects_in_namespace(nil, objects)
    end

    def find_all(name)
      @name_to_objects[name.to_s.downcase] || []
    end
    
    def find(name)
      find_all(name).first
    end
    alias :[] :find
    
    def find_in_namespace(namespace, name)
      (@namespace_and_name_to_object[namespace.to_s.downcase] || {})[name.to_s.downcase]
    end
    
    def find_by_class(klass, name)
      (@class_and_name_to_object[klass] || {})[name.to_s.downcase]
    end
    
    def find_names_for(object)
      @object_to_names[object] || []
    end
    
    def find_name_for(object)
      find_names_for(object).first
    end
  end

  @dictionary = Dictionary.new

  def self.find_all(name)
    @dictionary.find_all(name)
  end
  
  def self.find(arg1, arg2=nil)
    if arg2
      @dictionary.find_in_namespace(arg1, arg2)
    else
      @dictionary.find(arg1)
    end
  end
  
  class << self
    attr_reader :dictionary
    alias :[] :find
  end
  
  module DictionaryLookup
    def self.included(klass)
      klass.extend(ClassMethods)
    end
    
    def unique_name
      namespace, name = Harmony.dictionary.find_name_for(self)
      name if name && Harmony.dictionary.find_all(name).length == 1
    end
    
    def names_with_namespaces
      Harmony.dictionary.find_names_for(self)
    end
    
    def names
      names_with_namespaces.map {|namespace,name| name}
    end
    
    def namespaced_name
      Harmony.dictionary.find_names_for(self).find {|namespace,name| !namespace.nil?}
    end

    def name_by_class
      namespace, name = Harmony.dictionary.find_name_for(self)
      name
    end

    def inspect
      if (name = unique_name)
        "Harmony[#{name.inspect}]"
      elsif (namespace_and_name = namespaced_name)
        "Harmony#{namespaced_name.inspect}"
      elsif (name = name_by_class)
        "#{self.class}[#{name.inspect}]"
      else
        super
      end
    end
    
    def to_s
      Harmony.dictionary.find_name_for(self).last or super
    end
    
    module ClassMethods
      def find(name)
        Harmony.dictionary.find_by_class(self, name)
      end
      alias :[] :find

      private
      def name_object_in_namespace(*p); Harmony.dictionary.name_object_in_namespace(*p); end
      def name_objects_in_namespace(*p); Harmony.dictionary.name_objects_in_namespace(*p); end
      def name_object(*p); Harmony.dictionary.name_object(*p); end
      def name_objects(*p); Harmony.dictionary.name_objects(*p); end
    end
  end
end