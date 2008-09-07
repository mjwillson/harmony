require 'set'
module Harmony
  # A set of notes / combination of pitches
  class Chord
    attr_reader :notes
    def initialize(notes)
      notes = notes.map {|n| n.to_i}
      notes = Set.new(notes) unless notes.is_a?(Set)
      @notes = notes
    end

    def map_add(interval)
      Chord.new(@notes.map {|x| x + interval.to_i})
    end
    alias_method :transpose, :map_add

    def max
      Note[@notes.max]
    end
    
    def min
      Note[@notes.min]
    end
    
    def range
      Interval[@notes.max - @notes.min]
    end
    
    include Enumerable
    def each
      @notes.each {|n| yield Note[n]}
    end

    include ComparisonCoercions

    def modulo_octaves
      Chord::ModuloOctaves.new(@notes)
    end
    
    def modulo_transposition
      Chord::ModuloTransposition.new(@notes)
    end
    
    def notes_modulo_octaves
      Chord::NotesModuloOctaves.new(@notes)
    end
    
    def ==(other)
      compare(:==, other) {@notes == other.notes}
    end

    def hash
      @notes.inject(0) {|h, note| h ^ note} # Set#hash is actually a bit crap
    end
    def eql?(other)
      super || (other.is_a?(Chord) && @notes == other.notes)
    end
  
    def subset?(other)
      compare(:subset?, other) {@notes.subset?(other.notes)}
    end
    
    def &(other)
      compare(:&, other) {Chord.new(@notes & other.notes)}
    end

    def |(other)
      compare(:|, other) {Chord.new(@notes | other.notes)}
    end
    
    def empty?
      @notes.empty?
    end
    
    def inspect
      "#{self.class}.new(#{to_a.inspect})"
    end
    
    def to_s
      "Chord(#{to_a.join(',')})"
    end
    
    def jazz_chord
      modulo_octaves.jazz_chord
    end
    
    def jazz_chord_type
      modulo_transposition.jazz_chord_type
    end
  end
end