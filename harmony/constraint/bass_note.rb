module Harmony
  class Constraint::BassPitch < Constraint
    def initialize(pitch)
      @pitch == pitch
    end

    def match(chord)
      chord.min == @pitch
    end
  end
end