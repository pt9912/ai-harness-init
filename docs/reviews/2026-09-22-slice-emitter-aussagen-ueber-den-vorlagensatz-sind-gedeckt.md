# Review: slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt

**Rolle:** Reviewer · **Datum:** 2026-09-22
**Commit-Bereich:** `6c261398..HEAD` (ein Implementer-Commit `fa125cf8`)
**Plan:** [`docs/plan/planning/in-progress/slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt.md`](../plan/planning/in-progress/slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt.md)
**Bezug:** [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`ADR-0057`](../plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md),
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
[`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)

Kontext gelesen: Plan (vollständig, §1–§8), `.harness/skills/reviewer.md`, `AGENTS.md` §3, der volle
Diff `6c261398..HEAD` (`internal/emit/templates.go`, `internal/emit/templates_test.go`,
`internal/emit/export_test.go`, `test/mutations/396-398`), `internal/emit/templates.go` vollständig
(`isRecurring`/`isDerivativeIndex`/`isBrownfieldOnly`/`inScope`), `test/courseset-fixture.bats`,
`spec/lastenheft.md` §LH-FA-02.

**Selbst reproduziert (nicht nur gelesen):**
- `make gates` real ausgeführt — Exit 0, alle Gates grün (Protokoll unten).
- Mutation `test/mutations/396-disposition-in-keiner-menge.sh` live gefahren: Mutation auf
  `internal/emit/templates.go` angewendet, `docker build --target test` (Rezept `test-go`) gab
  `FAIL: TestDispositionen_DeckenBezugsmengeVollstaendigUndDisjunkt` mit exakt der im Fall
  vorhergesagten Meldung (`harness/sensors/gate.template.md: in keiner der vier Dispositionen …`),
  Datei danach mit `git checkout` zurückgesetzt (Tree wieder clean).
- Die drei `v6.7.2`-Proben gegen `.harness/baseline/v6.7.2/` real gefahren: liefern `No such file or
  directory` (Exit 2) statt der zugesagten leeren Ausgabe — bestätigt die "Rot"-Beschreibung aus DoD
  3 unabhängig vom Implementer-Bericht.
- Die vier Proben gegen den aktuellen Stand (`.harness/baseline/v6.9.0/`) real gefahren: alle vier
  liefern leere Ausgabe wie zugesagt.
- Bezugsmenge nachgezählt: `find .harness/baseline/v6.9.0/templates -name '*.template.md' | grep -v
  project-readme … | wc -l` → `24`, deckt sich mit der im Plan und im Wächter-Kommentar behaupteten
  Zahl.
- `test/mutations/397` und `398` wurden **nicht** live gefahren (Budget) — stattdessen die
  Test-Logik (`treffer`-Map, `len(mitglied)`-Fallunterscheidung) gegen die in den Fall-Dateien
  beschriebenen Mutationen durchgerechnet; beide führen nach der Logik nachvollziehbar zu
  `len(mitglied) == 2` (397) bzw. zweifach zu `0` und `2` (398). Als `verifizierbar: ja` markiert,
  aber nicht selbst rot gesehen — siehe LOW-1.

---

## Findings

### MEDIUM-1 — Plan-Abweichung (`export_test.go`) nur im Commit-Bericht, nicht in §3 des Slice-Plans nachgetragen

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-09-implementierung.md` §Rücksprungkanten-Regeln ("Der Plan
  lebt in §3 des Slice-Plans, nicht im Chat-Verlauf … kein separates Artefakt entsteht neu"; "Nimmt
  der Lauf etwas mit, das §1 ausschließt, ist das eine Plan-Änderung und gehört vor den Code, nicht
  in den Bericht danach")
- **pfad:** `internal/emit/export_test.go` (neu); `docs/plan/planning/in-progress/slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt.md`
  §3 (unverändert — führt nur `templates.go`, `templates_test.go`, `test/mutations/`)
- **befund:** §3 des Slice-Plans listet drei Dateien/Komponenten; `internal/emit/export_test.go`
  steht dort nicht, obwohl es Teil des Diffs ist. Die Abweichung ist real (neue Datei, erstes
  `export_test.go` in `internal/emit/`, überhaupt das erste im Repo — bislang ist jede
  `internal/emit/*_test.go`-Datei `package emit_test`) und wurde vom Implementer selbst nur in der
  Commit-Message offengelegt, nicht in §3 der Plan-Datei fortgeschrieben. Das Baseline-Regelwerk
  bindet Plan-Verfeinerungen (5→4-Rücksprung) ausdrücklich an §3 als lebendes Dokument, nicht an den
  Bericht danach.
- **Bewertung, warum nicht HIGH:** §1 des Slice-Plans schließt keine neue Testdatei aus — weder
  unter "Produktionscode-Grenze" noch unter "Test-Layout-Konvention" steht ein einschlägiger Punkt;
  die vier §1-Ausschlüsse (Lastenheft, Vorlagensatz, Grenz-Aussage, Emit-Disposition) sind alle
  eingehalten (siehe Negativbefunde). `export_test.go` ist geprüft eine reine
  Sichtbarkeits-Brücke (vier Ein-Zeiler-Delegationen ohne Logik, kompiliert nie in ein
  Produktions-Binary) und löst keinen der Modul-5-"zu groß"-Trigger aus (kein zusätzlicher
  Liefer-Punkt, keine zusätzliche Schicht, weiterhin in einer Sitzung prüfbar) — eine Rückführung
  `in-progress → next` wäre unverhältnismäßig gewesen.
- **verifizierbar:** ja — `git diff 6c261398..HEAD -- docs/plan/planning/` ist leer; die
  Datei-Tabelle in §3 der Plan-Datei nennt `export_test.go` nicht.
- **klasse:** Plan-Abweichung landet im Commit-Bericht statt in §3 des Plans

### LOW-1 — Zwei von drei neuen Mutationsfällen nicht unabhängig rot gesehen

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `test/mutations/397-disposition-doppelt-belegt.sh`,
  `test/mutations/398-disposition-tausch-gleiche-kardinalitaet.sh`
- **befund:** Dieser Review hat nur Fall 396 live gefahren (Budget); 397 und 398 wurden anhand der
  Testlogik nachvollzogen, nicht ausgeführt. Der Implementer-Bericht behauptet für alle drei einen
  Rot-Beleg von Hand; das ist plausibel und die Fall-Dateien sind konsistent mit dem Wächter-Code,
  aber nicht durch diesen Lauf unabhängig bestätigt.
- **verifizierbar:** ja — `make mutate` (voller Lauf, ~50 min) oder gezielt
  `sed -i '…' internal/emit/templates.go && docker build --target test …` je Fall.
- **klasse:** Rot-Beleg für Mutationsfall nicht vom Reviewer selbst reproduziert (Budget-Grenze)

---

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| §1-Ausschluss "Lastenheft wird hier nicht geschrieben" | geprüft, ohne Befund — `spec/lastenheft.md` nicht im Diff |
| §1-Ausschluss "Vorlagensatz selbst wird nicht verändert" | geprüft, ohne Befund — `.harness/baseline/`, `internal/emit/templates/` nicht im Diff |
| §1-Ausschluss "Grenz-Aussage nicht weicher formuliert, falls Probe nicht leer" | geprüft, ohne Befund — alle vier Proben liefern leere Ausgabe gegen v6.9.0 (selbst gefahren) |
| §1-Ausschluss "Keine Änderung an der Emit-Disposition selbst" | geprüft, ohne Befund — `isRecurring`/`isDerivativeIndex`/`isBrownfieldOnly`/`inScope` unverändert, nur Kommentar-Text (v6.7.2→v6.9.0) angefasst |
| DoD 1 — Wächter deckt Bezugsmenge vollständig und disjunkt | geprüft, ohne Befund — Logik nachvollzogen, Fall 396 live rot gesehen, Bezugsmenge (24) nachgezählt |
| DoD 2 — jede Weiche einer LH-FA-02-Aussage zugeordnet | geprüft, ohne Befund — vier Einträge, Zitate stimmen mit `spec/lastenheft.md` §LH-FA-02 überein (auch `isBrownfieldOnly`s "kein Beleg"-Zeile ist durch den bereits bestehenden `GRENZE`-Kommentar gedeckt, nicht neu erfunden) |
| DoD 3 — Proben gegen geltenden Satz (v6.9.0), Zusage trägt Ergebnis | geprüft, ohne Befund — alle drei `v6.7.2`-Stellen auf `v6.9.0` nachgezogen, live gegen v6.7.2 (Fehler) und v6.9.0 (leer) verifiziert |
| `isBrownfieldOnly` "benannter Befund ohne Deckung" | geprüft, ohne Befund — der `GRENZE`-Kommentar existierte bereits vor diesem Slice (nicht im Diff verändert) und ist sachlich korrekt: `LH-FA-02` nennt Singletons/Wiederkehrende/derivative Indexe/`.gitkeep`/Set-Index-README, aber keine brownfield-gebundene Disposition |
| AGENTS.md §3.7 (Kommentar-Klassen) | geprüft, ohne Befund — die neuen/geänderten Kommentare (`v6.7.2`→`v6.9.0`, Wächter-Kopfkommentar, `export_test.go`-Kopfkommentar, drei Mutationsfall-Kommentare) sind präsentisch, beschreiben Ist-Zustand bzw. Rang-Zeiger (ADR-0057, MR-036), keine Entstehungs-Narrative |
| `make gates` | geprüft, ohne Befund — selbst ausgeführt, Exit 0 (baseline-verify, docs-check, lint, build/test, shell-lint, ci-lint, comment-claims, host-bin, span-check) |
| Traceability (Commit-Message) | geprüft, ohne Befund — nennt `LH-FA-02`, `LH-QA-01`, `LH-QA-02`, `MR-025`, `MR-033`, `ADR-0057` |
| DoD-Punkte "Doku-Update" / "Reconciliation-Register" | geprüft, ohne Befund — beide korrekt als "entfällt"/"Vorbedingung" markiert, kein Vertrag im Diff berührt |

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Plan-Abweichung landet im Commit-Bericht statt in §3 des Plans ·
Rot-Beleg für Mutationsfall nicht vom Reviewer selbst reproduziert (Budget-Grenze)

## Verdikt

**Merge-blockierend:** nein — keine HIGH-Befunde. MEDIUM-1 ist eine Plan-Pflege-Lücke ohne
Sachrisiko (die tatsächliche Änderung ist geprüft harmlos: reine Sichtbarkeits-Brücke, keine
Logikänderung, alle §1-Ausschlüsse eingehalten); sie gehört in die Closure-Notiz (§7 "Was ging
anders als geplant") nachgetragen, nicht als Blocker behandelt. LOW-1 ist eine
Reviewer-Prozess-Transparenz-Notiz (Budget-Grenze dieses Laufs), kein Implementer-Defekt.

**Übergabe:** Findings gehen an den Implementer/Planner zur Closure-Notiz (§7); die
Finding-Klassen gehen in die Slice-Closure §7 und von dort in das Beobachtungs-Register. Dieser
Report ist ein Lauf-Beleg (Audit: Diff `6c261398..HEAD`, Skill `.harness/skills/reviewer.md`
v2.0.0, Modell Sonnet 5, Verdikt "kein Merge-Blocker") und wird über Läufe hinweg nicht wieder
gelesen. Kein Ersatz für Verifikation — DoD-/Spec-Konformität prüft der Verifier separat.
