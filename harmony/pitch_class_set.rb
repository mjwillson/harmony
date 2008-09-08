module Harmony
  # A set of pitches / combination of pitches, with the pitches themselves (as well as the pitch_set as a whole) treated regardless of the octave they're in.
  # Eg, the Dminor chord, regardless of whether it's inverted (A,D,F vs D,F,A) / what octave the notes are in.
  # Effectively a subset of {0, ..., 11}
  class PitchClassSet
    attr_reader :word
    def initialize(arg)
      @word = case arg
      when Fixnum then arg
      when Enumerable
        # integer bitfield with 12 binary digits representing the 12 pitches
        arg.inject(0) {|acc, n| acc | (1 << (n.to_i % 12))}
      end
    end

    def map_add(interval)
      interval = interval.to_i % 12
      PitchClassSet.new((@word << interval) & 4095 | (@word >> (12-interval)))
    end
    alias_method :transpose, :map_add

    include Enumerable
    def each
      12.times {|n| yield PitchClass[n] if @word & (1<<n) != 0}
    end

    include SetComparisonCoercions
    include SetComparisonCoercions::ComparesPitchClasses

    def modulo_transposition
      PitchClassSet::ModuloTransposition.new(@word)
    end
    
    def ==(other)
      compare(:==, other) {@word == other.word}
    end

    def hash
      @word
    end
    def eql?(other)
      super || (other.is_a?(PitchClassSet) && @word == other.word)
    end
  
    def subset?(other)
      compare(:subset?, other) {(~@word) | other.word == -1}
    end
    
    def &(other)
      compare(:&, other) {PitchClassSet.new(@word & other.word)}
    end

    def |(other)
      compare(:|, other) {PitchClassSet.new(@word | other.word)}
    end
    
    def ~@
      PitchClassSet.new(~@word)
    end
    
    def empty?
      @word == 0
    end
    
    def inspect
      "#{self.class}.new(#{to_a.inspect})"
    end
    
    def to_s
      "PitchClassSet(#{to_a.join(',')})"
    end
  end
end