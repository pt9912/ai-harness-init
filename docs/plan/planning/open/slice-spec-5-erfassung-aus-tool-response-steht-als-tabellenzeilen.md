# Slice slice-spec-5-erfassung-aus-tool-response-steht-als-tabellenzeilen: Der Block „was aus tool_response erfasst wird“ in Spec §5 steht als Tabellenzeilen, seine Begründung in der Entscheidung, sein Messprotokoll nicht mehr im Fließtext

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
`slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert`). Dieser Slice ist der **Pilot** der
Umbau-Reihe: er prüft das Rezept an dem kleinsten zusammenhängenden Block, bevor die übrigen
geschnitten werden (Baseline-Regelwerk `modul-05-planning-harness.md` §Regeln gegen typische
Fehlannahmen: wer alle Slices vor der ersten Implementation plant, plant tote Slices).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (Accepted, unveränderlich; die Policy
hinter der Positiv-Liste),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md),
die ADR aus `slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug` (**Voraussetzung, `Accepted`**),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (Gegenbeispiel), §3.7 (wer eine Kommentarzeile anfasst, zieht sie
nach), §3.4.

**Berührte Spec-Stellen:** [§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) —
der Block „Werkzeug-Achse und Positiv-Liste“ (ab Zeile 137, bis vor die Start-Konvention) und der Block
„Payload-Quelle, erfasste Menge, `SubagentStart`, Hintergrund-Fall, Nicht-erfasst, Strom“ (ab Zeile 311,
bis vor die Abweichungen); neue Zeilen ab `SPEC-035`.

**Verantwortlich:** — bis zur Priorisierung. Ausführende Rolle: Implementer-Kontext; die schärfende ADR
für die Begründungen schreibt der Architect als Übergabe-Schritt (Frage 4 der ADR-Slice).

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die Festlegungen des Blocks stehen als Tabellenzeilen mit `SPEC-<NNN>`, Wächter-Spalte und
LH-Bezug; sein Begründungstext steht in der Entscheidung, sein Messprotokoll ist nach der ADR
entfernt oder verlagert; und jede Textstelle im Repo, die eine Passage dieses Blocks beim Namen
nennt, löst weiter auf.

**Ausgangslage, gemessen** (keine Erwartungswerte):

```sh
sed -n '137,195p' spec/spezifikation.md | wc -c    # Bytes des ersten Teilblocks
sed -n '311,353p' spec/spezifikation.md | wc -c    # Bytes des zweiten Teilblocks
```

Die Zeilengrenzen sind Stand der Planung; der Klassifikations-Bericht liefert die für den Lauf
gültigen, weil die Datei wandert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die übrigen Blöcke von §5.** Vorläufiger Ausgangs-Schnitt für den Planner (nach dem Bericht des
  Klassifikations-Slice zu prüfen): Start-Konvention samt Berichtsgröße (Zeilen 197 bis 309) ·
  Abweichung 1 samt Splitting-Regel (355 bis 468) · Abweichungen 2 bis 6 (470 bis 589) · die
  „Bewacht“-Liste (591 bis 717). **Diese Blöcke schneidet der Planner bei der Closure dieses Slice**
  und legt sie per `cp` in `open/` an, mit dem Zuschnitt, den der Pilot gezeigt hat — vorher wären es
  tote Slices. Bis dahin hat der Folge-Schnitt keine Datei und ist deshalb hier eine Bedingung, keine
  Adresse.
- **Keine Verhaltensänderung an `internal/`, `test/`, `cmd/`.** Es ändern sich Kommentar-Zeiger, nie
  Code; wer eine Kommentarzeile anfasst, zieht sie nach [`AGENTS.md`](../../../../AGENTS.md) §3.7.
- **Kein Umbau der Wächter-Nennungen der übrigen Blöcke.** Die 24 Testnamen und 26 Fall-Dateien
  bleiben in Summe erhalten; dieser Slice bewegt nur die des Blocks.
- **Kein emittiertes Gegenstück** (die Spezifikations-Vorlage im Emit-Baum) — anderer Vorgang.

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

- [ ] **Liefer-Punkt 1 — die Festlegungen als Zeilen.** Jede Einheit der Klasse „Festlegung“ des Blocks
      steht als Tabellenzeile mit fortlaufender `SPEC-<NNN>` (ab `SPEC-035`, nie neu vergeben), mit
      Wächter- und LH-Spalte. **Wächter-Bilanz, Vorher/Nachher:** die Nennungen von Testnamen und
      Fall-Dateien in der Spec (Kommando: `grep -oE '`Test[A-Za-z0-9_]+`|test/mutations/[0-9]+-[a-z0-9-]+\.sh' spec/spezifikation.md | sort -u`)
      sind vor und nach dem Umbau bis auf bewusst benannte Verlagerungen dieselbe Menge (Differenz
      gegen `git show <Basis>:spec/spezifikation.md`). **Rot gesehen:** einen Namen aus einer neuen
      Zeile streichen → die Differenz ist nicht leer. Kein Sensor hält das — die Bilanz ist ein
      Kommando des Laufs, und der Lerneintrag prüft, ob daraus ein Sensor wird.
- [ ] **Liefer-Punkt 2 — Begründung und Messprotokoll.** Die Begründungen des Blocks stehen in der
      schärfenden ADR (Architect-Übergabe; der Lauf schreibt keinen ADR-Text), die Messprotokolle sind
      nach der Festlegung der ADR entfernt oder am dort bestimmten Ort. Die Spec zeigt nicht abwärts:
      **Bruchprobe an der realen Quelle**, eine ADR-Kennung nackt in eine neue Zeile → `make docs-check`
      rot (`ids`), ein Link auf eine Entscheidungs-Datei → rot (`matrix`, Klasse `spec-straten`).
- [ ] **Liefer-Punkt 3 — Zeiger-Nachzug.** Jede Stelle aus dem Zeiger-Inventar des Klassifikations-Slice,
      die eine Passage dieses Blocks nennt, zeigt auf die neue `SPEC-<NNN>` oder eine unverändert
      vorhandene Überschrift. **Rot gesehen:** ein Zeiger auf eine entfernte Formulierung → das
      Inventar-Kommando listet ihn. Dass ein **Satz seine Bedeutung behält**, hält kein Sensor; der
      Review prüft Vorher/Nachher Satz für Satz, und der Bericht sagt, welche Sätze so geprüft sind.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: §7 Historie der Spec trägt die Zeile, „Letzte Änderung“ ist gesetzt.
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
| `spec/spezifikation.md` | update | der Block aus §1 wird Tabellenzeilen; Fließtext des Blocks entfällt oder wird verlagert; §7 |
| ADR unter `docs/plan/adr/` (Architect, eigener Commit) | neu | schärft die Zeilen; trägt die Begründungen des Blocks (Frage 4 des ADR-Slice) |
| Kommentare in `internal/`, `test/mutations/` | update | nur Zeiger, aus dem Zeiger-Inventar (Liefer-Punkt 3) |

- Reihenfolge im Lauf: erst Zeiger-Inventar des Blocks lesen, dann Zeilen schreiben, dann Zeiger
  nachziehen, dann Bilanz-Kommando; die ADR-Übergabe liegt zwischen Bestandsaufnahme und Schreiben.
- Überschriften-Struktur: der `structure`-Block der `.d-check.yml` (ab Zeile 97) ist bei der Planung
  nicht gelesen; eigener Stoff wird `###` unter dem passenden Abschnitt, die oberste `##`-Ebene bleibt
  die der Vorlage.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-spec-tabellen-tragen-die-lh-bezug-spalte` liegt in `done/`
(die Zeilen tragen die Spalte, in die dieser Slice schreibt) und die Klassen-ADR ist `Accepted`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Diff in einer Review-Sitzung nicht
  prüfbar ist oder mehr als die Hälfte des Blocks in Klasse „Grenzfall“ liegt — dann Teilung nach
  den zwei Teilblöcken aus §1.
- `in-progress` → `open` (blockiert — Carveout?): wenn die schärfende ADR nicht zustande kommt
  (Frage 4: Sammel-ADR gegen Block-ADR ungeklärt) — der Umbau schreibt keine Begründung ins Leere.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) Wächter-Bilanz und Zeiger-Kommando ohne unbenannte Differenz, die
Bruchproben stehen im Report; (2) `make gates` grün mit Stempel, der den Arbeitsbaum deckt. Dazu der
Lerneintrag (Kandidaten: *neuer Sensor* Bindungs-Bilanz; *geschärfte Regel* für den Rezept-Ablauf).
**Closure-Pflicht des Planners über die DoD hinaus:** die übrigen Blöcke aus §1 werden mit dem
gelernten Zuschnitt per `cp` als Slices in `open/` angelegt (Baseline-Regelwerk
`modul-05-planning-harness.md`: Plan und Implementation alternieren); den Abschluss schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Satz ändert beim Umbau seine Bedeutung**, und kein Sensor liest den Wortlaut. — **Ausgang:** wird
  bei der Closure eingetragen (eingetreten / entfallen / weiter offen).
- **Ein Kommentar-Zeiger in einer der 30 Dateien bleibt auf der alten Passage stehen** (Zahl mit
  Kommando in `slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert` §1). — **Ausgang:** wird
  bei der Closure eingetragen.
- **Der Block ist nicht repräsentativ**, und die übrigen Blöcke (Abweichungen, „Bewacht“-Liste) verlangen
  ein anderes Rezept. — **Ausgang:** wird bei der Closure eingetragen; der Pilot ist dafür da.
- **Die Tabellenzeilen werden so lang wie `SPEC-031`**, statt den Fließtext zu ersetzen. — **Ausgang:** wird
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
