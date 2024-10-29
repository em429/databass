class Track < ApplicationRecord
  has_many :playlist_tracks, dependent: :destroy
  has_many :playlists, through: :playlist_tracks

  validates :artist, presence: true
  validates :track_title, presence: true
  validates :track_title, uniqueness: { scope: :artist, message: "already exists for this artist" }

  before_create :set_default_values

  private

  def set_default_values
    self.play_count ||= 0
    self.favorite ||= false
  end
end
