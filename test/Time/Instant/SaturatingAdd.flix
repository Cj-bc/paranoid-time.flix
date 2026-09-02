///
/// Tests for `Time.Instant.saturatingAdd`.
///
/// `saturatingAdd` agrees with `tryAdd` whenever the result is representable,
/// and returns the nearest extreme instead of `None` when it is not.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.SaturatingAdd {
    use Time.Duration
    use Time.Instant.Harness.{epoch, instantOf, maxInstant, minInstant, partsOf}

    /// A whole-second duration lands entirely in `secondsSinceEpoch`.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js`.
    @Test
    def saturatingAdd01_wholeSeconds_addsToSecondsSinceEpoch(): Unit \ Assert =
        Assert.assertEq(expected = (60i64, 0), partsOf(Time.Instant.saturatingAdd(epoch(), Duration.minutes(1))))

    /// A sub-second duration is kept to the nanosecond.
    ///
    /// Adapted from test262 `Instant/prototype/add/basic.js` (its sub-second arm).
    @Test
    def saturatingAdd02_subSecondDuration_isKeptExactly(): Unit \ Assert =
        Assert.assertEq(expected = (1i64, 500_000_000),
                        partsOf(Time.Instant.saturatingAdd(instantOf(0i64, 750_000_000), Duration.milliseconds(750))))

    /// A negative duration moves the instant backwards and keeps `nano` non-negative.
    ///
    /// Adapted from test262 `Instant/prototype/add/cross-epoch.js`.
    @Test
    def saturatingAdd03_negativeDurationCrossingTheEpoch_keepsNanoNonNegative(): Unit \ Assert =
        Assert.assertEq(expected = (-1i64, 500_000_000),
                        partsOf(Time.Instant.saturatingAdd(epoch(), Duration.milliseconds(-500))))

    /// The zero duration is the identity.
    ///
    /// Adapted from test262 `Instant/prototype/add/blank-duration.js`.
    @Test
    def saturatingAdd04_zeroDuration_returnsTheSameInstant(): Unit \ Assert =
        Assert.assertEq(expected = (1_735_689_600i64, 123_456_789),
                        partsOf(Time.Instant.saturatingAdd(instantOf(1_735_689_600i64, 123_456_789), Duration.zero())))

    /// Landing exactly on an extreme is not saturation, it is just the result.
    ///
    /// Adapted from test262 `Instant/prototype/add/minimum-maximum-instant.js`.
    @Test
    def saturatingAdd05_reachingAnExtreme_returnsThatInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(maxInstant()),
                        partsOf(Time.Instant.saturatingAdd(instantOf(Int64.maxValue(), 999_999_998), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = partsOf(minInstant()),
                        partsOf(Time.Instant.saturatingAdd(instantOf(Int64.minValue(), 1), Duration.nanoseconds(-1i64))))

    /// Overflow returns the latest instant rather than wrapping. The clamp is to
    /// the extreme itself, `nano` ceiling included.
    ///
    /// Adapted from test262 `Instant/prototype/add/result-out-of-range.js`. Temporal
    /// has no saturating variant -- it throws a `RangeError` -- so the inputs carry
    /// over but the expectation is clamping.
    @Test
    def saturatingAdd06_pastTheLatestInstant_returnsTheLatestInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(maxInstant()),
                        partsOf(Time.Instant.saturatingAdd(maxInstant(), Duration.nanoseconds(1i64))));
        Assert.assertEq(expected = partsOf(maxInstant()),
                        partsOf(Time.Instant.saturatingAdd(maxInstant(), Duration.days(1))))

    /// Underflow returns the earliest instant rather than wrapping.
    ///
    /// Adapted from test262 `Instant/prototype/add/result-out-of-range.js` (its
    /// negative arms), with clamping in place of the `RangeError`.
    @Test
    def saturatingAdd07_pastTheEarliestInstant_returnsTheEarliestInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(minInstant()),
                        partsOf(Time.Instant.saturatingAdd(minInstant(), Duration.nanoseconds(-1i64))));
        Assert.assertEq(expected = partsOf(minInstant()),
                        partsOf(Time.Instant.saturatingAdd(minInstant(), Duration.days(-1))))

    /// A duration under a second can still overflow, through the carry alone.
    ///
    /// No test262 counterpart: the carry between the two fields is specific to
    /// this representation.
    @Test
    def saturatingAdd08_carryPastTheLatestInstant_returnsTheLatestInstant(): Unit \ Assert =
        Assert.assertEq(expected = partsOf(maxInstant()),
                        partsOf(Time.Instant.saturatingAdd(instantOf(Int64.maxValue(), 500_000_000), Duration.milliseconds(600))))

    /// Where `tryAdd` succeeds, `saturatingAdd` must return the same instant.
    ///
    /// No test262 counterpart: it relates the two variants this library offers, and
    /// Temporal has only the throwing one.
    @Test
    def saturatingAdd09_withinRange_agreesWithTryAdd(): Unit \ Assert =
        let cases = List#{
            (epoch(), Duration.milliseconds(1)),
            (instantOf(-1i64, 999_999_999), Duration.nanoseconds(1i64)),
            (instantOf(1_735_689_600i64, 123_456_789), Duration.seconds(-3)),
            (instantOf(0i64, 0), Duration.zero()),
            (instantOf(Int64.maxValue(), 999_999_998), Duration.nanoseconds(1i64)),
            (instantOf(Int64.minValue(), 1), Duration.nanoseconds(-1i64))
        };
        List.forEach(match (t, d) -> {
            Assert.assertEq(expected = Some(partsOf(Time.Instant.saturatingAdd(t, d))),
                            Option.map(partsOf, Time.Instant.tryAdd(t, d)))
        }, cases)
}
