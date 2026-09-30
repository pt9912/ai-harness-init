# Verifier-Report: slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert — 2026-09-30

**Rolle:** Verifier (Modul 11) — geprüft gegen die DoD (§2 des Slice-Plans), §1 (Ziel und Abgrenzung), §3 (Plan) und ADR-0013.
**Kette:** `3ece6acb..79f4ffde` (Tip `79f4ffde`, Arbeitsbaum vor diesem Report clean, 10 Commits vor `origin/main`).
**Eingangs-Kontext:** Slice-Plan (vollständig), Klassifikationsbericht `docs/reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md` (Stand `79f4ffde`, nach Review nachgebessert), Review-Report `…-review.md` (`a5cc5b42`), `AGENTS.md` §3.4/§3.6/§3.7/§3.8/§3.10/§3.11, `v6.13.0` · `regelwerk/modul-11-verification.md`.
Jede Zahl unten ist ein eigener Lauf, keine aus Implementer- oder Reviewer-Bericht übernommen. Scratchpad-Kopien; der Bericht, der Plan und `spec/` sind unverändert.

**Vorlage:** Unter `.harness/baseline/v6.13.0/templates/docs/reviews/` liegt nur `review-report.template.md` (Review-Form mit Findings-Schema des Reviewer-Skills); für einen Verifier-Report gibt es keine Vorlage. Form wie die vorhandenen `…-verify.md`-Reports (DoD je Punkt · Plan-vs-Code-Diff · Übergaben).

---

## 1. DoD §2 — je Punkt

### Liefer-Punkt 1 — Klassifikationstabelle: BESTÄTIGT (mit benannter Grenze der Zusage)

Eigene Messungen (Repo-Wurzel, Kommandos aus Plan §1 und Bericht §2):

```sh
sed -n '137,718p' spec/spezifikation.md | wc -c                      # 45889
awk -F'|' '/^\| (U|T)/ {s+=$8} END{print s}' $F                      # 45889   (Summe der Bytes-Spalte)
comm -23 <Testnamen der Spec> <Testnamen der Tabelle>                # leer    (24 Namen)
comm -23 <Fall-Dateien der Spec> <Fall-Dateien der Tabelle>          # leer    (26 Dateien)
awk -F'|' '/^\| (U|T)/ && $3 ~ /[0-9]–[0-9]/' $F | wc -l            # 75      (mit /^\| U[0-9]+ / → 64)
```

Über den Bericht hinaus, ohne dessen Kommandos: **jede der 64 Einheiten einzeln** gegen `sed -n '<a>,<b>p' spec/spezifikation.md | wc -c` gehalten — 0 Abweichungen; die Zeilenbereiche der Bytes-tragenden Zeilen schließen lückenlos von 137 bis 718 (keine Lücke, kein Überlapp). Alle 24 Testnamen (`func <Name>` in `internal/`, `cmd/`) und alle 26 Fall-Dateien existieren.

**Rot-Beleg (Modul 11 §Bewusstes Brechen), von mir gefahren** — Kopie des Berichts im Scratchpad, Zeilen gestrichen, die drei Kommandos aus Bericht §2 *Vollständigkeit* (Soll 45889):

| gestrichen in der Kopie | Byte-Summe | Testnamen fehlen | Fall-Dateien fehlen |
|---|---|---|---|
| nichts | 45889 | — | — |
| `U10` (Zeile in §3 und in §6.1; 646 Bytes) | 45243 | — | — |
| `U52` | 45292 | `TestClampSurvivesBrokenPayload`, `TestEmitWritesSpanFromHook`, `TestSubkommandoRouting_ReportSchreibtBilanz` | `154-unterkommando-routing-vertauscht.sh` |
| `T` | 45889 | 11 (alle `TestCommand*`) | — |
| `U56`,`U57`,`U58`,`U59`,`U61` | 44407 | — | 128, 129, 132, 135 |
| `U51` | 44154 | — | 9 (107 bis 115) |
| `U53` | 45388 | — | 123 bis 126 |
| `U08` (nennt Tests, alle noch anderswo genannt) | 45430 | — | — |
| Spec-Kopie mit erfundenem `TestErfundenXyz` und `999-erfunden.sh` in Zeile 700, Bericht unverändert | 45889 gegen Soll 45938 | `TestErfundenXyz` | `999-erfunden.sh` |

Gelesen (Meldung, nicht nur Exit): Jede fehlende Einheit lässt die Byte-Summe von 45889 abweichen; die beiden Namens-Kommandos nennen bei `U52`, `U51`, `U53`, `U56…` den **fehlenden Namen selbst** — das Rot trägt die behauptete Ursache. Das Streichen von `T` färbt allein die Namens-Differenz (die Summe bleibt: `T` zählt 0). Das stimmt Zeile für Zeile mit der Bruchprobe im Bericht (§2 *Bruchprobe*) überein.

**Grenze der Zusage, die der Plan-Wortlaut breiter fasst.** Plan §2: „eine Zeile streichen — **beide** Kommandos zeigen den Fehlbetrag“. Das gilt nur für eine Zeile, die einen Wächter namentlich nennt (`U52`); bei `U10` und `U08` zeigt allein die Byte-Summe den Fehlbetrag, bei `T` allein die Namens-Differenz. Der Bericht sagt das selbst (Lesart unter der Bruchprobe; §7 „Grenzen“: Byte-Summe und Fall-Dateien tragen die Vollständigkeit, die Namens-Differenz allein nicht). Der DoD-Kern — die Vollständigkeit ist messbar und färbt rot — ist gehalten; der Wortlaut „beide Kommandos“ ist es nur für Wächter-nennende Zeilen und **nicht** als Aussage über jede Zeile.

**Zweite Grenze, gemessen (Mutation gesehen, Bericht sagt sie nicht ausdrücklich).** Die Byte-Summe misst die Summe, nicht die Zuordnung: In einer Kopie `U10` 646→600 und `U11` 1426→1472 gesetzt, `U01` 137–140 → 137–141 verlängert: `sum=45889`, alle Kommandos **grün**. Nur die Einzel-Schleife (`sed` je Einheit) meldet `ABW U01`, `ABW U10`, `ABW U11`. Ein Kommando dafür steht im Bericht nicht; der Bericht behauptet es auch nicht (§7: „Die Vollständigkeit ist maschinell gedeckt“; „die Klassen-Zuordnung ist nicht gedeckt“), die Zusage „Bytes je Einheit sind richtig“ ist also **durch mich, nicht durch einen Sensor des Berichts** belegt. INFO an den Planner.

**Klassenverteilung nachgerechnet** (Summe der Bytes-Spalte je Klasse über den Tabellenzeilen, Anteil an 45889):

| Klasse | Zeilen | Grenzfälle | Bytes | Anteil |
|---|---|---|---|---|
| a | 21 | 6 | 10177 | 22,2 % |
| b | 10 | 5 | 3293 | 7,2 % |
| c | 15 | 11 | 13508 | 29,4 % |
| d | 12 | 1 | 8245 | 18,0 % |
| e | 16 | 1 | 10666 | 23,2 % |

Alle Werte stimmen mit Bericht §2 überein. Abgeleitete Zahlen des Berichts ebenfalls: 20 Einheiten und 4 zweite Zeilen als Grenzfall (24 = 6+5+11+1+1); 6405 Bytes (47,4 % von 13508) in den Prüfschritten U41, U43–U45, U48, U49 und 2998 Bytes in U40, U42, U46, U47, U50 (Summe der Tabellenwerte selbst nachgerechnet).

**Zählregel „35 Zeilen“ (Risiko 3): BESTÄTIGT.** Die 35 Treffer nach Erst-Zeile der Einheit: a 4 (142, 160, 325, 330), b 4 (156, 447, 450, 452), c 24, d 0, e 3 (195, 621, 655). `grep -c 'ungemessen'` → 2 (195, 655); die übrigen 33 sind Messstellen (`grep -vc` → 33). 24 in c, nach beiden Zeilen einer Zwei-Klassen-Einheit 27 (Zeilen 142, 325, 330 haben als zweite Zeile `c`; Zeile 160 in U05 hat keine). Bericht §2 und §4 Punkt 5 stimmen.

**Einheiten-Schnitt (64 gegen ~34/41): sauber als Plan-Abweichung benannt.** Bericht §1 *Abweichung vom Schnitt des Slice-Plans* nennt den Plan-Schnitt (41 Einheiten = 34 − 2 + 3 + 6; ich habe die beiden `awk`-Zählungen gefahren: 2 und 6, plus die 34 Block-Anfänge), die Differenz (23), eine Aufschlüsselung je Block (`149 5 · 201 2 · 303 2 · 372 3 · 470 8 · 550 4 · 594 13` — von mir identisch reproduziert; 8+13+16=37 gegen 3+6+5=14), eine Begründung (eigener Wächter-Satz oder eigene Klasse je Einheit) und übergibt die Frage ausdrücklich an den Planner. Die 75 Zeilen liegen unter der Rückführungs-Grenze aus Plan §4 (rund 100). Damit ist F-1 des Reviews eingearbeitet.

### Liefer-Punkt 2 — Zeiger-Inventar: BESTÄTIGT

- `grep -rnE 'spezifikation\.md' internal test cmd harness/tools docs/plan/adr` → **100** Stellen; die `Z`-Tabelle des Berichts hat 100 Zeilen und ist als Menge `Datei:Zeile` **identisch** (`diff` der sortierten Listen leer).
- Verteilung selbst gezählt: 44 mit mindestens einer `U`-Einheit, 23 nur `T`, 3 nur `K`, 7 `P`, 23 ohne Einheit (`—`), Summe 100; ADR-Text 51 (`Z001`–`Z051`). Die Spalte *Sensor-Abhängigkeit* der Klassifikationstabelle und die Spalte *Einheit(en)* der `Z`-Tabelle sind Paar für Paar deckungsgleich (Abgleich per Skript; einzige Differenz war die `U21b`-Normalisierung meines Filters, keine des Berichts).
- **Stichprobe: 15 Stellen** gegen die Fundstelle mit Kontext gelesen: Z057 (U20 verdrahtete Ereignisse), Z062 (U24 Felder statt Dateiname), Z065 (U32 Splitting), Z066 (U37 Prüfreihenfolge Punkt 3), Z070 (T, SPEC-021), Z075 (U60, „Bewacht, Punkt 8“), Z080 (U28 Worktree-Fall), Z085 (U27 Abweichung 1), Z086 (—, ADR-0011-Delegation, keine §5-Passage), Z090 (T,U03, „NEUN Werte“), Z093 (U37 Punkt 2), Z094 (U46), Z031 und Z038 (ADR-Text), Z052. Alle plausibel und zuordenbar; eine Stelle ohne zuordenbare Einheit steht als eigene Zeile (23-mal).
- **Kleiner Befund (INFO):** Z052 (`harness/tools/full-smoke.sh:926`) ist keine Kommentar-Nennung, sondern ein per `sed` in eine Fixture-Datei geschriebener Text (der Satz „Siehe … fuer Details (Abwaertslink, Zahn)“ mit einem Markdown-Link auf die Spec). Die Spalte *Art* führt „Kommentar (Rang-Zeiger)“, richtiger wäre Fixture; die Einheit `—` stimmt. Ohne Folge für Vollständigkeit oder Zuordnung.
- Randbefunde des Berichts (§7) nachgemessen: `grep -c 'statt Implementation' spec/spezifikation.md` → 0; `grep -c 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → 0 bzw. 1; ADR-0028 Zeile 214 und ADR-0021 Zeilen 72 und 652 nennen die Erwartung wie berichtet. Beide ADRs sind nicht angefasst (unten §3).

### Liefer-Punkt 3 — LH-Vorschlag: BESTÄTIGT

- **Vollständigkeit:** §6.1 führt alle 21 Zeilen der Klasse `a` (inklusive `U11b`), §6.2 alle 34 Zeilen `SPEC-001` bis `SPEC-034`. Jede Zeile trägt einen Kandidaten mit Fundstelle oder „kein LH gefunden“.
- **Fundstellen gegen `spec/lastenheft.md` gelesen:** `LH-FA-10` ab Zeile 257; Happy Path 287–288, Rolle besetzt 289–290, Betrieb fail-open/Umfang fail-closed 291–292, Redaktion 293–298, Leser 303–306, Benannte Grenze 315–316, Beschreibung 259–266 — alle wie zitiert. Die Nachbar-Nennung von Span/Token/Subagent/Erfassung/Bilanz außerhalb von `LH-FA-10` liegt in den Zeilen 344, 391, 403, 437, 448, 517, 555, 557 (Bericht nennt 344, 391, 403, 437 als Nachbarn in `LH-FA-11`/`LH-FA-12`; die übrigen vier habe ich nicht auf Träger-Relevanz gelesen).
- **Die 10 SPEC-Zeilen ohne LH** (001, 002, 003, 008, 014, 016, 019, 026, 027, 028): mit `grep` auf `model_version`, `permission_mode`, `duration_ms`, `total_tool`, `total_duration`, `seq`, `branch`, `commit`, `session`, `agent_type`, `SubagentStart`/`SubagentStop`, `Splitting`, `Sammelposten`, `spawned`, `hook`, `Matcher` im Bereich 257–318 des Lastenhefts: **kein Treffer**. Die Aussage „kein LH gefunden“ ist damit für diese Felder gehalten; 13 von 21 in Klasse `a` und 10 von 34 Tabellenzeilen stimmen mit §6.3 überein.
- **Grenze (Bericht benennt sie):** Die Bindungsstufe (`einzeln` / `pauschal` / `nahe`) ist ein Urteil des Berichts; ich habe es nicht ersetzt und stichprobenhaft gelesen (U36/`SPEC-010` „leer heißt unbekannt“ wortgleich in Zeile 289–290 → `einzeln` trägt). Die Ebenen-Frage (Zielrepo gegen dieses Repo) ist als Vorbehalt im Bericht an den Architect gegeben.

### `make gates` grün: BESTÄTIGT (für den Stand `79f4ffde`)

`make gates` auf sauberem Baum `79f4ffde` (vor diesem Report): **EXIT=0** (2 min 12 s). Kernzeilen: `baseline-verify: v6.13.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)` · `d-check: 2151 Datei(en) geprüft, 0 Befund(e)` · `comment-claims: 79 Datei(en) geprueft, 0 Befund(e)` · bats 454 `ok`, 0 `not ok` · `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`. Der Lauf nach dem Commit dieses Reports steht in der Übergabe an den Aufrufer.

### Review durchgeführt: BESTÄTIGT

Report `a5cc5b42` liegt vor (0 HIGH, 0 MEDIUM, 3 LOW, 2 INFO). Alle fünf Findings sind in `79f4ffde` eingearbeitet (unten §2).

### Doku-Update entfällt: BESTÄTIGT

`git diff --stat 3ece6acb..HEAD -- spec docs/plan/adr AGENTS.md harness .harness internal test cmd` → **leer**. Kein öffentlicher Vertrag berührt.

### Closure-Pflichten (Notiz mit Lerneintrag, Beobachtungs-Register, Risiko-Ausgänge, Paarungen): NICHT GEPRÜFT — Planner-Arbeit (§3.10). Die Plan-Datei trägt in §7 noch den Platzhalter; kein DoD-Häkchen gesetzt.

---

## 2. Review-Findings F-1 bis F-5 — wirklich eingearbeitet?

| Finding | Stand in `79f4ffde` | Verdikt |
|---|---|---|
| F-1 Einheiten-Schnitt nicht als Plan-Abweichung benannt | Bericht §1 *Abweichung vom Schnitt des Slice-Plans* mit Rechnung, Kommandos, Begründung und Übergabe an den Planner; §4 Punkt 7 wiederholt die Übergabe | eingearbeitet, Zahlen reproduziert |
| F-2 Sammelzeile `T` verdeckt Namens-Differenz | §2 *Vollständigkeit* nennt 16 Namen in `T`, 11 nur in `SPEC-031`, 5 in `T` und Fließtext; Streichprobe `U56…` zeigt die Blindheit | eingearbeitet |
| F-3 Bruchprobe fehlte im Bericht | §2 *Bruchprobe*, fünf Zeilen; von mir vollständig reproduziert (Tabelle oben) | eingearbeitet, Rot gesehen |
| F-4 Zählregel der 35 nennt ihre Grenzen nicht | §2 „Was die Zählung ausweist“: `ungemessen`-Zeilen 195/655, Erst-Zeile-Regel, 33/27-Zählung | eingearbeitet, nachgemessen |
| F-5 U35-Partner ohne Begründung | Tabelle: U35 „Grenzfall (b/a)“; §4 Punkt 8 begründet (Abgrenzung + Festlegung im selben Satz, „von `d` sagt der Text nichts“) | eingearbeitet |

---

## 3. Plan-vs-Code-Diff (beide Richtungen)

**Geplant und gebaut:** Genau eine neue Datei unter `docs/reviews/` mit der Slice-Kennung im Namen (Plan §3, erste Zeile); Klassifikationstabelle, Zeiger-Inventar, LH-Vorschlag (Liefer-Punkte 1 bis 3).

**Geplant „keine Änderung“, und keine geschehen:** `spec/spezifikation.md` (Plan §3), `spec/`, `docs/plan/adr/`, `AGENTS.md`, `harness/`, `.harness/`, `internal/`, `test/`, `cmd/` — der Diff über `3ece6acb..HEAD` ist für alle leer. Damit sind §3.4, §3.8 und die Abgrenzung „Kein Umbau von `spec/`“ / „Keine Änderung an `internal/`, `test/`, `cmd/`“ gehalten; ADR-0021 und ADR-0028 bleiben trotz der gemeldeten Randbefunde unverändert.

**Gebaut, aber nicht im Plan §3 (nach Sachlage):**
1. `docs/plan/planning/in-progress/roadmap.md` (Commit `3d926f6f`, 2 Zeilen: Ruhe-Marker weicht dem Slice). Plan §3 führt die Datei nicht; Baseline Modul 6 §Offene Wellen verlangt den Marker-Abgleich mit `in-progress/`. Prozess-notwendig, nicht Slice-Arbeit; Hinweis an den Planner, dass Plan §3 die Roadmap nicht nennt. Kein Befund.
2. Die zwei `git mv`-Commits `33262e16`/`ed6c7875` (reine Moves durch `make slice-mv`) und der Review-Report `a5cc5b42` — Lifecycle bzw. DoD-Punkt „Review“, geplant.

**Im Bericht gebaut, im Plan nicht ausdrücklich verlangt (innerhalb der Abgrenzung):** Träger-Zeile `T`; zehn zweite Zeilen mit demselben Zeilenbereich (Plan §3 „Grenzfälle … zwei Zeilen“ — **geplant**); Randbefunde zu ADR-0021/0028 (§7); Bindungsstufen `einzeln`/`pauschal`/`nahe` im LH-Vorschlag. Diese entscheiden keine Klasse und schreiben keinen Norm-Text (Bericht „Art“: Eingabe, nicht Norm). Kein Verstoß gegen §1 „Ausdrücklich NICHT“:
- „Keine Entscheidung über Klassen, Ort der Messprotokolle oder LH-Spalte“ — gehalten: §4 stellt acht Fragen an den Architect, entscheidet keine.
- „Kein Löschen eines Messprotokolls“ — nichts gelöscht.
- „Tabellenzeilen `SPEC-001` bis `SPEC-034` werden nicht klassifiziert“ — gehalten; `T` hat Klasse `—`, 0 Bytes.

**Plan gegen Code, Abweichungen:**
- Einheiten-Schnitt (siehe oben) — benannt.
- Plan-Formulierung „beide Kommandos zeigen den Fehlbetrag“ ist enger zu lesen (siehe Liefer-Punkt 1).
- Plan §1 „Ausgangslage“ trägt „34 Zeilen mit Kennung … der Auftraggeber nannte 36“; der Bericht wiederholt 34 (`grep -c 'SPEC-[0-9]'` → 34, von mir bestätigt).

**Hard Rules am Bericht:** §3.7 — der Bericht ist ein Zeitdokument in `docs/reviews/**`, kein Zustandsfeld; keine Befund-Kennung als Begründung. §3.11 — `grep -nE 'planning/(open|next|in-progress|done)|in-progress/'` über Bericht und Review-Report → kein Treffer; Slice-Kennung ohne Lifecycle-Pfad, Verweise auf ADRs, `MR-*` und `LH-FA-10` als Kennungs-Anker; `docs/reviews/2026-08-02-span-schema-messreihen.md` ist ein Zeitdokument außerhalb des Lifecycles. §3.6 — jede Zusage im Bericht trägt ihr Gegenbeispiel (Bruchprobe) oder benennt die Lücke (§7). §3.10 — kein Closure-Artefakt angefasst.

---

## 4. Übergaben und offene Punkte

### An den Planner (Closure, §3.10 — nicht von mir geschrieben)

**Risiko-Ausgänge §6, mit Beleg zur Entscheidung des Planners** (Vorschlag, Urteil bleibt beim Planner):

1. *„Der Absatz ist die falsche Einheit“* — **eingetreten**: 64 statt 41 Einheiten, 10 Einheiten mit zwei Klassen. Ausgang *eingetreten* verlangt Kennung: Der Umbau-Slice `slice-spec-5-erfassung-aus-tool-response-steht-als-tabellenzeilen` (liegt in `open/`) und `slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug` existieren; ob die Übergabe „feinerer Schnitt der Umbau-Slices?“ (Bericht §4 Punkt 7) dort ankommt, ist die Frage, die die Adresse annehmen muss (Modul 5 §Ziel-Form, Klasse 1).
2. *„Grenzfall-Klassen sind ein Urteil über Norm-Text“* — Vorkehrung gehalten (24 markierte Zeilen, keine Entscheidung); Ausgang *weiter offen* oder *eingetreten* mit Adresse `slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug`.
3. *„35 Treffer werden als (c) gelesen“* — **eingetreten**, gemessen: 24 von 35 nach Erst-Zeile in Klasse c, 2 davon `ungemessen`, 33 Messstellen, 27 nach beiden Zeilen. Der Ausgang ist quantifiziert; die Klassen-Entscheidung liegt beim Architect.

**Lerneintrag-Kandidaten** (Plan §5 nannte: *neuer Sensor* für die unbewachte Wächter-Nennung, *benannte Spec-Lücke* für Zeilen ohne LH):
- *Benannte Spec-Lücke* ist geliefert: 13 von 21 Festlegungs-Einheiten und 10 von 34 Tabellenzeilen ohne LH (§6.3 des Berichts) — `LH-FA-10` ist der einzige Träger.
- *Neuer Sensor / Regel:* zwei gemessene Blindheiten von Vollständigkeits-Kommandos: (a) Sammelzeile `T` verdeckt die Namens-Differenz (Reviewer F-2); (b) die Byte-Summe misst die Summe, nicht die Zuordnung (meine Mutation: Werte verschoben, Summe gleich, alles grün). Kein Sensor hält die Einzel-Bytes je Einheit; die Einzel-Schleife ist ein Verifier-Kommando, kein Gate. Verwandt: `vollstaendigkeits-zusage-misst-falsche-ebene` (verkörpert, drei Belege).

**Beobachtungs-Register** (Planner entscheidet Anlage; Kennungen zitieren, Zähler wird nicht gesetzt): Kandidat für einen neuen Eintrag — *Vollständigkeits-Kommando über Summe und Namensmenge prüft weder Einzelwert noch Zuordnung*; oder eine weitere Evidence-Datei bei `vollstaendigkeits-zusage-misst-falsche-ebene`. Beide passen in `BEO-ALL`. Zusätzlich gehört §8 des Plans (Treffer `stellen-messung-als-eigenschaft-ausgegeben` 6×, geplant): die „gemessen am …“-Zeilen der Spec sind mit 33 Messstellen der Gegenstand — bleibt Kontext für den Umbau, kein Zähler-Ereignis dieses Slice.

**An den Planner, Nicht-Risiko:** (i) Plan §3 nennt die Roadmap-Änderung nicht (Marker-Pflicht, Prozess-notwendig). (ii) Die Frage nach dem feineren Einheiten-Schnitt für die Umbau-Slices (Bericht §4 Punkt 7, F-1) liegt bei ihm. (iii) Z052 ist Fixture statt Kommentar (INFO, kein Nachzug nötig).

### An den Architect (aus Bericht §4, nicht von mir entschieden)

1. Klasse `d` (Abweichung): Aufnahme-Regel (Zeilen 20–23) weist die Abweichung ins Konventionsdokument, `MR-021` weist die sechs erklärten Abweichungen nach §5 — 12 Zeilen, 8245 Bytes.
2. Klasse `e` (Wächter-Zuordnung): 16 Zeilen, 10666 Bytes (23,2 %), von der Spec selbst als unbewacht bezeichnet (Zeilen 82–91).
3. Prozess-Konventionen (U09, U10, U13, U15) gegen die Klassen.
4. Messprotokoll mischt vier Aussagearten; 6405 Bytes in Prüfschritten innerhalb von Abweichungen 5 und 6.
5. Ort der Messprotokolle (`MR-021` nennt `docs/reviews/2026-08-02-span-schema-messreihen.md`).
6. Ebenen-Passung der LH-Bindungen (Zielrepo gegen dieses Repo).
7. Zwei Zeiger ohne Gegenstück (ADR-0028 Zeile 214, ADR-0021 Zeilen 72/652) — zwei Zeilen in eingefrorenen ADRs, die auf Spec-Stellen zeigen, die es nicht gibt; Korrektur nur per Folge-ADR.

**Von mir nicht geprüft (benannt):** ob die Klassen-Zuordnung je Einheit *richtig* ist (Urteil über Norm-Text, Architect); die 100 Zeiger-Zuordnungen wurden nicht alle, sondern in 15 Stichproben gelesen; die Nachbar-Nennungen des Lastenhefts in den Zeilen 448, 517, 555, 557 wurden nicht auf ihre Träger-Relevanz gelesen.

---

## 5. Verdikt

| DoD-Punkt | Verdikt |
|---|---|
| Liefer-Punkt 1 — Klassifikationstabelle | **bestätigt** (Grenze: Byte-Summe deckt Vollständigkeit, nicht Einzelwerte; Plan-Wortlaut „beide Kommandos“ gilt nur für Wächter-nennende Zeilen — beides vom Bericht bzw. hier benannt) |
| Liefer-Punkt 2 — Zeiger-Inventar | **bestätigt** (100/100; 15 Stichproben; Z052 Art-Mislabel INFO) |
| Liefer-Punkt 3 — LH-Vorschlag | **bestätigt** |
| `make gates` grün | **bestätigt** (Exit 0 auf `79f4ffde`; Lauf nach diesem Report im Handoff) |
| Review durchgeführt, Report liegt vor | **bestätigt**; F-1 bis F-5 eingearbeitet |
| Doku-Update entfällt | **bestätigt** (Diff leer) |
| Closure-Notiz · Register · Risiko-Ausgänge · Paarungen | **offen — Planner** |

Kein HIGH, kein MEDIUM. Der Slice ist aus Verifier-Sicht schließbar; die Schließung selbst schreibt der Planner.
