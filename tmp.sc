/*
Sketch: Hierarchical beat ordering

02120212 /2/2/2
o---o--- [oo]
o-o-o-o- [oo]
oooooooo [oooo]

o------- [o]
o---.--- [.]
o-.-.-o- [.o]
o.....o. [....]

0323132303231323 /2/2/2/2
o-------o------- [oo]
o---o---o---o--- [oo]
o-o-o-o-o-o-o-o- [oooo]
oooooooooooooooo [oooooooo]

.-------o------- [.o]
.---o---o---o--- [oo]
.-.-o-o-o-o-o-.- [.oo.]
.o..ooo.ooo.ooo. [o.o.o.o.]

o-------o------- [oo]
o---o---o---o--- [oo]
o-.-o-.-o-.-o-.- [....]
o..oo..oo..oo..o [.o.o.o.o]

011011 /2/3
o--o-- [oo] 
o..o.o [...o]

021212021212 /2/3/2
o-----o----- [oo]     t0 = 2      : r0 = t0
o-o-o-o-o-o- [oooo]   t1 = 3 * t0 : r1 = t1 - r0
oooooooooooo [oooooo] t2 = 2 * t1 : r2 = t2 - r1

011011011 /3/3
o--o--o-- [ooo]
o..o..o.o [.....o]

0101010101 /5/2
o-.-o-.-.- [o.o..]
o..oo..... [.o...]
*/
Rhythm_ {
  // The total length of the measure in seconds.
  var <length;

  // Ordered list of divisors for the measure.
  // For example, [2, 2] divides the measure in two, then two again, resulting in four beats.
  // And [2, 3, 2] divides the measure in two, then three, then two, resulting in twelve beats.
  // This provides more structure than a simple time signature, as it makes the hierarchical
  // structure of the measure explicit.
  var <divisors;

  // List of velocities for each beat, in time order (as opposed to hierarchy-order specified
  // in `new`).
  var <velocities;

  *new { |length, divisors, velocities|
    ^super.new.init(length, divisors, velocities);
  }

  init { |inLength, inDivisors, inVelocities|
    length = inLength;
    divisors = inDivisors;
    this.initVelocities(inVelocities);
  }

  // o-----o----- [oo]     t0 = 2      : r0 = t0
  // o-o-o-o-o-o- [oooo]   t1 = 3 * t0 : r1 = t1 - r0
  // oooooooooooo [oooooo] t2 = 2 * t1 : r2 = t2 - r1
  initVelocities{ |inVelocities|
    // Populate velocities in time order, where `inVelocities` is in hierarchy order.
    // The input velocities are a flat array in hierarchy order, so we need to reorder
    // them to match the order implied by the hierarchy of divisors.
    var totalBeats = divisors.reduce({ |acc, d| acc * d });
    var remaining = 0, total = 1;

    velocities = Array.newClear(totalBeats);
    divisors.do { |d, i|
      total = total * d;
      remaining = total - remaining;
      remaining.do {
        velocities = velocities.add(inVelocities.pop);
      };
    };
  }
}


