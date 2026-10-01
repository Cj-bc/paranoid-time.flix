// Copyright (C) 2025 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/subtract/basic-arithmetic.js`
/// (esid: sec-temporal.plaindate.prototype.subtract).
///
/// `subtract` takes a `Temporal.Duration`; `LocalDate` has one `tryMinus*` per unit, answering `None`
/// where `Temporal` throws. A single-unit duration becomes a call to that unit's function.
/// One that mixes units goes through the harness's `trySubtractDuration`, which subtracts the
/// years and months together and then the weeks and days, the order `Temporal` does.
/// The round trips (`calculatedStart`) chain the two calls. The dates, built from
/// property bags in test262, become the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Subtract.BasicArithmetic {

    use TemporalHelpers.{assertSomePlainDate, trySubtractDuration, plainDate}
    use Time.LocalDate.{tryMinusDays, tryMinusMonths, tryMinusWeeks, tryMinusYears}

    /// test262: Years.
    @Test
    def basicArithmetic01_years(): Unit \ Assert = {
        assertSomePlainDate(tryMinusYears(plainDate(2021, 7, 16), -1i64),
                            2022, 7, 16, "add 1y");
        assertSomePlainDate(tryMinusYears(plainDate(2021, 7, 16), -4i64),
                            2025, 7, 16, "add 4y");
        assertSomePlainDate(tryMinusYears(plainDate(2021, 7, 16), 1i64),
                            2020, 7, 16, "subtract 1y");
        assertSomePlainDate(tryMinusYears(plainDate(2021, 7, 16), 4i64),
                            2017, 7, 16, "subtract 4y");
        assertSomePlainDate(trySubtractDuration(plainDate(1997, 12, 1), -3i64, -6i64, 0i64, -17i64),
                            2001, 6, 18, "add 3y6m17d");
        assertSomePlainDate(trySubtractDuration(plainDate(1997, 12, 1), -3i64, -6i64, 0i64, -17i64) |> Option.flatMap(x -> trySubtractDuration(x, 3i64, 6i64, 0i64, 17i64)),
                            1997, 12, 1, "subtract 3y6m17d")
    }

    /// test262: Months.
    @Test
    def basicArithmetic02_months(): Unit \ Assert = {
        assertSomePlainDate(tryMinusMonths(plainDate(2021, 7, 16), -5i64),
                            2021, 12, 16, "add 5mo with result in the same year");
        assertSomePlainDate(tryMinusMonths(plainDate(2021, 8, 16), -5i64),
                            2022, 1, 16, "add 5mo with result in the next year");
        assertSomePlainDate(tryMinusMonths(plainDate(2019, 10, 1), -5i64),
                            2020, 3, 1, "add 5mo with result in the next year on day 1 of month");
        assertSomePlainDate(tryMinusMonths(plainDate(2021, 10, 31), -5i64),
                            2022, 3, 31, "add 5mo with result in the next year on day 31 of month");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 7, 16), -1i64, -2i64, 0i64, 0i64),
                            2022, 9, 16, "add 1y 2mo");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 11, 30), -1i64, -2i64, 0i64, 0i64),
                            2023, 1, 30, "add 1y 2mo with result in the next year");
        assertSomePlainDate(tryMinusMonths(plainDate(2021, 7, 16), 5i64),
                            2021, 2, 16, "subtract 5mo with result in the same year");
        assertSomePlainDate(tryMinusMonths(plainDate(2021, 1, 16), 5i64),
                            2020, 8, 16, "subtract 5mo with result in the previous year");
        assertSomePlainDate(tryMinusMonths(plainDate(2019, 2, 1), 5i64),
                            2018, 9, 1, "subtract 5mo with result in the previous year on day 1 of month");
        assertSomePlainDate(tryMinusMonths(plainDate(2021, 3, 31), 5i64),
                            2020, 10, 31, "subtract 5mo with result in the previous year on day 31 of month");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 7, 16), 1i64, 2i64, 0i64, 0i64),
                            2020, 5, 16, "subtract 1y 2mo");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 2, 17), 1i64, 2i64, 0i64, 0i64),
                            2019, 12, 17, "subtract 1y 2mo with result in the previous year");
        assertSomePlainDate(tryMinusMonths(plainDate(2000, 12, 1), -6i64),
                            2001, 6, 1, "subtract 6mo");
        assertSomePlainDate(tryMinusMonths(plainDate(2000, 12, 1), -6i64) |> Option.flatMap(x -> tryMinusMonths(x, 6i64)),
                            2000, 12, 1, "subtract 6mo")
    }

    /// test262: Weeks.
    @Test
    def basicArithmetic03_weeks(): Unit \ Assert = {
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 2, 19), -1i64),
                            2021, 2, 26, "add 1w");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 12, 24), -1i64),
                            2021, 12, 31, "add 1w with result on the last day of the year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 12, 25), -1i64),
                            2022, 1, 1, "add 1w with result on the first day of the next year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 1, 27), -1i64),
                            2021, 2, 3, "add 1w in a 31-day month with result in the next month");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 7, 27), -1i64),
                            2021, 8, 3, "add 1w in another 31-day month with result in the next month");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 6, 27), -1i64),
                            2021, 7, 4, "add 1w in a 30-day month with result in the next month");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 1, 27), -6i64),
                            2021, 3, 10, "add 6w with result in the same year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 12, 24), -6i64),
                            2022, 2, 4, "add 6w with result in the next year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 6, 27), -6i64),
                            2021, 8, 8, "add 6w crossing months of 30 and 31 days");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 7, 27), -6i64),
                            2021, 9, 7, "add 6w crossing months of 31 and 31 days");
        assertSomePlainDate(trySubtractDuration(plainDate(2020, 12, 28), -1i64, 0i64, -2i64, 0i64),
                            2022, 1, 11, "add 1y 2w with result in the next year");
        assertSomePlainDate(trySubtractDuration(plainDate(2019, 10, 28), 0i64, -2i64, -3i64, 0i64),
                            2020, 1, 18, "add 2mo 3w with result in the next year");
        assertSomePlainDate(trySubtractDuration(plainDate(2019, 10, 31), 0i64, -2i64, -3i64, 0i64),
                            2020, 1, 21, "add 2mo 3w with result in the next year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 2, 19), 1i64),
                            2021, 2, 12, "subtract 1w");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 1, 8), 1i64),
                            2021, 1, 1, "subtract 1w with result on the first day of the year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 1, 7), 1i64),
                            2020, 12, 31, "subtract 1w with result on the last day of the previous year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 6, 4), 1i64),
                            2021, 5, 28, "subtract 1w with result in the previous 31-day month");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 7, 3), 1i64),
                            2021, 6, 26, "subtract 1w with result in the previous 30-day month");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 6, 4), 6i64),
                            2021, 4, 23, "subtract 6w with result in the same year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 1, 27), 6i64),
                            2020, 12, 16, "subtract 6w with result in the previous year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 9, 8), 6i64),
                            2021, 7, 28, "subtract 6w crossing months of 30 and 31 days");
        assertSomePlainDate(tryMinusWeeks(plainDate(2021, 8, 8), 6i64),
                            2021, 6, 27, "subtract 6w crossing months of 31 and 31 days");
        assertSomePlainDate(trySubtractDuration(plainDate(2022, 1, 5), 1i64, 0i64, 2i64, 0i64),
                            2020, 12, 22, "subtract 1y 2w with result in the previous year");
        assertSomePlainDate(trySubtractDuration(plainDate(2019, 3, 2), 0i64, 2i64, 3i64, 0i64),
                            2018, 12, 12, "subtract 2mo 3w with result in the previous year");
        assertSomePlainDate(tryMinusWeeks(plainDate(2000, 1, 1), -40i64),
                            2000, 10, 7, "add 40w");
        assertSomePlainDate(tryMinusWeeks(plainDate(2000, 1, 1), -40i64) |> Option.flatMap(x -> tryMinusWeeks(x, 40i64)),
                            2000, 1, 1, "subtract 40w")
    }

    /// test262: Days.
    @Test
    def basicArithmetic04_days(): Unit \ Assert = {
        assertSomePlainDate(tryMinusDays(plainDate(2021, 7, 16), -10i64),
                            2021, 7, 26, "add 10 days with result in the same month");
        assertSomePlainDate(tryMinusDays(plainDate(2021, 7, 26), -10i64),
                            2021, 8, 5, "add 10 days with result in the next month");
        assertSomePlainDate(tryMinusDays(plainDate(2021, 12, 26), -10i64),
                            2022, 1, 5, "add 10 days with result in the next year");
        assertSomePlainDate(trySubtractDuration(plainDate(2020, 12, 28), 0i64, 0i64, -2i64, -3i64),
                            2021, 1, 14, "add 2w 3d with result in the next year");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 7, 16), -1i64, -2i64, 0i64, -4i64),
                            2022, 9, 20, "add 1y 2mo 4d");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 2, 27), -1i64, -2i64, 0i64, -4i64),
                            2022, 5, 1, "add 1y 2mo 4d with result in a month following a 30-day month");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 7, 30), -1i64, -2i64, 0i64, -4i64),
                            2022, 10, 4, "add 1y 2mo 4d with result in a month following a 30-day month");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 1, 28), -1i64, -2i64, 0i64, -4i64),
                            2022, 4, 1, "add 1y 2mo 4d with result in a month following a 31-day month");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 6, 30), -1i64, -2i64, 0i64, -4i64),
                            2022, 9, 3, "add 1y 2mo 4d with result in a month following a 31-day month");
        assertSomePlainDate(tryMinusDays(plainDate(2021, 7, 16), 10i64),
                            2021, 7, 6, "subtract 10 days with result in the same month");
        assertSomePlainDate(tryMinusDays(plainDate(2021, 7, 6), 10i64),
                            2021, 6, 26, "subtract 10 days with result in the previous month");
        assertSomePlainDate(tryMinusDays(plainDate(2021, 1, 4), 10i64),
                            2020, 12, 25, "subtract 10 days with result in the previous year");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 1, 15), 0i64, 0i64, 2i64, 3i64),
                            2020, 12, 29, "subtract 2w 3d with result in the previous year");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 7, 16), 1i64, 2i64, 0i64, 4i64),
                            2020, 5, 12, "subtract 1y 2mo 4d");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 7, 4), 1i64, 2i64, 0i64, 4i64),
                            2020, 4, 30, "subtract 1y 2mo 4d with result in a 30-day month");
        assertSomePlainDate(trySubtractDuration(plainDate(2021, 6, 4), 1i64, 2i64, 0i64, 4i64),
                            2020, 3, 31, "subtract 1y 2mo 4d with result in a 31-day month");
        assertSomePlainDate(tryMinusDays(plainDate(2000, 1, 1), -280i64),
                            2000, 10, 7, "add 280d");
        assertSomePlainDate(tryMinusDays(plainDate(2000, 1, 1), -280i64) |> Option.flatMap(x -> tryMinusDays(x, 280i64)),
                            2000, 1, 1, "subtract 280d")
    }

}
