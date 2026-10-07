# Review — slice-neutralisierung-haelt-ihren-wortlaut-am-gepinnten-stand

**Gegenstand:** Commit `604a5aad` („Rolle Implementer: Wortlaut-Neutralisierung …") gegen den
Plan-Stand `9f6cebde`. **Rolle:** Reviewer (Modul 10), frischer Kontext. **Datum:** 2026-10-08.
**Bezug:** [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-071`](../../harness/conventions.md#mr-071), [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7.

Bruchproben liefen in Kopien unter dem Scratchpad (bats-Image aus `BATS_IMAGE`, nur
`test/neutralisierung-marker.bats`, Baum `:ro`); der Arbeitsbaum blieb unberührt.

## Findings

### HIGH-1 — Vollständigkeits-Fall bleibt grün über drei Formen einer Wortlaut-Neutralisierung

- `kategorie`: HIGH (Skill §LOW/INFO mit Eskalation, *Grenzen-Aufzählung ohne Formen-Probe* — keine Gate meldet die Folge)
- `quelle`: AGENTS.md §3.6, LH-FA-02
- `pfad`: `test/neutralisierung-marker.bats:16-17` (Grenze), `:76-80` (Erkennung)
- `befund`: Der Fall „die Marker-Tabelle nennt jede Konstante, die templates.go an
  strings.ReplaceAll gibt" erkennt nur `strings.ReplaceAll(s, <id>,` und nur `const <id> = "…"`;
  die Grenze nennt allein das String-Literal. Gefahren — je eine unbekannte Marker-Konstante, die
  die Vorlage nicht trifft, an `templates.go` angehängt:

  | Form | Ergebnis |
  |---|---|
  | `const sMarker = "…"` + `ReplaceAll(s, sMarker, …)` | `not ok 3` (rot, Tabelle unvollständig) |
  | `const bodyMarker = "…"` + `ReplaceAll(body, bodyMarker, …)` | alle drei `ok` |
  | ``const rawMarker = `…` `` + `ReplaceAll(s, rawMarker, …)` | alle drei `ok` |
  | `const ( grpMarker = "…" )` + `ReplaceAll(s, grpMarker, …)` | alle drei `ok` |

  Failure-Szenario: eine neue Wortlaut-Neutralisierung in `neutralisiereJeDatei` — dort heißt der
  Text `body` — oder als Raw-String/Gruppen-Konstante wird am gepinnten Stand ein stiller No-op,
  und kein Fall wird rot, obwohl der Testname „jede Konstante" zusagt. Die Grenz-Zeile nennt keine
  der drei grünen Formen.
- `verifizierbar`: ja (die Sonden oben, rot erwartet)
- `klasse`: Vollständigkeits-Wächter erkennt eine Teilmenge der Formen und filtert den Rest still

### MEDIUM-1 — Entfernen von `NeutralizeRoadmap` ist nur am Default-Pin verhaltensneutral

- `kategorie`: MEDIUM (Bezug-/Abdeckungslücke)
- `quelle`: LH-FA-02
- `pfad`: `internal/emit/templates.go:459-461` (entfernter `case roadmapTemplate`); `cmd/ai-harness-init/main.go:504`
- `befund`: Am Pin `v6.17.0` trifft der Marker 0-mal (Rot-Werkzeug DoD 1 nachgefahren: alte
  `templates.go` + Tabellenzeile `roadmapDoneLink:roadmapTemplate` → `roadmapDoneLink: 0 Treffer in
  docs/plan/planning/roadmap.template.md (v6.17.0)`); `ReplaceAll` mit 0 Treffern ist die
  Identität, die emittierte Roadmap bleibt am Pin byte-gleich, ihre Platzhalter-Links
  (`../done/<welle-id>-results.md`, Zeile 107) fängt `NeutralizePlaceholderLinks`. Der Bootstrap
  nimmt aber `COURSE_TAG` (opt-in, im Benutzerhandbuch mit `COURSE_TAG=v3.5.2` als Beispiel), und
  im Kurs-Klon trägt `lab/templates/docs/plan/planning/roadmap.template.md` den Marker an `v3.5.2`,
  `v6.0.0`, `v6.5.0` (je 1 Treffer, `` git -C <kurs> grep -c 'welle-NN-results.md`](../done/' <tag> ``),
  an `v6.8.0` nicht mehr. Failure-Szenario: ein Bootstrap mit einem solchen Tag emittiert jetzt
  den toten Link `../done/welle-NN-results.md`, den das emittierte `links`-Modul rot meldet. Der
  Plan §1 grenzt `COURSE_TAG` nicht ab; ob ältere Tags sonst gate-sicher emittieren, ist nicht
  gemessen.
- `verifizierbar`: nein (kein Gate bootstrappt einen Nicht-Default-Tag)
- `klasse`: Pin-gebundene Entfernung ohne Abgrenzung des Opt-in-Tags

### INFO-1 — `# expect:` nennt den Testnamen statt der Meldung

- `kategorie`: INFO
- `quelle`: Plan DoD 2, MR-071
- `pfad`: `test/mutations/561-neutralisierungs-marker-verfehlt-den-gepinnten-stand.sh:3`
- `befund`: Der Plan verlangt die gelesene Meldung als `expect:`. `form_matched`
  (`harness/tools/mutate.sh:618-622`) sucht `expect` nur in Zeilen der Form `not ok [0-9]+`; die
  Meldung steht in `#`-Zeilen und wäre dort nie zu finden — der Testname ist die einzige
  bindende Wahl. Die Meldung steht im Fall-Kopf. Der Fall unterscheidet damit nicht, welcher der
  zwei Marker rot wurde.
- `verifizierbar`: ja
- `klasse`: —

## Gefahrene Kommandos

- `make mutate MUTATE_CASES=561-neutralisierungs-marker-verfehlt-den-gepinnten-stand` →
  `mutate: 1 ok, 0 Befund(e)` (der Kurzname `561` bricht ab: „unbekannter Fall").
- Gegenprobe (Mutation angewandt, `skip` ausschließlich in Fall 2): `ok 1`, `ok 2 # skip`, `ok 3`
  — Fall 2 bindet die Mutation allein.
- Unveränderte Kopie: drei `ok`.
- Restbezüge: `grep -rn 'NeutralizeRoadmap\|roadmapDoneLink\|RoadmapGateSafe\|29-roadmap'` außerhalb
  `done/`, `docs/reviews/`, `dist/`, Spans → nur Plan und
  `observations/BEO-ALL/emittierte-neutralisierung-greift-am-vendorten-stand-nicht/observation.md`
  (Closure-Sache, bestätigt).

## Geprüft, ohne Befund

- (a) Fixture `courseSet()`: der neue Kommentar zur Roadmap stimmt — `eingebettet` trägt
  `../<welle-NN-titel>.md`.
- (b) Fall 2 liest Pin (`DefaultTag`), Marker (`templates.go`) und vendored Vorlage — reale Quelle,
  keine Fixture; Fall 1 hält die Vorbedingung, die leere Tabelle/leeren Pin-Wert fail-closed macht.
- (c) Doc-Kommentare in `templates.go` (§3.7): Zusage + Sensor, keine Chronik; die zwei
  verbleibenden Konstanten treffen je genau 1-mal.
- (d) Plan-Konformität Liefer-Punkte 1–2: Funktion, Konstante, Aufruf, zwei Tests, Fixture-Zeile,
  Fall 29 entfernt; `roadmapTemplate` bleibt genutzt (`templates.go:545`).
