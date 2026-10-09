# Review-Report: slice-kotlin-root-bootstrap — 2026-10-09

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (die DoD prüft der Verifier).

**Gegenstand:** Commit `12d6868d` (Implementer, Welle `welle-kotlin-skelett`).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

**Eingangs-Kontext:**

- Slice-Plan `slice-kotlin-root-bootstrap` (Stand `12d6868d`)
- [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Accepted)
- [`MR-089`](../../harness/conventions.md#mr-089), [`MR-051`](../../harness/conventions.md#mr-051)
- [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
  [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules)

**Summary:** 0 HIGH · 0 MEDIUM · 3 LOW · 2 INFO — Klassen: *Mutations-Fall dupliziert einen
bestehenden Wächter an derselben Quell-Stelle* · *Test-Kommentar zeigt auf eine nicht existierende
Stufe und sagt einer ungemessenen Variante Deckung zu* · *Zahl in der Commit-Message ohne das
Kommando, das genau sie ausgibt* · *Zahn ohne eigene Quell-Stelle* · *Zuwachs aus einem Lauf-Paar*.

## Findings

### LOW-1 — Fälle 626 und 627 binden nichts, was nicht schon ein bestehender Test allein bindet

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6; Skill §LOW/INFO mit Eskalation (Mutations-Fall nennt einen Test, die Mutation färbt mehrere)
- `pfad`: `test/mutations/626-kotlin-root-fragment-scoped.sh:3`, `test/mutations/627-kotlin-root-ohne-arch-gate.sh:3`
- `befund`: Beide Fälle sind grün im Sinne von `make mutate` (rot am benannten Test). Die Gegenprobe —
  Mutation angewandt, `t.Skip` ausschließlich in `TestRun_BootstrapKotlinRoot`, `make test-go` in
  einer Kopie — bleibt in beiden Fällen rot: 626 färbt `TestKotlinCodeGateFragment_RootUndSubdir`,
  627 färbt `TestArchGateConfig_OnlyLayered`, `…_CoversEveryLayeredCombo`, `…_KotlinMatchesSkeleton`,
  `…_KotlinEdgesMatchSkeleton`. Die Mutationen liegen in `internal/gen/`, die der Bestand schon
  allein bindet; was der neue Test Eigenes hält — die Verdrahtung des One-Shot in `cmd/` mit Pfad
  `.` für `kotlin` —, trifft keiner der beiden Fälle. Ein Bruch der `cmd/`-Verdrahtung für
  `kotlin` bliebe ohne Fall.
- `verifizierbar`: ja — Gegenprobe wie oben
- `klasse`: Mutations-Fall dupliziert einen bestehenden Wächter an derselben Quell-Stelle

### LOW-2 — Der Kopf von `TestRun_BootstrapKotlinRoot` nennt eine Stufe, die es nicht gibt, und sagt der flachen Variante einen Gate-Lauf zu

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7 (Zusage)
- `pfad`: `cmd/ai-harness-init/main_test.go:389`
- `befund`: Der Kommentar verweist für den Gate-Lauf auf die full-smoke-Stufe „Kotlin als One-Shot am
  Root“; `grep -rn 'Kotlin als One-Shot am Root' harness/` findet nichts, die Stufe heißt
  „Root-Bootstrap (--lang kotlin --arch hexslice)“. Der Satz gilt für beide Varianten des Tests;
  die Stufe fährt nur `hexslice`, `--lang kotlin` ohne `--arch` am Root fährt kein E2E (die
  Stufen-Kopfzeile sagt das selbst: „NICHT gemessen: --lang kotlin ohne --arch am Root“).
- `verifizierbar`: nein
- `klasse`: Test-Kommentar zeigt auf eine nicht existierende Stufe und sagt einer ungemessenen Variante Deckung zu

### LOW-3 — Die Laufzeit-Zahlen der Commit-Message nennen das Kommando nicht, das sie ausgibt

- `kategorie`: LOW
- `quelle`: [`MR-051`](../../harness/conventions.md#mr-051) Setzung 1
- `pfad`: Commit-Message `12d6868d`, Zeile „Laufzeit (MR-089)“
- `befund`: „210,95 s ohne gegen 250,55 s mit der Stufe“ — `make full-smoke` gibt keine
  Gesamtdauer aus (`grep -n 'SECONDS' harness/tools/full-smoke.sh` nennt nur die zwei
  Stufen-Timer, ganzzahlig); die Zahlen mit zwei Nachkommastellen stammen aus einem ungenannten
  äußeren Zeitmesser, und wie der Lauf „ohne“ die Stufe hergestellt wurde, steht nicht da. Die
  Lage- und Varianten-Angaben aus [`MR-089`](../../harness/conventions.md#mr-089) (Images lokal,
  Basis-Cache warm, Gradle-Auflösung je Lauf, Variante `hexslice`, flat ungemessen) sind
  vollständig.
- `verifizierbar`: nein
- `klasse`: Zahl in der Commit-Message ohne das Kommando, das genau sie ausgibt

### INFO-1 — Der Arch-Zahn der Root-Stufe hat keine eigene Quell-Stelle

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `harness/tools/full-smoke.sh:3283`
- `befund`: Die Root-Stufe hält allein: die unscoped Gradle-Ziele mit Kontext `.` (gebunden durch
  Fall 628, hier nicht nachgefahren — Netz) und das Zusammenspiel Kotlin-Config × Root-Mount.
  Für Letzteres gibt es keine kotlin-eigene Root-Stelle: die `.a-check.yml` ist konstant
  (`archGateConfigs()` in `internal/gen/arch.go:152`), der Root-Zweig des Arch-Fragments in
  `internal/emit/archgate.go:78`/`:114` ist sprach-agnostisch und am cpp-Root schon gefahren. Jede
  Mutation der Kotlin-Config bricht zuerst die Subdir-Stufe (`full-smoke.sh:3085`). Die
  Stufen-Kopfzeile sagt nicht mehr zu als gemessen: rot mit `core-impurity` an `Greeting.kt:4`,
  übrige Richtungs-Regeln und flat ausdrücklich „NICHT gemessen“. Kein Befund über die Zusage.
- `verifizierbar`: nein
- `klasse`: Zahn ohne eigene Quell-Stelle

### INFO-2 — Der Zuwachs +39,6 s ist die Differenz eines Lauf-Paars

- `kategorie`: INFO
- `quelle`: [`MR-089`](../../harness/conventions.md#mr-089)
- `pfad`: Commit-Message `12d6868d`
- `befund`: Die Differenz zweier Einzelläufe der ganzen Suite trägt deren Streuung mit; die Stufe
  druckt ihre eigene Dauer (`full-smoke.sh:3298`), die Message nennt sie nicht. Die
  Gradle-Auflösung je Lauf steckt in der Zahl und ist als Lage benannt — die Zahl ist ein
  Warm-Basis-Wert dieser Variante, kein Kalt-Wert.
- `verifizierbar`: nein
- `klasse`: Zuwachs aus einem Lauf-Paar

## Negativbefunde (geprüft, ohne Befund)

- **Plan-Änderung §3 (AGENTS.md §3.10):** Der Implementer erweitert die Begründung der Zeile
  `cmd/`/`internal/gen/`; Änderungs-Art bleibt `update`. §3.10 bindet DoD, Closure-Trigger und
  Out-of-Scope-Grenze — §3 ist keines davon, und `modul-09-implementierung.md` Z. 81–84 weist das
  Fortschreiben von §3 dem Implementer zu („Plan verfeinern“). Keine Abnahme verschoben; die
  Rückführung `in-progress → next` (Verzweigung außerhalb `internal/gen/`) ist nicht eingetreten.
- **Mutationsfälle 626/627 auf der realen Verdrahtung:** `make mutate MUTATE_CASES='626-kotlin-root-fragment-scoped 627-kotlin-root-ohne-arch-gate'`
  → `2 ok, 0 Befund(e)`; beide `sed`-Anker treffen (`internal/gen/kotlin.go:75`, `internal/gen/arch.go:152`).
  Fall 628 trifft dieselbe Zeile; die gemischte Root-Stufe (`full-smoke.sh:2802`) läuft über
  `kotlinFragmentMixed` und fängt die Mutation nicht vorher ab — der Kopf „kein früherer Abschnitt“
  hält.
- **`kennungen_test.go`:** die Varianten `kotlin-flat`/`kotlin-hexslice` laufen über die reale
  Emission in dieselbe beidseitige Gleichheits-Prüfung; der Doc-Kommentar zählt die Varianten
  („go und cpp je Layout“) ohne Kotlin auf — sagt weniger zu, als der Test hält, kein Befund.
- **ADR-0088:** Root-Fragment unscoped mit Kontext `.`, Config modul-relativ am Root, Arch-Gate nur
  bei `hexslice` — Test und Stufe prüfen genau das; kein Widerspruch.
- **Hard Rules §3.1/§3.2/§3.3/§3.5/§3.9:** keine neue Make-Zeile, keine Suppression, kein Move,
  keine Lockerung, keine Host-Toolchain im Diff.
- **full-smoke-Mechanik:** neues tmp-Repo in `cleanup`, `chmod 755` gesetzt, Rück-Kopie der
  mutierten `Greeting.kt` vor der Auswertung.
