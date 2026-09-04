// Copyright (C) 2025 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/since/float64-representable-integer.js`
/// (esid: sec-temporal.instant.prototype.since).
///
/// test262 takes a gap of 2^64 nanoseconds — more than a `Number` can name exactly — and
/// checks that `since` reports it with the precision the spec prescribes rather than with
/// whatever the implementation happens to hold internally.
///
/// The limit here is a different one, and harder: `between` answers a `Time.Duration`, which
/// is an `Int64` nanosecond count, so a gap it cannot name is not reported imprecisely but
/// not reported at all — `None`. test262's gap is well past that ceiling, so the case carries
/// over as it stands. Where exactly the ceiling falls is a question `Temporal` cannot ask, and
/// is pinned in `test/TestTime/Instant/Between.flix` instead.
///
/// 2^64 ns is 18446744073709551616 ns, which is 18446744073 seconds plus 709551616 ns.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Since.Float64RepresentableInteger {

    use TemporalHelpers.assertNoDuration
    use TemporalHelpers.epoch
    use TemporalHelpers.instant
    use Time.Instant.between

    ///
    /// test262's `i1.since(i2)` over a gap of 2^64 nanoseconds.
    ///
    /// `Int64.maxValue()` is about 9.22e18 ns, so a gap of 1.84e19 ns has no `Duration`.
    ///
    @Test
    def since01_aGapOfTwoToTheSixtyFourNanoseconds_hasNoDuration(): Unit \ Assert =
        assertNoDuration(between(epoch(), instant(18_446_744_073i64, 709_551_616)),
                         "a gap of 2^64 nanoseconds")

}
