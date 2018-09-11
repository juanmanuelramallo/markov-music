require "muse"
require './chord.rb'

class Song
  def initialize(params = {})
    @bpm = params[:bpm]
    @name = params[:name]
    @@song = params[:song]
    Chord.from_string("4-Am-3")
  end

  def perform
    Muse::Song.record(@name, { bpm: @bpm }) do
      @notes = Muse::NOTES.drop(1)
      @i = 0
      @modifiers = {
        "7" => 10,
        "maj7" => 11,
        "sus4" => 5,
        "add9" => 2,
        "5aum" => 8,
        "6" => 9
      }

      @@song.split(" ").map.with_index do |block, i|
        beat = block.split("-")[0]
        chord = Chord.from_string(block)
        bar(i, b: beat, bpm: @bpm).notes { self.instance_eval(chord.notes) }
      end
    end
  end
end

Song.new({
  bpm: 90,
  name: "Attention",
  song: "4-Am-4 4-GM-4 4-Em-3 4-FM-3 8-Am-3"
}).perform
