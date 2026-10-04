class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :name, index: { unique: true, name: "unique_games" }

      t.timestamps
    end
  end
end
