StrumPattern {
  var <>delay, <>direction, <>curve, <>humanize;

  *new { |delay = 0.01, direction = \up, curve = 1, humanize = 0|
    ^super.new.init(delay, direction, curve, humanize);
  }

  init { |inDelay, inDirection, inCurve, inHumanize|
    delay = inDelay;
    direction = inDirection;
    curve = inCurve;
    humanize = inHumanize.clip(0, 1);
  }

  // Generate lag times for a chord of given size
  lagTimes { |chordSize|
    var lags = Array.new(chordSize);
    var baseDelay = delay;
    
    chordSize.do { |i|
      var position = direction.switch(
        \up, { i },
        \down, { chordSize - 1 - i },
        \upDown, { if(i < (chordSize/2), i, chordSize - 1 - i) },
        \downUp, { if(i < (chordSize/2), chordSize/2 - 1 - i, i - chordSize/2) },
        \random, { chordSize.rand },
        { i } // default to up
      );
      
      // Apply curve to the delay
      var curvedDelay = baseDelay * (position ** curve);
      
      // Add humanization
      var human = if(humanize > 0, { rrand(humanize.neg, humanize) * baseDelay }, 0);
      
      lags.add(curvedDelay + human);
    };
    
    ^lags;
  }

  // Generate velocity pattern for strummed notes
  velocityPattern { |chordSize, baseVel = 0.7|
    var vels = Array.new(chordSize);
    
    chordSize.do { |i|
      var position = direction.switch(
        \up, { i / (chordSize - 1) },
        \down, { 1 - (i / (chordSize - 1)) },
        \upDown, { 
          if(i < (chordSize/2), 
            { i / (chordSize/2) },
            { 1 - ((i - chordSize/2) / (chordSize/2)) }
          )
        },
        { 1 } // default full velocity
      );
      
      // Slight velocity variation based on position
      var vel = baseVel * (0.8 + (0.2 * position));
      vels.add(vel);
    };
    
    ^vels;
  }

  // Common strum patterns as class methods
  *guitar { |speed = \medium|
    var delays = (
      fast: 0.005,
      medium: 0.015,
      slow: 0.03,
      verySlow: 0.06
    );
    ^StrumPattern(delays[speed] ?? 0.015, \up, 1.2, 0.1);
  }

  *harp { |speed = \medium|
    var delays = (
      fast: 0.01,
      medium: 0.025,
      slow: 0.05
    );
    ^StrumPattern(delays[speed] ?? 0.025, \up, 0.8, 0.05);
  }

  *mandolin {
    ^StrumPattern(0.003, \down, 1, 0.15);
  }

  *roll { |duration = 1, density = 30|
    var delay = duration / density;
    ^StrumPattern(delay, \upDown, 1, 0.2);
  }

  // Apply strum pattern to a chord progression
  applyToProgression { |progression, rhythm = nil|
    var events = [];
    var chordDurations = rhythm.notNil.if(
      { rhythm.scaledDurations },
      { Array.fill(progression.size, 1) }
    );
    var chordVelocities = rhythm.notNil.if(
      { rhythm.velocities },
      { Array.fill(progression.size, 0.7) }
    );
    
    progression.chords.do { |chord, i|
      var freqs = chord.freqs;
      var lags = this.lagTimes(freqs.size);
      var vels = this.velocityPattern(freqs.size, chordVelocities.wrapAt(i));
      var dur = chordDurations.wrapAt(i);
      
      // Create events for each note in the chord
      freqs.do { |freq, j|
        events = events.add((
          freq: freq,
          lag: lags[j],
          amp: vels[j],
          dur: dur,
          sustain: dur * 0.9
        ));
      };
    };
    
    ^events;
  }

  // Returns a Pattern that generates strum events
  asPattern { |chords, rhythm = nil|
    var events = this.applyToProgression(chords, rhythm);
    ^Pdef(\strum,
      Pbind(
        \freq, Pseq(events.collect(_.freq)),
        \lag, Pseq(events.collect(_.lag)),
        \amp, Pseq(events.collect(_.amp)),
        \dur, Pseq(events.collect(_.dur)),
        \sustain, Pseq(events.collect(_.sustain))
      )
    );
  }
}