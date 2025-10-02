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
~am = Chord.minor(9, -1);  // A minor
~f = Chord.major(5, -1);   // F major
~c = Chord.major(0, -1);   // C major
~g = Chord.major(7, -1);   // G major

~prog = Prog([~am, ~f, ~c, ~g]);
)

// Alternative approaches with the new Chord API:
(
// Approach 1: Roman numerals (cleanest for diatonic progressions)
~prog_roman = Prog.inKey(\C, [\vi, \IV, \I, \V]);

// Approach 2: Neo-Riemannian transforms (good for voice-leading exploration)
~c_root = Chord.major(\C, -2);
~am_from_c = ~c_root.r;  // Relative: C major -> A minor

// Approach 3: Direct construction with convenience methods
~am_direct = Chord.minor(\A, -1);
~f_direct = Chord.major(\F, -1);
)

// Simplification using the new Roman numeral notation:
(
// Now we can use Roman numerals!
~prog_roman = Prog.inKey(\C, [\vi, \IV, \I, \V]);

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

~prog = ~jazz_prog;
~chords = Pchain(
	~prog,
	Rhythm.clave(\son, 0.5),
	Pbind(\instrument, \ePad)
).play(~clock);

~bass = Pchain(
	~prog.bassLine.octave(-2),
	Rhythm.straight(8, 4, 0.7),  // 8 notes, 1 beat each
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

