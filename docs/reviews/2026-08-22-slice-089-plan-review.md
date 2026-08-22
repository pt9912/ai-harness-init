# Review-Report: slice-089 (Plan, vor Code) — 2026-08-22

**Review-Art:** **Plan** — geprüft wird der Plan gegen Spec und Accepted-ADRs, *bevor*
implementiert wird (Modul 10 §Drei Review-Arten). Es gibt keinen Diff am Gegenstand des Slice;
der Diff, der vorliegt, ist der des Plans selbst.

**Gegenstand:** `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md` im Stand
`428c224` (Re-Schnitt, +227/−122; Baum sauber, `git status --porcelain` leer beim Start).
Anlass des Re-Schnitts: `ADR-0021` ist seit `1b540c8` **Accepted** und damit nach
[`AGENTS.md`](../../AGENTS.md) §3.4 immutabel; die alte Plan-Fassung plante das Gegenteil ihrer
Festlegung 5.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-22

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md`, dazu
  `git show 428c224` (Re-Schnitt-Commit samt Message)
- **aktive ADRs:** [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  (**Accepted** — Festlegung 5 und alle sieben Folgepflichten in §Konsequenzen vollständig
  gelesen), [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md),
  [`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md),
  [`ADR-0019`](../plan/adr/0019-agent-guard-prueft-die-aufrufform.md),
  [`ADR-0020`](../plan/adr/0020-emittierte-modul-15-regeln.md)
- **`LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **weitere Verträge:** [`CO-002`](../plan/carveouts/CO-002-token-achse-je-rolle.md) (der
  Gegenstand des Vollzugs), [`docs/plan/carveouts/README.md`](../plan/carveouts/README.md),
  [`spec/spezifikation.md`](../../spec/spezifikation.md) §5,
  `.claude/hooks/pretooluse-agent-guard.sh`,
  [welle-09](../plan/planning/welle-09-modul-15-konformitaet.md) §3,
  [`harness/conventions.md`](../../harness/conventions.md)
  [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §2 Source Precedence, §3.1 · §3.3 · §3.4 ·
  §3.6 · §3.7 · §3.8, §4
- Regelwerk `v3.5.2`: `modul-05-planning-harness.md` §Ziel-Form: Slice,
  `modul-07-carveouts.md`, `modul-08-agentenrollen.md`, `modul-10-review-harness.md`
- **vorherige Findings am gleichen Modul:** die vier `ADR-0021`-Runden
  (`docs/reviews/2026-08-22-adr-0021-*.md` — sie erklären, warum die ADR so lautet) und die
  slice-088-Runden mit den drei wiederkehrenden Klassen: *eine Zahl, die ihr Kommando nicht
  liefert* · *eine Zusage breiter als ihr Sensor* · *dieselbe Aussage an mehreren Fundorten*.
  Zwei dieser drei Klassen treten unten wieder auf.

## Selbst gefahren (nichts übernommen)

Alle Zahlen und Wächter-Zuordnungen dieses Reports sind in diesem Lauf selbst erhoben, über
`428c224`, Arbeitsbaum unberührt.

| Kommando | Ergebnis | Plan-Angabe | Urteil |
|---|---|---|---|
| `grep -n 'zu verschieben' docs/plan/carveouts/CO-002-token-achse-je-rolle.md` | 1 Zeile (`113`) | „heute genau **1** Zeile" | **stimmt** |
| `grep -n '^## Verifikation' <dieselbe Datei>` | 1 Zeile (`133`) | „genau **1** Zeile" | **stimmt** |
| `grep -n 'd-check:ignore' <dieselbe Datei>` | 1 Zeile (`142`) | „genau **1** Zeile" | **stimmt** (die *Begründung* daneben nicht — F-3) |
| `awk '/^## Verifikation/,/^## Geschichte/' <dieselbe Datei> \| grep -c '^- \[ \]'` | **5** | „heute **5**" | **stimmt** |
| `grep -c 'done/' <dieselbe Datei>` | **5** (Zeilen 26 · 97 · 113 · 142 · 150) | „heute **5** Zeilen, davon **drei** Verweise auf ein abgeschlossenes Planungs-Artefakt, die bleiben" | **stimmt** — 26/97/150 sind `planning/done/slice-086` |
| `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` | **6** Zeilen in **2** Dateien (spec `166,211,242,370,492`; Hook `14`) | „sechs Zeilen in zwei Dateien; **5** / **1**" | **stimmt** |
| `grep -ln 'responseKeys' test/mutations/*.sh` | leer, Exit 1 | „**leer (Exit 1)**" | **stimmt** |
| Gegenprobe dazu: `grep -n 'path: \[\]string' test/mutations/*.sh` | nur 123–126, und die **fügen** Einträge hinzu | „Die vorhandenen Fälle decken diese Richtung nicht" | **stimmt** — kein Fall entfernt einen Eintrag |
| `ls docs/plan/planning/done/ \| grep -c 'welle-09-results'` | **0** (`find . -name 'welle-09-results*'` → leer) | „**0**" | **stimmt** |
| `grep -n 'ADR-0' spec/spezifikation.md` | genau **1** Treffer, Zeile `723`, unter `## 7. Historie` (Überschrift Zeile `718`); `matrix.exclude-sections` führt `"7. Historie"` | „genau **einen** Treffer … in §7 Historie" | **stimmt** |
| `grep -n '^\*\*Status:' docs/plan/adr/0021-…md` | `3:**Status:** Accepted` | wörtlich so im Plan | **stimmt** |
| `ls docs/plan/planning/in-progress/` | nur `roadmap.md` | „außer der Roadmap keinen Slice" | **stimmt** |
| `grep -rn ']([^)]*open/slice-089-…\.md)' --include='*.md' docs` | **5** Zeilen in **2** Dateien, beide unter `done/` | „**5** Zeilen in **2** Dateien" | **stimmt** |
| `make docs-check` | `d-check: 341 Datei(en) geprüft, 0 Befund(e)`, Exit 0 | Plan nennt nur `0 Befund(e)` und kennzeichnet die Dateizahl als **kein** Erwartungswert | **stimmt**, [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2 eingehalten |
| **Mutation, Wegwerf-Kopie außerhalb des Repos:** die zwei Cache-Zähler aus `responseKeys()` gelöscht, `make test-go` | `--- FAIL: TestNoResponseFreetextReachesSpan` (`"cache_creation_input_tokens":33 fehlt`); **kein** weiterer Fehlschlag — `TestOnlyAgentToolGetsResponseValues` bleibt **grün** | DoD (3): „färbt `TestNoResponseFreetextReachesSpan` rot … **Nicht** `TestOnlyAgentToolGetsResponseValues`" | **stimmt — gemessen, nicht angenommen** |
| Quellen-Lesung dazu: Gegenprobe von `TestOnlyAgentToolGetsResponseValues` (`internal/span/response_test.go:181`) prüft `SpawnedRole`, `TotalTokens`, `InputTokens`, `ModelVersion` | **vier** der neun | „vier der neun Werte" | **stimmt** (die Zahl selbst steht ohne Kommando — F-4) |

Weitere Nachweise dieses Laufs: `.d-check.yml` führt `modules: [links, anchors, ids, matrix,
codepaths, spans]` — **kein** Modul liest einen Kopf-Status oder die Ergänzung eines Satzes
(Plan-Aussage bestätigt). `matrix.rules` verbietet nur `spec-straten → adr` und
`spec-straten → slice`; `docs/plan/carveouts/` ist **keine** Klasse, ein verlinktes `ADR-0021`
im Stub-Kopf ist also gate-sicher. Kein einziger Anker-Link zeigt in einen Abschnitt von
`CO-002` (`grep -rn 'CO-002-token-achse-je-rolle\.md#'` → leer): die Streichung des Abschnitts
`## Verifikation` bricht keinen Link. `harness/tools/mutate.sh` liest `test/mutations/*.sh`
automatisch ein; kein Test und kein Dokument verdrahtet eine Fallzahl — die Plan-Aussage
„Nummer beim Anlegen die nächste freie" trägt.

---

## Findings

### F-1 — Das Ziel in §1 reicht über das ganze Repo, die DoD über sechs Zeiger; zwei **lebende** Planungs-Artefakte führen die Schwelle weiter als offen und werden nirgends genannt

- `kategorie`: **MEDIUM**
- `quelle`: [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 1
  (*„kein Auflösungs-Trigger, kein Folge-Slice"*) · [`AGENTS.md`](../../AGENTS.md) §3.6
  (Zusage ohne Gegenbeispiel) · §2 Source Precedence Rang 5
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:39` (Ziel) gegen
  `docs/plan/planning/in-progress/roadmap.md:22-24` und
  `docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md:112-114,154-158,191-193,197-199`
- `befund`: §1 sagt zu: *„Keine Stelle im Repo führt die Messung noch als ausstehend."* DoD (2)
  deckt **sechs** Zeiger in zwei Dateien, DoD (1) den Stub und den Index — gemessen tragen
  **13** lebende Dateien eine `CO-002`-Nennung
  (`git ls-files | grep -v '^docs/reviews/' | grep -v '^docs/plan/planning/done/' | grep -v '^\.harness/baseline/' | xargs grep -ln 'CO-002'`),
  und zwei davon führen die Schwelle nach dem Vollzug weiter als offen: die **Roadmap**
  (Source Precedence Rang 5) schreibt *„die Rechnung liegt hinter dem Auflösungs-Trigger von
  CO-002"*, und **slice-071** in `open/` schreibt *„Fällt der Trigger von CO-002 positiv, wird
  die Rechnung geschnitten … Was ‚positiv' heißt, steht dort und nur dort (§Auflösungs-Trigger)"*
  sowie eine Rückführung *„falls CO-002 währenddessen **negativ** entschieden wird"*, deren
  Bedingung seit `1b540c8` bereits erfüllt ist. slice-071:197-199 verweist zusätzlich auf
  `CO-002` §Verifikations-Liste als den Ort, an den eine fehlende Zeile gehört — genau den
  Abschnitt, den DoD (1) **als Ganzes** streicht. Weder §3 (Berührte Dateien, die welle-09
  ausdrücklich als *unverändert* mit Begründung führt) noch §6 (*Nicht in diesem Slice*) nennen
  Roadmap oder slice-071.
- `verifizierbar`: **ja** — kein Gate: `make docs-check` bleibt grün, weil keine Adresse sich
  bewegt. Bestätigt wird der Befund durch die drei `grep`-Läufe oben; das Versagen tritt beim
  Eintritt von slice-071 auf, dessen `in-progress → open`-Bedingung vor dem ersten Handgriff
  wahr ist.

### F-2 — Die zwei vertagten Folgepflichten und die Reihenfolge, die sie schützt, haben in dem Artefakt, das sie vollziehen muss, keinen Träger; der Plan sagt „mit Träger statt bloßer Ablage"

- `kategorie`: **MEDIUM**
- `quelle`: [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  Folgepflicht 3 und 4 (*„er gehört dem Planner **angesagt**, nicht ihm überlassen"*) ·
  Regelwerk `v3.5.2` `modul-05-planning-harness.md`
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:220-225` und
  `:310-315` gegen `docs/plan/planning/welle-09-modul-15-konformitaet.md` (ganze Datei)
- `befund`: §3 benennt Ort (*„die Closure von welle-09"*), Träger (*„Planner-Arbeit am
  lebenden Wellen-Plan"*) und §6 die Reihenfolge (*„der Kopf des Stubs trägt den
  Verdikt-Status, bevor die Ergebnis-Notiz der Welle die Zellen setzt"*) — gemessen enthält
  `welle-09-modul-15-konformitaet.md` **keine** Nennung von `ADR-0021` und **keine** von
  `slice-089` (`grep -n '0021\|slice-089' …` → Exit 1), während ihr §3 weiter *„CO-001 **und**
  CO-002 geprüft"* als Closure-Kriterium führt und Zeile 133 *„ein Carveout endet nach Modul 7
  in beiden Ausgängen in `done/`"* behauptet. Nach dem Abschluss steht die Reihenfolge nur noch
  in `ADR-0021` und in dieser Plan-Datei unter `done/` — einem Zeitdokument. Das Scheitern ist
  genau das, was §6 selbst beschreibt: schließt welle-09 zuerst, liest ihr Audit *Aktiv* und
  schreibt zwei Matrix-Zellen als *deklariert*, gegen eine angenommene ADR.
- `verifizierbar`: **ja** — kein Gate; der Nachweis ist der `grep` über welle-09 (Exit 1) und
  die Liste der lebenden `ADR-0021`-Nennungen (drei Dateien: die ADR, der ADR-Index, dieser
  Plan).

### F-3 — Die Begründung des dritten Prüfkommandos in DoD (1) ist falsch: die `d-check:ignore`-Direktive steht **nicht** in der letzten Zeile des gestrichenen Abschnitts

- `kategorie`: **LOW**
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (die Aussage neben dem Kommando ist gefahren) ·
  [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 1
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:76-78` gegen
  `docs/plan/carveouts/CO-002-token-achse-je-rolle.md:133-143`
- `befund`: Der Plan schreibt *„`grep -n 'd-check:ignore'` → leer (Exit 1) als Gegenprobe, weil
  die Direktive in der letzten Zeile des gestrichenen Abschnitts steht"*. Gemessen läuft der
  Abschnitt von Zeile 133 bis 143; die Direktive steht auf **142**, dem **vierten von fünf**
  Haken, und die letzte Zeile ist 143. Die behauptete Schlussfolgerung trägt damit nicht: ein
  leeres `d-check:ignore` ist auch mit einem Zustand vereinbar, in dem allein Zeile 142
  gestrichen wurde und Überschrift plus vier Haken stehen bleiben — genau der Fall, den
  `ADR-0021` in einer Wegwerf-Kopie **gefahren** hat (*„der Abschnitt trägt noch vier Haken"*).
  Der Sensor-Satz als Ganzes bleibt tragfähig, weil `grep -n '^## Verifikation'` die
  Überschrift deckt; falsch ist die Begründung, die daneben steht.
- `verifizierbar`: **ja** — `awk 'NR>=133 && NR<=143' docs/plan/carveouts/CO-002-token-achse-je-rolle.md`
  zeigt die Position; kein Gate berührt.

### F-4 — „die neun Werte" und „vier der neun" tragen in DoD (3) kein Kommando und keine Lücken-Nennung, während die Nachbarzahlen in DoD (1) und (2) beides haben

- `kategorie`: **LOW**
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 (*„Liefert kein Kommando sie …, steht **das** dabei"*)
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:114,118-120`
- `befund`: DoD (3) trägt die Belegzahlen *„der Wächter, der die **neun** Werte hält"* und
  *„in seiner Gegenprobe **vier** der neun Werte — die zwei Cache-Zähler gehören nicht dazu"*.
  Beide sind tragend (aus ihnen folgt der Austausch des genannten Wächters), beide stehen ohne
  das Kommando oder die Lesung, die sie liefert, und ohne die von `MR-025` verlangte
  Kennzeichnung, dass keines sie liefert — im selben DoD-Punkt, in dem
  `grep -ln 'responseKeys' test/mutations/*.sh` neben einer anderen Aussage steht, und zwei
  DoD-Punkte neben `awk … | grep -c` bzw. `grep -c` je Datei. Der Inhalt ist korrekt (in diesem
  Lauf nachgelesen und mutiert), die Form ist die Klasse, wegen der `MR-025` geschrieben wurde
  und die dieser Plan nach dem Cutoff vollständig bindet.
- `verifizierbar`: **ja** — `sed -n '152,184p' internal/span/response_test.go` liefert die vier
  Werte; `make mutate` berührt es nicht.

### F-5 — Der Plan macht den „Spec-Eigentümer" zum Schreiber von Rang-2-Text und zum Adressaten einer Rückführung; die Rolle existiert im Repo nicht

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.8 (*„Wo eine Quelle die schreibende Rolle benennt,
  gilt sie unverändert; wo keine sie benennt, bleibt die Frage offen."*) · Regelwerk `v3.5.2`
  `modul-08-agentenrollen.md`
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:233` (Datei-Tabelle)
  und `:256-259` (Rückführung `in-progress → open`)
- `befund`: Die Datei-Tabelle weist `spec/spezifikation.md` an *„Spec-Eigentümer + Implementer"*
  zu, und §4 macht denselben Namen zum Ziel einer Rückführung (*„eine Frage an den
  Spec-Eigentümer, kein Nachzug"*). Gemessen kommt der Begriff im Repo außerhalb dieses Plans
  **nur** in `ADR-0021` Folgepflicht 2 vor; `.claude/agents/` führt sechs Rollen (architect,
  implementer, planner, reviewer, validator, verifier), `.harness/skills/` keine gleichnamige.
  Ein Implementer, der die Tabelle liest, hat für die Übergabe an Rang 2 keinen adressierbaren
  Empfänger und entscheidet die Rollen-Frage im eigenen Lauf — dieselbe Klasse, die derselbe
  Re-Schnitt an anderer Stelle als Rollen-Bruch entfernt hat.
- `verifizierbar`: **ja** — `grep -rn 'Spec-Eigentümer' AGENTS.md harness/ spec/ docs/plan/adr/ .harness/skills/`
  und `ls .claude/agents/`; kein Gate.

### F-6 — Von den drei „je für sich tragenden" Ausschluss-Gründen trägt der erste für Folgepflicht 4 nicht: das Audit hat heute einen Gegenstand

- `kategorie`: **LOW**
- `quelle`: [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  Folgepflicht 4 · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:202-208` gegen
  `docs/plan/planning/welle-09-modul-15-konformitaet.md:126-134`
- `befund`: §3 begründet den Ausschluss von Folgepflicht **3 und 4** mit *„drei Gründen, die je
  für sich tragen"*, und der erste lautet *„Die Zellen haben heute keinen Gegenstand"*
  (`ls docs/plan/planning/done/ | grep -c 'welle-09-results'` → 0, in diesem Lauf bestätigt).
  Für Folgepflicht 3 (die zwei Matrix-Zellen) trägt das. Folgepflicht 4 ist aber nicht die
  Zelle, sondern die **Audit-Regel**, und die hat heute einen Gegenstand: welle-09 §3 führt
  seit `open/` das Kriterium *„CO-001 **und** CO-002 geprüft"* und in Zeile 133 den Satz
  *„ein Carveout endet nach Modul 7 in beiden Ausgängen in `done/`"* — beide stehen jetzt in
  einem lebenden Artefakt. Die Gründe (b) und (c) tragen den Ausschluss weiterhin; die Zusage
  „je für sich" reicht weiter als das, was gemessen dasteht.
- `verifizierbar`: **ja** — `sed -n '126,134p' docs/plan/planning/welle-09-modul-15-konformitaet.md`;
  kein Gate.

### F-7 — Folgepflicht 6 ist weder getragen noch als ausgeschlossen genannt

- `kategorie`: **INFO**
- `quelle`: [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  Folgepflicht 6
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:17-19` und `:321-327`
- `befund`: §Bezug rechnet *„Von den sieben Folgepflichten trägt dieser Slice **drei** … die zwei
  weiteren Planner-Posten liegen ausdrücklich außerhalb"*; §6 nennt zusätzlich Folgepflicht 7
  (Adaptions-Block, *„Architect — nichts zu tun"*). Folgepflicht 6 (*die emittierte Ebene bleibt
  unberührt, und das ist eine Entscheidung*) kommt im Plan an keiner Stelle vor
  (`grep -n 'emittier' <plan>` → Exit 1), und die Datei-Tabelle führt `internal/emit/` weder als
  berührt noch — anders als `internal/span/` — als **unverändert mit Begründung**. Sie verlangt
  heute keine Arbeit; genannt ist sie trotzdem nicht.
- `verifizierbar`: **nein** — kein Gate-Lauf; Text-Abgleich gegen §Konsequenzen der ADR.

### F-8 — Der Stub verliert mit dem Abschnitt `## Verifikation (nach Auflösung)` eine Pflicht-Sektion der vendored Ziel-Form; das ist ADR-angeordnet und ohne Sensor

- `kategorie`: **INFO**
- `quelle`: `.harness/baseline/v3.5.2/templates/docs/plan/carveouts/carveout.template.md` ·
  [`AGENTS.md`](../../AGENTS.md) §3.8 · Regelwerk `v3.5.2` `modul-07-carveouts.md`
  §Werkzeug-Wahl (*„Checkliste reduziert auf die Architektur-Folgen"*)
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:66-68`
- `befund`: Das vendored Carveout-Template führt `## Verifikation (nach Auflösung)` als eigene
  Sektion; DoD (1) streicht sie **als Ganzes**. Die Anordnung stammt aus `ADR-0021` Festlegung 5
  und ist nach §3.4 bindend — der Plan folgt ihr korrekt. Unbenannt bleibt, dass das Ergebnis ein
  Carveout ist, dem eine Sektion der Ziel-Form fehlt: `.d-check.yml` führt kein Modul, das
  Carveout-Struktur prüft, und Folgepflicht 7 begründet den fehlenden Adaptions-Eintrag allein
  für die **Ablage**-Frage, nicht für die Sektion. Ein späterer Ziel-Form-Abgleich sieht eine
  Abweichung ohne Register-Eintrag.
- `verifizierbar`: **nein** — kein Gate; Träger wäre ein Architect-Lauf, nicht dieser Slice.

### F-9 — DoD (2) ist auch bei einer vollständig unveränderten Datei grün; der Plan nennt die Lücke, aber schwächer, als sie ist

- `kategorie`: **INFO**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 ·
  [`ADR-0021`](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 2
- `pfad`: `docs/plan/planning/open/slice-089-carveout-co-002-ueberfuehren.md:104-113`
- `befund`: Das Rot-Kommando von DoD (2) — *sechs Zeilen in zwei Dateien, verschwindet eine, ist
  eine Aussage entfernt* — misst allein die **Über**-Löschung. Es ist heute grün, es ist nach
  einem korrekten Nachzug grün, und es ist nach **null** Handgriffen grün; es sagt also nichts
  über den Gegenstand des DoD-Punkts („gezogen wird ihre Aussage"). Der Plan benennt das —
  *„Kein Kommando deckt, ob ein Satz seine Aussage wirklich nachgezogen hat: `grep` zählt
  Zeilen, keine Tempora"* —, und das ist die ehrliche Form aus §2 („wo keines existiert, steht
  **das** dabei"). Nicht gesagt ist, dass auch ein **gar nicht ausgeführter** DoD-Punkt das
  Kommando passiert; die Formulierung „keine Tempora" liest sich enger. Der zweite genannte
  Sensor (`make docs-check` gegen die zwei versperrten Formen) deckt die Verbots-, nicht die
  Gebots-Seite. Träger bleibt die Verifikation am Text (Modul 11) — im Plan benannt, hier nur
  präzisiert. **REFUTED wäre die schärfere Lesart**: eine verschwiegene Lücke liegt nicht vor.
- `verifizierbar`: **nein** — der Zustand „unverändert" ist der heutige und in der Tabelle oben
  bereits gemessen.

## Negativbefunde

- **geprüft, ohne Befund — die Kernfrage dieses Laufs: Plan gegen die immutable ADR.** Alle
  drei getragenen Folgepflichten stimmen mit `ADR-0021` überein, Angabe für Angabe.
  **Folgepflicht 1:** vier Änderungen am Stub (Status · `Letzte Prüfung` + Geschichte-Zeile ·
  Handlungs-Anweisung raus **und** Vorspann-Satz rein, Abschnitt bleibt · `## Verifikation`
  ganz raus mit allen fünf Haken), **eine** am Index (aus *Aktiv* in einen eigenen Abschnitt für
  den permanenten Übergang), **ein** Commit, **kein** `git mv`, kein `carveouts/done/` — deckt
  sich wörtlich mit §Konsequenzen. **Folgepflicht 2:** die sechs Zeiger behalten ihre Adresse,
  nachgezogen wird die Aussage; die fünf Spec-Stellen sind nach **Eigenschaft** benannt und
  identisch mit dem `Schärft`-Kopf der ADR (fünfter Punkt der Erfassungs-Liste · START-KONVENTION
  · Wächter-Absatz zu deren Bedingung 2 · Abweichung 1 · Abweichung 5); die zwei versperrten
  Formen (ADR-Link aus dem Spec-Stratum, bare Kennung) sind korrekt als versperrt geführt.
  **Folgepflicht 5:** der Mutations-Fall steht als **eigener** DoD-Punkt, wie die ADR es unter
  Verweis auf `ADR-0012` Folgepflicht 4 verlangt. **Der Plan plant nichts, was der ADR
  widerspricht** — der Defekt der Vorfassung ist behoben.
- **geprüft, ohne Befund — DoD (3), Wächter-Zuordnung.** Die Zuordnung ist in diesem Lauf in
  einer Wegwerf-Kopie außerhalb des Repos mutiert und gefahren (s. Tabelle): rot wird genau
  `TestNoResponseFreetextReachesSpan`, `TestOnlyAgentToolGetsResponseValues` bleibt grün. Die
  Eigenschaft ist so beschrieben, dass ein Implementer sie ohne Adresse bauen kann — Ort
  (`test/mutations/`), Handlung (einen Eintrag aus `responseKeys()` in
  `internal/span/response.go` entfernen), erwarteter Wächter, Abgrenzung gegen den falschen
  Wächter und die Nummern-Regel stehen da; der Treiber liest die Fälle per Glob ein, eine
  Registrierung ist nicht nötig.
- **geprüft, ohne Befund — die Kommandos in DoD (1).** Alle drei treffen heute genau eine Zeile
  und laufen nach dem Vollzug leer; das schmale Muster `'zu verschieben'` trifft die
  Handlungs-Anweisung und **nicht** die drei bleibenden `planning/done/`-Verweise, was der Plan
  in §6 korrekt beziffert. Der Abschnitt `## Auflösungs-Trigger` bleibt zu Recht stehen: die
  zwei verbatim-Zitate aus `ADR-0021` §Der zweite Ausgang war vorgesehen überleben die
  Streichung der Handlungs-Anweisung wörtlich (nachgelesen, Zeilen 114-118 der ADR gegen
  110-115 des Stubs).
- **geprüft, ohne Befund — Doku-Gate-Verträglichkeit des Vollzugs.** Kein Anker-Link zeigt in
  einen Abschnitt von `CO-002`; die vier Prosa-Verweise auf `CO-002 §…` (ADR-0019 zweimal,
  ADR-0021 einmal, slice-071 einmal) zielen auf Abschnitte, die stehen bleiben. `matrix` verbietet
  `carveouts → adr` nicht, der geplante Status mit verlinkter Kennung ist also
  `MR-001`-konform. `make docs-check` ist am geprüften Stand grün.
- **geprüft, ohne Befund — die benannten Lücken innerhalb der drei DoD-Punkte.** Vorspann-Satz,
  Kopf-Status und Index-Abschnitt sind ausdrücklich als kommandolos geführt, mit zutreffender
  Begründung (kein `.d-check.yml`-Modul liest Ergänzung oder Status — an der Modul-Liste
  nachgeprüft). Die Abwesenheit des Mutations-Falls ist als unmeldbar geführt. §5 nennt die
  Lücke des Vollzugs ein zweites Mal. Die Lückenführung *innerhalb* der DoD ist vollständig;
  unvollständig ist sie außerhalb (F-1, F-7).
- **geprüft, ohne Befund — Modul 5.** Drei slice-eigene DoD-Punkte plus die drei Vorlagen-Punkte
  — an der Schranke, nicht darüber; der Plan begründet die Schranke ausdrücklich. Berührt werden
  Doku und `test/mutations/`, keine Produktions-Datei (die zwei Go-Dateien stehen als
  *unverändert* mit Begründung in der Tabelle) — höchstens zwei Schichten. §1–§8 folgen dem
  vendored Slice-Template in Reihenfolge und Benennung, §7 ist leer.
- **geprüft, ohne Befund — Trigger und Lifecycle (§4/§5).** `open → next` ist erfüllt und mit dem
  Kommando belegt, dessen Ausgabe wörtlich stimmt; die WIP-Belegung ist ausdrücklich als beim
  Eintritt neu zu fahren gekennzeichnet, nicht als Erwartungswert. §5 verlangt den
  Link-Reconciliation-Commit nach **jedem** der drei Moves — die Lehre aus slice-086 §7 ist
  gezogen — und kennzeichnet die eingehende Menge als Bestandsaufnahme.
- **geprüft, ohne Befund — [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).**
  Alle drei Fragen aus Setzung 1 sind beantwortet und die Antworten tragen; Setzung 2/3 sind
  gezogen: `grep -n 'slice-089' docs/plan/planning/in-progress/roadmap.md` ist leer, es gibt
  keinen Roadmap-Eintrag.
- **geprüft, ohne Befund — [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  im Übrigen.** Jede der geprüften Zahlen in §2, §3, §5 und §6 steht neben dem Kommando, das
  genau sie liefert, und jedes dieser Kommandos liefert in diesem Lauf genau diesen Wert; die
  zwei wandernden Größen (Dateizahl des Doku-Gates, eingehende Link-Menge) sind ausdrücklich als
  **kein** Erwartungswert gekennzeichnet. Die einzige Ausnahme ist F-4.
- **geprüft, ohne Befund — Hard Rules.** §3.3 ist korrekt gelesen (die Zwei-Commit-Auflage greift
  bei Move **und** Rewrite; hier gibt es nur den Rewrite, also ein Commit — und sie greift
  weiterhin für die eigenen Lifecycle-Moves). §3.4 ist eingehalten: die ADR steht in der Tabelle
  als **unverändert**, §6 schließt jede Änderung an ihr aus, §4 auch die am Status. §3.6 trägt
  DoD (3). §3.7 ist für den Hook-Kommentar richtig zitiert (Indikativ über den Zustand). §3.8 ist
  nicht berührt — der Plan ordnet keinen Adaptions-Eintrag an und begründet das mit
  Folgepflicht 7.
- **geprüft, ohne Befund — [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).**
  Kein neuer Gate-Name, kein Gate über leerem Prüfbereich: der neue Fall läuft in `make mutate`,
  das ausdrücklich **nicht** in `make gates` hängt, und §6 sagt es ein zweites Mal. Die Zitierung
  von `LH-QA-01` für einen Dogfood-Sensor folgt der Praxis von `harness/tools/mutate.sh` und der
  ADR selbst — Ebene benannt, kein Dogfood/emittiert-Kurzschluss.
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ist nicht berührt: keine
  Pin-Bewegung, kein Image, kein Template.
- **geprüft, ohne Befund — Rollen-Zuschnitt im Übrigen.** Die Zuweisungen decken sich mit den
  Folgepflichten der ADR: Stub und Index → Implementer, Mutations-Fall → Implementer, ADR →
  unverändert, welle-09 → unverändert mit Begründung statt Planner-Zeile in einer
  Implementer-Tabelle. Der frühere Rollen-Bruch ist behoben; offen bleibt allein der Name aus
  F-5.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 2 |
| LOW | 4 |
| INFO | 3 |

## Verdikt

**Merge-blockierend: ja — für den Eintritt nach `next`/`in-progress`, nicht für den Inhalt der
drei DoD-Punkte.**

Die Kernfrage dieses Laufs ist **beantwortet und positiv**: der Plan bildet Folgepflicht 1, 2
und 5 von `ADR-0021` ab, Angabe für Angabe, und er plant an keiner Stelle etwas anderes als die
immutable ADR. Der Defekt, der den Re-Schnitt ausgelöst hat, ist behoben. Jedes Rot-Kommando ist
in diesem Lauf selbst gefahren und liefert den angegebenen Wert; die Wächter-Zuordnung in
DoD (3) ist mutiert und bestätigt. **Null HIGH.**

Zwei MEDIUM blockieren nach der Regel des Skills (*„HIGH und MEDIUM blockieren typischerweise"*),
und die Abweichung wird hier begründet statt still entschieden: beide betreffen **nicht** die
Ausführbarkeit der drei DoD-Punkte, sondern (F-1) eine Zusage in §1, die das ganze Repo verspricht,
während die DoD sechs Zeiger deckt und zwei lebende Planungs-Artefakte — darunter eines auf
Source-Precedence-Rang 5 — die entschiedene Schwelle weiter als offen führen, und (F-2) die
fehlende Trägerschaft der vertagten Folgepflichten in dem Artefakt, das sie vollziehen muss.
Beide sind **Plan-Korrekturen** und damit die billigste Stelle, an der sie zu haben sind
(Modul 10 §Drei Review-Arten); nach der Implementierung kosten sie einen zweiten Lauf an
`spec/`-fremden Artefakten oder eine falsch geschlossene Welle.

Die vier LOW und drei INFO blockieren nicht. F-3 und F-4 sind wieder die zwei Klassen aus den
slice-088-Runden (*eine Aussage/Zahl, die ihr Kommando nicht liefert*; *eine Zusage breiter als
ihr Sensor*) — dritte Wiederholung derselben Klassen in dieser Slice-Folge und damit nach
§Kontext-Eskalation des Skills ein **Steering-Loop-Signal**: `MR-025` ist geschrieben, aber sein
Träger ist bisher nur die Regel selbst.

**Übergabe:** Findings gehen an den **Planner** (Rückkante Review → Plan bei Plan-Defekt), nicht
an die Implementation — der Gegenstand ist der Plan. Der Report ersetzt keine Verifikation;
DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
