require "test_helper"

class TracksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @track = tracks(:one)  # Assuming you have a track fixture named 'one'
  end

  test "should get index" do
    get tracks_url
    assert_response :success
  end

  test "should get show" do
    get track_url(@track)
    assert_response :success
  end

  test "should get new" do
    get new_track_url
    assert_response :success
  end

  test "should create track" do
    assert_difference("Track.count") do
      post tracks_url, params: {
        track: {
          artist: "New Artist",
          track_title: "New Track",
          youtube_id: "newid123"
        }
      }
    end

    assert_redirected_to track_url(Track.last)
  end

  test "should get edit" do
    get edit_track_url(@track)
    assert_response :success
  end

  test "should update track" do
    patch track_url(@track), params: {
      track: {
        artist: "Updated Artist",
        track_title: "Updated Track",
        youtube_id: @track.youtube_id
      }
    }
    assert_redirected_to track_url(@track)
  end

  test "should destroy track" do
    assert_difference("Track.count", -1) do
      delete track_url(@track)
    end

    assert_redirected_to tracks_url
  end
end
