// Represents an ordered group of notes, in a specific tuning.
//
// TODO:
// - Parameterize root frequency.
Notes : Pattern {
  var <tuning;

  *new { |tuning = (Tuning.at(\et12))|
    ^super.new.init(tuning);
  }

  init { |inTuning|
    tuning = inTuning;
  }

  // Returns the pitch class for a given note.
  pitchClass{ |note|
    var sign = note.sign;
    note = note.abs.mod(tuning.size);
    ^case
      {note == 0} {0}
      {sign > 0}  {note}
      {sign < 0}  {tuning.size-note}
    ;
  }

  size { ^this.notes.size }

  freqs {
    var mod = tuning.size;
    var pcs = all {:this.pitchClass(note), note <- this.notes};
    var octs = 440 * (2 ** floor(this.notes / mod));
    ^all {:round(tuning.ratios[pcs[i]] * octs[i]), i <- (0..this.notes.size-1)};
  }

  // Derived classes must provide a .notes method
  notes { this.subclassResponsibility(thisMethod); ^nil }

  embedInStream { |inval|
    var freqList = this.freqs;
    inf.do { |i|
      inval[\freq] = freqList.wrapAt(i);
      inval = inval.yield;
    };
    ^inval
  }
}

