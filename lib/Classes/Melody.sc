// Represents a sequence of single notes that form a melodic line.
Melody : Notes {
  var <>notes;

  // Creates a new Melody from an array of note numbers.
  // notes: Array of chromatic note numbers.
  // tuning: Tuning system to use (defaults to 12-tone equal temperament).
  // Returns: New Melody instance.
  *new { |notes, tuning = (Tuning.at(\et12))|
    ^super.new(tuning).initMelody(notes);
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

