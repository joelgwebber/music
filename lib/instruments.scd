(
"./lib/drums.scd".load;

SynthDef(\who, {|amp=0.1, freq=440, detune=0, gate=1, out=0, ffreq=800|
	var env = EnvGen.kr(
		Env.asr(0.01, amp, 0.5), gate,
		doneAction: Done.freeSelf
	);
  Out.ar(out, Formant.ar(freq + detune, ffreq, 120, env));
}).add;

SynthDef(\singrain, {|out=0, freq=440, sustain=0.05, pan=0.5|
  var env = EnvGen.kr(
    Env.perc(0.01, sustain, 0.3),
		doneAction: Done.freeSelf
  );
  Out.ar(out, Pan2.ar(
    SinOsc.ar(freq, 0, env),
    pan
  ));
}).add;

SynthDef(\smooth, {|freq = 440, sustain = 1, amp = 0.5, out|
  var env = EnvGen.kr(
    Env.linen(0.05, sustain, 0.1),
    doneAction: Done.freeSelf
  );
  Out.ar(out, (SinOsc.ar(freq, 0, amp) * env) ! 2);
}).add;

SynthDef(\bass, {|out, freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15, detune = 1.005, preamp = 4|
  var lagged = Lag.kr(freq, slideTime);
  var env = Env.adsr(0.01, 0.3, 0.4, 0.1);
  var sig = LPF.ar(
    Mix(VarSaw.ar([lagged, lagged * detune], 0, width, preamp)).distort *
      amp * EnvGen.kr(env, gate, doneAction: Done.freeSelf),
    ffreq
  );
  Out.ar(out, sig ! 2)
}).add;

SynthDef(\cfstring1, {|i_out, freq = 360, gate = 1, pan, amp=0.1|
  var out, eg, fc, osc, a, b, w;
  fc = LinExp.kr(LFNoise1.kr(Rand(0.25, 0.4)), -1, 1, 500, 2000);
  osc = Mix.fill(8, {LFSaw.ar(freq * [Rand(0.99, 1.01), Rand(0.99, 1.01)], 0, amp) }).distort * 0.2;
  eg = EnvGen.kr(Env.asr(1, 1, 1), gate, doneAction: Done.freeSelf);
  out = eg * RLPF.ar(osc, fc, 0.1);
  #a, b = out;
  Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

SynthDef(\pls, { |freq=220 out=0 amp=0.7 res=0.5|
  var sig, env;
  sig = LFPulse.ar(Line.ar(freq, freq/4, Rand(0.01, 0.1)), 0, Rand(0.01, 0.99), amp);
  sig = RLPF.ar(sig, freq*5*Line.kr(1, 0, Rand(0.1, 0.9)), res);
  env = Env.perc(0.001, Rand(0.1, 0.8)).kr(2);
  sig = (sig * env * 2).softclip;
  sig = Pan2.ar(sig, Rand(-0.5, 0.5));
  Out.ar(out, sig);
}).add;

SynthDef(\sin, {arg freq=110, out=0, amp=0.9, gate=1;
  Out.ar(out,
    Pan2.ar(
      RHPF.ar(
        SinOsc.ar(freq, 0, amp) * Env.adsr.kr(2, gate),
        LFDNoise3.ar(Rand(0.01, 16), freq).abs,
        LFDNoise3.ar(Rand(0.01, 3), 1).abs
      ) * 0.1,
      Rand(-0.9, 0.9)
    ).softclip
  );
}).add;

SynthDef(\help_SPE2, { |i_out=0, sustain=1, freq|
    var out;
    out = RLPF.ar(
        LFSaw.ar( freq ),
        LFNoise1.kr(1, 36, 110).midicps,
        0.1
    ) * EnvGen.kr( Env.perc, levelScale: 0.3,
        timeScale: sustain, doneAction: Done.freeSelf );
    out = [out, DelayN.ar(out, 0.04, 0.04) ];
    4.do({ out = AllpassN.ar(out, 0.05, [0.05.rand, 0.05.rand], 4) });
    Out.ar( i_out, out );
}).send(s);

SynthDef(\BerlinB, { arg i_out=0, freq = 80, amp = 0.2, pan=0;
    var out, a, b;
    amp = Decay2.kr(Impulse.kr(0), 0.05, 8, amp);
    out = RLPF.ar(
        LFPulse.ar(freq, 0, SinOsc.kr(0.12,[0,0.5pi],0.48,0.5), amp),
        freq * SinOsc.kr(0.21,0,4,8),
        0.07
    );
    #a, b = out;
    DetectSilence.ar(a, 0.0001, doneAction: Done.freeSelf);
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+1])));
}).add;

SynthDef(\CFString1, { arg i_out, freq = 360, gate = 1, pan, amp=0.1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25,0.4)), -1,1,500,2000);
    osc = Mix.fill(8, { LFSaw.ar(freq * [Rand(0.99,1.01),Rand(0.99,1.01)], 0, amp) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(1,1,1), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

SynthDef(\CFString2, { arg i_out, freq = 360, gate = 1, pan, amp=0.1, dorkarg=1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25,0.4)), -1,1,500,2000);
    osc = Mix.fill(8, { LFSaw.ar(freq * [Rand(0.99,1.01),Rand(0.99,1.01)], 0, amp * dorkarg ) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(1,1,1), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

SynthDef(\pgrain,
    { arg out = 0, freq=800, sustain=0.001, amp=0.5, pan = 0;
        var window;
        window = Env.sine(sustain, amp * AmpCompA.kr(freq));
        Out.ar(out,
            Pan2.ar(
                SinOsc.ar(freq),
                pan
            ) * EnvGen.ar(window, doneAction: Done.freeSelf)
        )
    }
).add;

SynthDef(\noiseGrain,
    { arg out = 0, freq=800, sustain=0.001, amp=0.5, pan = 0;
        var window;
        window = Env.perc(0.002, sustain, amp * AmpCompA.kr(freq));
        Out.ar(out,
            Pan2.ar(
                Ringz.ar(PinkNoise.ar(0.1), freq, 2.6),
                pan
            ) * EnvGen.ar(window, doneAction: Done.freeSelf)
        )
    }
).add;
)

