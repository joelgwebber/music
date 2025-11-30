(
// Moonlight Sonata - Generated from MIDI analysis
Server.local.boot;
"lib/piano.scd".load;
)

(
~clock = TempoClock(60/60); // Adjust tempo as needed

~left  = (instrument: \piano, amp: 0.4, sustain: 4);
~right = (instrument: \piano, amp: 0.3, sustain: 2);

// Rhythm patterns extracted from MIDI
~piano_right_secondRhythm = Prhythm.straight(12, 4);
~piano_right_firstRhythm = Prhythm.straight(4, 4);
~piano_leftRhythm = Prhythm.note(4);

// Harmonic progression: i - ♭vii - ♭vi - iv - v - v - i - vii - i - iv - ♭vii - ♭vii - ♭iii - ♭iii - ♭ii - vii - ♭vii - vi - ♭vii - iv - ♭vii - ♭iii - ♭v - ♭iii - ♭vii - ♭iii - ♭v - ♭iii - ♭vii - v - iii - iv - ♭vii - vii - iv - iii - iv - ii - i - vii - vii - i - iv - ♭v - v - v - v - v - v - v - v - v - v - v - v - ♭vi - iv - v - i - vii - i - iv - ♭vii - ♭vii - ♭iii - ii - ♭iii - ii - i - vii - i - iv - v - i - iv - ♭vi - iv - i - iv - ♭vi - iv - i - iv - ii - ♭iii - i - ii - vii - i - ♭vi - v - iv - v - v - i - i
~phrases = [
  // Phrase 1 (M1.0-2.0): C♯-C♯, B-B
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\C1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 2 (M3.0-4.0): A-A, F♯-F♯, G♯-G♯, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\A3, \C4, \E4, \A3, \C4, \E4, \A3, \D4, \F4, \A3, \D4, \F4, \G3, \C4, \F4, \G3, \C4, \E4, \G3, \C4, \D4, \F3, \C4, \D4]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\A1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 3 (M5.0-6.0): C♯-G♯-C♯, C-G♯-C
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\E3, \G3, \C4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \D4, \F4, \G3, \D4, \F4, \G3, \D4, \F4, \G3, \D4, \F4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\G4, \G4, \G4, \G4, \G4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pchord(\C, [7, 5], 2), ~piano_leftRhythm, ~left),
  )),

  // Phrase 4 (M7.0-8.0): C♯-C♯, F♯-F♯, B-B, B-B
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\G3, \C4, \E4, \G3, \C4, \E4, \A3, \C4, \F4, \A3, \C4, \F4, \G3, \B3, \E4, \G3, \B3, \E4, \A3, \B3, \D4, \A3, \B3, \D4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\G4, \A4, \G4, \F4, \B4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\C1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 5 (M9.0-10.0): E-E, E-E
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\G3, \B3, \E4, \G3, \B3, \E4, \G3, \B3, \E4, \G3, \B3, \E4, \G3, \B3, \E4, \G3, \B3, \E4, \G3, \B3, \E4, \G3, \B3, \E4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\E4, \G4, \G4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\E1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 6 (M11.0-12.0): D-D, C-C, B-B, A♯-A♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\G3, \B3, \F4, \G3, \B3, \F4, \G3, \B3, \F4, \G3, \B3, \F4, \G3, \C4, \E4, \G3, \B3, \E4, \G3, \C4, \E4, \F3, \C4, \E4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\G4, \G4, \G4, \G4, \F4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\D1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 7 (M13.0-14.0): B-B, F♯-F♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\F3, \B3, \D4, \F3, \B3, \D4, \G3, \B3, \C4, \E3, \B3, \C4, \F3, \B3, \D4, \F3, \B3, \D4, \F3, \A3, \C4, \F3, \A3, \C4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\F4, \G4, \E4, \F4, \F4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\B1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 8 (M15.0-16.0): B-B, E-E, G-G, E-E
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\B3, \D4, \F4, \B3, \D4, \F4, \B3, \D4, \F4, \B3, \D4, \F4, \B3, \E4, \G4, \B3, \E4, \G4, \B3, \E4, \G4, \B3, \E4, \G4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\B4, \C5, \A4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\B1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 9 (M17.0-18.0): B-B, E-E, G-G, E-E
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\B3, \D4, \F4, \B3, \D4, \F4, \B3, \D4, \F4, \B3, \D4, \F4, \B3, \E4, \G4, \B3, \E4, \G4, \B3, \E4, \G4, \B3, \E4, \G4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\B4, \B4, \C5, \A4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\B1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 10 (M19.0-20.0): B-B, G♯-G♯, F-F, F♯-F♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\B3, \D4, \F4, \B3, \D4, \F4, \B3, \D4, \F4, \B3, \D4, \F4, \B3, \C4, \G4, \B3, \C4, \G4, \A3, \C4, \F4, \A3, \C4, \F4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\B4, \B4, \B4, \A4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\B1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 11 (M21.0-21.0): B-B, C-C
  Pphrase(4.0, (
    arpeggio: Pvoice(Pmelody([\G3, \B3, \D4, \G3, \B3, \D4, \F3, \A3, \D4, \F3, \A3, \D4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\G4, \F4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\B1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 12 (M23.0-24.0): F♯-C♯-F♯, F-C♯-F
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\F3, \A3, \C4, \A3, \C4, \F4, \C4, \F4, \A4, \C4, \F4, \A4, \C4, \G4, \B4, \C4, \G4, \B4, \C4, \G4, \B4, \C4, \G4, \B4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\C5, \C5, \C5, \C5, \C5]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pchord(\F, [7, 5], 2), ~piano_leftRhythm, ~left),
  )),

  // Phrase 13 (M25.0-26.0): F♯-F♯, D♯-D♯, C♯-C♯, C-G♯-C, C-G♯-C
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\C4, \F4, \A4, \C4, \F4, \A4, \C4, \F4, \A4, \C4, \F4, \A4, \D4, \F4, \G4, \D4, \F4, \G4, \D4, \F4, \G4, \D4, \F4, \G4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\C5, \C5, \C5, \D5, \D5]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\F1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 14 (M27.0-28.0): C♯-G♯-C♯, F♯-F♯, G-G, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\E4, \G4, \C5, \E4, \G4, \C5, \D4, \F4, \A4, \C4, \E4, \A4, \C5, \C4, \D4, \C4, \G4, \D4, \C4, \A4, \D4, \C4, \F4, \D4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\E5, \D5, \C5]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pchord(\C, [7, 5], 2), ~piano_leftRhythm, ~left),
  )),

  // Phrase 15 (M29.0-30.0): G♯-G♯, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\C4, \D4, \C4, \G3, \D4, \C4, \A3, \D4, \C4, \F3, \D4, \E3, \E4, \G4, \E4, \C5, \G4, \E4, \E5, \G4, \E4, \C5, \G4]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\G1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 16 (M31.0-32.0): G♯-G♯, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\E3, \G3, \E3, \C4, \G3, \E3, \E4, \G3, \E3, \C4, \G3, \D3, \A3, \F3, \C4, \A3, \D4, \C4, \F4, \D4, \A4, \F4, \C5]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\G1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 17 (M33.0-34.0): G♯-G♯, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\E3, \C4, \G3, \E4, \C4, \G4, \E4, \C5, \G4, \E5, \C5, \G4, \C4, \G4, \E4, \A4, \G4, \C5, \A4, \E5, \C5, \G5, \E5, \A5]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\G1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 18 (M35.0-35.0): G♯-G♯
  Pphrase(12.0, (
    arpeggio: Pvoice(Pmelody([\F4, \C5, \A4, \D5, \C5, \F5, \D5, \A5, \F5, \C6, \A5, \D6, \C6, \F5, \A5, \D5, \F5, \C5, \D5, \A4, \C5, \F4, \A4, \D4, \F4, \C4, \D4, \A3, \C4, \F3, \A3, \D3, \F3, \F3, \C3, \A3]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\G1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 19 (M38.0-39.0): G♯-G♯, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\F3, \G3, \A3, \G3, \C3, \F3, \F3, \D3, \A3, \F3, \C3, \A3, \F3, \G3, \A3, \G3, \C3, \F3, \F3, \D3, \A3, \F3, \C3, \A3]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\G1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 20 (M40.0-41.0): G♯-G♯, A-A, F♯-F♯, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\F3, \G3, \A3, \G3, \C3, \F3, \C3, \E3, \C4, \C3, \E3, \C4, \D3, \A3, \C4, \D3, \A3, \C4, \D3, \G3, \C4, \D3, \F3, \C4]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pmelody([\G1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 21 (M42.0-43.0): C♯-G♯-C♯, C-G♯-C
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\E3, \G3, \C4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \C4, \E4, \G3, \D4, \F4, \G3, \D4, \F4, \G3, \D4, \F4, \G3, \D4, \F4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\G4, \G4, \G4, \G4, \G4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pchord(\C, [7, 5], 2), ~piano_leftRhythm, ~left),
  )),

  // Phrase 22 (M44.0-45.0): C♯-C♯, F♯-F♯, B-B, B-B
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\G3, \C4, \E4, \G3, \C4, \E4, \A3, \C4, \F4, \A3, \C4, \F4, \G3, \B3, \E4, \G3, \B3, \E4, \A3, \B3, \D4, \A3, \B3, \D4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\G4, \A4, \G4, \F4, \B4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\C1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 23 (M46.0-47.0): E-E, D♯-D♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\G3, \B3, \E4, \B3, \E4, \G4, \B3, \E4, \G4, \B3, \E4, \G4, \B3, \F4, \A4, \B3, \F4, \A4, \B3, \F4, \A4, \B3, \F4, \A4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\E4, \B4, \B4, \B4, \B4, \B4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\E1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 24 (M48.0-49.0): E-E, D♯-D♯, C♯-C♯, C-G♯-C, C♯-G♯-C♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\B3, \E4, \G4, \B3, \E4, \G4, \C4, \F4, \G4, \C4, \E4, \G4, \D4, \F4, \G4, \D4, \F4, \G4, \E4, \G4, \C5, \E4, \G4, \C5]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\B4, \C5, \C5, \D5, \E5]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\E1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 25 (M50.0-51.0): F♯-F♯, G♯-G♯, C♯-C♯
  Pphrase(9.0, (
    arpeggio: Pvoice(Pmelody([\D4, \F4, \A4, \D4, \F4, \A4, \C4, \F4, \G4, \C4, \F4, \G4, \C4, \E4, \G4, \C4, \E4, \G4, \C4, \F4, \G4, \C4, \F4, \G4, \C4, \F4, \A4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\D5, \C5, \C5, \C5, \D5]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\F1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 26 (M52.0-53.0): F♯-F♯, A-A, F♯-F♯, C♯-C♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\C4, \F4, \A4, \C4, \F4, \A4, \C4, \F4, \A4, \C4, \F4, \G4, \C4, \F4, \G4, \C4, \F4, \G4, \C4, \F4, \G4, \C4, \F4, \A4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\C5, \C5, \C5, \D5]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\F1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 27 (M54.0-56.0): F♯-F♯, A-A, F♯-F♯, C♯-C♯, F♯-F♯, D♯-D♯
  Pphrase(10.0, (
    arpeggio: Pvoice(Pmelody([\C4, \F4, \A4, \C4, \F4, \A4, \C4, \F4, \A4, \C4, \F4, \G4, \C4, \F4, \G4, \C4, \F4, \A4, \C4, \F4, \A4, \B3, \F4, \A4, \B3, \F4, \A4, \B3, \F4, \A4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\C5, \C5, \C5, \B4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\F1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 28 (M56.0-58.0): E-E, C♯-C♯, D♯-D♯, C-C, C♯-C♯, A-A, G♯-G♯
  Pphrase(8.0, (
    arpeggio: Pvoice(Pmelody([\B3, \E4, \G4, \A3, \E4, \G4, \A3, \D4, \F4, \G3, \D4, \F4, \G3, \C4, \E4, \F3, \C4, \D4, \F3, \C4, \D4, \G3, \C4, \D4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\B4, \A4, \A4, \G4, \G4, \F4, \G4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\E1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 29 (M58.0-59.0): F♯-F♯, G♯-G♯, G♯-G♯
  Pphrase(5.0, (
    arpeggio: Pvoice(Pmelody([\A3, \C4, \D4, \G3, \C4, \E4, \G3, \C4, \E4, \F3, \C4, \D4, \F3, \C4, \D4]), ~piano_right_secondRhythm, ~right),
    melody: Pvoice(Pmelody([\A4, \G4, \G4]), ~piano_right_firstRhythm, ~right),
    bass: Pvoice(Pmelody([\F1]), ~piano_leftRhythm, ~left),
  )),

  // Phrase 30 (M68.0-69.0): C♯-G♯-C♯, C♯-G♯-C♯
  Pphrase(6.0, (
    arpeggio: Pvoice(Pmelody([\E3, \E3]), ~piano_right_secondRhythm, ~right),
    bass: Pvoice(Pchord(\C, [7, 5], 2), ~piano_leftRhythm, ~left),
  )),

];

// Print section details with tablature
~phrases.do { |section, i| section.asTab.postln };

// Play phrases sequentially
~composition = Pseq(~phrases);
~player = ~composition.play(~clock);
)

~player.stop;
