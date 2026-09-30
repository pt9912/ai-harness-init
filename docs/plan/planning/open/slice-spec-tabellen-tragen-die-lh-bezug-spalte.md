# Slice slice-spec-tabellen-tragen-die-lh-bezug-spalte: Die Tabellen von Spec §3 und §5 nennen je Zeile das Lastenheft-Element, das sie präzisieren

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung über die DoD hinaus (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht; Begründung im Slice
`slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert`).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug;
welche Zeile welches Element präzisiert, liefert der LH-Vorschlag des Klassifikations-Slice),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (Zielort),
[`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) (`Proposed`; Tabellenform),
die ADR aus `slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug` (**Voraussetzung, `Accepted`**;
sie legt Spaltenname und Fundstellen-Form fest — dieser Plan wiederholt sie nicht),
[`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** [§3](../../../../spec/spezifikation.md#3-defaults-und-konstanten),
[§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) (die drei Tabellen; `SPEC-001` bis
`SPEC-034`), [§Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel), §7 Historie.
Der Verweis zeigt aufwärts; die Spec nennt diesen Slice nie.

**Verantwortlich:** — bis zur Priorisierung. Ausführende Rolle: Implementer-Kontext, wie bisher bei
Änderungen an §5, solange keine Quelle die schreibende Rolle der Spec-Straten benennt
(`slice-151-spec-straten-haben-eine-schreibende-rolle`, offen).

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Jede Zeile der drei Tabellen (§3 und die zwei Tabellen von §5) trägt in der Spalte, die die
ADR benennt, einen Anker-Link auf ihr Lastenheft-Element — oder den ausdrücklichen Vermerk, dass es
keines gibt —, und die Aufnahme-Regel nennt Klassen und Spalte in der Fassung der ADR.

**Ausgangslage, gemessen:**

```sh
grep -c 'SPEC-[0-9]' spec/spezifikation.md      # 34  Zeilen mit Kennung (SPEC-001 bis SPEC-034: 2 in §3, 26 Feldtabelle, 6 Werkzeug-Tabelle)
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Umbau des Fließtexts.** Der Slice fasst nur die Tabellen an und ist darum unabhängig vom
  Zuschnitt der Umbau-Slices; der Fließtext folgt in `slice-spec-5-erfassung-aus-tool-response-steht-als-tabellenzeilen`
  und dessen Folge-Schnitten.
- **Kein Lastenheft-Edit.** Eine Zeile ohne Element bleibt eine benannte Lücke; ihr Ausgang ist ein
  Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015), ein anderer Vorgang mit
  anderem Autor.
- **Keine Neu-Vergabe von Kennungen.** `SPEC-<NNN>` ist eine Adresse und wird nie neu vergeben
  (Aufnahme-Regel); die Spalte kommt hinzu, die Zeilen bleiben.
- **Keine Änderung am Parser von `slice-feldabdeckung-existenz-sensor`.** Ist der Sensor vorher
  gebaut, zieht **dieser** Slice seinen Parser nach (§6); ist er nachher dran, liest er die neue Form.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — die Spalte.** Alle 34 Zeilen tragen einen Wert; ein Wert ist ein
      Anker-Link ins Lastenheft oder der vereinbarte Vermerk. **Rot gesehen, an der realen Quelle:**
      (i) ein Link mit erfundenem Anker → `make docs-check` meldet ihn (`anchors`); (ii) eine geleerte
      Zelle → ob das Gate sie meldet, wird gefahren und im Report festgehalten. Bleibt sie grün, ist
      das eine **benannte Lücke** (kein Sensor hält „jede Zeile trägt den Wert“), und der Lerneintrag
      ist ein neuer Sensor, nicht ein Satz in der Spec.
- [ ] **Liefer-Punkt 2 — die Aufnahme-Regel und ihre Ränder.** Der Text nennt Klassen und Spalte wie
      die ADR; der Kopf („Letzte Änderung“) und eine Zeile in §7 Historie stehen (ohne die Zeile
      bleibt die Änderung in der Spec unsichtbar — Beobachtung
      [`spec-aenderung-ohne-historie-zeile`](../observations/BEO-ALL/spec-aenderung-ohne-historie-zeile/observation.md)).
      Die Spec zeigt nach dem Edit weiter nicht abwärts: `make docs-check` bleibt grün (`matrix`,
      `ids`); **Bruchprobe:** eine ADR-Kennung nackt in eine Zelle → rot.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Handbuch-Sicht (`docs/user/`) nennt keine Spalte von §5; Prüfung per
      `grep -rn 'spezifikation' docs/user | wc -l` steht im Bericht, ein Treffer wird nachgezogen.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` | update | drei Tabellen um die Spalte; Aufnahme-Regel; Kopf; §7 — Liefer-Punkte 1 und 2 |
| `internal/span/`, `test/` | keine | kein Wächter liest den Wortlaut der Spec (gemessen im Klassifikations-Slice, §1); die Tabellen-Änderung bricht keinen Test |

- Die Zellen-Anzahl der Zeilen bleibt je Tabelle einheitlich; Pipes im Zellinhalt sind `\|`-maskiert
  (die Zeile `SPEC-031` trägt schon solche).

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): die ADR aus `slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug`
ist `Accepted`, und der LH-Vorschlag des Klassifikations-Slice liegt vor.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn für mehr als die Hälfte der Zeilen kein
  Lastenheft-Element gefunden wird — dann ist die Zuordnung selbst der Befund und geht an den
  Architect, bevor 34 Zellen mit „kein LH“ gefüllt werden.
- `in-progress` → `open` (blockiert — Carveout?): wenn `slice-feldabdeckung-existenz-sensor` zuerst
  in `in-progress/` steht — WIP und Parser-Kopplung klären, dann erst die Spalte.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make docs-check` meldet keinen Befund und die Bruchproben aus
Liefer-Punkt 1 und 2 stehen im Report; (2) `make gates` grün mit Stempel, der den Arbeitsbaum deckt.
Dazu der Lerneintrag. Den Abschluss schreibt der Planner ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Kein Lastenheft-Element für viele Zeilen** — dann fehlt dem Lastenheft eine Anforderung, oder §5
  gehört keiner. — **Ausgang:** wird bei der Closure eingetragen (eingetreten / entfallen / weiter offen).
- **Der Tabellenparser aus `slice-feldabdeckung-existenz-sensor` bricht an der neuen Spalte.** —
  **Ausgang:** wird bei der Closure eingetragen.
- **Die Spalte bleibt Dekoration**, weil kein Sensor sie hält (siehe Rot-Probe (ii)). — **Ausgang:** wird
  bei der Closure eingetragen.

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

Wird bei der Closure vom Planner gefüllt ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*` (gesamtes Repo, Kürzel `ALL`,
Modus Greenfield laut Modus-Deklaration in `harness/conventions.md`). Die Deklaration führt für
`spec/` keine feinere Sub-Area, und alle Beobachtungen des Registers tragen diese eine; die Schwelle
≥ 2 von 3 Achsen lässt sich damit nicht feiner prüfen, als die Deklaration es zulässt — benannt, nicht
gelöst.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, gemergter Stand; Zähler =
Dateien unter `evidence/` (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`). Treffer
am Gegenstand „Spec-Text, Messungen, Kopplung an Code“:

- [`spec-aenderung-ohne-historie-zeile`](../observations/BEO-ALL/spec-aenderung-ohne-historie-zeile/observation.md)
  — 1×, offen: eine Änderung an Lastenheft oder Spezifikation ohne Zeile in der Historie.
- [`spec-zeile-enger-als-der-code-den-sie-beschreibt`](../observations/BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt/observation.md)
  — 1×, offen.
- [`festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten`](../observations/BEO-ALL/festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten/observation.md)
  — 1×, offen.
- [`feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`](../observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/observation.md)
  — 1×, offen; sein Existenz-Sensor ist `slice-feldabdeckung-existenz-sensor` (`open/`, hängt an einer
  `Proposed`-ADR).
- [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md)
  — 6×, geplant (`slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`); berührt die
  „gemessen am …“-Zeilen des Fließtexts unmittelbar.
- [`mess-zusage-trifft-das-eigene-zitat`](../observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/observation.md)
  — 5×, verkörpert ([`MR-058`](../../../../harness/conventions.md#mr-058), Adaptions-Block).

Kein Eintrag erreicht mit diesem Slice die 3×-Schwelle: ein Slice legt je Eintrag höchstens eine
Beleg-Datei an, die drei Einträge mit einem Beleg kämen auf 2×.
Dieser Slice **ändert die Spec**; die ersten drei Einträge betreffen ihn darum unmittelbar (Zeile in §7
Historie · Zeile enger als der Code · Reichweite von Festlegung und Rumpf).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
