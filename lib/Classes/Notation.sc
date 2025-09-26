// Notation - Helper class for parsing and converting musical notation
// Supports Roman numerals, chord symbols, note names, and scale degrees
Notation {
  classvar <noteMap, <romanMap;

  *initClass {
    // Map note symbols to chromatic numbers
    noteMap = (
      \C: 0, \D: 2, \E: 4, \F: 5, \G: 7, \A: 9, \B: 11,
      \Cb: 11, \Db: 1, \Eb: 3, \Fb: 4, \Gb: 6, \Ab: 8, \Bb: 10,
      \Cs: 1, \Ds: 3, \Es: 5, \Fs: 6, \Gs: 8, \As: 10, \Bs: 0,
      // Also support sharp notation
      \Csharp: 1, \Dsharp: 3, \Esharp: 5, \Fsharp: 6,
      \Gsharp: 8, \Asharp: 10, \Bsharp: 0,
      \Cflat: 11, \Dflat: 1, \Eflat: 3, \Fflat: 4,
      \Gflat: 6, \Aflat: 8, \Bflat: 10
    );

    // Map Roman numerals to scale degrees
    romanMap = (
      \I: 1, \II: 2, \III: 3, \IV: 4, \V: 5, \VI: 6, \VII: 7,
      \i: 1, \ii: 2, \iii: 3, \iv: 4, \v: 5, \vi: 6, \vii: 7
    );
  }

  // Convert a note symbol to chromatic pitch class (0-11)
  *noteToNumber { |note|
    ^noteMap[note] ? 0;
  }

  // Convert chromatic number to note name (using sharps)
  *numberToNote { |num|
    var names = [\C, \Cs, \D, \Ds, \E, \F, \Fs, \G, \Gs, \A, \As, \B];
    ^names[num % 12];
  }

  // Parse a key symbol (e.g., \C, \Am, \Gm) into root and mode
  *parseKey { |key|
    var keyStr = key.asString;
    var root, mode;

    case
      { keyStr.endsWith("m") } {
        root = keyStr[0..keyStr.size-2].asSymbol;
        mode = \minor;
      }
      { true } {
        root = key;
        mode = \major;
      };

    ^[this.noteToNumber(root), mode];
  }

  // Parse a Roman numeral into degree, quality, and modifiers
  *parseRomanNumeral { |numeral|
    var str = numeral.asString;
    var degree, quality, alteration = 0, bassNote, chordType;

    // Check for bass note (slash notation with underscore)
    if (str.includes($_)) {
      var parts = str.split($_);
      str = parts[0];
      bassNote = parts[1].asSymbol;
    };

    // Check for chromatic alterations (b or #)
    if (str[0] == $b) {
      alteration = -1;
      str = str[1..];
    };
    if (str[0] == $#) {
      alteration = 1;
      str = str[1..];
    };

    // Find the base Roman numeral
    degree = this.findRomanDegree(str);
    quality = this.determineQuality(str);
    chordType = this.parseChordType(str);

    ^(
      degree: degree,
      quality: quality,
      alteration: alteration,
      chordType: chordType,
      bassNote: bassNote
    );
  }

  // Find the Roman numeral degree (1-7)
  *findRomanDegree { |str|
    // Check longer numerals first to avoid false matches
    [\VII, \III, \II, \VI, \IV, \I, \V,
     \vii, \iii, \ii, \vi, \iv, \i, \v].do { |num|
      if (str.beginsWith(num.asString)) {
        ^romanMap[num];
      };
    };
    ^1;  // Default to I
  }

  // Determine chord quality from Roman numeral case
  *determineQuality { |str|
    // Check the first Roman character for case
    [\I, \V, \X].do { |char|
      if (str.beginsWith(char.asString)) { ^'major' };
    };
    ^'minor';  // Lowercase means minor
  }

  // Parse chord extensions and types
  *parseChordType { |str|
    case
      { str.contains("maj9") } { ^\maj9 }
      { str.contains("maj7") } { ^\maj7 }
      { str.contains("m7") } { ^\m7 }
      { str.contains("7") } { ^\dom7 }
      { str.contains("9") } { ^\dom9 }
      { str.contains("11") } { ^\dom11 }
      { str.contains("13") } { ^\dom13 }
      { str.contains("sus4") } { ^\sus4 }
      { str.contains("sus2") } { ^\sus2 }
      { str.contains("dim") || str.contains("°") } { ^\dim }
      { str.contains("+") || str.contains("aug") } { ^\aug }
      { str.contains("6") } { ^\add6 }
      { true } { ^\triad };
  }

  // Get scale degrees for a given mode
  *scaleDegrees { |mode = \major|
    ^if (mode == \major) {
      [0, 2, 4, 5, 7, 9, 11]  // Major scale intervals
    } {
      [0, 2, 3, 5, 7, 8, 10]  // Natural minor scale intervals
    };
  }

  // Get intervals for a chord based on quality and type
  *chordIntervals { |quality = 'major', chordType = \triad, degree = 1, mode = \major|
    // Handle special diatonic cases
    if ((mode == \major) && (degree == 7)) {
      // vii° in major is diminished
      if (chordType == \triad) { ^[3, 3] };
    };
    if ((mode == \minor) && (degree == 2)) {
      // ii° in minor is diminished
      if (chordType == \triad) { ^[3, 3] };
    };

    // Standard interval patterns
    ^case
      // Triads
      { chordType == \triad } {
        if (quality == 'major') { [4, 3] } { [3, 4] }
      }
      // Sevenths
      { chordType == \dom7 } {
        if (quality == 'major') { [4, 3, 3] } { [3, 4, 3] }
      }
      { chordType == \maj7 } {
        if (quality == 'major') { [4, 3, 4] } { [3, 4, 4] }
      }
      { chordType == \m7 } { [3, 4, 3] }
      // Extended chords
      { chordType == \dom9 } {
        if (quality == 'major') { [4, 3, 3, 4] } { [3, 4, 3, 4] }
      }
      { chordType == \maj9 } {
        if (quality == 'major') { [4, 3, 4, 3] } { [3, 4, 4, 3] }
      }
      // Altered chords
      { chordType == \dim } { [3, 3] }
      { chordType == \aug } { [4, 4] }
      { chordType == \sus4 } { [5, 2] }
      { chordType == \sus2 } { [2, 5] }
      { chordType == \add6 } {
        if (quality == 'major') { [4, 3, 2] } { [3, 4, 2] }
      }
      // Default to major triad
      { [4, 3] };
  }

  // Build a chord from a Roman numeral in a given key
  *romanToChord { |keyRoot, mode, romanNumeral, octave = 0|
    var parsed = this.parseRomanNumeral(romanNumeral);
    var scaleDegrees = this.scaleDegrees(mode);
    var chord, chordRoot, intervals;

    // Calculate chord root (wrap to 0-11)
    chordRoot = (keyRoot + scaleDegrees[parsed.degree - 1] + parsed.alteration) % 12;

    // Get intervals for the chord
    intervals = this.chordIntervals(
      parsed.quality,
      parsed.chordType,
      parsed.degree,
      mode
    );

    // Create the chord
    chord = Chromatic(chordRoot, intervals, octave);

    // TODO: Handle inversions based on bassNote
    if (parsed.bassNote.notNil) {
      // Calculate inversion from bass note
    };

    ^chord;
  }

  // Parse a chord symbol (e.g., Cmaj7, Dm7, G7) into a Chromatic chord
  *symbolToChord { |symbol, octave = 0|
    var str = symbol.asString;
    var root, quality, chordType, intervals;
    var rootStr, qualStr;

    // Extract root note (first 1-2 chars)
    // Check for sharp (#) or flat (b) but not 's' which could be 'sus'
    if ((str.size > 1) && ((str[1] == $b) || (str[1] == $#))) {
      rootStr = str[0..1];
      qualStr = str[2..];
    } {
      // Check if it's a sharp note with 's' notation (e.g., Cs, Fs)
      // Only if 's' is NOT followed by 'us' (which would be 'sus')
      if ((str.size > 1) && (str[1] == $s)) {
        // Check if it's 'sus' or just 's' for sharp
        if ((str.size > 2) && (str[2] == $u)) {
          // It's 'sus', not sharp
          rootStr = str[0..0];
          qualStr = str[1..];
        } {
          // It's sharp (Cs, Fs, etc.)
          rootStr = str[0..1];
          qualStr = if (str.size > 2) { str[2..] } { "" };
        }
      } {
        rootStr = str[0..0];
        qualStr = str[1..];
      }
    };

    root = this.noteToNumber(rootStr.asSymbol);

    // Parse the chord type first
    chordType = this.parseChordType(qualStr);

    // Determine quality from the qualifier string
    // Sus chords and other special types don't have major/minor quality
    quality = if ((chordType == \sus4) || (chordType == \sus2) ||
                  (chordType == \dim) || (chordType == \aug)) {
      'neutral'
    } {
      if (qualStr.beginsWith("m") && qualStr.beginsWith("maj").not) {
        'minor'
      } {
        'major'
      }
    };

    // Get intervals
    intervals = this.chordIntervals(quality, chordType);

    ^Chromatic(root, intervals, octave);
  }
}
