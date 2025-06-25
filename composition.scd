// Demonstration of the new composable pattern approach
(
Server.local.boot;
"lib/instruments.scd".load;
)

// 1. Create progressions without durations
(
// Simple circle of fifths progression
~prog1 = Progression.circleOfFifths(0, 8, \dominant7);

// ii-V-I progression
~prog2 = Progression.ii_V_I(3, \major);

// Neo-Riemannian progression
~prog3 = Progression.neoRiemannian(Chromatic(0, [4, 3], 0), "PLRP");
)

// 2. Create rhythm patterns independently
(
// Various rhythm patterns
~rhythm1 = RhythmPattern.straight(4, 1, 0.7);
~rhythm2 = RhythmPattern.swing(8, 0.67, 1.0, 0.8);
~rhythm3 = RhythmPattern.clave(\son);
~rhythm4 = RhythmPattern.euclidean(5, 8, 0.25, 0.8);
)

// 3. Combine progressions with rhythms using chord patterns
(
// Simple chord progression with straight rhythm
p = ~prog1.chordPattern(~rhythm1, \singrain).play;
)
p.stop;

(
// Same progression with swing rhythm
p = ~prog1.chordPattern(~rhythm2, \singrain).play;
)
p.stop;

(
// ii-V-I with clave rhythm
p = ~prog2.cycle(4).chordPattern(~rhythm3, \singrain).play;
)
p.stop;

// 4. Arpeggio patterns
(
// Various arpeggio patterns
~arp1 = ArpeggioPattern.up(4, 1);      // Up pattern across 2 octaves
~arp2 = ArpeggioPattern.upDown(4, 1, false);  // Up-down without repeating top
~arp3 = ArpeggioPattern.alberti(4);    // Classical Alberti bass
~arp4 = ArpeggioPattern.random(4, 16, 1);  // Random pattern
)

(
// Apply different arpeggio patterns to the same progression
p = ~prog1.arpeggioPattern(~arp1, ~rhythm1, \singrain).play;
)
p.stop;

(
// Alberti bass pattern with swing rhythm
p = ~prog2.cycle(2).arpeggioPattern(~arp1, ~rhythm1, \singrain).play;
)
p.stop;

// 5. Strum patterns
(
// Various strum patterns
~strum1 = StrumPattern.guitar(\fast);
~strum2 = StrumPattern.harp(\medium);
~strum3 = StrumPattern.mandolin;
~strum4 = StrumPattern(0.05, \upDown, 1.5, 0.1);  // Custom strum
)

(
// Apply strum patterns
p = ~prog1.strumPattern(~strum2, ~rhythm1, \singrain).play;
)
p.stop;

(
// Harp-like strum with euclidean rhythm
p = ~prog3.cycle(2).strumPattern(~strum2, ~rhythm4, \singrain).play;
)
p.stop;

// 6. Advanced composability examples

(
// Mix different techniques - bass line + arpeggios
var bassRhythm = RhythmPattern([2, 1, 1], [0.8, 0.6, 0.7]);
var arpRhythm = RhythmPattern.euclidean(7, 8, 0.25, 0.5);

fork {
  // Play bass line
  Pbind(
    \instrument, \bass,
    \freq, Pseq(~prog1.bassLine),
    \dur, Pseq(bassRhythm.scaledDurations),
    \amp, Pseq(bassRhythm.velocities) * 0.8,
    \octave, 2
  ).play;

  // Play arpeggios on top
  ~prog1.arpeggioPattern(
    ArpeggioPattern.converge(3, 2),
    arpRhythm,
    \singrain
  ).play;
};
)

(
// Voice-led chords with custom rhythm
var customRhythm = RhythmPattern(
  [0.5, 0.25, 0.25, 1, 0.5, 0.5],
  [0.9, 0.6, 0.7, 1, 0.8, 0.8],
  [0.8, 0.5, 0.5, 1, 0.7, 0.7]
);

p = ~prog2.cycle(2).voiceLeadPattern(customRhythm, \singrain).play;
)
p.stop;

// 7. Create complex layered arrangement
(
fork {
  var prog = Progression.circleOfFifths(3, 4, \major).octave(-1);
  var mainRhythm = RhythmPattern([1, 1, 1, 1]);

  // Layer 1: Bass line
  Pbind(
    \instrument, \bass,
    \freq, Pseq(prog.roots, inf),
    \dur, Pseq(mainRhythm.scaledDurations, inf),
    \amp, 0.7,
    \octave, 3
  ).play;

  // Layer 2: Strummed chords
  0.5.wait;
  prog.strumPattern(
    StrumPattern(0.02, \up, 1.2, 0.05),
    mainRhythm,
    \singrain
  ).play;

  // Layer 3: Top voice melody
  1.wait;
  Pbind(
    \instrument, \singrain,
    \freq, Pseq(prog.topVoice, inf) * 2,
    \dur, Pseq(RhythmPattern.swing(8, 0.67, 0.5).scaledDurations, inf),
    \amp, 0.4,
    \sustain, 0.3
  ).play;
};
)

// 8. Using pattern streams directly
(
// Create a stream of chords and process them
var stream = ~prog1.asStream;
var rhythm = RhythmPattern.straight(1, 0.5);

p = Pbind(
  \instrument, \singrain,
  \chord, stream,
  \freq, Pfunc({ |ev| ev[\chord].freqs }),
  \dur, Pseq(rhythm.scaledDurations, inf),
  \amp, 0.5
).play;
)
p.stop;

// 9. Creating patterns from strings
(
// Create arpeggio pattern from string notation
var arpFromString = ArpeggioPattern.fromString("0213", 2);
p = ~prog2.cycle(4).arpeggioPattern(arpFromString, ~rhythm1, \singrain).play;
)
p.stop;

