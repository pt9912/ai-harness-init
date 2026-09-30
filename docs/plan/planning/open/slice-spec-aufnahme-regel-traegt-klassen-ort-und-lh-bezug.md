# Slice slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug: Klassen, Ort der Messprotokolle und LH-Bezug-Spalte von Spec §5 sind entschieden (Architect)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — dieselbe Feststellung wie im Slice
`slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert` (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht): keine Closure-Bedingung über die DoDs hinaus.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug wie
im Vorgänger-Slice),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (Festlegung 1: §5 ist Zielort; **Accepted**,
wird nicht revidiert, sondern durch die neue ADR geschärft),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) und
[`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (wer Norm-Artefakte
schreibt),
[`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (der ADR-Index
gehört dem Architect),
[`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) (`Proposed`; bindet die
Tabellenform von §5),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (Immutabilität), §3.5 (Senkung braucht eine ADR), §3.8
(Architect schreibt ADRs), §3.11 (Adressen in einfrierenden Artefakten).

**Berührte Spec-Stellen:**
[§Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel) und
[§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) — die ADR nennt sie in ihrem
`Schärft:`-Feld; dieser Slice ändert sie nicht.

**Verantwortlich:** — bis zur Priorisierung. Ausführende Rolle: **Architect**
([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md)).
Der Planner schreibt keinen ADR-Text; dieser Plan ist das Übergabe-Artefakt.

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Eine ADR, geschrieben vom Architect auf der Menge aus `slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert`,
entscheidet die Klassen des Spec-Fließtexts, den Ort der Messprotokolle und die LH-Bezug-Spalte — und
gibt dem Planner den Hinweis, nach dem er die Umbau-Slices schneidet.

**Zu entscheiden — Fragen an den Architect** (der Planner beantwortet keine, er benennt die Kanten):

1. **Klassenraster.** Arbeitshypothese des Auftraggebers: Festlegung · Begründung · Messprotokoll.
   Der Vorgänger-Slice führt zwei Zeilen mehr: *Abweichung von der Baseline* (Aufnahme-Regel Zeilen 20
   bis 23 weist sie ins Konventionsdokument, die §5-Einleitung führt sie hier; Widerspruch innerhalb der
   Spec, betrifft rund 18 KB; der Adaptions-Eintrag [`MR-021`](../../../../harness/conventions.md#mr-021)
   ist bei der Planung nicht gelesen) und *passt in keine*. Die fünf Kommentar-Klassen aus
   [`AGENTS.md`](../../../../AGENTS.md) §3.7 passen nach Befund des Planners nicht als Raster.
   *Ergänzung aus dem Klassifikationsbericht des Vorgänger-Slice* (Zeitdokument unter `docs/reviews/`,
   Klassenverteilung in seinem §2): Klasse `d` und Klasse `e` tragen je einen erheblichen Anteil des
   Fließtexts; Klasse `e` bezeichnet die Spec selbst als unbewacht. Der Bericht markiert Grenzfälle
   und entscheidet keinen — die Zuordnung jedes markierten Grenzfalls urteilt der Architect am
   Wortlaut. Die Prozess-Konventionen des Fließtexts (Einheiten `U09`, `U10`, `U13`, `U15` des
   Berichts) sind gegen die Klassen zu halten.
   **Auftraggeber-Frage, die der Architect stellt und nicht beantwortet:** Gehört die Abweichung von
   der Baseline in die Spezifikation ([`MR-021`](../../../../harness/conventions.md#mr-021)) oder ins
   Konventionsdokument (Aufnahme-Regel, Zeile 21)? Die Spec widerspricht sich hier selbst; die
   Antwort entscheidet, ob Klasse `d` eine Klasse der Spec bleibt.
2. **Ort, Konsument und Form der Messprotokolle.** Optionen: entfallen (git hält sie) · Zeitdokument
   unter einem Unterordner von `docs/` (Auftraggeber erwägt das). Jede Option hat vier Randbedingungen,
   die die ADR beantworten muss: ein **Konsument** (sonst kein Artefakt,
   [`MR-025`](../../../../harness/conventions.md#mr-025)); **Form mit Kommando und Ausgabe**; die Spec darf
   **nicht dorthin zeigen** (die `matrix`-Klasse `spec-straten` verbietet den Weg nach außen); und ob
   `exempt-paths` in der `.d-check.yml` erweitert werden — das wäre eine Senkung nach
   [`AGENTS.md`](../../../../AGENTS.md) §3.5 und braucht in der ADR eine eigene Festlegung.
   Bestand: `docs/reviews/**` ist bereits ausgenommen (`.d-check.yml`, Zeilen 327 bis 343 und 374).
   *Ergänzung aus dem Bericht:* das Messprotokoll mischt vier Aussagearten; die ADR sagt, ob alle vier
   denselben Ort bekommen. [`MR-021`](../../../../harness/conventions.md#mr-021) nennt bereits ein
   Zeitdokument unter `docs/reviews/` als Ort einer Messreihe — Bestand, an dem die Option gemessen
   wird, keine Vorentscheidung.
3. **LH-Bezug-Spalte.** Name (Auftraggeber: „Präzisiert LH-…“), Form der Fundstelle (Anker-Link, die
   link-policy verlangt ihn), Behandlung einer Zeile ohne Lastenheft-Element (benannte Spec-Lücke; eine
   LH-Änderung wäre ein Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015), nicht
   Sache der Spec), und ob §5 als Ganzes ein Lastenheft-Element präzisiert.
   *Ergänzung aus dem Bericht:* Kandidaten mit Bindungsstufe (`einzeln` / `pauschal` / `nahe`) und die
   Zeilen „kein LH gefunden“ (benannte Spec-Lücke) stehen im LH-Vorschlag des Berichts. Die Kandidaten
   tragen einen Ebenen-Vorbehalt: `LH-FA-10` beschreibt das Verhalten im **Zielrepo**, die Spec-Zeile
   teils das **dieses** Repos — die ADR entscheidet die Ebenen-Passung der Bindung.
   **Fehlt ein Lastenheft-Element für eine Spec-Zeile, ist das ein Change Request am Lastenheft nach
   [`MR-015`](../../../../harness/conventions.md#mr-015)** — Entscheidung des Auftraggebers; der
   Architect benennt die Lücke und schreibt keine Anforderung.
4. **Wohin die Begründungen (Klasse b) gehen:** eine Sammel-ADR zu §5 oder je Umbau-Block eine
   schärfende ADR. Das entscheidet, ob ein Umbau-Slice einen Architect-Schritt in der Mitte hat.
5. **Wer §5 schreibt.** `slice-151-spec-straten-haben-eine-schreibende-rolle` (offen) führt die Frage;
   bisher haben Implementer-Läufe §5 geändert. Die ADR darf sie mitentscheiden, muss nicht.
6. **Bindungs-Bilanz.** Die Nennung eines Wächters in der Spec ist unbewacht (Kopf von §5); ob der
   Umbau einen Sensor braucht, oder ob `slice-feldabdeckung-existenz-sensor` ihn trägt — und wie sich
   dessen Tabellenparser zur neuen Spalte verhält.
7. **Das emittierte Gegenstück** (die Spezifikations-Vorlage im Emit-Baum) ist ein anderer
   Vorgang (Dogfood vs. emittiert); die ADR sagt, ob er entsteht.
8. **Zwei Zeiger ohne Gegenstück in eingefrorenen ADRs.**
   [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Zeile 214) und
   [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Zeilen 72 und 652) erwarten
   eine Spec-Passage, die es nicht gibt (Randbefunde im Klassifikationsbericht des Vorgänger-Slice).
   Beide sind `Accepted` und unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4); die ADR sagt,
   ob eine Folge-ADR sie auffängt oder die Lücke als bekannt stehen bleibt.
9. **Schnitt der Umbau-Slices.** Der Bericht schneidet den Fließtext feiner als der Plan des
   Vorgänger-Slice (die Abweichung steht in seinem §1); ob die Umbau-Slices dem Einheiten-Schnitt des
   Berichts folgen, hält die ADR im Schnitt-Hinweis für den Planner fest.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein ADR-Text vom Planner.** Der Rollenwechsel braucht ein Artefakt, keine Vorwegnahme
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); die Fragen oben sind die Übergabe.
- **Kein Edit an `spec/`.** Die Norm ist die ADR; der Spec-Text folgt im Slice
  `slice-spec-tabellen-tragen-die-lh-bezug-spalte` und in den Umbau-Slices — sonst schreibt derselbe
  Lauf Norm und Bestand.
- **Keine Klassifikation einzelner Absätze.** Sie ist die Eingabe aus dem Vorgänger-Slice; die ADR
  nennt die Menge (Zahl mit Kommando), keine Zeile.
- **Kein emittiertes Gegenstück** (Frage 7) — anderer Vorgang, Tool-Ebene.

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

- [ ] **Liefer-Punkt 1 — die ADR.** Sie liegt vor, `Schärft:` nennt die Aufnahme-Regel und §5 als
      Link, und sie beantwortet die Fragen 1 bis 3 mit Festlegungen (4 bis 7: beantwortet oder als
      offen mit Trigger benannt). Ihre Fitness Function nennt **je Festlegung, was rot werden muss**;
      die Rot-Beobachtung liegt im Bericht des Verifiers. Eine Festlegung ohne benanntes
      Gegenbeispiel gilt als nicht fertig ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **Liefer-Punkt 2 — der ADR-Index** trägt die Zeile (derivativ, Architect,
      [`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update entfällt: die ADR ändert keinen öffentlichen Vertrag; der Spec-Text folgt in den
      Folge-Slices.
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
| ADR unter `docs/plan/adr/` (Architect) | neu | Liefer-Punkt 1; Kopf nennt den Bericht des Vorgänger-Slice bei seiner **Kennung**, nicht als Pfad (§3.11: er wandert) |
| `docs/plan/adr/README.md` (Architect) | update | Liefer-Punkt 2, derivativ |

- Eingang: der Bericht des Vorgänger-Slice (Klassifikationstabelle, Zeiger-Inventar, LH-Vorschlag).
  Grenzfälle daraus urteilt der Architect selbst am Wortlaut.
- Die Zeiger-Inventar-Zeilen bestimmen, welche Passagen-Namen („Abweichung 1“, „Lesevorschrift“, …) die
  Umbau-Slices als Namen erhalten oder nachziehen müssen; die ADR hält das als Folgepflicht fest.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Slice `slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert`
liegt in `done/` und sein Bericht ist gelesen (die Menge steht, nach der entschieden wird).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Fragen 1 bis 3 nicht in einer
  Review-Sitzung prüfbar sind — dann eine ADR je Frage-Gruppe (Klassen · Ort · Spalte).
- `in-progress` → `open` (blockiert — Carveout?): wenn der Bericht des Vorgängers Klassen zeigt, die
  keines der Raster trägt (Klasse „passt in keine“ überwiegt) — dann geht der Vorgänger zurück, nicht
  die ADR vor.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) die ADR ist `Accepted` **und** ihr ADR-Index-Eintrag steht;
(2) `make gates` grün mit Stempel, der den Arbeitsbaum deckt. Dazu der Lerneintrag (geschärfte Regel ·
neuer Sensor · benannte Spec-Lücke). Den Abschluss schreibt der Planner in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10). Bei der Closure legt der Planner die Umbau-Slices an, die
die ADR in ihrem Schnitt-Hinweis nennt (per `cp` in `open/`).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die ADR wird vor ihrer Bewährung unveränderlich**; ein Fehlgriff kostet einen Folge-ADR. —
  **Ausgang:** wird bei der Closure eingetragen (eingetreten / entfallen / weiter offen). Vorkehrung: die
  Menge steht vorher (Vorgänger-Slice), und die ADR bleibt bis zur Review-Runde lokal.
- **`slice-feldabdeckung-existenz-sensor` liest die Tabelle von §5**; eine neue Spalte oder ein
  geänderter Zeilen-Schnitt berührt seinen Parser. — **Ausgang:** wird bei der Closure eingetragen.
- **Eine Senkung durch `exempt-paths` wird als Ortsentscheidung getarnt.** — **Ausgang:** wird bei der
  Closure eingetragen; die ADR muss sie als eigene Festlegung führen ([`AGENTS.md`](../../../../AGENTS.md) §3.5).

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

Wird bei der Closure vom Planner gefüllt ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht vom
Architect-Lauf, der die ADR geschrieben hat.

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
Dieser Slice ändert keine Zeile der Spec; die Einträge sind Kontext für die Slices, die es tun.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
