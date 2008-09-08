module Harmony
  class Constraint::PitchClasses < Constraint
    def initialize(pitches)
      @pitches == pitches
    end

    def match(chord)
      @pitches.all? {|pitch| chord.include?(pitch)}
    end
  end
end