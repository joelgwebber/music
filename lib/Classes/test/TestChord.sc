TestChord : UnitTest {

  // Test basic chord construction
  test_construction {
    var chord;

    // Numeric construction
    chord = Chord(0, [4, 3], 0);
    this.assertEquals(chord.root, 0, "Root should be 0");
    this.assertEquals(chord.intervals, [4, 3], "Intervals should be [4, 3]");
    this.assertEquals(chord.octave, 0, "Octave should be 0");

    // Convenience constructors with numeric roots
    chord = Chord.major(0, 0);
    this.assertEquals(chord.intervals, [4, 3], "Major should be [4, 3]");

    chord = Chord.minor(9, 0);
    this.assertEquals(chord.root, 9, "Minor root should be 9");
    this.assertEquals(chord.intervals, [3, 4], "Minor should be [3, 4]");

    chord = Chord.dom7(7, 0);
    this.assertEquals(chord.intervals, [4, 3, 3], "Dom7 should be [4, 3, 3]");

    chord = Chord.maj7(0, 0);
    this.assertEquals(chord.intervals, [4, 3, 4], "Maj7 should be [4, 3, 4]");

    chord = Chord.min7(2, 0);
    this.assertEquals(chord.intervals, [3, 4, 3], "Min7 should be [3, 4, 3]");

    chord = Chord.dim(11, 0);
    this.assertEquals(chord.intervals, [3, 3], "Dim should be [3, 3]");

    chord = Chord.aug(4, 0);
    this.assertEquals(chord.intervals, [4, 4], "Aug should be [4, 4]");

    chord = Chord.sus4(7, 0);
    this.assertEquals(chord.intervals, [5, 2], "Sus4 should be [5, 2]");

    chord = Chord.sus2(2, 0);
    this.assertEquals(chord.intervals, [2, 5], "Sus2 should be [2, 5]");
  }

  // Test symbolic note construction
  test_symbolicConstruction {
    var chord;

    // Test with note symbols
    chord = Chord.major(\C, 0);
    this.assertEquals(chord.root, 0, "C major root should be 0");

    chord = Chord.minor(\A, 0);
    this.assertEquals(chord.root, 9, "A minor root should be 9");

    chord = Chord.major(\G, 0);
    this.assertEquals(chord.root, 7, "G major root should be 7");

    // Test with accidentals
    chord = Chord.minor(\Bb, 0);
    this.assertEquals(chord.root, 10, "Bb minor root should be 10");

    chord = Chord.major(\Fs, 0);
    this.assertEquals(chord.root, 6, "F# major root should be 6");

  }

  // Test note generation
  test_notes {
    var chord, notes;

    // C major triad in octave 0
    chord = Chord.major(0, 0);
    notes = chord.notes;
    this.assertEquals(notes.size, 3, "Triad should have 3 notes");
    this.assertEquals(notes[0], 0, "First note should be C (0)");
    this.assertEquals(notes[1], 4, "Second note should be E (4)");
    this.assertEquals(notes[2], 7, "Third note should be G (7)");

    // A minor 7 in octave -1
    chord = Chord.min7(9, -1);
    notes = chord.notes;
    this.assertEquals(notes.size, 4, "Seventh chord should have 4 notes");
    this.assertEquals(notes[0], -3, "First note should be A in octave -1");
  }

  // Test octave transposition
  test_octave {
    var chord, transposed;

    chord = Chord.major(0, 0);
    transposed = chord.oct(1);
    this.assertEquals(transposed.octave, 1, "Octave should be 1");
    this.assertEquals(transposed.root, 0, "Root should be unchanged");

    transposed = chord.oct(-2);
    this.assertEquals(transposed.octave, -2, "Octave should be -2");
  }

  // Test inversion
  test_inversion {
    var chord, inverted, notes;

    chord = Chord.major(0, 0);
    inverted = chord.invert(1);
    notes = inverted.notes;
    this.assert(notes[0] > chord.notes[0], "First inversion should move bass up");

    inverted = chord.invert(2);
    this.assertEquals(inverted.inversion, 2, "Second inversion should have inversion=2");
  }

  // Test transposition
  test_transpose {
    var chord, transposed;

    chord = Chord.major(0, 0);
    transposed = chord.transpose(7);
    this.assertEquals(transposed.root, 7, "Root should transpose by 7 semitones");
    this.assertEquals(transposed.intervals, [4, 3], "Intervals should be unchanged");

    transposed = chord.transpose(-3);
    this.assertEquals(transposed.root, -3, "Root can be negative");
  }

  // Test quality changes
  test_qualityChanges {
    var chord, modified;

    // toMajor
    chord = Chord.minor(0, 0);
    modified = chord.toMajor;
    this.assertEquals(modified.intervals.asArray, [4, 3], "toMajor should make [4, 3]");

    // toMinor
    chord = Chord.major(0, 0);
    modified = chord.toMinor;
    this.assertEquals(modified.intervals.asArray, [3, 4], "toMinor should make [3, 4]");

    // add7
    chord = Chord.major(0, 0);
    modified = chord.add7(\dom);
    this.assertEquals(modified.intervals, [4, 3, 3], "add7(dom) should add 3");

    modified = chord.add7(\maj);
    this.assertEquals(modified.intervals, [4, 3, 4], "add7(maj) should add 4");
  }

  // Test neo-Riemannian transforms
  test_neoRiemannian {
    var chord, transformed;

    // Parallel (P): C major -> C minor
    chord = Chord.major(0, 0);
    transformed = chord.p;
    this.assertEquals(transformed.root, 0, "P should keep same root");
    this.assertEquals(transformed.intervals.asArray, [3, 4], "P should swap to minor");

    // Relative (R): C major -> A minor
    chord = Chord.major(0, 0);
    transformed = chord.r;
    this.assertEquals(transformed.root, 9, "R from C major should give A minor");
    this.assertEquals(transformed.intervals.asArray, [3, 4], "R should give minor");

    // Leading-tone (L): C major -> E minor
    chord = Chord.major(0, 0);
    transformed = chord.l;
    this.assertEquals(transformed.root, 4, "L from C major should give E minor");
    this.assertEquals(transformed.intervals.asArray, [3, 4], "L should give minor");

    // Slide (S): C major -> C# minor
    chord = Chord.major(0, 0);
    transformed = chord.s;
    this.assertEquals(transformed.root, 1, "S from C major should raise root by 1");
    this.assertEquals(transformed.intervals.asArray, [3, 4], "S should give minor");

    // Nebenverwandt (N): C major -> Eb major
    chord = Chord.major(0, 0);
    transformed = chord.n;
    this.assertEquals(transformed.root, 3, "N from C major should give Eb major");
    this.assertEquals(transformed.intervals.asArray, [4, 3], "N should preserve quality");

    // Hexatonic pole (H): C major -> Ab minor
    chord = Chord.major(0, 0);
    transformed = chord.h;
    this.assertEquals(transformed.root, 8, "H from C major should give Ab minor");
    this.assertEquals(transformed.intervals.asArray, [3, 4], "H should give minor");
  }

  // Test neoRiemannian string operations
  test_neoRiemannianString {
    var chord, transformed, stringVersion;

    chord = Chord.major(0, 0);

    // PLR transform
    transformed = chord.neoRiemannian("PLR");
    this.assert(transformed.root.isNumber, "PLR should produce valid chord");

    // Test chaining
    transformed = chord.p.l.r;
    stringVersion = chord.neoRiemannian("PLR");
    this.assertEquals(transformed.root, stringVersion.root, "Chaining should match string");
    this.assertEquals(transformed.intervals, stringVersion.intervals, "Intervals should match");
  }

  // Test union
  test_union {
    var c, em, combined;

    c = Chord.major(0, 0);      // C-E-G
    em = Chord.minor(4, 0);     // E-G-B
    combined = c.union(em);
    this.assertEquals(combined.notes.size, 4, "Union should have 4 unique notes (C-E-G-B)");
  }

  // Test inKey construction
  test_inKey {
    var chord;

    chord = Chord.inKey(\C, \I);
    this.assertEquals(chord.root, 0, "I in C should be C");
    this.assertEquals(chord.intervals, [4, 3], "I should be major");

    chord = Chord.inKey(\C, \vi);
    this.assertEquals(chord.root, 9, "vi in C should be A");
    this.assertEquals(chord.intervals, [3, 4], "vi should be minor");

    chord = Chord.inKey(\G, \V7);
    this.assertEquals(chord.root, 2, "V in G should be D");
    this.assertEquals(chord.intervals, [4, 3, 3], "V7 should be dom7");
  }

  // Test fromSymbol construction
  test_fromSymbol {
    var chord;

    chord = Chord.fromSymbol(\Cmaj7);
    this.assertEquals(chord.root, 0, "Cmaj7 should have root C");
    this.assertEquals(chord.intervals, [4, 3, 4], "Cmaj7 should be maj7");

    chord = Chord.fromSymbol(\Dm7);
    this.assertEquals(chord.root, 2, "Dm7 should have root D");
    this.assertEquals(chord.intervals, [3, 4, 3], "Dm7 should be m7");

    chord = Chord.fromSymbol(\G7);
    this.assertEquals(chord.root, 7, "G7 should have root G");
    this.assertEquals(chord.intervals, [4, 3, 3], "G7 should be dom7");
  }

  // Test arpeggio patterns
  test_arp {
    var chord, melody;

    chord = Chord.major(0, 0);

    melody = chord.arp(\up);
    this.assertEquals(melody.notes.size, 3, "Up arp should have 3 notes");
    this.assertEquals(melody.notes[0], 0, "First note should be root");

    melody = chord.arp(\down);
    this.assertEquals(melody.notes.size, 3, "Down arp should have 3 notes");
    this.assertEquals(melody.notes[0], 7, "First note should be highest");

    melody = chord.arp(\upDown);
    this.assert(melody.notes.size > 3, "UpDown should have more notes");
  }
}
