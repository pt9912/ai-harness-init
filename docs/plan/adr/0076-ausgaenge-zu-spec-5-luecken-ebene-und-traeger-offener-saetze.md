# ADR-0076: Die Ausgänge von E1, E3 und E4 zu Spec §5 stehen fest, die 19 `Lücke`-Zeilen haben eine Ebene, und die offenen Prozess-Sätze haben einen Träger oder ein begründetes Negativ

**Status:** Proposed

**Datum:** 2026-09-30

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (der einzige Träger des Span-Schemas im Vertrag),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (**Accepted** — E1 bis E4, Festlegung 5, Fitness-Zeile 13,
Re-Evaluierungs-Trigger 4),
[ADR-0075](0075-begruendungen-zu-spec-5-sammel-adr.md) (**Accepted** — Folgepflicht 1),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[`MR-015`](../../../harness/conventions.md#mr-015) (Change Request am Lastenheft),
[`MR-021`](../../../harness/conventions.md#mr-021),
[`MR-025`](../../../harness/conventions.md#mr-025) (Zahl neben Kommando),
[`MR-075`](../../../harness/conventions.md#mr-075),
[`MR-076`](../../../harness/conventions.md#mr-076),
[`MR-077`](../../../harness/conventions.md#mr-077),
[`AGENTS.md`](../../../AGENTS.md) §3.4, §3.6, §3.7, §3.8, §3.10, §3.11,
die [Verifikation](../../reviews/2026-09-30-slice-spec-aufnahme-regel-und-umbau-verifikation.md)
(Zeitdokument in der stehenden Ablage `docs/reviews/`; „A-n" unten meint ihre Übergabe an den Architect)

**Revidiert (Teil-Ablösung, Kern von [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) unberührt):**
die Fitness-Zeile 13 (Festlegung 2 unten) und der Satz zur Ereignis-Menge im Ebenen-Test von Festlegung 5
(Festlegung 3 unten). Beide ADRs bleiben `Accepted` und unverändert; wo ihr Wortlaut diesem widerspricht, gilt diese ADR.

**Schärft:**
[ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md),
[ADR-0075](0075-begruendungen-zu-spec-5-sammel-adr.md) und
[`spec/spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
(die Spalte `Präzisiert` der 19 `Lücke`-Zeilen). Aufwärts-Deklaration: wer diese ADR ändert, zieht §5 nach. Die
Spezifikation nennt diese ADR nie.

---

## Kontext

Die Verifikation hat die zwei Slices zu §5 mit Übergaben an den Architect geschlossen: E1, E3 und E4 sind vollzogen und
in keiner Folge-ADR festgehalten (A-1), Fitness-Zeile 13 misst den Gegenwert (A-2), zwei Prozess-Zustände haben keinen
Träger (A-3), die Datei `docs/user/rollen-laeufe.md` hat keine benannte schreibende Rolle (A-4), zwei Begründungen
tragen keine Quelle (A-5), und 19 Zeilen tragen `Lücke` (A-7). Diese ADR entscheidet diese sechs und die Quelle der Regel
zu `BEO-ALL/geplanter-slice-wird-nie-gearbeitet`. **Nicht entschieden:** A-6 (Namen in der Spalte `Sensor`), A-8 (Parser des
Existenz-Sensors) und die schreibende Rolle der Spec-Straten
([ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 7).

**Zwei Messungen, die die Entscheidungen tragen.** Erstens: das Tool emittiert die Erfassungs-Verdrahtung ins Zielrepo;
den Agent-Guard emittiert es nicht.

```sh
grep -c SubagentStart internal/emit/templates/enforce/settings-capture-hooks.json      # 1
ls internal/emit/templates/enforce | grep -c 'agent-guard'                              # 0
```

Zweitens: [ADR-0075](0075-begruendungen-zu-spec-5-sammel-adr.md) steht in genau einem Commit
(`git log --format=%h -- docs/plan/adr/0075-begruendungen-zu-spec-5-sammel-adr.md | wc -l` → 1), und dieser Commit trägt
die zweite Geschichte-Zeile bereits (`git log --format=%h -S'Prozess-Konvention nach' -- docs/plan/adr/0075-begruendungen-zu-spec-5-sammel-adr.md`
nennt dieselbe Kennung). Beide Zahlen messen den Stand dieser ADR und sind keine Erwartungswerte
([`MR-025`](../../../harness/conventions.md#mr-025)).

## Entscheidung

**Wir wählen Option C: je Zeile die Ebene, je Prozess-Satz ein Träger oder ein begründetes Negativ, und keine Änderung
an einer `Accepted`-ADR.** Diese ADR schreibt keinen Spec-Text, kein Lastenheft, keinen Adaptions-Eintrag und keinen
Code; der Nachzug folgt in eigenen Schritten.

### Festlegung 1 — E1, E3 und E4 sind vollzogen (A-1)

Vollzogen ist je Entscheidung die Option A der [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md):

| Entscheidung | Ausgang | Träger |
|---|---|---|
| E1 — Ort der Abweichungen 1 und 2 | Adaptions-Eintrag | [`MR-076`](../../../harness/conventions.md#mr-076) (Abweichung 1), [`MR-077`](../../../harness/conventions.md#mr-077) (Abweichung 2), Kopf-Marken an [`MR-021`](../../../harness/conventions.md#mr-021) |
| E3 — Ort der Prozess-Konventionen | ein Dokument unter `docs/user/` | [`docs/user/rollen-laeufe.md`](../../user/rollen-laeufe.md) |
| E4 — die Spalte `Sensor` | bleibt | Kopfzeile der Feldtabelle in `spec/spezifikation.md` |

**Wie es dazu kam, als Zustand:** der Auftraggeber hat angeordnet, den Umbau ohne Rückfragen umzusetzen; eine
Einzelentscheidung zu E1, E3 oder E4 liegt nicht vor. Die Ausgänge sind die Empfehlungen des Architects
([ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) §Offene Entscheidungen), vollzogen unter dieser
Anordnung. Die Annahme dieser ADR durch den Auftraggeber bestätigt sie; ein Widerspruch geht den Folge-ADR-Weg
(Re-Evaluierungs-Trigger 1).

### Festlegung 2 — Fitness-Zeile 13 von ADR-0074 wird korrigiert, nicht der Bestand (A-2)

Die Zeile verlangte für `START-KONVENTION` „gleich dem Wert vor dem Umbau (1)"; sie gilt bis E3. Mit E3 = A gilt an ihrer
Stelle: die Start-Konvention steht **nicht** mehr in der Spezifikation und **steht** in `docs/user/rollen-laeufe.md`. Der
Bestand bleibt, wie er ist; die Regel folgt ihm. Kommandos in der Fitness Function unten (Zeile 2).

### Festlegung 3 — die Ebene der 19 `Lücke`-Zeilen (A-7)

**Der Ebenen-Test von [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 5 wird an einem
Satz gezogen:** „die Ereignis-Menge gehört auf die Verdrahtungs-Seite" gilt nur für Verdrahtung, die **allein dieses Repo**
trägt. Verdrahtung, die das Tool ins Zielrepo emittiert (`settings-capture-hooks.json`), ist Träger-Seite: das Zielrepo
bekommt sie, und [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) emittiert den Träger samt seinem Schreiber und seiner Auswertung. Der Agent-Guard gehört nicht
dazu (Messung im Kontext).

**Eine Zeile trägt [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), wenn ihr Gegenstand ein Feld, ein Wert, eine Schranke, eine Ableitung oder ein Verhalten des
emittierten Trägers ist, das ein Wort der Beschreibung oder ein Akzeptanzkriterium des Elements deckt. Erweitern kann eine
Präzisierung den Umfang nicht** (Aufnahme-Regel der Spezifikation). Das Urteil folgt dem Wortlaut; kein Sensor hält es.

| Gruppe | Zeilen | Entscheidung und Grund |
|---|---|---|
| **trägt [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)** | `SPEC-014` | `Pflicht`-Feld; die „volle Pflicht-Spalte" des Happy Path. Der Zirkel-Vorbehalt aus ADR-0074 Festlegung 5 bleibt benannt: `branch`/`commit` stehen nicht unter den Korrelations-Achsen der Beschreibung |
| | `SPEC-037` | Akzeptanzkriterium „Umfang fail-closed": Name und Status, sonst nichts |
| | `SPEC-045`, `SPEC-046` | Regeln der Auswertung im Block *Token-Attribution* (Beschreibung); „Emittiert werden Schreiber und Auswertung" (Leser). Die Auswertung liegt im Träger (`cmd/ai-harness-init/span_report.go`, `internal/report/`) |
| | `SPEC-047` | Berichtsgröße: „Die Auswertung nennt ihre Abdeckung zuerst". Der Satz der Zelle über die Sichtbarkeit des Bruchs der Regel „Rollen-Arbeit läuft als Rolle" ist Prozess-Konvention und steht in `docs/user/rollen-laeufe.md`; der Nachzug kürzt die Zelle |
| | `SPEC-054` | der Strom ist die Ableitung aus `session` und `agent` (`SPEC-008`, getragen) und die Grundlage der `seq`-Zusage (`SPEC-003`, getragen) |
| | `SPEC-056` | „Minimal/netzlos" ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), als Akzeptanzkriterium in [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) geführt): kein Netz, kein `gh` |
| | `SPEC-060` | `seq`, Ableitung von `slice` und `requirement`: Korrelations-Achsen der Beschreibung |
| | `SPEC-063` | der Beleg der Läufe („Damit erhält der Adopter den **Beleg**"): ein liegengebliebenes Lock legt den Schreiber nicht lautlos still |
| | `SPEC-065` | Schreiber und Auswertung sind zwei Unterkommandos eines Trägers (Leser) |
| | `SPEC-082` | Pflichtfeld `tool` der Zeile |
| **verlässt die Spezifikation** (betrifft nur dieses Repo) | `SPEC-040` | Werkzeug-Verhalten (Schema von `Agent`, Sicht) und Betriebsart der Rollen-Läufe dieses Repos; der Träger legt keine Betriebsart fest. Hintergrund ohne Verbrauchs-Achse trägt `SPEC-039`, die Betriebsart `docs/user/rollen-laeufe.md`; eine Messaussage geht nach `docs/reviews/` ([ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 4) |
| | `SPEC-041`, `SPEC-085`, `SPEC-086` | der Agent-Guard ist nicht emittiert; seine Zusagen und Grenzen stehen im Kopfkommentar von `.claude/hooks/pretooluse-agent-guard.sh` und in `test/agent-guard.bats` ([`AGENTS.md`](../../../AGENTS.md) §3.7: Zusage, Grenze), die Begründung in [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 1 und [ADR-0075](0075-begruendungen-zu-spec-5-sammel-adr.md) Festlegung 5 |
| | `SPEC-084` | Aussage über die Wächter dieses Repos (Gegenproben `mustContain`): die Grenze steht als Kommentar am Helfer, kein Träger-Merkmal |
| **bleibt `Lücke`, ein Change Request** | `SPEC-051`, `SPEC-052`, `SPEC-053` | emittiert (Messung im Kontext), aber kein Wort von [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) deckt sie: das Element sagt „je Werkzeug-Aufruf einen Span"; der Start eines Subagenten ist kein Werkzeug-Aufruf, „nicht erfasst" ist eine Umfangs-Grenze. Eine Präzisierung erweitert nicht |

Menge und Nummern misst die Zeile 4 der Fitness Function. **Change Requests: einer** ([`MR-015`](../../../harness/conventions.md#mr-015)-Form, gebündelt): das
Lastenheft-Element [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), ein Kriterium zum Erfassungs-Umfang (welche Ereignisse einen Span erzeugen, welche
ausdrücklich nicht), getragen von `SPEC-051`, `SPEC-052`, `SPEC-053`. **Text und Entscheidung gehören dem Auftraggeber**
([`MR-015`](../../../harness/conventions.md#mr-015)); der Architect schreibt keine Anforderung. **Zweiter Change Request,
falls der Auftraggeber [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) enger liest** (nur Schreiber, keine Auswertungsregeln): `SPEC-045`, `SPEC-046`,
`SPEC-047` (*Token-Attribution*). Der Nachzug der Zellen (`Lücke` → Anker, Zeilen verlassen die Spezifikation) ist
Bestandsarbeit eines Implementer-Laufs nach der Annahme.

### Festlegung 4 — U14 und U38 sind akzeptierte Negative (A-3)

- **U14 — Bedingung 1 der Start-Konvention (der Rollen-Typ per @-Erwähnung) hat keine Durchsetzung.** Ein Register-Eintrag
  entfällt: die Wirkung ist sichtbar, die Lücke bekannt und der Zähler misst hier nichts, was nicht schon ein Bericht
  zeigt. Wer die Bedingung bricht, bekommt `general-purpose`, `agent_role` bleibt leer, der Lauf fällt in den Sammelposten
  der Token-Bilanz (`SPEC-047`) — sichtbar, soweit der Lauf Zähler trägt. Ein Sensor, der den Typ verlangt, wäre eine
  Guard-Verschärfung ([ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 1 entscheidet die Aufrufform, nicht
  die Rolle). **Träger:** die Berichtsgröße; **Nachzug:** ein Satz in `docs/user/rollen-laeufe.md`, dass diese Bedingung
  keinen Wächter trägt (Ist-Zustand; der Architect zieht ihn nach, wenn er die Datei ohnehin anfasst).
- **U38 — ob ein vom Nutzer abgesetzter Aufruf einen Span erzeugt, ist nicht gemessen.** Keine Zeile, kein Bericht und keine
  Entscheidung stützt sich auf die Antwort; eine Messung braucht einen interaktiven Aufruf, den kein `make`-Ziel fährt.
  Ein einmaliger, folgenloser Blindfleck: kein Eintrag. **Trigger:** braucht eine Entscheidung diese Aussage, entsteht die
  Messung als Zeitdokument in `docs/reviews/`.

### Festlegung 5 — die zwei Begründungen ohne Träger in ADR-0075 (A-5)

- **„Erst die Prüfung, dann die Abweichung" (Methode zu Abweichung 5): begründetes Negativ.** Ihr Gegenstand war Abweichung 5;
  [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 3 stuft sie nicht mehr als Abweichung ein.
  Die zwei Ergebnisse der Prüfung (ableitbar: nein, gemessen; vermeidbar: nein) tragen `SPEC-039` und die Guard-Zusagen aus
  Festlegung 3. Ein künftiger Abweichungs-Eintrag trägt seine Begründung in seinem Rumpf. Der Wortlaut ist am Stand
  `85e5ab5b` lesbar (`git show 85e5ab5b:spec/spezifikation.md | grep -n 'Erst die Prüfung'`).
- **„Kippen, nicht Rot" (Prüfstein der Wächter-Einträge): der Träger ist vorhanden.** Der Kommentar `PRUEFSTEIN` in
  `internal/span/response_test.go` trägt Zusage und Grenze („für die zwei Cache-Zähler ist das Kippen nicht herstellbar, solange
  `input_tokens` als Teilstring in derselben Liste steht"), `SPEC-076` und `SPEC-077` tragen die Zelle. **Lücke, benannt:**
  wird der Teilstring entfernt, wird das Kippen herstellbar und der Satz falsch; kein Sensor liest den Kommentar gegen die Liste.

### Festlegung 6 — die schreibende Rolle von `docs/user/rollen-laeufe.md` (A-4, Liefer-Punkt 2a)

**Der Architect schreibt diese Datei — nur diese, nicht `docs/user/` im Ganzen.** Änderungen landen in einem eigenen
Commit, der ausschließlich Architect-Artefakte berührt und die Rolle in seiner Message nennt
([`AGENTS.md`](../../../AGENTS.md) §3.8, sinngemäß). Grund: die Datei trägt die Norm-Aussagen über das Rollen-Verfahren, die vorher
in der Spezifikation standen und von dort nach [ADR-0074](0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)
Festlegung 13 und E3 ausgelagert wurden; [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) legt Norm-Artefakte
ohne benannte Quelle dem Architect zu. Damit ist der Commit `85e5ab5b` im Zuschnitt nachträglich gedeckt. **Die schreibende Rolle
der Spec-Straten bleibt offen** (ADR-0074 Festlegung 7); fällt sie anders, ist diese Zuordnung neu zu prüfen.

### Festlegung 7 — Zielort und Inhalt der Regel zu `BEO-ALL/geplanter-slice-wird-nie-gearbeitet` (Liefer-Punkt 2b)

**Zielort:** der Anweisungssatz des Planners, `.claude/commands/plan-welle.md`, Abschnitt *Slices bereitstellen*, vor dem
Satz zum Sichten des Registers. Den Text schreibt der Planner ([ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md));
diese Festlegung ist sein Übergabe-Artefakt. Eine Hard Rule entfällt: die Regel bindet den Schnitt, nicht jeden Lauf.

**Inhalt:** ein Befund aus Review, Verifikation oder Closure bekommt eine Plan-Datei in `open/` nur mit einem Auslöser:
(1) ein Auftrag des Auftraggebers; (2) er blockiert oder verfälscht die laufende Arbeit; (3) das Register hat ihn auf 3×
gehoben; (4) ein bereits geplanter Slice nennt ihn als Folge-Slice mit Kennung. **Ohne Auslöser** hat er die zwei anderen
Ausgänge von [Modul 6](../../../.harness/baseline/v6.13.0/regelwerk/modul-06-roadmap.md): einen Register-Eintrag
(`observation.md` und `evidence/<vorgangs-id>.md`) oder die ausdrückliche Ablehnung mit Grund in der Closure-Notiz.

**Was vom Vorschlag des Planners bleibt:** die Richtung (Register statt Plan-Datei bis zu einem Anspruch). **Was nicht:** „bis zur
ersten Beanspruchung" — beansprucht wird eine Datei, die es nach dem Vorschlag noch nicht gäbe; die vier Auslöser sind
beobachtbar. **Grenze:** „ein Auslöser liegt vor" ist Urteil; ein Sensor bräuchte ein Pflichtfeld im Slice-Kopf, und die
Vorlage ist vendored ([`MR-007`](../../../harness/conventions.md#mr-007)) — ein Feld ist hier nicht ergänzbar. Erreicht die
Klasse ein viertes Mal die Schwelle, ist damit die Begründung „kein mechanischer Sensor möglich" schon geführt; ein neuer
Grund oder eine neue Möglichkeit ist der Trigger.

### Festlegung 8 — die zweite Geschichte-Zeile von ADR-0075 bleibt, und ihre Aussage wird hier fortgeschrieben

Die Verifikation nennt die Zeile „nach `Accepted` eingefügt". Git zeigt das nicht: [ADR-0075](0075-begruendungen-zu-spec-5-sammel-adr.md)
liegt in einem Commit, und die Zeile steht in diesem (Messung im Kontext); ein Eingriff vor dem Commit ist keiner an einer
`Accepted`-ADR. **Nicht bestätigt, nicht ausgeschlossen:** ob die Zeile vor dem Commit geschrieben wurde, als die Datei, auf die
sie zeigt, noch nicht existierte (`git cat-file -e db588981:docs/user/rollen-laeufe.md` scheitert). Heilung ohne Änderung an
ADR-0075: die Zeile steht als **Nachtrag der Geschichte** und nicht als Teil der Entscheidung; ihr Satz „wer sie künftig ändert,
ist nicht entschieden" ist mit Festlegung 6 entschieden. Ein Rückbau der Zeile wäre die zweite Änderung an einer
`Accepted`-ADR ([`AGENTS.md`](../../../AGENTS.md) §3.4) und entfällt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — alle 19 Zeilen bleiben `Lücke`, ein Change Request über alle | kein Urteil je Zeile | 16 Zeilen wären Präzisierung oder gar keine Spec-Aussage; der Auftraggeber entschiede über Text, den das Element schon deckt |
| B — alle 19 verlassen die Spezifikation | die Spec trägt keine `Lücke`-Zeile mehr | der Träger-Umfang (`SPEC-051` bis `053`) und die Zeilen, die das Element trägt, verlören ihre Festlegung |
| **C — Ebene je Zeile (gewählt)** | ein Change Request statt 19; jede Zeile hat einen Ort | Urteil ohne Sensor (Fitness Zeile 5); die Lesart von [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) entscheidet bei `SPEC-045` bis `047` |
| D — U14 und U38 als Register-Einträge | der Zähler sähe eine Wiederholung | der Zähler misst Wiederholung über Vorgänge; hier wiederholt sich nichts, was ein Bericht nicht schon zeigt |
| E — die Regel zu toten Slices als Hard Rule | bindet jeden Lauf | sie bindet nur den Schnitt; eine Hard Rule ohne Sensor wächst nur ([Modul 13](../../../.harness/baseline/v6.13.0/regelwerk/modul-13-quality-gates.md)) |

## Konsequenzen

- **Positiv:** E1, E3 und E4 haben einen Beleg; der Auftraggeber sieht die Zahl seiner Change Requests; jede `Lücke`-Zeile
  hat eine Ebene; die zwei Prozess-Sätze und die zwei Begründungen haben einen Ort oder ein begründetes Negativ.
- **Negativ, benannt:** die Ebenen-Zuordnung hält kein Sensor; bis zum Nachzug tragen 19 Zeilen `Lücke`, und die Aufnahme-Regel
  ist für sie verletzt. Die Regel zu toten Slices bleibt Prosa im Anweisungssatz ohne Sensor.
- **Folgepflichten:** (1) ein Implementer-Lauf zieht die Zellen nach (`Lücke` → Anker für die Gruppe „trägt", Zeilen der Gruppe
  „verlässt" wandern an ihren Ort, Zelle `SPEC-047` gekürzt); (2) der Auftraggeber entscheidet über den Change Request
  ([`MR-015`](../../../harness/conventions.md#mr-015)); (3) der Planner schreibt die Regel aus Festlegung 7 und weist dem
  Register-Eintrag den Ausgang zu; (4) der Architect zieht den Satz zu U14 in `docs/user/rollen-laeufe.md` nach.

## Fitness Function (falls maschinell prüfbar)

Jede Festlegung, die ein Rot tragen kann, hat eine Zeile; wo keines herstellbar ist, steht `keiner` mit der Lücke
([`AGENTS.md`](../../../AGENTS.md) §3.6). **Rot gesehen ist noch keine Zeile**; die Beobachtung liegt bei der Verifikation. Kein
Kommando ist ein Gate.

| Nr | Festlegung | Tooling | Regel | rot, wenn |
|---|---|---|---|---|
| 1 | 1 E1 vollzogen | Messkommando | `grep -cE '^\| \[MR-07[67]\]' harness/conventions.md` → 2 | 0 oder 1: ein Eintrag fehlt im Index |
| 2 | 1 E3, 2 Zeile 13 | Messkommando | `grep -c 'START-KONVENTION' spec/spezifikation.md` → 0 **und** `grep -c 'START-KONVENTION' docs/user/rollen-laeufe.md` → 1 | Spec ≥ 1 (die Konvention steht wieder dort) oder Datei 0 (sie steht nirgends) |
| 3 | 1 E4 | Messkommando | `grep -c '^\| ID \| Feld \| Pflicht \| Incident-Frage \| Sensor \|' spec/spezifikation.md` → 1 | 0: die Spalte fällt oder die Kopfzeile ändert sich |
| 4 | 3 Menge der Zeilen | Messkommando (Block unter der Tabelle) | heute die 19 Kennungen der Festlegung 3; nach dem Nachzug `SPEC-051 SPEC-052 SPEC-053` | nach dem Nachzug eine andere Menge als diese drei |
| 5 | 3 Ebenen-Zuordnung | — | **keiner** | eine falsch zugeordnete Zeile: [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) trägt sie nicht, oder die Zeile ist Träger-Verhalten und verlässt die Spezifikation. Träger ist die Review des Nachzugs |
| 6 | 3 der Guard ist nicht emittiert | Messkommando | `ls internal/emit/templates/enforce \| grep -c 'agent-guard'` → 0 | ≥ 1: ein Guard-Bestandteil wird emittiert, `SPEC-041`, `085`, `086` gehören dann wieder in die Spec |
| 7 | 3 Ereignisse sind emittiert | Messkommando | `grep -c SubagentStart internal/emit/templates/enforce/settings-capture-hooks.json` → 1 | 0: die Verdrahtung entfällt, `SPEC-051` bis `053` sind dann keine Träger-Aussage |
| 8 | 4 U14 und U38 | — | **keiner** | ein Negativ ohne Grund gilt nicht; Träger ist die Review dieser ADR. Rot nicht herstellbar: ein akzeptiertes Negativ hat kein Gegenbeispiel, das ein Sensor sähe |
| 9 | 5 Prüfstein-Kommentar | Messkommando | `grep -c PRUEFSTEIN internal/span/response_test.go` → 1 | 0: der Träger der Begründung fehlt. **Lücke:** kein Sensor hält den Kommentar gegen die `mustNotContain`-Liste |
| 10 | 6 schreibende Rolle | Messkommando | `git log --format=%s <Annahme-Commit>..HEAD -- docs/user/rollen-laeufe.md \| grep -vc 'Rolle Architect'` → 0 | ≥ 1: ein Commit an der Datei nennt eine andere Rolle. **Lücke:** der Sensor liest die Message, nicht die Rolle ([`AGENTS.md`](../../../AGENTS.md) §3.8 nennt dieselbe Grenze) |
| 11 | 7 Regel zu toten Slices | — | **keiner** | eine neue Plan-Datei in `open/`, deren Kopf und §1 keinen der vier Auslöser nennt. Von Hand lesbar, kein Sensor (Grund in Festlegung 7); Träger ist der Anweisungssatz des Planners und die Review des Plans |
| 12 | 8 ADR-0075 unverändert | `make adr-immutable` | Kern einer `Accepted`-ADR über der Range unverändert | eine inhaltliche Änderung an ADR-0075 oder ADR-0074 nach dem Annahme-Commit dieser ADR. **Rot nicht herstellbar:** ein Commit im Haupt-Klon liegt außerhalb der Verifikation |
| 13 | Immutabilität dieser ADR nach Annahme | `make adr-immutable` | wie Zeile 12 | eine inhaltliche Änderung nach `Accepted` |

Kommando zu Zeile 4:

```sh
grep -E '\| Lücke \|$' spec/spezifikation.md | grep -oE '^\| `SPEC-[0-9]+`' | tr -d '|` ' | tr '\n' ' '
```

## Re-Evaluierungs-Trigger

- **Wenn der Auftraggeber E1, E3 oder E4 anders entscheidet** *(feedforward)*: Folge-ADR mit `supersedes` auf Festlegung 1,
  Rückbau der betroffenen Einträge in eigenen Schritten.
- **Wenn ein Change Request zu [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) angenommen wird** *(feedforward)*: die Zellen `SPEC-051` bis `053` zeigen auf das
  Element; Festlegung 3 ist für diese Gruppe geschlossen.
- **Wenn der Auftraggeber [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) enger liest** *(feedforward)*: `SPEC-045` bis `047` wechseln in einen zweiten Change Request.
- **Wenn ein Guard-Bestandteil emittiert wird** *(computational feedback — Fitness Zeile 6)*: die Gruppe „verlässt" ist neu zu prüfen.
- **Wenn die schreibende Rolle der Spec-Straten entschieden ist** *(feedforward)*: Festlegung 6 ist neu zu prüfen.
- **Wenn die Regel zu toten Slices ein viertes Mal die Schwelle erreicht** *(feedforward)*: Festlegung 7 ist gegen den neuen Beleg
  neu zu prüfen — ein möglicher Sensor oder ein Grund, der die Begründung dort trägt.
- **Wenn ein Abweichungs-Eintrag ohne vorherige Prüfung „ableitbar / vermeidbar" entsteht** *(feedforward)*: die Methode aus
  Festlegung 5 wandert als Satz in die Karte des Architects (`.claude/agents/architect.md`).
- **Wenn eine Entscheidung die Aussage zum Nutzer-Aufruf braucht** *(feedforward)*: die Messung entsteht (Festlegung 4).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-30 | Proposed | Architect-Lauf zu den Übergaben A-1 bis A-5 und A-7 der [Verifikation](../../reviews/2026-09-30-slice-spec-aufnahme-regel-und-umbau-verifikation.md). Die Annahme liegt beim Auftraggeber. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-NNNN` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
