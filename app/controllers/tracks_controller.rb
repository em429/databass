class TracksController < ApplicationController
  before_action :set_track, only: [:show, :edit, :update, :destroy, :toggle_favorite]

  def index
    @tracks = Track.all
    apply_sorting
    @tracks = @tracks.page(params[:page]).per(15)
  end

  def show
    @playlists = Playlist.all
  end

  def new
    @track = Track.new
  end

  def create
    @track = Track.new(track_params)
    
    if @track.save
      redirect_to @track, notice: 'Track was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @track.update(track_params)
      redirect_to @track, notice: 'Track was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @track.destroy
      redirect_to tracks_url, notice: 'Track was successfully removed.'
    else
      redirect_to tracks_url, alert: 'Unable to remove track.'
    end
  end

  def toggle_favorite
    @track.update(favorite: !@track.favorite)
    redirect_back(fallback_location: tracks_path)
  end

  def search
    query = params[:q].to_s.downcase
    @tracks = Track.where('lower(artist) LIKE ? OR lower(track_title) LIKE ?', 
                         "%#{query}%", "%#{query}%")
    
    if params[:playlist_id].present?
      @playlist = Playlist.find(params[:playlist_id])
      @tracks = @tracks.joins(:playlist_tracks)
                      .where(playlist_tracks: { playlist_id: @playlist.id })
    end
    
    apply_sorting
    @tracks = @tracks.page(params[:page]).per(15)
    render :index
  end

  private

  def set_track
    @track = Track.find(params[:id])
  end

  def track_params
    params.require(:track).permit(:artist, :track_title, :youtube_url)
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
