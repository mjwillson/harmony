module Harmony
  class Pitch
    attr_reader :midi_number

    def initialize(arg)
      @midi_number = case arg
      when Fixnum then arg
      when /^([A-Z][#b]?)(-?\d+)$/
        PitchClass::NOTES_FROM_NAME[$1] + 12*$2.to_i
      else
        raise ArgumentError
      end
    end
  
    include Comparable

    def <=>(other)
      @midi_number <=> other.midi_number
    end
    
    def ==(other)
      case other
      when Pitch
        other.midi_number == @midi_number
      when PitchClass
        other.midi_number == (@midi_number % 12)
      else
        false
      end
    end
  
    def hash
      @midi_number.hash
    end
  
    alias_method :eql?, :==

    def +(n)
      case n
      when Fixnum
        self.class.new(@midi_number + n)
      when Interval
        self.class.new(@midi_number + n.semitones)
      when Pitch, PitchClass
        raise ArgumentError.new("Adding two pitches is meaningless")
      else
        raise ArgumentError.new("Bad argument to Pitch#+")
      end
    end
  
    def -(n)
      case n
      when Fixnum
        self.class.new(@midi_number - n)
      when Interval
        self.class.new(@midi_number - n.semitones)
      when Pitch
        Interval.new(@midi_number - n.midi_number)
      when PitchClass
        raise ArgumentError.new("An interval involving a non-fixed PitchClass is ill-defined - fix the PitchClass to an octave first")
      else
        raise ArgumentError.new("Bad argument to Pitch#-")
      end
    end
  
    def succ
      self + 1
    end
  
    def pred
      self - 1
    end
  
    def inspect
      "#{self.class}['#{self}']"
    end

    def octaves
      @midi_number / 12
    end
  
    def semitones_beyond_octave
      @midi_number % 12
    end

    def unfix
      PitchClass.new(semitones_beyond_octave)
    end
    alias_method :pitch_class, :unfix
    alias_method :modulo_octaves, :unfix

    def to_s
      "#{pitch_class}#{octaves}"
    end
    
    def to_i
      @midi_number
    end
  
    def self.[](s); new(s); end
  end
end