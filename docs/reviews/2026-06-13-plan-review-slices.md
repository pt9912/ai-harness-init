# Review-Report: slice-001..005 (welle-01/02) — 2026-06-13

**Review-Art:** Plan — geprüft gegen `spec/lastenheft.md`,
`spec/architecture.md`, `docs/plan/adr/0001-skelett-distribution.md`,
`harness/conventions.md` und die Hard Rules in `AGENTS.md`.

**Gegenstand:** Slice-Pläne in `docs/plan/planning/open/` (`slice-001` bis
`slice-005`), `welle-01-offline-kern.md`, `roadmap.md`.

**Skill:** unabhängiger Reviewer-Agent (`code-documentation:code-reviewer`), kein Repo-Skill-Pfad.
**Modell:** Opus 4.8 · **Datum:** 2026-06-13.

**Eingangs-Kontext** (Verträge, gegen die geprüft wurde):

- die fünf Slice-Pläne + `welle-01-offline-kern.md` + `roadmap.md`
- aktive ADR: `ADR-0001`
- berührte IDs: `LH-FA-01`..`LH-FA-05`, `LH-QA-01`..`LH-QA-03`
- `AGENTS.md` (Hard Rules 3.1–3.5)

---

## Findings

### F-1 — LH-FA-01 Boundary-AC ("kein Überschreiben ohne --force") in keinem DoD

- `kategorie`: HIGH
- `quelle`: `LH-FA-01` (Boundary-AC, `spec/lastenheft.md:41`)
- `pfad`: `slice-003-template-ablage.md:52`, `slice-001-cli-skeleton.md:26`
- `befund`: Das Boundary-AC „Given bereits vorhandene Artefakte … kein Überschreiben ohne `--force`" steht in keiner DoD-Checkbox. slice-001 parst `--force` nur, slice-003 nennt die `--force`-Semantik allein unter „Risiken". Das Verhalten ist von keinem Slice prüfbar abgenommen.
- `verifizierbar`: ja — ein bats-Test „Lauf gegen Repo mit vorhandener Datei ohne `--force` → kein Überschreiben / Exit≠0" fehlt in allen fünf DoD-Listen.

### F-2 — LH-FA-01 über zwei Wellen gesplittet, Happy-Path-AC erst in welle-02

- `kategorie`: MEDIUM
- `quelle`: `LH-FA-01` (Happy Path, `spec/lastenheft.md:40`), Roadmap M1
- `pfad`: `welle-01-offline-kern.md:35`, `roadmap.md:32`, `slice-005-root-readme.md:26`
- `befund`: welle-01 führt `LH-FA-01` als Bezug und M1 beansprucht „lauffähiger Offline-Kern", doch das einzige DoD, das den Happy-Path „`make gates` grün" als vollen Smoke abnimmt, liegt in slice-005 (welle-02). welle-01 §3 deklariert nur eine „`LH-QA-01`-Vorstufe". `LH-FA-01` wird in welle-01 nicht vertraglich abgeschlossen.
- `verifizierbar`: ja — Abschluss von welle-01 (slice-001..003 DoD grün) erfüllt das Happy-Path-AC nachweislich nicht.

### F-3 — Projektname-Stempelung (LH-FA-01-Detail) unter Bezug LH-FA-02

- `kategorie`: MEDIUM
- `quelle`: `LH-FA-01` („Projektname gestempelt", `spec/lastenheft.md:35`), Bezug-Korrektheit
- `pfad`: `slice-003-template-ablage.md:9,27`
- `befund`: slice-003 referenziert nur `LH-FA-02`, enthält aber das DoD „Projektname wird in die Singleton-Ziele gestempelt". Stempeln ist Bestandteil der `LH-FA-01`-Beschreibung, nicht von `LH-FA-02`; der Bezug ist ggü. dem DoD-Inhalt unvollständig.
- `verifizierbar`: nein — Bezugs-Zuordnung, durch Textvergleich belegbar, kein Gate.

### F-4 — bats-Spannung zu LH-QA-03 nur als Risiko-Notiz, nicht als ADR/Carveout

- `kategorie`: HIGH
- `quelle`: `LH-QA-03` („bash + git + docker; sonst nichts", `spec/lastenheft.md:80`), `AGENTS.md` §3.5
- `pfad`: `slice-001-cli-skeleton.md:52-55`, `slice-004-skeleton-picker.md:52`
- `befund`: bats ist in allen fünf DoDs verpflichtendes Test-Tooling und wird in slice-001 ins `gates`-Target promotet. `LH-QA-03` begrenzt die Abhängigkeiten auf bash+git+docker. Die faktisch getroffene Entscheidung, bats verbindlich in den Gate-Lauf zu nehmen, wird nur als Risiko/Annahme geführt — eine Abweichung von einer abnahmebindenden NFA ohne ADR/Carveout.
- `verifizierbar`: ja — `make gates` im Minimal-Container (bash+git+docker, kein bats) gemäß `LH-QA-03`-Messmethode schlägt fehl, solange bats im `test`-Target hängt.

### F-5 — Promotion `lint`/`test` ohne harte Atomaritäts-Kopplung (Hard-Rule-3.1-Risiko)

- `kategorie`: MEDIUM
- `quelle`: `AGENTS.md` §3.1 „Keine halluzinierten Gates", `LH-QA-01`
- `pfad`: `slice-001-cli-skeleton.md:29,39`, `AGENTS.md:69`
- `befund`: `AGENTS.md` §4 führt `lint`/`test` als „Nicht behauptet". slice-001 promotet beide nach `AGENTS.md`/`harness/README.md` und ins `gates`-Target, koppelt aber Target-Anlage und Promotion nicht als harte DoD-Bedingung. Promotion vor lauffähigem Target erzeugte einen genannten Gate ohne Existenz auf frischem Checkout (§3.1).
- `verifizierbar`: ja — `make gates` auf frischem Checkout nach Promotion-Commit: Exit 0 bestätigt Konformität, „target not found" den Verstoß.

### F-6 — Normative Slice→Roadmap-Referenz im „Welle:"-Feld (slice-004/005)

- `kategorie`: LOW
- `quelle`: Regelwerk SDP — Referenz-Richtung (Slices referenzieren normativ nur aufwärts)
- `pfad`: `slice-004-skeleton-picker.md:7-8`, `slice-005-root-readme.md:7-8`
- `befund`: Beide welle-02-Slices verlinken im Kopf-Feld „Welle:" auf `in-progress/roadmap.md`. Die Roadmap ist Kontext, keine normative Entscheidungsgrundlage; die Kontext-vs-normativ-Abgrenzung ist am Kopf-Feld nicht ausgewiesen. slice-001..003 verweisen demgegenüber auf die flache Welle-Datei.
- `verifizierbar`: nein — Referenz-Richtungs-Frage, Feldvergleich.

### F-7 — slice-002 DoD „Digest aus Pin-Quelle" nicht gegen kanonische Quelle verankert

- `kategorie`: LOW
- `quelle`: `LH-QA-02` (`spec/lastenheft.md:75`), `harness/conventions.md` §Baseline (`conventions.md:12`)
- `pfad`: `slice-002-doc-gate-emit.md:25`
- `befund`: Das DoD „Digest … aus einer Pin-Quelle, nicht floating" benennt keine konkrete Quelle, während die Konvention den Digest in `harness.mk` / Baseline v0.8.0 fixiert. slice-004 verankert seine Pin-Quelle dagegen präzise. Die unbestimmte Formulierung ist gegen einen Soll-Wert nicht maschinell prüfbar.
- `verifizierbar`: nein — Prüfbarkeits-/Formulierungsbefund.

### F-8 — slice-002 docker-Voraussetzung nur LH-QA-03 zugeordnet, nicht der Architektur

- `kategorie`: INFO
- `quelle`: `architecture.md` §3 (docker = Gate-Lauf, `architecture.md:39`), `LH-QA-03`
- `pfad`: `slice-002-doc-gate-emit.md:50`
- `befund`: slice-002 hält docker als „Annahme `LH-QA-03`" fest. docker ist laut `architecture.md` §3 eine nicht-substituierbare externe Abhängigkeit für den Gate-Lauf — der Verweis ist nicht falsch, aber unterspezifiziert.
- `verifizierbar`: nein — Bezugs-Vollständigkeit.

## Negativbefunde

- geprüft, ohne Befund: AC-Abdeckung `LH-FA-02`/`03`/`04`/`05` — je genau ein Slice-DoD, keine Doppelung/Widerspruch.
- geprüft, ohne Befund: `LH-FA-01` Negative-AC (fehlendes `--lang` → Exit 2 + Usage) — sauber in slice-001.
- geprüft, ohne Befund: `LH-QA-01` — slice-002 und slice-005 decken Gate-Grünlauf/Smoke.
- geprüft, ohne Befund: Bezug slice-004 — `LH-FA-04`/`LH-QA-02`/`ADR-0001` exakt; `ADR-0001` ist Accepted.
- geprüft, ohne Befund: Abhängigkeiten/Zyklenfreiheit — slice-001 → {002,003} → welle-01-Closure → {004 → 005}; gerichtet, azyklisch.
- geprüft, ohne Befund: Scope gegen Welle-Out-of-Scope — kein Netz-/README-Scope in welle-01-Slices.
- geprüft, ohne Befund: Template-Konformität — alle Slices Sektionen 1–8 inkl. Sub-Area-Modus-Begründung (GF konsistent mit `conventions.md`).
- geprüft, ohne Befund: Hard Rule 3.3 — in `planning/README.md` verankert; kein Plan-Konflikt.
- geprüft, ohne Befund: Hard Rule 3.2 — slice-001 fordert explizit „keine Inline-Suppression".
- geprüft, ohne Befund: `harness/README.md` §Sensors / „Nicht behauptet" existiert real — Promotion-Ziel nicht halluziniert.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 3 |
| LOW | 2 |
| INFO | 1 |

## Verdikt

**Merge-blockierend:** ja — F-1 und F-4 (HIGH) sollten vor Implementierungs-Start
aufgelöst werden; F-2/F-3/F-5 (MEDIUM) ebenfalls, da sie Vertrags-Abdeckung
und Hard-Rule-3.1-Konformität betreffen. F-6/F-7 (LOW) und F-8 (INFO) sind
nicht blockierend.

**Übergabe:** Findings gehen zurück an die Planung (Rückkante Review → Plan).
Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der
Verifier separat am Code (Modul 11).
