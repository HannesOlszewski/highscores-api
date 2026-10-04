require "test_helper"

class ScoreTest < ActiveSupport::TestCase
  test "score must be an integer" do
    assert Score.new(game: games(:pong), name: "carol", score: -5).valid?
    assert Score.new(game: games(:pong), name: "carol", score: 2**40).valid?
    assert_not Score.new(game: games(:pong), name: "carol", score: 1.5).valid?
    assert_not Score.new(game: games(:pong), name: "carol", score: "abc").valid?
    assert_not Score.new(game: games(:pong), name: "carol", score: 2**64).valid?
  end

  test "name is required and limited in length" do
    assert_not Score.new(game: games(:pong), name: "  ", score: 1).valid?
    assert_not Score.new(game: games(:pong), name: "x" * 51, score: 1).valid?
  end
end
