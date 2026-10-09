# Verifikation: Closure-Trigger von welle-kotlin-skelett (Schritt 1)

**Rolle:** Verifier · **Datum:** 2026-10-09 · **Gegenstand:** Closure-Trigger aus
`docs/plan/planning/welle-kotlin-skelett.md` §3, Punkte 1–3 (Punkt 4, die Closure-Notiz, ist
Planner-Arbeit und nicht Gegenstand dieses Belegs) · Bezug [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md).

**Gemessener Commit:** `11b35f680e2abab3e25a50cbe6dd4a30109b694c` (HEAD, `main`, Arbeitsbaum sauber
vor und nach beiden Läufen; `git rev-parse HEAD` vor `make full-smoke` und danach gleich). Beide
Läufe nacheinander auf diesem Commit: erst `make full-smoke`, dann `make gates`.

## Verdikte

- **Alle Slices aus §4 in `done/` — bestätigt.**
  `find docs/plan/planning -name 'slice-kotlin-*.md' -not -path '*/observations/*'` →
  `done/slice-kotlin-flaches-skelett.md`, `done/slice-kotlin-hexslice-mit-arch-gate.md`,
  `done/slice-kotlin-root-bootstrap.md`, `done/slice-kotlin-freshness.md`; in `open/`, `next/`,
  `in-progress/` kein `kotlin`-Treffer.
- **`make gates` grün — bestätigt.** Exit 0, Wandzeit 191 s; letzte Zeile
  `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.
- **`make full-smoke` grün mit allen Kotlin-Stufen — bestätigt.** Exit 0. Kotlin-Stufen im Log, je
  mit Stufen-Kopf und ohne `FEHLER` des Laufs selbst (das Skript bricht an jedem Fehlschlag ab):
  - **flat (Mono-Repo, `add-lang kotlin apps/kt`):** `full-smoke: add-lang kotlin apps/kt ins
    Mono-Repo (dritte Sprache, JVM-Gradle) ...`; Abdeckung `LH-FA-04 LH-FA-06 LH-QA-01` (Gradle-Gates
    assemble/test/detekt, Guard blockt `gradle build`).
  - **gemischter Root go+cpp+kotlin:** `full-smoke: gemischter Root go+cpp+kotlin — make
    test/lint/build direkt bedient drei Sprach-Fragmente ...`.
  - **hexslice (Subdir, `add-lang kotlin apps/kthex --arch hexslice`) samt rotem Gegenbeispiel:**
    `full-smoke: Kotlin-Arch-Gate-Zaehne belegt (Import aus der Domain in einen Adapter faerbt a-check
    rot, danach zurueckgenommen):` gefolgt von
    `src/main/kotlin/app/hexagon/domain/example/Greeting.kt:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier`
    und `core-impurity: 1`.
  - **Root-Bootstrap (`--lang kotlin --arch hexslice`) samt rotem Gegenbeispiel:**
    `full-smoke: Kotlin-Arch-Gate-Zahn am Root belegt (...)` gefolgt von derselben Zeile
    `Greeting.kt:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier` und
    `core-impurity: 1`.
  - **Kennungs-Form:** `(kotlin flat)` und `(kotlin hexslice)` unter den 8 gefahrenen Kombinationen,
    je `docs-check '0 Befund(e)'`.
- **`core-impurity`-Meldungen gelesen.** Subdir und Root nennen dieselbe Fundstelle — die
  Domain-Datei `Greeting.kt`, Zeile 4 — und dieselbe Ursache, den Import des Adapters
  `app.adapters.driven.notify.StdoutNotifier` in den Kern. Das Rot trägt die behauptete Ursache;
  das Skript hält die Zeile wörtlich (`grep -qF`, `harness/tools/full-smoke.sh` an den Stellen
  `kthexarch_out` und `ktrootarch_out`).
- **Zwei `FEHLER`-Zeilen im Log sind kein Befund:** `selbstpruefung: FEHLER — [Makefile] ist nicht
  der Traeger …` und `e2e-abdeckung: FEHLER — Stufe ohne Deklaration …` stehen eingerückt unter
  Stufen, die die Gegenrichtung absichtlich rot fahren, und der Lauf endet Exit 0.

## Laufzeit (MR-089)

- `make full-smoke`: **256 s** Wandzeit (`date +%s` vor/nach), davon laut Log Kotlin-hexslice-Stufe
  16 s und Kotlin-Root-Stufe 5 s; `make gates` danach: 191 s.
- **Lage: warm.** Images lokal im Builder-Store, Build-Cache warm — im Log 609 `CACHED`-Schritte,
  kein Pull und kein Extrahieren einer Schicht; das Gradle-Image `gradle:9.8.1-jdk21` erscheint nur
  als `load metadata`/`FROM … @sha256:d5c815d1…`. Gemessen auf einem Host, auf dem die vier
  Kotlin-Slices zuvor gelaufen sind.
- **Variante:** der volle E2E-Lauf, also alle Varianten, die `full-smoke` fährt (sprachlos; go flat,
  hexagonal, hexslice; cpp flat, hexslice; kotlin flat, hexslice; gemischter Root) zugleich; eine
  Zahl je Variante liegt nur für die zwei Kotlin-Stufen oben vor.
- **Ungemessen:** kalte Lage (kein Image, kalter Cache) und der Lauf in CI.

## Ergebnis

Closure-Trigger §3 Punkte 1–3 auf `11b35f68` **erfüllt**. Offene Punkte für den Planner: keine aus
diesem Schritt; Punkt 4 (Closure-Notiz) steht aus.
