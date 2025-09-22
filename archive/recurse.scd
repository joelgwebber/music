(
Server.local.boot;
"lib/instruments.scd".load;
)

Synth(\SOStom, [ \freq, 110 ]);

(
Pdef(\sweep, { arg sustain=1, n=8, freq=440, ratio=0.1;
    Pbind(
        \instrument, \pgrain,
        \dur, sustain.value / n,
        \freq, Pseq((1..n)) * ratio + 1 * freq.value // freq is a function, has to be evaluated
    )
});
Pdef(\sweep2, { arg sustain=1, n=8, freq=440, ratio=0.1;
    Pbind(
        \instrument, \noiseGrain,
        \dur, sustain.value / n, // sustain is also a function, has to be evaluated
        \freq, Pseq((1..n).scramble) * ratio + 1 * freq.value,
        \recursionLevel, 2
    )
});
Pdef(\sweep3, { arg freq=440;
    Pbind(
        \type, \phrase,
        \instrument, \sweep,
        \freq, Pfunc({ rrand(0.8, 1.3) }) * freq.value,
        \dur, 0.3,
        \legato, 1.3,
        \n, 5
    )
});
)

(
p = Pbind(
    \type, \phrase,
    \instrument, \sweep3,
    \n, 15,
    \degree, Pseq([0, 4, 7], 2),
    \sustain, Pseq([1, 1, 1], 2),
    \duration, 1,
).play
)

p.stop;
