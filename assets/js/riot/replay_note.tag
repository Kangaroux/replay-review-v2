<replay-note>
  <div class="note { active: isActive }">
    <a class="note-trashcan" title="Delete note" onclick={ deleteNote } if={ user === window.userid }>
      <i class="fa fa-trash-o" aria-hidden="true"></i>
    </a>

    <a class="note-timestamp" onclick={ skip }>{ time_string }</a>: { text }
  </div>

  <script>
    this.id = opts.data.id;
    this.isActive = opts.data.isActive;
    this.user = opts.data.user;
    this.time = opts.data.time;
    this.time_string = opts.data.time_string;
    this.text = opts.data.text;

    deleteNote() {
      opts.deleteNote(this);
    }

    skip() {
      opts.skip(this.time);
    }

  </script>
</replay-note>