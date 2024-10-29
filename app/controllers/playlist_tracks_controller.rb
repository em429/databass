class PlaylistTracksController < ApplicationController
  include ActionView::RecordIdentifier
  before_action :set_playlist

  def create
    @track = Track.find(params[:track_id])
    @playlist.tracks << @track unless @playlist.tracks.include?(@track)
    redirect_back(fallback_location: track_path(@track), notice: 'Track added to playlist.')
  end

  def destroy
    @track = Track.find(params[:id])
    @playlist_track = @playlist.playlist_tracks.find_by(track: @track)
    
    if @playlist.tracks.delete(@track)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@playlist_track)) }
        format.html { redirect_back(fallback_location: playlist_path(@playlist), notice: 'Track removed from playlist.') }
      end
    else
      redirect_back(fallback_location: playlist_path(@playlist), alert: 'Unable to remove track from playlist.')
    end
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:playlist_id])
  end
end
