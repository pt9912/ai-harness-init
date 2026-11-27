# Slice slice-full-smoke-gates-echt-gruen: `full-smoke` läuft ohne Docker vollgrün

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — die Restmenge der
LP2/LP3-Lieferpunkte von
[`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Messmethode „`make gates` grün out-of-the-box" — der volle Nachweis),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`ADR-0109`](../../../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md),
[`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin je neuem Fall).

**Berührte Spec-Stellen:** `spec/spezifikation.md` — die E2E-Stufen-Deklarationen
im Umfang der Rest-Stufen. Der Verweis zeigt **aufwärts**.

**Verantwortlich:** —

**Autor:** pt9912 (Rolle Planner, Closure-Lauf slice-smoke-und-full-smoke-ohne-docker). **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Restmenge des docker-losen `full-smoke` trägt den Host-Weg —
Vorbild: die Slice-Datei
[`done/slice-smoke-und-full-smoke-ohne-docker.md`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
§1, deren reale Lauf-Kette an der **ersten** Daemon-gebundenen Stufe brach
(belegt am Register
[`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)).
Die vier Rest-Klassen, je eine Stufe-Gruppe des `full-smoke`-Skripts:

- **1a — Vorlauf-Wächter-/Doku-Zahn-Stufen** über dem emittierten
  `d-check.mk` (`doc-commits`, `doc-immutable`): Docker-getriebene Module des
  emittierten Doc-Gates — der host-native Weg trägt dieselben Module am Host
  (dieselbe Form wie der Labor-`docs-check-host`-Rezept),
- **1b — Archiv-Leseprobe** (`unzip` am Inventar),
- **1c — hexslice-/hexagonal-Bootstraps** (`a-check --print-mk` ohne
  Host-Carrier),
- **1d — die carrier-gebundenen `make gates`-Läufe** des Mono-Repos.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Stufen-Deklarationen der E2E-Abdeckung** — sie werden nicht still
  geändert ([`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit));
  ein Wegfall einer Deklaration ist eine Senkung mit ADR (§3.5), kein Teil
  dieses Slices.
- **Die Mutations-Fälle der `smoke`-Spur** — die sind entlassen und tragen
  (Bestand bleibt bewusst stehen).
- **Der Release-Schnitt am Tag** ([`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix))
  — ein anderer Vorgang.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** `make full-smoke` läuft auf einem Host **ohne**
      Docker-Daemon **vollgrün** (Exit 0) — die vier Stufen-Gruppen 1a–1d
      tragen je einen host-nativen Träger, die Stufen-Deklarationen bleiben
      unverändert.
- [ ] **Liefer-Punkt 2:** ein `# verify: full-smoke`-Fall färbt docker-los
      (Treiber-Lauf mit Befund am Fall-Ausgang, nicht mehr an der
      Daemon-Vorbedingung; die Vorbedingung entlässt die
      full-smoke-Spur des Treibers, wenn die Restmenge trägt).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen sind von der nächsten Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | die Stufen-Gruppen 1a–1d je Host-Form |
| `harness/tools/mutate.sh` | update | Entlassung der full-smoke-Spur aus der Daemon-Vorbedingung, wenn die Restmenge trägt |
| `Makefile` / emittierte `d-check.mk`-Vorlage | update | host-native Module je Stufe |
| `test/mutations/` (je Fall) | neu | Färbung-Nachweis je neuem Fall (MR-071/MR-090) |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
liegt in `done/` und [`slice-ci-runner-ohne-docker`](../done/slice-ci-runner-ohne-docker.md)
sind abgelöst — die reale Lauf-Kette steht mit ihrem exakten
Abbruchpunkt.

**Rückführungen — vorab benennen:**

- `in-progress` → `next`: mehr als drei Liefer-Punkte — etwa, wenn eine
  Stufe-Gruppe je Bootstrap-Layout re-slicen braucht → re-slicen je Gruppe.
- `in-progress` → `open`: eine Stufe-Gruppe hat keinen host-nativen Träger,
  den der Host-Vorrat trägt — dann Carveout-Klärung an der ADR-0109-Fassung
  und die Stufen-Deklaration wird neu formuliert, nicht still geändert.

## 5. Closure-Trigger

DoD (§2) vollständig; der reale Lauf `make full-smoke` (vollgrün, Exit 0)
und der Färbungs-Lauf eines `# verify: full-smoke`-Falles im
Verifikations-Bericht. Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- **F-7 des Reviews 2026-11-27 (INFO): die `SKEL_GO_VERSION`-Ableitung trägt
  die Tool-Ebene des Pins, die Profil-Prüfung die Repo-Dockerfile-Ebene** —
  die zwei Formen drifteten in der Vorbestand-Klasse
  `TestGoProfile_PinsMatchRepo` (1.27.3 generiert vs 1.27.4 im
  Repo-Dockerfile). **Ausgang:** bei Closure entscheiden — eigener
  Mikroposten (Pin-Derivation an der Tool-Ebene binden) oder die Lücke am
  Ort benennen; kein stiller Bestand.
- **Die 63 `full-smoke`-Fälle der Mutations-Anlage laufen erst nach der
  Entlassung** — **Ausgang:** dieselbe Vorbedingungs-Form wie die
  smoke-Spur ([`slice-mutate-treiber-host-modi`](../done/slice-mutate-treiber-host-modi.md));
  bis dahin benennt der Treiber die Ursache, nicht einen Fall-Ausgang.

## 7. Closure-Notiz

- *(wird bei dessen Closure gefüllt)*

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `harness/tools/`
(Kürzel `TOOLS`) und `*` (Kürzel `ALL`); beide erfüllen die Schwelle ≥ 2
von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:

- [`BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet`](../observations/BEO-ALL/docker-aussetzer-im-vorlauf-wird-als-falscher-grund-gemeldet/state.md)
  — Stand verkörpert (Treiber-Vorbedingung); dieser Slice ist die Adresse
  seines `full-smoke`-Rests — kein weiterer Übertritt.
- [`BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache`](../observations/BEO-ALL/full-smoke-fall-expect-pinnt-nicht-die-ursache/state.md)
  — 2 Vorgänge (< 3×): die Stufen-Deklarationen werden nicht umgeschrieben;
  bei der LP-2-Färbung die `# expect:`-Form je neuem Fall nach
  `MR-071`/`MR-090` führen.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
