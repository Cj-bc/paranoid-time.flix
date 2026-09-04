// Copyright 2021 the V8 project authors. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/add/basic.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// test262 builds each argument as `new Temporal.Duration(0, 0, 0, 0, h, m, s, ms, us, ns)`
/// and reads the result back as one nanosecond count. A `Time.Duration` is a single signed
/// nanosecond count, so the same argument is written as a sum of the per-unit constructors,
/// and each expected count is restated as the (second, nanosecond-of-second) pair.
///
/// `add` throws on a result out of range; `tryAdd` answers `None` instead. Every case here
/// is well inside the range, so `tryAdd` answers `Some`.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.Basic {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.tryAdd

    /// test262's `new Temporal.Instant(50000n)`: 50000 ns after the epoch.
    def inst(): Instant = fromNanos(50_000i64)

    /// The 3 ms + 2 us + 1 ns that every case in test262's file carries: 3002001 ns.
    def subSeconds(): Duration =
        Duration.milliseconds(3) + Duration.microseconds(2) + Duration.nanoseconds(1i64)

    /// The negated form, -3002001 ns.
    def negativeSubSeconds(): Duration =
        Duration.milliseconds(-3) + Duration.microseconds(-2) + Duration.nanoseconds(-1i64)

    ///
    /// test262: "add positive sub-seconds" is 3052001n.
    ///
    /// 50000 + 3002001 = 3052001 ns, still under one second.
    ///
    @Test
    def add01_positiveSubSeconds_addsThem(): Unit \ Assert =
        assertSomeInstant(expected = instant(0i64, 3_052_001), tryAdd(inst(), subSeconds()),
                          "add positive sub-seconds")

    ///
    /// test262: "add positive seconds" is 4e9 + 3052001n.
    ///
    @Test
    def add02_positiveSeconds_addsThemToTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(4i64, 3_052_001),
                          tryAdd(inst(), Duration.seconds(4) + subSeconds()),
                          "add positive seconds")

    ///
    /// test262: "add positive minutes" is (5 * 60 + 4) * 1e9 + 3052001n.
    ///
    /// 5 minutes and 4 seconds is 304 seconds.
    ///
    @Test
    def add03_positiveMinutes_addsThemToTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(304i64, 3_052_001),
                          tryAdd(inst(), Duration.minutes(5) + Duration.seconds(4) + subSeconds()),
                          "add positive minutes")

    ///
    /// test262: "add positive hours" is (6 * 3600 + 5 * 60 + 4) * 1e9 + 3052001n.
    ///
    /// 6 hours, 5 minutes and 4 seconds is 21904 seconds.
    ///
    @Test
    def add04_positiveHours_addsThemToTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(21_904i64, 3_052_001),
                          tryAdd(inst(),
                                 Duration.hours(6) + Duration.minutes(5) + Duration.seconds(4) + subSeconds()),
                          "add positive hours")

    ///
    /// test262: "add negative sub-seconds" is -2952001n.
    ///
    /// 50000 - 3002001 = -2952001 ns, which crosses the epoch: the second count goes to -1
    /// and the leftover is 1000000000 - 2952001 = 997047999 ns.
    ///
    @Test
    def add05_negativeSubSeconds_borrowsASecondAcrossTheEpoch(): Unit \ Assert =
        assertSomeInstant(expected = instant(-1i64, 997_047_999), tryAdd(inst(), negativeSubSeconds()),
                          "add negative sub-seconds")

    ///
    /// test262: "add negative seconds" is -4e9 - 2952001n.
    ///
    /// -4002952001 ns is -5 seconds plus 997047999 ns.
    ///
    @Test
    def add06_negativeSeconds_subtractThemFromTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(-5i64, 997_047_999),
                          tryAdd(inst(), Duration.seconds(-4) + negativeSubSeconds()),
                          "add negative seconds")

    ///
    /// test262: "add negative minutes" is (5 * 60 + 4) * -1e9 - 2952001n.
    ///
    /// -304002952001 ns is -305 seconds plus 997047999 ns.
    ///
    @Test
    def add07_negativeMinutes_subtractThemFromTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(-305i64, 997_047_999),
                          tryAdd(inst(), Duration.minutes(-5) + Duration.seconds(-4) + negativeSubSeconds()),
                          "add negative minutes")

    ///
    /// test262: "add negative hours" is (6 * 3600 + 5 * 60 + 4) * -1e9 - 2952001n.
    ///
    /// -21904002952001 ns is -21905 seconds plus 997047999 ns.
    ///
    @Test
    def add08_negativeHours_subtractThemFromTheSecondCount(): Unit \ Assert =
        assertSomeInstant(expected = instant(-21_905i64, 997_047_999),
                          tryAdd(inst(),
                                 Duration.hours(-6) + Duration.minutes(-5) + Duration.seconds(-4)
                                   + negativeSubSeconds()),
                          "add negative hours")

}
