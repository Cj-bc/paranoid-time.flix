// Copyright (C) 2025 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/add/overflow-adding-months-to-max-year.js`
/// (esid: sec-temporal.plaindate.prototype.add).
///
/// test262 adds 5432 months and 5432 weeks to the first day of `Temporal`'s last year,
/// 275760, and the negated duration to its earliest date, and expects both to throw. The
/// same claim is restated against this library's ends: the first day of 9999, and
/// -9999-01-01. The duration goes through the harness's `tryAddDuration`, which answers
/// `None` where `Temporal` throws.
///
/// The `saturating` half has no counterpart in test262; it is here because it tests the
/// same boundary. The months alone already leave the range, so that is what it is given.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Add.OverflowAddingMonthsToMaxYear {

    use TemporalHelpers.{assertNoPlainDate, assertPlainDate, plainDate, tryAddDuration}
    use Time.LocalDate.{min, saturatingPlusMonths}

    @Test
    def overflowAddingMonthsToMaxYear01_pastEitherEnd_isNotADate(): Unit \ Assert = {
        assertNoPlainDate(tryAddDuration(plainDate(9_999, 1, 1), 0i64, 5_432i64, 5_432i64, 0i64), "maxYear");
        assertNoPlainDate(tryAddDuration(min(), 0i64, -5_432i64, -5_432i64, 0i64), "minYear")
    }

    @Test
    def overflowAddingMonthsToMaxYear02_pastEitherEnd_saturatesToThatEnd(): Unit \ Assert = {
        assertPlainDate(saturatingPlusMonths(plainDate(9_999, 1, 1), 5_432i64), 9_999, 12, 31, "maxYear");
        assertPlainDate(saturatingPlusMonths(min(), -5_432i64), -9_999, 1, 1, "minYear")
    }

}
