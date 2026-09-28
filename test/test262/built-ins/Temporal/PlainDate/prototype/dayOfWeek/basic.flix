// Copyright (C) 2021 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/dayOfWeek/basic.js`
/// (esid: sec-get-temporal.plaindate.prototype.dayofweek).
///
/// The `dayOfWeek` property is a number from 1 (Monday) to 7 (Sunday). `getDayOfWeek`
/// answers a `DayOfWeek` instead, as `java.time` does, and its `getValue` is that same
/// number.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.DayOfWeek.Basic {

    use TemporalHelpers.plainDate
    use Time.DayOfWeek.getValue
    use Time.LocalDate.getDayOfWeek

    /// 1976-11-15 to 1976-11-21 run from Monday to Sunday.
    @Test
    def dayOfWeek01_basic(): Unit \ Assert =
        List.forEach(i -> {
            let d = plainDate(1976, 11, 14 + i);
            Assert.assertEqWithMsg(expected = i, getValue(getDayOfWeek(d)), "${d} should be on day ${i}")
        }, List.range(1, 8))

}
