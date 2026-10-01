// Copyright (C) 2022 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/daysInMonth/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.daysinmonth).
///
/// The `daysInMonth` property becomes `lengthOfMonth`. The dates built with the
/// constructor and with `Temporal.PlainDate.from` both become the harness's `plainDate`.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.DaysInMonth.Basic {

    use TemporalHelpers.plainDate
    use Time.LocalDate.lengthOfMonth

    @Test
    def daysInMonth01_basic(): Unit \ Assert =
        List.forEach(match (year, month, day, expected) -> {
                       let d = plainDate(year, month, day);
                       Assert.assertEqWithMsg(expected = expected, lengthOfMonth(d), "${expected} days in the month of ${d}")
                     },
                     List#{(1976, 2, 18, 29), (1976, 11, 18, 30), (1976, 12, 18, 31), (1977, 2, 18, 28),
                           (2021, 1, 15, 31), (2020, 2, 15, 29), (2000, 2, 15, 29), (2021, 2, 15, 28),
                           (2021, 3, 15, 31), (2021, 4, 15, 30), (2021, 5, 15, 31), (2021, 6, 15, 30),
                           (2021, 7, 15, 31), (2021, 8, 15, 31), (2021, 9, 15, 30), (2021, 10, 15, 31),
                           (2021, 11, 15, 30), (2021, 12, 15, 31),
                           (2019, 1, 18, 31), (2020, 2, 18, 29), (2019, 2, 18, 28), (2019, 3, 18, 31),
                           (2019, 4, 18, 30), (2019, 5, 18, 31), (2019, 6, 18, 30), (2019, 7, 18, 31),
                           (2019, 8, 18, 31), (2019, 9, 18, 30), (2019, 10, 18, 31), (2019, 11, 18, 30),
                           (2019, 12, 18, 31)})

}
