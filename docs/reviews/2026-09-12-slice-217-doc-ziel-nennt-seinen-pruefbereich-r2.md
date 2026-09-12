# Review R2 — slice-217: `doc-*`-Ziel nennt seinen Prüfbereich (Nacharbeit)
**Rolle:** Reviewer · **Datum:** 2026-09-12 · **Skill:** `.harness/skills/reviewer.md` 1.7.0 · **Gegenstand:** `0dc740e8` — `d-check.mk`, `harness/sensors/doc-tracked.md`, `harness/sensors/doc-structure.md`, `test/doc-block-marke-wiring.bats` (+102/−28)
**Plan:** [`slice-217`](../plan/planning/in-progress/slice-217-doc-ziel-nennt-seinen-pruefbereich.md) · **Runde 1:** [Report](2026-09-12-slice-217-doc-ziel-nennt-seinen-pruefbereich.md) (0 HIGH / 4 MEDIUM / 1 LOW; MEDIUM-4 laut Auftrag durch slice-114 erledigt, nicht Gegenstand)
**Quellen:** [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7, [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) · alle Läufe netzlos über dem Digest aus [`d-check.mk`](../../d-check.mk), Mount `:ro`, kein Build

## Findings
### MEDIUM-1 — Die Schärfung tauscht den `@echo`-Anker gegen den Positions-Anker, die Zusage deckt weiter beide
`quelle` [`AGENTS.md`](../../AGENTS.md) §3.6 · `pfad` `test/doc-block-marke-wiring.bats:47`, `harness/sensors/doc-structure.md:67-69` · `verifizierbar` ja — `make test-bats` über einer mutierten `d-check.mk` · `klasse` Sensor gewinnt eine Achse und verliert eine andere, Zusage deckt weiter beide
`em = (index($0, marke) > 0) ? 1 : 0` nimmt **jede** Rezept-Zeile statt wie bisher nur `^\t@echo`; die Zusage daneben sagt, der Wächter prüfe die Textform „**und damit, ob sie *erscheinen würde***". Gemessen mit den aus dem bats-Text extrahierten Funktionen über Kopien von `d-check.mk` (`diff <(c_ziele) <(marke_ausgabe_ziele)`):

| Mutation an `d-check.mk` | `0dc740e8^` | `0dc740e8` |
|---|---|---|
| `@echo` **vor** `docker run` (Runde-1-Fall) | grün | **rot** ✔ |
| Zeile 112 `@echo ` → `@: ` — Marke bleibt letzte Rezept-Zeile, Lauf gibt nichts aus | rot | **grün** |
| `@echo` gelöscht, Marke als `#`-Kommentar an der `docker run`-Zeile | rot | **grün** |

Versagen: in den zwei unteren Formen trägt die letzte Rezept-Zeile das Literal und der Wächter bleibt grün, während die Marke gar nicht erscheint bzw. als von `make` vorab echote Kommandozeile **vor** der Befund-Ausgabe — genau die Reihenfolge, gegen die der Slice antritt.

### MEDIUM-2 — Die Marke adressiert einen Abschnitt, den es nach slice-114 nicht mehr gibt
`quelle` DoD (2) des Plans (*„zeigt auf den Absatz aus (1)"*) · `pfad` `d-check.mk:110,112,119,121`, `test/doc-block-marke-wiring.bats:22` · `verifizierbar` ja — `make doc-tracked`, `make doc-help` · `klasse` Zeiger überlebt den Ortswechsel seines Ziels nicht
Die Marke sagt *„siehe harness/README.md Abschnitt zu doc-tracked/doc-structure"*; `grep -c 'fuehrt fuer dieses Modul keinen eigenen Block' harness/README.md` → **0**, `grep -n 'doc-tracked' harness/README.md` → zwei Tabellenzeilen, die nach `sensors/doc-tracked.md` weiterzeigen. Versagen: `make doc-tracked` endet real mit dieser Zeile (gefahren: `1168 Datei(en), 0 Befund(e)` + Marke), wer ihr folgt, findet im Einstieg keinen solchen Abschnitt — und `MARKE=` im Wächter friert die Adresse zusätzlich ein.

### LOW-1 — `DoD (3)` als Zeiger in einem lebenden Sensor-Dokument
`quelle` Maintainability · `pfad` `harness/sensors/doc-structure.md:67` · `verifizierbar` nein — Urteil · `klasse` Verweis auf die interne Gliederung eines Zeitdokuments
Der neue Absatz verweist auf „den Wächter aus DoD (3)", ohne Link und ohne den Slice zu nennen; die Nummerierung lebt im Slice-Plan, der nach `done/` wandert und dort zum Stub gekürzt wird.

## Negativbefunde (geprüft, ohne Befund)
- **R1-MEDIUM-1 aufgelöst:** das Kopf-Kommando liefert **8**; die Hunk-Köpfe (`1,13c1,64 · 15c66 · 26,27c77,78 · 59c110 · 60a112 · 67c119 · 68a121 · 75,76c128,129`) belegen die Erklärung Handgriff für Handgriff — vier aus 1–4, vier aus Handgriff 5.
- **R1-MEDIUM-2, Positions-Hälfte aufgelöst:** Zeile 1 der Tabelle oben; die Grenze (`docker run` bricht ab → `make` erreicht das `@echo` nie) steht unmittelbar unter der Zusage, die sie einschränkt, und nennt `doc-tracked` als den erreichbaren Fall — also an der richtigen Stelle.
- **R1-MEDIUM-3 aufgelöst:** die `doc-structure`-Kette **verbatim** über einer Kopie von `0dc740e8` außerhalb des Repos gefahren → `1163 Datei(en), 0 Befund(e)` ohne Block, `1163 … 100 Befund(e)` mit Block, Befundzeile wie abgedruckt; die Flag-Listen beider Dokumente sind mit `d-check.mk:111`/`:120` mengengleich (md5 über die sortierten Flags). Das `--config` im zweiten Lauf ist redundant (Auto-Discovery gemessen), verfälscht das Paar nicht.
- **R1-LOW-1 aufgelöst:** `--print-config` führt `tracked.exempt-targets: []` („Globs über den AUFGELÖSTEN Zielpfad") und `targets.exempt-targets` („Regelnamen EXAKT (kein Glob, anders als tracked)") — genau die Trennung, die der neue Absatz zieht.
- **Ableitung intakt:** `c_ziele()` zählt weiterhin keinen Zielnamen auf; über der von `test/mutations/309-*.sh` mutierten Datei liefert sie `doc-citations-probe doc-structure doc-tracked`, die Bijektion fällt — der Mutations-Fall beißt nach der Schärfung unverändert.
- **slice-114, zweite Frage:** jede Aussage steht einmal — der Vier-Klassen-Block nur in `harness/sensors/doc-tracked.md` (dazu im Plan), Marke- und Grenze-Absatz nur in `doc-structure.md`, `harness/README.md` trägt zwei Tabellenzeilen ohne Inhaltskopie; keine Doppelung (zur Adresse s. MEDIUM-2).
- **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), [`AGENTS.md`](../../AGENTS.md) §3.7, [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert):** jede Zahl steht neben ihrem Kommando und nennt, wo sie wandert; die neuen Kommentare stehen im Indikativ über die Stelle, tragen Zusage/Abgrenzung/Grenze und weder Slice-Nummer noch Befund-Kennung; Handgriff 5 bleibt als Nachpflege deklariert.
- **Out-of-Scope gehalten:** `.d-check.yml`, `internal/`, `cmd/`, `test/mutations/` unberührt (`git show --name-only 0dc740e8`); kein neues `make`-Ziel, keine neue Gate-Tabellenzeile ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## Summary und Verdikt
0 HIGH · 2 MEDIUM · 1 LOW · 0 INFO. Drei der vier Runde-1-Befunde sind belegt aufgelöst; wiederkehrende Klasse über beide Runden ist **die Zusage reicht weiter als der Sensor, der sie hält** (R1-MEDIUM-2, hier MEDIUM-1) — zweites Auftreten, Kandidat für §7.
**Blockiert** — 2 MEDIUM. Der Kern trägt: Hunk-Zahl gemessen und erklärt, Gegenproben fahren verbatim, Schlüssel-Verwechslung behoben, abgeleitete C-Menge und Mutations-Fall unversehrt. Offen sind die beim Positions-Anker eingetauschte Ausgabe-Achse (MEDIUM-1) und die Adresse, auf die die Marke zeigt (MEDIUM-2).
