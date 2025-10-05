/*
Rhythm - Pattern-based rhythm generator with various rhythm patterns

Rhythm represents timing patterns using rational durations (numerators/denominator),
velocities, and gate values. Uses integer subdivisions for exact timing.

Duration Model:
  - denominator: Subdivision resolution per beat (1=whole, 4=quarters, 8=eighths, 12=triplets)
  - numerators[i]: Duration of note i, measured in subdivisions
  - Note duration in beats = numerators[i] / denominator
  - Total pattern duration = numerators.sum / denominator beats

Factory Methods:
  Most create 1-beat rhythmic patterns (straight, swing, clave, euclidean)
  Rhythm.note() creates sustained notes of arbitrary duration

Examples:
  Rhythm.straight(8)      // 8 equal notes in 1 beat:  [1,1,1,1,1,1,1,1]/8, total=1 beat
  Rhythm.straight(8, 4)   // 8 equal notes in 4 beats: [1,1,1,1,1,1,1,1]/2, total=4 beats
  Rhythm.swing(4)         // 4 swing pairs in 1 beat:  [2,1,2,1,2,1,2,1]/12, total=1 beat
  Rhythm.note(4)          // Single 4-beat note: [4]/1, total=4 beats
  Rhythm.euclidean(5, 8)  // 5 hits in 8 steps, 1 beat: [1,1,1,1,1,1,1,1]/8, total=1 beat
*/

Prhythm : Pattern {
  var <numerators, <denominator, <velocities, <gates;

  /*
  Create a single sustained note rhythm.

  Arguments:
    beats - Beats to cover
    vel - Velocity/amplitude

  Example:
    Rhythm.note(1)     // Single 1-beat note: [1] / 1
    Rhythm.note(4)     // Single 4-beat note: [4] / 1
  */
  *note { |beats = 1, vel = 0.7|
    // Single sustained note: denominator=1 (whole note resolution)
    ^Prhythm([beats], 1, [vel]);
  }

  /*
  Create a straight rhythm pattern with even spacing.

  Arguments:
    notes - Number of notes
    beats - Beats to cover
    vel - Velocity/amplitude

  Creates equal notes across any number of beats(each note = notes/beats beat).

  Examples:
    Rhythm.straight(4)     // 4 quarter notes over 1 beat        |xxxx|
    Rhythm.straight(8)     // 8 eighth notes over 1 beat         |xxxx xxxx|
    Rhythm.straight(8, 2)  // 8 eighth notes over 2 beats:       |xxxx|xxxx|
    Rhythm.straight(6)     // 6 notes (2 triplets) over 1 beat   |xx xx xx|
    Rhythm.straight(6, 3)  // 6 notes (2 triplets) over 3 beats: |xx|xx|xx|
  */
  *straight { |notes = 4, beats = 1, vel = 0.7|
    var numerators, vels;

    if ((notes/beats).frac != 0) {
      Error("notes / beats (% / %) must be integral".format(notes, beats)).throw;
    };

    numerators = Array.fill(notes, 1);
    vels = Array.fill(notes, vel);
    ^Prhythm(numerators, notes/beats, vels);
  }

  /*
  Create a triplet swing rhythm pattern with 2:1 ratio (long-short pairs).

  Arguments:
    n - Number of swing pairs
    vel - Base velocity

  Creates n swing pairs in 1 beat total using triplet subdivisions.
  Each pair takes 3 subdivisions: long note = 2, short note = 1.
  This creates the classic jazz/blues swing feel.

  Examples:
    Rhythm.swing(4)  // 4 swing pairs (8 notes): [2,1,2,1,2,1,2,1]/12, total=1 beat
    Rhythm.swing(2)  // 2 swing pairs (4 notes): [2,1,2,1]/6, total=1 beat
  */
  *swing { |n = 4, vel = 0.7|
    var numerators = Array.new(n * 2);
    var vels = Array.new(n * 2);
    var denom = n * 3;  // n pairs, each pair takes 3 subdivisions

    n.do { |i|
      numerators.add(2);  // Long note
      numerators.add(1);  // Short note
      vels.add(vel);
      vels.add(vel * 0.8);
    };

    ^Prhythm(numerators, denom, vels);
  }

  /*
  Find appropriate denominator for a duration.
  Uses common subdivisions: 4 (sixteenths), 3 (triplets), 12 (fine triplets), etc.
  */
  *findDenominator { |dur|
    var candidates = [4, 3, 8, 12, 16, 6, 24];
    candidates.do { |denom|
      var product = dur * denom;
      if ((product - product.round).abs < 0.001) { ^denom };
    };
    ^12;  // Default fallback
  }

  /*
  Create traditional Latin clave patterns (3-2 orientation).

  Arguments:
    type - Clave type: \son, \rumba, or \bossa

  Returns a 1-beat pattern with 16 subdivisions and 5 hits distributed according to type:

    Son clave (3-2):   |X..X|..X.|..X.|X...|  (hits at 0,3,6,10,12)
    Rumba clave (3-2): |X..X|...X|..X.|X...|  (hits at 0,3,7,10,12)
    Bossa clave:       |X..X|..X.|..X.|.X..|  (hits at 0,3,6,10,13)

  Example:
    Rhythm.clave(\son)  // [1,1,1,...,1]/16, total=1 beat, velocity pattern controls hits
  */
  *clave { |type = \son|
    var patterns = (
      // Son clave: hits at steps 0, 3, 6, 10, 12
      son: [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0],
      // Rumba clave: hits at steps 0, 3, 7, 10, 12
      rumba: [1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0],
      // Bossa clave: hits at steps 0, 3, 6, 10, 13
      bossa: [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0]
    );
    var pattern = patterns[type] ?? patterns[\son];
    var numerators = Array.fill(16, 1);  // All equal subdivisions
    var vels = pattern.collect { |v| if(v == 1, 0.8, 0) };  // Velocity controls hits/rests
    ^Prhythm(numerators, 16, vels);
  }

  /*
  Create a Euclidean rhythm pattern that distributes hits evenly across steps.

  Arguments:
    hits - Number of hits to distribute (k)
    steps - Total number of steps (n)
    vel - Velocity for hits

  Uses Bjorklund's algorithm to generate rhythms used in traditional music
  from around the world. Distributes k hits as evenly as possible across n steps.
  Creates a 1-beat pattern with `steps` subdivisions, using velocity to control hits/rests.

  Common patterns (all 1 beat total):
    E(3,8):  |X..X..X.|  - Tresillo (Cuban)
    E(5,8):  |X.X.X.XX|  - Cinquillo (Cuban)
    E(5,12): |X..X.X..X.X.|  - West African bell pattern
    E(7,12): |X.X.X.X.X.X.X.|  - Common in Persian music

  Example:
    Rhythm.euclidean(5, 8)  // [1,1,1,1,1,1,1,1]/8, total=1 beat

  Algorithm visualization for E(5,8):
    Start:  [1][1][1][1][1] | [0][0][0]
    Step 1: [1,0][1,0][1,0] | [1][1]
    Step 2: [1,0,1][1,0,1]  | [1,0]
    Result: [1,0,1,0,1,0,1,1] (pattern applied via velocities)
  */
  *euclidean { |hits, steps, vel = 0.7|
    var pattern = this.bjorklund(hits, steps);
    var numerators = Array.fill(steps, 1);  // All equal subdivisions
    var vels = pattern.collect { |v| if(v == 1, vel, 0) };  // Velocity controls hits/rests
    ^Prhythm(numerators, steps, vels);
  }

  /*
  Bjorklund's algorithm for generating Euclidean rhythm patterns.

  Arguments:
    hits - Number of hits (k)
    steps - Total number of steps (n)

  Returns an array of 1s (hits) and 0s (rests) distributed as evenly as possible.
  This is the core algorithm used by *euclidean, exposed for direct use.

  The algorithm repeatedly pairs groups until only one remainder group is left,
  similar to the Euclidean GCD algorithm. The result is a maximally even
  distribution of hits across steps.

  Example:
    Rhythm.bjorklund(5, 8)  // => [1,0,1,0,1,0,1,1]

  How it works for E(5,8):
    Initial: [1] [1] [1] [1] [1] | [0] [0] [0]
             └──────5 ones──────┘   └─3 zeros─┘

    Iteration 1: Pair 3 ones with 3 zeros
             [1,0] [1,0] [1,0] | [1] [1]
             └─────3 pairs────┘   └2 left─┘

    Iteration 2: Pair 2 compound with 2 remaining
             [1,0,1] [1,0,1] | [1,0]
             └───2 pairs───┘   └1 left┘

    Done: Flatten to [1,0,1,0,1,0,1,1]
  */
  *bjorklund { |hits, steps|
    var pattern, counts;

    if (hits > steps) { hits = steps };
    if (hits == 0) { ^Array.fill(steps, 0) };
    if (hits == steps) { ^Array.fill(steps, 1) };

    // Build pattern as array of groups: hits [1]s, (steps-hits) [0]s
    pattern = Array.fill(hits, { [1] }) ++ Array.fill(steps - hits, { [0] });
    counts = [hits, steps - hits];

    // Repeatedly pair up groups until we can't anymore
    while { (counts[1] > 1) && (counts[0] > 0) } {
      var numPairs = min(counts[0], counts[1]);
      var newPattern = Array.new;

      // Pair up elements from both groups
      numPairs.do { |i|
        newPattern = newPattern.add(pattern[i] ++ pattern[counts[0] + i]);
      };

      // Append remaining unpaired elements
      if (counts[0] > numPairs) {
        (counts[0] - numPairs).do { |i|
          newPattern = newPattern.add(pattern[numPairs + i]);
        };
      };
      if (counts[1] > numPairs) {
        (counts[1] - numPairs).do { |i|
          newPattern = newPattern.add(pattern[counts[0] + numPairs + i]);
        };
      };

      pattern = newPattern;
      counts = [newPattern.size - (counts[1] - numPairs), counts[1] - numPairs];
    };

    ^pattern.flatten;
  }

  /*
  Create a new Rhythm from integer numerators, denominator, velocities, and gates.

  Arguments:
    numerators - Array of subdivision counts (duration of each note in subdivisions)
    denominator - Subdivision resolution per beat (1=whole, 4=quarters, 8=eighths, 12=triplets)
    velocities - Array of velocities/amplitudes
    gates - Array of gate/legato values

  Duration calculation:
    Each note's duration in beats = numerators[i] / denominator
    Total duration in beats = numerators.sum / denominator

  Examples:
    Prhythm([1, 1, 1, 1], 4)       // Four quarter notes (total: 1 beat)
    Prhythm([2, 1, 2, 1], 6)       // Swing eighths (total: 1 beat)
    Prhythm([4], 1)                // Single 4-beat note
    Prhythm([3, 3, 2], 8)          // Mixed eighths (total: 1 beat)
  */
  *new { |numerators, denominator, velocities = nil, gates = nil|
    ^super.new.init(numerators, denominator, velocities, gates);
  }

  init { |inNumerators, inDenominator, inVelocities, inGates|
    numerators = inNumerators;
    denominator = inDenominator;
    velocities = inVelocities ?? Array.fill(numerators.size, 0.7);
    gates = inGates ?? Array.fill(numerators.size, 0.9);
  }

  /*
  Returns scaled durations as floats (numerators / denominator).
  Each value represents the duration of that note in beats.

  Example:
    Rhythm.straight(4).durations    // => [0.25, 0.25, 0.25, 0.25]
    Rhythm.note(3).durations        // => [3.0]
    Rhythm.swing(2).durations       // => [0.333, 0.166, 0.333, 0.166]
  */
  durations {
    ^numerators.collect({ |num| (num / denominator) });
  }

  /*
  Returns total duration of one cycle through the pattern in beats.

  Examples:
    Rhythm.straight(4).totalDuration   // => 1.0 beat
    Rhythm.note(12).totalDuration      // => 12.0 beats
    Rhythm.swing(4).totalDuration      // => 1.0 beat
  */
  totalDuration {
    ^(numerators.sum / denominator);
  }

  /*
  Returns number of steps in the rhythm.
  */
  size {
    ^numerators.size;
  }

  /*
  Returns a new Rhythm with steps in reverse order.

  Example:
    Rhythm.euclidean(5, 8).reverse.asString
  */
  reverse {
    ^Prhythm(
      numerators.reverse,
      denominator,
      velocities.reverse,
      gates.reverse
    );
  }

  /*
  Concatenates two rhythm patterns.

  Note: If rhythms have different denominators, finds LCM and scales accordingly.

  Example:
    Rhythm.straight(4) ++ Rhythm.euclidean(3, 8)
  */
  ++ { |other|
    var lcm = this.lcm(denominator, other.denominator);
    var scale1 = lcm / denominator;
    var scale2 = lcm / other.denominator;
    var newNums = (numerators * scale1) ++ (other.numerators * scale2);

    ^Prhythm(
      newNums,
      lcm,
      velocities ++ other.velocities,
      gates ++ other.gates
    );
  }

  /*
  Returns a subsequence of the rhythm from start to end (inclusive).

  Arguments:
    start - Starting index (0-based)
    end - Ending index (inclusive)

  Example:
    Rhythm.euclidean(5, 8).copyRange(0, 3)  // First 4 steps
  */
  copyRange { |start, end|
    ^Prhythm(
      numerators.copyRange(start, end),
      denominator,
      velocities.copyRange(start, end),
      gates.copyRange(start, end)
    );
  }

  /*
  Pattern embedInStream implementation. Loops infinitely, yielding events
  with \dur, \amp, and \legato keys set from the rhythm data.
  */
  embedInStream { |inval|
    inf.do { |i|
      inval[\dur] = (numerators.wrapAt(i) / denominator);
      inval[\amp] = velocities.wrapAt(i);
      inval[\legato] = gates.wrapAt(i);
      inval = inval.yield;
    };
    ^inval
  }

  /*
  Calculate least common multiple of two integers.
  */
  lcm { |a, b|
    ^(a * b) / this.gcd(a, b);
  }

  /*
  Calculate greatest common divisor of two integers.
  */
  gcd { |a, b|
    var temp;
    while { b != 0 } {
      temp = b;
      b = a % b;
      a = temp;
    };
    ^a;
  }

  /*
  Format rhythm as text notation for visualization.

  Arguments:
    groupBy - Number of subdivisions per group (default: denominator, nil = no grouping)

  Returns a string showing subdivisions with 'X' for hits and '.' for continuations/rests.
  Includes metadata showing note count and total duration (numerators.sum/denominator).

  Examples:
    Rhythm.clave(\son).asString       // |X..X..X...X.X...| (16 notes, 16/16)
    Rhythm.euclidean(5, 8).asString   // |X.X.X.XX| (8 notes, 8/8)
    Rhythm.swing(4).asString(3)       // |X.X|X.X|X.X|X.X| (8 notes, 12/12)
    Rhythm.note(4).asString           // |X| (1 notes, 4/1)
  */
  asString { |groupBy|
    var str = "";
    var subdivPos = 0;
    var noteIdx = 0;
    var totalSubdivisions = numerators.sum;
    groupBy = groupBy ?? denominator;

    // Iterate through each subdivision in the pattern
    totalSubdivisions.do { |subdivIdx|
      var numerator, vel;

      // Add grouping separator
      if ((subdivIdx > 0) && (groupBy.notNil) && (subdivIdx % groupBy == 0)) {
        str = str ++ "|";
      };

      // Check if this subdivision starts a new note
      numerator = numerators.wrapAt(noteIdx);
      vel = velocities.wrapAt(noteIdx);

      if (subdivPos == 0) {
        // Start of a note
        if (vel > 0) {
          str = str ++ "X";
        } {
          str = str ++ ".";  // Rest
        };
        subdivPos = subdivPos + 1;
      } {
        // Continuation of current note
        str = str ++ ".";
        subdivPos = subdivPos + 1;
      };

      // Move to next note if we've used up this note's duration
      if (subdivPos >= numerator) {
        subdivPos = 0;
        noteIdx = noteIdx + 1;
      };
    };

    ^"|%| (% beats)".format(str, this.totalDuration);
  }
}
