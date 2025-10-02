// Represents a sequence of single notes that form a melodic line.
Melody : Notes {
  var <>notes;

  // Creates a new Melody from an array of note numbers.
  // notes: Array of chromatic note numbers or note symbols.
  // tuning: Tuning system to use (defaults to 12-tone equal temperament).
  // octave: Base octave offset (adds 12*octave to all notes).
  // Returns: New Melody instance.
  *new { |notes, tuning = (Tuning.et12), octave = 0|
    var processedNotes = notes.collect({ |note|
      var noteNum = Notation.noteToNumber(note);
      noteNum + (tuning.size * octave);
    });
    ^super.new(tuning).initMelody(processedNotes);
  }

  // Creates a Melody from a starting note and intervals.
  // start: Starting note (number 0-11 or note symbol).
  // intervals: Array of semitone intervals.
  // tuning: Tuning system to use.
  // octave: Base octave offset.
  // Returns: New Melody instance.
  *fromIntervals { |start, intervals, tuning = (Tuning.et12), octave = 0|
    var startNote = Notation.noteToNumber(start) + (tuning.size * octave);
    var melodyNotes = [startNote];
    var currentNote = startNote;

    intervals.do { |interval|
      currentNote = currentNote + interval;
      melodyNotes = melodyNotes.add(currentNote);
    };

    ^super.new(tuning).initMelody(melodyNotes);
  }

  // Creates a single-note Melody (convenience for bass lines).
  // note: Note number or symbol.
  // tuning: Tuning system to use.
  // octave: Octave offset.
  // Returns: New Melody instance with one note.
  *note { |note, tuning = (Tuning.et12), octave = 0|
    ^this.new([note], tuning, octave);
  }

  initMelody { |inNotes|
    notes = inNotes;
  }

  // Concatenates this melody with another.
  // other: Another Melody to append.
  // Returns: New combined Melody.
  ++ { |other|
    ^Melody(notes ++ other.notes, tuning);
  }

  // Transposes all notes by octaves.
  // steps: Number of octaves to transpose (positive = up, negative = down).
  // Returns: New transposed Melody.
  octave { |steps|
    var transposedNotes = notes + (tuning.size * steps);
    ^Melody(transposedNotes, tuning);
  }
}

