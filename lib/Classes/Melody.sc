Melody : Notes {
  var <>notes;

  *new { |notes, tuning = (Tuning.at(\et12))|
    ^super.new(tuning).initMelody(notes);
  }

  initMelody { |inNotes|
    notes = inNotes;
  }

  ++ { |other|
    ^Melody(notes ++ other.notes, tuning);
  }

  // Transposes all notes by octaves
  octave { |steps|
    var transposedNotes = notes + (tuning.size * steps);
    ^Melody(transposedNotes, tuning);
  }
}

