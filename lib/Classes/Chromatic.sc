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
  classvar <names;

  *initClass {
    names = ['A', 'A♯', 'B', 'C', 'C♯', 'D', 'D♯', 'E', 'F', 'F♯', 'G', 'G♯'];
  }

  // Returns the diatonic name of the given note.
  *noteName { |note|
    ^names[Chord.pitchClass(note, 12)];
  }

  // Swaps the major and minor thirds in an array of intervals.
  *swapThirds { |intervals|
    ^all {:switch(i)
      {3} {4}
      {4} {3}
      {i}, i <- intervals};
  }

  *new { |root, intervals, octave = 0, inversion = 0|
    ^super.new.init(root, intervals, octave, inversion, Tuning.at(\et12));
  }

  // Returns an arraw of this chord's note names.
  names {
    ^all {:Chromatic.noteName(note), note <- this.notes};
  }

  // Octave transform:
  // Returns a chord whose root is adjusted by a number of octaves.
  oct { |steps|
    ^Chromatic(root, intervals, octave + steps);
  }

  // Parallel transform:
  // Returns a chord whose major and minor thirds are swapped.
  // The root is left unchanged.
  parallel {
    ^Chromatic(root, Chromatic.swapThirds(intervals), octave);
  }

  // Up transform:
  // Inverse of the down transform.
  up { |steps = 1|
    var newRoot = root, newInts = intervals;
    steps.do {
      newRoot = newRoot + newInts[0];
      newInts = Chromatic.swapThirds(newInts);
    }
    ^Chromatic(newRoot, newInts, octave);
  }

  // Down transform:
  // Returns a chord whose major and minor thirds are swapped,
  // and whose root is down a third (major or minor).
  // This is equivalent to one of the neo-Riemannian R/L transforms,
  //   depending upon whether the starting chord is major or minor.
  down { |steps = 1|
    var newRoot = root, newInts = intervals;
    steps.do {
      newInts = Chromatic.swapThirds(newInts);
      newRoot = newRoot - newInts[0];
    };
    ^Chromatic(newRoot, newInts, octave);
  }
}

