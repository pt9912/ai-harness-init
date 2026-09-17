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

### Im gebootstrappten Ziel — Vertrag

Dieselbe Logik reist als emittiertes Werkzeug mit — `tools/harness/history-range-guard.sh`
([`MR-005`](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)) — und hängt dort an
**beiden** history-lesenden Targets: das Doc-Gate-Fragment des Ziels ergänzt `doc-immutable`
und `doc-commits` um den Wächter als **Vorbedingung**, er läuft also vor dem Modul-Lauf. Das
Rezept der zwei Targets bleibt das aus dem tool-generierten `d-check.mk`, das der Bootstrap
kanonisch neu schreibt. Das Ziel kennt kein `make adr-immutable`; die Bindung ist dort die
Vorbedingung selbst, und sie liegt in keinem Gate: `make gates` fährt keines der zwei Targets
(sie brauchen eine `RANGE`).

## Grenze — was das Grün nicht abdeckt

- **Eine *unauflösbare* Basis** (z. B. `HEAD~1` in einem Tiefe-1-Klon) fängt der Wächter **selbst**
  ab: `git rev-list --count` schlägt fehl, er meldet die Basis als *nicht auflösbar* und endet mit
  2 (`grep -n 'NICHT aufloesbar' ../tools/history-range-guard.sh`). Das ist keine doppelte
  Prüfung ohne Gegenstand: d-check bricht für diesen Fall erst seit `v0.76.3` unabhängig von der
  Klassen-Konfiguration ab. Gemessen am frisch emittierten Ziel (dessen `.d-check.yml` weder
  `vcs:` noch `commits:` führt), am Wächter vorbei über `docker run` mit dem Digest des Ziels,
  `--range deadbeef..cafebabe`: unter `v0.76.3` `d-check: error: Range-Basis "deadbeef" nicht
  auflösbar: reference not found`, Exit 2, für `vcs` und für `commits`; unter `v0.76.1` an
  derselben Stelle `d-check: 20 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — blind und grün. Im
  Dogfood, dessen `.d-check.yml` beide Blöcke führt, brach d-check schon vorher ab.
- **`STAGED=1` prüft nicht den Inhalt.** Fehlt jede gestagte Änderung, meldet der Wächter das
  explizit statt schweigend mit Exit 0 zu enden; findet sich mindestens eine, bleibt die Ausgabe
  leer — den Inhalt der gestagten Änderung prüft dann das d-check-Modul selbst, nicht dieser
  Wächter.
- **`doc-commits` im Dogfood hängt am Objektspeicher des Klons.** Der `commits:`-Block in
  [`.d-check.yml`](../../.d-check.yml) trägt eine nicht-leere `id-patterns`-Liste. Ein Pack, dessen
  Name nicht mit `pack-` beginnt, ist kein Abbruchgrund mehr: Der gepinnte d-check liest jedes
  Pack mit gültigem Hash-Suffix und passender `.idx`. Gemessen am Stand `v0.76.3` an einer
  Wegwerf-Kopie, deren Objekte vollständig in einem `loose-*.pack` mit passender `.idx` liegen
  (`ls .git/objects/pack/`, keine Alternates, `count: 0`): `make doc-commits
  RANGE=c414119b..ebb76b3d` meldet dort 1 × `commit-untraceable`, make-Exit 2, und
  `make adr-immutable RANGE=8ae647cc~1..8ae647cc` meldet `0 Befund(e)`, make-Exit 0 — unter
  `v0.76.1` brachen beide an derselben Kopie mit `Range-Basis "<hash>" nicht auflösbar: reference
  not found` ab, make-Exit 2. **Abbruchgründe bleiben zwei:** ein wirklich fehlendes Objekt der
  Range (dieselbe Kopie ohne die `.idx` des Packs: Exit 2, dieselbe Meldung, unter `v0.76.3`) und
  ein Klon, der seine Objekte über Alternates liest (`git clone --shared`: beide Ziele Exit 2,
  dieselbe Meldung, unter `v0.76.3` wie unter `v0.76.1`). Geprüft hat der Lauf in den gemessenen
  Klonen ohne Alternates, deren Objekte in einem Pack mit gültigem Index oder lose liegen; dass
  diese Formen genügen, ist nicht belegt. Einzelheiten und die gemessenen Formen im Sensor
  [`commit-msg-check`](commit-msg-check.md). Das emittierte
  `.d-check.yml` (`internal/emit/templates/d-check.yml`) führt keinen `commits:`-Block; dort ist
  das Ziel bedienbar, und die Zusage ist messbar. Der Wächter bleibt für `doc-immutable`
  unverändert wirksam.
- **`STAGED=1` gehört zu `doc-immutable`.** Nur dessen Rezept in `d-check.mk` führt einen
  `STAGED`-Zweig (`--staged`); `doc-commits` übergibt allein `--range $(RANGE)`. Ein Aufruf
  `make doc-commits STAGED=1` prüft den Index also im Wächter, nicht im Modul.
- `.d-check.yml` aktiviert für `docs-check` selbst die Module, die `grep -n '^modules:' .d-check.yml`
  nennt — keines davon liest Historie, gemessen am Stand `v0.76.3` mit dem Kommando aus
  [`AGENTS.md`](../../AGENTS.md) §3.8. Ein history-lesender Job braucht
  `fetch-depth: 0` an seinem Checkout **und** diesen Wächter davor.

Details und Beleg stehen im Kopf von `harness/tools/history-range-guard.sh`, Abschnitt BELEG.

### Im gebootstrappten Ziel — Grenze

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

**Beide Hälften der Zusage sind an beiden Targets gemessen, jede an ihrem Aufbau.** Der Abbruch
des Wächters läuft an beiden Targets über dem flachen Klon. Der blinde Grün-Fall — dieselbe
leere Range über `-f d-check.mk`, also ohne das Doc-Gate-Fragment — trägt `doc-immutable` am
**flachen** und `doc-commits` am **vollständigen** Klon; beide führen dieselbe auflösbare, aber
leere Range (`git rev-list --count HEAD..HEAD` → **0**), und die Stufe prüft das vorab.

Warum zwei Aufbauten, gemessen am frisch emittierten Ziel unter dem gepinnten `v0.76.3`,
`--range HEAD..HEAD`, ohne Wächter:

| Aufbau | `doc-immutable` | `doc-commits` |
|---|---|---|
| vollständiger Klon | `0 Befund(e)`, Exit 0 | `0 Befund(e)`, Exit 0 |
| flacher Klon (Tiefe 1 über zwei Commits) | `0 Befund(e)`, Exit 0 | `d-check: error: Range-Basis-Vorfahren nicht lesbar: object not found`, Exit 2 |

Der **Anlass** des Wächters — die auflösbare, aber leere Range — bleibt an beiden Aufbauten
ungedeckt; das ist die Klasse, gegen die er steht. Der flache Klon legt daneben eine
**unauflösbare Vorfahren-Kette** vor, und die nimmt `v0.76.3` dem Wächter ab, aber nur am Modul
`commits`, das die Range über die Vorfahren auflöst — `vcs` löst nur die zwei Bäume auf. Unter
`v0.76.1` meldete auch `doc-commits` im flachen Klon `0 Befund(e)` bei Exit 0.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | Range aufgelöst und nicht leer, oder `--staged` (unabhängig davon, ob etwas gestagt ist) |
| 1 | Range auflösbar, aber leer (0 Commits) |
| 2 | Range **nicht** auflösbar (Basis fehlt im Klon) |

## Sperren

- `Usage: history-range-guard.sh …` — kein Argument, über `make` also weder `RANGE` noch
  `STAGED=1`; die Shell bricht am leeren Parameter ab → eine Range nennen. Beim Direktaufruf endet
  das Skript damit mit 1, derselben Zahl wie bei der leeren Range; die Meldung trennt die zwei
  Fälle. Über `make history-range-guard` endet jeder Abbruch des Wächters mit 2.

### Im gebootstrappten Ziel — Sperren

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

## Bindung

Kein Gate-Versprechen; Vorlauf für `make adr-immutable`.
