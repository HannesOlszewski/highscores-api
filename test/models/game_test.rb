require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup { @game = games(:pong) }

  test "name must be URL-safe and unique" do
    assert Game.new(name: "space-invaders_2").valid?
    assert_not Game.new(name: "space invaders").valid?
    assert_not Game.new(name: "pong.json").valid?
    assert_not Game.new(name: "new").valid?
    assert_not Game.new(name: "pong").valid?
  end

  test "to_param keeps the persisted name while a rename is invalid" do
    @game.name = "not valid"
    assert_equal "pong", @game.to_param
  end

  test "destroying a game deletes its scores" do
    assert_difference "Score.count", -2 do
      @game.destroy
    end
  end

  test "leaderboard orders by score, then by who got there first" do
    @game.submit_score(name: "carol", score: 300)
    assert_equal %w[ alice carol bob ], @game.leaderboard.map(&:name)
  end

  test "submit_score creates a new entry" do
    score = @game.submit_score(name: "carol", score: 200)

    assert score.previously_new_record?
    assert_equal 200, score.score
    assert_equal 2, score.rank
  end

  test "submit_score raises an existing player's score" do
    score = @game.submit_score(name: "bob", score: 500)

    assert_not score.previously_new_record?
    assert_equal 500, scores(:bob).reload.score
    assert_equal 1, score.rank
  end

  test "submit_score keeps the player's best score" do
    assert_no_changes -> { scores(:alice).reload.updated_at } do
      score = @game.submit_score(name: "alice", score: 10)
      assert_equal 300, score.score
    end
  end

  test "submit_score matches names after stripping whitespace" do
    assert_no_difference "Score.count" do
      @game.submit_score(name: " alice ", score: 400)
    end
    assert_equal 400, scores(:alice).reload.score
  end

  test "submit_score returns validation errors without saving" do
    score = @game.submit_score(name: "alice", score: "lots")

    assert_includes score.errors[:score], "is not a number"
    assert_equal 300, scores(:alice).reload.score
  end

  test "submit_score keeps only the best LEADERBOARD_SIZE scores" do
    game = games(:tetris)
    Game::LEADERBOARD_SIZE.times { |i| game.submit_score(name: "player#{i}", score: 100 + i) }

    assert_no_difference "game.scores.count" do
      assert_not_nil game.submit_score(name: "newcomer", score: 1_000).rank
    end
    assert_nil game.scores.find_by(name: "player0")

    assert_nil game.submit_score(name: "loser", score: 1).rank
    assert_nil game.scores.find_by(name: "loser")
    assert_equal Game::LEADERBOARD_SIZE, game.reload.scores_count
  end
end
