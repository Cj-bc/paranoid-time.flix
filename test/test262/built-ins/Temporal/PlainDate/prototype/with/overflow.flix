// Copyright (C) 2025 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/with/overflow.js`
/// (esid: sec-temporal.plaindate.prototype.with).
///
/// `with({ year })`, `with({ month })` and `with({ day })` become `tryWithYear`,
/// `tryWithMonth` and `tryWithDayOfMonth`, which answer `None` where `with` throws.
///
/// Two cases part company with test262. `with` constrains a month above 12 to 12, and a
/// day past the end of the month to its last day, unless given `{ overflow: "reject" }`.
/// `java.time`'s `withMonth` and `withDayOfMonth` reject both, and so do the functions
/// here; the claim that comes over is the `reject` one.
///
/// The `monthCode` cases are not ported: there are no month codes here.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.With.Overflow {

    use TemporalHelpers.{assertNoPlainDate, plainDate}
    use Time.LocalDate.{tryWithDayOfMonth, tryWithMonth, tryWithYear}

    ///
    /// test262: a year of -300000 or 300000 throws even with `constrain`.
    ///
    /// Both are outside this library's range too. So is the year just past each end of it,
    /// which is the boundary the claim is about here.
    ///
    @Test
    def overflow01_aYearOutsideTheRange_isRejected(): Unit \ Assert = {
        let date = plainDate(1976, 11, 18);
        assertNoPlainDate(tryWithYear(date, -300_000), "too-low year");
        assertNoPlainDate(tryWithYear(date, 300_000), "too-high year");
        assertNoPlainDate(tryWithYear(date, -10_000), "the year before -9999");
        assertNoPlainDate(tryWithYear(date, 10_000), "the year after 9999")
    }

    /// test262: month 0 throws even with `constrain`, and month 13 throws with `reject`.
    @Test
    def overflow02_aMonthOutsideTheYear_isRejected(): Unit \ Assert = {
        let date = plainDate(1976, 11, 18);
        assertNoPlainDate(tryWithMonth(date, 0), "non-positive month");
        assertNoPlainDate(tryWithMonth(date, 13), "too-high month")
    }

    /// test262: day 0 throws even with `constrain`, and day 31 of November throws with `reject`.
    @Test
    def overflow03_aDayOutsideTheMonth_isRejected(): Unit \ Assert = {
        let date = plainDate(1976, 11, 18);
        assertNoPlainDate(tryWithDayOfMonth(date, 0), "non-positive day");
        assertNoPlainDate(tryWithDayOfMonth(date, 31), "too-high day")
    }

}
