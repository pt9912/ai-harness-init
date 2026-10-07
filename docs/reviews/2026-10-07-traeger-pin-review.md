# Review: slice-full-smoke-misst-den-emittierten-traeger-pin

**Rolle:** Reviewer (`.harness/skills/reviewer.md`) · **Datum:** 2026-10-07 ·
**Gegenstand:** Commit `2425712b` gegen den Slice-Plan (Stand `45400d0b`), `ADR-0058` Festlegung 1,
`LH-QA-02`, `AGENTS.md` §3.6/§3.7, `MR-071`.

## Summary

0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO. Wiederkehrende Klasse: *Teilmessung der E2E-Stufe nennt die
Ursache, nicht die Folge* (LOW-1).

## Findings

### LOW-1 — Stufe 5 misst den Verifizierungs-Kanal des Adopters nicht, und die Deklaration sagt das nicht

- `kategorie`: LOW
- `quelle`: `LH-QA-02`, `AGENTS.md` §3.6 (emittierte Abdeckungs-Aussage)
- `pfad`: `harness/tools/full-smoke.sh:1817-1820`, `:1826` (Deklaration), `docs/user/e2e-abdeckung.md` Zeile Stufe 5
- `befund`: `klon_traeger_fetch` lässt die exportierten `TRAEGER_SHA256_*` des Dogfood-Makefile
  (`Makefile:53`) stehen; damit nimmt das emittierte Skript den Zweig `quelle="Pin"`
  (`internal/emit/templates/enforce/traeger-fetch.sh:124-134`) und lädt die `SHA256SUMS` nie. Ein
  Adopter hat keine Digest-Pins (das Fragment führt keine) und läuft immer über den Manifest-Kanal.
  Failure-Szenario: ein Release ohne `SHA256SUMS`-Asset oder mit fehlendem Plattform-Eintrag lässt
  `make full-smoke` grün, während `make traeger-fetch` beim Adopter bricht. Die Deklaration nennt die
  Vererbung („die Digest-Pins erbt der Aufruf weiter“), aber nicht deren Folge, und behält
  „sha256 vor der Ablage verifiziert“ ohne Kanal.
  Der Plan schließt die übrigen Exporte aus (§1) und führt das Risiko in §6
  („Weitere Stufen erben Dogfood-Exporte“); der Fund betrifft dieselbe Stufe, die Ausgangs-Zuweisung
  liegt beim Planner.
- `verifizierbar`: ja — ein Lauf von Stufe 5 ohne `TRAEGER_SHA256_*` in der Umgebung würde den
  Manifest-Kanal fahren; heute misst ihn nur der hermetische bats-Fall `happy im Ziel-Modus`.
- `klasse`: Teilmessung der E2E-Stufe nennt die Ursache, nicht die Folge

### INFO-1 — Laufzeit-Aussage im Fall-Kopf trifft nicht zu

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.7
- `pfad`: `test/mutations/554-traeger-tag-im-fragment-umbenannt-full-smoke.sh:13-14` (wie 553:22-23)
- `befund`: „läuft fast voll durch: die Stufe liegt spät“ — gemessen 17,61 s (554) und 18,30 s (553)
  gegen einen Grün-Vorlauf von 154,56 s; Stufe 5 von 31. Wer Shards oder Netzbedarf nach dem Kopf
  plant, rechnet mit dem vollen Lauf. Keine Fehlfunktion.
- `verifizierbar`: ja — Zeitzeilen von `make mutate`.
- `klasse`: Kommentar-Zusage ohne Messung

## Kommandos und Ausgaben

```text
make mutate MUTATE_CASES='555-traeger-tag-im-fragment-umbenannt-pin-kopplung 554-traeger-tag-im-fragment-umbenannt-full-smoke 553-ausgang-unveroeffentlichter-traeger-tag'
mutate: ok      553-… -> AUSGANG LEITUNG: make traeger-fetch im frischen Klon rot
mutate: ok      554-… -> AUSGANG BAUM: make traeger-fetch im frischen Klon rot
mutate: ok      555-… -> pin-kopplung rot
mutate: 3 ok, 0 Befund(e)          # EXIT 0
```

Gegenprobe 555 (Kopie des Baums aus `git archive HEAD`): `pin_wert` auf die Präfix-Form
`grep "^$2"` zurückgesetzt, Mutation 555 angewandt (`TRAEGER_TAGX ?= v0.5.0`),
`make test-bats BATS_TARGET=test/traeger-fetch.bats` → alle Fälle `ok`, rc=0. Der Fall bindet die
exakte Form.

Sonde zu `env -u … MAKEFLAGS MFLAGS` (Scratch-Makefile, `make -s -j3 outer FOO=cli`, Fragment
`FOO ?= frag`): mit `env -u` liefert der innere Lauf `frag`, ohne ihn `cli`; `MAKEOVERRIDES` bleibt
als Verweis `${-*-command-variables-*-}` in der Umgebung und löst im inneren Lauf leer auf.

`make e2e-abdeckung` in derselben Kopie: `git status --porcelain` leer (byte-gleich zum Erzeuger).
Diff ohne Zeilennummern: `diff <(… sed 's/full-smoke\.sh:[0-9]+/L/') …` → **1** geänderte Zeile
(Stufe 5); die übrigen 26 sind die Verschiebung um 14 Zeilen.

## Geprüft, ohne Befund

- **(a) `klon_traeger_fetch`:** trifft beide Fetch-Aufrufe im Klon (`grep -n 'traeger-fetch'
  harness/tools/full-smoke.sh` außerhalb von Kommentaren: Zeilen 1933, 1957); die Aufrufe (a)/(d)
  holen nichts. Wegfall von `MAKEFLAGS` nimmt dem inneren `make` nur `-s/-j/-k/-i` und
  Kommandozeilen-Zuweisungen — keiner davon wird von `traeger-fetch` gebraucht; CI ruft
  `make full-smoke` ohne Flags (`.github/workflows/ci.yml:85`), lokal und CI verhalten sich gleich.
  Der Negativ-Fall (c) erreicht das Skript weiter, weil die `$ts_pin_var=…`-Zuweisung als Argument
  hinter `env -u` steht.
- **(b) Fälle 553/554/555:** alle drei gebunden; 555 mit Gegenprobe gefahren. 554-Gegenprobe ohne
  `env -u` gelesen, nicht gefahren (ohne `env -u` liefert der geerbte Dogfood-Wert den Tag, der
  Fehlt-Zweig in `traeger-fetch.sh:99-102` wird nicht erreicht). Die FEHLER-Zeile von 554
  („nicht gesetzt“) zeigt `make mutate` nicht; gelesen ist nur die Einordnung `AUSGANG BAUM`.
- **(c) `pin_wert` exakt `^<name> ?=`:** gefahrene Formen `:=`, `=`, `?=` ohne Leerzeichen, zwei
  Leerzeichen — jede liefert leer, und jede Zusicherung in `pin-kopplung` (Vergleich gegen das
  Literal `v0.5.0`, `[ -n "$mk" ]`) wird rot. Fehl-Rot statt stilles Grün; kein Befund, weil der
  Bestand an beiden Stellen `?=` mit einem Leerzeichen führt.
- **(d) `docs/user/e2e-abdeckung.md`:** byte-gleich zum Erzeuger, eine inhaltliche Zeile; die
  Deklaration nennt die Grenze der Digest-Pins (Folge siehe LOW-1).
- **MR-071:** die `sed`-Anker von 553/554/555 treffen den Quell-Bestand
  (`^TRAEGER_TAG ?= ` in `internal/emit/templates/enforce/traeger.mk:25`; in der Kopie angewandt,
  Zeile danach `TRAEGER_TAGX ?= v0.5.0`).
- **§3.7 Kommentare:** der neue Funktionskopf und die Fall-Köpfe beschreiben Zusage und Grenze im
  Indikativ; 553 trägt keine Erzählung der früheren Fassung mehr.
