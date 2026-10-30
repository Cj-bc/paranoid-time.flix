// Copyright (C) 2021 the V8 project authors. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/with/constrain-days.js`
/// (esid: sec-temporal.plaindate.prototype.with).
///
/// `with({ monthCode })` becomes `tryWithMonth`, which pulls the day of the month back to
/// the end of a short month, as `with` does by default. `java.time`'s `withMonth` only
/// does that, so the `{ overflow: "reject" }` half is not ported: the cases that throw have
/// no counterpart, and the ones that pass `reject` and succeed are the same replacements
/// as without it.
///
/// `with/constrain-day.js` is the same set of cases for the `gregory` calendar, and is not
/// ported separately.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.With.ConstrainDays {

    use TemporalHelpers.{assertSomePlainDate, plainDate}
    use Time.LocalDate.tryWithMonth

    def lastDays(februaryLength: Int32): List[(Int32, Int32)] =
        List#{(2, februaryLength), (3, 31), (4, 30), (5, 31), (6, 30), (7, 31), (8, 31),
              (9, 30), (10, 31), (11, 30), (12, 31)}

    /// test262: Common year.
    @Test
    def constrainDays01_commonYear(): Unit \ Assert =
        List.forEach(match (month, day) ->
                       assertSomePlainDate(tryWithMonth(plainDate(2019, 1, 31), month), 2019, month, day,
                                           "common-year month ${month}"),
                     lastDays(28))

    /// test262: Leap year, forwards.
    @Test
    def constrainDays02_leapYear(): Unit \ Assert =
        List.forEach(match (month, day) ->
                       assertSomePlainDate(tryWithMonth(plainDate(2016, 1, 31), month), 2016, month, day,
                                           "leap-year month ${month}"),
                     lastDays(29))

}
