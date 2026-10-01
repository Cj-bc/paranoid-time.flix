// Copyright (C) 2021 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/dayOfYear/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.dayofyear).
///
/// The `dayOfYear` property becomes `getDayOfYear`. `Temporal.PlainDate.from` with a
/// string becomes the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.DayOfYear.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.getDayOfYear

    @Test
    def dayOfYear01_aWeekInNovember(): Unit \ Assert =
        List.forEach(i -> {
            let d = plainDate(1976, 11, 14 + i);
            Assert.assertEqWithMsg(expected = 319 + i, getDayOfYear(d), "${d} should be on day ${319 + i}")
        }, List.range(1, 8))

    @Test
    def dayOfYear02_basic(): Unit \ Assert =
        List.forEach(match (year, month, day, expected) ->
                       Assert.assertEqWithMsg(expected = expected, getDayOfYear(plainDate(year, month, day)),
                                              "${year}-${month}-${day}"),
                     List#{(1970, 1, 1, 1), (2000, 1, 1, 1), (2021, 1, 15, 15), (2020, 2, 15, 46),
                           (2000, 2, 15, 46), (2020, 3, 15, 75), (2000, 3, 15, 75), (2001, 3, 15, 74),
                           (2000, 12, 31, 366), (2001, 12, 31, 365), (2019, 1, 18, 18),
                           (2020, 2, 18, 49), (2019, 12, 31, 365), (2000, 12, 31, 366)})

}
