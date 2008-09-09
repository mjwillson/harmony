module Harmony
  # this is a 'binary 12-necklace' (a word of length 12 over a binary alphabet, taken modulo cyclic permutations).
  # alternatively, a set of pitches-modulo-octave, treated (as a whole) modulo any transposition into another key
  # alternatively, a shape of chord, without regard for which octave any given note of the chord is placed in.
  # alternatively, a type of scale, as in "Major" or "Minor pentatonic", without regard for which note of the scale is seen as the starting note (that would be a 'mode')
  class PitchClassSet::ModuloTransposition
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
      super || (other.is_a?(PitchClassSet::ModuloTransposition) && other.representative == @representative)
    end
    
    include SetComparisonCoercions
    include SetComparisonCoercions::ComparesModuloOctaves
    include SetComparisonCoercions::ComparesPitchClasses
    include SetComparisonCoercions::ComparesModuloTransposition
    
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
      PitchClassSet::ModuloTransposition.new(~@representative)
    end
    
    def empty?
      @representative == 0
    end

    # intersection and union aren't well-defined in this context
    
    def unique_transpositions
      @words.map {|word| PitchClassSet.new(word)}
    end
    
    # this fixes seemingly quite arbitrarily, based on the lexicographic choice of representative,
    # but you can vary the transposition offset to get different variations (not necessarily 12 distinct, as there may be symmetries, eg the whole-tone scale only has 2 distinct transpositions)
    def fix_transposition(offset=nil)
      result = PitchClassSet.new(@representative)
      result = result.map_add(offset) if offset
      result
    end
    
    # this also fixes seemingly quite arbitrarily, based on the lexicographic choice of representative
    def fix_pitch_octaves
      result = PitchSet::ModuloTransposition.new((0..11).select {|n| @representative & (1<<n) != 0})
    end
    alias :fix_starting_pitch :fix_pitch_octaves
    alias :fix_mode :fix_pitch_octaves
    alias :fix_inversion :fix_pitch_octaves
    
    # this will give you all modes of the scale. how many you get depends how many notes there are in the scale and what symmetries are present in it
    def modes
      fix_mode.modes
    end
    alias :inversions :modes
    
    
    include DictionaryLookup
    
    name_objects_in_namespace "Scale",
      # 12-note
      new([0,1,2,3,4,5,6,7,8,9,10,11]) => ['Chromatic scale', 'Chromatic'],

      # 9-note
      # http://en.wikipedia.org/wiki/Blues_scale
      new([0,2,3,4,5,7,9,10,11]) => ['Nine-note blues scale', 'Nine-note blues', 'Nine note blues scale', 'Nine note blues'],

      # 7-note
      new([0,2,4,5,7,9,11]) => ['Major scale', 'Major', 'Diatonic scale', 'Diatonic', 'Natural minor scale', 'Natural minor', 'Melodic minor scale descending', 'Melodic minor descending scale', 'Descending melodic minor scale', 'Melodic minor descending'],
      new([0,2,3,5,7,8,11]) => ['Minor scale', 'Minor', 'Harmonic minor scale', 'Harmonic minor'],
      new([0,2,4,5,7,8,11]) => ['Minor scale with major third', 'Minor major scale'],
      new([0,2,3,5,7,9,11]) => ['Melodic minor ascending scale', 'Melodic minor scale ascending', 'Ascending melodic minor scale', 'Ascending melodic minor', 'Melodic minor ascending'],
      # http://en.wikipedia.org/wiki/Blues_scale
      new([0,2,3,5,6,9,10]) => ['Seven-note blues scale', 'Seven-note blues', 'Seven note blues scale', 'Seven note blues'],

      # 6-note
      new([0,2,4,6,8,10]) => ['Whole tone scale', 'Whole tone'],
      new([0,3,5,6,7,10]) => ['Six-note blues scale', 'Six-note blues', 'Six note blues scale', 'Six note blues'], # http://en.wikipedia.org/wiki/Blues_scale
      new([0,3,4,7,8,11]) => ['Augmented scale', 'Symmetrical augmented scale', 'Augmented', 'Symmetrical augmented'], # http://en.wikipedia.org/wiki/Hexatonic_scale#Augmented_scale
      new([0,2,4,6,9,10]) => ['Prometheus', 'Prometheus scale'], # http://en.wikipedia.org/wiki/Hexatonic_scale#Prometheus_scale

      # 5-note
      new([0,2,4,7,9]) => ['Major pentatonic scale', 'Major pentatonic'],
      new([0,3,5,7,10]) => ['Minor pentatonic scale', 'Minor pentatonic']
    
    name_objects_in_namespace "Key",
      new([0,2,4,5,7,9,11]) => ['Major key', 'Major'],
      new([0,2,3,5,7,8,11]) => ['Minor key', 'Minor'],
      new([0,2,3,5,7,8,9,10,11]) => ['Minor key with ascending and descending melodic notes', 'Minor key with melodic notes', 'Minor key with variations']
      
    
    name_objects_in_namespace "Triad",
      new([0,4,7]) => ['Major triad', 'Major'],
      new([0,3,7]) => ['Minor triad', 'Minor'],
      new([0,3,6]) => ['Diminished triad', 'Diminished']

      # lots more i've ommitted
  end
end