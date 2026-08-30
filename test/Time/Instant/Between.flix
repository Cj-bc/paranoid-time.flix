///
/// Tests for `Time.Instant.between`.
///
/// `between` reports the *magnitude* of the gap between two instants, so it is
/// symmetric and never negative. The gap is returned as a `Duration` built from
/// a number of milliseconds that must fit in an `Int32`; wider gaps are `None`.
///
mod Time.Instant.Between {
    use Time.Duration
    use Time.Instant.Harness.instantOf

    /// The simplest gap, measured forwards.
    @Test
    def between01_forwards(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.milliseconds(1_000)), Time.Instant.between(instantOf(0i64), instantOf(1_000i64)))

    /// `between` reports a magnitude, so the argument order does not matter.
    @Test
    def between02_isSymmetric(): Unit \ Assert =
        let a = instantOf(-4_000i64);
        let b = instantOf(9_000i64);
        Assert.assertEq(expected = Time.Instant.between(a, b), Time.Instant.between(b, a));
        Assert.assertEq(expected = Some(Duration.milliseconds(13_000)), Time.Instant.between(a, b))

    /// An instant is zero away from itself.
    @Test
    def between03_identicalInstants(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(instantOf(1_234i64), instantOf(1_234i64)));
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(instantOf(Int64.maxValue()), instantOf(Int64.maxValue())));
        Assert.assertEq(expected = Some(Duration.zero()), Time.Instant.between(instantOf(Int64.minValue()), instantOf(Int64.minValue())))

    /// Both instants may be before the epoch.
    @Test
    def between04_beforeTheEpoch(): Unit \ Assert =
        Assert.assertEq(expected = Some(Duration.milliseconds(500)), Time.Instant.between(instantOf(-1_500i64), instantOf(-1_000i64)))

    /// The resulting `Duration` carries milliseconds, not the raw difference.
    @Test
    def between05_resultIsInMilliseconds(): Unit \ Assert =
        let actual = Time.Instant.between(instantOf(0i64), instantOf(1i64));
        Assert.assertEq(expected = Some(1_000_000i64), Option.map(Duration.toNanos, actual));
        Assert.assertEq(expected = Some(1i64), Option.map(Duration.toMillis, actual))

    /// The widest gap that still fits in an `Int32` of milliseconds is reported.
    @Test
    def between06_largestRepresentableGap(): Unit \ Assert =
        let gap = Int32.toInt64(Int32.maxValue());
        Assert.assertEq(expected = Some(Duration.milliseconds(Int32.maxValue())), Time.Instant.between(instantOf(0i64), instantOf(gap)));
        Assert.assertEq(expected = Some(Duration.milliseconds(Int32.maxValue())), Time.Instant.between(instantOf(gap), instantOf(0i64)))

    /// One millisecond wider than that is not representable.
    @Test
    def between07_gapTooWideIsNone(): Unit \ Assert =
        let gap = Int32.toInt64(Int32.maxValue()) + 1i64;
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(0i64), instantOf(gap)));
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(gap), instantOf(0i64)))

    /// The gap between the two extremes is far too wide to be represented, so
    /// it must be `None`. Subtracting them in `Int64` wraps around, which must
    /// not be mistaken for a small gap.
    @Test
    def between08_extremesAreTooFarApart(): Unit \ Assert =
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(Int64.minValue()), instantOf(Int64.maxValue())));
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(Int64.maxValue()), instantOf(Int64.minValue())))

    /// A gap of 2^63 milliseconds is likewise unrepresentable. Taking the
    /// absolute value of the wrapped difference must not turn it into a small
    /// -- or negative -- duration.
    @Test
    def between09_gapAtTheEdgeOfInt64(): Unit \ Assert =
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(0i64), instantOf(Int64.minValue())));
        Assert.assertEq(expected = None, Time.Instant.between(instantOf(Int64.minValue()), instantOf(0i64)))

    /// Whatever the arguments, `between` never reports a negative duration.
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
