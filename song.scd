(
Server.local.boot;
"lib/instruments.scd".load;
)

// Canon in D
// D - A - Bm - F#m - G - D - G - A
(
var dM = Diatonic(5, 5, [4, 3], -1);
var aM = dM.up(2).oct(-1);
var bm = aM.down(3).oct(1);
var fsm = bm.up(2).oct(-1);
var gM = fsm.up(4).oct(-1);

var prog = [ dM, aM, bm, fsm, gM, dM.oct(-1), gM, aM ];

p = Pbind(
    \instrument, \bass,
    \freq, Pseq(all {:ch.freqs, ch <- prog}),
    \dur, 1,
    \amp, 0.5
).play;

all {:ch.names, ch <- prog};
)

(
var dM = Diatonic(5, 5, [4, 3], -2);
var prog = [ dM, dM.up(1), dM.up(2), dM.up(3), dM.up(4), dM.up(5) ];

p = Pbind(
    \instrument, \bass,
    \freq, Pseq(all {:ch.freqs, ch <- prog}),
    \dur, 1,
    \amp, 0.5
).play;

all {:ch.names, ch <- prog};
)

p.stop;
