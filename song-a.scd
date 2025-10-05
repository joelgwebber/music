(
Server.local.boot;
"./lib/instruments.scd".load;

// Piano synth with realistic attack and controllable sustain
SynthDef(\piano, {|out=0, freq=440, gate=1, amp=0.5, vel=0.7, sustain=1, pan=0|
  var sig, env, harmonics, decay;

  // Realistic piano envelope: fast attack, exponential decay
  // sustain parameter controls the decay time (0.1 to 4, default 1)
  decay = sustain.clip(0.1, 4);
  env = EnvGen.kr(
    Env.perc(0.001, decay, 1, -6),
    gate,
    doneAction: Done.freeSelf
  );

  // Multiple harmonics for piano-like timbre
  // Lower harmonics are louder, higher ones add brightness
  harmonics = Mix.ar([
    // Fundamental and first few harmonics (strong)
    SinOsc.ar(freq * 1, 0, 1.0),
    SinOsc.ar(freq * 2, 0, 0.5),
    SinOsc.ar(freq * 3, 0, 0.3),
    SinOsc.ar(freq * 4, 0, 0.2),
    // Higher harmonics for brightness
    SinOsc.ar(freq * 5, 0, 0.1),
    SinOsc.ar(freq * 6, 0, 0.08),
    SinOsc.ar(freq * 7, 0, 0.05),
    SinOsc.ar(freq * 8, 0, 0.03)
  ]) * 0.15;

  // Add slight inharmonicity (piano strings aren't perfectly harmonic)
  harmonics = harmonics + Mix.ar([
    SinOsc.ar(freq * 1.003, 0, 0.05),
    SinOsc.ar(freq * 2.01, 0, 0.03)
  ]);

  // Velocity affects both amplitude and tone
  // Higher velocity = brighter sound (less filtering)
  sig = LPF.ar(harmonics, vel.linexp(0, 1, 2000, 12000));

  // Apply envelope and velocity-sensitive amplitude
  sig = sig * env * vel.linlin(0, 1, 0.3, 1.0) * amp;

  // Stereo output with panning
  Out.ar(out, Pan2.ar(sig, pan));
}).add;
)

(
~clock = TempoClock.new(120/60); // 120 BPM
~piano = Pchain(
  Prhythm.straight(4),
  Pchord.minor(\C, -1).arp,
  Pbind(\instrument, \piano, \vel, 0.7, \sustain, 1.5, \pan, 0)
).play(~clock);
)

~piano.stop;
