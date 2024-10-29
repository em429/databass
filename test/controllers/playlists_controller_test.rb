require "test_helper"

class PlaylistsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @playlist = playlists(:one)  # Assuming you have a playlist fixture named 'one'
  end

  test "should get index" do
    get playlists_url
    assert_response :success
  end

  test "should get show" do
    get playlist_url(@playlist)
    assert_response :success
  end

  test "should get new" do
    get new_playlist_url
    assert_response :success
  end

  test "should create playlist" do
    assert_difference("Playlist.count") do
      post playlists_url, params: { playlist: { name: "New Test Playlist" } }
    end

    assert_redirected_to playlist_url(Playlist.last)
  end

  test "should get edit" do
    get edit_playlist_url(@playlist)
    assert_response :success
  end

  test "should update playlist" do
    patch playlist_url(@playlist), params: { playlist: { name: "Updated Playlist Name" } }
    assert_redirected_to playlist_url(@playlist)
  end

  test "should destroy playlist when empty" do
    # Ensure the playlist has no tracks
    @playlist.playlist_tracks.destroy_all

    assert_difference("Playlist.count", -1) do
      delete playlist_url(@playlist)
    end

    assert_redirected_to playlists_url
  end

  test "should not destroy playlist with tracks" do
    # Create a track and add it to the playlist if not already present
    unless @playlist.playlist_tracks.exists?
      track = tracks(:one)
      @playlist.playlist_tracks.create!(track: track)
    end

    assert_no_difference("Playlist.count") do
      delete playlist_url(@playlist)
    end

    assert_redirected_to playlists_url
    assert_equal "Cannot delete playlist that contains tracks.", flash[:alert]
  end
end
