// Unit tests for the Notation class
TestNotation : UnitTest {

  // Test note name to number conversion
  test_noteToNumber {
    // Natural notes
    this.assertEquals(Notation.noteToNumber(\C), 0, "C should be 0");
    this.assertEquals(Notation.noteToNumber(\D), 2, "D should be 2");
    this.assertEquals(Notation.noteToNumber(\E), 4, "E should be 4");
    this.assertEquals(Notation.noteToNumber(\F), 5, "F should be 5");
    this.assertEquals(Notation.noteToNumber(\G), 7, "G should be 7");
    this.assertEquals(Notation.noteToNumber(\A), 9, "A should be 9");
    this.assertEquals(Notation.noteToNumber(\B), 11, "B should be 11");

    // Sharp notes
    this.assertEquals(Notation.noteToNumber(\Cs), 1, "C# should be 1");
    this.assertEquals(Notation.noteToNumber(\Ds), 3, "D# should be 3");
    this.assertEquals(Notation.noteToNumber(\Fs), 6, "F# should be 6");
    this.assertEquals(Notation.noteToNumber(\Gs), 8, "G# should be 8");
    this.assertEquals(Notation.noteToNumber(\As), 10, "A# should be 10");

    // Flat notes
    this.assertEquals(Notation.noteToNumber(\Db), 1, "Db should be 1");
    this.assertEquals(Notation.noteToNumber(\Eb), 3, "Eb should be 3");
    this.assertEquals(Notation.noteToNumber(\Gb), 6, "Gb should be 6");
    this.assertEquals(Notation.noteToNumber(\Ab), 8, "Ab should be 8");
    this.assertEquals(Notation.noteToNumber(\Bb), 10, "Bb should be 10");

    // Edge cases
    this.assertEquals(Notation.noteToNumber(\Cb), 11, "Cb should be 11");
    this.assertEquals(Notation.noteToNumber(\Bs), 0, "B# should be 0");
    this.assertEquals(Notation.noteToNumber(\Fb), 4, "Fb should be 4");
    this.assertEquals(Notation.noteToNumber(\Es), 5, "E# should be 5");
  }

  // Test number to note conversion
  test_numberToNote {
    this.assertEquals(Notation.numberToNote(0), \C, "0 should be C");
    this.assertEquals(Notation.numberToNote(1), \Cs, "1 should be C#");
    this.assertEquals(Notation.numberToNote(2), \D, "2 should be D");
    this.assertEquals(Notation.numberToNote(7), \G, "7 should be G");
    this.assertEquals(Notation.numberToNote(11), \B, "11 should be B");

    // Test wrapping
    this.assertEquals(Notation.numberToNote(12), \C, "12 should wrap to C");
    this.assertEquals(Notation.numberToNote(13), \Cs, "13 should wrap to C#");
    this.assertEquals(Notation.numberToNote(24), \C, "24 should wrap to C");
  }

  // Test key parsing
  test_parseKey {
    var root, mode;

    // Major keys
    #root, mode = Notation.parseKey(\C);
    this.assertEquals(root, 0, "C root should be 0");
    this.assertEquals(mode, \major, "C should be major");

    #root, mode = Notation.parseKey(\G);
    this.assertEquals(root, 7, "G root should be 7");
    this.assertEquals(mode, \major, "G should be major");

    #root, mode = Notation.parseKey(\Bb);
    this.assertEquals(root, 10, "Bb root should be 10");
    this.assertEquals(mode, \major, "Bb should be major");

    // Minor keys
    #root, mode = Notation.parseKey(\Am);
    this.assertEquals(root, 9, "Am root should be 9");
    this.assertEquals(mode, \minor, "Am should be minor");

    #root, mode = Notation.parseKey(\Cm);
    this.assertEquals(root, 0, "Cm root should be 0");
    this.assertEquals(mode, \minor, "Cm should be minor");

    #root, mode = Notation.parseKey(\Fm);
    this.assertEquals(root, 5, "Fm root should be 5");
    this.assertEquals(mode, \minor, "Fm should be minor");
  }

  // Test Roman numeral parsing
  test_parseRomanNumeral {
    var parsed;

    // Simple major numerals
    parsed = Notation.parseRomanNumeral(\I);
    this.assertEquals(parsed.degree, 1, "I should be degree 1");
    this.assertEquals(parsed.quality, 'major', "I should be major");
    this.assertEquals(parsed.chordType, \triad, "I should be a triad");
    this.assertEquals(parsed.alteration, 0, "I should have no alteration");

    // Simple minor numerals
    parsed = Notation.parseRomanNumeral(\vi);
    this.assertEquals(parsed.degree, 6, "vi should be degree 6");
    this.assertEquals(parsed.quality, 'minor', "vi should be minor");
    this.assertEquals(parsed.chordType, \triad, "vi should be a triad");

    // Seventh chords
    parsed = Notation.parseRomanNumeral(\V7);
    this.assertEquals(parsed.degree, 5, "V7 should be degree 5");
    this.assertEquals(parsed.quality, 'major', "V7 should be major");
    this.assertEquals(parsed.chordType, \dom7, "V7 should be dominant 7");

    parsed = Notation.parseRomanNumeral(\Imaj7);
    this.assertEquals(parsed.degree, 1, "Imaj7 should be degree 1");
    this.assertEquals(parsed.chordType, \maj7, "Imaj7 should be major 7");

    parsed = Notation.parseRomanNumeral(\ii7);
    this.assertEquals(parsed.degree, 2, "ii7 should be degree 2");
    this.assertEquals(parsed.quality, 'minor', "ii7 should be minor");
    this.assertEquals(parsed.chordType, \dom7, "ii7 should be dominant 7 type");

    // Altered roots
    parsed = Notation.parseRomanNumeral(\bVII);
    this.assertEquals(parsed.degree, 7, "bVII should be degree 7");
    this.assertEquals(parsed.alteration, -1, "bVII should have -1 alteration");

    parsed = Notation.parseRomanNumeral(\bII);
    this.assertEquals(parsed.degree, 2, "bII should be degree 2");
    this.assertEquals(parsed.alteration, -1, "bII should have -1 alteration");

    // Slash chords (bass notes)
    parsed = Notation.parseRomanNumeral(\I_E);
    this.assertEquals(parsed.degree, 1, "I_E should be degree 1");
    this.assertEquals(parsed.bassNote, \E, "I_E should have E in bass");

    // Special chords
    parsed = Notation.parseRomanNumeral(\Isus4);
    this.assertEquals(parsed.chordType, \sus4, "Isus4 should be sus4 type");

    parsed = Notation.parseRomanNumeral(\vdim);
    this.assertEquals(parsed.chordType, \dim, "vdim should be diminished");
  }

  // Test chord type parsing
  test_parseChordType {
    this.assertEquals(Notation.parseChordType(""), \triad, "Empty should be triad");
    this.assertEquals(Notation.parseChordType("7"), \dom7, "7 should be dom7");
    this.assertEquals(Notation.parseChordType("maj7"), \maj7, "maj7 should be maj7");
    this.assertEquals(Notation.parseChordType("m7"), \m7, "m7 should be m7");
    this.assertEquals(Notation.parseChordType("9"), \dom9, "9 should be dom9");
    this.assertEquals(Notation.parseChordType("maj9"), \maj9, "maj9 should be maj9");
    this.assertEquals(Notation.parseChordType("sus4"), \sus4, "sus4 should be sus4");
    this.assertEquals(Notation.parseChordType("sus2"), \sus2, "sus2 should be sus2");
    this.assertEquals(Notation.parseChordType("dim"), \dim, "dim should be dim");
    this.assertEquals(Notation.parseChordType("°"), \dim, "° should be dim");
    this.assertEquals(Notation.parseChordType("+"), \aug, "+ should be aug");
    this.assertEquals(Notation.parseChordType("aug"), \aug, "aug should be aug");
    this.assertEquals(Notation.parseChordType("6"), \add6, "6 should be add6");
  }

  // Test scale degrees
  test_scaleDegrees {
    var major = Notation.scaleDegrees(\major);
    var minor = Notation.scaleDegrees(\minor);

    this.assertEquals(major, [0, 2, 4, 5, 7, 9, 11], "Major scale degrees");
    this.assertEquals(minor, [0, 2, 3, 5, 7, 8, 10], "Minor scale degrees");
  }

  // Test chord intervals
  test_chordIntervals {
    // Basic triads
    this.assertEquals(
      Notation.chordIntervals('major', \triad),
      [4, 3],
      "Major triad intervals"
    );
    this.assertEquals(
      Notation.chordIntervals('minor', \triad),
      [3, 4],
      "Minor triad intervals"
    );

    // Seventh chords
    this.assertEquals(
      Notation.chordIntervals('major', \dom7),
      [4, 3, 3],
      "Dominant 7 intervals"
    );
    this.assertEquals(
      Notation.chordIntervals('major', \maj7),
      [4, 3, 4],
      "Major 7 intervals"
    );
    this.assertEquals(
      Notation.chordIntervals('minor', \m7),
      [3, 4, 3],
      "Minor 7 intervals"
    );

    // Special chords
    this.assertEquals(
      Notation.chordIntervals('major', \dim),
      [3, 3],
      "Diminished intervals"
    );
    this.assertEquals(
      Notation.chordIntervals('major', \aug),
      [4, 4],
      "Augmented intervals"
    );
    this.assertEquals(
      Notation.chordIntervals('major', \sus4),
      [5, 2],
      "Sus4 intervals"
    );
    this.assertEquals(
      Notation.chordIntervals('major', \sus2),
      [2, 5],
      "Sus2 intervals"
    );

    // Diatonic special cases
    this.assertEquals(
      Notation.chordIntervals('major', \triad, 7, \major),
      [3, 3],
      "vii° in major should be diminished"
    );
    this.assertEquals(
      Notation.chordIntervals('minor', \triad, 2, \minor),
      [3, 3],
      "ii° in minor should be diminished"
    );
  }

  // Test Roman numeral to chord conversion
  test_romanToChord {
    var chord;

    // C major context
    chord = Notation.romanToChord(0, \major, \I, 0);
    this.assertEquals(chord.root, 0, "I in C should have root 0");
    this.assertEquals(chord.intervals, [4, 3], "I in C should be major");

    chord = Notation.romanToChord(0, \major, \vi, 0);
    this.assertEquals(chord.root, 9, "vi in C should have root 9 (A)");
    this.assertEquals(chord.intervals, [3, 4], "vi in C should be minor");

    chord = Notation.romanToChord(0, \major, \V7, 0);
    this.assertEquals(chord.root, 7, "V7 in C should have root 7 (G)");
    this.assertEquals(chord.intervals, [4, 3, 3], "V7 in C should be dom7");

    // G major context
    chord = Notation.romanToChord(7, \major, \I, 0);
    this.assertEquals(chord.root, 7, "I in G should have root 7");

    chord = Notation.romanToChord(7, \major, \IV, 0);
    this.assertEquals(chord.root, 0, "IV in G should have root 0 (C)");

    // A minor context
    chord = Notation.romanToChord(9, \minor, \i, 0);
    this.assertEquals(chord.root, 9, "i in Am should have root 9");
    this.assertEquals(chord.intervals, [3, 4], "i in Am should be minor");

    chord = Notation.romanToChord(9, \minor, \VI, 0);
    this.assertEquals(chord.root, 5, "VI in Am should have root 5 (F)");
    this.assertEquals(chord.intervals, [4, 3], "VI in Am should be major");

    // Altered chords
    chord = Notation.romanToChord(0, \major, \bVII, 0);
    this.assertEquals(chord.root, 10, "bVII in C should have root 10 (Bb)");

    // Diminished chords
    chord = Notation.romanToChord(0, \major, \vii, 0);
    this.assertEquals(chord.root, 11, "vii in C should have root 11 (B)");
    this.assertEquals(chord.intervals, [3, 3], "vii in C should be diminished");
  }

  // Test symbol to chord conversion
  test_symbolToChord {
    var chord;

    // Basic major chords
    chord = Notation.symbolToChord(\C, 0);
    this.assertEquals(chord.root, 0, "C should have root 0");
    this.assertEquals(chord.intervals, [4, 3], "C should be major triad");

    chord = Notation.symbolToChord(\G, 0);
    this.assertEquals(chord.root, 7, "G should have root 7");

    // Basic minor chords
    chord = Notation.symbolToChord(\Am, 0);
    this.assertEquals(chord.root, 9, "Am should have root 9");
    this.assertEquals(chord.intervals, [3, 4], "Am should be minor triad");

    chord = Notation.symbolToChord(\Dm, 0);
    this.assertEquals(chord.root, 2, "Dm should have root 2");
    this.assertEquals(chord.intervals, [3, 4], "Dm should be minor triad");

    // Seventh chords
    chord = Notation.symbolToChord(\Cmaj7, 0);
    this.assertEquals(chord.root, 0, "Cmaj7 should have root 0");
    this.assertEquals(chord.intervals, [4, 3, 4], "Cmaj7 should be maj7");

    chord = Notation.symbolToChord(\G7, 0);
    this.assertEquals(chord.root, 7, "G7 should have root 7");
    this.assertEquals(chord.intervals, [4, 3, 3], "G7 should be dom7");

    chord = Notation.symbolToChord(\Dm7, 0);
    this.assertEquals(chord.root, 2, "Dm7 should have root 2");
    this.assertEquals(chord.intervals, [3, 4, 3], "Dm7 should be m7");

    // Flat/sharp roots
    chord = Notation.symbolToChord(\Bb, 0);
    this.assertEquals(chord.root, 10, "Bb should have root 10");

    chord = Notation.symbolToChord(\Ebmaj7, 0);
    this.assertEquals(chord.root, 3, "Ebmaj7 should have root 3");

    chord = Notation.symbolToChord(\Fs, 0);
    this.assertEquals(chord.root, 6, "F# should have root 6");

    // Special chords
    chord = Notation.symbolToChord(\Csus4, 0);
    this.assertEquals(chord.intervals, [5, 2], "Csus4 should be sus4");

    chord = Notation.symbolToChord(\Gsus2, 0);
    this.assertEquals(chord.intervals, [2, 5], "Gsus2 should be sus2");

    chord = Notation.symbolToChord(\Bdim, 0);
    this.assertEquals(chord.intervals, [3, 3], "Bdim should be diminished");

    chord = Notation.symbolToChord(\Caug, 0);
    this.assertEquals(chord.intervals, [4, 4], "Caug should be augmented");
  }

  // Integration test: Full progression parsing
  test_progressionParsing {
    var chord;

    // Test a ii-V-I progression in C major
    chord = Notation.romanToChord(0, \major, \ii, 0);
    this.assertEquals(chord.root, 2, "ii in C should be D");
    this.assertEquals(chord.intervals, [3, 4], "ii should be minor");

    chord = Notation.romanToChord(0, \major, \V, 0);
    this.assertEquals(chord.root, 7, "V in C should be G");
    this.assertEquals(chord.intervals, [4, 3], "V should be major");

    chord = Notation.romanToChord(0, \major, \I, 0);
    this.assertEquals(chord.root, 0, "I in C should be C");
    this.assertEquals(chord.intervals, [4, 3], "I should be major");
  }
}

// Usage:
// TestNotation.run;       // Verbose (default)
// TestNotation.run(false); // Quiet (only failures)
// TestNotation.runQuiet;  // Convenience method

