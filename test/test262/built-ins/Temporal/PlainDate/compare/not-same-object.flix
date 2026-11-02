// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/compare/not-same-object.js`
/// (esid: sec-temporal.plaindate.compare).
///
/// `Temporal.PlainDate.compare` becomes `Order[LocalDate]`, and its 0 becomes `EqualTo`.
/// `LocalDate` is a value, so "the same object" is the same value passed twice.
///
mod Test262.BuiltIns.Temporal.PlainDate.Compare.NotSameObject {

    use TemporalHelpers.plainDate

    @Test
    def notSameObject01_equalDates_compareEqual(): Unit \ Assert = {
        let date1 = plainDate(1914, 2, 23);
        let date2 = plainDate(1914, 2, 23);
        Assert.assertEqWithMsg(expected = Comparison.EqualTo, Order.compare(date1, date1), "same object");
        Assert.assertEqWithMsg(expected = Comparison.EqualTo, Order.compare(date1, date2), "same date")
    }

}
