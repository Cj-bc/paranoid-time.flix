///
/// Tests for `Time.Instant.trySub`.
///
/// `trySub(t, d)` is the mirror image of `tryAdd(t, d)`: it must move `t`
/// *backwards* by `d`, and return `None` when the result would leave the range
/// of an `Int64` of milliseconds.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.TrySub {
    use Time.Duration
    use Time.Instant.Harness.{instantOf, millisOf, millisOfOpt}

    /// A positive duration moves the instant backwards.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js`.
    @Test
    def trySub01_positiveDuration(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(1_000i64), Duration.milliseconds(500));
        Assert.assertEq(expected = Some(500i64), millisOfOpt(actual))

    /// A negative duration moves the instant forwards.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js` (its negative arms).
    @Test
    def trySub02_negativeDuration(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(1_000i64), Duration.milliseconds(-500));
        Assert.assertEq(expected = Some(1_500i64), millisOfOpt(actual))

    /// The zero duration is the identity.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/blank-duration.js`.
    @Test
    def trySub03_zeroDurationIsIdentity(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(1_234i64), Duration.zero());
        Assert.assertEq(expected = Some(1_234i64), millisOfOpt(actual))

    /// Subtracting across the epoch is not special-cased.
    ///
    /// Adapted from test262 `Instant/prototype/add/cross-epoch.js`, which drives the
    /// same instant through both `add` and `subtract`.
    @Test
    def trySub04_acrossTheEpoch(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(500i64), Duration.milliseconds(1_500));
        Assert.assertEq(expected = Some(-1_000i64), millisOfOpt(actual))

    /// Coarser units are converted before they are subtracted.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js`.
    @Test
    def trySub05_largerUnits(): Unit \ Assert =
        Assert.assertEq(expected = Some(-3_600_000i64), millisOfOpt(Time.Instant.trySub(instantOf(0i64), Duration.hours(1))));
        Assert.assertEq(expected = Some(-86_400_000i64), millisOfOpt(Time.Instant.trySub(instantOf(0i64), Duration.days(1))));
        Assert.assertEq(expected = Some(-60_000i64), millisOfOpt(Time.Instant.trySub(instantOf(0i64), Duration.minutes(1))))

    /// `Instant` has millisecond resolution, so a sub-millisecond duration is
    /// truncated towards zero rather than rounded.
    ///
    /// No test262 counterpart, for the reason given on `TryAdd.tryAdd06`.
    @Test
    def trySub06_subMillisecondDurationIsTruncated(): Unit \ Assert =
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.trySub(instantOf(0i64), Duration.nanoseconds(999_999i64))));
        Assert.assertEq(expected = Some(0i64), millisOfOpt(Time.Instant.trySub(instantOf(0i64), Duration.nanoseconds(-999_999i64))));
        Assert.assertEq(expected = Some(-1i64), millisOfOpt(Time.Instant.trySub(instantOf(0i64), Duration.nanoseconds(1_999_999i64))))

    /// Landing exactly on the smallest representable instant succeeds.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/minimum-maximum-instant.js`.
    @Test
    def trySub07_reachesMinValueExactly(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(1));
        Assert.assertEq(expected = Some(Int64.minValue()), millisOfOpt(actual))

    /// Landing exactly on the largest representable instant succeeds.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/minimum-maximum-instant.js`.
    @Test
    def trySub08_reachesMaxValueExactly(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(-1));
        Assert.assertEq(expected = Some(Int64.maxValue()), millisOfOpt(actual))

    /// Underflowing past the smallest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/result-out-of-range.js` and
    /// `subtract/minimum-maximum-instant.js`, with `None` in place of the `RangeError`.
    @Test
    def trySub09_underflowIsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.trySub(instantOf(Int64.minValue()), Duration.milliseconds(1))));
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.trySub(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(2))))

    /// Overflowing past the largest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/result-out-of-range.js` and
    /// `subtract/minimum-maximum-instant.js` (their negative arms).
    @Test
    def trySub10_overflowIsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.trySub(instantOf(Int64.maxValue()), Duration.milliseconds(-1))));
        Assert.assertEq(expected = None, millisOfOpt(Time.Instant.trySub(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(-2))))

    /// The extremes are still reachable when the duration keeps them in range.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/minimum-maximum-instant.js`.
    @Test
    def trySub11_zeroDurationAtTheExtremes(): Unit \ Assert =
        Assert.assertEq(expected = Some(Int64.maxValue()), millisOfOpt(Time.Instant.trySub(instantOf(Int64.maxValue()), Duration.zero())));
        Assert.assertEq(expected = Some(Int64.minValue()), millisOfOpt(Time.Instant.trySub(instantOf(Int64.minValue()), Duration.zero())))

    /// `Duration` is stored as nanoseconds, so `Int64.minValue()` nanoseconds
    /// cannot be negated within an `Int64`. Truncating it to milliseconds first
    /// makes it representable: -9_223_372_036_854 milliseconds, whose negation
    /// is an ordinary number.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/subtract-large-subseconds.js`,
    /// which subtracts the most extreme durations the host can represent.
    @Test
    def trySub12_mostNegativeDuration(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(0i64), Duration.nanoseconds(Int64.minValue()));
        Assert.assertEq(expected = Some(9_223_372_036_854i64), millisOfOpt(actual))

    /// The largest positive duration is subtracted without incident.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/subtract-large-subseconds.js`.
    @Test
    def trySub13_mostPositiveDuration(): Unit \ Assert =
        let actual = Time.Instant.trySub(instantOf(0i64), Duration.nanoseconds(Int64.maxValue()));
        Assert.assertEq(expected = Some(-9_223_372_036_854i64), millisOfOpt(actual))

    /// Adding a duration and subtracting it again returns the original instant,
    /// for any duration that is a whole number of milliseconds.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js` and
    /// `since/add-subtract.js`, which assert `later.subtract(diff)` returns `earlier`.
    @Test
    def trySub14_undoesTryAdd(): Unit \ Assert =
        let cases = List#{
            (instantOf(0i64), Duration.milliseconds(1)),
            (instantOf(1_000i64), Duration.milliseconds(-500)),
            (instantOf(-1_000i64), Duration.seconds(3)),
            (instantOf(1_234i64), Duration.zero()),
            (instantOf(999i64), Duration.days(7))
        };
        List.forEach(match (t, d) -> {
            let roundTripped = Option.flatMap(x -> Time.Instant.trySub(x, d), Time.Instant.tryAdd(t, d));
            Assert.assertEq(expected = Some(millisOf(t)), millisOfOpt(roundTripped))
        }, cases)

    /// `trySub(t, d)` and `tryAdd(t, d)` must move in opposite directions.
    ///
    /// No test262 counterpart: Temporal has never had to state that `subtract` is not
    /// `add`. It is here because this library currently gets that wrong.
    @Test
    def trySub15_isNotTryAdd(): Unit \ Assert =
        let t = instantOf(0i64);
        let d = Duration.milliseconds(1);
        Assert.assertNeqWithMsg(
            unexpected = millisOfOpt(Time.Instant.tryAdd(t, d)),
            millisOfOpt(Time.Instant.trySub(t, d)),
            "trySub must subtract the duration, not add it"
        )
}
