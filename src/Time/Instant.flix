pub mod Time.Instant {
  use Time.Clock
  use Time.Duration
  use Time.TimeUnit

  ///
  /// A point on the time-line.
  ///
  /// It is stored as two dedicated fields:
  ///
  /// - `secondsSinceEpoch`: whole seconds since Java Epoch (1970-01-01T00:00:00Z).
  /// - `nano`: nanosecond-of-second adjustment. Always in [0, 999_999_999].
  ///
  /// `nano` is never negative, thus every point on the time-line has exactly one
  /// representation and structural equality coincides with equality in time.
  ///
  /// Not every pair of field values is a valid `Instant`. The representable range runs from
  /// -9999-01-02T00:00:00Z to 9999-12-30T23:59:59.999999999Z; see `min` and
  /// `max` for what puts it one day inside the four-digit year range at each end.
  /// Every operation here either stays inside it or reports that it could not.
  ///
  pub enum Instant({
    secondsSinceEpoch = Int64,
    nano = Int32
  })

  ///
  /// The instances below are written by hand because Flix cannot derive traits for
  /// an enum whose case holds a record.
  ///

  instance Eq[Instant] {
    pub def eq(x: Instant, y: Instant): Bool =
      let Instant(i1) = x;
      let Instant(i2) = y;
      i1#secondsSinceEpoch == i2#secondsSinceEpoch and i1#nano == i2#nano
  }

  instance Hash[Instant] {
    pub def hash(x: Instant): Int32 =
      let Instant(i) = x;
      Hash.hash(i#secondsSinceEpoch) `Hash.combine` Hash.hash(i#nano)
  }

  /// Compares `secondsSinceEpoch` first and only falls back to `nano`.
  instance Order[Instant] {
    pub def compare(x: Instant, y: Instant): Comparison =
      let Instant(i1) = x;
      let Instant(i2) = y;
      match Order.compare(i1#secondsSinceEpoch, i2#secondsSinceEpoch) {
        case Comparison.EqualTo => Order.compare(i1#nano, i2#nano)
        case c                  => c
      }
  }

  /// The number of nanoseconds in one second.
  def nanosPerSecond(): Int64 = 1_000_000_000i64

  /// The number of milliseconds in one second.
  def millisPerSecond(): Int64 = 1_000i64

  /// The number of nanoseconds in one millisecond.
  def nanosPerMilli(): Int64 = 1_000_000i64

  ///
  /// The earliest representable `Instant`: -9999-01-02T00:00:00Z.
  ///
  /// The range is the four-digit year range of the proleptic Gregorian calendar, pulled in
  /// by one day at each end. The day of slack is what lets a UTC offset be applied without
  /// leaving the range: offsets stay inside +/-18:00, so every instant here still names a
  /// year in [-9999, 9999] once one is applied. Without it, -9999-01-01T00:00:00Z read at
  /// any positive offset would fall in the year -10000.
  ///
  /// -9999-01-02 is 4371587 days before the epoch, and 4371587 * 86400 = 377705116800.
  ///
  pub def min(): Instant =
    Instant({secondsSinceEpoch = -377_705_116_800i64, nano = 0})

  ///
  /// The latest representable `Instant`: 9999-12-30T23:59:59.999999999Z.
  ///
  /// One nanosecond before 9999-12-31T00:00:00Z, which is 2932896 days after the epoch:
  /// 2932896 * 86400 = 253402214400, one second below which is 253402214399.
  ///
  pub def max(): Instant =
    Instant({secondsSinceEpoch = 253_402_214_399i64, nano = 999_999_999})

  ///
  /// Returns `t` when it is within the representable range, otherwise `Err` with the end it
  /// lies outside of.
  ///
  def checkRange(t: Instant): Result[Instant, Instant] =
    if (max() < t) Err(max())
    else if (t < min()) Err(min())
    else Ok(t)

  /// Returns `x / n` rounded towards negative infinity. `n` must be positive.
  def floorDiv(x: Int64, n: Int64): Int64 =
    let q = x / n;
    if (Int64.remainder(x, n) < 0i64) q - 1i64 else q

  ///
  /// Returns the `Instant` at `epochSecond` whole seconds after the epoch, or `None` when it
  /// is outside the representable range.
  ///
  /// A whole second count is what `secondsSinceEpoch` already holds, so there is nothing to
  /// split and nothing to carry: `nano` is left at zero on both sides of the epoch, and the
  /// range check is the only thing that can fail. An `Int64` second count reaches about seven
  /// orders of magnitude further than either end of the range, so it often does.
  ///
  pub def tryOfEpochSecond(epochSecond: Int64): Option[Instant] =
    Instant({secondsSinceEpoch = epochSecond, nano = 0}) |> checkRange |> Result.toOption

  ///
  /// Returns the `Instant` at `epochSecond` whole seconds after the epoch, clamped to the
  /// nearest end of the range when it lies outside it.
  ///
  pub def saturatingOfEpochSecond(epochSecond: Int64): Instant =
    match (Instant({secondsSinceEpoch = epochSecond, nano = 0}) |> checkRange) {
      case Ok(v) => v
      case Err(v) => v
    }

  ///
  /// Splits `ms` into the two fields an `Instant` is stored in, without regard for the
  /// representable range.
  ///
  /// The division only ever shrinks the magnitude, so this cannot overflow however far
  /// outside the range `ms` lands.
  ///
  def splitEpochMilliseconds(ms: Int64): Instant =
    Instant({secondsSinceEpoch = floorDiv(ms, millisPerSecond()),
             nano = Int64.truncateToInt32(Int64.modulo(ms, millisPerSecond()) * nanosPerMilli())})

  ///
  /// Returns the `Instant` that is `ms` milliseconds after the epoch, or `None` when that is
  /// outside the representable range.
  ///
  /// An `Int64` millisecond count reaches about four orders of magnitude further than either
  /// end of the range, so, as with `tryOfEpochSecond`, not every count it can hold has an
  /// `Instant`.
  ///
  pub def tryOfEpochMilli(ms: Int64): Option[Instant] =
    splitEpochMilliseconds(ms) |> checkRange |> Result.toOption

  ///
  /// Returns the `Instant` that is `ms` milliseconds after the epoch, clamped to the nearest
  /// end of the range when it lies outside it.
  ///
  pub def saturatingOfEpochMilli(ms: Int64): Instant =
    match splitEpochMilliseconds(ms) |> checkRange {
      case Ok(v)  => v
      case Err(v) => v
    }

  ///
  /// Returns the `Instant` that is `ns` nanoseconds after the epoch.
  ///
  /// No range check is needed and no `try` form exists: an `Int64` nanosecond count spans a
  /// little over +/-292 years, which is well inside the range at either end.
  ///
  pub def ofEpochNanos(ns: Int64): Instant =
    Instant({secondsSinceEpoch = floorDiv(ns, nanosPerSecond()),
             nano = Int64.truncateToInt32(Int64.modulo(ns, nanosPerSecond()))})

  ///
  /// Returns the current `Instant`.
  ///
  /// A `Clock` reports a millisecond count, so this clamps the way `saturatingOfEpochMilli`
  /// does. A real clock is nowhere near either end of the range; a frozen or mocked one can
  /// be.
  ///
  pub def now(): Instant \ Clock =
    saturatingOfEpochMilli(Clock.currentTime(TimeUnit.Milliseconds))

  ///
  /// Returns the `Instant` that is `seconds` seconds and `nanos` nanoseconds after `t`.
  ///
  /// Returns Ok() when the calculated Instant is in valid range, otherwise Err() with
  /// the largest/smallest value.
  ///
  /// `nanos` must be in (-1_000_000_000, 1_000_000_000) and `seconds` must be small
  /// enough that `seconds + 1` does not overflow. Both hold for the parts a `Duration`
  /// is split into.
  ///
  def internalShift(t: Instant, seconds: Int64, nanos: Int64): Result[Instant, Instant] =
    let Instant(i) = t;
    // In (-1_000_000_000, 2_000_000_000), so the carry is -1, 0 or 1.
    let n = Int32.toInt64(i#nano) + nanos;
    let s = seconds + floorDiv(n, nanosPerSecond());
    let nano = Int64.truncateToInt32(Int64.modulo(n, nanosPerSecond()));
    // For an `Instant` in range the sum is nowhere near overflowing -- `i#secondsSinceEpoch`
    // is within +/-3.8e11 and `s` within +/-9.3e9 -- but the record constructor is public, so
    // `t` need not be in range and the sum has to be ruled out before it is taken. Otherwise
    // an argument far outside the range would wrap round and land back inside it.
    if (0i64 < s and (Int64.maxValue() - s) < i#secondsSinceEpoch) Err(max())
    else if (s < 0i64 and i#secondsSinceEpoch < (Int64.minValue() - s)) Err(min())
    else checkRange(Instant({secondsSinceEpoch = i#secondsSinceEpoch + s, nano = nano}))

  /// Returns Ok() when calculated Instant is in valid range, otherwise return the largest/smallest value.
  def internalTryPlus(t: Instant, d: Duration): Result[Instant, Instant] =
    let dns = Duration.toNanos(d);
    internalShift(t, floorDiv(dns, nanosPerSecond()), Int64.modulo(dns, nanosPerSecond()))

  pub def tryPlus(t: Instant, d: Duration): Option[Instant] =
    internalTryPlus(t, d) |> Result.toOption

  pub def saturatingPlus(t: Instant, d: Duration): Instant =
    match internalTryPlus(t, d) {
      case Ok(v)  => v
      case Err(v) => v
    }

  /// Returns Ok() when calculated Instant is in valid range, otherwise return the largest/smallest value.
  def internalTryMinus(t: Instant, d: Duration): Result[Instant, Instant] =
    let dns = Duration.toNanos(d);
    // The duration is negated part by part: `Int64.minValue()` has no positive
    // counterpart, but neither the second- nor the nano-part of the split has that problem.
    internalShift(t, -floorDiv(dns, nanosPerSecond()), -Int64.modulo(dns, nanosPerSecond()))

  pub def tryMinus(date: Instant, d: Duration): Option[Instant] =
    internalTryMinus(date, d) |> Result.toOption

  pub def saturatingMinus(t: Instant, d: Duration): Instant =
    match internalTryMinus(t, d) {
      case Ok(v)  => v
      case Err(v) => v
    }

  ///
  /// The largest `Instant` that has an `Int64` nanosecond count, as the pair it is stored
  /// in: `Int64.maxValue()` is 9223372036854775807 ns, which is 9223372036 whole seconds
  /// plus 854775807 ns.
  ///
  def largestCountableInstant(): (Int64, Int64) = (9_223_372_036i64, 854_775_807i64)

  /// Returns the number of nanoseconds between `t` and the epoch
  pub def toEpochNanos(t: Instant): BigInt =
    let Instant(v) = t;
    Int64.toBigInt(v#secondsSinceEpoch) * Int64.toBigInt(nanosPerSecond()) + Int32.toBigInt(v#nano)

  ///
  /// Returns the absolute amount of time between `d1` and `d2`,
  /// or None when it is too large to fit in a `Duration`.
  ///
  /// The difference is taken field by field rather than as the difference of two
  /// `toEpochNanos` results: a gap can fit in a `Duration` while neither end of it has an
  /// `Int64` count from the epoch, and the gap between an instant and itself is zero however
  /// far out it sits.
  ///
  pub def between(d1: Instant, d2: Instant): Option[Duration] =
    let Instant(earlier) = Order.min(d1, d2);
    let Instant(later) = Order.max(d1, d2);
    // Two `Instant`s in range are at most 6.4e11 seconds apart, but the record constructor is
    // public, so they need not be in range and the two second counts alone can be further
    // apart than an `Int64` holds. That has to be ruled out before the subtraction below.
    if (earlier#secondsSinceEpoch < 0i64 and (Int64.maxValue() + earlier#secondsSinceEpoch) < later#secondsSinceEpoch)
      None
    else
      // In (-1_000_000_000, 1_000_000_000), and negative only when the second count differs.
      let nanoDiff = Int32.toInt64(later#nano) - Int32.toInt64(earlier#nano);
      let borrow = if (nanoDiff < 0i64) 1i64 else 0i64;
      // `later` is at or after `earlier`, so both come out non-negative, with the borrow
      // leaving `nano` in [0, 999999999] the way an `Instant` itself holds it.
      let seconds = later#secondsSinceEpoch - earlier#secondsSinceEpoch - borrow;
      let nano = nanoDiff + borrow * nanosPerSecond();
      let (maxSeconds, maxNano) = largestCountableInstant();
      if (maxSeconds < seconds or (seconds == maxSeconds and maxNano < nano)) None
      else Some(Duration.nanoseconds(seconds * nanosPerSecond() + nano))
}
