# Review-Report: slice-offene-wellen-liste-hat-einen-waechter — 2026-09-13

**Review-Art:** Verifikation (Modul 11) — geprüft wird gegen **DoD, Plan und Spec**, nicht gegen
Diff-Stil (Reviewer, Modul 10) und nicht gegen realen Bedarf (Validator, Modul 8). Das
Übergabe-Artefakt ist der *DoD-/ADR-Konformitätsbericht + Plan-vs-Code-Diff an den Planner*.

**Gegenstand:** vier Commits, in dieser Reihenfolge — `ba8698fc` (Aktivierung + Rot),
`ca135c49` (Nacharbeit Runde 1: HIGH-1, HIGH-3, MEDIUM-2), `87557369` (DoD (3), Sensor-Prosa zeigt
auf `ADR-0046`), `19e2be67` (Nacharbeit Runde 2: MEDIUM-1, LOW-1). **Nicht Gegenstand:** die
ADR-0046-eigene Runde (`2f8ad619`/`d59184d8`/`7cfd8283`) und `72646514` (`reviewer.md` auf
Ziel-Form — eigener Vorgang).

**Skill:** keiner — Verifikation läuft über die Artefaktklasse **„keins"**
(Modul 8 §Welche Rolle braucht welche Artefaktklasse): die Prüfgrundlage ist der Slice selbst
(DoD §2, Trigger §4/§5, Risiken §6), nicht ein repo-spezifisches, nicht-ableitbares Urteil.
**Modell:** Claude Sonnet 5 · **Datum:** 2026-09-13

**Eingangs-Kontext:**

- [`docs/plan/planning/in-progress/slice-offene-wellen-liste-hat-einen-waechter.md`](../plan/planning/in-progress/slice-offene-wellen-liste-hat-einen-waechter.md)
  (DoD §2, Trigger §4/§5, Risiken §6)
- [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (Anlass),
  [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) (`Accepted`, von diesem
  Slice zitiert)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`AGENTS.md`](../../AGENTS.md) §3.5, §3.6, §3.7, §3.8, §3.9, §3.10
- [Review-Report Runde 1](2026-09-13-slice-offene-wellen-liste-hat-einen-waechter.md),
  [Review-Report Runde 2](2026-09-13-slice-offene-wellen-liste-hat-einen-waechter-r2.md) —
  DoD-Bestätigung und Sensor-Belege des Implementers (Aufgabenstellung dieses Laufs)

**Mess-Umgebung.** Kein Docker-Ziel selbst gefahren — weder `make gates` noch `make mutate` noch
`make docs-check`; das ist Implementer-Sensor-Beleg und wird hier gegen den Diff und gegen die
zitierten Reproduktionen (Commit-Message `ba8698fc`, Runde-1-Sonden N-1/N-2/N-6, Runde-2-Sonde N-4)
gelesen, nicht neu erhoben. Selbst gefahren: `git show`/`git diff`/`git log` über den
Vier-Commit-Bogen, `grep`/`sed`/`ls`/`wc` gegen den Arbeitsbaum, sowie
`bash harness/tools/working-tree-hash.sh` gegen `.harness/state/gates-passed.diffsha`. Repo-Zustand
zum Zeitpunkt dieses Laufs: `git status --porcelain` leer, `HEAD` = `72646514`.

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| V-1 | HIGH | DoD-Punkt (3) verlangt wörtlich die Aussage *„Richtung B — ein Zeiger ohne Datei — fällt über das Modul `links` (`target-missing`), nicht über `waves`"*. Das ist gemessen falsch: Ein Zeiger unter „Offene Wellen" ohne passende flache Datei fällt über `wave-drift` (`waves`), nicht über `links` — bereits die Nachmessung im Umsetzungs-Commit `ba8698fc` selbst stellt das fest, unabhängig reproduziert in Runde 1 (N-2). Nur für einen toten **Vorschau**-Zeiger stimmt die DoD-Formulierung. Der gelieferte Sensor-Text weicht bewusst und korrekt vom DoD-Wortlaut ab (`AGENTS.md` §3.6 — Zusage folgt der Messung). Damit ist DoD (3) **wie geschrieben** nicht wahr abhakbar: das Häkchen bestätigte eine falsche Tatsachenbehauptung, egal wie der Code aussieht. Bereits Runde 1 hat dies als INFO-2 notiert und als **Planner**-Nachzug eingeordnet (`AGENTS.md` §3.10 — die ausführende Rolle schreibt ihr Abnahmekriterium nicht um); es blieb über beide Review-Runden und alle vier Commits unkorrigiert, weil dafür keine der beiden Rollen zuständig ist. | Slice-Plan §2 (3); Modul 11 (*„DoD-Verletzung … ist eine eigene Klasse, die nur die Verifikation fängt"*); `AGENTS.md` §3.10 | Slice-Plan §2, Zeilen 182–186 gegen [`harness/sensors/docs-check.md:48-50`](../../harness/sensors/docs-check.md) | ja — Runde-1-Sonde N-2 (Zeiger `welle-88` unter „Offene Wellen" ohne Datei → `-disable links` → 1 Befund `wave-drift`) | DoD-Punkt enthält eine gemessen widerlegte Tatsachenbehauptung und ist damit unerfüllbar-wie-geschrieben |
| V-2 | INFO | Round-2-INFO-1: die vierte Folgepflicht aus [ADR-0046](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Konsequenzen (*„fällig als eigener Vorgang"*, Zeiger statt Norm-Frage in `harness/sensors/docs-check.md`) ist mit Commit `87557369` vollzogen, gebucht unter „DoD (3)". Das berührt **keinen wörtlichen** DoD-Punkt dieses Slice — DoD (3) benennt nur die Link/waves-Unterscheidung (V-1), nicht diesen Absatz — bleibt aber eine Diskrepanz: Die ADR ist ab `Accepted` immutabel und führt die Folgepflicht weiterhin als *„fällig"*, während sie de facto erledigt ist, und nirgends im Repo steht das. Keine DoD-Verletzung **dieses** Slice; ein Closure-Punkt für den Planner (Vermerk in §7 oder Zuordnung zu einer Beobachtungs-Kennung, wie Runde 2 selbst vorschlägt). | ADR-0046 §Konsequenzen | Commit-Message `87557369`; ADR-0046 §Konsequenzen, vierte Folgepflicht | nein — Abgleich zweier Texte | Folgepflicht ohne notierten Ausgang (identisch mit Runde-2-Klassifikation) |
| V-3 | INFO | Round-2-INFO-2: [`docs/plan/planning/open/slice-210-*.md`](../plan/planning/open/slice-210-planning-modul-im-emittierten-doc-gate.md) behauptet in seinem §1 weiterhin, `waves` sei im Dogfood aus und stelle eine dokumentierte Abweichung dar — beides ist seit `ba8698fc` bzw. `7cfd8283` falsch. Kein DoD-Punkt **dieses** Slice, keine Implementer-Pflicht (die Datei gehört dem Planner); die Übergabe ist bereits in `ca135c49` erfolgt (MEDIUM-1 benannt und referenziert). Reiner Hinweis für den Planner, bevor `slice-210` selbst bearbeitet wird. | `MR-054` | `docs/plan/planning/open/slice-210-planning-modul-im-emittierten-doc-gate.md:100-101` | nein — `git grep 'waves' docs/plan/planning/open/slice-210-*.md` gegen `grep 'waves:' .d-check.yml` | Überholter offener Plan ohne genormten Ausgang (identisch mit Runde-2-Klassifikation) |
| V-4 | LOW | Runde 2 endete `BLOCKIERT` (MEDIUM-1, LOW-1) und es liegt keine Runde-3-Reviewer-Bestätigung vor, dass `19e2be67` diese zwei Findings tatsächlich schließt — Modul 8 sieht die Übergabe Implementer→Verifier *„nach Review-Schluss"* vor, und Runde 2 hat nicht mit Freigabe geschlossen. Ich habe die Behebung selbst am Diff nachvollzogen (siehe Negativbefunde N-6/N-7) und halte sie inhaltlich für tragend. Kein DoD-Punkt verlangt eine Freigabe-Runde wörtlich (DoD nennt nur *„Review durchgeführt, Report … liegt vor"*, erfüllt durch die zwei vorliegenden Reports), daher kein Blocker — aber ein Prozess-Hinweis für den Planner. | Modul 8 §Rollen-Sequenz für einen Slice | `docs/reviews/2026-09-13-slice-offene-wellen-liste-hat-einen-waechter-r2.md` (Verdikt: *„BLOCKIERT — knapp, an einer Satzgrenze"*) | nein — Prozess-Beobachtung | Verifikation nach ungeschlossener Review-Runde |

---

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| DoD (1) — `waves:`-Block, Bestand grün | geprüft, ohne Befund: `.d-check.yml` trägt `waves: {dir: docs/plan/planning, mode: many}`; der Begründungs-Kommentar beschreibt jetzt die Deckung (fünf Lagen, vier Grund-Codes) statt des Ausbleibens und zeigt auf `harness/sensors/docs-check.md`, nicht mehr auf `harness/README.md` |
| DoD (2) — Richtung A rot gesehen | geprüft, ohne Befund: Commit-Message `ba8698fc` trägt Kommando, Grund-Code (`wave-drift`) und Ausgabe, gefahren gegen `git archive HEAD \| tar -x` außerhalb des Repos, `--network none`, Digest aus `d-check.mk` |
| DoD (3) — Grenze im Sensor-Text | siehe V-1 — Grenze ist im gelieferten Text korrekt benannt, der DoD-Wortlaut selbst ist falsch |
| `.d-check.yml` außerhalb des `waves`-Blocks | geprüft, ohne Befund: `git diff ba8698fc^ 19e2be67 -- .d-check.yml` zeigt ausschließlich den neuen Kommentar-Abschnitt und den neuen `waves:`-Unterblock; `modules:`, `scan.ignore` und alle sieben `ignore-refs`-Paare unverändert — keine Senkung, §3.5 nicht berührt (Aktivierung = Anhebung nach `MR-001`) |
| Schicht-Abgrenzung (§1 des Plans) | geprüft, ohne Befund: `git diff --stat ba8698fc^ 19e2be67` führt ausschließlich `.d-check.yml`, `harness/sensors/docs-check.md`, `test/**` und Planungs-/ADR-Artefakte außerhalb dieses Vier-Commit-Bogens — `internal/`, `cmd/`, `harness/tools/` unberührt |
| Rollen-Grenze §3.10 (Commit-Zuschnitt) | geprüft, ohne Befund: Slice-Plan-Datei, Roadmap, `docs/plan/planning/observations/**` und `docs/plan/planning/done/**` sind über keinen der vier Commits verändert — kein DoD-Häkchen, kein Closure-Feld, keine Risiko-Zeile angefasst |
| Rollen-Grenze §3.8 (HIGH-2, Runde 1) | geprüft, ohne Befund: die als offen übergebene Abweichungs-Frage wurde durch die Architect-Runde (`ADR-0046`) beantwortet, nicht durch den Implementer; `ca135c49` und `87557369` entscheiden sie ausdrücklich nicht selbst |
| Mutationsabdeckung (Runde-1-MEDIUM-2) | geprüft, ohne Befund: `test/mutations/` wächst über den Vier-Commit-Bogen von 304 auf 309 Dateien (+5: `319`–`323`), deckungsgleich mit der behaupteten Fall-Zahl; die vier Zusicherungen in `test/waves-modul-wiring.bats` haben je einen Fall, der ihr zuvor unerreichtes Prädikat trifft (322 → Zusicherung 1, 323 → Zusicherung 3, laut Runde-2-N-4, von mir am Fall-Text nachvollzogen) |
| Verwaister Mutationsfall (Runde-1-HIGH-3) | geprüft, ohne Befund: `test/mutations/273-planning-block-rumpf-entfernt.sh` zitiert im `# expect:`-Kopf *„planning: heading zeigt auf den Abschnitt 'Offene Wellen', nicht auf den Modul-Default"* — diese Zusicherung existiert wortgleich in `test/planning-modul-wiring.bats:45` |
| Zusammenfassungs-Präzision (Runde-2-MEDIUM-1) | geprüft, ohne Befund: `harness/sensors/docs-check.md:48-50` benennt jetzt den toten Zeiger als *„toter **Vorschau**-Zeiger"* und stellt daneben klar, dass ein toter Zeiger unter „Offene Wellen" über `wave-drift` fällt — kein Widerspruch mehr zum Absatz 20 Zeilen darüber |
| Reichweiten-Genauigkeit „genau das" (Runde-2-LOW-1) | geprüft, ohne Befund: der Satz nennt jetzt *„die Kopplung Datei ⟺ Zeiger"* statt *„genau das"* und benennt die dritte, ungedeckte Wirkung von ADR-0046 Festlegung 1 ausdrücklich |
| Gate-Nachweis | geprüft, ohne Befund: `bash harness/tools/working-tree-hash.sh` liefert `78a905bb95db5aee7a3f1d32106f6d5e5ef1238a82fd24b4a23114640b3c1946`, identisch mit `.harness/state/gates-passed.diffsha`; Arbeitsbaum sauber |
| Beobachtungs-Register-Kennungen | geprüft, ohne Befund: alle sieben von den beiden Review-Reports zitierten `BEO-ALL/*`-Kennungen existieren mit mindestens einer Evidence-Datei |
| Kein Konflikt-Pfad (Modul 8) | geprüft, ohne Befund: keines der vier Commits widerspricht einer Rollen-Entscheidung; der reguläre Weg Reviewer → Implementer genügte in beiden Runden |

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** DoD-Punkt enthält eine gemessen widerlegte Tatsachenbehauptung ·
Folgepflicht ohne notierten Ausgang · Überholter offener Plan ohne genormten Ausgang ·
Verifikation nach ungeschlossener Review-Runde

---

## Verdikt

**DoD: nicht erfüllt — an genau einem Punkt, und der Fehler liegt im Abnahmekriterium, nicht im
gelieferten Artefakt.**

Sieben der acht Liefer- und Gate-Kriterien halten vollständig: Die `waves`-Fähigkeit ist verdrahtet
und der Bestand bleibt grün (DoD 1), Richtung A ist einmal rot gesehen mit Kommando, Grund-Code und
Ausgabe im Umsetzungs-Commit (DoD 2), `make gates` ist über dem finalen Stand nachweislich grün
(Hash-Deckung `gates-passed.diffsha`), die Mutationsabdeckung ist nach der Runde-1-Nacharbeit
lückenlos für alle vier `waves`-Zusicherungen (309 Fälle, +5 gegenüber dem Ausgangsbestand), der
verwaiste Mutationsfall aus Runde 1 ist repariert, und die zwei Präzisions-Findings aus Runde 2
(MEDIUM-1, LOW-1) sind im finalen Diff `19e2be67` tatsächlich behoben — von mir unabhängig am Text
nachvollzogen, nicht nur in einer Commit-Message behauptet. Keine Gate-Lockerung, keine
Rollen-Grenzverletzung (§3.8, §3.10), kein Produkt-Code berührt, kein unentschiedener
Konflikt-Pfad.

**Was fehlt: DoD-Punkt (3), wörtlich gelesen, ist falsch (V-1).** Er verlangt eine Aussage über die
Sensor-Prosa, die die eigene Nachmessung des Umsetzungs-Laufs bereits im ersten Commit widerlegt
hat, und die beide Review-Runden unangetastet ließen, weil ihre Korrektur nach `AGENTS.md` §3.10
nicht in den Implementer- oder Reviewer-Kontext gehört. Das gelieferte Artefakt ist **inhaltlich
korrekt und deckt genau die Kante, die das Modul trägt** — aber es erfüllt den DoD-Punkt, indem es
ihm widerspricht, nicht, indem es ihn erfüllt. Ein Häkchen an DoD (3) würde eine falsche
Tatsachenbehauptung bestätigen; das Häkchen offen zu lassen und die Formulierung durch den Planner
zu korrigieren, ist der einzige Weg, der weder das Artefakt verfälscht noch die Zusage bricht.

**Für den Planner, vor der Closure:**

1. **DoD-Punkt (3) umformulieren** (nicht der Implementer — §3.10): Die Zusage muss die real
   gemessene Grenze tragen — ein toter Zeiger unter „Offene Wellen" ohne Datei fällt über `waves`
   (`wave-drift`), nur ein toter Zeiger in der Vorschau-Tabelle fällt ausschließlich über `links`.
   Nach dieser Korrektur ist DoD (3) durch den vorliegenden Stand von `harness/sensors/docs-check.md`
   erfüllt, ohne dass am Code oder an der Prosa noch etwas zu ändern wäre.
2. **V-2/V-3 als Closure-Notizen bzw. Folge-Hinweise aufnehmen** — keine Blocker, aber ohne
   Vermerk verschwinden sie zwischen zwei Rollen, die beide zu Recht nicht zuständig sind.
3. **V-4 ist kein Blocker**, aber der Planner sollte wissen, dass die Runde-2-Freigabe der letzten
   Nacharbeit nur durch diese Verifikation erfolgt ist, nicht durch eine dritte Reviewer-Runde.

**Übergabe:** Dieser Bericht geht an den Planner (Modul 8: Verifier → Planner,
*„DoD-/ADR-Konformitätsbericht + Plan-vs-Code-Diff"*). Er ersetzt keine Validierung — ob das
Ergebnis den realen Bedarf trifft, ist Sache des Validators und hier nicht geprüft.
