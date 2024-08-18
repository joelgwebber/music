// TODO: doc
// - Handle 2nd/6th interval transforms
//
// -C-
//
// -B♮
//    \                                                
//    -D♮----A♮----E♮----B♮                              
//       \  /  \  /  \  /  \                           
//        F♮----C♮----G♮----D♮----A♮----E♮----B♮
//              ^             \  /  \  /  \  /  \
//            tonic            F♮----C♮----G♮----D♮-
//                                   ^             \
//                                 tonic            F♮-
//
// -D-
//
// -C#
//    \
//    -E♮----B♮----F#----C#
//       \  /  \  /  \  /  \               
//        G♮----D♮----A♮----E♮-
//              ^             \
//             tonic           G♮-
//
// -etc-
//
Diatonic : Chord {
  classvar <upThirds, <dnThirds;
  var <tonic;

  *initClass {
    // This array contains the major (4) and minor (3) thirds found at each diatonic note.
    // It represents the thirds for A (tonic=0), and can simply be shifted to other keys
    //   by adjusting the index mod 12 (e.g., for C, subtract 4 from the array index).
    // It contains zeros for notes not in the given key.
    //
    //     B♭       D♭    E♭       G♭    A♭
    //  A  A# B  C  C# D  D# E  F  F# G  G#
    //  
    //  4     3     3  4     4     3     3   A
    //  3  4     3     3  4     4     3      A# Bb
    //     3  4     3     3  4     4     3   B
    //  3     3  4     3     3  4     4      C
    //     3     3  4     3     3  4     4   C# Db
    //  4     3     3  4     3     3  4      D
    //     4     3     3  4     3     3  4   D# Eb
    //  4     4     3     3  4     3     3   E
    //  3  4     4     3     3  4     3      F
    //     3  4     4     3     3  4     3   F# Eb
    //  3     3  4     4     3     3  4      G
    //     3     3  4     4     3     3  4   G# Ab
    //
    upThirds = [4, 0, 3, 0, 3, 4, 0, 4, 0, 3, 0, 3];
    dnThirds = [3, 0, 3, 0, 4, 3, 0, 3, 0, 4, 0, 4];
  }

  // TODO:: Validate root and intervals against tonic.
  *new { |tonic, root, intervals, octave = 0|
    ^super.new.init(tonic, root, intervals, octave);
  }

  init { |inTonic, inRoot, inIntervals, inOctave|
    super.init(inRoot, inIntervals, inOctave, Tuning.at(\et12));
    tonic = inTonic;
  }

  // Detach this diatonic chord from its tonic.
  chromatic {
    ^Chromatic(root, intervals, octave);
  }

  oct { |steps|
    ^Diatonic(tonic, root, intervals, octave + steps);
  }

  parallel {
    // TODO: adjust tonic and root to parallel key.
    var parallelTonic = tonic;
    var parallelRoot = root;
    ^Diatonic(parallelTonic, parallelRoot, Chromatic.swapThirds(intervals), octave);
  }

  up { |steps = 1|
    var cur = this;
    steps.do { cur = cur.upOne() };
    ^cur;
  }

  upOne {
    var newRoot = root + intervals[0];
    var note = newRoot, newInts = [];
    intervals.do { |interval|
      interval = this.adjustInterval(note, interval, false);
      note = note + interval;
      newInts = newInts ++ interval;
    };
    ^Diatonic(tonic, newRoot, newInts, octave);
  }

  down { |steps = 1|
    var cur = this;
    steps.do { cur = cur.downOne() };
    ^cur;
  }

  downOne {
    var newRoot = root - this.adjustInterval(root, intervals[0], true);
    var note = newRoot, newInts = [];
    intervals.do { |interval|
      interval = this.adjustInterval(note, interval, false);
      note = note + interval;
      newInts = newInts ++ interval;
    };
    ^Diatonic(tonic, newRoot, newInts, octave);
  }

  adjustInterval{ |note, interval, down|
    ^if ((interval == 3) || (interval == 4))
        { interval = this.thirdFor(note, down) }
        { interval };
  }

  thirdFor { |note, down|
    var pc = this.pitch(note - tonic);
    ^down.if { Diatonic.dnThirds[pc] } { Diatonic.upThirds[pc] };
  }

  // Returns an arraw of this chord's note names.
  names {
    ^all {:Chromatic.noteName(note), note <- this.notes};
  }
}

