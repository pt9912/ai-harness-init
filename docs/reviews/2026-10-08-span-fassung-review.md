# Review-Report: slice-span-traegt-die-fassung-seiner-erfassungsregel — 2026-10-08

**Review-Art:** Code — gegen Plan + Konventionen.

**Gegenstand:** `602a72b0` (Claim `1ed7b4b1`, `4fb33001`, `257acc61`)

**Skill:** `.harness/skills/reviewer.md` @ `78381a2b` (Version 2.3.0)

**Modell:** claude-opus-5-5 · **Datum:** 2026-10-08

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link.

**Eingangs-Kontext:**

- `slice-span-traegt-die-fassung-seiner-erfassungsregel` (Plan, §1–§4, §6), Welle `welle-erfassungsschicht-im-ziel`
- `LH-FA-13` (Lastenheft 0.25.1), `LH-FA-17` (Präzisiert-Ziel von `SPEC-095`)
- `ADR-0011` Festlegung 1 Punkt 3 (geschlossenes Schema)
- `spec/spezifikation.md` §5, `MR-075`, `MR-071`
- `AGENTS.md` §3.6, §3.7
- git-Historie der Erfassungsregel (`git log -- internal/span`, Tags je Commit)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die Tabelle sagt zu, je Fassung zu nennen, „was sich gegenüber der vorigen geändert hat"; Fassung 2 nennt nur `program`. Im selben Release (`v0.2.4`) hat `fb1ca361` auch `argc` umgedeutet: Wortgrenze von `strings.Fields` (jeder Unicode-Leerraum, `\r`, `\v`, `\f`) auf Leerzeichen/Tab/Zeilenende — bei gleicher Payload ein anderer `argc`-Wert, nach der eigenen Zählregel (`SPEC-089`) ein Bedeutungswechsel. Keine Zeile ist falsch zugeordnet, weil keine Zeile die Fassungen 1–3 trägt; der Leser der Tabelle sieht den `argc`-Sprung aber nicht als Regelwechsel. | `LH-FA-13`, `AGENTS.md` §3.6 | `spec/spezifikation.md:188` (`SPEC-091`) | nein | nachgetragene Fassungs-Beschreibung lässt einen Feld-Wechsel aus |
| F-2 | LOW | Der Kommentar von `fassungsZeile` und `SPEC-089` sagen zu „Ohne lesbare Zeile entfällt sie"; kein Test bindet diese Teil-Zusage. Sonde: Guard `if len(b.Fassungen) == 0 { return "" }` entfernt — dann schreibt der Bericht bei leerem oder ganz unlesbarem Bestand eine leere Zeile `Erfassungsregel: ` —, `make test-go` EXIT 0. Praktisch erreichbar: leerer Bestand ist der Regelfall im frisch gebootstrappten Ziel. | `AGENTS.md` §3.6 (Skill: mehrteilige Zusage je Teil) | `internal/report/report.go` · `func fassungsZeile`, erste Bedingung | ja — `make test-go` über der Sonde | Teil-Zusage eines mehrteiligen Kommentars ohne bindenden Fall |
| F-3 | INFO | Dieselbe Sonde entfernt zusätzlich `n < 1` aus der Bedingung für *dem Leser unbekannt* — weiterhin EXIT 0: eine negative `rule_version` bekäme den Zusatz nicht, ohne dass ein Test es merkt. Der Emitter schreibt keine negative Zahl; erreichbar ist der Zweig nur über eine von Hand oder fremd geschriebene Zeile. | `AGENTS.md` §3.6 | `internal/report/report.go` · `if n < 1 \|\| n > span.CurrentRuleVersion` | ja — `make test-go` über der Sonde | Teil-Zusage eines mehrteiligen Kommentars ohne bindenden Fall |
| F-4 | INFO | Die Zählregel („steigt um eins, sobald …") nennt keine Einheit — Commit, Slice oder Release. Die nachgetragene Tabelle fasst je Fassung mehrere Wert-Wechsel zusammen (Fassung 3: `dfa544df`, `92f03d31`, `aa905f04`; Fassung 4: `91af2b67`, `b0c73625` — `null` als Zähler vorher `0`, danach Kennzeichnung), und im Dogfood schreibt `make host-bin` den Träger aus jedem Zwischenstand. Ein künftiger Lauf kann die Tabelle als Präzedenz für „einmal je Slice" lesen, die Regel als „je Wechsel". Zuständig: Architect/Planner (Festlegung in §5). | `LH-FA-13` | `spec/spezifikation.md:181` (`SPEC-089`) | nein | Zählregel ohne Einheit |

### Gefahrene Sonden (Scratchpad-Kopien per `git archive HEAD`, Host-Baum unberührt)

| Sonde | Erwartung | Ergebnis |
|---|---|---|
| `make mutate MUTATE_CASES='592-… 593-… 594-…'` | drei Fälle ok | `3 ok, 0 Befund(e)`, EXIT 0 |
| Gegenprobe: Mutationen 592, 593, 594 zugleich angewandt, `t.Skip` **ausschließlich** in `TestSpanCarriesCurrentRuleVersion`, `TestCurrentRuleVersionIsTheLastSpecFassung`, `TestAggregiere_TrenntDieFassungen` | grün = jeder benannte Test bindet allein | `make test-go` EXIT 0, kein `--- FAIL` |
| `fassungsZeile`: Leer-Guard entfernt, `n < 1` aus der Unbekannt-Bedingung entfernt | rot, wenn beide Teil-Zusagen gebunden sind | `make test-go` EXIT 0 → F-2, F-3 |
| Historie: `git log -- internal/span` gegen `SPEC-090`–`SPEC-093`, erster Tag je Commit (`git tag --contains`) | jeder Wert-Wechsel einer Fassung zugeordnet und beschrieben | Fassung 2 = `v0.2.4`, 3 = `v0.2.5`, 4 = `v0.3.0` stimmen; `argc`-Wechsel in `fb1ca361` fehlt → F-1 |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Pflichtfeld `rule_version` (Emitter, Draht-Form, `TestMandatoryFieldsAlwaysPresent`) | geprüft, ohne Befund: kein `omitempty`, `Build` setzt die Konstante, `TestSpanCarriesCurrentRuleVersion` misst an der geschriebenen Zeile über drei Payloads; Fall 592 färbt nur ihn (Gegenprobe). |
| Kopplung Träger ↔ Spezifikation (§3.6 reale Quelle) | geprüft, ohne Befund: `TestCurrentRuleVersionIsTheLastSpecFassung` liest die reale `spec/spezifikation.md`, bricht bei leerer Treffermenge ab, prüft Lückenlosigkeit und letzte Zeile; das Regex trifft `SPEC-089` (`Fassung der …`) nicht. Die unbewachte Hälfte (Wechsel nicht erkannt) benennt `SPEC-094` selbst. |
| Bericht trennt Fassungen, ohne Bestand umzudeuten | geprüft, ohne Befund außer F-2/F-3: Zeilen ohne Feld zählen unter Schlüssel 0 → *Fassung nicht bekannt*, nie unter der Leser-Fassung (Fall 594 bindet); Token-Bilanz unverändert über den ganzen Bestand; nicht-ganzzahliges Feld macht die Zeile unlesbar wie in `SPEC-089` zugesagt. |
| Altbestand ohne Feld → *nicht bekannt* (Lastenheft 0.25.1, `LH-FA-13` „unbekannt ist gekennzeichnet") | geprüft, ohne Befund: der Emitter schreibt nie `0`; die Kennzeichnung entsteht beim Leser für Zeilen vor dem Feld, Plan §1 schließt die Migration aus. |
| Geschlossenes Schema (`ADR-0011`) und Feldliste im Ziel | geprüft, ohne Befund: das Feld steht in §5 (`SPEC-088`) und in `SchemaNotes`; die emittierte Feldliste wird aus dem Span-Typ gelesen. Keine Prosa-Aufzählung der Pflichtfelder in `spec/`, `docs/user/`, `harness/`, `internal/` blieb ohne das Feld (`git grep` nach Zahl-Aufzählungen: 0 Treffer). |
| Spec-Form (`MR-075`) | geprüft, ohne Befund: `SPEC-088`–`SPEC-095` je mit `Präzisiert`-Spalte; Fassungs-Tabelle mit ID- und `Präzisiert`-Spalte. |
| Mutations-Fälle 592–594 (`MR-071`, Anker, `# files:`/`# expect:`, Exklusivität) | geprüft, ohne Befund: jeder `sed`-Anker trifft genau seine Zeile (Diff der mutierten Kopie: drei Zeilen), Treiber ok, Gegenprobe grün; Fall 592 behauptet „`TestMandatoryFieldsAlwaysPresent` bleibt grün" — durch die Gegenprobe bestätigt. |
| Kommentare (§3.7) und je Test eigener Doc-Kommentar | geprüft, ohne Befund: vier neue Tests, je ein eigener Doc-Kommentar im Indikativ; keine Chronik, keine Befund-Kennung, keine verworfene Alternative in Code-Kommentaren und Fall-Köpfen. |
| Handbuch Ist-Zustand | geprüft, ohne Befund: die Zeile zu `make span-report` beschreibt die Ausgabe ohne Kennung und ohne Chronik. |
| Zwischenfall (eigener `git checkout`, neu eingespielt) gegen §3 | geprüft, ohne Befund: `git show --stat 602a72b0` führt jede in Plan §3 genannte Datei; Löschungen insgesamt 5 Zeilen, alle in Plan, Handbuch und `span_test.go` als Ersetzung — keine unbeabsichtigte Rücknahme fremden Inhalts im Commit. |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 2 |
| INFO | 2 |
