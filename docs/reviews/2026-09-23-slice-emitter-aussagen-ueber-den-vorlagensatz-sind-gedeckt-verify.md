# Verifikation `slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt`: DoD 1 bis 3 erfüllt, Rot-Belege für Fall 397 und 398 nacheilend erbracht, ein Plan-Diff für die Closure

**Rolle:** Verifier · **Datum:** 2026-09-23 · **Geprüfter Stand:** `fa125cf8` (= Inhalt der Kette
`6c261398..fa125cf8`, ein Implementer-Commit; `HEAD` ist der Review-Report-Commit `d9bb77fc`,
Arbeitsbaum sauber vor diesem Bericht). **Verifikations-Art:** DoD- und ADR-Konformität gegen den
tatsächlichen Baum (`v6.9.0` · `regelwerk/modul-11-verification.md`). Das ist kein Review.
**Modell:** `glm-5.3-flash[1m]`.

**Eingang:**

- der Slice-Plan `slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt` §1 bis §8, Stand im
  Pfad `in-progress/`;
- der Umsetzungs-Commit `fa125cf8` (`Rolle Implementer: …`), Bereich `6c261398..fa125cf8`;
- der Review-Report vom 2026-09-22 (Verdikt: kein Merge-Blocker, 1 MEDIUM, 1 LOW). Er ist als
  Kontext gelesen, nicht als Beleg: Jede Aussage unten beruht auf einem eigenen Lauf;
- [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`ADR-0057`](../plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline).

---

## 1. Ergebnis je DoD-Punkt

| DoD-Punkt | Status | Beleg |
|---|---|---|
| **(1)** — Wächter `TestDispositionen_DeckenBezugsmengeVollstaendigUndDisjunkt` hält vier Dispositionen gegen die aus `emit.inScope` abgeleitete Bezugsmenge, in zwei Richtungen | **erfüllt** | §2.2 und §2.3. `internal/emit/templates_test.go` (Zeilen 1053–1157): die Bezugsmenge wird über `fs.WalkDir` mit `emit.InScope(rel)` **abgeleitet**, nicht ein zweites Mal aufgezählt (Zeilen 1116–1131). Jede der vier Dispositionen wird **einzeln** ausgewertet (`treffer`-Map, Zeilen 1135–1140) — nicht über die kurzschließende `||`-Kette des Dispatchs in `planTemplates`; die Aufrufform stimmt mit dem Dispatch überein (`emit.IsRecurring(path.Base(rel))`, templates.go:355). **Vollständigkeit** färbt in `case 0` (Zeile 1150), die Meldung nennt Pfad **und** den geprüften Ausschnitt; **Disjunktheit** färbt im `default`-Zweig (Zeile 1154). Die Singleton-Menge steht als **benannte Liste im Prüfbereich** (`singletonBezugsmenge`, 10 Einträge) — im Emitter ist sie der Default ohne Aussage (templates.go, planTemplates: „WER HIER EINE VORLAGE NICHT EINTRAEGT, ENTSCHEIDET `Singleton`"). **Keine Zahl als Erwartungswert**: die einzigen `len`-Nutzungen des Wächters sind `len(bezugsmenge) == 0` (Leerlauf-Sperre) und `switch len(mitglied)` (die gemessene Eigenschaft); kein `== 24`, keine Vorlagen-Kardinalität behauptet — die `24` in den Fehlermeldungen ist informativ (`len(bezugsmenge)`, awk-Beleg §2.3). Die vier Dispositionen tragen je eine Aussage in `dispositionsAussagen`; drei Zitate wurden gegen `spec/lastenheft.md` §LH-FA-02 verbatim geprüft, `isBrownfieldOnly` trägt den benannten Befund mit Adressat (Change Request, `MR-036`) — die von DoD 2 geforderte Form. **Kopplung an den realen Satz:** der Wächter liest `courseSet()`; dessen Treue hält `test/courseset-fixture.bats` (Dateibestand per `diff`, in-scope 24 mit dem zählenden Kommando daneben, `isRecurring`-Rumpf gegen die aus dem realen vendored Satz abgeleitete Menge) — der Test läuft im `make gates`. |
| **(2)** — jede Weiche einer Aussage in `LH-FA-02` zugeordnet, vollständig | **erfüllt** | `dispositionsAussagen` führt vier Einträge (drei Weichen + die Voreinstellung Singleton); `len(dispositionsAussagen) != 4` und die Leer-String-Prüfung färben rot, sobald eine Weiche ohne zugeordnete Aussage dasteht — derselbe Test ist der Rot-Pfad. Die `4` ist der strukturelle Nenner aus DoD 2 (Kommando (b) aus §1 plus Voreinstellung), keine Messgröße über den Bestand. `isBrownfieldOnly` trägt statt eines Zitats den benannten Befund mit Adressat — der `GRENZE`-Kommentar an `isBrownfieldOnly` (templates.go:147–149) existierte bereits und ist im Diff nicht verändert. |
| **(3)** — drei Proben gegen den geltenden Vorlagensatz, Zusage trägt das Ergebnis | **erfüllt** | §2.1. Die drei Proben (templates.go, Block unter `StripCommentHints`) nennen `T=.harness/baseline/v6.9.0/templates`; der vierte Kommentar-Block (`unmaskQuotedCommentSyntax`) nennt denselben Tag. Der Tag ist **der aus `harness/conventions.md` §Baseline** (Zeile 11: `**Stand:** \`v6.9.0\``), nicht ein im Plan eingefrorener (`MR-033`). `git grep -c 'v6\.7\.2' -- internal/emit/templates.go` → **0** (Exit 1, keine Ausgabe). Jeder Operand löst auf (`[ -e ]`). Alle Proben wurden von diesem Lauf selbst gefahren: gegen `v6.9.0` **alle leer**, gegen den abgelösten `v6.7.2`-Baum **Fehler statt leer** (exit 2, „No such file or directory") — die Rot-Beschreibung aus DoD 3 ist damit unabhängig vom Reviewer-Report bestätigt. |
| `make gates` grün | **erfüllt, nicht erneut gefahren** | Auftrag: nicht nochmal fahren. Die Aufzeichnung `.harness/state/gates-passed.diffsha` (Stand heute 04:27) trägt `5cac1af4…75be4`, und `harness/tools/working-tree-hash.sh` liefert über dem aktuellen Baum **denselben** Hash — die Aufzeichnung deckt den geprüften Stand. Die zweite Hälfte des Triggers (das `git grep` auf den abgelösten Tag) ist selbst gefahren: 0. |
| Review durchgeführt, Report unter `docs/reviews/` | **erfüllt** | `docs/reviews/2026-09-22-slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt.md` (Verdikt: kein Merge-Blocker, 1 MEDIUM, 1 LOW). Als Kontext gelesen, nicht als Beleg. |
| Doku-Update | entfällt, korrekt | Kein `make`-Ziel, kein Sensor-Vertrag, keine emittierte Vorlage im Diff (§3); der Vertrag `spec/lastenheft.md` ist Vorbedingung und nicht berührt. |
| Closure-Notiz, Register, Risiko-Ausgänge, drei Paarungen | **nicht geprüft — Planner** | Closure-Pflichten (`AGENTS.md` §3.10); die Belege für die Risiko-Ausgänge stehen in §5. |
| Reconciliation-Register | entfällt | wie im Plan begründet — die Datei führt dieses Repo nicht. |

## 2. Eigene Messungen

Alle Läufe über `docker`, `make` und `git`, netzlos, gegen den sauberen Arbeitsbaum am Stand
`d9bb77fc`. Nach jedem Mutationslauf: `git checkout -- internal/emit/templates.go`,
`git status --porcelain` leer. Keine Zahl ist ein Erwartungswert.

### 2.1 DoD 3 — die Proben, selbst gefahren

Operande, geprüft mit `[ -e ]`: `.harness/baseline/v6.9.0/templates` und
`internal/emit/templates` lösen auf; `.harness/baseline/v6.7.2/templates` fehlt (abgelöst —
`.harness/baseline/` führt nur `v6.9.0`). Der Repo-weite Rest von `v6.7.2` in Code-Dateien
(`*.go`, `Makefile`, `*.mk`) ist leer; die zwei übrigen Nennungen im lebenden Bestand sind keine
Probe-Operanden (§6, V-2).

| Probe (Kommentar-Block in `internal/emit/templates.go`) | Gegenstand | gegen `v6.9.0` | Gegenprobe gegen `v6.7.2` |
|---|---|---|---|
| `grep -rn '``' "$T" --include='*.md' \| grep -e '<!--' -e '\-\->'` | „Backtick-Lauf", vendored Baum | **leer** | grep-Exit 2, `No such file or directory` — **Fehler statt leer** |
| `grep -rn '``' internal/emit/templates/ \| grep -e '<!--' -e '\-\->'` | dieselbe Form, embedded Baum | **leer** | — |
| `find "$T" -name '*.md' -print0 \| xargs -0 awk '{ c=gsub(/`/,"`"); if (c%2==1 && ($0 ~ /<!--/ \|\| $0 ~ /-->/)) print FILENAME":"FNR }'` | „zeilenübergreifendes Zitat" (ungerade Backtick-Zahl) | **leer** | — |
| `grep -rlP '\x00' .harness/baseline/v6.9.0/templates internal/emit/templates` | NUL-Byte (Block `unmaskQuotedCommentSyntax`) | **leer** | — |

Der `templates.go`-Diff der Kette ist **kommentarhaft**: zwei Hunks, 3 gelöschte/6 hinzugefügte
Zeilen — ausschließlich die drei Tag-Operanden (`v6.7.2` → `v6.9.0`). Kein Angriff auf Logik.

### 2.2 Bewusstes Brechen — Fall 397 (`disposition-doppelt-belegt`), nacheilender Rot-Beleg

Der Reviewer sah nur Fall 396 live rot; nach Modul 11 (§Bewusstes Brechen für
DoD-Testbehauptungen) trägt dieser Lauf die fehlenden Belege nach.

```sh
bash test/mutations/397-disposition-doppelt-belegt.sh     # sed-Anker trifft (git diff: 1 Zeile)
make test-go                                              # exit 2
git checkout -- internal/emit/templates.go                # Baum sauber
```

Der benannte Wächter fällt — Meldung **gelesen**:

```
--- FAIL: TestDispositionen_DeckenBezugsmengeVollstaendigUndDisjunkt (0.00s)
    templates_test.go:1154: docs/plan/planning/roadmap.template.md: in mehreren
    Dispositionen zugleich: Singleton (Default), isRecurring
    (Bezugsmenge: emit.InScope ueber courseSet(), 24 Vorlagen)
```

- Die Meldung kommt vom **benannten** Wächter (`expect:`-Zeile der Fall-Datei), aus seinem
  `default`-Zweig (Disjunktheit, `templates_test.go:1154`) — genau die in der Fall-Datei
  vorhergesagte Rot-Bedingung 2, nicht von einem anderen Zweig und nicht an einer Zahl.
- Kollateral (dieselbe Ursache — `roadmap.template.md` wird nach der Mutation nicht mehr
  emittiert): `TestTemplates_Layout`, `TestTemplates_EmittierterBestandVollstaendig`,
  `TestTemplates_RoadmapGateSafe`, `TestTemplates_KeinPlatzhalterLinkImEmittiertenSatz`,
  `TestTraegerInventur_JedeGenannteAdresseEntstehtImZiel`. Erwartete Nebeneffekte an echten
  Treffern; der benannte Wächter fällt aus seinem eigenen Zweig heraus.

### 2.3 Bewusstes Brechen — Fall 398 (`tausch-gleiche-kardinalitaet`), nacheilender Rot-Beleg

```sh
bash test/mutations/398-disposition-tausch-gleiche-kardinalitaet.sh   # Tausch, Kardinalität bleibt 11
make test-go                                                          # exit 2
git checkout -- internal/emit/templates.go                            # Baum sauber
```

Der Wächter fällt **zweifach**, beide Meldungen **gelesen**:

```
--- FAIL: TestDispositionen_DeckenBezugsmengeVollstaendigUndDisjunkt (0.00s)
    templates_test.go:1154: docs/plan/planning/roadmap.template.md: in mehreren
    Dispositionen zugleich: Singleton (Default), isRecurring …        (Disjunktheit)
    templates_test.go:1150: harness/sensors/gate.template.md: in keiner der
    vier Dispositionen …                                              (Vollständigkeit)
```

- **Nicht an einer Zahl.** Die Kardinalität von `isRecurring` bleibt bei elf Einträgen (Tausch,
  keine Addition); der Wächter-Rumpf führt **keine** Kardinalitäts-Aussage (awk über den Rumpf:
  einzige `len`-Nutzungen sind `len(bezugsmenge) == 0` und `switch len(mitglied)`). Ein Zähl-Test
  bliebe hier grün — **der Lauf ist der Beleg für Risiko 3** (§6).
- Die Meldungen stammen aus den **beiden** Zweigen des benannten Wächters (`case 0` = Zeile 1150,
  `default` = Zeile 1154) — „Zahn muss seine Zusicherung binden": nicht ein anderer Zweig, nicht
  ein anderes Testsegment.
- Kollateral wie bei 397 (dieselbe Ursachenklasse, `gate.template.md` wird als Singleton
  emittiert, `roadmap` nicht mehr): Layout, Bestand, RoadmapGateSafe, KeinPlatzhalterLink,
  TraegerInventur.

### 2.4 Fall 396 — vom Reviewer live rot gesehen, hier nicht wiederholt

Die Fall-Datei ist gelesen (sed-Anker auf dieselbe `case`-Zeile wie Fall 398 — gegen den
Quell-Bestand gemessen, `MR-071`); den Live-Rot-Lauf hat der Review-Report 2026-09-22 mit der
exakt vorhergesagten Meldung geführt. Kein Nachbeleg, den ein anderer Lauf schon erbracht hat.

### 2.5 Closure-Trigger 1 — `make gates` nicht erneut gefahren

Auftrag: der Lauf ist real gefahren (Exit 0, Review-Report §Self reproduziert) und die
Aufzeichnung vorhanden. Geprüft: die Aufzeichnung deckt den Arbeitsbaum (Hash-Gleichheit, oben);
`git grep -c 'v6\.7\.2' -- internal/emit/templates.go` → 0. Die Test-Stage (`make test-go`,
Docker-only) lief zweimal für die Rot-Belege — über `make`, nicht auf dem Host (`AGENTS.md` §3.9).

## 3. Plan-vs-Code-Diff

`git diff --stat 6c261398..fa125cf8` nennt 6 Dateien. §3 des Plans nennt `templates.go`,
`templates_test.go` und `test/mutations/` (drei Fälle).

| Richtung | Datei | Einordnung |
|---|---|---|
| geplant, gebaut | `internal/emit/templates.go` | die drei Proben (Tag-Nachzug) + Zuordnung der Weichen; Diff rein kommentarhaft (§2.1) |
| geplant, gebaut | `internal/emit/templates_test.go` | der Wächter aus DoD 1 und 2 (+107 Zeilen) |
| geplant, gebaut | `test/mutations/396-…`, `397-…`, `398-…` | die drei Fälle aus DoD 1 „Rot" |
| **gebaut, nicht geplant** | `internal/emit/export_test.go` (+20) | **reine Sichtbarkeits-Brücke**: vier Ein-Zeiler-Delegationen auf die unexportierten Weichen und `inScope`, ohne Logik, ohne Nachbau der Emit-Disposition; `_test.go`-Datei (`package emit`), fließt nie in ein Produktions-Binary. Sie ist Träger des Wächters aus DoD 1, kein zusätzlicher Liefer-Punkt; keiner der vier §1-Ausschlüsse ist verletzt (Lastenheft, Vorlagensatz, Grenz-Aussage, Emit-Disposition — nichts davon im Diff). Entspricht MEDIUM-1 des Reviewers; **Übergabe an die Closure-Notiz** (§7 „Was ging anders als geplant"). |

Keine weitere Datei über die vier hinaus. Die Commit-Message des Umsetzungs-Commits trägt die
Traceability (`LH-FA-02`, `LH-QA-01`, `LH-QA-02`, `MR-025`, `MR-033`, `ADR-0057`).

## 4. ADR- und MR-Konformität

| Quelle | Ergebnis | Beleg |
|---|---|---|
| `ADR-0057` Festlegung 1 | konform | Der Wächter bindet an die Eigenschaft gegen die aus `emit.inScope` abgeleitete Bezugsmenge, nicht an eine Aufzählung; Vollständigkeit und Disjunktheit in zwei Richtungen, jede Menge einzeln ausgewertet. |
| `ADR-0057` Festlegung 2 | konform | Der Start-Trigger nennt den Change Request ausdrücklich als keine Vorbedingung; `spec/lastenheft.md` ist nicht im Diff, der Wächter liest seine Sollmenge aus dem vendored Satz. |
| `ADR-0057` Festlegung 4 / `ADR-0020` | konform | `ADR-0020` ist im Diff nicht berührt (Accepted, unangetastet); die Zahl in Festlegung (e) bleibt datierte Messung, maßgeblich für die Menge ist ab ADR-0057 der Wächter aus DoD 1. |
| `MR-025` Setzung 2 | konform | Der Wächter behauptet keine Kardinalität (§2.3, awk-Beleg); die `24` in seinen Fehlermeldungen ist informativ; die `24` der bats-Stufe steht neben ihrem zählenden Kommando. |
| `MR-033` | konform | Die Proben nennen `v6.9.0`, identisch mit der §Baseline-Zeile von `harness/conventions.md`; kein eingefrorener Plan-Tag im Code (grep → 0). |
| `AGENTS.md` §3.6 | konform | Drei Rot-Belege für drei `test/mutations/`-Fälle — Fall 396 live (Reviewer), Fall 397 und 398 von diesem Verifier-Lauf nacheilend erbracht, Meldungen vom benannten Wächter gelesen und gegen die Fall-Dateien geprüft. |
| `AGENTS.md` §3.9 | konform | Beide Test-Läufe über `make test-go` (Docker); der Host führt nur `git`, `docker`, `make`. |

## 5. Belege für die Risiko-Ausgänge (§6, an den Planner)

**Der Ausgang vergibt hier nicht** — der Planner trägt ihn in §7 ein; hier steht die
Prüfperspektive je Risiko.

- **Risiko 1 (die Aufzählung in Rang 1 trifft den Bestand weiter nicht).** Die Differenz ist real
  gemessen: `LH-FA-02` nennt fünf wiederkehrende (ADR · slice · welle · carveout · review-report),
  `isRecurring` führt 11; der Wächter hängt an ihr nicht (`ADR-0057` Festlegung 2). Belege
  sprechen für den Ausgang *weiter offen* ins Beobachtungs-Register — ein Slice kann Rang 1
  nicht schreiben.
- **Risiko 2 (eine Probe fällt nicht leer aus).** Alle drei Proben (plus die NUL-Probe) sind
  gegen `v6.9.0` leer, eigener Lauf (§2.1). Belege für *entfallen*.
- **Risiko 3 (der Wächter misst eine Zahl statt der Zuordnung).** Fall 398 fällt zweifach an
  Vollständigkeit und Disjunktheit, während die Kardinalität von `isRecurring` unverändert bleibt,
  und der Wächter führt keine Kardinalitäts-Aussage (§2.3). Der Lauf ist der Beleg; spricht für
  *entfallen*.
- **Risiko 4 (Baseline-Sprung zwischen Plan und Lauf).** Die Proben lesen den Stand aus
  `harness/conventions.md` §Baseline (`v6.9.0`), nicht aus dem Plan; kein `v6.7.2`-Operand in
  `templates.go`. Belege für *entfallen*.
- **Risiko 5 (die Zahl-Aussage in `ADR-0020`).** `ADR-0020` ist im Diff unberührt; die Lesart
  trägt `ADR-0057` Festlegung 4, und der Wächter aus DoD 1 existiert und bindet die Menge.
  Belege für *entfallen*.

## 6. Befunde

| ID | Schwere | Befund | Beleg | Adresse |
|---|---|---|---|---|
| V-1 | INFO | **Plan-vs-Code: `internal/emit/export_test.go` ist gebaut, aber nicht in §3 des Slice-Plans** (MEDIUM-1 des Reviewers, hier bestätigt: `git diff 6c261398..fa125cf8 -- docs/plan/planning/` ist leer). Kein DoD-Verstoß — weder ein fehlender Liefer-Punkt noch eine §1-Verletzung; die Brücke ist Träger des Wächters aus DoD 1 (§3). | §3 | Planner: in der Closure-Notiz unter „Was ging anders als geplant" |
| V-2 | INFO | **Zwei `v6.7.2`-Nennungen im lebenden Bestand außerhalb des Slice-Gegenstands**: `.harness/skills/reviewer.md:4` (eigene Baseline-Kopfzeile des Skills) und `docs/migrations/v6.8.0.md` (Migrations-Report, Zeitdokument). Keine ist ein Probe-Operand, keine wurde in dieser Kette berührt; der Cutoff von §3.7 bindet den Bestand nicht. Kein Bestandteil des Diffs. | `git grep -n 'v6\.7\.2' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline'` | keine — zur Kenntnis |

**Kein Befund blockiert die Closure.** Kein Liefer-Punkt fehlt, keine §1-Grenze ist verletzt,
kein Mutationsfall bleibt ohne Rot-Beleg (alle drei rot gesehen, 397 und 398 von diesem Lauf).

## 7. Gate-Lauf

`make gates` ist **nicht erneut gefahren** (Auftrag). Beleg für Closure-Trigger 1: die
Aufzeichnung `.harness/state/gates-passed.diffsha` (`5cac1af4…75be4`, Stand heute 04:27) deckt
den Arbeitsbaum — `harness/tools/working-tree-hash.sh` liefert denselben Hash. Die zweite Hälfte
des Triggers (`git grep -c 'v6\.7\.2'` → 0) ist selbst gefahren. Danach zwei `make test-go`-Läufe
für die Rot-Belege, der Baum nach jedem Lauf zurückgesetzt und sauber.

## 8. Negativbefunde

- Der Arbeitsbaum war vor jedem Mutationslauf sauber und ist nach `git checkout` wieder sauber;
  die einzige Änderung dieses Laufs ist dieser Bericht.
- Die Weichen-Rümpfe (`isRecurring`, `isDerivativeIndex`, `isBrownfieldOnly`, `inScope`) sind in
  der Kette unverändert — der `templates.go`-Diff trägt nur Kommentar-Operanden.
- `.harness/baseline/` (der Vorlagensatz), `spec/lastenheft.md` und `docs/plan/adr/` sind nicht
  im Diff — alle vier §1-Ausschlüsse gehalten.
- Beide sed-Anker der Fälle 397 und 398 trafen den Quell-Bestand (nach Anwendung:
  `git diff` nicht leer — kein stummer No-op, `MR-071`).
- Der benannte Wächter fällt in beiden Läufen aus seinen eigenen Branches (`case 0` / `default`)
  heraus, mit der in der jeweiligen Fall-Datei vorhergesagten Meldung; die übrigen FAILs sind
  Kollateral an echten Emit-Änderungen, nicht der alleinige Signalfall.
- `make gates` wurde nicht erneut gefahren; der Nachweis läuft über die Hash-Gleichheit der
  Aufzeichnung, nicht über einen zweiten Lauf.