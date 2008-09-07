module Harmony
  class Vector < Array
    @subclasses = {}
    class << self
      attr_reader :scalar_class

      def [](klass)
        @subclasses[klass] ||= Class.new(self) { @scalar_class = klass }
      end
    
      def name
        scalar_class ? "#{superclass}[#{scalar_class.name}]" : super
      end
      alias :inspect :name
      alias :to_s :name
    
      def new(items)
        if scalar_class
          super(items)
        else
          self[items.find {|x|x}.class].new(items)
        end
      end
    end

    def initialize(items)
      raise ArgumentError unless items.all? {|item| item.nil? || item.is_a?(self.class.scalar_class)}
      super
    end

    def min
      select {|x|x}.min
    end
    
    def max
      select {|x|x}.max
    end

    def +(other)
      Vector.new(zip(other).map {|a,b| a && b && a+b})
    end
    alias :transpose :+
  
    def -(other)
      Vector.new(zip(other).map {|a,b| a && b && a-b})
    end
  
    def *(n)
      Vector.new(map {|x| x && x*n})
    end
  
    def inspect
      "#{self.class}.new(#{super})"
    end
    
    def to_s
      '[' + join(', ') + ']'
    end
    
    def to_set
      Set.new(self)
    end
  end
end