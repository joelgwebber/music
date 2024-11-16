Rhythm {
  var <durations, <velocities;

  *new { |velocities, durations|
    ^super.new.init(velocities, durations);
  }

  // Makes a new Rhythm of (length) seconds, with the given note velocities.
  // The notes can be of any velocity value, positive, negative, or zero, and
  // represent an equal-time division of the measure's length.
  //
  // When returned in velocities and durations, the velocities will be normalized
  // to the range [0,1], and the durations will be in seconds. The number of values
  // returned will be the minimum necessary to represent the input notes.
  //
  // For example:
  //   notes:      1 1 0 0 1 1 0 0
  //   durations:  2   2   2   2  
  //   velocities: 1   0   1   0  
  //
  //   notes:      2 1 0 0 2 0 0 1
  //   durations:  1 1 2   1 2   1
  //   velocities: 2 1 0   2 0   1
  //
  // TODO: Use rests explicitly, rather than just velocity=0.
  //
  *fromNotes { |length, notes|
    ^super.new.fromNotes(length, notes);
  }

  init { |inVelocities, inDurations|
    velocities = inVelocities;
    durations = inDurations;
  }

  fromNotes { |length, notes|
    var prev = 0, curIndex = -1;
    var maxVelocity = 0;

    notes.do { |note, index|
      if (note.abs > maxVelocity) {
        maxVelocity = note.abs;
      };

      if (prev.isNil or: { note != prev }) {
        if (curIndex >= 0) {
          durations = durations.add(index - curIndex);
        };
        velocities = velocities.add(note);
        curIndex = index;
      };
      prev = note;
    };

    // Add the duration for the last segment
    if (curIndex >= 0) {
      durations = durations.add(notes.size - curIndex);
    };

    durations = durations * length / notes.size;
    velocities = velocities / maxVelocity;
  }
}


RConvolve {
  var input, filter;

  *new { |input, filter|
    ^super.new.init(input, filter);
  }

  init { |inInput, inFilter|
    super.init(inInput.length, inInput.notes);
  }
}

