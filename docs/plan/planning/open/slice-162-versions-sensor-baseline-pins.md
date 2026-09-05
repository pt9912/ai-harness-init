# Slice slice-162: Der `versions`-Sensor hält die Baseline-Pins gegen den adoptierten Stand

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — ein Sensor-Neubau, den
[welle-14](../done/welle-14-re-baseline.md) §6 ausdrücklich ausschließt; die Linie trägt
[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md). Der Slice ist der **Ausgang** einer
Katalog-Position aus [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 und
kein Mitglied der Re-Baseline-Welle.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Modul über leerem Prüfbereich ist ein behaupteter Gate),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(die emittierte Starter-Config),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop),
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ein vergessener Nachzug eines Baseline-Pins ist ein Befund, kein toter Link.**

Jeder Verweis in die vendorte Baseline trägt deren Version im Pfad
(`.harness/baseline/<tag>/…`), und die bewegt sich bei jedem Bump. Die Ziel-Fassung nennt dafür
zwei Dinge: die Regel (`grundlagen-traceability.md` §Herkunfts-Anker, *Zwei Rot-Quellen, ein
Prinzip* — nicht die Form wechseln, damit nichts mehr rotten kann, sondern das Rotten sichtbar
machen) und das Werkzeug (das `versions`-Modul im Startgerüst `.d-check.yml`: `pin-pattern`,
`current-from` auf **eine** Deklaration, `version-stale` als Befund).

Der Slice liefert den Sensor im Dogfood **und** die Frage, ob die emittierte Starter-Config den
Block mitbekommt — sie führt heute weder `versions` noch `vcs`
(`grep -c 'versions\|vcs' internal/emit/templates/d-check.yml`; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **`versions` ist aktiviert und hat Zähne:** der Block steht in
      [`.d-check.yml`](../../../../.d-check.yml), und ein absichtlich falscher Pin ist **rot
      gesehen** worden ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Nicht aktiviert, solange der
      gepinnte d-check-Stand das Modul nicht führt — das wäre ein behaupteter Gate.
- [ ] **Der Bezugspunkt ist genau einer:** `current-from` zeigt auf die eine Deklaration des
      adoptierten Standes, und die eingefrorenen Artefakte
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4) sind über `exempt-paths` benannt statt still
      übergangen.
- [ ] **Die emittierte Ebene ist entschieden:** ob die Starter-Config den `versions`-Kommentarblock
      trägt — mit Begründung, nicht als Nebeneffekt.
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt.
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
| [`.d-check.yml`](../../../../.d-check.yml) | update | der `versions`-Block |
| `internal/emit/templates/d-check.yml` | update | die emittierte Starter-Config |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update | nur, falls ein neuer Gate-Name entsteht |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): zwei Bedingungen zugleich —
[slice-161](../done/slice-161-conventions-kopf-traegt-die-ziel-form.md) liegt in `done/` (der Bezugspunkt,
den `current-from` liest, existiert), **und** der gepinnte d-check-Stand führt das Modul
`versions`, gemessen über `--print-config` statt angenommen
([slice-135](slice-135-d-check-pin-v0661.md) trägt den Pin-Sprung).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Ausnahme-Menge der
  eingefrorenen Artefakte eine eigene Entscheidung verlangt.
- `in-progress` → `open` (blockiert — Carveout?): wenn der gepinnte Stand das Modul nicht führt.
  Es dann zu aktivieren wäre ein behaupteter Gate
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  nicht ein Zwischenschritt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; das Gegenbeispiel ist rot gesehen; Closure-Notiz mit Steering-Loop-Lerneintrag
geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Sensor läuft über einer leeren Menge und wird nie rot** — dieselbe Klasse wie ein
  behauptetes Gate; die Zähne sind vor der Aktivierung zu belegen, nicht danach. — **Ausgang:**
  offen, wird bei Closure verbucht.
- **Die eingefrorenen Artefakte werden über eine breite Ausnahme still ausgenommen** — davor
  warnt [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  mit dem Zensus-Gedanken: jede Ventil-Zeile nennt, *was* sie ausnimmt und *warum*.
  — **Ausgang:** offen, wird bei Closure verbucht.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die Doku-Gate-Config
und die Emissions-Vorlage liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).

**Vorgelagert — offene Beobachtungen sichten:** `BEO-017` (ein vorgeschriebener Ortswechsel macht
eine Adresse in einem eingefrorenen Artefakt tot) ist die Klasse, die dieser Sensor sichtbar
macht — er löst sie nicht auf, er meldet sie. `BEO-006` (die Register-Paarung hat in keinem
gepinnten Stand ein Modul) berührt dieselbe Achse *fehlende Fähigkeit des Fremd-Werkzeugs*, ist
aber ein anderer Gegenstand. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
