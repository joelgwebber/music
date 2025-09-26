(
Server.local.boot;
"lib/instruments.scd".load;

// Step 1: Create focused instruments for our composition
// Clean, punchy bass for electronic music
SynthDef(\eBass, {|out=0, freq=440, amp=0.3, gate=1, cutoff=1000, res=0.3|
	var env = EnvGen.kr(
		Env.adsr(0.01, 0.1, 0.7, 0.1),
		gate,
		doneAction: Done.freeSelf
	);
	var osc = Mix([
		SinOsc.ar(freq),
		Saw.ar(freq * 0.99, 0.5),
		Pulse.ar(freq * 1.01, 0.5, 0.3)
	]);
	var filt = RLPF.ar(osc, cutoff * env + 100, res);
	Out.ar(out, Pan2.ar(filt * env * amp, 0));
}).add;

// Soft pad for chords
SynthDef(\ePad, {|out=0, freq=440, amp=0.2, gate=1, pan=0|
	var env = EnvGen.kr(
		Env.adsr(0.3, 0.2, 0.8, 0.5),
		gate,
		doneAction: Done.freeSelf
	);
	var osc = Mix([
		Saw.ar(freq * [0.99, 1, 1.01], 0.3),
		SinOsc.ar(freq * 2, 0, 0.1)
	]).sum;
	var filt = LPF.ar(osc, 2000 + (env * 1000));
	Out.ar(out, Pan2.ar(filt * env * amp, pan));
}).add;

// Simple kick drum
SynthDef(\eKick, {|out=0, amp=0.5|
	var env = EnvGen.kr(Env.perc(0.001, 0.3), doneAction: Done.freeSelf);
	var pitchEnv = EnvGen.kr(Env.perc(0.001, 0.05));
	var osc = SinOsc.ar(60 + (pitchEnv * 40));
	Out.ar(out, Pan2.ar(osc * env * amp, 0));
}).add;

// Hi-hat
SynthDef(\eHat, {|out=0, amp=0.3, sustain=0.05|
	var env = EnvGen.kr(Env.perc(0.001, sustain), doneAction: Done.freeSelf);
	var noise = WhiteNoise.ar();
	var filt = HPF.ar(noise, 8000);
	Out.ar(out, Pan2.ar(filt * env * amp, 0));
}).add;
)

// Step 2: Define our chord progression
(
// Let's use a simple but effective progression
// Am - F - C - G (vi - IV - I - V in C major)
~am = Chromatic(9, [3, 4], -1);  // A minor
~f = Chromatic(5, [4, 3], -1);   // F major
~c = Chromatic(0, [4, 3], -1);   // C major
~g = Chromatic(7, [4, 3], -1);   // G major

~prog = Prog([~am, ~f, ~c, ~g]);
postln("Chord progression created: Am - F - C - G");
)

// Alternative: Using Diatonic (experimental)
(
// In C major, we could build diatonic chords like this:
// Diatonic(tonic, root, intervals, octave)
// However, Diatonic expects (tonic, root, intervals) where tonic is the key center

// C major scale degrees:
// I = C (0), ii = D (2), iii = E (4), IV = F (5), V = G (7), vi = A (9), vii° = B (11)

// Attempting to use Diatonic for vi-IV-I-V:
~am_d = Diatonic(0, 9, [3, 4], -1);  // vi in C major
~f_d = Diatonic(0, 5, [4, 3], -1);   // IV in C major
~c_d = Diatonic(0, 0, [4, 3], -1);   // I in C major
~g_d = Diatonic(0, 7, [4, 3], -1);   // V in C major

~prog_d = Prog([~am_d, ~f_d, ~c_d, ~g_d]);
postln("Diatonic progression created");

// Problem: We still need to specify intervals manually
// The Diatonic class doesn't automatically derive them from scale degrees
)

// Alternative: Building from a root chord with transformations
(
// Start with C major and use thirds transformations
~c_root = Chromatic(0, [4, 3], -1);

// To get from C to Am: down a major third
~am_from_c = ~c_root.thirds(-1);  // But this gives us A major, not minor

// The issue is that thirds() maintains chord quality
// We'd need a diatonic thirds method that respects the key

postln("Transformation approach needs diatonic-aware methods");
)

// Simplification using the new Roman numeral notation:
(
// Now we can use Roman numerals!
~prog_roman = Prog.inKey(\C, [\vi, \IV, \I, \V]);
postln("Roman numeral progression: vi-IV-I-V in C");

// Test it sounds the same as our manual version
~test_roman = Pchain(
	~prog_roman,
	Rhythm.straight(4, 2, 0.25),
	Pbind(\instrument, \ePad)
).play(~clock);
)
~test_roman.stop;

// More examples of what's now possible:
(
// Jazz progression with extensions
~jazz_prog = Prog.inKey(\C, [\Imaj7, \vi7, \ii7, \V7]);

// Minor key progression
~minor_prog = Prog.inKey(\Am, [\i, \iv, \VI, \V]);

// Borrowed chords (mixing major/minor)
~borrowed = Prog.inKey(\C, [\I, \IV, \iv, \I]);  // IV to iv is a classic borrowed chord

~jazz = Pchain(
	~borrowed,
	Rhythm.straight(4, 2, 0.25),
	Pbind(\instrument, \ePad)
).play(~clock);
)
~jazz.stop;

// Step 3: Test the chord progression with our pad
(
~clock = TempoClock(120/60); // 120 BPM

~chords = Pchain(
	~prog,
	Rhythm.straight(4, 2, 0.25),  // 4 chords, 2 beats each
	Pbind(\instrument, \ePad)
).play(~clock);

~bass = Pchain(
	~prog.bassLine.octave(-2),
	Rhythm.straight(8, 1, 0.7),  // 8 notes, 1 beat each
	Pbind(\instrument, \eBass, \cutoff, 500)
).play(~clock);

~kick = Pbind(
	\instrument, \eKick,
	\dur, 1,
	\amp, 0.4
).play(~clock);

~hat = Pbind(
	\instrument, \eHat,
	\dur, 0.5,
	\amp, Pseq([0.7, 0.4], inf),
	\sustain, 0.02
).play(~clock);
)

// Stop all
(
~chords.stop;
~bass.stop;
~kick.stop;
~hat.stop;
)

