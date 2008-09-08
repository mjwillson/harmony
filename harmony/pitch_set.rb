require 'set'
module Harmony
  # A set of pitches / combination of pitches
  class PitchSet
    attr_reader :pitches
    def initialize(pitches)
      pitches = pitches.map {|n| n.to_i}
      pitches = Set.new(pitches) unless pitches.is_a?(Set)
      @pitches = pitches
    end

    def map_add(interval)
      PitchSet.new(@pitches.map {|x| x + interval.to_i})
    end
    alias_method :transpose, :map_add

    def max
      Pitch[@pitches.max]
    end
    
    def min
      Pitch[@pitches.min]
    end
    
    def range
      Interval[@pitches.max - @pitches.min]
    end
    
    include Enumerable
    def each
      @pitches.each {|n| yield Pitch[n]}
    end

    include SetComparisonCoercions

    def modulo_octaves
      PitchSet::ModuloOctaves.new(@pitches)
    end
    
    def modulo_transposition
      PitchSet::ModuloTransposition.new(@pitches)
    end
    
    def pitches_modulo_octaves
      PitchClassSet.new(@pitches)
    end
    
    def ==(other)
      compare(:==, other) {@pitches == other.pitches}
    end

    def hash
      @pitches.inject(0) {|h, pitch| h ^ pitch} # Set#hash is actually a bit crap
    end
    def eql?(other)
      super || (other.is_a?(PitchSet) && @pitches == other.pitches)
    end
  
    def subset?(other)
      compare(:subset?, other) {@pitches.subset?(other.pitches)}
    end
    
    def &(other)
      compare(:&, other) {PitchSet.new(@pitches & other.pitches)}
    end

    def |(other)
      compare(:|, other) {PitchSet.new(@pitches | other.pitches)}
    end
    
    def empty?
      @pitches.empty?
    end
    
    def inspect
      "#{self.class}.new(#{to_a.inspect})"
    end
    
    def to_s
      "PitchSet(#{to_a.join(',')})"
    end
    
    def jazz_chord
      modulo_octaves.jazz_chord
    end
    
    def jazz_chord_type
      modulo_transposition.jazz_chord_type
    end
  end
end