require "test_helper"

class ScoresControllerTest < ActionDispatch::IntegrationTest
  test "index lists the leaderboard without signing in" do
    get "/games/pong/scores"

    assert_response :success
    assert_equal "application/json", response.media_type
    assert_equal [
      { "rank" => 1, "name" => "alice", "score" => 300 },
      { "rank" => 2, "name" => "bob", "score" => 100 }
    ], response.parsed_body
  end

  test "index returns an empty list for a game without scores" do
    get "/games/tetris/scores"

    assert_response :success
    assert_equal [], response.parsed_body
  end

  test "index returns 404 for an unknown game" do
    get "/games/missing/scores"

    assert_response :not_found
    assert_equal({ "error" => "Game not found" }, response.parsed_body)
  end

  test "create adds a new score" do
    assert_difference "Score.count" do
      post "/games/pong/scores", params: { name: "carol", score: 200 }, as: :json
    end

    assert_response :created
    assert_equal({ "rank" => 2, "name" => "carol", "score" => 200 }, response.parsed_body)
  end

  test "create updates an existing player's score" do
    assert_no_difference "Score.count" do
      post "/games/pong/scores", params: { name: "bob", score: 500 }, as: :json
    end

    assert_response :ok
    assert_equal({ "rank" => 1, "name" => "bob", "score" => 500 }, response.parsed_body)
  end

  test "create keeps the player's best score" do
    post "/games/pong/scores", params: { name: "alice", score: 1 }, as: :json

    assert_response :ok
    assert_equal({ "rank" => 1, "name" => "alice", "score" => 300 }, response.parsed_body)
  end

  test "create reports a null rank when the score doesn't make the leaderboard" do
    game = games(:tetris)
    Game::LEADERBOARD_SIZE.times { |i| game.scores.create!(name: "player#{i}", score: 100) }

    assert_no_difference "Score.count" do
      post "/games/tetris/scores", params: { name: "carol", score: 1 }, as: :json
    end

    assert_response :ok
    assert_equal({ "rank" => nil, "name" => "carol", "score" => 1 }, response.parsed_body)
  end

  test "create rejects a non-integer score" do
    post "/games/pong/scores", params: { name: "carol", score: "lots" }, as: :json

    assert_response :unprocessable_content
    assert_equal({ "errors" => { "score" => [ "is not a number" ] } }, response.parsed_body)
  end

  test "create requires name and score" do
    post "/games/pong/scores", params: { name: "carol" }, as: :json

    assert_response :bad_request
    assert_match "score", response.parsed_body["error"]
  end

  test "create returns 404 for an unknown game" do
    post "/games/missing/scores", params: { name: "carol", score: 1 }, as: :json

    assert_response :not_found
  end
end
