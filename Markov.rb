require 'pickup'
require 'yaml'

class Markov
  attr_accessor :chords
  attr_reader :file_name

  def initialize(file_name: "markov.yml")
    @file_name = file_name
    @chords = YAML.load_file(file_name) || {}
  end

  def learn(current_chord_name, next_chord_name, write_to_file=true)
    chords[current_chord_name] ||= {}
    chords[current_chord_name][next_chord_name] ||= 0
    chords[current_chord_name][next_chord_name] += 1
    # puts "Learn #{current_chord_name} -> #{next_chord_name}"
    write if write_to_file
  end

  def learn_from_song(song)
    chords = song.split(" ")
    chords.each.with_index do |chord, i|
      break if i == chords.size - 1
      learn(chord, chords[i + 1], false)
    end
    write
  end

  def write
    File.write(file_name, chords.to_yaml)
  end

  def next_chord(from_chord_name)
    if chords[from_chord_name].nil?
      # puts " [ EMPTY ] "
      return "_"
    end

    pickup = Pickup.new(chords[from_chord_name])
    picked = pickup.pick 1
    # puts "\t#{from_chord_name} -> #{picked}"
    picked
  end

  def future(from_chord_name, steps)
    return if steps.zero? || steps.nil?

    previous_chord_name = from_chord_name
    (1..steps).flat_map do |_|
      previous_chord_name = next_chord previous_chord_name
    end
  end
end

# m = Markov.new
# m.learn_from_song("CM Dm FM Am GM CM CM FM")

# # m.future("CM", 5)
