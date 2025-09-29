(
Server.local.boot;
"lib/instruments.scd".load;
)

( // Chords to use throughout.
~cm = Chord.minor(3, -2);
~gm = ~cm.l.l;
~ebmaj7 = Chord.maj7(3, -2);
~fM = ~cm.p.r.r;

~gsus4 = Chord.sus4(7, -1);
~gM = ~gm.p;
~g7 = ~gM.add7(\dom);

~prog = Prog([~cm, ~gm, ~cm, ~gm, ~ebmaj7, ~fM, ~gsus4, ~gM, ~g7]);
)

( // Define the melody.
Pdef(\prog, ~prog);
Pdef(\swing4, Rhythm.swing);
)

(
~melody = Pchain(
	Pdef(\swing4),
	Pdef(\prog),
	Pbind(\instrument, \singrain),
).play;
)

( // And a bass line from the roots.
~bass = Pchain(
	~prog.octave(-1).bassLine,
	Rhythm.straight(1, 0.5),
	Pbind(\instrument, \bass, \amp, 0.1),
).play;
)

( // Flatten and straighten the rhythm.
Pdef(\prog, ~prog.arp(\down));
Pdef(\swing4, Rhythm.straight(4, 0.25));
)

( // Vary the progression.
~prog = Prog([~cm, ~gm, ~cm, ~gm, ~ebmaj7, ~cm, ~gm, ~cm, ~gm, ~g7]);
Pdef(\prog, ~prog);
)

~bass.stop;
~melody.stop;

