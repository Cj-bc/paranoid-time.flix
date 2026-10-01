// Copyright (C) 2025 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/with/leap-year.js`
/// (esid: sec-temporal.plaindate.prototype.with).
///
/// `with({ year })` becomes `tryWithYear`, which pulls a leap day back to February 28 in a
/// common year, as `with` does by default. `java.time`'s `withYear` only does that, so the
/// case that expects `{ overflow: "reject" }` to throw is not ported.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.With.LeapYear {

    use TemporalHelpers.{assertSomePlainDate, plainDate}
    use Time.LocalDate.tryWithYear

    @Test
    def leapYear01_toAnotherLeapYear_keepsTheLeapDay(): Unit \ Assert =
        assertSomePlainDate(tryWithYear(plainDate(2016, 2, 29), 2012), 2012, 2, 29,
                            "day not constrained when moving to another leap year")

    @Test
    def leapYear02_toACommonYear_constrainsTheLeapDay(): Unit \ Assert =
        assertSomePlainDate(tryWithYear(plainDate(2016, 2, 29), 2018), 2018, 2, 28,
                            "day constrained when moving to a common year")

}
