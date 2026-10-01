// Copyright (C) 2025 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/subtract/overflow-subtracting-months-from-min-year.js`
/// (esid: sec-temporal.plaindate.prototype.subtract).
///
/// test262 subtracts 5432 months and 5432 weeks from `Temporal`'s earliest date, and the
/// negated duration from the first day of its last year, 275760, and expects both to
/// throw. The same claim is restated against this library's ends: -9999-01-01, and the
/// first day of 9999. The duration goes through the harness's `trySubtractDuration`, which
/// answers `None` where `Temporal` throws.
///
/// The `saturating` half has no counterpart in test262; it is here because it tests the
/// same boundary. The months alone already leave the range, so that is what it is given.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Subtract.OverflowSubtractingMonthsFromMinYear {

    use TemporalHelpers.{assertNoPlainDate, assertPlainDate, plainDate, trySubtractDuration}
    use Time.LocalDate.{min, saturatingMinusMonths}

    @Test
    def overflowSubtractingMonthsFromMinYear01_pastEitherEnd_isNotADate(): Unit \ Assert = {
        assertNoPlainDate(trySubtractDuration(min(), 0i64, 5_432i64, 5_432i64, 0i64), "minYear");
        assertNoPlainDate(trySubtractDuration(plainDate(9_999, 1, 1), 0i64, -5_432i64, -5_432i64, 0i64), "maxYear")
    }

    @Test
    def overflowSubtractingMonthsFromMinYear02_pastEitherEnd_saturatesToThatEnd(): Unit \ Assert = {
        assertPlainDate(saturatingMinusMonths(min(), 5_432i64), -9_999, 1, 1, "minYear");
        assertPlainDate(saturatingMinusMonths(plainDate(9_999, 1, 1), -5_432i64), 9_999, 12, 31, "maxYear")
    }

}
