Rhythm : Pattern {
  var <rawDurations, <velocities, <gates, <timebase;

  // Common rhythm patterns as class methods
  *straight { |n = 4, dur = 1, vel = 0.7|
    var durs = Array.fill(n, dur);
    var vels = Array.fill(n, vel);
    ^Rhythm(durs, vels);
  }

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

  // Clave patterns: 'son', 'rumba', 'bossa'
  // TODO: These durations aren't computed properly.
  *clave { |type = \son|
    var patterns = (
      son: [[1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0], [1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 0.7, 1, 0.7, 1, 0.7, 0.8, 0.7]],
      rumba: [[1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0], [1, 0.7, 0.8, 1, 0.7, 0.8, 0.7, 1, 0.7, 0.8, 1, 0.7, 1, 0.7, 0.8, 0.7]],
      bossa: [[1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0], [1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 0.7]]
    );
    var pattern = patterns[type] ?? patterns[\son];
    var durs = pattern[0].collect { |v| if(v > 0, 0.25, Rest(0.25)) };
    var vels = pattern[1];
    ^Rhythm(durs, vels, timebase: 1);
  }

  // Create pattern from Euclidean algorithm
  // TODO: Not working.
  *euclidean { |hits, steps, dur = 1, vel = 0.7|
    var pattern = this.bjorklund(hits, steps);
    var durs = pattern.collect { |v| if(v > 0, dur, Rest(dur)) };
    var vels = Array.fill(steps, { |i| if(pattern[i] > 0, vel, 0) });
    ^Rhythm(durs, vels);
  }

  // Bjorklund's algorithm for generating Euclidean rhythms
  // TODO: Not working.
  *bjorklund { |hits, steps|
    var pattern, remainder, divisor, level;

    if (hits > steps) { hits = steps };
    if (hits == 0) { ^Array.fill(steps, 0) };
    if (hits == steps) { ^Array.fill(steps, 1) };

    pattern = Array.fill(hits, [1]) ++ Array.fill(steps - hits, [0]);
    remainder = steps - hits;
    divisor = hits;

    while { remainder > 1 } {
      var newPattern = [];
      var pairs = min(remainder, divisor);

      pairs.do { |i|
        newPattern = newPattern.add(pattern[i] ++ pattern[divisor + i]);
      };

      if (divisor > remainder) {
        (divisor - remainder).do { |i|
          newPattern = newPattern.add(pattern[remainder + i]);
        };
      };

      pattern = newPattern;
      level = remainder;
      remainder = divisor % remainder;
      divisor = level;
    };

    ^pattern.flatten;
  }

  *new { |durations, velocities = nil, gates = nil, timebase = 1|
    ^super.new.init(durations, velocities, gates, timebase);
  }

  init { |inDurations, inVelocities, inGates, inTimebase|
    rawDurations = inDurations;
    velocities = inVelocities ?? Array.fill(rawDurations.size, 0.7);
    gates = inGates ?? Array.fill(rawDurations.size, 0.9);
    timebase = inTimebase;
  }

  // Returns scaled durations
  durations {
    ^rawDurations * timebase;
  }

  // Returns total duration
  totalDuration {
    ^rawDurations.sum * timebase;
  }

  // Returns number of events
  size {
    ^rawDurations.size;
  }

  // Reverses the rhythm pattern
  reverse {
    ^Rhythm(
      rawDurations.reverse,
      velocities.reverse,
      gates.reverse,
      timebase
    );
  }

  // Concatenates two rhythm patterns
  // TODO: This doesn't handle mixed timebases correctly.
  ++ { |other|
    ^Rhythm(
      rawDurations ++ other.rawDurations,
      velocities ++ other.velocities,
      gates ++ other.gates,
      timebase
    );
  }

  // Returns a subsequence of the rhythm
  copyRange { |start, end|
    ^Rhythm(
      rawDurations.copyRange(start, end),
      velocities.copyRange(start, end),
      gates.copyRange(start, end),
      timebase
    );
  }

  embedInStream { |inval|
    inf.do { |i|
      inval[\dur] = rawDurations.wrapAt(i) * timebase;
      inval[\amp] = velocities.wrapAt(i);
      inval[\legato] = gates.wrapAt(i);
      inval = inval.yield;
    };
    ^inval
  }
}
