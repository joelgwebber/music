// Represents a group of notes related by intervals.
//
// TODO:
// - Modulo inversion to chord size.
Chord : Notes {
  var <>root, <>intervals, <>octave, <>inversion;

  *new { |root, intervals, octave = 0, inversion = 0, tuning = (Tuning.at(\et12))|
    ^super.new(tuning).initChord(root, intervals, octave, inversion);
  }

  initChord { |inRoot, inIntervals, inOctave, inVersion|
    root = inRoot;
    intervals = inIntervals;
    octave = inOctave;
    inversion = inVersion;
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

  // Returns a Melody with the chord arpeggiated
  // Examples:
  //   chord.arp             // ascending (default)
  //   chord.arp(\up)        // ascending: [0, 1, 2]
  //   chord.arp(\down)      // descending: [2, 1, 0]
  //   chord.arp(\upDown)    // up then down: [0, 1, 2, 1]
  //   chord.arp(\downUp)    // down then up: [2, 1, 0, 1]
  //   chord.arp(\random)    // random order
  //   chord.arp([0, 2, 1])  // custom pattern (wraps if needed)
  arp { |pattern = \up|
    var indices = case
      { pattern.isArray } { pattern }
      { pattern == \up } { (0..this.size-1) }
      { pattern == \down } { (this.size-1..0) }
      { pattern == \upDown } { (0..this.size-1) ++ (this.size-2..1) }
      { pattern == \downUp } { (this.size-1..0) ++ (1..this.size-2) }
      { pattern == \random } { (0..this.size-1).scramble }
      { (0..this.size-1) };  // Default to ascending

    // Use wrapAt for overflow handling
    var arpNotes = indices.collect { |idx|
      this.notes.wrapAt(idx)
    };

    ^Melody(arpNotes, this.tuning);
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

