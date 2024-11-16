s.boot;
(
/**
* SELFSTEP by Alexander Zhagun-Linnik, 2018
* a simple self-playing piece with generative patterning
**/
{
	var scale = Scale.harmonicMinor;
	var time = 1.5;                   // beat length in seconds multiplied by 2

	// define synths
	SynthDef(\pls, {arg freq=220, out=0, amp=0.7, res=0.5;
		var sig, env;
		sig = LFPulse.ar(Line.ar(freq, freq/4, Rand(0.01, 0.1)), 0, Rand(0.01, 0.99), amp);
		sig = RLPF.ar(sig, freq*5*Line.kr(1, 0, Rand(0.1, 0.9)), res);
		env = Env.perc(0.001, Rand(0.1, 0.8)).kr(2);
		sig = (sig * env * 2).softclip;
		sig = Pan2.ar(sig, Rand(-0.5, 0.5));
		Out.ar(out, sig);
	}).add;
	SynthDef(\kck, {arg freq=220, out=0, amp=0.9;
		var sig, env;
		sig = SinOsc.ar(Line.ar(freq, freq/4, Rand(0.01, 0.1)), 0, 0.5, amp);
		sig = RLPF.ar(sig, freq*8*Line.kr(1, 0, Rand(0.01, 0.3)));
		env = Env.perc(0.001, Rand(0.01, 0.5), 0.5).kr(2);
		sig = (sig * env * 4).softclip;
		sig = Pan2.ar(sig, Rand(-0.3, 0.3));
		Out.ar(out, sig);
	}).add;
	SynthDef(\sin, {arg freq=110, out=0, amp=0.9, gate=1;
		var sig;
		sig = SinOsc.ar(freq, 0, amp)*Env.adsr.kr(2, gate);
		sig = RHPF.ar(sig, LFDNoise3.ar(Rand(0.01, 16), freq).abs, LFDNoise3.ar(Rand(0.01, 3), 1).abs)*0.1;
		sig = Pan2.ar(sig, Rand(-0.9, 0.9)).softclip;
		Out.ar(out, sig);
	}).add;
	SynthDef(\snr, {arg freq=220, out=0, amp=1.0;
		var sig, env;
		sig = WhiteNoise.ar(1);
		sig = RLPF.ar(sig, freq*6*Line.ar(1, 0, Rand(0.01, 0.3)), Rand(0.4, 0.6));
		env = Env.perc(0.001, Rand(0.01, 0.2)).kr(2);
		sig = (sig * env * amp * 8).softclip;
		sig = Pan2.ar(sig, Rand(-0.5, 0.5));
		Out.ar(out, sig);
	}).add;
	SynthDef(\hgh, {arg freq=220, out=0, amp=1.0, res=0.5;
		var sig, env;
		sig = WhiteNoise.ar(1);
		sig = RHPF.ar(sig, freq*40*Line.ar(0.5, 1, Rand(0.01, 0.1)), res);
		env = Env.perc(0.001, Rand(0.01, 0.1)).kr(2);
		sig = (sig * env * amp * 2).softclip;
		sig = Pan2.ar(sig, Rand(-0.7, 0.7));
		Out.ar(out, sig);
	}).add;
	s.sync; // wait for server to load synthdefs

	// define patterns...
	Ppar([
		Pbind(
			\instrument, \kck,
			\dur,  Prand([time/2, time/2, time/2, time/2, time/4, time/8], inf),
			\scale, scale,
			\degree, Pbrown(0, 8, Prand([1, 2], inf)),
			\octave, 4,
		),
		Pbind(
			\instrument, \pls,
			\dur, Prand([time/8, time/4], inf),
			\scale, scale,
			\degree, Pbrown(0, 12, Prand([1, 2, 3], inf)),
			\octave, 4,
			\res, Pfunc({(SystemClock.seconds*0.03).sin.abs})
		),
		Pbind(
			\instrument, \pls,
			\dur, Prand([time/2, time, time/4, time/8], inf),
			\scale, scale,
			\degree, Pbrown(0, 12, Prand([1, 2, 3, 4, 5], inf)),
			\octave, 5,
			\res, Pfunc({(SystemClock.seconds*0.5).sin.abs})
		),
		Pbind(
			\instrument, \sin,
			\dur, Prand([1, 2, 4, 8], inf),
			\scale, scale,
			\degree, Pbrown(0, 12, Prand([1, 2, 3, 4, 5], inf)),
			\octave, 5,
			\amp, Pfunc({0.3.rand})
		),
		Pbind(
			\instrument, \sin,
			\dur, Prand([1, 2, 4, 8], inf),
			\scale, scale,
			\degree, Pbrown(0, 12, Prand([1, 2, 3, 4, 5], inf)),
			\octave, 5,
			\amp, Pfunc({0.3.rand})
		),
		Pbind(
			\instrument, \snr,
			\dur, Prand([time, time, time, time, time/8, time/4], inf),
			\scale, scale,
			\degree, Pbrown(0, 12, Prand([1, 2, 3], inf)),
			\octave, 5,
		),
		Pbind(
			\instrument, \hgh,
			\dur, Prand([time/8], inf),
			\scale, scale,
			\degree, Prand(Array.fill(8, {arg i;i}), inf),
			\octave, Prand(Array.fill(6, {arg i;i}), inf),
			\res, Pfunc({(SystemClock.seconds*0.3).sin.abs}),
		)
	]).play; // ...and start playing
}.fork;
)
