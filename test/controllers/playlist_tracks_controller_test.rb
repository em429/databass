require "test_helper"

class PlaylistTracksControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get playlist_tracks_create_url
    assert_response :success
  end

  test "should get destroy" do
    get playlist_tracks_destroy_url
    assert_response :success
  end
end
