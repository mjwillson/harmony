module Harmony
  # this is a 'binary 12-necklace' (a word of length 12 over a binary alphabet, taken modulo cyclic permutations).
  # alternatively, a set of pitches-modulo-octave, treated (as a whole) modulo any transposition into another key
  # alternatively, a shape of chord, without regard for which octave any given note of the chord is placed in.
  # alternatively, a type of scale, as in "Major" or "Minor pentatonic", without regard for which note of the scale is seen as the starting note (that would be a 'mode')
  class Chord::PitchesModuloOctaves::ModuloTransposition
    def initialize(arg)
      word = case arg
      when Fixnum then arg
      when Enumerable
        # integer bitfield with 12 binary digits representing the 12 pitches
        arg.inject(0) {|acc, n| acc | (1 << (n.to_i % 12))}
      end
      # all 12 cyclic permutations of the above
      @words = Set.new
      12.times {@words << word; word = (word>>1) | ((word & 1) << 11)}
      # the lexicographically smallest of these - a uniquely-determined representative for the equivalence class
      @representative = @words.min
    end
    attr_reader :representative
    
    def hash
      @representative
    end
    def eql?(other)
      super || (other.is_a?(Chord::PitchesModuloOctaves::ModuloTransposition) && other.representative == @representative)
    end
    
    include ComparisonCoercions
    include ComparisonCoercions::ComparesModuloOctaves
    include ComparisonCoercions::ComparesPitchesModuloOctaves
    include ComparisonCoercions::ComparesModuloTransposition
    
    def ==(other)
      compare(:==, other) {@representative == other.representative}
    end

    def subset?(other)
      compare(:subset?, other) do
        # we can define a partial order like so:
        # x <= y if there is some cyclic permutation pi such that pi(representative(x)) <= representative(y)
        # for example, we could say the 'major' chord shape is a subset of the 'maj7' chord shape.
        r = other.representative
        @words.any? {|word| (~word) | r == -1}
      end
    end

    def ~@
      Chord::PitchesModuloOctaves::ModuloTransposition.new(~@representative)
    end
    
    def empty?
      @representative == 0
    end

    # intersection and union aren't well-defined in this context
    
    def unique_transpositions
      @words.map {|word| Chord::PitchesModuloOctaves.new(word)}
    end
    
    # this fixes seemingly quite arbitrarily, based on the lexicographic choice of representative,
    # but you can vary the transposition offset to get different variations (not necessarily 12 distinct, as there may be symmetries, eg the whole-tone scale only has 2 distinct transpositions)
    def fix_transposition(offset=nil)
      result = Chord::PitchesModuloOctaves.new(@representative)
      result = result.map_add(offset) if offset
      result
    end
    
    # this also fixes seemingly quite arbitrarily, based on the lexicographic choice of representative
    def fix_pitch_octaves
      result = Chord::ModuloTransposition.new((0..11).select {|n| @representative & (1<<n) != 0})
    end
    alias :fix_starting_pitch :fix_pitch_octaves
    alias :fix_mode :fix_pitch_octaves
    alias :fix_inversion :fix_pitch_octaves
    
    # this will give you all modes of the scale. how many you get depends how many notes there are in the scale and what symmetries are present in it
    def modes
      fix_mode.modes
    end
    alias :inversions :modes
    
    
    SCALE_TYPES = {
      # 12-note
      'chromatic' => new([0,1,2,3,4,5,6,7,8,9,10,11]),

      # 9-note
      'nine-note blues' => new([0,2,3,4,5,7,9,10,11]), # http://en.wikipedia.org/wiki/Blues_scale

      # 7-note
      'major' => new([0,2,4,5,7,9,11]),
      '(harmonic) minor' => new([0,2,3,5,7,8,11]),
      'minor with major third' => new([0,2,4,5,7,8,11]),
      'melodic minor ascending' => new([0,2,3,5,7,9,11]),
      # 'melodic minor descending' => new([0,2,3,5,7,8,10]), # just a mode of the major scale
      'seven-note blues' => new([0,2,3,5,6,9,10]), # http://en.wikipedia.org/wiki/Blues_scale

      # 6-note
      'whole tone' => new([0,2,4,6,8,10]),
      'six-note blues' => new([0,3,5,6,7,10]), # http://en.wikipedia.org/wiki/Blues_scale
      'symmetrical augmented' => new([0,3,4,7,8,11]), # http://en.wikipedia.org/wiki/Hexatonic_scale#Augmented_scale
      'prometheus' => new([0,2,4,6,9,10]), # http://en.wikipedia.org/wiki/Hexatonic_scale#Prometheus_scale

      # 5-note
      'major pentatonic' => new([0,2,4,7,9]),
      'minor pentatonic' => new([0,3,5,7,10]),
      
      # 3-note
      'major triad' => new([0,4,7]),
      'minor triad' => new([0,3,7]),
      'diminished triad' => new([0,3,6]),

      # lots more i've ommitted
    }
    SCALE_TYPE_LOOKUP = SCALE_TYPES.invert
    
    def scale_type
      SCALE_TYPE_LOOKUP[self]
    end
  end
end