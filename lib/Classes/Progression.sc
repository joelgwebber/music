// Encapsulates a sequence of chords and provides methods for manipulation and pattern generation
Progression {
  var <>chords, <>durations;

  *new { |chords, durations = nil|
    ^super.new.init(chords, durations);
  }

  init { |inChords, inDurations|
    chords = inChords;
    durations = inDurations ?? Array.fill(chords.size, 1); // default to 1 beat per chord
  }

  // Returns the number of chords in the progression
  size { ^chords.size }

  // Returns all frequencies for the progression as a flat array
  freqs {
    ^chords.collect(_.freqs).flatten;
  }

  // Returns frequencies grouped by chord
  freqsByChord {
    ^chords.collect(_.freqs);
  }

  // Returns all note names for the progression
  names {
    ^chords.collect(_.names);
  }

  // Transposes all chords by the given number of semitones
  transpose { |semitones|
    var newChords = chords.collect({ |chord|
      chord.class.new(chord.root + semitones, chord.intervals, chord.octave, chord.inversion);
    });
    ^Progression(newChords, durations);
  }

  // Transposes all chords by octaves
  octave { |steps|
    var newChords = chords.collect(_.oct(steps));
    ^Progression(newChords, durations);
  }

  // Inverts all chords by the given number of inversions
  invert { |steps|
    var newChords = chords.collect(_.invert(steps));
    ^Progression(newChords, durations);
  }

  // Reverses the progression
  reverse {
    ^Progression(chords.reverse, durations.reverse);
  }

  // Concatenates two progressions
  ++ { |other|
    ^Progression(chords ++ other.chords, durations ++ other.durations);
  }

  // Returns a subsequence of the progression
  copyRange { |start, end|
    ^Progression(
      chords.copyRange(start, end),
      durations.copyRange(start, end)
    );
  }

  // Cycles through the progression n times
  cycle { |n = 2|
    ^Progression(
      chords.stutter(n).flatten,
      durations.stutter(n).flatten
    );
  }

  // Maps a function over each chord
  collect { |func|
    var newChords = chords.collect(func);
    ^Progression(newChords, durations);
  }

  // Common progressions as class methods
  *ii_V_I { |key = 0, mode = \major|
    var root, second, fifth;
    var chords;

    if (mode == \major) {
      root = Chromatic(key, [4, 3], 0);         // I (major)
      second = Chromatic(key + 2, [3, 4], 0);   // ii (minor)
      fifth = Chromatic(key + 7, [4, 3], 0);    // V (major)
    } {
      root = Chromatic(key, [3, 4], 0);         // i (minor)
      second = Chromatic(key + 2, [3, 3], 0);   // ii° (diminished)
      fifth = Chromatic(key + 7, [3, 4], 0);    // v (minor)
    };

    chords = [second, fifth, root];
    ^Progression(chords);
  }

  *circleOfFifths { |start = 0, length = 8, quality = \dominant7|
    var chords = [];
    var current = start;

    length.do {
      var chord = case
        { quality == \major } { Chromatic(current, [4, 3], 0) }
        { quality == \minor } { Chromatic(current, [3, 4], 0) }
        { quality == \dominant7 } { Chromatic(current, [4, 3, 3], 0) };

      chords = chords.add(chord);
      current = (current + 7) % 12; // move up a fifth
    };

    ^Progression(chords);
  }

  // Create a neo-Riemannian progression from a starting chord and operations
  *neoRiemannian { |startChord, operations|
    var chords = [startChord];
    var currentChord = startChord;

    operations.do { |op|
      currentChord = currentChord.neoRiemannian(op.asString);
      chords = chords.add(currentChord);
    };

    ^Progression(chords);
  }

  // Pattern generation methods

  // Generates an arpeggiated pattern from the progression
  arpeggio { |pattern = nil, notesPer = 4|
    var result = [];
    pattern = pattern ?? (0..notesPer-1); // default ascending pattern

    chords.do { |chord, i|
      var notes = chord.notes;
      var dur = durations[i] / pattern.size;

      pattern.do { |index|
        var note = notes.wrapAt(index);
        result = result.add([note, dur]);
      };
    };

    ^result; // returns [note, duration] pairs
  }

  // Generates a strummed pattern
  strum { |delay = 0.01, direction = \up|
    var result = [];

    chords.do { |chord, i|
      var notes = chord.notes;
      var freqs = chord.freqs;
      var lags = Array.fill(notes.size, { |j| delay * j });

      if (direction == \down) { 
        notes = notes.reverse;
        freqs = freqs.reverse;
      };

      result = result.add([
        freqs,          // all frequencies for this chord
        lags,           // strum delays for each note
        durations[i]    // duration for this chord
      ]);
    };

    ^result; // returns [frequencies, lags, duration] triplets for each chord
  }

  // Returns a Pbind-ready event pattern
  asPattern { |instrument = \default, amp = 0.5|
    ^Pbind(
      \instrument, instrument,
      \freq, Pseq(this.freqs),
      \dur, Pseq(durations.collect(_.dup(chords[0].size)).flatten),
      \amp, amp
    );
  }
}

