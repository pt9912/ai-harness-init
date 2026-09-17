# Verifikation `slice-stilllegungs-form-hat-einen-waechter`: DoD 1 bis 3 erfüllt, zwei LOW für die Sensor-Datei, ein Plan-Diff für die Closure

**Rolle:** Verifier · **Datum:** 2026-09-17 · **Geprüfter Stand:** `86fd6508` (= `HEAD` vor diesem
Bericht, Arbeitsbaum sauber). Geprüft ist die Kette `ef756260..86fd6508`
(`git log --oneline ef756260..86fd6508 | wc -l` → `6`).
**Verifikations-Art:** DoD- und ADR-Konformität gegen den tatsächlichen Baum
(`v6.9.0` · `regelwerk/modul-11-verification.md`). Das ist kein Review.
**Modell:** `claude-opus-5[1m]`.

**Eingang:**

- der Slice-Plan `slice-stilllegungs-form-hat-einen-waechter` §1 bis §8, Stand im Pfad
  `in-progress/`;
- die Umsetzung: Implementer-Commits `8366b374` und `61a6fe61`; Architect-Commits `510b7ac7`
  (`AGENTS.md` §3.8/§3.10) und `be2f8b83` (Verdikt zu F-1);
- beide Review-Reports vom 2026-09-17 (Runde 1: 1 HIGH, 1 MEDIUM; Runde 2: 0 HIGH, 0 MEDIUM,
  2 LOW, 4 INFO) und das Architect-Verdikt. Sie sind als Kontext gelesen, nicht als Beleg: Jede
  Aussage unten beruht auf einem eigenen Lauf;
- `ADR-0056`, `MR-001`, `MR-010`, `MR-054`, `MR-055`, `MR-062`, `AGENTS.md` §3.5 und §3.11;
- Fremdquelle, nur lesend: der lokale Klon des d-check-Repos (eine CR-Antwort zu `hint`).

---

## 1. Ergebnis je DoD-Punkt

| DoD-Punkt | Status | Beleg |
|---|---|---|
| **1** — `structure` mit `open-tasks-require-marker` für die `done/`-Pläne, Marke in §7, §2 gezählt, 0 Befunde, Prüfbereich und Grenze mit Kommando | **erfüllt** | `.d-check.yml` führt `structure` in `modules:` und eine Regel über `done/slice-*.md` mit `section-pattern: '^## 2\. Definition of Done$'`, `max-open-tasks: 0`, `open-tasks-require-marker: "Gegenstand"` und `open-tasks-require-marker-section: '^## 7\. Closure-Notiz'`. `make docs-check` im Gate-Lauf: `1604 Datei(en) geprüft, 0 Befund(e)`. Die Zahlen-Kommandos der Sensor-Datei geben am Stand dieselben Werte aus (§2.1). Dass die Marke **in §7** gesucht wird, ist rot gesehen (V4, M2). Die Muster sind gegen alle Überschriften gemessen: Kein Plan in `done/`, `open/`, `next/` oder `in-progress/` weicht ab (§2.1). Prüfbereich, Ausnahmeliste und Grenzen stehen mit Kommando in `harness/sensors/docs-check.md` §Modul `structure`. |
| **2** — Rot gesehen, Meldung gelesen, Grenze `make mutate` benannt | **erfüllt**, mit V-2 | Selbst gefahren, in Kopien im Scratchpad außerhalb des Repos (§2.2): Ein stillgelegter Slice ohne `Gegenstand:` meldet genau einen `section-open-tasks-marker-missing` auf seiner §2-Überschrift (V1). Mit der Zeile bleibt er ohne Befund (V2). Ein regulär gelieferter Slice mit allen Häkchen bleibt ohne Befund (V6). Gegenprobe: Ohne `structure` in `modules:` bleibt V1 ohne Befund (V9). Die Meldung passt zu diesem Treffer (§2.2). Die Kommandos stehen in der Message von `8366b374`. Die Grenze *„`make docs-check` gibt keine Fehlschlag-Form von `make mutate` aus“* steht in der Sensor-Datei und trifft zu. Die Zahl im selben Satz ist falsch: V-2. |
| **3** — `MR-054`-Kriterien je mit Messung, Entscheidung und Grund in der Sensor-Datei, Vorlage unverändert | **erfüllt** | An einem frisch emittierten Ziel selbst nachgemessen (§2.3): Kriterium 2 ist nicht erfüllt (`section-missing`, *„Regel trifft keine Datei …“*), Kriterium 3 ebenfalls nicht (kein Zahn in `harness/tools/full-smoke.sh`, das Rot entsteht nur von Hand). `git diff --stat ef756260 86fd6508 -- internal` gibt nichts aus. Die Vorlage `internal/emit/templates/d-check.yml` enthält kein `structure` (`grep -c` → `0`), und das emittierte Ziel führt `modules: [links, anchors, ids, matrix, spans]`. Die Sensor-Datei nennt Entscheidung und Grund. |
| `make gates` grün | **erfüllt** | §7 |
| Review durchgeführt, Report liegt vor | **erfüllt** | zwei Review-Reports und ein Architect-Verdikt vom 2026-09-17 unter `docs/reviews/`; Runde 2 blockiert nichts |
| Doku-Update: `docs-check.md` nennt Bedingung, Prüfbereich, Gegenbeispiel | **erfüllt** | `harness/sensors/docs-check.md` §Modul `structure` (Was es hält · Prüfbereich · Tabelle V0–V9, M1–M3 · Grenzen · emittiertes Gate) |
| Closure-Notiz, Register, Risiko-Ausgänge, Paarungen | **nicht geprüft, Planner** | Closure-Pflichten (`AGENTS.md` §3.10); Belege für die Risiko-Ausgänge in §5 |
| Reconciliation-Register | entfällt | wie im Plan begründet; zur Form des Häkchens siehe §5.3 |

## 2. Eigene Messungen

Alle Läufe über `docker`, `make` und `git`, netzlos. Die Basis-Kopie entsteht per
`git archive HEAD` (`86fd6508`) im Scratchpad außerhalb des Repos; jede Lage bekommt eine frische
Kopie davon. Gefahren ist das Gate selbst, `make -s -C <kopie> docs-check`, mit dem Digest aus
`d-check.mk` (`v0.76.1`, `sha256:1470ecdc…33b3`). `git status --porcelain` im Arbeitsbaum war nach
jedem Lauf leer. Keine Zahl ist ein Erwartungswert.

### 2.1 Prüfbereich und Muster (DoD 1)

Die Kommandos aus `harness/sensors/docs-check.md` §Modul `structure`, am Stand gefahren:

| Kommando (gekürzt) | Ausgabe | Sensor-Datei |
|---|---|---|
| `ls docs/plan/planning/done/slice-*.md \| wc -l` | 177 | 177 |
| `grep -lE '^\s*[-*] \[ \]' docs/plan/planning/done/*.md \| wc -l` | 31 | 31 |
| die `awk`-Schleife über die Überschriften offener Items | nur `## 2. Definition of Done` | dasselbe |
| `sed -n '/^structure:/,/^# targets/p' .d-check.yml \| grep -c …` | 30 | 30 |
| `ls docs/plan/planning/{open,next}/slice-[0-9]*.md \| wc -l` | 65 | 65 |
| `grep -lE '^(- )?\*\*Gegenstand:\*\*' docs/plan/planning/done/slice-*.md \| wc -l` | 9; davon trägt nur `slice-135` offene Items (5) | 9, *„keiner außer `slice-135`“* |
| `grep -lE '^\s*- \[ \] Die drei Paarungen' docs/plan/planning/done/slice-*.md \| wc -l` | 7 | 7 |

Zusätzlich gemessen:

- **Die Ausnahmeliste ist genau die Differenz.** Die Menge der Pläne mit offenen Items und die 30
  Einträge unter `exempt-paths` unterscheiden sich per `comm -3` in genau einer Datei, dem
  stillgelegten `slice-135-d-check-pin-v0661.md`. Jeder Eintrag existiert. Keiner trägt eine
  Marke in §7. Keine Datei außerhalb von `slice-*.md` trägt offene Items.
- **Die Muster treffen den ganzen Bestand.** Gezählt ist mit `grep -L '^## 2\. Definition of Done$'`
  und `grep -L '^## 7\. Closure-Notiz'`. In `done/` fehlt keiner der 177 Pläne die exakte
  §2-Überschrift oder die §7-Überschrift. Dasselbe gilt für `open/` (72), `next/` (21) und
  `in-progress/` (1), also für jede künftige Stilllegung aus dem heutigen Bestand.
- **Keine Namenskollision.** Kein Dateiname aus `open/`, `next/` oder `in-progress/` steht in
  `exempt-paths` (`comm -12` → `0`).
- **Die Marke wird in §7 gesucht, und das trägt.** V4: Ein stillgelegter Slice mit
  `- **Gegenstand:** …` in §2 statt §7 meldet `section-open-tasks-marker-missing`. M2: Ohne
  `open-tasks-require-marker-section` meldet der unveränderte Bestand genau einen
  `section-open-tasks-marker-missing`, und zwar in `slice-135` (`:211`), dessen Marke in §7 steht.
  M1: Ohne beide Marker-Schlüssel meldet der Bestand 5 × `section-tasks-open` in `slice-135`
  (`:221`, `:230`, `:248`, `:268`, `:275`). Beide Zeilen der Sensor-Tabelle stimmen.
- `make -s -C <kopie> doc-structure` über dem unveränderten Bestand: `1604 Datei(en) geprüft,
  0 Befund(e)`, wie `harness/sensors/doc-structure.md` sagt.

### 2.2 Bewusstes Brechen (DoD 2)

Die Sonde ist der Plan dieses Slice aus `in-progress/`: Alle DoD-Punkte sind leer, und §7 trägt
keine Zeile in Marken-Form. Er liegt in der Kopie als `done/slice-verifier-sonde.md`, einem Namen,
der nicht in `exempt-paths` steht. Seine relativen Links lösen aus `done/` gleich auf
(`target-missing` in V1: `0`).

```sh
git archive HEAD | tar -x -C <basis>; cp -a <basis> <kopie>
cp <plan dieses Slice> <kopie>/…/done/slice-verifier-sonde.md
make -s -C <kopie> docs-check
```

| Lage | make-Exit | Ausgabe |
|---|---|---|
| V0 Bestand unverändert | 0 | `1604 Datei(en) geprüft, 0 Befund(e)` |
| **V1** stillgelegt, §7 ohne `Gegenstand:` | 2 | `1605 …, 1 Befund(e)`: `…/slice-verifier-sonde.md:89` · `section-open-tasks-marker-missing` |
| **V2** wie V1, `- **Gegenstand:** entfallen: …` direkt unter der §7-Überschrift | 0 | `1605 …, 0 Befund(e)` |
| V2p wie V1, `- Gegenstand: entfallen: …` ohne Fettung in §7 | 2 | `section-open-tasks-marker-missing` (V-3) |
| V3 wie V1, die Platzhalter-Zeile der Vorlage in §7 | 0 | `0 Befund(e)` — die Grenze *„Form, kein Inhalt“* hält |
| V4 wie V1, `Gegenstand:` in §2 statt §7 | 2 | `section-open-tasks-marker-missing` |
| **V6** regulär: alle `- [ ]` auf `- [x]`, ohne `Gegenstand:` | 0 | `0 Befund(e)` |
| V7 wie V6, je ein offenes Item in §1, §6, §7 und §8 | 0 | `0 Befund(e)` |
| V8i wie V6, ein eingerücktes offenes Item in §2 | 2 | `section-open-tasks-marker-missing` |
| **V9** wie V1, `structure` aus `modules:` genommen (Block bleibt) | 0 | `0 Befund(e)` |
| M3 wie V1, Block **und** Aktivierung entfernt | 0 | `0 Befund(e)`; dazu `test/doc-block-marke-wiring.bats` im gepinnten bats-Image: `not ok 1 doc-*: C-Menge …`, der Diff nennt `-doc-structure`. Kontrolle auf der Basis-Kopie: `ok 1`, `ok 2` |
| V10 der nummerierte `slice-067-pretooluse-ausgabeform.md` aus `open/` unter eigenem Namen in `done/` | 2 | `section-open-tasks-marker-missing` auf `:42`; daneben `closure-note-thin` (sein §7 ist ein Satz) |
| V11 wie V1, §2-Überschrift `## 2. Definition of Done (stillgelegt)` | 2 | `section-missing` auf `:1`, vierte Spalte: der `hint` (V-1) |
| V12 wie V1, aber unter `done/welle-sonde/` | 2 | kein `structure`-Befund; 19 × `target-missing` aus der tieferen Lage. Der Glob ist flach, wie benannt |
| V13 Bestand, eine Datei aus `exempt-paths` gelöscht | 0 | `1603 …, 0 Befund(e)` (V-4) |
| V14 Bestand, alle flachen `done/slice-*.md` gelöscht | 2 | `section-missing` · *„Regel trifft keine Datei (auch nach Abzug von exempt-paths) — das Gate liefe leer“* |

**Die Meldung von V1, gelesen.** Die vierte Spalte lautet *„offene DoD-Punkte in done/ —
geliefert: abhaken; stillgelegt: §7 trägt **Gegenstand:** mit Kennung oder Grund“*. Der Treffer ist
ein stillgelegter Slice mit offenen DoD-Punkten und ohne Marke in §7. Die Meldung nennt beide
Ursachen, die ein offener Punkt in `done/` haben kann, und für den stillgelegten Fall genau die
fehlende Zeile samt ihrem Ort. Die Zeilennummer `:89` ist die §2-Überschrift der Sonde. Der
Grund-Code benennt die fehlende Marke. Die Begründung passt zu diesem Treffer.
Dieselbe Meldung erscheint bei V8i, also bei einem gelieferten Slice, und passt dort über den
ersten Ausweg.

**Grenze `make mutate`.** `harness/tools/mutate.sh`, Funktion `failure_form` (Zeilen 587–599),
führt die Stufen `test`, `test-go`, `test-bats`, `smoke`, `full-smoke` und `ci-lint`. Eine Stufe
für `docs-check` gibt es nicht. Die DoD-Aussage stimmt; zur Zahl im Satz siehe V-2.

### 2.3 Das emittierte Ziel (DoD 3)

Der Träger kommt aus `make host-bin` im Gate-Lauf dieses Berichts. Ein leeres git-Repo im
Scratchpad, darin `ai-harness-init --lang go --name probe`, Exit 0. Das Ziel pinnt
`DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.76.1`, und `done/` enthält nur `.gitkeep`.

| Lage im Ziel | make-Exit | Ausgabe |
|---|---|---|
| E0 unverändert | 0 | `20 Datei(en) geprüft, 0 Befund(e)`; `grep -c structure .d-check.yml` → `0` |
| E1 `structure` in `modules:` + die Regel dieses Repos ohne `exempt-paths` und ohne `hint` | 2 | `section-missing` · *„Regel trifft keine Datei (auch nach Abzug von exempt-paths) — das Gate liefe leer“* |
| E2 wie E1, die vendored `slice.template.md` als `done/slice-sonde.md` | 0 | `21 …, 0 Befund(e)`; die Vorlage trägt `- **Gegenstand:** <…>` in §7 |
| E3 wie E2, ohne die `Gegenstand:`-Zeile | 2 | `section-open-tasks-marker-missing` auf `:79` · *„offene Task-Items ohne die geforderte Marke **Gegenstand:**“* |
| E4 unverändertes Ziel-Gate + dieselbe Vorlagen-Kopie | 0 | `0 Befund(e)`; die Sonde allein färbt nichts |

Kriterium 2 ist damit am frischen Bestand nicht erfüllt (E1). Kriterium 3 ist von Hand rot
gesehen (E3), aber ohne Zahn: `grep -ciE 'structure|open-tasks' harness/tools/full-smoke.sh` → `0`.
`MR-055` Setzung 3 wertet das als nicht erfüllt. Kriterium 1 ist erfüllt
(`grep -m1 '^modules:' .d-check.yml` nennt `structure`). Die Entscheidung *„nicht ins Ziel“*
trägt also, und zwar an diesem einen Ziel, wie die Sensor-Datei nach `MR-055` einschränkt.

### 2.4 Das Fragment (`MR-010`, `MR-062`)

```sh
diff <(docker run --rm --network none ghcr.io/pt9912/d-check@sha256:1470ecdc…33b3 --print-mk) d-check.mk | grep -c '^[0-9]'   # 6
```

Die Hunks: `1,13c1,74` (Kopf), `15c76` (Digest), `26,27c87,88` (`docs-check`),
`59c120` und `60a122` (die Marke an `doc-tracked`), `75,76c137,138` (`doc-help`). Nur `59c120` und
`60a122` enthalten eine Rezept-Zeile mit dem Markentext. Das entspricht dem Kopf: fünf Handgriffe,
sechs Hunks, die Marken-Menge besteht nur aus `doc-tracked`. Der Pin (`DCHECK_IMAGE`/`DCHECK_DIGEST`)
bleibt in der Kette unverändert.

## 3. Plan-vs-Code-Diff

`git diff --stat ef756260 86fd6508` nennt 13 Dateien. §3 des Plans nennt zwei Dateien und bedingt
die emittierte Vorlage.

| Richtung | Datei | Einordnung |
|---|---|---|
| geplant, gebaut | `.d-check.yml`, `harness/sensors/docs-check.md` | DoD 1 und 2 |
| geplant, bewusst nicht gebaut | Vorlage unter `internal/emit/` | DoD 3 entscheidet *„nicht ins Ziel“*; `internal/` ist in der Kette unverändert |
| gebaut, nicht geplant | `d-check.mk` | Folge der Aktivierung. `structure` hat jetzt einen Block, also verliert `doc-structure` die Marke aus `MR-062`. Ohne diese Änderung fiele `test/doc-block-marke-wiring.bats` (M3 zeigt die Gegenrichtung) |
| gebaut, nicht geplant | `harness/sensors/doc-structure.md`, `harness/sensors/doc-tracked.md` | Folge: `doc-structure` wechselt von Klasse C nach B |
| gebaut, nicht geplant | `harness/README.md` | Folge: Die Vertrags-Zelle von `docs-check` zählt die aktiven Module auf, die Werkzeug-Zeile von `doc-structure` beschreibt das Ziel neu |
| gebaut, nicht geplant | `.github/workflows/ci.yml`, `harness/sensors/history-range-guard.md` | Review F-2: Beide Aufzählungen der aktiven Module waren nach der Aktivierung falsch und nennen jetzt das Kommando |
| gebaut, nicht geplant | `test/mutations/309-drittes-c-ziel-ohne-marke.sh` | Review F-3: Der Kommentar nennt `doc-structure` nicht mehr, der Fall selbst ist unverändert |
| andere Rolle, eigener Commit | `AGENTS.md` §3.8/§3.10 (`510b7ac7`), das Architect-Verdikt (`be2f8b83`) | Architect-Artefakte, je ein Commit nur mit Artefakten dieser Rolle (`AGENTS.md` §3.8) |
| Zeitdokumente | zwei Review-Reports | Reviewer |

**Keine Änderung überschreitet die Abgrenzung in §1.** Der Pin bleibt unverändert. In `done/` ist
kein Plan geändert (`git diff --stat ef756260 86fd6508 -- docs/plan/planning/done` gibt nichts aus).
Ein Sensor für den Risiko-Ausgang ist nicht gebaut, und die Auflösung der Kennung prüft nichts.
Die sieben ungeplanten Dateien halten lebende Aussagen wahr, die die Aktivierung sonst falsch
machte. §3 hat diese Nachzugs-Klasse nicht vorhergesehen: V-5.

## 4. ADR- und MR-Konformität

| Quelle | Ergebnis | Beleg |
|---|---|---|
| `ADR-0056` | konform | Das Gate hält den urteilsfreien Teil der Stilllegungs-Form aus `v6.9.0` · `modul-05-planning-harness.md`, und zwar nur die **Anwesenheit** der Zeile (V3 grün). Das ist nicht schärfer als die Quelle; die Grenze ist benannt. Die Paarungen-Zeile deckt das Architect-Verdikt ab, mit der Quelle `modul-05` Zeile 191 (*„werden abgehakt wie bei jeder Closure“*). |
| `MR-001` | konform | Eine Gate-Anhebung über den Steering-Loop braucht keine ADR. Die Aktivierung samt Ausnahmeliste ist netto eine Anhebung, denn vorher prüfte kein aktives Modul die Form (V9). |
| `MR-010`, `MR-062` | konform | §2.4; `test/doc-block-marke-wiring.bats` ist im Gate-Lauf `ok 104` und färbt unter M3 rot |
| `MR-054` | konform | Drei Kriterien je gemessen (§2.3), die Vorlage bleibt unverändert |
| `MR-055` | konform | Die Messung ist auf das eine Ziel eingeschränkt, Kriterium 3 nach Setzung 3 als nicht erfüllt gewertet |
| `AGENTS.md` §3.5 | konform | Die 30 Einträge sind Teil der Einführung. Jeder weitere ist im Kommentar als Senkung deklariert. Die Liste nennt Dateinamen, kein Muster (V10 zeigt: ein nummerierter Slice aus `open/` fällt in den Prüfbereich) |
| `AGENTS.md` §3.11 | konform | `.d-check.yml` ist ein änderbares Artefakt, also bleibt der Pfad der richtige Zeiger. Der Nachzug von `archive-welle` sucht im `git ls-files`-Suchraum (`internal/archive/scan.go`, `Suchraum`), zu dem `.d-check.yml` gehört; gefahren ist das nicht. Ein toter Eintrag färbt nichts (V13): V-4 |

## 5. Belege für die Risiko-Ausgänge (§6, an den Planner)

### 5.1 Risiko 1 — der Prüfbereich schließt künftige Stilllegungen aus

Die Belege sprechen für den Ausgang *entfallen*:

- Die Ausnahmeliste nennt 30 Dateinamen und kein Muster. Kein Name aus `open/`, `next/` oder
  `in-progress/` steht darin (§2.1, `comm -12` → `0`).
- Das Gegenbeispiel liegt im Prüfbereich: `done/slice-verifier-sonde.md` meldet (V1).
- Ein **nummerierter** Slice aus `open/` fällt unter eigenem Namen in `done/` ebenfalls in den
  Prüfbereich (V10, `slice-067-pretooluse-ausgabeform.md`). Genau diese Klasse würde ein Glob über
  die Kennungs-Form ausschließen.
- Die §2- und §7-Muster treffen jeden heutigen Plan in `open/`, `next/` und `in-progress/` (§2.1).
  Weicht eine Überschrift ab, meldet die Regel `section-missing` (V11) und bleibt nicht still grün.
- **Nicht** gedeckt ist ein Plan, der die flache Ablage verlässt (V12). Das ist die benannte
  Grenze *„Der Glob ist flach“* und keine Stilllegung.

### 5.2 Risiko 2 — Task-Items außerhalb von §2

Die Belege sprechen für den Ausgang *entfallen*:

- `section-pattern` ist `'^## 2\. Definition of Done$'`.
- V7: Ein regulärer Slice mit je einem offenen Item in §1, §6, §7 und §8 bleibt ohne Befund.
- V8i: Ein eingerücktes offenes Item **in** §2 meldet. Gezählt wird also §2, auch eingerückt.
- Im Bestand stehen offene Items nur in §2 (die `awk`-Schleife in §2.1).

### 5.3 Übergabe zur Closure (kein Befund)

Die Plan-Datei trägt 11 offene Task-Items, alle in §2
(`grep -cE '^\s*[-*] \[ \]' <plan>` → `11`). Nach dem `git mv` liegt sie im Prüfbereich; bleibt
dann ein Item offen, ist das Lage V8 und `make docs-check` rot. Das gilt auch für die zwei Zeilen,
die nichts liefern:

- *„Reconciliation-Register: entfällt“* — der Bestand hakt sie ab
  (`grep -hE '^\s*- \[.\] Reconciliation-Register' docs/plan/planning/done/slice-*.md | cut -c1-6 | sort | uniq -c`
  → `23 - [x]`, keine offene);
- *„Die drei Paarungen … sind getragen“* — laut Architect-Verdikt §4 Punkt 1 wird sie abgehakt.

## 6. Befunde

| ID | Schwere | Befund | Beleg | Adresse |
|---|---|---|---|---|
| V-1 | LOW | **Die Meldung bei `section-missing` nennt nicht ihre Ursache, wenn eine einzelne Datei die §2-Überschrift nicht trägt.** Die vierte Spalte ist dann der `hint` der Regel (*„offene DoD-Punkte in done/ — geliefert: abhaken; stillgelegt: §7 trägt **Gegenstand:** …“*). Die Ursache ist aber die abweichende Überschrift, und beide Auswege des Hints lassen den Befund rot. Der Grund-Code stimmt. Im Fall *„Regel trifft keine Datei“* behält die Meldung ihren eigenen Text (V14), wie die CR-Antwort des Werkzeugs zusagt; der Satz der Sensor-Datei zu diesem Fall stimmt also. Die Sensor-Tabelle führt die Lage V11 nicht. Heute trägt kein Plan eine abweichende Überschrift (§2.1). | V11, V14 | Implementer: Lage V11 in die Tabelle von `harness/sensors/docs-check.md` §Modul `structure` aufnehmen oder den `hint` so fassen, dass er zu jedem Grund-Code der Regel passt |
| V-2 | LOW | **Die Zahl in der Grenze *„`make mutate` kennt zwei Fehlschlag-Formen“* ist falsch.** `failure_form` in `harness/tools/mutate.sh` (Zeilen 587–599) führt neben `--- FAIL:` und `not ok N` auch `smoke: FEHLER`, `full-smoke: FEHLER` und das actionlint-Format `:N:N:`; die `smoke`-Zeile besteht seit 2026-07-20 (`git blame`). Die tragende Aussage, dass keine Stufe `docs-check` fährt, stimmt. Denselben Satz trägt `AGENTS.md` §3.8, den `510b7ac7` in dieser Kette neu gefasst und dabei übernommen hat; dort stimmt die Folgerung ebenfalls (*„keine, in der ein Commit-Zuschnitt rot wird“*). | `grep -n 'kennt zwei' AGENTS.md harness/sensors/docs-check.md` → Zeile 380 und Zeile 326 | Implementer für `harness/sensors/docs-check.md`; Architect für `AGENTS.md` §3.8 (Übergabe, §3.8 gehört ihm) |
| V-3 | INFO | **Die Marke gilt nur in der Vorlagen-Form `**Gegenstand:**`.** Eine ungefettete Zeile `- Gegenstand: …` in §7 meldet (V2p). Die DoD spricht von *„der Zeile `Gegenstand:`“*, die Vorlage schreibt sie gefettet, und `hint` sowie Kommentar nennen die gefettete Form. Das Gate ist hier fail-closed und nicht schärfer als die Ziel-Form. Die Sensor-Tabelle führt die Lage nicht. | V2p | Implementer, nach Ermessen |
| V-4 | INFO | **Ein toter Eintrag in `exempt-paths` bleibt still.** Fehlt eine ausgenommene Datei, meldet der Lauf nichts (V13). Die Zusage *„extensional geschlossen auf die Pläne in done/, die …“* hält dann niemand mehr, sobald ein Plan die flache Ablage verlässt, etwa durch `make archive-welle`. Ein falsches Grün folgt daraus nicht, denn der Stub liegt außerhalb des flachen Globs (V12). Die Sensor-Datei nennt nur den flachen Glob. | V13, V12 | Implementer oder der Lauf, der die erste Archivierung plant (`AGENTS.md` §3.11) |
| V-5 | LOW | **Plan-vs-Code: §3 nennt sieben geänderte Dateien nicht.** Alle sieben ziehen lebende Aussagen über die aktive Modul-Menge oder die Marken-Menge nach (§3). Keine überschreitet §1. Das ist keine DoD-Verletzung, sondern eine Lücke im Plan: Eine Aktivierung ändert jede Stelle, die die aktiven Module aufzählt. | §3 | Planner: in der Closure-Notiz unter *„Was ging anders als geplant“* |

**Kein Befund blockiert die Closure.** V-1 bis V-5 betreffen weder einen Liefer-Punkt noch die
Gate-Wirkung.

## 7. Gate-Lauf

`make gates` am Stand `86fd6508`, sauberer Arbeitsbaum, vor jeder Kopie gestartet: **Exit 0**.

- `baseline-verify: v6.9.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`
- `d-check: 1604 Datei(en) geprüft, 0 Befund(e)`
- bats: `311` × `ok`, `0` × `not ok`, darunter `ok 104 doc-*: C-Menge …`
- `comment-claims: 64 Datei(en) geprueft, 0 Befund(e)`
- `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`

`HEAD` war vor und nach dem Lauf `86fd6508`.

## 8. Negativbefunde

- Kein Plan in `done/` und keine Datei unter `internal/` ist in der Kette geändert.
- Der d-check-Pin ist unverändert.
- Die 30 Ausnahmen sind genau die Pläne mit offenen Items und ohne Marke. Keine fehlt, keine ist
  zu viel, keine trägt eine Marke.
- Keine Datei außerhalb von `slice-*.md` trägt in `done/` offene Items; der Glob verliert also
  nichts.
- Kein heutiger Plan weicht von der §2- oder §7-Überschrift ab.
- Kein Name eines offenen, nächsten oder laufenden Slice steht in der Ausnahmeliste.
- Die Umsetzungs-Commits tragen die Kommandos des Rot-Belegs (`8366b374`).
- Die Sonde allein färbt im emittierten Ziel nichts (E4); das Rot in E3 kommt von der Regel.
- `test/doc-block-marke-wiring.bats` fällt unter M3 aus dem behaupteten Grund: `doc-structure` steht
  in der abgeleiteten Menge, aber nicht unter den Zielen mit Marke.
