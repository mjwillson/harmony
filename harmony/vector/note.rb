module Harmony
  # A vector of Notes
  Vector[Note].class_eval do
    def self.new(notes)
      super(notes.map {|s| s.is_a?(String) ? Note[s] : s})
    end
  
    GUITAR_TUNING = new(['E3','A3','D4','G4','B4','E5'])
  end
end