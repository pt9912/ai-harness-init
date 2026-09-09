# Review — slice-129: Die Closure-Notiz-Pflicht bekommt ihren Sensor

**Rolle:** Reviewer (Modul 10, frischer Kontext) · **Datum:** 2026-09-09
· **Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) v1.7.0

## Eingangs-Kontext (die fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Wert |
|---|---|
| **Diff/Commit-Range** | `02937ed3..ccfb463a` sowie die zwei Vorläufer-Commits `c4c20ed2` (Ruhe-Marker) und `f783fedb` (Verweis-Nachzug). **Ausgenommen** `89db88a3` und `e201769d` (ADR-0033, anderer Vorgang im selben Checkout) — ihr Artefakt `docs/reviews/2026-09-09-adr-0033-konsistenz-review.md` ist nicht Gegenstand dieses Reviews. |
| **Slice-Plan** | [`docs/plan/planning/in-progress/slice-129-closure-notiz-hat-einen-sensor.md`](../plan/planning/in-progress/slice-129-closure-notiz-hat-einen-sensor.md) |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (in jeder Commit-Message genannt), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Aktive ADRs im Bezug** | keine ADR-ID in den Commit-Messages dieses Slice; berührt werden mittelbar [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)/[ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (Fall 221) und [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (`Proposed`, s. MEDIUM-1). Alle im Diff berührten Ventil-ADRs sind `Accepted`, keine superseded. |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1, §3.3, §3.5, §3.6, §3.7, §3.9, §3.10 |
| **Vorherige Findings am gleichen Modul** | [`2026-09-06-slice-125-planning-modul-review.md`](2026-09-06-slice-125-planning-modul-review.md) — F-1 (HIGH, Mutations-Deckung trifft den lauten Pfad), F-8 (INFO, Zusicherung über der leeren Menge wahr). Beide Klassen treten hier wieder auf; F-8 hat der Implementer selbst gefunden und im Fall `273` behandelt. |

**Nicht Gegenstand:** die DoD-Abhakung — Plan-/DoD-Konformität prüft die Verifikation.

## Prüfmittel und Sonden

Alle Messungen netzlos, gegen **Kopien außerhalb des Repos** (`git archive HEAD | tar -x`),
Mount `:ro`, mit dem in [`d-check.mk`](../../d-check.mk) gepinnten Digest
(`sha256:e31a372b…`, `v0.74.1`) bzw. dem in `Makefile` gepinnten `BATS_IMAGE`. Der Arbeitsbaum
wurde für keine Sonde angefasst (`git status --porcelain` vor und nach dem Lauf leer).

| Sonde | Kommando (gekürzt) | Ergebnis |
|---|---|---|
| Basis | `docker run … d-check@<digest>` | `1008 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 |
| Kontrolle §7 gekürzt | dieselbe Kopie, §7 von `done/slice-001a-cli-skeleton.md` auf einen Satz | `…/slice-001a-cli-skeleton.md:79 closure-note-thin`, EXIT 1 |
| `dir` entfernt | `sed -i '/^    dir: …done$/d'` | `1008 Datei(en) geprüft, 0 Befund(e)`, **EXIT 0** — still grün |
| `glob: '*.md'` | Weitung auf die Welle-Ebene | **20** Befunde: **12** `closure-note-missing`, **8** `closure-note-thin` |
| `placeholder: true` | Bedingung an | **1** `closure-note-placeholder`, `…/slice-087-…:353` |
| Unterverzeichnis | identische Sonden-Datei flach in `done/` **und** in `done/welle-99/` | flach: `closure-note-thin`; tief: **0** Treffer |
| Mutationen 285/286/287 | je isolierte Kopie, `bats test/closure-modul-wiring.bats` | jede färbt **ihre benannte** Zusicherung rot |
| Mutation 273 alt/neu | Vor-Fassung (`c230d961^`) gegen den neuen Baum | alt: `waves` bleibt **grün**; neu: 8 von 12 fallen, `waves` darunter |
| Mutation 221 | isolierte Kopie, `bats test/ignore-refs-restbreite.bats` | rot, `# expect:` fällt wörtlich (Treiber-Probe `grep -F`) |
| `boilerplate`/`dir`-Wert | eigene Sonden (kein Fall im Satz) | beide Zusicherungen fallen — Zähne vorhanden, Haltbarkeit unbewacht |
| `make comment-claims` | Gate | `57 Datei(en) geprueft, 0 Befund(e)` |
| Gate-Stempel | `.harness/state/gates-passed.diffsha` gegen `harness/tools/working-tree-hash.sh` | deckungsgleich (`00b1eb2b…`) |

**Keine Erwartungswerte** — alle Zahlen wandern mit dem Bestand
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

## Findings

### HIGH-1 — Der ausführende Lauf hat die eigenen Abnahmekriterien umgeschrieben und abgehakt

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10 (Hard Rule)
- `pfad`: `docs/plan/planning/in-progress/slice-129-closure-notiz-hat-einen-sensor.md:104,114,126` (Commit `3b6c81af`, „Rolle Implementer: slice-129 — DoD behauptet, Plan-Tabelle an die getroffene Entscheidung angepasst")
- `befund`: Der Implementations-Commit setzt alle drei DoD-Häkchen von `[ ]` auf `[x]` und ersetzt den Kriterien-Text durch einen Bericht der getroffenen Entscheidung; dabei verschwinden die **`**Rot:**`-Klauseln von DoD (2) und (3) ersatzlos** — darunter der einzige mechanische Falsifikator des Slice (*„Mechanisch rot wird der Punkt, wenn nach der Entscheidung ein **neues** Paket ohne Notiz nach `done/` wandert und der Lauf es **nicht** meldet"*) und der Beleg-Vergleich aus DoD (3) (`grep -c '^doc-' d-check.mk` → 11 gegen `grep -c 'doc-' Makefile` → 0). §3.10 bindet beide Hälften ausdrücklich an den Planner: *„Gebunden ist der ganze Abschluss: … **die DoD-Häkchen** …"* und *„die ausführende Rolle schreibt ihr eigenes Abnahmekriterium nicht um"*; eine solche Änderung ist dort ein **Übergabe-Artefakt**, kein Schritt des ausführenden Laufs. Der Verifier (Modul 11) liest damit eine DoD, die beschreibt, was geliefert wurde, statt zu benennen, woran es scheitern müsste — die Prüfung gegen sie wird tautologisch, und zwei Falsifikatoren stehen für keinen Folge-Lauf mehr zur Verfügung. Der Commit ist zwar sauber geschnitten (nur die Plan-Datei), nennt aber `Rolle Implementer` und ist damit an `git log --stat` genau als das ablesbar, was §3.10 ausschließt.
- `verifizierbar`: nein — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Commits, und `make mutate` kennt keine Fehlschlag-Form für einen Rollen-/Commit-Zuschnitt; §3.10 stellt diese Wächter-Lücke für sich selbst fest. Beobachtbar allein an `git show 3b6c81af`.
- `klasse`: fremdes Rollen-Artefakt im Implementations-Kontext (ausführende Rolle schreibt ihr eigenes Abnahmekriterium um) — Register: [`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md), Stand `verkörpert` (§3.10), Zähler heute 7

### HIGH-2 — Die tragende Begründung der Filter-Entscheidung zitiert eine aufgelöste Adaption

- `kategorie`: HIGH
- `quelle`: [`MR-016`](../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) (aufgelöst durch [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)); Maßstab: [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) *„jede Ventil-Zeile nennt, was sie ausnimmt und warum"*, den der Slice-Plan selbst als Auflage für DoD (2) führt
- `pfad`: `harness/README.md:109`
- `befund`: Der neue Absatz begründet den Ausschluss der Welle-Ebene aus dem Kandidaten-Filter mit *„Die Welle-Closure dieses Repos liegt auf zwei Dateien verteilt (dort als Markdown-Link auf `MR-016`)"*. `MR-016` liegt in [`harness/conventions/done/`](../../harness/conventions/done/) und trägt nach [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) nur noch Kopf und Zeiger — der Rumpf ist weg, und die Zwei-Datei-Aussage stand nie darin. Der ablösende Eintrag `MR-037` trägt sie ebenfalls nicht (`grep -ciE 'zwei[- ]datei|ergebnisnotiz|welle-plan.*zeiger' harness/conventions/MR-037-*.md` → **0**); das einzige lebende Artefakt, das die Form behauptet, ist dieser Absatz selbst (`git grep -lniE 'auf zwei Dateien verteilt' -- '*.md' ':!.harness/baseline' ':!docs/plan/planning/done' ':!docs/reviews'` → nur `harness/README.md`). Wer der Verweiskette folgt, landet bei einem Stub, von dort bei einem Eintrag über wellenlose Arbeit — und findet die Begründung des Gate-Ausschlusses nirgends. Kein Gate sieht das: der Anker `#mr-016--…` bleibt nach `MR-020` in der Index-Tabelle stehen, damit Verweise **nicht** brechen; `links`/`anchors` bleiben dauerhaft grün über einem toten Zitat. Dieselbe Stelle steht auch im Slice-Plan-Kopf (`Bezug:`) und in §8 — dort geerbt vom Plan-Datum 2026-08-28, drei Tage vor `MR-037`; neu geschrieben in einem lebenden Artefakt ist sie hier.
- `verifizierbar`: nein durch ein Gate — `make docs-check` bleibt über der Zeile grün (Anker existiert). Beobachtbar durch `ls harness/conventions/done/ | grep MR-016` und die Tabelle *Aufgelöste Adaptionen* in [`harness/conventions.md`](../../harness/conventions.md).
- `klasse`: retirierter Adaptions-Eintrag als lebende Begründung zitiert

### MEDIUM-1 — Der Prüfbereich des neuen Sensors greift flach; die vom Regelwerk vor der ersten Archivierung verlangte Geltungsbereichs-Prüfung fehlt

- `kategorie`: MEDIUM
- `quelle`: `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4 (*„Vor der ersten Archivierung ist der Geltungsbereich der vorhandenen Sensoren zu prüfen. Ein Sensor, der auf `done/*.md` keilt, sieht die archivierten Stubs im Unterverzeichnis nicht mehr und bleibt grün, ohne noch etwas zu prüfen. Wer archiviert, zieht den Geltungsbereich mit — **oder benennt, dass die Zusage für Stubs nicht mehr gilt**"*), Baseline `v6.5.0`; [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `harness/README.md:137` und `.d-check.yml:53-54`
- `befund`: Gemessen an einem Sonden-Paar: eine `slice-*.md` mit leerem §7 **flach** in `done/` meldet `closure-note-thin`; dieselbe Datei in `done/welle-99/` erzeugt **null** Treffer — der Kandidaten-Filter greift nicht rekursiv. Der Absatz sagt dagegen *„jeder `docs-check`-Lauf öffnet jetzt auch **jede** `slice-*.md` unter `done/`"*; die Grenze ist nirgends benannt, weder in [`.d-check.yml`](../../.d-check.yml) noch in [`harness/README.md`](../../harness/README.md) noch im Slice-Plan. `done/` trägt heute keine Unterverzeichnisse, die Zusage ist also **heute** wahr — sie wird mit dem ersten `make archive-welle` falsch, und genau dieses Werkzeug wird im selben Checkout gebaut ([ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md), Commits `89db88a3`/`e201769d`, `Proposed`). Der Fehlerfall ist der vom Regelwerk wörtlich beschriebene: nach der Archivierung liegen die Stubs — die per Ziel-Form **keinen** §7 mehr tragen — außerhalb des Prüfbereichs, und der Sensor bleibt grün, ohne noch etwas zu prüfen.
- `verifizierbar`: ja — `mkdir docs/plan/planning/done/welle-99` in einer Kopie außerhalb des Repos, eine `slice-*.md` mit leerem §7 hineinlegen, `docker run … d-check@<digest>`: 0 Befunde gegen den Treffer derselben Datei flach.
- `klasse`: Sensor-Prüfbereich deckt den Ort nicht, an den der Prozess seinen Gegenstand bewegt

### MEDIUM-2 — Die Begründung des Ausschlusses ordnet alle zwölf `missing`-Befunde der H1-Form zu; gemessen sind es acht

- `kategorie`: MEDIUM
- `quelle`: [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) (*„Kein Rückfall auf stilles Grün: jede Ventil-Zeile nennt, was sie ausnimmt und warum"*), [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `harness/README.md:111` und `:116`
- `befund`: Der Absatz begründet den engen Filter mit *„die Ergebnisnotiz selbst führt ihre Closure-Aussage als **H1**, nicht als die vom Modul erwartete H2/H3"* und schreibt die zwölf `closure-note-missing` geschlossen dieser Ursache zu (*„jede `welle-NN-results.md`, die H1-Form"*). Gemessen trägt die H1-Form nur **8** der 12 (`grep -lE '^# .*[Cc]losure' docs/plan/planning/done/welle-*results*.md | wc -l` → 8). Die übrigen vier — `welle-06`, `welle-07`, `welle-08`, `welle-12` — führen als H1 *„Results-Notiz"* und tragen in **keiner** Überschriften-Ebene das Wort `Closure` (`grep -cE '^#{1,6} .*[Cc]losure'` → 0); sie fielen auch als H2/H3 durch. Die vendored Ziel-Form setzt `# Welle <NN> — <Titel> — Closure-Notiz` (`.harness/baseline/v6.5.0/templates/docs/plan/planning/welle-results.template.md:1`), diese vier weichen also von ihr ab. Die Ausnahme deckt damit vier echte Ziel-Form-Abweichungen mit ab, ohne sie zu nennen — der Satz *„Beide Klassen entstehen aus derselben Zwei-Datei-Form, nicht aus fehlender Substanz"* trägt für ein Drittel der Menge nicht, und wer den Filter später weitet, rechnet mit einer Reparatur (H1 → H2), die vier Dateien nicht grün macht.
- `verifizierbar`: ja — die zwei `grep`-Kommandos oben über `docs/plan/planning/done/welle-*results*.md`; die Fundzahl 12 selbst ist mit `closure.glob: '*.md'` gegen eine Kopie außerhalb des Repos reproduziert.
- `klasse`: Zusammenfassung stärker als ihre Quelle — Register: [`BEO-ALL/zusammenfassung-staerker-als-ihre-quelle`](../plan/planning/observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md), Stand `offen`, Zähler heute 3

### LOW-1 — Der Kommentar von Fall 286 behauptet „jeden Welle-Plan", seine eigene Quelle sagt acht von zwölf

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist), §3.6
- `pfad`: `test/mutations/286-closure-glob-hinzugefuegt.sh:8`
- `befund`: *„`docs-check` selbst faerbt darauf **jeden** Welle-Plan und **jede** Welle-Ergebnisnotiz unter `done/` rot"*. Gemessen färbt die Weitung 12 von 12 Ergebnisnotizen, aber nur **8** von 12 Welle-Plänen (`closure-note-thin` auf `welle-01`, `-02`, `-05`, `-06`, `-07`, `-08`, `-10`, `-12`); vier Welle-Pläne bleiben grün. Der Kommentar verweist im selben Satz auf [`harness/README.md`](../../harness/README.md), das an dieser Stelle korrekt *„acht der zwölf Welle-Pläne"* sagt — Kommentar und zitierte Quelle widersprechen einander.
- `verifizierbar`: ja — `closure.glob: '*.md'` gegen eine Kopie außerhalb des Repos, `grep closure-note-thin | wc -l` → 8 gegen `ls docs/plan/planning/done/welle-*.md | grep -v results | wc -l` → 12.
- `klasse`: Zusammenfassung stärker als ihre Quelle (zweite Fundstelle desselben Vorgangs — zählt nach Modul 6 nicht zweimal)

### LOW-2 — Drei der sechs neuen Zusicherungen tragen keinen `test/mutations/`-Fall

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6; [`harness/README.md`](../../harness/README.md) (*„gelistet heißt: wer keinen Fall in `test/mutations/` hat, ist unbewacht"*)
- `pfad`: `test/closure-modul-wiring.bats:62,68,76`
- `befund`: `test/closure-modul-wiring.bats` bringt sechs Zusicherungen; die drei neuen Fälle 285/286/287 nennen in ihrer `# expect:`-Zeile drei davon. Ohne benannten Fall bleiben *„closure.dir zeigt auf docs/plan/planning/done"*, *„der konfigurierte closure.dir existiert als Verzeichnis"* und *„closure.boilerplate bleibt unbesetzt"*. Zähne haben alle drei — eigene Sonden (`dir: docs/plan/planning/nirgendwo` bzw. `boilerplate: [...]`) färben sie rot —, unbewacht ist ihre **Haltbarkeit**: `make mutate` würde ihren künftigen Zahnverlust nicht melden. Das trifft ausgerechnet die `boilerplate`-Zusicherung, die der Slice-Plan §6 als *„die Stelle, an der dieser Slice sich selbst rot färben kann"* führt.
- `verifizierbar`: ja — `grep -h '^# expect:' test/mutations/28[567]*.sh` gegen `grep -c '^@test' test/closure-modul-wiring.bats`; die Zähne selbst über die zwei Sonden oben.
- `klasse`: neuer Wächter ohne Mutations-Fall — Register: [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md), Stand `offen`, Zähler heute 1

### INFO-1 — Eine `Proposed`-ADR trägt in einer Commit-Message die Begründung einer Norm-Anwendung

- `kategorie`: INFO
- `quelle`: [ADR-0029](../plan/adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) (`Status: Proposed`)
- `pfad`: Commit-Message `838cc6d6`
- `befund`: Die Entfernung von `· seit slice-129` aus dem `.d-check.yml`-Kommentar wird mit *„laut ADR-0029"* begründet. ADR-0029 steht auf `Proposed` und ist damit nicht normativ; die Aussage, auf die es sich stützt, steht in seinem §Kontext und trägt selbst einen Zeiger auf die Baseline (`modul-06-roadmap.md` §Das Beobachtungs-Register). Die vorgenommene Änderung ist unabhängig davon richtig — der entfernte Anker begründete eine Design-Entscheidung, nicht eine aus dem Steering Loop verkörperte Regel, und [`AGENTS.md`](../../AGENTS.md) §3.7 deckt das ohne ADR-0029. Notiert bleibt der Rang des Zitats, nicht das Ergebnis.
- `verifizierbar`: nein — Commit-Messages liest kein Modul.
- `klasse`: Proposed-ADR als normative Quelle zitiert

### INFO-2 — Die Ziel-Beschreibung von `doc-planning` deckt jetzt weniger als das Ziel tut

- `kategorie`: INFO
- `quelle`: [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (`d-check.mk` ist tool-generiert)
- `pfad`: `d-check.mk:99`
- `befund`: `doc-planning` beschreibt sich als *„Planning-Lifecycle-Konsistenz (Roadmap <-> in-progress) via Modul planning"*. Seit dieser Änderung fährt derselbe Aufruf über dasselbe `.d-check.yml` auch die Closure-Struktur-Prüfung über `done/` mit; wer das Ziel für die Roadmap-Invariante aufruft, bekommt möglicherweise `closure-note-*`. Das Fragment ist tool-generiert und gehört ausdrücklich **nicht** in den Änderungsbereich dieses Slice — der Eintrag steht als benannte Beobachtung, nicht als Auftrag. `doc-planning` ist kein Gate und hat keinen Aufrufer.
- `verifizierbar`: nein — die Beschreibung ist ein Kommentar in einem generierten Fragment.
- `klasse`: tool-generierte Ziel-Beschreibung deckt weniger als das Ziel tut

### INFO-3 — Der Ruhe-Marker-Nachzug ist das siebte Auftreten einer Beobachtung, die bei 6 offen steht

- `kategorie`: INFO
- `quelle`: [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
- `pfad`: `docs/plan/planning/in-progress/roadmap.md` (Commit `c4c20ed2`)
- `befund`: Der `git mv` `next/ → in-progress/` machte den Ruhe-Marker *„Nichts in Arbeit."* falsch; `make docs-check` meldete `planning-drift`, der Implementer zog die Zeile nach. Der Nachzug ist formal in Ordnung — er setzt ein Zustandsfeld auf den Ist-Zustand, ohne Chronik ([`AGENTS.md`](../../AGENTS.md) §3.7) —, und kein Artefakt weist den Schritt einer anderen Rolle zu. Der Vorgang selbst ist das siebte belegte Auftreten der Klasse; das Register führt sie mit **6** Belegen weiterhin als `offen`, also seit vier Belegen über der 3×-Schwelle ohne zugewiesenen Ausgang.
- `verifizierbar`: nein — kein Sensor zählt das Register gegen die Schwelle (die `observations`-Fähigkeit des Moduls `planning` ist nicht aktiviert).
- `klasse`: Lifecycle-Move macht ein bewachtes Zustandsfeld falsch

## Negativbefunde (geprüft, ohne Befund)

- **Die Kernentscheidung ist vom Plan gedeckt.** DoD (3) formulierte sie in der Vor-Fassung ausdrücklich als offene Wahl zwischen eigenem `--config`-Profil und dem geteilten Durchsetzungspunkt, mit der Auflage *„Welcher der beiden gilt, ist aufzuschreiben — mit dem, was die gewählte Form **nicht** leistet"*; die §3-Tabelle hielt die Zeile offen (*„die Entscheidung **ist** DoD (3) und wird nicht vorweggenommen"*). Die getroffene Wahl und ihre Nicht-Leistung stehen in `harness/README.md`. **Keine Erweiterung über den Plan hinaus.**
- **DoD-(1)-Beleg reproduziert.** Basis-Lauf `0 Befund(e)`/EXIT 0 und die Kontrolle `…/slice-001a-cli-skeleton.md:79 closure-note-thin` sind wörtlich das, was `harness/README.md` als Ausgabe zitiert. Die Null ist eine gemessene Null, kein leerer Prüfbereich.
- **Die Zahl 20 und ihre Zusammensetzung stimmen.** 12 `closure-note-missing` + 8 `closure-note-thin`, jede Ergebnisnotiz genau einmal. Nur die *Ursachen-Zuschreibung* trägt nicht (MEDIUM-2); die Entscheidung, den Filter eng zu lassen, wird davon nicht berührt — keiner der 20 Befunde weist fehlende Substanz nach.
- **Die `placeholder`-Begründung trägt.** Genau **1** Fund, `docs/plan/planning/done/slice-087-…:353`; die Zeile trägt `` `<z.B. \`<make-target>\`>` `` — eine Vorlagen-Syntax in escapten Backticks, kein unausgefüllter Rumpf. Die Behauptung ist belegt, nicht nur plausibel.
- **Die drei neuen Mutationen treffen je ihre benannte Zusicherung.** 285 → Zusicherung 1 (zusätzlich 2 und 3, was der Treiber zulässt: er verlangt nur, dass die `# expect:`-Zeile in der Fehlschlag-Ausgabe steht), 286 → Zusicherung 4, 287 → Zusicherung 5. Jede über einer isolierten Kopie außerhalb des Repos gemessen.
- **Der `273`-Regressionsfund ist echt, der Fix sauber, der ursprüngliche Zweck erhalten.** Gegenprobe gefahren: die Fassung aus `c230d961^` lässt gegen den neuen Baum die `waves`-Zusicherung **grün** — genau die Vakuität, die der Fall abfangen soll (F-8 aus dem slice-125-Review). Die erweiterte Fassung lässt 8 von 12 Zusicherungen fallen, die erwartete darunter; `# expect:` ist unverändert und nennt weiter `waves`. Der Kommentar beziffert 8/12 und die vier vakuos grünen korrekt — nachgezählt.
- **Der `221`-Nachzug ist korrekt.** Die `# expect:`-Zeile deckt jetzt wörtlich `test/ignore-refs-restbreite.bats:240`; der enge Sensor über der isolierten Kopie wird rot, und die Treiber-Probe (`grep -E '^not ok' | grep -F -- "$expect"`) trifft. Der Fall ist eine von diesem Slice unabhängige Altlast aus slice-197 (Klasse `mutations-fall-ueberlebt-die-umbenennung-seines-waechters`, Register-Stand 1, `offen`); ihn mitzunehmen ist durch den Standard-DoD-Punkt *„`make mutate` ohne Befund"* gedeckt und kein Umfangs-Wachstum im Sinne von Modul 5.
- **Der Verweis-Nachzug in `slice-192` ist zulässig, keine Grenzüberschreitung.** `f783fedb` ändert eine **Adresse**, keine Aussage: `[slice-129](slice-129-….md)` → `[slice-129](../in-progress/slice-129-….md)`. Es ist die präfixlose Geschwister-Form, die `make slice-mv` als Grenze 3 selbst offenlässt, und Schritt 9 des Anweisungssatzes verlangt den Nachzug von Hand. Keine Norm-Aussage in einem fremden Rollen-Artefakt, keine Zustands-Änderung an `slice-192`.
- **Kommentare gegen §3.7.** Alle im Umfang neu geschriebenen Kommentare durchgesehen (`.d-check.yml`, `test/closure-modul-wiring.bats`, `test/mutations/273/285/286/287`). Nach `838cc6d6` trägt keiner eine Slice-Nummer als Begründung, keinen Konjunktiv über die verworfene Alternative und keinen abgebrochenen Satz. Der `.d-check.yml`-Block ist Abgrenzung im Indikativ, der bats-Kopf Kopplung. Der einzige Rest ist die Mengen-Überzeichnung in 286 (LOW-1), kein Klassen-Verstoß.
- **Kein Gate gelockert.** `modules:` ist unverändert (`links, anchors, ids, matrix, codepaths, spans, planning`); `closure` ist eine Fähigkeit **innerhalb** des schon aktiven Moduls. Die Änderung ist ein Gate-**Anheben** — [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) Steering-Loop, kein ADR nach [`AGENTS.md`](../../AGENTS.md) §3.5. Kein `ignore`/`ignore-refs`-Eintrag berührt.
- **Keine Folge-Drift in den Modul-Aufzählungen.** Weil `modules:` unverändert bleibt, sind der CI-Kopf (`.github/workflows/ci.yml:21`) und die `docs-check`-Zeile in [`AGENTS.md`](../../AGENTS.md) durch diesen Diff nicht falsch geworden — die dortige Verkürzung ist Altbestand (slice-125-Review F-3), nicht Gegenstand hier.
- **`done/` und `.harness/baseline/` sind unangetastet.** `git diff --name-only 02937ed3^ ccfb463a | grep -E '^(docs/plan/planning/done/|\.harness/baseline/)' | wc -l` → **0**. Das Rot entstand ausschließlich in Wegwerf-Kopien; die Plan-Zeile *„wird eine `done/`-Datei geändert, um den Gate grün zu bekommen, ist das ein Befund"* ist gehalten.
- **§3.3 gehalten.** Move und Inhalt liegen in getrennten Commits (`7aab219e`/`c5601c34` für den `slice-mv`, danach die Inhalts-Commits).
- **§3.9 gehalten.** Kein Host-Paketmanager und keine Host-Toolchain in einem Rezept; alle Läufe über `make`/gepinnte Images.
- **Keine superseded ADR referenziert.** Die im Diff mittelbar berührten Ventil-ADRs (0026, 0027, 0030, 0032, 0034, 0039) stehen alle auf `Accepted`.
- **Der Sensor-Mechanismus selbst ist fail-closed und nicht still.** Sonde: mit entferntem `dir` meldet d-check `1008 Datei(en) geprüft, 0 Befund(e)` bei EXIT 0 — genau die stille Rückfall-Form, die der Kommentar von Fall 285 behauptet, und genau der Grund, aus dem die Aktivierungs-Zusicherung existiert. Behauptung belegt.
- **Gate-Stempel und Arbeitsbaum decken sich.** `.harness/state/gates-passed.diffsha` == `harness/tools/working-tree-hash.sh` (`00b1eb2b…`); `make comment-claims` `57/0` selbst gefahren.

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 2 |
| LOW | 2 |
| INFO | 3 |

**Wiederkehrende Klassen dieses Laufs** (Modul 5 §Closure-Regeln, dritte Speisungs-Quelle):
*fremdes Rollen-Artefakt im Implementations-Kontext* · *Zusammenfassung stärker als ihre Quelle*
(zwei Fundstellen, **ein** Vorgang) · *neuer Wächter ohne Mutations-Fall* · *Lifecycle-Move macht
ein bewachtes Zustandsfeld falsch* · neu: *retirierter Adaptions-Eintrag als lebende Begründung
zitiert* · neu: *Sensor-Prüfbereich deckt den Ort nicht, an den der Prozess seinen Gegenstand
bewegt*.

## Verdikt

**Merge-blockierend: ja** — zwei HIGH und zwei MEDIUM.

Die **Substanz des Slice trägt**: der Sensor ist verdrahtet, seine Null ist gemessen und nicht
leer, sein Rot ist reproduzierbar, die drei neuen Mutationen treffen ihre Zusicherungen, und der
selbst gefundene `273`-Regressionsfund ist echt und sauber behoben — in beiden Richtungen
nachgemessen. Beide HIGH liegen **neben** der Fähigkeit, nicht in ihr:

- **HIGH-1** ist eine Rollen-Grenze, keine technische. Er folgt dem Konflikt-Pfad aus Modul 8 nur
  dann, wenn ihm widersprochen wird; unwidersprochen ist er eine Übergabe an den Planner, die
  vor der Verifikation liegt — der Verifier prüft sonst gegen ein Kriterium, das der geprüfte
  Lauf selbst geschrieben hat.
- **HIGH-2** ist ein totes Zitat an der tragenden Stelle einer Gate-Entscheidung, das kein Gate
  je sehen wird, weil der Anker nach [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  mit Absicht stehenbleibt.

**MEDIUM-1** ist der Befund mit der längsten Reichweite: das Regelwerk verlangt die
Geltungsbereichs-Prüfung ausdrücklich **vor** der ersten Archivierung, und die Archivierung wird
im selben Checkout gebaut. **MEDIUM-2** berührt die Entscheidung nicht, wohl aber ihre Begründung.

Die beiden LOW und die drei INFO blockieren nicht.
