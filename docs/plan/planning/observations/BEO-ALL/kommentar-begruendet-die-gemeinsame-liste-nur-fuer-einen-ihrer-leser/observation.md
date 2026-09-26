# Kommentar begründet die gemeinsame Liste nur für einen ihrer Leser

**Sub-Area:** `*` (gesamtes Repo)

Eine Liste hat zwei Leser, und der Kommentar an ihr begründet ihren Inhalt nur für den einen: Der Kommentar
an `AusgenommenePfade()` in `internal/archive/scan.go` sagt, warum `docs/reviews/**` nicht darin steht, mit
dem Grund des Hänger-Wächters; der Nachzug liest dieselbe Liste (`AusgenommenePfadeNachzug()`) und liest
`docs/reviews/**` aus einem anderen Grund. Der Kommentar ist nicht falsch, er lässt den Wächter-Grund als
den einzigen erscheinen; wer die Liste für den einen Leser ändert, sieht den anderen nicht. Die
Fehlerrichtung ist *jeder Leser der Liste findet seinen Grund*.

## Benannt, nicht gezählt

[`ausnahmeliste-nur-auf-form-geprueft`](../ausnahmeliste-nur-auf-form-geprueft/observation.md) trifft die
**Berechtigung** eines Eintrags, die mechanisch nie geprüft wird; hier trägt der Kommentar den Grund eines
Lesers und schweigt zum zweiten.
