// Copyright (C) 2021 the V8 project authors. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.LocalDate; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/PlainDate/from/out-of-range.js`
/// (esid: sec-temporal.plaindate.from).
///
/// `Temporal.PlainDate.from` with a `{year, month, day}` bag becomes `tryOf`, and a
/// `RangeError` becomes `None`. `tryOf` only ever rejects, so the cases test262 runs with
/// `{ overflow: "reject" }` and the two it runs with the default come over alike.
///
/// Not ported: the `monthCode` cases, since there are no month codes here, and the
/// `-Infinity` ones, which cannot be written as an `Int32`.
///
mod Test262.BuiltIns.Temporal.PlainDate.From.OutOfRange {

    use TemporalHelpers.assertNoPlainDate
    use Time.LocalDate.tryOf

    def check(cases: List[(Int32, Int32)], msg: String): Unit \ Assert =
        List.forEach(match (month, day) ->
                       assertNoPlainDate(tryOf(2021, month, day), "${msg}: month=${month}, day=${day}"),
                     cases)

    /// test262: `month: -1` and `day: -17`.
    @Test
    def outOfRange01_aNegativeMonthOrDay_isNotADate(): Unit \ Assert =
        check(List#{(-1, 17), (7, -17)}, "negative")

    /// test262: the `{year, month, day}` cases with `{ overflow: "reject" }`.
    @Test
    def outOfRange02_noSuchMonthOrDay_isNotADate(): Unit \ Assert =
        check(List#{(12, 0), (12, 32), (1, 32), (2, 29), (6, 31), (9, 31), (0, 5), (13, 5),
                    (3, 32), (4, 31), (5, 32), (7, 32), (8, 32), (10, 32), (11, 31)},
              "reject")

    /// test262: day 0 and month 0 throw even with the default `overflow`.
    @Test
    def outOfRange03_dayZeroOrMonthZero_isNotADate(): Unit \ Assert =
        check(List#{(12, 0), (0, 3)}, "default overflow")

}
