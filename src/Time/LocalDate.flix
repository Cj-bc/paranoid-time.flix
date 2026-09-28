pub mod Time.LocalDate {
  use Time.DayOfWeek
  use Time.DayOfWeek.DayOfWeek

  ///
  /// A date without a time-zone in the ISO-8601 calendar system, such as 2007-12-03.
  ///
  /// It is stored as the number of days since the epoch day 1970-01-01, which is day 0.
  /// Every date has exactly one day count, so the derived `Eq` and `Order` are equality
  /// and order in time.
  ///
  /// The calendar is the proleptic Gregorian one — today's leap year rules applied to all
  /// time — with astronomical year numbering: the year before 1 is 0, and the one before
  /// that is -1.
  ///
  /// Not every day count is a valid `LocalDate`. The representable range runs from
  /// -9999-01-01 to 9999-12-31, the four-digit year range; see `min` and `max`.
  /// Every operation here either stays inside it or reports that it could not. The
  /// constructor is public, so a count outside the range can still be built directly;
  /// the arithmetic stays exact for such a value, but the field accessors
  /// (`getYear`, `getMonthValue` and the rest) are only meaningful inside the range.
  ///
  pub enum LocalDate(Int64) with Eq, Order, Hash

  ///
  /// Formats `d` as `uuuu-MM-dd`, the way `java.time.LocalDate.toString` does.
  ///
  /// The year is written with at least four digits and a leading `-` when it is
  /// negative, so -1 is `-0001` and 0 is `0000`. A year above 9999 would take a leading
  /// `+`; only a value built directly outside the range can have one.
  ///
  instance ToString[LocalDate] {
    pub def toString(d: LocalDate): String =
      let (year, month, day) = fields(d);
      let sign = if (year < 0i64) "-" else if (9_999i64 < year) "+" else "";
      let pad = (w, n) -> String.padLeft(w, '0', Int64.toString(n));
      "${sign}${pad(4, Int64.abs(year))}-${pad(2, Int32.toInt64(month))}-${pad(2, Int32.toInt64(day))}"
  }

  /// The smallest year a `LocalDate` can have.
  def minYear(): Int64 = -9_999i64

  /// The largest year a `LocalDate` can have.
  def maxYear(): Int64 = 9_999i64

  ///
  /// The earliest representable `LocalDate`: -9999-01-01.
  ///
  /// `Instant` stops one day short of the four-digit year range at each end, so that a
  /// UTC offset can be applied without leaving it. A `LocalDate` has no offset to apply,
  /// so it takes the whole range.
  ///
  /// -9999-01-01 is 4371587 days before the epoch.
  ///
  pub def min(): LocalDate = LocalDate(-4_371_587i64)

  ///
  /// The latest representable `LocalDate`: 9999-12-31.
  ///
  /// 9999-12-31 is 2932896 days after the epoch.
  ///
  pub def max(): LocalDate = LocalDate(2_932_896i64)

  /// Returns `x / n` rounded towards negative infinity. `n` must be positive.
  def floorDiv(x: Int64, n: Int64): Int64 =
    let q = x / n;
    if (Int64.remainder(x, n) < 0i64) q - 1i64 else q

  ///
  /// Returns `d` when it is within the representable range, otherwise `Err` with the end it
  /// lies outside of.
  ///
  def checkRange(d: LocalDate): Result[LocalDate, LocalDate] =
    if (max() < d) Err(max())
    else if (d < min()) Err(min())
    else Ok(d)

  /// Returns the `Ok` or the `Err` side of `r`, whichever it holds.
  def either(r: Result[LocalDate, LocalDate]): LocalDate = match r {
    case Ok(v)  => v
    case Err(v) => v
  }

  /// Returns true if `year` is a leap year in the proleptic Gregorian calendar.
  def isLeap(year: Int64): Bool =
    Int64.modulo(year, 4i64) == 0i64 and
      (Int64.modulo(year, 100i64) != 0i64 or Int64.modulo(year, 400i64) == 0i64)

  /// Returns the number of days in `month` of `year`. `month` must be in [1, 12].
  def daysInMonth(year: Int64, month: Int32): Int32 = match month {
    case 2 => if (isLeap(year)) 29 else 28
    case 4 => 30
    case 6 => 30
    case 9 => 30
    case 11 => 30
    case _ => 31
  }

  ///
  /// Returns the day count of `year`-`month`-`day`, without regard for the representable
  /// range. `month` must be in [1, 12] and `day` in [1, 31].
  ///
  /// This is Howard Hinnant's `days_from_civil`: the year is taken to start in March, so
  /// that the leap day is the last day of it, and is counted in 400-year eras of 146097
  /// days each.
  ///
  def daysFromCivil(year: Int64, month: Int32, day: Int32): Int64 =
    let y = if (month <= 2) year - 1i64 else year;
    let era = floorDiv(y, 400i64);
    // Year of era, in [0, 399].
    let yoe = y - era * 400i64;
    // Month counted from March, in [0, 11].
    let mp = Int32.toInt64(if (month > 2) month - 3 else month + 9);
    // Day of the year starting in March, in [0, 365].
    let doy = (153i64 * mp + 2i64) / 5i64 + Int32.toInt64(day) - 1i64;
    // Day of era, in [0, 146096].
    let doe = yoe * 365i64 + yoe / 4i64 - yoe / 100i64 + doy;
    // 719468 is the day count of 0000-03-01, the first day of the era the epoch is in.
    era * 146_097i64 + doe - 719_468i64

  ///
  /// Returns the (year, month, day) that `d` falls on. The inverse of `daysFromCivil`.
  ///
  /// Only valid for day counts small enough that adding 719468 to them does not
  /// overflow, which every count in the representable range is by far.
  ///
  def fields(d: LocalDate): (Int64, Int32, Int32) =
    let LocalDate(epochDay) = d;
    let z = epochDay + 719_468i64;
    let era = floorDiv(z, 146_097i64);
    // Day of era, in [0, 146096].
    let doe = z - era * 146_097i64;
    // Year of era, in [0, 399].
    let yoe = (doe - doe / 1_460i64 + doe / 36_524i64 - doe / 146_096i64) / 365i64;
    // Day of the year starting in March, in [0, 365].
    let doy = doe - (365i64 * yoe + yoe / 4i64 - yoe / 100i64);
    // Month counted from March, in [0, 11].
    let mp = (5i64 * doy + 2i64) / 153i64;
    let day = Int64.truncateToInt32(doy - (153i64 * mp + 2i64) / 5i64 + 1i64);
    let month = Int64.truncateToInt32(if (mp < 10i64) mp + 3i64 else mp - 9i64);
    let year = yoe + era * 400i64 + (if (month <= 2) 1i64 else 0i64);
    (year, month, day)

  ///
  /// Returns the `LocalDate` of `year`-`month`-`day`, or `None` when that is not a date
  /// in the representable range.
  ///
  def ofFields(year: Int64, month: Int32, day: Int32): Option[LocalDate] =
    if (year < minYear() or maxYear() < year) None
    else if (month < 1 or 12 < month) None
    else if (day < 1 or daysInMonth(year, month) < day) None
    else Some(LocalDate(daysFromCivil(year, month, day)))

  ///
  /// Returns the `LocalDate` of `year`-`month`-`dayOfMonth`, or `None` when there is no
  /// such date in the representable range.
  ///
  /// `month` runs from 1 (January) to 12 (December). `dayOfMonth` has to exist in that
  /// month of that year: 2021-02-29 is `None`, not 2021-03-01 or 2021-02-28.
  ///
  pub def tryOf(year: Int32, month: Int32, dayOfMonth: Int32): Option[LocalDate] =
    ofFields(Int32.toInt64(year), month, dayOfMonth)

  ///
  /// Returns the `LocalDate` that is day `dayOfYear` of `year`, or `None` when there is no
  /// such date in the representable range.
  ///
  /// `dayOfYear` runs from 1 to 365, or to 366 in a leap year.
  ///
  pub def tryOfYearDay(year: Int32, dayOfYear: Int32): Option[LocalDate] =
    let y = Int32.toInt64(year);
    if (y < minYear() or maxYear() < y) None
    else if (dayOfYear < 1 or lengthOfYearOf(y) < dayOfYear) None
    else Some(LocalDate(daysFromCivil(y, 1, 1) + Int32.toInt64(dayOfYear) - 1i64))

  ///
  /// Returns the `LocalDate` that is `epochDay` days after 1970-01-01, or `None` when it
  /// is outside the representable range.
  ///
  pub def tryOfEpochDay(epochDay: Int64): Option[LocalDate] =
    LocalDate(epochDay) |> checkRange |> Result.toOption

  ///
  /// Returns the `LocalDate` that is `epochDay` days after 1970-01-01, clamped to the
  /// nearest end of the range when it lies outside it.
  ///
  pub def saturatingOfEpochDay(epochDay: Int64): LocalDate =
    LocalDate(epochDay) |> checkRange |> either

  /// Returns the number of days from 1970-01-01 to `d`, which is day 0.
  pub def toEpochDay(d: LocalDate): Int64 =
    let LocalDate(epochDay) = d;
    epochDay

  ///
  /// Returns the year of `d`, from -9999 to 9999.
  ///
  /// Years are numbered astronomically: the year before 1 is 0.
  ///
  pub def getYear(d: LocalDate): Int32 =
    let (year, _, _) = fields(d);
    Int64.truncateToInt32(year)

  /// Returns the month of `d`, from 1 (January) to 12 (December).
  pub def getMonthValue(d: LocalDate): Int32 =
    let (_, month, _) = fields(d);
    month

  /// Returns the day of the month of `d`, from 1 to 31.
  pub def getDayOfMonth(d: LocalDate): Int32 =
    let (_, _, day) = fields(d);
    day

  /// Returns the day of the year of `d`, from 1 to 365, or to 366 in a leap year.
  pub def getDayOfYear(d: LocalDate): Int32 =
    let LocalDate(epochDay) = d;
    let (year, _, _) = fields(d);
    Int64.truncateToInt32(epochDay - daysFromCivil(year, 1, 1)) + 1

  ///
  /// Returns the day of the week `d` falls on.
  ///
  /// 1970-01-01 was a Thursday, the fourth day of an ISO-8601 week.
  ///
  pub def getDayOfWeek(d: LocalDate): DayOfWeek =
    let LocalDate(epochDay) = d;
    let value = Int64.truncateToInt32(Int64.modulo(epochDay + 3i64, 7i64)) + 1;
    match DayOfWeek.tryOf(value) {
      case Some(dow) => dow
      // `value` is in [1, 7] by construction.
      case None      => DayOfWeek.Monday
    }

  ///
  /// Returns true if `d` is in a leap year.
  ///
  /// A year is a leap year if it is divisible by four, unless it is also divisible by 100
  /// but not by 400: 2000 was one, 1900 was not. Year 0 is one.
  ///
  pub def isLeapYear(d: LocalDate): Bool =
    let (year, _, _) = fields(d);
    isLeap(year)

  /// Returns the number of days in the month `d` is in, from 28 to 31.
  pub def lengthOfMonth(d: LocalDate): Int32 =
    let (year, month, _) = fields(d);
    daysInMonth(year, month)

  /// Returns the number of days in `year`: 366 in a leap year, 365 otherwise.
  def lengthOfYearOf(year: Int64): Int32 = if (isLeap(year)) 366 else 365

  /// Returns the number of days in the year `d` is in: 366 in a leap year, 365 otherwise.
  pub def lengthOfYear(d: LocalDate): Int32 =
    let (year, _, _) = fields(d);
    lengthOfYearOf(year)

  /// Returns true if `d1` is after `d2`.
  pub def isAfter(d1: LocalDate, d2: LocalDate): Bool = d1 > d2

  /// Returns true if `d1` is before `d2`.
  pub def isBefore(d1: LocalDate, d2: LocalDate): Bool = d1 < d2

  /// Returns true if `d1` is the same date as `d2`.
  pub def isEqual(d1: LocalDate, d2: LocalDate): Bool = d1 == d2

  //
  // Arithmetic
  //
  // Every amount is taken as a `BigInt` internally. Negating an `Int64` amount for the
  // `minus` forms cannot overflow that way, and neither can multiplying weeks into days.
  //

  ///
  /// Returns the `LocalDate` `days` days after `d`, or `Err` with the end of the range the
  /// result lies beyond.
  ///
  /// The sum is taken exactly, so it holds even for a `d` built directly outside the
  /// range: a sum that comes back into the range is `Ok`.
  ///
  def shiftDays(d: LocalDate, days: BigInt): Result[LocalDate, LocalDate] =
    let LocalDate(epochDay) = d;
    let sum = Int64.toBigInt(epochDay) + days;
    if (Int64.toBigInt(toEpochDay(max())) < sum) Err(max())
    else if (sum < Int64.toBigInt(toEpochDay(min()))) Err(min())
    else Ok(LocalDate(BigInt.clampToInt64(min = Int64.minValue(), max = Int64.maxValue(), sum)))

  ///
  /// Returns the `LocalDate` `months` months after `d`, or `Err` with the end of the range
  /// the result lies beyond.
  ///
  /// The day of the month is kept, unless the target month is too short for it, in which
  /// case it is pulled back to the last day of that month: 2019-01-31 plus one month is
  /// 2019-02-28.
  ///
  /// A `d` outside the range has no month to count from, so it is reported as lying
  /// beyond the end it is outside of.
  ///
  def shiftMonths(d: LocalDate, months: BigInt): Result[LocalDate, LocalDate] =
    // No two months in the range are more than 239999 months apart. Anything larger is
    // ruled out here, which keeps the Int64 arithmetic below from overflowing.
    let limit = 240_000ii;
    match checkRange(d) {
      case Err(end) => Err(end)
      case Ok(_) =>
        if (limit < months) Err(max())
        else if (months < -limit) Err(min())
        else {
          let (year, month, day) = fields(d);
          let m = BigInt.clampToInt64(min = -240_000i64, max = 240_000i64, months);
          let total = year * 12i64 + Int32.toInt64(month - 1) + m;
          let newYear = floorDiv(total, 12i64);
          let newMonth = Int64.truncateToInt32(Int64.modulo(total, 12i64)) + 1;
          if (maxYear() < newYear) Err(max())
          else if (newYear < minYear()) Err(min())
          else Ok(LocalDate(daysFromCivil(newYear, newMonth, Int32.min(day, daysInMonth(newYear, newMonth)))))
        }
    }

  pub def tryPlusDays(d: LocalDate, days: Int64): Option[LocalDate] =
    shiftDays(d, Int64.toBigInt(days)) |> Result.toOption

  pub def saturatingPlusDays(d: LocalDate, days: Int64): LocalDate =
    shiftDays(d, Int64.toBigInt(days)) |> either

  pub def tryMinusDays(d: LocalDate, days: Int64): Option[LocalDate] =
    shiftDays(d, -Int64.toBigInt(days)) |> Result.toOption

  pub def saturatingMinusDays(d: LocalDate, days: Int64): LocalDate =
    shiftDays(d, -Int64.toBigInt(days)) |> either

  pub def tryPlusWeeks(d: LocalDate, weeks: Int64): Option[LocalDate] =
    shiftDays(d, Int64.toBigInt(weeks) * 7ii) |> Result.toOption

  pub def saturatingPlusWeeks(d: LocalDate, weeks: Int64): LocalDate =
    shiftDays(d, Int64.toBigInt(weeks) * 7ii) |> either

  pub def tryMinusWeeks(d: LocalDate, weeks: Int64): Option[LocalDate] =
    shiftDays(d, Int64.toBigInt(weeks) * -7ii) |> Result.toOption

  pub def saturatingMinusWeeks(d: LocalDate, weeks: Int64): LocalDate =
    shiftDays(d, Int64.toBigInt(weeks) * -7ii) |> either

  ///
  /// Returns the `LocalDate` `months` months after `d`, or `None` when that is outside
  /// the representable range.
  ///
  /// The day of the month is pulled back to the last day of the target month when that
  /// month is too short for it: 2019-01-31 plus one month is 2019-02-28.
  ///
  pub def tryPlusMonths(d: LocalDate, months: Int64): Option[LocalDate] =
    shiftMonths(d, Int64.toBigInt(months)) |> Result.toOption

  pub def saturatingPlusMonths(d: LocalDate, months: Int64): LocalDate =
    shiftMonths(d, Int64.toBigInt(months)) |> either

  pub def tryMinusMonths(d: LocalDate, months: Int64): Option[LocalDate] =
    shiftMonths(d, -Int64.toBigInt(months)) |> Result.toOption

  pub def saturatingMinusMonths(d: LocalDate, months: Int64): LocalDate =
    shiftMonths(d, -Int64.toBigInt(months)) |> either

  ///
  /// Returns the `LocalDate` `years` years after `d`, or `None` when that is outside the
  /// representable range.
  ///
  /// A leap day is pulled back to February 28 when the target year is not a leap year.
  ///
  pub def tryPlusYears(d: LocalDate, years: Int64): Option[LocalDate] =
    shiftMonths(d, Int64.toBigInt(years) * 12ii) |> Result.toOption

  pub def saturatingPlusYears(d: LocalDate, years: Int64): LocalDate =
    shiftMonths(d, Int64.toBigInt(years) * 12ii) |> either

  pub def tryMinusYears(d: LocalDate, years: Int64): Option[LocalDate] =
    shiftMonths(d, Int64.toBigInt(years) * -12ii) |> Result.toOption

  pub def saturatingMinusYears(d: LocalDate, years: Int64): LocalDate =
    shiftMonths(d, Int64.toBigInt(years) * -12ii) |> either

  //
  // Replacing a field
  //
  // As in `java.time`, `withYear` and `withMonth` pull the day of the month back to the
  // end of a month that is too short for it, while `withDayOfMonth` and `withDayOfYear`
  // have nothing to pull back and answer `None` for a day that does not exist.
  //

  /// Returns the fields of `d`, or `None` when `d` is outside the representable range.
  def fieldsInRange(d: LocalDate): Option[(Int64, Int32, Int32)] =
    checkRange(d) |> Result.toOption |> Option.map(fields)

  ///
  /// Returns `d` with the year replaced by `year`, or `None` when `year` is outside
  /// [-9999, 9999].
  ///
  /// A leap day is pulled back to February 28 when `year` is not a leap year.
  ///
  pub def tryWithYear(d: LocalDate, year: Int32): Option[LocalDate] =
    fieldsInRange(d) |> Option.flatMap(match (_, month, day) -> {
      let y = Int32.toInt64(year);
      if (y < minYear() or maxYear() < y) None
      else ofFields(y, month, Int32.min(day, daysInMonth(y, month)))
    })

  ///
  /// Returns `d` with the month replaced by `month`, or `None` when `month` is outside
  /// [1, 12].
  ///
  /// The day of the month is pulled back to the last day of `month` when that month is
  /// too short for it.
  ///
  pub def tryWithMonth(d: LocalDate, month: Int32): Option[LocalDate] =
    fieldsInRange(d) |> Option.flatMap(match (year, _, day) ->
      if (month < 1 or 12 < month) None
      else ofFields(year, month, Int32.min(day, daysInMonth(year, month)))
    )

  ///
  /// Returns `d` with the day of the month replaced by `dayOfMonth`, or `None` when that
  /// day does not exist in the month.
  ///
  pub def tryWithDayOfMonth(d: LocalDate, dayOfMonth: Int32): Option[LocalDate] =
    fieldsInRange(d) |> Option.flatMap(match (year, month, _) -> ofFields(year, month, dayOfMonth))

  ///
  /// Returns `d` with the day of the year replaced by `dayOfYear`, or `None` when that
  /// day does not exist in the year.
  ///
  pub def tryWithDayOfYear(d: LocalDate, dayOfYear: Int32): Option[LocalDate] =
    fieldsInRange(d) |> Option.flatMap(match (year, _, _) ->
      tryOfYearDay(Int64.truncateToInt32(year), dayOfYear))

}
