# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a SuperCollider music composition and live coding repository that contains custom classes for music theory, rhythm patterns, and composition tools.

## Critical Setup Information

### SuperCollider Integration
- **lib/ Directory**: All `.sc` files in `lib/` are automatically symlinked into SuperCollider's classpath and added to the class library
- **Execution Method**: The user controls SuperCollider through a vim plugin. Never attempt to execute SuperCollider directly from the shell
- **Working with SC**: Write SuperCollider code into `.scd` files (like `compo.scd`) and the user will execute them

## Repository Structure

### Core Classes (lib/Classes/)
All pattern classes follow SuperCollider's P-prefix convention:
- `Pitches.sc`: Base class for pitch collections (renamed from Notes)
- `Pchord.sc`: Chord pattern with intervals, inversions, tuning, and neo-Riemannian transformations
- `Pmelody.sc`: Melodic sequence pattern (single-note lines)
- `Prhythm.sc`: Rhythm pattern generation and manipulation
- `Pvoice.sc`: Combines melody + rhythm + timbre into a single voice
- `Pphrase.sc`: Timed container for parallel voices
- `Pprog.sc`: Chord progression sequencing with neo-Riemannian transformations
- `Notation.sc`: Utilities for note names, Roman numerals, and chord symbols

### Instruments and Sound (lib/)
- `instruments.scd`: SynthDef definitions for various instruments
- `drums.scd`: Drum and percussion SynthDefs

### Composition Files (root)
- `compo.scd`: Main working composition file
- `progressions.scd`: Examples using the Progression class with neo-Riemannian transformations
- `patterns.scd`: Pattern-based composition examples
- `strum.scd`: Strumming pattern examples

### Examples (examples/)
Multiple example compositions demonstrating various techniques and musical ideas

## Common Development Tasks

### Testing SuperCollider Code
1. Write code in a `.scd` file
2. User will execute through vim plugin
3. Boot server with: `Server.local.boot;`
4. Load instruments: `"lib/instruments.scd".load;`

### SClang quirks
- vars must *always* be at the start of a block.

### Working with Chords and Progressions
```supercollider
// Create a chord using factory methods
var cm = Pchord.minor(\C, 4);
// Apply neo-Riemannian transformations
var gm = cm.transpose(7);
// Create progression
var prog = Pprog([cm, gm]);
// Play pattern
p = prog.asPattern(\cfstring1, 0.5).play;

// Create using Roman numerals
var prog = Pprog.inKey(\C, [\I, \IV, \V, \I]);

// Create a voice combining melody, rhythm, and timbre
var voice = Pvoice(
  Pchord.major(\C, 4).arp(\up),
  Prhythm.straight(12, 4),
  (instrument: \piano, amp: 0.3)
);
```

### Neo-Riemannian Transformations
Both Pchord and Pprog support neo-Riemannian operations:
- P (Parallel): Major ↔ Minor
- R (Relative): Relative major/minor
- L (Leading tone): Leading tone exchange
- S (Slide): Chromatic third relation
- N (Nebenverwandt): Combination transformation
- H (Hexatonic pole): Hexatonic cycle

Chain operations with strings: `chord.neoRiemannian("PLR")` or use shorthand methods: `chord.p.l.r`

## Important Notes

- Never create SynthDefs or modify the class library without explicit request
- All musical examples should be self-contained and bootable
- Pattern timing is typically in beats, not seconds
- The tuning system defaults to ET12 but supports custom tunings
