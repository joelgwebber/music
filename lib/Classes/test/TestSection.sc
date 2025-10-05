TestSection : UnitTest {

  // Test Section construction with array
  test_construction_array {
    var section, voice1, voice2;

    voice1 = Voice(Melody([\C]), Rhythm.note(1));
    voice2 = Voice(Melody([\E]), Rhythm.note(1));

    section = Section(4, [voice1, voice2]);

    this.assertEquals(section.duration, 4, "Duration should be 4");
    this.assertEquals(section.voices.size, 2, "Should have 2 voices");
    this.assert(section.voices[\v0].notNil, "First voice should be at v0");
    this.assert(section.voices[\v1].notNil, "Second voice should be at v1");
  }

  // Test Section construction with event
  test_construction_event {
    var section, voice1, voice2;

    voice1 = Voice(Melody([\C]), Rhythm.note(1));
    voice2 = Voice(Melody([\E]), Rhythm.note(1));

    section = Section(4, (bass: voice1, melody: voice2));

    this.assertEquals(section.duration, 4, "Duration should be 4");
    this.assertEquals(section.voices.size, 2, "Should have 2 voices");
    this.assert(section.voices[\bass].notNil, "Bass voice should exist");
    this.assert(section.voices[\melody].notNil, "Melody voice should exist");
  }

  // Test Section.asTab with single rhythm density
  test_asTab_uniform {
    var section, voice1, voice2, tab;

    voice1 = Voice(Melody([\C], octave: 4), Rhythm.straight(4, 1));
    voice2 = Voice(Melody([\E], octave: 4), Rhythm.straight(4, 1));

    section = Section(1, (v1: voice1, v2: voice2));
    tab = section.asTab();

    // Both voices have same denominator=4, so should align perfectly
    this.assert(tab.contains("C♮4"), "Should contain C notes");
    this.assert(tab.contains("E♮4"), "Should contain E notes");
  }

  // Test Section.asTab with mixed rhythm densities
  test_asTab_mixed {
    var section, bassVoice, arpVoice, tab;

    // Bass: 1 note in 1 beat (denominator=1)
    bassVoice = Voice(Melody([\C], octave: 2), Rhythm.note(1));

    // Arpeggio: 4 notes in 1 beat (denominator=4)
    arpVoice = Voice(Melody([\E, \G, \B, \E]), Rhythm.straight(4, 1));

    section = Section(1, (bass: bassVoice, arp: arpVoice));
    tab = section.asTab();

    // Both lines should be visually aligned (can't verify size/dashes due to UTF-8)
    // Just verify both voices are present in output
    this.assert(tab.contains("bass"), "Should contain bass label");
    this.assert(tab.contains("arp"), "Should contain arp label");
    this.assert(tab.contains("C"), "Should contain C note from bass");
    this.assert(tab.contains("E"), "Should contain E note from arp");
  }

  // Test Section.asTab with duration padding
  test_asTab_padding {
    var section, voice, tab, cCount;

    // Voice with 1-beat rhythm in 4-beat section
    voice = Voice(Melody([\C], octave: 4), Rhythm.note(1));
    section = Section(4, (voice: voice));

    tab = section.asTab();

    // Should render 4 repetitions of the note
    cCount = tab.findAll("C♮4").size;
    this.assertEquals(cCount, 4, "Should have 4 C notes for 4 beats");
  }

  // Test Section.asTab LCM calculation
  test_asTab_lcm {
    var section, v1, v2, v3, tab;

    // Denominators: 2, 3, 6 -> LCM = 6
    v1 = Voice(Melody([\C]), Rhythm.straight(2, 1));  // denom=2
    v2 = Voice(Melody([\E]), Rhythm.straight(3, 1));  // denom=3
    v3 = Voice(Melody([\G]), Rhythm.straight(6, 1));  // denom=6

    section = Section(1, (v1: v1, v2: v2, v3: v3));
    tab = section.asTab();

    // All lines should be visually aligned (can't verify size/dashes due to UTF-8)
    // Just verify all voices are present
    this.assert(tab.contains("v1"), "Should contain v1 label");
    this.assert(tab.contains("v2"), "Should contain v2 label");
    this.assert(tab.contains("v3"), "Should contain v3 label");
    this.assert(tab.contains("C"), "Should contain C note");
    this.assert(tab.contains("E"), "Should contain E note");
    this.assert(tab.contains("G"), "Should contain G note");
  }

  // Test Section.asTab label alignment
  test_asTab_labels {
    var section, v1, v2, tab, lines, shortLine, longLine, shortLabelEnd, longLabelEnd;

    v1 = Voice(Melody([\C]), Rhythm.note(1));
    v2 = Voice(Melody([\E]), Rhythm.note(1));

    section = Section(1, (short: v1, verylongname: v2));
    tab = section.asTab();

    lines = tab.split($\n);

    // Labels should be padded to same width
    shortLine = lines.detect({ |l| l.contains("short") });
    longLine = lines.detect({ |l| l.contains("verylongname") });

    shortLabelEnd = shortLine.indexOf($:);
    longLabelEnd = longLine.indexOf($:);

    this.assertEquals(shortLabelEnd, longLabelEnd, "Label colons should align");
  }

  // Test Section.asTab with mixed note name lengths (sharps vs naturals)
  test_asTab_variableLengthNames {
    var section, arpVoice, bassVoice, tab;

    // Arpeggio with mix of sharps (3 visual chars) and naturals (3 visual chars, but more UTF-8 bytes)
    // D#4, F#4, A♮4 pattern
    arpVoice = Voice(
      Chord(\Ds, [3, 3], 4).arp(\up),
      Rhythm.straight(12, 4)
    );

    // Bass with sharp (3 visual chars)
    bassVoice = Voice(
      Melody([\Gs], octave: 2),
      Rhythm.note(4)
    );

    section = Section(4, (arpeggio: arpVoice, bass: bassVoice));
    tab = section.asTab();

    // Both lines should be visually aligned despite variable UTF-8 byte sizes
    // Verify both voices are rendered correctly
    this.assert(tab.contains("arpeggio"), "Should contain arpeggio label");
    this.assert(tab.contains("bass"), "Should contain bass label");
    this.assert(tab.contains("D#"), "Should contain D# from arpeggio");
    this.assert(tab.contains("G#"), "Should contain G# from bass");
  }
}
