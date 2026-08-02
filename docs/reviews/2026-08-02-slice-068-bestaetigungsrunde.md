# Review slice-068 — Bestätigungsrunde zum Verdikt vom selben Tag (Modul 10)

**Gegenstand:** Commit-Range `42de3ff..HEAD` (`1a381b1`), zwei Commits: `13e9ac9` (Implementer —
H1, M1, M2) und `1a381b1` (Planner — M5, M3, L2, DoD-Nachzug). Drei Dateien, 46 hinzugefügte
Zeilen, kein Code.

**Datum:** 2026-08-02 · **Rolle:** Reviewer, frischer Kontext · **Baseline:** Agents-Regelwerk
v3.5.2, Modul 10 §Ziel-Form.

**Schnitt:** eng. Geprüft werden H1, M1, M2, M3, M5, L2, die Verortung von M4, der Abgleich
Plan gegen umgesetzten Text (DoD (1), DoD (2)) und die Frage, ob beim Beheben Neues entstanden
ist. **Nicht geprüft:** L1, L3, I1 und die Sache hinter M4.

**Pflicht-Kontext (fünf Punkte + Slice-Plan):**

- **Diff/Range:** `42de3ff..HEAD`; `42de3ff` ist der Review-Commit, `9eb07a4` der begutachtete
  Stand. Baum sauber, HEAD `1a381b1`.
- **`LH-*`:** keine — die `requirement`-Achse bleibt leer und begründet (Dogfood-Prozessebene).
- **Aktive ADRs:** `ADR-0011` (Accepted, im Commit referenziert), `ADR-0013` (Accepted),
  `ADR-0014` (Accepted). `ADR-0012` steht weiter auf **Proposed** (gemessen am Kopf, Zeile 3).
- **Hard Rules:** `AGENTS.md` §3; tragend §3.4, §3.5, §3.6.
- **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-08-02-slice-068-review.md`
  (1 HIGH · 5 MEDIUM · 3 LOW · 1 INFO) sowie die slice-060-/slice-076-Reihe. Wiederkehrendes
  Muster dort: Aussage über eine Quelle ohne Messung der Quelle, und Wachstum durch
  Danebenschreiben. Beide sind in dieser Runde **nicht** erneut aufgetreten (N4, N9).
- **Slice-Plan:** `docs/plan/planning/in-progress/slice-068-rollen-arbeit-laeuft-als-rolle.md`.

---

## Befund je beauftragtem Punkt

### H1 — erledigt

Die Zusage sagt jetzt, was die Größe misst, und nennt beide Formen getrennt.

`spec/spezifikation.md:266-267` sagt statt *„Sichtbar wird der Bruch **allein** an der
Berichtsgröße"* nun: *„Verhindert wird er von nichts, und **sichtbar wird nur eine seiner beiden
Formen** — welche, sagt der nächste Punkt."* Der Folgeabsatz (`:269-277`) führt beide aus:
*„**Sichtbar ist die eine Form:** wer Rollen-Arbeit delegiert, aber nicht unter dem Rollen-Typ,
dessen Lauf fällt in den Sammelposten und hebt den Anteil — groß heißt **insoweit** ‚nicht
gelebt'"* gegen *„**Die andere bleibt unsichtbar:** wer den Schritt selbst im Haupt-Kontext tut,
erzeugt keinen `Agent`-Span und steht weder im Zähler noch im Nenner … **klein heißt nicht
‚gelebt'**"*.

Beleg, dass die Begründung an ihrer Quelle hängt: *„die Bilanz rechnet über Subagenten-Läufe
(Abweichung 6)"* gegen `spec/spezifikation.md:516-517` — *„Jede Token-Bilanz aus diesen Spans ist
damit eine Bilanz über **Subagenten-Läufe**"*. Trifft wörtlich.

Zweite Fundstelle mitgezogen: `docs/plan/planning/welle-09-modul-15-konformitaet.md:95`
führt *„ablesbar ist die Regel dahinter **zum Teil** an einer Berichtsgröße"* statt *„allein"*.
Der Sensor-Ausschluss der Zelle bleibt davon getragen: weniger Ablesbarkeit schwächt das Argument
„ein Bericht ist kein Wächter" nicht.

Gegenprobe auf verbliebene Ausschließlichkeit — `grep -nE 'allein|nur dort|ausschließlich'`:
`spec/spezifikation.md` fünf Treffer (140, 409, 495, 512, 619), keiner betrifft die
Berichtsgröße; `welle-09-modul-15-konformitaet.md` 0 Treffer; im Slice-Plan ein Treffer, und der
ist die **Verneinung** (`:100` *„nicht an der Größe allein"*).

### M1 — erledigt, Ersparnis gemessen

`spec/spezifikation.md:282-285` führt jetzt Überschrift plus Zeiger in der Form, die der
Abschnitt selbst führt (`:197` *„im Einzelnen in **Abweichung 5**, hier nicht wiederholt"*):
*„Die Falle: ein Span kann einen erfassten Wert tragen und trotzdem ein zählerloser Lauf sein —
im Einzelnen in **Abweichung 5 (3)(a)**, hier nicht wiederholt."*

Byte-Ersparnis, Befehl und Ergebnis:

    awk 'NR>=278 && NR<=287' <alt> | wc -lc   ->  10   849
    awk 'NR>=282 && NR<=285' <neu> | wc -lc   ->   4   345

**−6 Zeilen / −504 Byte** an dieser Stelle. Die Ziel-Adresse des Zeigers trifft: `:413` beginnt
Abweichung 5, `:434` ihr Unterpunkt 3, `(a)` steht in `:434`; die Aussage selbst in `:448-451`.

Was mit den zehn Zeilen wegfiel, war die Hilfsbegründung *„beide Ausgänge sagen dasselbe"*. Sie
ist nicht ersatzlos verloren, sondern **überholt**: `:445-447` hält fest, dass die Gestalt
inzwischen im Bestand liegt (*„ein `Agent`-Span, der von den neun Werten genau `model_version`
trägt und keinen der acht"*). Die Festlegung ruht damit auf einer Beobachtung statt auf einer
Zwei-Ausgänge-Hypothese.

### M2 — erledigt

Die absolute Nebenaussage (*„ob eine Handlung im Haupt-Kontext ‚Planner-Arbeit' war, kann niemand
maschinell entscheiden"*) ist fort. Der tragende Grund steht wörtlich weiter
(`spec/spezifikation.md:261-263`): *„ein Wächter wie der für Bedingung 2 entscheidet über eine
**Aufrufform**, die ihm vor dem Start vorliegt, und hier unterbleibt gerade der Aufruf, den er
sähe."*

An ihre Stelle tritt eine Aussage, die mit Abweichung 3 zusammengeht statt gegen sie:
*„Was Abweichung 3 aus zwei erfassten Feldern ableitet, teilt den Sammelposten **im Nachhinein**
auf — eine Entscheidung vor der Handlung ist es nicht."* Abgleich gegen `:382-384`
(*„ableitbar aus bereits erfassten Feldern sind **zwei** Signale — das `slice`-Feld … und das
Schreibziel"*) und gegen `:396-397` (Splitting-Pflicht): trifft, ohne die Pflicht zu bestreiten.

Absatz 1 ist dabei **geschrumpft**: 1041 → 1019 Byte (12 → 11 Zeilen).

### M5 — erledigt; Abgleich über den gelöschten Text

Der `ENTFALLEN`-Block ist ganz weg. Maß: `awk 'NR>=92 && NR<=116' <alt> | wc -lc` → **25 Zeilen /
2041 Byte**. Ich habe ihn Posten für Posten gegen den Ist-Bestand gehalten, nicht über
Namensgleichheit:

| Aussage des gelöschten Blocks | Verbleib |
|---|---|
| der frühere DoD (2) wurde von slice-060 DoD (3) geliefert | steht in `welle-09-modul-15-konformitaet.md:158` (*„Die Haupt-Kontext-Abweichung selbst hat slice-060 DoD (3) geliefert"*) — nicht verloren, und dort am richtigen Ort |
| die Nicht-Erreichbarkeit steht als Abweichung 6 in §5 | steht im Plan `:145-146` |
| *„Abweichung 6 trägt das Verdikt permanent … sagt das inzwischen selbst und begründet es aus Modul 7"* | **falsch, korrekt entfernt.** Nachgemessen: `awk 'NR>=489 && NR<=522' spec/spezifikation.md \| grep -nEi 'permanent\|dauerhaft\|Aufwand\|entfällt\|ersatzlos\|ADR\|Modul 7\|Trigger\|Folge-Slice'` → **0 Treffer**, Exit 1. Dokumentweit `grep -nEi 'permanent\|dauerhaft\|ersatzlos\|Folge-Slice\|Auflösungs-Trigger' spec/spezifikation.md` → **genau eine** Zeile, `:485`, und die liegt in Abweichung 5 |
| Vergleich der drei Prüfschritte alt gegen Abweichung 6 (*„drei gegen drei ist ein Zufall der Zählung"*) | **nicht ersetzt — und der Gegenstand des Vergleichs existiert nicht mehr.** Die Warnung richtete sich an jemanden, der den entfallenen DoD-Punkt mit Abweichung 6 vergleicht; der entfallene Punkt steht seit dieser Runde nirgends mehr im Repo. Die drei Schritte selbst stehen autoritativ in `spec/spezifikation.md` Abweichung 6. Kein bindender Verlust |
| *„Es gibt keinen Auflösungs-Trigger mehr … wer hier einen Träger sucht, findet keinen"* | überlebt als **Eigenschaft** in `:145-148`: *„sie steht als Abweichung 6 … und nennt dort **keinen Auflösungs-Trigger**. Wer an ihr einen Träger für einen Folge-Slice sucht, findet keinen — auch nicht in diesem Plan."* Die neue Fassung ist **enger** als die alte (Aussage über Abweichung 6 statt über die Welt) und exakt das, was der Grep oben misst |

Ergebnis: **nichts Bindendes verloren.** Weggefallen sind ein Datums-Stempel, die
Entstehungs-Erzählung des Plan-Textes und eine unbelegte Fremdzuschreibung.

### M3 — erledigt, Bein für Bein

`slice-068:100` stellt die Aufnahme-Begründung neu auf. Abgleich gegen die drei Kriterien in
`spec/spezifikation.md:11-18`:

1. *„Etwas, gegen das gemessen werden kann"* ← *„gemessen wird gegen die **Festlegung** — welcher
   Lauf in den Sammelposten fällt, und was die Berichtsgröße zeigt und was nicht —, nicht an der
   Größe allein, die nur die delegierte Hälfte trägt"*. Das Bein steht jetzt auf zwei
   Definitionen, die der Auswerter aus slice-066 implementieren muss, nicht auf der Ablesbarkeit
   der Konvention. Trägt.
2. *„ohne Vertragsänderung fortschreibbar"* ← unverändert übernommen. Trägt.
3. *„die nächste Zeile seiner Tabelle verdrängt keinen anderen Text"* ← *„die nächste Festlegung
   zur Größe ist ein weiterer Punkt ihrer Liste und verdrängt keinen anderen Text"*. Am Text
   beobachtbar: die Liste steht in `spec/spezifikation.md:279` und `:282` (*„Zwei Festlegungen
   gehören dazu:"*, `:277`); ein dritter Punkt hängt an. Trägt — anders als das zurückgenommene
   *„mit jeder weiteren Rolle wachsend"*, das der Planner selbst als falsch gemessen hat
   (Rollen-Namen stehen in `:94, 372, 373, 375, 470`, keine davon im Block).

### L2 — erledigt

`slice-068:101` führt `slice-066` jetzt als **`keine Änderung`** mit Grund. Die Spur der
bewussten Nicht-Ausführung steht damit im Artefakt und friert mit der Closure als das ein, was
sie war. Der Wert ist im Rahmen des Etablierten: die `Änderungs-Art`-Spalte hat in
`.harness/baseline/v3.5.2/templates/docs/plan/planning/slice.template.md:49` kein Vokabular, und
`done/` führt neben `update`/`neu`/`refactor` bereits `entfernt` und `voraussichtlich update`.

### DoD (1) — Plan und Text sagen dasselbe

| DoD (1) verlangt | umgesetzt |
|---|---|
| `:51-52` *„Arbeit, die einer Harness-Rolle zugeordnet ist, läuft **unter dem Rollen-Typ**; der Haupt-Kontext orchestriert und ist der Sammelposten."* | `spec:259-260` **wörtlich identisch** |
| `:53-55` *„eine mechanische Durchsetzung ist **nicht möglich**, weil ein Wächter über eine **Aufrufform** entscheidet, die ihm vor dem Start vorliegt — und hier unterbleibt gerade der Aufruf, den er sähe."* | `spec:260-263`, gleicher Grund, **im selben Absatz** |
| `:58-59` kein Entscheidungs-/Planungs-Kennzeichen im bindenden Text | gemessen: `grep -nE 'slice-[0-9]\|welle-[0-9]' spec/spezifikation.md` → **0 Treffer**; `grep -nE '(ADR\|LH\|MR)-[0-9]'` → 2 Treffer, `:83` (Link nach `harness/conventions.md`, keine Entscheidungs-/Planungs-Datei) und `:657` (Historie, ausgenommen) |

Der vom Implementer protokollierte Plan-Abweichungs-Grund ist damit aufgelöst: der Plan verlangt
den zurückgenommenen Satz nicht mehr.

### DoD (2) — Punkt 2 sagt jetzt dasselbe wie der Text; zwei Reste s. B2

`slice-068:67` führt jetzt *„**„Span mit irgendeinem erfassten Wert" ist die falsche Definition
von gedeckt.**"* gegen `spec:282` *„**„Gedeckt" heißt „Span mit ZÄHLERN", nicht „Span mit
irgendeinem erfassten Wert".**"* — dieselbe Aussage, die Inversion ist weg. Punkt 1 stimmt
wörtlich überein (`:64-66` gegen `spec:279-281`, letzterer 260 Byte, unverändert).

### M4 — die Verortung trägt nur zur Hälfte (s. Finding B1)

---

## Findings

### B1 — die Wellen-Verortung widerspricht der eigenen DoD (3)

- **kategorie:** MEDIUM
- **quelle:** `AGENTS.md` §3.6 (*„die Zusage auf das einschränken, was der Code hält"*);
  `welle-09-modul-15-konformitaet.md:103` (Definition des Wertes *deklariert*)
- **pfad:** `docs/plan/planning/in-progress/slice-068-rollen-arbeit-laeuft-als-rolle.md:155-156`
  gegen `:83-85` und `docs/plan/planning/welle-09-modul-15-konformitaet.md:158`
- **befund:** §6 schließt mit *„die Festlegung dieses Slice — kein *Sensor*, und **welcher Wert
  je Abweichung** — hängt nicht daran"*. Genau dieser Wert ist der offene Posten: DoD (3)
  (`:83-85`) und die Slice-Zeile im Wellen-Plan (`:158`) legen für den Hintergrund-Teil den Wert
  *deklariert* fest, und die Wert-Tabelle definiert *deklariert* als *„bewusste Nicht-Umsetzung
  als `MR-<NNN>`"* (`welle-09:103`). Gemessen: `harness/conventions.md` führt **22**
  `MR-`Einträge und **0** Treffer für `Hintergrund` — kein Eintrag deklariert diese Abweichung.
  Der Satz zwei Zeilen darüber sagt das selbst (*„für diese Form führt die Tabelle keinen
  Wert"*). Die erste Hälfte der Verortung (*kein Sensor*) hängt tatsächlich nicht daran; die
  zweite ist der Gegenstand. Wer DoD (3) prüft, findet im selben Dokument beides: die Festlegung
  des Wertes und die Feststellung, dass es ihn für diese Form nicht gibt.
- **verifizierbar:** ja, teilweise — `grep -c '^### MR-' harness/conventions.md` → 22 und
  `grep -ci 'Hintergrund' harness/conventions.md` → 0 sind die Messung; der Widerspruch selbst
  ist am Textvergleich `:155-156` gegen `:83-85` nachzulesen, kein Gate greift.

### B2 — Plan-Text und umgesetzter Text driften in DoD (2), nachdem §1 nachgezogen wurde

- **kategorie:** LOW
- **quelle:** Maintainability; `spec/spezifikation.md:349-350` (*„derselbe Ausfall zweimal
  beschrieben wäre zwei Stellen, die auseinanderdriften"*)
- **pfad:** `slice-068-rollen-arbeit-laeuft-als-rolle.md:60-63` und `:68-77` gegen `:43-45` und
  `spec/spezifikation.md:271-276`, `:282-285`
- **befund:** Zwei Stellen sind beim Nachziehen stehengeblieben. (a) §1 führt seit `1a381b1`
  *„zum Teil ablesbar"* (`:43`), die Spezifikation *„groß heißt **insoweit** ‚nicht gelebt'"*
  (`:272-273`) — DoD (2) sagt unverändert flach *„Der Sammelposten-Anteil … ist die Messgröße:
  groß heißt ‚nicht gelebt'"* (`:61-62`), ohne die Einschränkung, die dieselbe Datei zwanzig
  Zeilen darüber führt. (b) DoD (2) Punkt 2 beschreibt in zehn Zeilen (`:68-77`) die Messung
  (`resolvedModel`, §3-Schranke, *„beide Ausgänge sagen dasselbe"*), die im umgesetzten Text
  bewusst auf einen Zeiger nach Abweichung 5 (3)(a) zusammengezogen wurde. Wer den Rumpf als
  Wortlaut-Anforderung liest — DoD (1) führt mit *„Wortlaut-Kern:"* ausdrücklich eine solche —,
  sucht diesen Text an der Berichtsgrößen-Stelle und findet ihn nicht.
- **verifizierbar:** nein — kein Gate; nachprüfbar am Zitat-Vergleich der genannten Stellen.

### B3 — „er" und „seiner" haben im bindenden Absatz kein Bezugswort mehr

- **kategorie:** LOW
- **quelle:** Maintainability; `spec/spezifikation.md` ist Rang 2 der Source Precedence
- **pfad:** `spec/spezifikation.md:266-267`
- **befund:** Der Satz lautet *„sie kann gebrochen werden, ohne dass irgendetwas rot wird.
  Verhindert wird **er** von nichts, und sichtbar wird nur eine **seiner** beiden Formen"*. Das
  Substantiv, auf das *er/seiner* zeigte, war *„der Bruch"*; es stand im ersetzten Satz
  (`grep -n 'Bruch\|gebrochen'`: alt `:266-267` mit *„Sichtbar wird der Bruch"*, neu nur noch
  `:266` *„gebrochen werden"* und `:307` in anderem Zusammenhang) und ist mit ihm entfallen. Das
  nächststehende maskuline Substantiv ist *„Wächter"* aus `:265` — wörtlich gelesen sagt der
  Satz, der Wächter werde von nichts verhindert.
- **verifizierbar:** nein — kein Gate; nachprüfbar am Grep oben und am Absatz selbst.

### B4 — dieselbe unbelegte Zuschreibung, die aus dem Plan entfernt wurde, steht in `ADR-0012`

- **kategorie:** INFO
- **quelle:** `AGENTS.md` §3.6 (Aussage über eine Quelle ohne Messung der Quelle);
  `ADR-0012` ist **Proposed** und damit nicht normativ
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:168-172`
- **befund:** *„Folgepflicht 1: `MR-018` Abweichung 6 trägt statt eines Auflösungs-Triggers das
  Verdikt *permanent — übergeführt in diese ADR*."* Das ist wörtlich die Aussage, die der
  Planner aus dem `ENTFALLEN`-Block genommen hat, weil sie nicht misst; sie ist auch heute
  unerfüllt (0 Treffer, s. M5-Tabelle), und ihr benannter Träger `MR-018` ist durch `MR-021`
  aufgehoben. **Außerhalb des Auftrags** — die Sache hinter M4 war ausdrücklich nicht zu prüfen;
  hier steht sie, weil sie derselben Klasse angehört und weil die §6-Verortung sie nicht nennt.
- **verifizierbar:** ja — der Grep über Abweichung 6 ist die Messung (s. M5-Tabelle); der
  Status am ADR-Kopf, Zeile 3.

---

## Negativbefunde (geprüft, ohne Befund)

- **N1 — `harness/conventions.md` byte-gleich.** `sha256sum` über `cde2c59`, `42de3ff`, `HEAD`
  und den Arbeitsbaum: viermal
  `31cfbd3033711fba9698293b64b8062ddd442142896e326b0f11a9a1f4d9839f`.
  `git diff cde2c59..HEAD -- harness/conventions.md` ist leer (0 Zeilen). Die append-only-Fläche
  `MR-018`–`MR-021` ist unberührt.
- **N2 — die Byte-Bilanz geht auf, und zwar Absatz für Absatz.** `spec/spezifikation.md`
  56 307 → 56 300 Byte (−7), 659 → 657 Zeilen. Zerlegt: Absatz 1 (M2) 1041 → 1019 = **−22**;
  Absatz 2 (H1) 295 → 814 = **+519**; Punkt 1 260 → 260 = **0**; Punkt 2 (M1) 849 → 345 =
  **−504**. Summe −7 — deckungsgleich mit dem Dateidelta. Der H1-Zuwachs ist vollständig durch
  die M1-Ersparnis bezahlt.
- **N3 — der Plan wächst nicht.** `slice-068…md` 12 250 → 11 974 Byte (−276), 176 → 166 Zeilen.
  `welle-09…md` 20 582 → 20 584 (+2), 261 Zeilen unverändert.
- **N4 — keine Entstehungs-Erzählung eingezogen.** Über alle 46 hinzugefügten Zeilen
  (`git diff 42de3ff..HEAD | grep '^+' | grep -v '^+++'`): `grep -nEi '2026-[0-9]|stand
  (bis|vorher|dort)|bis hierhin|zuvor|Befund|Runde [0-9]|Review-|zurückgenommen|umgezogen|
  inzwischen|früher'` → **0 Treffer** (Exit 1). Der entfernte Block trug einen Datums-Stempel
  und genau diese Erzählform; er ist ersatzlos weg.
- **N5 — kein Absatz, wo ein Satz gereicht hätte.** Der einzige gewachsene Block ist Absatz 2
  (+519 Byte). Er trägt vier voneinander unabhängige Aussagen (welche Form sichtbar ist, welche
  nicht, warum nicht — kein `Agent`-Span, Bilanz über Subagenten-Läufe —, und die Umkehrung
  *„klein heißt nicht gelebt"*); jede ist für den H1-Befund nötig. Der alte Satz *„Groß heißt
  ‚nicht gelebt'"* ist **ersetzt** (`:272-273` mit *„insoweit"*), nicht danebengestellt, ebenso
  die Absatz-Überschrift. Auch die drei Plan-Änderungen ersetzen: §3-Zeile, DoD-Sätze und
  §1-Satz sind Substitutionen, der einzige Zuwachs ist ein §6-Punkt und die Erweiterung eines
  bestehenden §6-Punktes — beides am Ort für offene Punkte.
- **N6 — keine neue Doppelung im Sinne von M1.** Die einzige Wiederholung, die der neue Text
  erzeugt, ist die Prämisse *„fällt in den Sammelposten"*: `grep -n 'fällt in den Sammelposten'
  spec/spezifikation.md` → **2 Treffer** (`:254` vorbestehend zur Start-Konvention, `:272` neu).
  `:272` zieht daraus eine andere Folgerung (*„und hebt den Anteil"*), die `:254` nicht führt;
  es sind nicht zwei Beschreibungen desselben Ausfalls, sondern eine Folgerung aus einer
  geteilten Prämisse. Unter der Schwelle von M1 (dort: zehn Zeilen mit derselben Messung,
  derselben Schranken-Referenz und demselben Vorbehalt).
- **N7 — die Querverweise des neuen Textes tragen.** Vier geprüft: *„Abweichung 5 (3)(a)"* gegen
  `:413` (Punkt 5) / `:434` (Unterpunkt 3, Fall (a)) / `:448-451` (die Aussage) — trifft, die
  Verschachtelung ist jetzt vollständig genannt statt verkürzt; *„die Bilanz rechnet über
  Subagenten-Läufe (Abweichung 6)"* gegen `:516-517` — wörtlich; *„die Größe, die Abweichung 3
  ohnehin verlangt"* gegen `:398-400` — trifft; *„Was Abweichung 3 aus zwei erfassten Feldern
  ableitet"* gegen `:382-384` — trifft, inklusive der Zahl **zwei**.
- **N8 — kein Wächter, kein neuer Zahn fällig.** `git diff --name-only 42de3ff..HEAD` → drei
  Dateien, alle Markdown unter `spec/` und `docs/plan/`. `ls test/mutations/*.sh | wc -l` → 135;
  die `# files:`-Köpfe nennen **36** eindeutige Zieldateien, davon unter `spec/` oder `docs/`:
  **0**.
- **N9 — die zwei wiederkehrenden Muster sind diesmal nicht aufgetreten.** (a) *Aussage ohne
  Messung der Quelle*: jede neue Fremdzuschreibung im Diff ist gegen ihre Quelle geprüft (N7),
  und die eine unbelegte des Vorstands ist entfernt (M5). (b) *Wachstum durch Danebenschreiben*:
  N2, N3, N5.
- **N10 — Gate-Lauf.** `make gates` **Exit 0**:
  `baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)`,
  `d-check: 285 Datei(en) geprüft, 0 Befund(e)`, `1..150` bats mit `grep -c '^not ok'` → **0**,
  `comment-claims: 38 Datei(en) geprueft, 0 Befund(e)`,
  `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert`.
- **N11 — nicht geprüft, weil nicht beauftragt:** L1 (die Historie-Zeile `spec:657` zählt §5 auf
  und nennt die zwei neuen Festlegungen weiterhin nicht — unverändert offen), L3, I1 und die
  Sache hinter M4. Das ist eine Auftrags-Grenze, kein Negativbefund.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | B1 |
| LOW | 2 | B2, B3 |
| INFO | 1 | B4 |

Aus dem Vorstand: **H1 erledigt**, **M1 erledigt**, **M2 erledigt**, **M3 erledigt**,
**M5 erledigt**, **L2 erledigt**; **M4** verortet, Verortung trägt zur Hälfte (B1).
Offen aus dem Vorstand, nicht beauftragt: L1, L3, I1.

## Verdikt

**Konform mit Auflage — der blockierende Befund ist weg.** H1 ist an beiden Fundstellen
geschlossen, und die Zusage sagt jetzt genau, welche Hälfte die Größe trägt und welche nicht;
M1, M2, M3, M5 und L2 sind mit eigenem Beleg erledigt; Plan und umgesetzter Text sagen in
DoD (1) und in DoD (2) Punkt 2 dasselbe; `harness/conventions.md` ist byte-gleich; die Byte-
Bilanz geht Absatz für Absatz auf, und beim Beheben ist weder ein danebengestellter Absatz noch
eine Entstehungs-Erzählung entstanden.

**slice-068 ist bereit für die Verifikation.** Die Stelle, an der sie hängenbleiben kann, ist
benannt und nicht die DoD-Wortlaut-Frage, sondern **B1**: DoD (3) legt für den Hintergrund-Teil
den Wert *deklariert* fest, §6 stellt zwei Zeilen später fest, dass die Wert-Tabelle für diese
Form keinen Wert führt, und behauptet zugleich, die Festlegung hänge nicht daran. Das ist vor
der **Closure** zu klären, nicht vor der Verifikation — die Zelle selbst entsteht erst beim
Wellen-Closure, und DoD (3) verlangt ausdrücklich nur die Festlegung, nicht die Zelle. B2 und
B3 sind Textmängel ohne Wirkung auf die DoD.
