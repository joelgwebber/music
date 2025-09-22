// Pattern Song - Three-voice composition exploring pattern design
// =================================================================
// A simple song structure using the pattern composition framework
// to coordinate three voices sharing a chord progression with
// evolving musical parameters over time

(
Server.local.boot;
"lib/instruments.scd".load;
"pattern_composition.scd".load;

// Shared musical material
~song = IdentityDictionary.new;

// Define our chord progression (in MIDI notes)
// Using a simple ii-V-I-vi progression in C major
~song[\chordRoots] = [62, 67, 60, 69];  // D, G, C, A
~song[\chordQualities] = [
	[0, 3, 7, 10],    // Dm7
	[0, 4, 7, 11],    // G7
	[0, 4, 7, 12],    // Cmaj7
	[0, 3, 7, 10]     // Am7
];

// Shared time structure - 2 bars per chord
~song[\chordDurations] = [2, 2, 2, 2];  // in bars
~song[\barDuration] = 4;  // 4 beats per bar
~song[\totalBars] = ~song[\chordDurations].sum;

// Create evolving parameters that all voices can reference
// These use Pseg to create smooth transitions over the song duration
~song[\globalDynamics] = Pseg(
	[0.3, 0.7, 0.5, 0.8, 0.4],  // amplitude envelope
	[2, 2, 3, 1] * ~song[\barDuration],  // segment durations
	\exp,
	1  // play once
);

~song[\globalDensity] = Pseg(
	[0.5, 1.0, 0.75, 1.2, 0.6],  // density multiplier
	[2, 2, 3, 1] * ~song[\barDuration],
	\lin,
	1
);

~song[\globalBrightness] = Pseg(
	[0.4, 0.8, 0.6, 1.0, 0.5],  // brightness/cutoff parameter
	[2, 2, 3, 1] * ~song[\barDuration],
	\sin,
	1
);

// Voice 1: Bass - Roots and rhythmic foundation
~song[\bassVoice] = {
	var chordIndex = Pstutter(
		~song[\chordDurations] * ~song[\barDuration] * 2,  // notes per chord
		Pseq((0..3), 1)
	);

	var roots = Pindex(~song[\chordRoots], chordIndex, inf);

	// Create bass pattern using factories
	var basePattern = Pbind(
		\instrument, \bass,
		\midinote, roots - 12,  // Bass octave
		\dur, 0.5,
		\amp, 0.5
	);

	// Apply rhythmic pattern that evolves
	var rhythmicPattern = Pbindf(basePattern,
		\dur, Pif(
			Pkey(\amp) > 0.6,
			Pseq([0.5, 0.5, 0.25, 0.25, 0.5], inf),  // busier when louder
			Pseq([0.75, 0.25, 0.5, 0.5], inf)  // simpler when quieter
		)
	);

	// Apply global dynamics
	var withDynamics = Pbindf(rhythmicPattern,
		\amp, ~song[\globalDynamics] * Pkey(\amp) * 0.8
	);

	// Add some articulation variation
	~velocityContour.(withDynamics, \accent);
};

// Voice 2: Harmony - Chord voicings
~song[\harmonyVoice] = {
	// Generate arpeggio notes for each chord
	var arpNotes = ~song[\chordRoots].collect({ |root, i|
		var chord = ~song[\chordQualities][i];
		var arpPattern = [
			[0, 2, 1, 3, 0, 2, 1, 3],  // Pattern 1 (8 notes)
			[0, 1, 2, 3, 2, 1],  // Pattern 2 (6 notes)
			[0, 3, 2, 1, 0, 2, 3, 1],  // Pattern 3 (8 notes)
			[0, 1, 2, 3, 3, 2, 1, 0]  // Pattern 4 (8 notes)
		][i];
		arpPattern.collect({ |idx| root + chord.wrapAt(idx) })
	}).flatten;

	// Create pattern from the notes
	var arpPattern = Pbind(
		\instrument, \cfstring1,
		\midinote, Pseq(arpNotes, 1),
		\dur, 0.25,
		\amp, 0.3
	);

	// Apply density-based rhythm modification
	var densityModified = Pbindf(arpPattern,
		\dur, Pkey(\dur) / ~song[\globalDensity].clip(0.5, 2.0)
	);

	// Apply global dynamics with offset
	var withDynamics = Pbindf(densityModified,
		\amp, (~song[\globalDynamics] * 0.7 + 0.2) * Pkey(\amp)
	);

	// Add brightness control (could map to filter cutoff)
	Pbindf(withDynamics,
		\brightness, ~song[\globalBrightness]
	);
};

// Voice 3: Melody - Top voice with motivic development
~song[\melodyVoice] = {
	// Define melodic motifs that develop over time
	var motif1 = [0, 2, 3, 2, 0];
	var motif2 = [3, 2, 0, 1, 0];
	var motif3 = [0, 1, 2, 3, 4, 3, 2, 1];

	// Generate melody notes for each chord using motifs
	var melodyNotes = ~song[\chordRoots].collect({ |root, i|
		var chord = ~song[\chordQualities][i];
		var motifs = [motif1, motif2, motif3, motif1];
		var currentMotif = motifs[i % motifs.size];

		// Repeat motif to fill the chord duration
		var repeats = (~song[\chordDurations][i] * ~song[\barDuration] * 4 / currentMotif.size).ceil.asInteger;
		currentMotif.dup(repeats).flatten.collect({ |degree|
			root + 12 + chord.wrapAt(degree)
		})
	}).flatten;

	var melodyPattern = Pbind(
		\instrument, \blip,
		\midinote, Pseq(melodyNotes, 1),
		\dur, 0.125,
		\amp, 0.4
	);

	// Apply transformations based on song position
	var transformed = ~pipe.(
		{ |p|
			// Vary rhythm with density
			Pbindf(p,
				\dur, Pif(
					~song[\globalDensity] > 0.8,
					Pseq([0.125, 0.125, 0.25], inf),
					Pkey(\dur)
				)
			)
		},
		{ |p|
			// Add ornaments in bright sections
			Pbindf(p,
				\midinote, Pif(
					~song[\globalBrightness] > 0.7,
					Pseq([Pkey(\midinote), Pkey(\midinote) + 1, Pkey(\midinote)], 1),
					Pkey(\midinote)
				)
			)
		}
	).(melodyPattern);

	// Apply global dynamics with slight lead
	var withDynamics = Pbindf(transformed,
		\amp, (~song[\globalDynamics] * 1.2).clip(0, 1) * Pkey(\amp)
	);

	// Add legato variations
	Pbindf(withDynamics,
		\legato, Pif(
			~song[\globalBrightness] > 0.6,
			0.3,  // Staccato when bright
			0.9   // Legato when mellow
		)
	);
};

// Master sequencer - Combines all voices with proper synchronization
~song[\arrangement] = {
	// Create sections with different voice combinations
	var intro = Pfindur(
		2 * ~song[\barDuration],
		~song[\bassVoice].value
	);

	var verse1 = Pfindur(
		4 * ~song[\barDuration],
		Ppar([
			~song[\bassVoice].value,
			~song[\harmonyVoice].value
		])
	);

	var chorus = Pfindur(
		4 * ~song[\barDuration],
		Ppar([
			~song[\bassVoice].value,
			~song[\harmonyVoice].value,
			~song[\melodyVoice].value
		])
	);

	var verse2 = Pfindur(
		4 * ~song[\barDuration],
		Ppar([
			// Transformed versions of the original voices
			~patternOps[\transpose].(5).(~song[\bassVoice].value),
			~patternOps[\stretch].(1.5).(~song[\harmonyVoice].value)
		])
	);

	var outro = Pfindur(
		2 * ~song[\barDuration],
		~patternOps[\stretch].(2.0).(
			~song[\melodyVoice].value
		)
	);

	// Sequence the sections
	Pseq([
		intro,
		verse1,
		chorus,
		verse2,
		outro
	], 1);
};

// Alternative: Full parallel version with all voices throughout
~song[\fullArrangement] = {
	Pfindur(
		~song[\totalBars] * ~song[\barDuration],
		Ppar([
			~song[\bassVoice].value,
			Pfindur(  // Harmony enters after intro
				(~song[\totalBars] - 1) * ~song[\barDuration],
				Rest(1 * ~song[\barDuration]) <> ~song[\harmonyVoice].value
			),
			Pfindur(  // Melody enters later
				(~song[\totalBars] - 2) * ~song[\barDuration],
				Rest(2 * ~song[\barDuration]) <> ~song[\melodyVoice].value
			)
		])
	);
};

// Play functions
~playSong = {
	"Playing arranged song structure...".postln;
	~songPlayer = ~song[\arrangement].value.play;
};

~playFullSong = {
	"Playing full parallel arrangement...".postln;
	~songPlayer = ~song[\fullArrangement].value.play;
};

~stopSong = {
	~songPlayer.stop;
	"Song stopped.".postln;
};

"Pattern song loaded. Use ~playSong.value or ~playFullSong.value to play.".postln;
)

// Play the arranged version
~playSong.value;

// Or play the full parallel version
// ~playFullSong.value;

// Stop playback
// ~stopSong.value;

// Individual voice testing
// ~song[\bassVoice].value.play;
// ~song[\harmonyVoice].value.play;
// ~song[\melodyVoice].value.play;
