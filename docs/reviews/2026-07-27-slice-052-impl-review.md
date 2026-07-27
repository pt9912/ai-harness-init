# Review-Report: slice-052 — 2026-07-27

**Review-Art:** Code — geprüft wird der fertige Diff gegen **Plan + Konventionen**
(Modul 10 §Drei Review-Arten). Nicht geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-052 (`v0.1.1` — die Nutzer-Doku sagt, was das Werkzeug tut),
Commit `eeead0b` (`README.md`, `docs/user/benutzerhandbuch.md`; 2 Dateien, +17/−10).

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan: `docs/plan/planning/in-progress/slice-052-release-v0-1-1.md` (§2 DoD, §3 Ist-Messung mit Kommandos, §5 Closure-Trigger, §6 Risiken) — Klartext-Pfad statt Link, der `done/`-Move bricht ihn sonst
- Berührte `LH-*`-IDs: [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (phasierter, idempotenter Bootstrap), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin/Reproduzierbarkeit), [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Plattform-Matrix)
- Aktive ADRs mit ID im Commit/Slice: **keine** — der Diff ist reine Nutzer-Prosa; die Pin-Aussage stützt sich auf Code (`internal/fetch/baseline.go`), nicht auf eine ADR-ID
- [`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (Release-Workflow), [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) (CR-Regel: `spec/` nicht als Nebeneffekt)
- [`AGENTS.md`](../../AGENTS.md) §3 Hard Rules
- Vorherige Findings am gleichen Gegenstand: `docs/reviews/2026-07-26-slice-050-impl-review-runde-{1..5}.md` (Klasse „Aufzählung unvollständig"), `docs/reviews/2026-07-26-slice-051-impl-review.md` und `-runde-2` (Klasse „Beleg behauptet, nicht gemessen")

---

## Findings

### F-1 — Die protokollierte Gegenprobe zu Befund (2) liefert nicht den protokollierten Wert

- `kategorie`: MEDIUM
- `quelle`: slice-052 §3/§6 (Messmethode: „der Slice verlangt das **Kommando** als Beleg, nicht die Zahl") · Klasse aus slice-050/051
- `pfad`: Commit-Message `eeead0b` (Absatz „(2) …") vs. `docs/user/benutzerhandbuch.md:556`
- `befund`: Die Commit-Message protokolliert `Gegenprobe: grep -c 'arbeitet in **einem** Schritt' -> 0`. Auf dem Stand, den derselbe Commit herstellt, liefert dieses Kommando **1** — die §11-Zeile 1.8 zitiert den alten Wortlaut, korrekt und laut Kasten über der Tabelle sogar verlangt. Versagensbild: der nächste Leser (oder der Verifier) fährt die Gegenprobe nach, bekommt 1 und schließt entweder auf einen unvollständigen Fix oder tilgt die §11-Zeile — und damit den Änderungs-Nachweis.
- `verifizierbar`: ja — `grep -c 'arbeitet in \*\*einem\*\* Schritt' docs/user/benutzerhandbuch.md` → `1`; die einzige Fundstelle ist Zeile 556 (§11).

### F-2 — `README.md` nennt `COURSE_TAG`, ohne die Fundstelle zu benennen

- `kategorie`: INFO
- `quelle`: Maintainability (Doku-Drift-Kandidat)
- `pfad`: `README.md:40`
- `befund`: Beide korrigierten Handbuch-Stellen zeigen auf den Abschnitt [Eine andere Kurs-Version verwenden](../user/benutzerhandbuch.md#eine-andere-kurs-version-verwenden); die neue README-Formulierung nennt `COURSE_TAG` als Ausweg, ohne auf diesen Abschnitt zu zeigen. Der Verweis auf das Handbuch steht im README nur allgemein (Zeilen 15 und 53).
- `verifizierbar`: nein — kein Gate prüft Verweis-Symmetrie; `docs-check` sieht nur tote Links, und hier fehlt der Link, statt zu brechen.

### F-3 — Der Kopf trägt einen Software-Stand, den es noch nicht gibt

- `kategorie`: INFO
- `quelle`: slice-052 §3 Reihenfolge (4) / §6 („Das Zeitfenster zwischen Doku-Commit und Tag … benannt, nicht wegdefiniert")
- `pfad`: `docs/user/benutzerhandbuch.md:4`
- `befund`: Der Handbuch-Kopf nennt `**Software-Stand:** v0.1.1`, während `v0.1.1` noch kein Tag ist (`git tag` kennt bis `v0.1.0`). Das ist die im Plan gewählte Reihenfolge — der Tag soll die korrigierte Doku tragen —, aber es ist die einzige Aussage des Diffs, die erst ein **künftiger** Schritt wahr macht; bleibt der Tag aus, ist sie dauerhaft falsch.
- `verifizierbar`: ja — `git tag --list 'v0.1.1'` nach dem Release-Lauf; leer = Aussage offen.

## Negativbefunde

- geprüft, ohne Befund: **Vollständigkeit von Befund (3)** — alle fünf im Plan gezählten Fundstellen sind angefasst (Handbuch alt 179/301/309/489 → neu 183/305/313/493, README 37 → 39); das Plan-Kommando `grep -n "neueres Regelwerk nach\|neueren Kurs-Stand" docs/user/benutzerhandbuch.md README.md` liefert nur noch korrigierte Treffer plus das §11-Zitat.
- geprüft, ohne Befund: **breitere Suche nach derselben Aussage** — `grep -rniE "(neuer|neuere|neueren|neueres|aktualisier|auffrisch|hebt)[^.]{0,40}(Regelwerk|Kurs-Stand|Kurs-Version)"` über `docs/` (ohne `plan/`, `reviews/`) und `README.md`: keine unkorrigierte Instanz.
- geprüft, ohne Befund: **emittierte Artefakte** — `internal/emit/` und `.harness/baseline/v3.5.2/templates/`: keine Instanz der drei Aussagen; die Ziel-Repos tragen sie nicht, der Fix muss dort nicht nachgezogen werden.
- geprüft, ohne Befund: **Deckung der Pin-Aussage durch Code** — `cmd/ai-harness-init/main.go:277` (`tag := envOr("COURSE_TAG", fetch.DefaultTag)`) und `internal/fetch/baseline.go:48` (`const DefaultTag = "v3.5.2"`): der Re-Lauf desselben Programms holt denselben Stand; die neue Prosa sagt genau das und nicht mehr.
- geprüft, ohne Befund: **Windows-Hinweis gegen die Messung** — `grep -ciE "sign|codesign|signtool|authenticode"` über **alle drei** Workflows (`ci.yml`, `release.yml`, `upstream-drift.yml`) → `0`; der Hinweis behauptet keinen Dialog-Wortlaut, die Formulierung bleibt innerhalb des Belegten.
- geprüft, ohne Befund: **`spec/lastenheft.md` unberührt** ([`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) — `git diff --name-only 1fe2496..HEAD -- spec/` ist leer.
- geprüft, ohne Befund: **Verzicht auf `make mutate`** — kein Wächter liegt auf den beiden geänderten Dateien: `grep -rn "README.md" test/mutations/*.sh` trifft nur Kommentare über *emittierte* Ziel-Dateien, `benutzerhandbuch` kommt in `test/`, `Makefile`, `harness/tools/` nicht vor.
- geprüft, ohne Befund: **Link-Ziele des Diffs** — der Anker `#eine-andere-kurs-version-verwenden` existiert (`docs/user/benutzerhandbuch.md:317`); `make gates` Exit 0, `d-check` 198 Datei(en) / 0 Befund(e).
- geprüft, ohne Befund: **§11-Regel „wo Versions-Aussagen hingehören"** (Kasten über der Tabelle, seit 1.7) — die „ab `v0.1.0`"-Aussagen stehen im Rumpf, die „bis 1.7 stand da …"-Aussagen in der 1.8-Zeile.
- geprüft, ohne Befund: **`AGENTS.md` §3 Hard Rules** — der Diff berührt weder Gate, Baseline noch `spec/`; kein Stilles-Grün-Pfad, kein halluziniertes Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 2 |

## Verdikt

**Merge-blockierend:** ja — F-1 ist MEDIUM und blockiert damit typischerweise.

**Begründete Einschränkung des Umfangs:** F-1 trifft **nicht** den ausgelieferten
Text, sondern den Beleg über ihn. Der Diff selbst ist konform: alle fünf
Fundstellen von Befund (3) sind angefasst, die Pin-Aussage deckt sich mit dem
Code, der Windows-Hinweis bleibt innerhalb des Gemessenen. Auflösung von F-1 heißt
deshalb: die Gegenprobe auf ein Kommando stellen, das die §11-Zeile nicht mitzählt,
und den korrigierten Beleg dort festhalten, wo er nachgeschlagen wird
(Closure-Notiz) — der Commit `eeead0b` selbst wird nicht umgeschrieben.
F-2 und F-3 sind INFO und erwarten keine Aktion; F-3 löst sich mit dem Tag auf.

**Übergabe:** Findings gehen an die Implementation (Rückkante
Review → Plan bei Plan-Defekt). Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
