(
{ // even odd harmonics
	var baseFreq = 100;
	var numFreqs = 69;
	var vowel = Vowel(\a, \bass);
	var startFilterOrder = 4.0;
	var stopFilterOrders = [0.8, 0.65, 0.5, 0.35, 0.1];
	var freqs, evenFreqs, oddFreqs, amps, evenAmps, oddAmps, orders;
	var dur = 12;
	var evenAmpMod = SinOsc.kr(freq: 1).exprange(0.04, 1).sqrt;
	var oddAmpMod = SinOsc.kr(freq: 1, phase: pi).exprange(0.04, 1).sqrt;
	var ampEnv = Env.linen(attackTime: 0.01, sustainTime: dur, releaseTime: 0.2).kr(doneAction: 2);

	evenFreqs = ((1, 3 .. numFreqs) * baseFreq);
	oddFreqs = ((2, 4 .. numFreqs) * baseFreq);

	// there are 5 formants in each vowel, ergo 5 filter orders may be provided
	orders = stopFilterOrders.collect{|stop, i|  
		XLine.kr(startFilterOrder, stop, dur * ( 4 + (2 * i)/dur))
	};

	evenAmps = vowel.ampAt(evenFreqs, orders ) * evenAmpMod;
	oddAmps = vowel.ampAt(oddFreqs, orders ) * oddAmpMod;

	freqs = evenFreqs ++ oddFreqs;
	amps = evenAmps ++ oddAmps;

	amps = amps.normalizeSum; // tame amplitudes

	DynKlang.ar(`[freqs, amps , nil] ) * 0.1 * ampEnv;
}.play
)

