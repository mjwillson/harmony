module Harmony
  # an equivalence class of intervals modulo octave. so essentially this is the integers mod 12 
  class IntervalClass
    def self.[](s); new(s); end

    def initialize(semitones)
      @semitones = semitones % 12
    end

    attr_reader :semitones

    def ==(other)
      case other
      when Fixnum
        (other % 12) == @semitones
      when IntervalClass
        other.semitones == @semitones
      when Interval
        other.semitones_beyond_octave == @semitones
      else
        false
      end
    end

    def hash
      @semitones.hash
    end

    alias_method :eql?, :==

    def +(n)
      case n
      when Fixnum
        self.class.new(@semitones + n)
      when Interval, IntervalClass
        self.class.new(@semitones + n.semitones)
      when PitchClass
        other + self
      else
        raise ArgumentError.new("Bad argument to IntervalClass#+")
      end
    end

    def -(n)
      case n
      when Fixnum
        self.class.new(@semitones - n)
      when Interval, IntervalClass
        self.class.new(@semitones - n.semitones)
      else
        raise ArgumentError.new("Bad argument to PitchClass#-")
      end
    end

    def succ
      self + 1
    end

    def pred
      self - 1
    end
    
    def -@
      self.class.new(- @semitones)
    end
    
    def *(n)
      raise ArgumentError.new("Expected integer to IntervalClass#*") unless n.is_a?(Fixnum)
      self.class.new(@semitones * n)
    end

    def fix(octave=0)
      Interval.new(octave*12 + @semitones)
    end
    alias_method :representative, :fix
    alias_method :interval, :fix

    def inspect
      "#{self.class}[#{@semitones}]"
    end
    
    def to_i
      @semitones
    end
  end
end