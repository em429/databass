require 'sqlite3'

namespace :import do
  desc 'Import data from legacy SQLite database'
  task legacy_data: :environment do
    def extract_youtube_id(url)
      return nil unless url
      # Try to match both youtube.com and youtu.be URLs
      if url.include?('youtube.com')
        # Handle youtube.com URLs
        match = url.match(/(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})/)
        match[1] if match
      elsif url.include?('youtu.be')
        # Handle youtu.be URLs
        url.split('/').last.split('?').first
      end
    end

    def convert_date(date_str)
      return nil unless date_str
      # Convert YYYY-MM-DD to timestamp
      "#{date_str} 00:00:00"
    end

    begin
      # Connect to the legacy SQLite database
      # NOTE: Replace with actual path to your legacy database
      legacy_db = SQLite3::Database.new('/Volumes/Shared/playlists/playlists.db')
      legacy_db.results_as_hash = true

      ActiveRecord::Base.transaction do
        # Import tracks
        puts "Importing tracks..."
        track_id_mapping = {}
        legacy_db.execute("SELECT * FROM tracks") do |track|
          begin
            # Try to find existing track
            existing_track = Track.find_by(artist: track['artist'], track_title: track['title'])
            
            if existing_track
              puts "\nSkipping duplicate track: #{track['artist']} - #{track['title']}"
              track_id_mapping[track['id']] = existing_track.id
            else
              new_track = Track.create!(
                track_title: track['title'],
                artist: track['artist'],
                youtube_id: extract_youtube_id(track['url']),
                created_at: convert_date(track['date']),
                updated_at: convert_date(track['date']),
                play_count: track['play_count'] || 0,
                favorite: false # Set default for new field
              )
              track_id_mapping[track['id']] = new_track.id
              print "."
            end
          rescue ActiveRecord::RecordInvalid => e
            puts "\nError importing track: #{track['artist']} - #{track['title']}: #{e.message}"
            # Continue with next track
            next
          end
        end
        puts "\nTracks import completed!"

        # Import playlists
        puts "\nImporting playlists..."
        playlist_id_mapping = {}
        legacy_db.execute("SELECT * FROM playlists") do |playlist|
          begin
            new_playlist = Playlist.create!(
              name: playlist['title'], # Changed from title to name to match schema
              created_at: Time.current,
              updated_at: Time.current
            )
            playlist_id_mapping[playlist['id']] = new_playlist.id
            print "."
          rescue ActiveRecord::RecordInvalid => e
            puts "\nError importing playlist '#{playlist['title']}': #{e.message}"
            # Try to find existing playlist
            existing_playlist = Playlist.find_by(name: playlist['title'])
            if existing_playlist
              playlist_id_mapping[playlist['id']] = existing_playlist.id
            end
            next
          end
        end
        puts "\nPlaylists import completed!"

        # Import playlist_tracks associations
        puts "\nImporting playlist track associations..."
        legacy_db.execute("SELECT * FROM playlist_tracks") do |pt|
          new_playlist_id = playlist_id_mapping[pt['playlist_id']]
          new_track_id = track_id_mapping[pt['track_id']]
          
          if new_playlist_id && new_track_id
            begin
              PlaylistTrack.create!(
                playlist_id: new_playlist_id,
                track_id: new_track_id
              )
              print "."
            rescue ActiveRecord::RecordInvalid => e
              puts "\nError creating playlist track association: #{e.message}"
              next
            end
          else
            puts "\nSkipping invalid playlist_track association (missing playlist or track)"
          end
        end
        puts "\nPlaylist track associations import completed!"
      end

    rescue SQLite3::Exception => e
      puts "SQLite3 error occurred: #{e.message}"
      raise e
    rescue StandardError => e
      puts "An error occurred: #{e.message}"
      raise e
    ensure
      legacy_db&.close
    end

    puts "\nImport completed successfully!"
  end
end
