pub mod Time.LocalDateTime {
  use Time.Clock
  use Time.Duration
  use Time.TimeUnit

  ///
  /// The wrapped `Int64` is seconds since the 1970-01-01T00:00:00Z epoch (UTC).
  /// The getters below assume this representation.
  ///
  pub enum LocalDateTime(Int64) with Eq, Order, Hash

  pub def now(): LocalDateTime \ Clock =
    LocalDateTime(Clock.currentTime(TimeUnit.Seconds))

  pub def today(): LocalDateTime \ Clock =
    LocalDateTime(Clock.currentTime(TimeUnit.Days))

  pub def add(date: LocalDateTime, d: Duration): LocalDateTime =
    let LocalDateTime(t) = date;
    let Duration(d2) = d;
    LocalDateTime(t + d2)

  pub def sub(date: LocalDateTime, d: Duration): LocalDateTime =
    let LocalDateTime(t) = date;
    let Duration(d2) = d;
    LocalDateTime(t - d2)

  pub def between(d1: LocalDateTime, d2: LocalDateTime): Duration =
    let LocalDateTime(t1) = d1;
    let LocalDateTime(t2) = d2;
    Duration.Duration(Int64.abs(t1 - t2))

  pub def second(date: LocalDateTime): Int32 =
    let LocalDateTime(t) = date;
    Int64.truncateToInt32(Int64.modulo(t, 60i64))

  pub def minute(date: LocalDateTime): Int32 =
    let LocalDateTime(t) = date;
    Int64.truncateToInt32(Int64.modulo(t, 3600i64) / 60i64)

  pub def hour(date: LocalDateTime): Int32 =
    let LocalDateTime(t) = date;
    Int64.truncateToInt32(Int64.modulo(t, 86400i64) / 3600i64)

  ///
  /// Returns the floor of `x / n`, i.e. rounding towards negative infinity.
  ///
  def floorDiv(x: Int64, n: Int64): Int64 =
    (x - Int64.modulo(x, n)) / n

  ///
  /// Decomposes `days` (days since the 1970-01-01 epoch) into a
  /// `(year, month, dayOfMonth)` triple.
  ///
  /// Based on Howard Hinnant's `civil_from_days` algorithm, which is valid
  /// over the entire range of `Int64` and correctly accounts for leap years.
  ///
  def civilFromDays(days: Int64): (Int64, Int64, Int64) =
    let z = days + 719468i64;
    let era = floorDiv(z, 146097i64);
    let doe = z - era * 146097i64;
    let yoe = floorDiv(doe - floorDiv(doe, 1460i64) + floorDiv(doe, 36524i64) - floorDiv(doe, 146096i64), 365i64);
    let y = yoe + era * 400i64;
    let doy = doe - (365i64 * yoe + floorDiv(yoe, 4i64) - floorDiv(yoe, 100i64));
    let mp = floorDiv(5i64 * doy + 2i64, 153i64);
    let d = doy - floorDiv(153i64 * mp + 2i64, 5i64) + 1i64;
    let m = if (mp < 10i64) mp + 3i64 else mp - 9i64;
    let finalY = if (m <= 2i64) y + 1i64 else y;
    (finalY, m, d)

  pub def year(date: LocalDateTime): Int32 =
    let LocalDateTime(t) = date;
    let (y, _, _) = civilFromDays(floorDiv(t, 86400i64));
    Int64.truncateToInt32(y)

  pub def month(date: LocalDateTime): Int32 =
    let LocalDateTime(t) = date;
    let (_, m, _) = civilFromDays(floorDiv(t, 86400i64));
    Int64.truncateToInt32(m)

  pub def dayOfMonth(date: LocalDateTime): Int32 =
    let LocalDateTime(t) = date;
    let (_, _, d) = civilFromDays(floorDiv(t, 86400i64));
    Int64.truncateToInt32(d)
}
