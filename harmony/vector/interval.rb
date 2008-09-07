module Harmony
  # A vector of Intervals (useful for representing a set of finger positions relative to a particular tuning on a stringed instrument...)
  Vector[Interval].class_eval do
    def to_chord_diagram
      open_or_not_used_row = "    " + map do |i|
        case i
        when 0 then 'O'
        when nil then 'X'
        else ' '
        end
      end.join(' ')

      min_non_open = select {|i| i && i > 0}.min
      min_non_open = Interval.new(1) if min_non_open <= 2

      fret_rows = (min_non_open..max).map do |i|
        frets = map {|j| j == i ? 'O' : '|'}.join(' ')
        sprintf('%2d  %s', i, frets)
      end
      
      result = [open_or_not_used_row]
      result << '    +-+-+-+-+-+' if min_non_open == 1
      result.concat(fret_rows)
      result.join("\n")
    end
  end
end