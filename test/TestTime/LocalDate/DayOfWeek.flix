///
/// Tests for `Time.DayOfWeek`, which `Temporal` has no counterpart for: its `dayOfWeek` is
/// a plain number.
///
mod TestTime.LocalDate.DayOfWeek {

    use Time.DayOfWeek.{DayOfWeek, getValue, tryOf}

    @Test
    def dayOfWeek01_tryOf_undoesGetValue(): Unit \ Assert =
        List.forEach(n -> Assert.assertEqWithMsg(expected = Some(n), tryOf(n) |> Option.map(getValue), "${n}"),
                     List.range(1, 8))

    @Test
    def dayOfWeek02_mondayIsOne_andSundayIsSeven(): Unit \ Assert =
        Assert.assertEq(expected = (1, 7), (getValue(DayOfWeek.Monday), getValue(DayOfWeek.Sunday)))

    @Test
    def dayOfWeek03_outsideOneToSeven_isNone(): Unit \ Assert = {
        Assert.assertEq(expected = None, tryOf(0));
        Assert.assertEq(expected = None, tryOf(8))
    }

    @Test
    def dayOfWeek04_orderFollowsTheValue(): Unit \ Assert =
        Assert.assertTrue(DayOfWeek.Monday < DayOfWeek.Tuesday and DayOfWeek.Saturday < DayOfWeek.Sunday)

}
