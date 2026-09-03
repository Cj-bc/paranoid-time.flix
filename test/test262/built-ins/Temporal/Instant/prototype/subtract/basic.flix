///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/subtract/basic.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// The mirror image of `add/basic.js`, from the same starting point and with the same
/// arguments. A `Time.Duration` is a single signed nanosecond count, so test262's
/// ten-argument `Temporal.Duration` becomes a sum of the per-unit constructors, and each
/// expected count is restated as a (second, nanosecond-of-second) pair.
///
/// `subtract` throws on a result out of range; `trySub` answers `None` instead. Every case
/// here is well inside the range, so `trySub` answers `Some`.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.Basic {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.trySub

    /// test262's `new Temporal.Instant(50000n)`: 50000 ns after the epoch.
    def inst(): Instant = fromNanos(50_000i64)

    /// The 3 ms + 2 us + 1 ns that every case in test262's file carries: 3002001 ns.
    def subSeconds(): Duration =
        Duration.milliseconds(3) + Duration.microseconds(2) + Duration.nanoseconds(1i64)

    /// The negated form, -3002001 ns.
    def negativeSubSeconds(): Duration =
        Duration.milliseconds(-3) + Duration.microseconds(-2) + Duration.nanoseconds(-1i64)

    ///
    /// test262: "subtract positive sub-seconds" is -2952001n.
    ///
    /// 50000 - 3002001 = -2952001 ns, which crosses the epoch: the second count goes to -1
    /// and the leftover is 1000000000 - 2952001 = 997047999 ns.
    ///
    @Test
    def subtract01_positiveSubSeconds_borrowsASecondAcrossTheEpoch(): Unit \ Assert =
        assertSomeInstant(expected = instant(-1i64, 997_047_999), trySub(inst(), subSeconds()),
                          "subtract positive sub-seconds")

    ///
    /// test262: "subtract positive seconds" is -4e9 - 2952001n.
    ///
    /// -4002952001 ns is -5 seconds plus 997047999 ns.
    ///
    @Test
    def subtract02_positiveSeconds_subtractThemFromTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(-5i64, 997_047_999),
                          trySub(inst(), Duration.seconds(4) + subSeconds()),
                          "subtract positive seconds")

    ///
    /// test262: "subtract positive minutes" is (5 * 60 + 4) * -1e9 - 2952001n.
    ///
    /// 5 minutes and 4 seconds is 304 seconds, and -304002952001 ns is -305 seconds plus
    /// 997047999 ns.
    ///
    @Test
    def subtract03_positiveMinutes_subtractThemFromTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(-305i64, 997_047_999),
                          trySub(inst(), Duration.minutes(5) + Duration.seconds(4) + subSeconds()),
                          "subtract positive minutes")

    ///
    /// test262: "subtract positive hours" is (6 * 3600 + 5 * 60 + 4) * -1e9 - 2952001n.
    ///
    /// 6 hours, 5 minutes and 4 seconds is 21904 seconds, and -21904002952001 ns is
    /// -21905 seconds plus 997047999 ns.
    ///
    @Test
    def subtract04_positiveHours_subtractThemFromTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(-21_905i64, 997_047_999),
                          trySub(inst(),
                                 Duration.hours(6) + Duration.minutes(5) + Duration.seconds(4) + subSeconds()),
                          "subtract positive hours")

    ///
    /// test262: "subtract negative sub-seconds" is 3052001n.
    ///
    /// 50000 + 3002001 = 3052001 ns, still under one second.
    ///
    @Test
    def subtract05_negativeSubSeconds_addsThem(): Unit \ Assert =
        assertSomeInstant(expected = instant(0i64, 3_052_001), trySub(inst(), negativeSubSeconds()),
                          "subtract negative sub-seconds")

    /// test262: "subtract negative seconds" is 4e9 + 3052001n.
    @Test
    def subtract06_negativeSeconds_addThemToTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(4i64, 3_052_001),
                          trySub(inst(), Duration.seconds(-4) + negativeSubSeconds()),
                          "subtract negative seconds")

    /// test262: "subtract negative minutes" is (5 * 60 + 4) * 1e9 + 3052001n.
    @Test
    def subtract07_negativeMinutes_addThemToTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(304i64, 3_052_001),
                          trySub(inst(), Duration.minutes(-5) + Duration.seconds(-4) + negativeSubSeconds()),
                          "subtract negative minutes")

    /// test262: "subtract negative hours" is (6 * 3600 + 5 * 60 + 4) * 1e9 + 3052001n.
    @Test
    def subtract08_negativeHours_addThemToTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(21_904i64, 3_052_001),
                          trySub(inst(),
                                 Duration.hours(-6) + Duration.minutes(-5) + Duration.seconds(-4)
                                   + negativeSubSeconds()),
                          "subtract negative hours")

}
