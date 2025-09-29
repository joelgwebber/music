// Encapsulates a sequence of chords and provides methods for manipulation and pattern generation
Prog : Pattern {
  var <chords, <tuning;

  *initClass {
    Class.initClassTree(Notation);
  }

  // Creates a ii-V-I progression in the given key.
  // key: Root key (number 0-11 or note symbol).
  // mode: Key mode (\major or \minor).
  // Returns: Prog with ii-V-I chords.
  *ii_V_I { |key = 0, mode = \major|
    var root, second, fifth;
    var chords;
    var keyNum = Notation.noteToNumber(key);

    // TODO: Diatonic?
    if (mode == \major) {
      root = Chord(keyNum, [4, 3], 0);         // I (major)
      second = Chord(keyNum + 2, [3, 4], 0);   // ii (minor)
      fifth = Chord(keyNum + 7, [4, 3], 0);    // V (major)
    } {
      root = Chord(keyNum, [3, 4], 0);         // i (minor)
      second = Chord(keyNum + 2, [3, 3], 0);   // ii° (diminished)
      fifth = Chord(keyNum + 7, [3, 4], 0);    // v (minor)
    };

    chords = [second, fifth, root];
    ^Prog(chords);
  }

  // Creates a circle of fifths progression.
  // start: Starting note (number 0-11 or note symbol).
  // length: Number of chords to generate.
  // quality: Chord quality (\major, \minor, or \dominant7).
  // Returns: Prog following the circle of fifths.
  *circleOfFifths { |start = 0, length = 8, quality = \dominant7|
    var chords = [];
    var current = Notation.noteToNumber(start);

    // TODO: Diatonic?
    length.do {
      var chord = case
        { quality == \major } { Chord(current, [4, 3], 0) }
        { quality == \minor } { Chord(current, [3, 4], 0) }
        { quality == \dominant7 } { Chord(current, [4, 3, 3], 0) };

      chords = chords.add(chord);
      current = (current + 7) % 12; // move up a fifth
    };

    ^Prog(chords);
  }

  // Creates a neo-Riemannian progression from a starting chord and operations.
  // startChord: Initial Chord.
  // operations: Array of operation symbols (\P, \L, \R, \S, \N, \H) or strings.
  // Returns: Prog with neo-Riemannian transformations applied.
  *neoRiemannian { |startChord, operations|
    var chords = [startChord];
    var currentChord = startChord;

    operations.do { |op|
      currentChord = currentChord.neoRiemannian(op.asString);
      chords = chords.add(currentChord);
    };

    ^Prog(chords);
  }

  // Creates a new Prog from an array of Chords.
  // chords: Array of Chord instances.
  // Returns: New Prog instance.
  *new { |chords|
    ^super.new.init(chords);
  }

  // Create a progression from Roman numerals in a given key
  // Examples:
  //   Prog.inKey(\C, [\I, \vi, \IV, \V])     // C Am F G
  //   Prog.inKey(\G, [\I, \vi, \ii, \V])     // G Em Am D
  //   Prog.inKey(\Am, [\i, \iv, \i, \V])     // Am Dm Am E
  //   Prog.inKey(\C, [\I, \V_E, \I])         // C G/E C (with inversion)
  //   Prog.inKey(\C, [\Imaj7, \vi7, \V7])    // Cmaj7 Am7 G7
  *inKey { |key = \C, numerals, octave = 0|
    var keyRoot, mode, chords;

    // Parse key using Notation helper
    #keyRoot, mode = Notation.parseKey(key);

    // Build chords from Roman numerals
    chords = numerals.collect { |numeral|
      Notation.romanToChord(keyRoot, mode, numeral, octave);
    };

    ^Prog(chords);
  }

  init { |inChords|
    chords = inChords;
    tuning = inChords[0].tuning;

    // Validate that all chords have the same tuning
    inChords.do({ |chord|
      if (chord.tuning != tuning) {
        Error("All chords in a Prog must share the same tuning.");
      }
    })
  }

  // Gets the number of chords in the progression.
  // Returns: Integer count of chords.
  size { ^chords.size }

  // Gets all note names for each chord in the progression.
  // Returns: Array of arrays of note name symbols.
  names { ^chords.collect(_.names) }

  // Gets all note numbers for each chord in the progression.
  // Returns: Array of arrays of chromatic note numbers.
  notes { ^chords.collect(_.notes) }

  // Gets frequencies for each chord in the progression.
  // Returns: Array of arrays of frequencies in Hz.
  freqs { ^chords.collect(_.freqs) }

  // Pattern implementation that yields chord frequencies.
  // inval: Event being processed.
  // Returns: Modified event stream.
  embedInStream { |inval|
    var chordFreqs = this.freqs;
    inf.do { |i|
      inval[\freq] = chordFreqs.wrapAt(i);
      inval = inval.yield;
    };
    ^inval
  }

  // Returns a Melody with the chords arpeggiated
  // Examples:
  //   prog.arp                              // all chords ascending
  //   prog.arp(\down)                       // all chords descending
  //   prog.arp(\upDown)                     // all chords up-down pattern
  //   prog.arp([0, 2, 1])                   // custom pattern for all chords
  //   prog.arp([\up, \down])                // alternating patterns
  arp { |pattern = \up|
    var arpNotes;

    arpNotes = switch(pattern.class,
      Symbol, {
        // Single symbol pattern applied to all chords
        this.chords.collect({ |chord| chord.arp(pattern).notes }).flatten;
      },
      Array, {
        if(pattern.size == 0) {
          Error("Empty array pattern provided to Prog.arp").throw;
        };

        switch(pattern[0].class,
          Integer, {
            // Numeric array pattern like [0, 2, 1]
            this.chords.collect({ |chord| chord.arp(pattern).notes }).flatten;
          },
          Symbol, {
            // Array of symbols like [\up, \down, \upDown]
            this.chords.collect({ |chord, i|
              chord.arp(pattern.wrapAt(i)).notes
            }).flatten;
          },
          {
            Error("Array pattern must contain numbers or symbols, not %".format(pattern[0].class)).throw;
          }
        )
      },
      {
        Error("Invalid pattern type: %. Expected Symbol or Array.".format(pattern.class)).throw;
      }
    );

    ^Melody(arpNotes, this.tuning);
  }

  // Extracts a melody from the root notes of each chord.
  // Returns: Melody of root notes.
  roots {
    ^Melody(chords.collect({ |chord| chord.notes[0] }), this.tuning);
  }

  // Extracts a melody from the bass (lowest) notes of each chord.
  // Returns: Melody of bass notes.
  bassLine {
    ^Melody(chords.collect({ |chord| chord.notes.minItem }), this.tuning);
  }

  // Extracts a melody from the top (highest) notes of each chord.
  // Returns: Melody of top notes.
  topVoice {
    ^Melody(chords.collect({ |chord| chord.notes.maxItem }), this.tuning);
  }

  // Transposes all chords by semitones.
  // semitones: Number of semitones to transpose (positive = up, negative = down).
  // Returns: New transposed Prog.
  transpose { |semitones|
    var newChords = chords.collect({ |chord|
      chord.class.new(chord.root + semitones, chord.intervals, chord.octave, chord.inversion);
    });
    ^Prog(newChords);
  }

  // Transposes all chords by octaves.
  // steps: Number of octaves to transpose (positive = up, negative = down).
  // Returns: New transposed Prog.
  octave { |steps|
    var newChords = chords.collect(_.oct(steps));
    ^Prog(newChords);
  }

  // Inverts all chords in the progression.
  // steps: Number of inversions to apply to each chord.
  // Returns: New Prog with inverted chords.
  invert { |steps|
    var newChords = chords.collect(_.invert(steps));
    ^Prog(newChords);
  }

  // Reverses the order of chords in the progression.
  // Returns: New Prog with reversed chord order.
  reverse {
    ^Prog(chords.reverse);
  }

  // Concatenates this progression with another.
  // other: Another Prog to append.
  // Returns: New combined Prog.
  ++ { |other|
    ^Prog(chords ++ other.chords);
  }
}
