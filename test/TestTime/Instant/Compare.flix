///
/// Tests for the hand-written `Order[Instant]` instance that test262 has no counterpart for.
///
/// `Temporal.Instant` is a single signed nanosecond count, so nothing over there can be said
/// about how a second field and a nanosecond field are weighed against each other, nor about
/// instants outside the representable range — constructing one already throws.
///
/// The instant builders and assertions come from the test262 harness rather than being
/// written out again here.
///
mod TestTime.Instant.Compare {

    use TemporalHelpers.{instant, parts}
    use Time.Instant.{max, min}

    /// The seconds decide first, and a larger `nano` never makes up for a smaller second.
    @Test
    def compare01_aLargerNanoUnderASmallerSecond_isStillLessThan(): Unit \ Assert = {
        Assert.assertEq(expected = Comparison.LessThan,
                        Order.compare(instant(3i64, 999_999_999), instant(4i64, 0)));
        Assert.assertEq(expected = Comparison.GreaterThan,
                        Order.compare(instant(4i64, 0), instant(3i64, 999_999_999)))
    }

    /// `nano` decides when the seconds agree.
    @Test
    def compare02_theSameSecond_isDecidedByTheNano(): Unit \ Assert =
        Assert.assertEq(expected = Comparison.LessThan,
                        Order.compare(instant(3i64, 1), instant(3i64, 2)))

    ///
    /// The two ends of the range bound `Order` as well, so no instant sorts outside them.
    ///
    /// The two inner instants are derived from the ends rather than written out, so that the
    /// case says which side of an end it means to be on and by how much.
    ///
    @Test
    def compare03_everyInstant_sortsBetweenTheTwoEnds(): Unit \ Assert = {
        let (earliestSecond, _) = parts(min());
        let (latestSecond, _) = parts(max());
        Assert.assertTrue(min() < instant(0i64, 0));
        Assert.assertTrue(instant(0i64, 0) < max());
        Assert.assertTrue(min() < instant(earliestSecond, 1));
        Assert.assertTrue(instant(latestSecond, 999_999_998) < max())
    }

}
