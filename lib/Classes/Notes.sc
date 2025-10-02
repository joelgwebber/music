// Represents an ordered group of notes, in a specific tuning.
//
// TODO:
// - Parameterize root frequency.
Notes : Pattern {
  var <tuning;

  *new { |tuning = (Tuning.at(\et12))|
    ^super.new.init(tuning);
  }

  init { |inTuning|
    tuning = inTuning;
  }

  // Returns the pitch class for a given note.
  pitchClass{ |note|
    var sign = note.sign;
    note = note.abs.mod(tuning.size);
    ^case
      {note == 0} {0}
      {sign > 0}  {note}
      {sign < 0}  {tuning.size-note}
    ;
  }

  size { ^this.notes.size }

  // Converts a MIDI note number to scientific pitch notation (3-char fixed width).
  // note: MIDI note number (0-127).
  // Returns: String like "C♮4", "C#4", "D♭4" (3 characters).
  noteToScientific { |note|
    var pc = this.pitchClass(note);
    var octave = (note / tuning.size).floor.asInteger;
    var noteNames = ["C♮", "C#", "D♮", "D#", "E♮", "F♮", "F#", "G♮", "G#", "A♮", "A#", "B♮"];
    ^noteNames[pc] ++ octave.asString;
  }

  // Gets scientific pitch notation for all notes.
  // Returns: Array of 3-char strings.
  scientific {
    ^this.notes.collect({ |note| this.noteToScientific(note) });
  }

  freqs {
    // MIDI standard: note 69 (A4) = 440 Hz
    // Formula: freq = 440 * 2^((midiNote - 69) / 12)
    // For 12-TET tuning with ratios, we calculate octave frequency and apply ratio
    var mod = tuning.size;
    var pcs = all {:this.pitchClass(note), note <- this.notes};

    // Calculate frequency for each note using MIDI standard
    // Base frequency for C in each octave, then apply tuning ratio for pitch class
    var freqs = this.notes.collect({ |note|
      var pc = this.pitchClass(note);
      // A4 (MIDI 69) = 440 Hz, so C4 (MIDI 60) = 440 * 2^(-9/12)
      // For any note: 440 * 2^((note - 69)/12)
      440 * (2 ** ((note - 69) / 12));
    });

    ^freqs.collect(_.round);
  }

  // Derived classes must provide a .notes method
  notes { this.subclassResponsibility(thisMethod); ^nil }

  embedInStream { |inval|
    var freqList = this.freqs;
    inf.do { |i|
      inval[\freq] = freqList.wrapAt(i);
      inval = inval.yield;
    };
    ^inval
  }
}

