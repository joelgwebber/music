// Section - A timed container for multiple voices playing in parallel
//
// Encapsulates a duration and multiple Voice instances, handling parallel
// playback and automatic duration limiting. Supports both array and named
// voice access.
//
// Examples:
//   Pphrase(4, [bassVoice, chordVoice])  // Array syntax
//   Pphrase(4, (bass: bassVoice, chords: chordVoice))  // Named syntax
//
Pphrase : Pattern {
  var <duration, <voices;

  // Creates a new Section with a duration and voices.
  // dur: Duration in beats for this section.
  // voicesIn: Either an Array of voices or an Event with named voices.
  // Returns: New Section instance.
  *new { |dur, voicesIn|
    ^super.new.init(dur, voicesIn);
  }

  init { |dur, voicesIn|
    duration = dur;

    // Convert array to named event if needed
    voices = if(voicesIn.isKindOf(Event)) {
      voicesIn
    } {
      // Auto-generate keys: v0, v1, v2, etc.
      var pairs = voicesIn.collectAs({ |v, i|
        [("v" ++ i).asSymbol, v]
      }, Array).flatten;
      Event.newFrom(pairs);
    };
  }

  // Pattern implementation - spawns all voices in parallel with duration limit.
  embedInStream { |inval|
    var spawner = Pspawner({ |sp|
      voices.keysValuesDo { |key, voice|
        if (duration == inf)
          { sp.par(voice) }
          { sp.par(Pfindur(duration, voice)); }
      };
      sp.wait(duration);
    });
    inval = spawner.embedInStream(inval);
    ^inval;
  }

  // Renders aligned tablature for all voices in the section.
  // Returns: String with all voices aligned and padded to section duration.
  asTab {
    var str = "";
    var maxKeyLen = 0;
    var subdivsPerBeat;

    // Calculate LCM of denominators (subdivisions per beat) across all voices for alignment
    subdivsPerBeat = voices.values.collect({ |voice|
      voice.rhythm.denominator;
    }).reduce({ |a, b|
      var gcd = { |x, y|
        var temp;
        while { y != 0 } {
          temp = y;
          y = x % y;
          x = temp;
        };
        x;
      };
      // LCM(a, b) = (a * b) / GCD(a, b)
      (a * b) / gcd.(a, b);
    });

    // Find longest key name for alignment
    voices.keys.do { |key|
      maxKeyLen = max(maxKeyLen, key.asString.size);
    };

    // Render each voice with aligned labels and common subdivsPerBeat
    voices.keysValuesDo { |key, voice|
      var keyStr = key.asString.padRight(maxKeyLen);
      str = str ++ ("%: %\n".format(keyStr, voice.asTab(duration, subdivsPerBeat)));
    };

    ^str;
  }

  // Returns a readable string representation.
  printOn { |stream|
    stream << "Pphrase(" << duration << ", " << voices.size << " voices)";
  }
}
