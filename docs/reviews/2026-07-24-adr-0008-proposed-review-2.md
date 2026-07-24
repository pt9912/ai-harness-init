# Review 2 — ADR-0008 (Proposed, überarbeitet): Architektur-Achse (`--arch`)

**Datum:** 2026-07-24 ·
**Reviewer:** unabhängig (frischer Kontext, kein Selbst-Review) ·
**Rolle:** Modul 10 (Review) + Modul 4 (ADR-Review, **2. Proposed-Runde**) ·
**Gegenstand:** `docs/plan/adr/0008-arch-achse-emittiertes-skelett.md` (Status Proposed, nach 1. Review überarbeitet) ·
**Fokus (ADR-0007-Doppel-Lehre):** fix-induzierte Regressionen + neue Widersprüche in der überarbeiteten Fassung — nicht bestätigen, sondern nach dem suchen, was die Fixes kaputt/übersehen haben.

## Eingangs-Kontext

- **Runde 1** fand 2× MEDIUM + 1× LOW + 1× INFO (keine HIGH). Prüf-Schwerpunkt Runde 2: haben M-1/M-2/LOW-1 die Befunde **wirklich** aufgelöst (nicht nur umformuliert), und hat die Überarbeitung eine neue Ist-Behauptung / einen toten Verweis / einen internen Widerspruch eingeführt?
- **Ist-Code gelesen:** `internal/gen/golang.go` (`goProfile` = 4 Dateien: `go.mod`, `Dockerfile`, `.golangci.yml`, `cmd/app/main.go`), `internal/gen/cpp.go` (`cppProfile` = 6 Dateien), `internal/gen/gen.go` (`profiles()`), `cmd/ai-harness-init/main.go` (`runAddLang` Z. 130).
- **Spec-Anker geprüft:** `spec/lastenheft.md` LH-FA-07 (Z. 136–152), LH-FA-04 (Z. 76).
- **a-check-Ist-Stand geprüft:** `grep -rni a-check` → **nur** `Dockerfile:2,7` + `Makefile:12` (Kommentare). Kein Image-Pin, kein `a-check.mk`, kein `--print-mk`-Aufruf. Bestätigt die Grundlage von M-1.

---

## Prüfung der Runde-1-Fixes

### M-1 (a-check „reales Tool wie d-check" → Vorbedingung) — **AUFGELÖST**

Durchgängig als **zu erfüllende Vorbedingung** geführt, nicht als Ist-Tatsache:

- **Kontext (Z. 20–24):** „a-check ist als **Schwester-Tool avisiert** … **anders als d-check** ist es im Repo aber **noch nicht integriert** — kein gepinntes Image, kein `a-check --print-mk`-Aufruf, kein `a-check.mk`. Seine reale Verfügbarkeit + Pin + `--print-mk` sind eine **zu erfüllende Vorbedingung** … **keine erreichte Parität**." Exakt der geforderte Ton; deckt sich mit dem Ist-Grep (nur Dockerfile/Makefile-Kommentar).
- **Annahme 1 (Z. 54–58):** „**Heute nicht erfüllt** (nur Dockerfile-Kopf-Referenz); die Umsetzungs-Welle beginnt mit dem Beleg (Image + Digest + realer `--print-mk`-Lauf). Kippt die Verfügbarkeit, ist die a-check-**Emission** blockiert (nicht die `--arch`-Achse selbst …)." Sauber entkoppelt.

**Rest-Widerspruch-Check (vom Auftrag explizit verlangt):** Entscheidung 3 (Z. 89–93) sagt weiterhin „`a-check.mk` (aus `a-check --print-mk`, **Image digest-gepinnt**)". Das ist **kein** Rest-Widerspruch: es beschreibt die **Ziel-Emissions-Mechanik**, und die Formulierung spiegelt **verbatim das LH-FA-07-Requirement** selbst — `lastenheft.md:139-140`: „`a-check.mk` (a-checks `--print-mk`-Fragment, a-check-Image **per Digest gepinnt**)". Die ADR schreibt hier also den Spec-Zielzustand fort, nicht eine erreichte Ist-Parität; Kontext + Annahme 1 rahmen ihn eindeutig als noch-nicht-erfüllt. **Konsistent.** (Zusätzlich bestätigt der Lastenheft-Changelog `0.4.0`/Z. 267 selbst „arch-Gate a-check → a-check.mk, **wenn integriert**" — die Nicht-Integriertheit ist Spec-anerkannt.)

### M-2 (Kompositions-Modell / `flat`-Mischarakterisierung) — **im Kern AUFGELÖST** (ein LOW-Rest, s. u.)

Der Kern-Fehlermodus von M-1-Runde („flat = eine Entry-Point-Rolle" → Slice lässt Gerüstung fallen → `make gates` bricht) ist **geschlossen**:

- Entscheidung 2 (Z. 75–88) trennt jetzt explizit **(a) arch-invariante Bau-/Toolchain-Gerüstung** — „`go.mod`, `Dockerfile` (die Gate-Stages!), `.golangci.yml` bzw. `CMakeLists.txt`/`.clang-tidy`", **immer** präsent, „sonst bräche `make gates` mangels Dockerfile-Stages" — von **(b) Rollen-Renderer** und der **Arch-Schicht** (Layout).
- Byte-Identitäts-Zusage: „das Ist-`flat`-Profil (go: `go.mod`/`Dockerfile`/`.golangci.yml`/`main.go`; cpp: 6 Dateien) bleibt **byte-identisch** (LH-QA-02); `hexagonal` ersetzt nur den **Code**-Teil". **Gegen den Ist-Code wahr:** `goProfile` = genau diese 4 Dateien, `cppProfile` = genau 6. Die kompatibilitäts-kritische Zusage stimmt.

**Kein Bruch anderer ADR-Stellen:** Idempotenz (Entscheidung 5) klassifiziert nur Schicht-Code + a-check-Dateien und verweist im Übrigen auf ADR-0007 Entsch. 3 — die Bau-Gerüstung (`go.mod`/`Dockerfile`/`.golangci.yml`) ist dort bereits skip-if-present klassifiziert; **kein Konflikt**. Alternativen-Tabelle D-contra (Z. 112) und Fitness Functions (flat → kein a-check, `make gates` grün) sind mit dem revidierten Entsch.-2-Modell konsistent.

### LOW-1 (`add-lang`-Parser-Umbau als CLI-Kosten) — **AUFGELÖST**

Konsequenzen Z. 126–129 benennt es jetzt explizit: „der `add-lang`-Parser verwirft heute jedes `-`-Argument hart … `--arch` ist dort ein **Parser-Umbau**, kein additiver Schritt". **Gegen den Ist-Code wahr:** `main.go:130` `… || strings.HasPrefix(args[0], "-") || strings.HasPrefix(args[1], "-")` → Exit 2; Kommentar Z. 124 „Genau zwei Positionsargumente, keine Flags".

### INFO-1 (Idempotenz-Klassen) — weiterhin konsistent mit ADR-0007. Entscheidung 5 unverändert korrekt.

---

## Findings Runde 2 (Regressions-/Neu-Jagd)

### LOW-1 (neu) — Grauzone: die cpp-**Tests** sind im „Gerüstung ⟂ Rolle"-Modell nicht verortet

- **kategorie:** LOW
- **pfad:** Entscheidung 2 (Z. 76–86)
- **befund:** Das Modell nennt als cpp-Bau-Gerüstung nur „`CMakeLists.txt`/`.clang-tidy`" und als Datei-**Rollen** „Entry-Point, Domain-Entity, Port-Interface, Adapter". `cppProfile` (`internal/gen/cpp.go:19-28`) emittiert aber zusätzlich **`tests/CMakeLists.txt` + `tests/test_main.cpp`** — die fallen weder unter die namentlich genannte Gerüstung noch unter eine der vier Rollen. Es gibt **keine „Test"-Rolle**. Für `flat` ist das folgenlos (die Blanket-Zusage „cpp: 6 Dateien byte-identisch" deckt sie), aber für `hexagonal` bleibt offen, ob die Tests arch-invariante Gerüstung sind (bleiben → dann testet `test_main.cpp` weiter `add(2,3)`, das die hexagonale Domäne nicht mehr trägt → stale) oder Code (ersetzt → aber das Modell hat keine Test-Rolle).
- **warum nicht MEDIUM:** Der M-2-Kern-Fehlermodus (flat bricht `make gates`) ist geschlossen; dies ist ein **Vorwärts-Detail der `hexagonal`-Layout-Definition**, kein Ist-Widerspruch. Der `flat`-Pfad (kompatibilitäts-kritisch) ist byte-geschützt.
- **vorschlag:** Ein Halbsatz in Entscheidung 2 oder in der Welle-Slice-Beschreibung: Tests entweder als arch-invariante Gerüstung führen (dann bei `hexagonal` auf die Domäne umgehängt) **oder** als fünfte Rolle. Nicht §3.4-blockierend.

### INFO-1 (neu) — Konsequenzen (Z. 122–123) unterschlägt die Gerüstungs-Hälfte des Migrations-Bruchs

- **pfad:** Konsequenzen Z. 121–123 vs. Entscheidung 2
- **befund:** Der Auftrag fragt, ob der Migrations-Bruch als „**Gerüstung + Rollen-Renderer**" benannt ist. Entscheidung 2 und die History-Zeile (Z. 166, „Bau-/Toolchain-Gerüstung als arch-invariant benannt") tun das; die **Konsequenzen** dagegen verkürzen: „die Sprach-Profile müssen von ‚ein Datei-Satz' auf ‚**rendere Rolle X**' umgestellt werden". Das lässt die (a)-Hälfte (arch-invariante Gerüstung bleibt) weg, die Entscheidung 2 gerade als tragend etabliert hat. Interne Formulierungs-Inkonsistenz, kein Widerspruch in der Sache.
- **vorschlag:** „… von ‚ein Datei-Satz' auf ‚**arch-invariante Gerüstung + Rollen-Renderer**'". Optional.

### INFO-2 (neu) — Entry-Point-Pfad als „`main.go`" statt `cmd/app/main.go`

- **pfad:** Entscheidung 2 (Z. 83, 80: „Entry-Point → `main.go`/`src/main.cpp`")
- **befund:** Der reale Go-Entry-Point ist `cmd/app/main.go` (`golang.go:34`), nicht `main.go`. Kürzel, keine Falsch-Behauptung über den Gerüstungs-Split (der Runde-1-Report selbst schrieb präzise `cmd/app/main.go`). Kosmetisch.

---

## Negativbefunde (geprüft, ohne Befund)

- **Neue Ist-Behauptung eingeschleppt?** Nein. Die einzige a-check-nahe „Mechanik"-Aussage (Entsch. 3 „Image digest-gepinnt") spiegelt das LH-FA-07-Requirement, keine erfundene Reife. Kein „wie d-check"-Paritäts-Claim mehr.
- **Fix bricht andere ADR-Stelle?** Nein — Entsch. 5 (Idempotenz), Alternativen D, Fitness Functions, Konsequenzen tragen das revidierte Entsch.-2-Modell widerspruchsfrei; ADR-0007-Entsch.-3-Klassen unberührt.
- **Byte-Identität `flat`:** gegen `goProfile`/`cppProfile` **wahr** (4 bzw. 6 Dateien, Gerüstung explizit immer präsent).
- **LH-FA-07-Zitat** („trägt das Skelett keine hexagonalen Schichten, wird das Gate begründet **nicht** emittiert") — verbatim korrekt gegen `lastenheft.md:149-150`.
- **Toter Verweis?** Anker (`#lh-fa-07--…`, `#lh-fa-04--…`) entsprechen den Lastenheft-Überschriften (Z. 136/76). Kein toter Link gefunden.
- **§3.4/§3.5:** korrekt Proposed mit Immutable-Fußnote; a-check-Aktivierung läuft über diese ADR (korrektes Vehikel), LH-QA-01 durch konditionale Emission gewahrt. Kein Verstoß.
- **History-Tabelle (Z. 166):** protokolliert M-1/M-2/LOW-1/INFO-1 der Runde 1 akkurat.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 0 | — |
| LOW | 1 | LOW-1 (cpp-Tests im Gerüstung⟂Rolle-Modell nicht verortet — `hexagonal`-Detail, `flat` byte-geschützt) |
| INFO | 2 | INFO-1 (Konsequenzen unterschlägt Gerüstungs-Hälfte des Migrations-Bruchs), INFO-2 (`main.go` vs. `cmd/app/main.go`) |

## Verdikt: **ACCEPT-REIF**

Alle drei Runde-1-Befunde sind **substanziell** aufgelöst, nicht nur umformuliert:

1. **M-1** — a-check ist jetzt durchgängig **Vorbedingung** (Kontext + Annahme 1), deckt sich mit dem Ist-Grep (nur Dockerfile/Makefile-Kommentar). Der von Runde 2 gesuchte Rest-Widerspruch in Entscheidung 3 ist **keiner**: „Image digest-gepinnt" spiegelt verbatim das LH-FA-07-Requirement (Ziel-Mechanik), nicht erreichte Parität.
2. **M-2** — der kompatibilitäts-kritische Fehlermodus (flat lässt Gerüstung fallen → `make gates` bricht) ist geschlossen: Bau-Gerüstung explizit **arch-invariant/immer präsent**, `flat`-Profil **byte-identisch** — gegen `goProfile`/`cppProfile` verifiziert.
3. **LOW-1** — `add-lang`-Parser-Umbau als CLI-Kosten benannt, gegen `main.go:130` wahr.

**Keine fix-induzierte Regression, keine neue Ist-/Falsch-Behauptung, kein gebrochener Cross-Verweis.** Die verbleibenden Punkte sind 1× LOW + 2× INFO reine Schärfungen (cpp-Test-Verortung im `hexagonal`-Layout; Konsequenzen-Wortlaut; Entry-Point-Pfad) — sie würden den implementierenden Slice **nicht** auf einen Widerspruch oder eine Falsch-Behauptung laufen lassen, weil der `flat`-Kompatibilitätspfad byte-geschützt ist und das cpp-Test-Detail ein Vorwärts-Design der `hexagonal`-Layout-Definition ist (natürlicher Slice-Inhalt, kein ADR-Widerspruch).

**Empfehlung:** Der ADR kann nach §3.4 eingefroren (Accepted) werden. Optional vor dem Freeze der Einzeiler zu LOW-1 (Tests als Gerüstung ODER fünfte Rolle) und die INFO-1-Wortlaut-Angleichung — beide nicht blockierend.
