require "test_helper"

class GamesControllerTest < ActionDispatch::IntegrationTest
  setup { @game = games(:pong) }

  test "requires signing in" do
    get games_path
    assert_redirected_to new_session_path
  end

  test "index" do
    sign_in_as users(:one)
    get games_path

    assert_response :success
    assert_select "a[href=?] strong", game_path(@game), text: "pong"
  end

  test "show lists the leaderboard" do
    sign_in_as users(:one)
    get game_path(@game)

    assert_response :success
    assert_select "td", text: "alice"
  end

  test "create" do
    sign_in_as users(:one)

    assert_difference "Game.count" do
      post games_path, params: { game: { name: "asteroids" } }
    end
    assert_redirected_to game_path("asteroids")
  end

  test "create with an invalid name" do
    sign_in_as users(:one)

    assert_no_difference "Game.count" do
      post games_path, params: { game: { name: "has spaces" } }
    end
    assert_response :unprocessable_content
  end

  test "update renames the game" do
    sign_in_as users(:one)
    patch game_path(@game), params: { game: { name: "pong-deluxe" } }

    assert_redirected_to game_path("pong-deluxe")
    assert_equal "pong-deluxe", @game.reload.name
  end

  test "destroy deletes the game and its scores" do
    sign_in_as users(:one)

    assert_difference({ "Game.count" => -1, "Score.count" => -2 }) do
      delete game_path(@game)
    end
    assert_redirected_to games_path
  end

  test "destroy a score" do
    sign_in_as users(:one)

    assert_difference "Score.count", -1 do
      delete game_score_path(@game, scores(:bob))
    end
    assert_redirected_to game_path(@game)
  end

  test "destroy a score requires signing in" do
    assert_no_difference "Score.count" do
      delete game_score_path(@game, scores(:bob))
    end
    assert_redirected_to new_session_path
  end
end
