// TODO:
// - Handle 2nd/6th interval transforms
//
// Chords in the 12-tone chromatic scale, with no explicit tonal root.
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
Chromatic : Chord {
  classvar <names, <tuning;

  *initClass {
    Class.initClassTree(Tuning); // You'd think this wouldn't be necessary, but...
    tuning = Tuning.at(\et12);
    names = ['A', 'A♯', 'B', 'C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯'];
  }

  // Swaps the major and minor thirds in an array of intervals.
  *swapThirds { |intervals|
    ^all {:switch(i)
      {3} {4}
      {4} {3}
      {i}, i <- intervals};
  }

  *new { |root, intervals, octave = 0, inversion = 0|
    ^super.new(root, intervals, octave, inversion, tuning);
  }

  *newFrom { |chord|
    ^super.new(chord.root, chord.intervals, chord.octave, chord.inversion, tuning);
  }

  // Returns an array of this chord's note names.
  // For chromatic chords, it will always use sharps rather than flats.
  names { ^all {:this.noteName(note), note <- this.notes} }

  // Returns the diatonic name of the given note.
  noteName { |note| ^names[this.pitchClass(note)] }

  union { |other| ^Chromatic.newFrom(super.union(other)) }
  oct { |steps| ^Chromatic(root, intervals, octave + steps, inversion) }
  invert { |steps| ^Chromatic(root, intervals, octave, (inversion + steps) % this.size, tuning) }

  // Parallel transform:
  // Returns a chord whose major and minor thirds are swapped.
  // The root is left unchanged.
  parallel {
    ^Chromatic(root, Chromatic.swapThirds(intervals), octave);
  }

  // Thirds transform:
  // Returns a chord whose root is adjusted by the specfied number of thirds,
  // adjusting its major/minor third intervals as necessary.
  //
  // This is equivalent to one of the neo-Riemannian R/L transforms,
  // depending upon whether the starting chord is major or minor.
  thirds { |steps|
    var up = steps.sign, cur = this;
    steps = steps.abs;
    steps.do { cur = (up > 0).if { cur.upThird } { cur.downThird } };
    ^cur;
  }

  upThird {
    var newRoot = root + intervals[0];
    var newInts = Chromatic.swapThirds(intervals);
    ^Chromatic(newRoot, newInts, octave);
  }

  downThird {
    var newInts = Chromatic.swapThirds(intervals);
    var newRoot = root - newInts[0];
    ^Chromatic(newRoot, newInts, octave);
  }

  // TODO:doc
  extend { |steps|
    var cur = this;
    steps.abs.do { cur = cur.union(cur.thirds(steps.sign)) };
    ^cur;
  }

  // Neo-Riemannian transformations

  // Relative transformation (R): Major <-> relative minor
  // C major (C-E-G) -> A minor (A-C-E)
  // A minor (A-C-E) -> C major (C-E-G)
  relative {
    var isMajor = (intervals[0] == 4);
    ^isMajor.if(
      { this.thirds(1) },  // Major to minor: up a third
      { this.thirds(-1) }  // Minor to major: down a third
    );
  }

  // Leading-tone exchange (L): Major <-> minor via leading tone
  // C major (C-E-G) -> E minor (E-G-B)
  // E minor (E-G-B) -> C major (C-E-G)
  leadingTone {
    var isMajor = (intervals[0] == 4);
    ^isMajor.if(
      { this.thirds(2) },   // Major to minor: up two thirds
      { this.thirds(-2) }   // Minor to major: down two thirds
    );
  }

  // Parallel transformation (P): Major <-> parallel minor
  // C major (C-E-G) -> C minor (C-Eb-G)
  // Already implemented above

  // Slide transformation (S): slides the third
  // C major (C-E-G) -> C# minor (C#-E-G#)
  slide {
    var isMajor = (intervals[0] == 4);
    var newRoot = isMajor.if(
      { root + 1 },  // Major: root up semitone
      { root - 1 }   // Minor: root down semitone
    );
    ^Chromatic(newRoot, Chromatic.swapThirds(intervals), octave);
  }

  // Nebenverwandt (N): combines R, L, and P
  // C major -> Eb major
  nebenverwandt {
    var isMajor = (intervals[0] == 4);
    ^isMajor.if(
      { Chromatic(root + 3, intervals, octave) },     // Major: up minor third
      { Chromatic(root - 3, intervals, octave) }      // Minor: down minor third
    );
  }

  // Hexatonic pole (H): maximally distant in neo-Riemannian space
  // C major (C-E-G) -> Ab minor (Ab-B-Eb)
  hexatonicPole {
    var isMajor = (intervals[0] == 4);
    ^isMajor.if(
      { Chromatic(root + 8, [3, 4], octave) },    // Major to minor tritone away
      { Chromatic(root + 8, [4, 3], octave) }     // Minor to major tritone away
    );
  }

  // Apply a sequence of neo-Riemannian operations
  // ops: string of operations, e.g. "PLR" or "RLRL"
  neoRiemannian { |ops|
    var chord = this;
    ops.do { |op|
      chord = switch(op,
        $P, { chord.parallel },
        $L, { chord.leadingTone },
        $R, { chord.relative },
        $S, { chord.slide },
        $N, { chord.nebenverwandt },
        $H, { chord.hexatonicPole },
        { chord } // default: no change
      );
    };
    ^chord;
  }
}

