# Slice slice-kotlin-hexslice-mit-arch-gate: Kotlin-hexslice mit emittiertem Arch-Gate und core-impurity-Zahn

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt — eines von
`open/`, `next/`, `in-progress/`, `done/`. Er wechselt nur durch `git mv`, siehe Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-kotlin-skelett](welle-kotlin-skelett.md).

**Bezug:** [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) · [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) · [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md). Grundlage: Vorklärung
`2026-10-08-kotlin-welle-architect-vorklaerung`.

**Berührte Spec-Stellen:** `spec/architecture.md` Layout je Sprache; `ARC-009`, `ARC-010` (über [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** `add-lang kotlin --arch hexslice` rendert die Rollen-Pakete aus [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 4 samt
`.a-check.yml`, und ein Import aus dem Kern in einen Adapter färbt das emittierte Arch-Gate rot.

**Ausdrücklich NICHT in diesem Slice:**

- `--lang kotlin` am Root — übernimmt `slice-kotlin-root-bootstrap`; zusammen mit ihm hätte dieser
  Slice vier Liefer-Punkte.
- `hexagonal` und dessen Zähne — [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) legt das Layout nicht fest (Trigger 3, Folge-ADR).
- Eine Anforderung an a-check — nur, wenn eine Config, die Importe auflöst, grün bleibt
  (Re-Evaluierungs-Trigger 1); dann Rückführung.

## 2. Definition of Done

- [x] hexslice-Renderer mit den Pfaden aus [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 4, Paket == Verzeichnis;
      `archGateConfigs()` mit `resolution: kotlin: {mode: fixed-root, roots: ["src/main/kotlin/app"], package_base: "app"}`;
      im gebootstrappten Ziel meldet a-check keinen Hinweis „0 von N Import-Symbolen lösen auf".
- [x] `make full-smoke`: `add-lang kotlin <pfad> --arch hexslice` grün; mit Import aus
      `app.hexagon.domain` nach `app.adapters` rot mit `core-impurity` (Meldung gelesen); Stufe mit
      `e2e_abdeckung`-Kopfzeile; Laufzeit-Zuwachs gemessen, in §7
      ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)).
- [x] `spec/architecture.md` Layout je Sprache um Kotlin nachgezogen (Folgepflicht [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — oder in §7 notiert, dass keine Beobachtung anfiel.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die Closure von `welle-kotlin-skelett`; nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/kotlin.go`, `internal/gen/arch.go` (+ Tests) | update | Rollen-Renderer, `archGateConfigs()` |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe + Arch-Zahn, erzeugte Sicht |
| `spec/architecture.md` | update | Layout je Sprache |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-kotlin-flaches-skelett` liegt in `done/`.

**Rückführungen:**

- `in-progress` → `next`: der Rollen-Renderer verlangt eine Änderung am sprach-agnostischen Seam
  `internal/gen/arch.go` — eigener Schnitt.
- `in-progress` → `open`: eine auflösende Config bleibt grün ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Trigger 1) — Anforderung an
  a-check über den Auftraggeber.

## 5. Closure-Trigger

DoD vollständig, Arch-Zahn rot und Gegenprobe grün in `make full-smoke`, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- JVM/Gradle verlängern `make full-smoke` je Stufe um einen `docker build` mit
  Dependency-Auflösung — **Ausgang:** entfallen — gemessen, Δ ≈ 9 s am Gesamtlauf bei warmer Lage
  (§7); der kalte Lauf ist benannt ungemessen, die Klasse trägt
  `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen`, verkörpert in
  [MR-089](../../../../harness/conventions.md#mr-089).
- Ein Paket außerhalb seines Verzeichnisses entgeht der Auflösung ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) §Konsequenzen) —
  **Ausgang:** entfallen — im Skelett hält Fall 623 (`TestKotlinHexslice_PaketGleichVerzeichnis`)
  Paket == Verzeichnis; ein Adopter, der ein Paket anderswo ablegt, ist eine Konsequenz, die
  [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) in Kauf nimmt.

## 7. Closure-Notiz

- **Was hat funktioniert:** Der Arch-Zahn färbt mit
  `Greeting.kt:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier`, die
  Stufe vergleicht die Zeile byte-genau; die HEAD-Config meldet keinen Hinweis „0 von N
  Import-Symbolen", der Root aus Fall 624 vier (gegen a-check `v0.23.0`). Die Fälle 623 und 624
  binden ihren Wächter allein (Gegenprobe mit `t.Skip`), Fall 625 färbt über `app-impurity`
  (Review-Report `2026-10-09-slice-kotlin-hexslice-mit-arch-gate` §Belege).
- **Laufzeit (DoD 2, [MR-089](../../../../harness/conventions.md#mr-089)):** `make full-smoke`
  186,35 s auf `9d1b0837` gegen 177,17 s auf `9d1b0837^`, Δ ≈ 9 s am Gesamtlauf; je ein Lauf,
  Images und BuildKit-Cache warm; Variante `add-lang kotlin --arch hexslice` neben dem bereits
  gebauten flachen Kotlin-Modul. Streuung und kalter Lauf sind ungemessen. Die 13 s der Stufe
  umfassen `make -j gates` über alle Module des Ziels und sind kein Kotlin-Zuwachs (Review INFO-2).
  Kein Beleg für `BEO-ALL/kosten-einer-emittierten-pruefung-im-ziel-ungemessen`: Lage und Variante
  sind benannt, die Regel hat gegriffen.
- **Was ging anders als geplant:** `spec/architecture.md` bekam den Abschnitt „Layout je Sprache"
  neu, samt go-/cpp-Sätzen, die die Folgepflicht aus
  [ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) nicht deckt
  (Review LOW-1). Das Architect-Verdikt `2026-10-09-spec-architecture-architect-verdikt` lässt sie
  als akzeptiertes Negativ bis `slice-151-spec-straten-haben-eine-schreibende-rolle` stehen.
- **Steering-Loop-Eintrag:** benannte Spec-Lücke — `ARC-009` legt den Composition Root für
  `hexslice`/`hexagonal` sprachübergreifend auf `cmd/`, Code und Absatz „Layout je Sprache“ führen
  ihn je Sprache (Review LOW-2). Die Korrektur wartet auf eine schreibende Rolle für Rang 3; Adresse
  `slice-151-spec-straten-haben-eine-schreibende-rolle` (`open/`), Änderungsbedarf als Übergabe im
  Architect-Verdikt.
- **Beobachtungs-Register (`../observations/`):** Belege in
  `BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` (LOW-1, verkörpert in
  [ADR-0062](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)) ·
  `BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt` (LOW-2, 2×, offen) ·
  `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` (INFO-1, geplant) ·
  `BEO-ALL/strukturtest-sieht-den-import-alias-nicht` (INFO-3, 2×, offen). Benannt, nicht gezählt:
  INFO-2 — die Stufen-Ausgabe nennt ihren Umfang, und §7 liest sie nicht als Zuwachs. Kein Eintrag
  erreicht mit diesem Slice 3× ohne Ausgang.
- **Folge-Slices:** keine.
- **Paarungen geprüft am 2026-10-09:** (a) kein Eintrag trägt das Zielort-Feld, die benannte
  Spec-Lücke hat keinen Zielort; die genannte Adresse `slice-151-spec-straten-haben-eine-schreibende-rolle`
  existiert unter `open/` · (b) keine Folge-Slices genannt · (c) die fünf hier genannten `BEO-ALL/…`
  existieren, je `evidence/*.md` ≥ 1; zweite Hälfte über das Register: 2 Verzeichnisse ohne Beleg,
  namentlich `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` und
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet (Kommando:
  Schleife über `BEO-ALL/*/evidence/*.md`, `close-welle.md` Schritt 3).
- **Risiken aus §6:** Ausgänge stehen in §6.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (`ALL`); das Skelett liegt in `internal/gen/` und
`harness/tools/full-smoke.sh`, für die die Modus-Deklaration keine eigene Sub-Area führt.

**Vorgelagert — offene Beobachtungen sichten** (Zähler je
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gelesen 2026-10-09):
`neuer-waechter-ohne-mutations-fall` — 19, geplant; jeder neue Kotlin-Test ist ein neuer Wächter ·
`pin-digest-ohne-waechter` — 4, geplant; Kotlin pinnt per Tag ([ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2) ·
`cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` — offen; trifft das Kotlin-Image gleich ·
`lokaler-full-smoke-scheitert-auf-macos-host` — 2, offen; neue full-smoke-Stufen erben ihn.

**Modus:** alle berührten Sub-Areas GF.
