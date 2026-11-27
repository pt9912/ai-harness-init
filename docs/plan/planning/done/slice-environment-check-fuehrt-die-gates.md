# Slice slice-environment-check-fuehrt-die-gates: Tool-/Versions-Check als erster Gate-Check (`make environment-check`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — der Closure-Trigger
der Welle beobachtet mehr als ein Slice-DoD trägt (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(die Umgebungs-Zusage — dieser Check ist ihre Messmethode docker-los),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(docker-los-Pfad — der erste Gate-Check fährt nur mit Host-Werkzeugen),
[ADR-0003](../../adr/0003-go-native-binaries.md),
[ADR-0109](../../adr/0109-…-gates-laeufen-docker-los.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->
(Soll-Form Mischform, Ausführungsort Host+CI),
`slice-c4-environment-check-v7-0-0` ([docs/plan/planning/done/](../done/slice-c4-environment-check-v7-0-0.md);
die frühere Entscheidung „Weg B entfällt" wandert um — der Träger kehrt als
docker-los-Prüfgegenstand zurück, neue Begründung, kein stiller Rückschritt).

**Berührte Spec-Stellen:** `spec/spezifikation.md` — die Festlegung des Checks
(Prüfformen, Vergleich, rot/Warnung) trägt hier **eine** neue `SPEC-<NNN>`-Stelle
(Baseline-Regelwerk `grundlagen-source-precedence.md`
§Vergebenes Kürzel, je Sub-Bereich). Der Verweis zeigt **aufwärts**.

**Verantwortlich:** pt9912

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make environment-check` fährt als **erster** Check von
`make gates` (Vorlage: `.harness/baseline/<tag>/templates/harness/sensors/environment-check.template.md`)
und belegt die docker-lose Umgebungs-Zusage (Tool-/Versions-Check, Modul 14):
ein Inventar je Werkzeug (git, bash, make, GNU-Werkzeuge, go, bats,
shellcheck, actionlint, d-check-Binary, tar/curl je Bedarf), Soll als
**Mischform** (ableiten, wo eine Pin-Stelle existiert; Manifest-Wert für die
übrigen), Ausführungsort Host + CI. Der Check läuft feststellend — Pin legt
fest, Check belegt; fehlt ein Werkzeug oder weicht es vom Pin ab, endet der
Gate-Lauf an ihm, bevor ein Gate gegen fehlendes Werkzeug falsch färbt
(Umgebungs-Befund-Klasse, Baseline-Regelwerk `modul-13-quality-gates.md`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Gate-Rezepte selbst stehen** — der Check fährt **an** der
  Gates-Kante, die Rezepte hinter den Stufen baut
  [`slice-labor-gates-host-rezepte`](../open/slice-labor-gates-host-rezepte.md)
  (Schicht-Abgrenzung); hier entsteht nur die Vorbedingung.
- **Beschaffung von Binären (d-check, Träger)** — ein eigenes Slice:
  [`slice-binraire-ziehen-ohne-docker`](../in-progress/slice-binraire-ziehen-ohne-docker.md);
  der Check prüft Anwesenheit und Version, wie die Binäre herkommen, steht
  woanders.
- **Der PreToolUse-Guard wird nicht geändert** — er blockt die
  Befehlsposition und bleibt in Kraft ([ADR-0109-Platzhalter]); das
  Check-Skript läuft über `bash`, seine Werkzeug-Aufrufe leben im Skript.
  Bestand bleibt bewusst stehen.

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** das Check-Skript + Inventar-Datei + die
      `SPEC-<NNN>`-Festlegung (Prüfformen, Vergleich, rot/Warnung) — je
      Inventar-Zeile Werkzeug · Prüfform · Soll (Pin-Stelle oder Manifest-
      Wert) · Kontext · Grund; die Mischform steht an **einer** Quelle; der
      Sensor-Text `harness/sensors/environment-check.md` trägt Vertrag,
      Inventar-Ort und Grenzen (Vorlagen-Form). — erfüllt: Skript + Inventar
      (13 Zeilen) in 81fc3ddc, die `SPEC-099`-Festlegung in
      `spec/spezifikation.md` in 9297bd70.
- [x] **Liefer-Punkt 2:** der Check hängt als **erster** Check der
      Gates-Kante (`record-gates`-Liste vor `baseline-verify`) und in
      `make gates` — erfüllt: `record-gates`-Kante in 81fc3ddc, Index-Zeile in
      9297bd70; die Index-Zeile in `harness/README.md` §Sensors nennen
      den Target mit Bindung [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- [x] **Liefer-Punkt 3:** der d-check-Schaufel-Block `pinsync` (Stellen-
      Abgleich) vergleicht die Manifest-Sollwerte gegen die Pin-Stellen byte-
      genau; die Fassung steht in `.d-check.yml`. — erfüllt: pinsync-Block +
      Fälle 795–798 in 81fc3ddc; Fall-796-Anker gegen den Bestand
      nachgezogen in 44e0594b. Rot gesehen über ein
      manipuliertes Inventar-Soll (Mutations-Fälle je
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [x] `make gates` grün — über
      [`CO-007`](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md)
      bedingt (CI-Rot vorgefunden, Trigger: Abschluss von
      [`welle-ohne-docker`](../welle-ohne-docker.md)); der lokale
      Kanten-Lauf endet am Inventar an `d-check · Ist: fehlt` — by design
      (fail-closed; die Beschaffung ist
      `slice-binraire-ziehen-ohne-docker`).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8). — Report
      2e8140fb; F-1/F-2 gelöst, Abgleich-Addendum d4da2fde (kein
      HIGH/MEDIUM offen).
- [x] Doku-Update: Sensor-Index-Zeile + Sensor-Text (offentlicher Vertrag). —
      9297bd70.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. — §7.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert. — erfüllt: `evidence/`-Datei ergänzt (siehe §7);
      die `.viper.sh`-Erwähnung ist nicht-zählend benannt (§7).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen). — beide in §7 (entfallen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/environment-check.sh` | neu | der Laufzeit-Check (feststellend, fail-closed) |
| `harness/tools/environment-inventory.txt` (Name beim Implementer) | neu | das Inventar je Zeile Werkzeug · Prüfform · Soll · Kontext · Grund |
| `Makefile` | update | Ziel `make environment-check` + erste Stufe der Gates-Kante (`record-gates`-Liste) |
| `harness/sensors/environment-check.md` | neu | Sensor-Text nach der Baseline-Vorlage (Vertrag, Inventar, Grenzen, Ausgänge) |
| `.d-check.yml` | update | `pinsync`-Block (Stellen-Abgleich) |
| `spec/spezifikation.md` | update | `SPEC-<NNN>`-Festlegung (Prüfform je Werkzeug, rot/Warnung) |
| `test/environment-check.bats` | neu | Happy/Negative — fehlendes Werkzeug, Pin-Abweichung, Warn-Zweig; je Zusage rot gesehene Fälle |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-adr-gates-laeufen-host-native`](../done/slice-adr-gates-laeufen-host-native.md)
liegt in `done/` — der Soll-Weg (Mischform) steht als Architektur-Entscheidung.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa, wenn die Inventar-Form maschinen-unlesbar bleibt und
  der `pinsync`-Abgleich einen Parser braucht → re-slicen (Inventar-Form
  simpler schneiden).
- `in-progress` → `open` (blockiert — Carveout?): ein Werkzeug am Host trägt
  **kein** versionierbares Soll (`bash` am CI-Runner?) — Carveout-
  Entscheidung in der ADR nachziehen; der Slice steht bis zur Klärung.

## 5. Closure-Trigger

DoD (§2) vollständig und die zwei reale Protokoll-Läufe im Verifikations-
Bericht: (1) ein `make gates`-Lauf auf diesem Host **ohne** Docker-Daemon
endet an `environment-check` mit Umgebungs-Befund (eine Werkzeug-Zeile), wenn
eine Inventar-Abweichung manipuliert wurde, und (2) der Lauf läuft grün
durch mit dem ungefaßten Inventar. Zusätzlich: Closure-Notiz mit Lerneintrag
geschrieben.

## 6. Risiken und offene Punkte

- **`curl` steht am Host nicht** (Träger-Beschaffung braucht Netz) —
  **Ausgang (ist):** entfallen — das Inventar trägt ihn als `optional`-Eintrag; die Beschaffung
  selbst ist [`slice-binraire-ziehen-ohne-docker`](../in-progress/slice-binraire-ziehen-ohne-docker.md)
  und sein Netz-Aufruf nennt seinen Träger.
- **Der Guard blockt den Implementer beim Testen des Checks** (direkte
  `go`/`bats`-Positionen) — **Ausgang (ist):** entfallen, nicht eingetreten — der Guard bleibt in Kraft
  ([ADR-0109](docs/plan/planning/done/) <!-- d-check:ignore (Platzhalter-Kennung: ADR-0109-Form, entsteht im Architect-Slice) -->);
  der Prüf-Weg läuft über `make`-Rezepte; wo ein Test eine direkte Position
  braucht, ist das der Befund und wird an den ADR zurückgemeldet, nicht
  still umgangen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

- **Was hat funktioniert:** das Inventar trägt 13 Zeilen je Werkzeug ·
  Prüfform · Pflichtgrad · Soll (Quelle als Präfix) · Kontext · Grund, das
  Soll als **Mischform an einer Quelle** (`SPEC-099`; abgeleitet nur für
  `go` gegen die `GO_VERSION`-Pin-Stelle, Manifest-Wert für die übrigen,
  Probe für *Fähigkeit*) — die Form blieb maschinen-lesbar ohne Parser
  (§4-Rückführung „Inventar maschinen-unlesbar" nicht angetroffen). Die
  Gates-Kante ist zweifach verdrahtet: `record-gates`-Liste an erster Stelle
  (81fc3ddc), Index-Zeile in `harness/README.md` §Sensors mit Bindung
  LH-QA-02/LH-QA-03 (9297bd70). Die lokalen Rot-Belege liefen am realen
  Quell-Skript; die Verifier-Nachprobe nahm sie am /tmp-Tree-Archiv des
  Laufs nach. Der Guard-Blocker trat nicht ein — alle Prüf-Wegs liefen über
  `make` bzw. Skript-Aufrufe im Rahmen des Guards.
- **Was ging anders als geplant:** der Tier-2-Schlüssel-Rückenstand — der
  Schlüssel-Satzerzeuger trägt auf main noch keine `environment-check`-Zeile —
  lässt den Check stets voll fahren; das ist fail-closed by design (am
  Makefile-Kommentar der Kante deklariert) und trägt seine Nehmer-Seite im
  Kopf von `slice-gates-pruefgegenstand-stempel-v1` (§1 `Übernimmt:`,
  b4491b3d) — der Rückstand ist kein Defekt des Vorgängers, sondern die
  noch nicht geschriebene Zeile des Nehmers. Der pinsync-Stellen-Abgleich
  ist doppelt dokumentiert (Konfigurations-Kommentar und Sensor-Text); seine
  Form wurde am Bestand verifiziert, nicht halluziniert (2 Pins / 4
  Quellen). Der Pin-Bump `GO_VERSION` 1.27.3 → 1.27.4 ging als eigene
  Transaktion im Range (44e0594b), das abgeleitete Inventar-Soll im selben
  Zug nachgezogen.
- **Steering-Loop-Eintrag:** gezählt, nicht verkörpert — kein Zielort, darum
  kein `liegt in`-Feld (`grundlagen-traceability.md` §Herkunfts-Anker). Der
  Inventar-Check ist der Gegen-Typ der zitierten Beobachtung, aber ein
  Sensor-Artefakt dieses Slices (`SPEC-099`), nicht die vom Ausgang
  zugewiesene Regel; die Regel trägt die Kennung
  `slice-mess-rezept-nennt-seine-host-voraussetzungen`, und ein zweiter
  Zielort daneben wäre die Drift-Form aus zwei Definitionen desselben
  Wortes. Auslöser:
  [`BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus`](../observations/BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/observation.md).
- **Beobachtungs-Register (`../observations/`):**
  `evidence/slice-environment-check-fuehrt-die-gates.md` in
  [`BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/`](../observations/BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/observation.md)
  ergänzt — Zähler steht damit bei 4×, `state.md` unverändert (`geplant`,
  Kennung des Träger-Slices). Dazu eine **nicht-zählende Erwähnung** (kein
  Auftreten, bekommt keine Datei unter `evidence/` — README der Ablage):
  `.viper.sh` (Ablage 7cb85890, Repo-Wurzel, ohne Make-Target) ist vom
  Verifier als unreferenziertes Hilfsskript ohne Abdeckungs-Anker benannt —
  bewusster Bestand-Entscheid, Einzel-Vorkommen, keine wiederkehrende
  Versagensklasse; die Grenze trägt der Kopf des Skripts selbst. Kein
  `BEO-`-Verzeichnis dafür angelegt.
- **Folge-Slices:** keine neuen; die §1-Abgrenzungen bleiben —
  [`slice-binraire-ziehen-ohne-docker`](../in-progress/slice-binraire-ziehen-ohne-docker.md)
  (Beschaffung d-check/Träger) und
  [`slice-labor-gates-host-rezepte`](../open/slice-labor-gates-host-rezepte.md)
  (Gate-Rezepte), beide in `open/`.
- **MR-042-Anlass:** nicht gegeben — das Lastenheft ist nicht berührt; die
  Änderung wächst die Spezifikation (Rang 2) um `SPEC-099`, ohne
  Vertragsänderung.
- **Rest-Übergaben:** die docker-gebundenen Zähne — der pinsync-Verhaltens-
  Lauf, die bats-Stufe des Test-Gates und die Mutations-Verifikation der
  Fälle 795–798 — bleiben der Heilung von
  [`welle-ohne-docker`](../welle-ohne-docker.md) zugeordnet; der
  make-level `SPEC-099`-Protokoll-Lauf (voller Kanten-Lauf) hängt an der
  d-check-Binary (`slice-binraire-ziehen-ohne-docker`) und an
  [`CO-007`](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md).
- **Risiken aus §6:** beide **entfallen** — `curl`: das Inventar trägt ihn
  als `optional`-Zeile (Warnung ist kein Rot, Inventar-Kommentar); die
  Beschaffung ist `slice-binraire-ziehen-ohne-docker`, dessen Netz-Aufruf
  seinen Träger nennt. Guard: nicht eingetreten — alle Prüf-Wegs liefen
  über `make` bzw. Skript-Aufrufe; der Guard stand keinem Weg im Weg.
- **Drei Paarungen:** Anker — kein `liegt in`-Feld, nichts zu paaren ·
  Folge-Slice — keiner neu genannt (die zwei `open/`-Slices sind
  §1-Abgrenzung, keine Übernahme) · Register — die berührten
  `BEO-`-Verzeichnisse tragen Belege (`BEO-ALL/mess-rezept-…` 4×,
  `BEO-ALL/host-werkzeug-variante-…` unverändert) und das Kommando der
  README (Verzeichnisse ohne `evidence/*.md`) wurde nicht von diesem Lauf
  belastet. Ergebnis: keine Befunde; das Paarungs-Kästchen (§2) bleibt für
  die Welle-Closure [`welle-ohne-docker`](../welle-ohne-docker.md) offen —
  sie prüft die Paarungen erneut.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** und die **vier Pflichtkriterien**.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `harness/tools/`
(Kürzel `TOOLS`) und `*` (gesamtes Repo, Kürzel `ALL`); beide stehen in der
Modus-Deklaration, beide erfüllen die Schwelle ≥ 2 von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer für die berührten Aussagen:

- [`BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus`](../observations/BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/state.md)
  — 1 Vorgang (< 3×): ein Rezept setzt unbenannte Host-Konfiguration voraus —
  der Inventar-Check ist genau der Gegen-Typ (Voraussetzungen benannt je
  Werkzeug). Bei Closure `evidence/`-Datei ergänzen.
- [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — 7 Vorgänge, Ausgang *verkörpert*; der Check wird die Versionen feststellen
  und BSD-Varianten sichtbar machen, trägt die macOS-Behebung aber nicht
  (Grenze im ADR). Kein 3×-Übertritt mit diesem Slice.

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
