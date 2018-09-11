require "muse"

class Chord
  attr_reader :tonic, :octave, :is_major, :modifiers

  MODIFIERS = {
    "7" => 10,
    "maj7" => 11,
    "sus4" => 5,
    "add9" => 2,
    "5aum" => 8,
    "6" => 9
  }.freeze

  NOTES = Muse::NOTES.drop(1).freeze

  def self.from_string(chord)
    _, chord_name, octave = chord.split("-")
    tonic = chord_name.scan(/[^mM]/)[0].downcase
    is_major = chord_name.scan(/[mM]/)[0] == "M"
    first_modifier = chord_name.index("_") || chord_name.size - 1
    modifiers = chord_name[first_modifier + 1, chord_name.size].split("_")
    new({ tonic: tonic, M: is_major, modifiers: modifiers, octave: octave })
  end

  def initialize(options = {})
    @tonic = options[:tonic].downcase
    @is_major = options[:M]
    @modifiers = options[:modifiers]
    @octave = options[:octave] || 3
  end

  def notes
    indexes = []
    tonic_index = NOTES.index(tonic)
    indexes = modifiers.map { |modifier| tonic_index + MODIFIERS[modifier] }.compact
    indexes << (tonic_index + (is_major ? 4 : 3)) unless modifiers.include?("sus4")
    indexes << (tonic_index + 7)
    indexes << tonic_index
    indexes.map { |i| note(i) }.join("#{octave}_") + "#{octave}"
  end

  private

  def note(index)
    NOTES[index % NOTES.length]
  end
end

# puts Chord.new({ tonic: "D", M: false, modifiers: %w(7), octave: 4 }).notes
# puts Chord.from_string("4-Dm_7-4").notes
