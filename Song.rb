require "muse"
require './chord.rb'

class Song
  def initialize(params = {})
    @bpm = params[:bpm]
    @name = params[:name]
    @@song = params[:song]
  end

  def perform
    Muse::Song.record(@name, { bpm: @bpm }) do
      @@song.split(" ").map.with_index do |block, i|
        beat = block.split("-")[0]
        chord = Chord.from_string(block)
        bar(i, b: beat, bpm: @bpm).notes { self.instance_eval(chord.notes) }
      end
    end
  end
end

# Song.new({
#   bpm: 90,
#   name: "Attention",
#   song: "4-Am-4 4-GM-4 4-Em-3 4-FM-3 8-Am-3"
# }).perform
