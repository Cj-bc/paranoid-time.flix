// Copyright (C) 2025 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/add/blank-duration.js`
/// (esid: sec-temporal.plaindate.prototype.add).
///
/// The blank `Temporal.Duration` is zero of every unit. `LocalDate` has one `tryPlus*` per
/// unit, so each of them is given zero.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Add.BlankDuration {

    use TemporalHelpers.{assertSomePlainDate, plainDate}
    use Time.LocalDate.{tryPlusDays, tryPlusMonths, tryPlusWeeks, tryPlusYears}

    @Test
    def blankDuration01_zeroOfEveryUnit_leavesTheDateUnchanged(): Unit \ Assert = {
        let d = plainDate(2025, 8, 22);
        assertSomePlainDate(tryPlusYears(d, 0i64), 2025, 8, 22, "years: result is unchanged");
        assertSomePlainDate(tryPlusMonths(d, 0i64), 2025, 8, 22, "months: result is unchanged");
        assertSomePlainDate(tryPlusWeeks(d, 0i64), 2025, 8, 22, "weeks: result is unchanged");
        assertSomePlainDate(tryPlusDays(d, 0i64), 2025, 8, 22, "days: result is unchanged")
    }

}
