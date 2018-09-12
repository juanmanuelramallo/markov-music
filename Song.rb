require "muse"
require "./chord.rb"

class Song
  attr_reader :bpm, :title
  attr_accessor :tonic

  NOTES = Muse::NOTES.drop(1).freeze

  def initialize(params = {})
    @bpm = params[:bpm]
    @title = params[:title]
    @tonic = params[:tonic]
    @@chords = chords_assignment(params[:chords])
  end

  def transpose(new_tonic = "c")
    diff = NOTES.index(new_tonic) - NOTES.index(tonic)
    @@chords.map! { |chord| chord + diff }
    self
  end

  def perform
    Muse::Song.record(@title, { bpm: @bpm }) do
      @@chords.map.with_index do |chord, i|
        beat = 4
        bar(i, b: beat).notes { self.instance_eval(chord.notes) }
      end
    end
  end

  private

  def chords_assignment(chords_string)
    chords_string.split(" ").map do |chord|
      Chord.from_string(chord)
    end
  end
end

# puts Song.new({
#   bpm: 90,
#   title: "Attention",
#   tonic: "c",
#   chords: "4-Am-4 4-GM-4 4-Em-3 4-FM-3 8-Am-3"
# }).transpose("f").perform
