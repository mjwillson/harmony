module Harmony
  class Interval
    attr_reader :semitones
    def initialize(semitones)
      @semitones = semitones
    end
  
    include Comparable
  
    def <=>(other)
      @semitones <=> case other
        when Fixnum then other
        when Interval then other.semitones
        else raise ArgumentError
      end
    end
  
    def ==(other)
      case other
      when Interval
        other.semitones == @semitones
      when IntervalClass
        other.semitones == semitones_beyond_octave
      when Fixnum
        other == @semitones
      else
        false
      end
    end
  
    def hash
      @semitones.hash
    end
  
    alias_method :eql?, :==
    
    TONAL_NAMES = [
      ['Unison'],
      ['Semitone', 'Minor 2nd'],
      ['Tone', 'Whole tone', 'Major 2nd'],
      ['Augmented 2nd', 'Minor 3rd'],
      ['Major 3rd'],
      ['Perfect 4th'],
      ['Tritone', 'Augmented 4th', 'Diminished 5th'],
      ['Perfect 5th'], 
      ['Augmented 5th', 'Minor 6th'],
      ['Major 6th'],
      ['Diminished 7th'],
      ['Major 7th']
    ]
  
    def octaves
      @semitones / 12
    end
  
    def semitones_beyond_octave
      @semitones % 12
    end

    def sgn
      @semitones <=> 0
    end

    def abs
      self.class.new(@semitones.abs)
    end
  
    def -@
      Interval.new(- @semitones)
    end
  
    def inspect
      "#{self.class}[#{@semitones}]"
    end
  
    def to_s(use_tonal_name = false)
      case sgn
      when 1 then "Up #{abs.name_with_octaves(use_tonal_name)}"
      when 0 then 'Unison'
      when -1 then "Down #{abs.name_with_octaves(use_tonal_name)}"
      end
    end
  
    def name_with_octaves(use_tonal_name = false)
      raise 'Only for upwards intervals' unless @semitones > 0
      [ case octaves
        when 0 then nil
        when 1 then "an Octave"
        else "#{octaves} Octaves"
        end,
        case semitones_beyond_octave
        when 0 then nil
        when 1 then use_tonal_name ? 'a '+TONAL_NAMES[semitones_beyond_octave].last : "a Semitone"
        else use_tonal_name ? 'a '+TONAL_NAMES[semitones_beyond_octave].last : "#{semitones_beyond_octave} Semitones"
        end
      ].compact.join(' and ')
    end
  
    def +(other)
      case other
      when NoteClass, Note
        other + self
      when Fixnum
        Interval.new(@semitones + other)
      when Interval
        Interval.new(@semitones + other.semitones)
      else
        raise ArgumentError.new("Bad argument to Interval#+")
      end
    end

    def -(other)
      case other
      when NoteClass, Note
        other - self
      when Fixnum
        Interval.new(@semitones - other)
      when Interval
        Interval.new(@semitones - other.semitones)
      else
        raise ArgumentError.new("Bad argument to Interval#-")
      end
    end
    
    def succ
      self + 1
    end
    
    def pref
      self - 1
    end
  
    def *(n)
      raise ArgumentError.new("Expected integer to Interval#*") unless n.is_a?(Fixnum)
      Interval.new(@semitones * n)
    end
    
    def to_i
      @semitones
    end
    
    def unfix
      NoteClass.new(semitones_beyond_octave)
    end
    alias_method :interval_class, :unfix
    alias_method :modulo_octaves, :unfix
    
    def self.[](s); new(s); end
  end
end