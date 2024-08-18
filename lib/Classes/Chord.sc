// Represents any group of notes, in any tuning, related by intervals.
//
// TODO:
// - Octave is kind of a dumb name for non-diatonic scales. Powers? Exponents?
// - Parameterize root frequency.
// - Support inversions. Maybe as extra parameter to preserve intervals?
// - ...
Chord {
  var <root, <intervals, <octave, <tuning;

  *pitchClass{ |note, pitches|
    var sign = note.sign;
    note = note.abs.mod(pitches);
    ^case
      {note == 0} {0}
      {sign > 0}  {note}
      {sign < 0}  {12-note}
    ;
  }

  *new { |root, intervals, octave = 0, tuning = (Tuning.at(\et12))|
    ^super.new.init(root, intervals, octave, tuning);
  }

  init { |inRoot, inIntervals, inOctave, inTuning|
    root = inRoot;
    intervals = inIntervals;
    octave = inOctave;
    tuning = inTuning;
  }

  // Returns an ordered array of note indices.
  notes {
    var notes = [root];
    var curNote = root;
    intervals.do({ |interval|
      curNote = curNote + interval;
      notes.add(curNote);
    });
    ^notes;
  }

  // Returns an ordered array of frequencies in these Intervals.
  freqs {
    var notes = this.notes();
    var mod = tuning.size;
    var pcs = all {:this.pitch(note), note <- notes};
    var octs = 440 * (2 ** (octave + floor(notes / mod)));
    ^all {:round(tuning.ratios[pcs[i]] * octs[i]), i <- (0..notes.size-1)};
  }

  pitch { |note|
    ^Chord.pitchClass(note, tuning.size);
  }

  // Octave transform:
  // Returns a chord whose root is adjusted by a number of octaves.
  oct { |steps|
    ^Chord(root, intervals, octave + steps, tuning);
  }
}

