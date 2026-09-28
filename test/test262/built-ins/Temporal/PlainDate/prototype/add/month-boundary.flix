// Copyright (C) 2025 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/add/month-boundary.js`
/// (esid: sec-temporal.plaindate.prototype.add).
///
/// The walk comes over step for step. `add` with six months becomes `tryPlusMonths`, and
/// with one day `tryPlusDays`. The `reject` option `from` is given has nothing to reject
/// for 2000-12-01 and is dropped.
///
/// Every date the walk reaches is near 2000, far from either end of the range, so the
/// `Option`s are unwrapped with `LocalDate.min()` as the default: a `None` would show up
/// as a wrong date in the assertion that follows.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Add.MonthBoundary {

    use TemporalHelpers.{assertPlainDatesEqual, plainDate}
    use Time.LocalDate
    use Time.LocalDate.{LocalDate, getDayOfMonth, lengthOfMonth, tryPlusDays, tryPlusMonths}

    def days(d: LocalDate, n: Int64): LocalDate = tryPlusDays(d, n) |> Option.getWithDefault(LocalDate.min())

    def months(d: LocalDate, n: Int64): LocalDate = tryPlusMonths(d, n) |> Option.getWithDefault(LocalDate.min())

    /// Moves `d` forward, one day at a time, to the next first day of a month.
    def nextFirstOfMonth(d: LocalDate, forward: Int64): LocalDate =
        let next = days(d, forward);
        if (getDayOfMonth(next) == 1) next else nextFirstOfMonth(next, forward)

    ///
    /// test262 runs the loop body once per duration; `duration` is the month count, and
    /// `forward` the day count that moves one day later under `add`.
    ///
    def check(duration: Int64, forward: Int64): Unit \ Assert = {
        let start = plainDate(2000, 12, 1);
        let end = months(start, duration);

        let startYesterday = days(start, -forward);
        let endYesterday = months(startYesterday, duration);
        Assert.assertEqWithMsg(expected = Int32.min(getDayOfMonth(startYesterday), lengthOfMonth(endYesterday)),
                               getDayOfMonth(endYesterday), "adding months should result in same day");

        let endYesterdayNextDay = nextFirstOfMonth(endYesterday, forward);
        assertPlainDatesEqual(expected = end, Some(endYesterdayNextDay), "endYesterdayNextDay");

        let endReverse = days(endYesterdayNextDay, -forward);
        let startReverse = months(endReverse, -duration);
        Assert.assertEqWithMsg(expected = Int32.min(getDayOfMonth(endReverse), lengthOfMonth(startReverse)),
                               getDayOfMonth(startReverse), "subtracting months give the same day");

        let startReverseNextDay = nextFirstOfMonth(startReverse, forward);
        assertPlainDatesEqual(expected = start, Some(startReverseNextDay), "startReverseNextDay")
    }

    @Test
    def monthBoundary01_months6(): Unit \ Assert = check(6i64, 1i64)

    @Test
    def monthBoundary02_months6n(): Unit \ Assert = check(-6i64, 1i64)

}
