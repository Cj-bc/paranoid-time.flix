// Copyright (C) 2022 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/inLeapYear/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.inleapyear).
///
/// The `inLeapYear` property becomes `isLeapYear`. The dates built with the constructor
/// and with `Temporal.PlainDate.from` both become the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.InLeapYear.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.isLeapYear

    @Test
    def inLeapYear01_basic(): Unit \ Assert = {
        Assert.assertEqWithMsg(expected = true, isLeapYear(plainDate(1976, 11, 18)), "leap year");
        Assert.assertEqWithMsg(expected = false, isLeapYear(plainDate(1977, 11, 18)), "non-leap year");
        List.forEach(match (year, expected) ->
                       Assert.assertEqWithMsg(expected = expected, isLeapYear(plainDate(year, 7, 15)), "${year}-07-15"),
                     List#{(1995, false), (1996, true), (1997, false), (1998, false), (1999, false),
                           (2000, true), (2001, false), (2002, false), (2003, false), (2004, true),
                           (2005, false)});
        List.forEach(match (year, expected) ->
                       Assert.assertEqWithMsg(expected = expected, isLeapYear(plainDate(year, 3, 18)), "${year}-03-18"),
                     List#{(2019, false), (2020, true), (2021, false), (2022, false), (2023, false),
                           (2024, true), (2025, false), (2026, false)})
    }

}
