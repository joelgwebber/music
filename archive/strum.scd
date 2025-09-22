// Example demonstrating proper chord strumming with the new composable pattern approach

(
Server.local.boot;
"lib/instruments.scd".load;
)

// Create chord progressions
(
var cMajor = Chromatic(3, [4, 3], 0);   // C major
var fMajor = Chromatic(8, [4, 3], 0);   // F major  
var gMajor = Chromatic(10, [4, 3], 0);  // G major
var aMajor = Chromatic(0, [4, 3], 0);   // A major

~prog1 = Progression([cMajor, fMajor, gMajor, aMajor]);
~prog2 = Progression.ii_V_I(3, \major);
~prog3 = Progression.neoRiemannian(Chromatic(3, [4, 3], 0), "PLR");
~prog4 = Progression.circleOfFifths(3, 4, \major).octave(-2);
)

// Simple strummed chord progression
(
var rhythm = RhythmPattern.straight(4, 1);
var strum = StrumPattern.guitar(\medium);

p = ~prog1.strumPattern(strum, rhythm, \singrain).play;
)
p.stop;

// Faster downward strum with swing rhythm
(
var rhythm = RhythmPattern.swing(3, 0.67, 1);
var strum = StrumPattern(0.02, \down);

p = ~prog2.strumPattern(strum, rhythm, \singrain).play;
)
p.stop;

// Very slow strum for dramatic effect
(
var rhythm = RhythmPattern([2, 1.5, 2.5]);
var strum = StrumPattern(0.1, \up);

p = ~prog3.strumPattern(strum, rhythm, \singrain).play;
)
p.stop;

// Alternating strum directions with custom rhythm
(
var rhythm = RhythmPattern([1, 1, 1, 1], [0.8, 0.6, 0.8, 0.6]);

// Create alternating strum patterns
var upStrum = StrumPattern(0.1, \up);
var downStrum = StrumPattern(0.1, \down);

// Manually alternate between patterns
fork {
  var chords = ~prog4.chords;
  var rhythmDurs = rhythm.scaledDurations;
  var rhythmVels = rhythm.velocities;
  
  chords.do { |chord, i|
    var strum = if(i.even, upStrum, downStrum);
    var events = strum.applyToProgression(Progression([chord]), RhythmPattern([rhythmDurs[i]], [rhythmVels[i]]));
    
    Pbind(
      \instrument, \bass,
      \freq, Pseq(events.collect(_.freq)),
      \lag, Pseq(events.collect(_.lag)),
      \amp, Pseq(events.collect(_.amp)),
      \dur, Pseq(events.collect(_.dur)),
      \sustain, 1.0
    ).play;
    
    rhythmDurs[i].wait;
  };
};
)

// Complex strumming patterns
(
// Harp-like arpeggiation
var rhythm = RhythmPattern.euclidean(5, 8, 0.5);
var strum = StrumPattern.harp(\slow);

p = ~prog1.cycle(2).strumPattern(strum, rhythm, \singrain).play;
)
p.stop;

// Mandolin-style tremolo
(
var rhythm = RhythmPattern([0.25, 0.25, 0.25, 0.25], [0.9, 0.7, 0.7, 0.9]);
var strum = StrumPattern.mandolin;

p = ~prog2.strumPattern(strum, rhythm, \singrain).play;
)
p.stop;

// Roll effect
(
var rhythm = RhythmPattern([4]); // One long chord
var strum = StrumPattern.roll(4, 60); // 60 notes over 4 beats

p = Progression([Chromatic(3, [4, 3, 3, 4], 0)]).strumPattern(strum, rhythm, \singrain).play;
)
p.stop;

// Humanized strumming
(
var rhythm = RhythmPattern.straight(4, 1, 0.7);
var strum = StrumPattern(0.03, \up, 1.2, 0.3); // 30% humanization

p = ~prog1.strumPattern(strum, rhythm, \singrain).play;
)
p.stop;

// Combined techniques: Strum + Arpeggio
(
fork {
  // Background strummed chords
  var strumRhythm = RhythmPattern([2, 2], [0.5, 0.5]);
  var strum = StrumPattern.guitar(\slow);
  
  ~prog1.cycle(2).strumPattern(strum, strumRhythm, \singrain).play;
  
  // Foreground arpeggiated melody
  0.5.wait;
  var arpRhythm = RhythmPattern.straight(16, 0.25, 0.6);
  var arp = ArpeggioPattern.upDown(4, 2, false);
  
  ~prog1.cycle(2).arpeggioPattern(arp, arpRhythm, \singrain).play;
};
)

// Up-down strum pattern
(
var rhythm = RhythmPattern([1, 1, 1, 1]);
var strum = StrumPattern(0.05, \upDown, 1, 0.1);

p = ~prog3.strumPattern(strum, rhythm, \singrain).play;
)
p.stop;
