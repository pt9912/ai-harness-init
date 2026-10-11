# Welle welle-11: Träger-Aussage — das emittierte Repo sagt, welche mitgelieferte Regel keinen Träger hat

**Zielmeilenstein:** kein Meilenstein-Bezug (Konformitäts-Welle auf der emittierten Ebene, keine
Nutzer-Fähigkeit des Werkzeugs).

**Verantwortlich:** Planner. **Datum:** 2026-08-22.

---

## 1. Welle-Ziel

**Das gebootstrappte Repo sagt zu dem Regelwerk, das es vollständig mitgeliefert bekommt, welche
seiner Regeln dort einen Träger haben und welche nicht — als Text in bereits emittierten
Dokumenten, ohne ein neues Artefakt.**

Der Gegenstand ist die zweite Hälfte von
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren). Die erste ist erfüllt:
das Ziel trägt den vendored Baum netzlos und prüfsummen-verifiziert. Die zweite: ein Adopter liest
Regeln, deren Träger in seinem Repo nicht existiert, und nichts in seinem Repo sagt es ihm. Dieselbe
Lage ist der Gegenstand von [welle-09](welle-09-modul-15-konformitaet.md) für Modul 15.

**Mess-Verfahren.** Maßgeblich ist ein gebootstrapptes Ziel, nicht der Emit-Code: zwei Sonden-Repos,
mit dem Binär aus [`harness/tools/full-smoke.sh`](../../../harness/tools/full-smoke.sh)-Bauart
erzeugt (`make artifact DEST=<dir>`, dann `ai-harness-init --name Probe` bzw.
`ai-harness-init --lang go --name ProbeGo` in ein leeres `git init`-Verzeichnis) — die
**Varianten-Klammer**, ohne die wahr und falsch an der Ausgabe nicht zu unterscheiden sind
([`ADR-0007`](../adr/0007-bootstrap-phasen.md): `--lang` ist optional). Kommando neben der Aussage
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

**Zwei Befunde grenzen den Schnitt ab:**

1. **Der Reviewer-Skill kommt mit.** `ls .harness/skills/` im Sonden-Repo nennt `reviewer.md`
   **und** `closure-note-reviewer.md`; beide sind Singletons in
   [`internal/emit/templates.go`](../../../internal/emit/templates.go) (`inScope`, als Regel statt
   als Allowlist), und [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
   führt den Reviewer-Skill. Dasselbe gilt für jeden `### Ziel-Form`-Abschnitt des Regelwerks
   (`grep -rh '^### Ziel-Form' .harness/baseline/*/regelwerk/ | wc -l`): jede Vorlage liegt im
   `templates/`-Geschwisterbaum, den das Ziel vollständig bekommt. Ein Slice dafür hätte keinen
   Gegenstand.
2. **Die Mutations-Regel steht im Ziel nirgends.** *„Keine Zusage ohne rot gesehenes
   Gegenbeispiel"* ist [`AGENTS.md`](../../../AGENTS.md) §3.6 **dieses** Repos; die emittierte
   `AGENTS.md` stammt aus der vendored Vorlage und führt andere Hard Rules
   (`grep -n '^### 3\.' AGENTS.md` im Sonden-Repo), und im mitgelieferten Baum steht die Regel nicht
   (`grep -rniE 'rot gesehen|gegenbeispiel' .harness/baseline/` im Sonden-Repo). Ein Ziel, das die
   Regel nicht liest, vermisst ihren Träger nicht — `harness/tools/mutate.sh` und `test/mutations/`
   sind kein Slice dieser Welle (§6).

### Kontext: die Emissions-Frage ist entschieden

[`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) ist *Accepted*: der
Träger der Erfassungsschicht ist das laufende Produkt-Binär, kopiert in den gitignorierten
Zustands-Bereich des Ziels; Schreiber und Auswertung sind seine Unterkommandos, die Rollen-Typen
gehen generisch mit. Sie revidiert aus
[`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) die Festlegungen 1 und 2 sowie das
Erfassungs-Glied der Festlegung 3 — verwiesen, nicht abgeschrieben. Grundlage ist
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren). Für die Träger-
Tabelle dieser Welle heißt das: Erfassung, Token-Attribution/Cache-Counter und Rollen-Trennung
tragen den Wert *geht mit*; die Umsetzung ist Gegenstand von
[welle-12](done/welle-12-erfassungsschicht-emittieren.md), nicht dieser Welle (§6).

## 2. Trigger (Welle startet)

- **[welle-14](done/welle-14-re-baseline.md) liegt in `done/`** (eingetreten). Jede Messung dieser
  Welle läuft über den vendored Baum, den ein Baseline-Sprung tauscht; eine Aussage über den
  Freshness-Audit vor dem Tausch beschriebe eine Prozedur, die das Ziel danach nicht mehr liest.
- **[welle-09](welle-09-modul-15-konformitaet.md) ist keine Vorbedingung.** Die Abgrenzung bleibt:
  die `make`-Ansprüche der **lebenden** emittierten Doku-Tische gehören slice-087, die des
  **vendored Baums** dieser Welle (§4).

## 3. Closure-Trigger (Welle schließt)

**Das gemeinsame Kriterium:** *Für jeden Regelblock und jede Ziel-Form des mitgelieferten
Regelwerks sagt das emittierte Repo, ob ein Träger mitkommt — belegt im `full-smoke`.*

- **Alle Slices dieser Welle in `done/`.**
- **Vollständigkeit heißt Inventar gegen Abdeckung, nicht „die auffälligen".** Der **Nenner** ist
  die Datei-Zahl des mitgelieferten Regelwerk-Verzeichnisses, zur Laufzeit gelesen
  (`ls .harness/baseline/*/regelwerk/*.md | wc -l` im gebootstrappten Ziel), nicht abgeschrieben
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Je Regelblock genau ein Wert, und der Wert-Vorrat ist geschlossen:** *Träger kommt mit* ·
  *Träger liegt bei, ist nicht verdrahtet* · *kommt nicht mit — Grund und Dauer benannt*. Eine
  leere Zelle ist ein offener Closure-Trigger. Wo
  [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) oder
  [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) den Wert gesetzt
  hat, wird er verwiesen, nicht abgeschrieben.
- **Beide Richtungen im `full-smoke`, über beide Bootstrap-Varianten geklammert:** (a) die Aussage
  steht im frisch gebootstrappten Ziel out-of-the-box, sprachlos **und** mit `--lang go`; (b) ihre
  emit-seitige Rücknahme wird **rot gesehen**. Nur (a) wäre die
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle eine
  Ebene weiter ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **Kein neues Artefakt.** Der emittierte Datei-Satz wächst nicht — die Aussage landet in
  Dokumenten, die das Ziel ohnehin bekommt. Damit bleiben die Aufzählung aus
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) und das Budget
  aus [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) unberührt; ohne
  diese Schranke wäre die Welle ein Change Request
  ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
  Prüfbar an `TestTemplates_EmittierterBestandVollstaendig` in `internal/emit/templates_test.go`,
  **nicht** an `TestTemplates_Layout` (der prüft `os.Stat`-Listen und bleibt grün, wenn ein Pfad
  hinzukommt, der in keiner steht). Grenze: der Vergleich deckt die Kurs-Vorlagen-Schicht;
  `EnforcePaths` und `CommandPaths` prüfen Enthaltensein statt Vollständigkeit, eine geschlossene
  Liste des **gesamten** emittierten Datei-Satzes existiert nicht.
- **`make gates` grün** *und* `make full-smoke`; jeder neue Wächter hat seinen
  `test/mutations/`-Fall ([`AGENTS.md`](../../../AGENTS.md) §3.6). Ein Wächter, der **allein** an
  `make full-smoke` hängt, bekommt seinen Fall über den Modus in `failure_form`
  (`grep -c 'full-smoke' harness/tools/mutate.sh`, mitwandernd).
- **Carveout-Audit (Modul 7)** über `docs/plan/carveouts/` — gelesen wird der `Status:`-Kopf
  (`grep -n '^\*\*Status:' docs/plan/carveouts/CO-*.md`).
- **Closure-Notiz `welle-11-results.md`** mit Steering-Loop-Eintrag — entfällt bei Auflösung (§4).

## 4. Slices in dieser Welle

Der Zustand jedes Slice ist sein Lifecycle-Verzeichnis, hier nicht gespiegelt.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-090](done/slice-090-freshness-audit-im-ziel.md) | Das Ziel erfährt, dass sein vendored Baum altert — und warum kein Sensor mitkommt | [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |
| [slice-091](done/slice-091-vendored-baum-ohne-anspruch.md) | Der mitgelieferte Baum stellt keine `make`-Ansprüche an das Ziel, und eine lebende Zeile sagt es | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-092](done/slice-092-traeger-inventur.md) | Die Träger-Inventur: je Regelblock ein Wert, Inventar gegen Abdeckung | [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |

**Reihenfolge:** 090 und 091 setzen je einen Wert und hängen nicht aneinander (090 spricht über eine
Regel **ohne** Träger, 091 über einen **Anspruch ohne Gegenstand**); 092 schließt die Liste, weil
eine Inventur davor zwei Zellen als offen führte, die dann belegt sind. 090 und 091 sind zwei
Slices, weil sie zwei Fragen beantworten (geschuldete **Handlung** des Adopters gegen
**Falschaussage**, die beim `cp` einer Vorlage weiterwandert: `welle.template.md` nennt
`make fullbuild`, `NNNN-titel.template.md` nennt `make arch-check`, beide werden nach
[`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
absichtlich in lebende Pläne kopiert); zusammen wären es mehr Zusagen, als Modul 5 §Ziel-Form einem
Schnitt zugesteht.

### Die Welle ist aufgelöst — der Wellen-Test fällt negativ aus

Der Gegenstand der drei Slices ist in
[`slice-das-ziel-sagt-was-sein-vendored-baum-ist`](done/slice-das-ziel-sagt-was-sein-vendored-baum-ist.md)
aufgegangen; der Nehmer steht ohne Welle. Nach Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht liegt eine Welle nur vor, wenn der Closure-Trigger **mehr** beobachtet, als die
DoDs ihrer Slices belegen. Hier tut er es nicht: `make gates`, `make full-smoke` und die Inventur
gegen den Laufzeit-Nenner stehen in der DoD des Nehmers, und das Trigger-Audit über
`docs/plan/carveouts/` trägt im Repo ohne Wellen-Betrieb die Slice-Closure
(`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle); ein repo-weiter Verifikations-Beleg
über die Slice-DoD hinaus fehlt. Die Auflösung ist eine Umplanung und steht im Drift-Log der
Roadmap, nicht im Closure-Log.

**Der Vollzug des Ortswechsels ist gesperrt.** Der `git mv` dieser Datei nach `done/` machte
Pfad-Nennungen in eingefrorenen Artefakten tot, über beide Adress-Formen (Code-Span in
[`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), Markdown-Links in
`done/`); keines der `ignore-refs`-Ventile deckt sie. **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
git grep -c 'welle-11-traeger-aussage' -- 'docs/plan/adr/*.md' 'docs/plan/planning/done/*.md' \
  | awk -F: '{s+=$NF} END{print s+0}'
grep -c '^  - in: ' .d-check.yml
```

Nach [`AGENTS.md`](../../../AGENTS.md) §3.11 gehört die Entscheidung **vor** den Move, und ein
weiteres `ignore-refs`-Paar ist eine Senkung nach §3.5 mit eigener ADR — Architect-Arbeit. Bis
dahin bleibt die Datei flach, und *Offene Wellen* der Roadmap folgt ihr (der Abschnitt ist
derivativ). **Benannte Lücke:** wohin die Datei einer aufgelösten Welle gehört und ob eine
`welle-11-results.md` entsteht (hier: nein, nichts geliefert, nichts verkörpert), führt keine Quelle.

## 5. Abhängigkeiten

- **Wird blockiert von:** [welle-14](done/welle-14-re-baseline.md) (§2), und nur von ihr.
- **Blockiert:** keine geplante Welle.
- **Innerhalb der Welle:** {090, 091} → 092.
- **Benachbart, nicht abhängig:** slice-087 räumt dieselbe Fehlerklasse in den **lebenden**
  emittierten Doku-Tischen; wer beide gleichzeitig anfasst, erzeugt einen Konflikt in
  `internal/emit`.

## 6. Out-of-Scope für diese Welle

- **Die Emission der Modul-15-Erfassungsschicht** — Träger, Schreiber, Auswertung, Rollen-Typen,
  Feldlisten-Dokument. Sie ist durch [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  entschieden ([`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)),
  aber das Welle-Ziel bindet auf *„als Text in bereits emittierten Dokumenten, ohne ein neues
  Artefakt"* (§1) — Träger, Hook-Wrapper, Rollen-Fassung und Feldlisten-Dokument sind neue
  Artefakte und eine eigene Welle (welle-12). Die Träger-Tabelle trägt für die betroffenen Blöcke
  den Wert *geht mit*.
- **Die Aktivierung von `doc-targets` im Ziel** (Modul 15, Block 4): [welle-09](welle-09-modul-15-konformitaet.md),
  entschieden in [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegungen 4/5; diese
  Welle nimmt das Ergebnis als Zellwert entgegen und rührt die Konfiguration nicht an.
- **Die `make`-Ansprüche der lebenden emittierten Doku-Tische** (`AGENTS.md`, `harness/README.md`,
  `.harness/skills/closure-note-reviewer.md`): slice-087 in welle-09.
  [slice-091](done/slice-091-vendored-baum-ohne-anspruch.md) nimmt nur den **vendored** Baum; sein
  Sweep schließt genau diese drei Vorlagen aus (dort §1).
- **Eine Reparatur im vendored Baum.** Er ist byte-verifiziert (`make baseline-verify` gegen
  `SHA256SUMS`, hier wie im Ziel); wer den Anspruch dort heilte, färbte den Gate rot. Die Welle sagt
  **über** den Baum etwas, sie ändert ihn nicht ([`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md)
  Festlegung 4(e)).
- **`harness/tools/mutate.sh` + `test/mutations/`** — kein Gegenstand im Ziel (§1, Befund 2); ein
  Slice dafür schriebe eine Aussage über eine Abwesenheit, deren Gegenstück im Ziel nicht existiert
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse mit
  umgekehrtem Vorzeichen). Nimmt ein künftiger Kurs-Stand die Regel auf, gehört die Frage in den
  Adaptions-Durchgang des Baseline-Sprungs.
- **Zeitdokumente** unter `docs/reviews/**` und `docs/plan/planning/done/**`: sie halten den Stand
  ihres Laufs fest und werden nicht nachgezogen
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich).

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-11-results.md. -->
