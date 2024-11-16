s.boot;

(
s.newBusAllocators;
~vbus = Bus.audio(s, 2);
s.freeAll;
)

(
SynthDef(\reverb, {
	var sig, in;
	in = \in.ar(0);
	sig = In.ar(in, 2);
	sig = Delay2.ar(sig);
	sig = FreeVerb.ar(sig, 0.75, 0.7, 0.3);
	sig = LPF.ar(sig, \cut.ar(2000));
	sig = LeakDC.ar(sig!2);
	Out.ar(0, sig);
}).add;

SynthDef(\bass, {
	var sig, freq, duration, cutoff, fxSend;
	fxSend = \fxSend.ar(0);
	duration = \duration.kr(1);
	cutoff = SinOsc.ar(XLine.ar(duration/2, duration*3, duration)).range(\lcut.ar(100), \hcut.ar(2000));
	freq = \freq.ar(440);
	sig = Saw.ar(freq * [-0.1, 0, 0.1].midiratio);
	sig = sig.sum * -7.dbamp;
	sig = MoogFF.ar(sig, cutoff);
	sig = sig * Env.perc(\atk.kr(0.01), duration, curve: -4).ar(Done.freeSelf);
	Out.ar(\out.ar(0), sig!2 * \amp.ar(1));
	Out.ar(\fx.ar(0), sig!2 * fxSend.dbamp);
}).add;

SynthDef(\kick, {
	var sig, freq;
	freq = \freq.ar(55);
	sig = SinOsc.ar(freq * [1, 2.1, 3.2, 4.5], Rand(0, 1), [1, 0.3, 0.2, 0.1]) * (1 + (3 * Env.perc(0, 1, curve: -8).ar));
	sig = sig * Env.perc(0.001, [0.51, 0.3, 0.2, 0.1], curve: 4).ar;
	sig = sig.sum;
	sig = sig * -10.dbamp;
	sig = sig + BPF.ar(Hasher.ar(Sweep.ar), 1250, 0.3, 0.3);
	sig = sig * Env.perc(0.001, 0.3, curve: -8).ar(Done.freeSelf);
	sig = Pan2.ar(sig, \pan.ar(0));
	Out.ar(\out.ar(0), sig * \amp.ar(0.5));
}).add;

SynthDef(\snare, {
	var sig, freq;
	freq = \freq.ar(255);
	sig = SinOsc.ar(freq * [1, 2.1, 3.2, 4.5], Rand(0, 1), [0.51, 0.3, 0.2, 0.1]) * (1 + (2 * Env.perc(0, 1, curve: -8).ar));
	sig = sig * Env.perc(0, [0.51, 0.3, 0.2, 0.1], curve: 4).ar;
	sig = sig.sum;
	sig = sig * -15.dbamp;
	sig = sig + BPF.ar(Hasher.ar(Sweep.ar), 2550, 0.7);
	sig = sig + BPF.ar(Hasher.ar(Sweep.ar), 5500, 0.7);
	sig = sig * Env.perc(0.001, 0.3, curve: -8).ar(Done.freeSelf);
	sig = Pan2.ar(sig, \pan.ar(-0.4));
	Out.ar(\out.ar(0), sig * \amp.ar(0.25));
}).add;

SynthDef(\hat, {
	var sig;
	sig = WhiteNoise.ar * (1 + (2 * Env.perc(0, 0.3, curve: -10).ar));
	sig = BPF.ar(sig, 8500, 0.5);
	sig = sig + BPF.ar(sig, 8500, 0.7);
	sig = sig * -10.dbamp;
	sig = sig * Env.perc(0.001, 0.3, curve: -8).ar(Done.freeSelf);
	sig = Pan2.ar(sig, {Rand(-0.5, 0.5)});
	Out.ar(\out.ar(0), sig * \amp.ar(0.45));
}).add;
)

(
var s, tempo, beat, map, pattern, pattern2, root;

s = Server.default;
s.freeAll;

s.bind{Synth(\reverb, [\in, ~vbus], s, \addToTail)};

tempo = 60/140;
beat = tempo/4;
root = 36;
map = Dictionary[
	$k -> \kick,
	$s -> \snare,
	$h -> \hat
];

~bassline0 = Pbind(\instrument, \bass,
	\dur, beat,
	\duration, beat,
	\atk, 0.001,
	\freq, (root + Pseq([0, 10, 7, 3], 8)).midicps,
	\amp, Pseq([0.3, 0.26, 0.25, 0.27], inf),
	\fx, 0,
	\fxSend, -10
);

~bassline1 = Pbind(\instrument, \bass,
	\dur, beat,
	\duration, beat,
	\atk, 0.001,
	\freq, ((root+1) + Pseq([0, 10, 7, 3], 8)).midicps,
	\amp, Pseq([0.3, 0.26, 0.25, 0.27], inf),
	\fx, 0,
	\fxSend, -10
);

~bassline2 = Pbind(\instrument, \bass,
	\dur, beat,
	\duration, beat,
	\atk, 0.001,
	\freq, ((root+5) + Pseq([2, 10, 5, 3], 8)).midicps,
	\amp, Pseq([0.3, 0.26, 0.25, 0.27], inf),
	\fx, 0,
	\fxSend, -10
);
~bassline3 = Pbind(\instrument, \bass,
	\dur, beat,
	\duration, beat,
	\atk, 0.001,
	\freq, ((root+6) + Pseq([0, 10, 4, 3], 8)).midicps,
	\amp, Pseq([0.3, 0.26, 0.25, 0.27], inf),
	\fx, 0,
	\fxSend, -10
);

~mel0 = Pbind(\instrument, \bass,
	\dur, beat,
	\duration, beat,
	\freq, ((root+36) + Prand([0, 3, 5, 7, 10], 32)).midicps,
	\amp, Pseries(0.1, 0.01, 32),
	\lcut, 2000,
	\hcut, 2500,
	\fx, ~vbus,
	\fxSend, -15
);
~mel1 = Pbind(\instrument, \bass,
	\dur, beat,
	\duration, beat,
	\freq, ((root+29) + Prand([2, 3, 5, 7, 9], 32)).midicps,
	\amp, Pseries(0.5, -0.01, 32),
	\lcut, 1000,
	\hcut, 2000,
	\fx, ~vbus,
	\fxSend, -15
);
~mel2 = Pbind(\instrument, \bass,
	\dur, beat,
	\duration, beat,
	\freq, ((root+31) + Prand([0,1, 3, 4, 6, 8, 10], 128)).midicps,
	\amp, Pseries(0.1, 0.01, 32),
	\lcut, 5000,
	\hcut, 10000,
	\fx, ~vbus,
	\fxSend, -15
);

pattern = "
k.k.s..s..k.s...
khkhshhshhkhshhh
";

pattern2 = "
khkhsk.hhhkhs..k
khkhshhhssssssss
";

Routine({
	2.do{ |count = 0|
		2.do{
			if(count == 1) {
			~mel0.play;
		};
			~bassline0.play;
			[0, 15, 7].do{|note|
				s.bind{Synth(\bass, [
					\freq, (root + note).midicps,
					\duration, (16*beat),
					\atk, 0.3,
					\out, 0,
					\fx, ~vbus,
					\fxsend, -5,
				])};
			};
			pattern.do{|character|
				if(character == $.){
					beat.wait;
				} {
					if(map[character].notNil) {
						s.bind{Synth(map[character]);};
						beat.wait;
					};
				};
			};
			~bassline1.play;
			[1, 16, 8].do{|note|
				s.bind{Synth(\bass, [
					\freq, (root + note).midicps,
					\duration, (16*beat),
					\out, 0,
					\fx, ~vbus,
					\fxsend, -1
				])};
			};
			pattern2.do{|character|
				if(character == $.){
					beat.wait;
				} {
					if(map[character].notNil) {
						s.bind{Synth(map[character]);};
						beat.wait;
					};
				};
			};
		};
		1.do{
			if(count == 1) {
			~mel1.play;
		};
			~bassline2.play;
			[0, 15, 7].do{|note|
				s.bind{Synth(\bass, [
					\freq, ((root+5) + note).midicps,
					\duration, (16*beat),
					\out, 0,
					\fx, ~vbus,
					\fxsend, 1
				])};
			};
			pattern.do{|character|
				if(character == $.){
					beat.wait;
				} {
					if(map[character].notNil) {
						s.bind{Synth(map[character]);};
						beat.wait;
					};
				};
			};
			~bassline3.play;
			[1, 15, 7].do{ |note|
				s.bind{Synth(\bass, [
					\freq, ((root+5) + note).midicps,
					\duration, (16*beat),
					\out, 0,
					\fx, ~vbus,
					\fxsend, 0
				])};
			};
			pattern2.do{|character|
				if(character == $.){
					beat.wait;
				} {
					if(map[character].notNil) {
						s.bind{Synth(map[character]);};
						beat.wait;
					};
				};
			};
		};
		1.do{
			if(count == 1) {
				~mel2.play;
			};
			[0, 16, 7, 10].do{ |note|
				s.bind{Synth(\bass, [
					\freq, ((root + 7) + note).midicps,
					\atk, 0.3,
					\duration, (64*beat),
					\out, 0,
					\fx, ~vbus,
					\fxsend, -1
				])};
			};
			pattern.do{|character|
				if(character == $.){
					beat.wait;
				} {
					if(map[character].notNil) {
						s.bind{Synth(map[character]);};
						beat.wait;
					};
				};
			};
			pattern2.do{|character|
				if(character == $.){
					beat.wait;
				} {
					if(map[character].notNil) {
						s.bind{Synth(map[character]);};
						beat.wait;
					};
				};
			};
		};
		count = count + 1;
	};
	//end

	s.bind{Synth(\bass, [
		\freq, root.midicps,
		\duration, (64*beat),
		\lcut, 250,
		\hcut, 1000,
		\amp, 0.5,
		\out, 0,
		\fx, 0
	])};

	[0, 15, 7].do{|note|
		s.bind{Synth(\bass, [
			\freq, (root+note).midicps,
			\duration, (64*beat),
			\out, 0,
			\fx, ~vbus,
			\fxsend, 2,
			\lcut, 750,
			\hcut, 5000,
			\amp, 0.5
		])};
	};
}).play;
)
