module Harmony
  class Constraint::BassNote < Constraint
    def initialize(note)
      @note == note
    end

    def match(chord)
      chord.min == @note
    end
  end
end