# Verifikation: slice-kotlin-root-bootstrap — 2026-10-09

**Rolle:** Verifier (Modul 11). **Gegenstand:** `12d6868d` (Arbeit), `a96c30e0` (Review-Befunde),
gegen den Slice-Plan (Stand `a96c30e0`), [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Accepted).
**Review:** `2026-10-09-slice-kotlin-root-bootstrap` (`5b6d728d`), 0 HIGH · 0 MEDIUM · 3 LOW · 2 INFO.
Gelesen habe ich den ganzen Diff. Gemessen habe ich nur, was unten steht.

**Urteil:** Die Liefer-Punkte sind bestätigt. Die Closure-Punkte sind offen. Kein Befund betrifft
Bedeutung oder Verhalten. Für den Planner gibt es einen offenen Punkt zur Laufzeit-Angabe.

## Verdikte je DoD-Punkt

- **DoD 1 — `--lang kotlin` und `--lang kotlin --arch hexslice` am Root, mit Unit-Tests: bestätigt.**
  - `TestRun_BootstrapKotlinRoot` (flat + hexslice) und die zwei Kotlin-Varianten in
    `TestEmittierteDateienTragenNurImZielAufloesendeKennungen` laufen grün in `make gates` (unten).
  - Rot-Beleg an der Verdrahtung (von mir ergänzt, in einer `git archive`-Kopie außerhalb des
    Repos): In `cmd/ai-harness-init/main.go:626` wurde `wireLang(…, ".", …)` zu `"sub"` geändert,
    danach lief `make test-go`. Ergebnis: `--- FAIL: TestRun_BootstrapKotlinRoot` mit
    `flat: settings.gradle.kts liegt nicht am Root …` (dasselbe für `Dockerfile`, `harness/mk/kotlin.mk` …),
    außerdem `--- FAIL: TestRun_BootstrapMeldetNeueTargets` (`stdout nennt das neue Gate lint nicht`).
    Alle anderen Pakete bleiben `ok`. Der Test wird also aus dem behaupteten Grund rot.
  - Rot-Belege in `internal/gen/`:
    `MUTATE_JOBS=1 MUTATE_CASES='626-… 627-… 628-…' make mutate` → `3 ok, 0 Befund(e)`, EXIT 0;
    626 → `TestKotlinCodeGateFragment_RootUndSubdir rot`, 627 → `TestArchGateConfig_KotlinMatchesSkeleton rot`.
- **DoD 2 — `make full-smoke` mit Root-Stufe `--lang kotlin --arch hexslice`, `make gates` grün samt
  Arch-Gate, Kopfzeile, Laufzeit-Zuwachs in §7: bedingt.** Die Stufe ist bestätigt. Offen ist §7,
  denn die Laufzeit trägt erst die Closure ein.
  - `make full-smoke` (allein gefahren) → EXIT 0, `grep -c 'full-smoke: FEHLER'` → 0,
    `grep -c 'Import-Symbolen'` → 0.
  - Root-Arch-Zahn, Meldung gelesen:
    `src/main/kotlin/app/hexagon/domain/example/Greeting.kt:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier`.
    Die Regel und die Fundstelle stimmen mit der Mutation der Stufe überein.
  - Fall 628 (full-smoke) → `full-smoke: FEHLER — make gates am Kotlin-Root-Modul ohne Beleg fuer: rot`,
    also die behauptete Meldung.
  - Kopfzeile: `make e2e-abdeckung` erzeugt keinen Diff gegenüber `docs/user/e2e-abdeckung.md`.
    Die Zeile „Stufe 21“ nennt `NICHT gemessen: --lang kotlin ohne --arch am Root`.
  - Laufzeit nach [`MR-089`](../../harness/conventions.md#mr-089): Gemessen mit
    `/usr/bin/time -f 'FULLSMOKE_SECONDS=%e' make full-smoke` → `FULLSMOKE_SECONDS=218.54`.
    Die Stufe meldet `Kotlin-Root-Stufe dauerte 5s`. Lage: Images lokal, Docker-Build-Cache warm
    auch für die Gradle-Schichten (zuvor liefen Implementer-, Review- und Mutate-Läufe über
    dasselbe Skelett), ein Lauf. Variante `--lang kotlin --arch hexslice`; flat am Root ist nicht gemessen.
    Ein Lauf davor brach ab: `ERROR: failed to build: … rpc error: code = Unavailable … EOF` in der
    cpp-Stufe am gemischten Root, gleichzeitig mit zwei `make test-go`-Läufen von mir. Ich ordne das
    BuildKit zu, nicht dem Baum. Der Grün-Vorlauf von `make mutate` über denselben Baum war grün (243,27 s).
- **DoD 3 — `make gates` grün: bestätigt** (Lauf am Ende, vor dem Commit dieses Berichts).
- **DoD 4 — Review durchgeführt: bestätigt.** Der Report liegt unter `docs/reviews/` (`5b6d728d`),
  geschrieben in eigenem Kontext. LOW-1 und LOW-2 sind in `a96c30e0` umgesetzt (Fälle nennen den
  direkt lesenden Test, der Testkopf nennt die richtige Stufe und sagt der flachen Variante keinen
  Gate-Lauf zu). Für LOW-3 gibt es keine Code-Änderung; das geht an den Planner (unten).
- **DoD 5–8 (Closure-Notiz, Register, Risiko-Ausgang, Paarungen): nicht bestätigt — offen.** Das ist
  Planner-Arbeit. §6 und §7 stehen noch auf *bei Closure*.

## Grenze im Testkopf (cmd-Verdrahtung)

Die Grenze stimmt.
- `grep -n -i kotlin cmd/ai-harness-init/*.go` außer Tests findet nur Hilfetexte (Z. 120, 290). Es
  gibt keine kotlin-eigene Verzweigung.
- `wireLang` (Z. 420) ist sprachunabhängig. Was sprachspezifisch ist, liegt in `internal/gen/`.
- Der Bruch des Pfads `"."` in `emitAll` färbt `TestRun_BootstrapKotlinRoot` **und**
  `TestRun_BootstrapMeldetNeueTargets` rot (Messung oben). Die Aussage „bindet die cmd-Stelle
  nicht allein“ ist damit belegt.

## Plan-vs-Code

- §3, Zeile `cmd/`/`internal/gen/`: Der Plan sagt „ohne Code-Änderung, nur Tests und Fälle 626–628“.
  `git show --stat 12d6868d a96c30e0` bestätigt das: Produktcode ist unverändert, geändert sind
  `main_test.go`, `kennungen_test.go`, `test/mutations/626–628`, `full-smoke.sh` und
  `e2e-abdeckung.md`. Nichts ist ohne Plan gebaut.
- Rückführungen in §4 sind nicht eingetreten. Es gibt keine sprachspezifische Verzweigung außerhalb
  von `internal/gen/`, und die Root-Stufe ist ohne Renderer-Änderung grün.
- ADR-0088: Das Root-Fragment ist unscoped mit Kontext `.`. `.a-check.yml` trägt
  `roots: ["src/main/kotlin/app"]` und `package_base: "app"`. Das Arch-Gate gibt es nur bei
  `hexslice`. Test und Stufe prüfen genau das, ich finde keinen Widerspruch.

## Offen für den Planner

- **Laufzeit-Angabe (§7, Risiko §6).** Der Implementer gibt +39,6 s an (210,95 s gegen 250,55 s) und
  schreibt „Gradle-Abhängigkeiten werden je Lauf neu aufgelöst“. Mein Lauf meldet für die Stufe 5 s
  bei warmem Cache. Die Aussage gilt also nur bei kaltem Gradle-Layer, nicht je Lauf. Wie die Zahl
  gemessen wurde, steht im Protokoll des Implementers, und ein Kommando dafür fehlt (LOW-3,
  [`MR-051`](../../harness/conventions.md#mr-051)). Der Planner sollte in §7 die Lage nennen, unter
  der die Zahl gilt.
- `--lang kotlin` ohne `--arch` am Root deckt nur der Unit-Test, ein Gate-Lauf fehlt. Die Kopfzeile
  und der Testkopf sagen das. Das ist eine Grenze, kein Befund.

## Negativbefunde

- Mutationsfälle: alle drei treffen ihren Anker und werden mit der benannten Meldung rot.
- E2E-Sicht: die erzeugte Datei stimmt mit der Deklaration überein.
- Hard Rules: keine Host-Toolchain und keine Suppression im Diff. Den Verifikationslauf habe ich
  über `make` gefahren.
