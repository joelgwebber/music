// Examples demonstrating the new Progression class and neo-Riemannian transformations

(
Server.local.boot;
"lib/instruments.scd".load;
)

// Example 1: Using the Progression class with your existing Skyrim progression
(
var cm = Chromatic(3, [3, 4], -2);
var gm = cm.thirds(2);
var ebmaj7 = gm.extend(-1);
var fM = cm.parallel.thirds(-2);
var gsus4 = Chromatic(3, [7, 7], -1);
var gM = gm.parallel();
var g7 = gM.extend(1);

// Create a Progression object
var prog = Progression([cm, gm, cm, gm, ebmaj7, fM, gsus4, gM, g7]);

// Play it using the built-in pattern method
p = prog.chordPattern(nil, \cfstring1).play;

// Show the chord names
prog.names.postln;
)
p.stop;

// Example 2: Using neo-Riemannian transformations
(
var cMajor = Chromatic(3, [4, 3], 0); // C major

// Individual transformations
"C major: ".post; cMajor.names.postln;
"Relative (R): ".post; cMajor.relative.names.postln;
"Leading tone (L): ".post; cMajor.leadingTone.names.postln;
"Parallel (P): ".post; cMajor.parallel.names.postln;
"Slide (S): ".post; cMajor.slide.names.postln;
"Nebenverwandt (N): ".post; cMajor.nebenverwandt.names.postln;

// Chain transformations using the string notation
"PLR chain: ".post; cMajor.neoRiemannian("PLR").names.postln;
)

// Example 3: Creating a neo-Riemannian progression
(
var cMajor = Chromatic(3, [4, 3], 0);
var prog = Pprog.neoRiemannian(cMajor, "PLRPLR");

p = prog(nil, \cfstring1).play;
prog.names.postln;
)
p.stop;

// Example 4: Common progressions
(
// ii-V-I in C major
var prog1 = Progression.ii_V_I(3, \major);
"ii-V-I in C: ".post; prog1.names.postln;
)

(
// Circle of fifths with dominant 7ths
var prog2 = Progression.circleOfFifths(3, 8, \dominant7);
"Circle of fifths: ".post; prog2.names.postln;

p = prog2.chordPattern(nil, \cfstring1).play;
)
p.stop;

// Example 5: Arpeggio patterns
(
var prog = Progression.ii_V_I(3, \major);
var arpeggioData = prog.arpeggioPattern(nil, [0, 2, 1, 3], \up); // Custom arpeggio pattern

// Convert to events for Pbind
var notes = arpeggioData.collect(_[0]);
var durs = arpeggioData.collect(_[1]);

p = Pbind(
    \instrument, \cfstring1,
    \note, Pseq(notes),
    \dur, Pseq(durs),
    \amp, 0.3
).play;
)
p.stop;

// Example 6: Progression manipulation
(
var prog1 = Progression.ii_V_I(3, \major);
var prog2 = prog1.reverse;      // Reverse the progression
var prog3 = prog1.transpose(5); // Transpose up 5 semitones
var prog4 = prog1.cycle(2);     // Repeat twice

"Original: ".post; prog1.names.postln;
"Reversed: ".post; prog2.names.postln;
"Transposed: ".post; prog3.names.postln;
"Cycled: ".post; prog4.names.postln;
)

// Example 7: Complex neo-Riemannian journey
(
var cMajor = Chromatic(3, [4, 3], 0);
var operations = "PLRSLNHP"; // Various operations
var prog = Progression.neoRiemannian(cMajor, operations);

// Slow, atmospheric playback
p = Pbind(
    \instrument, \cfstring1,
    \freq, Pseq(prog.freqs),
    \dur, 0.5,
    \sustain, 0.5,
    \amp, 0.3
).play;

"Neo-Riemannian journey: ".postln;
prog.names.do { |names, i|
    ("%: %".format(operations[i] ?? "start", names)).postln;
};
)
p.stop;

// Example 8: Combining progressions
(
var prog1 = Progression.ii_V_I(3, \major);
var bridge = Progression.neoRiemannian(prog1.chords.last, "PL");
var prog2 = Progression.circleOfFifths(bridge.chords.last.root, 4, \major);

var combined = prog1 ++ bridge ++ prog2;

p = combined.chordPattern(nil, \cfstring1).play;
"Combined progression: ".postln;
combined.names.do { |names| names.postln };
)
p.stop;

// Simple strum example
(
// Create a simple chord progression
var cMajor = Chromatic(3, [4, 3], 0);  // C major
var fMajor = Chromatic(8, [4, 3], -1);  // F major
var gMajor = Chromatic(10, [4, 3], -1); // G major
var prog = Progression([cMajor, fMajor, gMajor], [1, 1, 1]); // 2 beats each

// Get strum data: returns [note, delay, duration] triplets
var strumData = prog.strum(0.2, \up);  // 50ms delay between notes, upward strum

// Convert to pattern
p = Pbind(
  \instrument, \cfstring1,
  \freq, Pseq(strumData.collect(_[0])),  // notes
  \lag, Pseq(strumData.collect(_[1])),   // delays
  \dur, Pseq(strumData.collect(_[2])),   // durations
  \sustain, 1,
  \amp, 0.3
).play;
)
p.stop;
