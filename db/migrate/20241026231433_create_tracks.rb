class CreateTracks < ActiveRecord::Migration[8.0]
  def change
    create_table :tracks do |t|
      t.string :artist
      t.string :track_title
      t.string :youtube_url
      t.integer :play_count
      t.boolean :favorite

      t.timestamps
    end
  end
end
