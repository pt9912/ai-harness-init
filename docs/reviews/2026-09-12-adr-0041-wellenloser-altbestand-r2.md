# Review — ADR-0041, Runde 2 (wellenloser Altbestand geht in ein Sammel-Archiv)

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Skill:** `.harness/skills/reviewer.md` v1.7.0
**Gegenstand:** Commit `379def11` gegen `5969a86b` — `docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md` (`Proposed`)
**Plan:** `slice-183` · **Vorrunde:** `docs/reviews/2026-09-12-adr-0041-wellenloser-altbestand.md` · **Baum:** sauber (`git status --porcelain` leer)

## Findings

**MEDIUM-1** · `slice-183` DoD 2 / `v6.5.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz · `0041-…md:271`, `:276` gegen `slice-183-…md:134`, `:71`
Die ADR setzt *„keiner ihrer fünf Re-Evaluierungs-Trigger ist gefeuert"*; ihr Slice-Plan verlangt in DoD 2 das Gegenteil — *„gefeuert ist **einer** ihrer Trigger"* — und begründet es in §1 mit der sechsten Zeile der Träger-Tabelle. Die ADR kehrt die Prämisse um, ohne die Abweichung zu benennen; die Sequenz verlangt für den Rückweg zum Planner ein Artefakt (*„Kein Pfeil ohne benennbares Artefakt"*), und ab `Accepted` ist die Stelle nach [`AGENTS.md`](../../AGENTS.md) §3.4 unerreichbar, während DoD 2 wörtlich unerfüllbar wird.
*verifizierbar:* nein — kein Modul aus `grep -n '^modules:' .d-check.yml` hält DoD gegen ADR. *klasse:* ADR kehrt eine DoD-Prämisse um, ohne sie zu benennen.

**MEDIUM-2** · Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR) · `0041-…md:327`
Die Contra-Zelle der neuen Option E behauptet *„Verlangt dieselbe Betriebsart-Arbeit wie B **und** darüber hinaus …"*. Diese Obermenge besteht nicht: Folgepflicht 1 (`:354`–`:360`) nennt für B **vier** aufzuhebende Ausgänge — `ergebnisnotiz`, die zwei um den Welle-Plan, `untergrenze` —, E lässt den Altbestand flach, archiviert weiter unter Welle-Kennungen und berührt von den vieren allein `untergrenze`. Die Kosten-Achse der Abwägung kippt damit zuungunsten der einzigen Option, die diese Runde erstmals sieht — dieselbe Klasse, die die Vorrunde als MEDIUM-1 führte, in der Option, die sie beantworten sollte.
*verifizierbar:* ja — `grep -o 'Kennung: "[a-z-]*"' internal/archive/vorschau.go` gegen `--vorschau welle-01` (Sperren nur `untergrenze`, `haenger`; keine welle-gebundene). *klasse:* Kosten-Obermenge über eine verworfene Option behauptet.

**LOW-1** · [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2 · `0041-…md:159`
Der Nenner `# 153 von 347` gab schon an seinem eigenen Commit **348** aus (`git ls-tree -r --name-only 379def11 docs/reviews | grep -c '\.md$'` → 348; an `5969a86b` → 347), und der Block trägt als einziger der sechs keine *„kein Erwartungswert"*-Zeile — die Zahl friert unreproduzierbar ein. *verifizierbar:* ja, Kommando im Block. *klasse:* eingefrorene Zahl aus transientem Baum-Zustand.

**INFO-1** · `0041-…md:326` — Die Pro-Zelle von Option D stützt sich auf *„ein Nachbar-Repo desselben Nutzers hat sie gebaut"*; kein Kommando dieses Repos belegt das. Nicht tragend (D ist an drei anderen Gründen verworfen), aber es friert als Behauptung ein. *verifizierbar:* nein. *klasse:* Beleg außerhalb der prüfbaren Menge.

## Negativbefunde (geprüft, ohne Befund)

- **Prüfpunkt 2 — Träger-Unterscheidung (das verlangte Urteil):** Sie **trägt**. Die Tabelle in `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht führt in ihrer Spalte durchgängig Prozess-Momente (`Slice-Closure §7`, `Slice-Planung, §8`), ADR-0033 Festlegung 1 ein ausführendes Artefakt; dieselbe Quelle sagt zum Artefakt nur *„deshalb gehört die Operation in ein Werkzeug und nicht in Handarbeit"* (verbatim, 1 Treffer) — ein Werkzeug verlangt, keines benannt. **Unabhängig bestätigt:** Trigger 1 ist *feedforward* auf eine Baseline-**Änderung**; die sechste Zeile stand schon in `v6.5.0`, unter dem ADR-0033 am 2026-09-10 `Accepted` wurde. Damit trägt das Kein-`Supersedes` doppelt.
- **Prüfpunkt 1 — Verwerfung von Option E:** sachlich tragfähig, aber nicht in allen drei Contra-Punkten (MEDIUM-2). Die zwei übrigen halten: `[haenger]` feuert real auch für `welle-01` (nachgefahren, Sperren `untergrenze` + `haenger`), und der Pro-Satz *„würde für künftige Wellen benutzbar"* ist damit widerlegt — E fällt auch ohne den beanstandeten Satz.
- **Prüfpunkt 5 — Festlegungen unverändert:** die fünf Leitsätze sind gegen `git show 5969a86b:<datei>` byte-gleich (`diff` der `^\*\*[1-5]\. `-Blöcke: nur Zitat-Ergänzungen, kein normativer Satz bewegt); Wahl-Satz und Kopf identisch.
- **Prüfpunkt 4 — Zitate:** 20 Zitat-Formen aus `modul-06-roadmap.md` (`v6.5.0`) über whitespace-/auszeichnungs-normalisiertem Quelltext geprüft — je **1** Treffer, einzig die kurze Form *„Repo ohne Wellen"* 2, weil sie Teilzeichenkette der Spaltenüberschrift ist. Darin alle fünf Segmente des Blockzitats, die Tabellenzeile samt Pipe und *„die Zahl der archivierten Vorgänge"*. Die drei ADR-0033-Zitate (Trigger 1, Trigger 2 samt Nachsatz) ebenfalls je 1 Treffer.
- **Prüfpunkt 3 — HIGH-1 der Vorrunde:** an der Substanz behoben. Jede Baseline-Aussage trägt jetzt Tag, Datei, Abschnitt und Zitat ([ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2); die zwei Paraphrasen in Anführungszeichen (*„wellenlos seit der letzten Closure"*, *„Ziel-Fassung"*) sind durch verbatim-Zitate ersetzt.
- **Prüfpunkt 3 — MEDIUM-1/-2, LOW-1/-2 der Vorrunde:** Prämisse ist jetzt für alle Optionen dasselbe änderbare Werkzeug (`:58`–`:66`); die Partition geht auf (4 Sperren = 2 welle-gebunden + `untergrenze` + `haenger`, Sperre ≠ Code-Ausgang getrennt benannt); der `altbestand`-Lauf ist am sauberen Baum neu gemessen; die Fitness-Zeile trägt beide Konjunkte von `untergrenzeSperre` (`len(b.Wellenlose) == 0 || b.Untergrenze != ""`).
- **Messungen nachgefahren:** 57/148 · 3/12/0 · 48 über 10 Wellen, 9 ohne Adressat, Closures nicht in Nummern-Folge · 12 Evidence-Dateien · `grep -c 'Kennung: "'` → 8 · `--vorschau altbestand` → 0/57/91/144, 4 Sperren, Exit 3 · `--vorschau welle-01` → 4/57/87/150, 2 Sperren. Alle identisch mit der ADR (Ausnahme LOW-1).
- **`AGENTS.md` §3.11:** kein Pfad auf ein wanderndes Artefakt — die drei `../planning/…`-Links zeigen auf ein Verzeichnis und auf die stehende Ablage des Beobachtungs-Registers; der Slice ist als Kennung `slice-183` genannt, Folgepflicht 1 verweigert die Kennung des Folge-Slice ausdrücklich.
- **`AGENTS.md` §3.4 / LOW-3 der Vorrunde:** die `Verweis`-Spalte trägt jetzt die Kennung `slice-183` plus das auslösende Zitat — Adresse statt Chronik. Dass für den Nacharbeits-Lauf keine zweite `Überarbeitet`-Zeile steht, ist **kein** Verstoß: die Ziel-Form (`v6.5.0`, `templates/docs/plan/adr/NNNN-titel.template.md` §Geschichte) führt nur `Proposed` und `Accepted`; die Mehrzeilen-Form von ADR-0033 ist Praxis, keine Norm.
- **Fitness Function / `LH-QA-01`:** die Leere ist gemessen — `modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]`, keines urteilt über Archive; `--vorschau` ist korrekt als *kein Gate, in keiner Prerequisite-Kette* eingeordnet.
- **Gegen den Slice-Plan im Übrigen:** DoD 1 und 3 sind durch §Entscheidung und §Fitness Function eingelöst; die vier Out-of-Scope-Punkte sind gewahrt, insbesondere *„Der Ausgang der eingehenden Verweise"* durch Festlegung 4.

## Kategorie-Summary

HIGH 0 · MEDIUM 2 · LOW 1 · INFO 1

## Verdikt

**Blockierend.** Die Sachentscheidung — Sammel-Archiv statt Welle — ist gemessen gestützt, und beide vorgelegten Prüfpunkte tragen: die Träger-Unterscheidung hält (doppelt), die Verwerfung von Option E hält in der Sache. Beanstandet ist zweimal Begründungstext, der ab `Accepted` einfriert: eine gegen den eigenen Slice-Plan umgekehrte, aber nicht benannte Prämisse (MEDIUM-1) und eine Kosten-Obermenge über die neue Option E (MEDIUM-2). MEDIUM-1 ist ein Rollen-Widerspruch zwischen Architect und Planner und gehört nach `v6.5.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz auf den Verdikt-Pfad *„ADR gilt, Slice-Plan hat falsch behauptet"* mit Plan-Diff als Übergabe-Artefakt — nicht in diese Datei hinein.
Der Acceptance-Trigger (*„Report ohne blockierenden Befund"*) ist mit diesem Report **nicht** eingelöst; der Beleg ist nach [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 eine **dritte** Runde derselben prüfenden Rolle.
