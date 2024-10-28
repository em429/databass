class RenameYoutubeUrlToYoutubeIdInTracks < ActiveRecord::Migration[8.0]
  def change
    rename_column :tracks, :youtube_url, :youtube_id
  end
end
