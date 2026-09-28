// Copyright (C) 2026 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/year/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.year).
///
/// The `year` property becomes `getYear`. `Temporal.PlainDate.from` with a string becomes
/// the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Year.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.getYear

    @Test
    def year01_basic(): Unit \ Assert = {
        Assert.assertEq(expected = 2021, getYear(plainDate(2021, 7, 15)));
        Assert.assertEq(expected = 2019, getYear(plainDate(2019, 3, 15)))
    }

}
