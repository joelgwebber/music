(
Server.local.boot;
~midi = SimpleMIDIFile.read("/Users/joel/src/rs/music/midi/moonlight_1.mid");
)

(
~getVoices = { |m|
	var voices, trackNames, tracksWithNotes, activeNotes;
	var allEvents, noteList;

	// Get track names and filter to those with actual note events
	trackNames = m.trackNames();
	tracksWithNotes = m.noteOnEvents().collect { |e| e[0] }.asSet.asArray.sort;

	// Create active notes tracking for duration calculation
	activeNotes = IdentityDictionary.new;
	tracksWithNotes.do { |track| activeNotes[track] = IdentityDictionary.new };

	// Process all MIDI events to calculate note durations
	// Sort by time, then by velocity (0 velocity = noteOff comes first)
	allEvents = (m.noteOnEvents() ++ m.noteOffEvents()).sort { |a, b|
		if (a[1] == b[1]) {
			// Same timestamp: sort by velocity (0 comes before positive)
			a[5] < b[5]
		} {
			a[1] < b[1]
		}
	};
	noteList = IdentityDictionary.new;
	tracksWithNotes.do { |track| noteList[track] = [] };

	allEvents.do { |event|
		var track = event[0];
		var ticks = event[1];
		var eventType = event[2];
		var channel = event[3];
		var pitch = event[4];
		var velocity = event[5];
		var beat = m.beatAtTime(ticks);

		if (tracksWithNotes.includes(track)) {
			if (eventType == \noteOn && (velocity > 0)) {
				// Start a note
				activeNotes[track][pitch] = (beat: beat, velocity: velocity, startTicks: ticks);
			} {
				// Note off (or noteOn with velocity 0)
				if (activeNotes[track][pitch].notNil) {
					var startNote = activeNotes[track][pitch];
					var duration = beat - startNote.beat;
					noteList[track] = noteList[track].add((
						beat: startNote.beat,
						pitch: pitch,
						velocity: startNote.velocity,
						duration: duration
					));
					activeNotes[track][pitch] = nil;
				};
			};
		};
	};

	// Convert to named voices using track names
	voices = ();
	tracksWithNotes.do { |trackNum|
		var trackName = trackNames.detect { |pair| pair[0] == trackNum };
		var voiceName = if (trackName.notNil) {
			trackName[1].asString.toLower.replace(" ", "_").asSymbol
		} {
			("track_" ++ trackNum).asSymbol
		};
		voices[voiceName] = noteList[trackNum];
	};

	// Group simultaneous notes into chords (within 0.1 beat tolerance)
	voices = voices.collect { |voice|
		var grouped = [];
		var currentGroup = [];
		var lastBeat = -1;

		voice.do { |note|
			if ((note.beat - lastBeat).abs < 0.1) {
				currentGroup = currentGroup.add(note);
			} {
				if (currentGroup.size > 0) {
					grouped = grouped.add(currentGroup);
				};
				currentGroup = [note];
				lastBeat = note.beat;
			};
		};
		if (currentGroup.size > 0) {
			grouped = grouped.add(currentGroup);
		};
		grouped
	};

	voices
};

// Add tempo map extraction
~getTempoMap = { |m|
	var tempoMap = m.tempoMap();
	tempoMap.collect { |pair|
		var ticks = pair[0];
		var bpm = pair[1];
		var beats = m.beatAtTime(ticks);
		(beat: beats, bpm: bpm, ticks: ticks)
	}
};

// Create full analysis structure
~analyzeMoonlight = { |m|
	var voices = ~getVoices.(m);
	var tempoMap = ~getTempoMap.(m);
	var trackNames = m.trackNames();

	(
		metadata: (
			title: "Moonlight Sonata",
			key: \Cs,
			timeSignature: [4, 4],
			tempoMap: tempoMap,
			trackNames: trackNames
		),
		voices: voices
	)
};

~analysis = ~analyzeMoonlight.(~midi);

// Preview the voices
"Available voices:".postln;
~analysis.voices.keys.do { |key| key.postln };
"".postln;

// Show tempo map
"Tempo map:".postln;
~analysis.metadata.tempoMap.postln;
"".postln;

// Add smart quantization for pattern conversion
~quantizeVoices = { |voices, subdivision=12|
	var quantizedVoices = ();

	voices.keysValuesDo { |voiceName, chordEvents|
		quantizedVoices[voiceName] = chordEvents.collect { |chordGroup|
			// Quantize the beat position
			var originalBeat = chordGroup[0].beat; // All notes in group have same beat
			var quantizedBeat = (originalBeat * subdivision).round / subdivision;

			// Update all notes in the chord group
			chordGroup.collect { |note|
				note.put(\beat, quantizedBeat);
				note.put(\quantizedDuration, (note.duration * subdivision).round / subdivision);
				note
			}
		}
	};

	quantizedVoices
};

// Convert to pattern-ready format
~toPatternFormat = { |voices|
	var patternVoices = ();

	voices.keysValuesDo { |voiceName, chordEvents|
		patternVoices[voiceName] = chordEvents.collect { |chordGroup|
			if (chordGroup.size == 1) {
				// Single note
				(
					beat: chordGroup[0].beat,
					notes: [chordGroup[0].pitch],
					duration: chordGroup[0].quantizedDuration,
					velocity: chordGroup[0].velocity
				)
			} {
				// Chord - collect all pitches
				(
					beat: chordGroup[0].beat,
					notes: chordGroup.collect(_.pitch).sort,
					duration: chordGroup[0].quantizedDuration, // Assume same duration
					velocity: chordGroup.collect(_.velocity).mean // Average velocity
				)
			}
		}
	};

	patternVoices
};

// Re-run analysis with fixed duration calculation
~analysis = ~analyzeMoonlight.(~midi);

// Create quantized and pattern-ready versions
~quantizedVoices = ~quantizeVoices.(~analysis.voices);
~patternVoices = ~toPatternFormat.(~quantizedVoices);

// Preview first few events from each voice
~analysis.voices.keysValuesDo { |voiceName, events|
	(voiceName.asString ++ " (first 3 chord events):").postln;
	events[0..2].postln;
	"".postln;
};

"Pattern-ready format:".postln;
~patternVoices.keysValuesDo { |voiceName, events|
	(voiceName.asString ++ " (first 3 pattern events):").postln;
	events[0..2].postln;
	"".postln;
};

// Example: Convert bass chords to Pchord objects
"Bass chord conversion examples:".postln;
~bassChords = ~patternVoices.piano_left.collect { |event|
	if (event.notes.size > 1) {
		Pchord.fromMIDI(event.notes)
	} {
		nil  // Skip single notes
	}
}.select(_.notNil);

~bassChords[0..2].do { |chord, i|
	("Bass chord " ++ i ++ ": " ++ chord.names).postln;
};

// COMPOSITION ANALYSIS AND GENERATION
// Simple Roman numeral analysis helper (define first)
~getRomanNumeral = { |chord, key|
	var keyRoot = [\C, \Cs, \D, \Ds, \E, \F, \Fs, \G, \Gs, \A, \As, \B].indexOf(key);
	var chordRoot = chord.root;
	var interval = (chordRoot - keyRoot) % 12;
	var isMajor = (chord.intervals[0] == 4);

	// Basic chord degree mapping
	var degree = case
		{ interval == 0 } { isMajor.if("I", "i") }
		{ interval == 1 } { isMajor.if("♭II", "♭ii") }
		{ interval == 2 } { isMajor.if("II", "ii") }
		{ interval == 3 } { isMajor.if("♭III", "♭iii") }
		{ interval == 4 } { isMajor.if("III", "iii") }
		{ interval == 5 } { isMajor.if("IV", "iv") }
		{ interval == 6 } { isMajor.if("♭V", "♭v") }
		{ interval == 7 } { isMajor.if("V", "v") }
		{ interval == 8 } { isMajor.if("♭VI", "♭vi") }
		{ interval == 9 } { isMajor.if("VI", "vi") }
		{ interval == 10 } { isMajor.if("♭VII", "♭vii") }
		{ interval == 11 } { isMajor.if("VII", "vii") };

	degree
};

// Extract harmonic progression with Roman numeral analysis
~analyzeHarmony = { |patternVoices, key=\Cs|
	var bassEvents, chords, progression;

	// Check if piano_left voice exists
	if (patternVoices.piano_left.isNil) {
		"Warning: No piano_left voice found".postln;
		^(events: [], chords: [], progression: [])
	};

	bassEvents = patternVoices.piano_left.select { |event| event.notes.size.asInteger > 1 };

	chords = bassEvents.collect { |event|
		var chord = Pchord.fromMIDI(event.notes);
		var measure = (event.beat / 4).floor; // Assuming 4/4 time
		(
			beat: event.beat,
			measure: measure,
			chord: chord,
			notes: event.notes,
			duration: event.duration,
			// Simple Roman numeral analysis (could be enhanced)
			roman: ~getRomanNumeral.(chord, key)
		)
	};

	(events: bassEvents, chords: chords, progression: chords.collect(_.roman))
};

// Extract rhythm patterns from timing data
~extractRhythms = { |patternVoices, beatsPerMeasure=4|
	var rhythms = ();

	patternVoices.keysValuesDo { |voiceName, events|
		var beats = events.collect(_.beat);
		var durations = events.collect(_.duration);
		var measureLength = beatsPerMeasure;

		// Skip empty voices
		if (beats.size == 0) {
			rhythms[voiceName] = (
				beats: [],
				durations: [],
				pattern: [],
				prhythm: "Prhythm.note(1)" // Default: single whole note
			);
		} {
			var maxBeat, arraySize, rhythmArray, sampleSize, patternSample;

			// Create rhythm pattern - mark active beats
			maxBeat = beats.maxItem.ceil;
			arraySize = (maxBeat * 4).asInteger;
			if (arraySize < 16) { arraySize = 16 }; // Minimum 16
			rhythmArray = Array.fill(arraySize, 0); // 16th note resolution

			events.do { |event|
				var startIndex = (event.beat * 4).round.asInteger;
				var durationIndices = (event.duration * 4).round.asInteger;
				// Check bounds before accessing array
				if (startIndex < rhythmArray.size) {
					rhythmArray[startIndex] = 1; // Mark attack point
				};
			};

			sampleSize = rhythmArray.size;
			if (sampleSize > 16) { sampleSize = 16 }; // Limit to first 16 elements

			patternSample = rhythmArray[0..(sampleSize-1)];

			rhythms[voiceName] = (
				beats: beats,
				durations: durations,
				pattern: rhythmArray,
				// Create appropriate Prhythm pattern based on voice type (simplified)
				prhythm: case
					{ voiceName.asString.contains("left") } {
						"Prhythm.note(4)"  // Bass: simple whole notes
					}
					{ voiceName.asString.contains("right_second") } {
						"Prhythm.straight(12, 4)"  // Accompaniment: triplet arpeggios
					}
					{ voiceName.asString.contains("right_first") } {
						"Prhythm.straight(4, 4)"   // Melody: quarter notes
					}
					{ "Prhythm.note(1)" }  // Default
			);
		}; // Close the else block
	};

	rhythms
};

// Convert MIDI voices to Pvoice-ready format
~generateVoices = { |patternVoices, harmony|
	var voices = ();

	patternVoices.keysValuesDo { |voiceName, events|
		var melodyNotes, chordNotes, timbre;

		// Skip empty voices
		if (events.size == 0) {
			"Warning: Empty voice " ++ voiceName.postln;
		} {
			var firstEvent, noteCount;

			// Determine voice type and timbre
			timbre = case
				{ voiceName.asString.contains("left") } {
					"(instrument: \\piano, amp: 0.4, sustain: 4)"
				}
				{ voiceName.asString.contains("right") } {
					"(instrument: \\piano, amp: 0.3, sustain: 2)"
				}
				{ "(instrument: \\piano, amp: 0.3)" }
			;

			// Extract musical content - check if first event has multiple notes
			firstEvent = events[0];
			noteCount = firstEvent.notes.size;

			if (noteCount.asInteger > 1) {
				// Multi-note voice (chords)
				chordNotes = events.collect { |event|
					Pchord.fromMIDI(event.notes).names
				};
				voices[voiceName] = (
					type: \chord,
					content: chordNotes,
					timbre: timbre,
					pattern: events
				);
			} {
				// Single-note voice (melody)
				melodyNotes = events.collect { |event| event.notes[0] };
				voices[voiceName] = (
					type: \melody,
					content: melodyNotes,
					timbre: timbre,
					pattern: events
				);
			};
		}; // Close the if statement
	};

	voices
};

// Segment into phrases based on harmonic rhythm
~segmentPhrases = { |harmony, beatsPerPhrase=8|
	var phrases = [];
	var currentPhrase = [];
	var currentBeat = 0;
	var finalPhraseSize;

	harmony.chords.do { |chord|
		var beatDiff = (chord.beat - currentBeat).asFloat;
		var phraseSize = currentPhrase.size.asInteger;
		if ((beatDiff >= beatsPerPhrase) && (phraseSize > 0)) {
			phrases = phrases.add(currentPhrase);
			currentPhrase = [chord];
			currentBeat = chord.beat;
		} {
			currentPhrase = currentPhrase.add(chord);
		};
	};

	finalPhraseSize = currentPhrase.size.asInteger;
	if (finalPhraseSize > 0) {
		phrases = phrases.add(currentPhrase);
	};

	phrases
};

// Generate SuperCollider composition code
~generateComposition = { |patternVoices, harmony, title="MIDI Analysis"|
	var voices = ~generateVoices.(patternVoices, harmony);
	var phrases = ~segmentPhrases.(harmony);
	var rhythms = ~extractRhythms.(patternVoices);
	var code = "";

	// Header
	code = code ++ "(\n";
	code = code ++ "// " ++ title ++ " - Generated from MIDI analysis\n";
	code = code ++ "Server.local.boot;\n";
	code = code ++ "\"/Users/joel/src/rs/music/piano.scd\".load;\n";
	code = code ++ ")\n\n";

	// Clock and timbres
	code = code ++ "(\n";
	code = code ++ "~clock = TempoClock(60/60); // Adjust tempo as needed\n\n";
	code = code ++ "~left  = (instrument: \\piano, amp: 0.4, sustain: 4);\n";
	code = code ++ "~right = (instrument: \\piano, amp: 0.3, sustain: 2);\n\n";

	// Rhythm definitions
	code = code ++ "// Rhythm patterns extracted from MIDI\n";
	rhythms.keysValuesDo { |voiceName, rhythm|
		code = code ++ "~" ++ voiceName.asString ++ "Rhythm = " ++ rhythm.prhythm ++ ";\n";
	};

	// Harmonic progression
	code = code ++ "\n// Harmonic progression: " ++ harmony.progression.join(" - ") ++ "\n";
	code = code ++ "~phrases = [\n";

	phrases.do { |phrase, i|
		var measureStart = phrase[0].measure;
		var measureEnd = phrase.last.measure;
		var chordNames = phrase.collect { |chord| chord.chord.names.join("-") };
		var phraseStartBeat, phraseEndBeat;

		code = code ++ "  // Phrase " ++ (i+1) ++ " (M" ++ (measureStart+1) ++ "-" ++ (measureEnd+1) ++ "): " ++ chordNames.join(", ") ++ "\n";
		code = code ++ "  Pphrase(" ++ ((phrase.last.beat - phrase[0].beat) + phrase.last.duration) ++ ", (\n";

		// Generate voices for this phrase - extract phrase-specific melody content
		phraseStartBeat = phrase[0].beat;
		phraseEndBeat = phrase.last.beat + phrase.last.duration;

		voices.keysValuesDo { |voiceName, voice|
			var voiceCode = case
				{ voiceName.asString.contains("left") } { "bass" }
				{ voiceName.asString.contains("right_second") } { "arpeggio" }
				{ voiceName.asString.contains("right_first") } { "melody" }
				{ voiceName.asString.replace("piano_", "").replace("_", "") };

			if (voice.type == \chord) {
				// Generate readable bass chord using the phrase's chord data
				var chord = phrase[0].chord; // Pchord object from harmonic analysis
				var rootNote = Notation.numberToNote(chord.root);
				var chordCode;

				// Create readable chord constructor based on interval pattern
				if (chord.intervals == [12]) {
					// Octave doubling - single note
					chordCode = "Pmelody([\\" ++ Notation.midiToSymbol(chord.root + 24) ++ "])"; // Octave 2
				} {
					if (chord.intervals == [3, 4]) {
						// Minor triad
						chordCode = "Pchord.minor(\\" ++ rootNote ++ ", 2)";
					} {
						if (chord.intervals == [4, 3]) {
							// Major triad
							chordCode = "Pchord.major(\\" ++ rootNote ++ ", 2)";
						} {
							// Complex chord - fall back to constructor
							chordCode = "Pchord(\\" ++ rootNote ++ ", " ++ chord.intervals ++ ", 2)";
						};
					};
				};

				code = code ++ "    " ++ voiceCode ++ ": Pvoice(" ++ chordCode ++ ", ~" ++ voiceName.asString ++ "Rhythm, ~left),\n";
			} {
				// Extract events that occur within this phrase's time window
				var phraseEvents = patternVoices[voiceName].select { |event|
					(event.beat >= phraseStartBeat) && (event.beat < phraseEndBeat)
				};

				if (phraseEvents.size > 0) {
					var eventSample, melodyNotes, pitchClasses, averageOctave, midiNoteList, melodyCode;

					// Use all events in the phrase, don't limit to 8
					eventSample = phraseEvents;

					// Extract melody notes for this phrase
					melodyNotes = eventSample.collect { |event| event.notes[0] };

					// Generate readable notation using the new converter
					melodyCode = ~generateMelodyCode.(melodyNotes, voiceName, true); // true = use notation
					code = code ++ "    " ++ voiceCode ++ ": Pvoice(" ++ melodyCode ++ ", ~" ++ voiceName.asString ++ "Rhythm, ~right),\n";
				} {
					// Skip voices with no events in this phrase instead of generating defaults
					("    // " ++ voiceCode ++ ": No events in this phrase, skipping\n").postln;
				};
			};
		};

		code = code ++ "  )),\n\n";
	};

	code = code ++ "];\n\n";

	// Playback code
	code = code ++ "// Print section details with tablature\n";
	code = code ++ "~phrases.do { |section, i| section.asTab.postln };\n\n";
	code = code ++ "// Play phrases sequentially\n";
	code = code ++ "~composition = Pseq(~phrases);\n";
	code = code ++ "~player = ~composition.play(~clock);\n";
	code = code ++ ")\n\n";
	code = code ++ "~player.stop;\n";

	code
};
)

// COMPLETE ANALYSIS AND GENERATION PIPELINE
(
"=== MOONLIGHT SONATA ANALYSIS ===".postln;

// Check prerequisites
if (~patternVoices.isNil) {
	"❌ Error: ~patternVoices not defined. Run previous analysis blocks first.".postln;
} {
	try {
		var file, codeLines, maxLines;

		// Run harmonic analysis
		~harmony = ~analyzeHarmony.(~patternVoices, \Cs);
		("Harmonic progression: " ++ ~harmony.progression.join(" - ")).postln;
		"".postln;

		// Extract rhythm patterns
		~rhythms = ~extractRhythms.(~patternVoices);
		"Rhythm patterns extracted:".postln;
		~rhythms.keysValuesDo { |voice, rhythm|
			var maxIndex, beatSample;
			maxIndex = rhythm.beats.size - 1;
			if (maxIndex > 4) { maxIndex = 4 };
			beatSample = if (maxIndex >= 0) { rhythm.beats[0..maxIndex] } { [] };
			(voice.asString ++ ": " ++ beatSample.round(0.01)).postln;
		};
		"".postln;

		// Generate composition code
		~compositionCode = ~generateComposition.(~patternVoices, ~harmony, "Moonlight Sonata");

		// Save to file
		file = File.new("moonlight_generated.scd", "w");
		file.write(~compositionCode);
		file.close;
		"✅ Generated composition saved to moonlight_generated.scd".postln;

		// Print first few measures as preview
		"".postln;
		"=== GENERATED CODE PREVIEW ===".postln;
		codeLines = ~compositionCode.split($\n);
		maxLines = codeLines.size - 1;
		if (maxLines > 20) { maxLines = 20 };
		codeLines[0..maxLines].do(_.postln);
		"... (see moonlight_generated.scd for full code)".postln;

	} { |error|
		("❌ Analysis failed: " ++ error.errorString).postln;
		error.dumpBackTrace;
	};
};
)

(
// SMART MIDI→NOTATION CONVERTER
~midiToNotation = { |midiNotes, key = \Cs|
    // Converts array of MIDI numbers to octave-specific symbols
    // midiNotes: Array of MIDI note numbers
    // key: Key context for enharmonic spelling (future enhancement)
    // Returns: Array of symbols like [\Gs3, \Cs4, \E4]

    midiNotes.collect { |midi|
        Notation.midiToSymbol(midi);
    };
};

// DUAL-FORMAT MELODY GENERATOR
~generateMelodyCode = { |melodyNotes, voiceName, useNotation = true|
    // Generates Pmelody code in either notation or raw MIDI format
    // melodyNotes: Array of MIDI note numbers
    // voiceName: Voice name for rhythm lookup
    // useNotation: If true, use symbols; if false, use raw MIDI
    // Returns: String of SuperCollider code

    // DEBUG: Print the actual MIDI numbers being processed
    ("DEBUG - " ++ voiceName ++ " melody notes: " ++ melodyNotes[0..7]).postln;
    if (melodyNotes.size > 0) {
        var firstNote = melodyNotes[0];
        var pc = firstNote % 12;
        var symbol = Notation.midiToSymbol(firstNote);
        ("DEBUG - First note: MIDI=" ++ firstNote ++ " PC=" ++ pc ++ " Symbol=" ++ symbol).postln;
    };

    if (useNotation) {
        var symbols = ~midiToNotation.(melodyNotes);
        var symbolList = symbols.collect { |sym| "\\" ++ sym.asString }.join(", ");
        "Pmelody([" ++ symbolList ++ "])";
    } {
        var midiList = melodyNotes.join(", ");
        "Pmelody([" ++ midiList ++ "])";
    };
};
)

// Regenerate composition with extended notation system and debug output
(
"=== REGENERATING WITH DEBUG OUTPUT ===".postln;
~compositionCode = ~generateComposition.(~patternVoices, ~harmony, "Moonlight Sonata");
File.new("moonlight_generated.scd", "w").write(~compositionCode).close;
"✅ Regenerated composition with debug output".postln;
"Check the console output above to see what MIDI numbers are being processed.".postln;
)

