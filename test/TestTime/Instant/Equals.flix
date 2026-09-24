///
/// Tests for the hand-written `Eq[Instant]` instance that test262 has no counterpart for.
///
/// `Temporal.Instant` is a single signed nanosecond count, so it has no second field that a
/// hand-written comparison could forget to look at.
///
/// The instant builders come from the test262 harness rather than being written out again here.
///
mod TestTime.Instant.Equals {

    use TemporalHelpers.instant

    /// Instants sharing a `nano` are still told apart by their second count.
    @Test
    def equals01_instantsDifferingInTheSecondAlone_areNotEqual(): Unit \ Assert =
        Assert.assertFalseWithMsg(instant(1_234_567_890i64, 123_456_789) == instant(1_234_567_891i64, 123_456_789),
                                  "instants one second apart are equal")

}
