// Copyright (C) 2025 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262
/// `test/built-ins/Temporal/Instant/prototype/subtract/blank-duration.js`
/// (esid: sec-temporal.instant.prototype.subtract).
///
/// `new Temporal.Duration()` with no arguments is the zero duration; `Duration.zero()` here.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Subtract.BlankDuration {

    use TemporalHelpers.assertSomeInstant
    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use Time.Duration
    use Time.Instant.trySub

    /// test262: `new Temporal.Instant(1n).subtract(new Temporal.Duration())` is unchanged.
    @Test
    def subtract01_theZeroDuration_leavesTheInstantUnchanged(): Unit \ Assert =
        assertSomeInstant(expected = instant(0i64, 1), trySub(fromNanos(1i64), Duration.zero()),
                          "result is unchanged")

}
