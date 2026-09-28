// Copyright (C) 2026 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/month/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.month).
///
/// The `month` property becomes `getMonthValue`, which is the number `java.time` gives
/// alongside its `Month` enum. `Temporal.PlainDate.from` with a string becomes the
/// harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Month.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.getMonthValue

    @Test
    def month01_basic(): Unit \ Assert = {
        Assert.assertEq(expected = 7, getMonthValue(plainDate(2021, 7, 15)));
        Assert.assertEq(expected = 3, getMonthValue(plainDate(2019, 3, 15)))
    }

}
