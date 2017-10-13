<replay-video>
  <div class="replay-video-container">
    <div class="notes-container { 'controls-visible': controlsVisible, 'drawer-open': drawerOpen }" if={ showSidebar }>
      <div class="notes" ref="notes">
        <div class="note { active: isActive }" each={ notes }>
          <a href="#" onclick={ jumpToTime }>{ time_string }</a>: { text }
        </div>
      </div>
      <div class="drawer-handle" onclick={ toggleDrawer }>
        <i class="fa fa-ellipsis-h" aria-hidden="true"></i>
      </div>
      <div class="notes-drawer">
        <p>Current Time: <span class="notes-time">{ currentTime }</span></p>
        <form>
          <textarea ref="input" onkeypress={ submitNote }></textarea>
        </form>
      </div>
    </div>
    <video id="player" class="video-js vjs-default-skin" controls></video>
  </div>

  <script>
    // The youtube player object
    this.player = null;
    this.currentTime = "0:00";
    this.controlsVisible = false;
    this.drawerOpen = false;
    this.showSidebar = false;
    this.notes = [];
    this.activeNote = null;

    // How many seconds a note will stay active for past its timestamp.
    const MAX_ACTIVE_TIME = 30;

    // Add any existing notes
    this.setupNotes();

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
        console.log(this.player);
        
        // This gets called periodically as the video plays
        this.player.on("timeupdate", () => {
          this.onTimeUpdate(this.player.currentTime());
        });

        this.player.one("play", () => {
          this.showSidebar = true;
          this.update({
            showSidebar: this.showSidebar
          })
        });

        // Check if the controls are open.
        // TODO: Could optimize a bit, controls are always visible if the video is paused
        setInterval(this.checkControlsOpen, 33);
      });
    });

    setupNotes() {
      let notes = window.replay_notes[this.opts.replayId.toString()];

      if(!notes) {
        return;
      }

      for(let k of notes) {
        this.notes.append(this.createNote({text: k.text, time: k.time}));
      }

      this.sortNotes();
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
          if(newActiveNote === null) {
            this.activeNote.isActive = false;
            this.activeNote = null;
          } else {
            this.activeNote = newActiveNote;
            this.activeNote.isActive = true;
          }

          this.update({
            notes: this.notes
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
        this.controlsVisible = open;
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
      this.update({
        currentTime: this.formatTime(time)
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

      // Force an update
      this.update({
        notes: this.notes
      });
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
    }

  </script>
</replay-video>