/// Unit tests for `Time.LocalDateTime.between`.

@Test
def betweenSameInstantIsZero(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(123i64);
    Assert.assertTrue(Time.Duration.isZero(Time.LocalDateTime.between(d, d)))

@Test
def betweenIsSymmetricRegardlessOfArgumentOrder(): Unit \ Assert =
    let d1 = Time.LocalDateTime.LocalDateTime(0i64);
    let d2 = Time.LocalDateTime.LocalDateTime(500i64);
    Assert.assertTrue(Time.LocalDateTime.between(d1, d2) == Time.LocalDateTime.between(d2, d1))

@Test
def betweenReportsWrongMillisDueToNanosecondUnitMismatch(): Unit \ Assert =
    // NOTE: this pins a suspected bug rather than desired behavior.
    // `between` builds its result as `Duration.Duration(millisDiff)`, but
    // `Duration`'s wrapped Int64 represents *nanoseconds* (see
    // `Duration.toMillis`, which divides by 1_000_000, and
    // `Duration.milliseconds`, which multiplies by it). So a 1000ms gap is
    // currently stored as 1000 *nanoseconds*, which truncates to 0ms when
    // read back. If `between` is fixed to go through `Duration.milliseconds`,
    // this test's expected value should become 1000i64.
    let d1 = Time.LocalDateTime.LocalDateTime(0i64);
    let d2 = Time.LocalDateTime.LocalDateTime(1000i64);
    let gap = Time.LocalDateTime.between(d1, d2);
    Assert.assertEq(expected = 0i64, Time.Duration.toMillis(gap))

@Test
def betweenAtInt64BoundaryCanProduceNegativeDuration(): Unit \ Assert =
    // NOTE: this pins a suspected bug rather than desired behavior.
    // `Int64.abs(Int64.minValue())` is specified to return -1, since the
    // true magnitude of `Int64.minValue()` has no positive Int64
    // representation. `between` computes `Int64.abs(t1 - t2)` directly, so
    // when that difference lands exactly on `Int64.minValue()`, the
    // "elapsed time" it reports is a *negative* Duration, which should be
    // impossible for a magnitude.
    let d1 = Time.LocalDateTime.LocalDateTime(-1i64);
    let d2 = Time.LocalDateTime.LocalDateTime(Int64.maxValue());
    let gap = Time.LocalDateTime.between(d1, d2);
    Assert.assertTrue(Time.Duration.isNegative(gap))
