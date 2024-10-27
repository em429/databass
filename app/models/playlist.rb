class Playlist < ApplicationRecord
  has_many :playlist_tracks, dependent: :restrict_with_error
  has_many :tracks, through: :playlist_tracks

  validates :name, presence: true
end
