class TracksController < ApplicationController

  def index
    @tracks = Track.all
    apply_sorting
    @tracks = @tracks.page(params[:page]).per(15)
  end

  def show
    @playlists = Playlist.all
    @track = Track.find(params[:id])
  end

  def new
    @track = Track.new
  end

  def edit
    @track = Track.find(params[:id])
  end

  def create
    # Check if track already exists
    existing_track = Track.find_by(artist: track_params[:artist], track_title: track_params[:track_title])
    
    if existing_track
      redirect_to existing_track, notice: "This track already exists in the database."
      return
    end

    @track = Track.new(track_params)
    
    if @track.save
      redirect_to @track, notice: "Track was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @track = Track.find(params[:id])
    # Check if update would create a duplicate
    existing_track = Track.where.not(id: @track.id)
                        .find_by(artist: track_params[:artist], track_title: track_params[:track_title])
    
    if existing_track
      redirect_to existing_track, notice: "A track with this artist and title already exists."
      return
    end

    if @track.update(track_params)
      redirect_to @track, notice: "Track was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @track = Track.find(params[:id])
    if @track.destroy
      redirect_to tracks_url, notice: "Track was successfully removed."
    else
      redirect_to tracks_url, alert: "Unable to remove track."
    end
  end

  def increment_play_count
    @track = Track.find(params[:id])
    @track.increment!(:play_count)
    render json: { success: true, play_count: @track.play_count }
  end

  def toggle_favorite
    @track = Track.find(params[:id])
    @track.update(favorite: !@track.favorite)
    redirect_back(fallback_location: tracks_path)
  end

  def search
    query = params[:q].to_s.downcase
    @tracks = Track.where("lower(artist) LIKE ? OR lower(track_title) LIKE ?", 
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
    params.require(:track).permit(:artist, :track_title, :youtube_id)
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
