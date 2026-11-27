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

**Verantwortlich:** pt9912

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
  [`slice-emittierte-gates-host-pfad`](../done/slice-emittierte-gates-host-pfad.md)
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

[x] **Liefer-Punkt 1:** die Wächter-Setups restaurieren je Setup die
      Umgebung, die sie brauchen (PATH/Shims, `BATS_ROOT`/`BATS_LIBDIR`,
      `LC_ALL` am sort/comm- und awk-Benutzungsort), messbar an
      `test/traeger-fetch.bats` (Ziel-Modus-Fälle) und
      `test/targets-modul-wiring.bats` (Fall 6).
[x] **Liefer-Punkt 2:** dieselben Wächter-Dateien liefern einzeln und im
      vollen `test/`-Sweep dieselbe Rot-Menge (gemessen je Wächter-Datei
      mindestens einmal beider Formen, dokumentiert im Verifikations-Bericht).
[x] **Liefer-Punkt 3:** die Rezept-Wächter tragen an beiden Wegen
      (`make test-bats` und opt-in `make test-bats-image`) denselben
      Exit-Vertrag — oder die Grenze steht in der Sensors-Zelle
      (`harness/sensors/`) und die Prosa des `docs-check`-Sensor-Texts nennt
      den gefetchten Carrier-Weg (Review-Befund F-3).
- [ ] `make gates` grün.
[x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
[x] Doku-Update, falls ein öffentlicher Vertrag berührt ist
      (`harness/README.md` §Sensors).
[x] Closure-Notiz mit Steering-Loop-Lerneintrag.
[x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      weiteres Vorkommen in `evidence/`; **kein Zaehler wird gesetzt**, er
      folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine
      Antwort und wird in §7 notiert.
[x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
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

**Ist-Stand gegen die Tabelle (Implementer, 2026-11-27):** die Zeilen
`test/rezept-host.bats`/`test/dockerfile-teststufe.bats` (Rezept-Grep-Form, Weg-Agnostik
der Rezept-Wächter, Review-Befund F-2 des Vorgänger-Reviews) trägt der Vorgänger-Commit
`be63da5d`; `harness/sensors/docs-check.md` (Carrier-Prosa, F-3) und die
`BATS_ROOT`/`BATS_LIBDIR`-Restauration am Host-Weg in `harness/tools/bats-lint.sh` (F-1)
trägt `9c788a9c` (`git log -S BATS_ROOT -- harness/tools/bats-lint.sh`,
`git blame harness/sensors/docs-check.md`) — der Bestand erfüllt diese drei Zeilen vor
diesem Lauf. Dieser Lauf berührt `test/traeger-fetch.bats` und `test/targets-modul-wiring.bats`
(Liefer-Punkt 1) und ergänzt die Grenz-Zeile im Kopf von `test/dockerfile-teststufe.bats`
(die Grenz-Form des Kopfes von `test/rezept-host.bats` steht schon). **Zweite Instanz derselben
Klasse, gemessen im vollen Sweep** (`make test-bats BATS_TARGET=test/`, 6 rot):
[`test/traeger-fetch-host.bats`](../../../../test/traeger-fetch-host.bats) trägt dieselbe
geerbte-Pin-Klasse an den Manifest-Modus-Fällen ({603, 605, 606, 607, 608} mit voller/teiler
ambienten Pin-Menge) — derselbe Ausmerz wie im traeger-fetch-Setup, die Datei steht darum
unten nicht in §3; die Rückführungs-Schwelle („mehr als drei berührte Wächter-Dateien") ist
damit nicht gerissen: über den Plan hinaus berührt dieser Lauf genau eine Wächter-Datei.
**Ein dritter roter Fall im Sweep ist kein Gegenstand dieses Slices** (vom Claim-Commit an
rot, im Worktree an `e3c4cfd2` nachgemessen): Fall 273 des Wächters
`test/ignore-refs-restbreite.bats` (`done/** → .harness/baseline/**`:
11 auflösende Links, deklariert 10) — die Deckungs-Deklaration ist beim Move des
[done](../../../../docs/plan/planning/done/slice-adr-gates-laeufen-host-native.md)-Plans
(`8e249284`) nicht nachgezogen; der Nachzug läuft über den Präzedenz-Commit `9321ffcc`
(Rolle Planner, „Deckungs-Deklaration nach dem Move nachgezogen", keine Verbreiterung des
Eintrags, keine ADR-Pflicht).

**Mess-Protokoll (Implementer, 2026-11-27):** die Rot-Menge von
[`test/traeger-fetch.bats`](../../../../test/traeger-fetch.bats) ist vor dem Fix eine
Funktion der ambienten [``TRAEGER_*``](../../../../Makefile)-Teilmenge — der
`make test-bats`-Rezept-Weg exportiert Tag und die sechs Digest-Pins ins
bats-Environment: voller Pin-Satz 3× → {3, 5, 7, 9} rot; die Teilmenge nur
`TRAEGER_SHA256_DARWIN_AMD64` → {3, 5, 9} rot; ohne ambient → 10/10 grün.
[„Fall 6"](../../../../test/targets-modul-wiring.bats) bricht unter
`LANG=en_US.UTF-8` an `comm -23` (`file 1 is not in sorted order`), grün unter
`LC_ALL=C`. Nach dem Fix: `make test-bats BATS_TARGET=test/traeger-fetch.bats` 3× →
0 rot, Fall 6 grün unter beiden Locale-Varianten.

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
  steht mit 7 Vorgängen im Register) — **Ausgang:** entfallen — die Bruchprobe
  an der realen Route isoliert die geerbten Pin-Mengen als Auslöser, nicht den
  Läufer: Setups ihres `unset`-Entkleids über das Rezept mit vollem
  `Makefile:61`-Export liefern die Plan-§3-Rot-Mengen ({3, 5, 7, 9} ·
  {603, 605, 606, 607, 608}), die restaurierten Setups liefern 0 rot
  (Verifikations-Bericht L-7); kein Carveout.
- **Die Restaurierung am Wächter-Setup dreht am Symptom, am Host-Profile
  vorbei** (der Sweep-Defekt könnte an der Reihenfolge des `bats`-Dateilaufs
  selbst hängen, nicht an Exporten früherer Setups) — **Ausgang:** entfallen —
  der volle Sweep liefert an dem Stand mit restaurierten Setups exakt die
  Vorlauf-Rot (Fall 273, Vorbestand) und keinen Fall aus dem Diff, und die
  Einzelläufe je Wächter liefern dieselbe Rot-Menge wie der Sweep
  (Verifikations-Bericht L-1 … L-6); die Grenze (docker trägt den Image-Weg
  nicht) steht im Verifikations-Bericht.

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

**Closure-Notiz (Rolle Planner, 2026-11-27)** — Quellen: eigener Lauf, die
offenen Punkte des Implementer-/Verifier-Berichts
([`docs/reviews/2026-11-27-slice-waechter-umgebungs-robustheit-verify.md`](../../reviews/2026-11-27-slice-waechter-umgebungs-robustheit-verify.md))
und die Review-Klassen des Reports
([`docs/reviews/2026-11-27-slice-waechter-umgebungs-robustheit.md`](../../reviews/2026-11-27-slice-waechter-umgebungs-robustheit.md)).

- **Was hat funktioniert:** der Setup-Ausmerz trägt — nach dem Fix liefern
  Einzellauf und voller Sweep dieselbe Rot-Menge je Wächter (Verifikations-
  Bericht L-1 … L-6; LP 1 und 2), und die Bruchproben an der realen Route
  bestätigen die geerbten Pin-Mengen als Auslöser (L-7), so dass beide
  §6-Risiken ohne Carveout entfallen.
- **Was ging anders als geplant:** (1) der DoD-Posten `make gates` grün ist
  an dieser Closure **offen** — rot an fünf **vorbestehenden** Klassen, keine
  aus dem Slice-Diff (am Claim-Commit `e3c4cfd2` bestandsidentisch belegt,
  Verifikations-Bericht L-8 … L-11): docs-check 102 Befunde (Planungs-Baum/
  Index-Nachzug), bats Fall 273 ignore-refs 11/10 (Präzedenz-Nachzug über die
  `9321ffcc`-Route), shell-lint SC2254 in `harness/tools/gates-keys.sh` ×4 +
  SC2016 in `test/mutations/785`, Mutations-Anker 784/785 veraltet, `make
  test-go` zwei Klassen (Stop-Hook-KommitBindung in `internal/emit`;
  `TestGoProfile_PinsMatchRepo` GO_VERSION 1.27.3 generiert vs 1.27.4 im
  Repo-Dockerfile). Die Nachzüge tragen die laufenden Slices der Welle
  ([`slice-emittierte-gates-host-pfad`](../done/slice-emittierte-gates-host-pfad.md)
  und die in-progress-Slices `slice-gates-pruefgegenstand-stempel-v1`,
  `slice-stamp-records-konsum-v1`); kein Carveout-Artefakt — die roten Fälle
  bleiben rot sichtbar. (2) LP 3 ist in der gelesenen Form bestätigt, mit
  Grenze: docker trägt auf dem Host nicht, das Image-Weg-Urteil über den
  Exit-Vertrag reist nach CI; bis dahin tragen die Grenz-Zeile im Kopf des
  Wächters und die docs-check-Prosa. (3) LP 1 über den Plan hinaus: auch
  `test/traeger-fetch-host.bats` trug die geerbte-Pin-Klasse — als zweite
  Instanz in §3 nachgezogen. (4) Fall 273 bleibt Planner-Posten (Deckungs-
  Deklaration nach dem Move nachziehen, keine Verbreiterung des Eintrags).
- **Steering-Loop-Eintrag:** geschärfte Regel (gezählt, nicht verkörpert —
  kein `liegt in`, mit diesem Slice wurde nichts an einen Zielort
  verkörpert): **die Weg-Agnostik der Wächter endet an den Werkzeugen und der
  Umgebung des Ausführungsorts** — der Wächter-Setup trägt seine eigene
  Umgebung (Export-Erbe `TRAEGER_*`, Locale an `sort`/`comm`), statt sie aus
  früheren Setups des Sweeps oder dem Host-Profil zu erben. Grenze der
  Klasse (Review F-1 des Reports 2026-11-27, ungebundener Teil): die
  Kollations-Festlegung bindet ihre Zahnstange an den vier `sort`-Stellen;
  der `comm`-Teil der Zusage trägt keinen eigenen Mutations-Fall — ein
  späterer Weg der `comm`-Präfixe verfälscht die Zusage nicht, öffnet aber
  die spurious-rote Seite einer Host-Kollation. Die Kommentar-Ergänzung dieser
  Grenze geht als Übergabe-Artefakt an den nächsten Planner-Posten der Welle;
  sie ist hier gelesen, nicht in den Bestand geschrieben.
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/state.md)
  — Ausgang dieses Slices, Beleg
  [`evidence/slice-waechter-umgebungs-robustheit.md`](../observations/BEO-ALL/waechter-rot-menge-schwankt-mit-umgebungs-variante/evidence/slice-waechter-umgebungs-robustheit.md).
  Kein weiteres Vorkommen angefallen; der Zähler steht damit bei 2×, unter
  der Schwelle.
- **Drei Paarungen:** Anker — der Lerneintrag oben ist gezählt, es gibt
  keinen `liegt in` · Folge-Slices —
  [`slice-emittierte-gates-host-pfad`](../done/slice-emittierte-gates-host-pfad.md)
  (Emittier-Rezepte, in §1 ausgeschlossene Schicht) und der offene
  Fall-273-Präzedenz-Nachzug (Posten der Welle, kein eigener Slice) ·
  Register — der Eintrag oben (Zähler 2×, unter der Schwelle). Die Prüfung
  der Paarungen trägt die schließende Welle.

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
