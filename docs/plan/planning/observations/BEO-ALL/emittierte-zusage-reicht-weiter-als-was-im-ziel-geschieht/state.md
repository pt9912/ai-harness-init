**Stand:** verkörpert in `AGENTS.md` §3.6 (`seit slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst`)

Kennung: [`slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst`](../../../done/slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst.md) — er lässt die Kurzbeschreibung
einer E2E-Stufe nennen, was der Lauf im Ziel misst, und übergibt die Regel dazu an den Architect.

Eine der vier Richtungen ist bewacht: Der hermetische Test hält jede in einer Inventur-Zelle
genannte Adresse gegen die Adressen, die der Emit wirklich schreibt
(`internal/emit/baumaussage_test.go`, `make test`), und die Nenner-Deckung hält
[`test/baum-inventur.bats`](../../../../../../test/baum-inventur.bats). Die **Bedingung** eines
Trägers — Gelingens-Zweig, skip-if-present, Melde-Kanal — liest keiner der beiden, und
[`make full-smoke`](../../../../../../harness/sensors/full-smoke.md) auch nicht: dort entsteht
jedes Ziel im Gelingens-Zweig und auf leerem Grund, also genau in dem Zweig, den die Aussage
behauptet. Träger ist der Lauf, der die Aussage schreibt.

**Sensor der Adress-Hälfte:** `internal/emit/baumaussage_test.go` (`make test`) und
[`test/baum-inventur.bats`](../../../../../../test/baum-inventur.bats) urteilen über sie.

**Offen beim Auftraggeber — die Bedingungs-Hälfte.** Der Sensor ist benannt: je Bedingungs-Zweig
(Gelingens-Zweig, skip-if-present, Melde-Kanal) eine `full-smoke`-Stufe auf vorbelegtem Grund. Kein
bestehender Slice trägt ihn; ob ein Slice ihn bekommt oder die Lücke als akzeptiertes Negativ steht,
entscheidet der Auftraggeber.
