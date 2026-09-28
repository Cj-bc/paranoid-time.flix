// Copyright (C) 2022 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/subtract/basic.js`
/// (esid: sec-temporal.plaindate.prototype.subtract).
///
/// `subtract` takes a `Temporal.Duration` and throws when the result is out of range;
/// `LocalDate` has one `tryMinus*` per unit, answering `None` instead. A single-unit
/// argument becomes a call to that unit's function; `Temporal.Duration.from('P43Y')` is
/// the same argument as `{ years: 43 }` and is not repeated.
///
/// The table at the bottom is the one in `add/basic.js`, subtracted negated. Those go
/// through the harness's `trySubtractDuration`, which subtracts the years and months
/// together and then the weeks and days, the order `Temporal` subtracts them in. The
/// dates in the table are strings in test262, and become the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Subtract.Basic {

    use TemporalHelpers.{assertPlainDatesEqual, assertSomePlainDate, plainDate, trySubtractDuration}
    use Time.LocalDate.{tryMinusDays, tryMinusMonths, tryMinusYears}

    ///
    /// test262: the single-unit cases at the top of the file, one call each.
    ///
    @Test
    def subtract01_singleUnits_subtractThem(): Unit \ Assert = {
        let date = plainDate(2019, 11, 18);
        assertSomePlainDate(tryMinusYears(date, 43i64), 1976, 11, 18, "years: 43");
        assertSomePlainDate(tryMinusMonths(date, 11i64), 2018, 12, 18, "months: 11");
        assertSomePlainDate(tryMinusDays(date, 20i64), 2019, 10, 29, "days: 20");
        assertSomePlainDate(tryMinusMonths(plainDate(2019, 2, 28), 1i64), 2019, 1, 28, "2019-02-28 minus months: 1");
        assertSomePlainDate(tryMinusYears(plainDate(1976, 11, 18), -43i64), 2019, 11, 18, "years: -43");
        assertSomePlainDate(tryMinusMonths(plainDate(2018, 12, 18), -11i64), 2019, 11, 18, "months: -11");
        assertSomePlainDate(tryMinusDays(plainDate(2019, 10, 29), -20i64), 2019, 11, 18, "days: -20");
        assertSomePlainDate(tryMinusMonths(plainDate(2019, 1, 28), -1i64), 2019, 2, 28, "2019-01-28 minus months: -1")
    }

    ///
    /// test262: the `testData` table, as (date, years, months, weeks, days, expected).
    ///
    @Test
    def subtract02_mixedUnits_matchTheTable(): Unit \ Assert =
        List.forEach(match (y, m, d, years, months, weeks, days, ey, em, ed) ->
            assertPlainDatesEqual(expected = plainDate(ey, em, ed),
                                  trySubtractDuration(plainDate(y, m, d), -years, -months, -weeks, -days),
                                  "${y}-${m}-${d} with (${years}, ${months}, ${weeks}, ${days})"),
          List#{
            (2020, 2, 29, 1i64, 0i64, 0i64, 0i64, 2021, 2, 28),
            (2020, 2, 29, 4i64, 0i64, 0i64, 0i64, 2024, 2, 29),
            (2021, 7, 16, 1i64, 0i64, 0i64, 0i64, 2022, 7, 16),
            (2021, 7, 16, 0i64, 5i64, 0i64, 0i64, 2021, 12, 16),
            (2021, 8, 16, 0i64, 5i64, 0i64, 0i64, 2022, 1, 16),
            (2021, 10, 31, 0i64, 5i64, 0i64, 0i64, 2022, 3, 31),
            (2021, 9, 30, 0i64, 5i64, 0i64, 0i64, 2022, 2, 28),
            (2019, 9, 30, 0i64, 5i64, 0i64, 0i64, 2020, 2, 29),
            (2019, 10, 1, 0i64, 5i64, 0i64, 0i64, 2020, 3, 1),
            (2021, 7, 16, 1i64, 2i64, 0i64, 0i64, 2022, 9, 16),
            (2021, 11, 30, 1i64, 2i64, 0i64, 0i64, 2023, 1, 30),
            (2021, 12, 31, 1i64, 2i64, 0i64, 0i64, 2023, 2, 28),
            (2022, 12, 31, 1i64, 2i64, 0i64, 0i64, 2024, 2, 29),
            (2021, 7, 16, 1i64, 0i64, 0i64, 4i64, 2022, 7, 20),
            (2021, 2, 27, 1i64, 0i64, 0i64, 4i64, 2022, 3, 3),
            (2023, 2, 27, 1i64, 0i64, 0i64, 4i64, 2024, 3, 2),
            (2021, 12, 30, 1i64, 0i64, 0i64, 4i64, 2023, 1, 3),
            (2021, 7, 30, 1i64, 0i64, 0i64, 4i64, 2022, 8, 3),
            (2021, 6, 30, 1i64, 0i64, 0i64, 4i64, 2022, 7, 4),
            (2021, 7, 16, 1i64, 2i64, 0i64, 4i64, 2022, 9, 20),
            (2021, 2, 27, 1i64, 2i64, 0i64, 4i64, 2022, 5, 1),
            (2021, 2, 26, 1i64, 2i64, 0i64, 4i64, 2022, 4, 30),
            (2023, 2, 26, 1i64, 2i64, 0i64, 4i64, 2024, 4, 30),
            (2021, 12, 30, 1i64, 2i64, 0i64, 4i64, 2023, 3, 4),
            (2021, 7, 30, 1i64, 2i64, 0i64, 4i64, 2022, 10, 4),
            (2021, 6, 30, 1i64, 2i64, 0i64, 4i64, 2022, 9, 3),
            (2021, 7, 16, 0i64, 0i64, 0i64, 10i64, 2021, 7, 26),
            (2021, 7, 26, 0i64, 0i64, 0i64, 10i64, 2021, 8, 5),
            (2021, 12, 26, 0i64, 0i64, 0i64, 10i64, 2022, 1, 5),
            (2020, 2, 26, 0i64, 0i64, 0i64, 10i64, 2020, 3, 7),
            (2021, 2, 26, 0i64, 0i64, 0i64, 10i64, 2021, 3, 8),
            (2020, 2, 19, 0i64, 0i64, 0i64, 10i64, 2020, 2, 29),
            (2021, 2, 19, 0i64, 0i64, 0i64, 10i64, 2021, 3, 1),
            (2021, 2, 19, 0i64, 0i64, 1i64, 0i64, 2021, 2, 26),
            (2021, 2, 27, 0i64, 0i64, 1i64, 0i64, 2021, 3, 6),
            (2020, 2, 27, 0i64, 0i64, 1i64, 0i64, 2020, 3, 5),
            (2021, 12, 24, 0i64, 0i64, 1i64, 0i64, 2021, 12, 31),
            (2021, 12, 27, 0i64, 0i64, 1i64, 0i64, 2022, 1, 3),
            (2021, 1, 27, 0i64, 0i64, 1i64, 0i64, 2021, 2, 3),
            (2021, 6, 27, 0i64, 0i64, 1i64, 0i64, 2021, 7, 4),
            (2021, 7, 27, 0i64, 0i64, 1i64, 0i64, 2021, 8, 3),
            (2021, 2, 19, 0i64, 0i64, 6i64, 0i64, 2021, 4, 2),
            (2021, 2, 27, 0i64, 0i64, 6i64, 0i64, 2021, 4, 10),
            (2020, 2, 27, 0i64, 0i64, 6i64, 0i64, 2020, 4, 9),
            (2021, 12, 24, 0i64, 0i64, 6i64, 0i64, 2022, 2, 4),
            (2021, 12, 27, 0i64, 0i64, 6i64, 0i64, 2022, 2, 7),
            (2021, 1, 27, 0i64, 0i64, 6i64, 0i64, 2021, 3, 10),
            (2021, 6, 27, 0i64, 0i64, 6i64, 0i64, 2021, 8, 8),
            (2021, 7, 27, 0i64, 0i64, 6i64, 0i64, 2021, 9, 7),
            (2020, 2, 29, 0i64, 0i64, 2i64, 3i64, 2020, 3, 17),
            (2020, 2, 28, 0i64, 0i64, 2i64, 3i64, 2020, 3, 16),
            (2021, 2, 28, 0i64, 0i64, 2i64, 3i64, 2021, 3, 17),
            (2020, 12, 28, 0i64, 0i64, 2i64, 3i64, 2021, 1, 14),
            (2020, 2, 29, 1i64, 0i64, 2i64, 0i64, 2021, 3, 14),
            (2020, 2, 28, 1i64, 0i64, 2i64, 0i64, 2021, 3, 14),
            (2021, 2, 28, 1i64, 0i64, 2i64, 0i64, 2022, 3, 14),
            (2020, 12, 28, 1i64, 0i64, 2i64, 0i64, 2022, 1, 11),
            (2020, 2, 29, 0i64, 2i64, 3i64, 0i64, 2020, 5, 20),
            (2020, 2, 28, 0i64, 2i64, 3i64, 0i64, 2020, 5, 19),
            (2021, 2, 28, 0i64, 2i64, 3i64, 0i64, 2021, 5, 19),
            (2020, 12, 28, 0i64, 2i64, 3i64, 0i64, 2021, 3, 21),
            (2019, 12, 28, 0i64, 2i64, 3i64, 0i64, 2020, 3, 20),
            (2019, 10, 28, 0i64, 2i64, 3i64, 0i64, 2020, 1, 18),
            (2019, 10, 31, 0i64, 2i64, 3i64, 0i64, 2020, 1, 21)
          })

}
