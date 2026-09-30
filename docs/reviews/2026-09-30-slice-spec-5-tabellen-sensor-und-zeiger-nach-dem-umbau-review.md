# Review-Report: slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau — 2026-09-30

**Review-Art:** Code — gegen Plan, ADR und Hard Rules (nicht gegen die DoD; das ist die Verifikation).

**Gegenstand:** Commit-Range `7bc65747..HEAD` (`72ab4387`, `6a022725`, `fe5a26c0`, `a1599ed5`, `3ab9b2eb`, `54943cd8`); 13 Dateien, +322/−33.

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · **Modell:** claude-sonnet-5-5 · **Datum:** 2026-09-30

**Eingangs-Kontext:** Slice-Plan `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau` (vier Liefer-Punkte, Größenregel begründet verletzt, §4 Rückführungen) · `ADR-0074`, `ADR-0075`, `ADR-0076` (Festlegung 3, Fitness-Zeile 4) · `LH-FA-10` (Lastenheft 0.23.0, Kriterium *Erfassungs-Umfang*) · `AGENTS.md` §2, 3.2, 3.5–3.9, 3.11 · v6.13.0 `regelwerk/modul-10-review-harness.md`, `modul-13-quality-gates.md` · Implementer-Bericht und die zwei Berichte zum Umbau von Spec §5.

---

## Findings

### MEDIUM-1 — Zitat-Sensor: die geprüfte Menge am Bestand ist ein Artefakt des Falls 503, keine Sonde belegt sie
- `kategorie`: MEDIUM · `quelle`: `AGENTS.md` §3.6; Skill-Regel „Zusicherung über einer Menge, die leer sein kann"
- `pfad`: `test/spec-zitate.bats` (Test „jedes woertliche Zitat …"); `test/mutations/503-spec-zitat-ohne-fundstelle.sh`
- `befund`: Im bats-Image (`awk` des Images, selbst gefahren) liefert `zitate` über den unveränderten Bestand **genau ein** Zitat: `test/mutations/503-…sh: Unterscheidbar` — den Kommentar des Falls 503 selbst, der über das Fenster von 250 Zeichen zur `# files: spec/spezifikation.md`-Zeile im selben Kommentarblock als Zitat der Spezifikation gilt. Ein reales Zitat (Fall 131) gibt es nach dem Nachzug nicht mehr. Der Test grünt damit über einer Menge, die nur durch die Fixture-Datei nicht leer ist; er belegt nirgends, dass sie nicht leer ist (anders als `mit_spec >= 1` im Schwester-Test), und koppelt sich an den Wortlaut von 503: entfällt die Großschreibung `Unterscheidbar` in der Spezifikation, färbt sich der Sensor durch den eigenen Fall rot; wird 503 umformuliert, prüft er nichts und bleibt grün.
- Rot des Falls 503 ist an einer eingeführten, synthetischen Zeile gesehen (`make mutate`, 503 ok); die reale Quelle (ein Kommentar der Bestandsdateien) ist nicht gebunden — §3.6 „Fixture gegen reale Quelle". Der Kopf der bats-Datei nennt nicht, dass der Bestand heute kein reales Zitat trägt.
- `verifizierbar`: ja (awk-Lauf im Image, s. o.) · `klasse`: Wächter über leerer Menge / Selbstzitat der Fixture

### LOW-1 — Die Aufnahme-Regel der Spezifikation sagt noch `Lücke` für Verdrahtung dieses Repos
- `kategorie`: LOW · `quelle`: `ADR-0076` Festlegung 3; Doku-Drift
- `pfad`: `spec/spezifikation.md:27` — „eine Zeile über die Verdrahtung dieses Repos hat ihn nicht und trägt `Lücke`"
- `befund`: Nach `ADR-0076` Festlegung 3 verlässt Verdrahtung, die nur dieses Repo trägt, die Spezifikation (fünf Zeilen sind so gegangen); keine Zeile trägt mehr `Lücke` (`grep -E '\| Lücke \|$' spec/spezifikation.md | grep -oE '^\| `SPEC-[0-9]+`'` gibt nichts aus). Die Regel beschreibt einen Zustand, den der Diff beseitigt hat. Gleiches Muster in der neuen Historie-Zeile (`spec/spezifikation.md:227`): „Jede Zeile mit `Lücke` trägt einen Anker ins Lastenheft" — `Lücke` heißt nach Zeile 151 gerade *kein* Element; der Satz widerspricht der Definition und trifft keine Zeile mehr. `Lücke` als zulässiger Übergangswert (Zeilen 18, 151) bleibt davon unberührt. Der Implementer hat Zeile 27 selbst übergeben.
- `verifizierbar`: nein (kein Sensor liest Prosa) · `klasse`: Regel-Prosa nach Umbau nicht mitgezogen

### INFO-1 — Fensterbreite 250 und Byte-Zählung
- `pfad`: `test/spec-zitate.bats` (Kopf, `win`)
- `befund`: 250 ist eine Setzung ohne Messgrundlage; der Kopf nennt sie als Grenze („weiter als 250 Zeichen … NICHT GEPRUEFT"), das ist ehrlich. Gezählt werden im Image-`awk` Bytes (Umlaute zählen doppelt), der Kopf sagt „Zeichen". Unter einem UTF-8-fähigen `awk` (Host) kürzt `substr(rest, s + 3)` das Zitat um zwei Zeichen (`terscheidbar`) — der Sensor ist an das Image-`awk` gebunden, Docker-only macht das hermetisch, die Bindung steht nirgends.
- `klasse`: Grenzen-Aufzählung · `verifizierbar`: ja

### INFO-2 — Die Positiv-Sonde von Test 2 zählt nicht die geprüfte Menge
- `pfad`: `test/spec-tabellenform.bats` (Test „keine SPEC-Zeile …", `n=$(grep -c 'SPEC-' …)`)
- `befund`: Die Sonde zählt jedes Vorkommen von `SPEC-` (auch Prosa), nicht die Zeilen, über die der `awk` läuft. Dieselbe Zeilen-Regex ist in Test 1 über `mit_spec >= 1` belegt; ein Formwechsel, der nur Test 2 trifft, bleibt ohne Sonde. Kein Fall in Reichweite, Nebenzahn ohne Mutation (benannt als „ungebundener Nebenzahn" im Auftrag).
- `klasse`: Wächter über leerer Menge

### INFO-3 — Kommentar-Nachzüge 128 und 134 über den Plan hinaus
- `pfad`: `test/mutations/128-span-rolle-unnormalisiert.sh`, `test/mutations/134-span-zaehler-praesent-leer.sh`
- `befund`: Nur Kommentarzeilen; die Fälle entfernen wörtliche Zitate, die hinter `spezifikation.md` stehen und im Spec-Text nicht mehr vorkommen (`SPEC-044` trägt `general-purpose: 62 %` nicht). Ohne den Nachzug läge dort vermutlich ein Befund des neuen Sensors (nicht nachgefahren); der Zeiger auf `SPEC-071` trägt (Zeile sagt: `general-purpose` steht nie als Rolle im Span). Ich halte sie für planzulässig, weil aus Liefer-Punkt 2 gefolgert; der Bericht nennt sie.
- `klasse`: —

## Negativbefunde (geprüft, ohne Befund)

- **Sensoren 501/502/503 (selbst gefahren):** `make mutate MUTATE_CASES="501-… 502-… 503-…"` → `3 ok, 0 Befund(e)`, jeder Fall färbt den benannten Test, Reste im Baum: keine (`git status` sauber). Gegenprobe der Exklusivität: nur `spec-tabellenform.bats` und `spec-zitate.bats` lesen die Spezifikation (`git grep`); 501 lässt die Zellen stehen (Test 2 unbeteiligt), 502 die Kopfzeilen (Test 1 unbeteiligt); Test 1 bindet „`Präzisiert` fehlt in **einer** Tabelle", das alte „mindestens 3" nicht. Die Meldung des roten Laufs trägt die benannte Regel.
- **Shell-Lint/Hermetik:** `make gates` EXIT 0 (shell-lint, docs-check, test, lint, build, baseline-verify); keine Suppression (§3.2); Tests laufen im bats-Image ohne Netz, keine Host-Toolchain (§3.9).
- **Liefer-Punkt 4, Anker (sechs von elf gegen `LH-FA-10` und `ADR-0076`-Tabelle gelesen):** `SPEC-014` (Pflicht-Feld; Zirkel-Vorbehalt bleibt), `037` (Kriterium Umfang fail-closed), `045`/`046` (Auswertung), `054` (Strom), `056` (netzlos/kein `gh`), `063` (Lock/Beleg), `082` (Pflichtfeld `tool`) — Ebene stimmt mit der ADR überein, nicht nur auflösend.
- **`SPEC-047` gekürzt:** der entfallene Satz (Sichtbarkeit des Bruchs der Regel, zählerloser Lauf, Haupt-Kontext steht weder im Zähler noch im Nenner, kleiner Anteil ≠ Regel gelebt) steht in der Nutzer-Doku zu Rollen-Läufen (Abschnitt „Dass Rollen-Arbeit als Rolle läuft", dritter Punkt); keine Aussage ohne Träger.
- **`SPEC-051`–`053`:** Text stimmt mit dem neuen Kriterium *Erfassungs-Umfang* überein (abgeschlossener Aufruf inkl. fehlgeschlagener und Start ja; geblockter Aufruf und Ende nein); Anker ist der Elementanker plus Kriteriums-Name, das Kriterium hat keinen eigenen Anker.
- **Fünf gestrichene Zeilen:** `SPEC-041`, `085`, `086` → Kopfkommentar `pretooluse-agent-guard.sh` und `test/agent-guard.bats` (vier fail-closed-Zweige, lesbarer Typ läuft durch, Fälle 139/150/32, `TestEnforce_*`, `smoke.sh`, Grenzen), `SPEC-084` → Kommentar am Helfer `mustContain`, `SPEC-040` → Kopf des Guards und Nutzer-Doku; keine Aussage verloren; die Behauptung „der Agent-Guard wird nicht emittiert" stimmt (`git grep pretooluse-agent-guard -- internal/emit cmd` leer). `SPEC-040/041/084/085/086` bleiben ungenutzt, keine Doppelung.
- **Kommando zu Fitness-Zeile 4 von `ADR-0076`:** gibt nichts aus.
- **Nur Kommentare außerhalb der Spec:** `git diff -U0 7bc65747..HEAD -- internal test cmd harness .claude` ohne Kommentarzeilen; übrig nur die Zeilen der neuen Dateien (501–503, zwei bats). Bestandsdateien tragen nur Kommentar-Änderungen.
- **Wächter-Bilanz:** Namen in `comm -3` zwischen Stand `7bc65747` und HEAD: verschwunden sind `agent-guard.bats`, Fall 139/150/32, `make test`, `make test-go`, `TestEnforce_EmitsAllMechanicFiles`, `TestEnforce_SettingsWiresBothHooks` — jeder steht an anderer Stelle im Repo als Text (Guard-Kopf, bats-Kopf, Go-Tests); neu sind die fünf Testnamen der Sensor-Zellen. Die Fälle 123 und 127 stehen als Kommentar an `mustContain` in `internal/span/response_test.go`.
- **Sensor-Namen (Liefer-Punkt 3 b):** `107/112/154` → `TestClampSurvivesBrokenPayload`, `108`, `109`, `113`, `114`, `115` stimmen mit dem jeweiligen `# expect:` überein.
- **Formregeln der Spezifikation:** `make docs-check` im Gate grün; kein Verweis nach unten, keine nackte Entscheidungs-Kennung; Historie-Zeile ohne ADR-Kennung; neue Kommentare (Guard, bats) tragen Zusage/Grenze, keine Chronik (§3.7), keine Pfad-Adresse eines frei wandernden Artefakts (§3.11).
- **Rollen-Grenze (§3.8/§3.10):** berührt sind Spec, Sensoren, Kommentare, ein Hook-Kopf, der Bericht; kein ADR, MR, `AGENTS.md`, `conventions`, Lastenheft, Nutzer-Doku, keine Slice-Closure.
- **Größe/Prüfbarkeit:** 13 Dateien, überwiegend Zellen und Kommentare; in einer Sitzung prüfbar; die Rückführungs-Bedingung des Plans (§4) ist nicht ausgelöst.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 3 |

Klassen: Wächter über leerer Menge / Selbstzitat der Fixture · Regel-Prosa nach Umbau nicht mitgezogen.

## Verdikt

**schließbar nach Änderungen:** MEDIUM-1 klären (Positiv-Sonde oder Benennung, dass der Bestand kein reales Zitat trägt, und Entkopplung des Bestands-Zitats vom Fall 503) und LOW-1 (Zeilen 27 und 227 der Spezifikation) nachziehen. Kein HIGH, kein Rollen-Konflikt. `make gates` grün.
