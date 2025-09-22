// Pattern Transformation Stack Experiment
// A hierarchical approach to composition using layered event transformations

(
Server.local.boot;
"lib/instruments.scd".load;
)

// Custom transformation functions for pattern processing
(
// Base transformation function that validates inputs
~makeTransform = { |name, requiredKeys, transform|
	Pfunc({ |ev|
		// Check required keys exist
		requiredKeys.do { |key|
			if(ev[key].isNil) {
				Error("Transform '%' requires key '%' but it was not found".format(name, key)).throw;
			};
		};
		// Apply transformation
		transform.value(ev);
	});
};

// Shuffle pattern - adjusts timing and creates ghost notes
~makeShuffle = { |amount = 0.2|
	~makeTransform.value(
		"Shuffle",
		[\dur, \amp],
		{ |ev|
			var shuffle = [amount.neg, amount].choose;
			var isGhost = 0.25.coin;
			ev[\dur] = ev[\dur] * (1 + shuffle);
			ev[\amp] = if(isGhost, ev[\amp] * 0.3, ev[\amp]);
			ev[\legato] = if(isGhost, 0.5, 0.9);
			ev;
		}
	);
};

// Chord tone mapper - maps scale degrees to chord tones
~makeChordTone = {
	~makeTransform.value(
		"ChordTone",
		[\degree, \chord, \scale],
		{ |ev|
			var chordTones = ev[\chord];
			var degree = ev[\degree];
			if(chordTones.notNil) {
				// Map degree to nearest chord tone
				var octave = (degree / chordTones.size).floor;
				var idx = degree % chordTones.size;
				ev[\degree] = chordTones[idx] + (octave * 7);
			};
			ev;
		}
	);
};

// Velocity pattern based on beat position
~makeGroove = {
	var beatCount = 0;
	~makeTransform.value(
		"Groove",
		[\amp],
		{ |ev|
			var pattern = [1.0, 0.6, 0.8, 0.6];  // Basic 4/4 groove
			ev[\amp] = ev[\amp] * pattern[beatCount % 4];
			beatCount = beatCount + 1;
			ev;
		}
	);
};
)

// Build a composition using the transformation stack
(
~basePattern = Pbind(
	// Core note generation - simple ascending pattern
	\degree, Pseq([0, 1, 2, 3, 4, 5, 6, 7].stutter(2), inf),
	\dur, 0.25,
	\amp, 0.7,
	\scale, Scale.minor,
	\octave, 4
);

// Higher-order control pattern - chord progression
~chordControl = Pbind(
	\chord, Pseq([
		[0, 2, 4],      // i chord
		[3, 5, 7],      // iv chord  
		[4, 6, 8],      // v chord
		[0, 2, 4],      // i chord
	], inf),
	\chordDur, 2,  // Each chord lasts 2 beats
);

// Merge chord changes into the note stream
~withChords = Pchain(
	~basePattern,
	Pbindf(
		// This creates a pattern that holds chord values for their duration
		\chord, Pstutter(
			Pkey(\chordDur) / Pkey(\dur),  // How many notes per chord
			Pkey(\chord)
		)
	) <> ~chordControl
);

// Stack transformations
~transformed = Pchain(
	// Each transformation reads the event and modifies it
	Pbindf(\dummy, ~makeChordTone.value),
	Pbindf(\dummy, ~makeShuffle.value(0.15)),
	Pbindf(\dummy, ~makeGroove.value),
	~withChords
);

// Final pattern with instrument
~final = ~transformed <> Pbind(
	\instrument, \cfstring1,
	\pan, Pwhite(-0.3, 0.3),
	\sustain, Pkey(\dur) * Pkey(\legato)
);

// Play it
p = ~final.play;
)

// Stop playback
p.stop;

// Variation: Add melodic contour control
(
// Add a melodic shape that modulates the base pattern
~contourControl = Pbind(
	\contour, Pseq([0, 2, 1, 3, 2, 4, 3, 1], inf),
	\contourScale, 2
);

~withContour = Pchain(
	~basePattern,
	Pbindf(
		\degree, Pkey(\degree) + (Pkey(\contour) * Pkey(\contourScale))
	) <> ~contourControl
);

// Combine with chord progression and transformations
~full = Pchain(
	Pbindf(\dummy, ~PChordTone.value),
	Pbindf(\dummy, ~PShuffle.value(0.1)),
	Pbindf(\dummy, ~PGroove.value),
	~withContour <> ~chordControl
);

~finalWithContour = ~full <> Pbind(
	\instrument, \cfstring1,
	\pan, Pwhite(-0.3, 0.3),
	\sustain, Pkey(\dur) * Pkey(\legato)
);

q = ~finalWithContour.play;
)

// Stop playback
q.stop;

// Example showing runtime validation
(
// This will error because \chord is missing
~broken = Pchain(
	Pbindf(\dummy, ~PChordTone.value),  // Expects \chord
	Pbind(
		\degree, Pseq([0, 1, 2, 3], inf),
		\dur, 0.25,
		\scale, Scale.major
		// Missing \chord!
	)
);

// Uncomment to see the error:
// r = ~broken.play;
)

// More complex example: Multi-voice with shared control
(
// Shared control signals
~globalControl = Pbind(
	\root, Pseq([0, -2, 3, 0], inf),
	\rootDur, 4,
	\density, Pseq([1, 1.5, 2, 1], inf),
	\densityDur, 2
);

// Voice 1: Melody
~melody = Pbind(
	\degree, Prand([0, 2, 4, 5, 7], inf),
	\dur, Pfunc({ |ev| 0.25 / ev[\density] }),
	\octave, 5,
	\amp, 0.6
);

// Voice 2: Bass
~bass = Pbind(
	\degree, Pseq([0, 0, 4, 5], inf),
	\dur, Pfunc({ |ev| 1 / ev[\density] }),
	\octave, 3,
	\amp, 0.8
);

// Merge control into voices
~melodyWithControl = Pchain(
	~melody,
	Pbindf(
		\root, Pstutter(Pkey(\rootDur) / Pkey(\dur), Pkey(\root)),
		\density, Pstutter(Pkey(\densityDur) / Pkey(\dur), Pkey(\density)),
		\degree, Pkey(\degree) + Pkey(\root)
	) <> ~globalControl
);

~bassWithControl = Pchain(
	~bass,
	Pbindf(
		\root, Pstutter(Pkey(\rootDur) / Pkey(\dur), Pkey(\root)),
		\density, Pstutter(Pkey(\densityDur) / Pkey(\dur), Pkey(\density)),
		\degree, Pkey(\degree) + Pkey(\root)
	) <> ~globalControl
);

// Play both voices
~melodyFinal = ~melodyWithControl <> Pbind(\instrument, \cfstring1, \pan, 0.3);
~bassFinal = ~bassWithControl <> Pbind(\instrument, \bass1, \pan, -0.3);

m = ~melodyFinal.play;
b = ~bassFinal.play;
)

// Stop playback
m.stop;
b.stop;
