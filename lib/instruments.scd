(
SynthDef(\who, {|amp=0.1, freq=440, detune=0, gate=1, out=0, ffreq=800|
  var env = Env.asr(0.01, amp, 0.5);
  var sig = Formant.ar(freq + detune, ffreq, 120,
    EnvGen.kr(env, gate, doneAction: Done.freeSelf)
  );
  Out.ar(out, sig)
}).add;

SynthDef(\singrain, {|freq = 440, amp = 0.2, sustain = 1, out|
  Out.ar(out, (
    SinOsc.ar(freq, 0, amp) *
    EnvGen.kr(Env.perc(0.01, sustain), doneAction: Done.freeSelf)
  ) ! 2)
}).add;

SynthDef(\sinegrain2, {|out=0, freq=440, sustain=0.05, pan|
  var sig = Pan2.ar(
    SinOsc.ar(freq, 0, EnvGen.kr(Env.perc(0.01, sustain, 0.3), doneAction: Done.freeSelf)),
    pan
  );
  Out.ar(out, sig)
}).add;

SynthDef(\smooth, {|freq = 440, sustain = 1, amp = 0.5, out|
  var sig =
    SinOsc.ar(freq, 0, amp) *
    EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: Done.freeSelf);
  Out.ar(out, sig ! 2)
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

SynthDef(\kik, {|out, preamp = 1, amp = 1|
  var freq = EnvGen.kr(Env([400, 66], [0.08], -3));
  var sig =
    SinOsc.ar(freq, 0.5pi, preamp).distort * amp *
    EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: Done.freeSelf);
  Out.ar(out, sig ! 2);
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
)

