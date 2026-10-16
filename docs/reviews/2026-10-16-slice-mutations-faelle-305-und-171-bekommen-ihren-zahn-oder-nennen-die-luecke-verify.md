# Verifikation slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke (HEAD d8e4cb5e)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `ebf6f927..HEAD`: `726cdd93` (Fall 305), `1607085d`
(Fall 171), `d8e4cb5e` (Koepfe nach Review); `harness/tools/full-smoke.sh` und `harness/tools/mutate.sh` sind nicht im Diff
(`git diff --stat ebf6f927..HEAD`: zwei Fall-Skripte plus Plan-Datei).
Mutations-Laeufe strikt einzeln, `SMOKE_ARTIFACT_TARGET=artifact-host`, `PATH=…gnubin`. Von Hand gebrochen in `git archive`-Kopien
unter `~/.colima-tmp`, am Ende entfernt. Geprueft ist die DoD vor Closure; Closure, Register, Paarungen und Haekchen sind Planner-Arbeit.

## Verdikte je DoD-Punkt

- **D1 Fall 305 — bestaetigt, Variante (ii) per Zwei-Dateien-Mutation.**
  - `# files: internal/span/emit.go docs/user/benutzerhandbuch.md`; `make mutate-greift` -> `653 Fall/Faelle, 653 greifen, 0 Befund(e)`.
  - Einzellauf `MUTATE_CASES=305-rollenachse-ziel-verliert-rolle-fullsmoke make mutate`: Gruen-Vorlauf 106 s, dann
    `ok 305-… -> FEHLER — Rollen-Typ fehlt rot`, `1 ok, 0 Befund(e)`, TEILLAUF 1 von 653, Beleg-Slot unberuehrt.
  - Von Hand (Kopie, Skript angewendet, `make full-smoke-host`, EXIT 2): Handbuch-Baum **gruen** (`94 Pfade … dokument-only decken den Bestand`,
    go 13, cpp 15), danach `full-smoke: FEHLER — Rollen-Typ fehlt (--lang go): .claude/agents/validator.md`. Nur diese Stufe faellt.
  - Kontrast (Kopie, nur `internal/span/emit.go` gekuerzt, Handbuch original): EXIT 2 mit
    `FEHLER — Handbuch-Baum (dokument-only): im Handbuch genannt, vom Lauf nicht angelegt: [.claude/agents/validator.md]`. Der Rot-Beleg
    traegt also die behauptete Ursache (Handbuch im Gleichschritt), nicht irgendeine.
- **D2 Fall 171 — bestaetigt: Muster lag vor, (ii) hergestellt.**
  - Quelle des alten Befunds selbst gelesen (`gh run view <id> --log`): Runs 38698945568, 38529836984, 38376387942, je Shard `mutate (2)`:
    `BEFUND 171-… rot, aber 'die Feldliste liegt nicht im GEPRUEFTEN Doku-Bereich' faellt nicht — falscher Grund` mit
    `full-smoke: FEHLER — Handbuch-Baum (dokument-only): im Handbuch genannt, vom Lauf nicht angelegt: [harness/erfassung-feldliste.md]; vom Lauf angelegt, im Handbuch nicht genannt: [.harness/erfassung-feldliste.md];`. Wortlaut stimmt.
  - Neue Mutation: `scan.ignore` der emittierten `.d-check.yml` nimmt `harness/erfassung-feldliste.md` auf, Pfad bleibt. `# files:` und `# expect: laesst das docs-check des Ziels GRUEN` gesetzt.
  - Einzellauf: `ok 171-… -> laesst das docs-check des Ziels GRUEN rot`, 0 Befund. Von Hand (Kopie, EXIT 2): Handbuch-Baum gruen (dokument-only 95 Pfade, go 13, cpp 15), dann
    `full-smoke: FEHLER — ein toter Verweis in harness/erfassung-feldliste.md laesst das docs-check des Ziels GRUEN: das Dokument liegt ausserhalb des geprueften Bereichs`
    (`full-smoke.sh` ~996, Zweig `feldzahn_rc -eq 0`).
  - Zahn misst die Zusage, nicht die Anwesenheit: das Dokument ist angelegt und im Handbuch genannt (Handbuch-Baum gruen); rot wird erst die Aussage, dass docs-check des Ziels einen toten Verweis dort sieht — ADR-0022 Festlegung 7 (GEPRUEFTER Bereich).
- **D3 `make gates` — bestaetigt.** EXIT 0 am HEAD `d8e4cb5e`; `.harness/state/gates-passed.head` == `git rev-parse HEAD`; `git status --short` leer;
  `d-check: 2726 Datei(en) geprueft, 0 Befund(e)`. `make mutate-greift` 653/653.
- **D4 Review — Report liegt vor** (`docs/reviews/2026-10-16-slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke.md`, 0 HIGH 0 MEDIUM 2 LOW 2 INFO); Inhalt nicht neu beurteilt.
- **D5–D8 Closure, Register, Risiko-Ausgaenge, Paarungen — nicht dran** (Planner).

## Koepfe (§3.6 / §3.7) und Reviewer-LOWs

- LOW-1 behoben: Kopf 305 sagt „unter den Stufen von full-smoke.sh … sieht dann nur rollen_typen_im_ziel“ und nennt, dass unter `make test` `agents_test.go` und `rollen_kopplung_test.go` dieselbe Kuerzung faerben (Stichprobe: Kopf gelesen, Tests nicht neu gebrochen).
- LOW-2 behoben: beide Koepfe fuehren die Kopplung im Indikativ (Handbuch-Baum steht vor …; bleibt gruen), kein Konjunktiv ueber die verworfene Alternative, keine Befund-Kennung, keine Chronik.
- Aussage ueber 614/615: Fall 615 mutiert `internal/emit/enforce.go` (`return FieldList(targetDir)` -> `return nil`), `# expect:` nennt `im Handbuch genannt, vom Lauf nicht angelegt: [harness/erfassung-feldliste.md]`; CI-Logs der Runs 38529836984/38376387942 zeigen `ok 615-… -> …` mit genau dieser Meldung. **Stimmt fuer 615.**
- **F-1 (INFO): Kopf 171 nennt „die Faelle 614 und 615“ als Halter der Stufe fuer die Ablage der Feldliste; 614 mutiert `docs/plan/carveouts` (`.gitkeep`), nicht die Feldliste.** Es haelt dieselbe Stufe, aber nicht fuer diesen Pfad. Kein Verhaltensbefund, die Zusage ist an 615 voll belegt; Praezisierung nur bei Anfassen des Kopfes.

## Planabweichung — bestaetigt als Erfuellung

- Plan/Architect nannte fuer 305 nur die Datei-Anlage als (ii) und hielt eine `sed`-Variante fuer nicht herstellbar. Gebaut ist eine andere (ii): `CanonicalRoles` gekuerzt **und** die Zeile `│       └── validator.md` im Baum von `docs/user/benutzerhandbuch.md` §6 gestrichen. Das erfuellt den DoD-Wortlaut (Zahn zurueck, `FEHLER — Rollen-Typ fehlt` rot); beide `# expect:`-Zusagen sind gemessen (oben).
- Die Annahme „nicht herstellbar“ ist am **Handbuch** widerlegt, nicht am Emissions-Code: der Emissions-Code allein bleibt unherstellbar (Kontrast-Lauf faellt am Handbuch-Baum); herstellbar wird es, weil der Baum eine Zeile fuehrt, die im Gleichschritt mitwandert. Datei-Anlage und Fallback (i) sind nicht noetig; `harness/tools/full-smoke.sh` bleibt unveraendert, passend zum Plan-Eintrag „update nur bei (i)“.
- Plan-vs-Code: Plan §3 nennt Fall 305 (update) und 171 (pruefen, Aenderung bei Befund) — gebaut: beide Faelle geaendert, 171 mit Befund aus den CI-Logs. Nichts Gebautes ausserhalb des Plans. Die Plan-Aussage „Variante (ii) per Datei-Anlage“ ist nach der Messung veraltet; Aktualisierung gehoert in die Closure-Notiz (Planner).
- DoD-Punkt 2 nennt „Wortlaut aus dem Lauf in §7“: §7 ist noch leer (Closure); der Wortlaut steht hier und im CI-Log.

## Offene Punkte / Luecke

- **Benannte Luecke bestaetigt:** der lokale Weg `SMOKE_ARTIFACT_TARGET=artifact-host` fuer `# verify: full-smoke`-Faelle steht in keiner Doku; `grep -rn SMOKE_ARTIFACT_TARGET docs harness/README.md harness/sensors Makefile` trifft nur `Makefile:225` (Rezept `smoke-host`). Kein Sensor prueft das. Deckt sich mit Reviewer INFO-1.
- Mehrfach-Lauf nicht gefahren (Plan §6, bewusst einzeln); beide Einzellaeufe liefen ohne Docker-Aussetzer.
- Zeit: Einzellauf je ~130 s gesamt, davon Gruen-Vorlauf ~106 s (Variante host).
