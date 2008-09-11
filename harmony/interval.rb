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
      when PitchClass, Pitch
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
      when PitchClass, Pitch
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
      PitchClass.new(semitones_beyond_octave)
    end
    alias_method :interval_class, :unfix
    alias_method :modulo_octaves, :unfix
    
    include DictionaryLookup

    name_objects_in_namespace "Interval",
      new(0) => 'Unison',
      new(1) => 'Semitone',
      new(1) => 'Minor 2nd',
           
      new(2) => 'Tone',
      new(2) => 'Whole tone',
      new(2) => 'Major 2nd',
           
      new(3) => 'Augmented 2nd',
      new(3) => 'Minor 3rd',
           
      new(4) => 'Major 3rd',
           
      new(5) => 'Perfect 4th',
           
      new(6) => 'Tritone',
      new(6) => 'Augmented 4th',
      new(6) => 'Diminished 5th',
           
      new(7) => 'Perfect 5th',
           
      new(8) => 'Augmented 5th',
      new(8) => 'Minor 6th',
           
      new(9) => 'Major 6th',
          
      new(10) => 'Diminished 7th',
            
      new(11) => 'Major 7th',
            
      new(12) => 'Octave'

    # http://en.wikipedia.org/wiki/Solfege
    name_objects_in_namespace "English solfege diatonic scale",
      new(0) => ['Do', 'Doh'],
      new(2) => ['Re', 'Ray'],
      new(4) => ['Mi', 'Mee'],
      new(5) => ['Fa', 'Fah'],
      new(7) => ['So', 'Sol', 'Soh'],
      new(9) => ['La', 'Lah'],
      new(11) => ['Ti', 'Tee']

    name_objects_in_namespace "English solfege ascending chromatic notes",
      new(1)  => ['Di', 'Dee'],
      new(3)  => ['Ri', 'Ree'],
      new(6)  => ['Fi', 'Fee'],
      new(8)  => ['Si', 'See'],
      new(10) => ['Li', 'Lee']

    name_objects_in_namespace "English solfege descending chromatic notes",
      new(1) =>  ['Ra', 'Rah'],
      new(3) =>  ['Me', 'May'],
      new(6) =>  ['Se', 'Say'],
      new(8) =>  ['Le', 'Lay'],
      new(10) => ['Te', 'Tay']
  end
end