/// Unit tests for `Time.LocalDateTime.now`.

@Test
def betweenSameNowInstantIsZero(): Unit \ (Assert + Time.Clock) =
    let d = Time.LocalDateTime.now();
    Assert.assertTrue(Time.Duration.isZero(Time.LocalDateTime.between(d, d)))
