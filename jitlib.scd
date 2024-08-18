(
    s.boot;
    p = ProxySpace.push(s);
)

~out.play;
~out = { SinOsc.ar([400, 408] * 0.8, 0, 0.2) };
~out = { SinOsc.ar([443, 600 - Rand(0,200)], 0, 0.2) };
~out.stop;

~out.fadeTime = 4;
~out = { SinOsc.ar(Rand(800, 300.0) * [1,1.1], 0, 0.1) };
~out.free(3);    // release the synths and the group with a given fadeTime without changing proxy time

~out.play;
~out = Pbind(
    \instrument, \who, 
    \freq, [440, 880], 
    \ffreq, 800, 
    \gate, 1, 
    \legato, 0.1);
~out.stop;

a = Harmony.new([0, 4, 7]);

{ Klank.ar([[800, 1071, 1153, 1723], nil, [1, 1, 1, 1]], Impulse.ar(2, 0, 0.1)) }.play;
