# Slice slice-204: Das Feld `program` nennt das Programm, nicht das Navigations-Segment davor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice ändert **eine** Funktion und zwei Spec-Zeilen; sein Beleg sind
drei Gegenbeispiele und ein grüner Gate-Lauf, und beides steht in seiner eigenen DoD. Ein
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
Spec-Zeilen sind darum kein Lastenheft-Thema)

**Berührte Spec-Stellen:** [`SPEC-021`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
(`program`, `argc`) und `SPEC-031` (die `Bash`-Zeile der Werkzeug-Tabelle: *„erstes Token nach
übersprungenen `NAME=WERT`-Präfixen"*). Beide Zeilen beschreiben die heutige Mechanik wörtlich und
werden mit ihr falsch — sie wandern mit.

**Verantwortlich:** —

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
Token des nächsten Segments. `SPEC-021` verspricht mit `program` die Antwort auf *„Welches
Programm lief?"*; heute antwortet der Wert in **38 %** der `Bash`-Spans mit einem Shell-Konstrukt
statt mit einem Programm.

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
  [slice-151](slice-151-spec-straten-haben-eine-schreibende-rolle.md) liefert genau diese ADR. Wie
  dieser Slice sich in der Zwischenzeit verhält, steht in §2 — er entscheidet die Frage nicht
  still mit.
- **Keine Änderung an `span-report`, `span-watch` oder `hook-overhead`.** Sie lesen das Feld;
  dieser Slice schreibt es — **anderer Vorgang**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Liefer-Punkt 1 — `commandProgram()` überspringt führende Navigations-Segmente.** (Einer, nicht
drei: Die Spec-Zeilen und die Fälle sind die Form derselben Lieferung, nicht zusätzlicher Umfang.)

- [ ] **Drei Gegenbeispiele, je einmal rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6):
  - [ ] `cd /x && make gates` → `make` (heute: `cd`).
  - [ ] `cd /x && TOKEN=abc gh pr create` → **nichts**. Das ist das **wichtigste** Kriterium: Die
        fail-closed-Linie aus [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) gilt
        **pro Segment**. Wer das Segment wechselt, nimmt sie mit — die Verbesserung darf nicht das
        Loch öffnen, das der heutige Code geschlossen hat (der Kommentar über der Funktion nennt
        den gemessenen Anlass: `GITHUB_TOKEN=ghp_… gh pr create` landete sonst verbatim als
        `program`).
  - [ ] `TestCommandProgramSkipsAssignments` bleibt **grün** — die bestehende Zusage wird nicht
        umgeschrieben, um die neue zu ermöglichen.
- [ ] **`argc` trägt eine neue Bedeutung, und sie ist gesetzt, nicht mitgeschleift:** Argumente
      des **gewählten Segments** statt der ganzen Zeile. Für `cd /x && make gates` ist `argc` 1
      (`gates`), nicht 4. Eine Setzung, keine Selbstverständlichkeit — sie steht in der
      Spec-Zeile, sonst behauptet das Feld weiter etwas anderes, als es misst.
- [ ] **`SPEC-021` und `SPEC-031`** in
      [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
      §5 sind nachgezogen — beide beschreiben die Mechanik heute wörtlich („erstes Token nach
      übersprungenen `NAME=WERT`-Präfixen") und wären danach falsch. Das Technik-Stratum ist ohne
      Vertragsänderung fortschreibbar
      ([`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence));
      das Lastenheft wird **nicht** angefasst.
- [ ] **Die offene Eigentumsfrage ist benannt, nicht entschieden.** Der Lauf, der die zwei
      Spec-Zeilen schreibt, hält in §7 fest, dass für dieses Stratum **keine Quelle** eine
      schreibende Rolle benennt, und nennt [slice-151](slice-151-spec-straten-haben-eine-schreibende-rolle.md)
      als deren Adresse. Er leitet daraus **keine** Zuständigkeit ab — eine aus Zweckmäßigkeit
      abgeleitete Rolle wäre genau der Befund, den slice-151 auflösen soll.
- [ ] Ein Fall in `test/mutations/` nimmt der neuen Zusage die Zähne — ohne ihn ist sie
      unbewacht ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der Fall trifft die
      **Segment**-Grenze, nicht nur den Happy Path.

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
| `internal/span/span.go` | update | `commandProgram()` — die Segment-Schleife um die bestehende Zuweisungs-Schleife; der Kommentar über der Funktion nimmt die fail-closed-Linie pro Segment mit |
| `internal/span/span_test.go` | update | die drei Gegenbeispiele, `TestCommandProgramSkipsAssignments` unverändert daneben |
| `test/mutations/<N>-span-program-segment-*.sh` | neu | nimmt der Segment-Grenze die Zähne |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 | update | `SPEC-021` (`program`, `argc`) und `SPEC-031` (`Bash`-Zeile) |

**Zwei Schichten:** Produkt-Code (`internal/span/` samt seinen Fällen) und Spec-Stratum 2. Kein
`cmd/`, kein `Makefile`, kein `internal/emit/`.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert, `Verantwortlich:` ist gesetzt, das
WIP-Limit des Rolleninhabers ist frei. **Keine Abhängigkeit von einem anderen Slice** — siehe §5
zum Verhältnis zu slice-203.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Segment-Trennung lässt sich nicht
  textuell ziehen, ohne `&&`/`;` innerhalb von Anführungszeichen oder Klammer-Ausdrücken falsch zu
  treffen, und eine tragfähige Fassung verlangt eine Zerlegung der Zeile statt einer
  Übersprung-Regel. Dann ist es ein anderer Slice als dieser.
- `in-progress` → `open` (blockiert — Carveout?): Die zwei Spec-Zeilen lassen sich ohne eine
  Entscheidung über das Rollen-Eigentum nicht schreiben — dann wartet der Slice auf
  [slice-151](slice-151-spec-straten-haben-eine-schreibende-rolle.md), und **das** ist der Blocker,
  nicht der Code.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(1)** Die drei Gegenbeispiele sind je einmal rot gesehen und als
Fall abgelegt, `make gates` ist grün. **(2)** Ein Lauf über einem frischen Strom zeigt für ein
`cd … && <programm>`-Kommando das **Programm** im Feld `program` — gemessen, nicht behauptet.
Dazu der Lerneintrag in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke).

**Verhältnis zu [slice-203](slice-203-der-laufende-agent-wird-sichtbar-waehrend-er-laeuft.md):**
203 baut die Sicht, dieser Slice macht sie aussagekräftig — eine Live-Sicht, die bei 38 % der
Aufrufe „cd" anzeigt, sagt dem Beobachter nichts. **Die Abhängigkeit ist eingetragen, aber sie
hängt nicht:** 203 ist auch mit dem heutigen Wert nützlich, nur ärmer, und dieser Slice ist ohne
203 ebenso lieferbar. Keiner der beiden wartet auf den anderen — sonst wären es zwei
Zombie-Slices (Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Segment-Trennung öffnet die fail-closed-Lücke.** Wird die Zuweisungs-Prüfung beim
  Segment-Wechsel nicht mitgenommen, landet ein Token-Wert wieder im Log — der Fall, dessen
  Behebung der heutige Kommentar dokumentiert. Das zweite Gegenbeispiel in §2 ist genau dieser
  Wächter. — **Ausgang:** <offen>
- **`&&` und `;` sind Text, nicht Struktur.** Innerhalb von Anführungszeichen, in einem
  `find -exec`-Ausdruck oder in einer Subshell trennen sie kein Segment. Eine Übersprung-Regel
  kann hier danebengreifen — die Rückführung in §4 nimmt den Fall auf. — **Ausgang:** <offen>
- **Der Bestand mischt danach zwei Bedeutungen.** Spans vor und nach diesem Slice tragen
  dasselbe Feld mit verschiedener Regel; ein Leser, der über die Zeit vergleicht, sieht einen
  Sprung, der keine Verhaltensänderung ist. Kein Feld trägt die Fassung.
  — **Ausgang:** <offen>
- **Für das berührte Spec-Stratum benennt keine Quelle eine schreibende Rolle.** Der Slice ändert
  zwei Zeilen in Rang 2 der Source Precedence, ohne dass gesagt ist, wer das darf. Adresse:
  [slice-151](slice-151-spec-straten-haben-eine-schreibende-rolle.md). — **Ausgang:** <offen>

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
Setzung 2, gelesen am gemergten Stand vom 2026-09-08). Diesen Vorgang betreffen:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `anweisungssatz-eigentum-ohne-quelle` | 5× | geplant | **unmittelbar** — dieser Slice schreibt in ein Stratum ohne benannte schreibende Rolle; ihr `state.md` nennt bereits `slice-151` als Adresse, und §1 verweist dorthin, statt die Frage still zu entscheiden |
| `zusage-ohne-herstellbares-gegenbeispiel` | 2× | offen | die drei Gegenbeispiele in §2 sind der Regelfall dieser Klasse; das zweite (fail-closed pro Segment) ist das, an dem sie sich entscheidet |
| `neuer-waechter-ohne-mutations-fall` | 1× | offen | die neue Zusage braucht ihren Fall in `test/mutations/`, sonst ist sie unbewacht |
| `zusage-nennt-sensor-der-form-nicht-sieht` | 9× | geplant | der Funktionskopf nennt seinen Geltungsbereich; wird die Segment-Regel ergänzt, ohne den Kommentar mitzunehmen, ist es genau diese Klasse — Adresse `slice-181` |
| `vollstaendigkeits-zusage-misst-falsche-ebene` | 2× | offen | die Ebenen-Aussage im Kopf (Dogfood **und** emittiert, über den Träger statt über eine Vorlage) ist genau die Stelle, an der diese Klasse auftritt |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 3× | offen | über der Schwelle: jede Zahl dieses Plans steht neben dem Kommando, das genau sie ausgibt |

**Zwei Einträge tragen bereits einen Ausgang** (`anweisungssatz-eigentum-ohne-quelle`,
`zusage-nennt-sensor-der-form-nicht-sieht` — beide `geplant` mit Kennung); dieser Slice ändert ihn
nicht. **Ein Eintrag steht über der Schwelle** (`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`)
und wartet auf den Lese-Schritt; dieser Slice weist ihm keinen Ausgang zu und erhöht ihn nicht
vorab. Alle Bezeichnungen sind **zitiert**, nicht neu formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.
