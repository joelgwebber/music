# Pattern Composition Framework

## Overview
We've developed a comprehensive framework for composing, stacking, and parameterizing patterns in SuperCollider. The framework provides multiple complementary approaches that can be mixed and matched for flexible musical composition.

## Key Concepts

### 1. Pattern Stack
Functional composition approach using modifier chains. Each modifier is a function that transforms a pattern and returns a new pattern.

**Example modifiers:**
- `~shuffleNotes` - Randomly perturb note pitches
- `~velocityContour` - Apply amplitude envelopes (exp, linear, accent patterns)
- `~timeStretch` - Scale durations by a factor
- `~transpose` - Shift pitches by semitones

**Usage:**
```supercollider
~patternStack.(basePattern, [
    { |p| ~shuffleNotes.(p, 0.3) },
    { |p| ~velocityContour.(p, \accent) },
    { |p| ~timeStretch.(p, 1.5) }
])
```

### 2. Pattern Sequencer
Two methods for applying different patterns across time ranges:

- **`~patternSequencer`** - Uses `Pfindur` to limit each pattern to a specific duration
- **`~patternSwitcher`** - Time-based switching between patterns

**Usage:**
```supercollider
~patternSequencer.([pattern1, pattern2, pattern3], [2, 3, 2]) // durations in beats
```

### 3. Hierarchical Patterns
Long-term patterns that overlay and modify shorter patterns. Uses `Pchain` to apply envelope patterns over melodic sequences.

**Example:** Amplitude envelope over melodic phrases
```supercollider
~hierarchicalPattern.(melodyPatterns, envelopePattern)
```

### 4. Parameterized Pattern Factories
Dictionary-based pattern templates with default parameters that can be overridden.

**Available factories:**
- `\arpeggio` - Generate arpeggios with root, intervals, rate, repeats
- `\rhythm` - Apply rhythmic patterns to existing patterns
- `\shuffle` - Add timing variations
- `\melodicContour` - Create melodic shapes (up, down, arch, random)

**Usage:**
```supercollider
~patternFactory[\arpeggio].(root: 48, intervals: [0, 3, 7, 10], rate: 0.1)
```

### 5. Composable Pattern Operations
Functional programming style with curried operations that can be composed.

**Operations:**
- `~compose` - Right-to-left function composition
- `~pipe` - Left-to-right function composition (more intuitive)
- `~patternOps[\transpose]` - Curried transposition
- `~patternOps[\stretch]` - Curried time stretching
- `~patternOps[\repeat]` - Pattern repetition
- `~patternOps[\limit]` - Duration limiting

**Usage:**
```supercollider
var transform = ~pipe.(
    ~patternOps[\transpose].(7),
    ~patternOps[\stretch].(1.5),
    ~patternOps[\repeat].(2)
);
transform.(basePattern)
```

### 6. Event-level Pattern Stacking
Merge parallel patterns at the event level with different strategies.

**Merge strategies:**
- `\override` - Later patterns override earlier ones
- `\combine` - Add numeric values together
- `\multiply` - Multiply numeric values

**Usage:**
```supercollider
~stackedPattern.([melodyPattern, dynamicsPattern, articulationPattern], \override)
```

## Complex Example
The framework supports combining multiple approaches:

```supercollider
~complexExample = {
    // 1. Create base pattern with factory
    var melody = ~patternFactory[\melodicContour].(
        notes: [60, 63, 65, 67, 70],
        shape: \arch
    );

    // 2. Apply rhythm transformation
    var rhythmic = ~patternFactory[\rhythm].(melody, rhythm: [2, 1, 1, 3, 1]);

    // 3. Add velocity contour
    var dynamics = ~velocityContour.(rhythmic, \exp);

    // 4. Sequence variations
    ~patternSequencer.([
        dynamics,
        ~patternOps[\transpose].(5).(dynamics),
        ~patternOps[\stretch].(1.5).(dynamics)
    ], [4, 4, 6]).play;
};
```

## Files
- `pattern_composition.scd` - Main framework implementation
- `test_pattern_debug.scd` - Step-by-step testing of individual components
- `patterns.scd` - Original exploration file with SuperCollider pattern examples

## Key Insights
1. **Composability** - Functions that transform patterns can be chained in any order
2. **Parameterization** - Factory patterns with default arguments enable quick variations
3. **Time organization** - Both sequential (time ranges) and hierarchical (overlays) are supported
4. **Event merging** - Different strategies for combining parallel pattern streams

## Next Steps
- Explore pattern state/memory across iterations
- Implement pattern interpolation/morphing between states
- Add probability-based pattern selection
- Create higher-level musical structure patterns (verse/chorus/bridge)