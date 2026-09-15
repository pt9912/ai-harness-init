# Verifikation `slice-226-implementer-anweisungssatz-zieht-nach` — beide Liefer-Punkte tragen, drei Grenzen benannt

**Rolle:** Verifier · **Datum:** 2026-09-15 · **Geprüfter Stand:** `040ba0f7` (Umsetzung `bbd10ea2`,
Review Runde 1 `e8a8187a`, Implementer-Nachzug `b053b205`, Planner-Nachzug `89919a1a`, Runde 2
`adc04622`, Planner-Nachzug `040ba0f7`) · **Prüfgegenstand:** §2 Definition of Done gegen den
tatsächlichen Stand, dazu §1, §3, §5, §6, §8 des Plans — **nicht** der Plan gegen sich selbst (das
war der Reviewer) · **Reviews:** `2026-09-15-slice-226-implementer-anweisungssatz-zieht-nach`
(Runde 1: 0 HIGH · 2 MEDIUM · 0 LOW · 3 INFO, blockierend) und dieselbe Kennung `-r2` (0 HIGH ·
0 MEDIUM · 0 LOW · 2 INFO, nicht blockierend).

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an keinem der zwei
Implementer-Commits, an keinem der vier Planner-Commits, an keiner der zwei Review-Runden und an
keiner Datei des Slice etwas verfasst — kein Satz des Anweisungssatzes, keine Plan-Zeile, kein
Review-Befund, kein Kommentar. Er hat gelesen und Sensoren gefahren.

**Offengelegt — was dieser Lauf am Baum getan hat.** Drei Mutationen am **Gegenstand** sind an
`/tmp`-**Kopien** von `.claude/commands/implement-slice.md` gefahren worden (`/tmp/mut.md`,
`/tmp/mutB.md`, `/tmp/mutC.md`); die Sonde selbst ist dort in der Form gefahren, die die DoD nennt
(`git grep -cE … -- <datei>` über `git -C /tmp grep --no-index`, gleiche Implementierung, gleiche
Zählung, gleicher Exit-Code). Am **Repo** ist keine Mutation angewandt worden;
`git status --porcelain` war vor und nach jeder Messung leer. `make gates` und `make docs-check`
liefen über den Hauptbaum. Er trug zum Messzeitpunkt den Commit `25ac0b5c` eines **parallelen
Planner-Laufs** (`docs/plan/planning/open/slice-e2e-abdeckung-ist-deklariert-und-erzeugt.md`) — er
ist in keiner Zusicherung dieses Berichts enthalten, und die von ihm ausgelöste Wanderung der
`docs-check`-Dateizahl (1418 → 1419) ist nicht dem Slice zugeordnet.

**Ausgenommener Gegenstand — nicht geprüft, mit Grund.** Die **Closure** (§7, Beobachtungs-Register,
§6-Ausgänge, DoD-Häkchen, `git mv`) ist Planner-Arbeit nach [`AGENTS.md`](../../AGENTS.md) §3.10 und
war nicht Gegenstand dieses Auftrags. Der Slice des parallelen Planner-Laufs ebenso — fremde,
laufende Arbeit.

**Zitier-Form:** Kennung statt Adresse für alles, was der Prozess bewegt; ortsfeste Code-Pfade als
Inline-Code. Der geprüfte Gegenstand wird über seinen **Stand** festgehalten, nicht über seinen
Lifecycle-Pfad.

---

## Ergebnis in einer Tabelle

| §2 DoD-Punkt | Verdikt |
|---|---|
| **Liefer-Punkt 1** — vier Plan-vor-Code-Blöcke, je an ihrer Stelle, Beleg Form-Vergleich | **erfüllt** (§2.1) |
| **Liefer-Punkt 2** — Notations-Sonde EXIT 1, beide Schreibweisen, Prüfbereich eine Datei | **erfüllt** (§2.2) |
| `make gates` grün | **erfüllt** (§2.3) |
| Review durchgeführt, Report unter `docs/reviews/`, kein blockierender Befund | **erfüllt** (§2.4) |
| Doku-Update: kein öffentlicher Vertrag berührt | **erfüllt** (§2.5) |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **nicht fällig** — Planner (`AGENTS.md` §3.10) |
| Reconciliation-Register: entfällt | **erfüllt** (§2.6) |
| Beobachtungs-Register (`../observations/`) fortgeschrieben | **nicht fällig** — Planner |
| Jedes Risiko aus §6 trägt einen Ausgang | **nicht fällig** — Planner; §6 führt alle drei als *offen bis zur Closure* |
| Die drei Paarungen sind getragen | **nicht fällig** — im Wellen-Repo die Welle-Closure (Modul 6) |

**DoD-Verletzung: keine.** Beide slice-eigenen Liefer-Punkte tragen am Stand, die vier
Prozess-Punkte tragen oder sind noch nicht fällig.

**Befunde eigener Klasse (Verifier, keine DoD-Verletzung): zwei Grenzen und ein Plan-Drift** —
eine falsche Fundstellen-Angabe für einen der vier Blöcke (V-1), eine Zusage breiter als ihr
Rot-Beleg ohne Wächter (V-2), und die nicht benannte Menge hinter einer Stellen-Nennung (V-3).
Alle drei sind Befunde **über den Plan bzw. über den Beleg**, keiner widerlegt das Gelieferte.

---

## 1. §5 Closure-Trigger — beide Kriterien

**Kriterium (1): beide Liefer-Punkte belegt, je Block eine benannte Fundstelle, Notations-Kommando
EXIT 1, `make gates` grün.** Vier von vier Teilen tragen: §2.1 (Fundstellen + Form-Vergleich), §2.2
(EXIT 1), §2.3 (`make gates` EXIT 0). **Erfüllt.**

**Kriterium (2): Review-Report unter `docs/reviews/`, kein blockierender Befund.** Vorhanden:
`2026-09-15-slice-226-implementer-anweisungssatz-zieht-nach-r2.md`, Verdikt *„Merge-blockierend:
nein … **0 HIGH · 0 MEDIUM · 0 LOW · 2 INFO**"*, Summary-Tabelle gelesen. Die zwei MEDIUM der
Runde 1 sind an zwei getrennten Commits gezogen (`b053b205` Implementer für F-1, `89919a1a` Planner
für F-2/F-4). **Erfüllt.**

Dazu der Lerneintrag (§7) und die §6-Ausgänge — **nicht fällig**, Planner.

---

## 2. Je DoD-Punkt

### 2.1 Liefer-Punkt 1 — die vier Blöcke, an ihrer Stelle, mit Form-Vergleich

**Der Form-Vergleich selbst gefahren, gegen beide Stände.** Der Bezug des Slice ist
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit): der Abgleich läuft gegen den
committet vendored Baum, netzlos. Der vendored Baum ist gegen den lokalen Kurs-Klon gegengehalten —
er weicht vom Tag `v6.8.0` in **genau einer** Zeile ab (dem Quellen-Kommentar, den das Release-Asset
auf eine absolute URL umschreibt), der Regelwerkstext ist identisch:

```sh
git -C /Development/KI/ai-harness-course show v6.8.0:lab/regelwerk/modul-09-implementierung.md > /tmp/kurs9.md
diff /tmp/kurs9.md .harness/baseline/v6.8.0/regelwerk/modul-09-implementierung.md | grep -c '^[<>]'   # 2
```

**Der Delta-Block steht in der Ziel-Fassung und nicht in der Ausgangs-Fassung** — vier Anker, je
Block einer, über beide Tags:

```sh
cd /Development/KI/ai-harness-course
for p in 'Die Tests-Zeile bindet an die Akzeptanzkriterien' \
         'Betrifft dieselbe Ursache viele gleichrangige Dateien' \
         'Die Plan-Ausgabe in Schritt 4 nennt Out-of-Scope' \
         'Der Plan lebt in §3 des Slice-Plans'; do
  printf '%s ' "$(git grep -c "$p" v6.0.0 -- lab/regelwerk/modul-09-implementierung.md 2>/dev/null || echo 0)"
  printf '%s ' "$(git grep -c "$p" v6.8.0 -- lab/regelwerk/modul-09-implementierung.md 2>/dev/null || echo 0)"
  echo "$p"
done
# 0 1 Die Tests-Zeile bindet …      · 0 1 Betrifft dieselbe Ursache …      · 0 1 Out-of-Scope …
# 0 1 Der Plan lebt in §3 des Slice-Plans
git diff --shortstat v6.0.0..v6.7.2 -- lab/regelwerk/modul-09-implementierung.md   # 1 Datei, +35/−4
```

**Vier Fundstellen im Anweisungssatz, alle vier an der Stelle, die die DoD nennt:**

| Block | Fundstelle im Anweisungssatz | Stelle, die die DoD nennt | Modul-Abschnitt `v6.8.0` |
|---|---|---|---|
| Tests-Zeile bindet an die Akzeptanzkriterien-ID | `.claude/commands/implement-slice.md:82` | „bei der Testdatei-Zeile der Plan-Ausgabe" | §Minimal Agent Workflow, Zeile 27 |
| Eine Ursache über viele gleichrangige Dateien | `:87` | „daneben" | §Minimal Agent Workflow, Zeile 35 |
| Plan-Ausgabe in Schritt 4 nennt Out-of-Scope | `:92` | „bei Schritt 4" | §Minimal Agent Workflow, Zeile 43 |
| Der Plan lebt in §3, nicht im Chat-Verlauf | `:111` | „bei den Rücksprüngen" | **§Rücksprungkanten-Regeln**, Zeile 81 |

Block 1–3 stehen in Punkt 13 der Datei, unter der Überschrift `## Plan vor Code (Modul 9, Schritt 4
— nicht optional)` — das ist Modul-9-Schritt 4, also die Stelle, an die das Modul sie bindet. Block 4
steht unmittelbar unter dem Absatz `**Plan-Defekt-Rücksprungkanten (Modul 9):**` und damit bei den
Kanten 5→4 und 6→4. Die vier Sätze sind sinntreue Übertragungen, keine Zitate; die Adressen, die sie
nennen (*Schritt 3*, *Schritt 4*, *§1*, *§3*, *5→4*, *6→4*), lösen im Anweisungssatz auf.

**Erfüllt.** Der Form-Vergleich ist damit von diesem Lauf unabhängig gefahren — und er deckt Block 4
in **einem anderen Abschnitt** als dem, den §2 als Vergleichsbereich nennt (V-1).

### 2.2 Liefer-Punkt 2 — die Notations-Sonde

**Kommando am geprüften Stand, beide Schreibweisen, der eine Prüfbereich:**

```sh
git grep -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- .claude/commands/implement-slice.md
# (keine Ausgabe)   EXIT 1
```

**Beide Schreibweisen einzeln, damit der Prüfumfang sichtbar ist:**

```sh
git grep -nE 'slice-<NNN>|welle-<NN>' -- .claude/commands/implement-slice.md   # EXIT 1
git grep -nE '<slice-NNN>|<welle-NN>' -- .claude/commands/implement-slice.md   # EXIT 1
```

**Die Zahl des Anlass-Blocks am genannten Vor-Stand trägt** — und sie ist die der **breiten** Sonde,
nicht der schmalen; genau das war der Runde-1-Befund F-2:

```sh
git grep -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' bbd10ea2^ -- .claude/commands/implement-slice.md   # 5
git grep -cE 'slice-<NNN>|welle-<NN>'                       bbd10ea2^ -- .claude/commands/implement-slice.md   # 3
```

**Die zwei Stellen, an denen die zwei sich unterscheiden, sind genau die geklammerte Form**
(`SLICE=<slice-NNN>` in ehemals Zeile 58 und 181) — die schmale Sonde sah drei, die breite fünf.

**Erfüllt.** Der Anlass-Block nennt seinen Ref (`bbd10ea2^`) ausdrücklich und die Zahl daneben.

### 2.3 `make gates` grün

```text
$ make gates
span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
EXIT 0
```

**EXIT 0**, entscheidende Zeile der Schluss-Sensor `span-check`; `docs-check` ist in der Kette
mitgelaufen (`d-check: 1419 Datei(en) geprüft, 0 Befund(e)`). Gefahren über `25ac0b5c`; dessen
einziger Unterschied zu `040ba0f7` ist die Datei des fremden Planner-Laufs, und der Gegenstand ist
byte-identisch:

```sh
git diff --stat 040ba0f7 HEAD -- .claude/commands/implement-slice.md   # (leer)
```

**Erfüllt.**

### 2.4 Review durchgeführt, Report liegt vor, kein blockierender Befund

Beide Runden liegen unter `docs/reviews/`, die zweite trägt die Summary-Tabelle 0/0/0/2 und das
Verdikt *nicht blockierend*; die zwei MEDIUM der ersten Runde sind an den zwei Commits gezogen, die
die Übergabe nannte. **Erfüllt.**

### 2.5 Doku-Update: kein öffentlicher Vertrag berührt

Die Source Precedence ([`AGENTS.md`](../../AGENTS.md) §2) führt **keinen** Rang für
`.claude/commands/` — die Datei ist Lauf-Instruktion, wie §2 es sagt. Die kanonischen Stellen, die
den Anweisungssatz **erwähnen**, sind gegen den neuen Text gehalten:

```sh
git grep -n 'implement-slice' -- '*.md' ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning'
```

- [`ADR-0020`](../../docs/plan/adr/0020-emittierte-modul-15-regeln.md) Zeile 547 stützt sich darauf,
  dass die Datei *„das Muster `make verify-*` zitiert und damit kein Ziel behauptet"* — das Muster
  steht unverändert im Text (Zeile 130).
- [`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Zeile 166
  zitiert den Eröffnungssatz der Datei — unverändert.
- Das Benutzerhandbuch führt die drei Commands in einer **Historien**-Zeile (Fassung 1.13) —
  Zeitdokument, kein Vertrag.

**Erfüllt.**

### 2.6 Reconciliation-Register: entfällt

```sh
ls docs/plan/planning/reconciliation.md
# ls: Zugriff auf '…' nicht möglich: Datei oder Verzeichnis nicht gefunden
```

**Erfüllt** — das DoD-Item beschreibt genau diesen Leerzustand.

---

## 3. Modul 11 §Bewusstes Brechen — die zwei Rot-Belege des Umsetzers

Der Slice beruft sich an **beiden** Liefer-Punkten auf Sonden. Nachgefahren, je einmal.

### 3.1 Liefer-Punkt 2 — die Sonde hat beide Zähne (rot gesehen)

Zwei Mutationen, je eine pro Schreibweise, an der Stelle, an der die **schmale** Sonde blind war
bzw. an der Form, die sie sieht:

| Mutation an einer `/tmp`-Kopie | DoD-2-Sonde (beide Formen) | alte schmale Sonde (nur spitz) |
|---|---|---|
| `SLICE=slice-<Kennung>` → `SLICE=<slice-NNN>` (Zeile 58) | **EXIT 0**, `mut.md:1` | EXIT 1 — **blind**, genau F-2 |
| `evidence/slice-<Kennung>.md` → `evidence/slice-<NNN>.md` (Zeile 195) | **EXIT 0**, `mutB.md:1` | EXIT 0 |
| gelieferter Stand, unverändert | EXIT 1 | EXIT 1 |

```sh
git -C /tmp grep --no-index -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- mut.md    # mut.md:1,  EXIT 0
git -C /tmp grep --no-index -cE 'slice-<NNN>|welle-<NN>'                       -- mut.md    # (leer),    EXIT 1
git -C /tmp grep --no-index -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- impl-orig.md  # (leer), EXIT 1
```

**Trägt die behauptete Ursache — ja, und sie trägt sie allein.** Die Mutation ist die **Wiederkehr
der alten Notation**, nichts sonst; der rote Lauf meldet die Zahl 1 auf genau der mutierten Datei,
der grüne Lauf auf der unveränderten Kopie nichts. Die schmale Sonde bleibt auf der ersten Mutation
grün — das ist der Beleg dafür, dass die Erweiterung aus F-2 **nicht kosmetisch** war, sondern eine
Klasse geschlossen hat. **Der Rot-Beleg gehört zum gefixten Kommando; der Rot-Beleg des Umsetzers
gehörte zu einem früheren Prüfumfang, und beides ist konsistent.**

### 3.2 Liefer-Punkt 1 — der Rot-Beleg trägt die Existenz, nicht die Stelle

Der Umsetzer belegt die vier Blöcke über vier block-eigene Wörter; die Reihe ist vom Reviewer schon
als abweichend gemeldet (er erhielt keinen Bericht mit Anker-Satz). Eigene Messung, gleiche Form,
ein Wort je Block, Vor-Stand gegen gelieferten Stand:

```sh
for w in Akzeptanzkriterien gleichrangig Out-of-Scope Chat-Verlauf; do
  git grep -c "$w" bbd10ea2^ -- .claude/commands/implement-slice.md    # 0 / 0 / 0 / 0
  git grep -c "$w"           -- .claude/commands/implement-slice.md    # 1 / 2 / 2 / 1
done
```

**Der Rot-Beleg reproduziert dem Sinne nach (0/0/0/0 → 1/2/2/1) und trägt die behauptete Ursache für
die *Existenz*-Hälfte der Zusage:** die Blöcke sind neu in dieser Datei, keiner war vorher da. **Er
trägt die *Stellen*-Hälfte nicht** — und die ist die Hälfte, die die DoD formuliert (*„je an der
Stelle, an der der Lauf sie braucht"*). Nachgefahren: ein Block wird entfernt, und **nichts** fällt,
was ein Sensor fährt:

```sh
# /tmp/mutC.md — der Block „Der Plan lebt in §3 des Slice-Plans" (Zeile 111-113) fehlt
git -C /tmp grep --no-index -cE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- mutC.md   # (leer), EXIT 1
grep -c 'Chat-Verlauf' /tmp/mutC.md                                                          # 0
```

Die DoD-2-Sonde bleibt **grün**, während ein Liefer-Punkt-1-Block fehlt; gefallen ist allein ein
Ad-hoc-Wort-`grep`, das **kein Ziel, kein Test und kein Mutations-Fall** fährt. Das ist **keine
DoD-Verletzung**: DoD-1 schreibt sich als Beleg ausdrücklich einen **Form-Vergleich von Hand** mit
benannter Fundstelle vor, keinen Sensor — und der ist gefahren (§2.1). Es ist die benannte Grenze
**V-2** (§4).

---

## 4. Befunde eigener Klasse (Verifier, keine DoD-Verletzung)

### V-1 — die Fundstellen-Angabe des vierten Blocks ist falsch (Plan-vs-Artefakt-Drift)

`slice-226` §1 Zeile 79 sagt über die vier Blöcke: *„alle im Abschnitt §Minimal Agent Workflow (8
Schritte)"*. **Für drei stimmt das, für den vierten nicht.** Gemessen im vendored Baum, Stand
`v6.8.0` (und ebenso am Kurs-Tag `v6.7.2`):

```sh
grep -n '^### ' .harness/baseline/v6.8.0/regelwerk/modul-09-implementierung.md | head -3
#  5:### Kernidee · 10:### Minimal Agent Workflow (8 Schritte) · 75:### Rücksprungkanten-Regeln (Modul 9)
grep -n 'Der Plan lebt in §3' .harness/baseline/v6.8.0/regelwerk/modul-09-implementierung.md   # 81
```

Der Satz *„Der Plan lebt in §3 des Slice-Plans"* steht in **§Rücksprungkanten-Regeln (Modul 9)**,
nicht im Minimal Agent Workflow — er ist zwischen `v6.0.0` und `v6.7.2` **dort** hinzugekommen, die
drei übrigen in §Minimal Agent Workflow. Dasselbe gilt für die Fundstelle, auf die §2 den
Form-Vergleich stellt: `§Minimal Agent Workflow` ist als Vergleichsbereich zu eng für Block 4.

**Was das nicht ist:** kein Defekt am Gelieferten — der Anweisungssatz führt Block 4 an der richtigen
Stelle („bei den Rücksprüngen", §2 sagt das selbst), und der Review-Report der Runde 1 vergleicht in
seinem §4/§5 ausdrücklich gegen **beide** Abschnitte („§Minimal Agent Workflow **und**
§Rücksprungkanten-Regeln"), die Bestätigung steht also. Auch die Commit-Message `bbd10ea2` trägt die
zu enge Angabe.

**Was es ist:** eine Plan-Aussage über den Gegenstand, die der Bestand widerlegt — dieselbe Klasse,
die §2 bei Liefer-Punkt 1 mit *„ein Block ohne Fundstelle ist der Befund, keine Auslassung"* für
sich selbst adressiert. **Zu heilen beim Planner, nicht hier** ([`AGENTS.md`](../../AGENTS.md) §3.10);
sie verschiebt keine Abnahme, weil §2 den vierten Block korrekt verortet.

### V-2 — die Zusage von Liefer-Punkt 1 ist breiter als ihr Rot-Beleg, und der Wächter fehlt

§2 Liefer-Punkt 1 sagt zwei Dinge: *dass* die vier Blöcke dastehen, und *dass* sie je an der Stelle
stehen, an der der Lauf sie braucht. Der vorgelegte Rot-Beleg (§3.2) deckt das erste, nicht das
zweite; §3.2 zeigt, dass kein Sensor das zweite deckt. §6 Risiko 1 benennt genau das (*„Der Nachzug
hat keinen Wächter"*, Ausgang: offen bis zur Closure), §1 schließt den Sensor-Bau ausdrücklich aus
(*„Es wäre ein anderer Vorgang"*), und [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
wird nicht verletzt — es wird **keine** Deckung behauptet. **Benannt, nicht geschlossen:** das ist
zulässig und nicht verschwiegen. Es gehört aber in die Closure-Notiz, damit die Lücke nicht als
„rot gesehen" gelesen wird.

### V-3 — eine Stellen-Nennung, die Menge dahinter ist größer (INFO)

§2 Liefer-Punkt 2 sagt: *„eine lebende Fundstelle außerhalb (`Makefile:340`) ist benannt, nicht still
gelassen"*. **Die Stelle trifft zu** (`Makefile:340`, Hilfetext des `slice-mv`-Ziels, führt
`SLICE=<slice-NNN>`), **die Menge ist größer.** Gemessen über beide Schreibweisen, ohne den vendored
Baum und ohne die Review-Zeitdokumente:

```sh
git grep -lE 'slice-<NNN>|welle-<NN>|<slice-NNN>|<welle-NN>' -- ':!.harness/baseline' ':!docs/reviews' | wc -l   # 52
```

Nach Klassen durchgesehen, damit der Satz nicht als Vollständigkeits-Aussage stehenbleibt:

| Klasse | Beispiel | Trägt die Fundstellen-Aussage? |
|---|---|---|
| **lebende Regel, die die **Invokations-Form** vorschreibt** | `Makefile:340` | **nein** — die einzige, die sie meint; von §2 benannt |
| Regel-Text über die **vorbestehende** Form | `MR-057`, `MR-028`, `MR-031` Setzung 2, `AGENTS.md:282` (Suchmuster-Zitat, das §3.7 ausdrücklich stehen lässt) | nein — sie **zitieren** die alte Form als das, was sie regeln, und [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Satz 1 lässt den Bestand ausdrücklich stehen |
| **eingefroren** (§3.4 / §3.11) | ADRs `0030`, `0031`, `0041`; `docs/plan/planning/done/**` | nein — ab `Accepted` bzw. ab Closure nicht mehr Arbeitsgegenstand |
| **emittierte Ebene** | `internal/emit/templates/commands/implement-slice.md`, `…close-welle.md` | nein — in §1 mit **6** Vorkommen benannt und mit dem Satz, daß sie **keinen** Folge-Träger hat |
| **Meta-Notation in offenen Plänen** | `docs/plan/planning/open/**` | nein — von §2 DoD-2 und vom Review-Befund N-1 benannt |

```sh
git grep -cE 'slice-<NNN>|welle-<NN>' -- internal/emit/templates | awk -F: '{s+=$NF} END{print s}'   # 6
git grep -n 'SLICE=' -- internal/emit/templates/                                                   # (leer)
```

**Ergebnis der Durchsicht: keine unbenannte lebende Fundstelle der Invokations-Form bleibt übrig** —
die Nennung ist richtig, sie nennt nur **einen** ihrer vier Gründe. Kein Mangel, eine Grenze der
Formulierung ([`MR-055`](../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).

---

## 5. §1-Abgrenzung am Diff

Am Diff der sechs Commits geprüft, beide Richtungen:

```sh
git diff --stat bbd10ea2^ 040ba0f7
```

- `.claude/commands/implement-slice.md` — **nur** in `bbd10ea2` und `b053b205`, beide vom
  Implementer. Der Liefergegenstand aus §3, sonst nichts.
- `docs/plan/planning/in-progress/slice-226-…md` — **nur** in den Planner-Commits `89919a1a` und
  `040ba0f7` (die zwei Übergaben der Review-Runden).
- `docs/reviews/2026-09-15-slice-226-…{,-r2}.md` — die zwei Review-Reports.

**Nicht berührt, wie §1 es verlangt:** `internal/emit/templates/commands/**` (keine Datei darunter
im Diff), `Makefile`, `harness/tools/slice-mv.sh`, `.claude/commands/plan-welle.md`,
`.claude/commands/close-welle.md`, `.harness/skills/reviewer.md` — die zwei anderen Wellen-Mitglieder
und der Reviewer-Skill bleiben unangetastet. **Kein Zug an einem fremden Gegenstand.**

---

## 6. Plan-vs-Artefakt-Diff (beide Richtungen)

**Gebaut wie geplant:** der einzige §3-Eintrag (`.claude/commands/implement-slice.md`, *update*) ist
der einzige Liefergegenstand; die vier Blöcke stehen darin, die Notation ist auf die Ziel-Form
gezogen; kein Gate, kein Sensor, kein Folge-Artefakt ist entstanden. Die Reihenfolge der Commits
hält die Rollen-Grenze ein: Umsetzung + F-1 im Implementer-Kontext, die zwei die **Abnahme**
treffenden Nachzüge (F-2, F-4 an §2/§5) im Planner-Kontext, keine Hard Rule, kein Adaptions-Eintrag,
kein Gate-Index im Diff ([`AGENTS.md`](../../AGENTS.md) §3.8 hält).

**Gebaut, aber nicht niedergeschrieben im Plan:** nichts Wesentliches. Der F-1-Nachzug
(`b053b205`) fügt dem Out-of-Scope-Block die Rollen-Zuordnung aus §3.10 hinzu — das ist die
**Auflösung** des Runde-1-Befunds, nicht eine stille Erweiterung, und sie hat ihr Original in
[`AGENTS.md`](../../AGENTS.md) §3.10, also nicht die von
[`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 2
adressierte Lage (bindende Aussage ohne kanonische Quelle).

**Geplant, aber abweichend ausgeführt:** die Fundstellen-Angabe aus §1 (V-1) — der vierten Block
liegt in einem anderen Modul-Abschnitt als dort behauptet.

---

## 7. Rest-Unsicherheit

- **Die drei Rot-Belege habe ich an `/tmp`-Kopien gefahren, nicht am Repo-Baum.** Der Zahn ist
  derselbe (gleiches Muster, gleiche Zählung, gleicher Exit-Code, `git grep` selbst), die
  **Verdrahtung** der DoD-2-Sonde am echten Pfad ist zusätzlich am unveränderten Stand gefahren
  (EXIT 1, §2.2). Ein Rest bleibt: ich habe keinen roten Lauf **im** Repo gesehen — die
  Mutation wäre für die Dauer des Laufs eine Änderung des Gegenstands gewesen, und der Stop-Hook
  verlangt für jeden Abschluss einen deckungsgleichen Stempel.
- **Was ich nicht geprüft habe, weil es nicht mein Gegenstand ist:** die Wirkung der vier Blöcke auf
  einen echten Implementer-Lauf (kein Gate liest Prosa), die zwei INFO der Runde 2 als
  Review-Qualität (nur ihre Ziehung, §8), und die emittierte Ebene (§1 schließt sie aus, `make
  full-smoke` ist dort der Beleg — **nicht gefahren**, weil außerhalb des Lieferumfangs und ohne
  einen benannten Träger für diese Fundmenge).
- **Der Baum hat sich während des Laufs bewegt:** `25ac0b5c` eines parallelen Planner-Laufs liegt
  über dem geprüften Stand. Er berührt den Gegenstand nicht (`git diff --stat 040ba0f7 HEAD --
  .claude/commands/implement-slice.md` leer); die `docs-check`-Dateizahl wanderte dadurch von 1418
  auf 1419 und ist keiner Zusicherung dieses Berichts zugeordnet.
