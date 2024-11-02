(
SynthDef(\who, {|amp=0.1, freq=440, detune=0, gate=1, out=0, ffreq=800|
    var env;
    env = Env.asr(0.01, amp, 0.5);
    Out.ar(out,
        Formant.ar(freq + detune, ffreq, 120, EnvGen.kr(env, gate, doneAction: Done.freeSelf)),
    )
}).add;

SynthDef(\singrain, {|freq = 440, amp = 0.2, sustain = 1, out|
  var sig;
  sig = SinOsc.ar(freq, 0, amp) *
        EnvGen.kr(Env.perc(0.01, sustain), doneAction: Done.freeSelf);
  Out.ar(out, sig ! 2);    // sig ! 2 is the same as [sig, sig]
}).add;

SynthDef(\sinegrain2, {|out=0, freq=440, sustain=0.05, pan|
    var env;
    env = EnvGen.kr(Env.perc(0.01, sustain, 0.3), doneAction: Done.freeSelf);
    Out.ar(out, Pan2.ar(SinOsc.ar(freq, 0, env), pan))
}).add;

SynthDef(\smooth, {|freq = 440, sustain = 1, amp = 0.5, out|
    var sig;
    sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: Done.freeSelf);
    Out.ar(out, sig ! 2)
}).add;

SynthDef(\bass, {|out, freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15,
        detune = 1.005, preamp = 4|
    var sig, env;
    env = Env.adsr(0.01, 0.3, 0.4, 0.1);
    freq = Lag.kr(freq, slideTime);
    sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
        * EnvGen.kr(env, gate, doneAction: Done.freeSelf);
    sig = LPF.ar(sig, ffreq);
    Out.ar(out, sig ! 2)
}).add;

SynthDef(\kik, {|out, preamp = 1, amp = 1|
    var freq = EnvGen.kr(Env([400, 66], [0.08], -3)),
        sig = SinOsc.ar(freq, 0.5pi, preamp).distort * amp
            * EnvGen.kr(Env([0, 1, 0.8, 0], [0.01, 0.1, 0.2]), doneAction: Done.freeSelf);
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
)

