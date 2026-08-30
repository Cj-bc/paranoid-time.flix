///
/// Tests for `Time.Instant.tryAdd`.
///
/// `tryAdd` returns `None` exactly when the result would leave the range of an
/// `Int64` of milliseconds, so most of these cases sit on that boundary.
///
mod Time.Instant.TryAdd {
    use Time.Duration
    use Time.Instant.Harness.{instantOf, millisOfOpt}

    /// A positive duration moves the instant forwards.
    @Test
    def tryAdd01_positiveDuration(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(1_000i64), Duration.milliseconds(500));
        Assert.assertEq(expected = Some(1_500i64), millisOfOpt(actual))

    /// A negative duration moves the instant backwards.
    @Test
    def tryAdd02_negativeDuration(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(1_000i64), Duration.milliseconds(-500));
        Assert.assertEq(expected = Some(500i64), millisOfOpt(actual))

    /// The zero duration is the identity.
    @Test
    def tryAdd03_zeroDurationIsIdentity(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(1_234i64), Duration.zero());
        Assert.assertEq(expected = Some(1_234i64), millisOfOpt(actual))

    /// Adding across the epoch is not special-cased.
    @Test
    def tryAdd04_acrossTheEpoch(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(-500i64), Duration.milliseconds(1_500));
        Assert.assertEq(expected = Some(1_000i64), millisOfOpt(actual))

    /// Coarser units are converted before they are added.
    @Test
    def tryAdd05_largerUnits(): Unit \ Assert =
        Assert.assertEq(expected = Some(3_600_000i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.hours(1))));
        Assert.assertEq(expected = Some(86_400_000i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.days(1))));
        Assert.assertEq(expected = Some(60_000i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.minutes(1))))

    /// `Instant` has millisecond resolution, so a sub-millisecond duration is
    /// truncated towards zero rather than rounded.
    @Test
    def tryAdd06_subMillisecondDurationIsTruncated(): Unit \ Assert =
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(999_999i64))));
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(-999_999i64))));
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.microseconds(999))))

    /// Only the whole milliseconds of a mixed duration are kept.
    @Test
    def tryAdd07_truncatesTowardsZeroNotDownwards(): Unit \ Assert =
        Assert.assertEq(expected = Some(1i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(1_999_999i64))));
        Assert.assertEq(expected = Some(-1i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(-1_999_999i64))))

    /// Landing exactly on the largest representable instant succeeds.
    @Test
    def tryAdd08_reachesMaxValueExactly(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(1));
        Assert.assertEq(expected = Some(Int64.maxValue()), millisOfOpt(actual))

    /// Landing exactly on the smallest representable instant succeeds.
    @Test
    def tryAdd09_reachesMinValueExactly(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(-1));
        Assert.assertEq(expected = Some(Int64.minValue()), millisOfOpt(actual))

    /// Overflowing past the largest instant yields `None` rather than wrapping.
    @Test
    def tryAdd10_overflowIsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue()), Duration.milliseconds(1))));
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(2))));
        // A duration given in nanoseconds must be range-checked after it is
        // truncated to milliseconds: `Int64.maxValue()` nanoseconds is
        // 9_223_372_036_854 milliseconds.
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue() - 9_223_372_036_853i64), Duration.nanoseconds(Int64.maxValue()))))

    /// Underflowing past the smallest instant yields `None` rather than wrapping.
    @Test
    def tryAdd11_underflowIsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue()), Duration.milliseconds(-1))));
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(-2))));
        // `Int64.minValue()` nanoseconds truncates to -9_223_372_036_854 milliseconds.
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue() + 9_223_372_036_853i64), Duration.nanoseconds(Int64.minValue()))))

    /// The extremes are still reachable when the duration keeps them in range.
    @Test
    def tryAdd12_zeroDurationAtTheExtremes(): Unit \ Assert =
        Assert.assertEq(expected = Some(Int64.maxValue()), millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue()), Duration.zero())));
        Assert.assertEq(expected = Some(Int64.minValue()), millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue()), Duration.zero())))

    /// The largest duration that still fits is accepted.
    @Test
    def tryAdd13_largestDurationInRange(): Unit \ Assert =
        // `Int64.maxValue()` nanoseconds truncates to 9_223_372_036_854 milliseconds.
        let actual = Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(Int64.maxValue()));
        Assert.assertEq(expected = Some(9_223_372_036_854i64), millisOfOpt(actual))
}
