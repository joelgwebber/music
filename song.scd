(
Server.local.boot;
"lib/instruments.scd".load;
)

/*
Skyrim - Awake

c      C  Eb G
g      G  Bb D
c      C  Eb G
g      G  Bb D
Ebmaj7 Eb Bb D  G
F      F  A  C
gsus4  G  C  D
G      G  B  D
G7     G  B  D  F

G minor (Bb major):

   A♮----E♮    B♮  <- parallel
  /  \  /  \  /  \
F♮----C♮----G♮----D♮----A♮
        \  /  \  /  \  /  \
         E♭----B♭----F♮----C♮
*/
(
var cm = Chromatic(3, [3, 4], -2);
var gm = cm.thirds(2);
var ebmaj7 = gm.addThirds(-1);
var fM = cm.parallel.thirds(-2);
var gsus4 = Chromatic(3, [7, 7], -1);
var gM = gm.parallel();
var g7 = gM.addThirds(1);
var prog;

prog = [cm, gm, cm, gm, ebmaj7, fM, gsus4, gM, g7];
p = Pbind(
    \instrument, \cfstring1,
    \freq, Pseq(all {:ch.freqs, ch <- prog}),
    \dur, 1,
    \amp, 0.5
).play;

all {:ch.names, ch <- prog};
)


// Canon in D
// D - A - Bm - F#m - G - D - G - A
//
// ---F#----C#
//   /  \  /  \
// D♮----A♮----E♮----B♮----F#----C#
//               \  /  \  /  \  /  \
//                G♮----D♮----A♮----E♮----B♮----F#---
//                                    \  /  \  /  \
//                                     G♮----D♮----A♮
(
var dM = Diatonic(5, 5, [4, 3], -1);
var aM = dM.thirds(2).oct(-1);
var bm = aM.thirds(-3).oct(1);
var fsm = bm.thirds(2).oct(-1);
var gM = fsm.thirds(4).oct(-1);

var prog = [ dM, aM, bm, fsm, gM, dM.oct(-1), gM, aM ];

p = Pbind(
    \instrument, \cfstring1,
    \freq, Pseq(all {:ch.freqs, ch <- prog}),
    \dur, 1,
    \amp, 0.5
).play;

all {:ch.names, ch <- prog};
)

p.stop;
