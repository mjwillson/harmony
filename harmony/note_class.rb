module Harmony
  # a note modulo octave shifts
  class NoteClass
    def self.[](s); new(s); end
  
    def initialize(arg)
      @midi_number = case arg
      when Fixnum then arg % 12
      when Note then arg.midi_number % 12
      when /^([A-G][#b]?)/i
        NOTES_FROM_NAME[$1]
      else
        raise ArgumentError
      end
    end

    def ==(other)
      case other
      when Note
        (other.midi_number % 12) == @midi_number
      when NoteClass
        other.midi_number == @midi_number
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
      when Interval, IntervalClass
        self.class.new(@midi_number + n.semitones)
      when NoteClass
        raise ArgumentError.new("Adding two NoteClasss is meaningless")
      else
        raise ArgumentError.new("Bad argument to NoteClass#+")
      end
    end
  
    def -(n)
      case n
      when Fixnum
        self.class.new(@midi_number - n)
      when Interval, IntervalClass
        self.class.new(@midi_number - n.semitones)
      when NoteClass, Note
        raise ArgumentError.new("An interval involving a non-fixed NoteClass is ill-defined - fix the NoteClass to an octave first")
      else
        raise ArgumentError.new("Bad argument to NoteClass#-")
      end
    end
  
    def succ
      self + 1
    end
  
    def pred
      self - 1
    end

    def fix(octave=5)
      Note.new(octave*12 + @midi_number)
    end
    alias_method :representative, :fix
    alias_method :note, :fix
  
    def inspect
      "#{self.class}['#{self}']"
    end
  
    NOTE_NAMES = [
      ['C'],
      ['C#', 'Db'],
      ['D'],
      ['Eb', 'D#'],
      ['E'],
      ['F'],
      ['F#','Gb'],
      ['G'],
      ['G#','Ab'],
      ['A'],
      ['Bb','A#'],
      ['B']
    ]
    NOTES_FROM_NAME = {}; NOTE_NAMES.each_with_index {|names, i| names.each {|name| NOTES_FROM_NAME[name] = i}}
  
    def to_s
      NOTE_NAMES[@midi_number].first
    end
    
    def to_i
      @midi_number
    end
  end
end