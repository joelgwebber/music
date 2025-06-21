// Example demonstrating proper chord strumming

(
Server.local.boot;
"lib/instruments.scd".load;
)

// Simple strummed chord progression
(
var cMajor = Chromatic(3, [4, 3], 0);   // C major
var fMajor = Chromatic(8, [4, 3], 0);   // F major  
var gMajor = Chromatic(10, [4, 3], 0);  // G major
var aMajor = Chromatic(0, [4, 3], 0);   // A major

var prog = Progression([cMajor, fMajor, gMajor, aMajor], [1, 1, 1, 1]);

// Get strum data - now returns [frequencies, lags, duration] for each chord
var strumData = prog.strum(0.05, \up);

p = Pbind(
    \instrument, \cfstring1,
    \freq, Pseq(strumData.collect(_[0])),      // chord frequencies (arrays)
    \lag, Pseq(strumData.collect(_[1])),        // strum delays (arrays)
    \dur, Pseq(strumData.collect(_[2])),        // chord durations
    \sustain, 1,
    \amp, 0.3
).play;
)
p.stop;

// Faster downward strum with a different progression
(
var prog = Progression.ii_V_I(3, \major);
var strumData = prog.strum(0.02, \down);  // Faster, downward

p = Pbind(
    \instrument, \cfstring1,
    \freq, Pseq(strumData.collect(_[0])),
    \lag, Pseq(strumData.collect(_[1])),
    \dur, Pseq(strumData.collect(_[2])),
    \sustain, 1.2,
    \amp, 0.4
).play;
)
p.stop;

// Very slow strum for dramatic effect
(
var prog = Progression.neoRiemannian(Chromatic(3, [4, 3], 0), "PLR");
var strumData = prog.strum(0.1, \up);  // 100ms between notes

p = Pbind(
    \instrument, \cfstring1,
    \freq, Pseq(strumData.collect(_[0])),
    \lag, Pseq(strumData.collect(_[1])),
    \dur, Pseq(strumData.collect(_[2])),
    \sustain, 3,
    \amp, 0.25
).play;
)
p.stop;

// Alternating strum directions
(
var prog = Progression.circleOfFifths(3, 4, \major).octave(-2);
var upStrum = prog.strum(0.1, \up);
var downStrum = prog.strum(0.1, \down);

// Alternate between up and down strums
var alternatingData = [upStrum[0], downStrum[1], upStrum[2], downStrum[3]];

p = Pbind(
    \instrument, \bass,
    \freq, Pseq(alternatingData.collect(_[0])),
    \lag, Pseq(alternatingData.collect(_[1])),
    \dur, Pseq(alternatingData.collect(_[2])),
    \sustain, 1.0,
    \amp, 0.35
).play;
)
p.stop;
