# test262 ports

`Time.Instant` and `Time.LocalDate` cases carried over from [tc39/test262][test262], kept in
the directory layout the originals have so that each file can be read next to its source.
`Temporal.Instant` is ported for `Time.Instant`, and `Temporal.PlainDate` for
`Time.LocalDate`.

Source revisions:

- [`2808d41`][rev] (`test/built-ins/Temporal/Instant`).
- [`7ab7faf`][rev-plaindate] (`test/built-ins/Temporal/PlainDate`).

[test262]: https://github.com/tc39/test262
[rev]: https://github.com/tc39/test262/tree/2808d4143f00993c2e65456d9a99b8f82b6743f9/test/built-ins/Temporal/Instant
[rev-plaindate]: https://github.com/tc39/test262/tree/7ab7fafa0003f73fc85c1b95d88094d33f7eb8bd/test/built-ins/Temporal/PlainDate

## Licence

The cases here are derived from test262, which is published by Ecma International under
the BSD 3-clause licence. A verbatim copy is in `test/test262/LICENSE`, and every ported
file keeps the copyright notice of the test262 file it came from, as that licence
requires.

The notices name Igalia, Bloomberg LP, André Bargull and the V8 project authors, each on
the files they wrote. `harness/TemporalHelpers.flix` is *not* derived from test262's
`harness/temporalHelpers.js` — it only plays the same role — so it carries no such notice
and is under this repository's own licence, as is the rest of the project.
