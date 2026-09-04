// Copyright (C) 2018 Bloomberg LP. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/add/cross-epoch.js`
/// (esid: sec-temporal.instant.prototype.add).
///
/// `Instant` has no string parser, so the four timestamps test262 names are spelled out as
/// the (second, nanosecond-of-second) pairs they denote:
///
///   1969-12-25T12:23:45.678901234Z -> ( -560175, 678901234)  the starting point
///   1969-12-15T12:23:45.678900434Z -> (-1424175, 678900434)  240 hours and 800 ns earlier
///   1970-01-04T12:23:45.678902034Z -> (  303825, 678902034)  240 hours and 800 ns later
///
/// The starting point is before the epoch and the later one after it, so the pair of
/// shifts crosses the epoch in both directions.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Add.CrossEpoch {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.Instant
    use Time.Instant.tryAdd
    use Time.Instant.trySub

    /// 1969-12-25T12:23:45.678901234Z.
    def inst(): Instant = instant(-560_175i64, 678_901_234)

    /// 1969-12-15T12:23:45.678900434Z.
    def one(): Instant = instant(-1_424_175i64, 678_900_434)

    /// 1970-01-04T12:23:45.678902034Z.
    def two(): Instant = instant(303_825i64, 678_902_034)

    /// test262's `{ hours: 240, nanoseconds: 800 }`. 240 hours is 864000 seconds.
    def shift(): Duration = Duration.hours(240) + Duration.nanoseconds(800i64)

    /// test262's `{ hours: 480, nanoseconds: 1600 }`, twice `shift()`.
    def doubleShift(): Duration = Duration.hours(480) + Duration.nanoseconds(1_600i64)

    ///
    /// test262: `inst.subtract({ hours: 240, nanoseconds: 800 })` is
    /// 1969-12-15T12:23:45.678900434Z.
    ///
    /// -560175 - 864000 = -1424175 seconds, and 678901234 - 800 = 678900434 ns.
    ///
    @Test
    def add01_subtractingTheShift_movesBackBeforeTheEpoch(): Unit \ Assert =
        assertSomeInstant(expected = one(), trySub(inst(), shift()),
                          "inst.subtract({ hours: 240, nanoseconds: 800 })")

    ///
    /// test262: `inst.add({ hours: 240, nanoseconds: 800 })` is
    /// 1970-01-04T12:23:45.678902034Z.
    ///
    /// -560175 + 864000 = 303825 seconds, and 678901234 + 800 = 678902034 ns, so the
    /// result lands after the epoch.
    ///
    @Test
    def add02_addingTheShift_crossesTheEpochForwards(): Unit \ Assert =
        assertSomeInstant(expected = two(), tryAdd(inst(), shift()),
                          "inst.add({ hours: 240, nanoseconds: 800 })")

    /// test262: `two.subtract({ hours: 480, nanoseconds: 1600 })` is `one`.
    @Test
    def add03_subtractingTwiceTheShiftFromTheLater_crossesTheEpochBackwards(): Unit \ Assert =
        assertSomeInstant(expected = one(), trySub(two(), doubleShift()),
                          "two.subtract({ hours: 480, nanoseconds: 1600 })")

    /// test262: `one.add({ hours: 480, nanoseconds: 1600 })` is `two`.
    @Test
    def add04_addingTwiceTheShiftToTheEarlier_crossesTheEpochForwards(): Unit \ Assert =
        assertSomeInstant(expected = two(), tryAdd(one(), doubleShift()),
                          "one.add({ hours: 480, nanoseconds: 1600 })")

}
