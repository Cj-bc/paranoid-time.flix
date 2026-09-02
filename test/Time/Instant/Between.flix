///
/// Tests for `Time.Instant.between`.
///
/// `between` reports the *magnitude* of the gap between two instants, so it is
/// symmetric and never negative. The gap is returned as a `Duration`, which
/// counts nanoseconds in an `Int64`; wider gaps are `None`.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.Between {
    use Time.Duration
    use Time.Instant.Harness.{epoch, epochPastLargestDuration, epochPlusLargestDuration, instantOf, maxInstant, minInstant}

    /// The simplest gap, measured forwards.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js`.
    @Test
    def between01_aLaterInstant_returnsTheirDifference(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.nanoseconds(1_750_000_000i64)),
                        Time.Instant.between(instantOf(10i64, 500_000_000), instantOf(12i64, 250_000_000)))

    /// `between` reports a magnitude, so the argument order does not matter.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js` and
    /// `since/add-subtract.js`, which assert `later.until(earlier)` is
    /// `diff.negated()`. `between` reports a magnitude rather than a signed
    /// difference, so the two orders come out *equal* here instead of negated.
    @Test
    def between02_theArgumentsInReverseOrder_returnsTheSameDuration(): Unit \ Assert =
        let a = instantOf(10i64, 500_000_000);
        let b = instantOf(12i64, 250_000_000);
        Assert.assertEq(expected = Time.Instant.between(a, b), Time.Instant.between(b, a));
        Assert.assertEq(expected = Some(Duration.nanoseconds(1_750_000_000i64)), Time.Instant.between(b, a))

    /// An instant is zero away from itself.
    ///
    /// Adapted from test262 `Instant/prototype/until/blank-result.js`.
    @Test
    def between03_theSameInstantTwice_returnsZero(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(epoch(), epoch()));
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(maxInstant(), maxInstant()));
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(minInstant(), minInstant()))

    /// Sub-second differences are kept to the nanosecond.
    ///
    /// Adapted from test262 `Instant/prototype/until/subseconds.js`, which pins down
    /// the precision the difference is reported at.
    @Test
    def between04_oneNanosecondApart_returnsOneNanosecond(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.nanoseconds(1i64)),
                        Time.Instant.between(instantOf(5i64, 1), instantOf(5i64, 2)))

    /// A later instant may carry the smaller `nano`, which makes the nano-part of
    /// the difference negative before the seconds are folded in.
    ///
    /// No test262 counterpart: the two-field split is specific to this
    /// representation.
    @Test
    def between05_aLaterInstantWithSmallerNano_borrowsFromTheSeconds(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.nanoseconds(999_999_999i64)),
                        Time.Instant.between(instantOf(5i64, 1), instantOf(6i64, 0)))

    /// Instants either side of the epoch are not special-cased.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js`, whose earlier
    /// instant is itself before the epoch.
    @Test
    def between06_instantsAcrossTheEpoch_returnsTheirDifference(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.milliseconds(500)),
                        Time.Instant.between(instantOf(-1i64, 500_000_000), epoch()));
        Assert.assertEq(expected = Some(Duration.seconds(2)),
                        Time.Instant.between(instantOf(-1i64, 0), instantOf(1i64, 0)))

    /// The widest gap that still fits in a `Duration` is reported, in both orders.
    ///
    /// Adapted from test262 `Instant/prototype/until/float64-representable-integer.js`.
    /// There the ceiling is float64 precision in the `Duration`; here it is the
    /// `Int64` of nanoseconds a `Duration` counts.
    @Test
    def between07_theLargestRepresentableDifference_returnsIt(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.nanoseconds(Int64.maxValue())),
                        Time.Instant.between(epoch(), epochPlusLargestDuration()));
        Assert.assertEq(expected = Some(Duration.nanoseconds(Int64.maxValue())),
                        Time.Instant.between(epochPlusLargestDuration(), epoch()))

    /// One nanosecond more does not fit.
    ///
    /// Adapted from test262 `Instant/prototype/until/float64-representable-integer.js`.
    @Test
    def between08_oneNanosecondPastTheLargestDifference_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, Time.Instant.between(epoch(), epochPastLargestDuration()));
        Assert.assertEq(expected = None, Time.Instant.between(epochPastLargestDuration(), epoch()))

    /// The gap between the two extremes is far too wide to be represented.
    /// Subtracting them in `Int64` wraps around, which must not be mistaken for a
    /// small gap.
    ///
    /// Adapted from test262 `Instant/limits.js` together with
    /// `until/float64-representable-integer.js`: the widest gap the type admits.
    @Test
    def between09_theWholeRepresentableRange_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, Time.Instant.between(minInstant(), maxInstant()));
        Assert.assertEq(expected = None, Time.Instant.between(maxInstant(), minInstant()))

    /// A gap of 2^63 seconds is likewise unrepresentable, whichever side of the
    /// epoch it is measured from.
    ///
    /// Adapted from test262 `Instant/limits.js`.
    @Test
    def between10_aGapAtTheEdgeOfInt64_returnsNone(): Unit \ Assert =
        Assert.assertEq(expected = None, Time.Instant.between(epoch(), minInstant()));
        Assert.assertEq(expected = None, Time.Instant.between(minInstant(), epoch()));
        Assert.assertEq(expected = None, Time.Instant.between(epoch(), maxInstant()))

    /// Whatever the arguments, `between` never reports a negative duration.
    ///
    /// No test262 counterpart: `until` and `since` are signed, so Temporal never
    /// needs this. `between` reports a magnitude, which makes it an invariant here.
    @Test
    def between11_anyPairOfInstants_neverReturnsANegativeDuration(): Unit \ Assert =
        let cases = List#{
            (epoch(), instantOf(1i64, 0)),
            (instantOf(1i64, 0), epoch()),
            (instantOf(-1i64, 0), instantOf(1i64, 0)),
            (instantOf(1i64, 0), instantOf(-1i64, 0)),
            (instantOf(5i64, 1), instantOf(6i64, 0)),
            (instantOf(6i64, 0), instantOf(5i64, 1)),
            (epoch(), minInstant()),
            (minInstant(), maxInstant()),
            (maxInstant(), minInstant()),
            (epoch(), epochPastLargestDuration())
        };
        List.forEach(match (a, b) -> {
            match Time.Instant.between(a, b) {
                case None    => ()
                case Some(d) => Assert.assertFalseWithMsg(Duration.isNegative(d),
                                                          "between returned the negative duration ${d}")
            }
        }, cases)
}
