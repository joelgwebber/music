// Moonlight Sonata - First phrase (M1-5)
// Using Voice class to structure bass and harmony lines

(
Server.local.boot;
"/Users/joel/src/rs/music/piano.scd".load;
)

(
~clock = TempoClock(60/60); // Very slow, ~60 BPM

// Define sections: each has duration, bass voice, and arpeggio voice
// Using MIDI/scientific pitch notation: C4 = middle C (MIDI 60)
~sections = [
  (dur: 8,
   bass: Voice(
     Melody([\Cs], octave: 2),  // C#2 (MIDI 25)
     Rhythm.note(8),
     (instrument: \piano, amp: 0.4, sustain: 4)
   ),
   arpeggio: Voice(
     Chord.minor(\Cs, 4).arp(\up),  // C#4-E4-G#4
     Rhythm.straight(3),
     (instrument: \piano, amp: 0.3, sustain: 2)
   )),  // M1-2: C#m

  (dur: 4,
   bass: Voice(
     Melody([\Gs], octave: 1),  // G#1 (MIDI 20)
     Rhythm.note(4),
     (instrument: \piano, amp: 0.4, sustain: 4)
   ),
   arpeggio: Voice(
     Chord(\Ds, [3, 3], 4).arp(\up),  // D#4-F#4-A4
     Rhythm.straight(3),
     (instrument: \piano, amp: 0.3, sustain: 2)
   )),  // M3: D#-F#-A (F#m/D#) = iv6

  (dur: 4,
   bass: Voice(
     Melody([\A], octave: 1),  // A1 (MIDI 21)
     Rhythm.note(4),
     (instrument: \piano, amp: 0.4, sustain: 4)
   ),
   arpeggio: Voice(
     Chord(\E, [4, 5], 4).arp(\up),  // E4-G#4-C#5
     Rhythm.straight(3),
     (instrument: \piano, amp: 0.3, sustain: 2)
   )),  // M4: E-G#-C# (with octave jump)

  (dur: 4,
   bass: Voice(
     Melody([\E], octave: 1),  // E1 (MIDI 16)
     Rhythm.note(4),
     (instrument: \piano, amp: 0.4, sustain: 4)
   ),
   arpeggio: Voice(
     Chord.major(\E, 4).arp(\up),  // E4-G#4-B4
     Rhythm.straight(3),
     (instrument: \piano, amp: 0.3, sustain: 2)
   ))  // M5: E major
];

// Print section details with tablature
~printSections = {
  "=== Moonlight Sections ===".postln;
  ~sections.do { |sec, i|
    ("Section %: dur=%".format(i+1, sec.dur)).postln;
    ("  Bass notes: %".format(sec.bass.notes)).postln;
    ("  Bass tab:   %".format(sec.bass.asTab(sec.dur))).postln;
    ("  Arp notes:  %".format(sec.arpeggio.notes)).postln;
    ("  Arp tab:    %".format(sec.arpeggio.asTab(sec.dur))).postln;
    "".postln;
  };
};

~printSections.();

// Spawner approach: layer bass + arpeggio voices
~composition = Pspawner({ |sp|
  ~sections.do { |section, i|
    var duration = section[\dur];
    var bassVoice = section[\bass];
    var arpeggioVoice = section[\arpeggio];

    ("Section %: dur=%".format(i+1, duration)).postln;

    // Bass layer - Voice already contains all parameters
    sp.par(Pfindur(duration, bassVoice));

    // Arpeggio layer - Voice already contains all parameters
    sp.par(Pfindur(duration, arpeggioVoice));

    // Wait for section to complete before moving to next
    sp.wait(duration);
  };

  "Phrase complete".postln;
});

~player = ~composition.play(~clock);
)

~player.stop;

