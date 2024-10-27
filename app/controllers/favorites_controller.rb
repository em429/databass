class FavoritesController < ApplicationController
  def index
    @tracks = Track.where(favorite: true)
    apply_sorting
    @tracks = @tracks.page(params[:page]).per(15)
  end

  private

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
