/// Unit tests for `Time.LocalDateTime.sub`.

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
