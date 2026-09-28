// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/equals/basic.js`
/// (esid: sec-temporal.plaindate.protoype.equals).
///
/// `equals` becomes both `Eq[LocalDate]` and `isEqual`, which `java.time` spells out as a
/// method of its own.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Equals.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.isEqual

    @Test
    def equals01_basic(): Unit \ Assert = {
        let date1 = plainDate(1976, 11, 18);
        let date2 = plainDate(1914, 2, 23);
        let date3 = plainDate(1914, 2, 23);
        Assert.assertEqWithMsg(expected = (false, false), (date1 == date2, isEqual(date1, date2)), "different dates");
        Assert.assertEqWithMsg(expected = (true, true), (date2 == date3, isEqual(date2, date3)), "same dates");
        Assert.assertEqWithMsg(expected = (true, true), (date2 == date2, isEqual(date2, date2)), "same objects")
    }

}
