(
Server.local.boot;
"lib/instruments.scd".load;

// Load the pattern composition framework
"pattern_composition.scd".load;
)

// Debug version - test each component separately
(
// Step 1: Test basic melodic contour
~testMelody = {
	var melody = ~patternFactory[\melodicContour].(
		notes: [60, 63, 65, 67, 70],
		shape: \arch,
		octaveRange: 0  // Keep it simple for now
	);

	Pbindf(melody, \instrument, \bass).play;
};

p = ~testMelody.value;
)
p.stop;

(
// Step 2: Test rhythm modifier
~testRhythm = {
	var base = Pbind(
		\instrument, \bass,
		\midinote, Pseq([60, 62, 64, 65, 67], inf),
		\dur, 0.25
	);

	var rhythmic = ~patternFactory[\rhythm].(base, rhythm: [2, 1, 1, 3, 1], unit: 0.125);
	rhythmic.play;
};

p = ~testRhythm.value;
)
p.stop;

(
// Step 3: Test pipe transformation
~testPipe = {
	var base = Pbind(
		\instrument, \bass,
		\midinote, Pseq([60, 62, 64, 65, 67], inf),
		\dur, 0.25
	);

	var transformed = ~pipe.(
		~patternOps[\transpose].(7),
		~patternOps[\stretch].(1.5)
	).(base);

	transformed.play;
};

p = ~testPipe.value;
)
p.stop;

(
// Step 4: Test sequencer
~testSeq = {
	var pat1 = Pbind(
		\instrument, \bass,
		\midinote, Pseq([60, 62, 64], inf),
		\dur, 0.2
	);

	var pat2 = Pbind(
		\instrument, \bass,
		\midinote, Pseq([67, 69, 71], inf),
		\dur, 0.15
	);

	var sequence = ~patternSequencer.([pat1, pat2], [2, 2]);
	sequence.play;
};

p = ~testSeq.value;
)
p.stop;

(
// Step 5: Simplified complex example
~simpleComplex = {
	var base, transformed, sequence;

	// Simple base pattern
	base = Pbind(
		\instrument, \bass,
		\midinote, Pseq([60, 63, 65, 67, 70, 67, 65, 63], 1),
		\dur, 0.25
	);

	// Apply one transformation
	transformed = ~patternOps[\stretch].(1.5).(base);

	// Sequence two versions
	sequence = ~patternSequencer.([
		base,
		~patternOps[\transpose].(5).(base)
	], [2, 2]);

	sequence.play;
};

~simpleComplex.value;
)
