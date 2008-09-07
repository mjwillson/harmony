module Harmony
  module ComparisonCoercions
    
    #  Embeddings between different layers of equivalence classes. This commutes:
    #
    #       Chord::ModuloTransposition                       Chord::NotesModuloOctaves::ModuloTransposition
    #    Chord compared modulo all transpositions         Chord compared modulo all transpositions
    #    Note offsets compared strictly --------------->  Notes compared modulo octave transpositions  
    #                 ^                                                        ^
    #                 |                                                        |
    #       Chord::ModuloOctaves                              'Chord::NotesModuloOctaves::ModuloOctaves'
    #    Chord compared modulo octave transpositions                          ^   [is isomorphic to the below, so
    #    Note offsets compared strictly                                       |    not actually implemented separately]
    #                ^                                                        v
    #       Chord    |                                        Chord::NotesModuloOctaves        
    #    Chord compared strictly        --------------->    Chord compared strictly
    #    Note offsets compared strictly                     Notes compared modulo octave transpositions
    #
    # (guess who likes category theory)
    
    def notes_modulo_octaves
      raise ArgumentError.new("Couldn't coerce #{self.class} to have notes comparable modulo octaves")
    end

    def modulo_octaves
      raise ArgumentError.new("Couldn't coerce #{self.class} to be comparable modulo octaves")
    end
    
    def modulo_transposition
      raise ArgumentError.new("Couldn't coerce #{self.class} to be comparable modulo transposition")
    end

    module ComparesNotesModuloOctaves
      def notes_modulo_octaves
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
      if !other.is_a?(ComparisonCoercions)
        if method == :== then return false else raise ArgumentError.new("#{self.class} and #{other.class} not compatible for operation #{method}") end
      end
      # we have to pass it a block that calls super so it can call the original comparison method
      return yield if self.class == other.class

      a, b = self, other
      
      b = b.notes_modulo_octaves if a.is_a?(ComparesNotesModuloOctaves) && !b.is_a?(ComparesNotesModuloOctaves)
      a = a.notes_modulo_octaves if b.is_a?(ComparesNotesModuloOctaves) && !a.is_a?(ComparesNotesModuloOctaves)

      b = b.modulo_octaves if a.is_a?(ComparesModuloOctaves) && !b.is_a?(ComparesModuloOctaves)
      a = a.modulo_octaves if b.is_a?(ComparesModuloOctaves) && !a.is_a?(ComparesModuloOctaves)

      b = b.modulo_transposition if a.is_a?(ComparesModuloTransposition) && !b.is_a?(ComparesModuloTransposition)
      a = a.modulo_transposition if b.is_a?(ComparesModuloTransposition) && !a.is_a?(ComparesModuloTransposition)

      a.send(method, b)
    end
  end
end