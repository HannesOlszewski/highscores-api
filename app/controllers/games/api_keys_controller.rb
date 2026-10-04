class Games::ApiKeysController < ApplicationController
  def update
    game = Game.find_by!(name: params[:game_name])
    game.regenerate_api_key

    redirect_to game, notice: "Generated a new API key. The old key no longer works."
  end
end
