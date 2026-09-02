///
/// Tests for `Time.Instant.saturatingSub`.
///
/// `saturatingSub` agrees with `trySub` whenever the result is representable,
/// and returns the nearest extreme instead of `None` when it is not.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.SaturatingSub {
    use Time.Duration
    use Time.Instant.Harness.{epoch, epochPastLargestDuration, instantOf, maxInstant, minInstant, partsOf}

    /// A whole-second duration comes straight off `secondsSinceEpoch`.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js`.
    @Test
    def saturatingSub01_wholeSeconds_subtractsFromSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = (-3_600i64, 0), partsOf(Time.Instant.saturatingSub(epoch(), Duration.hours(1))))

    /// A sub-second duration is kept to the nanosecond, borrowing a second.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js` (its sub-second arm).
    @Test
    def saturatingSub02_subSecondDuration_isKeptExactly(): Unit \ Assert =
        Assert.assertEq(expected = (0i64, 750_000_000),
                        partsOf(Time.Instant.saturatingSub(instantOf(1i64, 500_000_000), Duration.milliseconds(750))))

    /// A negative duration moves the instant forwards.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js` (its negative arms).
    @Test
    def saturatingSub03_negativeDuration_carriesIntoSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = (1i64, 500_000_000),
                        partsOf(Time.Instant.saturatingSub(instantOf(0i64, 750_000_000), Duration.milliseconds(-750))))

    /// Crossing the epoch backwards still leaves `nano` non-negative.
    ///
    /// Adapted from test262 `Instant/prototype/add/cross-epoch.js`.
    @Test
    def saturatingSub04_crossingTheEpoch_keepsNanoNonNegative(): Unit \ Assert =
        Assert.assertEq(expected = (-1i64, 500_000_000),
                        partsOf(Time.Instant.saturatingSub(epoch(), Duration.milliseconds(500))))

    /// The zero duration is the identity.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/blank-duration.js`.
    @Test
    def saturatingSub05_zeroDuration_returnsTheSameInstant(): Unit \ Assert =
        Assert.assertEq(expected = (1_735_689_600i64, 123_456_789),
                        partsOf(Time.Instant.saturatingSub(instantOf(1_735_689_600i64, 123_456_789), Duration.zero())))

    /// Landing exactly on an extreme is not saturation, it is just the result.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/minimum-maximum-instant.js`.
    @Test
    def saturatingSub06_reachingAnExtreme_returnsThatInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(minInstant()),
                        partsOf(Time.Instant.saturatingSub(instantOf(Int64.minValue(), 1), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = partsOf(maxInstant()),
                        partsOf(Time.Instant.saturatingSub(instantOf(Int64.maxValue(), 999_999_998), Duration.nanoseconds(-1i64))))

    /// Underflow returns the earliest instant rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/result-out-of-range.js`, with
    /// clamping in place of the `RangeError`.
    @Test
    def saturatingSub07_pastTheEarliestInstant_returnsTheEarliestInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(minInstant()),
                        partsOf(Time.Instant.saturatingSub(minInstant(), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = partsOf(minInstant()),
                        partsOf(Time.Instant.saturatingSub(minInstant(), Duration.days(1))))

    /// Overflow returns the latest instant rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/result-out-of-range.js` (its
    /// negative arms), with clamping in place of the `RangeError`.
    @Test
    def saturatingSub08_pastTheLatestInstant_returnsTheLatestInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(maxInstant()),
                        partsOf(Time.Instant.saturatingSub(maxInstant(), Duration.nanoseconds(-1i64))));
        Assert.assertEq(expected = partsOf(maxInstant()),
                        partsOf(Time.Instant.saturatingSub(maxInstant(), Duration.days(-1))))

    /// A duration under a second can still underflow, through the borrow alone.
    ///
    /// No test262 counterpart: the borrow between the two fields is specific to
    /// this representation.
    @Test
    def saturatingSub09_borrowPastTheEarliestInstant_returnsTheEarliestInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(minInstant()),
                        partsOf(Time.Instant.saturatingSub(instantOf(Int64.minValue(), 500_000_000), Duration.milliseconds(600))))

    /// `Int64.minValue()` nanoseconds cannot be negated as a whole, but the split
    /// still subtracts it exactly rather than saturating.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/subtract-large-subseconds.js`.
    @Test
    def saturatingSub10_theSmallestDuration_subtractsItExactly(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(epochPastLargestDuration()),
                        partsOf(Time.Instant.saturatingSub(epoch(), Duration.nanoseconds(Int64.minValue()))))

    /// Where `trySub` succeeds, `saturatingSub` must return the same instant.
    ///
    /// No test262 counterpart, for the reason given on
    /// `SaturatingAdd.saturatingAdd09`.
    @Test
    def saturatingSub11_withinRange_agreesWithTrySub(): Unit \ Assert =
        let cases = List#{
            (epoch(), Duration.milliseconds(1)),
            (instantOf(0i64, 0), Duration.nanoseconds(1i64)),
            (instantOf(1_735_689_600i64, 123_456_789), Duration.seconds(-3)),
            (instantOf(0i64, 0), Duration.zero()),
            (instantOf(Int64.minValue(), 1), Duration.nanoseconds(1i64)),
            (instantOf(Int64.maxValue(), 999_999_998), Duration.nanoseconds(-1i64))
        };
        List.forEach(match (t, d) -> {
            Assert.assertEq(expected = Some(partsOf(Time.Instant.saturatingSub(t, d))),
                            Option.map(partsOf, Time.Instant.trySub(t, d)))
        }, cases)

    /// `saturatingSub(t, d)` and `saturatingAdd(t, d)` must move in opposite
    /// directions.
    ///
    /// No test262 counterpart, for the reason given on `TrySub.trySub15`.
    @Test
    def saturatingSub12_aNonZeroDuration_movesTheOppositeWayFromSaturatingAdd(): Unit \ Assert =
        let t = instantOf(1_735_689_600i64, 123_456_789);
        let d = Duration.milliseconds(1);
        Assert.assertEq(expected = (1_735_689_600i64, 124_456_789), partsOf(Time.Instant.saturatingAdd(t, d)));
        Assert.assertEq(expected = (1_735_689_600i64, 122_456_789), partsOf(Time.Instant.saturatingSub(t, d)))
}
