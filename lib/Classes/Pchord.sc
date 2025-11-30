// Chords in the 12-tone chromatic scale.
//
// The Tonnetz (tone network) below shows the lattice of major/minor third relationships
// used by neo-Riemannian transformations. Horizontal lines = major thirds (4 semitones),
// diagonal lines = minor thirds (3 semitones). Each triangle represents a triad.
//
//    E♭----B♭----F♮----C♮----G♮----D♮----A♮----E♮
//   /  \  /  \  /  \  /  \  /  \  /  \  /  \  /  \
// B♮----G♭----D♭----A♭----E♭----B♭----F♮----C♮----G♮
//   \  /  \  /  \  /  \  /  \  /  \  /  \  /  \  /  \
//    D♮----A♮----E♮----B♮----G♭----D♭----A♭----E♭----B♭
//   /  \  /  \  /  \  /  \  /  \  /  \  /  \  /  \  /
// B♭----F♮----C♮----G♮----D♮----A♮----E♮----B♮----G♭
//   \  /  \  /  \  /  \  /  \  /  \  /  \  /  \  /  \
//    D♭----A♭----E♭----B♭----F♮----C♮----G♮----D♮----A♮
//   /  \  /  \  /  \  /  \  /  \  /  \  /  \  /  \  /
// A♮----E♮----B♮----G♭----D♭----A♭----E♭----B♭----F♮
//
Pchord : Pitches {
  classvar <names;
  var <root, <intervals, <octave, <inversion;

  *initClass {
    Class.initClassTree(Notation);
    names = ['C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯', 'A', 'A♯', 'B'];
  }

  // Swaps major and minor thirds in an interval array (3 ↔ 4).
  // intervals: Array of semitone intervals.
  // Returns: Array with swapped thirds.
  *swapThirds { |intervals|
    ^all {:switch(i)
      {3} {4}
      {4} {3}
      {i}, i <- intervals};
  }

  // Creates a new Pchord from raw parameters.
  // root: Chromatic pitch class (0-11) or note symbol.
  // intervals: Array of semitone intervals between successive notes.
  // octave: Base octave for the chord.
  // inversion: Chord inversion (0 = root position).
  // Returns: New Chord instance.
  *new { |root, intervals, octave = 0, inversion = 0|
    ^super.new.initChord(root, intervals, octave, inversion);
  }

  initChord { |inRoot, inIntervals, inOctave, inInversion|
    root = Notation.noteToNumber(inRoot);
    intervals = inIntervals;
    octave = inOctave;
    inversion = inInversion;
  }

  // Creates a copy of an existing Chord.
  // chord: Chord instance to copy.
  // Returns: New Chord with same properties.
  *newFrom { |chord|
    ^Pchord(chord.root, chord.intervals, chord.octave, chord.inversion);
  }

  // Creates a Chord from a Roman numeral in a given key.
  // key: Key symbol (e.g., \C, \Am, \Gm).
  // numeral: Roman numeral symbol (e.g., \I, \vi, \V7).
  // octave: Base octave for the chord.
  // Returns: Chord corresponding to the numeral in the key.
  *inKey { |key = \C, numeral, octave = 0|
    var keyRoot, mode;
    #keyRoot, mode = Notation.parseKey(key);
    ^Notation.romanToChord(keyRoot, mode, numeral, octave);
  }

  // Creates a Chord from a chord symbol.
  // symbol: Chord symbol (e.g., \Cmaj7, \Dm7, \G7).
  // octave: Base octave for the chord.
  // Returns: Chord matching the symbol.
  *fromSymbol { |symbol, octave = 0|
    ^Notation.symbolToChord(symbol, octave);
  }

  // Creates a major triad.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Major triad Chord.
  *major { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [4, 3], octave);
  }

  // Creates a minor triad.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Minor triad Chord.
  *minor { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [3, 4], octave);
  }

  // Creates a dominant 7th chord.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Dominant 7th Chord.
  *dom7 { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [4, 3, 3], octave);
  }

  // Creates a major 7th chord.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Major 7th Chord.
  *maj7 { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [4, 3, 4], octave);
  }

  // Creates a minor 7th chord.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Minor 7th Chord.
  *min7 { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [3, 4, 3], octave);
  }

  // Creates a diminished triad.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Diminished triad Chord.
  *dim { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [3, 3], octave);
  }

  // Creates an augmented triad.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Augmented triad Chord.
  *aug { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [4, 4], octave);
  }

  // Creates a suspended 4th chord.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Sus4 Chord.
  *sus4 { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [5, 2], octave);
  }

  // Creates a suspended 2nd chord.
  // root: Root note (number 0-11 or note symbol).
  // octave: Base octave for the chord.
  // Returns: Sus2 Chord.
  *sus2 { |root, octave = 0|
    ^Pchord(Notation.noteToNumber(root), [2, 5], octave);
  }

  // Creates a Pchord from MIDI note numbers.
  // midiNotes: Array of MIDI note numbers (e.g., [60, 64, 67] for C major).
  // Returns: Pchord with calculated root, intervals, and octave.
  *fromMIDI { |midiNotes|
    var sortedNotes, root, intervals, octave;

    if (midiNotes.size == 0) {
      Error("Cannot create chord from empty array").throw;
    };

    // Sort notes and remove duplicates
    sortedNotes = midiNotes.as(Set).as(Array).sort;

    // Calculate root pitch class and octave from lowest note
    root = sortedNotes[0] % 12;
    octave = (sortedNotes[0] / 12).floor - 5; // MIDI octave adjustment

    // Calculate intervals between consecutive notes
    intervals = [];
    (sortedNotes.size - 1).do { |i|
      intervals = intervals ++ [sortedNotes[i+1] - sortedNotes[i]];
    };

    ^Pchord(root, intervals, octave);
  }

  // Generates the actual note numbers for this chord.
  // Returns: Array of chromatic note numbers including octave.
  notes {
    var curNote = root + (tuning.size * octave);
    var result = [curNote];
    intervals.do { |interval|
      curNote = curNote + interval;
      result = result ++ [curNote];
    };
    ^if (inversion > 0) {
      result.rotate(inversion.neg).collect({ |note, i|
        if (i < inversion) { note + tuning.size } { note }
      });
    } {
      result;
    };
  }

  // Gets the note names for all notes in the chord.
  // Returns: Array of note name symbols.
  names { ^all {:this.noteName(note), note <- this.notes} }

  // Converts a note number to its name symbol.
  // note: Chromatic note number.
  // Returns: Note name symbol.
  noteName { |note| ^names[this.pitchClass(note)] }

  // Combines this chord with another, creating a new chord with all unique notes.
  // other: Another Chord to combine with.
  // Returns: New Chord containing all unique notes from both chords.
  union { |other|
    var allNotes = (this.notes ++ other.notes).as(Set).as(Array).sort;
    var newIntervals = [];
    (allNotes.size - 1).do { |i|
      newIntervals = newIntervals ++ [allNotes[i+1] - allNotes[i]];
    };
    ^Pchord(allNotes[0] - (tuning.size * octave), newIntervals, octave);
  }

  // Transposes the chord by octaves.
  // steps: Number of octaves to transpose (positive = up, negative = down).
  // Returns: New transposed Chord.
  oct { |steps| ^Pchord(root, intervals, octave + steps, inversion) }

  // Creates an inversion of this chord.
  // steps: Number of inversions to apply.
  // Returns: New inverted Chord.
  invert { |steps| ^Pchord(root, intervals, octave, (inversion + steps) % this.size) }

  // Transposes the chord by semitones.
  // semitones: Number of semitones to transpose (positive = up, negative = down).
  // Returns: New transposed Chord.
  transpose { |semitones| ^Pchord(root + semitones, intervals, octave, inversion) }

  // Converts a minor triad to major by swapping the third intervals.
  // Returns: New Chord with major quality.
  toMajor {
    var newIntervals = intervals.copy;
    // Swap minor third to major third structure
    if (newIntervals.size >= 2 && newIntervals[0] == 3 && newIntervals[1] == 4) {
      newIntervals[0] = 4;
      newIntervals[1] = 3;
    };
    ^Pchord(root, newIntervals, octave);
  }

  // Converts a major triad to minor by swapping the third intervals.
  // Returns: New Chord with minor quality.
  toMinor {
    var newIntervals = intervals.copy;
    // Swap major third to minor third structure
    if (newIntervals.size >= 2 && newIntervals[0] == 4 && newIntervals[1] == 3) {
      newIntervals[0] = 3;
      newIntervals[1] = 4;
    };
    ^Pchord(root, newIntervals, octave);
  }

  // Adds a 7th to the chord.
  // type: Type of 7th to add (\dom, \maj, or \min).
  // Returns: New Chord with added 7th.
  add7 { |type = \dom|
    var newIntervals = intervals.copy;
    var seventhInterval = case
      { type == \dom } { 3 }
      { type == \maj } { 4 }
      { type == \min } { 3 };
    ^Pchord(root, newIntervals ++ [seventhInterval], octave);
  }

  // Adds a 9th to the chord (includes 7th if not present).
  // Returns: New Chord with added 9th.
  add9 {
    var newIntervals = case
      { intervals.size == 2 } { intervals ++ [3, 4] }
      { intervals.size == 3 } { intervals ++ [4] }
      { intervals };
    ^Pchord(root, newIntervals, octave);
  }

  // Replaces the chord with a sus4 version.
  // Returns: New sus4 Chord.
  withSus4 {
    ^Pchord(root, [5, 2], octave);
  }

  // Replaces the chord with a sus2 version.
  // Returns: New sus2 Chord.
  withSus2 {
    ^Pchord(root, [2, 5], octave);
  }

  // Neo-Riemannian P transformation: swaps major ↔ minor.
  // Returns: New Chord with opposite quality.
  parallel {
    ^Pchord(root, Pchord.swapThirds(intervals), octave);
  }

  // Shorthand for parallel transformation.
  p { ^this.parallel }

  relative {
    // R: Relative transformation
    // Major → relative minor (e.g., C major → A minor: root + 9)
    // Minor → relative major (e.g., A minor → C major: root + 3)
    var isMajor = (intervals[0] == 4);
    if (isMajor) {
      // Major to relative minor (sixth down = 9 semitones up)
      ^Pchord(root + 9, Pchord.swapThirds(intervals), octave);
    } {
      // Minor to relative major (minor third up)
      ^Pchord(root + 3, Pchord.swapThirds(intervals), octave);
    };
  }

  // Shorthand for relative transformation.
  r { ^this.relative }

  leadingTone {
    // L: Leading-tone transformation
    // Major → up a major third to minor (e.g., C major → E minor)
    // Minor → down a major third to major (e.g., E minor → Ab major)
    var isMajor = (intervals[0] == 4);
    if (isMajor) {
      // Major to minor (up a major third)
      ^Pchord(root + 4, Pchord.swapThirds(intervals), octave);
    } {
      // Minor to major (down a major third)
      ^Pchord(root - 4, Pchord.swapThirds(intervals), octave);
    };
  }

  // Shorthand for leadingTone transformation.
  l { ^this.leadingTone }

  // Neo-Riemannian S transformation: chromatic third relation.
  // Major up 1 semitone to minor, minor down 1 semitone to major.
  // Returns: New transformed Chord.
  slide {
    var isMajor = (intervals[0] == 4);
    var newRoot = isMajor.if(
      { root + 1 },
      { root - 1 }
    );
    ^Pchord(newRoot, Pchord.swapThirds(intervals), octave);
  }

  // Shorthand for slide transformation.
  s { ^this.slide }

  // Neo-Riemannian N transformation: combination of R, L, and P.
  // Major up minor third, minor down minor third (preserves quality).
  // Returns: New transformed Chord.
  nebenverwandt {
    var isMajor = (intervals[0] == 4);
    ^isMajor.if(
      { Pchord(root + 3, intervals, octave) },
      { Pchord(root - 3, intervals, octave) }
    );
  }

  // Shorthand for nebenverwandt transformation.
  n { ^this.nebenverwandt }

  // Neo-Riemannian H transformation: hexatonic pole.
  // Moves to the opposite pole in the hexatonic cycle.
  // Returns: New transformed Chord.
  hexatonicPole {
    var isMajor = (intervals[0] == 4);
    ^isMajor.if(
      { Pchord(root + 8, [3, 4], octave) },
      { Pchord(root + 8, [4, 3], octave) }
    );
  }

  // Shorthand for hexatonicPole transformation.
  h { ^this.hexatonicPole }

  // Applies a sequence of neo-Riemannian transformations.
  // ops: String of operation characters (P, L, R, S, N, H).
  // Returns: New transformed Chord after all operations.
  neoRiemannian { |ops|
    var chord = this;
    ops.do { |op|
      chord = switch(op,
        $P, { chord.p },
        $L, { chord.l },
        $R, { chord.r },
        $S, { chord.s },
        $N, { chord.n },
        $H, { chord.h },
        { chord }
      );
    };
    ^chord;
  }

  // Generates an arpeggiated Melody from this Chord.
  // pattern: Arpeggio pattern (\up, \down, \upDown, \downUp, or custom Array).
  // Returns: Melody with arpeggiated notes.
  arp { |pattern = \up|
    var notes = this.notes;
    var arpNotes = switch(pattern,
      \up, { notes },
      \down, { notes.reverse },
      \upDown, { notes ++ notes.reverse[1..notes.size-2] },
      \downUp, { notes.reverse ++ notes[1..notes.size-2] },
      {
        if (pattern.isKindOf(Array)) {
          pattern.collect({ |idx| notes.wrapAt(idx) });
        } {
          Error("Invalid arpeggio pattern: %".format(pattern)).throw;
        }
      }
    );
    ^Pmelody(arpNotes, tuning);
  }

  // Creates a Pattern that plays this chord's notes in sequence.
  // inst: Instrument name to use.
  // duration: Duration between notes.
  // Returns: Pbind pattern.
  asPattern { |inst = \default, duration = 1|
    ^Pbind(
      \instrument, inst,
      \freq, Pseq(this.freqs, inf),
      \dur, duration
    );
  }

  embedInStream { |inval|
    inf.do {
      inval[\freq] = this.freqs;
      inval = inval.yield;
    };
    ^inval;
  }
}
