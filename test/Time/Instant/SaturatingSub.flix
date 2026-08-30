///
/// Tests for `Time.Instant.saturatingSub`.
///
/// `saturatingSub` agrees with `trySub` whenever the result is representable,
/// and clamps to the nearest extreme instead of returning `None` when it is not.
///
mod Time.Instant.SaturatingSub {
    use Time.Duration
    use Time.Instant.Harness.{instantOf, millisOf}

    /// A positive duration moves the instant backwards.
    @Test
    def saturatingSub01_positiveDuration(): Unit \ Assert =
        let actual = Time.Instant.saturatingSub(instantOf(1_000i64), Duration.milliseconds(500));
        Assert.assertEq(expected = 500i64, millisOf(actual))

    /// A negative duration moves the instant forwards.
    @Test
    def saturatingSub02_negativeDuration(): Unit \ Assert =
        let actual = Time.Instant.saturatingSub(instantOf(1_000i64), Duration.milliseconds(-500));
        Assert.assertEq(expected = 1_500i64, millisOf(actual))

    /// The zero duration is the identity.
    @Test
    def saturatingSub03_zeroDurationIsIdentity(): Unit \ Assert =
        let actual = Time.Instant.saturatingSub(instantOf(1_234i64), Duration.zero());
        Assert.assertEq(expected = 1_234i64, millisOf(actual))

    /// Coarser units are converted before they are subtracted.
    @Test
    def saturatingSub04_largerUnits(): Unit \ Assert =
        Assert.assertEq(expected = -3_600_000i64, millisOf(Time.Instant.saturatingSub(instantOf(0i64), Duration.hours(1))));
        Assert.assertEq(expected = -86_400_000i64, millisOf(Time.Instant.saturatingSub(instantOf(0i64), Duration.days(1))))

    /// Sub-millisecond durations are truncated towards zero, as in `trySub`.
    @Test
    def saturatingSub05_subMillisecondDurationIsTruncated(): Unit \ Assert =
        Assert.assertEq(expected = 0i64, millisOf(Time.Instant.saturatingSub(instantOf(0i64), Duration.nanoseconds(999_999i64))));
        Assert.assertEq(expected = 0i64, millisOf(Time.Instant.saturatingSub(instantOf(0i64), Duration.nanoseconds(-999_999i64))))

    /// Landing exactly on an extreme is not saturation, it is just the result.
    @Test
    def saturatingSub06_reachesTheExtremesExactly(): Unit \ Assert =
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(1))));
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(-1))))

    /// Underflow clamps to the smallest instant rather than wrapping.
    @Test
    def saturatingSub07_underflowClampsToMinValue(): Unit \ Assert =
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.minValue()), Duration.milliseconds(1))));
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.minValue()), Duration.days(1))));
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(2))))

    /// Overflow clamps to the largest instant rather than wrapping.
    @Test
    def saturatingSub08_overflowClampsToMaxValue(): Unit \ Assert =
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.maxValue()), Duration.milliseconds(-1))));
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.maxValue()), Duration.days(-1))));
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingSub(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(-2))))

    /// `Duration` is stored as nanoseconds, so `Int64.minValue()` nanoseconds
    /// cannot be negated within an `Int64`. Truncating it to milliseconds first
    /// makes it representable: -9_223_372_036_854 milliseconds.
    @Test
    def saturatingSub09_mostNegativeDuration(): Unit \ Assert =
        let actual = Time.Instant.saturatingSub(instantOf(0i64), Duration.nanoseconds(Int64.minValue()));
        Assert.assertEq(expected = 9_223_372_036_854i64, millisOf(actual))

    /// Where `trySub` succeeds, `saturatingSub` must return the same instant.
    @Test
    def saturatingSub10_agreesWithTrySubInRange(): Unit \ Assert =
        let cases = List#{
            (instantOf(0i64), Duration.milliseconds(1)),
            (instantOf(-1_000i64), Duration.seconds(3)),
            (instantOf(1_234i64), Duration.zero()),
            (instantOf(Int64.minValue() + 1i64), Duration.milliseconds(1)),
            (instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(-1))
        };
        List.forEach(match (t, d) -> {
            Assert.assertEq(
                expected = Some(millisOf(Time.Instant.saturatingSub(t, d))),
                Option.map(millisOf, Time.Instant.trySub(t, d))
            )
        }, cases)

    /// `saturatingSub(t, d)` and `saturatingAdd(t, d)` must move in opposite
    /// directions.
    @Test
    def saturatingSub11_isNotSaturatingAdd(): Unit \ Assert =
        let t = instantOf(0i64);
        let d = Duration.milliseconds(1);
        Assert.assertNeqWithMsg(
            unexpected = millisOf(Time.Instant.saturatingAdd(t, d)),
            millisOf(Time.Instant.saturatingSub(t, d)),
            "saturatingSub must subtract the duration, not add it"
        )
}
