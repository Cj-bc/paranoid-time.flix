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

  /// The earliest representable `Instant`.
  def minInstant(): Instant =
    Instant({secondsSinceEpoch = Int64.minValue(), nano = 0})

  /// The latest representable `Instant`.
  def maxInstant(): Instant =
    Instant({secondsSinceEpoch = Int64.maxValue(), nano = 999_999_999})

  /// Returns `x / n` rounded towards negative infinity. `n` must be positive.
  def floorDiv(x: Int64, n: Int64): Int64 =
    let q = x / n;
    if (Int64.remainder(x, n) < 0i64) q - 1i64 else q

  /// Returns the `Instant` that is `ms` milliseconds after the epoch.
  pub def fromEpochMilliseconds(ms: Int64): Instant =
    Instant({secondsSinceEpoch = floorDiv(ms, millisPerSecond()),
             nano = Int64.truncateToInt32(Int64.modulo(ms, millisPerSecond()) * nanosPerMilli())})

  /// Returns the `Instant` that is `ns` nanoseconds after the epoch.
  pub def fromEpochNanoseconds(ns: Int64): Instant =
    Instant({secondsSinceEpoch = floorDiv(ns, nanosPerSecond()),
             nano = Int64.truncateToInt32(Int64.modulo(ns, nanosPerSecond()))})

  pub def now(): Instant \ Clock =
    fromEpochMilliseconds(Clock.currentTime(TimeUnit.Milliseconds))

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
    if (0i64 < s and (Int64.maxValue() - s) < i#secondsSinceEpoch) Err(maxInstant())
    else
      if (s < 0i64 and i#secondsSinceEpoch < (Int64.minValue() - s)) Err(minInstant())
      else Ok(Instant({secondsSinceEpoch = i#secondsSinceEpoch + s, nano = nano}))

  /// Returns Ok() when calculated Instant is in valid range, otherwise return the largest/smallest value.
  def internalTryAdd(t: Instant, d: Duration): Result[Instant, Instant] =
    let dns = Duration.toNanos(d);
    internalShift(t, floorDiv(dns, nanosPerSecond()), Int64.modulo(dns, nanosPerSecond()))

  pub def tryAdd(t: Instant, d: Duration): Option[Instant] =
    internalTryAdd(t, d) |> Result.toOption

  pub def saturatingAdd(t: Instant, d: Duration): Instant =
    match internalTryAdd(t, d) {
      case Ok(v)  => v
      case Err(v) => v
    }

  /// Returns Ok() when calculated Instant is in valid range, otherwise return the largest/smallest value.
  def internalTrySub(t: Instant, d: Duration): Result[Instant, Instant] =
    let dns = Duration.toNanos(d);
    // The duration is negated part by part: `Int64.minValue()` has no positive
    // counterpart, but neither the second- nor the nano-part of the split has that problem.
    internalShift(t, -floorDiv(dns, nanosPerSecond()), -Int64.modulo(dns, nanosPerSecond()))

  pub def trySub(date: Instant, d: Duration): Option[Instant] =
    internalTrySub(date, d) |> Result.toOption

  pub def saturatingSub(t: Instant, d: Duration): Instant =
    match internalTrySub(t, d) {
      case Ok(v)  => v
      case Err(v) => v
    }

  ///
  /// The largest `Instant` that has an `Int64` nanosecond count, as the pair it is stored
  /// in: `Int64.maxValue()` is 9223372036854775807 ns, which is 9223372036 whole seconds
  /// plus 854775807 ns.
  ///
  def largestCountableInstant(): (Int64, Int64) = (9_223_372_036i64, 854_775_807i64)

  ///
  /// The smallest one. `Int64.minValue()` is -9223372036854775808 ns, which sits 854775808 ns
  /// below -9223372036 whole seconds; rounding towards negative infinity puts it at
  /// -9223372037 seconds plus the remaining 145224192 ns, which keeps `nano` non-negative.
  ///
  def smallestCountableInstant(): (Int64, Int64) = (-9_223_372_037i64, 145_224_192i64)

  ///
  /// Returns the number of nanoseconds between `t` and the epoch, or `None` when `t` is too
  /// far from it to count in an `Int64`.
  ///
  /// An `Int64` of nanoseconds spans a little over +/-9.22e18 ns where `Instant` reaches
  /// +/-9.22e18 *seconds*, so all but a billionth of the range has no count.
  ///
  pub def toEpochNanos(t: Instant): Option[Int64] =
    let Instant(v) = t;
    let s = v#secondsSinceEpoch;
    let n = Int32.toInt64(v#nano);
    let (maxSeconds, maxNano) = largestCountableInstant();
    let (minSeconds, minNano) = smallestCountableInstant();
    if (s < minSeconds or maxSeconds < s) None
    // At either end `s * nanosPerSecond()` would itself overflow, so the count is reached by
    // walking in from the end rather than by multiplying out.
    else if (s == maxSeconds)
      if (maxNano < n) None else Some(Int64.maxValue() - (maxNano - n))
    else if (s == minSeconds)
      if (n < minNano) None else Some(Int64.minValue() + (n - minNano))
    // In [-9223372036, 9223372035], where `s * nanosPerSecond() + n` stays inside `Int64`.
    else Some(s * nanosPerSecond() + n)

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
    // The two second counts alone can be further apart than an `Int64` holds, so that has to
    // be ruled out before the subtraction below is done.
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
