module Harmony
  class Constraint::NoteClasses < Constraint
    def initialize(notes)
      @notes == notes
    end

    def match(chord)
      @notes.all? {|note| chord.include?(note)}
    end
  end
end