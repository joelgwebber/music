TestPrhythm : UnitTest {

  // Test basic rhythm construction
  test_construction {
    var rhythm;

    // Basic construction
    rhythm = Rhythm([1, 1, 1, 1], 4);
    this.assertEquals(rhythm.numerators, [1, 1, 1, 1], "Numerators should be [1, 1, 1, 1]");
    this.assertEquals(rhythm.denominator, 4, "Denominator should be 4");
  }

  // Test flexible duration model (no invariant required)
  test_flexibleDurations {
    var rhythm;

    // Pattern where sum = denominator (1 beat total)
    rhythm = Rhythm([2, 1, 1], 4);
    this.assertEquals(rhythm.totalDuration, 1.0, "4/4 should equal 1 beat");

    // Pattern where sum != denominator (multi-beat note)
    rhythm = Rhythm([12], 1);
    this.assertEquals(rhythm.totalDuration, 12.0, "12/1 should equal 12 beats");

    // Pattern with custom subdivision
    rhythm = Rhythm([3, 5], 2);
    this.assertEquals(rhythm.totalDuration, 4.0, "8/2 should equal 4 beats");
  }

  // Test straight rhythm factory
  test_straight {
    var rhythm;

    // Default: 1 beat
    rhythm = Prhythm.straight(4);
    this.assertEquals(rhythm.numerators, [1, 1, 1, 1], "Straight 4 should be [1,1,1,1]");
    this.assertEquals(rhythm.denominator, 4, "Denominator should be 4");
    this.assertEquals(rhythm.totalDuration, 1.0, "Should create 1-beat pattern");

    rhythm = Prhythm.straight(8);
    this.assertEquals(rhythm.numerators.size, 8, "Straight 8 should have 8 notes");
    this.assertEquals(rhythm.denominator, 8, "Denominator should be 8");
    this.assertEquals(rhythm.totalDuration, 1.0, "Should create 1-beat pattern");

    // Custom beats parameter
    rhythm = Prhythm.straight(12, 4);
    this.assertEquals(rhythm.numerators.size, 12, "Straight 12,4 should have 12 notes");
    this.assertEquals(rhythm.denominator, 3, "Denominator should be 3 (12 notes / 4 beats)");
    this.assertEquals(rhythm.totalDuration, 4.0, "Should create 4-beat pattern");

    rhythm = Prhythm.straight(6, 2);
    this.assertEquals(rhythm.numerators.size, 6, "Straight 6,2 should have 6 notes");
    this.assertEquals(rhythm.denominator, 3, "Denominator should be 3 (6 notes / 2 beats)");
    this.assertEquals(rhythm.totalDuration, 2.0, "Should create 2-beat pattern");
  }

  // Test swing rhythm factory
  test_swing {
    var rhythm;

    rhythm = Prhythm.swing(4);
    this.assertEquals(rhythm.numerators, [2, 1, 2, 1, 2, 1, 2, 1], "Swing 4 should be [2,1,2,1,2,1,2,1]");
    this.assertEquals(rhythm.denominator, 12, "Denominator should be 12 (4 pairs * 3)");
    this.assertEquals(rhythm.totalDuration, 1.0, "Should create 1-beat pattern");

    // Check velocity pattern
    this.assertEquals(rhythm.velocities[0], 0.7, "Long note should have base velocity");
    this.assertFloatEquals(rhythm.velocities[1], 0.7 * 0.8, "Short note should have 80% velocity");
  }

  // Test note rhythm factory
  test_note {
    var rhythm;

    rhythm = Prhythm.note(1);
    this.assertEquals(rhythm.numerators, [1], "Note 1 should be [1]");
    this.assertEquals(rhythm.denominator, 1, "Denominator should be 1");
    this.assertEquals(rhythm.totalDuration, 1.0, "1-beat note should have totalDuration=1");

    rhythm = Prhythm.note(4);
    this.assertEquals(rhythm.numerators, [4], "Note 4 should be [4]");
    this.assertEquals(rhythm.denominator, 1, "Denominator should be 1 (whole note resolution)");
    this.assertEquals(rhythm.totalDuration, 4.0, "4-beat note should have totalDuration=4");

    rhythm = Prhythm.note(12);
    this.assertEquals(rhythm.numerators, [12], "Note 12 should be [12]");
    this.assertEquals(rhythm.denominator, 1, "Denominator should be 1");
    this.assertEquals(rhythm.totalDuration, 12.0, "12-beat note should have totalDuration=12");

    // Test with velocity parameter
    rhythm = Prhythm.note(2, 0.5);
    this.assertEquals(rhythm.numerators, [2], "Note 2 should be [2]");
    this.assertEquals(rhythm.velocities, [0.5], "Velocity should be [0.5]");
    this.assertEquals(rhythm.totalDuration, 2.0, "2-beat note should have totalDuration=2");
  }

  // Test clave rhythm factory
  test_clave {
    var rhythm, hitCount;

    rhythm = Prhythm.clave(\son);
    this.assertEquals(rhythm.numerators.size, 16, "Clave should have 16 subdivisions");
    this.assertEquals(rhythm.denominator, 16, "Denominator should be 16");
    this.assertEquals(rhythm.totalDuration, 1.0, "Should create 1-beat pattern");

    // Check that hits are marked with velocity
    hitCount = rhythm.velocities.count({ |v| v > 0 });
    this.assertEquals(hitCount, 5, "Son clave should have 5 hits");

    rhythm = Prhythm.clave(\rumba);
    hitCount = rhythm.velocities.count({ |v| v > 0 });
    this.assertEquals(hitCount, 5, "Rumba clave should have 5 hits");
  }

  // Test euclidean rhythm factory
  test_euclidean {
    var rhythm, hitCount;

    // E(3,8) - Tresillo pattern
    rhythm = Prhythm.euclidean(3, 8);
    this.assertEquals(rhythm.numerators.size, 8, "E(3,8) should have 8 subdivisions");
    this.assertEquals(rhythm.denominator, 8, "Denominator should be 8");
    this.assertEquals(rhythm.totalDuration, 1.0, "Should create 1-beat pattern");

    hitCount = rhythm.velocities.count({ |v| v > 0 });
    this.assertEquals(hitCount, 3, "E(3,8) should have 3 hits");

    // E(5,12) - West African bell pattern
    rhythm = Prhythm.euclidean(5, 12);
    this.assertEquals(rhythm.numerators.size, 12, "E(5,12) should have 12 subdivisions");
    this.assertEquals(rhythm.denominator, 12, "Denominator should be 12");
    this.assertEquals(rhythm.totalDuration, 1.0, "Should create 1-beat pattern");

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
    this.assertEquals(rhythm.totalDuration, 1.0, "Pattern with rests should be 1 beat");
    this.assertEquals(rhythm.velocities[1], 0, "Rest should have velocity 0");
    this.assertEquals(rhythm.velocities[3], 0, "Rest should have velocity 0");
  }
}
