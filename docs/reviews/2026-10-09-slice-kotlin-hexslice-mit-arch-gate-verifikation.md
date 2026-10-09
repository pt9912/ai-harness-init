# Verifikations-Bericht: slice-kotlin-hexslice-mit-arch-gate — 2026-10-09

**Rolle:** Verifier (Baseline-Regelwerk `modul-11-verification.md`) · **Modell:** claude-opus-5-5

**Gegenstand:** Commit `9d1b0837` (Implementer) gegen die DoD des Slice-Plans
`slice-kotlin-hexslice-mit-arch-gate` (Stand `6e613cdb`), gegen
[`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`spec/architecture.md`](../../spec/architecture.md) und
[ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Accepted).
Eingang: Review `2026-10-09-slice-kotlin-hexslice-mit-arch-gate` (0 HIGH · 0 MEDIUM · 2 LOW · 3 INFO).

**Urteil:** die Liefer-Punkte 1, 3 und 4 sind bestätigt. Punkt 2 ist bedingt bestätigt: die Laufzeit
ist gemessen, ihr Eintrag in §7 fehlt noch und gehört zur Closure. Punkt 5 ist bestätigt. Die
Punkte 6 bis 9 sind Closure-Arbeit des Planners. Es gibt keinen Befund gegen Verhalten oder Zusage.
Offen sind zwei Spec-Punkte für den Architect (Review LOW-1 und LOW-2).

## Verdikte je DoD-Punkt

- **1 — hexslice-Renderer, Paket == Verzeichnis, `resolution`-Block, kein Hinweis „0 von N
  Import-Symbolen“: bestätigt.**
  - Pfade gegen ADR-0088 Festlegung 4: `internal/gen/kotlin.go` rendert
    `src/main/kotlin/app/hexagon/{domain,application}/…`, `src/main/kotlin/app/adapters/{driving,driven}/…`
    und `src/main/kotlin/app/Main.kt`. Der `resolution`-Block lautet `kotlin: {mode: fixed-root,
    roots: ["src/main/kotlin/app"], package_base: "app"}` (`kotlin.go:510–514`), wörtlich wie in
    der ADR.
  - Rot-Beleg Paket == Verzeichnis: Fall 623 in einem Klon unter dem Scratchpad angewandt, danach
    `make test-go`. Ergebnis `--- FAIL: TestKotlinHexslice_PaketGleichVerzeichnis` mit
    `kotlin_test.go:231: …/domain/example/Greeting.kt deklariert package app.hexagon.domain, das
    Verzeichnis verlangt app.hexagon.domain.example`. Rot wird nur dieser Test, und zwar aus dem
    behaupteten Grund.
  - Rot-Beleg Root: Fall 624 ebenso angewandt. Ergebnis `--- FAIL:
    TestArchGateConfig_KotlinEdgesMatchSkeleton` mit neun Zeilen
    `… loest auf src/main/kotlin/hexagon/… auf und trifft keine Schicht (das Gate saehe ihn nicht)`
    und fünf Zeilen „Kante … wird von keinem aufgeloesten Import gebraucht“. Der Grund stimmt mit
    der Behauptung überein. **Grenze:** der Test misst einen Nachbau der a-check-Auflösung (Review
    INFO-1). Die reale Quelle hält erst `make full-smoke`, siehe Punkt 2. An a-check selbst hat das
    Review diese Mutation gefahren, ich habe den Lauf nicht wiederholt.
  - `make mutate MUTATE_CASES='623-… 624-…'` → `mutate: 2 ok, 0 Befund(e)`.
  - Abwesenheit des Hinweises im Ziel: In meinem `make full-smoke`-Log ergibt
    `grep -n 'Import-Symbolen' fs.log` keinen Treffer, und die Stufe prüft diese Abwesenheit
    ausdrücklich (`full-smoke.sh`, Block `kthex_out`).

- **2 — `make full-smoke`: grün, Domain→Adapter rot mit `core-impurity`, Stufen-Kopfzeile,
  Laufzeit-Zuwachs in §7: bedingt bestätigt.**
  - Grüner Lauf, selbst gefahren: `/usr/bin/time make full-smoke` endet mit **EXIT=0** nach
    **186,35 s**. Variante: das volle full-smoke-Programm, also alle Stufen und nicht nur Kotlin.
    Lage: Images und BuildKit-Cache warm, weil unmittelbar davor zwei full-smoke-Läufe des
    `mutate`-Laufs vorausgingen. Das Basis-Image `gradle:9.8.1-jdk21` liegt nicht als Tag im
    lokalen Image-Store, wird aber aus dem BuildKit-Cache bedient. Im Abschnitt der Stufe stehen 111
    `CACHED`-Zeilen. Kalter Lauf: *ungemessen*.
  - Rotes Gegenbeispiel, Meldung gelesen (`fs.log` Zeile 5682):
    `src/main/kotlin/app/hexagon/domain/example/Greeting.kt:4: core-impurity: Kern importiert
    app.adapters.driven.notify.StdoutNotifier`, danach `core-impurity: 1`. Die Regel ist die
    behauptete und die Fundstelle die mutierte Datei.
  - Rot-Beleg der Stufe (Fall 625, `role: domain` → `role: app`):
    `make mutate MUTATE_CASES='625-kotlin-arch-zahn-im-ziel'` ergibt
    `mutate: ok 625-… -> full-smoke: FEHLER — Kotlin-Arch-Gate rot, aber nicht mit core-impurity an
    der Domain-Datei (rot aus falschem Grund?). Ausgabe: rot` und `1 ok, 0 Befund(e)`, EXIT 0,
    Gesamtdauer 370,55 s (Grün-Vorlauf 198,73 s, Fall 158,91 s). Die Stufe unterscheidet also die
    Regel und nicht nur den Exit-Code. Die `app-impurity`-Zeile selbst führt das mutate-Log nicht.
    Gelesen hat sie das Review am direkten a-check-Lauf.
  - Stufen-Kopfzeile: `e2e_abdeckung "LH-FA-04 LH-FA-07 LH-QA-01" …` steht vor der Stufe. Die
    Kurzbeschreibung nennt, was gemessen ist, und ihre NICHT-gemessen-Liste (Review: ohne Befund).
  - **Laufzeit nach [`MR-089`](../../harness/conventions.md#mr-089):** Die Stufe gibt
    `Kotlin-hexSlice-Stufe dauerte 13s (make -j gates samt add-lang und Arch-Zahn)` aus (Zeile 5684,
    selber Lauf, warm). Wie das Review in INFO-2 schreibt, umfassen diese 13 s ein `make -j gates`
    über alle Module des Test-Repos. Bei warmem Cache sind sie größtenteils `CACHED`, und die Zahl
    ist **kein isolierter Kotlin-Zuwachs**. Den Zuwachs habe ich darum am ganzen Lauf gemessen:
    Ein Klon auf `9d1b0837^` (`343d1eb8`), unter derselben warmen Lage unmittelbar danach gefahren,
    ergibt `make full-smoke` → EXIT=0 nach **177,17 s**. Das ergibt **Δ ≈ 9 s** gegen 186,35 s.
    Variante ist `add-lang kotlin --arch hexslice` in einem Test-Repo, in dem schon ein flaches
    Kotlin-Modul (`apps/kt`) gebaut ist. Es ist je ein Lauf ohne Wiederholung, die Streuung ist also
    *ungemessen*. Der kalte Lauf, in dem die Stufe `gradle`-Layer und Dependencies zieht, ist
    *ungemessen*. **Belegt ist damit nur: warm, Δ ≈ 9 s am Gesamtlauf.** Eine Kalt-Aussage gibt
    diese Messung nicht her.
  - **Offen:** Die DoD verlangt die Zahl „in §7“. §7 steht noch auf *bei Closure*, das ist
    Planner-Arbeit (AGENTS.md §3.10). Die Zahl gehört dort mit Lage und Variante hin, wie oben
    angegeben.

- **3 — `spec/architecture.md` Layout je Sprache um Kotlin nachgezogen: bestätigt, mit zwei offenen
  Punkten für den Architect.**
  - Der Kotlin-Teil deckt sich mit ADR-0088 Festlegung 4 und mit dem Renderer: Pakete als
    Schichten, Paket == Verzeichnis, `resolution`-Block, Composition Root `Main.kt`, `exclude`
    `src/test/**`. Ebenso die Kante `driven_adapters→ports_outbound`, die als
    Vererbungs-Erfüllung beschrieben ist und in `kotlin.go` als Kante steht. Ein Gate oder einen
    Sensor für den Absatz gibt es nicht. Die Prüfung ist meine Lektüre.
  - **LOW-1 bestätigt:** Vor dem Commit gab es den Abschnitt nicht
    (`git show 9d1b0837^:spec/architecture.md | grep -c 'Layout je Sprache'` → 0). Der neue
    Absatz setzt zusätzlich Aussagen zu `go` und `cpp`. Inhaltlich stimmen sie mit `langArchs()`
    überein (`gen.go:147–151`). Die Folgepflicht aus ADR-0088 deckt sie aber nicht.
  - **LOW-2 bestätigt:** Die ARC-009-Zeile (`spec/architecture.md:97`) setzt „Composition Root
    `cmd/`“ für `hexslice` ohne Sprach-Einschränkung. Der neue Absatz nennt für `cpp`
    `src/main.cpp` und für `kotlin` `src/main/kotlin/app/Main.kt`. Der Code folgt dem neuen
    Absatz: `kotlin.go` rendert `Main.kt`, `composition_root: ["src/main/kotlin/app/Main.kt"]`.
    Innerhalb von Rang 3 widerspricht sich die Spec damit. Am Verhalten ist nichts falsch.

- **4 — `make gates` grün: bestätigt.** Ich habe den Lauf einmal am Ende über dem Baum mit diesem
  Bericht gefahren, Exit 0. Das ist Bedingung des Commits, der den Bericht trägt (Stop-Hook,
  `record-gates`).

- **5 — Review durchgeführt, Report liegt vor, kein Self-Review: bestätigt.** Der Report ist
  `2026-10-09-slice-kotlin-hexslice-mit-arch-gate.md` in Commit `6e613cdb`. Die Rolle steht in der
  Message, und der Commit ist ein anderer als `9d1b0837`.

- **6–9 — Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: nicht Gegenstand der
  Verifikation.** Das ist Planner-Arbeit bei der Closure. §6 und §7 stehen auf *bei Closure*.

## Plan-vs-Code

- Plan → Code: Alle drei Zeilen aus §3 sind geliefert (Renderer und `arch.go` mit Tests,
  full-smoke-Stufe und erzeugte Sicht `docs/user/e2e-abdeckung.md`, Spec-Absatz). Das Ziel aus §1
  ist erfüllt: `add-lang kotlin --arch hexslice` legt `.a-check.yml` und `arch-apps-kthex.mk` ab,
  und der Kern→Adapter-Import färbt das Gate rot.
- Code → Plan: Der Commit berührt drei Stellen, die §3 nicht wörtlich nennt.
  `internal/gen/gen.go` (`langArchs`: `kotlin` → `flat, hexslice`) ist notwendig, damit
  `--arch hexslice` nicht mit Exit 2 endet. Dazu kommen `internal/gen/archgate_test.go`
  (OnlyLayered-Zeilen) und `test/mutations/623–625`. Alle drei liegen innerhalb von „(+ Tests)“
  bzw. der Wächter-Pflicht (AGENTS.md §3.6). Die Rückführung aus §4 (Umbau am Seam `arch.go`)
  greift nicht, denn der Seam bekommt nur einen Map-Eintrag (`git show 9d1b0837 -- internal/gen/arch.go`:
  +1 Zeile `"kotlin": …` neben dem Ausrichten der vorhandenen zwei).
- Abgrenzung §1: Es gibt kein `hexagonal` für Kotlin
  (`TestGenerateArch_KotlinOhneHexagonal`, OnlyLayered-Zeile `{"kotlin", "hexagonal", false}`),
  kein `--lang kotlin` am Root und keine Anforderung an a-check. Trigger 1 aus ADR-0088 ist nicht
  eingetreten, denn die auflösende Config färbt rot.
- Spec-Abgleich LH-FA-07: Der Happy Path ist erfüllt (`.a-check.yml` und Fragment liegen, das
  Arch-Gate ist in `make gates` grün). Der Zahn ist erfüllt (`core-impurity` mit Regel-Namen).
  Disjunktheit gegenüber einem zweiten Kotlin-Layout hat keinen Gegenstand, solange es nur
  `hexslice` gibt.

## Offene Punkte für Planner und Architect

- **Planner (Closure):** Laufzeit in §7 mit Lage und Variante nach MR-089 eintragen. Belegt ist
  „warm, Δ ≈ 9 s am Gesamtlauf, je ein Lauf“. Die Stufen-Ausgabe „13s“ darf dort nicht als
  Kotlin-Zuwachs stehen. Kalt ist *ungemessen*. Der Ausgang für Risiko §6-1 (JVM/Gradle verlängert
  full-smoke) bekommt damit eine Warm-Zahl, aber keine Kalt-Zahl. Für Risiko §6-2 (Paket außerhalb
  seines Verzeichnisses) hält Fall 623 die Form des Skeletts. Ein Adopter-Bruch bleibt laut
  ADR-0088 §Konsequenzen akzeptiert.
- **Architect:** Review LOW-1 (go/cpp-Aussagen ohne anweisende Quelle, ADR-0062) und LOW-2
  (ARC-009 „Composition Root `cmd/`“ gegen den neuen Absatz) sind beide bestätigt. Sie betreffen
  Rang 3 und gehören vor oder zu `slice-151-spec-straten-haben-eine-schreibende-rolle`. Den
  Slice blockieren sie nicht.
- **Review INFO-1:** Die reale a-check-Auflösung hält nur `make full-smoke`, kein Gate. Der
  Testkopf von `TestArchGateConfig_KotlinEdgesMatchSkeleton` nennt diesen Halter nicht.
  Möglicher Kandidat für die Closure-Notiz bzw. `neuer-waechter-ohne-mutations-fall`.

## Kommandos

```text
$ make mutate MUTATE_CASES='623-kotlin-hexslice-paket-verzeichnis 624-kotlin-arch-root-ohne-package-base'
mutate: 2 ok, 0 Befund(e)
$ (Klon, Fall 623 angewandt) make test-go
--- FAIL: TestKotlinHexslice_PaketGleichVerzeichnis
$ (Klon, Fall 624 angewandt) make test-go
--- FAIL: TestArchGateConfig_KotlinEdgesMatchSkeleton
$ /usr/bin/time make mutate MUTATE_CASES='625-kotlin-arch-zahn-im-ziel'
mutate: ok 625-… -> full-smoke: FEHLER — Kotlin-Arch-Gate rot, aber nicht mit core-impurity …
mutate: 1 ok, 0 Befund(e)          # 370,55 s, EXIT 0
$ /usr/bin/time make full-smoke    # HEAD 6e613cdb, warm
EXIT=0  FULLSMOKE_SECONDS=186.35
full-smoke:   src/main/kotlin/app/hexagon/domain/example/Greeting.kt:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier
full-smoke: Kotlin-hexSlice-Stufe dauerte 13s (make -j gates samt add-lang und Arch-Zahn).
$ (Klon auf 343d1eb8) /usr/bin/time make full-smoke    # warm, direkt danach
EXIT=0  FULLSMOKE_PARENT_SECONDS=177.17
$ make gates
EXIT 0
```

**Stichproben statt Volllektüre:** Den Diff von `kotlin.go` habe ich über die Dateimenge der Rollen
und die Arch-Config gelesen, nicht über die Kotlin-Quelltexte im Einzelnen. Das Review hat ihn
vollständig gelesen.
