/*
*  Twilight Luminaries by Alexander Zhagun-Linnik
*  Moscow, 2019
*
*  Endless generative composition based on random polyphonic sequences.
*
*  etherguide@gmail.com
*/
(
Server.default = s;
o=s.options;
o.memSize;
o.sampleRate;
o.memSize = 2.pow(16);
o.sampleRate = 44100;
s.quit;

s.waitForBoot({
	~rseq = {Array.fill(~num = rrand(2, 8), {arg i; rrand(0, 12)})};
	~scale = Scale.at(Scale.names.choose);
	~time = 5;
	~root = rrand(0, 12);
	~maingain = 4;

	{
		SynthDef(\sin, {arg freq=440, amp = 0.9, gate=1, out=0, release=1, attack=0.01, maingain=4, decay=1, detune=0.01;
			var sig = Mix.fill(12, {arg i;
				SinOsc.ar(freq+(freq*Rand(detune.neg, detune)), Rand(0.0, 1.0), amp/12);
			});
			sig = (sig*maingain).softclip;
			sig = (sig * Env.adsr(attack, decay, 1.0, release).kr(2, gate));
			sig = Pan2.ar(sig, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), Rand(0.01, 3.0)));
			Out.ar(out, sig);
		}).add;

		SynthDef(\sim, {arg freq=440, out=0, release=1, maingain=4;
			var amp = Rand(0.0, 0.5);
			var sig = SinOsc.ar(freq, Rand(0.0, 1.0), amp/12);
			sig = (sig*maingain).softclip;
			sig = sig * Env.perc(0.0001, releaseTime: release, curve: -8).kr(2);
			sig = CombC.ar(sig, Rand(0.01, 0.4), Rand(0.01, 0.4), Rand(0.01, 0.3), Rand(0.01, 2));
			sig = Pan2.ar(sig, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), Rand(0.01, 3.0)));
			Out.ar(out, sig);
		}).add;

		SynthDef(\str, {arg freq=440, amp = 1.0, gate=1, out=0, verb=0.5, release=1, attack=0.01, maingain=4, decay=1, detune=0.01;
			var sig = Mix.fill(12, {
				VarSaw.ar(freq+(freq*Rand(detune.neg, detune)), Rand(0.0, 1.0), Rand(0.0, 1.0),  amp/12);
			});
			attack = attack*2;
			sig = (sig*maingain).softclip;
			sig = sig * Env.adsr(attack, decay, 1.0, release).kr(2, gate);
			sig = Pan2.ar(sig, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), Rand(0.01, 3.0)));
			Out.ar(out, sig);
		}).add;

		s.sync;

		loop{
			~rseq = {Array.fill(~num = rrand(2, 8), {arg i; rrand(0, 8)})};
			if(rrand(1, 5)==4, {
				~scale = Scale.at(Scale.names.choose);
			});
			if(rrand(1, 5)==4, {
				~root = rrand(0, 12);
			});
			Pdef(\main,
				Ppar(Array.fill(rrand(1, 8), {
					Pbind(
						\instrument, [\sin, \str, \sim].choose,
						\scale, ~scale,
						\dur, [2, 1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/3, 1/6, 1/12].choose*~time,
						\degree, Pseq(~rseq.value, inf),
						\octave, [2, 3, 4, 5, 6].choose,
						\type, Pfunc({[\note, \note, \rest].choose}),
						\verb, rrand(0.05, 0.8),
						\release, rrand(0.0, 4.0),
						\attack, rrand(0.001, 1.0),
						\root, ~root,
						\maingain, Pbrown(0.1, 6.0, Pfunc({rrand(0.1, 1.0)}), inf),
						\detune, rrand(0.005, 0.015),
						\decay, Pfunc({rrand(0.01, 2.0)}),
					)
				}))
			).play();
			Ndef(\proc, {
				var sig = FreeVerb.ar(
					In.ar(0, 2),
					rrand(0.01, 0.99),
					rrand(0.01, 0.99),
					rrand(0.01, 0.99)
				);
				Out.ar(0, sig);
			}).fadeTime_(rrand(0.1, 3.0));
			([8, 4, 2, 1].choose*~time).sleep;
		}
	}.fork;
});
)
