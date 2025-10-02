// Voice - A melodic/harmonic line combining melody, rhythm, and timbre
//
// Wraps a pattern chain while maintaining access to melody and rhythm components
// for inspection and rendering. Can be extended with additional patterns while
// preserving Voice type.
//
// Examples:
//   Voice(Melody([\C, \E, \G]), [0.5, 0.5, 1], (instrument: \piano, amp: 0.4))
//   Voice(Chord.major(\C), 2, (instrument: \piano, amp: 0.3))
//     .chain(Pbind(\legato, 0.9))
//
Voice : Pattern {
  var <melody, <rhythm, <timbre, <pattern;

  // Creates a new Voice from melody, rhythm, and timbre.
  // melody: Melody or Chord instance.
  // rhythm: Duration value or pattern (number, array, or Pattern).
  // timbre: Event with instrument and performance parameters (amp, legato, etc.).
  // Returns: New Voice instance.
  *new { |melody, rhythm, timbre|
    ^super.new.init(melody, rhythm, timbre);
  }

  init { |inMelody, inRhythm, inTimbre|
    melody = inMelody;
    rhythm = inRhythm;
    timbre = inTimbre ?? (instrument: \default);
    this.rebuildPattern;
  }

  // Rebuilds the internal pattern chain from components.
  rebuildPattern {
    var timbreArgs = [];
    var timbrePbind;

    // Convert timbre event to key-value pairs for Pbind
    timbre.keysValuesDo { |key, value|
      timbreArgs = timbreArgs.add(key).add(value);
    };

    timbrePbind = Pbind(*timbreArgs);
    // Rhythm already sets \dur, \amp, \legato via embedInStream
    pattern = Pchain(melody, rhythm, timbrePbind);
  }

  // Adds an additional pattern to the chain.
  // additionalPattern: Pattern to chain (typically Pbind).
  // Returns: This Voice instance for method chaining.
  chain { |additionalPattern|
    pattern = Pchain(pattern, additionalPattern);
    ^this;
  }

  // Gets the note numbers from the melody/chord.
  // Returns: Array of note numbers.
  notes {
    ^melody.notes;
  }

  // Renders the voice as a tablature-style string showing notes and durations.
  // maxDur: Maximum duration to render (default: rhythm.totalDuration)
  // Returns: String with notes aligned with their rhythmic positions in scientific notation.
  asTab { |maxDur|
    var notes = this.notes;
    var scientificNotes = melody.scientific;
    var durs = rhythm.durations;
    var targetDur = maxDur ?? rhythm.totalDuration;
    var str = "";
    var charsPerBeat = 4;
    var noteWidth = 4;  // 3 chars for note + 1 space separator
    var targetChars = (targetDur * charsPerBeat).asInteger;
    var pos = 0;
    var noteIdx = 0;

    // Keep adding notes until we fill the target duration
    while { pos < targetChars } {
      var dur = durs.wrapAt(noteIdx);
      var numChars = (dur * charsPerBeat).asInteger.max(noteWidth);
      var noteStr = scientificNotes.wrapAt(noteIdx);
      var remainingChars = targetChars - pos;

      // Only use as many chars as we have room for
      numChars = min(numChars, remainingChars);

      // If we have room for at least the note + space, add it
      if (numChars >= noteWidth) {
        str = str ++ noteStr ++ " ";  // Add space after note
        pos = pos + noteWidth;
        numChars = numChars - noteWidth;

        // Pad with dashes for remaining duration
        numChars.do {
          str = str ++ "-";
          pos = pos + 1;
        };
      } {
        // Not enough room for full note, just pad to end
        numChars.do {
          str = str ++ "-";
          pos = pos + 1;
        };
      };

      noteIdx = noteIdx + 1;
    };

    ^str;
  }

  // Pattern implementation - delegates to internal pattern chain.
  embedInStream { |inval|
    ^pattern.embedInStream(inval);
  }

  // Returns a readable string representation.
  printOn { |stream|
    stream << "Voice(" << melody.class.name << ", " << rhythm << ")";
  }
}
