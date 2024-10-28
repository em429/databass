import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["thumbnail", "progress", "player", "playCount"]

  players = {}

  connect() {
    if (!window.YT) {
      const tag = document.createElement('script')
      tag.src = "https://www.youtube.com/iframe_api"
      const firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
    }
  }

  playAudio(event) {
    const videoId = this.getYoutubeId(event.target.dataset.youtubeUrl)
    const imgElement = event.target
    
    if (!this.players[videoId]) {
      this.players[videoId] = new YT.Player(`player-${videoId}`, {
        height: '0',
        width: '0',
        videoId: videoId,
        playerVars: {
          'autoplay': 1,
          'controls': 0,
        },
        events: {
          'onReady': (event) => {
            event.target.playVideo()
            imgElement.style.opacity = '0.5'
            this.updateProgressBar(videoId)
          },
          'onStateChange': (event) => {
            if (event.data == YT.PlayerState.PLAYING) {
              this.updateProgressBar(videoId)
            } else {
              clearInterval(this.players[videoId].progressInterval)
            }
          }
        }
      })
    } else {
      if (this.players[videoId].getPlayerState() === YT.PlayerState.PLAYING) {
        this.players[videoId].pauseVideo()
        imgElement.style.opacity = '1'
        clearInterval(this.players[videoId].progressInterval)
      } else {
        this.players[videoId].playVideo()
        imgElement.style.opacity = '0.5'
        this.updateProgressBar(videoId)
      }
    }
  }

  updateProgressBar(videoId) {
    clearInterval(this.players[videoId].progressInterval)
    this.players[videoId].progressInterval = setInterval(() => {
      const player = this.players[videoId]
      const duration = player.getDuration()
      const currentTime = player.getCurrentTime()
      const progress = (currentTime / duration) * 100
      const progressBar = document.getElementById(`progress-${videoId}`)
      if (progressBar) {
        progressBar.style.width = `${progress}%`
      }
      
      if (progress >= 60 && !player.playCountIncremented) {
        this.incrementPlayCount(videoId)
        player.playCountIncremented = true
      }
    }, 1000)
  }

  incrementPlayCount(videoId) {
    const trackId = document.getElementById(`player-${videoId}`).dataset.trackId
    fetch(`/tracks/${trackId}/increment_play_count`, {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
        'Content-Type': 'application/json',
      },
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        const playCountElement = document.getElementById(`play-count-${trackId}`)
        if (playCountElement) {
          const currentCount = parseInt(playCountElement.textContent, 10)
          playCountElement.textContent = (currentCount + 1).toString()
        }
      }
    })
    .catch((error) => {
      console.error('Error:', error)
    })
  }

  getYoutubeId(url) {
    const regExp = /^.*(youtu.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/
    const match = url.match(regExp)
    return (match && match[2].length === 11) ? match[2] : null
  }
}
