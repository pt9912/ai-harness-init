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
[slice-program-feld-nennt-weder-operator-noch-wertfragment](../done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
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
[slice-program-feld-nennt-weder-operator-noch-wertfragment](../done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
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
  [slice-program-feld-nennt-weder-operator-noch-wertfragment](../done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
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

- [x] **Vier Gegenbeispiele, je einmal rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6),
      jedes über `span.Derive` **und** über den serialisierten Span (`span.Build` bis zur Zeile in
      `internal/span/emit.go`):
  - [x] `cd /x && make gates` → `make` (ohne diesen Slice: `cd`) · `set -e; make gates` → `make`.
  - [x] `cd /x && TOKEN=abc gh pr create` → `gh`, und **weder `TOKEN` noch `abc` stehen in der
        geschriebenen Zeile**. Das ist das **wichtigste** Kriterium: Die Verbesserung darf das Loch
        nicht öffnen, das der Kommentar über der Funktion nennt (`GITHUB_TOKEN=ghp_… gh pr create`
        landete sonst verbatim als `program`). Der Schutz selbst ist die Wert-Grenze des ersten
        Slice; dieser Fall belegt, dass sie **hinter einem übersprungenen Navigations-Segment**
        gilt — die Komposition, nicht die Prüfung.
  - [x] `cd /x && TOKEN="abc def" gh pr create` → **nichts** (Wert-Rand nicht bestimmbar, wie
        beim ersten Slice, jetzt nach einem Navigations-Segment).
  - [x] Die Ränder des Übersprungs: `cd /x` allein und `cd /x &&` → `cd` · `cd /x || exit 1` →
        `cd` · `cd a && cd b && make` → `make` (§1: das Navigations-Segment bleibt das Programm,
        wenn nichts folgt oder das Folge-Segment nur bei Fehlschlag läuft).
  - `TestCommandProgramSkipsAssignments` und die Tests des ersten Slice bleiben **grün und
    unverändert** — die bestehende Zusage wird nicht umgeschrieben, um die neue zu ermöglichen.
- [x] Ein Fall in `test/mutations/` nimmt der **Navigations-Grenze** die Zähne (Mutation: `cd`/`set`
      werden nicht übersprungen). Er trifft die Segment-Grenze, nicht nur den Happy Path; sein
      `sed`-Muster ist **nach** der Implementierung gegen den Quell-Bestand gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
      Ohne ihn ist die Zusage unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

**Liefer-Punkt 2 — `argc` zählt die Argumente des gewählten Segments.**

- [x] `argc` ist gesetzt, nicht mitgeschleift: Felder **nach dem Programm bis zum Ende seines
      Segments** (Operator-Feld oder ein Feld, das auf `;` endet) statt bis Zeilenende. Für
      `cd /x && make gates` ist `argc` 1 (`gates`), nicht 4 — und für `make gates && echo x` ist
      es 1, nicht 3: **die Bedeutung ändert sich für jede Zeile mit Operator**, nicht nur für
      Navigations-Zeilen. Jeder dieser Fälle ist ein Test mit rot gesehener Mutation (Segment-Ende
      wird nicht gesucht → `argc` läuft bis Zeilenende).
- [x] Ein Fall in `test/mutations/` bindet die `argc`-Grenze; sein Wächter ist der Test dieses
      Liefer-Punkts, nicht der aus Liefer-Punkt 1 — ein Fall, der bei geschwächter Zusicherung noch
      rot wird, deckt einen anderen Zweig, und die Gegenprobe steht in der Closure-Notiz.

**Liefer-Punkt 3 — die Spec nennt die neue Mechanik, und die Eigentumsfrage ist benannt.**

- [x] `SPEC-021` (`argc`: segment-begrenzt) und `SPEC-031` (die `Bash`-Zeile: Navigations-Segmente
      zusätzlich zu den Zuweisungs-Segmenten des ersten Slice) in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
      §5 sind nachgezogen. Das Technik-Stratum ist ohne Vertragsänderung fortschreibbar
      ([`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence));
      das Lastenheft wird **nicht** angefasst.
- [x] **Die offene Eigentumsfrage ist benannt, nicht entschieden.** Der Lauf, der die Spec-Zeilen
      schreibt, hält in §7 fest, dass für dieses Stratum **keine Quelle** eine schreibende Rolle
      benennt, und nennt [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md)
      als deren Adresse. Er leitet daraus **keine** Zuständigkeit ab — eine aus Zweckmäßigkeit
      abgeleitete Rolle wäre genau der Befund, den slice-151 auflösen soll.

**Pro Slice konstant — zählt nicht in den einen:**

- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register ([`../observations/`](../observations/)) fortgeschrieben — **kein
      Zähler wird gesetzt**, er folgt aus den Dateien.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice läuft
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
[slice-program-feld-nennt-weder-operator-noch-wertfragment](../done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md)
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
  Wächter. — **Ausgang:** *weiter offen* — Beobachtungs-Register,
  [`BEO-ALL/shell-nachbau-ohne-tokenizer-deckt-nicht-jede-eingabe-klasse`](../observations/BEO-ALL/shell-nachbau-ohne-tokenizer-deckt-nicht-jede-eingabe-klasse/observation.md).
  Die Instanz, die das Risiko beschrieb, ist **eingetreten und im Slice geschlossen**: hinter einem
  `cd` erreichten Wörter aus Kommentar, Here-Doc-Körper und Folgezeile das Feld `program`
  (Review Runde 1, H-1). Die zwei Kompositions-Fälle aus §2 tragen — am gebauten Träger steht weder
  `TOKEN` noch `abc` in der geschriebenen Zeile. Offen bleibt die Klasse, die keine Tabelle
  vollständig hält: `A=b "secret token" x` nennt ohne Navigation weiter `"secret`.
- **`&&` und `;` sind Text, nicht Struktur.** Innerhalb von Anführungszeichen, in einem
  `find -exec`-Ausdruck oder in einer Subshell trennen sie kein Segment; ohne Leerraum
  (`a&&b`) sind sie kein eigenes Feld und das Segment-Ende wird nicht gefunden — `argc` zählt dann
  zu viel. Eine Übersprung-Regel kann hier danebengreifen — die Rückführung in §4 nimmt den Fall
  auf. — **Ausgang:** *weiter offen* — Beobachtungs-Register,
  [`BEO-ALL/regel-rand-ohne-benannte-luecke`](../observations/BEO-ALL/regel-rand-ohne-benannte-luecke/observation.md).
  Das Risiko ist **eingetreten und im Slice aufgefangen**: die Regel überspringt ein Navigations-Segment
  nur bei einer Zeile und schlichten Wörtern, jeder nicht bestimmbare Rand lässt `cd` stehen oder das
  Feld entfallen; die Rückführung nach §4 ist nicht gezogen (§7). Offen bleiben die Ränder, die die
  Aufzählung nicht nennt — die Länge eines Worts, das erste Wort eines Strings hinter einer
  Zuweisung — und der Preis (`cd "$DIR" && make` bleibt `cd`).
- **Der Bestand mischt danach zwei Bedeutungen — an zwei Feldern.** Spans vor und nach diesem Slice
  tragen `program` **und** `argc` mit verschiedener Regel; `argc` ändert sich für **jede** Zeile mit
  Operator, nicht nur für Navigations-Zeilen (§2, Liefer-Punkt 2). Ein Leser, der über die Zeit
  vergleicht, sieht einen Sprung, der keine Verhaltensänderung ist. Kein Feld trägt die Fassung.
  — **Ausgang:** *weiter offen* — Beobachtungs-Register,
  [`BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe`](../observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/observation.md).
  Das Risiko ist eingetreten; die Folge trägt der Eintrag, und kein Leser bricht (Review Runde 1, I-3).
- **Der erste Slice liefert den Begriff anders, als dieser ihn voraussetzt.** §1 setzt *Segment ohne
  Programm*, Operator als eigenes Feld und die Wert-Grenze voraus. Weicht die Umsetzung ab, trägt der
  Aufbau nicht (Rückführung in §4). — **Ausgang:** *entfallen* — der Vorgänger-Slice liegt in `done/`,
  und seine Tests bleiben grün und unverändert: der Diff dieses Slice löscht **0** Zeilen in
  `internal/span/span_test.go`
  (`git diff 5acbc97d~1..ed4eedcf -- internal/span/span_test.go | grep -c '^-[^-]'`), und `make test-go`
  ist am Stand des Verifiers grün.
- **Für das berührte Spec-Stratum benennt keine Quelle eine schreibende Rolle.** Der Slice ändert
  zwei Zeilen in Rang 2 der Source Precedence, ohne dass gesagt ist, wer das darf. Adresse:
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md). — **Ausgang:**
  *eingetreten* — Folge-Slice `slice-151`, eine Datei in `open/`: der Slice hat `SPEC-021` und
  `SPEC-031` ohne benannte Quelle für die schreibende Rolle geändert und daraus keine Zuständigkeit
  abgeleitet; die Frage bleibt bei `slice-151`, und `slice-151` nimmt sie an, denn er führt genau diese
  Frage.

## 7. Closure-Notiz

Geschrieben von der Rolle Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach zwei Review-Runden
und Verifikation. Alle Kommandos gemessen am 2026-09-27 am Stand `62a7b27d`, keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

- **Was hat funktioniert:** Liefer-Punkt 1 und 2 sind vom Verifier bestätigt und selbst gefahren: `cd /x && make gates` nennt `make`
  mit `argc` 1, `cd /x && TOKEN=abc gh pr create` nennt `gh` ohne `TOKEN` und `abc` in der geschriebenen Zeile (Träger real
  gebaut, `span-emit` gegen fünf Payloads, Closure-Trigger 2), `cd /x && TOKEN="abc def" gh pr create` nennt nichts. Die zwölf Fälle
  476 bis 487 (`ls test/mutations | grep -cE '^(47[6-9]|48[0-7])-'` → 12) tragen je einen Test als einzigen Träger der Mutation: Kontrolle rot,
  Gegenprobe (der benannte Test übersprungen) grün, für alle zwölf vom Verifier gefahren. Der Verifier schwächte den Code
  danach 84 Mal (45 Erweiterungen und 18 Verkürzungen der Whitelist, 21 weitere Schwächungen) und fuhr 147 Formen gegen drei Stände
  von `internal/span/span.go`: keine Schwächung blieb grün außer den benannten äquivalenten, und in keiner Form erreichte ein Wort
  eines Kommentars, Here-Doc-Körpers, einer Folgezeile oder eines Zuweisungs-Werts das Feld hinter einem Navigations-Segment. Die
  Suite löscht **0** Zeilen der bestehenden Tests
  (`git diff 5acbc97d~1..ed4eedcf -- internal/span/span_test.go | grep -c '^-[^-]'`).
- **Was ging anders als geplant:** Der Plan sah eine Funktion, zwei Spec-Zeilen und zwei Fälle vor. Gebaut sind neun Funktionen und Typen
  in `internal/span/span.go` (+201/−16), `internal/span/span_test.go` +406
  (`git diff --numstat 5acbc97d~1..ed4eedcf -- internal/span/span.go internal/span/span_test.go`), zwölf Fälle und `SPEC-031` von
  1174 auf 3821 Byte (`grep '^| .SPEC-031.' spec/spezifikation.md | wc -c`; Vorzustand `git show 5acbc97d~1:spec/spezifikation.md | grep '^| .SPEC-031.' | wc -c`).
  Ursache sind die Befunde: Review Runde 1 (Stand `490f2daa`; 1 HIGH, 2 MEDIUM, 1 LOW, 4 INFO) fand H-1 — Wörter aus Kommentar,
  Here-Doc-Körper und Folgezeile erreichten `program` hinter einem `cd`, der Weg, den
  [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) sperrt —, Runde 2 (Stand `e1ad8ccf`; kein HIGH, 2 MEDIUM, 2 LOW, 3 INFO) fand
  Tab-Wortgrenze und Fortsetzungs-Bedingung ungebunden und `cd /x && "secret token" x` → `"secret`, der Verifier zwei weitere Ränder
  (V-2, V-3, unten). **Gebaut, nicht geplant:** die Whitelist statt einer Regel, die Einzeiligkeit, das Zeilenende als Grenze von
  `argc`, das schlichte Wort am Programm-Wort, zehn Fälle mehr; der Verifier wertete das als größer als geplant und innerhalb des
  Gegenstands, **und der Planner schließt sich an** — Abgrenzung und Schichten (kein `internal/emit/`, keine Vorlage, kein `span-report`)
  hielten (`git diff --stat 5acbc97d~1..HEAD` nennt außer den Reports, der Roadmap und dem Slice nur `internal/span/span.go`,
  `internal/span/span_test.go`, `spec/spezifikation.md` und die Fälle).
- **Entscheidung 1 — der Schnitt trug nicht, und zwar an der Prüfbarkeit.** Gegen
  Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice: **drei** Liefer-Punkte (konform), **zwei** Schichten,
  Produkt-Code und Spec-Stratum (konform), *in einer Review-Sitzung prüfbar* — **nicht** getragen: es brauchte zwei Review-Runden
  und den Verifier, und jede Runde fand die nächste Rand-Klasse derselben Textsprache. Die Rückführungs-Bedingung in §4
  (*„die Segment-Trennung lässt sich nicht textuell ziehen … eine tragfähige Fassung verlangt eine Zerlegung der Zeile statt einer
  Übersprung-Regel"*) ist **berührt und dem Wortlaut nach nicht eingetreten**: das Ergebnis ist eine Übersprung-Regel, die an 147
  gefahrenen Formen trägt, weil sie im Zweifel `cd` stehen lässt oder das Feld entfallen lässt — auf Kosten des Nutzens. Das ist ein
  **Fehler des Plans**, nicht des Laufs: die Bedingung nannte eine Lösungsform (die Zerlegung) und kein beobachtbares Signal, und
  ein HIGH über Datenabfluss in Runde 1 (H-1) war der Zeitpunkt, an dem der Planner hätte entscheiden müssen — `in_progress → next`
  oder eine engere Regel —, ein Zeitpunkt, den der Lauf nicht vorsah. Der Slice bleibt geschlossen: die Lieferung trägt (Verifier),
  und ein Rückführen verwürfe sie. **Was das für den nächsten Slice der Klasse *erkennende Regel über Shell-Text* heißt** — ein
  Vorschlag an den Planner, der ihn schneidet, keine Regel: (1) der Plan trägt eine **Formen-Probe** vor dem Schnitt — die
  Rand-Formen der Textsprache (Kommentar, Here-Doc, Zeilenende, Anführungszeichen, Substitution, Tab, Fortsetzung) mit ihrem Ergebnis
  am Vorzustand —, und der Schnitt folgt aus der Zahl der Formen, die die Regel zerlegen muss; (2) der Plan **beziffert den Preis** der
  fail-closed-Linie oder weist ihn als ungemessen aus, mit dem Träger einer Datenbasis; (3) die Rückführungs-Bedingung nennt ein
  **beobachtbares Signal** — ein HIGH über Datenabfluss in einer Runde oder eine zweite Runde mit neuer Rand-Klasse —, nicht eine
  Lösungsform. Der Träger ist die Beobachtung
  [`erkennende-regel-ueber-text-waechst-ueber-ihren-schnitt`](../observations/BEO-ALL/erkennende-regel-ueber-text-waechst-ueber-ihren-schnitt/observation.md)
  (2×), die der Sichtungs-Schritt in §8 des nächsten Plans über eine solche Regel liest; als Norm-Text ist sie nicht geschrieben.
- **Wer was gelesen hat, und Entscheidung 2 — keine dritte Reviewer-Runde.** Runde 1 las bis `490f2daa`, Runde 2 bis `e1ad8ccf`. Danach liegen
  sechs Commits, die **kein Reviewer** gelesen hat: `658b2138` und `588397a4` (Tests), `aa905f04` (`internal/span/span.go`, der Zweig
  `case navigated && !plainNavigationWord(f)`), `ac09c100` (Fälle 483 bis 487), `ead7fa0f` und `ed4eedcf` (`SPEC-031`). Der Verifier hat sie
  gemessen — Schwächung des Zweigs rot, die fünf Fälle binden, 101 Formen ohne Fragment im Feld, die HEAD-Tests gegen `e1ad8ccf` rot in
  einem Test mit 15 Teilfällen —, das ist **keine** Review-Runde: der Reviewer prüft den Diff gegen Plan, ADR und Hard Rules, der
  Verifier gegen DoD und Spec. **Die Hard Rules verlangen keine dritte Runde**; [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2 (die Bestätigung einer Behebung ist die Runde einer **anderen** Rolle, nicht die Nachmessung des Kontexts, der sie schrieb)
  gilt für den Accept-Übergang einer ADR; ihr Grund trägt hier durch den Verifier, der die Behebungen der Runde 2 gemessen hat, nicht durch
  einen Reviewer. Abgewogen: *für* eine Runde spricht, dass der Zweig sicherheitsrelevant ist und dass jede frühere Runde die
  nächste Rand-Klasse fand. *Dagegen* spricht, dass der Zweig den **kleinsten Schließungs-Vorschlag** der Runde 2 (L-2: hinter einem
  übersprungenen Segment nur ein Wort nehmen, das `plainNavigationWord` besteht) umsetzt, dass er nur in die fail-closed-Richtung wirkt
  (er lässt das Feld entfallen, er nennt nichts Zusätzliches), dass der Verifier ihn mit mehr Formen und Schwächungen gefahren hat, als
  Runde 2 fuhr, und dass die Runden konvergieren (H-1 in Runde 1, kein HIGH in Runde 2, kein HIGH und kein MEDIUM beim Verifier).
  **Entscheidung: keine dritte Runde**, und das Häkchen *Review durchgeführt* bestätigt Runde 1 und Runde 2 samt den gezogenen Findings —
  **ein Report über die sechs Commits besteht nicht und wird nicht behauptet.** Die Wahl, dass die Whitelist am Programm-Wort dieselbe ist
  wie am Segment, hat damit **kein Reviewer bewertet**; sie ist vom Verifier nur gemessen. Wer sie für tragend hält, öffnet eine Runde als
  Übergabe, bevor der nächste Slice dieselbe Funktion anfasst. Die Klasse steht im Register
  ([`aenderung-nach-der-letzten-review-runde-bleibt-ungesehen`](../observations/BEO-ALL/aenderung-nach-der-letzten-review-runde-bleibt-ungesehen/observation.md),
  3×, siehe unten).
- **Mutate: Teilmessung, keine Gesamtaussage.** Real gefahren ist der Teillauf
  `make mutate MUTATE_JOBS=1 MUTATE_CASES=<476 bis 487>` (Verifier, Stand `ed4eedcf`): `12 ok, 0 Befund(e)`, `TEILLAUF 12 von 475 — kein Beleg`
  (`ls test/mutations/*.sh | wc -l` → 475); der Beleg-Slot `.harness/state/mutate-passed.key` ist vorher wie nachher nicht vorhanden
  (`ls .harness/state/mutate-passed.key` → nicht vorhanden). **Nicht gefahren:** ein voller `make mutate`; der Nachtlauf `mutate.yml`
  trägt ihn. Der Closure-Trigger 1 (*„`make mutate` meldet `0 Befund(e)`"*) ist damit **für die zwölf Fälle** erfüllt, nicht für das
  Ganze.
- **Grenzen der Lieferung, benannt — nicht behoben.** **V-2:** `program` hat keine Längengrenze; `cd /x && ` und ein Wort aus 1 000 000
  Zeichen nennt alle 1 000 000 Zeichen, hinter Navigation neu erreichbar, ohne Navigation und im Vorzustand ebenso; es ist ein
  schlichtes Wort in Befehlsposition, kein Wert (LOW). **V-3:** das erste Wort eines Strings ist ohne Navigation erreichbar
  (`A=b "secret token" x` → `"secret`, `"secret token" x` → `"secret`), weil die Schlichtheits-Prüfung nur hinter einem
  Navigations-Segment gilt; `SPEC-031` und der Kommentar nennen es für Formen ohne Navigation, für die Zuweisung nicht ausdrücklich
  (LOW). **V-4:** die Zeichenliste der Whitelist steht in `SPEC-031` als handgeschriebene Kopie, und kein Sensor hält sie gegen den
  Code; die Fälle 486 und 487 binden den Code gegen die erwartete Menge im Test, nicht gegen die Spec-Zeile, und der Satz *„Bewacht
  von … Fälle 486 und 487"* ist breiter als sein Sensor (LOW). Der Ausgang aller drei ist das Register (unten); ein Folge-Slice ist
  nicht geschnitten. **Der Preis der Whitelist:** `cd "$DIR" && make` bleibt `cd`, `cd /x && "$TOOL" x` und `cd /x && make; echo z`
  nennen **nichts**, `cd /x && make` mit einem Zeilenende irgendwo bleibt `cd`, jede mehrzeilige Zeile mit Navigation nennt `cd`
  (Verifier, Formen-Probe). **Der Nutzen ist nicht beziffert (V-5):** die Spans tragen nur `program` und `argc`, nie die Zeile; ob die
  **38 %** aus §1 fallen, zeigt erst ein Strom über die Zeit, und die Formen, die die Regel nicht auflöst, sind bekannt, ihr
  Anteil nicht. `TestCommandProgramFirstWordKeepsItsGluedRest` (die Grenze des Programm-Felds ohne Navigation) trägt keinen Fall; eine
  Schwächung färbt ihn, aber `make mutate` bewacht ihn nicht — Ist-Verhalten, nicht Zusage.
- **Spec-Stratum, Eigentumsfrage (Liefer-Punkt 3, zweiter Punkt).** Für [`spec/spezifikation.md`](../../../../spec/spezifikation.md) (Rang 2 der
  Source Precedence) benennt **keine Quelle** eine schreibende Rolle: [`AGENTS.md`](../../../../AGENTS.md) §3.8 weist nur Hard Rules und
  Adaptions-Block dem Architect zu und lässt jede andere Frage ausdrücklich offen. `SPEC-021` und `SPEC-031` hat ein Lauf mit der Rolle
  Implementer geschrieben (die Commit-Messages nennen sie); daraus wird **keine** Zuständigkeit abgeleitet — eine aus Zweckmäßigkeit
  abgeleitete Rolle wäre genau der Befund, den [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md) auflösen soll.
  Die Adresse ist `slice-151` (`open/`). **Querlage, benannt:** der Wortlaut des Punktes legt diese Zeile in §7 in die Hand *„des Laufs, der
  die Spec-Zeilen schreibt"*; §3.10 legt §7 in die Hand des Planners, ausdrücklich nicht in die des ausführenden Laufs. Der Implementer hat §7
  richtig leer gelassen (Verifier); die Zeile steht hier, vom Planner, und das Häkchen meint die **Zeile in §7**, nicht die Autorschaft
  des Laufs. Der Plan-Wortlaut stammt vom 2026-09-08 und wird nicht umgeschrieben. **Liefer-Punkt 3, erster Punkt, trägt mit Vorbehalt:**
  `SPEC-021` und `SPEC-031` sind nachgezogen und der Wortlaut ist am Code gelesen (V-4 nimmt die Liste aus, siehe oben); das Lastenheft ist
  unberührt.
- **Steering-Loop-Eintrag (Form: neuer Sensor).** Die Rand-Menge einer erkennenden Regel über Shell-Text ist gemessen statt vorausgesetzt:
  `TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure` fährt jedes ASCII-Zeichen ab 0 gegen die Whitelist der schlichten Zeichen — die
  Formen-Probe als Test statt als Einmal-Lauf —, und die Fälle 476 bis 487 binden je eine Grenze (Navigations-Segment, Segment-Ende, unsicherer
  Rand, Einzeiligkeit, Tab, Backslash-Fortsetzung, Programm hinter Navigation, NUL, `%`). **Kein Zielort-Feld und kein Herkunfts-Anker:** der
  Sensor trägt die Kennung seiner Quelle nicht in einer Regel-Zeile; die Paarung (a) hätte nichts, gegen das sie prüft. **Grenzen des Sensors,
  benannt:** er hält die **Zeichen** der Menge, nicht Formen, die keine Zeichen sind (Länge, Struktur eines Kommentars); er hält den Code gegen
  die erwartete Menge **im Test**, nicht gegen `SPEC-031`; er ist ein Go-Test gegen dieses Repo und wird nicht emittiert; die `sed`-Anker der
  zwölf Fälle sind Einzelzeilen im Quell-Bestand
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand), vom Verifier gemessen).
  **Die geschärfte Regel ist nicht verkörpert, und der Planner verkörpert sie nicht:** *eine Regel, die Text an Leerraum zerlegt und daraus ein
  Feld liest, führt für ihr Wort dieselbe Schlichtheits-Prüfung wie für ihr Segment, und der Plan trägt die Formen-Probe vor dem Schnitt.* Sie
  steht im Register, nicht in einem Norm-Artefakt; Hard Rules und Reviewer-Skill schreiben Architect bzw. Reviewer
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-204-das-programm-feld-nennt-das-programm.md`; Zähler gelesen mit
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  Ein Vorgang zählt einmal je Beobachtung; die Zuordnung ist je Kandidat ein **Urteil des Planners** und hier begründet.
  **Erstmals über der Schwelle, zwei Übergaben an den Architect:** (1)
  [`zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel`](../observations/BEO-ALL/zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel/observation.md)
  **3×** (Tab-Wortgrenze, Fortsetzungs-Bedingung, Programm-Feld auf `;`: Kommentar und Spec sagen jede Grenze zu, die Fälle banden je eine
  Hälfte); (2)
  [`aenderung-nach-der-letzten-review-runde-bleibt-ungesehen`](../observations/BEO-ALL/aenderung-nach-der-letzten-review-runde-bleibt-ungesehen/observation.md)
  **3×**, **neu angelegt** — kein Verzeichnis führte die Klasse (`ls docs/plan/planning/observations/BEO-ALL | grep -c 'review-runde'` → 1,
  das neue), und **die zwei früheren Vorgänge sind nachgetragen**, weil ihre Closure-Notizen dieselbe Lage wörtlich nennen
  (`slice-archive-welle-schreibt-in-reports-nur-die-link-form`: vier Commits nach dem Review, einer ohne jeden Leser;
  `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`: zwei) und ein abgeschlossener Vorgang mit dem Auftreten einen
  Beleg trägt; **wer sie nicht als Auftreten dieser Klasse liest, löscht die zwei Dateien unter `evidence/` und lässt den Eintrag bei 1×.**
  **Vierter Beleg, Eskalation:**
  [`regel-rand-ohne-benannte-luecke`](../observations/BEO-ALL/regel-rand-ohne-benannte-luecke/observation.md) **4×** (`verkörpert`): die Zeile des
  Reviewer-Skills hat an diesem Diff gegriffen — der Review fand die Lücken der Aufzählung — und die Autor-Seite blieb offen; der
  Eskalationsschritt laut `state.md` ist eine Falsch/Richtig-Zeile in [`AGENTS.md`](../../../../AGENTS.md) §3.6, **Architect-Arbeit (§3.8), nicht
  geschrieben und nicht zugewiesen.** **Je ein Beleg, unter der Schwelle:**
  [`zeichenmenge-mitglied-ohne-eigenen-zahn`](../observations/BEO-ALL/zeichenmenge-mitglied-ohne-eigenen-zahn/observation.md) (2×: Operator-Guards und
  Sweep), [`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
  (2×: Fall 476 und die Entflechtung in der Nachrunde 2),
  [`span-feld-bedeutung-wechselt-ohne-fassungs-angabe`](../observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/observation.md) (2×;
  jetzt auch `argc`), [`shell-nachbau-ohne-tokenizer-deckt-nicht-jede-eingabe-klasse`](../observations/BEO-ALL/shell-nachbau-ohne-tokenizer-deckt-nicht-jede-eingabe-klasse/observation.md)
  (2×: H-1 und die Ränder der Runde 2). **Neu, 2×:**
  [`erkennende-regel-ueber-text-waechst-ueber-ihren-schnitt`](../observations/BEO-ALL/erkennende-regel-ueber-text-waechst-ueber-ihren-schnitt/observation.md)
  — der zweite Beleg ist der Vorgänger-Slice `slice-program-feld-nennt-weder-operator-noch-wertfragment` (fünf Fälle statt zwei, drei Funktionen
  außerhalb von §3, zwei Runden), dessen Closure-Notiz das Plan-Delta nennt. **Über der Schwelle mit bestehendem Ausgang, je ein Beleg dazu:**
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (`geplant`; der emittierte Feldtext `internal/span/fieldlist.go` Zeile 94 sagt *„das erste Token der Kommandozeile"*, `SPEC-021` sagt jetzt *„das
  erste Wort des ausgeführten Segments"*) und
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) (`geplant`; V-4 — die
  Beobachtung führt Skript- und Funktionsköpfe, die Spec-Zeile ist dieselbe Fehlerrichtung an einer weiteren Fläche, und wer sie anders zuordnet,
  streicht die eine Datei). **Nicht als Beleg gezählt:** V-5 (Nutzen nicht beziffert) — ein Vorkommen ohne Beobachtung, das ein Bestand nicht
  trägt; wer es messen will, braucht eine Datenbasis, und die Spans tragen die Zeile nicht: kein Nachtrag in diesem Slice.
  **Lese-Schritt:** `for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -ge 3 ] && ! grep -qhE '^\*\*Stand:\*\* (verkörpert|geplant|gestrichen)' "$d"state.md "$d"observation.md && echo "$d"; done`
  nennt genau die zwei Einträge (1) und (2); sie tragen bis zum Architect `offen`, was zwischen zwei Lese-Schritten zulässig ist
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md) gilt der zweiten Hälfte von (c), nicht dieser Lage).
- **Folge-Slices:** keiner geschnitten. `slice-151` (`open/`) führt die Eigentumsfrage. Die Wortlaut-Kopplung des emittierten Feldtexts
  (`fieldlist.go` Zeile 94) führt **Frage A** von
  [slice-109](../next/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) (*„die Frage je Feld steht zweimal, und die zwei Fassungen driften"*, alle
  Felder des Trägers); dessen Plan nennt die `program`-Zeile nicht und wird **nicht** ergänzt — jede Antwort auf Frage A gleicht den Wortlaut je Feld ab,
  und eine hineingeschriebene Instanz wäre eine Zustandsaussage, die mit dem ersten Nachzug veraltet. V-2 (Längengrenze) und V-4 (Spec-Kopie) sind
  Register-Belege und keine Slices: beide hätten **einen** Liefer-Punkt in **einer** Schicht, aber kein Konsument wartet auf sie und keine Adresse
  fehlt (V-4 ist Beleg der Beobachtung `zusage-nennt-sensor-der-form-nicht-sieht`, deren Ausgang `geplant` an `slice-181` hängt; ob
  dieser Slice die Spec-Zeile trägt, ist nicht geprüft).
- **Übergaben, nicht erledigt:** (a) **Architect** — die zwei 3×-Einträge und die Eskalation von `regel-rand-ohne-benannte-luecke` (oben); (b) **Zeitdokument** —
  in `done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md` steht hinter einem nachgezogenen Link weiter *„(`next/`)"*; die Datei ist ein Zeitdokument
  ([`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1) und wird nicht angefasst; (c) **Implementer** — `internal/span/fieldlist.go` Zeile 94,
  über `slice-109`.
- **Risiken aus §6:** fünf, je ein Ausgang. (1) *Navigations-Überspringen umgeht die Wert-Grenze* — **weiter offen**, Register
  `shell-nachbau-ohne-tokenizer-…`; die Instanz (H-1) ist eingetreten und im Slice geschlossen. (2) *`&&` und `;` sind Text* — **weiter offen**, Register
  `regel-rand-ohne-benannte-luecke`; eingetreten und aufgefangen. (3) *Der Bestand mischt zwei Bedeutungen* — **weiter offen**, Register
  `span-feld-bedeutung-wechselt-ohne-fassungs-angabe`. (4) *Der erste Slice liefert den Begriff anders* — **entfallen**, belegt am Diff (0 gelöschte Zeilen). (5) *Kein
  Rollen-Eigentum am Spec-Stratum* — **eingetreten**, Folge-Slice `slice-151`. Dass jeder Ausgang trägt, ist gelesen: (1) bis (3) an je einem
  Register-Verzeichnis mit Beleg dieses Vorgangs, (4) an einem Kommando, (5) an der Adresse.
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** über beide Adress-Formen gemessen, außerhalb dieser Datei, am 2026-09-27:
  die Code-Span-Form `(open|next|in-progress|done)/<Kennung>` (`git grep -lE "(open|next|in-progress|done)/<Kennung>" -- . ':!<diese Datei>'`) trifft **3** Dateien —
  `done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md`, `done/slice-span-programm-nennt-das-programm.md` und `open/slice-205-der-strom-traegt-die-zug-grenze.md` —
  und die Markdown-Link-Form `](…<Kennung>[.md])` (`git grep -lE "\]\([^)]*<Kennung>(\.md)?[)#]" -- . ':!<diese Datei>'`) **2** davon (die erste und die dritte). In `docs/reviews`,
  `docs/plan/adr` und `.harness/baseline` treffen beide Formen **0** Dateien (`git grep -lE "<beide Muster>" -- docs/reviews docs/plan/adr .harness/baseline | wc -l` → 0):
  die Reports nennen den Slice bei der Kennung. **Entscheidung vor dem Move:** die zwei Zeitdokumente unter `done/` und die lebende `slice-205` in `open/` nennen den Pfad; der Nachzug
  ersetzt dort eine Adresse und ändert keine Aussage
  ([`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1, dieselbe Form wie der Nachzug beim Claim-Move, der dieselben drei Dateien schrieb);
  eine `Accepted`-ADR und die Baseline bekommen keinen Byte-Nachzug, und keine nennt den Slice als Pfad.
- **Der Move, gemessen (`make slice-mv` nach `done/`, 2026-09-27):** zwei Commits, wie Hard Rule 3.3 sie trennt — der reine Move (`86841db5`, 0 Zeilen
  geändert) und der Verweis-Nachzug (`1097ea25`, drei Dateien, je Pfad-Adresse ersetzt: `done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md`,
  `done/slice-span-programm-nennt-das-programm.md`, `open/slice-205-der-strom-traegt-die-zug-grenze.md`; `git show --stat` je Commit gelesen). Weder ein Report noch eine ADR noch die
  Baseline wurde berührt (`git diff --name-only 2026c1ac..HEAD -- docs/reviews docs/plan/adr .harness/baseline | wc -l` → **0**). Der Satz *„(`next/`)"* hinter einem Link in
  `done/slice-program-feld-nennt-weder-operator-noch-wertfragment.md` ist Zustandsprosa, die der Nachzug nicht erreicht (Grenze 1 von `make slice-mv`); er bleibt.
- **Drei Paarungen (nach dem Move geprüft, 2026-09-27):** (a) *Anker:* der Eintrag trägt kein Zielort-Feld (siehe *Steering-Loop-Eintrag*), das Feld
  `liegt in` steht in keiner Zeile dieser Sektion — es gibt nichts zu paaren; benannt, nicht als grün behauptet. (b) *Folge-Slice:* jede in dieser Datei genannte Slice-Kennung besteht
  als Datei im Planning-Lifecycle (`grep -oE 'slice-[a-z0-9][a-z0-9-]*[a-z0-9]' <diese Datei> | sort -u`, je Kennung
  `ls docs/plan/planning/{open,next,in-progress,done} | grep -cE "^<Kennung>(-.*)?\.md$"` → je **1**, 13 Kennungen): die Folge-Slices `slice-151` (`open/`) und `slice-109` (`next/`), die
  Nachbarn `slice-181` (`open/`) und `slice-205` (`open/`), der Vorgänger und die zwei Vorgänge der nachgetragenen Belege (`done/`); `slice-mv` ist ein Kommando-Name und kommt in
  keiner Form vor, die das Muster fände. (c) *Register, beide Hälften:* **Hälfte 1 getragen** — jede in dieser Datei genannte Beobachtung besteht als Verzeichnis mit nicht
  leerem `evidence/` (**10** Kennungen; Zähler gelesen 2026-09-27: 3, 2, 2, 4, 2, 2, 2, 3, 33, 19 — `for s in $(grep -oE 'observations/BEO-ALL/[a-z0-9-]+/observation.md' <diese Datei> | sed -E 's#observations/BEO-ALL/([a-z0-9-]+)/observation.md#\1#' | sort -u); do ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l; done`).
  **Register-Paarung (c), zweite Hälfte: 4 Verzeichnisse ohne Beleg, namentlich `ci-rennt-gegen-die-publikation-des-gepinnten-releases`,
  `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` und
  `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet**
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md) Festlegung 2;
  `for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done` → vier Namen, dieselben vier wie
  vor diesem Slice). Keines wurde von ihm angelegt oder berührt
  (`git diff --name-only 62a7b27d..HEAD | grep -cE 'ci-rennt-gegen|cpp-skelett|einstiegs-datei-weicht|planungs-bestand-waechst'` → **0**); der Befund endet erst mit dem Beleg eines
  abgeschlossenen Vorgangs. **Das Häkchen der letzten DoD-Zeile ist so gesetzt, wie die Register-README das Kästchen liest:** die Paarung ist gefahren und ihr Ergebnis steht mit den
  Namen in §7; das Kästchen sagt nicht, dass sie grün ist, und die zweite Hälfte von (c) bleibt ein Befund. Im Repo mit Wellen prüft die nächste Welle-Closure sie erneut.

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
