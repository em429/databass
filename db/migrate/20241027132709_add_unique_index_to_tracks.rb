class AddUniqueIndexToTracks < ActiveRecord::Migration[8.0]
  def change
    add_index :tracks, [ :artist, :track_title ], unique: true
  end
end
