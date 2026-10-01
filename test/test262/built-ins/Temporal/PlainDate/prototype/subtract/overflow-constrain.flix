// Copyright (C) 2022 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/subtract/overflow-constrain.js`
/// (esid: sec-temporal.plaindate.prototype.subtract).
///
/// `{ overflow: "constrain" }` is what `tryMinusMonths` always does, so the option is
/// dropped. Its `reject` counterpart, `overflow-reject.js`, has none here.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Subtract.OverflowConstrain {

    use TemporalHelpers.{assertSomePlainDate, plainDate}
    use Time.LocalDate.tryMinusMonths

    @Test
    def overflowConstrain01_marchTheThirtyFirstMinusAMonth_isTheLastDayOfFebruary(): Unit \ Assert =
        assertSomePlainDate(tryMinusMonths(plainDate(2020, 3, 31), 1i64), 2020, 2, 29, "mar31 minus months: 1")

}
