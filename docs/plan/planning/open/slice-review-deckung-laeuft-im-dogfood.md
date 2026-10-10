# Slice slice-review-deckung-laeuft-im-dogfood: Das Doku-Gate dieses Repos fährt `reviews`, und ein neuer Plan mit Review-Zusage ohne Report färbt es rot

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung beobachtet mehr als die DoD dieses Slice;
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate läuft über einer nicht leeren Menge),
[`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 3 Option (ii),
vom Auftraggeber am 2026-10-10 gewählt,
[`MR-054`](../../../../harness/conventions.md#mr-054) (Kriterium 1),
[`MR-086`](../../../../harness/conventions.md#mr-086) (die Emission bleibt aus),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (die Ausnahme nennt ihren ganzen Gegenstand).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die [`.d-check.yml`](../../../../.d-check.yml) führt `reviews` in `modules:` mit den
Schlüsseln der Vorlage `v6.18.0` (`match: name`, `require-promises`, `recursive`, `skip-pattern`,
`skip-allows-empty`). Der Bestand, den die Sonde am Start-HEAD als `review-missing` meldet, steht
als geschlossene `exempt-paths`-Liste darin (Cutoff). Ab dann hält ein Sensor, dass ein Plan, der
nach `done/` geht und eine Review-Zusage trägt, einen Report mit seiner vollen Kennung im Dateinamen
hat.

**Ausgangslage**, gemessen vom Architect an HEAD `5faf3823` mit der Vorlagen-Konfiguration: 70
Befunde, alle `review-missing`, überwiegend Reports mit gekürzter Kennung
([`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 3; Kommando
dort). Die Zahl ist kein Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 2). Die Liste wird am Start-HEAD neu
gemessen, denn bis dahin geht mindestens der Sprung-Slice nach `done/`.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Reports umbenennen oder fehlende nachziehen.** *Bestand bleibt stehen:* `docs/reviews/**` sind
  Zeitdokumente ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Ob ein gelisteter Plan einen gekürzt
  benannten Report hat oder gar keinen, klassifiziert die Liste nicht. Die Begründung sagt das.
- **Die Ablage-Form neuer Reports in Reviewer-Skill und Rollen-Anweisungen.** *Folge-Slice
  übernimmt es:* `slice-sprung-auf-v6180-wird-vollzogen`, Liefer-Punkt 2. Wer die Anweisungen
  schreibt, bestimmt [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md).
  Dieser Slice setzt den Sensor, nicht den Text.
- **`reviews` im emittierten Gate.** *Anderer Vorgang:* Am Pin `v0.86.1` startet ein frisches Ziel
  rot. [`MR-054`](../../../../harness/conventions.md#mr-054) Kriterium 2 und
  [`MR-086`](../../../../harness/conventions.md#mr-086) schließen die Emission aus
  ([`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 2).
- **Norm-Text zu [`MR-054`](../../../../harness/conventions.md#mr-054)/[`MR-086`](../../../../harness/conventions.md#mr-086)
  und eine etwaige ADR zur Ausnahmeliste.** *Anderer Vorgang:* Architect-Artefakte, eigener Commit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); Übergabe A1/A2 in §3.
- **Kein Produkt-Code.** *Schicht:* Gate-Konfiguration, Sensor-Doku, ein Mutations-Fall.

## 2. Definition of Done

- [ ] **1 — `reviews` läuft im Dogfood.** `.d-check.yml` führt `reviews` in `modules:` mit den fünf
      Schlüsseln der Vorlage. Die `exempt-paths`-Liste nennt Dateinamen, kein Muster, und ist auf
      die Befunde der Sonde am Start-HEAD geschlossen. Ihr Kommentar nennt den ganzen Gegenstand:
      jeden Baum, den sie trifft, gemessen am Ist-Bestand ([`AGENTS.md`](../../../../AGENTS.md)
      §3.5). Dazu den Cutoff und die Form des Urteils über weitere Einträge, nach dem Verdikt A1.
      `make docs-check` ist grün, die Vollständigkeits-Zeile ist gelesen, und die Kandidatenmenge
      ist nicht leer.
- [ ] **2 — Rot-Belege an der realen Konfiguration.** (a) Ein Plan in `done/` mit Review-Zusage
      und ohne Report mit seiner Kennung färbt `make docs-check` rot, mit `review-missing` an genau
      diesem Plan (Meldung gelesen). (b) Ein Fall in `test/mutations/` streicht einen Eintrag der
      Liste, und `make docs-check` wird rot. Damit ist belegt, dass jeder Eintrag trägt und die
      Liste nicht über den Bestand hinausreicht. Die Gegenprobe nach
      [`MR-071`](../../../../harness/conventions.md#mr-071) misst das `sed`-Muster am
      Quell-Bestand.
- [ ] **3 — Die Doku nennt Vertrag und Grenze.** Die Zeile `make docs-check` in
      [`harness/README.md`](../../../../harness/README.md) §Sensors nennt das Modul.
      [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) bekommt einen
      Abschnitt zu `reviews` mit Zusage, Cutoff und Grenze. Die Grenze: `match: name` hält einen
      Dateinamen, nicht, dass er ein Review ist. Ein Präfix-Paar unter `done/` deckt still. Die
      Berechtigung eines Listeneintrags bleibt Urteil.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` (`modules:`, Block `reviews:` samt `exempt-paths` und Kommentar) | update | 1 |
| `test/mutations/<NNN>-reviews-ausnahmeliste-eintrag-gestrichen.sh` | neu | 2(b); Wächter `make docs-check` |
| `harness/README.md` §Sensors, `harness/sensors/docs-check.md` | update | 3 |

- Die Sonde am Start-HEAD mit den Schlüsseln der Vorlage fahren, im Wegwerf-Klon. Erst die Liste
  aus ihren Befunden schreiben, dann die Konfiguration im Repo umstellen. Meldet die Sonde einen
  Befund, der nicht `review-missing` ist, ist das kein Listeneintrag (Rückführung unten).
- Rot-Beleg 2(a) im Wegwerf-Klon mit einem neuen Plan unter `done/`. Er wird nicht committet.
- `make test` deckt `internal/ausnahmegrund/`: Der Kommentar der neuen `exempt-paths`-Liste muss
  den Baum `docs/plan/planning/done/` nennen.

**Übergaben (vor dem Start zu beantworten):**

- **A1 — an den Architect:** Ist die Ausnahmeliste bei der Aktivierung eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5, mit ADR-Pflicht, ein Carveout (Trigger, Folge-Slice)
  oder keines von beiden, weil ein Modul zugeschaltet wird und die Schwelle nur steigt? Vorbild im
  Bestand ist die geschlossene Liste unter `structure:` in `.d-check.yml`: *„Ein weiterer Eintrag
  ist eine Senkung nach AGENTS.md 3.5"*. Das Verdikt bestimmt den Kommentar-Text aus
  Liefer-Punkt 1.
- **A2 — an den Architect:** Bekommen [`MR-054`](../../../../harness/conventions.md#mr-054)
  (Kriterium 1 für `reviews` erfüllt) und [`MR-086`](../../../../harness/conventions.md#mr-086)
  eine Notiz oder Kopf-Marke? Oder trägt das der Re-Evaluierungs-Trigger *„Der Dogfood fährt
  `reviews`"* von [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) allein?
  Das Verdikt ist ein Architect-Commit und kein Liefer-Punkt dieses Slice.

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-sprung-auf-v6180-wird-vollzogen` liegt in `done/`, und
das Verdikt A1 liegt vor.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Das Verdikt A1 verlangt eine
  Klassifikation der gelisteten Pläne in *gekürzt benannt* und *ohne Report* mit je eigenem
  Ausgang. Das ist ein zweiter Liefer-Punkt über den Bestand und sprengt eine Review-Sitzung.
- `in-progress` → `open` (blockiert — Carveout?): `reviews` nimmt am Pin kein `exempt-paths`, oder
  die Sonde meldet Befunde, die nicht `review-missing` sind. Die Liste trüge dann eine andere
  Klasse, und die Grundlage aus
  [`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 3 ist neu zu
  messen.

## 5. Closure-Trigger

Die drei Liefer-Punkte sind abgehakt, und `make gates` ist grün. Die Rot-Belege 2(a) und 2(b) sind
mit gelesener Meldung im Report oder in der Verifikation zitiert. Die Closure-Notiz trägt den
Lerneintrag.

## 6. Risiken und offene Punkte

- **Der Slice fällt an sich selbst.** Seine DoD trägt eine Review-Zusage. Ab Liefer-Punkt 1 hält
  `reviews` auch diesen Plan beim `git mv` nach `done/`. Trägt sein Report die Kennung nicht voll
  im Dateinamen, ist der Move-Stand rot. — **Ausgang:** <bei Closure>
- **Die Liste wächst still.** Ein Lauf, der später einen Plan in die Liste nimmt, statt den Report
  korrekt abzulegen, senkt den Sensor. Nur die Form ist prüfbar, die Berechtigung bleibt Urteil
  (`BEO-ALL/ausnahmeliste-nur-auf-form-geprueft`). — **Ausgang:** <bei Closure>
- **Ein Plan ohne Zusage läuft aus der Prüfmenge.** `require-promises` meldet den Leerlauf unter
  vorhandenen Slices. Ein einzelner Plan, dessen DoD die Review-Zeile nicht trägt, fällt still aus
  der Menge. — **Ausgang:** <bei Closure>
- **Die Liste ist zu groß für den Start-HEAD.** Zwischen der Messung und dem Start gehen weitere
  Slices nach `done/`, und die Sonde misst eine andere Menge als die 70. — **Ausgang:** <bei
  Closure>
- **Die Report-Form im Sprung ist nicht bindend.** Der Sprung-Slice zieht die Ablage-Form nach,
  aber ein Report, der zwischen Sprung und Aktivierung entsteht, kann gekürzt heißen und fällt
  dann in die Liste. — **Ausgang:** <bei Closure>

## 7. Closure-Notiz

- **Was hat funktioniert:** <bei Closure>
- **Was ging anders als geplant:** <bei Closure>
- **Steering-Loop-Eintrag:** <bei Closure — Kandidat: neuer Sensor `reviews` hält die volle
  Kennung im Report-Namen>
- **Beobachtungs-Register (`../observations/`):** <bei Closure>
- **Folge-Slices:** <bei Closure>
- **Risiken aus §6:** <bei Closure>
- **Drei Paarungen:** <bei Closure>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (`ALL`), die einzige Sub-Area,
der die Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md)
Gate-Konfiguration und Sensor-Doku zuordnet. Eine feinere Sub-Area führt die Deklaration nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register `../observations/BEO-ALL/` gelesen, Stand
`ac784390`.

- `emittierter-stand-laeuft-dem-dogfood-voraus`: 2 Belege, `offen`. Kein Beleg dieses Slice: Hier
  liefe der Dogfood dem Ziel voraus, die Gegenrichtung
  ([`ADR-0091`](../../adr/0091-ziel-fassung-regiert-den-sprung-v6180.md) Festlegung 4). Ob die
  Gegenrichtung eine eigene Beobachtung ist, entscheidet die Closure. Ein Gleichheits-Sensor
  bleibt ausgeschlossen (`state.md` dort).
- `ausnahmeliste-nur-auf-form-geprueft`: 4 Belege, verkörpert in
  [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md). Die neue
  Liste ist genau diese Klasse: Risiko 2 in §6.
- `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`: 1 Beleg, `offen`. Dieser Slice ist
  Auftrag des Auftraggebers, Auslöser (1). Er legt keinen Folge-Slice an.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
