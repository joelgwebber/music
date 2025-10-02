/*
Rhythm - Pattern-based rhythm generator with various rhythm patterns

Rhythm represents timing patterns with durations (including rests), velocities,
and gate values. It can generate common rhythm patterns like straight time,
swing, clave patterns, and Euclidean rhythms.

Example usage:
  Rhythm.straight(8, 0.25).play;
  Rhythm.clave(\son).asString;  // |X..X|..X.|..X.|X...|
  Rhythm.euclidean(5, 8, 0.25).play;
*/

Rhythm : Pattern {
  var <rawDurations, <velocities, <gates, <timebase;

  /*
  Create a single sustained note rhythm.

  Arguments:
    dur - Duration of the note (default: 1)
    vel - Velocity/amplitude (default: 0.7)

  Example:
    Rhythm.note(4)  // Single 4-beat note
  */
  *note { |dur = 1, vel = 0.7|
    ^Rhythm([dur], [vel]);
  }

  /*
  Create a straight rhythm pattern with even spacing.

  Arguments:
    n - Number of steps (default: 4)
    dur - Duration per step (default: 1)
    vel - Velocity/amplitude (default: 0.7)

  Example:
    Rhythm.straight(8, 0.25)  // |XXXX|XXXX| (8 steps)
  */
  *straight { |n = 4, dur = 1, vel = 0.7|
    var durs = Array.fill(n, dur);
    var vels = Array.fill(n, vel);
    ^Rhythm(durs, vels);
  }

  /*
  Create a swing rhythm pattern with uneven eighth notes.

  Arguments:
    n - Number of steps (default: 4)
    ratio - Swing ratio, where 0.67 = 2:1 triplet feel (default: 0.67)
    dur - Base duration (default: 1)
    vel - Base velocity (default: 0.7)

  Example:
    Rhythm.swing(8, 0.67, 0.25)  // Long-short pattern

  The ratio determines the proportion of duration for the first note:
    0.5 = straight (even)
    0.67 = triplet swing (2:1)
    0.75 = harder swing
  */
  *swing { |n = 4, ratio = 0.67, dur = 1, vel = 0.7|
    var durs = Array.new(n);
    var vels = Array.new(n);
    (n/2).asInteger.do { |i|
      durs.add(dur * ratio);
      durs.add(dur * (1 - ratio));
      vels.add(vel);
      vels.add(vel * 0.8);
    };
    if (n.odd) {
      durs.add(dur);
      vels.add(vel);
    };
    ^Rhythm(durs.keep(n), vels.keep(n));
  }

  /*
  Create traditional Latin clave patterns (3-2 orientation).

  Arguments:
    type - Clave type: \son, \rumba, or \bossa (default: \son)
    dur - Duration per step (default: 0.25)

  Returns a 16-step pattern with 5 hits distributed according to the clave type:

    Son clave (3-2):   |X..X|..X.|..X.|X...|  (hits at 0,3,6,10,12)
    Rumba clave (3-2): |X..X|...X|..X.|X...|  (hits at 0,3,7,10,12)
    Bossa clave:       |X..X|..X.|..X.|.X..|  (hits at 0,3,6,10,13)

  Example:
    Rhythm.clave(\son).play(TempoClock(120/60))
  */
  *clave { |type = \son, dur = 0.25|
    var patterns = (
      // Son clave: hits at steps 0, 3, 6, 10, 12
      son: [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0],
      // Rumba clave: hits at steps 0, 3, 7, 10, 12
      rumba: [1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0],
      // Bossa clave: hits at steps 0, 3, 6, 10, 13
      bossa: [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0]
    );
    var pattern = patterns[type] ?? patterns[\son];
    var durs = pattern.collect { |v|
      case
        { v == 1 } { dur }
        { true } { Rest(dur) };
    };
    var vels = pattern.collect { |v| if(v == 1, 0.8, 0) };
    ^Rhythm(durs, vels, timebase: 1);
  }

  /*
  Create a Euclidean rhythm pattern that distributes hits evenly across steps.

  Arguments:
    hits - Number of hits to distribute (k)
    steps - Total number of steps (n)
    dur - Duration per step (default: 1)
    vel - Velocity for hits (default: 0.7)

  Uses Bjorklund's algorithm to generate rhythms used in traditional music
  from around the world. Distributes k hits as evenly as possible across n steps.

  Common patterns:
    E(3,8):  |X..X|..X.|  - Tresillo (Cuban)
    E(5,8):  |X.X.|X.XX|  - Cinquillo (Cuban)
    E(5,12): |X..X.|X..X.|..  - West African bell pattern
    E(7,12): |X.X.|X.X.|X.X.X.  - Common in Persian music

  Example:
    Rhythm.euclidean(5, 8, 0.25).play;

  Algorithm visualization for E(5,8):
    Start:  [1][1][1][1][1] | [0][0][0]
    Step 1: [1,0][1,0][1,0] | [1][1]
    Step 2: [1,0,1][1,0,1]  | [1,0]
    Result: [1,0,1,0,1,0,1,1]
  */
  *euclidean { |hits, steps, dur = 1, vel = 0.7|
    var pattern = this.bjorklund(hits, steps);
    var durs = pattern.collect { |v|
      case
        { v == 1 } { dur }
        { true } { Rest(dur) };
    };
    var vels = pattern.collect { |v| if(v == 1, vel, 0) };
    ^Rhythm(durs, vels);
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
  Create a new Rhythm from durations, velocities, gates, and timebase.

  Arguments:
    durations - Array of durations (can include Rest() objects)
    velocities - Array of velocities/amplitudes (default: 0.7 for all)
    gates - Array of gate/legato values (default: 0.9 for all)
    timebase - Global duration multiplier (default: 1)

  Example:
    Rhythm([0.25, 0.25, Rest(0.25), 0.5], [0.8, 0.6, 0, 0.9])
  */
  *new { |durations, velocities = nil, gates = nil, timebase = 1|
    ^super.new.init(durations, velocities, gates, timebase);
  }

  init { |inDurations, inVelocities, inGates, inTimebase|
    rawDurations = inDurations;
    velocities = inVelocities ?? Array.fill(rawDurations.size, 0.7);
    gates = inGates ?? Array.fill(rawDurations.size, 0.9);
    timebase = inTimebase;
  }

  /*
  Returns scaled durations (rawDurations * timebase).
  */
  durations {
    ^rawDurations * timebase;
  }

  /*
  Returns total duration of one cycle through the pattern.
  */
  totalDuration {
    ^rawDurations.sum * timebase;
  }

  /*
  Returns number of steps in the rhythm.
  */
  size {
    ^rawDurations.size;
  }

  /*
  Returns a new Rhythm with steps in reverse order.

  Example:
    Rhythm.euclidean(5, 8).reverse.asString
  */
  reverse {
    ^Rhythm(
      rawDurations.reverse,
      velocities.reverse,
      gates.reverse,
      timebase
    );
  }

  /*
  Concatenates two rhythm patterns.

  Note: Uses the timebase of the first rhythm. If rhythms have different
  timebases, consider scaling them first.

  Example:
    Rhythm.straight(4, 0.25) ++ Rhythm.euclidean(3, 8, 0.25)
  */
  ++ { |other|
    ^Rhythm(
      rawDurations ++ other.rawDurations,
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
      rawDurations.copyRange(start, end),
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
      inval[\dur] = rawDurations.wrapAt(i) * timebase;
      inval[\amp] = velocities.wrapAt(i);
      inval[\legato] = gates.wrapAt(i);
      inval = inval.yield;
    };
    ^inval
  }

  /*
  Format rhythm as text notation for visualization.

  Arguments:
    groupBy - Number of steps per group (default: 4, nil = no grouping)

  Returns a string with 'X' for hits and '.' for rests, grouped by bars.

  Examples:
    Rhythm.clave(\son).asString      // |X..X|..X.|..X.|X...|
    Rhythm.euclidean(5, 8).asString  // |X.X.|X.XX|
    Rhythm.straight(8).asString(2)   // |XX|XX|XX|XX|
  */
  asString { |groupBy = 4|
    var str = "";
    var steps = rawDurations.size;

    rawDurations.do { |dur, i|
      // Add grouping separator
      if ((i > 0) && (groupBy.notNil) && (i % groupBy == 0)) {
        str = str ++ "|";
      };

      // X for hit, . for rest
      if (dur.isRest) {
        str = str ++ ".";
      } {
        str = str ++ "X";
      };
    };

    ^"|" ++ str ++ "| (" ++ steps ++ " steps)";
  }
}
