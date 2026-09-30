# Slice slice-spec-5-entscheidungen-nach-dem-umbau: Die Ausgänge der zwei Entscheidungen zu Spec §5 sind festgehalten, die Quellen der offenen Prozess-Sätze benannt und die Ebene der 19 Lücke-Zeilen entschieden (Architect)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung über die DoD hinaus (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug),
[`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) und
[`ADR-0075`](../../adr/0075-begruendungen-zu-spec-5-sammel-adr.md) (beide `Accepted`, unveränderlich: Korrekturen sind Folge-ADR),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md),
[`MR-075`](../../../../harness/conventions.md#mr-075), [`MR-076`](../../../../harness/conventions.md#mr-076),
[`MR-077`](../../../../harness/conventions.md#mr-077), [`MR-015`](../../../../harness/conventions.md#mr-015),
[`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.8.

**Berührte Spec-Stellen:** — (der Slice ändert keine Spec-Zeile; die Zeilen mit `Lücke` in
[§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) sind sein Gegenstand, nicht sein Edit-Ziel).

**Verantwortlich:** Architect (pt9912). Ausführende Rolle: **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8); der Planner schreibt keinen Norm-Text, dieser Plan ist das Übergabe-Artefakt.

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die Übergaben A-1 bis A-5 und A-7 aus der Verifikation
(`docs/reviews/2026-09-30-slice-spec-aufnahme-regel-und-umbau-verifikation.md`) sind entschieden; die Entscheidung steht in einer
Folge-ADR und, wo sie einen Adaptions-Eintrag trägt, im Konventionsspeicher. Die Bedingungen stehen in diesem Plan, weil der Lauf, der sie
trägt, ihn liest und den Bericht nicht.

1. **Liefer-Punkt 1 — die Folge-ADR zu den Ausgängen.** Sie hält fest: (a) E1, E3 und E4 aus
   [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) sind vollzogen — Abweichungen 1 und 2 als
   [`MR-076`](../../../../harness/conventions.md#mr-076) und [`MR-077`](../../../../harness/conventions.md#mr-077), die Prozess-Konvention in
   `docs/user/rollen-laeufe.md`, die Spalte `Sensor` bleibt —, ohne dass eine Folge-ADR den Ausgang trägt (der Re-Evaluierungs-Trigger 4 der
   ADR verlangt ihn dort); (b) Fitness-Zeile 13 verlangt für `START-KONVENTION` den Wert vor dem Umbau (1), der Ist-Wert ist 0
   (`grep -c 'START-KONVENTION' spec/spezifikation.md`) — die Zeile wird korrigiert, nicht der Bestand; (c) die zwei Begründungen ohne Träger in
   [`ADR-0075`](../../adr/0075-begruendungen-zu-spec-5-sammel-adr.md) (die Methode „Erst die Prüfung, dann die Abweichung" und die Begründung des
   Prüfsteins „Kippen, nicht Rot") bekommen einen Träger oder ein begründetes Negativ; (d) die Prozess-Zustände U14 (Bedingung 1 der
   Start-Konvention ohne Durchsetzung) und U38 (ob der Nutzer-Aufruf einen Span erzeugt) haben keinen Träger — Register-Eintrag oder
   akzeptiertes Negativ mit Grund. Und sie sagt, wie die nach `Accepted` eingefügte Geschichte-Zeile in [`ADR-0075`](../../adr/0075-begruendungen-zu-spec-5-sammel-adr.md) geheilt wird
   ([`AGENTS.md`](../../../../AGENTS.md) §3.4; der Immutabilitäts-Sensor meldete sie nicht) — die Wahl trifft der Architect.
   Fitness je Festlegung mit benanntem, rot zu sehendem Gegenbeispiel.
2. **Liefer-Punkt 2 — zwei Quellen.** (a) Wer `docs/user/rollen-laeufe.md` schreibt: die Datei wurde als „Rolle Architect" committet, keine
   Quelle benennt die schreibende Rolle. (b) Zielort und Inhalt der Regel zu `BEO-ALL/geplanter-slice-wird-nie-gearbeitet`: der Eintrag hat die
   Schwelle erreicht, der Lese-Schritt des Planners weist die Verkörperung diesem Slice zu (Baseline-Regelwerk `modul-08-agentenrollen.md`,
   Zug 3b). **Vorschlag des Planners, keine Norm:** ein aus einem Befund geschnittener Slice führt bis zur ersten Beanspruchung eine Zeile im
   Register statt einer Plan-Datei — der Architect übernimmt oder verwirft. Erscheint dieselbe Klasse ein viertes Mal, verlangt
   `modul-06-roadmap.md` Schritt 3 einen mechanischen Sensor oder die Begründung, warum keiner möglich ist.
3. **Liefer-Punkt 3 — die Ebene der 19 `Lücke`-Zeilen.** Der Architect entscheidet je Zeile, ob
   [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) sie als Präzisierung trägt (Ebenen-Test der
   [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md)). Eingang ist die Zuordnung der Verifikation, Abschnitt 2.5: zutreffend
   `Lücke` (`SPEC-040`, `041`, `051`, `052`, `053`, `054`, `084`, `085`, `086`); tragbar durch [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) nach ihrer Lesart (`SPEC-014`, `037`, `060`, `063`, `065`, `082`);
   Ebenen-Frage offen (`SPEC-045`, `046`, `047`, `056`). Menge und Nummern misst der Lauf neu (`grep -n '| Lücke |' spec/spezifikation.md`). Ergebnis ist eine
   benannte Liste. Der gebündelte Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015) bleibt Entscheidung des Auftraggebers; der
   Architect benennt die Lücken und schreibt keine Anforderung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Edit an `spec/`.** Wo eine Zelle von `Lücke` auf einen Anker wechselt, ist das Bestandsarbeit eines Implementer-Laufs nach der Entscheidung — sonst schreibt derselbe Lauf Norm und Bestand.
- **Kein Sensor und keine Zeilen-Bedingung.** Schranke der `Präzisiert`-Zählung, Zeiger auf entfernten Wortlaut, `SPEC-040` und die Sensor-Namen: `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau`.
- **Kein Parser des Existenz-Sensors.** Die Bedingung (Kopfzeilen-Präfix und Spalte 2) steht im Plan von `slice-feldabdeckung-existenz-sensor`.
- **Kein Change-Request-Text.** Anderer Vorgang, Auftraggeber-Entscheidung; ein Auftrag in `open/` entsteht nach der Liste aus Liefer-Punkt 3.
- **Keine emittierte Feldliste.** `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung` trägt sie; anderer Vorgang, Tool-Ebene.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste.

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Liefer-Punkt 1 — die Folge-ADR** liegt vor, `Schärft:` nennt beide ADRs als Link; Fitness je Festlegung nennt, was rot werden muss; die Rot-Beobachtung liegt im Bericht des Verifiers ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der ADR-Index trägt die Zeile im selben Commit.
- [x] **Liefer-Punkt 2 — zwei Quellen** stehen (Rolle der Datei `docs/user/rollen-laeufe.md`; Zielort und Inhalt der Regel zu `geplanter-slice-wird-nie-gearbeitet`), als ADR-Festlegung oder Adaptions-Eintrag in eigenem Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- [x] **Liefer-Punkt 3 — die benannte Liste** der `Lücke`-Zeilen mit Ebenen-Entscheidung je Zeile steht in der Folge-ADR oder im Bericht des Architect.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update entfällt, solange die ADR keinen öffentlichen Vertrag ändert; ändert sie einen, steht es im Bericht.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| ADR unter `docs/plan/adr/` (Architect) | neu | Liefer-Punkte 1 und 3 |
| `docs/plan/adr/README.md` (Architect) | update | derivativ ([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| `harness/conventions.md` und `harness/conventions/` (Architect) | update, falls Liefer-Punkt 2 einen Eintrag trägt | [`AGENTS.md`](../../../../AGENTS.md) §3.8 |

- Eingang: der Verifikationsbericht (Übergaben A-1 bis A-5, A-7; Abschnitt 2.5) und beide Reviews.
- Die schreibende Rolle von Spec §5 bleibt offen (`slice-151-spec-straten-haben-eine-schreibende-rolle`); dieser Slice entscheidet sie nicht mit.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-spec-5-wird-nach-adr-0074-umgebaut` liegt in `done/` (`ls docs/plan/planning/done/slice-spec-5-wird-nach-adr-0074-umgebaut.md`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß): wenn Liefer-Punkt 3 (19 Zeilen) in derselben Sitzung nicht prüfbar ist — dann eine ADR je Liefer-Punkt.
- `in-progress` → `open` (blockiert): wenn die Ebenen-Entscheidung eine Anforderung des Lastenhefts verlangt, die fehlt — der Change Request ist Sache des Auftraggebers.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) die Folge-ADR ist `Accepted` und ihr Index-Eintrag steht; (2) `make gates` grün mit Stempel, der den
Arbeitsbaum deckt. Dazu der Lerneintrag. Den Abschluss schreibt der Planner ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Ist die Liste aus
Liefer-Punkt 3 nicht leer, legt der Planner bei der Closure den Auftrag für den gebündelten Change Request in `open/` an (per `cp`).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Ebenen-Zuordnung der Zeilen bleibt Urteil ohne Sensor.** — **Ausgang:** wird bei der Closure eingetragen.
- **Die Regel zu `geplanter-slice-wird-nie-gearbeitet` bleibt Prosa ohne Sensor**, und die Klasse tritt ein viertes Mal ein. — **Ausgang:** wird bei der Closure eingetragen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Zustand:** Liefer-Punkte 1 bis 3 bestätigt im Verifikationsbericht `docs/reviews/2026-09-30-slice-spec-5-nachlauf-verifikation.md`:
  Folge-ADR [`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md) (Accepted, `make adr-immutable` ohne Befund), Quellen in Festlegung 6 und 7, Ebenen-Liste in Festlegung 3; der Nachzug der Zellen lief in `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau`.
- **Steering-Loop-Eintrag — geschärfte Regel:** eine Plan-Datei in `open/` entsteht nur mit einem von vier Auslösern. liegt in `.claude/commands/plan-welle.md` §Slices bereitstellen (`· seit slice-spec-5-entscheidungen-nach-dem-umbau`). Grenze, benannt: kein Sensor, ob ein Auslöser vorliegt, ist Urteil.
- **Review:** Report `docs/reviews/2026-09-30-adr-0076-review.md` liegt vor, kein HIGH. Die Findings sind Folge-ADR-Punkte des Architect (`AGENTS.md` §3.4: eine `Accepted`-ADR ist unveränderlich), keine Plan-Datei — kein Auslöser nach `.claude/commands/plan-welle.md` §Slices bereitstellen:
  - MEDIUM, Festlegung 6 — die Schreibrolle für `docs/user/rollen-laeufe.md` ist aus [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) abgeleitet, die für übrige Norm-Artefakte nichts sagt: eine neue Setzung. Ausgang: Register, Beleg in [`rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet`](../observations/BEO-ALL/rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet/observation.md).
  - LOW, Fitness-Zeile 4 — überholt (Ist-Stand leer wegen Lastenheft 0.23.0), Platzhalter `<Annahme-Commit>` in Zeile 10. Ausgang: Register, neue Beobachtung [`fitness-zeile-einer-angenommenen-adr-ist-nach-dem-vertrag-tot`](../observations/BEO-ALL/fitness-zeile-einer-angenommenen-adr-ist-nach-dem-vertrag-tot/observation.md).
  - LOW, Ebenen-Zuordnung — `SPEC-082`, `063`, `054` tragen dünnen Wortlaut-Bezug. Ausgang: *weiter offen* (Risiko-Eintrag zur Ebenen-Zuordnung unten, Register [`prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)); Folge-ADR-Punkt des Architect beim nächsten Anfassen.
- **Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015):** entfallen. Lastenheft 0.23.0 (Commit `3581f670`) trägt das Kriterium *Erfassungs-Umfang*; `SPEC-051` bis `053` tragen den Anker, der Ist-Stand der `Lücke`-Zeilen ist leer. Kein Auftrag in `open/`.
- **Beobachtungs-Register:** [`geplanter-slice-wird-nie-gearbeitet`](../observations/BEO-ALL/geplanter-slice-wird-nie-gearbeitet/observation.md) hat seinen Ausgang *verkörpert* (`state.md`); kein Beleg aus diesem Vorgang. Belege aus dem Review: siehe Zeile *Review*.
- **Risiken aus §6:**
  - Ebenen-Zuordnung bleibt Urteil ohne Sensor — *weiter offen*: Register [`prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md) (kein Beleg aus diesem Vorgang).
  - Regel zu `geplanter-slice-wird-nie-gearbeitet` bleibt Prosa, Klasse tritt ein viertes Mal ein — *weiter offen*: Register [`geplanter-slice-wird-nie-gearbeitet`](../observations/BEO-ALL/geplanter-slice-wird-nie-gearbeitet/observation.md), Grenze der Prosa-Form in dessen `state.md`.
- **Drei Paarungen:** nach dem `git mv` geprüft.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*` (gesamtes Repo, Kürzel `ALL`, Modus
Greenfield laut Modus-Deklaration in `harness/conventions.md`). Die Deklaration führt für `spec/` keine feinere
Sub-Area, und alle Beobachtungen des Registers tragen diese eine; die Schwelle ≥ 2 von 3 Achsen lässt sich damit
nicht feiner prüfen, als die Deklaration es zulässt — benannt, nicht gelöst.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, gemergter Stand; Zähler = Dateien unter
`evidence/` (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`). Treffer am Gegenstand „Regel zu einem Register-Eintrag,
Folge-ADR, Lücke zwischen Spec und Lastenheft":

- [`geplanter-slice-wird-nie-gearbeitet`](../observations/BEO-ALL/geplanter-slice-wird-nie-gearbeitet/observation.md) — Zuweisung der Verkörperung an diesen Slice (Liefer-Punkt 2 b).
- [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) — geplant; berührt die Belegklasse der Zeilen, die Liefer-Punkt 3 liest.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
