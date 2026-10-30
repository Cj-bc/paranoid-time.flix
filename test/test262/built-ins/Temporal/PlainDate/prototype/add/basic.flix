// Copyright (C) 2022 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/add/basic.js`
/// (esid: sec-temporal.plaindate.prototype.add).
///
/// `add` takes a `Temporal.Duration` and throws when the result is out of range;
/// `LocalDate` has one `tryPlus*` per unit, answering `None` instead. A single-unit
/// argument becomes a call to that unit's function; `Temporal.Duration.from('P43Y')` is
/// the same argument as `{ years: 43 }` and is not repeated.
///
/// The table at the bottom includes single-unit and mixed-unit durations. Single-unit
/// rows call that unit's function; mixed-unit rows go through the harness's `tryAddDuration`,
/// which adds the years and months together and then the weeks and days, the order
/// `Temporal` adds them in; its doc comment says why the order matters. The dates in the
/// table are strings in test262, and become the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Add.Basic {

    use TemporalHelpers.{assertPlainDatesEqual, assertSomePlainDate, plainDate, tryAddDuration}
    use Time.LocalDate.{tryPlusDays, tryPlusMonths, tryPlusWeeks, tryPlusYears}

    ///
    /// test262: the single-unit cases at the top of the file, one call each.
    ///
    @Test
    def add01_singleUnits_addThem(): Unit \ Assert = {
        let date = plainDate(1976, 11, 18);
        assertSomePlainDate(tryPlusYears(date, 43i64), 2019, 11, 18, "years: 43");
        assertSomePlainDate(tryPlusMonths(date, 3i64), 1977, 2, 18, "months: 3");
        assertSomePlainDate(tryPlusDays(date, 20i64), 1976, 12, 8, "days: 20");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 1, 31), 1i64), 2019, 2, 28, "2019-01-31 plus months: 1");
        assertSomePlainDate(tryPlusYears(plainDate(2019, 11, 18), -43i64), 1976, 11, 18, "years: -43");
        assertSomePlainDate(tryPlusMonths(plainDate(1977, 2, 18), -3i64), 1976, 11, 18, "months: -3");
        assertSomePlainDate(tryPlusDays(plainDate(1976, 12, 8), -20i64), 1976, 11, 18, "days: -20");
        assertSomePlainDate(tryPlusMonths(plainDate(2019, 2, 28), -1i64), 2019, 1, 28, "2019-02-28 plus months: -1")
    }

    ///
    /// test262: the `testData` table, as (date, years, months, weeks, days, expected).
    ///
    @Test
    def add02_durations_matchTheTable(): Unit \ Assert =
        List.forEach(match (y, m, d, years, months, weeks, days, ey, em, ed) -> {
            let date = plainDate(y, m, d);
            // Keep single-unit rows on their own API so the harness's conversion to
            // months and days cannot hide a defect in the year or week operations.
            let actual = match (years, months, weeks, days) {
                case (n, 0i64, 0i64, 0i64) => tryPlusYears(date, n)
                case (0i64, n, 0i64, 0i64) => tryPlusMonths(date, n)
                case (0i64, 0i64, n, 0i64) => tryPlusWeeks(date, n)
                case (0i64, 0i64, 0i64, n) => tryPlusDays(date, n)
                case _ => tryAddDuration(date, years, months, weeks, days)
            };
            assertPlainDatesEqual(expected = plainDate(ey, em, ed),
                                  actual,
                                  "${y}-${m}-${d} with (${years}, ${months}, ${weeks}, ${days})")
          },
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
