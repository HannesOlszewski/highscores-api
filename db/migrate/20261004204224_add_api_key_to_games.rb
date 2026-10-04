class AddApiKeyToGames < ActiveRecord::Migration[8.1]
  def up
    add_column :games, :api_key, :string

    select_values("SELECT id FROM games").each do |id|
      execute "UPDATE games SET api_key = #{quote(SecureRandom.base58(24))} WHERE id = #{quote(id)}"
    end

    change_column_null :games, :api_key, false
    add_index :games, :api_key, unique: true
  end

  def down
    remove_column :games, :api_key
  end
end
