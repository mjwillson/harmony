module Harmony
  # conceptually, a set of pitches, modulo a transposition of the whole pitch_set by some number of semitones (into a different key)
  # represented as: a set of intervals above the bottom pitch 0
  # corresponds to a 'shape of chord' - eg maj7, sus2 etc
  # or, a 'mode' of a scale, eg 'the Dorian mode of the major scale' - a scale with a particular note of the scale fixed as the starting note
  class PitchSet::ModuloTransposition
    def initialize(pitches)
      pitches = pitches.map {|n| n.to_i}
      pitches = Set.new(pitches) unless pitches.is_a?(Set)

      # we transform to a uniquely-determined representative for the equivalence class:
      min = pitches.min
      @interval_set = pitches.map! {|pitch| pitch - min}
    end

    attr_reader :interval_set

    include SetComparisonCoercions
    include SetComparisonCoercions::ComparesModuloTransposition

    def pitches_modulo_octaves
      PitchClassSet::ModuloTransposition.new(@interval_set)
    end

    def ==(other)
      compare(:==, other) {@interval_set == other.interval_set}
    end

    def hash
      @interval_set.inject(0) {|h, pitch| h ^ pitch} # Set#hash is actually a bit crap
    end
    def eql?(other)
      super || (other.is_a?(PitchSet::ModuloTransposition) && @interval_set == other.interval_set)
    end

    def subset?(other)
      compare(:subset?, other) do
        max_diff = other.interval_set.max - @interval_set.max
        # are there any offsets which we can slide our interval set by so that it lines up with a subset of the other's interval set?
        max_diff >= 0 && (0..max_diff).any? {|i| @interval_set.dup.map! {|j| j+i}.subset?(other.interval_set)}
      end
    end
    
    def empty?
      @interval_set.empty?
    end
    
    include DictionaryLookup

    name_objects_in_namespace "Jazz chord type",
      new([0, 4, 7]) => ['Major chord', 'Major'],
      new([0, 4, 7, 11]) => ['Major 7th chord', 'Major 7th', 'Major 7', 'Major seventh', 'Major seventh chord'],
      new([0, 4, 7, 11, 14]) => ['Major 9th chord', 'Major 9', 'Major ninth', 'Major 9th', 'Major ninth chord'],
      new([0, 4, 7, 11, 14, 17]) => ['Major 11th chord', 'Major 11', 'Major eleventh', 'Major 11th', 'Major eleventh chord'],
      new([0, 4, 7, 11, 14, 17, 21]) => ['Major 13th chord', 'Major 13', 'Major thirteenth', 'Major 13th', 'Major thirteenth chord'],
      new([0, 4, 7, 11, 14, 18]) => ['Major 9th sharp 11th chord', 'Major 9 sharp 11', 'Major ninth sharp eleventh', 'Major 9th sharp 11th', 'Major ninth sharp eleventh chord'],
      new([0, 4, 7, 11, 14, 18, 21]) => ['Major 13th sharp 11th chord', 'Major thirteenth sharp eleventh', 'Major 13th sharp 11th', 'Major thirteenth sharp eleventh chord'],
      new([0, 4, 7, 9]) => ['Major added 6th chord', 'Major 6', 'Major 6th', '6th', 'Added 6th', 'Major added 6th', 'Major sixth', 'Major added sixth', 'Major sixth chord'],
      new([0, 4, 7, 14]) => ['Major added 9th chord', 'Major add 9 chord', 'Major add 9th chord', 'Major add ninth', 'Major add ninth chord', 'Add 9th', 'Add ninth', 'Added 9th', 'Major added 9th', 'Added ninth', 'Major added ninth'],
      new([0, 4, 7, 9, 14]) => ['Major added 6th added 9th chord', 'Major 6 add 9', 'Major add 6 add 9', 'Major 6th add 9th', 'Major add 6th add 9th', 'Major sixth add ninth', 'Sixth add ninth', 'Major 6th added 9th', 'Major sixth added ninth', 'Sixth added ninth', 'Added sixth added ninth', 'Added 6th added 9th', 'Add 6th add 9th', 'Add 6 add 9'],
      new([0, 4, 6, 11]) => ['Major 7th flat 5th chord', 'Major 7th flat 5th', 'Major 7 flat 5', 'Major seventh flat fifth'],
      new([0, 4, 8, 11]) => ['Major 7th sharp 5th chord', 'Major 7th sharp 5th', 'Major 7 sharp 5', 'Major seventh sharp fifth'],
      new([0, 3, 7]) => ['Minor chord', 'Minor'],
      new([0, 3, 7, 10]) => ['Minor 7th chord', 'Minor 7th', 'Minor seventh'],
      new([0, 3, 7, 10, 14]) => ['Minor 9th chord', 'Minor 9th', 'Minor ninth'],
      new([0, 3, 7, 10, 14, 17]) => ['Minor 11th chord', 'Minor 11th', 'Minor eleventh'],
      new([0, 3, 7, 10, 14, 17, 21]) => ['Minor 13th chord', 'Minor 13th', 'Minor thirteenth'],
      new([0, 3, 7, 9]) => ['Minor 6th chord', 'Minor 6th', 'Minor sixth'],
      new([0, 3, 7, 14]) => ['Minor added 9th chord', 'Minor add 9 chord', 'Minor add 9th chord', 'Minor add ninth', 'Minor add ninth chord', 'Minor added 9th', 'Minor added ninth'],
      new([0, 3, 7, 9, 14]) => ['Minor 6th added 9th chord', 'Minor 6 add 9 chord', 'Minor 6th add 9th chord', 'Minor sixth add ninth', 'Minor sixth add ninth chord', 'Minor added 9th', 'Minor added ninth'],
      new([0, 3, 7, 11]) => ['Minor major 7th chord', 'Minor major 7th', 'Minor major seventh', 'Minor major 7'],
      new([0, 3, 7, 11, 14]) => ['Minor major 9th chord', 'Minor major 9th', 'Minor major ninth', 'Minor major 9'],
      new([0, 3, 6, 10]) => ['Minor 7th flat 5th chord', 'Minor 7th flat 5th', 'Minor seventh flat fifth', 'Minor 7 flat 5','Half-diminished seventh', 'Half-diminished 7th', 'Half-diminished 7th chord', 'Half-diminished seventh chord'],
      new([0, 3, 8, 10]) => ['Minor 7th sharp 5th chord', 'Minor 7th sharp 5th', 'Minor seventh sharp fifth', 'Minor 7 sharp 5'],
      new([0, 4, 7, 10]) => ['Dominant 7th chord', 'Dominant 7th', '7th', 'Seventh', 'Dominant seventh'],
      new([0, 4, 7, 10, 14]) => ['9th chord', '9th', 'Ninth'],
      new([0, 4, 7, 10, 14, 17]) => ['11th chord', '11th', 'Eleventh'],
      new([0, 4, 7, 10, 14, 17, 21]) => ['13th chord', '13th', 'Thirteenth'],
      new([0, 5, 7, 10]) => ['7th suspended 4th chord', '7th suspended 4th', 'Seventh suspended fourth'],
      new([0, 4, 6, 10]) => ['7th flat 5th chord', '7th flat 5th', 'Seventh flat fifth'],
      new([0, 4, 8, 10]) => ['7th sharp 5th chord', '7th sharp 5th', 'Seventh sharp fifth', 'Augmented 7th chord', '7th augmented 5th', 'Seventh augmented fifth'],
      new([0, 4, 7, 10, 13]) => ['7th flat 9th chord', '7th flat 9th', 'Seventh flat ninth'],
      new([0, 4, 7, 10, 15]) => ['7th sharp 9th chord', '7th sharp 9th', 'Seventh sharp ninth'],
      new([0, 4, 6, 10, 13]) => ['7th flat 5th flat 9th chord', '7th flat 5th flat 9th', 'Seventh flat fifth flat ninth'],
      new([0, 4, 6, 10, 15]) => ['7th flat 5th sharp 9th chord', '7th flat 5th sharp 9th', 'Seventh flat fifth sharp ninth'],
      new([0, 4, 8, 10, 13]) => ['7th sharp 5th flat 9th chord', '7th sharp 5th flat 9th', 'Seventh sharp fifth flat ninth'],
      new([0, 4, 8, 10, 15]) => ['7th sharp 5th sharp 9th chord', '7th sharp 5th sharp 9th', 'Seventh sharp fifth sharp ninth'],
      new([0, 4, 6, 10, 14]) => ['9th flat 5th chord', '9th flat 5th', 'Ninth flat fifth'],
      new([0, 4, 8, 10, 14]) => ['9th sharp 5th chord', '9th sharp 5th', 'Ninth sharp fifth'],
      new([0, 4, 7, 10, 14, 18, 21]) => ['13th sharp 11th chord', '13th sharp 11th', 'Thirteenth sharp eleventh'],
      new([0, 4, 7, 10, 13, 17, 21]) => ['13th flat 9th chord', '13th flat 9th', 'Thirteenth flat ninth'],
      new([0, 4, 7, 10, 13, 17]) => ['11th flat 9th chord', '11th flat 9th', 'Eleventh flat ninth'],
      new([0, 4, 8]) => ['Augmented chord', 'Augmented', 'Major augmented fifth', 'Augmented 5th', 'Augmented fifth', 'Major augmented 5th', 'Major sharp 5th', 'Major sharp fifth', 'Sharp 5th', 'Sharp fifth', 'Major augmented', 'Augmented major'],
      new([0, 3, 6]) => ['Diminished chord', 'Diminished', 'Minor flat 5th', 'Minor flat fifth'],
      new([0, 3, 6, 9]) => ['Diminished 7th chord', 'Diminished seventh', 'Diminished 7th'],
      new([0, 7]) => ['5th chord', '5th', 'Fifth', 'Power chord', 'Fifth chord'],
      new([0, 5, 7]) => ['Suspended 4th chord', 'Suspended chord', 'Suspended', 'Suspended 4th', 'Suspended fourth'],
      new([0, 2, 7]) => ['Suspended 2nd chord', 'Suspended 2nd', 'Suspended second'],
      new([0, 2, 5, 7]) => ['Suspended 2nd and 4th chord', 'Suspended 2nd suspended 4th', 'Suspended second suspended fourth', 'Suspended 2nd and 4th', 'Suspended second and fourth'],
      new([0, 4, 6]) => ['Major diminished 5th chord', 'Major diminished 5th', 'Diminished 5th', 'Major diminished fifth', 'Diminished fifth', 'Major diminished', 'Major flat 5th', 'Major flat fifth']

    name_objects_in_namespace "Jazz chord type suffix",
      new([0, 4, 7]) => ['maj',''],
      new([0, 4, 7, 11]) => ['maj7', 'maj 7'],
      new([0, 4, 7, 11, 14]) => ['maj9', 'maj 9'],
      new([0, 4, 7, 11, 14, 17]) => ['maj11', 'maj 11'],
      new([0, 4, 7, 11, 14, 17, 21]) => ['maj13', 'maj 13'],
      new([0, 4, 7, 11, 14, 18]) => ["maj9#{PitchClass::SHARP}11", 'maj9#11', 'maj 9 #11'],
      new([0, 4, 7, 11, 14, 18, 21]) => ["maj13#{PitchClass::SHARP}11", 'maj13#11', 'maj 13 #11'],
      new([0, 4, 7, 9]) => ['6','maj6', 'add6', 'add 6'],
      new([0, 4, 7, 14]) => ['add9', 'add 9'],
      new([0, 4, 7, 9, 14]) => ['6add9', '6 add 9', 'maj6add9', 'maj 6 add 9', '69', 'add6add9', 'add6 add9', 'add 6 add 9', 'add69'],
      new([0, 4, 6, 11]) => ['maj7b5', "maj7#{PitchClass::FLAT}5", 'maj 7 b5', "maj 7 #{PitchClass::FLAT}5"],
      new([0, 4, 8, 11]) => ['maj7#5', "maj7#{PitchClass::SHARP}5", 'maj 7 #5', "maj 7 #{PitchClass::SHARP}5", 'maj7+5', 'augmaj7', '+maj7', 'maj 7 +5', 'aug maj 7', '+ maj 7', 'maj 7 aug'],
      new([0, 3, 7]) => ['m','min'],
      new([0, 3, 7, 10]) => ['m7', 'm 7', 'min7', 'min 7'],
      new([0, 3, 7, 10, 14]) => ['m9', 'm 9', 'min9', 'min 9'],
      new([0, 3, 7, 10, 14, 17]) => ['m11', 'm 11', 'min11', 'min 11'],
      new([0, 3, 7, 10, 14, 17, 21]) => ['m13', 'm 13', 'min13', 'min 13'],
      new([0, 3, 7, 9]) => ['m6', 'm 6', 'min6', 'min 6', 'madd6', 'm add 6', 'min add 6', 'minadd6'],
      new([0, 3, 7, 14]) => ['madd9', 'm add 9', 'min add 9', 'minadd9'],
      new([0, 3, 7, 9, 14]) => ['m6add9', 'm 6 add 9', 'min6add9', 'min 6 add 9', 'min add 6 add 9', 'minadd6add9', 'minadd69', 'min add 6 9'],
      new([0, 3, 7, 11]) => ['mmaj7', 'm maj 7', 'min maj 7', 'mm7', 'm/M7', 'mM7'],
      new([0, 3, 7, 11, 14]) => ['mmaj9', 'm maj 9', 'min maj 9'],
      new([0, 3, 6, 10]) => ["m7#{PitchClass::FLAT}5", 'm7b5', 'm 7 b5', "m 7 #{PitchClass::FLAT}5"],
      new([0, 3, 8, 10]) => ["m7#{PitchClass::SHARP}5", 'm7#5', 'm 7 #5', "m 7 #{PitchClass::SHARP}5", 'm7+5', 'm 7 +5', 'm7aug5'],
      new([0, 4, 7, 10]) => '7',
      new([0, 4, 7, 10, 14]) => '9',
      new([0, 4, 7, 10, 14, 17]) => '11',
      new([0, 4, 7, 10, 14, 17, 21]) => '13',
      new([0, 5, 7, 10]) => ['7sus4', '7 sus 4', 'sus7', '7sus'],
      new([0, 2, 7, 10]) => ['7sus2', '7 sus 2'],
      new([0, 4, 6, 10]) => ["7#{PitchClass::FLAT}5", '7b5', "7 #{PitchClass::FLAT}5", '7 b5'],
      new([0, 4, 8, 10]) => ["7#{PitchClass::SHARP}5", '7#5', "7 #{PitchClass::SHARP}5", '7 #5', '7+5', '7 +5', '7aug5', '7 aug 5', '7 aug', '7+', '+7', '+ 7', 'aug7', 'aug 7'],
      new([0, 4, 7, 10, 13]) => ["7#{PitchClass::FLAT}9", '7b9', "7 #{PitchClass::FLAT}9", '7 b9'],
      new([0, 4, 7, 10, 15]) => ["7#{PitchClass::SHARP}9", '7#9', "7 #{PitchClass::SHARP}9", '7 #9'],
      new([0, 4, 6, 10, 13]) => ["7(#{PitchClass::FLAT}5,#{PitchClass::FLAT}9", '7(b5,b9)', '7b5b9', '7 b5 b9'],
      new([0, 4, 6, 10, 15]) => ["7(#{PitchClass::FLAT}5,#{PitchClass::SHARP}9", '7(b5,#9)', '7b5#9', '7 b5 #9'],
      new([0, 4, 8, 10, 13]) => ["7(#{PitchClass::SHARP}5,#{PitchClass::FLAT}9", '7(#5,b9)', '7#5b9', '7 #5 b9'],
      new([0, 4, 8, 10, 15]) => ["7(#{PitchClass::SHARP}5,#{PitchClass::SHARP}9", '7(#5,#9)', '7#5#9', '7 #5 #9'],
      new([0, 4, 6, 10, 14]) => ["9#{PitchClass::FLAT}5", '9b5', "9 #{PitchClass::FLAT}5", '9 b5'],
      new([0, 4, 8, 10, 14]) => ["9#{PitchClass::SHARP}5", '9#5', "9 #{PitchClass::SHARP}5", '9 #5', '9+5', '+9', '9aug5', '9 aug 5', '9 aug', '9+', 'aug 9', 'aug9'],
      new([0, 4, 7, 10, 14, 18, 21]) => ["13#{PitchClass::SHARP}11", '13#11', "13 #{PitchClass::SHARP}11", '13 #11'],
      new([0, 4, 7, 10, 13, 17, 21]) => ["13#{PitchClass::FLAT}9", '13b9', "13 #{PitchClass::FLAT}9", '13 b9'],
      new([0, 4, 7, 10, 13, 17]) => ["11#{PitchClass::FLAT}9", '11b9', "11 #{PitchClass::FLAT}9", '11 b9'],
      new([0, 4, 8]) => ['aug', '+', "-6", 'majb6', 'maj b6', 'maj#5', 'maj #5'],
      new([0, 3, 6]) => ['dim', 'minb5', 'min b5', 'm b5', 'm-5', 'm -5', 'min-5', 'min -5'],
      new([0, 3, 6, 9]) => ['dim7', 'dim 7'],
      new([0, 7]) => ['5'],
      new([0, 5, 7]) => ['sus4', 'sus', 'sus 4'],
      new([0, 2, 7]) => ['sus2', 'sus 2'],
      new([0, 2, 5, 7]) => ['sus2sus4', 'sus 2 sus 4', 'sus24', 'sus 2 4'],
      new([0, 4, 6]) => ['-5', 'majb5', 'majdim', 'maj b5', 'maj dim', 'dim5', 'majdim5', 'maj dim 5']
    
    name_objects_in_namespace "Mode",
      # 12-note
      new([0,1,2,3,4,5,6,7,8,9,10,11]) => ['Chromatic scale', 'Chromatic'],

      # 9-note
      # http://en.wikipedia.org/wiki/Blues_scale
      new([0,2,3,4,5,7,9,10,11]) => ['Nine-note blues scale', 'Nine-note blues', 'Nine note blues scale', 'Nine note blues'],

      # 7-note
      new([0,2,4,5,7,9,11]) => ['Major scale', 'Major scale', 'Diatonic scale', 'Ionian (I) mode', 'Ionian', 'Ionian mode'],
      new([0,2,3,5,7,9,10]) => ['Dorian (II) mode', 'Dorian', 'Dorian mode'],
      new([0,1,3,5,7,8,10]) => ['Phrygian (III) mode', 'Phrygian', 'Phrygian mode'],
      new([0,2,4,6,7,9,11]) => ['Lydian (IV) mode', 'Lydian', 'Lydian mode'],
      new([0,2,4,5,7,9,10]) => ['Mixolydian (V) mode', 'Mixolydian', 'Mixolydian mode'],
      new([0,2,3,5,7,8,10]) => ['Natural minor scale', 'Melodic minor descending scale', 'Melodic minor scale descending', 'Descending melodic minor scale', 'Descending melodic minor', 'Aeolian (VI) mode', 'Aeolian', 'Aeolian mode'],
      new([0,1,3,5,6,8,10]) => ['Locrian (VII) mode', 'Locrian', 'Locrian mode', 'Half diminished scale', 'Half-diminished scale'],

      new([0,2,3,5,7,8,11]) => ['Minor scale', 'Minor', 'Harmonic minor scale', 'Harmonic minor'],
      new([0,2,4,5,7,8,11]) => ['Minor scale with major third', 'Minor major scale'],
      new([0,2,3,5,7,9,11]) => ['Melodic minor ascending scale', 'Melodic minor scale ascending', 'Ascending melodic minor scale', 'Ascending melodic minor', 'Melodic minor ascending'],
      # http://en.wikipedia.org/wiki/Blues_scale
      new([0,2,3,5,6,9,10]) => ['Seven-note blues scale', 'Seven-note blues', 'Seven note blues scale', 'Seven note blues'],

      # 6-note
      new([0,2,4,6,8,10]) => ['Whole tone scale', 'Whole tone'],
      new([0,3,5,6,7,10]) => ['Six-note blues scale', 'Six-note blues', 'Six note blues scale', 'Six note blues'], # http://en.wikipedia.org/wiki/Blues_scale
      new([0,3,4,7,8,11]) => ['Augmented scale', 'Symmetrical augmented scale', 'Augmented', 'Symmetrical augmented'], # http://en.wikipedia.org/wiki/Hexatonic_scale#Augmented_scale
      new([0,2,4,6,9,10]) => ['Prometheus scale', 'Prometheus'], # http://en.wikipedia.org/wiki/Hexatonic_scale#Prometheus_scale

      # 5-note
      new([0,2,4,7,9]) => ['Major pentatonic scale', 'Major pentatonic'],
      new([0,3,5,7,10]) => ['Minor pentatonic scale', 'Minor pentatonic']


    name_objects_in_namespace "Triad inversion",
      # 3-note
      new([0,4,7]) => ['Major triad, root position', 'Major triad'],
      new([0,3,8]) => ['Major triad, 1st inversion', 'Major triad, first inversion'],
      new([0,5,9]) => ['Major triad, 2nd inversion', 'Major triad, second inversion'],

      new([0,3,7]) => ['Minor triad, root position', 'Minor triad'],
      new([0,4,9]) => ['Minor triad, 1st inversion', 'Minor triad, first inversion'],
      new([0,5,8]) => ['Minor triad, 2nd inversion', 'Minor triad, second inversion'],
      
      new([0,3,6]) => ['Diminished triad, root position', 'Diminished triad'],
      new([0,3,9]) => ['Diminished triad, 1st inversion', 'Diminished triad, first inversion'],
      new([0,6,9]) => ['Diminished triad, 2nd inversion', 'Diminished triad, second inversion']
    
    name_objects_in_namespace "Interval",
      new([0,1]) => 'Semitone',
      new([0,1]) => 'Minor 2nd',

      new([0,2]) => 'Tone',
      new([0,2]) => 'Whole tone',
      new([0,2]) => 'Major 2nd',

      new([0,3]) => 'Augmented 2nd',
      new([0,3]) => 'Minor 3rd',

      new([0,4]) => 'Major 3rd',

      new([0,5]) => 'Perfect 4th',

      new([0,6]) => 'Tritone',
      new([0,6]) => 'Augmented 4th',
      new([0,6]) => 'Diminished 5th',

      new([0,7]) => 'Perfect 5th',
 
      new([0,8]) => 'Augmented 5th',
      new([0,8]) => 'Minor 6th',

      new([0,9]) => 'Major 6th',

      new([0,10]) => 'Diminished 7th',

      new([0,11]) => 'Major 7th',
      
      new([0,12]) => 'Octave'

    def self.from_interval(n)
      new([0,n.to_i])
    end

    def to_interval
      Interval.new(@interval_set.max) if @interval_set.size == 2
    end

    
    def fix(start=0)
      PitchSet.new(@interval_set.map {|n| n+start.to_i})
    end
    
    # calculations of inversions of a chord / modes of a scale (essentially the same thing)
    
    def next_mode
      interval_set = @interval_set.dup
      octave_above_max = (interval_set.max / 12 + 1) * 12
      interval_set.delete(0); interval_set.add(octave_above_max)
      PitchSet::ModuloTransposition.new(interval_set)
    end
    alias :next_invertion :next_mode
    
    # this will give you all the modes of the corresponding scale. how many you get depends how many pitches there are in the scale and what symmetries are present in it.
    def modes
      result = []; mode = self
      while true
        result << mode
        mode = mode.next_mode
        break if mode == self
      end
      result
    end
    alias :inversions :modes
  end
end