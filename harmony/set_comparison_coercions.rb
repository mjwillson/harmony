module Harmony
  module SetComparisonCoercions
    
    #  Embeddings between different layers of equivalence classes of (Pitch | PitchClass) sets. This commutes:
    #
    #       PitchSet::ModuloTransposition                       PitchClassSet::ModuloTransposition
    #    PitchSet compared modulo all transpositions         PitchSet compared modulo all transpositions
    #    Pitch offsets compared strictly --------------->  Pitches compared modulo octave transpositions  
    #                  ^                                                       ^
    #                  |                                                       |
    #       PitchSet::ModuloOctaves                              PitchClassSet::ModuloOctaves
    #    PitchSet compared modulo octave transpositions                       ^   [is isomorphic to the below, so
    #    Pitch offsets compared strictly                                      |    not actually implemented separately]
    #                 ^                                                       v
    #       PitchSet  |                                          PitchClassSet        
    #    PitchSet compared strictly        --------------->    PitchSet compared strictly
    #    Pitch offsets compared strictly                     Pitches compared modulo octave transpositions
    #
    # (guess who likes category theory)
    
    def pitches_modulo_octaves
      raise ArgumentError.new("Couldn't coerce #{self.class} to have pitches comparable modulo octaves")
    end

    def modulo_octaves
      raise ArgumentError.new("Couldn't coerce #{self.class} to be comparable modulo octaves")
    end
    
    def modulo_transposition
      raise ArgumentError.new("Couldn't coerce #{self.class} to be comparable modulo transposition")
    end

    module ComparesPitchClasses
      def pitches_modulo_octaves
        self
      end
      
      def modulo_octaves
        self
      end
    end

    module ComparesModuloOctaves
      def modulo_octaves
        self
      end
    end

    module ComparesModuloTransposition
      def modulo_transposition
        self
      end
      
      def modulo_octaves
        self
      end
    end

    def ==(other)
      compare(:==, other) {super(other)}
    end
    
    def subset?(other)
      compare(:subset?, other) {super(other)}
    end
    
    def superset?(other)
      other.subset?(self)
    end

    def compare(method, other)
      if !other.is_a?(SetComparisonCoercions)
        if method == :== then return false else raise ArgumentError.new("#{self.class} and #{other.class} not compatible for operation #{method}") end
      end
      # we have to pass it a block that calls super so it can call the original comparison method
      return yield if self.class == other.class

      a, b = self, other
      
      b = b.pitches_modulo_octaves if a.is_a?(ComparesPitchClasses) && !b.is_a?(ComparesPitchClasses)
      a = a.pitches_modulo_octaves if b.is_a?(ComparesPitchClasses) && !a.is_a?(ComparesPitchClasses)

      b = b.modulo_octaves if a.is_a?(ComparesModuloOctaves) && !b.is_a?(ComparesModuloOctaves)
      a = a.modulo_octaves if b.is_a?(ComparesModuloOctaves) && !a.is_a?(ComparesModuloOctaves)

      b = b.modulo_transposition if a.is_a?(ComparesModuloTransposition) && !b.is_a?(ComparesModuloTransposition)
      a = a.modulo_transposition if b.is_a?(ComparesModuloTransposition) && !a.is_a?(ComparesModuloTransposition)

      a.send(method, b)
    end
  end
end