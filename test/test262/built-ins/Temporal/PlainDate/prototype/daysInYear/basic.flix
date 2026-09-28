// Copyright (C) 2022 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/daysInYear/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.daysinyear).
///
/// The `daysInYear` property becomes `lengthOfYear`. The dates built with the constructor
/// and with `Temporal.PlainDate.from` both become the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.DaysInYear.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.lengthOfYear

    @Test
    def daysInYear01_basic(): Unit \ Assert = {
        Assert.assertEqWithMsg(expected = 366, lengthOfYear(plainDate(1976, 11, 18)), "leap year");
        Assert.assertEqWithMsg(expected = 365, lengthOfYear(plainDate(1977, 11, 18)), "non-leap year");
        List.forEach(match (year, expected) ->
                       Assert.assertEqWithMsg(expected = expected, lengthOfYear(plainDate(year, 7, 15)), "${year}-07-15"),
                     List#{(1995, 365), (1996, 366), (1997, 365), (1998, 365), (1999, 365), (2000, 366),
                           (2001, 365), (2002, 365), (2003, 365), (2004, 366), (2005, 365)});
        List.forEach(match (year, expected) ->
                       Assert.assertEqWithMsg(expected = expected, lengthOfYear(plainDate(year, 3, 18)), "${year}-03-18"),
                     List#{(2019, 365), (2020, 366), (2021, 365), (2022, 365), (2023, 365), (2024, 366),
                           (2025, 365), (2026, 365)})
    }

}
