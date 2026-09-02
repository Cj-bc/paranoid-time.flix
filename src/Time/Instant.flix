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
  def ofEpochMilli(ms: Int64): Instant =
    Instant({secondsSinceEpoch = floorDiv(ms, millisPerSecond()),
             nano = Int64.truncateToInt32(Int64.modulo(ms, millisPerSecond()) * nanosPerMilli())})

  pub def now(): Instant \ Clock =
    ofEpochMilli(Clock.currentTime(TimeUnit.Milliseconds))

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

  /// Returns the absolute amount of time between `d1` and `d2`,
  /// or None when it is too large to fit in a `Duration`.
  pub def between(d1: Instant, d2: Instant): Option[Duration] =
    let Instant(earlier) = Order.min(d1, d2);
    let Instant(later) = Order.max(d1, d2);
    if (earlier#secondsSinceEpoch < 0i64 and (Int64.maxValue() + earlier#secondsSinceEpoch) < later#secondsSinceEpoch)
      None
    else
      let seconds = later#secondsSinceEpoch - earlier#secondsSinceEpoch;
      // In (-1_000_000_000, 1_000_000_000). Negative only when `seconds` is positive.
      let nanos = Int32.toInt64(later#nano) - Int32.toInt64(earlier#nano);
      if ((Int64.maxValue() / nanosPerSecond()) < seconds) None
      else
        let secondsAsNanos = seconds * nanosPerSecond();
        if (0i64 < nanos and (Int64.maxValue() - nanos) < secondsAsNanos) None
        else Some(Duration.nanoseconds(secondsAsNanos + nanos))
}
