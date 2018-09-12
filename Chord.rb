require "muse"

class Chord
  attr_reader :octave, :is_major, :modifiers
  attr_accessor :tonic, :semitones

  MODIFIERS = {
    "7" => 10,
    "maj7" => 11,
    "sus4" => 5,
    "add9" => 2,
    "5aum" => 8,
    "6" => 9
  }.freeze

  NOTES = Muse::NOTES.drop(1).freeze

  def self.g(chord)
    Chord.from_string("0-#{chord}-3")
  end

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
    @semitones = notes_in_semitones_from_tonic
  end

  def name
    ["#{tonic.capitalize}#{is_major ? 'M' : 'm'}", modifier_names].compact.join("_")
  end

  def notes
    semitones.map { |i| note(i) }.join("#{octave}_") + "#{octave}"
  end

  def +(semitones_amount)
    semitones.map! { |semitone| semitone + semitones_amount }
    @tonic = NOTES[(NOTES.index(tonic) + semitones_amount) % NOTES.size]
    self
  end

  private

  def note(index)
    NOTES[index % NOTES.length]
  end

  def modifier_names
    return nil if modifiers.empty?
    modifiers.select { |modifier| MODIFIERS[modifier] }.sort.join("_")
  end

  def notes_in_semitones_from_tonic
    @semitones = []
    tonic_index = NOTES.index(tonic)
    @semitones = modifiers.map { |modifier| tonic_index + MODIFIERS[modifier] }.compact
    @semitones << (tonic_index + (is_major ? 4 : 3)) unless modifiers.include?("sus4")
    @semitones << (tonic_index + 7)
    @semitones << tonic_index
  end
end

# puts Chord.new({ tonic: "E", M: true, modifiers: %w(maj7 add9) }).name
# puts Chord.g("Dm_7").name
# puts (Chord.g("Dm")).name
