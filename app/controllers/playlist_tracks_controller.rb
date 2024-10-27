class PlaylistTracksController < ApplicationController
  before_action :set_playlist

  def create
    @track = Track.find(params[:track_id])
    @playlist.tracks << @track unless @playlist.tracks.include?(@track)
    redirect_back(fallback_location: track_path(@track), notice: 'Track added to playlist.')
  end

  def destroy
    @track = Track.find(params[:id])
    @playlist.tracks.delete(@track)
    redirect_back(fallback_location: playlist_path(@playlist), notice: 'Track removed from playlist.')
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:playlist_id])
  end
end
