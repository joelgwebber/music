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
}

