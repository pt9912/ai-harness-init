**Stand:** offen

Eine der vier Richtungen ist bewacht: Der hermetische Test hält jede in einer Inventur-Zelle
genannte Adresse gegen die Adressen, die der Emit wirklich schreibt
(`internal/emit/baumaussage_test.go`, `make test`), und die Nenner-Deckung hält
[`test/baum-inventur.bats`](../../../../../../test/baum-inventur.bats). Die **Bedingung** eines
Trägers — Gelingens-Zweig, skip-if-present, Melde-Kanal — liest keiner der beiden, und
[`make full-smoke`](../../../../../../harness/sensors/full-smoke.md) auch nicht: dort entsteht
jedes Ziel im Gelingens-Zweig und auf leerem Grund, also genau in dem Zweig, den die Aussage
behauptet. Träger ist der Lauf, der die Aussage schreibt.
