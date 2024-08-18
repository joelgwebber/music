// Represents any group of notes, in any tuning, related by intervals.
//
// TODO: Parameterize root frequency.
Chord {
  var <>root, <>intervals, <>octave, <>inversion, <tuning;

  *pitchClass{ |note, pitches|
    var sign = note.sign;
    note = note.abs.mod(pitches);
    ^case
      {note == 0} {0}
      {sign > 0}  {note}
      {sign < 0}  {12-note}
    ;
  }

  *new { |root, intervals, octave = 0, inversion = 0, tuning = (Tuning.at(\et12))|
    ^super.new.init(root, intervals, octave, inversion, tuning);
  }

  init { |inRoot, inIntervals, inOctave, inVersion, inTuning|
    root = inRoot;
    intervals = inIntervals;
    octave = inOctave;
    inversion = inVersion;
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
    ^notes.rotate(inversion);
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

