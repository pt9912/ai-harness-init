# Slice slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert: Der Fließtext von Spec §5 ist Absatz für Absatz einer Klasse zugeordnet, bevor jemand ihn umbaut

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht fragt nach einer Closure-Bedingung, die mehr beobachtet als die DoDs der Slices.
Für diese Reihe von vier Slices (Klassifikation · Aufnahme-Regel · LH-Bezug-Spalte · Pilot-Umbau)
gibt es keine: die einzige repo-weite Bedingung, `make gates` grün, steht in jeder DoD; „§5 ohne
Fließtext-Messprotokoll“ ist die Summe der Umbau-DoDs und nicht mehr als sie; ein Replay-Lauf
besteht nicht (`grep -nE '^(replay|test-replay)' Makefile` → kein Treffer).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
(Arbeits-Bezug: die Commits, die §5 zuletzt änderten, nennen ihn; ob §5 überhaupt ein Element des
Lastenhefts präzisiert, ist ein Ergebnis dieses Slice und nicht seine Voraussetzung),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (Festlegung 1: §5 ist Zielort der
Feldtabelle),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (die Erfassungs-Policy, deren
Festlegungen §5 trägt),
[`ADR-0071`](../../adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) (`Proposed`; bindet
die Tabellenform, siehe §6),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (eine Zusage braucht ihr rot gesehenes Gegenbeispiel),
[`MR-025`](../../../../harness/conventions.md#mr-025) (jede Zahl steht neben dem Kommando, das sie
liefert).

**Berührte Spec-Stellen:**
[`spec/spezifikation.md` §5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) und
[§Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel) — gelesen, nicht geändert. Der
Verweis zeigt aufwärts; die Spec nennt diesen Slice nie.

**Verantwortlich:** Implementer (pt9912). Ausführende Rolle, als Setzung des Planners vom
Architect im Slice `slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug` zu bestätigen:
Implementer-Kontext — der Lauf liest, misst und schreibt einen Bericht, er schreibt keinen
Norm-Text; Grenzfälle der Klasse gehen als Übergabe-Artefakt an den Architect.

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Jede Einheit des Fließtexts von `spec/spezifikation.md` §5 nach der Werkzeug-Tabelle ist
in einer Tabelle genau einer Klasse zugeordnet — mit den Wächtern, die sie bindet, den Textstellen im
Repo, die sie beim Namen nennen, und einem Lastenheft-Kandidaten —, damit der Architect die Klassen
auf gemessener Menge entscheidet und der Planner die Umbau-Slices an gemessener Größe schneidet.

**Ausgangslage, gemessen** (Kommando neben Zahl, [`MR-025`](../../../../harness/conventions.md#mr-025);
keine Erwartungswerte, die Datei wandert):

```sh
sed -n '137,718p' spec/spezifikation.md | wc -c          # 45889  Fließtext nach der Werkzeug-Tabelle
awk 'NR>=137&&NR<=718{if($0==""){n=0}else if(!n){c++;n=1}}END{print c}' spec/spezifikation.md   # 34  Blöcke
grep -c 'SPEC-[0-9]' spec/spezifikation.md                # 34  Zeilen mit Kennung (der Auftraggeber nannte 36; Vorkommen vs. Zeilen, nicht verfolgt)
grep -nE 'gemessen|20[0-9]{2}-[0-9]{2}-[0-9]{2}' spec/spezifikation.md | awk -F: '$1>=137&&$1<=718' | wc -l   # 35
grep -oE '`Test[A-Za-z0-9_]+`' spec/spezifikation.md | sort -u | wc -l                          # 24  genannte Testnamen
grep -oE 'test/mutations/[0-9]+-[a-z0-9-]+\.sh' spec/spezifikation.md | sort -u | wc -l         # 26  genannte Fall-Dateien
grep -rlE 'spec/spezifikation\.md' internal test cmd | wc -l                                    # 30  Dateien mit Zeiger auf die Spec
```

- Zwei der 34 Blöcke sind Listen von über 6 KB (ab Zeile 470 und ab Zeile 594); bei ihnen ist der
  Listenpunkt die Einheit.
- Die 35 „gemessen/Datum“-Zeilen sind eine **Obergrenze** für Messprotokoll, keine Zahl davon:
  Zeilen wie 450 und 621 sind Zusagen, die das Wort nur benutzen.
- Alle 24 Testnamen und alle 26 Fall-Dateien waren bei der Planung vorhanden (Prüfschleife über
  `func <Name>` und `[ -f <Datei> ]`, kein Fehlbetrag).
- **Kein Sensor liest den Wortlaut der Spec:** in Nicht-Markdown-Dateien nennen nur Pfadlisten
  (`spec-straten` in der `.d-check.yml` und ihrer Emit-Vorlage, Testfixtures) die Datei; die 30
  Dateien oben tragen Kommentare, die §5 oder eine benannte Passage („Abweichung 1“,
  „Lesevorschrift“, „Prüfreihenfolge Punkt 2“) als Rang-Zeiger nennen. Ein Umbau bricht also
  keinen Test, er bricht **Zeiger** — und niemand bemerkt es.

**Klassen — Arbeitshypothese, vom Architect zu bestätigen oder zu ersetzen:** (a) Festlegung,
(b) Begründung, (c) Messprotokoll. Der Slice führt zwei Zeilen mehr: (d) **Abweichung von der
Baseline** — die Aufnahme-Regel (Zeilen 20 bis 23) weist sie ins Konventionsdokument, die
§5-Einleitung führt sie hier (rund 18 KB zwischen den Zeilen 355 und 589); und (e) „passt in keine“.
Die fünf Klassen aus [`AGENTS.md`](../../../../AGENTS.md) §3.7 (Zusage · Kopplung · Abgrenzung ·
Rang-Zeiger · Grenze) passen als Raster **nicht**: sie ordnen einen Kommentar nach dem, was er dem
sagt, der die Stelle ändert; ein Spec-Satz ist normativer Text. Als Zusatzspalte „Aussageart“ darf
der Lauf sie ausweisen (etwa „Nicht gemessen und deshalb offen“ als Grenze), ohne sie zur Klasse zu
machen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Umbau von `spec/` und keine Änderung der Aufnahme-Regel.** Erst die gemessene Menge, dann
  die Norm: eine ADR wird ab `Accepted` unveränderlich ([`AGENTS.md`](../../../../AGENTS.md) §3.4),
  eine Klassenwahl vor der Menge kostet den Folge-ADR. Umbau: `slice-spec-5-erfassung-aus-tool-response-steht-als-tabellenzeilen`.
- **Keine Entscheidung über Klassen, Ort der Messprotokolle oder LH-Spalte.** Das ist Norm-Arbeit
  des Architect (`slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug`); dieser Slice liefert
  die Eingabe und markiert Grenzfälle, statt sie zu entscheiden.
- **Kein Löschen eines Messprotokolls.** „Braucht ein Sensor, Test oder eine ADR die Zeile?“ ist hier
  ein Befund pro Einheit; über Entfallen oder Verlagern urteilt der Umbau nach der ADR.
- **Bestand bleibt bewusst stehen: die Tabellenzeilen `SPEC-001` bis `SPEC-034`.** Sie sind
  Festlegungen nach ihrer Bauart und werden nicht klassifiziert; sie kommen nur als Ziel der
  Wächter-Zuordnung und des LH-Vorschlags vor.
- **Keine Änderung an `internal/`, `test/`, `cmd/`.** Das Zeiger-Inventar ist eine Liste; der
  Nachzug gehört dem Umbau-Slice, der die angesprochene Passage bewegt.

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

- [ ] **Liefer-Punkt 1 — Klassifikationstabelle.** Eine Datei unter `docs/reviews/` (Name trägt die
      Slice-Kennung) ordnet jede Einheit von §5 nach der Werkzeug-Tabelle genau einer Klasse zu;
      Spalten: Zeilenbereich · Klasse · Sicherheit (sicher / Grenzfall) · Bytes · gebundene
      Wächter · Sensor-Abhängigkeit (liest ein Test, Sensor oder eine ADR die Einheit oder nennt
      sie beim Namen?). **Vollständigkeit ist messbar:** die Byte-Summe der Spalte gleicht dem
      ersten Kommando in §1, und jeder der 24 Testnamen und 26 Fall-Dateien steht in der Spalte
      „gebundene Wächter“ (beide Differenzen leer). **Rot gesehen:** eine Zeile aus der Tabelle
      streichen — beide Kommandos zeigen den Fehlbetrag; der Vermerk steht im Review-Bericht.
- [ ] **Liefer-Punkt 2 — Zeiger-Inventar.** Dieselbe Datei listet jede Stelle in `internal/`,
      `test/`, `cmd/`, `harness/tools/` und `docs/plan/adr/`, die §5 oder eine benannte Passage
      nennt (Kommando: `grep -rnE 'spezifikation\.md' internal test cmd harness/tools docs/plan/adr`),
      je mit der angesprochenen Einheit; eine Stelle ohne zuordenbare Einheit steht als eigene
      Zeile.
- [ ] **Liefer-Punkt 3 — LH-Vorschlag.** Je Einheit der Klasse (a) und je Zeile von `SPEC-001` bis
      `SPEC-034` ein Kandidat `LH-*` mit Fundstelle im Lastenheft, oder die ausdrückliche Zeile
      „kein LH gefunden“ — sie ist eine **benannte Spec-Lücke**, kein stilles Weglassen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update entfällt: der Slice ändert keinen öffentlichen Vertrag.
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
| Datei unter `docs/reviews/` (Name trägt die Slice-Kennung, Form der vorhandenen Rollen-Berichte) | neu | Klassifikationstabelle, Zeiger-Inventar, LH-Vorschlag — Liefer-Punkte 1 bis 3 |
| `spec/spezifikation.md` | keine | wird gelesen; jede Änderung wäre ein Bruch der Abgrenzung in §1 |

- Einheit ist der Absatz (Leerzeile-getrennt); bei den zwei Listen über 6 KB der Listenpunkt oberster
  Ebene. Die Tabelle nennt bei jeder Zeile die Zeilennummern des Standes, gegen den gemessen wurde
  (`git rev-parse HEAD` steht im Kopf des Berichts), weil die Datei wandert.
- Grenzfälle werden markiert und nicht geglättet: ein Satz, der Festlegung und Begründung zugleich
  trägt, bekommt zwei Zeilen mit demselben Zeilenbereich.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Priorisierung (`open` → `next`). Kein Vorgänger-Slice; die
Reihe beginnt hier, weil die Klassen-ADR auf der gemessenen Menge stehen soll.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Tabelle nicht in einer
  Review-Sitzung prüfbar ist (mehr als rund 100 Zeilen) — dann Halbierung nach Zeilenbereich
  (bis Zeile 468 / ab Zeile 470), zwei Slices mit je einer Tabelle.
- `in-progress` → `open` (blockiert — Carveout?): wenn `make docs-check` den Bericht unter
  `docs/reviews/` nicht annimmt (der `structure`-Block der `.d-check.yml` ab Zeile 97 ist bei der
  Planung nicht gelesen) — dann ist der Ort die Frage an den Architect, bevor weitergearbeitet wird.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) beide Vollständigkeits-Kommandos aus Liefer-Punkt 1 liefern die
Differenz null, und der Review-Bericht trägt die Bruchprobe; (2) `make gates` grün mit Stempel, der
den Arbeitsbaum deckt. Dazu der Lerneintrag in einer der drei Formen — Kandidaten: *neuer Sensor*
(die Nennung eines Wächters in der Spec ist unbewacht, Aufnahme-Regel-Kopf von §5) oder *benannte
Spec-Lücke* (Zeilen ohne LH). Den Abschluss schreibt der Planner, nicht der ausführende Lauf
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Absatz ist die falsche Einheit.** 34 Blöcke, zwei davon über 6 KB; ein Listenpunkt kann
  seinerseits mehrere Klassen tragen. — **Ausgang:** wird bei der Closure eingetragen (eingetreten /
  entfallen / weiter offen).
- **Die Klassen-Zuordnung eines Grenzfalls ist ein Urteil über Norm-Text**, das ein
  Implementer-Kontext nicht fällen soll. — **Ausgang:** wird bei der Closure eingetragen; die Vorkehrung
  (Grenzfälle markieren und an den Architect übergeben) steht in §1.
- **Die 35 Treffer für „gemessen/Datum“ werden als Klasse (c) gelesen**, obwohl ein Teil Zusagen sind.
  — **Ausgang:** wird bei der Closure eingetragen.

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

Wird bei der Closure vom Planner gefüllt ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht von
dem Lauf, der die Tabelle geschrieben hat.

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
