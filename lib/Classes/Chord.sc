// Represents any group of notes, in any tuning, related by intervals.
//
// TODO:
// - Parameterize root frequency.
// - Modulo inversion to chord size.
Chord {
  var <>root, <>intervals, <>octave, <>inversion, <tuning;

  // Returns the pitch class for a given pitch.
  *pitchClass{ |pitch, numClasses|
    var sign = pitch.sign;
    pitch = pitch.abs.mod(numClasses);
    ^case
      {pitch == 0} {0}
      {sign > 0}   {pitch}
      {sign < 0}   {12-pitch}
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

  size { ^intervals.size + 1 }

  // Returns a new chord whose root and intervals are computed from the union of
  //   this chord and another. This process focuses solely on pitch class.
  // It will retain this chord's octave and inversion.
  union { |other|
    var newInts, pitches;

    // Merge pitches, sort them, and remove duplicates.
    pitches = (this.pitches ++ other.pitches).sort;
    pitches = pitches.select({ |pc, i| (i == 0) || (pc != pitches[i-1]) });

    // Compute intervals from the pitches.
    newInts = all {:pitches[i] - pitches[i-1], i <- (1..pitches.size-1)};
    ^Chord(pitches[0], newInts, octave, inversion, tuning);
  }

  // Returns an ordered array of notes, taking octave and inversion into account.
  // Note that these are notes within this chord's tuning, not simply pitch classes.
  notes {
    var curNote = root + (tuning.size * octave);
    var notes = [curNote];
    var inverted;

    intervals.do({ |interval|
      curNote = curNote + interval;
      notes = notes.add(curNote);
    });

    inverted = notes[inversion..notes.size-1];
    if (inversion > 0) {
      inverted.addAll(notes[0..inversion-1] + tuning.size)
    }
    ^inverted;
  }

  // Returns an ordered array of frequencies in this chord, taking octave and
  //   inversion into account.
  freqs {
    var notes = this.notes();
    var mod = tuning.size;
    var pcs = all {:this.pitchClass(note), note <- notes};
    var octs = 440 * (2 ** floor(notes / mod));
    ^all {:round(tuning.ratios[pcs[i]] * octs[i]), i <- (0..notes.size-1)};
  }

  // Returns an array of pitches in this chord, ignoring octave and inversion.
  // These differ from pitch-classes in that they can extend beyond the strict
  //   definition of 'class', to preserve interval order.
  pitches {
    var curNote = root;
    var pitches = [curNote];
    intervals.do { |interval|
      curNote = curNote + interval;
      pitches.add(curNote);
    };
    ^pitches;
  }

  // Returns the pitch class for a given note.
  pitchClass{ |note|
    var sign = note.sign;
    note = note.abs.mod(tuning.size);
    ^case
      {note == 0} {0}
      {sign > 0}  {note}
      {sign < 0}  {12-note}
    ;
  }

  // Octave transform:
  // Returns a chord whose root is adjusted by a number of octaves.
  oct { |steps|
    ^Chord(root, intervals, octave + steps, inversion, tuning);
  }

  // Inversion transform:
  // Returns a chord inverted a given number of times.
  invert { |steps|
    ^Chord(root, intervals, octave, (inversion + steps) % this.size, tuning) 
  }
}

