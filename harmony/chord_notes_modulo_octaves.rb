module Harmony
  # A set of notes / combination of pitches, with the notes themselves (as well as the chord as a whole) treated regardless of the octave they're in.
  # Eg, the Dminor chord, regardless of whether it's inverted (A,D,F vs D,F,A) / what octave the notes are in.
  # Effectively a subset of {0, ..., 11}
  class Chord::NotesModuloOctaves
    attr_reader :word
    def initialize(arg)
      @word = case arg
      when Fixnum then arg
      when Enumerable
        # integer bitfield with 12 binary digits representing the 12 notes
        arg.inject(0) {|acc, n| acc | (1 << (n.to_i % 12))}
      end
    end

    def map_add(interval)
      interval = interval.to_i % 12
      Chord::NotesModuloOctaves.new((@word << interval) & 4095 | (@word >> (12-interval)))
    end
    alias_method :transpose, :map_add

    include Enumerable
    def each
      12.times {|n| yield NoteClass[n] if @word & (1<<n) != 0}
    end

    include ComparisonCoercions
    include ComparisonCoercions::ComparesNotesModuloOctaves

    def modulo_transposition
      Chord::NotesModuloOctaves::ModuloTransposition.new(@word)
    end
    
    def ==(other)
      compare(:==, other) {@word == other.word}
    end

    def hash
      @word
    end
    def eql?(other)
      super || (other.is_a?(Chord::NotesModuloOctaves) && @word == other.word)
    end
  
    def subset?(other)
      compare(:subset?, other) {(~@word) | other.word == -1}
    end
    
    def &(other)
      compare(:&, other) {Chord::NotesModuloOctaves.new(@word & other.word)}
    end

    def |(other)
      compare(:|, other) {Chord::NotesModuloOctaves.new(@word | other.word)}
    end
    
    def ~@
      Chord::NotesModuloOctaves.new(~@word)
    end
    
    def empty?
      @word == 0
    end
    
    def inspect
      "#{self.class}.new(#{to_a.inspect})"
    end
    
    def to_s
      "ChordNotesModuloOctaves(#{to_a.join(',')})"
    end
  end
end