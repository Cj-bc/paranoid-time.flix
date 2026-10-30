///
/// Tests for `isBefore`, `isAfter` and `isEqual`, which `java.time` has and `Temporal` does
/// not: there, `compare` and `equals` cover them, and those are ported under
/// `test/test262` as `Order[LocalDate]` and `Eq[LocalDate]`.
///
mod TestTime.LocalDate.Compare {

    use TemporalHelpers.plainDate
    use Time.LocalDate.{isAfter, isBefore, isEqual, max, min}

    @Test
    def compare01_twoDifferentDates(): Unit \ Assert = {
        let earlier = plainDate(-1, 12, 31);
        let later = plainDate(0, 1, 1);
        Assert.assertEq(expected = (true, false, false), (isBefore(earlier, later), isAfter(earlier, later), isEqual(earlier, later)));
        Assert.assertEq(expected = (false, true, false), (isBefore(later, earlier), isAfter(later, earlier), isEqual(later, earlier)))
    }

    @Test
    def compare02_theSameDate(): Unit \ Assert = {
        let d = plainDate(2000, 2, 29);
        Assert.assertEq(expected = (false, false, true), (isBefore(d, d), isAfter(d, d), isEqual(d, d)))
    }

    @Test
    def compare03_theEnds(): Unit \ Assert =
        Assert.assertEq(expected = (true, true), (isBefore(min(), max()), isAfter(max(), min())))

}
