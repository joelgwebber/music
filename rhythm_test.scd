(
s.boot;
"lib/instruments.scd".load;
p = ProxySpace.push(s);
)

(
var inst = { |inst, rhythm|
  var freqs = 220!rhythm.durations.size;
  Pbind(
    \instrument, inst,
    \freq, Pseq(freqs, inf),
    \dur, Pseq(rhythm.durations, inf),
    \amp, Pseq(rhythm.velocities, inf)
  )
};

var kik = { |rhythm| inst.value(\kik, rhythm) };
var hgh = { |rhythm| inst.value(\hgh, rhythm) };

// 3-----3-----
// 4-0-0-0-2-0-
//
// 4---4---4---4---
// 2-4---2-4---4---
//
var r0 = Rhythm([2, 1]/2, [2, 2]/4);
var r1 = Rhythm([2, 1]/2, [4, 2]/6);

a = hgh.value(r0).play;
b = kik.value(r1).play;
)

a.stop; b.stop;

