// Copyright (C) 2021 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/toString/basic.js`
/// (esid: sec-temporal.plaindate.protoype.tostring).
///
/// `toString()` becomes `ToString[LocalDate]`. For a year from 0 to 9999 the ISO-8601 form
/// `Temporal` writes and the one `java.time` writes are the same, so the expected strings
/// come over unchanged.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.ToString.Basic {

    use TemporalHelpers.plainDate

    @Test
    def toString01_basic(): Unit \ Assert = {
        Assert.assertEq(expected = "1976-11-18", ToString.toString(plainDate(1976, 11, 18)));
        Assert.assertEq(expected = "1914-02-23", ToString.toString(plainDate(1914, 2, 23)));
        Assert.assertEq(expected = "1996-02-29", ToString.toString(plainDate(1996, 2, 29)))
    }

}
