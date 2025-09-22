// Pattern Composition Framework
// ==============================
// Exploring approaches for composable, stackable, and parameterizable patterns

(
Server.local.boot;
"lib/instruments.scd".load;

// Approach 1: Pattern Stack - Transform patterns through a chain of modifiers
// Each modifier takes a pattern and returns a modified pattern
~patternStack = { |basePattern, modifiers|
	modifiers.inject(basePattern, { |pat, mod| mod.value(pat) });
};

// Example modifiers (functions that transform patterns)
~shuffleNotes = { |pattern, amount = 0.5|
	Pbindf(pattern,
		\midinote, Pif(
			Pfunc({ amount.coin }),
			Pkey(\midinote) + Prand([-2, -1, 0, 1, 2], 1),
			Pkey(\midinote)
		)
	)
};

~velocityContour = { |pattern, curve = \exp|
	var velPattern = curve.switch(
		\exp, Pexprand(0.3, 1.0, inf),
		\linear, Pwhite(0.3, 1.0, inf),
		\accent, Pseq([1.0, 0.5, 0.6, 0.5], inf),
		Pwhite(0.5, 0.8, inf)
	);
	Pbindf(pattern, \amp, velPattern * Pkey(\amp, 0.5))
};

~timeStretch = { |pattern, factor = 1.0|
	Pstretch(factor, pattern)
};

~transpose = { |pattern, semitones = 0|
	Pbindf(pattern, \midinote, Pkey(\midinote) + semitones)
};

// Test basic stacking
~testStack = {
	var basePattern = Pbind(
		\midinote, Pseq([60, 62, 64, 65, 67], inf),
		\dur, 0.25,
		\amp, 0.5
	);

	// Stack transformations
	~patternStack.(basePattern, [
		{ |p| ~shuffleNotes.(p, 0.3) },
		{ |p| ~velocityContour.(p, \accent) },
		{ |p| ~timeStretch.(p, 1.5) }
	]).play;
};

// Approach 2: Pattern Sequencer - Apply different patterns over time ranges
~patternSequencer = {
	arg patterns, durations;
	// Use Pfindur to limit each pattern to its duration, then sequence them
	Pseq(
		patterns.collect({ |pat, i|
			Pfindur(durations[i], pat)
		})
	)
};

// Alternative: Use time-based switching
~patternSwitcher = {
	arg patterns, switchTimes;
	var index = 0;
	Pfunc({
		var now = thisThread.beats;
		while { (index < (switchTimes.size - 1)) and: { now >= switchTimes[index + 1] } } {
			index = index + 1;
		};
		patterns[index]
	}).asStream.flatten;
};

// Test sequencing
~testSequence = {
	var patterns = [
		Pbind(\midinote, Pseq([60, 62, 64], inf), \dur, 0.2),
		Pbind(\midinote, Pseq([67, 69, 71], inf), \dur, 0.15),
		Pbind(\midinote, Pseq([72, 71, 69, 67], inf), \dur, 0.25)
	];

	~patternSequencer.(patterns, [2, 3, 2]).play;
};

// Approach 3: Hierarchical Patterns - Long patterns that modify shorter ones
~hierarchicalPattern = {
	arg basePatterns, overlayPattern;
	// overlayPattern should generate events that modify the base patterns
	Pchain(overlayPattern, Pseq(basePatterns, inf))
};

// Example: A long-term velocity envelope over shorter melodic patterns
~testHierarchy = {
	var melodies = [
		Pbind(\midinote, Pseq([60, 62, 64], 2), \dur, 0.2),
		Pbind(\midinote, Pseq([67, 65, 64], 2), \dur, 0.2),
		Pbind(\midinote, Pseq([60, 64, 67], 2), \dur, 0.2)
	];

	var envelope = Pbind(
		\amp, Pseg([0.2, 0.8, 0.2], [3, 3], \exp, inf)
	);

	~hierarchicalPattern.(melodies, envelope).play;
};

// Approach 4: Parameterized Pattern Factories
~patternFactory = IdentityDictionary.new;

// Register pattern templates
~patternFactory[\arpeggio] = { |root = 60, intervals = #[0, 4, 7], rate = 0.125, repeats = 4|
	Pbind(
		\midinote, Pseq(root + intervals, repeats),
		\dur, rate
	)
};

~patternFactory[\rhythm] = { |pattern, rhythm = #[1, 1, 2], unit = 0.125|
	Pbindf(pattern,
		\dur, Pseq(rhythm * unit, inf)
	)
};

~patternFactory[\shuffle] = { |pattern, amount = 0.1, range = 0.05|
	Pbindf(pattern,
		\dur, Pkey(\dur) * Pwhite(1.0 - range, 1.0 + range, inf),
		\timingOffset, Pwhite(amount.neg, amount, inf)
	)
};

~patternFactory[\melodicContour] = { |notes = #[60, 62, 64], shape = \up, octaveRange = 0|
	var contour = shape.switch(
		\up, (0..notes.size-1),
		\down, (notes.size-1..0),
		\arch, (0..notes.size-1) ++ (notes.size-2..1),
		\random, { notes.size.rand } ! (notes.size * 2)
	);

	Pbind(
		\midinote, Pseq(notes[contour], inf) + (12 * Pwhite(0, octaveRange, inf)),
		\dur, 0.25
	)
};

// Test factories
~testFactories = {
	var arp = ~patternFactory[\arpeggio].(root: 48, intervals: [0, 3, 7, 10], rate: 0.1);
	var rhythmic = ~patternFactory[\rhythm].(arp, rhythm: [2, 1, 1, 4], unit: 0.1);
	var shuffled = ~patternFactory[\shuffle].(rhythmic, amount: 0.02);
	shuffled.play;
};

// Approach 5: Composable Pattern Operations (inspired by functional composition)
~patternOps = IdentityDictionary.new;

// Define a compose function that chains operations
~compose = { |...funcs|
	{ |x|
		funcs.reverse.inject(x, { |acc, f| f.value(acc) })
	}
};

// Define a pipe function (opposite of compose - left to right)
~pipe = { |...funcs|
	{ |x|
		funcs.inject(x, { |acc, f| f.value(acc) })
	}
};

// Curry-friendly pattern operations
~patternOps[\transpose] = { |n| { |p| Pbindf(p, \midinote, Pkey(\midinote) + n) } };
~patternOps[\stretch] = { |factor| { |p| Pstretch(factor, p) } };
~patternOps[\repeat] = { |n| { |p| Pn(p, n) } };
~patternOps[\reverse] = { |p| Pn(p, 1).collect({ |ev| ev }).reverse };
~patternOps[\limit] = { |dur| { |p| Pfindur(dur, p) } };

// Test composition
~testComposition = {
	var base = Pbind(
		\midinote, Pseq([60, 62, 64, 65, 67], 1),
		\dur, 0.2
	);

	// Create a complex transformation by composing operations
	var transform = ~pipe.(
		~patternOps[\transpose].(7),
		~patternOps[\stretch].(1.5),
		~patternOps[\repeat].(2)
	);

	transform.(base).play;
};

// Approach 6: Event-level pattern stacking with merge strategies
~stackedPattern = { |patterns, merger = \override|
	var mergeFunc = merger.switch(
		\override, { |events| events.inject((), { |acc, ev| acc.putAll(ev) }) },
		\combine, { |events|
			var result = ();
			events.do { |ev|
				ev.keysValuesDo { |key, val|
					if(result[key].notNil and: { val.isNumber and: result[key].isNumber }, {
						result[key] = result[key] + val;
					}, {
						result[key] = val;
					});
				};
			};
			result
		},
		\multiply, { |events|
			var result = ();
			events.do { |ev|
				ev.keysValuesDo { |key, val|
					if(result[key].notNil and: { val.isNumber and: result[key].isNumber }, {
						result[key] = result[key] * val;
					}, {
						result[key] = val;
					});
				};
			};
			result
		}
	);

	Ppar(patterns).collect(mergeFunc);
};

// Test stacking
~testStacking = {
	var melody = Pbind(
		\midinote, Pseq([60, 62, 64, 65], inf),
		\dur, 0.25
	);

	var dynamics = Pbind(
		\amp, Pseq([0.8, 0.4, 0.5, 0.6], inf),
		\dur, 0.25
	);

	var articulation = Pbind(
		\legato, Pseq([0.2, 1.2, 0.8, 0.9], inf),
		\dur, 0.25
	);

	~stackedPattern.([melody, dynamics, articulation], \override).play;
};

// Example: Combining multiple approaches
~complexExample = {
	var melody, rhythmic, dynamics, sequence;

	// Base melodic material (parameterized)
	melody = ~patternFactory[\melodicContour].(
		notes: [60, 63, 65, 67, 70],
		shape: \arch,
		octaveRange: 0
	);

	// Add instrument
	melody = Pbindf(melody, \instrument, \bass);

	// Apply rhythm pattern
	rhythmic = ~patternFactory[\rhythm].(melody, rhythm: [2, 1, 1, 3, 1], unit: 0.125);

	// Add velocity contour
	dynamics = ~velocityContour.(rhythmic, \exp);

	// Sequence different variations
	sequence = ~patternSequencer.([
		dynamics,
		~patternOps[\transpose].(5).(dynamics),
		~patternOps[\transpose].(7).(~patternOps[\stretch].(1.5).(dynamics))
	], [4, 4, 6]);

	sequence.play;
};
)

~complexExample.value;
