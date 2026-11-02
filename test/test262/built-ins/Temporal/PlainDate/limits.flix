// Copyright 2021 the V8 project authors. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/limits.js`
/// (esid: sec-temporal.plaindate).
///
/// The constructor becomes `tryOf`, and a `RangeError` becomes `None`.
///
/// test262 pins the year limits at -271821-04-19 and 275760-09-13, the dates of
/// `Temporal`'s own range. The range here is the four-digit year range,
/// -9999-01-01 to 9999-12-31, so the "Year limits" half is restated against those two
/// dates: each end is a date, and the day beyond it is not. The "Monthday limits" half
/// comes over unchanged.
///
mod Test262.BuiltIns.Temporal.PlainDate.Limits {

    use TemporalHelpers.{assertNoPlainDate, assertSomePlainDate}
    use Time.LocalDate.tryOf

    /// test262: `new Temporal.PlainDate(-271821, 4, 18)` and `(275760, 9, 14)` throw.
    @Test
    def limits01_theDayBeyondEitherEnd_isNotADate(): Unit \ Assert = {
        assertNoPlainDate(tryOf(-10_000, 12, 31), "min");
        assertNoPlainDate(tryOf(10_000, 1, 1), "max")
    }

    /// test262: `new Temporal.PlainDate(-271821, 4, 19)` and `(275760, 9, 13)` are fine.
    @Test
    def limits02_eitherEnd_isADate(): Unit \ Assert = {
        assertSomePlainDate(tryOf(-9_999, 1, 1), -9_999, 1, 1, "min");
        assertSomePlainDate(tryOf(9_999, 12, 31), 9_999, 12, 31, "max")
    }

    /// test262: the last day of every month of 2021, and 2004-02-29.
    @Test
    def limits03_theLastDayOfEachMonth_isADate(): Unit \ Assert = {
        let lastDays = List#{(1, 31), (2, 28), (3, 31), (4, 30), (5, 31), (6, 30),
                             (7, 31), (8, 31), (9, 30), (10, 31), (11, 30), (12, 31)};
        List.forEach(match (month, day) -> assertSomePlainDate(tryOf(2021, month, day), 2021, month, day, "2021-${month}-${day}"), lastDays);
        assertSomePlainDate(tryOf(2004, 2, 29), 2004, 2, 29, "2004-02-29")
    }

    /// test262: February 29 of a common year throws.
    @Test
    def limits04_februaryTheTwentyNinthOfACommonYear_isNotADate(): Unit \ Assert =
        List.forEach(year -> assertNoPlainDate(tryOf(year, 2, 29), "${year}-02-29"),
                     List#{1900, 2001, 2002, 2003, 2100})

    /// test262: the day after the last day of every month of 2021 throws.
    @Test
    def limits05_theDayAfterTheLastDayOfEachMonth_isNotADate(): Unit \ Assert =
        List.forEach(match (month, day) -> assertNoPlainDate(tryOf(2021, month, day), "2021-${month}-${day}"),
                     List#{(1, 32), (2, 29), (3, 32), (4, 31), (5, 32), (6, 31),
                           (7, 32), (8, 32), (9, 31), (10, 32), (11, 31), (12, 32)})

}
