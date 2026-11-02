// Copyright (C) 2021 the V8 project authors. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/add/leap-year-arithmetic.js`
/// (esid: sec-temporal.plaindate.prototype.add).
///
/// `add` takes a `Temporal.Duration`; `LocalDate` has one `tryPlus*` per unit, answering `None`
/// where `Temporal` throws. A single-unit duration becomes a call to that unit's function.
/// One that mixes units goes through the harness's `tryAddDuration`, which adds the
/// years and months together and then the weeks and days, the order `Temporal` does.
/// The dates, parsed from strings in test262, become the harness's `plainDate`.
///
/// `add` constrains the day to the end of a short month by default, and throws instead with
/// `{ overflow: "reject" }`. `java.time` only constrains, and so does `LocalDate`, so the
/// default half comes over and the `reject` half does not: the cases that throw have no
/// counterpart, and the ones that pass `reject` and succeed are the same additions as
/// without it.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Add.LeapYearArithmetic {

    use TemporalHelpers.{assertSomePlainDate, tryAddDuration, plainDate}
    use Time.LocalDate.{tryPlusDays, tryPlusMonths, tryPlusWeeks, tryPlusYears}

    /// test262: Years.
    @Test
    def leapYearArithmetic01_years(): Unit \ Assert = {
        assertSomePlainDate(tryPlusYears(plainDate(2020, 2, 29), 1i64),
                            2021, 2, 28, "add 1y to leap day and constrain");
        assertSomePlainDate(tryPlusYears(plainDate(2020, 2, 29), 4i64),
                            2024, 2, 29, "add 4y to leap day");
        assertSomePlainDate(tryPlusYears(plainDate(2020, 2, 29), -1i64),
                            2019, 2, 28, "subtract 1y from leap day and constrain");
        assertSomePlainDate(tryPlusYears(plainDate(2020, 2, 29), -4i64),
                            2016, 2, 29, "subtract 4y from leap day")
    }

    /// test262: Months.
    @Test
    def leapYearArithmetic02_months(): Unit \ Assert = {
        assertSomePlainDate(tryPlusMonths(plainDate(2020, 1, 31), 1i64),
                            2020, 2, 29, "add 1mo to Jan 31 constrains to Feb 29 in leap year");
        assertSomePlainDate(tryPlusMonths(plainDate(2021, 9, 30), 5i64),
                            2022, 2, 28, "add 5mo with result in the next year constrained to Feb 28");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 9, 30), 5i64),
                            2020, 2, 29, "add 5mo with result in the next year constrained to Feb 29");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 12, 31), 1i64, 2i64, 0i64, 0i64),
                            2023, 2, 28, "add 1y 2mo with result in the next year constrained to Feb 28");
        assertSomePlainDate(tryAddDuration(plainDate(2022, 12, 31), 1i64, 2i64, 0i64, 0i64),
                            2024, 2, 29, "add 1y 2mo with result in the next year constrained to Feb 29");
        assertSomePlainDate(tryPlusMonths(plainDate(2020, 3, 31), -1i64),
                            2020, 2, 29, "subtract 1mo from Mar 31 constrains to Feb 29 in leap year");
        assertSomePlainDate(tryPlusMonths(plainDate(2020, 1, 31), -11i64),
                            2019, 2, 28, "subtract 11mo with result in the previous year constrained to Feb 28");
        assertSomePlainDate(tryPlusMonths(plainDate(2021, 1, 31), -11i64),
                            2020, 2, 29, "add 11mo with result in the next year constrained to Feb 29");
        assertSomePlainDate(tryAddDuration(plainDate(2022, 4, 30), -1i64, -2i64, 0i64, 0i64),
                            2021, 2, 28, "add 1y 2mo with result in the previous year constrained to Feb 28");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 4, 30), -1i64, -2i64, 0i64, 0i64),
                            2020, 2, 29, "add 1y 2mo with result in the previous year constrained to Feb 29")
    }

    /// test262: Weeks.
    @Test
    def leapYearArithmetic03_weeks(): Unit \ Assert = {
        assertSomePlainDate(tryPlusWeeks(plainDate(2021, 2, 27), 1i64),
                            2021, 3, 6, "add 1w in Feb with result in March");
        assertSomePlainDate(tryPlusWeeks(plainDate(2020, 2, 27), 1i64),
                            2020, 3, 5, "add 1w in Feb with result in March in a leap year");
        assertSomePlainDate(tryPlusWeeks(plainDate(2021, 2, 19), 6i64),
                            2021, 4, 2, "add 6w in Feb with result in the next month");
        assertSomePlainDate(tryPlusWeeks(plainDate(2020, 2, 19), 6i64),
                            2020, 4, 1, "add 6w in Feb with result in the next month in a leap year");
        assertSomePlainDate(tryPlusWeeks(plainDate(2020, 1, 27), 6i64),
                            2020, 3, 9, "add 6w with result in the same year, crossing leap day");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 28), 1i64, 0i64, 2i64, 0i64),
                            2021, 3, 14, "add 1y 2w to Feb 28 with result in March starting in leap year");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 2, 28), 1i64, 0i64, 2i64, 0i64),
                            2022, 3, 14, "add 1y 2w to Feb 28 with result in March starting in common year");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 29), 1i64, 0i64, 2i64, 0i64),
                            2021, 3, 14, "add 1y 2w to Feb 29 with result in March");
        assertSomePlainDate(tryAddDuration(plainDate(2019, 2, 28), 1i64, 0i64, 2i64, 0i64),
                            2020, 3, 13, "add 1y 2w to Feb 28 with result in March ending in leap year");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 29), 0i64, 2i64, 3i64, 0i64),
                            2020, 5, 20, "add 2mo 3w to leap day");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 28), 0i64, 2i64, 3i64, 0i64),
                            2020, 5, 19, "add 2mo 3w to Feb 28 of a leap year");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 2, 28), 0i64, 2i64, 3i64, 0i64),
                            2021, 5, 19, "add 2mo 3w to Feb 28 of a common year");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 12, 28), 0i64, 2i64, 3i64, 0i64),
                            2021, 3, 21, "add 2mo 3w from end of year crossing common-year Feb");
        assertSomePlainDate(tryAddDuration(plainDate(2019, 12, 28), 0i64, 2i64, 3i64, 0i64),
                            2020, 3, 20, "add 2mo 3w from end of year crossing leap-year Feb");
        assertSomePlainDate(tryPlusWeeks(plainDate(2021, 3, 3), -1i64),
                            2021, 2, 24, "subtract 1w in March with result in Feb");
        assertSomePlainDate(tryPlusWeeks(plainDate(2020, 3, 3), -1i64),
                            2020, 2, 25, "subtract 1w in March with result in leap-year Feb");
        assertSomePlainDate(tryPlusWeeks(plainDate(2021, 4, 2), -6i64),
                            2021, 2, 19, "subtract 6w with result in Feb");
        assertSomePlainDate(tryPlusWeeks(plainDate(2020, 4, 2), -6i64),
                            2020, 2, 20, "subtract 6w with result in leap-year Feb");
        assertSomePlainDate(tryPlusWeeks(plainDate(2020, 3, 9), -6i64),
                            2020, 1, 27, "subtract 6w with result in the same year, crossing leap day");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 3, 1), -1i64, 0i64, -2i64, 0i64),
                            2019, 2, 15, "subtract 1y 2w from Mar 1 starting in leap year");
        assertSomePlainDate(tryAddDuration(plainDate(2023, 3, 1), -1i64, 0i64, -2i64, 0i64),
                            2022, 2, 15, "subtract 1y 2w from Mar 1 starting in common year");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 29), -1i64, 0i64, -2i64, 0i64),
                            2019, 2, 14, "subtract 1y 2w from Feb 29");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 3, 1), -1i64, 0i64, -2i64, 0i64),
                            2020, 2, 16, "subtract 1y 2w from Mar 1 ending in leap year");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 29), 0i64, -2i64, -3i64, 0i64),
                            2019, 12, 8, "subtract 2mo 3w from leap day");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 3, 1), 0i64, -2i64, -3i64, 0i64),
                            2019, 12, 11, "subtract 2mo 3w from Mar 1 of a leap year");
        assertSomePlainDate(tryAddDuration(plainDate(2019, 3, 1), 0i64, -2i64, -3i64, 0i64),
                            2018, 12, 11, "subtract 2mo 3w from Mar 1 of a common year");
        assertSomePlainDate(tryAddDuration(plainDate(2019, 12, 28), 0i64, -11i64, -3i64, 0i64),
                            2019, 1, 7, "add 2mo 3w from end of year crossing common-year Feb");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 12, 28), 0i64, -11i64, -3i64, 0i64),
                            2020, 1, 7, "add 2mo 3w from end of year crossing leap-year Feb")
    }

    /// test262: Days.
    @Test
    def leapYearArithmetic04_days(): Unit \ Assert = {
        assertSomePlainDate(tryPlusDays(plainDate(2020, 2, 26), 10i64),
                            2020, 3, 7, "add 10d crossing leap day");
        assertSomePlainDate(tryPlusDays(plainDate(2021, 2, 26), 10i64),
                            2021, 3, 8, "add 10d crossing end of common-year Feb");
        assertSomePlainDate(tryPlusDays(plainDate(2020, 2, 19), 10i64),
                            2020, 2, 29, "add 10d with result on leap day");
        assertSomePlainDate(tryPlusDays(plainDate(2021, 2, 19), 10i64),
                            2021, 3, 1, "add 10d with result on common-year March 1");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 29), 0i64, 0i64, 2i64, 3i64),
                            2020, 3, 17, "add 2w 3d to leap day");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 2, 28), 0i64, 0i64, 2i64, 3i64),
                            2021, 3, 17, "add 2w 3d to end of common-year Feb");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 28), 0i64, 0i64, 2i64, 3i64),
                            2020, 3, 16, "add 2w 3d to day before leap day");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 2, 26), 1i64, 2i64, 0i64, 4i64),
                            2022, 4, 30, "add 1y 2mo 4d with result in common-year April");
        assertSomePlainDate(tryAddDuration(plainDate(2023, 2, 26), 1i64, 2i64, 0i64, 4i64),
                            2024, 4, 30, "add 1y 2mo 4d with result in leap-year April");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 12, 30), 1i64, 2i64, 0i64, 4i64),
                            2023, 3, 4, "add 1y 2mo 4d with result rolling over into common-year March");
        assertSomePlainDate(tryAddDuration(plainDate(2022, 12, 30), 1i64, 2i64, 0i64, 4i64),
                            2024, 3, 4, "add 1y 2mo 4d with result rolling over into leap-year March");
        assertSomePlainDate(tryAddDuration(plainDate(2022, 12, 29), 1i64, 2i64, 0i64, 4i64),
                            2024, 3, 4, "add 1y 2mo 4d with result rolling over into leap-year March");
        assertSomePlainDate(tryPlusDays(plainDate(2020, 3, 3), -10i64),
                            2020, 2, 22, "subtract 10d crossing leap day");
        assertSomePlainDate(tryPlusDays(plainDate(2021, 3, 3), -10i64),
                            2021, 2, 21, "subtract 10d crossing end of common-year Feb");
        assertSomePlainDate(tryPlusDays(plainDate(2020, 3, 10), -10i64),
                            2020, 2, 29, "subtract 10d with result on leap day");
        assertSomePlainDate(tryPlusDays(plainDate(2021, 3, 10), -10i64),
                            2021, 2, 28, "subtract 10d with result on common-year Feb 28");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 2, 29), 0i64, 0i64, -2i64, -3i64),
                            2020, 2, 12, "subtract 2w 3d from leap day");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 3, 1), 0i64, 0i64, -2i64, -3i64),
                            2021, 2, 12, "subtract 2w 3d from common-year Mar 1");
        assertSomePlainDate(tryAddDuration(plainDate(2020, 3, 1), 0i64, 0i64, -2i64, -3i64),
                            2020, 2, 13, "subtract 2w 3d from leap-year Mar 1");
        assertSomePlainDate(tryAddDuration(plainDate(2023, 3, 24), -1i64, -2i64, 0i64, -4i64),
                            2022, 1, 20, "subtract 1y 2mo 4d with result in common-year January");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 3, 24), -1i64, -2i64, 0i64, -4i64),
                            2020, 1, 20, "subtract 1y 2mo 4d with result in leap-year January");
        assertSomePlainDate(tryAddDuration(plainDate(2023, 5, 1), -1i64, -2i64, 0i64, -4i64),
                            2022, 2, 25, "add 1y 2mo 4d with result rolling over into common-year February");
        assertSomePlainDate(tryAddDuration(plainDate(2021, 5, 1), -1i64, -2i64, 0i64, -4i64),
                            2020, 2, 26, "add 1y 2mo 4d with result rolling over into leap-year February")
    }

}
