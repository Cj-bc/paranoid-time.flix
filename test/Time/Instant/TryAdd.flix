///
/// Tests for `Time.Instant.tryAdd`.
///
/// `tryAdd` returns `None` exactly when the result would leave the range of an
/// `Int64` of milliseconds, so most of these cases sit on that boundary.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.TryAdd {
    use Time.Duration
    use Time.Instant.Harness.{instantOf, millisOfOpt}

    /// A positive duration moves the instant forwards.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js`.
    @Test
    def tryAdd01_positiveDuration(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(1_000i64), Duration.milliseconds(500));
        Assert.assertEq(expected = Some(1_500i64), millisOfOpt(actual))

    /// A negative duration moves the instant backwards.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js` (its negative arms).
    @Test
    def tryAdd02_negativeDuration(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(1_000i64), Duration.milliseconds(-500));
        Assert.assertEq(expected = Some(500i64), millisOfOpt(actual))

    /// The zero duration is the identity.
    ///
    /// Adapted from test262 `Instant/prototype/add/blank-duration.js`.
    @Test
    def tryAdd03_zeroDurationIsIdentity(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(1_234i64), Duration.zero());
        Assert.assertEq(expected = Some(1_234i64), millisOfOpt(actual))

    /// Adding across the epoch is not special-cased.
    ///
    /// Adapted from test262 `Instant/prototype/add/cross-epoch.js`.
    @Test
    def tryAdd04_acrossTheEpoch(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(-500i64), Duration.milliseconds(1_500));
        Assert.assertEq(expected = Some(1_000i64), millisOfOpt(actual))

    /// Coarser units are converted before they are added.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js`, which walks the same
    /// ladder of units from sub-seconds up to hours.
    @Test
    def tryAdd05_largerUnits(): Unit \ Assert =
        Assert.assertEq(expected = Some(3_600_000i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.hours(1))));
        Assert.assertEq(expected = Some(86_400_000i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.days(1))));
        Assert.assertEq(expected = Some(60_000i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.minutes(1))))

    /// `Instant` has millisecond resolution, so a sub-millisecond duration is
    /// truncated towards zero rather than rounded.
    ///
    /// No test262 counterpart: a `Temporal.Instant` counts nanoseconds, so a
    /// sub-millisecond duration is exact there. Truncation is specific to this
    /// library's millisecond `Instant` paired with a nanosecond `Duration`.
    @Test
    def tryAdd06_subMillisecondDurationIsTruncated(): Unit \ Assert =
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(999_999i64))));
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(-999_999i64))));
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.microseconds(999))))

    /// Only the whole milliseconds of a mixed duration are kept.
    ///
    /// No test262 counterpart, for the same reason as `tryAdd06`.
    @Test
    def tryAdd07_truncatesTowardsZeroNotDownwards(): Unit \ Assert =
        Assert.assertEq(expected = Some(1i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(1_999_999i64))));
        Assert.assertEq(expected = Some(-1i64), millisOfOpt(Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(-1_999_999i64))))

    /// Landing exactly on the largest representable instant succeeds.
    ///
    /// Adapted from test262 `Instant/prototype/add/minimum-maximum-instant.js`
    /// ("Adding one to the minimum instant").
    @Test
    def tryAdd08_reachesMaxValueExactly(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(1));
        Assert.assertEq(expected = Some(Int64.maxValue()), millisOfOpt(actual))

    /// Landing exactly on the smallest representable instant succeeds.
    ///
    /// Adapted from test262 `Instant/prototype/add/minimum-maximum-instant.js`
    /// ("Subtracting one from the maximum instant").
    @Test
    def tryAdd09_reachesMinValueExactly(): Unit \ Assert =
        let actual = Time.Instant.tryAdd(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(-1));
        Assert.assertEq(expected = Some(Int64.minValue()), millisOfOpt(actual))

    /// Overflowing past the largest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/add/result-out-of-range.js` and
    /// `add/minimum-maximum-instant.js`. Temporal throws a `RangeError` where this
    /// library returns `None`.
    @Test
    def tryAdd10_overflowIsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue()), Duration.milliseconds(1))));
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(2))));
        // A duration given in nanoseconds must be range-checked after it is
        // truncated to milliseconds: `Int64.maxValue()` nanoseconds is
        // 9_223_372_036_854 milliseconds.
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue() - 9_223_372_036_853i64), Duration.nanoseconds(Int64.maxValue()))))

    /// Underflowing past the smallest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/add/result-out-of-range.js` and
    /// `add/minimum-maximum-instant.js` (their negative arms).
    @Test
    def tryAdd11_underflowIsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue()), Duration.milliseconds(-1))));
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(-2))));
        // `Int64.minValue()` nanoseconds truncates to -9_223_372_036_854 milliseconds.
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue() + 9_223_372_036_853i64), Duration.nanoseconds(Int64.minValue()))))

    /// The extremes are still reachable when the duration keeps them in range.
    ///
    /// Adapted from test262 `Instant/prototype/add/minimum-maximum-instant.js`
    /// ("Adding zero to the minimum/maximum instant").
    @Test
    def tryAdd12_zeroDurationAtTheExtremes(): Unit \ Assert =
        Assert.assertEq(expected = Some(Int64.maxValue()), millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue()), Duration.zero())));
        Assert.assertEq(expected = Some(Int64.minValue()), millisOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue()), Duration.zero())))

    /// The largest duration that still fits is accepted.
    ///
    /// Adapted from test262 `Instant/prototype/add/add-large-subseconds.js`, which
    /// pushes a duration given in a fine unit up to the largest value the host can
    /// represent.
    @Test
    def tryAdd13_largestDurationInRange(): Unit \ Assert =
        // `Int64.maxValue()` nanoseconds truncates to 9_223_372_036_854 milliseconds.
        let actual = Time.Instant.tryAdd(instantOf(0i64), Duration.nanoseconds(Int64.maxValue()));
        Assert.assertEq(expected = Some(9_223_372_036_854i64), millisOfOpt(actual))
}
