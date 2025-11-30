TestPprog : UnitTest {

  // Test basic progression construction
  test_construction {
    var chord1, chord2, prog;

    chord1 = Pchord.major(0, 0);
    chord2 = Pchord.minor(9, 0);
    prog = Pprog([chord1, chord2]);

    this.assertEquals(prog.size, 2, "Prog should have 2 chords");
    this.assertEquals(prog.chords[0].root, 0, "First chord root should be 0");
    this.assertEquals(prog.chords[1].root, 9, "Second chord root should be 9");
  }

  // Test inKey construction
  test_inKey {
    var prog;

    // I-IV-V-I in C major
    prog = Pprog.inKey(\C, [\I, \IV, \V, \I]);
    this.assertEquals(prog.size, 4, "Should have 4 chords");
    this.assertEquals(prog.chords[0].root, 0, "I should be C");
    this.assertEquals(prog.chords[1].root, 5, "IV should be F");
    this.assertEquals(prog.chords[2].root, 7, "V should be G");
    this.assertEquals(prog.chords[3].root, 0, "I should be C");

    // vi-IV-I-V in C major (pop progression)
    prog = Pprog.inKey(\C, [\vi, \IV, \I, \V]);
    this.assertEquals(prog.chords[0].root, 9, "vi should be A");
    this.assertEquals(prog.chords[0].intervals, [3, 4], "vi should be minor");
    this.assertEquals(prog.chords[1].root, 5, "IV should be F");
    this.assertEquals(prog.chords[1].intervals, [4, 3], "IV should be major");

    // i-iv-V in A minor
    prog = Pprog.inKey(\Am, [\i, \iv, \V]);
    this.assertEquals(prog.chords[0].root, 9, "i in Am should be A");
    this.assertEquals(prog.chords[0].intervals, [3, 4], "i should be minor");
    this.assertEquals(prog.chords[1].root, 2, "iv in Am should be D");
    this.assertEquals(prog.chords[1].intervals, [3, 4], "iv should be minor");
    this.assertEquals(prog.chords[2].root, 4, "V in Am should be E");
    this.assertEquals(prog.chords[2].intervals, [4, 3], "V should be major");
  }

  // Test ii-V-I progression
  test_ii_V_I {
    var prog;

    // Major ii-V-I
    prog = Pprog.ii_V_I(0, \major);
    this.assertEquals(prog.size, 3, "Should have 3 chords");
    this.assertEquals(prog.chords[0].root, 2, "ii should be D");
    this.assertEquals(prog.chords[0].intervals, [3, 4], "ii should be minor");
    this.assertEquals(prog.chords[1].root, 7, "V should be G");
    this.assertEquals(prog.chords[1].intervals, [4, 3], "V should be major");
    this.assertEquals(prog.chords[2].root, 0, "I should be C");

    // Minor ii-V-i
    prog = Pprog.ii_V_I(9, \minor);
    this.assertEquals(prog.chords[0].root, 11, "ii in Am should be B");
    this.assertEquals(prog.chords[0].intervals, [3, 3], "ii should be diminished");
    this.assertEquals(prog.chords[2].root, 9, "i should be A");
    this.assertEquals(prog.chords[2].intervals, [3, 4], "i should be minor");

    // With symbolic key
    prog = Pprog.ii_V_I(\G, \major);
    this.assertEquals(prog.chords[2].root, 7, "I in G should be G");
  }

  // Test circle of fifths
  test_circleOfFifths {
    var prog;

    prog = Pprog.circleOfFifths(0, 4, \major);
    this.assertEquals(prog.size, 4, "Should have 4 chords");
    this.assertEquals(prog.chords[0].root, 0, "Should start at C");
    this.assertEquals(prog.chords[1].root, 7, "Next should be G (up a fifth)");
    this.assertEquals(prog.chords[2].root, 2, "Next should be D");
    this.assertEquals(prog.chords[3].root, 9, "Next should be A");

    // With dominant 7
    prog = Pprog.circleOfFifths(0, 3, \dominant7);
    this.assertEquals(prog.chords[0].intervals, [4, 3, 3], "Should be dom7");

    // With symbolic start
    prog = Pprog.circleOfFifths(\F, 3, \major);
    this.assertEquals(prog.chords[0].root, 5, "Should start at F");
  }

  // Test neo-Riemannian progression
  test_neoRiemannian {
    var start, prog;

    start = Pchord.major(0, 0);
    prog = Pprog.neoRiemannian(start, "PLR");

    this.assertEquals(prog.size, 4, "PLR should create 4 chords (start + 3 transforms)");
    this.assertEquals(prog.chords[0].root, 0, "Should start at C major");
    this.assert(prog.chords[1].intervals == [3, 4], "P should give minor");
  }

  // Test transposition
  test_transpose {
    var prog, transposed;

    prog = Pprog.inKey(\C, [\I, \IV, \V]);
    transposed = prog.transpose(7);

    this.assertEquals(transposed.chords[0].root, 7, "I should transpose to G");
    this.assertEquals(transposed.chords[1].root, 12, "IV should transpose to C (next octave)");
  }

  // Test octave
  test_octave {
    var prog, moved;

    prog = Pprog.inKey(\C, [\I, \IV, \V]);
    moved = prog.octave(1);

    this.assertEquals(moved.chords[0].octave, 1, "Octave should be 1");
    this.assertEquals(moved.chords[1].octave, 1, "All chords should move");
  }

  // Test invert
  test_invert {
    var prog, inverted;

    prog = Pprog.inKey(\C, [\I, \IV, \V]);
    inverted = prog.invert(1);

    this.assertEquals(inverted.chords[0].inversion, 1, "First inversion");
    this.assertEquals(inverted.chords[1].inversion, 1, "All chords inverted");
  }

  // Test reverse
  test_reverse {
    var prog, reversed;

    prog = Pprog.inKey(\C, [\I, \IV, \V]);
    reversed = prog.reverse;

    this.assertEquals(reversed.chords[0].root, 7, "First should be V (G)");
    this.assertEquals(reversed.chords[2].root, 0, "Last should be I (C)");
  }

  // Test concatenation
  test_concatenation {
    var prog1, prog2, combined;

    prog1 = Pprog.inKey(\C, [\I, \IV]);
    prog2 = Pprog.inKey(\C, [\V, \I]);
    combined = prog1 ++ prog2;

    this.assertEquals(combined.size, 4, "Combined should have 4 chords");
    this.assertEquals(combined.chords[0].root, 0, "First should be I");
    this.assertEquals(combined.chords[2].root, 7, "Third should be V");
  }

  // Test arpeggio
  test_arp {
    var prog, melody;

    prog = Pprog.inKey(\C, [\I, \V]);

    // Single pattern for all chords
    melody = prog.arp(\up);
    this.assert(melody.notes.size >= 6, "Should have notes from both chords");

    melody = prog.arp(\down);
    this.assert(melody.notes.size >= 6, "Down should have notes");

    // Array of patterns
    melody = prog.arp([\up, \down]);
    this.assert(melody.notes.size >= 6, "Alternating patterns should work");

    // Custom index pattern
    melody = prog.arp([0, 2, 1]);
    this.assert(melody.notes.size >= 6, "Index pattern should work");
  }

  // Test roots
  test_roots {
    var prog, roots;

    prog = Pprog.inKey(\C, [\I, \IV, \V]);
    roots = prog.roots;

    this.assertEquals(roots.notes.size, 3, "Should have 3 roots");
    this.assertEquals(roots.notes[0], 0, "First root should be C");
    this.assertEquals(roots.notes[1], 5, "Second root should be F");
    this.assertEquals(roots.notes[2], 7, "Third root should be G");
  }

  // Test bassLine
  test_bassLine {
    var prog, bass, chord;

    // Test with inversions
    chord = Pchord.major(0, 0).invert(1);  // C major, first inversion (E in bass)
    prog = Pprog([chord]);
    bass = prog.bassLine;

    this.assertEquals(bass.notes.size, 1, "Should have 1 bass note");
    this.assert(bass.notes[0] < 12, "Bass note should be lowest note");
  }

  // Test topVoice
  test_topVoice {
    var prog, top;

    prog = Pprog.inKey(\C, [\I, \IV, \V]);
    top = prog.topVoice;

    this.assertEquals(top.notes.size, 3, "Should have 3 top notes");
    this.assert(top.notes[0] >= prog.chords[0].notes.minItem, "Top should be >= lowest");
  }
}
