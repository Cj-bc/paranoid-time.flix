// Copyright (C) 2025 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/from/negative-month-or-day.js`
/// (esid: sec-temporal.plaindate.from).
///
/// `Temporal.PlainDate.from` with a property bag becomes `tryOf`, and a `RangeError`
/// becomes `None`.
///
mod Test262.BuiltIns.Temporal.PlainDate.From.NegativeMonthOrDay {

    use TemporalHelpers.assertNoPlainDate
    use Time.LocalDate.tryOf

    @Test
    def negativeMonthOrDay01_aNegativeMonthOrDay_isNotADate(): Unit \ Assert = {
        assertNoPlainDate(tryOf(2000, -1, 1), "month -1");
        assertNoPlainDate(tryOf(2000, 1, -1), "day -1")
    }

}
