(
// Moonlight Sonata - First phrase (M1-5)
// Using Voice class to structure bass and harmony lines
Server.local.boot;
"/Users/joel/src/rs/music/piano.scd".load;
)

(
~clock = TempoClock(60/60); // 60 BPM

~left  = (instrument: \piano, amp: 0.4, sustain: 4);
~right = (instrument: \piano, amp: 0.3, sustain: 2);

~bassRhythm = Prhythm.note(4);
~arpRhythm = Prhythm.straight(12, 4);

~phrases = [
  // M1-2: C#m (C#-E-G#)
  Pphrase(8, (
    arpeggio: Pvoice(Pchord.minor(\Cs, 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Pvoice(Pmelody([\Cs], octave: 2),     ~bassRhythm, ~left),
  )),

  // M3: F#m/D# (D#-F#-A) = iv6
  Pphrase(4, (
    arpeggio: Pvoice(Pchord(\Ds, [3, 3], 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Pvoice(Pmelody([\Gs], octave: 2),       ~bassRhythm, ~left),
  )),

  // M4: E-G#-C#
  Pphrase(4, (
    arpeggio: Pvoice(Pchord(\E, [4, 5], 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Pvoice(Pmelody([\A], octave: 2),       ~bassRhythm, ~left),
  )),

  // M5: EM (E-G#-B)
  Pphrase(4, (
    arpeggio: Pvoice(Pchord.major(\E, 4).arp(\up), ~arpRhythm,  ~right),
    bass:     Pvoice(Pmelody([\E], octave: 2),     ~bassRhythm, ~left),
  ))
];

// Print section details with tablature
~phrases.do { |section, i| section.asTab.postln };

// Play phrases sequentially - Section handles spawning voices internally
~composition = Pseq(~phrases);
~player = ~composition.play(~clock);
)

~player.stop;
