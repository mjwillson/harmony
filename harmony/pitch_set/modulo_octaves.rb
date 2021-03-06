module Harmony
  # conceptually, a set of pitches, modulo a transposition of the whole pitch_set by some number of octaves
  # represented as: a set of intervals above the bottom pitch 0
  # corresponds to something like, eg, Gmaj7 chord pattern (regardless of which octave's G it starts on)
  # or, eg, C minor scale (regardless of which octave)
  class PitchSet::ModuloOctaves
    def initialize(pitches)
      pitches = pitches.map {|n| n.to_i}
      pitches = Set.new(pitches) unless pitches.is_a?(Set)

      # we transform to a uniquely-determined representative for the equivalence class:
      start_of_octave_of_min_pitch = pitches.min / 12 * 12 
      @interval_set = pitches.map! {|pitch| pitch - start_of_octave_of_min_pitch}
    end

    attr_reader :interval_set

    include SetComparisonCoercions
    include SetComparisonCoercions::ComparesModuloOctaves

    def pitches_modulo_octaves
      PitchClassSet.new(@interval_set)
    end
    
    def modulo_transposition
      PitchSet::ModuloTransposition.new(@interval_set)
    end

    def ==(other)
      compare(:==, other) {@interval_set == other.interval_set}
    end

    def hash
      @interval_set.inject(0) {|h, pitch| h ^ pitch} # Set#hash is actually a bit crap
    end
    def eql?(other)
      super || (other.is_a?(PitchSet::ModuloOctaves) && @interval_set == other.interval_set)
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
      PitchSet.new(@interval_set.map {|i| i+octave*12})
    end
    
    def inspect
      fix.inspect + '.modulo_octaves'
    end
    
    def to_s
      "PitchSetModuloOctaves(#{fix.to_a.join(',')})"
    end
    
    def jazz_chord
      jct = modulo_transposition.jazz_chord_type
      PitchClass.new(@interval_set.min).to_s + jct if jct
    end
  end
end