// Notation - Helper class for parsing and converting musical notation
// Supports Roman numerals, chord symbols, note names, and scale degrees
Notation {
  classvar <noteMap, <romanMap;

  *initClass {
    // Map note symbols to chromatic numbers
    noteMap = IdentityDictionary.newFrom([
      // Natural notes
      \C, 0,
      \D, 2,
      \E, 4,
      \F, 5,
      \G, 7,
      \A, 9,
      \B, 11,

      // Flat notes
      \Cb, 11,
      \Db, 1,
      \Eb, 3,
      \Fb, 4,
      \Gb, 6,
      \Ab, 8,
      \Bb, 10,

      // Sharp notes with 's' notation
      \Cs, 1,
      \Ds, 3,
      \Es, 5,
      \Fs, 6,
      \Gs, 8,
      \As, 10,
      \Bs, 0,

      // Long sharp notation
      \Csharp, 1,
      \Dsharp, 3,
      \Esharp, 5,
      \Fsharp, 6,
      \Gsharp, 8,
      \Asharp, 10,
      \Bsharp, 0,

      // Long flat notation
      \Cflat, 11,
      \Dflat, 1,
      \Eflat, 3,
      \Fflat, 4,
      \Gflat, 6,
      \Aflat, 8,
      \Bflat, 10
    ]);

    // Map Roman numerals to scale degrees
    romanMap = (
      \I: 1, \II: 2, \III: 3, \IV: 4, \V: 5, \VI: 6, \VII: 7,
      \i: 1, \ii: 2, \iii: 3, \iv: 4, \v: 5, \vi: 6, \vii: 7
    );
  }

  // Converts a note symbol to chromatic pitch class (0-11).
  // note: Note symbol (e.g., \C, \Fs, \Bb) or number.
  // Returns: Chromatic pitch class 0-11, or original if already a number.
  *noteToNumber { |note|
    if (note.isNumber) {
      ^note;
    } {
      ^noteMap[note] ? 0;
    };
  }

  // Converts a chromatic number to note name symbol (using sharps).
  // num: Chromatic pitch number.
  // Returns: Note symbol with sharp notation if needed.
  *numberToNote { |num|
    var names = [\C, \C♯, \D, \D♯, \E, \F, \F♯, \G, \G♯, \A, \A♯, \B];
    ^names[num % 12];
  }

  // Converts a MIDI note number to octave-specific symbol.
  // midiNote: MIDI note number (0-127).
  // Returns: Symbol like \Cs4, \Bb3, etc.
  *midiToSymbol { |midiNote|
    var pitchClass = this.numberToNote(midiNote % 12);
    var octave = (midiNote / 12).floor.asInteger - 1; // Standard MIDI octave calculation, ensure integer
    var noteStr = pitchClass.asString;

    // Convert Unicode sharp/flat symbols to 's'/'b' for SuperCollider compatibility
    noteStr = noteStr.replace("♯", "s").replace("♭", "b");

    ^(noteStr ++ octave.asString).asSymbol;
  }

  // Parses an octave-specific symbol to MIDI note number.
  // symbol: Symbol like \Cs4, \Bb3, etc.
  // Returns: MIDI note number.
  *symbolToMidi { |symbol|
    var str = symbol.asString;
    var octave, noteStr, pitchClass, octaveStart;

    // Extract octave number from end of string
    if (str.size < 2) {
      Error("Invalid octave symbol: %".format(symbol)).throw;
    };

    // Find where the octave number starts (last digit or negative sign)
    octaveStart = str.size - 1;
    while ({ (octaveStart > 0) && str[octaveStart].isDecDigit }) {
      octaveStart = octaveStart - 1;
    };
    if (str[octaveStart] == $-) {
      octaveStart = octaveStart - 1; // Include negative sign
    };
    octaveStart = octaveStart + 1;

    noteStr = str.keep(octaveStart);
    octave = str.drop(octaveStart).asInteger;

    // Convert note string to symbol and get pitch class
    pitchClass = this.noteToNumber(noteStr.asSymbol);

    ^pitchClass + ((octave + 1) * 12);
  }

  // Checks if a symbol is an octave-specific note (contains digits).
  // symbol: Symbol to check.
  // Returns: Boolean.
  *isOctaveSymbol { |symbol|
    var str = symbol.asString;
    ^str.any({ |char| char.isDecDigit });
  }

  // Parses a key symbol into root pitch and mode.
  // key: Key symbol (e.g., \C for C major, \Am for A minor).
  // Returns: Array of [root pitch (0-11), mode symbol (\major or \minor)].
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

  // Parses a Roman numeral into its components.
  // numeral: Roman numeral symbol (e.g., \I, \vi, \V7, \bVII).
  // Returns: Event with degree, quality, alteration, chordType, and bassNote.
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

  // Finds the scale degree from a Roman numeral string.
  // str: String containing Roman numeral.
  // Returns: Scale degree 1-7.
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

  // Determines chord quality from Roman numeral case.
  // str: String containing Roman numeral.
  // Returns: Symbol 'major' or 'minor' based on case.
  *determineQuality { |str|
    // Check the first Roman character for case
    [\I, \V, \X].do { |char|
      if (str.beginsWith(char.asString)) { ^'major' };
    };
    ^'minor';  // Lowercase means minor
  }

  // Parses chord extensions and types from a string.
  // str: String containing chord type indicators.
  // Returns: Symbol for chord type (e.g., \triad, \dom7, \maj7, \sus4).
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

  // Gets scale degree intervals for a given mode.
  // mode: Mode symbol (\major or \minor).
  // Returns: Array of semitone offsets from root for each scale degree.
  *scaleDegrees { |mode = \major|
    ^if (mode == \major) {
      [0, 2, 4, 5, 7, 9, 11]  // Major scale intervals
    } {
      [0, 2, 3, 5, 7, 8, 10]  // Natural minor scale intervals
    };
  }

  // Gets interval structure for a chord based on its properties.
  // quality: Chord quality ('major' or 'minor').
  // chordType: Type symbol (\triad, \dom7, \maj7, etc.).
  // degree: Scale degree (1-7) for diatonic context.
  // mode: Key mode (\major or \minor) for diatonic context.
  // Returns: Array of semitone intervals between chord tones.
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

  // Builds a Chord from a Roman numeral in a given key.
  // keyRoot: Root pitch of the key (0-11).
  // mode: Key mode (\major or \minor).
  // romanNumeral: Roman numeral symbol.
  // octave: Base octave for the chord.
  // Returns: Chord corresponding to the Roman numeral in the key.
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
    chord = Pchord(chordRoot, intervals, octave);

    // TODO: Handle inversions based on bassNote
    if (parsed.bassNote.notNil) {
      // Calculate inversion from bass note
    };

    ^chord;
  }

  // Parses a chord symbol into a Chord object.
  // symbol: Chord symbol (e.g., \Cmaj7, \Dm7, \G7, \Fsus4).
  // octave: Base octave for the chord.
  // Returns: Chord matching the symbol.
  *symbolToChord { |symbol, octave = 0|
    var str = symbol.asString;
    var root, quality, chordType, intervals;
    var rootStr, qualStr;

    // Extract root note (first 1-2 chars)
    // Start with just first character
    rootStr = str.keep(1);        // First character
    qualStr = str.drop(1);        // Everything after first character

    // Check if second character is an accidental
    if (str.size > 1) {
      if (str[1] == $#) {
        // Sharp with #
        rootStr = str.keep(2);
        qualStr = str.drop(2);
      } {
        if (str[1] == $b) {
          // Flat with b
          rootStr = str.keep(2);
          qualStr = str.drop(2);
        } {
          if ((str[1] == $s) && ((str.size < 3) || (str[2] != $u))) {
            // Sharp with 's', but not 'sus'
            rootStr = str.keep(2);
            qualStr = str.drop(2);
          };
        };
      };
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

    ^Pchord(root, intervals, octave);
  }
}
