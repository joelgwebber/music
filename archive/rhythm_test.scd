(
s.boot;
"lib/instruments.scd".load;
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

p = ProxySpace.push(s);
~hat = inst.value(\hgh, Rhythm(1, 2, [1, 1], [2, 1])).play;
~kick = inst.value(\kik, Rhythm(1, 3, [1, 1, 1], [2, 1, 1])).play;
~snare = inst.value(\snr, Rhythm(1, 2, [2], [1])).play;
)

p.clear();

p = ProxySpace.push(s);
currentEnvironment.postln;

~u.play(0, 2);
~u = { PinkNoise.ar(0.5) };
~u.clear;
~u;

(
~z = (~y * pi).sin * 0.5 * {
  LFSaw.kr(LFNoise1.kr(0.1 ! 3).sum * -18).max(0.2)
};
)

(
~z = {
    Splay.ar(
        SinOsc.ar(Rand(300,400) + ({exprand(1, 1.3)} ! rrand(1, 9)))
        * LFCub.ar({exprand(30, 900)} ! rrand(1, 9))
        * LFSaw.kr({exprand(1.0, 8.0)} ! rrand(1, 9)).max(0)
        * 0.1
    )
};
)

~y[1] = { Saw.ar([400, 401.3], 0.4) };
~y[0] = { Saw.ar([300, 301], 0.4) };

~z.play;
~z.isPlaying;
~z.monitor.isPlaying;
~z.stop;

~y.play;
~y.stop;

p.clear;
