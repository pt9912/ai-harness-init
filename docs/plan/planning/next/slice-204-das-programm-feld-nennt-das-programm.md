# Slice slice-204: Das Feld `program` nennt das Programm, nicht das Navigations-Segment davor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice ändert **eine** Funktion und zwei Spec-Zeilen; sein Beleg sind
rot gesehene Gegenbeispiele, zwei Mutations-Fälle und ein grüner Gate-Lauf, und sie stehen in seiner eigenen DoD. Ein
Closure-Trigger darüber schriebe sie ab (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht).

**Ebene: Produkt-Code — Dogfood *und* emittiert, ohne Vorlagen-Änderung.** `internal/span/` ist
Teil des Produkt-Binärs. Ein emittiertes Repo bekommt **keine** Kopie dieses Codes, sondern einen
Hook-Wrapper, der denselben Träger ruft
(`internal/emit/templates/enforce/span-emit.sh` → `"$carrier" span-emit`,
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5).
Die Änderung erreicht damit jedes emittierte Repo über den Träger; **keine Vorlage wird
angefasst**. Das ist die Aussage, nicht ein Offenlassen.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die
Erfassungsschicht, deren Feld hier repariert wird),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jede Zahl dieses Plans
steht neben dem Kommando, das sie ausgibt),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (die Erfassungs-Policy: was in den
Span darf und was nie — die fail-closed-Linie unten ist ihre Anwendung),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (der Träger, über
den die Änderung beide Ebenen erreicht),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(das Technik-Stratum ist Rang 2 und **ohne Vertragsänderung fortschreibbar** — die zwei
Spec-Zeilen sind darum kein Lastenheft-Thema),
[slice-program-feld-nennt-weder-operator-noch-wertfragment](../in-progress/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
(**Voraussetzung**: führt den Begriff *Segment ohne Programm* für Zuweisungen und die Wert-Grenze
ein, auf denen dieser Slice aufbaut — §1, §4)

**Berührte Spec-Stellen:** [`SPEC-021`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
(`argc`: die Bedeutung wird segment-begrenzt; `program` bleibt wahr) und `SPEC-031` (die
`Bash`-Zeile der Werkzeug-Tabelle, in der Fassung, die der erste Slice schreibt: sie nennt dann
übersprungene Zuweisungs-Segmente und wird um die Navigations-Segmente ergänzt). Beide Zeilen
beschreiben die Mechanik wörtlich und werden mit ihr falsch — sie wandern mit.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-08.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `commandProgram()` in `internal/span/span.go` überspringt **führende
Navigations-Segmente** (`cd`, `set`), die durch `&&` oder `;` abgetrennt sind, und nimmt das erste
Token des nächsten Segments; `argc` zählt die Argumente **dieses** Segments. `SPEC-021` verspricht
mit `program` die Antwort auf *„Welches Programm lief?"*; der Wert antwortet in **38 %** der
`Bash`-Spans mit einem Shell-Konstrukt statt mit einem Programm.

**Aufbau auf dem ersten Slice — was er liefert und was hier bleibt.**
[slice-program-feld-nennt-weder-operator-noch-wertfragment](../in-progress/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
ist **Voraussetzung** (Weg A: er wird zuerst umgesetzt). Er liefert: Zuweisungen bilden ein
**Segment ohne Programm**, ein Operator als eigenes Feld beendet es, ein Wert mit nicht bestimmbarem
Rand lässt `program` **ganz** entfallen (fail-closed), und `SPEC-031` nennt das. Dieser Slice
**baut auf demselben Begriff** und liefert nur, was bleibt:

| Gegenstand | erster Slice | dieser Slice |
|---|---|---|
| Zuweisungs-Segment überspringen, Operator beendet es | liefert | — (nimmt es als gegeben) |
| Wert-Grenze (`A="x y" cmd` → nichts), Schutz des Werts | liefert | — (nur ein Kompositions-Fall, s. u.) |
| **Navigations-Segmente `cd`/`set` überspringen** | — | **liefert** |
| `argc` segment-begrenzt (heute: bis Zeilenende) | lässt es | **liefert** |
| `SPEC-031` | schreibt Zuweisungs-Segmente | ergänzt Navigation |
| `SPEC-021` | gegengelesen, bleibt wahr | `argc`-Bedeutung |

Der Begriff *Segment ohne Programm* ist die Klammer: ein Navigations-Segment ist ein Segment, das
ein Kommando **vorbereitet** und darum übersprungen wird, wie eine Zuweisung. **Der Unterschied ist
eine Setzung, keine Selbstverständlichkeit:** Ein Navigations-Segment **ist** ein Programm (`cd`
läuft), eine Zuweisung ist keines. Folgt kein weiteres Segment (`cd /x` allein, `cd /x &&`), bleibt
das Navigations-Segment das Programm (`cd`) — die Zuweisung dagegen liefert dann **nichts**.
Folgt `||` (`cd /x || exit 1`), läuft das nächste Segment nur bei Fehlschlag: `program` ist dann
`cd`, nicht das Segment dahinter — anders als bei der Zuweisung, die nicht fehlschlagen kann.

Gemessen am Bestand unter `.harness/state/spans/` (**keine Erwartungswerte** — der Bestand ist
gitignored, maschinenlokal und seit dem 2026-09-08 auf drei Tage beschnitten; die Probe gehört
gefahren, nicht zitiert,
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5):

```sh
cd .harness/state/spans
T=$(cat *.jsonl | grep -c '"tool":"Bash"')
K=$(cat *.jsonl | grep '"tool":"Bash"' | grep -coE '"program":"(cd|set|until|while|for|if)"')
echo "$T Bash-Spans, $K Konstrukt, $(( K * 100 / T ))%"   # 7007 Bash-Spans, 2704 Konstrukt, 38%
cat *.jsonl | grep '"tool":"Bash"' | grep -oE '"program":"[^"]*"' | cut -d'"' -f4 \
  | sort | uniq -c | sort -rn | head -5                    # cd 2398, grep 814, git 800, sed 449, make 441
```

`cd` allein steht damit häufiger als `git`, `make` und `grep` **zusammen**. Die Erweiterung ist
dieselbe Mechanik eine Ebene höher: Die Funktion überspringt bereits etwas (führende
`NAME=WERT`-Präfixe), nur innerhalb **eines** Segments.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Zuweisungs-, Operator- und Wert-Grenze.** Sie gehört
  [slice-program-feld-nennt-weder-operator-noch-wertfragment](../in-progress/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
  und ist dort Liefer-Punkt 1 — **ein Vorgänger-Slice, der den Gegenstand führt**: wer sie hier noch
  einmal baute, hätte zwei Pläne über denselben Gegenstand, und der zweite wäre ein Konflikt in
  derselben Funktion. Dieser Slice nimmt sie als gegeben; sein Start hängt daran (§4).
- **Kein Griff in einen Schleifen- oder Bedingungs-Körper** (`for`, `while`, `until`, `if`). Das
  ist eine **andere Frage**: Ein Navigations-Segment steht *vor* dem Kommando und lässt sich
  überspringen; ein Schleifen-Körper *enthält* mehrere, und welches davon „das Programm" ist, ist
  keine Übersprung-Regel, sondern eine Auswahl. Der Rest ist beziffert und bleibt sichtbar:
  `cd`+`set` decken **2539** der **2709** Konstrukt-Fälle, es bleiben **170**
  (`cat *.jsonl | grep '"tool":"Bash"' | grep -coE '"program":"(cd|set)"'` gegen dieselbe Zeile
  mit der vollen Konstrukt-Liste; keine Erwartungswerte).
- **Keine Vorlage unter `internal/emit/templates/`.** Die Änderung erreicht ein emittiertes Repo
  über den **Träger**, nicht über eine Kopie — **Schicht-Abgrenzung**, und beim Review sofort
  prüfbar: berührt der Diff `internal/emit/`, ist der Slice aus seiner Schicht gelaufen.
- **Keine Nachbesserung des vorhandenen Bestands.** Alte Spans behalten ihren Wert; der Bestand
  ist append-only und maschinenlokal — **Bestand bleibt bewusst stehen**. Die Folge gehört
  benannt, nicht repariert (§6).
- **Keine Entscheidung über das Rollen-Eigentum an den Spec-Straten.** Wer
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md) schreiben darf, benennt **keine**
  Quelle — [`AGENTS.md`](../../../../AGENTS.md) §3.8 weist nur Hard Rules und Adaptions-Block dem
  Architect zu und sagt ausdrücklich: *„wo keine Quelle sie benennt, bleibt die Frage offen"*. Die
  Frage hat bereits eine Adresse, und **das ist ein Folge-Slice, der die Sendung annimmt**:
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md) liefert genau diese ADR. Wie
  dieser Slice sich in der Zwischenzeit verhält, steht in §2 — er entscheidet die Frage nicht
  still mit.
- **Keine Änderung an `span-report`, `span-watch` oder `hook-overhead`.** Sie lesen das Feld;
  dieser Slice schreibt es — **anderer Vorgang**.

### Nachbarschaft: ein zweiter Slice schreibt an §5

`slice-109-feldliste-jede-aussage-hat-ihre-quelle` schreibt ebenfalls an
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 — an
den Aussagen der Feldliste, nicht an `SPEC-021`/`SPEC-031`. Die zwei sind inhaltlich unabhängig
und voneinander nicht blockiert; **gleichzeitig** angefasst erzeugen sie einen Konflikt in
derselben Sektion. Wer den zweiten beginnt, während der erste läuft, löst ihn im Text statt in der
Planung.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Liefer-Punkt 1 — `commandProgram()` überspringt führende Navigations-Segmente.** Aufbauend auf
dem Zuweisungs-Segment des ersten Slice; Fälle und Mutations-Fall sind die Form derselben
Lieferung, nicht zusätzlicher Umfang.

- [ ] **Vier Gegenbeispiele, je einmal rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6),
      jedes über `span.Derive` **und** über den serialisierten Span (`span.Build` bis zur Zeile in
      `internal/span/emit.go`):
  - [ ] `cd /x && make gates` → `make` (ohne diesen Slice: `cd`) · `set -e; make gates` → `make`.
  - [ ] `cd /x && TOKEN=abc gh pr create` → `gh`, und **weder `TOKEN` noch `abc` stehen in der
        geschriebenen Zeile**. Das ist das **wichtigste** Kriterium: Die Verbesserung darf das Loch
        nicht öffnen, das der Kommentar über der Funktion nennt (`GITHUB_TOKEN=ghp_… gh pr create`
        landete sonst verbatim als `program`). Der Schutz selbst ist die Wert-Grenze des ersten
        Slice; dieser Fall belegt, dass sie **hinter einem übersprungenen Navigations-Segment**
        gilt — die Komposition, nicht die Prüfung.
  - [ ] `cd /x && TOKEN="abc def" gh pr create` → **nichts** (Wert-Rand nicht bestimmbar, wie
        beim ersten Slice, jetzt nach einem Navigations-Segment).
  - [ ] Die Ränder des Übersprungs: `cd /x` allein und `cd /x &&` → `cd` · `cd /x || exit 1` →
        `cd` · `cd a && cd b && make` → `make` (§1: das Navigations-Segment bleibt das Programm,
        wenn nichts folgt oder das Folge-Segment nur bei Fehlschlag läuft).
  - `TestCommandProgramSkipsAssignments` und die Tests des ersten Slice bleiben **grün und
    unverändert** — die bestehende Zusage wird nicht umgeschrieben, um die neue zu ermöglichen.
- [ ] Ein Fall in `test/mutations/` nimmt der **Navigations-Grenze** die Zähne (Mutation: `cd`/`set`
      werden nicht übersprungen). Er trifft die Segment-Grenze, nicht nur den Happy Path; sein
      `sed`-Muster ist **nach** der Implementierung gegen den Quell-Bestand gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
      Ohne ihn ist die Zusage unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

**Liefer-Punkt 2 — `argc` zählt die Argumente des gewählten Segments.**

- [ ] `argc` ist gesetzt, nicht mitgeschleift: Felder **nach dem Programm bis zum Ende seines
      Segments** (Operator-Feld oder ein Feld, das auf `;` endet) statt bis Zeilenende. Für
      `cd /x && make gates` ist `argc` 1 (`gates`), nicht 4 — und für `make gates && echo x` ist
      es 1, nicht 3: **die Bedeutung ändert sich für jede Zeile mit Operator**, nicht nur für
      Navigations-Zeilen. Jeder dieser Fälle ist ein Test mit rot gesehener Mutation (Segment-Ende
      wird nicht gesucht → `argc` läuft bis Zeilenende).
- [ ] Ein Fall in `test/mutations/` bindet die `argc`-Grenze; sein Wächter ist der Test dieses
      Liefer-Punkts, nicht der aus Liefer-Punkt 1 — ein Fall, der bei geschwächter Zusicherung noch
      rot wird, deckt einen anderen Zweig, und die Gegenprobe steht in der Closure-Notiz.

**Liefer-Punkt 3 — die Spec nennt die neue Mechanik, und die Eigentumsfrage ist benannt.**

- [ ] `SPEC-021` (`argc`: segment-begrenzt) und `SPEC-031` (die `Bash`-Zeile: Navigations-Segmente
      zusätzlich zu den Zuweisungs-Segmenten des ersten Slice) in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
      §5 sind nachgezogen. Das Technik-Stratum ist ohne Vertragsänderung fortschreibbar
      ([`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence));
      das Lastenheft wird **nicht** angefasst.
- [ ] **Die offene Eigentumsfrage ist benannt, nicht entschieden.** Der Lauf, der die Spec-Zeilen
      schreibt, hält in §7 fest, dass für dieses Stratum **keine Quelle** eine schreibende Rolle
      benennt, und nennt [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md)
      als deren Adresse. Er leitet daraus **keine** Zuständigkeit ab — eine aus Zweckmäßigkeit
      abgeleitete Rolle wäre genau der Befund, den slice-151 auflösen soll.

**Pro Slice konstant — zählt nicht in den einen:**

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register ([`../observations/`](../observations/)) fortgeschrieben — **kein
      Zähler wird gesetzt**, er folgt aus den Dateien.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice läuft
      **ohne Welle**, sie werden also hier geprüft, nach dem `git mv`.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/span/span.go` | update | `commandProgram()` in der Fassung des ersten Slice — Navigations-Segmente als weiteres Segment ohne Programm, `argc` bis Segment-Ende; der Kommentar über der Funktion nimmt beide Zusagen und ihre Wächter mit |
| `internal/span/span_test.go` | update | die Fälle aus Liefer-Punkt 1 und 2; `TestCommandProgramSkipsAssignments` und die Tests des ersten Slice unverändert daneben |
| `test/mutations/<N>-span-program-*.sh` | neu (zwei) | nehmen der Navigations-Grenze und der `argc`-Grenze die Zähne |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 | update | `SPEC-021` (`argc`) und `SPEC-031` (`Bash`-Zeile) |

**Zwei Schichten:** Produkt-Code (`internal/span/` samt seinen Fällen) und Spec-Stratum 2. Kein
`cmd/`, kein `Makefile`, kein `internal/emit/`.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert, `Verantwortlich:` ist gesetzt, das
WIP-Limit des Rolleninhabers ist frei — **und
[slice-program-feld-nennt-weder-operator-noch-wertfragment](../in-progress/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
liegt in `done/`.** Beobachtbar (ein anderer Mensch liest es an der Verzeichnis-Position) und kein
Ergebnis dieses Slice. Der Grund ist die Reihenfolge, nicht Vorsicht: beide ändern
`commandProgram()`, denselben Test und `SPEC-031`; dieser baut auf dem Begriff *Segment ohne
Programm* und der Wert-Grenze des ersten und gleicht `argc` danach an — gleichzeitig angefasst wäre
es ein Konflikt in derselben Funktion.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Segment-Trennung lässt sich nicht
  textuell ziehen, ohne `&&`/`;` innerhalb von Anführungszeichen oder Klammer-Ausdrücken falsch zu
  treffen, und eine tragfähige Fassung verlangt eine Zerlegung der Zeile statt einer
  Übersprung-Regel. Dann ist es ein anderer Slice als dieser.
- `in-progress` → `open` (blockiert — Carveout?): Die zwei Spec-Zeilen lassen sich ohne eine
  Entscheidung über das Rollen-Eigentum nicht schreiben — dann wartet der Slice auf
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md), und **das** ist der Blocker,
  nicht der Code. Ebenso, wenn der erste Slice den Begriff *Segment ohne Programm* oder die
  Wert-Grenze nicht so liefert, wie §1 sie voraussetzt — dann ist die Aufteilung neu zu schneiden,
  nicht im Lauf umzudeuten.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(1)** Die Gegenbeispiele aus Liefer-Punkt 1 und 2 sind je einmal
rot gesehen, die zwei Mutations-Fälle liegen in `test/mutations/`, `make mutate` meldet
`0 Befund(e)` und `make gates` ist grün. **(2)** Ein Lauf über einem frischen Strom zeigt für ein
`cd … && <programm>`-Kommando das **Programm** im Feld `program` und für ein
`cd … && make gates` die `argc` 1 — gemessen an der geschriebenen Zeile, nicht behauptet.
Dazu der Lerneintrag in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke).

**Kein Konsument wartet auf diesen Wert.** Eine Live-Sicht über demselben Strom ist in diesem
Repo nicht geschnitten; der Wert trägt für jeden Leser des Stroms, und dieser Slice ist ohne
einen benannten Konsumenten lieferbar — sonst wäre er ein Zombie-Slice (Baseline-Regelwerk
`modul-05-planning-harness.md` §Ziel-Form: Slice).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Das Navigations-Überspringen umgeht die Wert-Grenze des ersten Slice.** Liest die Segment-Wahl
  den Rest der Zeile über einen zweiten Weg, an der Wert-Prüfung vorbei, landet ein Token-Wert
  wieder im Log — der Fall, dessen Behebung der Kommentar über der Funktion dokumentiert. Die
  Kompositions-Fälle in §2 (Liefer-Punkt 1, zweites und drittes Gegenbeispiel) sind dieser
  Wächter. — **Ausgang:** <offen>
- **`&&` und `;` sind Text, nicht Struktur.** Innerhalb von Anführungszeichen, in einem
  `find -exec`-Ausdruck oder in einer Subshell trennen sie kein Segment; ohne Leerraum
  (`a&&b`) sind sie kein eigenes Feld und das Segment-Ende wird nicht gefunden — `argc` zählt dann
  zu viel. Eine Übersprung-Regel kann hier danebengreifen — die Rückführung in §4 nimmt den Fall
  auf. — **Ausgang:** <offen>
- **Der Bestand mischt danach zwei Bedeutungen — an zwei Feldern.** Spans vor und nach diesem Slice
  tragen `program` **und** `argc` mit verschiedener Regel; `argc` ändert sich für **jede** Zeile mit
  Operator, nicht nur für Navigations-Zeilen (§2, Liefer-Punkt 2). Ein Leser, der über die Zeit
  vergleicht, sieht einen Sprung, der keine Verhaltensänderung ist. Kein Feld trägt die Fassung.
  — **Ausgang:** <offen>
- **Der erste Slice liefert den Begriff anders, als dieser ihn voraussetzt.** §1 setzt *Segment ohne
  Programm*, Operator als eigenes Feld und die Wert-Grenze voraus. Weicht die Umsetzung ab, trägt der
  Aufbau nicht (Rückführung in §4). — **Ausgang:** <offen>
- **Für das berührte Spec-Stratum benennt keine Quelle eine schreibende Rolle.** Der Slice ändert
  zwei Zeilen in Rang 2 der Source Precedence, ohne dass gesagt ist, wer das darf. Adresse:
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md). — **Ausgang:** <offen>

## 7. Closure-Notiz

<!-- Wird bei der Closure gefüllt — Planner, nicht der Lauf, der die Arbeit tat
(AGENTS.md §3.10). -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Der Träger
liegt in `internal/span/`, die zweite Schicht ist `spec/` — `harness/tools/` (`TOOLS`) und
`.codex/` (`CODEX`) sind als Pfade nicht berührt. Eine eigene Sub-Area für die Erfassungsschicht
führt die Modus-Deklaration nicht, und dieser Slice legt keine an: Er ändert eine Funktion, nicht
die Reife-Achse eines Bereichs.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; die Zähler sind als Dateizahl unter
`evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte** —
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2, gelesen am gemergten Stand vom 2026-09-24). Diesen Vorgang betreffen:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `anweisungssatz-eigentum-ohne-quelle` | 5× | geplant | **unmittelbar** — dieser Slice schreibt in ein Stratum ohne benannte schreibende Rolle; ihr `state.md` nennt bereits `slice-151` als Adresse, und §1 verweist dorthin, statt die Frage still zu entscheiden |
| `zusage-ohne-herstellbares-gegenbeispiel` | 3× | verkörpert | die Gegenbeispiele in §2 sind der Regelfall dieser Klasse; die Komposition mit der Wert-Grenze (Liefer-Punkt 1, zweites und drittes) ist das, an dem sie sich entscheidet |
| `neuer-waechter-ohne-mutations-fall` | 12× | verkörpert | die neue Zusage braucht ihren Fall in `test/mutations/`, sonst ist sie unbewacht |
| `zusage-nennt-sensor-der-form-nicht-sieht` | 17× | geplant | der Funktionskopf nennt seinen Geltungsbereich; wird die Segment-Regel ergänzt, ohne den Kommentar mitzunehmen, ist es genau diese Klasse — Adresse `slice-181` |
| `vollstaendigkeits-zusage-misst-falsche-ebene` | 3× | verkörpert | die Ebenen-Aussage im Kopf (Dogfood **und** emittiert, über den Träger statt über eine Vorlage) ist genau die Stelle, an der diese Klasse auftritt |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 16× | verkörpert | die Regel steht ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)): jede Zahl dieses Plans steht neben dem Kommando, das genau sie ausgibt |
| `plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand` | 1× | offen | **unmittelbar** — zwei Pläne über `commandProgram()`; die Reihenfolge ist entschieden (erster Slice zuerst, §4) und dieser Plan ist an ihn angeschnitten, statt neben ihm zu stehen |

**Sechs Einträge tragen einen Ausgang** (`anweisungssatz-eigentum-ohne-quelle`,
`zusage-nennt-sensor-der-form-nicht-sieht` — `geplant` mit Kennung; die vier übrigen `verkörpert`
mit Zielort); dieser Slice ändert keinen. Der Eintrag `plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand`
steht unter der Schwelle; dieser Slice weist ihm keinen Ausgang zu und erhöht ihn nicht vorab. Alle
Bezeichnungen sind **zitiert**, nicht neu formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.
