/// Unit tests for `Time.LocalDateTime` (add, sub, between, now).
///
/// Names are fully qualified throughout (no `use` statements) to keep each
/// test self-contained and unambiguous, mirroring how the library itself
/// refers to `Time.Duration` from within `Time.LocalDateTime`.

// ---------------------------------------------------------------------
// add
// ---------------------------------------------------------------------

@Test
def addZeroDurationIsIdentity(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(0i64);
    let result = Time.LocalDateTime.add(d, Time.Duration.zero());
    Assert.assertTrue(result == d)

@Test
def addPositiveDurationIncreasesTime(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(0i64);
    let result = Time.LocalDateTime.add(d, Time.Duration.milliseconds(1));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(1i64))

@Test
def addNegativeDurationDecreasesTime(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(1000i64);
    let result = Time.LocalDateTime.add(d, Time.Duration.milliseconds(-1000));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(0i64))

@Test
def addAtInt64MaxValueWrapsAround(): Unit \ Assert =
    // Boundary: adding to the largest representable instant. Int64
    // addition wraps silently on overflow (two's complement), so one
    // millisecond past `Int64.maxValue()` becomes `Int64.minValue()`.
    let d = Time.LocalDateTime.LocalDateTime(Int64.maxValue());
    let result = Time.LocalDateTime.add(d, Time.Duration.milliseconds(1));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(Int64.minValue()))

@Test
def addAtInt64MinValueWithNegativeDurationWrapsAround(): Unit \ Assert =
    // Boundary: symmetric wraparound at the smallest representable instant.
    let d = Time.LocalDateTime.LocalDateTime(Int64.minValue());
    let result = Time.LocalDateTime.add(d, Time.Duration.milliseconds(-1));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(Int64.maxValue()))

// ---------------------------------------------------------------------
// sub
// ---------------------------------------------------------------------

@Test
def subZeroDurationIsIdentity(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(0i64);
    let result = Time.LocalDateTime.sub(d, Time.Duration.zero());
    Assert.assertTrue(result == d)

@Test
def subReachesEpochBoundaryExactly(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(1000i64);
    let result = Time.LocalDateTime.sub(d, Time.Duration.milliseconds(1000));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(0i64))

@Test
def subCrossesBelowEpochBoundary(): Unit \ Assert =
    // Boundary: subtracting past the epoch (0) yields a negative timestamp.
    let d = Time.LocalDateTime.LocalDateTime(0i64);
    let result = Time.LocalDateTime.sub(d, Time.Duration.milliseconds(1));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(-1i64))

@Test
def subAtInt64MinValueWrapsAround(): Unit \ Assert =
    // Boundary: subtracting from the smallest representable instant wraps
    // around to the largest one.
    let d = Time.LocalDateTime.LocalDateTime(Int64.minValue());
    let result = Time.LocalDateTime.sub(d, Time.Duration.milliseconds(1));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(Int64.maxValue()))

@Test
def subNegativeDurationActsLikeAdd(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(0i64);
    let result = Time.LocalDateTime.sub(d, Time.Duration.milliseconds(-1000));
    Assert.assertTrue(result == Time.LocalDateTime.LocalDateTime(1000i64))

@Test
def addThenSubIsIdentity(): Unit \ Assert =
    let d = Time.LocalDateTime.LocalDateTime(123456789i64);
    let dur = Time.Duration.seconds(42);
    let result = Time.LocalDateTime.sub(Time.LocalDateTime.add(d, dur), dur);
    Assert.assertTrue(result == d)

// ---------------------------------------------------------------------
// between
// ---------------------------------------------------------------------

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

// ---------------------------------------------------------------------
// now
// ---------------------------------------------------------------------

@Test
def betweenSameNowInstantIsZero(): Unit \ (Assert + Time.Clock) =
    let d = Time.LocalDateTime.now();
    Assert.assertTrue(Time.Duration.isZero(Time.LocalDateTime.between(d, d)))
