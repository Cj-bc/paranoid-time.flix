///
/// Tests for `Time.Instant.between`.
///
/// `between` reports the *magnitude* of the gap between two instants, so it is
/// symmetric and never negative. The gap is returned as a `Duration` built from
/// a number of milliseconds that must fit in an `Int32`; wider gaps are `None`.
///
/// Every test names the test262 case it was adapted from, or says plainly that it
/// has no counterpart there. References are against test262
/// `7710052` (2026-08-30) and are relative to `test/built-ins/Temporal/`.
///
mod Time.Instant.Between {
    use Time.Duration
    use Time.Instant.Harness.instantOf

    /// The simplest gap, measured forwards.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js`.
    @Test
    def between01_forwards(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.milliseconds(1_000)), Time.Instant.between(instantOf(0i64), instantOf(1_000i64)))

    /// `between` reports a magnitude, so the argument order does not matter.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js` and
    /// `since/add-subtract.js`, which assert `later.until(earlier)` is `diff.negated()`.
    /// `between` reports a magnitude rather than a signed difference, so the two
    /// orders come out *equal* here instead of negated.
    @Test
    def between02_isSymmetric(): Unit \ Assert =
        let a = instantOf(-4_000i64);
        let b = instantOf(9_000i64);
        Assert.assertEq(expected = Time.Instant.between(a, b), Time.Instant.between(b, a));
        Assert.assertEq(expected = Some(Duration.milliseconds(13_000)), Time.Instant.between(a, b))

    /// An instant is zero away from itself.
    ///
    /// Adapted from test262 `Instant/prototype/until/blank-result.js`.
    @Test
    def between03_identicalInstants(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(instantOf(1_234i64), instantOf(1_234i64)));
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(instantOf(Int64.maxValue()), instantOf(Int64.maxValue())));
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(instantOf(Int64.minValue()), instantOf(Int64.minValue())))

    /// Both instants may be before the epoch.
    ///
    /// Adapted from test262 `Instant/prototype/until/add-subtract.js`, whose earlier
    /// instant is itself before the epoch.
    @Test
    def between04_beforeTheEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.milliseconds(500)), Time.Instant.between(instantOf(-1_500i64), instantOf(-1_000i64)))

    /// The resulting `Duration` carries milliseconds, not the raw difference.
    ///
    /// Adapted from test262 `Instant/prototype/until/subseconds.js`, which pins down
    /// the unit the difference is reported in.
    @Test
    def between05_resultIsInMilliseconds(): Unit \ Assert =
        let actual = Time.Instant.between(instantOf(0i64), instantOf(1i64));
        Assert.assertEq(expected = Some(1_000_000i64), Option.map(Duration.toNanos, actual));
        Assert.assertEq(expected = Some(1i64), Option.map(Duration.toMillis, actual))

    /// The widest gap that still fits in an `Int32` of milliseconds is reported.
    ///
    /// Adapted from test262 `Instant/prototype/until/float64-representable-integer.js`.
    /// There the ceiling is float64 precision in the `Duration`; here it is the `Int32`
    /// of milliseconds `between` builds its `Duration` from.
    @Test
    def between06_largestRepresentableGap(): Unit \ Assert =
        let gap = Int32.toInt64(Int32.maxValue());
        Assert.assertEq(expected = Some(Duration.milliseconds(Int32.maxValue())), Time.Instant.between(instantOf(0i64), instantOf(gap)));
        Assert.assertEq(expected = Some(Duration.milliseconds(Int32.maxValue())), Time.Instant.between(instantOf(gap), instantOf(0i64)))

    /// One millisecond wider than that is not representable.
    ///
    /// Adapted from test262 `Instant/prototype/until/float64-representable-integer.js`.
    @Test
    def between07_gapTooWideIsNone(): Unit \ Assert =
        let gap = Int32.toInt64(Int32.maxValue()) + 1i64;
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(0i64), instantOf(gap)));
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(gap), instantOf(0i64)))

    /// The gap between the two extremes is far too wide to be represented, so
    /// it must be `None`. Subtracting them in `Int64` wraps around, which must
    /// not be mistaken for a small gap.
    ///
    /// Adapted from test262 `Instant/limits.js` together with
    /// `until/float64-representable-integer.js`: the widest gap the type admits.
    @Test
    def between08_extremesAreTooFarApart(): Unit \ Assert =
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(Int64.minValue()), instantOf(Int64.maxValue())));
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(Int64.maxValue()), instantOf(Int64.minValue())))

    /// A gap of 2^63 milliseconds is likewise unrepresentable. Taking the
    /// absolute value of the wrapped difference must not turn it into a small
    /// -- or negative -- duration.
    ///
    /// Adapted from test262 `Instant/limits.js`.
    @Test
    def between09_gapAtTheEdgeOfInt64(): Unit \ Assert =
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(0i64), instantOf(Int64.minValue())));
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(Int64.minValue()), instantOf(0i64)))

    /// Whatever the arguments, `between` never reports a negative duration.
    ///
    /// No test262 counterpart: `until` and `since` are signed, so Temporal never needs
    /// this. `between` reports a magnitude, which makes it an invariant here.
    @Test
    def between10_isNeverNegative(): Unit \ Assert =
        let cases = List#{
            (instantOf(0i64), instantOf(1_000i64)),
            (instantOf(1_000i64), instantOf(0i64)),
            (instantOf(-1_000i64), instantOf(1_000i64)),
            (instantOf(1_000i64), instantOf(-1_000i64)),
            (instantOf(0i64), instantOf(Int64.minValue())),
            (instantOf(Int64.minValue()), instantOf(Int64.maxValue()))
        };
        List.forEach(match (a, b) -> {
            match Time.Instant.between(a, b) {
                case None    => ()
                case Some(d) => Assert.assertFalseWithMsg(Duration.isNegative(d), "between returned the negative duration ${d}")
            }
        }, cases)
}
