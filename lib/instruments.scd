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

SynthDef(\help_SPE7_BerlinB, { arg i_out=0, freq = 80, amp = 0.2, pan=0;
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

SynthDef(\help_SPE7_CFString1, { arg i_out, freq = 360, gate = 1, pan, amp=0.1;
    var out, eg, fc, osc, a, b, w;
    fc = LinExp.kr(LFNoise1.kr(Rand(0.25,0.4)), -1,1,500,2000);
    osc = Mix.fill(8, { LFSaw.ar(freq * [Rand(0.99,1.01),Rand(0.99,1.01)], 0, amp) }).distort * 0.2;
    eg = EnvGen.kr(Env.asr(1,1,1), gate, doneAction: Done.freeSelf);
    out = eg * RLPF.ar(osc, fc, 0.1);
    #a, b = out;
    Out.ar(i_out, Mix.ar(PanAz.ar(4, [a, b], [pan, pan+0.3])));
}).add;

SynthDef(\help_SPE4_CFString2, { arg i_out, freq = 360, gate = 1, pan, amp=0.1, dorkarg=1;
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

SynthDef(\SOSkick,
	{ arg out = 0, freq = 50, mod_freq = 5, mod_index = 5, sustain = 0.4, amp = 0.8, beater_noise_level = 0.025;
	var pitch_contour, drum_osc, drum_lpf, drum_env;
	var beater_source, beater_hpf, beater_lpf, lpf_cutoff_contour, beater_env;
	var kick_mix;
	pitch_contour = Line.kr(freq*2, freq, 0.02);
	drum_osc = PMOsc.ar(	pitch_contour,
				mod_freq,
				mod_index/1.3,
				mul: 1,
				add: 0);
	drum_lpf = LPF.ar(in: drum_osc, freq: 1000, mul: 1, add: 0);
	drum_env = drum_lpf * EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	beater_source = WhiteNoise.ar(beater_noise_level);
	beater_hpf = HPF.ar(in: beater_source, freq: 500, mul: 1, add: 0);
	lpf_cutoff_contour = Line.kr(6000, 500, 0.03);
	beater_lpf = LPF.ar(in: beater_hpf, freq: lpf_cutoff_contour, mul: 1, add: 0);
	beater_env = beater_lpf * EnvGen.ar(Env.perc, 1.0, doneAction: 2);
	kick_mix = Mix.new([drum_env, beater_env]) * 2 * amp;
	Out.ar(out, [kick_mix, kick_mix])
	}
).add;

SynthDef(\SOSsnare,
	{arg out = 0, sustain = 0.1, drum_mode_level = 0.25,
	snare_level = 40, snare_tightness = 1000,
	freq = 405, amp = 0.8;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var snare_noise, snare_brf_1, snare_brf_2, snare_brf_3, snare_brf_4, snare_reson;
	var snare_env;
	var snare_drum_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.53, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.85),
					184,
					0.5/1.3,
					mul: drum_mode_env*5,
					add: 0);
	drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;

  // choose either noise source below
  //	snare_noise = Crackle.ar(2.01, 1);
	snare_noise = LFNoise0.ar(20000, 0.1);
	snare_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	snare_brf_1 = BRF.ar(in: snare_noise, freq: 8000, mul: 0.5, rq: 0.1);
	snare_brf_2 = BRF.ar(in: snare_brf_1, freq: 5000, mul: 0.5, rq: 0.1);
	snare_brf_3 = BRF.ar(in: snare_brf_2, freq: 3600, mul: 0.5, rq: 0.1);
	snare_brf_4 = BRF.ar(in: snare_brf_3, freq: 2000, mul: snare_env, rq: 0.0001);
	snare_reson = Resonz.ar(snare_brf_4, snare_tightness, mul: snare_level) ;
	snare_drum_mix = Mix.new([drum_mode_mix, snare_reson]) * 5 * amp;
	Out.ar(out, [snare_drum_mix, snare_drum_mix])
	}
).add;

SynthDef(\SOShats,
	{arg out = 0, freq = 6000, sustain = 0.1, amp = 0.8;
	var root_cymbal, root_cymbal_square, root_cymbal_pmosc;
	var initial_bpf_contour, initial_bpf, initial_env;
	var body_hpf, body_env;
	var cymbal_mix;
	
	root_cymbal_square = Pulse.ar(freq, 0.5, mul: 1);
	root_cymbal_pmosc = PMOsc.ar(root_cymbal_square,
					[freq*1.34, freq*2.405, freq*3.09, freq*1.309],
					[310/1.3, 26/0.5, 11/3.4, 0.72772],
					mul: 1,
					add: 0);
	root_cymbal = Mix.new(root_cymbal_pmosc);
	initial_bpf_contour = Line.kr(15000, 9000, 0.1);
	initial_env = EnvGen.ar(Env.perc(0.005, 0.1), 1.0);
	initial_bpf = BPF.ar(root_cymbal, initial_bpf_contour, mul:initial_env);
	body_env = EnvGen.ar(Env.perc(0.005, sustain, 1, -2), 1.0, doneAction: 2);
	body_hpf = HPF.ar(in: root_cymbal, freq: Line.kr(9000, 12000, sustain),mul: body_env, add: 0);
	cymbal_mix = Mix.new([initial_bpf, body_hpf]) * amp;
	Out.ar(out, [cymbal_mix, cymbal_mix])
}).add;

SynthDef(\SOStom,
	{arg out = 0, sustain = 0.4, drum_mode_level = 0.25,
	freq = 90, drum_timbre = 1.0, amp = 0.8;
	var drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc, drum_mode_mix, drum_mode_env;
	var stick_noise, stick_env;
	var drum_reson, tom_mix;

	drum_mode_env = EnvGen.ar(Env.perc(0.005, sustain), 1.0, doneAction: 2);
	drum_mode_sin_1 = SinOsc.ar(freq*0.8, 0, drum_mode_env * 0.5);
	drum_mode_sin_2 = SinOsc.ar(freq, 0, drum_mode_env * 0.5);
	drum_mode_pmosc = PMOsc.ar(	Saw.ar(freq*0.9),
								freq*0.85,
								drum_timbre/1.3,
								mul: drum_mode_env*5,
								add: 0);
	drum_mode_mix = Mix.new([drum_mode_sin_1, drum_mode_sin_2, drum_mode_pmosc]) * drum_mode_level;
	stick_noise = Crackle.ar(2.01, 1);
	stick_env = EnvGen.ar(Env.perc(0.005, 0.01), 1.0) * 3;
	tom_mix = Mix.new([drum_mode_mix, stick_env]) * 2 * amp;
	Out.ar(out, [tom_mix, tom_mix])
	}
).add;

SynthDef(\snare909,{ |out=0,mul=1,velocity=1|
	var excitation, membrane;

	excitation = LPF.ar(WhiteNoise.ar(1), 7040, 1) * (0.1 + velocity);
	membrane = (
		/* Two simple enveloped oscillators represent the loudest resonances of the drum membranes */
		(LFTri.ar(330,0,1) * EnvGen.ar(Env.perc(0.0005,0.055),doneAction:0) * 0.25)
		+(LFTri.ar(185,0,1) * EnvGen.ar(Env.perc(0.0005,0.075),doneAction:0) * 0.25)

		/* Filtered white noise represents the snare */
		+(excitation * EnvGen.ar(Env.perc(0.0005,0.4),doneAction:2) * 0.2)
		+(HPF.ar(excitation, 523, 1) * EnvGen.ar(Env.perc(0.0005,0.283),doneAction:0) * 0.2)

	) * mul;
	Out.ar(out, membrane!2)
}).add;
)

