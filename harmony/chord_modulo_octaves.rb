module Harmony
  # conceptually, a set of notes, modulo a transposition of the whole chord by some number of octaves
  # represented as: a set of intervals above the bottom note 0
  # corresponds to something like, eg, Gmaj7 chord pattern (regardless of which octave's G it starts on)
  # or, eg, C minor scale (regardless of which octave)
  class Chord::ModuloOctaves
    def initialize(notes)
      notes = notes.map {|n| n.to_i}
      notes = Set.new(notes) unless notes.is_a?(Set)

      # we transform to a uniquely-determined representative for the equivalence class:
      start_of_octave_of_min_note = notes.min / 12 * 12 
      @interval_set = notes.map! {|note| note - start_of_octave_of_min_note}
    end

    attr_reader :interval_set

    include ComparisonCoercions
    include ComparisonCoercions::ComparesModuloOctaves

    def notes_modulo_octaves
      Chord::NotesModuloOctaves.new(@interval_set)
    end
    
    def modulo_transposition
      Chord::ModuloTransposition.new(@interval_set)
    end

    def ==(other)
      compare(:==, other) {@interval_set == other.interval_set}
    end

    def hash
      @interval_set.inject(0) {|h, note| h ^ note} # Set#hash is actually a bit crap
    end
    def eql?(other)
      super || (other.is_a?(Chord::ModuloOctaves) && @interval_set == other.interval_set)
    end

    def subset?(other)
      compare(:subset?, other) do
        max_octaves_diff = (other.interval_set.max / 12) - (@interval_set.max / 12)
        # are there any octave offsets which we can slide our interval set by so that it lines up with a subset of the other's interval set?
        max_octaves_diff >= 0 && (0..max_octaves_diff).any? {|i| @interval_set.map {|j| j+i*12}.subset?(other.interval_set)}
      end
    end
    
    def empty?
      @interval_set.empty?
    end
    
    def fix(octave=0)
      Chord.new(@interval_set.map {|i| i+octave*12})
    end
    
    def inspect
      fix.inspect + '.modulo_octaves'
    end
    
    def to_s
      "ChordModuloOctaves(#{fix.to_a.join(',')})"
    end
    
    def jazz_chord
      jct = modulo_transposition.jazz_chord_type
      NoteClass[@interval_set.min].to_s + jct if jct
    end
  end
end