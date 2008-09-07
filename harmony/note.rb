module Harmony
  class Note
    attr_reader :midi_number

    def initialize(arg)
      @midi_number = case arg
      when Fixnum then arg
      when /^([A-Z][#b]?)(-?\d+)$/
        NoteClass::NOTES_FROM_NAME[$1] + 12*$2.to_i
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
      when Note
        other.midi_number == @midi_number
      when NoteClass
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
      when Note, NoteClass
        raise ArgumentError.new("Adding two notes is meaningless")
      else
        raise ArgumentError.new("Bad argument to Note#+")
      end
    end
  
    def -(n)
      case n
      when Fixnum
        self.class.new(@midi_number - n)
      when Interval
        self.class.new(@midi_number - n.semitones)
      when Note
        Interval.new(@midi_number - n.midi_number)
      when NoteClass
        raise ArgumentError.new("An interval involving a non-fixed NoteClass is ill-defined - fix the NoteClass to an octave first")
      else
        raise ArgumentError.new("Bad argument to Note#-")
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
      NoteClass.new(semitones_beyond_octave)
    end
    alias_method :note_class, :unfix
    alias_method :modulo_octaves, :unfix

    def to_s
      "#{note_class}#{octaves}"
    end
    
    def to_i
      @midi_number
    end
  
    def self.[](s); new(s); end
  end
end