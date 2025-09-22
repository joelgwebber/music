(
Server.local.boot;
"lib/instruments.scd".load;
)

(
  // streams as a sequence of pitches
  var pattern, streams, dur, durDiff;
  var stream;

  dur = 1/7;
  durDiff = 3;

  pattern = p({
    loop({
      if (0.5.coin, {
          #[ 24,31,36,43,48,55 ].do({|fifth| fifth.yield });
      });

      // varying arpeggio
      rrand(2,5).do({
          60.yield;
          #[63,65].choose.yield;
          67.yield;
          #[70,72,74].choose.yield;
      });

      // random high melody
      rrand(3,9).do({ #[74,75,77,79,81].choose.yield });
    });
  });

  streams = [
    (pattern - Pfunc.new({ #[12, 7, 7, 0].choose })).midicps.asStream,
    pattern.midicps.asStream
  ];

  r = Routine({
    loop({
      Synth( \help_SPE2, [ \freq, streams.at(0).next, \sustain, dur * durDiff ] );
      durDiff.do({
        Synth( \help_SPE2, [ \freq, streams.at(1).next, \sustain, dur ] );
        dur.wait;
      });
    })
  });
  r.play
)
r.stop;

(
p = Ppar([
    Pbind(
        \dur, Prand([0.2, 0.4, 0.6], inf),
        \midinote, Pseq([72, 74, 76, 77, 79, 81], inf),
        \db, -26,
        \legato, 1.1
    ),
    Prand([
        Ppar([
            Pbind(\dur, 0.2, \pan,  0.5, \midinote, Pseq([60, 64, 67, 64])),
            Pbind(\dur, 0.4, \pan, -0.5, \midinote, Pseq([48, 43]))
        ]),
        Ppar([
            Pbind(\dur, 0.2, \pan,  0.5, \midinote, Pseq([62, 65, 69, 65])),
            Pbind(\dur, 0.4, \pan, -0.5, \midinote, Pseq([50, 45]))
        ]),
        Ppar([
            Pbind(\dur, 0.2, \pan,  0.5, \midinote, Pseq([64, 67, 71, 67])),
            Pbind(\dur, 0.4, \pan, -0.5, \midinote, Pseq([52, 47]))
        ])
      ], inf)
], inf).play;
)
p.stop;

(
var makePattern, durpat;

durpat = Pseq([
  Pgeom(0.05, 1.1, 24),
  Pgeom(0.5, 0.909, 24)
], 2);

makePattern = { |note db pan|
  Pbind(
    \dur, durpat,
    \db, db,
    \pan, pan,
    \midinote, Pseq([note, note-4], inf)
  );
};

p = Ptpar([
    0.0, makePattern.value(53, -20, -0.9),
    2.0, makePattern.value(60, -23, -0.3),
    4.0, makePattern.value(67, -26,  0.3),
    6.0, makePattern.value(74, -29,  0.9)
], inf).play;
)
p.stop;

(
var pattern;

pattern = Pbind(
    \dur, 0.15,
    \degree, Pseq([ Pshuf(#[-7,-3,0,2,4,7], 4), Pseq([0,1,2,3,4,5,6,7]) ], 1)
);

p = Pseq([
    pattern,        // untransposed
    Padd(\mtranspose, 1, pattern),    // modal transpose up 1 degree
    Padd(\mtranspose, 2, pattern)    // modal transpose up 2 degrees
], inf).play
)
p.stop;

(
// beat stretching using Pstretch
var pattern;

// define the basic pattern
pattern = Pbind(
    \dur, 0.15,
    \degree, Pseq([ Pshuf(#[-7,-3,0,2,4,7], 4), Pseq([0,1,2,3,4,5,6,7]) ], 1)
);

p = Pseq([
    pattern,        // normal
    Pstretch(0.5, pattern),    // stretch durations by a factor of 1/2
    Pstretch(2.0, pattern)    // stretch durations by a factor of 2
], inf).play
)
p.stop;

(
// modal transposition
var pat1, pat2;

// define the basic pattern
pat1 = Pbind(
    \dur, 0.15,
    \degree, Pseq([ Pshuf(#[-7,-3,0,2,4,7], 4), Pseq([0,1,2,3,4,5,6,7]) ], 1)
);

pat2 = Paddp(
    \mtranspose, Pseq([0,1,2]),
    Ppar([
        pat1,
        Padd(\mtranspose, -3, pat1),    // down a 4th
        Padd(\mtranspose, 2, pat1)    // up a 3rd
    ])
);

p = Pseq([
    pat1,    // unmodified pattern
    pat2,    // parallel sequence
    Pstretch(1.5, pat2)    // parallel sequence stretched by 3/2
], inf).play
)
p.stop;

(
// beat time stretching
var pattern;

// define the basic pattern
pattern = Pbind(
    \dur, 0.1,
    \degree, Pseq([0,1,2,3,4,5,6,7])
);

p = Pstretchp(
    Pseq([1,2,3], inf),    // a value pattern as a source of values for multiplying with stretch
    pattern            // the pattern to be modified
).play
)
p.stop;

(
var pattern;
pattern = Pbind( \midinote, Pseq(#[60, 62, 64, 65, 67, 69, 71, 72]) );
p = Pseq([
    Pbindf(pattern, \legato, 0.1, \dur, 0.2),
    Pbindf(pattern, \legato, 1.0, \dur, 0.125),
    Pbindf(pattern, \legato, 2.0, \dur, 0.3)
], inf).play
)
p.stop;

(
var pattern;
pattern = Pbind( \midinote, Pseq(#[60, 62, 64, 65, 67, 69, 71, 72, 74, 76, 77, 79]) );

p = Pseq([
    Pbindf(pattern,\legato, 0.1, \dur, Pgeom(0.3, 0.85, inf)),
    Pbindf(pattern,\legato, 1.0, \dur, Pseq([0.3, 0.15], inf)),
    Pbindf(pattern,\legato, 2.0, \dur, Pseq([0.2, 0.2, 0.4], inf))
], inf).play
)
p.stop;

(
p = Pbind(
  \instrument, Prand([\help_SPE7_BerlinB, \help_SPE7_CFString1],inf),
  \degree, Pseq([0,1,2,4,6,3,4,8],inf),
  \dur, 0.8,
  \octave, 3,
  \amp, 0.03
).play; // this returns an EventStreamPlayer
)
p.stop;

(
p = Pbind(
    \degree, Pwhite(0,12),
    \dur, 0.2,
    \instrument, \help_SPE4_CFString2
);
e = p.play; // e is an EventStreamPlayer
)

(
// you can change the stream at any point in time
e.stream = Pbind(
    \degree, Pseq([0,1,2,4,6,3,4,8],inf),
    \dur, Prand([0.2,0.4,0.8],inf),
    \amp, 0.05,
    \octave, 5,
    \instrument, \help_SPE7_BerlinB, // you can also use a symbol
    \ctranspose, 0
).asStream;
)

(
e.stream = Pbind(
    [\degree, \dur], Pseq(
        [
            Pseq([[0,0.1],[2,0.1],[3,0.1],[4,0.1],[5,0.8]],2),
            Ptuple([Pxrand([6,7,8,9],4), 0.4]),
            Ptuple([Pseq([9,8,7,6,5,4,3,2]), 0.2])
        ], inf
    ),
    \amp, 0.05,
    \octave, 5,
    \instrument, \help_SPE7_CFString1
).asStream;
)

e.stop; p.stop;

