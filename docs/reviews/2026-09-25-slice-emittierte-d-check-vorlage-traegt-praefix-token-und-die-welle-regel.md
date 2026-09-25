# Review-Report: slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel — 2026-09-25

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 0abb97ac..HEAD` — vier Commits: `4e48c552` (Anspruch, reiner Move), `56bcaaad` (Roadmap-Marker),
`ceace58b` (Vorlage, Go-Test, Mutations-Fälle 435 bis 442), `ef6be99f` (full-smoke-Stufe, erzeugte
Abdeckungs-Sicht). `git diff --stat 0abb97ac..HEAD` → 14 Dateien, 411 Zeilen hinzu, 46 entfernt; berührt:
`internal/emit/templates/d-check.yml`, `internal/emit/emit_test.go`, `harness/tools/full-smoke.sh`,
`docs/user/e2e-abdeckung.md`, acht Fälle unter `test/mutations/`, die Roadmap (drei Zeilen weniger), der Slice-Plan
(Move).

**Plan-Bezug:** Slice `slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel` (§1 bis §4, §6, §8) —
Kennung, nicht Pfad: der Plan wandert mit dem Lifecycle. **Constraint:** `ADR-0065` (`Accepted`) Festlegungen 1, 2(a), 3, 6
und Folgepflicht 1 soweit die Vorlage; `LH-FA-01`, `LH-FA-03`, `LH-QA-01`, `LH-QA-02`; `MR-054`, `MR-055`, `MR-063`,
`MR-071`; `AGENTS.md` §3.6, §3.7, §3.11.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0065` vollständig · Regelwerk `v6.9.0`
`grundlagen-referenz-richtung.md` (Matrix-Tabelle, Gate-Text) und `grundlagen-source-precedence.md` §Vergabe ·
`AGENTS.md`. Der Implementer-Bericht lag nicht vor und war keine Quelle; Code, Tests und Sonden sind selbst gelesen
und gefahren.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt; alle Sonden in
Scratchpad-Kopien):

- **Zell-Messung** (Liefer-Punkt 1, unten): Matrix-Tabelle `sed -n '/^| Dokument ↓/,/^| \*\*Roadmap/p' $R/grundlagen-referenz-richtung.md | grep -o '❌' | wc -l` → 22;
  Zeilensummen 7 · 6 · 5 · 3 · 1. Verhalten im Ziel gegen ein frisch gebootstrapptes Ziel (Träger
  `.harness/state/bin/ai-harness-init`, byte-gleich zur Vorlage: `diff` leer) mit dem gepinnten d-check.
- **Grüner Start** (die sechs Kombinationen der Stufe plus `cpp hexagonal`): `0 Befund(e)`, Spec-Treffer
  `grep -cE '(slice|welle)-'` → 0 für sprachlos, go flat/hexagonal/hexslice, cpp flat/hexslice; `cpp hexagonal` →
  Exit 2, *„unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice"*. `langArchs()` in `internal/gen/gen.go` führt
  genau diese fünf Sprach-Architektur-Paare.
- **Fünf Gegenbeispiele der Stufe und Marker-Ausweg** von Hand im Ziel nachgebaut, Meldung gelesen (Ausgabe unten);
  je Gegenbeispiel die **Gegenprobe** (Position zurück in die alte Form bzw. Regel/Glob gestrichen) → `0 Befund(e)`
  (G1 bis G5 grün, Basis `0 Befund(e)`).
- **Zusatzsonden im Ziel:** `## Geschichte` in einer Spec-Datei; `## 7. Historie`; bares `ADR-`/`ADR-12`;
  `ADR-IDX-0004` als Titel, verlinkt und blank; `README.md` unter `docs/plan/adr/`; Spec → Carveout/Roadmap als Link
  und blank; ADR → Carveout/Roadmap als Link.
- **`internal/emit`-Test unmutiert** im vorhandenen Bild `ai-harness-init:test` (`--network none`, Scratchpad-Kopie
  von `git archive HEAD`): grün. **Zähne 435 bis 442 emuliert** (das Skript aus `test/mutations/` in der Kopie
  angewandt, `go test ./internal/emit`): je Fall genau **ein** roter Unterfall, der im `# expect:` genannte
  (Tabelle unten). **Sieben Ad-hoc-Mutationen** außerhalb der Fälle (Tabelle unten).
- **`test/full-smoke-ausgang.bats` und `test/e2e-abdeckung.bats`** im gepinnten bats-Image: 26 ok, 0 not ok.
  `make e2e-abdeckung` → *„unverändert — docs/user/e2e-abdeckung.md (21 Stufen, 21 Deklarationen)"*, `git status`
  danach leer: der Generator erzeugt dieselbe Datei.
- **Nicht gefahren:** `make mutate` (verboten, der Beleg hängt am Baum-Hash: Verifier); `make full-smoke` als
  Ganzes (lang; die Stufe ist in ihren Teilen einzeln nachgebaut, s. o. — der Lauf der Funktion
  `kennungs_form_im_ziel` selbst, ihrer Schleife und ihres `set -e`-Verhaltens ist damit **nicht** gemessen);
  `make lint`/`make test-go` als Ganzes; die Ziele mit `add-lang` am gemischten Root (der Aufruf brach in meiner
  Kopie ohne Aggregator ab, kein Befund am Diff). `make gates` — siehe Ende.

---

## Zell-Messung (Liefer-Punkt 1) — nachgemessen, Ist gegen Soll

Die Messung liest **zwei Stellen** — Matrix-Tabelle plus Gate-Text des Regelwerks und die eingebettete Vorlage — und
sagt über das Verhalten nur soweit, wie die Sonden im Ziel es tragen (`MR-055`).

| Gruppe der ❌-Zellen | Zellen | Ist (`0abb97ac`) | Soll (`HEAD`) | Beleg dieses Laufs |
|---|---|---|---|---|
| Rangfolge innerhalb der Straten (Vertrag → Technik/Sicht, Technik → Sicht) | 3 | `order` + `direction: no-downward` | unverändert | nicht Gegenstand (`ADR-0065` §Grenze) |
| Spalten ADR · Slice · Welle der drei Straten-Zeilen | 9 | ADR: Regel · Slice: Regel, nur Ziffern-Token · **Welle: Lücke (3)** | **9 Regel** | ADR-Zelle: Sonde 4 (`ADR-IDX-0004` blank → `id-unlinked`), Slice/Welle: Sonden 1 bis 3 (`matrix-forbidden`) |
| ADR → Welle | 1 | Regel, nur Ziffern-Token | **Regel mit Zeilen-Marker** | Sonde 2 und Ausweg |
| Spec-Stratum → Carveout, → Roadmap | 6 | nur `aussen`, nur als Link | unverändert | Sonde: Link → `spec-straten → aussen ist nicht erlaubt` (2 Befunde); blanke `CO-001` → 0 |
| ADR → Carveout, ADR → Roadmap, Slice → Roadmap | 3 | keine Regel | unverändert | Sonde: ADR-Link auf Carveout und Roadmap → `0 Befund(e)` |
| **Summe** | **22** | | 3 + 9 + 1 + 6 + 3 | |

**Die Zählung von `ADR-0065` §Grenze (drei · neun · eine · sechs · drei) stimmt.** Die Summe der Zeilen der Tabelle
(7 + 6 + 5 + 3 + 1) ergibt 22; keine Zelle ist doppelt gezählt. Zwei Aussagen der Zählung tragen nicht ohne Vorbehalt
und sind Befunde an den Architect (R1, R6): die Spalte „Regel" der neun Zellen hat für Spec-Straten einen Ausweg
über einen Abschnitt `Geschichte` (R1), und `ADR-` **ohne** vierstellige Nummer fängt keine Regel (R6). Beide
Zusatzbefunde des Implementers sind gemessen und stimmen.

## Ergebnis der Sonden im Ziel (Meldungen gelesen)

| Sonde | Ausgabe im Ziel | Gegenprobe |
|---|---|---|
| 1 ADR nennt `slice-lokal-probe` | `matrix-forbidden — Token-Referenz adr → slice (slice-)` | Token `slice-\d{3}` → `0 Befund(e)` |
| 2 ADR nennt `welle-cache-warmup` | `matrix-forbidden — Token-Referenz adr → welle (welle-)` | Token `welle-\d{2}` → `0 Befund(e)` |
| 3 Spec nennt `welle-cache-warmup` | `matrix-forbidden — Token-Referenz spec-straten → welle (welle-)` | Regel gestrichen → `0 Befund(e)` |
| 4 Spec nennt `ADR-IDX-0004` | `id-unlinked — Kennung ohne Link auf ihre Definition` | Muster `ADR-\d{4}` → `0 Befund(e)` |
| 5 `IDX-0004-probe.md` nennt `slice-lokal-probe` | `docs/plan/adr/IDX-0004-probe.md:7 … adr → slice (slice-)` | Glob gestrichen → `0 Befund(e)` |
| 6 dieselbe ADR-Zeile mit Slice- **und** Welle-Name plus Marker | `0 Befund(e)` | — |
| 7 `README.md` unter `docs/plan/adr/` nennt `slice-lokal-probe` | `0 Befund(e)` (Datei liegt außerhalb der Klasse, gewollt) | — |
| 8 `ADR-IDX-0004` als Titel / verlinkt aus `docs/` | `0 Befund(e)`; blank → `id-unlinked` | — |

Die Regexe der Stufe (`matrix-forbidden.*adr → slice \(slice-\)` und Verwandte) lesen jeweils die **Regel und das
Token** aus der Meldung, nicht nur den Exit; sie treffen die gemessenen Zeilen. Unter der Ziffern-Form bleibt jedes
Gegenbeispiel grün, jedes Rot kommt also aus der Änderung, nicht aus einem Nachbar-Befund.

## Emulierte Zähne

| Fall / Ad-hoc | Mutation | roter Unterfall von `TestDCheckConfig_KennungsForm` |
|---|---|---|
| 435 | Slice-Token in Ziffern-Form | `token_slice` (allein) |
| 436 | Welle-Token in Ziffern-Form | `token_welle` (allein) |
| 437 | Regel `spec-straten → welle` gestrichen | `regel_spec_straten_welle` (allein) |
| 438 | `ids`-Muster ohne Segment | `ids_muster_adr` (allein) |
| 439 | Glob mit Bereichs-Präfix gestrichen | `adr_klasse_bereichs_praefix` (allein) |
| 440 | Ziffern-Form im Kommentar | `keine_ziffern_form` (allein) |
| 441 | weiteres `token:` auf `spec-straten` | `token_menge` (allein) |
| 442 | weitere Regel `adr → aussen` | `regel_menge` (allein) |
| a | Slice-Token ganz weg | `token_slice`, `token_menge` |
| f | Regel `allow: true` | `regel_spec_straten_welle`, `regel_menge` |
| g | Regel auskommentiert | `regel_spec_straten_welle` |
| e | Glob `*-[0-9]*.md` statt `[A-Z]*-…` | `adr_klasse_bereichs_praefix` |
| m | Segment im ADR-Muster Pflicht statt optional | `ids_muster_adr` |
| n | Slice-Token `slice-[0-9]{3}` | `token_slice` |
| o | dritter Glob `README.md` | `adr_klasse_bereichs_praefix` |
| **l** | `link-policy: always` → `never` auf der ADR-Zeile von `ids` | **kein roter Test** (R3) |

Jeder der acht Fälle bindet **genau eine** Zusicherung: die Gegenprobe „Zusicherung geschwächt → grün heißt bindet"
folgt daraus — färbt eine Mutation nur den einen Unterfall, deckt ihn kein Nachbar. Die `sed`-Anker aller acht ändern die Datei
im heutigen Bestand (kein „MUTATION ÄNDERT NICHTS"); die Erwartung ist ein Präfix einer `--- FAIL:`-Zeile, wie
`failure_form()` für die Go-Stufe sie liest.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R1 | MEDIUM | `exclude-sections: [Geschichte]` gilt in der emittierten Konfiguration für **jede** Quelle, auch für die Spec-Straten: Steht in einer Spec-Datei ein Abschnitt `## Geschichte`, ist ein `slice-x` oder `welle-x` dort **kein Befund** (Zusatzsonde `## Geschichte`: Zeile mit `slice-abc welle-x ADR-0001` unter `## Geschichte` → nur `ADR-0001` als `id-unlinked`, weil `ids` die Ausnahme nicht honoriert; die Matrix-Tokens fehlen; unter `## 7. Historie` dagegen 2 Befunde). `ADR-0065` Festlegung 1 (*„Spec-Straten: Umformulieren … keine ausgenommene Sektion"*) und §Grenze (*„…wo die Vorlage keine Sektion ausnimmt"*) sagen das Gegenteil; die Zählung „neun Zellen: Regel" trägt für die Spec-Zeilen also nur ohne diesen Abschnitt. Die emittierten Spec-Vorlagen führen keinen `Geschichte`-Abschnitt (`grep -n '^## ' spec/lastenheft.md` im Ziel: `7. Historie`), der grüne Start ist nicht berührt; die Lücke besteht seit der Vorlage vor diesem Slice, der Diff nennt sie im Kommentar nicht. | `ADR-0065` Festlegung 1, §Grenze · `AGENTS.md` §3.6 (Zusage einschränken auf das, was gehalten wird) | `internal/emit/templates/d-check.yml` Zeile 113 (`exclude-sections`); `ADR-0065` §Grenze | ja — Zusatzsonde (`## Geschichte` mit `slice-abc welle-x` in `spec/lastenheft.md`) | Ausnahme-Sektion nimmt eine Klasse aus, die die Zusage benennt nicht |
| R2 | LOW | Der Diff ändert in `harness/tools/full-smoke.sh` einen Kommentar außerhalb des Gegenstands: `git diff 0abb97ac..HEAD` zeigt in Abschnitt (a2) `den ein` → `den eine`; der Satz lautet danach *„…der eine Index, den eine gebootstrapptes Repo von sich aus fuehrt"*. Kein Wortlaut des Slice und kein Zweck der Stufe verlangt die Änderung; sie ist ungrammatisch. | Maintainability · Plan §3 (*„Was der Slice nicht anfasst"* nennt nur `full-smoke.sh` als Datei, nicht diesen Abschnitt) | `harness/tools/full-smoke.sh` Zeile 3510 | ja — `git diff 0abb97ac..HEAD -- harness/tools/full-smoke.sh | grep -n 'den eine'` | unbeabsichtigte Änderung in fremdem Kommentar |
| R3 | LOW | Die Zusicherung `link-policy: always` in `TestDCheckConfig_EntschiedeneModulListe` ist `strings.Contains` über die **ganze Datei**; der Kommentar der Vorlage enthält `link-policy: always` (auskommentierter Requirement-Vorschlag, Zeile 16, und der Satz Zeile 64), sie ist damit auch bei `link-policy: never` auf der ADR-Zeile erfüllt. Der Diff hat den Regex-Teil der Zusicherung in `ids_muster_adr` verlegt und die Zusicherung auf `link-policy` allein verkürzt; `ids_muster_adr` liest bis `target: docs/plan/adr/,` und nicht weiter. Ad-hoc-Mutation **l** (`link-policy: never`) → kein roter Test in `internal/emit`, und kein Fall unter `test/mutations/` führt die Position (`grep -ln 'link-policy' test/mutations/*.sh` → nur 375, dessen Mutation sie nicht abschaltet). Was die Position bindet, ist allein das Gegenbeispiel 4 der full-smoke-Stufe (Meldung `id-unlinked`), das `make mutate` nur über eine full-smoke-Stufe fahren könnte. Bestand der Zusicherung, der Diff hat sie nicht enger, aber auch nicht enger gemacht. Nebenbefund: der Kommentar am Test sagt, jede Mutation färbe „genau eine Zusicherung"; a (Token ganz weg) und f (`allow: true`) färben je zwei — die Zusage gilt für die acht Fälle, nicht für die Menge. | `AGENTS.md` §3.6 · `MR-071` | `internal/emit/emit_test.go` Zeilen 59 bis 61, 115 bis 117; `internal/emit/templates/d-check.yml` Zeile 13 | ja — Mutation l gegen `go test ./internal/emit` → 0 rot | `Contains` über die ganze Datei trifft den Kommentartext |
| R4 | LOW | Die Kombinationen des grünen Starts sind in `kennungs_form_im_ziel` als feste Liste geschrieben (`"|" "go|flat" … "cpp|hexslice"`); sie sind mit `langArchs()` in `internal/gen/gen.go` heute deckungsgleich (gemessen), aber an keine Quelle gekoppelt. Kommt `cpp hexagonal` oder eine dritte Sprache hinzu, bleibt die Stufe grün und ihr Beschreibungstext (*„je Sprache und Architektur"*, `docs/user/e2e-abdeckung.md`) sagt mehr, als sie misst; ein Wächter meldet die Differenz nicht. | `LH-QA-01` · `AGENTS.md` §3.6 (Test-Name muss die Eigenschaft messen) · `ADR-0065` Festlegung 6 (ii) | `harness/tools/full-smoke.sh` Zeile 2933 (`for eintrag in …`) | ja — Sonde: `langArchs()` gegen die Liste, heute gleich; die Drift entsteht erst mit einem neuen Layout | Menge im E2E hartverdrahtet, keine Kopplung an die Quelle |
| R5 | INFO | Der Herkunfts-Kommentar der Vorlage führt eine **Positions-Liste** für den Nachzug (Token, Regel, `ids`-Muster, Glob) und die Zusagen „nur an einem freien Pfad", „der Marker ist nicht Ziel-spezifisch", „die Regeln mit dem Adaptions-Block als Quelle führt die Vorlage nicht". Die Aussagen stimmen gegen den Emitter (`writeSkipIfPresent(targetDir, ".d-check.yml", …)` in `internal/emit/emit.go` Zeile 183; einziger Schreibpfad der Datei; Sonde 6 belegt den Marker für Slice und Welle zugleich) — die Liste selbst hat keinen Träger: Kommt eine sechste Position hinzu, hält kein Test die Liste gegen die Vorlage. Das ist **kein** drittes Auftreten von „Zusage reicht weiter als das Geschehen im Ziel": der Kommentar sagt genau das, was der Emitter tut. | `AGENTS.md` §3.6, §3.7 (Zusage, Kopplung) | `internal/emit/templates/d-check.yml` Zeilen 56 bis 61 | nein — kein Sensor liest die Liste | Kommentar-Zusage ohne Träger, ihr Zähler steht beim Closure-Urteil |
| R6 | INFO | Ein bares `ADR-` ohne vierstellige Nummer (`ADR-`, `ADR-12`) fängt keine Regel (Sonde: `Siehe ADR- und ADR-12 hier.` in einer ADR → `0 Befund(e)`; in einer Spec-Datei ebenso). Der Gate-Text des Regelwerks lautet *„enthält `ADR-` oder `slice-`"*, `ADR-0065` §Grenze nennt ihn *„hier nicht enger, und nicht weiter"*; für `ADR-` ist die Vorlage enger (das Muster verlangt `\d{4}`). Bestand der Vorlage (`ADR-\d{4}` vor dem Diff), die Zählung der ADR trägt die Aussage nicht. Aufgefallen bei der Zell-Messung; der Diff verändert es nicht. | `ADR-0065` §Grenze · Regelwerk `grundlagen-referenz-richtung.md` (Gate-Text) | `internal/emit/templates/d-check.yml` Zeile 13 | ja — Sonde | Grenze der Vorlage enger als der zitierte Gate-Text |
| R7 | INFO | Der Ausweg-Fall der Stufe (dieselbe ADR-Zeile mit dem Marker → `0 Befund(e)`) kann über keine Änderung der **Vorlage** rot werden: fehlten `adr → slice` und `adr → welle`, wäre er ebenfalls grün. Er bindet den Marker des gepinnten d-check als Quellklasse-Ausweg (die Bedingung, die `ADR-0065` 2(c) für 2(b) nennt, hier für 2(a)/Festlegung 1), nicht eine Position der Datei. Dass dieselbe Zeile **ohne** Marker rot ist, folgt aus den Fällen (1) und (2) mit **getrennten** Zeilen, nicht aus einer Gegenprobe derselben Zeile. Kein Mangel; die Stufenbeschreibung nennt beides, ein Leser sollte den Fall nicht als Zahn der Vorlage lesen. | `AGENTS.md` §3.6 | `harness/tools/full-smoke.sh` (Fall „Kennungs-Ausweg") | ja — Regeln entfernen, Ausweg-Fall bleibt grün | Fall belegt eine Werkzeug-Eigenschaft, keine Position der Datei |
| R8 | INFO | Commit `56bcaaad` (Implementer) entfernt den Ruhe-Marker in der Roadmap; dieselbe Form wie beim Vorgänger-Slice, die Wiederherstellung steht im Commit als Teil des Abschlusses (Planner). Die Quelle, die dem Implementer diese Zeilen zuordnet, fehlt weiter (im Register geführt). Nichts anders als zuvor. | `AGENTS.md` §3.10 | `docs/plan/planning/in-progress/roadmap.md` | nein | schon geführt, kein neuer Befund |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Deckt die Vorlage `ADR-0065` (Festlegungen 1, 2(a), 3)?** Token `slice-` auf `slice`, `welle-` auf `welle`; Regel `{from: spec-straten, to: welle, allow: false}`; `ADR-([A-Z]+-)?\d{4}` mit `link-policy: always`; Klasse `adr` mit `[0-9]*.md` **und** `[A-Z]*-[0-9]*.md`, `README.md` draußen (Sonde 7); keine Ziffern-Form außer dem Token `MR-\d{3}` der Klasse `adaptionsblock` (nicht Gegenstand) | geprüft, ohne Befund |
| **Reichweite (Ausschluss):** der Diff berührt weder die eigene `.d-check.yml` noch `internal/emit/templates/enforce/`, `harness/tools/commit-msg-traceability.sh`, `harness/conventions*`, `AGENTS.md` oder das Handbuch (`git diff --stat`); keine Regel mit dem Adaptions-Block als Quelle, keine Neutralisierung, kein Marker-Kommentar außer dem, den `ADR-0065` Festlegung 1 und §Grenze für die Vorlage verlangen (der Marker steht dort als Ausweg und mit der Aussage, dass er nicht Ziel-spezifisch ist) | geprüft, ohne Befund |
| **Zell-Messung:** 22 = 3 · 9 · 1 · 6 · 3, die Zählung von `ADR-0065` stimmt; Vorbehalte R1 und R6 an den Architect | geprüft, mit Befund (R1, R6) |
| **Go-Test `TestDCheckConfig_KennungsForm`:** bindet die **Menge** der Token (`token_menge`: 3 Klassen), der Regeln (`regel_menge` gegen die geschlossene Liste) und die Ziffern-Form in allen Nicht-Klassen-Zeilen; acht Fälle, je genau ein Unterfall rot, Meldung gelesen (`token_slice: die Klasse slice traegt nicht das Praefix-Token slice-`, usw.); keine Bindung an die Namen der neuen Zeilen; sieben Ad-hoc-Mutationen alle rot, aus dem behaupteten Unterfall | geprüft, ohne Befund (R3 für `link-policy`) |
| **`TestDCheckConfig_EntschiedeneModulListe`:** die Kürzung entfernt den Regex-Teil, der in `ids_muster_adr` (`HasPrefix` auf das ganze Muster samt `target:`) enger steht; die übrigen Zusicherungen (Regeln `adr → slice/welle`, Module) unverändert | geprüft, ohne Befund |
| **Mutations-Fälle 435 bis 442:** Anker ändern die Datei im heutigen Bestand, Verdrahtung ist die Vorlage selbst (kein Nachbau der Prüfung), `# expect:` je ein Unterfall-Name; keiner färbt nur über ein Nachbar-Rot | geprüft, ohne Befund |
| **full-smoke-Stufe — Aufbau:** Stufen-Kopfzeile vorhanden, `e2e_abdeckung`-Deklaration nennt `LH-FA-01 LH-FA-03 LH-QA-01`, erzeugte Datei entsteht identisch (`make e2e-abdeckung` unverändert, 21 Stufen); `kf_gegenbeispiel` liest die Meldung per `grep -qE` auf Regel und Token, prüft per `cmp -s`, dass die Schwächung die Datei ändert, und verlangt `, 0 Befund(e)` in der Gegenprobe; jede der fünf Gegenproben ist von mir grün gemessen, jedes Gegenbeispiel rot mit der genannten Meldung | geprüft, ohne Befund (R4, R7) |
| **Wächter-Ehrlichkeit `test/full-smoke-ausgang.bats`:** die Datei ist im Diff **unverändert**; die Gleichung `A − B − C == D − 2` hält (die neue Stufe fügt einen `make`-Abschnitt mit `einordnen` und zwei Werkzeug-Aufrufe hinzu: `A +3`, `C +2`, `D +1`); 26 Fälle grün. Keine Lockerung, um die Stufe durchzubringen | geprüft, ohne Befund |
| **Register-Fallen (Plan §8) an den neuen Fällen:** `!` mitten im bats-Fall — der Diff legt keinen bats-Fall an; weite Assertion über enger — der Go-Test hat je Unterfall eine Assertion, Gegenprobe (die acht Fälle färben je einen Unterfall) trägt; Zusage nur über Fall-Assertion ohne Zahn — die neun Zusicherungen des Tests haben Zähne bis auf `link-policy` (R3) | geprüft, mit Befund (R3) |
| **Herkunfts-Kommentar (§3.7, §3.11):** Zustandsform, Indikativ, keine verworfene Alternative, keine Kennung dieses Repos (`ADR-IDX-0004` ist das Beispiel des Regelwerks), keine Pfad-Adresse eines bewegten Artefakts; Baseline-Bezug als `<tag>`-Pfad wie zuvor; „nur an einem freien Pfad" gegen `writeSkipIfPresent` und die einzige Schreibstelle geprüft | geprüft, ohne Befund (R5) |
| **Größe und Schnitt:** 4 Commits, 14 Dateien, 3 Liefer-Punkte, zwei Schichten (Emission, Test/E2E); Abgrenzung eingehalten: kein Adaptions-Eintrag, keine Hard-Rule-Änderung, das Handbuch unberührt (kein Ist-Wechsel an dem, was `docs/user/` beschreibt — die Abdeckungs-Sicht ist erzeugt) | geprüft, ohne Befund (R2) |
| **Rollen-Grenzen (§3.8, §3.10):** Commits `56bcaaad`, `ceace58b`, `ef6be99f` nennen die Rolle Implementer und berühren nur Vorlage, Test, Fälle, E2E, erzeugte Sicht und die drei Marker-Zeilen; kein Closure-Schritt, Plan §7 leer | geprüft, ohne Befund (R8: bekannte Form) |
| **Lint-Suppression (§3.2):** `git diff 0abb97ac..HEAD | grep -cE 'shellcheck disable|nolint'` → 0 | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 3 |
| INFO | 4 |

**Finding-Klassen dieses Laufs:** Ausnahme-Sektion nimmt eine Klasse aus, die die Zusage benennt nicht ·
unbeabsichtigte Änderung in fremdem Kommentar · `Contains` über die ganze Datei trifft den Kommentartext · Menge im E2E
hartverdrahtet, keine Kopplung an die Quelle · Kommentar-Zusage ohne Träger · Grenze der Vorlage enger als der zitierte
Gate-Text · Fall belegt eine Werkzeug-Eigenschaft, keine Position der Datei · schon geführte Form (Ruhe-Marker)

## Verdikt

**Kein Merge-Blocker an den Positionen.** Kein HIGH: die Vorlage deckt `ADR-0065` an den Festlegungen 1, 2(a) und 3, die
Ziffern-Form steht nirgends, der grüne Start hält für alle fünf Kombinationen, die die Stufe nennt, und jede Position
hat ein im Ziel rot gesehenes Gegenbeispiel mit gelesener Meldung und grüner Gegenprobe; die acht Zähne färben je
genau einen Unterfall aus dem behaupteten Grund. R1 (MEDIUM) ist vor der Closure zu klären, aber **nicht am Diff**: die
Lücke besteht in der Vorlage vor diesem Slice, sie widerspricht zwei Aussagen der `Accepted`-ADR und gehört dem
Architect. R2 bis R4 sind LOW und vor dem Merge mitzunehmen, wenn der Implementer sie für berechtigt hält.

**Übergabe:**

- **R1, R6 → Architect** (Adresse ist `ADR-0065`, unveränderlich: Folge-ADR mit `Supersedes` oder Aufnahme in die Grenze
  einer Folge-Entscheidung; die Zell-Messung des Slice trägt sie als benannte Lücke). Die Entscheidung, ob die Vorlage
  den Abschnitt aus den Spec-Straten nimmt, gehört nicht diesem Lauf.
- **R2, R3, R4 → Implementer** (Zeile 3510 in `full-smoke.sh` zurück; die `link-policy`-Zusicherung auf die Position
  binden oder die Lücke im Kopf des Tests benennen; die Kombinations-Liste an `langArchs()` koppeln oder die Grenze in
  der Stufenbeschreibung nennen).
- **R5, R7 → Planner** (beim Closure-Urteil zu den Registerzählern `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`,
  `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`: der Kommentar reicht nicht weiter als der Emitter; ob R5/R7
  als Auftreten zählt, ist das Urteil der Closure).
- **R8 → kein neuer Weg** (bekannte Form, im Register geführt).
- Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein
  Lauf-Beleg und ersetzt keine Verifikation: DoD-Konformität, den Beleg der Fälle unter `make mutate` und den Lauf
  von `make full-smoke` als Ganzes (die Stufe wurde hier nur in ihren Teilen im Ziel nachgebaut) prüft der Verifier.
