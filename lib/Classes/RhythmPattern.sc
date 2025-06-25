RhythmPattern {
  var <>durations, <>velocities, <>gates, <>timebase;

  *new { |durations, velocities = nil, gates = nil, timebase = 1|
    ^super.new.init(durations, velocities, gates, timebase);
  }

  init { |inDurations, inVelocities, inGates, inTimebase|
    durations = inDurations;
    velocities = inVelocities ?? Array.fill(durations.size, 0.7);
    gates = inGates ?? Array.fill(durations.size, 0.9);
    timebase = inTimebase;
  }

  // Scale all durations by a factor
  stretch { |factor|
    ^RhythmPattern(durations * factor, velocities, gates, timebase);
  }

  // Returns total duration
  totalDuration {
    ^durations.sum * timebase;
  }

  // Returns number of events
  size {
    ^durations.size;
  }

  // Cycles the rhythm pattern n times
  cycle { |n = 2|
    ^RhythmPattern(
      durations.stutter(n).flatten,
      velocities.stutter(n).flatten,
      gates.stutter(n).flatten,
      timebase
    );
  }

  // Reverses the rhythm pattern
  reverse {
    ^RhythmPattern(
      durations.reverse,
      velocities.reverse,
      gates.reverse,
      timebase
    );
  }

  // Concatenates two rhythm patterns
  ++ { |other|
    ^RhythmPattern(
      durations ++ other.durations,
      velocities ++ other.velocities,
      gates ++ other.gates,
      timebase
    );
  }

  // Returns a subsequence of the rhythm
  copyRange { |start, end|
    ^RhythmPattern(
      durations.copyRange(start, end),
      velocities.copyRange(start, end),
      gates.copyRange(start, end),
      timebase
    );
  }

  // Returns scaled durations
  scaledDurations {
    ^durations * timebase;
  }

  // Common rhythm patterns as class methods
  *straight { |n = 4, dur = 1, vel = 0.7|
    var durs = Array.fill(n, dur);
    var vels = Array.fill(n, vel);
    ^RhythmPattern(durs, vels);
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
    ^RhythmPattern(durs.keep(n), vels.keep(n));
  }

  *clave { |type = \son|
    var patterns = (
      son: [[1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0], [1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 0.7, 1, 0.7, 1, 0.7, 0.8, 0.7]],
      rumba: [[1, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 0], [1, 0.7, 0.8, 1, 0.7, 0.8, 0.7, 1, 0.7, 0.8, 1, 0.7, 1, 0.7, 0.8, 0.7]],
      bossa: [[1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0], [1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 1, 0.7, 0.8, 0.7]]
    );
    var pattern = patterns[type] ?? patterns[\son];
    var durs = pattern[0].collect { |v| if(v > 0, 0.25, Rest(0.25)) };
    var vels = pattern[1];
    ^RhythmPattern(durs, vels, timebase: 1);
  }

  // Create pattern from Euclidean algorithm
  *euclidean { |hits, steps, dur = 1, vel = 0.7|
    var pattern = this.bjorklund(hits, steps);
    var durs = pattern.collect { |v| if(v > 0, dur, Rest(dur)) };
    var vels = Array.fill(steps, { |i| if(pattern[i] > 0, vel, 0) });
    ^RhythmPattern(durs, vels);
  }

  // Bjorklund's algorithm for generating Euclidean rhythms
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

  // Returns a Pattern that can be used in Pbind
  asPattern {
    ^Pbind(
      \dur, Pseq(this.scaledDurations, inf),
      \amp, Pseq(velocities, inf),
      \legato, Pseq(gates, inf)
    );
  }
}