(
// Moonlight Sonata - First phrase (M1-5)
// Using Voice class to structure bass and harmony lines

Server.local.boot;
"/Users/joel/src/rs/music/piano.scd".load;
)

(
Section(4, (
  arpeggio: Voice(Chord(\Ds, [3, 3], 4).arp(\up), Rhythm.straight(12, 4)),
  bass:     Voice(Melody([\Gs], octave: 2),       Rhythm.note(4)),
)).asTab.postln;
nil
)

(
~clock = TempoClock(60/60); // 60 BPM

~left  = (instrument: \piano, amp: 0.4, sustain: 4);
~right = (instrument: \piano, amp: 0.3, sustain: 2);

~bassRhythm = Rhythm.note(4);
~arpRhythm = Rhythm.straight(12, 4);

~sections = [
  // M1-2: C#m (C#-E-G#)
  Section(8, (
    arpeggio: Voice(Chord.minor(\Cs, 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Voice(Melody([\Cs], octave: 2),     ~bassRhythm, ~left),
  )),

  // M3: F#m/D# (D#-F#-A) = iv6
  Section(4, (
    arpeggio: Voice(Chord(\Ds, [3, 3], 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Voice(Melody([\Gs], octave: 2),       ~bassRhythm, ~left),
  )),

  // M4: E-G#-C#
  Section(4, (
    arpeggio: Voice(Chord(\E, [4, 5], 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Voice(Melody([\A], octave: 2),       ~bassRhythm, ~left),
  )),

  // M5: EM (E-G#-B)
  Section(4, (
    arpeggio: Voice(Chord.major(\E, 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Voice(Melody([\E], octave: 2),     ~bassRhythm, ~left),
  ))
];

// Print section details with tablature
~sections.do { |section, i| section.asTab.postln };

// Play sections sequentially - Section handles spawning voices internally
~composition = Pseq(~sections);
~player = ~composition.play(~clock);
)

~player.stop;
