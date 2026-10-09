# Review-Report: slice-kotlin-hexslice-mit-arch-gate — 2026-10-09

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (die DoD prüft der Verifier).

**Gegenstand:** Commit `9d1b0837` (Implementer, Welle `welle-kotlin-skelett`).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · **Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

**Eingangs-Kontext:**

- Slice-Plan `slice-kotlin-hexslice-mit-arch-gate` (Stand `9d1b0837`)
- [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Accepted),
  [ADR-0062](../plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) (Accepted)
- [`MR-089`](../../harness/conventions.md#mr-089)
- [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
  [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules)

**Summary:** 0 HIGH · 0 MEDIUM · 2 LOW · 3 INFO — Klassen: *Spec-Absatz geht über den Nachzug
hinaus, den die Quelle anweist* · *Spec-Stratum widerspricht sich nach Nachzug* · *Nachbau einer
fremden Auflösung nennt seinen realen Halter nicht* · *gemessene Spanne ist nicht der benannte
Zuwachs* · *Import-Muster des Nachbaus erfasst nur die einfache Form*.

## Findings

### LOW-1 — Der Spec-Absatz geht über den angewiesenen Kotlin-Nachzug hinaus

- `kategorie`: LOW
- `quelle`: [ADR-0062](../plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) Festlegung 2 und 3; [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) §Konsequenzen, Folgepflicht
- `pfad`: `spec/architecture.md:226`
- `befund`: Die schreibende Rolle für die Spec-Straten ist nach ADR-0062 §„Was hier NICHT entschieden
  ist“ offen (`slice-151-spec-straten-haben-eine-schreibende-rolle` liegt in `open/`). Für den
  Kotlin-Teil greift die Ausnahme aus Festlegung 2: eine bestehende Quelle trägt die Antwort.
  ADR-0088 weist den Nachzug „im hexslice-Slice“ an, der Plan führt ihn in §3, und der Commit nennt
  die Quelle. Ein Abschnitt „Layout je Sprache“ bestand vor dem Commit aber nicht
  (`git show 9d1b0837^:spec/architecture.md | grep -c 'Layout je Sprache'` → 0). Der Absatz legt ihn
  neu an und setzt dabei Aussagen über `go` und `cpp` (Layout-Menge, Verzeichnisse,
  Composition Root, Exit 2). Diese Aussagen deckt die Folgepflicht nicht, die nur Kotlin betrifft.
  Für diesen Teil wurde die Eigentums-Frage im laufenden Vorgang beantwortet. Inhaltlich decken
  sich die Aussagen mit `langArchs()` in `internal/gen/gen.go`.
- `verifizierbar`: nein — Rollen-Zuordnung liest kein Gate (ADR-0062 §Fitness Function)
- `klasse`: Spec-Absatz geht über den Nachzug hinaus, den die Quelle anweist

### LOW-2 — ARC-009 widerspricht dem neuen Absatz im selben Stratum

- `kategorie`: LOW
- `quelle`: Maintainability (Spec-Konsistenz, Rang 3)
- `pfad`: `spec/architecture.md:97` gegen `spec/architecture.md:226`
- `befund`: Die ARC-009-Zeile legt `hexslice` sprachübergreifend auf „Composition Root `cmd/`“ fest.
  Der neue Absatz nennt für `cpp` `src/main.cpp` und für `kotlin` `src/main/kotlin/app/Main.kt`.
  Für `cpp` bestand die Drift schon vorher, der Diff dehnt sie auf eine zweite Sprache aus. Ein
  Leser von ARC-009 erwartet bei Kotlin ein `cmd/`, das der Renderer nicht anlegt.
- `verifizierbar`: nein
- `klasse`: Spec-Stratum widerspricht sich nach Nachzug

### INFO-1 — `TestArchGateConfig_KotlinEdgesMatchSkeleton` baut die a-check-Auflösung nach und nennt seinen realen Halter nicht

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Fixture gegen reale Quelle)
- `pfad`: `internal/gen/kotlin_test.go:305`
- `befund`: Der Test löst Importe selbst auf: `package_base` abstreifen, Punkte zu `/`, Root voran.
  Seine Zusage „so … wie a-check es … tut“ hält er nicht selbst. Sie hält die full-smoke-Stufe über
  die Abwesenheit von „Import-Symbolen“, und das nennt der Testkopf nicht. Gegen die reale Quelle
  geprüft, ohne Abweichung: a-check `v0.23.0` über dem erzeugten Skelett. Mit der HEAD-Config
  liefert der Lauf 0 Befunde ohne Hinweis. Mit dem Root aus Fall 624 meldet er vier Hinweise
  „0 von N Import-Symbolen“, also hat die Abwesenheits-Prüfung der Stufe Zähne. Ohne die Kante
  `driven_adapters→ports_outbound` kommt `wrong-direction: 2`, die Kante ist also erforderlich und
  passt zu ADR-0088 und zu `spec/architecture.md` (Vererbungs-Erfüllung). Ein Bruch an der realen
  Quelle (Pin-Sprung mit anderer Auflösung) färbt nur `make full-smoke`, kein Gate.
- `verifizierbar`: ja — `make full-smoke`
- `klasse`: Nachbau einer fremden Auflösung nennt seinen realen Halter nicht

### INFO-2 — Die gemessene Spanne der Stufe ist nicht der Kotlin-Zuwachs

- `kategorie`: INFO (Verifier/Planner, DoD-Punkt 2 und §7)
- `quelle`: [`MR-089`](../../harness/conventions.md#mr-089)
- `pfad`: `harness/tools/full-smoke.sh:3138`
- `befund`: Die Zeitspanne `kthex_start` umfasst `make -j gates` über `tmprepo_doc` mit allen vorher
  hinzugefügten Modulen (`apps/api`, `apps/web`, `apps/engine`, `apps/kt`, `apps/hex`,
  `apps/cpphex`) und nicht nur über `apps/kthex`. Die Ausgabezeile nennt die Variante und den Umfang
  („samt add-lang und Arch-Zahn“). Image- und Cache-Lage nennt sie nicht, denn ein Laufprotokoll ist
  kein Artefakt im Geltungsbereich von MR-089. Die Zahl, die §7 daraus übernimmt, trägt MR-089 erst
  dort. Liest man sie als „Zuwachs“, nennt sie mehr, als die Spanne misst.
- `verifizierbar`: nein
- `klasse`: gemessene Spanne ist nicht der benannte Zuwachs

### INFO-3 — Das Import-Muster des Nachbaus erfasst nur `import app.X.Y`

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `internal/gen/kotlin_test.go` (`importRe`)
- `befund`: `^import (app\.[A-Za-z.]+)$` überspringt `import app.x.*`, `import app.x.Y as Z` und
  Zeilen mit Nachsatz stumm. Am heutigen Skelett ist das folgenlos, weil jede deklarierte Kante
  gebraucht wird und eine leere Treffermenge den Test färbt. Nutzt eine Renderer-Änderung eine
  dieser Formen, fällt der Import aus der Prüfung „jeder Import hat seine Kante“. Gefahren:
  einfache Form (Skelett) · gelesen, nicht gefahren: Wildcard, Alias.
- `verifizierbar`: ja — eine Alias-Zeile im Renderer
- `klasse`: Import-Muster des Nachbaus erfasst nur die einfache Form

## Belege

```text
$ make mutate MUTATE_CASES='623-kotlin-hexslice-paket-verzeichnis 624-kotlin-arch-root-ohne-package-base'
mutate: ok      623-kotlin-hexslice-paket-verzeichnis      -> TestKotlinHexslice_PaketGleichVerzeichnis rot
mutate: ok      624-kotlin-arch-root-ohne-package-base     -> TestArchGateConfig_KotlinEdgesMatchSkeleton rot
mutate: 2 ok, 0 Befund(e)
```

Gegenprobe zu beiden Fällen (je Klon unter dem Scratchpad: Mutation angewandt, `t.Skip` **nur** im
benannten Test, `make test-go`): bei beiden grün mit Exit 0. Damit bindet der benannte Test jeweils
allein, und es gibt keinen Mitfärber.

Fall 625 (`role: domain` → `role: app`): Statt `make full-smoke` lief der mutierte Host-Träger
`add-lang kotlin apps/kthex --arch hexslice` und danach a-check `v0.23.0` direkt. Der grüne Lauf
blieb grün mit 0 Befunden. Der Zahn meldet
`Greeting.kt:4: app-impurity: Application importiert app.adapters.driven.notify.StdoutNotifier`,
also schlägt der `core-impurity`-Vergleich der Stufe fehl und gibt die `# expect:`-Meldung aus. Die
unmutierte Config färbt dieselbe Stelle mit
`Greeting.kt:4: core-impurity: Kern importiert app.adapters.driven.notify.StdoutNotifier`. Diese
Zeile prüft die Stufe byte-genau.

## Geprüft, ohne Befund

- **Referenz-Richtung im neuen Spec-Absatz:** kein Verweis auf eine ADR, einen Slice oder einen MR,
  nur a-check als Werkzeug.
- **Plan-Deckung:** Die drei Zeilen aus §3 (Renderer und `arch.go`, full-smoke und Sicht,
  `spec/architecture.md`) decken die elf Dateien des Diffs. Der Seam in `arch.go` bekommt nur einen
  Map-Eintrag, kein Umbau, also greift die Rückführung aus §4 nicht.
- **ADR-0088 Festlegung 4:** Pfade, `resolution`-Block (`fixed-root`, Root `src/main/kotlin/app`,
  `package_base` `app`), Composition Root `Main.kt`, kein `hexagonal` (Test
  `TestGenerateArch_KotlinOhneHexagonal`, OnlyLayered-Zeile).
- **Kanten-Menge gegen ADR-0088:** Die ADR legt keine Kanten fest. `driven_adapters→ports_outbound`
  folgt der Erfüllungs-Regel aus `spec/architecture.md` und ist an a-check real als erforderlich
  gemessen (INFO-1).
- **full-smoke-Kurzbeschreibung:** nennt, was die Stufe misst (Ablage, `make gates` grün, Abwesenheit
  des Hinweises, Rot mit `core-impurity` an der Datei). Die NICHT-gemessen-Liste nennt die übrigen
  Richtungs-Regeln und das Paket außerhalb seines Verzeichnisses. Keine Abdeckungs-Aussage über
  das hinaus.
- **Hard Rules §3.2/§3.5/§3.7:** keine Inline-Suppression, keine Gate-Lockerung, die neuen Kommentare
  tragen Zusage, Kopplung oder Grenze. Die Herkunft `slice-045a-Review INFO-1` in `gen.go` ist
  Bestand, den der Diff nicht angefasst hat.
- **Mutations-Fälle 623–625:** treffen die Quelle, die der Renderer emittiert (`internal/gen/kotlin.go`),
  nicht einen nachgebauten Stellvertreter.
