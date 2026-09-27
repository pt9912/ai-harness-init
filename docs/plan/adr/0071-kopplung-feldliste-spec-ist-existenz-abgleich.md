# ADR-0071: Die Kopplung zwischen der Feldliste des Trägers und Spec §5 ist ein bidirektionaler Existenz-Abgleich — keine Wortgleichheit, keine Erzeugung

**Status:** Proposed

**Datum:** 2026-09-27

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:**
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Rang 1 —
Redaktion des emittierten Dokuments, mittelbar berührt: diese Entscheidung bindet nur die
Dogfood-Seite des Trägers, nicht das emittierte Dokument selbst),
[`ADR-0013`](0013-technik-stratum-als-zielort.md) (**Accepted, nicht revidiert** — Festlegung 1
setzt [`spec/spezifikation.md`](../../../spec/spezifikation.md) §5 als Zielort der Feldtabelle,
lässt aber ausdrücklich offen, **in welcher Form** dieser Zielort zu seinem Gegenstand — der
Feldnotiz im Träger — steht; diese ADR füllt genau diese Lücke, ergänzend, nicht widersprechend),
[`ADR-0022`](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** — Festlegung 7
entscheidet dieselbe Frage für ein **anderes** Dokument, die emittierte Feldliste im Ziel: dort
*wird* aus dem Träger erzeugt, weil das Ziel-Stratum `skip-if-present` ist und dem Adopter gehört.
Diese ADR übernimmt die Konstruktion **nicht** für `spec/spezifikation.md` §5 — unser eigenes
Stratum ist weder `skip-if-present` noch fremd, und der tragende Grund von Festlegung 7 trägt hier
nicht),
[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(misst die vierte Spalte von §5 — den Sensor-Bezug je Zeile — als Feedforward, kein Gate hält sie;
diese Entscheidung rührt daran nicht),
[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (Vorbild
für "erzeugt", hier geprüft und für §5 verworfen — Begründung unten),
[`AGENTS.md`](../../../AGENTS.md) §3.6 (eine Zusage ohne rot gesehenes Gegenbeispiel ist nicht
fertig — der Grund, warum diese Entscheidung keine Wortgleichheit verlangt, die sie nicht halten
kann),
Baseline-Regelwerk `modul-11-verification.md` §Fitness Function ohne Standard-Tool (die
Sensor-Schicht-Tabelle, nach der unten gewählt wird).

**Revidiert:** keine. Diese ADR ist rein ergänzend zu [`ADR-0013`](0013-technik-stratum-als-zielort.md);
kein Satz jener Entscheidung wird aufgehoben oder geschärft, sie beantwortet nur eine Frage, die
[`ADR-0013`](0013-technik-stratum-als-zielort.md) selbst offengelassen hat.

**Schärft:**
[`spec/spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder).
Aufwärts-Deklaration: wer diese ADR ändert, zieht diese Spec-Stelle nach.

---

## Kontext

[`ADR-0013`](0013-technik-stratum-als-zielort.md) hat entschieden, **wo** die Feldtabelle lebt
(`spec/spezifikation.md` §5) — nicht, **wie** sie sich zu ihrem Gegenstand verhält: der
Feldnotiz je Feld im Träger (`internal/span/fieldlist.go`, `SchemaNotes()`). Diese Frage stand
ursprünglich in [slice-109](../planning/done/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md)
§1 als "Frage A/B" und wurde am 2026-09-27 in einen eigenen Slice ausgelagert
(`slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`), weil sie eine
Sensor-Architektur-Entscheidung ist (Baseline-Regelwerk `modul-08-agentenrollen.md`
§Rollen-Regeln: *"Regel-Verkörperung … sind Entscheidungen, keine Planung"*), keine
Planungs-Entscheidung.

**Gemessener Bestand (2026-09-27).** §5 führt **26** Datenzeilen
(`sed -n '/^| ID | Feld | Pflicht | Incident-Frage | Sensor |/,/^$/p' spec/spezifikation.md | grep -c '^| `'`)
für **32** Feld-Literale im Träger
(`grep -c '{Field: "' internal/span/fieldlist.go`); **6** Zeilen führen zwei Feld-Literale in
einer Zeile
(`sed -n '/^| ID | Feld | Pflicht | Incident-Frage | Sensor |/,/^$/p' spec/spezifikation.md | grep '^| `' | awk -F'|' '{n=gsub(/`[a-z_0-9]+`/,"&",$3); if(n>1) c++} END{print c}'`),
sodass 26 + 6 = 32 — **jedes** Feld des Trägers hat heute eine Entsprechung in §5. Ein
Implementer-Durchgang meldete **4 von 26** wortgleiche Zeilen (`ts`, `tool`, `tool_use_id`,
`status`); die Planner-Prüfung verifizierte an einer Stichprobe von acht Zeilen und diese ADR hat
sie an einer weiteren Stichprobe (`seq`, `slice`, `session`/`agent`, `program`/`argc`)
nachgemessen. Drei Kategorien treten dabei zutage, und keine ist ein Fehler:

1. **Reine Umformulierung derselben Aussage.** `seq` — Spec: *"Fehlt ein Span? — je Strom monoton
   steigend, damit der Leser eine Lücke sieht"*; Träger: *"Fehlt eine Zeile? — je Strom vergeben
   und steigend, damit eine Lücke sichtbar wird"*. Dieselbe Behauptung, zwei Register.
2. **Strukturelle Differenz.** `session`/`agent` — Spec bündelt beide Felder in **einer**
   Incident-Frage (`SPEC-008`, *"Welcher Lauf war es? — zusammen bilden sie den Strom"*); der
   Träger stellt für `agent` eine **eigene, zweite** Frage (*"Welcher Agent innerhalb des Laufs?"*),
   die in der Spec-Zeile nicht auftaucht. Beide Aussagen sind wahr, keine widerspricht der
   anderen — sie zerlegen dieselbe Tatsache unterschiedlich fein.
3. **Substanz-Gefälle.** `program`/`argc` — die Spec-Zeile `SPEC-021` verweist auf die
   Wortgrenzen-Regel in `SPEC-031`, die über mehrere hundert Wörter jeden Rand-Fall der
   Kommandozeilen-Segmentierung festlegt (nachgemessen: die Zeile `SPEC-031` ist die mit Abstand
   längste der Spec-Datei). Die Trägerfassung ist ein terser Adopter-Satz: *"das erste Token der
   Kommandozeile, nie die Zeile"*. Beide sind für ihr Publikum richtig — die Spec ist Rang-2,
   normativ, an Implementierer und Reviewer gerichtet; die Trägerfassung geht über
   [`ADR-0022`](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7 **verbatim**
   an den Adopter und muss dort kurz bleiben.

**Der Präzedenzfall für die zirkuläre Kopplung.**
[slice-096](../planning/done/slice-096-traeger-liegt-im-ziel.md) §7 (Steering-Loop-Eintrag) hat
bereits gemessen, was passiert, wenn ein Wächter seine Erwartung aus derselben Funktion ableitet,
die er prüfen soll: `TestEnforce_WrapperSuchtDenAblageort` holt die erwarteten Namen aus
`emit.CarrierPath()` — genau der Funktion, deren Mutation der Fall fangen sollte — und bleibt
darum unter `test/mutations/159` grün, obwohl die Mutation die Endungs-Logik bricht; rot wird nur
ein **anderer** Wächter, der unabhängig geschrieben ist. Übertragen auf diesen Fall: Würde §5 **aus**
dem Träger **erzeugt** und danach **gegen** den Träger **verglichen**, vergliche der Sensor zwei
Ausgaben derselben Quelle — er könnte strukturell nicht rot werden, weil beide Seiten aus demselben
Lauf derselben Funktion stammen.

## Entscheidung

**Wir wählen Option E — bidirektionaler Existenz-Abgleich, kein Wortgleichheits- und kein
Erzeugungs-Zwang.** `internal/span/fieldlist.go` (`SchemaNotes()`) und
[`spec/spezifikation.md`](../../../spec/spezifikation.md) §5 bleiben zwei unabhängig,
von Hand verfasste Artefakte — mit unterschiedlichem Register (Adopter-terse gegen Rang-2-normativ)
und ausdrücklich erlaubter Substanz-Differenz. Ein neuer Sensor (Make-Target- oder
Pre-commit-Hook-Ebene, Baseline-Regelwerk `modul-11-verification.md` §Fitness Function ohne
Standard-Tool) prüft ausschließlich **Existenz, nicht Wortlaut**: jedes `{Field: "X"}`-Literal in
`internal/span/fieldlist.go` hat ein Vorkommen des Tokens `` `X` `` irgendwo in der §5-Tabelle, und
jedes in §5 genannte Feld-Token hat ein `{Field: "X"}`-Gegenstück im Träger — in beiden Richtungen.
Die Frage, ob zwei existierende Einträge dieselbe **Kernaussage** tragen, bleibt dabei
unentschieden — das ist eine bewusste Grenze, kein Versehen, und sie steht unten unter
§Konsequenzen als benannte, nicht geschlossene Lücke.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (keine Kopplung, keine Zusage) | kein Aufwand | eine unbenannte Divergenz — ein Feld, das im Träger entsteht und in §5 nie ankommt (oder umgekehrt) — bleibt für immer unsichtbar; genau das Muster, das [`AGENTS.md`](../../../AGENTS.md) §3.1 als halluziniertes Artefakt einer Ebene tiefer beschreibt |
| B — erzeugt (§5 wird aus dem Träger generiert, [`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Vorbild) | Drift konstruktiv ausgeschlossen, wie bei der **emittierten** Feldliste ([`ADR-0022`](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7) | zwingt zur Wahl zwischen Substanzverlust im Rang-2-Stratum (SPEC-021/031 auf Adopter-Kürze gekürzt) oder Governance-Prosa im Träger, die über Festlegung 7 verbatim beim Adopter landet; kombiniert mit einem nachgelagerten Vergleich zirkulär (Präzedenzfall oben) |
| C — verglichen, wortgleich | einfachster Parser, kein Interpretationsspielraum | falsches Ziel: erzwingt Homogenisierung zweier Register, die laut Festlegung 7 legitim verschieden sein müssen; liefe an 22 von 26 Zeilen sofort und dauerhaft rot, bis die Substanz-Differenz beseitigt ist — und genau die soll bestehen bleiben |
| D — verglichen, Kernaussage (inferentiell, Doku-Konsistenz-Agent) | fängt echte Bedeutungs-Abweichungen, nicht nur fehlende Zeilen | teuerste Sensor-Schicht nach Modul 11 (*"hoch — wenn semantische Prüfung nötig ist"*), nicht-deterministisch, kein bestehendes Werkzeug im Repo; der Aufwand steht in keinem belegten Verhältnis zu einem bisher nicht beobachteten Schadensfall (kein LH-Akzeptanzkriterium verlangt Kernaussage-Gleichheit) |
| **E — verglichen, Existenz-Abgleich (gewählt)** | billig (deterministisch, Pre-commit-Hook-/Make-Target-Ebene, Modul 11 *"niedrig/mittel"*), fängt den konkret benannten Schadensfall (ein Feld existiert nur auf einer Seite), keine Zirkularität (zwei unabhängig verfasste Artefakte), keine erzwungene Homogenisierung | fängt **keine** Kernaussage-Abweichung bei existierenden Feldern — diese Lücke bleibt offen und ist unten benannt, nicht automatisiert geschlossen |

## Konsequenzen

- **Positiv:** ein Feld, das im Träger entsteht und nie eine §5-Zeile bekommt (oder umgekehrt),
  wird mechanisch sichtbar — der konkrete Schadensfall, den Option A unsichtbar ließe.
- **Positiv:** kein Zwang, 22 der 26 heutigen Zeilen anzugleichen. Der Umsetzungsaufwand ist damit
  auf den Bau **eines** Sensors begrenzt, nicht auf eine Textangleichung über beide Dokumente.
- **Positiv:** keine zirkuläre Kopplung — Sensor und geprüfte Artefakte sind drei verschiedene
  Dinge (Skript, Go-Quelltext, Markdown-Tabelle), keines erzeugt ein anderes.
- **Negativ, benannt statt verschwiegen:** eine falsche oder überziehende Behauptung in einer
  **existierenden** Zeile (Spec behauptet mehr über den Träger, als er tut, oder umgekehrt) bleibt
  vom neuen Sensor ungesehen. Das ist dieselbe Klasse, die
  [slice-109](../planning/done/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) für
  zwei konkrete Sätze bereits von Hand gefunden und behoben hat — die Existenz-Kopplung ersetzt
  diese Handarbeit nicht, sie fängt nur eine andere, komplementäre Fehlerklasse (fehlende statt
  falscher Zeile). Träger dieser Lücke ist die Sichtung bei künftiger Slice-Planung (Baseline-Regelwerk
  `modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung), nicht ein Gate — ein
  **akzeptiertes Negativ**, kein stillschweigend behaupteter Vertrag.
- **Folgepflicht 1 — der Sensor ist geschuldet, nicht geliefert.** Diese ADR entscheidet die Form;
  der Bau ist ein eigener, benannter Folge-Slice (siehe Übergabe in der Slice-Planung).
- **Folgepflicht 2 — [`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) bleibt unverändert.** Die vierte Spalte von §5 (Sensor-Bezug je Zeile)
  wird von dieser Entscheidung weder erzeugt noch verglichen; ihr Feedforward-Status ändert sich
  nicht.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| neues Skript (`grep`/`awk` über `internal/span/fieldlist.go` und `spec/spezifikation.md` §5) | Jedes `{Field: "X"}`-Literal im Träger hat ein Token `` `X` `` in der §5-Tabelle, und jedes Feld-Token der §5-Tabelle hat ein Gegenstück im Träger — bidirektional | **geschuldet, nicht geliefert** — Ziel eines benannten Folge-Slice, hier noch kein Make-Target |

**Was hier bewusst NICHT steht.** Ein Wächter, der die **Kernaussage** zweier existierender Zeilen
vergleicht — das ist Option D, hier verworfen (siehe §Konsequenzen, negativ). Ein Wächter, der
Wortgleichheit verlangt — das ist Option C, hier verworfen, weil sie das falsche Ziel misst.

## Re-Evaluierungs-Trigger

- **Wenn eine Kernaussage-Abweichung real auftritt und unbemerkt bleibt** *(feedforward — ein
  konkreter Vorfall, kein Sensor meldet ihn heute)*: eine Spec-Zeile behauptet über den Träger
  etwas, das er nicht (mehr) tut, oder umgekehrt, und der Existenz-Abgleich bleibt grün, weil
  beide Zeilen existieren. Tritt das ein, ist Option D (inferentiell) mit dieser Evidenz neu zu
  wägen — nicht diese Entscheidung stillschweigend zu erweitern.
- **Wenn Spans in anderer Form emittiert werden** *(feedforward — eine Vertragsänderung)*: dann ist
  zu prüfen, ob die Existenz-Kopplung auch für ein künftiges emittiertes Feldlisten-Dokument
  gelten soll, oder ob [`ADR-0022`](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  Festlegung 7 dafür ausreicht.
- **Wenn der Existenz-Sensor gebaut ist und dauerhaft rot bleibt** *(computational feedback, sobald
  das Folge-Slice liefert)*: dann ist entweder eine Zeile falsch benannt, oder die Grenze zwischen
  Träger und Spec braucht eine erneute Prüfung.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-27 | **Proposed** | Architect-Verdikt zum Slice `slice-kopplungsform-feldnotiz-spec-braucht-architektur-verdikt`, DoD (1) |
