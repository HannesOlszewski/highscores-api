# Public JSON API for reading and submitting a game's highscores.
class ScoresController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  # The request body is { "name": ..., "score": ... }; wrapping it under params[:score] would clobber the score.
  wrap_parameters false

  rate_limit to: 30, within: 1.minute, only: :create,
    with: -> { render json: { error: "Too many submissions, try again later" }, status: :too_many_requests }

  before_action :set_game
  before_action :authenticate_game, only: :create

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: "Game not found" }, status: :not_found
  end

  rescue_from ActionController::ParameterMissing do |error|
    render json: { error: error.message }, status: :bad_request
  end

  def index
    @scores = @game.leaderboard
  end

  def create
    name, score = params.require(%i[ name score ])
    @score = @game.submit_score(name:, score:)

    if @score.errors.any?
      render json: { errors: @score.errors }, status: :unprocessable_content
    else
      @rank = @score.rank
      render :show, status: @score.previously_new_record? && @rank ? :created : :ok
    end
  end

  private
    def set_game
      @game = Game.find_by!(name: params[:game_name])
    end

    def authenticate_game
      authenticated = authenticate_with_http_token do |api_key|
        ActiveSupport::SecurityUtils.secure_compare(api_key, @game.api_key)
      end

      unless authenticated
        response.headers["WWW-Authenticate"] = %(Bearer realm="highscores")
        render json: { error: "Missing or invalid API key" }, status: :unauthorized
      end
    end
end
