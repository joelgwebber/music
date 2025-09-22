(
Server.local.boot;
"lib/instruments.scd".load;
"pattern_composition.scd".load;
)

// Method 1: Using Pfunc to dynamically evaluate ~freq
(
~freqPattern = [440, 550, 660, 770];
~freqIndex = 0;
p = Pbind(
	\instrument, \singrain,
	\freq, Pfunc({ ~freqPattern.wrapAt(~freqIndex = ~freqIndex + 1) }),
	\dur, 0.5,
	\sustain, 1.0,
	\amp, 0.7
).play;
)

// Now you can change the pattern while playing:
~freqPattern = [440, 660];  // This will take effect immediately
~freqPattern = [220, 330, 440, 550];  // Or this
p.stop;

// Method 2: Using Pdefn for named pattern proxies
(
Pdefn(\freq, Pseq([440, 550, 660, 770], inf));
p = Pbind(
	\instrument, \singrain,
	\freq, Pdefn(\freq),
	\dur, 0.5,
	\sustain, 1.0,
	\amp, 0.7
).play;
)

// Change the pattern while playing:
Pdefn(\freq, Pseq([440, 660], inf));  // Takes effect on next cycle
Pdefn(\freq, Prand([220, 330, 440, 550], inf));  // Random frequencies
p.stop;

// Method 3: Using Pdef for entire pattern definitions
(
Pdef(\melody,
	Pbind(
		\instrument, \singrain,
		\freq, Pseq([440, 550, 660, 770], inf),
		\dur, 0.5,
		\sustain, 1.0,
		\amp, 0.7
	)
).play;
)

// Replace the entire pattern:
(
Pdef(\melody,
	Pbind(
		\instrument, \singrain,
		\freq, Pseq([440, 660], inf),
		\dur, 0.25,  // Also changed duration
		\sustain, 0.5,
		\amp, 0.7
	)
);  // Automatically updates the playing pattern
)

Pdef(\melody).stop;

// Method 4: Using control busses for continuous parameter control
(
~freqBus = Bus.control(s, 1);
~freqBus.set(440);

p = Pbind(
	\instrument, \singrain,
	\freq, ~freqBus.asMap,  // Maps the bus to the freq parameter
	\dur, 0.5,
	\sustain, 1.0,
	\amp, 0.7
).play;
)

// Smoothly change frequency:
~freqBus.set(550);
~freqBus.set(660);
p.stop;

// Method 5: Using Pbindef for live coding patterns
(
Pbindef(\live,
	\instrument, \singrain,
	\freq, Pseq([440, 550, 660, 770], inf),
	\dur, 0.5,
	\sustain, 1.0,
	\amp, 0.7
).play;
)

// Change individual keys while playing:
Pbindef(\live, \freq, Pseq([440, 660], inf));
Pbindef(\live, \dur, 0.25);
Pbindef(\live, \freq, Prand([220, 330, 440, 550], inf));
Pbindef(\live, \amp, Pseq([0.7, 0.3, 0.5], inf));

Pbindef(\live).stop;
Pbindef(\live).clear;  // Clear the definition

// Method 6: Using environment variables with Pfunc
(
~scale = [0, 2, 4, 5, 7, 9, 11];
~root = 60;
~octave = 0;

p = Pbind(
	\instrument, \singrain,
	\degree, Prand((0..7), inf),
	\scale, Pfunc({ ~scale }),
	\root, Pfunc({ ~root }),
	\octave, Pfunc({ ~octave }),
	\dur, 0.25,
	\sustain, 0.5,
	\amp, 0.7
).play;
)

// Change parameters while playing:
~scale = [0, 2, 3, 5, 7, 8, 10];  // Change to melodic minor
~root = 65;  // Change root to F
~octave = 1;  // Up an octave
p.stop;

// Method 7: Using a conductor pattern with nested patterns (using Pdef)
(
// For nested patterns that can be swapped, use Pdef/Pdefn:
Pdefn(\condFreq, Pseq([440, 550, 660, 770], inf));
Pdefn(\condDur, Pseq([0.5, 0.5, 0.5, 0.5], inf));
Pdefn(\condAmp, 0.7);

p = Pbind(
	\instrument, \singrain,
	\freq, Pdefn(\condFreq),
	\dur, Pdefn(\condDur),
	\sustain, 1.0,
	\amp, Pdefn(\condAmp)
).play;
)

// Modify the patterns:
Pdefn(\condFreq, Pseq([880, 440], inf));  // Change frequencies
Pdefn(\condDur, Pseq([0.25, 0.75], inf));  // Change rhythm
Pdefn(\condAmp, Pseq([0.3, 0.7], inf));  // Dynamic amplitude
p.stop;

// Method 7b: Using arrays with Pfunc (simpler for direct value access)
(
~conductor = (
	freqs: [440, 550, 660, 770],
	durs: [0.5, 0.5, 0.5, 0.5],
	amp: 0.7,
	sustain: 1.0,
	index: 0
);

p = Pbind(
	\instrument, \singrain,
	\freq, Pfunc({
		var i = ~conductor.index;
		~conductor.index = (i + 1) % ~conductor.freqs.size;
		~conductor.freqs.wrapAt(i)
	}),
	\dur, Pfunc({ ~conductor.durs.wrapAt(~conductor.index - 1) }),
	\sustain, Pfunc({ ~conductor.sustain }),
	\amp, Pfunc({ ~conductor.amp })
).play;
)

// Modify while playing:
~conductor.freqs = [880, 440];  // Change frequencies
~conductor.durs = [0.25, 0.75];  // Change rhythm
~conductor.amp = 0.1;  // Change amplitude
p.stop;

// Method 7b: Manual indexing only when you need synchronized stepping
(
~conductor = (
	freqs: [440, 550, 660, 770],
	durs: [0.5, 0.25, 0.25, 1.0],
	amps: [0.7, 0.5, 0.5, 0.8],
	index: 0
);

p = Pbind(
	\instrument, \singrain,
	// All parameters read from the same index for synchronized changes
	\freq, Pfunc({
		var i = ~conductor.index;
		~conductor.index = (i + 1) % ~conductor.freqs.size;
		~conductor.freqs.wrapAt(i)
	}),
	\dur, Pfunc({ |ev| ~conductor.durs.wrapAt(~conductor.index - 1) }),
	\amp, Pfunc({ |ev| ~conductor.amps.wrapAt(~conductor.index - 1) }),
	\sustain, 1.0
).play;
)

// Now changing any array keeps them synchronized:
~conductor.freqs = [220, 330, 440];  // They stay in sync
~conductor.durs = [0.33, 0.33, 0.34];
~conductor.amps = [0.9, 0.7, 0.5];
p.stop;
