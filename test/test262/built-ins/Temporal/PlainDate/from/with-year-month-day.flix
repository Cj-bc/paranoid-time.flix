// Copyright (C) 2021 the V8 project authors. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/from/with-year-month-day.js`
/// (esid: sec-temporal.plaindate.from).
///
/// `Temporal.PlainDate.from` with a `{year, month, day}` bag becomes `tryOf`.
///
mod Test262.BuiltIns.Temporal.PlainDate.From.WithYearMonthDay {

    use TemporalHelpers.assertSomePlainDate
    use Time.LocalDate.tryOf

    @Test
    def withYearMonthDay01_basic(): Unit \ Assert =
        assertSomePlainDate(tryOf(2021, 7, 15), 2021, 7, 15, "year/month/day")

}
