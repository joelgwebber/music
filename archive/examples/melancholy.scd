(
s.boot;

SynthDef(\plop, { arg out=0, amp=0.1, gate=1, pan=0, freq=200, t_trig=1,
		arg1=100, arg2=200, decay=0.01, flag=0.1, pluckdecay=3.1;
	var sig;
	sig = Formant.ar( 
		LFNoise0.kr( 0.05, 2.5, 7) * arg1, 
		arg2,
		500.0.rrand(700) 
	) * Trig.kr(t_trig, decay);

	sig = Pluck.ar( 
		BrownNoise.ar(0.5), 
		sig, 
		0.025, 
		freq.reciprocal.lag(flag), 
		pluckdecay
	) * 0.6;
	sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.4,0.1,0.8,7.1)),t_trig,doneAction:0);
	EnvGen.ar(Env.adsr(0.4,0.1,0.8,7.1),gate,doneAction:2);
	sig = LeakDC.ar(sig);
	sig = Pan2.ar(sig, pan, amp);
	Out.ar(out, sig);
}).add;
)

(
~baseFreq = 220;
~scale = Scale.nikriz.ratios * ~baseFreq;
//~scale = Scale.dorian.ratios * ~baseFreq;
//~scale = Scale.minor.ratios * ~baseFreq;

8.do { arg nn;
	var nnn = nn+1;

Pdef((\plop++nn).asSymbol, Pmono(
	//\instrument, \plop,
	\plop,
	\arg1, 100,
	\arg2, Pwhite(40,4000),
	\arg2, 3000,
	\decay, Pwhite(0.01,0.1),
	\decay, 0.01*nnn,
	\decay, 0.1/nnn,
	\adsr, Pseq([
		[ Env.adsr(0.1,0.1,0.8,3.3) ],
	],inf), 
	\freq, Pwhite(100,1500),
	\freq, Prand([100,1500,200,500,100],inf) * 0.7,
	\freq, Prand([100,1500,200,500,100],inf) * 1,
	\freq, Prand([100,1000,200,500,300,1000],inf) * 1,
	\freq, Pseq([100,1500,200,500,2000,100,250],inf),
	\freq, Pseq([
		100,1500,200,500,
	],inf),
	\freq, Pseq([
		100,1500,200,500,
		100,1500,200,500,
		100,1500,200,500,
		1000,100,1000,
	],inf) * Pseq([1.7,0.2,0.7,0.5],inf) * 1.0,
	\freq, Pseq([
		90,250,470,
		110,150,270,
		90,150,270,
		110,750,270,
	],inf) * Pseq([
		3,1,4,1.5,
		6,4,0.8,1.5,
	],inf) * Pseq([1,0.8,0.5,1.2],inf).stutter(32),
	\freq, Pseq([
		//Pser([100,1000],16),
		//Pser([100,2000],16),
		//Pser([200,1000*nnn],16),

		Pser([200,100]*nnn,16),
		Pser([200,400]*nnn,16),
		Pser([20,40]*nnn,16),
		//100*nnn
	],inf),
	\freq, Pseq([
		//200*log(nnn+1)
		Pser([Pfuncn({~scale.foldAt(nn)},1)],inf) * Pseq([1,2,1/6],1).stutter(16),

		Pser([200,100]*nnn,16),
		Pser([200,400]*nnn,16),
		Pser([20,40]*nnn,16),

		Pser([log(nnn+7)*200],32),
	],inf),
	\flag, Pseq([
		Prand([
		//Pser([1,0.1,1,0.1],16),
		//Pser([1,0.1,1,0.1]/2+0.3,16),
		0.05*nnn,
		0.1,
		//0.7*nnn,
		],inf)
		//Pser([1.12],16),
		//Pser([0.08],16),
	],inf),
	\lag, Pseg(Pseq([0,0.31],inf), 8)*nn,
	\arg2, Pkey(\freq),
	\arg1, Pkey(\freq),
	\sustain, 0.4,
	\dur, Pwhite(0.1,0.4) * 0.8,
	\dur, Pseq([0.5,1,1,0.5],inf) * 0.2,
	\dur, Pseq([0.5,1,1,0.5],inf) * Pseg(Pseq([3,0.2,0.1],inf), 16),
	\amp, min(1,Pkey(\dur)*3) * 1.7
)).play;
}
)
