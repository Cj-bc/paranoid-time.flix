///
/// Ported from test262 `test/built-ins/Temporal/Instant/prototype/equals/basic.js`
/// (esid: sec-temporal.instant.prototype.equals).
///
/// The counterpart of `Temporal.Instant.prototype.equals` is the hand-written `Eq[Instant]`
/// instance. test262's three nanosecond counts are restated as the pairs they denote:
///
///   1234567890123456789n -> (1234567890, 123456789)
///   1234567890123456000n -> (1234567890, 123456000)
///
/// The two differ only below the microsecond, so they share a second count and are told
/// apart by `nano` alone.
///
mod Test262.BuiltIns.Temporal.Instant.Prototype.Equals.Basic {

    use TemporalHelpers.fromNanos
    use TemporalHelpers.instant
    use Time.Instant.Instant

    def inst1(): Instant = fromNanos(1_234_567_890_123_456_789i64)

    def inst2(): Instant = fromNanos(1_234_567_890_123_456_000i64)

    def inst3(): Instant = fromNanos(1_234_567_890_123_456_000i64)

    /// test262: `assert(!inst1.equals(inst2))`.
    @Test
    def equals01_instantsDifferingInTheNanoAlone_areNotEqual(): Unit \ Assert =
        Assert.assertFalseWithMsg(inst1() == inst2(), "inst1 equals inst2")

    /// test262: `assert(inst2.equals(inst3))`.
    @Test
    def equals02_instantsBuiltFromTheSameCount_areEqual(): Unit \ Assert =
        Assert.assertTrueWithMsg(inst2() == inst3(), "inst2 equals inst3")

}
