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
  // Each subdivision renders as 3 characters. Notes are followed by dashes for their duration.
  asTab { |maxDur|
    var notes = this.notes;
    var scientificNotes = melody.scientific;
    var numerators = rhythm.numerators;
    var denominator = rhythm.denominator;
    var targetDur = maxDur ?? rhythm.totalDuration;
    var str = "";
    var charsPerSubdiv = 3;  // Each subdivision = 3 characters

    // Calculate how many rhythm cycles we need
    var targetSubdivisions = (targetDur * denominator).asInteger;
    var rhythmDuration = numerators.sum;  // Should equal denominator
    var numCycles = (targetSubdivisions / rhythmDuration).ceil.asInteger;
    var noteIdx = 0;
    var rhythmIdx = 0;

    // Render each note in the rhythm pattern, repeating as needed
    (numCycles * numerators.size).do { |i|
      var noteStr = scientificNotes.wrapAt(noteIdx);
      var numerator = numerators.wrapAt(rhythmIdx);
      var totalChars = numerator * charsPerSubdiv;

      // Render note name (3 chars)
      str = str ++ noteStr;

      // Pad with dashes for remaining duration
      (totalChars - charsPerSubdiv).do {
        str = str ++ "-";
      };

      noteIdx = noteIdx + 1;
      rhythmIdx = rhythmIdx + 1;
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
