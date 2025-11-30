(
Server.local.boot;
"./lib/piano.scd".load;
)

(
~clock = TempoClock(60/60); // 60 BPM

~left  = (instrument: \piano, amp: 0.4, sustain: 4);
~right = (instrument: \piano, amp: 0.3, sustain: 2);

~bassRhythm = Prhythm.note(4);
~arpRhythm = Prhythm.straight(12, 4);

// M3: F#m/D# (D#-F#-A) = iv6
~phrase = Pphrase(inf, (
  arp:  Pvoice(Pchord(\E, [4, 5], 4).arp(\up), ~arpRhythm,  ~right),
  bass: Pvoice(Pmelody([\A], octave: 2),       ~bassRhythm, ~left),
));

~phrase.asTab.postln;

~composition = Pseq([~phrase]);
~player = ~composition.play(~clock);
)

~player.stop;

