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

**Verantwortlich:** —

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
  [`slice-labor-gates-host-rezepte`](slice-labor-gates-host-rezepte.md)
  (Schicht-Abgrenzung); hier entsteht nur die Vorbedingung.
- **Beschaffung von Binären (d-check, Träger)** — ein eigenes Slice:
  [`slice-binraire-ziehen-ohne-docker`](slice-binraire-ziehen-ohne-docker.md);
  der Check prüft Anwesenheit und Version, wie die Binäre herkommen, steht
  woanders.
- **Der PreToolUse-Guard wird nicht geändert** — er blockt die
  Befehlsposition und bleibt in Kraft ([ADR-0109-Platzhalter]); das
  Check-Skript läuft über `bash`, seine Werkzeug-Aufrufe leben im Skript.
  Bestand bleibt bewusst stehen.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** das Check-Skript + Inventar-Datei + die
      `SPEC-<NNN>`-Festlegung (Prüfformen, Vergleich, rot/Warnung) — je
      Inventar-Zeile Werkzeug · Prüfform · Soll (Pin-Stelle oder Manifest-
      Wert) · Kontext · Grund; die Mischform steht an **einer** Quelle; der
      Sensor-Text `harness/sensors/environment-check.md` trägt Vertrag,
      Inventar-Ort und Grenzen (Vorlagen-Form).
- [ ] **Liefer-Punkt 2:** der Check hängt als **erster** Check der
      Gates-Kante (`record-gates`-Liste vor `baseline-verify`) und in
      `make gates`; die Index-Zeile in `harness/README.md` §Sensors nennen
      den Target mit Bindung [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- [ ] **Liefer-Punkt 3:** der d-check-Schaufel-Block `pinsync` (Stellen-
      Abgleich) vergleicht die Manifest-Sollwerte gegen die Pin-Stellen byte-
      genau; die Fassung steht in `.d-check.yml`. Rot gesehen über ein
      manipuliertes Inventar-Soll (Mutations-Fälle je
      [`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update: Sensor-Index-Zeile + Sensor-Text (offentlicher Vertrag).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
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
[`slice-adr-gates-laeufen-host-native`](../next/slice-adr-gates-laeufen-host-native.md)
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
  **Ausgang:** das Inventar trägt ihn als `optional`-Eintrag; die Beschaffung
  selbst ist [`slice-binraire-ziehen-ohne-docker`](slice-binraire-ziehen-ohne-docker.md)
  und sein Netz-Aufruf nennt seinen Träger.
- **Der Guard blockt den Implementer beim Testen des Checks** (direkte
  `go`/`bats`-Positionen) — **Ausgang:** der Guard bleibt in Kraft
  ([ADR-0109](docs/plan/planning/done/) <!-- d-check:ignore (Platzhalter-Kennung: ADR-0109-Form, entsteht im Architect-Slice) -->);
  der Prüf-Weg läuft über `make`-Rezepte; wo ein Test eine direkte Position
  braucht, ist das der Befund und wird an den ADR zurückgemeldet, nicht
  still umgangen.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <… | keine Beobachtung angefallen>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

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
