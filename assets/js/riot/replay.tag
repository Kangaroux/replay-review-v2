<replay-video>
  <div class="replay-container">
    <div class="notes-container { 'controls-open': controlsOpen }">
      <div class="notes" ref="notes">
        <div class="note" each={ notes }>
          <a href="#" onclick={ jumpToTime }>{ time_string }</a>: { text }
        </div>
      </div>
      <div class="drawer-handle" onclick={ toggleDrawer }>
        <i class="fa fa-ellipsis-h" aria-hidden="true"></i>
      </div>
      <div class="notes-drawer { 'drawer-open': drawerOpen }">
        <p>Current Time: <span class="notes-time">{ currentTime }</span></p>
        <form>
          <textarea ref="input" rows="4" onkeypress={ submitNote }></textarea>
        </form>
      </div>
    </div>
    <video id="player" class="video-js vjs-default-skin" controls></video>
  </div>

  <script>
    // The youtube player object
    this.player = null;
    this.currentTime = "0:00";
    this.controlsOpen = false;
    this.drawerOpen = true;
    this.notes = [];

    this.on("mount", () => {
      // Create the videojs player
      this.player = videojs("player", {
        fluid: true, // width 100%
        controlBar: {
          remainingTimeDisplay: false
        },
        techOrder: ["youtube"], 
        sources: [{ 
          type: "video/youtube", 
          src: "https://www.youtube.com/watch?v=" + this.opts.videoId
        }] 
      }, () => {
        console.log(this.player);
        
        // This gets called periodically as the video plays
        this.player.on("timeupdate", () => {
          this.onTimeUpdate(this.player.currentTime());
        });

        // Check if the controls are open.
        // TODO: Could optimize a bit, controls are always visible if the video is paused
        setInterval(this.checkControlsOpen, 33);
      });
    });

    onTimeUpdate(time) {
      this.updateTimeDisplay();
    }

    // Checks to see if the controls on the video are visible. When they are,
    // the sidebar gains a bit of padding so it's not covering the controls
    checkControlsOpen() {
      let el = this.player.el_;
      let open = el.classList.contains("vjs-has-started") 
        && (el.classList.contains("vjs-paused") || el.classList.contains("vjs-user-active"));

      if(open != this.controlsOpen) {
        this.controlsOpen = open;
        this.update({
          controlsOpen: open
        });
      }
    }

    // Formats a time (in seconds) to hours:minutes:seconds. Hours isn't shown if the
    // total duration of the video is less than an hour.
    formatTime(time) {
      let total_time = Math.floor(time);
      let hours = "";
      let minutes = Math.floor(total_time / 60);
      let seconds = total_time % 60;

      if(seconds < 10) {
        seconds = "0" + seconds;
      }

      if(this.player.duration >= 3600) {
        hours = Math.floor(total_time / 3600) + ":";
      }

      return hours + minutes + ":" + seconds;
    }

    // Updates the current time display on the sidebar
    updateTimeDisplay() {
      this.update({
        currentTime: this.formatTime(this.player.currentTime())
      });
    }

    // Toggles the notes drawer open when the user clicks on the drawer handle
    toggleDrawer() {
      this.drawerOpen = !this.drawerOpen;

      this.update({
        drawerOpen: this.drawerOpen
      })
    }

    // Submits a replay note when the user presses enter (but not shift enter)
    submitNote(e) {
      if(e.keyCode == 13 && !e.shiftKey) {
        let text = this.refs.input.value;

        if(!text.trim().length) {
          return;
        }

        let time = this.player.currentTime();

        this.addNote({
          time: time,
          time_string: this.formatTime(time),
          text: text
        });

        this.refs.input.value = "";

        e.preventDefault();
      }
    }

    addNote(note) {
      this.notes.push(note);

      // Sort the notes in ascending order. If I wasn't lazy I'd just insert it at the right
      // spot but I can't be bothered
      this.notes.sort((a, b) => {
        if(a.time > b.time) {
          return 1;
        } else if(a.time == b.time) {
          return 0;
        } else {
          return -1;
        }
      });
    }

    jumpToTime(e) {
      this.player.currentTime(e.item.time);
    }

  </script>
</replay-video>