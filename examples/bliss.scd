(
s.boot;

SynthDef(\param, { arg freq = 100, sustain, amp;
	var sig;
    sig = LFPar.ar(freq: freq,
        mul: EnvGen.kr(Env.perc(0, sustain, 0.5), doneAction:2) * amp);
	sig = Splay.ar(sig);
	Out.ar(0, sig);
}).add;

e = Pbind(
	\midinote, Prout({
		var tone0, tone1, tone2, interval, freq0, delta;
		loop {
			tone0 = rrand(0,11);
			interval = rrand(2,4);
			tone1 = Scale.minor(\pythagorean).at(tone0) + [0,12,24].choose + 0.07;
			tone2 = Scale.minor(\pythagorean).at(tone0 + interval) + [0,12,24].choose;
			freq0 = [tone1,tone2]+48;
			postln(freq0);
			freq0.yield;
		}
	}),
    \dur, Prand([1,2,4,8,12,16,4,6,8], inf),
    \instrument, \param,
	\amp, 0.5,
	\sustain, 2,
).play(quant:1); // returns an EventStream
TempoClock.default.tempo = 1200/60;
)
e.stop;

