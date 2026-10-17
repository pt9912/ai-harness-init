# Slice slice-java-hexslice-layout: Java-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** `welle-sprachprofile-java-python-csharp`.

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) ·
[`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren). [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md)
(Accepted) legt die Layouts
`flat` und `hexslice` fest, Festlegung 4 trägt Pfade und Auflösung.

**Berührte Spec-Stellen:** `spec/architecture.md` Layout je Sprache; `ARC-009`, `ARC-010` (über die ADR
des Architect).

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-17.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang java --arch hexslice` rendert die Rollen-Pakete der ADR (Pfade nach
[ADR-0060](../../adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)) samt `.a-check.yml`,
und ein Import aus dem Kern in einen Adapter färbt das emittierte Arch-Gate rot.

**Abhängigkeit:** setzt `slice-java-skelett` voraus (Renderer, Gerüst, Stufe im Mono-Repo); Start erst,
wenn der in `done/` liegt.

**Ausdrücklich NICHT in diesem Slice:**

- `flat` und das Java-Gerüst — liefert `slice-java-skelett`; hier nur die Schicht-Achse darüber.
- `hexagonal` — die ADR legt das Layout nicht fest (Re-Evaluierungs-Trigger, Folge-ADR); ohne ADR
  wäre es eine ungetragene Entscheidung.
- Eine Anforderung an a-check — nur, wenn eine Config, die Importe auflöst, grün bleibt
  (Re-Evaluierungs-Trigger der ADR); dann Rückführung.
- Ein Java-Freshness-Werkzeug — anderer Vorgang als das Layout.

## 2. Definition of Done

- [ ] hexslice-Renderer mit den Pfaden der ADR Festlegung 4 (`src/main/java/app/hexagon/…`,
      `src/main/java/app/adapters/…`, `Main.java`, Tests unter `src/test/java/app/`), Paket == Verzeichnis;
      `archGateConfigs()` mit `languages: java` und
      `resolution: java: {mode: fixed-root, roots: ["src/main/java/app"], package_base: "app"}`;
      `java` in `langArchs()` führt `hexslice`; im gebootstrappten Ziel meldet a-check keinen Hinweis
      „0 von N Import-Symbolen lösen auf" (Probe gegen das Ziel, nicht gegen eine Fixture).
- [ ] `make full-smoke`: `add-lang java <pfad> --arch hexslice` grün; mit Import aus
      `app.hexagon.domain` nach `app.adapters` rot mit `core-impurity` (Meldung gelesen); Stufe mit
      `e2e_abdeckung`-Kopfzeile, `docs/user/e2e-abdeckung.md` neu erzeugt; Laufzeit-Zuwachs mit
      Image-Lage und Variante ([`MR-089`](../../../../harness/conventions.md#mr-089)).
- [ ] `spec/architecture.md` Layout je Sprache um Java nachgezogen (Folgepflicht der ADR).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`),
      kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine
      Beobachtung anfiel.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die Closure von `welle-sprachprofile-java-python-csharp`; nach dem
      Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/java.go`, `internal/gen/arch.go` (+ Tests) | update | Rollen-Renderer, `archGateConfigs()`, `langArchs()` |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe und Arch-Zahn, erzeugte Sicht |
| `spec/architecture.md` | update | Layout je Sprache |
| `test/mutations/` | neu / update | ein Fall je neuem Wächter ([`MR-071`](../../../../harness/conventions.md#mr-071)) |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-java-skelett` liegt in `done/`, die ADR für Java ist
`Accepted`, WIP-Slot frei.

**Rückführungen — vorab benennen:**

- `in-progress` → `next`: der Rollen-Renderer verlangt eine Änderung am sprach-agnostischen Seam
  `internal/gen/arch.go` — eigener Schnitt.
- `in-progress` → `open`: eine auflösende Config bleibt grün (Trigger der ADR) — Anforderung an a-check
  über den Auftraggeber.

## 5. Closure-Trigger

DoD vollständig, Arch-Zahn rot und Gegenprobe grün in `make full-smoke`, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Das Gegenbeispiel färbt am gebootstrappten Ziel nicht rot (die ADR hat es nur am Probe-Projekt rot
  gesehen) — **Ausgang:** bei der Closure; zuerst die Config prüfen, Layout sonst aus dem Slice nehmen.
- Ein Paket außerhalb seines Verzeichnisses entgeht der Auflösung — **Ausgang:** bei der Closure;
  Skelett-Test hält Paket == Verzeichnis, Adopter-Fall ist Konsequenz der ADR.

## 7. Closure-Notiz

<!-- Erst bei der Closure füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Layout liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-17):
`neuer-waechter-ohne-mutations-fall` — 20, geplant; jeder neue Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 8, verkörpert; der a-check-Pin besteht schon ·
`waechter-misst-die-fixture-statt-der-realen-quelle` — 10, geplant; die Probe läuft gegen das Ziel, nicht
gegen eine Fixture ·
`strukturtest-sieht-den-import-alias-nicht` — 2, offen; der Paket-Test des Skeletts ist davon berührt ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 3, verkörpert; die Stufe erbt es.

**Modus:** alle berührten Sub-Areas GF.
