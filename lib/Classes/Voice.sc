// Voice - A melodic/harmonic line combining melody, rhythm, and timbre
//
// Wraps a pattern chain while maintaining access to melody and rhythm components
// for inspection and rendering. Can be extended with additional patterns while
// preserving Voice type.
//
// Examples:
//   Voice(Melody([\C, \E, \G]), Rhythm.straight(3), (instrument: \piano, amp: 0.4))
//   Voice(Chord.major(\C), Rhythm.note(2), (instrument: \piano, amp: 0.3))
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
  // Uses a fixed number of characters per note for consistent alignment across voices.
  //
  // maxDur: Maximum duration to render (default: rhythm.totalDuration)
  // subdivsPerBeat: Subdivisions per beat for alignment (default: calculated from rhythm)
  // Returns: String with notes aligned with their rhythmic positions in scientific notation.
  asTab { |maxDur, subdivsPerBeat|
    var notes = this.notes;
    var scientificNotes = melody.scientific;
    var numerators = rhythm.numerators;
    var denominator = rhythm.denominator;
    var targetDur = maxDur ?? rhythm.totalDuration;
    var str = "";

    // Calculate characters per beat based on rhythm density or override
    // Scientific notation is always 3 visual chars, so 4 chars per subdiv gives 1 char spacing
    var charsPerSubdiv = 4;
    var actualSubdivsPerBeat = subdivsPerBeat ?? (numerators.size / rhythm.totalDuration);
    var charsPerBeat = (actualSubdivsPerBeat * charsPerSubdiv).round.asInteger;

    // Calculate exact number of rhythm events to render
    // targetDur / rhythm.totalDuration gives us how many complete cycles
    // Multiply by numerators.size to get total events
    var totalEvents = (targetDur / rhythm.totalDuration * numerators.size).round.asInteger;

    // Render exactly that many events
    totalEvents.do { |i|
      var noteStr = scientificNotes.wrapAt(i);
      var numerator = numerators.wrapAt(i);
      var noteDuration = numerator / denominator;  // Duration in beats
      var totalChars = (noteDuration * charsPerBeat).round.asInteger;
      var padding;

      // Render note name
      str = str ++ noteStr;

      // Scientific notation is always 3 visual characters (note + accidental + octave)
      // Don't use noteStr.size as it counts UTF-8 bytes, not visual characters
      padding = totalChars - 3;
      padding.do {
        str = str ++ "-";
      };
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
