// Encapsulates a sequence of chords and provides methods for manipulation and pattern generation
Prog : Pattern {
  var <chords, <tuning;

  // Common progressions as class methods
  *ii_V_I { |key = 0, mode = \major|
    var root, second, fifth;
    var chords;

    // TODO: Diatonic?
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
    ^Prog(chords);
  }

  *circleOfFifths { |start = 0, length = 8, quality = \dominant7|
    var chords = [];
    var current = start;

    // TODO: Diatonic?
    length.do {
      var chord = case
        { quality == \major } { Chromatic(current, [4, 3], 0) }
        { quality == \minor } { Chromatic(current, [3, 4], 0) }
        { quality == \dominant7 } { Chromatic(current, [4, 3, 3], 0) };

      chords = chords.add(chord);
      current = (current + 7) % 12; // move up a fifth
    };

    ^Prog(chords);
  }

  // Create a neo-Riemannian progression from a starting chord and operations
  *neoRiemannian { |startChord, operations|
    var chords = [startChord];
    var currentChord = startChord;

    operations.do { |op|
      currentChord = currentChord.neoRiemannian(op.asString);
      chords = chords.add(currentChord);
    };

    ^Prog(chords);
  }

  *new { |chords|
    ^super.new.init(chords);
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

  // Returns the number of chords in the progression
  size { ^chords.size }

  // Returns all note names for the progression
  names { ^chords.collect(_.names) }

  // Returns all notes for the progression as a flat array
  notes { ^chords.collect(_.notes) }

  // Returns frequencies grouped by chord
  freqs { ^chords.collect(_.freqs) }

  // Pattern implementation - yields chord frequencies
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

  // Get Melody of chord roots
  roots {
    ^Melody(chords.collect({ |chord| chord.notes[0] }), this.tuning);
  }

  // Get bass line Melody (lowest note of each chord)
  bassLine {
    ^Melody(chords.collect({ |chord| chord.notes.minItem }), this.tuning);
  }

  // Get top voice Melody (highest note of each chord)
  topVoice {
    ^Melody(chords.collect({ |chord| chord.notes.maxItem }), this.tuning);
  }

  // Transposes all chords by the given number of semitones
  transpose { |semitones|
    var newChords = chords.collect({ |chord|
      chord.class.new(chord.root + semitones, chord.intervals, chord.octave, chord.inversion);
    });
    ^Prog(newChords);
  }

  // Transposes all chords by octaves
  octave { |steps|
    var newChords = chords.collect(_.oct(steps));
    ^Prog(newChords);
  }

  // Inverts all chords by the given number of inversions
  invert { |steps|
    var newChords = chords.collect(_.invert(steps));
    ^Prog(newChords);
  }

  // Reverses the progression
  reverse {
    ^Prog(chords.reverse);
  }

  // Concatenates two progressions
  ++ { |other|
    ^Prog(chords ++ other.chords);
  }
}
