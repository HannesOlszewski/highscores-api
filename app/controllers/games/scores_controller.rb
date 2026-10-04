class Games::ScoresController < ApplicationController
  def destroy
    game = Game.find_by!(name: params[:game_name])
    score = game.scores.find(params[:id])
    score.destroy

    redirect_to game, notice: "Removed #{score.name}’s score."
  end
end
