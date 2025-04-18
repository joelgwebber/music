/*
Requires SC3-plugins:
JPverb
WaveLoss
Greyhole
*/

(
s.waitForBoot({
Ndef(\n, {

	//var lfo = A2K.kr(HenonC.ar(1));
	//var lfo = A2K.kr(StandardL.ar([1,3]));
	var lfo1 = LFPulse.kr(1/16).range(1/2,1);
	var lfo = min(LFTri.kr([lfo1/2, lfo1/3], mul: 3).tanh, LFDNoise1.kr(lfo1));

	var in = lfo.range(0, 11).round;
	// Kumoi scale
	var scale = [
		\s0.kr(1),
		\s1.kr(0),
		\s2.kr(1),
		\s3.kr(1),
		\s4.kr(0),
		\s5.kr(1),
		\s6.kr(0),
		\s7.kr(1),
		\s8.kr(0),
		\s9.kr(1),
		\s10.kr(0),
		\s11.kr(0)
	];

	var inscale = Select.kr(in, scale);
	var semi = in * inscale;

	var trig = Changed.kr(semi);
	var trig2 = PulseDivider.kr(trig, 3);
	var midi = TChoose.kr(trig2, \root.kr(60) + [0, 12, 24]) + (semi) * (inscale > 0);

	var env = Decay2.kr(in:trig * (inscale > 0), decayTime:lfo1);
	var freq = midi.midicps;
	var sig = SinOscFB.ar(freq.lag(0.01) * [1, 1.01], feedback: SinOsc.kr(0.1).range(0.3,0.7)) * env;

	sig = RLPF.ar(sig, env.range(880, 2200), 0.3);
	sig = XFade2.ar(sig, JPverb.ar(HPF.ar(sig, 100), t60:1, size:3), 0);
	sig = XFade2.ar(sig, WaveLoss.ar(sig), -0.1);
	sig = XFade2.ar(sig, Greyhole.ar(sig), -0.75);

	sig * 0.2;

}).play;
})
)


/////////////////////////
// randomly change the scale
// (Kumoi scale sounds nice)
(
var vals = Array.fill(12, 0);
var scale = Scale.choose(size:[5,7].choose, pitchesPerOctave:12);
scale.name.postln;
scale.degrees.do({arg val;
	vals[val] = 1;
});
vals.do({arg val, i;
	var key = (\s ++ i).asSymbol;
	Ndef(\n).set(key, val);
});
)
