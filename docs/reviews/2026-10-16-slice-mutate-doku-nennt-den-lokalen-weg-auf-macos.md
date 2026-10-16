# Review: slice-mutate-doku-nennt-den-lokalen-weg-auf-macos

**Range:** Implementer `a6b75443` (`harness/sensors/mutate.md`: Abschnitt „Lokaler Weg für `# verify: full-smoke`-Fälle auf einem Nicht-Linux-Host"; `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh`: ein Kommentar-Satz im Kopf) · **Plan:** `slice-mutate-doku-nennt-den-lokalen-weg-auf-macos` (§1–§3) · **Bezug:** LH-QA-02, MR-071, MR-090, AGENTS.md §3.3/§3.6/§3.7/§3.8/§3.10 · Reviewer-Skill (Stand HEAD). Nicht geprüft: DoD (Verifier).

**Summary:** 0 HIGH · 0 MEDIUM · 2 LOW · 2 INFO — annahmefähig. Ergebnis zu (a): jede Aufruf- und Meldungs-Zusage am Quelltext und an zwei eigenen Läufen bestätigt; zwei Zusagen sind enger zu lesen, als sie dastehen (LOW-1, LOW-2). Ergebnis zu (b): Stelle passt, kein Widerspruch. Ergebnis zu (c): Kopfsatz stimmt, Fall unverändert, `mutate-greift` 653/653.

## Findings

### LOW-1 — Kollisions-Satz für Mehr-Fall-Läufe nennt einen Mechanismus, der für `full-smoke`-Fälle nicht gilt und nicht gemessen ist

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6 (Zusage nur, was belegt ist)
- `pfad`: `harness/sensors/mutate.md:134-135`
- `befund`: „Mehrere Worker, die zugleich Images bauen, kollidieren auf diesem Host an der Docker-Tag-Vergabe" steht im Indikativ ohne Herkunft. Die Beobachtung `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers` belegt es für das Tag `ai-harness-init:test` im Grün-Vorlauf (`make test-go`) eines gemischten Fünf-Fall-Laufs. `# verify: full-smoke`-Fälle laufen laut Treiber in der seriellen Spur (`mutate.sh:1891`, `plan_self_contained`); im eigenen Einzellauf stand genau ein Grün-Vorlauf (`1 full-smoke 111.11`) trotz „4 Worker". Ob ein Mehr-Fall-Lauf nur aus `full-smoke`-Fällen kollidiert, ist ungemessen; die Folgerung „nicht zugesagt" trägt, die Ursachen-Aussage nicht für diese Fallklasse. Die Doku nennt weder die Beobachtung noch „übernommen, nicht gemessen".
- `verifizierbar`: nein (Messung mit zwei `full-smoke`-Fällen; kein Gate)
- `klasse`: Ursachen-Aussage ohne Herkunft und für die genannte Fallklasse nicht gemessen

### LOW-2 — Geltungsbereich „nicht Linux/amd64" weiter als gemessen

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6
- `pfad`: `harness/sensors/mutate.md:117-118`
- `befund`: Der Abschnitt öffnet für jeden Host „nicht Linux/amd64", klammert „gemessen: macOS" ein. Gemessen ist macOS (Colima). Linux/arm64 und Windows sind weder gemessen noch ausgeschlossen; `artifact-host` leitet GOOS/GOARCH aus `uname` ab (`make host-bin`), für Windows trägt das Repo keine Aussage. Eine Grenze „nur macOS gemessen" steht nicht in der Liste der Grenzen. Dass ein Linux/amd64-Host die Variable nicht braucht, steht nicht da.
- `verifizierbar`: nein
- `klasse`: Geltungsbereich über den Messpunkt hinaus

### INFO-1 — DoD-Punkt 1 nennt Fall 305, gefahren und im Text genannt ist Fall 171

- `kategorie`: INFO
- `quelle`: Plan §2
- `pfad`: `harness/sensors/mutate.md:129-131`
- `befund`: Beide Fälle tragen `# verify: full-smoke` und laufen über denselben Pfad (Variable → `ARTIFACT_TARGET`, `full-smoke.sh:470`); Fall 171 trägt den Aufruf sachlich gleich wie 305, der Text nennt wahrheitsgemäß 171. Die Abweichung vom Wortlaut verschiebt die Abnahme; die Entscheidung liegt beim Planner (§7).
- `verifizierbar`: ja
- `klasse`: Messpunkt weicht vom Plan-Wortlaut ab

### INFO-2 — Zeitangaben sind Einzelwerte, eigene Messung weicht ab

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.6
- `pfad`: `harness/sensors/mutate.md:136-138`
- `befund`: Eigener Lauf: Grün-Vorlauf 111 s, Fall 14,5 s (Implementer: 157 s / 16,6 s). Der Text nennt 157 s selbst als Einzelwert und „mehrere Minuten", das trägt (111 s ≈ zwei Minuten, Gesamtlauf mit Image-Bau länger). Kein Mangel.
- `verifizierbar`: ja
- `klasse`: Einzelwert korrekt als solcher markiert

## Reproduzierte Läufe

- Mit Variable: `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=171-feldliste-ausserhalb-des-geprueften-bereichs PATH=…gnubin:$PATH make mutate` → `[w1] 171-… OK (14.49 s)`, `mutate: 1 ok, 0 Befund(e)`, `TEILLAUF 1 von 653`, Grün-Vorlauf 111,11 s, Exit 0.
- Ohne Variable (20,4 s): `full-smoke.sh: line 515: …/ai-harness-init: cannot execute binary file: Exec format error`, `full-smoke: FEHLER — der Bootstrap (sprachlos) der Stufe Handbuch-Baum ist NICHT Exit 0 (Exit 126).`, `mutate: BEFUND  worker-1 …`, Folge-BEFUNDe `vollstaendigkeit`/`zeit-bilanz`, `make` Exit 2. Die zitierte Meldung im Abschnitt (mit „…" für „der Stufe Handbuch-Baum") stimmt.
- Komma als Trenner: `MUTATE_CASES=171-…,615-…` → `ABBRUCH — MUTATE_CASES nennt einen unbekannten Fall: '171-…,615-…'`, Skript 1, `make` Error 1. „Leerzeichen, kein Komma" und „voller Name ohne `.sh`" stimmen mit `select_cases` (`mutate.sh:648-675`, `IFS=$' \t\n'`) überein.
- `make mutate-greift` (mit GNU-sed im PATH; ohne ihn scheitern BSD-sed-Fälle am Host, kein Befund des Diffs): `653 Fall/Faelle, 653 greifen, 0 Befund(e)`.

## Geprüft, ohne Befund

- (a) Aufruf, Exit 126, `BEFUND worker-1`, `make` Exit 2, Variablen-Durchreichung (`Makefile:235-236`, `full-smoke.sh:470`, analog `full-smoke-host`): bestätigt. Grenze „nur Einzel-Fälle" als Aussage über Gemessenes korrekt, siehe LOW-1 für die Ursache.
- (b) Stelle vor „Meldung eines roten Grün-Vorlaufs" passt (schließt an „Teillauf" an); `git grep` auf `SMOKE_ARTIFACT_TARGET`, `full-smoke-host`, `MUTATE_CASES` in `harness/`: kein Widerspruch zu `harness/README.md` (Zeile `full-smoke-host`) oder zum Abschnitt „Teillauf".
- (c) Kopfsatz Fall 171: 614 mutiert `internal/emit/templates.go` (carveouts-`.gitkeep`), 615 `internal/emit/enforce.go` mit `expect` `[harness/erfassung-feldliste.md]` — „der Fall 615 hält diese Stufe für die Ablage dieser Datei" stimmt. `git diff a6b75443~1 a6b75443 -- test/mutations` ändert nur diese zwei Kommentarzeilen; `# files:`/`# expect:`/`# verify:` und Mutation unverändert.
- (d) Commit trägt nur Doku und einen Fall-Kommentar (kein Move, §3.3), keine Norm-Artefakte (§3.8), keine Closure-Felder berührt (Plan §7 leer, DoD unabgehakt, §3.10). Message nennt Rolle und Kennungen.
- (f) „Kein Wächter hält diese Aussage … Träger ist der Lauf, der sie schreibt" steht im Abschnitt.
- §3.7: Abschnitt und Kopfsatz im Indikativ, keine verworfene Alternative, keine Befund-Kennung als Grund.
