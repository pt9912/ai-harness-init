# Umbau des Fließtexts von Spec §5 nach ADR-0074 — Bericht der Rolle Implementer

**Art:** Bericht der Rolle Implementer (Eingabe für Review und Verifikation). Zeitdokument; kein Norm-Text.

**Slice:** `slice-spec-5-wird-nach-adr-0074-umgebaut`. **Bezug:** [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) ·
[ADR-0074](../plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) ·
[ADR-0075](../plan/adr/0075-begruendungen-zu-spec-5-sammel-adr.md) · [MR-075](../../harness/conventions.md#mr-075) ·
[MR-076](../../harness/conventions.md#mr-076) · [MR-077](../../harness/conventions.md#mr-077).

## 1. Vorher-Messungen (Stufe a)

Stand vor dem Umbau: `git show 85e5ab5b:spec/spezifikation.md` (`git diff 85e5ab5b HEAD -- spec/spezifikation.md | wc -l` → 0, die
Arbeitskopie war bei Beginn identisch). Zahlen sind Messungen, keine Erwartungswerte
([MR-025](../../harness/conventions.md#mr-025)).

```sh
V=<Vorher-Fassung>
sed -n '4,/^## 7\. Historie/p' $V | grep -vc '^|'                                     # 682  Nicht-Tabellenzeilen
sed -n '4,/^## 7\. Historie/p' $V | grep -v '^|' | wc -c                              # 51194 Bytes
wc -c < $V                                                                            # 66691 Bytes gesamt
grep -oE '`Test[A-Za-z0-9_]+`|test/mutations/[0-9]+-[a-z0-9-]+\.sh' $V | sort -u | wc -l   # 50 Namen (24 Tests, 26 Fall-Dateien)
awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' $V | grep -v '^|' | grep -cE 'Negativ-Liste|Dauer des \*\*Aufrufs\*\*|Slice→Rolle|geraten, nicht|falsch geroutetes|EIGENEN'   # 6
sed -n '4,/^## 7\. Historie/p' $V | grep -cE '20[0-9]{2}-[0-9]{2}-[0-9]{2}'            # 12
awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' $V | grep -v '^|' | grep -cE 'test/|_test\.go|Fall [0-9]+|\.bats'   # 38
grep -c 'Abweichung [1-6]' $V                                                         # 17
grep -c 'START-KONVENTION' $V                                                         # 1
grep -c '^| ID | Feld | Pflicht | Incident-Frage | Sensor |' $V                       # 1
git grep -nE 'spezifikation\.md' -- internal test cmd harness/tools | wc -l           # 49  Zeiger-Stellen
```

Byte-Bilanz je Klasse am Stand vor dem Umbau (Klassifikationsbericht §2, Bytes des Fließtexts 137 bis 718 = 45889):
a Festlegung 10177 · b Begründung 3293 · c Messprotokoll 13508 · d Abweichung 8245 · e passt in keine (Wächter-Zuordnung) 10666.

**Treffer der Passagen-Namen in eingefrorenen ADRs** (`git grep -c -- '<Name>' -- docs/plan/adr ':!docs/plan/adr/0074-*' ':!docs/plan/adr/0075-*'`),
gemessen vor dem Umbau — sie bestimmen, welche Namen als Text in den übernehmenden Zeilen stehen
([ADR-0074](../plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 10):

| Name | Treffer / Dateien | Name | Treffer / Dateien |
|---|---|---|---|
| START-KONVENTION | 3 / 2 | Abweichung 5 | 10 / 3 |
| Bewacht | 3 / 3 | Abweichung 6 | 8 / 2 |
| Positiv-Liste | 4 / 2 | Splitting-Regel | 3 / 1 |
| Abweichung 1 | 3 / 1 | SubagentStart | 7 / 3 |
| Abweichung 2 | 0 / 0 | Sammelposten | 12 / 4 |
| Abweichung 3 | 0 / 0 | Berichtsgröße | 3 / 1 |
| Abweichung 4 | 2 / 1 | kanonischen Namen | 3 / 2 |
| Lesevorschrift | 0 / 0 | Prüfreihenfolge | 0 / 0 |

**Wächter-Zuordnung je Zusicherung, vorab gemessen** (Kopfkommentare der Fall-Dateien 107 bis 115, 123 bis 138, 154 gelesen):
jede der Zusicherungen der Prosa „Bewacht" wird von der `# expect:`-Zeile und dem Kopfkommentar ihres Falls oder vom Namen ihres Tests
getragen — der Test- bzw. Fallname behauptet die Zusicherung in seinem Namen. Ausgenommen sind die Sätze, die eine **Lücke** benennen
(kein Zahn für die `mustContain`-Gegenproben, sechs ungebundene `mustNotContain`-Einträge, Herkunfts-Achse ohne Zahn, Guard-Verdrahtung
dieses Repos): sie stehen als Zeilen mit Strich in der Spalte `Sensor`. Der Kommentar-Nachzug am Test steht in §5.

## 2. Stufen und Diff-Übersicht

| Stufe | Commit | Inhalt |
|---|---|---|
| a | `bf98b286` | Vorher-Messungen, dieser Bericht §1 |
| b | `22174fd5` | Spalte `Präzisiert` als letzte Spalte in §3, Feldtabelle, Werkzeug-Tabelle; zwei neue Tabellen (Regeln der Erfassung `SPEC-035` bis `SPEC-057`, Zusicherungen mit Sensor `SPEC-058` bis `SPEC-086`); die Prosa steht noch |
| c | `afceb459` | der Fließtext hinter der Werkzeug-Tabelle entfällt (Zeilen 137 bis 718 des Vorher-Stands, 595 Zeilen gelöscht); Vorspann von §5: Verweis auf „Bewacht" durch die Tabelle der Zusicherungen ersetzt, `gemessen`-Klammer der Sensor-Absatz-Grenze entfernt; die Trennzeile der Werkzeug-Tabelle (Stufe b trug fünf statt vier Spalten) berichtigt |
| d | `1ceb4026` | Aufnahme-Regel (Klassen, Spalte, Form), Kopf „Letzte Änderung", eine Zeile in §7 |
| e | `8009d213` | 18 Dateien, nur Kommentarzeilen (Zeiger auf `SPEC-<NNN>`; 1 Kommentar am Test: Grenze der `mustContain`-Gegenprobe) |
| f | dieser Bericht | Gegenbeispiele, Bilanzen, Übergaben |

Kein Lastenheft-Edit, keine Änderung an ADR, `harness/conventions*`, `AGENTS.md`, `.d-check.yml`
(`git log --oneline 3a5ccf54..HEAD -- .d-check.yml | wc -l` → 0), keine Änderung an der emittierten Vorlage
(`grep -rl 'Präzisiert' internal | wc -l` → 0).

## 3. Bilanzen nach dem Umbau

```sh
f=spec/spezifikation.md
sed -n '4,/^## 7\. Historie/p' $f | grep -vc '^|'                                       # 120  (vorher 682)
sed -n '4,/^## 7\. Historie/p' $f | grep -v '^|' | wc -c                                # 6969 (vorher 51194)
wc -c < $f; wc -l < $f                                                                  # 45086 Bytes, 231 Zeilen (vorher 66691, 736)
grep -cE '^\| `SPEC-[0-9]+`' $f                                                         # 86  (vorher 34)
grep -c '| Lücke |' $f                                                                  # 19
```

Der Rest-Fließtext (120 Zeilen) ist Aufnahme-Regel, Formregeln, Kopf, Vorspann von §5 (Gegenstand, geschlossenes Schema,
Spalte `Sensor`) und die zwei Einleitungssätze der neuen Tabellen — kein klassifizierter Fließtext (Bericht der Klassifikation, `K`).

| Messkommando (ADR-0075 / ADR-0074 Fitness, Anker `SPEC-034` unverändert die letzte Zeile der Werkzeug-Tabelle) | vorher | nachher |
|---|---|---|
| Kernsätze der Sammel-ADR im Fließtext | 6 | **0** |
| Datumszeilen `20…-…-…` in `sed -n '4,/^## 7\. Historie/p'` (die Kopfzeile „Letzte Änderung" liegt in Zeile 3 und wird vom `sed` nicht gelesen) | 12 | **0** |
| Test- oder Fallnamen im Fließtext hinter dem Anker (`test/`, `_test.go`, `Fall N`, `.bats`) | 38 | **0** |
| `grep -c 'Abweichung [1-6]' spec/spezifikation.md` | 17 | **9** — alle als erhaltener Name (ADR-0074 Festlegung 10): `SPEC-014` und `SPEC-024` (Bestandszellen, nachgezogen auf `SPEC-056`/`SPEC-055`), Namen in den Zeilen `SPEC-039` (5), `SPEC-043` (3), `SPEC-048` (5), `SPEC-049` (6), `SPEC-055` (1), `SPEC-056` (2), `SPEC-057` (4) |
| `grep -c 'START-KONVENTION' spec/spezifikation.md` | 1 | **0** |
| Namen der Wächter-Bilanz (24 Tests, 26 Fall-Dateien) | 50 | **50**, `comm -3` der zwei `sort -u`-Mengen **leer**, keine Verlagerung |
| Spalte `Präzisiert` (`grep -cE '^\| ID \|.*\| Präzisiert \|$'`) | 0 | **5** (drei Bestandstabellen, zwei neue) |
| Kopfzeilen-Präfix der Feldtabelle | 1 | **1** |

**Byte-Bilanz je Klasse** (Vorher-Bytes: Klassifikationsbericht §2; Ort: dieser Umbau):

| Klasse | Vorher (Bytes) | neuer Ort |
|---|---|---|
| a Festlegung | 10177 | Spec-Zeilen `SPEC-035` bis `SPEC-057` (Tabelle der Regeln: 10602 Bytes, zusammen mit d) |
| b Begründung | 3293 | Sammel-ADR ([ADR-0075](../plan/adr/0075-begruendungen-zu-spec-5-sammel-adr.md) Festlegung 1 bis 7); U13 in ADR-0019, U24b in ADR-0011 getragen; U16, U35 (R2) als Sätze der Zeilen `SPEC-047`, `SPEC-045` |
| c Messprotokoll | 13508 | **entfallen** (git hält sie); kein Messprotokoll angelegt — Konsumenten-Prüfung `git grep -nE '2026-08-(08\|15\|21)\|Mess-Dokument' -- docs/plan/adr \| grep -i spezifikation` → leer |
| d Abweichung | 8245 | Zeilen `SPEC-039`, `043`, `049`, `055`, `056`, `057` (die Zuordnung der Abweichungen zu den Modul-Regeln, U25 und U26, entfällt: [MR-076](../../harness/conventions.md#mr-076) und [MR-077](../../harness/conventions.md#mr-077) tragen `Ersetzt-Baseline-Regel` und Begründung); Prüfschritte 5.1 bis 5.3 und 6.1 bis 6.3 (Klasse c) entfallen |
| e Wächter-Zuordnung | 10666 | Zusicherungs-Tabelle `SPEC-058` bis `SPEC-086` (9215 Bytes) |
| p Prozess-Konvention (U09, U10, U11b, U15; in a gezählt) | 1931 | [`docs/user/rollen-laeufe.md`](../user/rollen-laeufe.md), Satz-für-Satz-Abgleich in §6 |

## 4. Gegenbeispiele, rot gesehen an der realen Quelle (`spec/spezifikation.md` verfälscht, Ausgabe gelesen, mit `git checkout` zurückgenommen)

| Nr | Verfälschung | Messung / wörtliche Ausgabe | gelesen |
|---|---|---|---|
| 1a | in `SPEC-067` den Namen `TestUnlistedResponseKeyStaysOut` gestrichen | `comm -3` → `` `TestUnlistedResponseKeyStaysOut` `` | Differenz nicht leer, benennt genau den gestrichenen Namen |
| 1b | Kopf der §3-Tabelle ohne `Präzisiert` | `grep -cE '^\| ID \|.*\| Präzisiert \|$'` → `4` (vorher `5`); die drei Bestandstabellen ohne Spalte → `2` | fällt; **Anmerkung:** die Schranke „mindestens 3" der ADR gilt für drei Tabellen, hier stehen fünf — ein einzelnes Weglassen ergibt 4, also über 3 |
| 1c | Spalte vor `Feld` eingefügt | `grep -c '^| ID | Feld | Pflicht | Incident-Frage | Sensor |'` → `0` | fällt (Vorher 1) |
| 1d | Zelle `Präzisiert` von `SPEC-004` geleert | `make docs-check` → `d-check: 2166 Datei(en) geprüft, 0 Befund(e)` | **bleibt grün: benannte Lücke** — kein Gate meldet eine leere Zelle; Sensor-Vorschlag für den Planner: `grep -cE '\| +\|$'` über den Tabellenzeilen |
| 1e | Anker in `SPEC-005` durch `lh-fa-10--erfundener-slug` ersetzt | `spec/spezifikation.md:112 lastenheft.md#lh-fa-10--erfundener-slug anchor-missing Anker entspricht keinem Heading-Slug und keinem HTML-Anker der Zieldatei` | `anchors` meldet es |
| 2a | Satz „Die Negativ-Liste altert …" in den Fließtext | Kernsatz-Messung → `1` (nachher 0) | fällt |
| 2b | `ADR-0011` nackt in `SPEC-050` | `spec/spezifikation.md:170 ADR-0011 id-unlinked Kennung ohne Link auf ihre Definition` | `ids`, Ursache die nackte Kennung |
| 2c | Link auf `docs/plan/adr/0074-…md` in `SPEC-050` | `spec/spezifikation.md:170 ../docs/plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md matrix-forbidden Referenz spec-straten → adr ist nicht erlaubt` | `matrix`, Klasse `spec-straten` |
| 3a | Kommentar `// unter Bewacht, Punkt 8.` zurück in `internal/span/response_test.go` | `git grep -n 'unter Bewacht' -- internal` → `internal/span/response_test.go:328:// unter Bewacht, Punkt 8.` | **Grenze:** das Zeiger-Kommando `git grep -nE 'spezifikation\.md' …` listet nur die Zeile, die den Dateinamen nennt (327); ein Zeiger, dessen entfernte Formulierung auf der Folgezeile steht, erscheint erst im zweiten `git grep` |
| 3b | Logikzeile in `internal/span/response_test.go` geändert (`… { _ = line`) | Nur-Kommentar-Kommando → `-func mustContain(t *testing.T, line string, erwartet ...string) {` / `+func mustContain(… ) { _ = line` | Kommando listet die Logikzeile; Nachher-Stand: 0 Zeilen |

Zusätzlich gemessen: Nur-Kommentar-Kommando über den ganzen Umbau
(`git diff -U0 22174fd5~1 HEAD -- internal test cmd harness/tools | grep -E '^[+-][^+-]' | grep -vE '^[+-][[:space:]]*(//|#)' | wc -l` → 0);
Zeiger-Stellen `git grep -nE 'spezifikation\.md' -- internal test cmd harness/tools | wc -l` → 50 (vorher 49, eine neue Kommentar-Stelle am Test);
stehende Kommentare auf entfernte Formulierungen (`unter Bewacht|Punkt 8|START-KONVENTION|Bedingung [12]`) → 0.

## 5. Zeiger-Nachzug und Wächter-Zuordnung als Kommentar

Nachgezogen (17 Dateien, `SPEC-<NNN>` statt Passagen-Name): `internal/report/report.go` (4), `report_test.go` (2), `internal/span/emit.go`,
`response.go` (2), `response_test.go` (3), `span_test.go`, `internal/emit/enforce_test.go`, sowie die Fälle
126, 128, 134, 136 (2), 137, 141, 142, 144, 145, 146, 147 in `test/mutations/`. Fall 144 nennt die entfernte Begründung
der Splitting-Regel nicht mehr als Inhalt der Spec. Unverändert bleiben Zeiger auf §5 als Ganzes und auf `SPEC-021`.
**Kommentar am Test:** `mustContain` in `internal/span/response_test.go` trägt die Grenze „Gegenprobe ohne Zahn"
(`SPEC-084`); die übrigen Zusicherungen tragen ihr Test-Name, ihr `# expect:` und der Kopfkommentar ihres Falls (§1).

## 6. Prozess-Konvention: Abgleich mit `docs/user/rollen-laeufe.md`

Satz für Satz, Quelle: Klassifikationstabelle U09, U10, U11, U11b, U13, U15.

| Aussage des entfernten Blocks | Ort jetzt |
|---|---|
| die Regel gehört hierher und in kein Gedächtnis (U09) | `rollen-laeufe.md` §Zweck |
| Rollen-Typ per @-Erwähnung entscheidet, welche Rolle läuft; Belegklasse fremde Doku (U10) | §START-KONVENTION, Punkt 1 |
| Betriebsart nicht wählbar, Hintergrund als Standard, „die Konvention hat nur noch Bedingung 1" (U11, U11b) | §START-KONVENTION, Punkt 2 |
| Guard entscheidet die Lesbarkeit der Aufrufform, nicht die Betriebsart (U13) | `rollen-laeufe.md` und Zeile `SPEC-041` |
| „general-purpose" → leere Rolle, Sammelposten (U09) | §START-KONVENTION, Punkt 3 |
| DASS Rollen-Arbeit als Rolle läuft, ohne Wächter; nur teilweise sichtbar (U15) | §Dass Rollen-Arbeit als Rolle läuft; Berichtsgröße in Zeile `SPEC-047` |
| **Bedingung 1 ist nicht durchgesetzt, kein Sensor prüft sie; die Freitext-Felder `prompt`/`description` sind ungemessen (U14)** | **nicht in `rollen-laeufe.md`** — Prozess-Zustand (R6), siehe §7 Übergabe 4 |
| Die Aussage „die Rolle des gestarteten Laufs steht in jeder Zeile des Subagenten-Stroms" (U12, Klasse c) | entfallen; `SPEC-009` und `SPEC-010` führen die Felder in jeder Zeile |

`grep -rn 'spezifikation' docs/user | wc -l` → 3; alle drei sind Links auf `#5-metriken-und-tracing-felder` in `rollen-laeufe.md` und
nennen keine Spalte und keinen entfernten Abschnitt (Kanonische Namen → `SPEC-042`, Berichtsgröße → `SPEC-047`).

## 7. Grenzfälle und Übergaben

An den **Architect** (Urteil, das dieser Lauf nicht fällt):

1. **`Präzisiert`-Zuordnung.** 19 von 86 Zeilen tragen `Lücke` (`grep -c '| Lücke |' spec/spezifikation.md`): `SPEC-014`, Regeln `037`, `040`, `041`, `045`, `046`, `047`, `051` bis `054`, `056`, Zusicherungen `060`, `063`, `065`, `082`, `084`, `085`, `086`. Als Link geführt sind die Zeilen, die ADR-0074 Festlegung 5 nennt (Felder der drei Blöcke, Schranken) und die Bericht-§6-Einträge „einzeln" und „pauschal"; **„nahe"-Bindungen** (`SPEC-035` Werkzeug-Achse, `SPEC-042` Namen, `SPEC-048` „Gedeckt") stehen als Link, ebenso die Zusicherungen, die eine Zeile mit Link schützen. `SPEC-014` ist `Lücke` (Vorbehalt der ADR: nur über die „volle Pflicht-Spalte", die sie selbst mitdefiniert). Kein Sensor hält die Passung des Ankers.
2. **Schranke „mindestens 3" der Fitness-Zeile 5** ist bei fünf Tabellen kein Sensor für das Weglassen in *einer* Tabelle; genauer wäre „gleich der Zahl der Tabellen mit `SPEC-`-Zeilen".
3. **Wächter-Namen der Spalte `Sensor`.** Die Fälle 108, 109, 113, 114, 115 tragen `# expect:` auf `TestUnknownToolStaysSilent`, `TestSeqIsAssignedNotDerived`, `TestSpansLandInStateDir`, `TestLeftoverLockDirectoryDoesNotBlock`, `TestDurationAndResultSize`; 112 und 154 auf `TestClampSurvivesBrokenPayload`. Die Spec nannte stattdessen die Datei `internal/span/span_test.go`. Die Zeilen `SPEC-059`, `060`, `062`, `063`, `064` führen die alte Nennung, damit die Wächter-Bilanz leer bleibt; die genauen Namen zu ergänzen wäre ein Namens-Zuwachs (Verlagerung), Entscheidung beim Architect.
4. **Prozess-Zustand (R6):** U14 (Bedingung 1 nicht durchgesetzt; Freitext-Felder ungemessen) und U38 (Nutzer-Aufruf, ob er einen Span erzeugt) haben in `rollen-laeufe.md` keinen Satz und stehen nicht mehr in der Spec — beides sind offene Fragen ohne Träger. Der Lauf hat kein Register geschrieben (Closure-Schritt des Planners).
5. **Begründungen ohne Träger** in der Sammel-ADR: „Erst die Prüfung, dann die Abweichung" (Methode der Abweichung 5) und der **Prüfstein „Kippen, nicht Rot"** samt „sechs weitere `omitempty`-Kopien bewusst nicht geschnitten" (U60). Der Prüfstein steht als Kommentar-Rest im Test (`response_test.go`, Kommentar am `mustNotContain`) und in der Zeile `SPEC-076` bis `SPEC-081`; die Methode entfällt.
6. **Zeiger in eingefrorenen ADRs** (Treffer je Name in §1): nach dem Umbau stehen die Namen Positiv-Liste, Abweichung 1/4/5/6, Splitting-Regel, SubagentStart, Sammelposten, Berichtsgröße und „kanonischen Namen" als Text in den übernehmenden Zeilen; **`Bewacht`** (3 Treffer in 3 ADRs) und **`START-KONVENTION`** (3 Treffer in 2 ADRs) stehen nicht in der Spec — `START-KONVENTION` steht als Überschrift in `docs/user/rollen-laeufe.md`, `Bewacht` als Überschrift der Tabelle „Zusicherungen und ihre Wächter" nicht. Akzeptiertes Negativ nach ADR-0074 Festlegung 10; die Zeilen `Abweichung 2`, `Abweichung 3`, `Lesevorschrift`, `Prüfreihenfolge` hatten 0 Treffer.
7. **E4 = A gehalten:** `Sensor` bleibt; die Nennung ist wie bisher unbewacht (Vorspann von §5).

An den **Planner** (Closure): `Lücke`-Zeilen → gebündelter Change-Request-Auftrag (19 Zeilen); Sensor-Vorschlag zu 1d; die Beobachtung „Spalte `Sensor` nennt eine Datei, deren Test den Fall nicht trägt" (Übergabe 3) als Beleg-Kandidat für `zusage-nennt-sensor-der-form-nicht-sieht`; U14/U38 als Kandidat für das Register.

## 8. Risiken

- **Sinnänderung beim Umbau** (Plan §6): kein Sensor liest den Wortlaut. Stichprobe für den Review: `SPEC-039` (Abweichung 5, aus U40 bis U46), `SPEC-045` (Splitting, U32/U33), `SPEC-049` (Abweichung 6), `SPEC-052` (`SubagentStart`), `SPEC-083` (Draht-Form). Gekürzt sind die Prüfschritte; die Zeilen tragen die Zusagen, nicht die Herleitung.
- **Zeilenlänge:** `SPEC-031` (Bestand) ist die längste; nur die Bestandszeile `SPEC-031` liegt über 1500 Zeichen (`awk 'length>1500' spec/spezifikation.md | wc -l` → 1), die längste neue Zeile (`SPEC-035` ff.) misst 850 Zeichen (awk `length`).
- **Existenz-Sensor:** die Feldtabelle trägt nur Felder, `Sensor` steht unverändert an Stelle 5, `Präzisiert` hinten.
- **Größenregel** (Plan §1): der Diff ist durch die Bilanzen (§3), die Bruchproben (§4) und die Stichprobe prüfbar; nicht jeder Satz einzeln.
