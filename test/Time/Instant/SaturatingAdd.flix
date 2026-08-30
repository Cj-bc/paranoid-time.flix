///
/// Tests for `Time.Instant.saturatingAdd`.
///
/// `saturatingAdd` agrees with `tryAdd` whenever the result is representable,
/// and clamps to the nearest extreme instead of returning `None` when it is not.
///
mod Time.Instant.SaturatingAdd {
    use Time.Duration
    use Time.Instant.Harness.{instantOf, millisOf}

    /// A positive duration moves the instant forwards.
    @Test
    def saturatingAdd01_positiveDuration(): Unit \ Assert =
        let actual = Time.Instant.saturatingAdd(instantOf(1_000i64), Duration.milliseconds(500));
        Assert.assertEq(expected = 1_500i64, millisOf(actual))

    /// A negative duration moves the instant backwards.
    @Test
    def saturatingAdd02_negativeDuration(): Unit \ Assert =
        let actual = Time.Instant.saturatingAdd(instantOf(1_000i64), Duration.milliseconds(-500));
        Assert.assertEq(expected = 500i64, millisOf(actual))

    /// The zero duration is the identity.
    @Test
    def saturatingAdd03_zeroDurationIsIdentity(): Unit \ Assert =
        let actual = Time.Instant.saturatingAdd(instantOf(1_234i64), Duration.zero());
        Assert.assertEq(expected = 1_234i64, millisOf(actual))

    /// Coarser units are converted before they are added.
    @Test
    def saturatingAdd04_largerUnits(): Unit \ Assert =
        Assert.assertEq(expected = 3_600_000i64, millisOf(Time.Instant.saturatingAdd(instantOf(0i64), Duration.hours(1))));
        Assert.assertEq(expected = 86_400_000i64, millisOf(Time.Instant.saturatingAdd(instantOf(0i64), Duration.days(1))))

    /// Sub-millisecond durations are truncated towards zero, as in `tryAdd`.
    @Test
    def saturatingAdd05_subMillisecondDurationIsTruncated(): Unit \ Assert =
        Assert.assertEq(expected = 0i64, millisOf(Time.Instant.saturatingAdd(instantOf(0i64), Duration.nanoseconds(999_999i64))));
        Assert.assertEq(expected = 0i64, millisOf(Time.Instant.saturatingAdd(instantOf(0i64), Duration.nanoseconds(-999_999i64))))

    /// Landing exactly on an extreme is not saturation, it is just the result.
    @Test
    def saturatingAdd06_reachesTheExtremesExactly(): Unit \ Assert =
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(1))));
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(-1))))

    /// Overflow clamps to the largest instant rather than wrapping.
    @Test
    def saturatingAdd07_overflowClampsToMaxValue(): Unit \ Assert =
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.maxValue()), Duration.milliseconds(1))));
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.maxValue()), Duration.days(1))));
        Assert.assertEq(expected = Int64.maxValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(2))))

    /// Underflow clamps to the smallest instant rather than wrapping.
    @Test
    def saturatingAdd08_underflowClampsToMinValue(): Unit \ Assert =
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.minValue()), Duration.milliseconds(-1))));
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.minValue()), Duration.days(-1))));
        Assert.assertEq(expected = Int64.minValue(), millisOf(Time.Instant.saturatingAdd(instantOf(Int64.minValue() + 1i64), Duration.milliseconds(-2))))

    /// Where `tryAdd` succeeds, `saturatingAdd` must return the same instant.
    @Test
    def saturatingAdd09_agreesWithTryAddInRange(): Unit \ Assert =
        let cases = List#{
            (instantOf(0i64), Duration.milliseconds(1)),
            (instantOf(-1_000i64), Duration.seconds(3)),
            (instantOf(1_234i64), Duration.zero()),
            (instantOf(Int64.maxValue() - 1i64), Duration.milliseconds(1)),
            (instantOf(Int64.minValue() + 1i64), Duration.milliseconds(-1))
        };
        List.forEach(match (t, d) -> {
            Assert.assertEq(
                expected = Some(millisOf(Time.Instant.saturatingAdd(t, d))),
                Option.map(millisOf, Time.Instant.tryAdd(t, d))
            )
        }, cases)
}
