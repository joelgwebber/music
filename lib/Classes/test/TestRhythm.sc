TestRhythm : UnitTest {

  // Test basic rhythm construction
  test_construction {
    var rhythm;

    // Basic construction
    rhythm = Rhythm([1, 1, 1, 1], 4);
    this.assertEquals(rhythm.numerators, [1, 1, 1, 1], "Numerators should be [1, 1, 1, 1]");
    this.assertEquals(rhythm.denominator, 4, "Denominator should be 4");
  }

  // Test measure validation invariant
  test_measureValidation {
    var rhythm;

    // Valid measure: sum = denominator
    rhythm = Rhythm([2, 1, 1], 4);
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Valid measure: sum should equal denominator");

    // Invalid measure: sum != denominator
    this.assertException({
      Rhythm([1, 1, 1], 4);  // sum=3, denom=4
    }, Error, "Should throw error when sum != denominator");

    this.assertException({
      Rhythm([2, 2, 2, 2], 4);  // sum=8, denom=4
    }, Error, "Should throw error when sum > denominator");
  }

  // Test straight rhythm factory
  test_straight {
    var rhythm;

    rhythm = Rhythm.straight(4);
    this.assertEquals(rhythm.numerators, [1, 1, 1, 1], "Straight 4 should be [1,1,1,1]");
    this.assertEquals(rhythm.denominator, 4, "Denominator should be 4");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");

    rhythm = Rhythm.straight(8);
    this.assertEquals(rhythm.numerators.size, 8, "Straight 8 should have 8 notes");
    this.assertEquals(rhythm.denominator, 8, "Denominator should be 8");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");
  }

  // Test swing rhythm factory
  test_swing {
    var rhythm;

    rhythm = Rhythm.swing(4);
    this.assertEquals(rhythm.numerators, [2, 1, 2, 1, 2, 1, 2, 1], "Swing 4 should be [2,1,2,1,2,1,2,1]");
    this.assertEquals(rhythm.denominator, 12, "Denominator should be 12 (4 pairs * 3)");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");

    // Check velocity pattern
    this.assertEquals(rhythm.velocities[0], 0.7, "Long note should have base velocity");
    this.assertFloatEquals(rhythm.velocities[1], 0.7 * 0.8, "Short note should have 80% velocity");
  }

  // Test note rhythm factory
  test_note {
    var rhythm;

    rhythm = Rhythm.note(1);
    this.assertEquals(rhythm.numerators, [1], "Note should be [1]");
    this.assertEquals(rhythm.denominator, 1, "Denominator should be 1");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");

    rhythm = Rhythm.note(4);
    this.assertEquals(rhythm.numerators, [4], "Note 4 should be [4]");
    this.assertEquals(rhythm.denominator, 4, "Denominator should be 4");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");
  }

  // Test clave rhythm factory
  test_clave {
    var rhythm, hitCount;

    rhythm = Rhythm.clave(\son);
    this.assertEquals(rhythm.numerators.size, 16, "Clave should have 16 subdivisions");
    this.assertEquals(rhythm.denominator, 16, "Denominator should be 16");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");

    // Check that hits are marked with velocity
    hitCount = rhythm.velocities.count({ |v| v > 0 });
    this.assertEquals(hitCount, 5, "Son clave should have 5 hits");

    rhythm = Rhythm.clave(\rumba);
    hitCount = rhythm.velocities.count({ |v| v > 0 });
    this.assertEquals(hitCount, 5, "Rumba clave should have 5 hits");
  }

  // Test euclidean rhythm factory
  test_euclidean {
    var rhythm, hitCount;

    // E(3,8) - Tresillo pattern
    rhythm = Rhythm.euclidean(3, 8);
    this.assertEquals(rhythm.numerators.size, 8, "E(3,8) should have 8 subdivisions");
    this.assertEquals(rhythm.denominator, 8, "Denominator should be 8");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");

    hitCount = rhythm.velocities.count({ |v| v > 0 });
    this.assertEquals(hitCount, 3, "E(3,8) should have 3 hits");

    // E(5,12) - West African bell pattern
    rhythm = Rhythm.euclidean(5, 12);
    this.assertEquals(rhythm.numerators.size, 12, "E(5,12) should have 12 subdivisions");
    this.assertEquals(rhythm.denominator, 12, "Denominator should be 12");
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Should form valid measure");

    hitCount = rhythm.velocities.count({ |v| v > 0 });
    this.assertEquals(hitCount, 5, "E(5,12) should have 5 hits");
  }

  // Test totalDuration calculation
  test_totalDuration {
    var rhythm;

    rhythm = Rhythm([1, 1, 1, 1], 4);
    this.assertEquals(rhythm.totalDuration, 1.0, "4/4 should equal 1 beat");

    rhythm = Rhythm([2, 1, 2, 1, 2, 1, 2, 1], 12);
    this.assertEquals(rhythm.totalDuration, 1.0, "12/12 should equal 1 beat");

    rhythm = Rhythm([3, 3, 2], 8);
    this.assertEquals(rhythm.totalDuration, 1.0, "8/8 should equal 1 beat");
  }

  // Test velocity and gates
  test_velocityGates {
    var rhythm;

    rhythm = Rhythm([1, 1, 1, 1], 4, [0.8, 0.6, 0.4, 0.2]);
    this.assertEquals(rhythm.velocities, [0.8, 0.6, 0.4, 0.2], "Custom velocities should be preserved");

    rhythm = Rhythm([1, 1, 1, 1], 4, [0.7, 0.7, 0.7, 0.7], [0.9, 0.5, 0.9, 0.5]);
    this.assertEquals(rhythm.gates, [0.9, 0.5, 0.9, 0.5], "Custom gates should be preserved");
  }

  // Test rests using velocity=0
  test_rests {
    var rhythm;

    // Rests should use velocity=0, not zero numerators
    rhythm = Rhythm([1, 1, 1, 1], 4, [0.7, 0, 0.7, 0]);
    this.assertEquals(rhythm.numerators.sum, rhythm.denominator, "Rests should still form valid measure");
    this.assertEquals(rhythm.velocities[1], 0, "Rest should have velocity 0");
    this.assertEquals(rhythm.velocities[3], 0, "Rest should have velocity 0");
  }
}
