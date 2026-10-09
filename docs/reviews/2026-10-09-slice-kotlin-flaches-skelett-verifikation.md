# Verifikations-Bericht: slice-kotlin-flaches-skelett — 2026-10-09

**Rolle:** Verifier (Baseline-Regelwerk `modul-11-verification.md`), an den Planner.
**Gegenstand:** Commits `17c80593` (Arbeit) und `bbe8fc56` (Review-Befunde), Slice-Plan
`slice-kotlin-flaches-skelett` (Stand `bbe8fc56`).
**Maßstab:** DoD §2 des Plans, [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Accepted).
Der Review-Report `2026-10-09-slice-kotlin-flaches-skelett` hat den Diff vollständig gelesen; hier
sind es darum Stichproben im Code (`internal/gen/kotlin.go`, `kotlin_test.go`, `enforce.go`, die
zwei full-smoke-Stufen, der Hilfetext-Test) und eigene Läufe.

**Urteil:** Die Liefer-Punkte sind in der Sache erfüllt, alle fünf Mutationsfälle färben ihren
Wächter aus dem behaupteten Grund rot. **Nicht erfüllt** ist die Mess-Zusage in DoD-Punkt 3
(Laufzeit-Zuwachs vorher/nachher): Eine Messung existiert nirgends. **Bedingt** ist DoD-Punkt 1:
Der Sonden-Lauf ist belegt, aber nicht in §7 eingetragen. §7 schreibt der Planner bei der Closure;
die Belege dafür stehen unten.

## Verdikte je DoD-Punkt

- **1 — Renderer `kotlin`/`flat` nach ADR-0088 F1–3: bedingt.**
  - Code: `settings.gradle.kts` ohne `include`, `build.gradle.kts` (Kotlin `2.4.21`, detekt `1.23.8`),
    `detekt.yml` (`maxIssues: 0`), Dockerfile mit Stages `build`/`test`/`lint` auf
    `gradle:${GRADLE_TAG}`, Default `9.8.1-jdk21` per Tag, kein Wrapper. Gehalten wird das vom
    exakten Datei-Satz in `TestGenerate_KotlinProfile`. `SKEL_KOTLIN_VERSION` läuft über
    `gen.DefaultVersion("kotlin")` (`gen.go`).
  - Sonde (ADR-0088 F3), eigener Lauf: `add-lang kotlin kt` in einem Scratch-Repo, danach
    `docker build --no-cache --target lint` → rc=0, `> Task :detekt`, `BUILD SUCCESSFUL in 48s`.
    Nach der Mutation aus Fall 621 (leere Funktion) → rc=1,
    `Main.kt:10:12: This empty block of code can be removed. [EmptyFunctionBlock]`,
    `Analysis failed with 1 weighted issues`. Die `test`-Stage bleibt unter derselben Mutation grün
    (rc=0): Das Rot kommt also aus detekt und nicht aus dem Compiler. Damit gilt der Zweig
    **detekt**; `ktlint` wird nicht gebraucht.
  - Bedingung: DoD verlangt „Sonden-Lauf in §7". §7 trägt nur `*bei Closure*`. Den Beleg nennt
    allein die Commit-Message von `17c80593`, und die wird nicht wieder gelesen. Die Werte oben
    sind der Eintrag.
- **2 — Fragment↔Stages-Test, rot gesehen; `blockedByLang("kotlin")` mit Kopplung: bestätigt.**
  `make mutate` (Kommando unten): `618-kotlin-stage-match -> TestKotlinCodeGateFragment_TargetsMatchStages rot`
  (Stage `AS test` umbenannt) · `619-kotlin-blocked-kopplung -> TestBlockedFragment_CoversAllGenProfiles rot`
  (kotlin-Eintrag gelöscht). Der Test iteriert über `gen.SupportedLangs()`, die Kopplung ist also
  echt. Exklusiv gebunden ist sie laut Review-Gegenprobe (`t.Skip`); nachgefahren habe ich das nicht.
- **3 — full-smoke-Stufen, Kopfzeilen, e2e-abdeckung, Laufzeit vorher/nachher: nicht bestätigt (Teil).**
  - Bestätigt: beide Stufen mit `e2e_abdeckung`-Kopfzeile (Log: „Abdeckung der Stufe ab Zeile 2702 …"
    und „… ab Zeile 2798 …"). `docs/user/e2e-abdeckung.md` führt Stufe 13 und 15. Byte-Gleichheit
    mit der Deklaration hält `test/e2e-abdeckung.bats` in `make gates`. 621 und 622 werden aus dem
    behaupteten Grund rot (siehe Mutationslauf).
  - Nicht bestätigt: Den Laufzeit-Zuwachs vorher/nachher hat niemand gemessen. Weder §7 noch die
    Commit-Messages noch der Review nennen eine Zahl. Mein eigener Lauf ist nur der Nachher-Wert,
    und auch der nur bei **warmem** Cache: `make full-smoke` → rc=0, **176 s**. Das Log zeigt
    `#10 [lint 1/1] RUN gradle --no-daemon detekt` / `#10 CACHED`, die Gradle-Schichten kamen aus
    einem früheren Lauf. Der Wert ist darum kein Zuwachs und keine Kalt-Messung. Die
    Mutationsläufe zeigen, wie viel eine Kotlin-Stufe ohne Cache-Treffer kostet: 621 102,26 s, 622
    65,01 s, der full-smoke-Grün-Vorlauf in der Kopie 204,01 s.
  - Offen für den Planner: Der Zuwachs muss nachgemessen werden (full-smoke an `2bb2b4f0` gegen
    `bbe8fc56`, beide kalt oder beide warm). Alternativ wird der Punkt ausdrücklich als nicht
    gemessen geschlossen. Das betrifft auch das Risiko 1 aus §6.
- **4 — Hilfetext nennt `kotlin` und `SKEL_KOTLIN_VERSION`: bestätigt.**
  `620-kotlin-hilfe-knopf -> TestUsage_NenntJedeSpracheUndIhrenKnopf rot`. Seit `bbe8fc56` prüft
  der Test die Sprache per Wortgrenzen-Regex (LOW-2). Eine Mutation „`go, ` gestrichen" habe ich
  für die neue Fassung nicht gefahren.
- **5 — `make gates` grün: bestätigt** auf dem Baum mit diesem Bericht, Lauf vor dem Commit
  (Ausgabe im Commit-Kontext; siehe Abschluss).
- **6 — Review durchgeführt, Report liegt vor: bestätigt** — `docs/reviews/2026-10-09-slice-kotlin-flaches-skelett.md`,
  Rolle Reviewer in `f05b8172`, eigener Kontext.
- **7–10 — Closure-Notiz, Register, Risiko-Ausgänge, Paarungen:** Planner-Arbeit, nicht
  Gegenstand dieser Verifikation (AGENTS.md §3.10). §6 und §7 tragen `*bei Closure*`.

## Kommandos und Ausgaben

```text
$ make full-smoke                      # rc=0, 176 s (warmer Cache, s. o.)
$ make mutate MUTATE_CASES='618-kotlin-stage-match 619-kotlin-blocked-kopplung 620-kotlin-hilfe-knopf 621-kotlin-skelett-lint-im-ziel 622-kotlin-gemischter-root'
mutate: ok      618-kotlin-stage-match          -> TestKotlinCodeGateFragment_TargetsMatchStages rot
mutate: ok      619-kotlin-blocked-kopplung     -> TestBlockedFragment_CoversAllGenProfiles rot
mutate: ok      620-kotlin-hilfe-knopf          -> TestUsage_NenntJedeSpracheUndIhrenKnopf rot
mutate: ok      621-kotlin-skelett-lint-im-ziel -> full-smoke: FEHLER — make gates nach add-lang kotlin ist NICHT Exit 0 (Kotlin-Gate kaputt). rot
mutate: ok      622-kotlin-gemischter-root      -> full-smoke: FEHLER — make test am gemischten Root mit Kotlin ohne Beleg fuer: [--target test -t kotlin:] — ein Kontext fiel heraus. rot
mutate: 5 ok, 0 Befund(e)                       # rc=0, 394 s
$ docker build --no-cache --target lint .       # Sonde, Scratch-Ziel aus add-lang kotlin: rc=0, BUILD SUCCESSFUL
$ docker build --target lint .                  # nach Mutation 621: rc=1, [EmptyFunctionBlock]
$ docker build --target test .                  # nach Mutation 621: rc=0
```

## Plan-vs-Code

- **Gebaut ohne Plan, aber im Plan nachgetragen:** In §3 stehen die Zeilen `main_test.go`,
  `gen_test.go`/`zeilenenden_test.go` und `test/mutations/` (54/56/306). Sie hat der Implementer
  selbst in `17c80593`/`bbe8fc56` eingetragen, nicht der Planner. Inhaltlich decken sie Tests und
  Fälle, keine Abnahme-Verschiebung. Die Form beanstandet der Review unter MEDIUM-1 (Klasse);
  übernehmen oder zurückweisen muss der Planner.
- **Im Code, im Plan nicht gefordert, ungemessen:** Die unscoped Root-Fassung
  (`add-lang kotlin .` an einem Root ohne andere Sprache, `IMAGE ?= app`) halten nur Go-Tests
  (`TestKotlinCodeGateFragment_RootUndSubdir`, 618). Kein E2E fährt sie real. Der Plan verlangt
  nur Mono-Repo und gemischten Root; das ist eine Grenze, kein DoD-Verstoß. `--lang kotlin` am
  Root ist ausdrücklich `slice-kotlin-root-bootstrap`.
- **Im Plan, im Code abweichend:** Am gemischten Root baut das Kotlin-Ziel das Go-Dockerfile
  (Review MEDIUM-2). Die Stufen-Kurzbeschreibung nennt die Grenze. Das emittierte Fragment und die
  Ausgabe von `add-lang` nennen sie nicht. Offen für den Planner, mit Ausgang bei der Closure.
- **Guard-Set:** `blocked/kotlin` führt zehn Werkzeuge, im Ziel gemessen ist allein `gradle build`.
  Die Kurzbeschreibung ist seit `bbe8fc56` auf diesen einen Aufruf eingeschränkt (LOW-1); die
  Zusage ist damit so breit wie ihr Sensor.
- **Handbuch:** Die Zeile `SKEL_KOTLIN_VERSION` ist zurückgenommen (MEDIUM-1). Das Handbuch nennt
  Kotlin nicht, wie es die Abgrenzung der Welle verlangt.

## Negativbefunde

- **ADR-0088 F1/F2/F4:** ein Modul, Pins per Tag/Version, kein Digest, kein Wrapper; `langArchs`
  kotlin = `flat`, und `TestGenerateArch_KotlinTraegtNurFlat` lehnt hexslice/hexagonal ohne
  Artefakte ab. Kein Befund.
- **LH-FA-06 (Guard je `--lang`):** Der Guard blockt `gradle build` im Ziel, die
  `blocked/kotlin`-Kopplung an die gen-Profile ist bewacht (619). Kein Befund.
- **Re-Evaluierungs-Trigger 2 von ADR-0088 / Rückführung `in-progress → open`:** nicht
  eingetreten, detekt läuft grün mit der gepinnten Version.

## Offene Punkte für Planner/Architect

1. DoD 3: Laufzeit-Zuwachs nachmessen oder als ungemessen schließen; daran hängt auch der Ausgang
   des §6-Risikos 1.
2. DoD 1: die Sonden-Werte oben in §7 übernehmen.
3. Review MEDIUM-2 (gemischter Root baut fremdes Dockerfile, im Ziel ungenannt) braucht einen
   Ausgang: Register-Eintrag, Folge-Slice oder Ablehnung.
4. Die §3-Zeilen des Implementers: übernehmen oder zurückweisen.
