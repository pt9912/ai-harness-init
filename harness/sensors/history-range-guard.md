# `make history-range-guard` — Vorlauf-Wächter für history-lesende d-check-Module

## Vertrag

`make history-range-guard RANGE=<base>..<head>` (oder `STAGED=1`) prüft **vor** einem
history-lesenden d-check-Modul-Lauf (`vcs`/`commits`, Targets `doc-immutable`/`doc-commits` in
`d-check.mk`), dass eine angeforderte Range git-seitig auflösbar **und** nicht leer ist. Kein
Gate, in keiner Prerequisite-Kette — er prüft eine Vorbedingung *für einen Job*, nicht den Zustand
des Repos ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Der Anlass:** `actions/checkout` klont per Default mit Tiefe 1; eine dabei *auflösbare, aber
leere* Range (z. B. `HEAD..HEAD`) meldet d-check ohne diesen Wächter `0 Befund(e)`, Exit 0 —
blind und grün, statt zu fallen
([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 3). Geprüft wird darum die **Range** (`git rev-list --count`), nicht die Klon-Tiefe.
`STAGED=1` prüft keine Range, sondern vergleicht den Index gegen `HEAD` (`git diff --cached`).

## Grenze — was das Grün nicht abdeckt

- **Eine *unauflösbare* Basis** (z. B. `HEAD~1` in einem Tiefe-1-Klon) deckt der Wächter **nicht
  zusätzlich** — d-check selbst bricht dafür schon mit Exit 2 ab, und ein Wächter, der nur das
  fängt, prüfte eine Eigenschaft, die das Werkzeug bereits hält.
- **`STAGED=1` prüft nicht den Inhalt.** Fehlt jede gestagte Änderung, meldet der Wächter das
  explizit statt schweigend mit Exit 0 zu enden; findet sich mindestens eine, bleibt die Ausgabe
  leer — den Inhalt der gestagten Änderung prüft dann das d-check-Modul selbst, nicht dieser
  Wächter.
- **`doc-commits` im Dogfood ist unbedienbar**, unabhängig von der Range: der `commits:`-Block
  in [`.d-check.yml`](../../.d-check.yml) trägt eine nicht-leere `id-patterns`-Liste, und jeder
  `--range`-Lauf des `commits`-Moduls bricht darunter ab (Exit 2) — Einzelheiten im Sensor
  [`commit-msg-check`](commit-msg-check.md). Das emittierte `.d-check.yml`
  (`internal/emit/templates/d-check.yml`) führt keinen `commits:`-Block; das Ziel ist darum
  bedienbar, und dort ist die Zusage messbar. Der Wächter bleibt für `doc-immutable`
  unverändert wirksam.
- **`STAGED=1` gehört zu `doc-immutable`.** Nur dessen Rezept in `d-check.mk` führt einen
  `STAGED`-Zweig (`--staged`); `doc-commits` übergibt allein `--range $(RANGE)`. Ein Aufruf
  `make doc-commits STAGED=1` prüft den Index also im Wächter, nicht im Modul.
- `.d-check.yml` aktiviert für `docs-check` selbst nur `links, anchors, ids, matrix, codepaths,
  spans, planning, targets` — keines davon liest Historie. Ein history-lesender Job braucht
  `fetch-depth: 0` an seinem Checkout **und** diesen Wächter davor.

Details und Beleg stehen im Kopf von `harness/tools/history-range-guard.sh`, Abschnitt BELEG.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | Range aufgelöst und nicht leer, oder `--staged` (unabhängig davon, ob etwas gestagt ist) |
| 1 | Range auflösbar, aber leer (0 Commits) |
| 2 | Range **nicht** auflösbar (Basis fehlt im Klon) |

## Sperren

- `Usage: history-range-guard.sh …` — kein Argument, über `make` also weder `RANGE` noch
  `STAGED=1`; die Shell bricht am leeren Parameter ab, **mit Exit 1**, derselben Zahl wie die leere
  Range → eine Range nennen. Die zwei Fälle trennt die Meldung, nicht der Exit.

## Bindung

Kein Gate-Versprechen; Vorlauf für `make adr-immutable`.

### Im gebootstrappten Ziel

Dieselbe Logik reist als emittiertes Werkzeug mit — `tools/harness/history-range-guard.sh`
([`MR-005`](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)) — und hängt dort an
**beiden** history-lesenden Targets: das Doc-Gate-Fragment des Ziels ergänzt `doc-immutable`
und `doc-commits` um den Wächter als **Vorbedingung**, er läuft also vor dem Modul-Lauf. Das
Rezept der zwei Targets bleibt das aus dem tool-generierten `d-check.mk`, das der Bootstrap
kanonisch neu schreibt. Das Ziel kennt kein `make adr-immutable`; die Bindung ist dort die
Vorbedingung selbst, und sie liegt in keinem Gate: `make gates` fährt keines der zwei Targets
(sie brauchen eine `RANGE`).

Die emittierte Fassung unterscheidet sich in einem Punkt von
[`harness/tools/history-range-guard.sh`](../tools/history-range-guard.sh): sie trägt die zwei
`--decide`-Zweige nicht, über die der Dogfood den reinen `decide()`-Kern ohne `git` prüft
(`test/history-range-guard.bats`) — im Ziel gibt es diesen Test nicht, die Entscheidung ist
dieselbe Funktion. Rot gesehen wird die Ziel-Fassung in
[`make full-smoke`](full-smoke.md): ein Klon der Tiefe 1 bricht über einer auflösbaren, aber
leeren Range an beiden Targets mit der Meldung des Wächters ab, dieselbe Range auf einem
vollständigen Klon bleibt grün. Dieselbe Stufe fährt die zwei Richtungen der Vorbindung
selbst: über einem `d-check.mk` **ohne** die Ziel-Definition bricht `make doc-immutable` bzw.
`make doc-commits` mit Exit 2 und der Meldung des Fragments ab — zweimal gefahren, mit
entfernter Ziel-Zeile und, als zweiter Auslöser derselben Klasse, mit einer Ziel-Zeile ohne
Rezept; über dem **unverfälschten** d-check.mk greift der Wächter und das Modul läuft
(Exit 0).

**Beide Hälften der Zusage sind an beiden Targets gemessen.** Der blinde Grün-Fall — dieselbe
leere Range über `-f d-check.mk`, also ohne das Doc-Gate-Fragment — meldet für `doc-immutable`
**und** `doc-commits` `0 Befund(e)` bei Exit 0; der Abbruch des Wächters ist für beide
gefahren.

**Das Fragment ist selbst fail-closed, je Ziel.** Es prüft vor der Vorbindung, ob das
eingebundene `d-check.mk` das Ziel **mit Rezept** führt — dieselbe Datei, die sein `include`
einbindet, mit `awk`, ohne Bild und ohne Netz. **Nur der belegte Ausgang wählt die Bindung**;
jeder andere — kein Treffer, eine Ziel-Zeile ohne Rezept, kein `awk` auf dem `PATH` oder eine
leere Ausgabe — fällt in den Abbruch mit Exit 2 und einer Meldung. Sonst stünde die Vorbindung
über einem Ziel ohne Rezept, und `make` endete mit Erfolg (Exit 0), statt zu fallen. Gelesen
wird die **Ziel-Zeile mit ihrer Rezept-Zeile**, nicht die `.PHONY`-Marke: `make` führt
`.PHONY` nicht als abfragbare Variable (`$(.PHONY)` expandiert leer, gemessen), und eine Datei
ohne Ziel-Zeile bleibt ohne Rezept, auch wenn ihre `.PHONY`-Marke stehenbleibt.

**Die Emission prüft die Voraussetzung der Bindung.** Beim Bootstrap bricht `AdaptMK`
(`internal/emit/emit.go`) ab, wenn das erzeugte `d-check.mk` eines der zwei Targets nicht
führt: die Vorbindungs-Zeile hätte dort kein Rezept, und `make` endete über dem Ziel mit
Erfolg, statt mit `Keine Regel` abzubrechen — fail-closed
([`MR-017`](../conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
