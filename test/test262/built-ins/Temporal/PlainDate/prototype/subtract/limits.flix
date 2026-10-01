// Copyright (C) 2021 Igalia, S.L.. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/prototype/subtract/limits.js`
/// (esid: sec-temporal.plaindate.prototype.subtract).
///
/// test262 steps one day past each end of `Temporal`'s range, -271821-04-19 and
/// +275760-09-13, and expects a `RangeError` with either `overflow` setting. The ends here
/// are -9999-01-01 and 9999-12-31, and `LocalDate` has no `overflow` option to vary.
/// `tryMinusDays` answers `None` where `Temporal` throws.
///
/// The `saturating` half has no counterpart in test262, since `Temporal` only has the
/// throwing form; it is here because it tests the same boundary.
///
mod Test262.BuiltIns.Temporal.PlainDate.Prototype.Subtract.Limits {

    use TemporalHelpers.{assertNoPlainDate, assertPlainDate}
    use Time.LocalDate.{max, min, saturatingMinusDays, tryMinusDays}

    /// test262: `min.subtract({ days: 1 })` throws.
    @Test
    def limits01_oneDayBeforeTheEarliestDate_isNotADate(): Unit \ Assert =
        assertNoPlainDate(tryMinusDays(min(), 1i64), "min")

    /// test262: `max.subtract({ days: -1 })` throws.
    @Test
    def limits02_oneDayAfterTheLatestDate_isNotADate(): Unit \ Assert =
        assertNoPlainDate(tryMinusDays(max(), -1i64), "max")

    @Test
    def limits03_pastEitherEnd_saturatesToThatEnd(): Unit \ Assert = {
        assertPlainDate(saturatingMinusDays(min(), 1i64), -9_999, 1, 1, "min");
        assertPlainDate(saturatingMinusDays(max(), -1i64), 9_999, 12, 31, "max")
    }

}
