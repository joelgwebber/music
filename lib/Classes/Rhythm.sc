/*
Rhythm - Pattern-based rhythm generator with various rhythm patterns

Rhythm represents timing patterns with rational durations (numerator/denominator),
velocities, and gate values. Uses integer subdivisions for exact timing.

The denominator represents the subdivision unit (e.g., 4=quarters, 8=eighths, 12=triplets)
The numerators represent how many subdivisions each note occupies.

Example usage:
  Rhythm.straight(8)      // 8 equal notes: numerators=[1,1,1,1,1,1,1,1], denom=8
  Rhythm.swing(4)         // 4 swing pairs: numerators=[2,1,2,1,2,1,2,1], denom=12
  Rhythm.note(4)          // Single note: numerators=[4], denom=4
*/

Rhythm : Pattern {
  var <numerators, <denominator, <velocities, <gates, <timebase;

  /*
  Create a single sustained note rhythm.

  Arguments:
    dur - Duration of the note in beats (default: 1)
    vel - Velocity/amplitude (default: 0.7)

  Example:
    Rhythm.note(1)   // Single whole note: [1] / 1
    Rhythm.note(4)   // Single 4-beat note: [4] / 4
  */
  *note { |dur = 1, vel = 0.7|
    // A single note measure: numerator = denominator = duration
    var denom = dur.asInteger.max(1);
    ^Rhythm([denom], denom, [vel]);
  }

  /*
  Create a straight rhythm pattern with even spacing.

  Arguments:
    n - Number of steps (default: 4)
    vel - Velocity/amplitude (default: 0.7)

  Example:
    Rhythm.straight(4)   // 4 equal notes: [1,1,1,1] / 4
    Rhythm.straight(8)   // 8 equal notes: [1,1,1,1,1,1,1,1] / 8
    Rhythm.straight(3)   // 3 equal notes: [1,1,1] / 3
  */
  *straight { |n = 4, vel = 0.7|
    var numerators = Array.fill(n, 1);
    var vels = Array.fill(n, vel);
    ^Rhythm(numerators, n, vels);
  }

  /*
  Create a triplet swing rhythm pattern with 2:1 ratio (long-short pairs).

  Arguments:
    n - Number of swing pairs (default: 4)
    vel - Base velocity (default: 0.7)

  Example:
    Rhythm.swing(4)  // 4 swing pairs (8 notes): [2,1,2,1,2,1,2,1] / 12

  Creates triplet-based swing where each pair takes 3 subdivisions:
    long note = 2 subdivisions, short note = 1 subdivision
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

    ^Rhythm(numerators, denom, vels);
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
    type - Clave type: \son, \rumba, or \bossa (default: \son)

  Returns a 16-step pattern with 5 hits distributed according to the clave type:

    Son clave (3-2):   |X..X|..X.|..X.|X...|  (hits at 0,3,6,10,12)
    Rumba clave (3-2): |X..X|...X|..X.|X...|  (hits at 0,3,7,10,12)
    Bossa clave:       |X..X|..X.|..X.|.X..|  (hits at 0,3,6,10,13)

  Example:
    Rhythm.clave(\son)  // [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1] / 16 with vel pattern
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
    ^Rhythm(numerators, 16, vels);
  }

  /*
  Create a Euclidean rhythm pattern that distributes hits evenly across steps.

  Arguments:
    hits - Number of hits to distribute (k)
    steps - Total number of steps (n)
    vel - Velocity for hits (default: 0.7)

  Uses Bjorklund's algorithm to generate rhythms used in traditional music
  from around the world. Distributes k hits as evenly as possible across n steps.
  Creates a measure with steps subdivisions, using velocity to control hits/rests.

  Common patterns:
    E(3,8):  |X..X|..X.|  - Tresillo (Cuban)
    E(5,8):  |X.X.|X.XX|  - Cinquillo (Cuban)
    E(5,12): |X..X.|X..X.|..  - West African bell pattern
    E(7,12): |X.X.|X.X.|X.X.X.  - Common in Persian music

  Example:
    Rhythm.euclidean(5, 8).play;

  Algorithm visualization for E(5,8):
    Start:  [1][1][1][1][1] | [0][0][0]
    Step 1: [1,0][1,0][1,0] | [1][1]
    Step 2: [1,0,1][1,0,1]  | [1,0]
    Result: [1,0,1,0,1,0,1,1]
  */
  *euclidean { |hits, steps, vel = 0.7|
    var pattern = this.bjorklund(hits, steps);
    var numerators = Array.fill(steps, 1);  // All equal subdivisions
    var vels = pattern.collect { |v| if(v == 1, vel, 0) };  // Velocity controls hits/rests
    ^Rhythm(numerators, steps, vels);
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
  Create a new Rhythm from integer numerators, denominator, velocities, gates, and timebase.

  Arguments:
    numerators - Array of integer numerators (subdivision counts per note)
    denominator - Integer denominator (subdivision unit: 4=quarters, 8=eighths, 12=triplets)
    velocities - Array of velocities/amplitudes (default: 0.7 for all)
    gates - Array of gate/legato values (default: 0.9 for all)
    timebase - Global duration multiplier (default: 1)

  Example:
    Rhythm([1, 1, 1, 1], 4, [0.8, 0.6, 0.8, 0.9])  // Four quarter notes
    Rhythm([2, 1, 2, 1], 3, [0.8, 0.6, 0.8, 0.6])  // Swing eighths (triplet feel)
  */
  *new { |numerators, denominator, velocities = nil, gates = nil, timebase = 1|
    ^super.new.init(numerators, denominator, velocities, gates, timebase);
  }

  init { |inNumerators, inDenominator, inVelocities, inGates, inTimebase|
    var sum = inNumerators.sum;

    // Validate that numerators sum equals denominator (well-formed measure)
    if (sum != inDenominator) {
      Error("Rhythm validation failed: numerators sum (%) != denominator (%). "
            "Numerators must sum to denominator to form a complete measure."
            .format(sum, inDenominator)).throw;
    };

    numerators = inNumerators;
    denominator = inDenominator;
    velocities = inVelocities ?? Array.fill(numerators.size, 0.7);
    gates = inGates ?? Array.fill(numerators.size, 0.9);
    timebase = inTimebase;
  }

  /*
  Returns scaled durations as floats (numerators / denominator * timebase).
  */
  durations {
    ^numerators.collect({ |num| (num / denominator) * timebase });
  }

  /*
  Returns total duration of one cycle through the pattern.
  */
  totalDuration {
    ^(numerators.sum / denominator) * timebase;
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
    ^Rhythm(
      numerators.reverse,
      denominator,
      velocities.reverse,
      gates.reverse,
      timebase
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

    ^Rhythm(
      newNums,
      lcm,
      velocities ++ other.velocities,
      gates ++ other.gates,
      timebase
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
    ^Rhythm(
      numerators.copyRange(start, end),
      denominator,
      velocities.copyRange(start, end),
      gates.copyRange(start, end),
      timebase
    );
  }

  /*
  Pattern embedInStream implementation. Loops infinitely, yielding events
  with \dur, \amp, and \legato keys set from the rhythm data.
  */
  embedInStream { |inval|
    inf.do { |i|
      inval[\dur] = (numerators.wrapAt(i) / denominator) * timebase;
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
    groupBy - Number of steps per group (default: rhythm length, nil = no grouping)

  Returns a string showing subdivisions with 'X' for hits and '.' for continuations.

  Examples:
    Rhythm.clave(\son).asString      // |X..X..X...X.X...|
    Rhythm.euclidean(5, 8).asString  // |X.X.X.XX|
    Rhythm.swing(4).asString(3)      // |X.X|X.X|X.X|X.X|
  */
  asString { |groupBy|
    var str = "";
    var subdivPos = 0;
    var noteIdx = 0;
    groupBy = groupBy ?? denominator;

    // Iterate through each subdivision in the measure
    denominator.do { |subdivIdx|
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

    ^"|" ++ str ++ "| (" ++ numerators.size ++ " notes, " ++ numerators.sum ++ "/" ++ denominator ++ ")";
  }
}
