// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/compare/basic.js`
/// (esid: sec-temporal.plaindate.compare).
///
/// `Temporal.PlainDate.compare` becomes `Order[LocalDate]`, and its -1, 0 and 1 become
/// `LessThan`, `EqualTo` and `GreaterThan`. `Temporal.PlainDate.from` with a string
/// becomes the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Compare.Basic {

    use TemporalHelpers.plainDate

    @Test
    def compare01_basic(): Unit \ Assert = {
        let d1 = plainDate(1976, 11, 18);
        let d2 = plainDate(2019, 6, 30);
        let d3 = plainDate(2019, 6, 30);
        Assert.assertEqWithMsg(expected = Comparison.EqualTo, Order.compare(d1, d1), "same object");
        Assert.assertEqWithMsg(expected = Comparison.LessThan, Order.compare(d1, d2), "earlier");
        Assert.assertEqWithMsg(expected = Comparison.GreaterThan, Order.compare(d2, d1), "later");
        Assert.assertEqWithMsg(expected = Comparison.EqualTo, Order.compare(d2, d3), "same date")
    }

}
