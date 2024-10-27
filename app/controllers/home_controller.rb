class HomeController < ApplicationController
  def index
    @random_track = Track.order("RANDOM()").first
    @track = Track.new
    @playlist = Playlist.new
    @playlists = Playlist.all
  end
end
