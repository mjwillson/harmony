module Harmony
  # A vector of Pitches
  Vector[Pitch].class_eval do
    def self.new(pitches)
      super(pitches.map {|s| s.is_a?(String) ? Pitch[s] : s})
    end
  
    GUITAR_TUNING = new(['E3','A3','D4','G4','B4','E5'])
  end
end