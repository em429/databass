require "test_helper"

class PlaylistTracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist = playlists(:one)
    @track_in_playlist = tracks(:one)
    @track_not_in_playlist = tracks(:two)
  end

  test "should add track to playlist" do
    assert_difference("PlaylistTrack.count") do
      post playlist_playlist_tracks_url(@playlist), params: { track_id: @track_not_in_playlist.id }
    end

    assert_redirected_to track_url(@track_not_in_playlist)
  end

  test "should remove track from playlist" do
    # First create a playlist_track to destroy
    @playlist_track = PlaylistTrack.create!(playlist: @playlist, track: @track_not_in_playlist)

    assert_difference("PlaylistTrack.count", -1) do
      delete playlist_playlist_track_url(@playlist, @track_not_in_playlist)
    end

    assert_redirected_to playlist_url(@playlist)
  end

  test "should not create duplicate track in playlist" do
    # First create a playlist_track
    PlaylistTrack.create!(playlist: @playlist, track: @track_in_playlist)

    # Try to add the same track again
    assert_no_difference("PlaylistTrack.count") do
      post playlist_playlist_tracks_url(@playlist), params: { track_id: @track_in_playlist.id }
    end

    assert_redirected_to track_url(@track_in_playlist)
  end
end
