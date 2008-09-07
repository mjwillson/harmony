module Harmony
  # conceptually, a set of notes, modulo a transposition of the whole chord by some number of semitones (into a different key)
  # represented as: a set of intervals above the bottom note 0
  # corresponds to a 'shape of chord' - eg maj7, sus2 etc
  # or, a 'mode' of a scale, eg 'the Dorian mode of the major scale' - a scale with a particular note of the scale fixed as the starting note
  class Chord::ModuloTransposition
    def initialize(notes)
      notes = notes.map {|n| n.to_i}
      notes = Set.new(notes) unless notes.is_a?(Set)

      # we transform to a uniquely-determined representative for the equivalence class:
      min = notes.min
      @interval_set = notes.map! {|note| note - min}
    end

    attr_reader :interval_set

    include ComparisonCoercions
    include ComparisonCoercions::ComparesModuloTransposition

    def notes_modulo_octaves
      Chord::NotesModuloOctaves::ModuloTransposition.new(@interval_set)
    end

    def ==(other)
      compare(:==, other) {@interval_set == other.interval_set}
    end

    def hash
      @interval_set.inject(0) {|h, note| h ^ note} # Set#hash is actually a bit crap
    end
    def eql?(other)
      super || (other.is_a?(Chord::ModuloTransposition) && @interval_set == other.interval_set)
    end

    def subset?(other)
      compare(:subset?, other) do
        max_diff = other.interval_set.max - @interval_set.max
        # are there any offsets which we can slide our interval set by so that it lines up with a subset of the other's interval set?
        max_diff >= 0 && (Interval.new(0)..max_diff).any? {|i| @interval_set.map {|j| j+i}.subset?(other.interval_set)}
      end
    end
    
    def empty?
      @interval_set.empty?
    end
    
    JAZZ_CHORD_TYPES = {
      ''         => new([0, 4, 7]),
      'maj7'     => new([0, 4, 7, 11]),
      'maj9'     => new([0, 4, 7, 11, 14]),
      'maj11'    => new([0, 4, 7, 11, 14, 17]),
      'maj13'    => new([0, 4, 7, 11, 14, 17, 21]),
      'maj9#11'  => new([0, 4, 7, 11, 14, 18]),
      'maj13#11' => new([0, 4, 7, 11, 14, 18, 21]),
      '6'        => new([0, 4, 7, 9]),
      'add9'     => new([0, 4, 7, 14]),
      '6add9'    => new([0, 4, 7, 9, 14]),
      'maj7b5'   => new([0, 4, 6, 11]),
      'maj7#5'   => new([0, 4, 8, 11]),
      'm'        => new([0, 3, 7]),
      'm7'       => new([0, 3, 7, 10]),
      'm9'       => new([0, 3, 7, 10, 14]),
      'm11'      => new([0, 3, 7, 10, 14, 17]),
      'm13'      => new([0, 3, 7, 10, 14, 17, 21]),
      'm6'       => new([0, 3, 7, 9]),
      'madd9'    => new([0, 3, 7, 14]),
      'm6add9'   => new([0, 3, 7, 9, 14]),
      'mmaj7'    => new([0, 3, 7, 11]),
      'mmaj9'    => new([0, 3, 7, 11, 14]),
      'm7b5'     => new([0, 3, 6, 10]),
      'm7#5'     => new([0, 3, 8, 10]),
      '7'        => new([0, 4, 7, 10]),
      '9'        => new([0, 4, 7, 10, 14]),
      '11'       => new([0, 4, 7, 10, 14, 17]),
      '13'       => new([0, 4, 7, 10, 14, 17, 21]),
      '7sus4'    => new([0, 5, 7, 10]),
      '7b5'      => new([0, 4, 6, 10]),
      '7#5'      => new([0, 4, 8, 10]),
      '7b9'      => new([0, 4, 7, 10, 13]),
      '7#9'      => new([0, 4, 7, 10, 15]),
      '7(b5,b9)' => new([0, 4, 6, 10, 13]),
      '7(b5,#9)' => new([0, 4, 6, 10, 15]),
      '7(#5,b9)' => new([0, 4, 8, 10, 13]),
      '7(#5,#9)' => new([0, 4, 8, 10, 15]),
      '9b5'      => new([0, 4, 6, 10, 14]),
      '9#5'      => new([0, 4, 8, 10, 14]),
      '13#11'    => new([0, 4, 7, 10, 14, 18, 21]),
      '13b9'     => new([0, 4, 7, 10, 13, 17, 21]),
      '11b9'     => new([0, 4, 7, 10, 13, 17]),
      'aug'      => new([0, 4, 8]),
      'dim'      => new([0, 3, 6]),
      'dim7'     => new([0, 3, 6, 9]),
      '5'        => new([0, 7]),
      'sus4'     => new([0, 5, 7]),
      'sus2'     => new([0, 2, 7]),
      'sus2sus4' => new([0, 2, 5, 7]),
      '-5'       => new([0, 4, 6])
    }
    JAZZ_CHORD_LOOKUP = JAZZ_CHORD_TYPES.invert
    
    def jazz_chord_type
      JAZZ_CHORD_LOOKUP[self]
    end
    
    SCALE_TYPES = {
      # 12-note
      'chromatic' => new([0,1,2,3,4,5,6,7,8,9,10,11]),

      # 9-note
      'nine-note blues' => new([0,2,3,4,5,7,9,10,11]), # http://en.wikipedia.org/wiki/Blues_scale

      # 7-note
      'major' => new([0,2,4,5,7,9,11]),
      'dorian (II) mode' => new([0,2,3,5,7,9,10]),
      'phrygian (III) mode' => new([0,1,3,5,7,8,10]),
      'lydian (IV) mode' => new([0,2,4,6,7,9,11]),
      'mixolydian (V) mode' => new([0,2,4,5,7,9,10]),
      'aeolian (VI) mode' => new([0,2,3,5,7,8,10]),
      'locrian (VII) mode' => new([0,1,3,5,6,8,10]),

      '(harmonic) minor' => new([0,2,3,5,7,8,11]),
      
      'melodic minor ascending' => new([0,2,3,5,7,9,11]),
      'melodic minor descending' => new([0,2,3,5,7,8,10]),
      'seven-note blues' => new([0,2,3,5,6,9,10]), # http://en.wikipedia.org/wiki/Blues_scale

      # 6-note
      'whole tone' => new([0,2,4,6,8,10]),
      'six-note blues' => new([0,3,5,6,7,10]), # http://en.wikipedia.org/wiki/Blues_scale
      'symmetrical augmented' => new([0,3,4,7,8,11]), # http://en.wikipedia.org/wiki/Hexatonic_scale#Augmented_scale
      'prometheus' => new([0,2,4,6,9,10]), # http://en.wikipedia.org/wiki/Hexatonic_scale#Prometheus_scale

      # 5-note
      'major pentatonic' => new([0,2,4,7,9]),
      'minor pentatonic' => new([0,3,5,7,10]),
    }
    
    
    def fix(start=0)
      Chord.new(@interval_set.map {|n| n+start.to_i})
    end
    
    def inspect
      fix.inspect + '.modulo_transposition'
    end

    # calculations of inversions of a chord / modes of a scale (essentially the same thing)
    
    def next_mode
      interval_set = @interval_set.dup
      octave_above_max = (interval_set.max / 12 + 1) * 12
      interval_set.delete(0); interval_set.add(octave_above_max)
      Chord::ModuloTransposition.new(interval_set)
    end
    alias :next_invertion :next_mode
    
    # this will give you all the modes of the corresponding scale. how many you get depends how many notes there are in the scale and what symmetries are present in it.
    def modes
      result = Set.new; mode = self
      while true
        result << mode
        mode = mode.next_mode
        break if mode == self
      end
      result
    end
    alias :inversions :modes
  end
end