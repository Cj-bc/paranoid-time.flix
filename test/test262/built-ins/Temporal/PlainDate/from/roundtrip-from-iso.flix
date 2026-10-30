// Copyright (C) 2025 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/from/roundtrip-from-iso.js`
/// (esid: sec-temporal.plaindate.from).
///
/// test262 reads a date's year, month and day back and builds the date again from them.
/// Here the date is built by the harness's `plainDate`, its fields are read back through the
/// accessors, and `tryOf` builds it again from them.
///
/// Only the year-and-month half is ported. The other half rebuilds the date from its
/// `monthCode`, which there is no counterpart for.
///
mod Test262.BuiltIns.Temporal.PlainDate.From.RoundtripFromIso {

    use TemporalHelpers.{assertSomePlainDate, plainDate}
    use Time.LocalDate.{getDayOfMonth, getMonthValue, getYear, tryOf}

    def testRoundtrip(year: Int32, month: Int32, day: Int32): Unit \ Assert = {
        let date = plainDate(year, month, day);
        assertSomePlainDate(tryOf(getYear(date), getMonthValue(date), getDayOfMonth(date)),
                            year, month, day, "${date} - created from year and month")
    }

    @Test
    def roundtripFromIso01_year2000(): Unit \ Assert = testRoundtrip(2000, 1, 1)

    @Test
    def roundtripFromIso02_year1(): Unit \ Assert = testRoundtrip(1, 1, 1)

}
