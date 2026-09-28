///
/// Helpers shared by the ported test262 cases.
///
/// This mirrors test262's own `harness/temporalHelpers.js`, which the ported files
/// pull in with an `includes: [temporalHelpers.js]` header.
///
/// The module has to be `pub` for the test files to `use` it, and Flix requires a
/// `pub mod` to sit at a path that matches its name, which is why this file is
/// `TemporalHelpers.flix` rather than the lower-case name test262 gives it.
///
/// It only plays the same role. None of the code below is taken or translated from
/// test262's harness, so this file carries no test262 copyright notice and is under this
/// repository's own licence. The ported cases beside it do carry one; see
/// `test/test262/LICENSE`.
///
pub mod TemporalHelpers {

    use Time.Duration
    use Time.Instant.Instant
    use Time.LocalDate
    use Time.LocalDate.LocalDate

    ///
    /// Builds an `Instant` from the two fields it is stored in.
    ///
    /// `Temporal.Instant` is a single signed nanosecond count, so every expectation
    /// taken from test262 has to be re-expressed as a (second, nanosecond-of-second)
    /// pair. Each ported case shows that arithmetic in its doc comment.
    ///
    pub def instant(secondsSinceEpoch: Int64, nano: Int32): Instant =
        Instant({secondsSinceEpoch = secondsSinceEpoch, nano = nano})

    /// 1970-01-01T00:00:00Z.
    pub def epoch(): Instant = instant(0i64, 0)

    ///
    /// The first day of -9999 and the last day of 9999, as whole days from the epoch in the
    /// proleptic Gregorian calendar with astronomical year numbering.
    ///
    /// These are the two dates the `Instant` range is stated against, not its ends: the ends
    /// sit one day inside them, which is what `Range.flix` checks.
    ///
    pub def dayOfMinus9999January1st(): Int64 = -4_371_588i64
    pub def dayOf9999December31st(): Int64 = 2_932_896i64

    /// The number of seconds in one day. No leap seconds are modelled.
    pub def secondsPerDay(): Int64 = 86_400i64


    /// Pair of secondsSinceEpoch and nanoseconds of largest instant that can be converted to Int64 nanoseconds
    pub def largestInstantPairToNanoseconds(): (Int64, Int32) = (9_223_372_036i64, 854_775_807)

    /// Pair of secondsSinceEpoch and nanoseconds of smallest instant that can be converted to Int64 nanoseconds
    pub def smallestInstantPairToNanoseconds(): (Int64, Int32) = (-9_223_372_037i64, 145_224_192)

    ///
    /// Stands in for test262's `new Temporal.Instant(ns)`.
    ///
    /// The split is done here rather than through `Time.Instant.ofEpochNanos`
    /// so that a case about `tryPlus` (say) does not silently depend on that function
    /// being correct. `ns` is divided towards negative infinity, which keeps the
    /// remainder — and therefore `nano` — non-negative.
    ///
    pub def fromNanos(ns: Int64): Instant =
        let q = ns / 1_000_000_000i64;
        let seconds = if (Int64.remainder(ns, 1_000_000_000i64) < 0i64) q - 1i64 else q;
        instant(seconds, Int64.truncateToInt32(Int64.modulo(ns, 1_000_000_000i64)))

    ///
    /// Exposes the two fields of `t`.
    ///
    /// `Instant` holds a record, so Flix cannot derive `ToString` for it and it cannot be
    /// handed to `Assert.assertEq` directly. Comparing the pair also reports which of the
    /// two numbers went wrong when a case fails.
    ///
    pub def parts(t: Instant): (Int64, Int32) =
        let Instant(i) = t;
        (i#secondsSinceEpoch, i#nano)

    ///
    /// The count `t` would report as `Temporal.Instant.prototype.epochMilliseconds`:
    /// whole milliseconds since the epoch, rounded towards negative infinity.
    ///
    /// Only meaningful for instants whose second count is small enough that
    /// `secondsSinceEpoch * 1000` fits in an `Int64`.
    ///
    pub def epochMilliseconds(t: Instant): Int64 =
        let (seconds, nano) = parts(t);
        seconds * 1_000i64 + Int32.toInt64(nano) / 1_000_000i64

    ///
    /// The count `t` would report as `Temporal.Instant.prototype.epochNanoseconds`.
    ///
    /// Only meaningful for instants whose distance from the epoch fits in an `Int64`,
    /// which is a far narrower range than `Instant` itself covers.
    ///
    pub def epochNanoseconds(t: Instant): Int64 =
        let (seconds, nano) = parts(t);
        seconds * 1_000_000_000i64 + Int32.toInt64(nano)

    /// test262's `TemporalHelpers.assertInstantsEqual`.
    pub def assertInstantsEqual(expected: {expected = Instant}, actual: Instant, msg: String): Unit \ Assert =
        let e = parts(expected#expected);
        let a = parts(actual);
        Assert.assertEqWithMsg(expected = e, a, "${msg}: expected ${e}, got ${a}")

    ///
    /// `assertInstantsEqual` for the `try` operations, which answer with an `Option`
    /// where `Temporal` returns the instant or throws.
    ///
    pub def assertSomeInstant(expected: {expected = Instant}, actual: Option[Instant], msg: String): Unit \ Assert =
        let e = Some(parts(expected#expected));
        let a = Option.map(parts, actual);
        Assert.assertEqWithMsg(expected = e, a, "${msg}: expected ${e}, got ${a}")

    ///
    /// Stands in for test262's `assert.throws(RangeError, ...)`.
    ///
    /// Where `Temporal` throws for a result outside the representable range, the `try`
    /// operations here answer `None` instead.
    ///
    pub def assertNoInstant(actual: Option[Instant], msg: String): Unit \ Assert =
        let a = Option.map(parts, actual);
        Assert.assertEqWithMsg(expected = None, a, "${msg}: expected None, got ${a}")

    ///
    /// The other half of test262's `assert.throws(RangeError, ...)`.
    ///
    /// The `saturating` operations answer with the nearest representable instant
    /// rather than failing, so a case that expects a `RangeError` in test262 turns
    /// into two here: `assertNoInstant` for `try`, and this one for `saturating`.
    ///
    pub def assertSaturated(expected: {expected = Instant}, actual: Instant, msg: String): Unit \ Assert =
        assertInstantsEqual(expected = expected#expected, actual, msg)

    ///
    /// test262's `TemporalHelpers.assertDurationsEqual`, for the `Option[Duration]`
    /// that `between` answers with.
    ///
    pub def assertSomeDuration(expected: {expected = Duration}, actual: Option[Duration], msg: String): Unit \ Assert =
        Assert.assertEqWithMsg(expected = Some(expected#expected), actual, "${msg}: expected ${Some(expected#expected)}, got ${actual}")

    ///
    /// `between` answers `None` for a gap too wide to fit in a `Duration`. test262 has
    /// no counterpart: `since` and `until` return an arbitrary-precision `Duration`.
    ///
    pub def assertNoDuration(actual: Option[Duration], msg: String): Unit \ Assert =
        Assert.assertEqWithMsg(expected = None, actual, "${msg}: expected None, got ${actual}")

    ///
    /// test262's `assert.sameValue(instant.epochNanoseconds, ...)`, for the
    /// `Option[Int64]` that `toEpochNanos` answers with.
    ///
    pub def assertSomeNanos(expected: {expected = Int64}, actual: Option[Int64], msg: String): Unit \ Assert =
        Assert.assertEqWithMsg(expected = Some(expected#expected), actual, "${msg}: expected ${Some(expected#expected)}, got ${actual}")

    ///
    /// `toEpochNanos` answers `None` for an instant too far from the epoch to count in an
    /// `Int64`. test262 has no counterpart: `epochNanoseconds` is an arbitrary-precision
    /// `BigInt`, so it is never out of range.
    ///
    pub def assertNoNanos(actual: Option[Int64], msg: String): Unit \ Assert =
        Assert.assertEqWithMsg(expected = None, actual, "${msg}: expected None, got ${actual}")

    //
    // PlainDate
    //

    ///
    /// The number of days from 1970-01-01 to `year`-`month`-`day` in the proleptic
    /// Gregorian calendar, worked out without `Time.LocalDate`.
    ///
    /// The date is first moved 25 whole 400-year cycles (146097 days each) forward, which
    /// puts every year from -9999 on at 1 or later, and then counted the way ordinal dates
    /// are: days in the whole years before it, in the whole months before it, and the day
    /// itself. 1970-01-01 is ordinal day 719163 when 0001-01-01 is day 1. This is a
    /// different route from the one `Time.LocalDate` takes, so a slip in one does not
    /// hide the same slip in the other.
    ///
    /// `month` and `day` must name a real date; nothing is checked.
    ///
    pub def epochDayOf(year: Int32, month: Int32, day: Int32): Int64 =
        let y = Int32.toInt64(year) + 10_000i64;
        let before = y - 1i64;
        let leap = Int64.remainder(y, 4i64) == 0i64 and
            (Int64.remainder(y, 100i64) != 0i64 or Int64.remainder(y, 400i64) == 0i64);
        let monthLengths = List#{31, if (leap) 29 else 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};
        let daysBeforeMonth = List.take(month - 1, monthLengths) |> List.sum |> Int32.toInt64;
        let ordinal = before * 365i64 + before / 4i64 - before / 100i64 + before / 400i64
            + daysBeforeMonth + Int32.toInt64(day);
        ordinal - 719_163i64 - 25i64 * 146_097i64

    ///
    /// Stands in for test262's `new Temporal.PlainDate(year, month, day)` and
    /// `Temporal.PlainDate.from("yyyy-mm-dd")`.
    ///
    /// The day count comes from `epochDayOf` rather than from `Time.LocalDate.tryOf`, so
    /// that a case about `tryPlusDays` (say) does not silently depend on that function
    /// being correct.
    ///
    pub def plainDate(year: Int32, month: Int32, day: Int32): LocalDate =
        LocalDate(epochDayOf(year, month, day))

    ///
    /// The three fields of `d` as its accessors report them, and its day count.
    ///
    pub def dateParts(d: LocalDate): (Int32, Int32, Int32, Int64) =
        (LocalDate.getYear(d), LocalDate.getMonthValue(d), LocalDate.getDayOfMonth(d), LocalDate.toEpochDay(d))

    ///
    /// test262's `TemporalHelpers.assertPlainDate`.
    ///
    /// test262 reads `year`, `month`, `monthCode` and `day` back off the result. There is
    /// one calendar and no month codes here, so what is read back is the year, the month,
    /// the day of the month and, alongside them, the day count, which is checked against
    /// `epochDayOf`. The fields catch an accessor that is wrong; the day count catches
    /// accessors that are wrong in the same way as the arithmetic that produced `actual`.
    ///
    pub def assertPlainDate(actual: LocalDate, year: Int32, month: Int32, day: Int32, msg: String): Unit \ Assert =
        let e = (year, month, day, epochDayOf(year, month, day));
        let a = dateParts(actual);
        Assert.assertEqWithMsg(expected = e, a, "${msg}: expected ${e}, got ${a}")

    ///
    /// `assertPlainDate` for the `try` operations, which answer with an `Option` where
    /// `Temporal` returns the date or throws.
    ///
    pub def assertSomePlainDate(actual: Option[LocalDate], year: Int32, month: Int32, day: Int32, msg: String): Unit \ Assert =
        let e = Some((year, month, day, epochDayOf(year, month, day)));
        let a = Option.map(dateParts, actual);
        Assert.assertEqWithMsg(expected = e, a, "${msg}: expected ${e}, got ${a}")

    /// test262's `TemporalHelpers.assertPlainDatesEqual`.
    pub def assertPlainDatesEqual(expected: {expected = LocalDate}, actual: Option[LocalDate], msg: String): Unit \ Assert =
        let e = Some(dateParts(expected#expected));
        let a = Option.map(dateParts, actual);
        Assert.assertEqWithMsg(expected = e, a, "${msg}: expected ${e}, got ${a}")

    ///
    /// Stands in for test262's `assert.throws(RangeError, ...)` around an operation that
    /// makes a `PlainDate`. The `try` operations here answer `None` instead.
    ///
    pub def assertNoPlainDate(actual: Option[LocalDate], msg: String): Unit \ Assert =
        let a = Option.map(dateParts, actual);
        Assert.assertEqWithMsg(expected = None, a, "${msg}: expected None, got ${a}")

    ///
    /// Stands in for test262's `date.add(new Temporal.Duration(years, months, weeks, days))`.
    ///
    /// `Temporal` adds the years and the months together first, pulling the day back to
    /// the end of a short month once, and then the weeks and the days. `java.time`'s
    /// `Period` does the same, and so does this: `tryPlusMonths` with the months the years
    /// and months come to, then `tryPlusDays` with the days the weeks and days come to.
    /// Adding the years and the months separately is not the same thing — 2020-02-29 plus
    /// one year is pulled back to 2021-02-28 before the months are added.
    ///
    pub def tryAddDuration(d: LocalDate, years: Int64, months: Int64, weeks: Int64, days: Int64): Option[LocalDate] =
        LocalDate.tryPlusMonths(d, years * 12i64 + months)
            |> Option.flatMap(x -> LocalDate.tryPlusDays(x, weeks * 7i64 + days))

    ///
    /// Stands in for test262's `date.subtract(new Temporal.Duration(years, months, weeks, days))`,
    /// which is `add` with the duration negated: the months first, then the days, both
    /// through the `minus` forms.
    ///
    pub def trySubtractDuration(d: LocalDate, years: Int64, months: Int64, weeks: Int64, days: Int64): Option[LocalDate] =
        LocalDate.tryMinusMonths(d, years * 12i64 + months)
            |> Option.flatMap(x -> LocalDate.tryMinusDays(x, weeks * 7i64 + days))

}
