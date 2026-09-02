///
/// Tests for `Time.Instant.trySub`.
///
/// `trySub(t, d)` is the mirror image of `tryAdd(t, d)`: it moves `t` backwards
/// by `d`, carrying and borrowing between `secondsSinceEpoch` and `nano`, and
/// returns `None` when the result would leave the representable range.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.TrySub {
    use Time.Duration
    use Time.Instant.Harness.{epoch, epochPastLargestDuration, instantOf, maxInstant, minInstant, partsOf, partsOfOpt}

    /// A whole-second duration comes straight off `secondsSinceEpoch`.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js`.
    @Test
    def trySub01_wholeSeconds_subtractsFromSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some((-3i64, 0)),
                        partsOfOpt(Time.Instant.trySub(epoch(), Duration.seconds(3))))

    /// Coarser units are converted before they are subtracted.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js`.
    @Test
    def trySub02_coarserUnits_convertsThemToSeconds(): Unit \ Assert =
        Assert.assertEq(expected = Some((-3_600i64, 0)), partsOfOpt(Time.Instant.trySub(epoch(), Duration.hours(1))));
        Assert.assertEq(expected = Some((-86_400i64, 0)), partsOfOpt(Time.Instant.trySub(epoch(), Duration.days(1))))

    /// A sub-second duration is kept to the nanosecond, not rounded to a coarser
    /// unit.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js` (its sub-second arm).
    @Test
    def trySub03_subSecondDuration_isKeptExactly(): Unit \ Assert =
        Assert.assertEq(expected = Some((5i64, 999_999_999)),
                        partsOfOpt(Time.Instant.trySub(instantOf(6i64, 0), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = Some((5i64, 996_997_999)),
                        partsOfOpt(Time.Instant.trySub(instantOf(6i64, 0), Duration.nanoseconds(3_002_001i64))))

    /// Nanoseconds past the previous second borrow from `secondsSinceEpoch`.
    ///
    /// No test262 counterpart: a `Temporal.Instant` is one signed count of
    /// nanoseconds, so it has no second field for a borrow to reach.
    @Test
    def trySub04_nanosPastThePreviousSecond_borrowsFromSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some((0i64, 750_000_000)),
                        partsOfOpt(Time.Instant.trySub(instantOf(1i64, 500_000_000), Duration.milliseconds(750))))

    /// A negative duration moves the instant forwards, carrying into the seconds.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/basic.js` (its negative arms).
    @Test
    def trySub05_negativeDuration_carriesIntoSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some((1i64, 500_000_000)),
                        partsOfOpt(Time.Instant.trySub(instantOf(0i64, 750_000_000), Duration.milliseconds(-750))))

    /// Crossing the epoch backwards still leaves `nano` non-negative.
    ///
    /// Adapted from test262 `Instant/prototype/add/cross-epoch.js`, which drives the
    /// same instant through both `add` and `subtract`.
    @Test
    def trySub06_crossingTheEpoch_keepsNanoNonNegative(): Unit \ Assert =
        Assert.assertEq(expected = Some((-1i64, 500_000_000)),
                        partsOfOpt(Time.Instant.trySub(epoch(), Duration.milliseconds(500))));
        Assert.assertEq(expected = Some((-1i64, 999_999_999)),
                        partsOfOpt(Time.Instant.trySub(epoch(), Duration.nanoseconds(1i64))))

    /// The zero duration is the identity, at the extremes as much as anywhere.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/blank-duration.js` and
    /// `subtract/minimum-maximum-instant.js`.
    @Test
    def trySub07_zeroDuration_returnsTheSameInstant(): Unit \ Assert =
        Assert.assertEq(expected = Some((1_735_689_600i64, 123_456_789)),
                        partsOfOpt(Time.Instant.trySub(instantOf(1_735_689_600i64, 123_456_789), Duration.zero())));
        Assert.assertEq(expected = Some(partsOf(maxInstant())),
                        partsOfOpt(Time.Instant.trySub(maxInstant(), Duration.zero())));
        Assert.assertEq(expected = Some(partsOf(minInstant())),
                        partsOfOpt(Time.Instant.trySub(minInstant(), Duration.zero())))

    /// Landing exactly on an extreme succeeds; it is the step past it that fails.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/minimum-maximum-instant.js`.
    @Test
    def trySub08_reachingAnExtreme_returnsThatInstant(): Unit \ Assert =
        Assert.assertEq(expected = Some(partsOf(minInstant())),
                        partsOfOpt(Time.Instant.trySub(instantOf(Int64.minValue(), 1), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = Some(partsOf(maxInstant())),
                        partsOfOpt(Time.Instant.trySub(instantOf(Int64.maxValue(), 999_999_998), Duration.nanoseconds(-1i64))))

    /// Underflowing past the earliest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/result-out-of-range.js` and
    /// `subtract/minimum-maximum-instant.js`, with `None` in place of the `RangeError`.
    @Test
    def trySub09_pastTheEarliestInstant_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.trySub(minInstant(), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.trySub(minInstant(), Duration.days(1))))

    /// Overflowing past the latest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/result-out-of-range.js` (its
    /// negative arms).
    @Test
    def trySub10_pastTheLatestInstant_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.trySub(maxInstant(), Duration.nanoseconds(-1i64))));
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.trySub(maxInstant(), Duration.days(-1))))

    /// A duration under a second can still underflow, through the borrow alone.
    ///
    /// No test262 counterpart: the borrow between the two fields is specific to
    /// this representation.
    @Test
    def trySub11_borrowPastTheEarliestInstant_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None,
                        partsOfOpt(Time.Instant.trySub(instantOf(Int64.minValue(), 500_000_000), Duration.milliseconds(600))))

    /// `Int64.minValue()` nanoseconds has no positive counterpart, so it cannot be
    /// negated as a whole. Negating the second- and nano-parts of its split
    /// separately has no such problem, and must land on the exact instant.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/subtract-large-subseconds.js`,
    /// which subtracts the most extreme durations the host can represent.
    @Test
    def trySub12_theSmallestDuration_subtractsItExactly(): Unit \ Assert =
        // Negating it reaches one nanosecond past `Int64.maxValue()` nanoseconds.
        Assert.assertEq(expected = Some(partsOf(epochPastLargestDuration())),
                        partsOfOpt(Time.Instant.trySub(epoch(), Duration.nanoseconds(Int64.minValue()))))

    /// The largest positive duration is subtracted without incident.
    ///
    /// Adapted from test262 `Instant/prototype/subtract/subtract-large-subseconds.js`.
    @Test
    def trySub13_theLargestDuration_subtractsItExactly(): Unit \ Assert =
        // -9_223_372_036_854_775_807ns is -9_223_372_037 seconds plus 145_224_193ns.
        Assert.assertEq(expected = Some((-9_223_372_037i64, 145_224_193)),
                        partsOfOpt(Time.Instant.trySub(epoch(), Duration.nanoseconds(Int64.maxValue()))))

    /// Subtracting a duration undoes adding it.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js` and
    /// `since/add-subtract.js`, which assert `later.subtract(diff)` returns `earlier`.
    @Test
    def trySub14_theDurationJustAdded_returnsTheOriginalInstant(): Unit \ Assert =
        let cases = List#{
            (epoch(), Duration.milliseconds(1)),
            (instantOf(1_735_689_600i64, 123_456_789), Duration.milliseconds(1_500)),
            (instantOf(-1i64, 999_999_999), Duration.nanoseconds(1i64)),
            (instantOf(0i64, 750_000_000), Duration.milliseconds(-750)),
            (instantOf(999i64, 1), Duration.days(7))
        };
        List.forEach(match (t, d) -> {
            let roundTripped = Option.flatMap(u -> Time.Instant.trySub(u, d), Time.Instant.tryAdd(t, d));
            Assert.assertEq(expected = Some(partsOf(t)), partsOfOpt(roundTripped))
        }, cases)

    /// `trySub(t, d)` and `tryAdd(t, d)` must move in opposite directions.
    ///
    /// No test262 counterpart: Temporal has never had to state that `subtract` is
    /// not `add`.
    @Test
    def trySub15_aNonZeroDuration_movesTheOppositeWayFromTryAdd(): Unit \ Assert =
        let t = instantOf(1_735_689_600i64, 123_456_789);
        let d = Duration.milliseconds(1);
        Assert.assertEq(expected = Some((1_735_689_600i64, 124_456_789)), partsOfOpt(Time.Instant.tryAdd(t, d)));
        Assert.assertEq(expected = Some((1_735_689_600i64, 122_456_789)), partsOfOpt(Time.Instant.trySub(t, d)))
}
