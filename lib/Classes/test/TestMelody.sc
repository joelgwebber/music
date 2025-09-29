TestMelody : UnitTest {

  // Test basic melody construction
  test_construction {
    var melody;

    melody = Melody([0, 2, 4, 5, 7, 9, 11, 12]);
    this.assertEquals(melody.notes.size, 8, "Should have 8 notes");
    this.assertEquals(melody.notes[0], 0, "First note should be 0");
    this.assertEquals(melody.notes[7], 12, "Last note should be 12");
  }

  // Test concatenation
  test_concatenation {
    var mel1, mel2, combined;

    mel1 = Melody([0, 2, 4]);
    mel2 = Melody([5, 7, 9]);
    combined = mel1 ++ mel2;

    this.assertEquals(combined.notes.size, 6, "Combined should have 6 notes");
    this.assertEquals(combined.notes[0], 0, "First note should be 0");
    this.assertEquals(combined.notes[3], 5, "Fourth note should be 5");
    this.assertEquals(combined.notes[5], 9, "Last note should be 9");
  }

  // Test octave transposition
  test_octave {
    var melody, transposed;

    melody = Melody([0, 4, 7]);
    transposed = melody.octave(1);

    this.assertEquals(transposed.notes.size, 3, "Should preserve note count");
    this.assertEquals(transposed.notes[0], 12, "First note should be up an octave");
    this.assertEquals(transposed.notes[1], 16, "Second note should be up an octave");
    this.assertEquals(transposed.notes[2], 19, "Third note should be up an octave");

    // Down an octave
    transposed = melody.octave(-1);
    this.assertEquals(transposed.notes[0], -12, "First note should be down an octave");
  }

  // Test frequency generation
  test_freqs {
    var melody, freqs;

    melody = Melody([0, 12, 24]);  // C at different octaves
    freqs = melody.freqs;

    this.assertEquals(freqs.size, 3, "Should have 3 frequencies");
    this.assert(freqs[1] > freqs[0], "Higher notes should have higher frequencies");
    this.assert(freqs[2] > freqs[1], "Higher notes should have higher frequencies");
  }

  // Test size
  test_size {
    var melody;

    melody = Melody([0, 2, 4, 5, 7]);
    this.assertEquals(melody.size, 5, "Size should be 5");

    melody = Melody([]);
    this.assertEquals(melody.size, 0, "Empty melody should have size 0");
  }

  // Test pitchClass
  test_pitchClass {
    var melody;

    melody = Melody([0, 12, 24, -12]);
    this.assertEquals(melody.pitchClass(0), 0, "0 mod 12 should be 0");
    this.assertEquals(melody.pitchClass(12), 0, "12 mod 12 should be 0");
    this.assertEquals(melody.pitchClass(13), 1, "13 mod 12 should be 1");
    this.assertEquals(melody.pitchClass(-1), 11, "Negative should wrap correctly");
  }

  // Test construction from chord arpeggios
  test_fromChordArp {
    var chord, melody;

    chord = Chord.major(0, 0);
    melody = chord.arp(\up);

    this.assertEquals(melody.class, Melody, "arp should return Melody");
    this.assertEquals(melody.notes.size, 3, "Should have 3 notes for triad");
    this.assertEquals(melody.notes[0], 0, "First note should be root");

    // Test different patterns
    melody = chord.arp(\down);
    this.assertEquals(melody.notes[0], 7, "Down should start with highest note");

    melody = chord.arp(\upDown);
    this.assert(melody.notes.size > 3, "upDown should have more than 3 notes");
  }

  // Test construction from progression roots
  test_fromProgRoots {
    var prog, melody;

    prog = Prog.inKey(\C, [\I, \IV, \V, \I]);
    melody = prog.roots;

    this.assertEquals(melody.class, Melody, "roots should return Melody");
    this.assertEquals(melody.notes.size, 4, "Should have 4 notes");
    this.assertEquals(melody.notes[0], 0, "First root should be C");
    this.assertEquals(melody.notes[1], 5, "Second root should be F");
    this.assertEquals(melody.notes[2], 7, "Third root should be G");
  }

  // Test construction from progression bassLine
  test_fromProgBassLine {
    var prog, melody;

    prog = Prog.inKey(\C, [\I, \IV, \V]);
    melody = prog.bassLine;

    this.assertEquals(melody.class, Melody, "bassLine should return Melody");
    this.assertEquals(melody.notes.size, 3, "Should have 3 notes");
  }

  // Test construction from progression topVoice
  test_fromProgTopVoice {
    var prog, melody;

    prog = Prog.inKey(\C, [\I, \IV, \V]);
    melody = prog.topVoice;

    this.assertEquals(melody.class, Melody, "topVoice should return Melody");
    this.assertEquals(melody.notes.size, 3, "Should have 3 notes");
  }
}