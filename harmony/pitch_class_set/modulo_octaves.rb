module Harmony
  class PitchClassSet
    ModuloOctaves = self # since individual notes are already compared by their pitch-class, shifting the whole pitch-class-set by an octave makes no difference.
  end
end