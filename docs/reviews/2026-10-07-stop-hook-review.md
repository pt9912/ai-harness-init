# Review: slice-stop-hook-bindet-an-den-commit (Implementer-Commit `09ac442b`)

**Rolle:** Reviewer (Modul 10), Skill `.harness/skills/reviewer.md` · **Datum:** 2026-10-07 ·
**Gegenstand:** `git show 09ac442b` (19 Dateien) gegen Slice-Plan `slice-stop-hook-bindet-an-den-commit`
und [ADR-0083](../plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(Festlegungen 1–6, Fitness Function); Kurs v6.17.0 `grundlagen-durchsetzungsschicht.md`
§Handoff-Gate (Loop-Guard), `modul-13-quality-gates.md` §Guard-Härtung, MR-002/MR-003, ADR-0028,
`AGENTS.md` §3.6/§3.7/§3.8.

**Summary:** 0 HIGH · 0 MEDIUM · 2 LOW · 2 INFO. Klassen: *Plan-Werkzeug ersetzt ohne
Übergabe-Artefakt* · *Zusage ohne Vorbedingung (Stempel fehlt)*.

## Findings

### LOW-1 — DoD 1 / Plan §3 nennen bats, geliefert ist ein Go-Test, ohne Übergabe an den Planner

- `quelle`: Slice-Plan §2 Liefer-Punkt 1, §3 (`test/*.bats`); ADR-0083 §Fitness Function, Spalte Tooling; `AGENTS.md` §3.10
- `pfad`: `internal/emit/stophook_test.go:1`; `docs/plan/planning/in-progress/slice-stop-hook-bindet-an-den-commit.md:57`, `:88`
- `befund`: Der Plan verlangt bats; geliefert ist `TestStopHook_CommitBindung` (Go), und weder Plan noch
  ein Übergabe-Artefakt nennen den Tausch — die Commit-Message nennt nur den Go-Test. Failure-Szenario:
  der Verifier liest Liefer-Punkt 1 wörtlich und findet keinen bats-Fall, oder er hakt ihn ab, ohne
  dass der Planner den Werkzeugwechsel je gesehen hat.
  **Urteil zur Gleichwertigkeit (Schwerpunkt b):** trägt. Der Test kopiert den echten Hook, das echte
  `record-gates.sh` und `working-tree-hash.sh` beider Fassungen unverändert in ein tmp-Repo mit echtem
  `git` (das `test`-Image erbt von `golang:` und führt git; das bats-Image führt keines,
  `test/history-range-guard.bats:10`), deckt alle elf Fälle der Rule-Spalte je Fassung und läuft unter
  `make test`. Die Regel-Spalte der Fitness Function ist damit vollständig gehalten; abweichend ist
  allein das Werkzeug.
- `verifizierbar`: ja — `make test-go` (Fälle), Plan-Text gegen Diff
- `klasse`: Plan-Werkzeug ersetzt ohne Übergabe-Artefakt

### LOW-2 — „ohne neuen Commit geht frei" steht ohne die Vorbedingung Stempel

- `quelle`: ADR-0083 Festlegung 5 (ohne Stempel strenger Zweig); `AGENTS.md` §3.6
- `pfad`: `CLAUDE.md:9`, `.claude/commands/implement-slice.md:21`, `internal/emit/templates/commands/implement-slice.md:36`
- `befund`: Die drei Texte sagen die Freigabe ohne neuen Commit unbedingt zu; der Hook gibt sie nur mit
  vorhandenem `gates-passed.head` (Hook Z. 69–72), sonst gilt der strenge Zweig. Failure-Szenario: im
  Ziel nach dem Update auf v0.5.0 (und im Dogfood auf jedem Klon vor dem ersten grünen Lauf) blockiert
  das erste Turn-Ende mit ungedeckter Änderung, während Briefing und Command-Vorlage Freigabe
  versprechen — genau das Plan-Risiko 2 („Blockade ohne Grund"), das der Text nicht erklärt.
- `verifizierbar`: ja — Go-Fall `fehlender_HEAD_Stempel_bei_ungedeckter_Aenderung_blockiert`
- `klasse`: Zusage ohne Vorbedingung

### INFO-1 — Dogfood-Fassung und Hook-`head_wert` ohne eigenen Mutationsfall

- `quelle`: `AGENTS.md` §3.6 (`make mutate`: wer keinen Fall hat, ist unbewacht)
- `pfad`: `test/mutations/545–549` (alle `# files:` auf `internal/emit/templates/enforce/`)
- `befund`: Die Zähne der Dogfood-Fassung sind dieselben Go-Fälle (Fassungs-Parameter), ihre
  Haltbarkeit hält `make mutate` aber nur über die Ziel-Fassung; ebenso hat `head_wert` im **Hook**
  (vier Kopien, Kopplung nur per Kommentar, kein textueller Drift-Wächter) keinen Fall. Gelesen, nicht
  gefahren: eine Verkürzung des Hook-`head_wert` auf „rev-parse scheitert → kein-commit" färbte
  `HEAD_auf_fehlenden_Ref…` (Hook endet dann mit `block`/Exit 0 statt Exit 2). Verhaltens-Drift der
  zwei §4-Klassen ist damit von den Fällen gedeckt, die Streichung der Dogfood-Zeile aus
  `stopHookFassungen()` von nichts.
- `verifizierbar`: ja — `make mutate` mit einem Fall auf `.claude/hooks/stop-require-gates.sh`
- `klasse`: Kopplung zweier Fassungen nur per Kommentar

### INFO-2 — Plan-Risiko 1 („Exit-2-Semantik im Repo ungemessen") hat einen Beleg im Repo

- `quelle`: Slice-Plan §6; ADR-0083 Festlegung 5 — Zuständig: Planner (Risiko-Ausgang)
- `pfad`: `docs/user/claude-hooks-referenz.md:686`, `:704`, Tabelle bei `:719` (`Stop` — Exit 2
  „verhindert, dass Claude stoppt"; jeder andere Code nicht-blockierend)
- `befund`: Die vendored Referenz trägt die Semantik, auf die der Trap setzt; ein Lauf gegen Claude
  Code ist es nicht.
- `verifizierbar`: nein (Werkzeug-Verhalten außerhalb des Repos)
- `klasse`: Risiko mit vorhandenem Beleg

## Kommandos und Ausgaben

- `make mutate MUTATE_CASES="545-… 546-… 547-… 548-… 549-… 550-…"` (Namen ausgeschrieben): 545–549
  je `OK` (gebunden, ~11–13 s); 550 `OK` (139,80 s, full-smoke) — `6 ok, 0 Befund(e)`, Exit 0.
- **Gegenprobe Fall 546** (Klon unter dem Scratchpad, entfernt): Mutation angewandt, `t.Skip` allein in
  `ziel/unlesbarer_HEAD_Stempel_Exit_2` → `make test-go` bleibt rot, mitgefärbt
  `ziel/HEAD_auf_fehlenden_Ref_record_rot_ohne_Stempel_Hook_Exit_2`. Kein Befund: beide binden den
  gemeinsamen Trap; der benannte Fall bindet zusätzlich, dass das Lesen des Stempels nicht
  verschluckt wird (ein `cat … || true` fiele allein an ihm).
- Loop-Guard außerhalb eines Repos: `echo '{"stop_hook_active":true}' | bash .claude/hooks/stop-require-gates.sh`
  → `approve`, Exit 0; `cd "$(git rev-parse --show-toplevel)"` ist dort ein No-op (`cd ""`), der
  Fehler fällt erst in `head_wert` → Exit 2.
- `make gates` (einmal, nach den Läufen oben, über dem Baum mit diesem Report): Exit 0.

## Geprüft, ohne Befund

- **(a) Logik, beide Hook- und record-gates-Fassungen:** Default blockiert genau bei HEAD ≠ Stempel und
  Hash ≠ Nachweis; ohne Stempel strenger Zweig; Schalter `test -e` / `= 1`; `stop_hook_active` vor
  jedem git-abhängigen Schritt. Trap: jede `set -e`-Abbruchstelle (Zuweisung aus Substitution, `cat`
  auf Verzeichnis, `git status`, Hash-Skript) endet mit 2; der Hook führt keine Pipeline, `approve`/
  `block` enden mit `exit 0` und passieren den Trap unverändert — kein Fehlblock im Normalfall
  (Go-Fälle frei/gedeckt). Die Fassungen differieren nur in Kommentaren und Werkzeugpfad (`diff`).
  `record-gates.sh` schreibt den Stempel erst nach erfolgreichem `head_wert`, Format von
  `gates-passed.diffsha` unverändert.
- **(c) Mutationsfälle:** 545–550 binden je ihre Fitness-Zeile (Lauf oben).
- **(d) Selbstprüfung Schritt (5) / full-smoke:** die drei `STOP …`-Zeilen entstehen erst nach der
  Entscheidung des echten Hooks im Klon (Exit 0 vorausgesetzt), keine durch Marker-Interpolation;
  `full-smoke.sh` liest genau diese drei; Deklaration und `docs/user/e2e-abdeckung.md` nennen, was der
  Lauf misst.
- **(e) Rollen:** `CLAUDE.md` liegt außerhalb von `AGENTS.md` §3.8 und ist von ADR-0083 §Konsequenzen
  ausdrücklich dem Slice zugewiesen; `.claude/commands/implement-slice.md` gehört dem Implementer
  (ADR-0028). Kein Norm-Artefakt (§3, Adaptions-Block, ADR) im Commit.
- **(f) Grenze „fertig ohne Commit geht durch":** genannt in Hook-Kopf beider Fassungen, `CLAUDE.md`,
  beiden `implement-slice.md`, `plan-welle.md`, `close-welle.md`; die übrigen Stop-Hook-Nennungen
  (`harness/README.md:98`, `:231`, `ci.yml`) sagen kein strenges Turn-Ende zu. Der Folge-MR zu
  MR-002/MR-003 ist Architect-Arbeit (DoD-Zeile *Doku-Update*), nicht dieses Diffs.
- **§3.7 Kommentare** im Diff: Zusage/Kopplung/Grenze, keine Chronik.
