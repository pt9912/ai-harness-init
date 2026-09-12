# Review — ADR-0041 (wellenloser Altbestand geht in ein Sammel-Archiv)

**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Skill:** `.harness/skills/reviewer.md` v1.7.0
**Gegenstand:** Commit `5969a86b` — `docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md` (`Proposed`) + `docs/plan/adr/README.md`
**Plan:** `docs/plan/planning/in-progress/slice-183-ausloeser-der-wellenlosen-archivierung.md` · **Baum:** sauber (`git status --porcelain` leer)

## Findings

**HIGH-1** · `ADR-0016` Festlegung 2 · `docs/plan/adr/0041-…md:243`, `:288`, `:211`, `:236`, `:299`
Die ADR nennt `ADR-0016` im Bezug als *„die Form, in der hier aus dem Regelwerk zitiert wird"*, trägt aber an fünf Stellen eine Regelwerks-Aussage ohne die dort verlangten drei Teile (Tag · Datei+Abschnitt · Zitat verbatim): Zeile 243 stützt das *Kein-`Supersedes`* auf *„die Baseline benennt den Träger für den wellenlosen Fall selbst"* — ohne Tag, Datei, Abschnitt und Zitat; Zeile 288 zitiert verbatim *„die Zahl der archivierten Vorgänge"* ohne Tag und Fundstelle. Ab `Accepted` friert das ein, und der Leser kann die Trigger-Feuerung nicht nachvollziehen — zumal `modul-06` das Wort *Träger* für den Prozess-Schritt (`Slice-Closure`) führt, `ADR-0033` Festlegung 1 für das Produkt-Binär.
*verifizierbar:* nein — kein Modul in `grep -n '^modules:' .d-check.yml` liest Zitat-Deckung. *klasse:* Regelwerks-Aussage in einfrierendem Artefakt ohne Drei-Teile-Beleg.
*Beleg:* `grep -nE 'Ziel-Fassung|die Baseline' <adr> | grep -v 'v6\.5\.0'` → 8 Zeilen; `grep -cF 'die Zahl der archivierten Vorgänge' <(tr '\n' ' ' < .harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md)` → 1.

**MEDIUM-1** · Baseline `modul-04-adrs.md` §Ziel-Form: ADR (MADR) · `:60`, `:277`, `:278`, `:279`
Die Abwägung misst A und C an einem unveränderlichen Werkzeug und B an einem veränderlichen. Zeile 279 verwirft *„nichts tun"* — die von der Quelle ausdrücklich freigestellte Option — mit *„Der unter ADR-0033 gebaute Träger bliebe in diesem Repo dauerhaft unbenutzbar"*, während Zeile 278 für die gewählte Option dieselbe Klasse Werkzeug-Arbeit als *„Die Betriebsart fehlt und steht als Folgepflicht"* verbucht; Zeile 60 nennt nur A *„nicht darstellbar"*, obwohl §Kontext (6) misst, dass B heute ebenso sperrt. Eine Option „Werkzeug ändern, Altbestand flach lassen" bleibt damit ungeprüft.
*verifizierbar:* nein. *klasse:* Alternativen-Vergleich mit asymmetrischer Prämisse.

**MEDIUM-2** · `MR-025` / Maintainability · `:178`–`:182`
*„Von den fünf Sperren hängen drei an der Welle-Form und eine an der fehlenden Untergrenze … `[unsauber]` … und `[haenger]`"* verteilt sechs Plätze auf fünf beobachtete Sperren. Von den fünf zitierten (`unsauber`, `ergebnisnotiz`, `kein-plan`, `untergrenze`, `haenger`) hängen **zwei** an der Welle-Form; die dritte (`mehrdeutiger-plan`) existiert im Code, feuert in diesem Lauf aber nicht. Ein Leser, der die Partition nachzählt, findet den Widerspruch nach dem Einfrieren.
*verifizierbar:* ja — `.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand` am sauberen Baum → 4 Sperren, davon `ergebnisnotiz` und `kein-plan` welle-gebunden. *klasse:* Partition über gemessener Menge geht nicht auf.

**LOW-1** · `MR-025` · `:170`–`:176` — Der zitierte Lauf meldet *„Sperren: 5"*; dasselbe Kommando liefert am sauberen Baum **4** (kein `[unsauber]`). Die ADR benennt die Ursache, die Zahl neben dem Kommando bleibt trotzdem nicht reproduzierbar. Der Block lässt zudem die `fremd`-Zeile (91) aus, die (2) führt. *verifizierbar:* ja, Kommando oben. *klasse:* eingefrorene Zahl aus transientem Baum-Zustand.

**LOW-2** · `LH-QA-01` · `:331` vs. `internal/archive/vorschau.go:124` — Die Fitness-Zeile sagt *„Solange kein `done/*/archiv.zip` liegt, sperrt jeder Lauf mit `[untergrenze]`"*; `untergrenzeSperre` verlangt zusätzlich `len(b.Wellenlose) > 0`. §Kontext (3) nennt beide Konjunkte, die Fitness-Zeile nur einen. *verifizierbar:* ja (`--vorschau` über einem Schlüssel ohne wellenlose Slices). *klasse:* Sensor-Zusage weiter als der Code.

**LOW-3** · ADR-Vorlage §Geschichte / `AGENTS.md` §5 · `:360` — Die Spalte `Verweis` trägt keinen Verweis, sondern eine Wiederholung von §Kontext. `AGENTS.md` §3.11 verbietet den **Pfad** des wandernden Slice-Plans, nicht seine **Kennung**; die Zeile nennt weder Kennung noch Commit, und die Herkunft der Entscheidung ist nach dem Einfrieren nur über `git` auffindbar. *verifizierbar:* nein. *klasse:* Verweis-Feld trägt Chronik statt Adresse.

## Negativbefunde (geprüft, ohne Befund)

- **Zentrale Messung (Prüfpunkt 1):** nachgefahren — `--vorschau` für `welle-01/02/07/13/15` meldet je **57** wellenlos; `internal/archive/collect.go` klassifiziert allein über `WelleFeld`/`KlasseVon`, kein Zeitfilter. Die Prämisse trägt.
- **Zahlen (Prüfpunkt 3):** 57 · 148 · 3/12/0 · 48 über 10 Wellen · 9 ohne Adressat · **153 von 347** Reports · `grep -c 'Kennung: "'` → 8 — alle sechs Blöcke mit den abgedruckten Kommandos nachgerechnet, alle identisch.
- **Option C (Prüfpunkt 2, Sachfrage):** `untergrenzeSperre` feuert bei 57 flachen wellenlosen Slices ohne `done/*/archiv.zip` für **jede** Welle — an allen sechs geprüften Schlüsseln beobachtet. Die Tatsachen-Hälfte der Aussage trägt (die Prämissen-Hälfte steht als MEDIUM-1).
- **Festlegung 5 (Untergrenze durch das Sammel-Archiv):** `untergrenze()` prüft **jedes** Unterverzeichnis von `done/` auf `archiv.zip`, nicht nur `welle-*`; `Einsammeln` liest `done/` nicht rekursiv. Der Schlüssel `altbestand` setzt die Grenze und entzieht die Stubs dem Einsammeln.
- **Festlegung 2 am Werkzeug:** `internal/archive/anwenden.go` schreibt `done/<b.Welle>/archiv.zip` generisch — die Form ist mit einem welle-freien Schlüssel darstellbar, sobald Folgepflicht 1 vorliegt.
- **`AGENTS.md` §3.11 (Prüfpunkt 4):** keine Slice-Kennung und kein Pfad auf ein wanderndes Artefakt — `grep -noE 'slice-[0-9]+' <adr>` → leer; alle Pfade sind Verzeichnis, Glob oder stehende Ablage (Beobachtungs-Register).
- **Kein-`Supersedes` gegen `ADR-0033`:** keine ihrer Festlegungen wird berührt; von ihren **fünf** Re-Evaluierungs-Triggern ist keiner der drei übrigen gefeuert. Die Einordnung *Entscheidung daneben statt Änderung* entspricht `AGENTS.md` §3.4. (Welcher Trigger feuert, steht als HIGH-1.)
- **Fitness Function (Prüfpunkt 5):** die Leere ist korrekt — `modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]`, keines urteilt über Archive; `archive-welle` steht in `exempt-targets` und ist in `harness/README.md` als *kein Gate, in keiner Prerequisite-Kette* geführt. Einordnung der `untergrenze`-Sperre trägt.
- **Blockzitat §Kontext:** verbatim nach `ADR-0016` (Auszeichnung entfernt, Whitespace normalisiert) gegen `v6.5.0` geprüft, Treffer 1.
- **Index-Zeile (`docs/plan/adr/README.md:48`):** Titel, Status und Bezug-Menge deckungsgleich mit der ADR, Form wie die Nachbarzeilen.
- **Gegen den Slice-Plan:** DoD 1–3 sind durch §Entscheidung, §Was diese Entscheidung nicht tut und §Fitness Function adressiert; die Abgrenzung *„Ausgang der Verweise ist nicht Teil dieses Slice"* ist in Festlegung 4 gewahrt.

## Kategorie-Summary

HIGH 1 · MEDIUM 2 · LOW 3 · INFO 0

## Verdikt

**Blockierend.** HIGH-1 und MEDIUM-1/-2 sind vor dem Accept-Übergang zu klären; alle drei betreffen Text, der ab `Accepted` nach `AGENTS.md` §3.4 nicht mehr korrigierbar ist. Die Sachentscheidung selbst — Sammel-Archiv statt Welle — ist gemessen gestützt und wird von keinem Befund widerlegt; beanstandet sind die Beleg-Form (HIGH-1), die Prämissen-Symmetrie der Abwägung (MEDIUM-1) und eine nicht aufgehende Partition (MEDIUM-2). Der Acceptance-Trigger der ADR (*„Report ohne blockierenden Befund"*) ist mit diesem Report **nicht** eingelöst; der Beleg ist nach `ADR-0040` Festlegung 2 eine erneute Reviewer-Runde.
