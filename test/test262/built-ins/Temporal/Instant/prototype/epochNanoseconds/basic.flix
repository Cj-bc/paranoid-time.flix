// Copyright (C) 2021 Igalia, S.L. All rights reserved.
// This code is governed by the BSD license found in test/test262/LICENSE.
// Adapted for Time.Instant; the module doc comment says what changed.
///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/epochNanoseconds/basic.js`
/// (esid: sec-get-temporal.instant.prototype.epochnanoseconds).
///
/// `Temporal.Instant` already holds the nanosecond count that `epochNanoseconds` reads,
/// so over there the property is a plain read of the field. Here it is a computation:
/// the two fields have to be recombined, so both of test262's values are restated as a
/// (second, nanosecond-of-second) pair on the way in.
///
/// The count is a `BigInt` in test262 and an `Int64` here, so `toEpochNanos` answers an
/// `Option` where the property cannot fail. Both values below are far inside the `Int64`
/// range and answer `Some`; the range itself is `test/TestTime/Instant/ToEpochNanos.flix`.
///
/// test262's two `typeof` assertions are not carried over — Flix checks the type at
/// compile time.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.EpochNanoseconds.Basic {

    use TemporalHelpers.assertSomeNanos
    use TemporalHelpers.instant
    use Time.Instant.toEpochNanos

    ///
    /// test262: `new Temporal.Instant(217175010_123_456_789n).epochNanoseconds` is
    /// `217175010_123_456_789n`.
    ///
    /// 217175010123456789 ns is 217175010 whole seconds plus 123456789 ns.
    ///
    @Test
    def toEpochNanos01_afterTheEpoch_recombinesTheTwoFields(): Unit \ Assert =
        assertSomeNanos(expected = 217_175_010_123_456_789i64,
                        toEpochNanos(instant(217_175_010i64, 123_456_789)),
                        "epochNanoseconds post epoch")

    ///
    /// test262: `new Temporal.Instant(-217175010_876_543_211n).epochNanoseconds` is
    /// `-217175010_876_543_211n`.
    ///
    /// `nano` stays non-negative before the epoch, so the same count is held as
    /// -217175011 seconds plus 123456789 ns:
    /// -217175011000000000 + 123456789 = -217175010876543211.
    ///
    @Test
    def toEpochNanos02_beforeTheEpoch_carriesTheBorrowedSecondBack(): Unit \ Assert =
        assertSomeNanos(expected = -217_175_010_876_543_211i64,
                        toEpochNanos(instant(-217_175_011i64, 123_456_789)),
                        "epochNanoseconds pre epoch")

}
