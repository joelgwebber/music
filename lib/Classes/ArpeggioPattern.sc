ArpeggioPattern {
  var <>pattern, <>octaves, <>gatePattern, <>repeat;

  *new { |pattern = nil, octaves = 1, gatePattern = nil, repeat = 1|
    ^super.new.init(pattern, octaves, gatePattern, repeat);
  }

  init { |inPattern, inOctaves, inGatePattern, inRepeat|
    pattern = inPattern ?? [0, 1, 2, 3]; // default ascending
    octaves = inOctaves;
    gatePattern = inGatePattern;
    repeat = inRepeat;
  }

  // Expand pattern across multiple octaves
  expandedPattern {
    var expanded = [];

    octaves.do { |oct|
      pattern.do { |index|
        expanded = expanded.add([index, oct]);
      };
    };

    if (repeat > 1) {
      expanded = expanded.stutter(repeat).flatten.reshape(expanded.size * repeat, 2);
    };

    ^expanded;
  }

  // Common arpeggio patterns as class methods
  *up { |size = 4, octaves = 1|
    ^ArpeggioPattern((0..size-1), octaves);
  }

  *down { |size = 4, octaves = 1|
    ^ArpeggioPattern((0..size-1).reverse, octaves);
  }

  *upDown { |size = 4, octaves = 1, includeTop = true|
    var up = (0..size-1);
    var down = includeTop.if(
      { up.reverse },
      { up.reverse[1..] }
    );
    ^ArpeggioPattern(up ++ down, octaves);
  }

  *downUp { |size = 4, octaves = 1, includeBottom = true|
    var down = (0..size-1).reverse;
    var up = includeBottom.if(
      { (0..size-1) },
      { (1..size-1) }
    );
    ^ArpeggioPattern(down ++ up, octaves);
  }

  *random { |size = 4, length = 8, octaves = 1|
    var pattern = Array.fill(length, { size.rand });
    ^ArpeggioPattern(pattern, octaves);
  }

  *converge { |size = 4, octaves = 1|
    var pattern = [];
    var mid = size / 2;

    size.do { |i|
      if (i.even) {
        pattern = pattern.add(i / 2);
      } {
        pattern = pattern.add(size - 1 - (i / 2));
      };
    };

    ^ArpeggioPattern(pattern, octaves);
  }

  *diverge { |size = 4, octaves = 1|
    var pattern = [];
    var mid = (size - 1) / 2;

    if (size.even) {
      (size/2).do { |i|
        pattern = pattern.add(mid.floor - i);
        pattern = pattern.add(mid.ceil + i);
      };
    } {
      pattern = pattern.add(mid);
      ((size-1)/2).do { |i|
        pattern = pattern.add(mid - i - 1);
        pattern = pattern.add(mid + i + 1);
      };
    };

    ^ArpeggioPattern(pattern.keep(size), octaves);
  }

  *alberti { |size = 4|
    var pattern = size.switch(
      3, { [0, 2, 1, 2] },
      4, { [0, 2, 1, 2] },
      { [0, 2, 1, 3] } // for larger chords
    );
    ^ArpeggioPattern(pattern, 1);
  }

  // Apply arpeggio pattern to a chord progression
  applyToProgression { |progression, rhythm = nil|
    var events = [];
    var chordDurations = rhythm.notNil.if(
      { rhythm.scaledDurations },
      { Array.fill(progression.size, 1) }
    );
    var chordVelocities = rhythm.notNil.if(
      { rhythm.velocities },
      { Array.fill(progression.size, 0.7) }
    );

    progression.chords.do { |chord, chordIndex|
      var notes = chord.notes;
      var freqs = chord.freqs;
      var expanded = this.expandedPattern;
      var notesPerBeat = expanded.size;
      var noteDur = chordDurations.wrapAt(chordIndex) / notesPerBeat;

      expanded.do { |indexOctave, i|
        var noteIndex = indexOctave[0];
        var octaveOffset = indexOctave[1];
        var note = notes.wrapAt(noteIndex) + (12 * octaveOffset);
        var freq = freqs.wrapAt(noteIndex) * (2 ** octaveOffset);
        var gate = gatePattern.notNil.if(
          { gatePattern.wrapAt(i) },
          { 0.9 }
        );

        events = events.add((
          freq: freq,
          amp: chordVelocities.wrapAt(chordIndex) * (0.9 + 0.1.rand),
          dur: noteDur,
          sustain: noteDur * gate,
          note: note
        ));
      };
    };

    ^events;
  }

  // Returns a Pattern that generates arpeggio events
  asPattern { |chords, rhythm = nil|
    var events = this.applyToProgression(chords, rhythm);
    ^Pdef(\arpeggio,
      Pbind(
        \freq, Pseq(events.collect(_.freq)),
        \amp, Pseq(events.collect(_.amp)),
        \dur, Pseq(events.collect(_.dur)),
        \sustain, Pseq(events.collect(_.sustain))
      )
    );
  }

  // Convenience method to create pattern from indices string
  *fromString { |str, octaves = 1|
    var pattern = str.ascii.collect { |char|
      case
        { (char >= 48) and: (char <= 57) } { char - 48 } // 0-9
        { (char >= 65) and: (char <= 90) } { char - 65 + 10 } // A-Z
        { (char >= 97) and: (char <= 122) } { char - 97 + 10 } // a-z
        { nil }
    }.reject(_.isNil);

    ^ArpeggioPattern(pattern, octaves);
  }
}
