module Harmony
  # A pitch modulo octave shifts.
  # http://en.wikipedia.org/wiki/Pitch_class
  # Currently we limit to pitch multiples of a Semitone
  class PitchClass
    attr_reader :midi_number
  
    def initialize(arg)
      @midi_number = case arg
      when Fixnum then arg % 12
      when Pitch then arg.midi_number % 12
      when /^([A-G][#b]?)/i
        NOTES_FROM_NAME[$1]
      else
        raise ArgumentError
      end
    end

    def ==(other)
      case other
      when Pitch
        (other.midi_number % 12) == @midi_number
      when PitchClass
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
      when PitchClass
        raise ArgumentError.new("Adding two PitchClasss is meaningless")
      else
        raise ArgumentError.new("Bad argument to PitchClass#+")
      end
    end
  
    def -(n)
      case n
      when Fixnum
        self.class.new(@midi_number - n)
      when Interval, IntervalClass
        self.class.new(@midi_number - n.semitones)
      when PitchClass, Pitch
        raise ArgumentError.new("An interval involving a non-fixed PitchClass is ill-defined - fix the PitchClass to an octave first")
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

    def fix(octave=5)
      Pitch.new(octave*12 + @midi_number)
    end
    alias_method :representative, :fix
    alias_method :pitch, :fix
  
    def to_i
      @midi_number
    end
    
    
    # names
    
    include DictionaryLookup
    
    name_objects_in_namespace "English note letters for the diatonic C-major scale",
      new(0) =>  ["C","C\342\231\256","C \342\231\256","Cnatural","C natural"],
      new(2) =>  ["D","D\342\231\256","D \342\231\256","Dnatural","D natural"],
      new(4) =>  ["E","E\342\231\256","E \342\231\256","Enatural","E natural"],
      new(5) =>  ["F","F\342\231\256","F \342\231\256","Fnatural","F natural"],
      new(7) =>  ["G","G\342\231\256","G \342\231\256","Gnatural","G natural"],
      new(9) =>  ["A","A\342\231\256","A \342\231\256","Anatural","A natural"],
      new(11) => ["B","B\342\231\256","B \342\231\256","Bnatural","B natural"]
    name_objects_in_namespace "Sharp english note letters",
      new(1) =>  ["C\342\231\257","C \342\231\257","C#","C #","Csharp","C sharp"],
      new(3) =>  ["D\342\231\257","D \342\231\257","D#","D #","Dsharp","D sharp"],
      new(5) =>  ["E\342\231\257","E \342\231\257","E#","E #","Esharp","E sharp"],
      new(6) =>  ["F\342\231\257","F \342\231\257","F#","F #","Fsharp","F sharp"],
      new(8) =>  ["G\342\231\257","G \342\231\257","G#","G #","Gsharp","G sharp"],
      new(10) => ["A\342\231\257","A \342\231\257","A#","A #","Asharp","A sharp"],
      new(0) =>  ["B\342\231\257","B \342\231\257","B#","B #","Bsharp","B sharp"]
    name_objects_in_namespace "Flat english note letters",
      new(11) => ["C\342\231\255","C \342\231\255","Cb","C b","Cflat","C flat"],
      new(1) =>  ["D\342\231\255","D \342\231\255","Db","D b","Dflat","D flat"],
      new(3) =>  ["E\342\231\255","E \342\231\255","Eb","E b","Eflat","E flat"],
      new(4) =>  ["F\342\231\255","F \342\231\255","Fb","F b","Fflat","F flat"],
      new(6) =>  ["G\342\231\255","G \342\231\255","Gb","G b","Gflat","G flat"],
      new(8) =>  ["A\342\231\255","A \342\231\255","Ab","A b","Aflat","A flat"],
      new(10) => ["B\342\231\255","B \342\231\255","Bb","B b","Bflat","B flat"]
    name_objects_in_namespace "Double-flat english note letters",
      new(10) => ["C\342\231\255\342\231\255","C \342\231\255\342\231\255","Cbb","C bb","Cflatflat","C double-flat","C double flat","C flat flat"],
      new(0) =>  ["D\342\231\255\342\231\255","D \342\231\255\342\231\255","Dbb","D bb","Dflatflat","D double-flat","D double flat","D flat flat"],
      new(2) =>  ["E\342\231\255\342\231\255","E \342\231\255\342\231\255","Ebb","E bb","Eflatflat","E double-flat","E double flat","E flat flat"],
      new(3) =>  ["F\342\231\255\342\231\255","F \342\231\255\342\231\255","Fbb","F bb","Fflatflat","F double-flat","F double flat","F flat flat"],
      new(5) =>  ["G\342\231\255\342\231\255","G \342\231\255\342\231\255","Gbb","G bb","Gflatflat","G double-flat","G double flat","G flat flat"],
      new(7) =>  ["A\342\231\255\342\231\255","A \342\231\255\342\231\255","Abb","A bb","Aflatflat","A double-flat","A double flat","A flat flat"],
      new(9) =>  ["B\342\231\255\342\231\255","B \342\231\255\342\231\255","Bbb","B bb","Bflatflat","B double-flat","B double flat","B flat flat"]
    name_objects_in_namespace "Double-sharp english note letters",
      new(2) =>  ["Cx","C x","Csharpsharp","C double-sharp","C double sharp","C sharp sharp"],
      new(4) =>  ["Dx","D x","Dsharpsharp","D double-sharp","D double sharp","D sharp sharp"],
      new(6) =>  ["Ex","E x","Esharpsharp","E double-sharp","E double sharp","E sharp sharp"],
      new(7) =>  ["Fx","F x","Fsharpsharp","F double-sharp","F double sharp","F sharp sharp"],
      new(9) =>  ["Gx","G x","Gsharpsharp","G double-sharp","G double sharp","G sharp sharp"],
      new(11) => ["Ax","A x","Asharpsharp","A double-sharp","A double sharp","A sharp sharp"],
      new(1) =>  ["xb","B x","Bsharpsharp","B double-sharp","B double sharp","B sharp sharp"]
  end
end