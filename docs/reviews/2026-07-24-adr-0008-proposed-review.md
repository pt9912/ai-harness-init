# Review — ADR-0008 (Proposed): Architektur-Achse (`--arch`) für das emittierte Skelett

**Datum:** 2026-07-24 ·
**Reviewer:** unabhängig (frischer Kontext, kein Selbst-Review) ·
**Rolle:** Modul 10 (Review) + Modul 4 (ADR-Review, Proposed-Runde) ·
**Gegenstand:** `docs/plan/adr/0008-arch-achse-emittiertes-skelett.md` (Status Proposed)

## Eingangs-Kontext (Pflicht)

- **Gegenstand:** Architektur-ADR (kein Code-Diff) — geprüft auf innere Konsistenz,
  Konsistenz mit bindenden Quellen und **Wahrheit gegen den Ist-Code**.
- **Betroffene `LH-*`:** [`LH-FA-07`](../../spec/lastenheft.md) (arch-Gate), [`LH-FA-04`](../../spec/lastenheft.md) (Skelett-Generator),
  [`LH-FA-01`](../../spec/lastenheft.md) (Bootstrap), [`LH-QA-01`](../../spec/lastenheft.md) (keine halluzinierten Gates), [`LH-QA-02`](../../spec/lastenheft.md) (Reproduzierbarkeit).
- **Referenzierte aktive ADRs:** ADR-0003, ADR-0005, **ADR-0007** (Bootstrap-Phasen / Idempotenz-Klassifikation).
- **Hard Rules:** AGENTS.md §3 (insb. §3.4 ADRs immutable, §3.5 Gate-Lockerung nur per ADR, §3.6 keine Zusage ohne rot gesehenes Gegenbeispiel).
- **Vorherige Findings gleicher Klasse:** ADR-0007 Review-1 **H2** — eine ADR-Tatsachenbehauptung („Durchsetzung sprach-agnostisch") war gegen den Ist-Code (Guard per `--lang`) **falsch**. Diese Klasse (Ist-Behauptung vs. Code) ist der Prüf-Schwerpunkt hier.

---

## Findings

### MEDIUM-1 — a-check als „reales, gepinntes Tool mit `--print-mk` (wie d-check)" ist im Repo nicht belegt (H2-Klasse)

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-02` / Hard Rule §3.6 (Zusage vs. Beleg); ADR-0007-H2-Klasse
- **pfad:** ADR-0008 Kontext (Z. 19–21) + Tragende Annahme 1 (Z. 51–52)
- **befund:** Der ADR behauptet als **Ist-Tatsache**: „a-check ist ein **reales Schwester-Tool** … prüft hexagonale Schichten" (Kontext) und „a-check ist ein **reales, gepinntes Tool** mit `--print-mk` (wie d-check)" (Annahme 1). Gegen den Code trägt der Vergleich „wie d-check" nicht: d-check ist voll belegt — `DefaultImage`/`DefaultDigest` gepinnt (`internal/emit/emit.go:30-31`), `d-check.mk`, realer `docker run <ref> --print-mk`-Aufruf (`internal/emit/emit.go:152`), MR-010/011/012. a-check erscheint **ausschließlich** als Kommentar-Referenz im `Dockerfile`-Kopf auf ein Schwester-Repo (`Dockerfile:2,7`); es gibt **kein** ACHECK-Image, **keinen** Digest-Pin, **kein** `a-check.mk`, **keinen** `a-check --print-mk`-Aufruf. Das Wort „gepinntes … wie d-check" schreibt a-check eine Reife/Pin-Existenz zu, die der Ist-Stand nicht hergibt — genau die H2-Klasse (Ist-Behauptung übersteigt den Code). Der ADR hedged korrekt, indem er es unter „Tragende Annahmen (kippen sie, kippt die Entscheidung)" führt und einen Re-Eval-Trigger setzt — aber die Kontext-Aussage steht als flache Tatsache.
- **Failure-Szenario:** Der implementierende Slice nimmt „`a-check --print-mk`, Image digest-gepinnt" (Entscheidung 3) als gegeben und plant den Emitter analog `emit.DocGate` — und stellt erst im Slice fest, dass es kein gepinntes a-check-Image/`--print-mk` gibt (anders als d-check, das v0.51.1@sha256 real hat). Der behauptete „reale Prüfbereich" (Konsequenz) hängt an einem Tool, dessen `--print-mk`-Vertrag im Repo nirgends verifiziert ist.
- **verifizierbar:** ja — `grep -rni "acheck\|a-check.mk\|ACHECK_IMAGE\|a-check --print-mk"` über `internal/`, `Makefile`, `*.sh` liefert **keinen** Treffer außer dem Dockerfile-Kommentar; d-check dagegen ist voll gepinnt.

### MEDIUM-2 — Kompositions-Modell (`lang-renderer × arch-layout`) lässt die arch-unabhängige, sprach-spezifische Bau-Gerüstung unverortet; `flat` = „eine Rolle: Entry-Point → main.go" mischarakterisiert das heutige Flach-Profil

- **kategorie:** MEDIUM
- **quelle:** `LH-FA-04` / `LH-QA-01` (out-of-the-box `make gates` grün); Tragende Annahme 2
- **pfad:** ADR-0008 Entscheidung 2 (Z. 69–74) + Annahme 2 (Z. 53–54)
- **befund:** Der ADR modelliert die Komposition als „**Arch-Schicht** liefert das Layout (welche Verzeichnisse + welche **Datei-Rollen** je Schicht); die **Sprach-Schicht rendert die Dateien je Rolle**" und setzt `flat` = „das degenerierte Layout (**eine** Rolle: ‚Entry-Point' → `main.go`/`src/main.cpp` wie heute)". Gegen den Ist-Generator trägt das nicht sauber: das heutige `flat`-Profil ist **kein** Ein-Datei-Entry-Point. `goProfile` (`internal/gen/golang.go:29-36`) emittiert 4 Dateien (`go.mod`, `Dockerfile`, `.golangci.yml`, `cmd/app/main.go`); `cppProfile` (`internal/gen/cpp.go:19-28`) emittiert 6 (`CMakeLists.txt`, `src/main.cpp`, `tests/CMakeLists.txt`, `tests/test_main.cpp`, `.clang-tidy`, `Dockerfile`). Der Großteil davon (Dockerfile-Stages, Manifest, Linter-Config, Tests) ist **sprach-spezifisch, aber arch-agnostisch** — es ist keine „Rolle" der hexagonalen Schichtung. Das Modell „Sprach-Renderer rendert *je Rolle*" verortet diese Bau-Gerüstung nirgends.
- **Failure-Szenario:** Ein implementierender Slice, der Entscheidung 2 wörtlich nimmt (flat = eine Entry-Point-Rolle), lässt die arch-agnostische Gerüstung fallen — das emittierte `flat`-Skelett trägt dann kein `Dockerfile`/`go.mod`/`.golangci.yml`/Tests mehr → `make gates` am flat-Ziel bricht (keine Dockerfile-Stages `--target test/lint/build`, an denen das Code-Gate-Fragment hängt). Der ADR beteuert „`flat` … wie heute" (Intent korrekt), aber die beschriebene **Mechanik** deckt diesen Intent nicht — das ist genau die tragende Annahme 2, deren Machbarkeit gegen den Ist-Generator zu prüfen war.
- **verifizierbar:** ja — `go test ./internal/gen/...` (Byte-Identität des flat-Profils) + `make full-smoke` (flat-Ziel `make gates` grün) würden eine wörtliche Ein-Rollen-Reduktion rot färben.

### LOW-1 — `add-lang`-Parser weist `-`-präfigierte Argumente heute hart ab; `--arch` ist keine additive Ergänzung, sondern ein Parser-Umbau — als CLI-Oberflächen-Kosten nicht benannt

- **kategorie:** LOW
- **quelle:** Maintainability / Konsequenz-Vollständigkeit
- **pfad:** ADR-0008 Entscheidung 1 (Z. 63–68) vs. `cmd/ai-harness-init/main.go:130`
- **befund:** Der ADR reiht `--arch` „parallel zu `--lang`/`add-lang`" ein: `add-lang <sprache> <pfad> [--arch <arch>]`. Der Ist-`runAddLang` trägt **keinerlei** Flag-Parsing — „Genau zwei Positionsargumente, keine Flags" (`main.go:124`) — und **verwirft** aktiv jedes `-`-präfigierte Argument: `len(args) != 2 || strings.HasPrefix(args[0], "-") || strings.HasPrefix(args[1], "-")` → Exit 2 (`main.go:130`). `--arch` an `add-lang` verlangt also einen echten Parser-Umbau (FlagSet nach der Positions-Extraktion), nicht das „Einreihen" eines vorhandenen Flags. ADR-0007 hat die analoge CLI-Oberflächen-Kosten (`add-lang`) unter Konsequenzen/Contra explizit benannt; ADR-0008 nennt „mehr Struktur" nur für den Generator, nicht für die `add-lang`-CLI.
- **Failure-Szenario:** Keine funktionale Fehlfunktion — Konsequenz-Untererfassung: der Wellen-Aufwand für `add-lang`-Parsing fehlt in der Slice-Planung.
- **verifizierbar:** ja — `go test ./cmd/...` (ein `add-lang go . --arch hexagonal`-Aufruf liefert heute Exit 2).

### INFO-1 — Idempotenz-Klassen (Entscheidung 5) sind konsistent mit ADR-0007 — bestätigt

- **kategorie:** INFO
- **quelle:** ADR-0007 Entscheidung 3 (Klassifikations-Tabelle)
- **pfad:** ADR-0008 Entscheidung 5 (Z. 85–89)
- **befund:** Die Zuordnung ist widerspruchsfrei zur ADR-0007-Tabelle: Schicht-**Code** (`domain/ports/adapters`) = **skip-if-present** (parallel zu `main.go`/adopter-editierbarem Skelett-Code, ADR-0007 Z. 102); `a-check.mk` + Aggregator-Anschluss = **konvergent** (parallel zu `d-check.mk`/`harness/mk/*.mk`, ADR-0007 Z. 100); `.a-check.yml` = **skip-if-present** „wie `.d-check.yml`" — und `.d-check.yml` steht in ADR-0007 tatsächlich in der skip-if-present-Zeile (Z. 101). Keine Fehl-Klasse. Dokumentiert als bestätigter Negativbefund.

---

## Negativbefunde (geprüft, ohne Befund)

- **Ist-Behauptungen gegen den Code (H2-Schwerpunkt):** „`internal/{emit,fetch,gen,wire}` flach" — **wahr** (`ls internal/` = emit/fetch/gen/wire). „`profiles()` mappt `lang → func(version) → {relpfad:inhalt}`" — **wahr** (`internal/gen/gen.go:82-87`). „`--lang` optional / `add-lang` existiert" — **wahr** (`main.go:88`, `main.go:81`). „`.d-check.yml` skip-if-present, `d-check.mk` konvergent" — **wahr** (ADR-0007 Z. 100/101). Einzige nicht-belegte Ist-Behauptung → **MEDIUM-1** (a-check-Pin/`--print-mk`).
- **a-check-Konditionalität ([`LH-QA-01`](../../spec/lastenheft.md)):** Entscheidung 3 emittiert a-check **genau dann**, wenn das Layout schichten-tragend (`hexagonal`) ist; `flat` → kein a-check, `make gates` grün. Deckt sich mit LH-FA-07s Negative-AC („trägt das Skelett keine hexagonalen Schichten, wird das Gate begründet nicht emittiert"). Fitness Function koppelt Arch-Wert ↔ a-check-Präsenz mit rot-färbendem Gegenbeispiel bei Fehl-Emission (beide Richtungen). Kein halluziniertes-Gate-Pfad gefunden.
- **Achsen-Trennung `--arch` ⟂ `--lang`:** Analogie zu ADR-0007 (`--lang` optional / `add-lang` wiederholbar, per-Modul) ist sauber; `--arch flat`-Default hält Rückwärtskompatibilität konzeptionell (mechanischer Vorbehalt → MEDIUM-2/LOW-1). Widerspruchsfrei zum bestehenden per-Modul-Mono-Repo-Vertrag.
- **Alternativen (A/B/C/D):** fair verglichen — A (N×M-Profile) und B (Arch in Profile backen) tragen beide die genannten Contra (Kombinatorik / nicht wählbar / quer-schneidend dupliziert); C (nichts tun) ehrlich als „LH-FA-07 dauerhaft offen, M4 unerreichbar". Keine offensichtlich fehlende Alternative.
- **Konsequenzen-Ehrlichkeit:** Der Negativteil benennt Kompositions-Schicht-Aufwand, den `profiles()`-**Migrations-Bruch** („kein rein additiver Schritt"), je-Sprache-Renderer-Aufwand und die fehlende Dogfood-Parität. Ehrlich; die einzige unbenannte Konsequenz ist die `add-lang`-Parser-Kosten (LOW-1) und die Gerüstungs-Verortung (MEDIUM-2).
- **Folgepflicht:** CR an lastenheft (LH-FA-04 Arch-Achse, LH-FA-07 Happy-Path), architecture.md-Nachzug, Fitness Functions, Welle „Arch-Achse" — deckt die von der Entscheidung ausgelösten Nachzüge.
- **Hard Rule §3.5:** a-check wird über **diese ADR** aktiviert (das korrekte Vehikel), nicht per PR-Kommentar; LH-QA-01 bleibt durch die konditionale Emission gewahrt. §3.4: korrekt Proposed mit Immutable-Fußnote. Kein Verstoß.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 | MEDIUM-1 (a-check-Pin/`--print-mk` unbelegt), MEDIUM-2 (Kompositions-Modell verortet Bau-Gerüstung nicht / `flat`-Mischarakterisierung) |
| LOW | 1 | LOW-1 (`add-lang`-Parser weist Flags ab) |
| INFO | 1 | INFO-1 (Idempotenz-Klassen konsistent — bestätigt) |

## Verdikt

**Richtung tragfähig; zwei MEDIUM vor Accept auszuräumen.** Die Achsen-Trennung `--arch` ⟂ `--lang`,
die konditionale a-check-Emission (LH-QA-01-wasserdicht) und die Idempotenz-Klassifikation
(konsistent mit ADR-0007) sind sauber. Zwei MEDIUM sind vor dem §3.4-Freeze zu adressieren —
beide sind die ADR-0007-H2-Klasse (Ist-Behauptung übersteigt den belegbaren Code):

1. **MEDIUM-1:** „a-check … gepinntes Tool mit `--print-mk` **wie d-check**" als flache Ist-Tatsache
   entschärfen — im Repo ist a-check nur eine Dockerfile-Kopf-Referenz (kein Pin, kein `.mk`, kein
   `--print-mk`), während d-check voll belegt ist. Empfehlung: Kontext/Annahme-1 als **zu belegende
   Vorbedingung** formulieren (a-check-Image/Digest + `--print-mk`-Vertrag beim implementierenden Slice
   nachweisen, analog dem d-check-Pin), statt „wie d-check" als erreichte Parität zu behaupten.
2. **MEDIUM-2:** Das Kompositions-Modell (Entscheidung 2) muss verorten, wo die **sprach-spezifische,
   arch-agnostische Bau-Gerüstung** (`Dockerfile`-Stages, `go.mod`/`CMakeLists.txt`, Linter-Config,
   Tests) im `lang-renderer × arch-layout`-Schema lebt — sie ist keine hexagonale „Rolle". Empfehlung:
   `flat` nicht als „eine Rolle: Entry-Point → `main.go`" beschreiben (das Ist-`flat`-Profil sind 4–6
   Dateien inkl. voller Docker-Bau-Kette), sondern klarstellen, dass der Sprach-Renderer immer sein
   arch-unabhängiges Gerüst emittiert **plus** die layout-getriebenen Schicht-Dateien.

LOW-1 (add-lang-Parser-Umbau als CLI-Oberflächen-Kosten benennen) ist nice-to-fix. Keine HIGH; kein
Verstoß gegen aktive ADR oder Hard Rule; kein halluziniertes Gate.
