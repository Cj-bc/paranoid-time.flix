// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/basic.js`
/// (esid: sec-temporal.plaindate).
///
/// `new Temporal.PlainDate(y, m, d, "iso8601")` becomes `tryOf(y, m, d)`, which answers
/// `Some` for a real date. The `calendarId` assertion is not ported: there is one calendar
/// and nothing to name it by.
///
mod Test262.BuiltIns.Temporal.PlainDate.Basic {

    use TemporalHelpers.assertSomePlainDate
    use Time.LocalDate.tryOf

    @Test
    def basic01_aRealDate_isBuiltFromItsFields(): Unit \ Assert =
        assertSomePlainDate(tryOf(2020, 12, 24), 2020, 12, 24, "with string")

}
