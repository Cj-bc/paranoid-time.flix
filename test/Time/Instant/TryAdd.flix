///
/// Tests for `Time.Instant.tryAdd`.
///
/// `Instant` splits a point in time across a whole-second `Int64` and a `nano`
/// pinned to [0, 999_999_999], so adding a duration has to carry and borrow
/// between the two fields and keep `nano` in range. `tryAdd` returns `None`
/// exactly when the result would leave the representable range, so most of these
/// cases sit on one of those two boundaries.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.TryAdd {
    use Time.Duration
    use Time.Instant.Harness.{epoch, epochPlusLargestDuration, instantOf, maxInstant, minInstant, partsOf, partsOfOpt}

    /// A whole-second duration lands entirely in `secondsSinceEpoch`.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js`.
    @Test
    def tryAdd01_wholeSeconds_addsToSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some((3i64, 0)),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.seconds(3))))

    /// Coarser units are converted before they are added.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js`, which walks the same
    /// ladder of units from sub-seconds up to hours.
    @Test
    def tryAdd02_coarserUnits_convertsThemToSeconds(): Unit \ Assert =
        Assert.assertEq(expected = Some((60i64, 0)), partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.minutes(1))));
        Assert.assertEq(expected = Some((3_600i64, 0)), partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.hours(1))));
        Assert.assertEq(expected = Some((86_400i64, 0)), partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.days(1))))

    /// A sub-second duration is kept to the nanosecond, not rounded to a coarser
    /// unit.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js`, whose sub-second arm
    /// adds milliseconds, microseconds and nanoseconds together.
    @Test
    def tryAdd03_subSecondDuration_isKeptExactly(): Unit \ Assert =
        Assert.assertEq(expected = Some((0i64, 1i32)),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = Some((0i64, 3_002_001)),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.nanoseconds(3_002_001i64))));
        Assert.assertEq(expected = Some((0i64, 999_999_999)),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.nanoseconds(999_999_999i64))))

    /// Nanoseconds past the next second carry into `secondsSinceEpoch`.
    ///
    /// No test262 counterpart: a `Temporal.Instant` is one signed count of
    /// nanoseconds, so it has no second field for a carry to reach.
    @Test
    def tryAdd04_nanosPastTheNextSecond_carriesIntoSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some((1i64, 500_000_000)),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(0i64, 750_000_000), Duration.milliseconds(750))));
        Assert.assertEq(expected = Some((1i64, 0)),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(0i64, 999_999_999), Duration.nanoseconds(1i64))))

    /// A negative duration moves the instant backwards, borrowing a second when
    /// it has to.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js` (its negative arms).
    @Test
    def tryAdd05_negativeDuration_borrowsFromSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some((0i64, 750_000_000)),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(1i64, 500_000_000), Duration.milliseconds(-750))));
        Assert.assertEq(expected = Some((2i64, 0)),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(5i64, 0), Duration.seconds(-3))))

    /// Crossing the epoch backwards still leaves `nano` non-negative.
    ///
    /// Adapted from test262 `Instant/prototype/add/cross-epoch.js`.
    @Test
    def tryAdd06_negativeDurationCrossingTheEpoch_keepsNanoNonNegative(): Unit \ Assert =
        Assert.assertEq(expected = Some((-1i64, 500_000_000)),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.milliseconds(-500))));
        Assert.assertEq(expected = Some((-1i64, 999_999_999)),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.nanoseconds(-1i64))))

    /// The zero duration is the identity, at the extremes as much as anywhere.
    ///
    /// Adapted from test262 `Instant/prototype/add/blank-duration.js` and
    /// `add/minimum-maximum-instant.js` ("Adding zero to the minimum/maximum
    /// instant").
    @Test
    def tryAdd07_zeroDuration_returnsTheSameInstant(): Unit \ Assert =
        Assert.assertEq(expected = Some((1_735_689_600i64, 123_456_789)),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(1_735_689_600i64, 123_456_789), Duration.zero())));
        Assert.assertEq(expected = Some(partsOf(maxInstant())),
                        partsOfOpt(Time.Instant.tryAdd(maxInstant(), Duration.zero())));
        Assert.assertEq(expected = Some(partsOf(minInstant())),
                        partsOfOpt(Time.Instant.tryAdd(minInstant(), Duration.zero())))

    /// Landing exactly on an extreme succeeds; it is the step past it that fails.
    ///
    /// Adapted from test262 `Instant/prototype/add/minimum-maximum-instant.js`
    /// ("Adding one to the minimum instant", "Subtracting one from the maximum
    /// instant").
    @Test
    def tryAdd08_reachingAnExtreme_returnsThatInstant(): Unit \ Assert =
        Assert.assertEq(expected = Some((Int64.maxValue(), 0)),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue() - 1i64, 0), Duration.seconds(1))));
        Assert.assertEq(expected = Some(partsOf(maxInstant())),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue(), 999_999_998), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = Some(partsOf(minInstant())),
                        partsOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue(), 1), Duration.nanoseconds(-1i64))))

    /// Overflowing past the latest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/add/result-out-of-range.js` and
    /// `add/minimum-maximum-instant.js`. Temporal throws a `RangeError` where this
    /// library returns `None`.
    @Test
    def tryAdd09_pastTheLatestInstant_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.tryAdd(maxInstant(), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.tryAdd(maxInstant(), Duration.days(1))));
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue(), 0), Duration.seconds(1))))

    /// Underflowing past the earliest instant yields `None` rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/add/result-out-of-range.js` and
    /// `add/minimum-maximum-instant.js` (their negative arms).
    @Test
    def tryAdd10_pastTheEarliestInstant_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.tryAdd(minInstant(), Duration.nanoseconds(-1i64))));
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.tryAdd(minInstant(), Duration.days(-1))));
        Assert.assertEq(expected = None, partsOfOpt(Time.Instant.tryAdd(instantOf(Int64.minValue(), 999_999_999), Duration.seconds(-1))))

    /// A duration under a second can still overflow, through the carry alone.
    ///
    /// No test262 counterpart: the carry between the two fields is specific to
    /// this representation.
    @Test
    def tryAdd11_carryPastTheLatestInstant_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None,
                        partsOfOpt(Time.Instant.tryAdd(instantOf(Int64.maxValue(), 500_000_000), Duration.milliseconds(600))))

    /// The largest duration there is, added to the epoch, is still in range.
    ///
    /// Adapted from test262 `Instant/prototype/add/add-large-subseconds.js`, which
    /// pushes a duration given in a fine unit up to the largest value the host can
    /// represent.
    @Test
    def tryAdd12_theLargestDuration_addsItExactly(): Unit \ Assert =
        Assert.assertEq(expected = Some(partsOf(epochPlusLargestDuration())),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.nanoseconds(Int64.maxValue()))))

    /// `Int64.minValue()` nanoseconds has no positive counterpart, but adding it
    /// needs none, and it must not be mistaken for a smaller magnitude.
    ///
    /// Adapted from test262 `Instant/prototype/add/add-large-subseconds.js` (its
    /// `Number.MIN_SAFE_INTEGER` arms).
    @Test
    def tryAdd13_theSmallestDuration_addsItExactly(): Unit \ Assert =
        // -9_223_372_036_854_775_808ns is -9_223_372_037 seconds plus 145_224_192ns.
        Assert.assertEq(expected = Some((-9_223_372_037i64, 145_224_192)),
                        partsOfOpt(Time.Instant.tryAdd(epoch(), Duration.nanoseconds(Int64.minValue()))))
}
