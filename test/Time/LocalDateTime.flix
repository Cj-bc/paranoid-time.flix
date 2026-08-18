mod Time.LocalDateTimeTest {
    use Time.LocalDateTime.LocalDateTime

    @Test
    def testSecondAtEpoch(): Unit \ Assert =
        Assert.assertEq(expected = 0, Time.LocalDateTime.second(LocalDateTime.LocalDateTime(0i64)))

    @Test
    def testSecondKnownInstant(): Unit \ Assert =
        // 2024-03-15T13:45:30Z
        Assert.assertEq(expected = 30, Time.LocalDateTime.second(LocalDateTime.LocalDateTime(1710510330000i64)))

    @Test
    def testSecondIgnoresSubSecondMillis(): Unit \ Assert =
        // 2024-03-15T13:45:30.999Z
        Assert.assertEq(expected = 30, Time.LocalDateTime.second(LocalDateTime.LocalDateTime(1710510330999i64)))

    @Test
    def testMinuteAtEpoch(): Unit \ Assert =
        Assert.assertEq(expected = 0, Time.LocalDateTime.minute(LocalDateTime.LocalDateTime(0i64)))

    @Test
    def testMinuteKnownInstant(): Unit \ Assert =
        // 2024-03-15T13:45:30Z
        Assert.assertEq(expected = 45, Time.LocalDateTime.minute(LocalDateTime.LocalDateTime(1710510330000i64)))

    @Test
    def testMinuteRollover(): Unit \ Assert =
        // 00:01:01
        Assert.assertEq(expected = 1, Time.LocalDateTime.minute(LocalDateTime.LocalDateTime(61000i64)))

    @Test
    def testHourAtEpoch(): Unit \ Assert =
        Assert.assertEq(expected = 0, Time.LocalDateTime.hour(LocalDateTime.LocalDateTime(0i64)))

    @Test
    def testHourKnownInstant(): Unit \ Assert =
        // 2024-03-15T13:45:30Z
        Assert.assertEq(expected = 13, Time.LocalDateTime.hour(LocalDateTime.LocalDateTime(1710510330000i64)))

    @Test
    def testHourBeforeEpoch(): Unit \ Assert =
        // 1969-12-31T23:59:59Z
        Assert.assertEq(expected = 23, Time.LocalDateTime.hour(LocalDateTime.LocalDateTime(-1000i64)))

    @Test
    def testYearMonthDayAtEpoch(): Unit \ Assert = {
        let d = LocalDateTime.LocalDateTime(0i64);
        Assert.assertEq(expected = 1970, Time.LocalDateTime.year(d));
        Assert.assertEq(expected = 1, Time.LocalDateTime.month(d));
        Assert.assertEq(expected = 1, Time.LocalDateTime.dayOfMonth(d))
    }

    @Test
    def testYearMonthDayKnownInstant(): Unit \ Assert = {
        // 2024-03-15T13:45:30Z
        let d = LocalDateTime.LocalDateTime(1710510330000i64);
        Assert.assertEq(expected = 2024, Time.LocalDateTime.year(d));
        Assert.assertEq(expected = 3, Time.LocalDateTime.month(d));
        Assert.assertEq(expected = 15, Time.LocalDateTime.dayOfMonth(d))
    }

    @Test
    def testLeapDay(): Unit \ Assert = {
        // 2000-02-29T00:00:00Z (leap year divisible by 400)
        let d = LocalDateTime.LocalDateTime(951782400000i64);
        Assert.assertEq(expected = 2000, Time.LocalDateTime.year(d));
        Assert.assertEq(expected = 2, Time.LocalDateTime.month(d));
        Assert.assertEq(expected = 29, Time.LocalDateTime.dayOfMonth(d))
    }

    @Test
    def testBeforeEpochDate(): Unit \ Assert = {
        // 1969-07-20T20:17:00Z
        let d = LocalDateTime.LocalDateTime(-14182980000i64);
        Assert.assertEq(expected = 1969, Time.LocalDateTime.year(d));
        Assert.assertEq(expected = 7, Time.LocalDateTime.month(d));
        Assert.assertEq(expected = 20, Time.LocalDateTime.dayOfMonth(d))
    }

    @Test
    def testCenturyNonLeapYear(): Unit \ Assert = {
        // 1900-01-01T00:00:00Z (not a leap year: divisible by 100 but not 400)
        let d = LocalDateTime.LocalDateTime(-2208988800000i64);
        Assert.assertEq(expected = 1900, Time.LocalDateTime.year(d));
        Assert.assertEq(expected = 1, Time.LocalDateTime.month(d));
        Assert.assertEq(expected = 1, Time.LocalDateTime.dayOfMonth(d))
    }
}
