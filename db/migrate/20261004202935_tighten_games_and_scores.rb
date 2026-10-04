class TightenGamesAndScores < ActiveRecord::Migration[8.1]
  def up
    change_column_null :games, :name, false
    change_column_null :games, :scores_count, false, 0

    change_column :scores, :score, :bigint, null: false
    change_column_null :scores, :name, false
    remove_index :scores, :game_id
    add_index :scores, [ :game_id, :name ], unique: true
  end

  def down
    remove_index :scores, [ :game_id, :name ]
    add_index :scores, :game_id
    change_column_null :scores, :name, true
    change_column :scores, :score, :integer, null: true

    change_column_null :games, :scores_count, true
    change_column_null :games, :name, true
  end
end
