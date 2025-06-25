// Encapsulates a sequence of chords and provides methods for manipulation and pattern generation
Progression {
  var <>chords;

  *new { |chords|
    ^super.new.init(chords);
  }

  init { |inChords|
    chords = inChords;
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
    ^Progression(newChords);
  }

  // Transposes all chords by octaves
  octave { |steps|
    var newChords = chords.collect(_.oct(steps));
    ^Progression(newChords);
  }

  // Inverts all chords by the given number of inversions
  invert { |steps|
    var newChords = chords.collect(_.invert(steps));
    ^Progression(newChords);
  }

  // Reverses the progression
  reverse {
    ^Progression(chords.reverse);
  }

  // Concatenates two progressions
  ++ { |other|
    ^Progression(chords ++ other.chords);
  }

  // Returns a subsequence of the progression
  copyRange { |start, end|
    ^Progression(chords.copyRange(start, end));
  }

  // Cycles through the progression n times
  cycle { |n = 2|
    ^Progression(chords.stutter(n).flatten);
  }

  // Maps a function over each chord
  collect { |func|
    var newChords = chords.collect(func);
    ^Progression(newChords);
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

  // Returns a Stream of chords for Pattern integration
  asStream {
    ^Pseq(chords, inf).asStream;
  }

  // Create a simple chord pattern
  chordPattern { |rhythm = nil, instrument = \default|
    var rhythmPattern = rhythm ?? RhythmPattern.straight(chords.size);
    ^Pbind(
      \instrument, instrument,
      \chord, Pseq(chords),
      \freq, Pfunc({ |ev| ev[\chord].freqs }),
      \dur, Pseq(rhythmPattern.scaledDurations),
      \amp, Pseq(rhythmPattern.velocities),
      \legato, Pseq(rhythmPattern.gates)
    );
  }

  // Create an arpeggiated pattern
  arpeggioPattern { |arpPattern = nil, rhythm = nil, instrument = \default|
    var arp = arpPattern ?? ArpeggioPattern.up(4);
    var events = arp.applyToProgression(this, rhythm);
    ^Pbind(
      \instrument, instrument,
      \freq, Pseq(events.collect(_.freq)),
      \amp, Pseq(events.collect(_.amp)),
      \dur, Pseq(events.collect(_.dur)),
      \sustain, Pseq(events.collect(_.sustain))
    );
  }

  // Create a strummed pattern
  strumPattern { |strumPattern = nil, rhythm = nil, instrument = \default|
    var strum = strumPattern ?? StrumPattern.guitar(\medium);
    var events = strum.applyToProgression(this, rhythm);
    ^Pbind(
      \instrument, instrument,
      \freq, Pseq(events.collect(_.freq)),
      \lag, Pseq(events.collect(_.lag)),
      \amp, Pseq(events.collect(_.amp)),
      \dur, Pseq(events.collect(_.dur)),
      \sustain, Pseq(events.collect(_.sustain))
    );
  }

  // Utility methods for working with patterns

  // Apply a function to each chord's frequencies
  mapFreqs { |func|
    ^chords.collect({ |chord| func.value(chord.freqs) });
  }

  // Get all root frequencies
  roots {
    ^chords.collect({ |chord| chord.freqs[0] });
  }

  // Get bass line (lowest note of each chord)
  bassLine {
    ^chords.collect({ |chord| chord.freqs.minItem });
  }

  // Get top voice (highest note of each chord)
  topVoice {
    ^chords.collect({ |chord| chord.freqs.maxItem });
  }

  // Create a voice-led pattern (minimizes movement between chords)
  voiceLeadPattern { |rhythm = nil, instrument = \default|
    var rhythmPattern = rhythm ?? RhythmPattern.straight(chords.size);
    var voicedChords = this.voiceLead;
    
    ^Pbind(
      \instrument, instrument,
      \freq, Pseq(voicedChords),
      \dur, Pseq(rhythmPattern.scaledDurations.collect(_.dup(chords[0].size)).flatten),
      \amp, Pseq(rhythmPattern.velocities.collect(_.dup(chords[0].size)).flatten),
      \legato, Pseq(rhythmPattern.gates.collect(_.dup(chords[0].size)).flatten)
    );
  }

  // Simple voice leading algorithm
  voiceLead {
    var result = [chords[0].freqs];
    
    (1..chords.size-1).do { |i|
      var prevFreqs = result[i-1];
      var currentFreqs = chords[i].freqs;
      var voicedFreqs = Array.new(currentFreqs.size);
      
      // For each voice in the previous chord, find the closest note in the current chord
      prevFreqs.do { |prevFreq|
        var distances = currentFreqs.collect({ |freq| (freq - prevFreq).abs });
        var closestIndex = distances.minIndex;
        voicedFreqs = voicedFreqs.add(currentFreqs[closestIndex]);
        currentFreqs = currentFreqs.reject({ |freq, j| j == closestIndex });
      };
      
      // Add any remaining notes
      voicedFreqs = voicedFreqs ++ currentFreqs;
      result = result.add(voicedFreqs);
    };
    
    ^result;
  }
}

