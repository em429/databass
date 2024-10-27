class AddUniqueIndexToPlaylistNames < ActiveRecord::Migration[8.0]
  def change
    add_index :playlists, :name, unique: true
  end
end
