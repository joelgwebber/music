(
s.boot;

~molecular_box = { arg lenpat, quant=16, keep=3, pattern;

	Prout({ arg ev;
		var lenstr = lenpat.asStream;
		var patstr;
		var buf = Array.fill(quant,{List.new});
		var pat, len;
		var i;
		var basepat;

		patstr = pattern.asStream;

		len = lenstr.next;
		if(len.isNil) {
				nil.yield;
		};

		i = 0;
		inf.do {
			var n;
			buf[i] = buf[i].keep(0-keep);
			n = buf[i];

			if(n.size != 0) {
				// previous note found, change note length
				len = lenstr.next;
				if(len.isNil) {
					 nil.yield;
				};
			};

			basepat = ev;
			basepat[\legato] = len;
			pat = patstr.next(basepat);
                        if(pat.isNil) {
                           nil.yield;
                        };

			n.add(Pn(pat,1));

			len.do {
				var n = buf[i];

				if(n.size != 0) {
					ev = Ppar(n).embedInStream;
				} {
					var myev;
					myev = ev.deepCopy;
					myev[\isRest] = true;
					ev = Pn(myev,1).embedInStream;
				};
				i = (i+1) % quant;
			};
		}
	})
};
);

(
SynthDef(\simple, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	sig = SinOsc.ar(freq * [1,1.01,2.01,1.02,1/2] * (SinOsc.kr(3)*0.01+1));
	sig = sig + LFTri.ar(freq * [1,1/2,1.01]);
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;
SynthDef(\saw, { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2;
	var sig, sig1, sig2, sig3;
	var env;
	sig = LFSaw.ar(freq * [1,1.01,2.01,1.02]);
	sig = Pulse.ar(freq * [1,1.01,2,2.01,1.002]) + sig;
	env = EnvGen.ar(Env.adsr(0.4,0.3,0.31,0.1),gate,doneAction:0);
	sig = RLPF.ar(sig, \ffreq.kr(1000) * (env+0.5));
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:doneAction);
	sig = Splay.ar(sig, spread, amp, pan);
	Out.ar(out, sig);
}).add;
SynthDef(\reverb, {arg out = 0, in=0;
    var sig = In.ar(in, 2);
    sig = FreeVerb.ar(sig,0.5,0.7);
    ReplaceOut.ar(out, sig);
}).add;
);

Synth.tail(1,\reverb); // if you want

(
Pdef(\mol, 
	~molecular_box.(Pseq([4.5,8],inf), 16, 3,
		Pseq([
			Pbind(
				\instrument, Pn(\simple,4),
				\adsr, Pseq([
					[ Env.adsr(0.1,0.1,0.8,0.4) ],
					[ Env.adsr(0.4,0.4,0.6,0.2) ],
				],inf),
				\legato, Pkey(\legato) / 2,
			),
			Pbind(
				\instrument, Pn(\saw,4),
				\ffreq, Pseq([5000,1000,200,2000],inf),
				\adsr, Pseq([
					[ Env.adsr(0.1,0.4,0.4,0.3) ],
				],inf),
				\legato, Pkey(\legato) / 2,
			),
		],inf) 
		<>
		Pbind(
			\degree, Pseq([
				Pseq((0..13)),
				Pseq((0..10)-4),
				Pseq((5..1)),
				Pseq((0..5)*2),
				Pseq((20..10)),
				Pseq((0..10)-10),
			],inf),
		);
	)
	<>
	Pbind(
		\dur, 1/4,
		\scale, Scale.minor,
	)
).play;
)

(
Pdef(\mol, 
	~molecular_box.(Pseq([4.5,2,5,1],inf), 16, 3,
		Pbind(
			\legato, Pseq([
				Pfuncn({ arg ev; ev[\legato] },16),
				Pser([0.5],16)
			],inf)
		)
		<>
		Pseq([
			Pbind(
				\instrument, Pn(\simple,4),
				\adsr, Pseq([
					[ Env.adsr(0.1,0.1,0.8,0.4) ],
					[ Env.adsr(0.4,0.4,0.6,0.2) ],
				],inf),
				\legato, Pkey(\legato) * Pseq([0.2,0.8,1.2],inf).stutter(3),
			),
			Pbind(
				\instrument, Pn(\saw,2),
				\ffreq, Pseq([5000,1000,700],inf),
				\adsr, Pseq([
					[ Env.adsr(0.1,0.4,0.4,0.3) ],
				],inf),
			),
			Pbind(
				\instrument, Pn(\saw,2),
				\ffreq, Pkey(\freq) * 4,
				\adsr, Pseq([
					[ Env.adsr(0.1,0.4,0.4,0.3) ],
				],inf),
			),
		],inf) 
		<>
		Pbind(
			\degree, Pseq([
				Pseq((5..1)),
				Pseq((0..3)),
				Pseq((0..10)-4),
				Pseq((0..5)*3),
				Pseq((2..10)),
				Pseq((0..10)-10),
			],inf),
		);
	)
	<>
	Pbind(
		\dur, 1/4,
		\mtranspose, 2,
		\root, 4,
		\scale, Scale.aeolian,
	)
).play;
)
