class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :edit, :update, :destroy]

  def index
    @playlists = Playlist.all
  end

  def show
    @tracks = @playlist.tracks
    apply_sorting
    @tracks = @tracks.page(params[:page]).per(15)
  end

  def new
    @playlist = Playlist.new
  end

  def create
    @playlist = Playlist.new(playlist_params)
    
    if @playlist.save
      redirect_to @playlist, notice: 'Playlist was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @playlist.update(playlist_params)
      redirect_to @playlist, notice: 'Playlist was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @playlist.playlist_tracks.exists?
      redirect_to playlists_url, alert: 'Cannot delete playlist that contains tracks.'
    elsif @playlist.destroy
      redirect_to playlists_url, notice: 'Playlist was successfully removed.'
    else
      redirect_to playlists_url, alert: 'Unable to remove playlist.'
    end
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:name)
  end

  def apply_sorting
    @sort_by = params[:sort_by]
    @sort_direction = params[:sort_direction] == 'desc' ? 'desc' : 'asc'

    case @sort_by
    when 'artist'
      @tracks = @tracks.order(artist: @sort_direction)
    when 'title'
      @tracks = @tracks.order(track_title: @sort_direction)
    when 'date'
      @tracks = @tracks.order(created_at: @sort_direction)
    when 'play_count'
      @tracks = @tracks.order(play_count: @sort_direction)
    when 'random'
      @tracks = @tracks.order('RANDOM()')
    else
      @tracks = @tracks.order(created_at: :desc)
    end
  end
end
