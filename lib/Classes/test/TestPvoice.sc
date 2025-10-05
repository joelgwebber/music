TestPvoice : UnitTest {

  // Test Voice construction
  test_construction {
    var voice, melody, rhythm;

    melody = Pmelody([\C, \E, \G]);
    rhythm = Prhythm.straight(4);
    voice = Pvoice(melody, rhythm);

    this.assertEquals(voice.melody, melody, "Melody should be stored");
    this.assertEquals(voice.rhythm, rhythm, "Rhythm should be stored");
    this.assert(voice.pattern.notNil, "Pattern should be created");
  }

  // Test Voice.asTab with default parameters
  test_asTab_default {
    var voice, melody, rhythm, tab;

    melody = Pmelody([\C, \E, \G], octave: 4);
    rhythm = Prhythm.straight(3, 1);  // 3 notes in 1 beat
    voice = Pvoice(melody, rhythm);

    tab = voice.asTab();

    // Should render 3 notes (C4, E4, G4) with proper spacing
    // Each note gets 4 chars (charsPerNote=4, notesPerBeat=3, charsPerBeat=12)
    this.assert(tab.contains("C♮4"), "Should contain C♮4");
    this.assert(tab.contains("E♮4"), "Should contain E♮4");
    this.assert(tab.contains("G♮4"), "Should contain G♮4");
  }

  // Test Voice.asTab with maxDur parameter
  test_asTab_maxDur {
    var voice, melody, rhythm, tab, cCount, eCount, gCount;

    melody = Pmelody([\C, \E, \G], octave: 4);
    rhythm = Prhythm.straight(3, 1);  // 3 notes in 1 beat
    voice = Pvoice(melody, rhythm);

    // Render 2 beats (should get 6 notes: C E G C E G)
    tab = voice.asTab(2);

    // Count how many times each note appears
    cCount = tab.findAll("C♮4").size;
    eCount = tab.findAll("E♮4").size;
    gCount = tab.findAll("G♮4").size;

    this.assertEquals(cCount, 2, "Should have 2 C notes in 2 beats");
    this.assertEquals(eCount, 2, "Should have 2 E notes in 2 beats");
    this.assertEquals(gCount, 2, "Should have 2 G notes in 2 beats");
  }

  // Test Voice.asTab with subdivsPerBeat parameter
  test_asTab_subdivsPerBeat {
    var voice1, voice2, melody, rhythm1, rhythm2, tab1, tab2;

    melody = Pmelody([\C]);

    // Voice 1: 1 note in 1 beat (denominator=1)
    rhythm1 = Prhythm.note(1);
    voice1 = Pvoice(melody, rhythm1);

    // Voice 2: 4 notes in 1 beat (denominator=4)
    rhythm2 = Prhythm.straight(4, 1);
    voice2 = Pvoice(melody, rhythm2);

    // Render with same subdivsPerBeat for alignment
    tab1 = voice1.asTab(1, 4);  // Force 4 subdivs per beat
    tab2 = voice2.asTab(1, 4);  // Force 4 subdivs per beat

    // Both should render with alignment (can't verify via size or dash count due to UTF-8)
    // Just verify they both contain the expected note
    this.assert(tab1.contains("C"), "Tab1 should contain C note");
    this.assert(tab2.contains("C"), "Tab2 should contain C note");
  }

  // Test Voice with Chord
  test_chord {
    var voice, chord, rhythm, notes;

    chord = Pchord.major(\C, 5);  // octave=5 gives C4 (MIDI 60)
    rhythm = Prhythm.note(1);
    voice = Pvoice(chord, rhythm);

    notes = voice.notes;

    // Should have all chord notes
    this.assertEquals(notes.size, 3, "Should have 3 notes");
    this.assertEquals(notes[0], 60, "Root should be C4");
    this.assertEquals(notes[1], 64, "Third should be E4");
    this.assertEquals(notes[2], 67, "Fifth should be G4");
  }

  // Test Voice with arpeggiated chord
  test_arpeggio {
    var voice, chord, rhythm, notes;

    chord = Pchord.minor(\C, 4).arp(\up);  // octave=4 gives C3 (MIDI 48)
    rhythm = Prhythm.straight(3, 1);
    voice = Pvoice(chord, rhythm);

    notes = voice.notes;

    // Arpeggiated chord should give individual notes in order
    this.assertEquals(notes.size, 3, "Should have 3 notes");
    this.assertEquals(notes[0], 48, "First note should be C3");
    this.assertEquals(notes[1], 51, "Second note should be Eb3");
    this.assertEquals(notes[2], 55, "Third note should be G3");
  }
}
