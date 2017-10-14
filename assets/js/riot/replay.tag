<replay-video>
  <div class="replay-video-container">
    <div class="notes-container { 'controls-visible': controlsVisible, 'drawer-open': drawerOpen }" if={ videoStarted }>
      <div class="notes" ref="notes">
        <div class="note { active: isActive }" each={ notes }>
          <a href="#" onclick={ jumpToTime }>{ time_string }</a>: { text }
        </div>
      </div>
      <div class="drawer-handle" onclick={ toggleDrawer }>
        <i class="fa fa-ellipsis-h" aria-hidden="true"></i>
      </div>
      <div class="notes-drawer">
        <p>Current Time: <span class="notes-time">{ currentTimeDisplay }</span></p>
        <textarea ref="input" onkeypress={ submitNote }></textarea>
      </div>
    </div>
    <video id="player" class="video-js vjs-default-skin" controls></video>
  </div>

  <script>
    // The youtube player object
    this.player = null;
    this.currentTimeDisplay = "0:00";
    this.controlsVisible = false;
    this.drawerOpen = false;
    this.videoStarted = false;
    this.notes = [];
    this.activeNote = null;

    // How many seconds a note will stay active for past its timestamp.
    const MAX_ACTIVE_TIME = 30;

    this.on("mount", () => {
      // Create the videojs player
      this.player = videojs("player", {
        fluid: true, // width 100%
        techOrder: ["youtube"], 
        sources: [{ 
          type: "video/youtube", 
          src: "https://www.youtube.com/watch?v=" + this.opts.videoId + "?rel=0"
        }] 
      }, () => {
        this.setupNotes();
        
        // This gets called periodically as the video plays
        this.player.on("timeupdate", () => {
          this.onTimeUpdate(this.player.currentTime());
        });

        this.player.one("play", () => {
          this.update({
            videoStarted: true
          })
        });

        // Check if the controls are open.
        // TODO: Could optimize a bit, controls are always visible if the video is paused
        setInterval(this.checkControlsOpen, 33);
      });
    });

    this.on("update", (e) => {
      console.log(e);
    });

    setupNotes() {
      let notes = window.replay_notes[this.opts.replayId.toString()];

      if(!notes) {
        return;
      }

      this.notes = notes.map(x => this.createNote({text: x.text, time: x.time}));
      this.sortNotes();
      this.update();
    }

    onTimeUpdate(time) {
      this.updateTimeDisplay(time);

      // Update the current highlighted note
      if(this.notes.length) {
        let newActiveNote = null;

        for(let i = 0; i < this.notes.length; i++) {
          // The note is ahead of the video
          if(this.notes[i].time > time) {
            break;
          }

          if(((i == this.notes.length - 1) || this.notes[i + 1].time > time)
              && (time - this.notes[i].time) < MAX_ACTIVE_TIME) {
            newActiveNote = this.notes[i];
          }
        }

        // Update the new active note if it changed
        if(newActiveNote !== this.activeNote) { 

          // Set the old note as inactive
          if(this.activeNote !== null) {
            this.activeNote.isActive = false;
          }

          // Set the new note to active
          if(newActiveNote !== null) {
            newActiveNote.isActive = true;
          }

          this.update({
            activeNote: newActiveNote
          });
        }
      }
    }

    // Checks to see if the controls on the video are visible. When they are,
    // the sidebar gains a bit of padding so it's not covering the controls
    checkControlsOpen() {
      let el = this.player.el_;
      let open = el.classList.contains("vjs-has-started") 
        && (el.classList.contains("vjs-paused") || el.classList.contains("vjs-user-active"));

      if(open != this.controlsVisible) {
        this.update({
          controlsVisible: open
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
    updateTimeDisplay(time) {
      let formatted = this.formatTime(time);

      // Update the time display if it's different
      if(formatted != this.currentTimeDisplay) {
        this.currentTimeDisplay = formatted;

        // The time display is only visible when the drawer is open, no need 
        // to update the tag
        if(this.drawerOpen) {
          this.update();
        }
      }
    }

    // Toggles the notes drawer open when the user clicks on the drawer handle
    toggleDrawer() {
      this.update({
        drawerOpen: !this.drawerOpen
      })
    }

    // Submits a replay note when the user presses enter (but not shift enter)
    submitNote(e) {
      if(e.keyCode == 13 && !e.shiftKey) {
        e.preventDefault();

        let text = this.refs.input.value.trim();

        if(!text.length) {
          return;
        }

        let time = this.player.currentTime();

        qwest.post(window.urls.api_new_note, {
          csrfmiddlewaretoken: window.csrf,
          replay: this.opts.replayId,
          text: text,
          time: time,
        }).then((x, r) => {
          this.addNoteToScreen(this.createNote({time: r.time, text: r.text, active: true}));
          this.refs.input.value = "";
        }).catch((e) => {
          console.log(e);
        });
      }
    }

    createNote(params) {
      return {
        isActive: params.active === true,
        time: params.time,
        time_string: this.formatTime(params.time),
        text: params.text
      };
    }

    // Adds the note to the screen and marks it as active
    addNoteToScreen(note) {
      this.notes.push(note);
      this.sortNotes();
      this.activeNote = note;

      //this.update();
    }

    sortNotes() {
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
      this.player.play();
    }
  </script>
</replay-video>