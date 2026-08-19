/// Unit tests for `Time.LocalDateTime.add`.

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
