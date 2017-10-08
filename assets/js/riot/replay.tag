<replay-video>
  <div class="replay-container">
    <div class="notes-container">
      <div class="notes" ref="notes"></div>
      <div class="drawer">
        <i class="fa fa-ellipsis-h" aria-hidden="true"></i>
      </div>
      <div class="notes-input hidden">
        <p>Current Time: <span class="notes-time">{ currentTime }</span></p>
        <form>
          <textarea rows="4"></textarea>
        </form>
      </div>
    </div>
    <video id="player" class="video-js vjs-default-skin" controls width="640" height="390"></video>
  </div>

  <script>
    // The youtube player object
    this.player = null;
    this.currentTime = "0:00";

    this.on("mount", () => {
      // Create the videojs player
      this.player = videojs("player", { 
        "techOrder": ["youtube"], 
        "sources": [{ 
          "type": "video/youtube", 
          "src": "https://www.youtube.com/watch?v=" + this.opts.videoId
        }] 
      }, () => {
        console.log("Player is ready");
        
        // This gets called periodically as the video plays
        this.player.on("timeupdate", () => {
          this.onTimeUpdate(this.player.currentTime());
        });
      });
    });

    onTimeUpdate(time) {
      console.log(time);
      this.updateTimeDisplay();
    }

    updateTimeDisplay() {
      let total_time = Math.floor(this.player.currentTime());
      let minutes = Math.floor(total_time / 60);
      let seconds = total_time - minutes;

      if(seconds < 10) {
        seconds = "0" + seconds;
      }

      console.log("Minutes: " + minutes + ", seconds: " + seconds);

      this.currentTime = minutes + ":" + seconds;

      this.update({
        currentTime: this.currentTime
      });
    }

  </script>
</replay-video>