module Harmony
  # this is a 'binary 12-necklace' (a word of length 12 over a binary alphabet, taken modulo cyclic permutations).
  # alternatively, a set of notes-modulo-octave, treated (as a whole) modulo any transposition into another key
  # alternatively, a shape of chord, without regard for which octave any given note of the chord is placed in.
  # alternatively, a type of scale, as in "Major" or "Minor pentatonic", without regard for which note of the scale is seen as the starting note (that would be a 'mode')
  class Chord::NotesModuloOctaves::ModuloTransposition
    def initialize(arg)
      word = case arg
      when Fixnum then arg
      when Enumerable
        # integer bitfield with 12 binary digits representing the 12 notes
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
      super || (other.is_a?(Chord::NotesModuloOctaves::ModuloTransposition) && other.representative == @representative)
    end
    
    include ComparisonCoercions
    include ComparisonCoercions::ComparesModuloOctaves
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
      Chord::NotesModuloOctaves::ModuloTransposition.new(~@representative)
    end
    
    def empty?
      @representative == 0
    end

    # intersection and union aren't well-defined in this context
    
    def unique_transpositions
      @words.map {|word| Chord::NotesModuloOctaves.new(word)}
    end
    
    # this fixes seemingly quite arbitrarily, based on the lexicographic choice of representative,
    # but you can vary the transposition offset to get different variations (not necessarily 12 distinct, as there may be symmetries, eg the whole-tone scale only has 2 distinct transpositions)
    def fix_transposition(offset=nil)
      result = Chord::NotesModuloOctaves.new(@representative)
      result = result.map_add(offset) if offset
      result
    end
    
    # this also fixes seemingly quite arbitrarily, based on the lexicographic choice of representative
    def fix_note_octaves
      result = Chord::ModuloTransposition.new((0..11).select {|n| @representative & (1<<n) != 0})
    end
    alias :fix_starting_note :fix_note_octaves
    alias :fix_mode :fix_note_octaves
    alias :fix_inversion :fix_note_octaves
    
    # this will give you all modes of the scale. how many you get depends how many notes there are in the scale and what symmetries are present in it
    def modes
      fix_mode.modes
    end
    alias :inversions :modes
  end
end