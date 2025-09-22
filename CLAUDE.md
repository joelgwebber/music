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
- `Chord.sc`: Represents groups of notes with intervals, inversions, and tuning support
- `Chromatic.sc`: Chromatic scale operations and transformations
- `Diatonic.sc`: Diatonic scale operations
- `Progression.sc`: Chord progression sequencing with neo-Riemannian transformations
- `RhythmPattern.sc`: Rhythm pattern generation and manipulation
- `ArpeggioPattern.sc`: Arpeggio pattern creation
- `StrumPattern.sc`: Guitar-like strumming patterns

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

### Working with Progressions
```supercollider
// Create chromatic chord
var cm = Chromatic(3, [3, 4], -2);
// Apply transformations
var gm = cm.thirds(2);
// Create progression
var prog = Progression([cm, gm]);
// Play pattern
p = prog.asPattern(\cfstring1, 0.5).play;
```

### Neo-Riemannian Transformations
The Progression class supports neo-Riemannian operations:
- P (Parallel): Major ↔ Minor
- R (Relative): Relative major/minor
- L (Leading tone): Leading tone exchange
- S (Slide): Chromatic third relation
- N (Nebenverwandt): Combination transformation

Chain operations with strings: `chord.neoRiemannian("PLR")`

## Important Notes

- Never create SynthDefs or modify the class library without explicit request
- All musical examples should be self-contained and bootable
- Pattern timing is typically in beats, not seconds
- The tuning system defaults to ET12 but supports custom tunings