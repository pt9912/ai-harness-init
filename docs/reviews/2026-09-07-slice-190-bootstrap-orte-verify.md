# Verifikation — slice-190: Der Bootstrap legt die Orte an, die seine eigenen emittierten Texte nennen

**Rolle:** Verifier (Modul 8/11) · **Datum:** 2026-09-07

**Eingang:** DoD-Bestätigung + Sensor-Belege des Implementers (Commits `2cb06ad9`,
`4dc08a93`), Review-Report `docs/reviews/2026-09-06-slice-190-bootstrap-orte-review.md`
(NICHT KONFORM, drei HIGH + ein MEDIUM), Planner-Übergabe (Commit `529df88e`, drei offene
Punkte in §6).

**Geprüfter Stand:** fünf Slice-Commits `711d92cb..4dc08a93` plus Planner-Commit `529df88e`.
Alle Messungen unten liefen gegen den Arbeitsbaum bei `529df88e` — teils über `git worktree`
(isoliert, kein `git checkout` im Hauptbaum), teils über eine `make mutate`-Isolationskopie,
die vor dem später gelandeten, slice-fremden Commit `d1646e6c` (Architect, ADR-0038) entstand.
Keine der Messungen ist von `d1646e6c` berührt — die Datei-Mengen beider Commits sind disjunkt
(`git show --stat d1646e6c` nennt `ADR-0038`-, Baseline- und Konventions-Pfade, keinen der
unten geprüften).

**Nicht Gegenstand:** Plan-Prosa- und Kommentar-Feinschliff, den das Review bereits
gegen Plan/ADR/Hard-Rules geprüft hat (HIGH-1/HIGH-2/MEDIUM-1) — hier wird nur bestätigt,
dass die Fixes wirklich greifen, nicht das Review wiederholt.

---

## DoD, Punkt für Punkt

### (1) Der Bootstrap legt `harness/conventions` an — **erfüllt**

```sh
sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c '^\t\t"'
# 7 — inkl. harness/conventions
```

Die drei Bedingungen aus ADR-0037 Festlegung 1 stehen im Kopfkommentar über
`structureGitkeeps()` **je einzeln**, nicht pauschal (`internal/emit/templates.go:405-417`,
(a)/(b)/(c) mit eigener Begründungszeile); der Commit `2cb06ad9` benennt sie ebenso einzeln
(„alle drei Bedingungen einzeln im Kopfkommentar belegt"). Am **emittierten** Baum bestätigt
(frischer `--lang go`-Bootstrap): `harness/conventions/.gitkeep` existiert,
`docs/plan/carveouts/done` und `docs/plan/planning/observations` existieren nicht.

Der Zahn ist der bestehende `TestTemplates_EmittierterBestandVollstaendig` — läuft grün in
`make gates` (unten).

### (2) Zwei Fundstellen bekommen einen benannten Ausgang — **erfüllt**

Am selben frischen `--lang go`-Bootstrap gegengelesen:

```sh
sed -n '65,80p' <ziel>/harness/conventions.md
# … kopiert aus der\ngleichnamigen Eintrags-Vorlage `MR-NNN-titel.template.md` …
sed -n '38,45p' <ziel>/docs/plan/planning/README.md
# … `docs/plan/carveouts/done/` <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) --> …
```

Beide Ausgänge sind byte-genau die, die die Neutralisierungs-Konstanten in
`internal/emit/templates.go` (`conventionsPathRefNew`, `carveoutsDoneRefNew`) vorschreiben,
und beide sind zulässige Formen nach DoD (2) (Umformulierung bzw. derselbe `d-check:ignore`-
Marker, den `carveout.template.md` für denselben Ort selbst führt). Zwei Wiring-Proben
(`TestTemplates_ConventionsTemplateRefGateSafe`,
`TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe`) messen die Ausgabe-Eigenschaft, nicht
ein Implementierungsdetail — bestätigt durch Lesen, nicht nur durch den grünen Testlauf.

### (3) `codepaths` 6 → 3, Rückstand namentlich der Register-Ort — **erfüllt, unabhängig nachgemessen**

Dies ist die tragende Zusage des Slice. Nachgemessen, nicht aus dem Commit übernommen:

**Vorher** — `git worktree add` auf `962319c7` (letzter Commit vor der Implementierung),
eigener `make host-bin`, frischer `--lang go`-Bootstrap in ein leeres Scratch-Repo,
`.d-check.yml` von Hand um `codepaths` über `roots: [spec, docs, harness]` ergänzt (dieser
Slice schaltet das Modul im emittierten Ziel nicht ein — siehe §1 des Plans), dann derselbe
gepinnte d-check-Digest wie im Plan (`sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`,
netzlos, `--network none`):

```text
d-check: 19 Datei(en) geprüft, 6 Befund(e)
harness/conventions.md:72   harness/conventions/                       codepath-missing
harness/conventions.md:73   harness/conventions/MR-NNN-titel.template.md codepath-missing
docs/plan/planning/README.md:42  docs/plan/carveouts/done/             codepath-missing
.claude/commands/close-welle.md:60     docs/plan/planning/observations/README.md  codepath-missing
.claude/commands/implement-slice.md:153 docs/plan/planning/observations/           codepath-missing
.claude/commands/plan-welle.md:46      docs/plan/planning/observations/README.md  codepath-missing
```

**Nachher** — derselbe Ablauf am Arbeitsbaum bei `529df88e`, beide Bootstrap-Formen
(`--lang go` **und** sprachlos):

```text
d-check: 19 Datei(en) geprüft, 3 Befund(e)
.claude/commands/close-welle.md:60      docs/plan/planning/observations/README.md  codepath-missing
.claude/commands/implement-slice.md:153 docs/plan/planning/observations/           codepath-missing
.claude/commands/plan-welle.md:46       docs/plan/planning/observations/README.md  codepath-missing
```

6 → 3 bestätigt, und die drei verbleibenden sind **namentlich** genau die drei
`observations/`-Fundstellen, die ADR-0037 Festlegung 2 einem eigenen, noch nicht geschnittenen
Slice zuweist — keine andere Fundstelle ist darunter. Die Messreihe ist damit kein
unreproduzierbarer Alleingang des umsetzenden Laufs.

### `make gates` / `make full-smoke` / `make mutate` — **gates und full-smoke bestätigt, mutate mit einer Einschränkung**

- `make gates` → EXIT 0; `docs-check: 896 Datei(en) geprüft, 0 Befund(e)`;
  `comment-claims: 56 Datei(en) geprueft, 0 Befund(e)` (eigener Lauf, Arbeitsbaum bei
  `529df88e`).
- `make full-smoke` → EXIT 0 (eigener Lauf, u. a. `full-smoke: OK — frisch gebootstrapptes
  Repo faehrt make -j gates out-of-the-box gruen …` für beide Bootstrap-Formen).
- `make mutate` → **261 ok, 0 Befund(e)**, eigener Lauf über den vollen kuratierten Satz,
  einschließlich der zwei neuen Fälle aus MEDIUM-1:
  ```text
  mutate: ok  274-conventions-template-ref-nicht-neutralisiert -> TestTemplates_ConventionsTemplateRefGateSafe rot
  mutate: ok  275-planning-readme-carveouts-done-ref-nicht-neutralisiert -> TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe rot
  ```
  **Einschränkung:** Die DoD-Formulierung verlangt „grün über die CI", nicht nur lokal. Der
  CI-Lauf für exakt den Commit `529df88e` wurde von GitHub Actions **cancelled** gemeldet
  (`gh run list`) — durch den nachfolgenden, slice-fremden Push `d1646e6c` verdrängt, nicht
  durch einen Befund. Es gibt damit **keinen abgeschlossenen CI-Lauf für genau diesen
  Commit-Stand**; der lokale Lauf oben ist der Ersatzbeleg, den dieser Verifikations-Kontext
  liefert, aber er ist nicht die in der DoD genannte Quelle. Vor der Closure sollte ein
  CI-Lauf über dem tatsächlichen Merge-Stand grün vorliegen (typischerweise der
  Wave-Self-/Merge-Commit selbst, nicht zwingend `529df88e` einzeln).

### Closure-Notiz / Beobachtungs-Register / Risiko-Ausgänge / drei Paarungen — **erwartungsgemäß offen**

Der Slice liegt in `in-progress/`, Closure ist Planner-Arbeit nach `AGENTS.md` §3.10 und
folgt erst nach dieser Verifikation. Entsprechend:

- Closure-Notiz (§7) trägt noch Platzhalter (`<…>`).
- Das Beobachtungs-Register ist für diesen Slice noch nicht fortgeschrieben —
  `emittierte-vorlagen-klassifikation-ohne-traeger` steht weiter bei **2** Belegen
  (`ls docs/plan/planning/observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/evidence/*.md | wc -l`
  → 2), obwohl der Plan seinen dritten Beleg für diesen Slice bereits ankündigt (§8). Das ist
  keine Lücke, sondern der erwartete Zustand vor der Closure-Buchung.
- Alle neun Risiken in §6 tragen noch `**Ausgang:** <offen>` — keines ist zugewiesen. Vor dem
  `git mv` nach `done/` braucht jedes einen der drei Ausgänge (Modul 5 §Offene Risiken werden
  bei Closure aufgelöst). Zwei der drei vom Planner zuletzt ergänzten Punkte (der eingefrorene
  Pfad-Widerspruch, s. u.; die Frage zur Adresse der Eintrags-Vorlage) hängen an einer
  Norm-Entscheidung des Architects, nicht an etwas, das der Planner allein auflösen kann.
- Die drei Paarungen (Anker · Folge-Slice · Register) sind nicht geprüft — sie hängen an den
  noch fehlenden Ausgängen und der noch fehlenden Registerbuchung.

---

## ADR-0037-Konformität

- **Festlegung 4** (kein Anlege-Weg für `docs/plan/carveouts/done`): **eingehalten**. Am
  emittierten Baum bestätigt — kein `docs/plan/carveouts/done` unter `--lang go`. Die Zeile in
  `docs/plan/planning/README.md`, die den Ort nennt, bekommt den `d-check:ignore`-Marker statt
  einer Anlage (DoD 2), nicht die Anlage selbst.
- **Festlegung 2** (Register-Ort mit `README.md`, eigener Schnitt): **eingehalten** — dieser
  Slice hat `docs/plan/planning/observations/` nicht vorgezogen. Am emittierten Baum
  bestätigt: kein `observations`-Verzeichnis unter `--lang go`. Die drei zugehörigen
  Fundstellen bleiben unverändert stehen und sind exakt die drei Rückstände aus DoD (3).
- **Folgepflicht 1** (die drei Bedingungen je Ort einzeln benennen, nicht pauschal):
  **eingehalten** — geprüft am Artefakt (Kopfkommentar `internal/emit/templates.go:405-417`),
  nicht am Vorsatz. (a), (b), (c) stehen als eigene Zeilen mit je eigener Begründung; die
  Commit-Message wiederholt die Zuordnung.

---

## Plan-vs-Code-Diff

- **§1** wurde vom Planner (`529df88e`) nachgezogen: die Prosa nennt die Zahl der
  Struktur-Verzeichnisse nicht mehr, sondern verweist allein auf das Kommando
  (`sed -n '/^func structureGitkeeps/,/^}/p' … | grep -c '^\t\t"'` → 7, aktuell). Vollständig —
  ein zweiter Zahlen-Rückstand (das ursprüngliche LOW-2-Finding) ist nicht mehr auffindbar.
- **§6** trägt seit `529df88e` drei zusätzliche offene Punkte, die exakt den Übergaben aus dem
  Review entsprechen (HIGH-3 → „Eingefrorene Artefakte adressieren wandernde
  Lifecycle-Dateien …"; INFO-1 → „Der `next → in-progress`-Move schreibt zwei Artefakte …";
  INFO-2 → „Der emittierte Text nennt die Eintrags-Vorlage ohne Adresse"). Keine dieser drei
  ist im Code aufgelöst — sie stehen korrekt als offene Risiken, nicht als erledigt.
- **Kein weiterer Rückstand gefunden:** §3 (Plan vor Code) benennt exakt die Dateien, die der
  Diff berührt (`internal/emit/templates.go`, `internal/emit/templates_test.go`, die
  *emittierten* Fassungen von `harness/conventions.md`/`docs/plan/planning/README.md` — nicht
  deren Dogfood-Pendants, die unverändert bleiben, wie am Diff bestätigt). Der
  Change-Request-Abschnitt in §3 stimmt mit ADR-0037 Festlegung 1 überein.
- **Der eine Rest-Widerspruch, den §6 offen führt** (nicht neu, nur bestätigt): Der von
  `make slice-mv` bewegte, eingefrorene Report
  `docs/reviews/2026-09-06-adr-0037-konsistenz-review.md` trägt jetzt den Link-Pfad
  `in-progress/` unmittelbar neben seiner eigenen Prosa „(in `open/`)" (Commit `962319c7`) —
  Pfad und Satz derselben Zeile widersprechen sich weiterhin. Das ist HIGH-3 aus dem Review,
  korrekt als offener Punkt in §6 registriert, nicht durch diesen Slice behoben (eine
  Architect-Norm-Frage nach `AGENTS.md` §3.8, wie der Plan selbst sagt).

---

## Verdikt

**DoD (1), (2), (3) sowie `make gates`/`make full-smoke` sind erfüllt und unabhängig
nachgemessen — DoD (3) als tragende Zusage vollständig reproduziert (6 → 3, Rückstand
namentlich identisch).** `make mutate` ist inhaltlich grün (261/0, beide neuen Fälle rot
gesehen), aber der von der DoD verlangte **CI**-Beleg für genau diesen Commit-Stand fehlt, weil
der zugehörige Lauf durch einen späteren, slice-fremden Push cancelled wurde — vor der Closure
ist ein grüner CI-Lauf über dem tatsächlichen Merge-/Closure-Stand nachzuholen.

ADR-0037 (Festlegung 2, 4, Folgepflicht 1) ist eingehalten. Der Plan ist nach dem
Planner-Nachzug (`529df88e`) deckungsgleich mit dem Code; kein unentdeckter
Plan-vs-Code-Rückstand gefunden.

**Nicht erfüllt, weil erwartungsgemäß noch nicht bearbeitet (Closure-Arbeit, `AGENTS.md`
§3.10):** Closure-Notiz, Beobachtungs-Register-Buchung, die neun Risiko-Ausgänge in §6, die
drei Paarungen. Zwei der neun Risiken (der eingefrorene Pfad-Widerspruch aus HIGH-3, die
Adress-Frage aus INFO-2) sind ohne eine vorgelagerte Architect-Entscheidung nicht auflösbar —
das ist kein Verifikations-Befund, sondern der Stand, den der Plan selbst korrekt so
beschreibt.

**Übergabe an den Planner:** DoD (1)–(3) und die Gate-Trias sind belastbar; vor dem `git mv`
nach `done/` fehlen (a) ein grüner CI-Lauf über dem Closure-Stand für die
`make mutate`-Zusage, (b) ein Ausgang je Risiko in §6, (c) die Register-Buchung und die drei
Paarungen.
