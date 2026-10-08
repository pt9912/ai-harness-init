# Verifikations-Bericht: slice-formel-skelett-nennt-die-fassungs-ausnahme — 2026-10-08

**Rolle:** Verifier (Modul 11) → Planner. **Gegenstand:** `6b8d134c`, `a24fb926`, `b1741744`;
Plan-Nachschnitt `3f337317`; Review-Report vom 2026-10-08 (`2026-10-08-formel-skelett-review.md`).
**Quellen:** Slice-Plan §1–§3, ADR-0063 (Proposed) Festlegung 1, ADR-0059 Festlegung 2, der Diff.
**Modell:** claude-opus-5-5.

## Verdikte je DoD-Punkt

- **(1) Skelett-Kommentar nennt die eine Injektion — bestätigt** (mit Finding V-1).
  - Wortlaut: `harness/tools/homebrew-formula.rb.tmpl` Z. 4–5 trägt den DoD-Satz byte-gleich
    (`der Bau injiziert genau einen Wert ins Binary, die Fassung (ADR-0063 Festlegung 1);
    eingebettete Vorgaben aus dem Quellstand berührt das nicht.`).
  - Wahr gegen den echten Bau: `grep -rn -- '-X\|ldflags' Dockerfile Makefile *.mk
    .github/workflows/ harness/mk` → einzige Injektion `Dockerfile:101`
    (`-X main.fassung=${TRAEGER_VERSION}`, bedingt über `:+`), sonst nur Kommentare.
  - Rot-Beleg (HIGH-Behebung, bewusstes Brechen in einer `git archive HEAD`-Kopie im Scratchpad,
    je Form eine Zeile an das Makefile angehängt, `make test-bats BATS_TARGET=test/release-matrix.bats`):
    - `-X=main.commit=x`, `-X 'main.commit=x'`, `-X "main.commit=x"`, `-X<TAB>main.commit=x` →
      je allein `not ok 9 … das Formel-Skelett nennt genau die eine Ausnahme …`, Meldung
      `der Bau injiziert nicht genau die Fassung ins Binary — der Skelett-Satz nennt nur sie: main.commit`
      — gelesen, trifft den eingesetzten Wert.
    - fail-closed: `-X $(PKG).v=x` → `not ok 9`, Meldung `ein -X in den Bau-Dateien folgt keiner
      erkannten Operanden-Form — der injizierte Wert ist nicht lesbar: …` (listet alle `-X`-Zeilen).
    - Gegenprobe: zweites `-X main.fassung=x` und unmutierte Kopie → `ok 9`.
  - `make mutate MUTATE_CASES='610-… 611-… 612-… 613-…'` → `mutate: 4 ok, 0 Befund(e)`
    (Teillauf, Prüfgegenstand `9c6eedbc…`).
- **`make gates` grün — bestätigt** (nicht neu gefahren): `.harness/state/gates-passed.head` =
  `b1741744` = HEAD, `gates-passed.diffsha` = `harness/tools/working-tree-hash.sh` =
  `d48eace0…`, Stempel 17:59 nach dem HEAD-Commit 17:51.
- **Review durchgeführt — bestätigt:** Report liegt vor; F-1 (HIGH) behoben und oben durch
  Bruch bestätigt; F-2/F-3 durch Plan-Nachschnitt `3f337317` und `b1741744` aufgenommen
  (Rot-Angabe nennt jetzt den Test, der den Satz hält). Ein Review über `b1741744` selbst
  existiert nicht; die DoD verlangt ihn nicht.
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen — offen** (Planner-Arbeit, nicht Gegenstand).

## Findings

- **V-1 (Zusage, MEDIUM):** `test/release-matrix.bats` Kopf-Liste Punkt 8 sagt weiter
  *„Der Kopf des Formel-Skeletts nennt als einzigen Wert im Binary die Fassung"* — dieselbe
  Allaussage, die Review F-2 widerlegt hat (eingebettetes `TRAEGER_TAG`, `DefaultTag`); der
  Skelett-Satz ist gefasst, die Zusage im Testkopf nicht. Übergabe an den Implementer.
- **V-2 (Plan-vs-Code, INFO):** Plan §3 und DoD (1) nennen die Mutations-Fälle 610/611; der Diff
  trägt zusätzlich 612 (Makefile, `-X=`) und 613 (Workflow, `-X "…"`) aus `b1741744`. Gebaut ohne
  Plan-Zeile; Planner zieht §3 nach oder nimmt es in die Closure-Notiz.
- **V-3 (Bedeutung, INFO):** „genau einen Wert" gilt für den Release-Bau; ohne `TRAEGER_VERSION`
  injiziert `Dockerfile:101` keinen (ADR-0063 Festlegung 3, Testkopf Punkt 5). Der Test hält
  „höchstens die Fassung" (Namensmenge = `main.fassung` oder Abbruch); den Null-Fall prüft er
  nicht. Am Formel-Skelett (Release-Kontext) trägt der Satz; kein Handlungsbedarf, benannt.

## Negativbefunde

- Plan §1 Abgrenzung: kein weiterer Formel-Griff, kein Re-Publish, Emissions-Griff unverändert — eingehalten.
- Grenze des Tests (eingebettete Vorgaben, `-X` außerhalb der gelesenen Dateien) ist im Testkopf benannt und deckt sich mit dem Satz.
- Review F-4 (610 färbt auch Test 6): unverändert; Test 9 trägt mit 612/613 jetzt eigene Zähne.
