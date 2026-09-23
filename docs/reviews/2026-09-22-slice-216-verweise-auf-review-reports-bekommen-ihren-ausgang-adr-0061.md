# Review-Report: slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang (ADR-0061/MR-072) — 2026-09-22

**Review-Art:** Design — geprüft gegen ADR-0033/ADR-0039/ADR-0041/ADR-0042, gegen den
Slice-Plan §1/§2/§6 und gegen `AGENTS.md` §3.4/§3.5/§3.8/§3.11 (Modul 10 §Drei Review-Arten).
Kein Code-Review: der Slice schließt Produkt-Code ausdrücklich aus (§1 *Ausdrücklich NICHT in
diesem Slice*).

**Gegenstand:** Commit `1da9fa6c` (Rolle Architect) auf `main`, Range `085bf344..HEAD`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** claude-sonnet-5 · **Datum:** 2026-09-22

**Eingangs-Kontext:**

- `slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang` (Slice-Plan, `in-progress/`)
- ADR-0061 (`Proposed`, neu), ADR-0033/ADR-0039/ADR-0041/ADR-0042 (alle `Accepted`)
- `LH-QA-01`, `LH-QA-02`
- `MR-072` (neuer Adaptions-Eintrag), `MR-045`/`MR-028` (Verzeichnis-Form-Pflichtfelder)
- `AGENTS.md` §3 (Hard Rules)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die in ADR-0061/MR-072 als „gemessen, nicht erwartet" präsentierten Kernzahlen sind am Commit-Stand von `1da9fa6c` mit exakt denselben Kommandos nachgerechnet falsch: statt „144 von 345" liefert der Lauf 171 von 519 Verweisen, statt „44 `[haenger]`-Fundstellen" liefert `archive-welle --vorschau welle-13` 58, statt „9 eingefrorene Fundstellen" sind es 10. Slice-Plan (Autor Planner, 2026-09-12) und ADR (Architect, 2026-09-22, 10 Tage später, aktiv wachsender Report-Bestand) tragen dieselben Zahlen 144/345 wortgleich — ein Indiz, dass die Kommandos beim ADR-Verfassen nicht neu gelaufen sind, obwohl die Prosa das Gegenteil behauptet. | `MR-025` (Zahl neben Kommando) | `docs/plan/adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md:57-80`, `harness/conventions/MR-072-…:6-10` | ja — die im ADR selbst genannten Kommandos erneut laufen lassen (`for r in docs/reviews/*.md; do …`; `archive-welle --vorschau welle-13`) | Messung im ADR nicht am Commit-Stand aktualisiert |
| F-2 | MEDIUM | `docs/plan/planning/done/welle-v021-faehigkeit.md` §4 führt `slice-216-verweise-auf-review-reports-bekommen-ihren-ausgang` als Mitglied dieser Welle (Bezug `LH-QA-01`), obwohl der Slice-Kopf explizit „**Welle:** ohne Welle" mit ausführlicher Begründung trägt (*„kein repo-weiter Beleg, kein Replay; damit fehlt das Mehr"*). §4 ist keine bloße Querverweis-Liste, sondern die Menge, gegen die der Closure-Trigger der Welle misst (§3: „Alle Slices der Welle (§4) liegen in `done/`"); die Mitgliedschaft dort macht slice-216 faktisch zu einem Blocker der Welle-Closure, während der Slice selbst das Gegenteil festlegt. Die Baseline-Regel „wellenlose Slices werden von der nächsten Welle-Closure mit archiviert" deckt das nicht: sie betrifft ausschließlich Schritt 4 (Zeitdokumente archivieren), nicht die §4-Mitgliedschaft, die den Trigger gated. Thematisch passt slice-216 auch nicht zum in §1 der Welle beschriebenen Bündel (Zielordner, Release-Prozedur, Skeleton-Struktur, Fall-Anlage-Regel — Review-Report-Archivierungsmechanik kommt dort nicht vor). Entstanden ist der Widerspruch vor diesem Commit (welle-v021-faehigkeit.md wurde am 2026-09-20 vom Planner eröffnet, 8 Tage nach slice-216s „ohne Welle"-Festlegung) und wird von `1da9fa6c` nicht berührt — er sollte aber vor der Welle-Closure aufgelöst werden (slice-216 aus §4 entfernen, oder den Slice-Kopf korrigieren, falls die Welle-Zugehörigkeit tatsächlich gewollt ist). | Modul 5 §Lifecycle als State Machine, Modul 6 §Wann Arbeit eine Welle braucht | `docs/plan/planning/welle-v021-faehigkeit.md:87` vs. `docs/plan/planning/in-progress/slice-216-…md:8-11` | ja — Diff der beiden Dateien, `git log` der beiden Commits (`b23dcef4` vs. `6db33eb6`) | Welle-Mitgliedschaft widerspricht Slice-eigener Wellenlos-Erklärung |
| F-3 | LOW | ADR-0061 zitiert ADR-0042 in Anführungszeichen als scheinbar wörtliches Zitat (*„hier bricht ein Verweis, weil sein Ziel ersatzlos verschwindet; [in ADR-0042] wird ein Artefakt geschrieben, weil sein Ziel umzieht"*), ändert dabei aber den Wortlaut: Das Original in ADR-0042 sagt *„Dort **bricht** ein Verweis …; hier wird ein Artefakt **geschrieben** …"* — „Dort" wurde zu „hier", und „[in ADR-0042]" als Klammer-Einschub ergänzt. Inhaltlich korrekt übertragen, aber kein Byte-genaues Zitat trotz Guillemets. | Maintainability | `docs/plan/adr/0061-…md:21-22` (und wiederholt `:87`) | nein — Prosa-Genauigkeit, kein Gate-Lauf deckt Zitat-Genauigkeit außerhalb der vendored Baseline (`check-lines` prüft nur Code-Pfad-Referenzen) | Guillemet-Zitat mit stillschweigender Wortänderung |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Alternativen-Abwägung (§1 Slice-Plan / ADR-0061 §Vier Alternativen) | geprüft, ohne Befund — alle vier Alternativen (auflösen, Stub, Ventil, Ausnehmen) behandelt, je mit Preis; die qualitative Schlussfolgerung (Alternative b trägt) bleibt auch unter den in F-1 korrigierten Zahlen unverändert bzw. wird durch sie eher gestützt (mehr Hänger-Fundstellen, nicht weniger) |
| 0-Anker-Links-Messung (ADR-0061 §Was heute gemessen ist, Punkt 4) | geprüft, ohne Befund — `git grep -ohE '\]\([^)]*docs/reviews/[^)]*\.md#[^)]*\)' -- '*.md' ':!.harness/baseline'` liefert `0`, wie im ADR angegeben |
| DoD-Punkt 1 (ADR liegt, Status + Acceptance-Trigger) | geprüft, ohne Befund — Status `Proposed`, Acceptance-Trigger in §Geschichte konkret und beobachtbar formuliert (Reviewer-Runde ohne blockierenden Befund) |
| DoD-Punkt 2 (Abweichung ausgesprochen, `MR-072`-Struktur) | geprüft, ohne Befund — alle Pflichtfelder der Ziel-Form (Datum, Wirksamkeits-Anlass, Geltungsbereich, Ersetzt-Baseline-Regel, Adaption, Begründung, Auflösungs-Trigger) vorhanden; Index-Zeile in `harness/conventions.md` trägt korrekt gekürzte Geltungsbereich-/Ersetzt-Baseline-Regel-Felder mit `…` |
| DoD-Punkt 3 (Sensor-Stand benannt statt behauptet) | geprüft, ohne Befund — ADR-0061 §Fitness Function benennt explizit die Zeile ohne Sensor (die drei Gegenformen), mit `LH-QA-01`-Bezug |
| `AGENTS.md` §3.8 (Commit-Zuschnitt) | geprüft, ohne Befund — `git show --stat 1da9fa6c` zeigt ausschließlich vier Architect-Artefakte (ADR, ADR-Index, `harness/conventions.md`, `MR-072`-Datei); Commit-Message beginnt mit „Rolle Architect:" |
| `AGENTS.md` §3.7 (Kommentar-Disziplin) | geprüft, ohne Befund — keine rohen Commit-Hashes in den neuen Dateien (`grep -nE '\b[0-9a-f]{7,40}\b'` → leer); Prosa beschreibt Ist-Zustand im Präsens, keine Entstehungs-Narrative außer F-3 |
| `AGENTS.md` §3.4/§3.11 (ADR-Immutabilität, keine bewegliche Adresse in einfrierendem Artefakt) | geprüft, ohne Befund — ADR-0061 ändert keine `Accepted`-ADR inhaltlich; referenzierte ADRs/Pfade sind stabil, keine Slice-Lifecycle-Pfade als Adresse zitiert |
| Bezugs-Konsistenz zu ADR-0033/ADR-0039/ADR-0041/ADR-0042 | geprüft, ohne Befund — alle vier `Accepted`; die zitierten Festlegungen (Stub-Form Schritt 4, enge `ignore-refs`-Aufnahmegrenze, `haenger`-Sperre, Trennung „Verweis bricht" vs. „Artefakt wird geschrieben") stimmen mit den Quelldateien überein |
| `make gates` | geprüft, ohne Befund — Exit 0 auf dem geprüften Commit-Stand |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Messung im ADR nicht am Commit-Stand aktualisiert · Welle-Mitgliedschaft widerspricht Slice-eigener Wellenlos-Erklärung · Guillemet-Zitat mit stillschweigender Wortänderung

## Verdikt

**Merge-blockierend:** nein — beide MEDIUM-Findings sind Präzisions- bzw. Prozess-Lücken, keine
ADR-/Hard-Rule-Verstöße, keine Gate-Lockerung und kein stilles Grün. Die architektonische
Kern-Entscheidung (Alternative b, Report-Stub am unveränderten Pfad) trägt unabhängig von der
exakten Höhe der zitierten Zahlen — unter den korrigierten Werten (171/519, 58 Hänger, 10
eingefrorene Fundstellen) wird der Preis von Alternative a) sogar noch höher, nicht niedriger.

Empfehlung vor `Accepted`: F-1 durch eine erneute Messung am tatsächlichen Merge-Stand beheben
(Zahlen aktualisieren oder explizit als „Stand 2026-09-12, seither gewachsen" kennzeichnen). F-2
gehört nicht in diesen ADR-Lauf, sondern zur Planner-Rolle: vor der Closure von
`welle-v021-faehigkeit` klären, ob slice-216 Mitglied ist oder nicht — die beiden Quellen dürfen
nicht weiter widersprechen.

**Übergabe:** Findings gehen an den Architect (F-1, F-3) bzw. den Planner (F-2, betrifft
`welle-v021-faehigkeit.md`, nicht den geprüften Commit). Die Finding-Klassen gehen zusätzlich in
die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein Lauf-Beleg und ersetzt
keine Verifikation (Modul 11).
