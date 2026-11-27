# Slice slice-waechter-umgebungs-robustheit: die Wächter-Suite misst unabhängig von der Werkzeug-Umgebung des Laufes

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — der Lernstand
kommt aus der Host-Umstellung der Gates-Kante in genau dieser Welle
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Wächter-Urteil, das an der Host-Umgebung hängt, statt am Prüfgegenstand),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(docker-los-Pflicht-Weg der Gates),
[ADR-0109](../../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)
(zwei Wege, ein Exit-Vertrag beide Wege),
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
(die Fall-Anlage misst ihre Muster gegen den Quell-Bestand — auch die
Wächter-Rahmenform, nicht nur der Anker).

**Berührte Spec-Stellen:** `spec/spezifikation.md` §9 (Sensors und
Abdeckung) — der Verweis zeigt **aufwärts**.

**Verantwortlich:** —

**Autor:** pt9912 (Rolle Planner, Closure-Lauf slice-labor-gates-host-rezepte). **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** die Wächter-Laufformen des `make test`-Weges tragen ihre Umgebung
je Setup selbst — PATH/Werkzeug-Shims, `BATS_ROOT`/`BATS_LIBDIR`,
Sortier- und Zeichen-Semantik (`LC_ALL`) —, sodass dieselbe Wächter-Datei
im Einzellauf und im vollen Sweep dieselbe Rot-Menge liefert. Getragen
steht der Stand im
[`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/state.md).

**Übernimmt:** `slice-labor-gates-host-rezepte` — dessen Closure die drei
Befund-Klassen am Register hinterlegt und den Gegenstand hierher verweist:
die Reihenfolge-Flakiness der Ziel-Modus-Fälle von `test/traeger-fetch.bats`,
die Sortier-Divergenz (`sort`/`comm`) im Fall 6 von
`test/targets-modul-wiring.bats`, die Werkzeug-Grenze der Rezept-Wächter am
gepinnten bats-Image (Review-Befund F-2 des Reports 2026-11-27) und ihre
Prosa-Grenze am Sensor-Text (F-3).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Emittier-Rezepte des Ziels** — sind
  [`slice-emittierte-gates-host-pfad`](../next/slice-emittierte-gates-host-pfad.md)
  (Schicht-Abgrenzung); hier stehen nur die Dogfood-Wächter.
- **Der Fall `810` der Mutations-Anlage** — seine Fassung liegt im
  Implementer-Commit-Set des Vorgänger-Slices; der neue Fall ist nur
  Bestands-Beispiel der Klasse, nicht sein Träger (anderer Vorgang).
- **Kein Gate wird gelockert** — die Wächter behalten ihre Invarianten; es
  wechselt nur die Laufform der Umgebung (Schicht-Abgrenzung: Werkzeuge ja,
  Gate-Verträge nein).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1:** die Wächter-Setups restaurieren je Setup die
      Umgebung, die sie brauchen (PATH/Shims, `BATS_ROOT`/`BATS_LIBDIR`,
      `LC_ALL` am sort/comm- und awk-Benutzungsort), messbar an
      `test/traeger-fetch.bats` (Ziel-Modus-Fälle) und
      `test/targets-modul-wiring.bats` (Fall 6).
- [ ] **Liefer-Punkt 2:** dieselben Wächter-Dateien liefern einzeln und im
      vollen `test/`-Sweep dieselbe Rot-Menge (gemessen je Wächter-Datei
      mindestens einmal beider Formen, dokumentiert im Verifikations-Bericht).
- [ ] **Liefer-Punkt 3:** die Rezept-Wächter tragen an beiden Wegen
      (`make test-bats` und opt-in `make test-bats-image`) denselben
      Exit-Vertrag — oder die Grenze steht in der Sensors-Zelle
      (`harness/sensors/`) und die Prosa des `docs-check`-Sensor-Texts nennt
      den gefetchten Carrier-Weg (Review-Befund F-3).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist
      (`harness/README.md` §Sensors).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      weiteres Vorkommen in `evidence/`; **kein Zaehler wird gesetzt**, er
      folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine
      Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **mit** Wellen-Betrieb von der nächsten Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/bats-lint.sh` | update | Setup-Restauration am Host-Weg (Muster F-1 des Reports 2026-11-27: der Läufer löst den Pfad, übergibt aber nicht dessen Umgebung) |
| `test/traeger-fetch.bats`, `test/targets-modul-wiring.bats` | update | Wächter-Setups je Fall auf feste Umgebungs-Zusagen (Path/Locale, `set -u`-harte Subumgebungen je Setup) |
| `test/rezept-host.bats`, `test/dockerfile-teststufe.bats` | update | Grenzmarkierung der Werkzeug-Abhängigkeiten (`make`, `git`) gegen den opt-in Image-Weg |
| `harness/sensors/docs-check.md` | update | Prosa trägt den gefetchten Carrier-Weg (F-3) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md)
liegt in `done/` und seine uncommitted WIP-Dateien (Doku-Update, Mutations-Fall
810, Sensor-Text) trug ein Implementer-Commit — die Register-Belegage ist
committet anliegend.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Reihenfolge-
  Robustheit verlangt mehr als drei berührte Wächter-Dateien — dann zerlegen
  je Wächter-Klasse (Transport/Setups vor Sortier-Semantik).
- `in-progress` → `open` (blockiert — Carveout?): die Ursache liegt im
  bats-Läufer selbst (Version am Host), nicht im Setup — dann Carveout-Klärung
  an der ADR-0109-Fassung.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD (§2) vollständig; der Verifikations-Bericht trägt den beiderseitigen
Lauf (Einzelform und vollem Sweep) je Wächter-Datei derselben Rot-Menge.
Closure-Notiz mit Lerneintrag (der Lerneintrag der Klasse
„Weg-agnostik der Wächter endet an den Werkzeugen“ gehört dann dem
Herkunfts-Anker `seit slice-waechter-umgebungs-robustheit`).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Ursache liegt nicht im Setup, sondern im Läufer-Werkzeug selbst**
  (bats-Version am Host; Varianten der Host-Werkzeuge — der Bestand
  [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  steht mit 7 Vorgängen im Register) — **Ausgang:** bei Closure messen; liegt
  sie am Läufer, geht der Slice zurück in `open/` und der Carveout-Zweig
  kommt an die ADR-Fassung.
- **Die Restaurierung am Wächter-Setup dreht am Symptom, am Host-Profile
  vorbei** (der Sweep-Defekt könnte an der Reihenfolge des `bats`-Dateilaufs
  selbst hängen, nicht an Exporten früherer Setups) — **Ausgang:** bei
  Closure messen (Fall-Diagnostik je früherem Setup isolieren); trägt die
  Reihenfolge des Läufers, steht der Grenz-Fund im Verifikations-Bericht
  und in der Sensors-Zelle.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- *(wird bei dessen Closure gefüllt)*

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.**

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `test/` (Kürzel `TEST`,
Wächter-Baum) und `harness/sensors/` (Kürzel `SENS`, Sensor-Prosa); beide
erfüllen die Schwelle ≥ 2 von 3 Achsen (Eigen-Konvention, eigene Phase, eigenes
Abweichungs-Risiko).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:
- [`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/state.md)
  (dieser Slice ist der Ausgang im Register): 1 Vorgang, unter der Schwelle —
  der Slice ist sein Ausgang, kein 3×-Übertritt.
- [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — 7 Vorgänge, Ausgang verkörpert; der Host-Ist-Zustand trägt sein Linux-Ein-
  Stand in ADR-0109-Fassung — kein 3×-Übertritt.
- [`BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last`](../observations/BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last/state.md)
  — 2 Vorgänge (< 3×), Umgebungs-Vorlauf-Familie, hier nicht zu bearbeiten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
