/*
*  Boreas by Alexander Zhagun-Linnik
*  Moscow, 2020
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
	{
	var num = 0;
	var rseq = {Array.fill(num = rrand(2, 8), {arg i; rrand(0, 8)})};
	var durlist = [2, 1, 1/2, 1/4, 1/8, 1/16, 1/32, 1/3, 1/6, 1/12];
	var scale = Scale.at(Scale.names.choose);
	var time = 5;
	var root = rrand(0, 12);
	var mg = 4;
	var masterSetup = false;
		SynthDef(\sin, {arg freq=440, amp = 0.9, gate=1, out=0, release=1, attack=0.01, mg=4, decay=1, detune=0.01;
			var sig = Mix.fill(12, {arg i;
				SinOsc.ar(freq+(freq*Rand(detune.neg, detune)), Rand(0.0, 1.0), amp / mg / 10);
			});
			sig = (sig * Env.adsr(attack, decay, 1.0, release).kr(2, gate));
			sig = Pan2.ar(sig, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), Rand(0.01, 3.0)));
			Out.ar(out, sig);
		}).add;
		SynthDef(\sim, {arg freq=440, out=0, release=1, mg=4;
			var amp = Rand(0.0, 0.5);
			var sig = SinOsc.ar(freq, Rand(0.0, 1.0), amp / mg * 1.2);
			sig = sig * Env.perc(0.0001, releaseTime: release, curve: -8).kr(2);
			sig = CombC.ar(sig, Rand(0.01, 0.4), Rand(0.01, 0.4), Rand(0.01, 0.3), Rand(0.01, 2));
			sig = Pan2.ar(sig, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), Rand(0.01, 3.0)));
			Out.ar(out, sig);
		}).add;
		SynthDef(\str, {arg freq=440, amp = 1.0, gate=1, out=0, verb=0.5, release=1, attack=0.01, mg=4, decay=1, detune=0.01;
			var sig = Mix.fill(12, {
				VarSaw.ar(freq+(freq*Rand(detune.neg, detune)), Rand(0.0, 1.0), Rand(0.0, 1.0),  amp / mg / 10);
			});
			attack = attack*2;
			sig = sig * Env.adsr(attack, decay, 1.0, release * 2).kr(2, gate);
			sig = Pan2.ar(sig, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), Rand(0.01, 3.0)));
			Out.ar(out, sig);
		}).add;
		SynthDef(\cha, {arg freq=440, amp = 1.0, gate=1, out=0, verb=0.5, release=1, attack=0.01, mg=4, decay=1, detune=0.01;
			var sig = WhiteNoise.ar(Rand(0.0, 0.9));
			sig = RLPF.ar(sig, freq, 0.1 + LFDNoise3.ar(1).abs * Rand(0.0, 0.1)) * 0.1 / mg;
			sig = sig.softclip * Env.adsr(attack, decay, 1.0, release).kr(2, gate);
			sig = Pan2.ar(sig, Line.kr(Rand(-1.0, 1.0), Rand(-1.0, 1.0), Rand(0.01, 3.0)));
			Out.ar(out, sig);
		}).add;
		s.sync;
		loop{
			rseq = {Array.fill(num = rrand(2, 12), {arg i; rrand(0, 8)})};
			if(rrand(1, 5)==4, {
				scale = Scale.at(Scale.names.choose);
			});
			if(rrand(1, 5)==4, {
				root = rrand(0, 12);
			});
			Pdef(\main,
				Ppar(Array.fill(rrand(1, 12), {arg i;
					var seq = rseq.value;
					var cursor = rrand(0, durlist.size - 1);
					var durnum = rrand(1, 5);
					var durs = Array.fill(durnum, {
						cursor = cursor + rrand(-2, 2);
						durlist.clipAt(cursor);
					});
					Pbind(
						\instrument, [\sin, \str, \str, \cha].choose,
						\scale, scale,
						\dur, Pseq(Array.fill(seq.size, {durs.choose * time}), inf),
						\degree, Pseq(seq, inf),
						\octave, [2, 3, 4, 5, 6].choose,
						\type, Pfunc({[\note, \note, \rest].choose}),
						\verb, rrand(0.05, 0.8),
						\release, rrand(0.0, 8.0),
						\attack, rrand(0.001, 3.0),
						\root, root,
						\mg, Pbrown(0.1, 6.0, Pfunc({rrand(0.1, 1.0)}), inf),
						\detune, rrand(0.005, 0.015),
						\decay, Pfunc({rrand(0.01, 2.0)}),
					)
				}))
			).play();
			if(masterSetup == false, {
				Ndef(\proc, {
					var sig = (In.ar(0, 2) * (1 + (8 * LFDNoise3.ar(0.1).abs))).softclip;
					sig = FreeVerb.ar(
						sig,
						LFDNoise3.ar(0.1).abs,
						LFDNoise3.ar(0.1).abs,
						LFDNoise3.ar(0.1).abs
					);
					Out.ar(0, sig);
				}).fadeTime_(3.0);
				masterSetup = true;
			});
			([8, 4, 2, 1].choose*time).sleep;
		}
	}.fork;
});
)
