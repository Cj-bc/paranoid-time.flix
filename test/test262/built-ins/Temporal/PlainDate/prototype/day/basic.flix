// Copyright (C) 2026 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/day/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.day).
///
/// The `day` property becomes `getDayOfMonth`. `Temporal.PlainDate.from` with a string
/// becomes the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Day.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.getDayOfMonth

    @Test
    def day01_basic(): Unit \ Assert = {
        Assert.assertEq(expected = 15, getDayOfMonth(plainDate(2021, 7, 15)));
        Assert.assertEq(expected = 18, getDayOfMonth(plainDate(2019, 3, 18)))
    }

}
