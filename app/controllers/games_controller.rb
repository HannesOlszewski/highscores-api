class GamesController < ApplicationController
  before_action :set_game, only: %i[ show edit update destroy ]

  def index
    @games = Game.order(:name)
  end

  def show
    @scores = @game.leaderboard
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(game_params)
    if @game.save
      redirect_to @game, notice: "Created #{@game.name}."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @game.update(game_params)
      redirect_to @game, notice: "Renamed to #{@game.name}."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @game.destroy
    redirect_to games_path, notice: "Deleted #{@game.name} and its scores."
  end

  private
    def set_game
      @game = Game.find_by!(name: params[:name])
    end

    def game_params
      params.expect(game: [ :name ])
    end
end
