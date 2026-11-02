///
/// The two ends of the `LocalDate` range, -9999-01-01 and 9999-12-31.
///
/// test262 names `Temporal`'s ends by parsing a string, which `LocalDate` has no form for,
/// so the claim that `min` and `max` really are those two dates is made here: their day
/// counts are checked against the harness's `epochDayOf`, which works them out through
/// ordinal dates, and their fields are read back.
///
mod TestTime.LocalDate.Range {

    use TemporalHelpers.{assertPlainDate, epochDayOf}
    use Time.LocalDate.{max, min, toEpochDay}

    @Test
    def range01_min_isMinus9999JanuaryTheFirst(): Unit \ Assert =
        assertPlainDate(min(), -9_999, 1, 1, "min")

    @Test
    def range02_max_is9999DecemberTheThirtyFirst(): Unit \ Assert =
        assertPlainDate(max(), 9_999, 12, 31, "max")

    ///
    /// The day counts spelled out, so that the two ends can be read without running
    /// anything: 4371587 days before the epoch and 2932896 after it.
    ///
    /// -9999-01-01 lies 3652425 days — 25 whole 400-year cycles — before 0001-01-01,
    /// which is day -719162.
    ///
    @Test
    def range03_theEnds_areTheseDayCounts(): Unit \ Assert = {
        Assert.assertEq(expected = (-4_371_587i64, 2_932_896i64), (toEpochDay(min()), toEpochDay(max())));
        Assert.assertEq(expected = (-4_371_587i64, 2_932_896i64), (epochDayOf(-9_999, 1, 1), epochDayOf(9_999, 12, 31)));
        Assert.assertEq(expected = -719_162i64 - 3_652_425i64, toEpochDay(min()))
    }

}
