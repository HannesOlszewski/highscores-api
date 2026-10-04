class CreateScores < ActiveRecord::Migration[8.1]
  def change
    create_table :scores do |t|
      t.integer :score
      t.string :name
      t.belongs_to :game, null: false, foreign_key: true

      t.timestamps
    end

    add_column :games, :scores_count, :integer, default: 0
  end
end
