# Review: slice-ausnahme-grund-nennt-seinen-ganzen-gegenstand — 2026-10-08

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md`) · **Gegenstand:** `f7d87bad`, `62758f7c`
(Claim `49720cf6`/`748c0180`) gegen den Slice-Plan (`in-progress/`, Welle `welle-emittiertes-doc-gate`),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-017`](../../harness/conventions.md#mr-017), [`MR-029`](../../harness/conventions.md#mr-029),
[`MR-071`](../../harness/conventions.md#mr-071), `AGENTS.md` §3.2/§3.5/§3.6/§3.7.
DoD 3 (Ort der Regel) ist Architect-Arbeit und nicht Gegenstand.

**Summary:** 1 HIGH · 2 MEDIUM · 0 LOW · 0 INFO.

## Findings

### F-1 — HIGH

- `quelle`: `AGENTS.md` §3.6; Skill §LOW/INFO mit Eskalation (Grenzen-Aufzählung ohne Formen-Probe)
- `pfad`: `internal/ausnahmegrund/ausnahmegrund.go:23-24`, `:60-62`
- `befund`: Laut Paketkopf liest der Parser Flow-Listen auf einer Zeile und Block-Listen mit `- `.
  Zwei gefahrene Formen enden still grün, ohne dass ein Gate das meldet. (a) Ein Block-Item in einfachen
  Anführungszeichen (`- 'tools/weg.sh'` unter `codepaths.ignore-refs`, `- 'tools/**'` unter
  `exempt-paths`) wird als Eintrag gezählt, aber mit Anführungszeichen im Wert (`reItem` entfernt nur `"`).
  Damit gibt es keine Treffer und keinen Befund. Die Flow-Form entfernt `'` dagegen. Weil der Eintrag
  gezählt wird, fängt ihn auch die Zählprobe `len(ee) < 10` nicht. (b) `scan.ignore` als Block-Liste
  liefert 0 Einträge, denn `reBlockKopf` kennt nur `exempt-paths|ignore-refs`. Damit ist die Aussage
  „Block-Liste mit `- `" für den Schlüssel `scan.ignore` falsch, also gerade für den Schlüssel mit dem
  Eintrag `.harness/**`, auf dem der emittierte Fall steht.
- `verifizierbar`: ja. Probe im Container (Testdatei temporär, danach entfernt), Ausgabe:
  `PROBE 3 Block-Item single-quoted (Zitat): eintraege=[codepaths.ignore-refs="'tools/weg.sh'"] befunde=0` ·
  `PROBE 4 Block-Item single-quoted (Glob): eintraege=[ids.exempt-paths="'tools/**'"] befunde=0` ·
  `PROBE 1 scan.ignore Block-Liste: eintraege=[] befunde=0`. Die Kontrollen liefern je 1 Befund:
  `PROBE 7` (double-quoted Block) und `PROBE 8` (Flow single-quoted).
- `klasse`: Parser-Grenze nennt eine Form als gelesen, die still nichts misst

### F-2 — MEDIUM

- `quelle`: `AGENTS.md` §3.6; Skill MEDIUM „Zusicherung über einer Menge, die leer sein kann"
- `pfad`: `cmd/ai-harness-init/ausnahmegrund_test.go:123-124`; `internal/ausnahmegrund/ausnahmegrund_test.go:62-66`
- `befund`: Der emittierte Fall belegt, dass `.harness/skills/reviewer.md` im Ziel liegt. Er belegt aber
  nicht, dass der Parser aus der emittierten Konfiguration überhaupt einen Eintrag liest, etwa
  `scan.ignore .harness/**`. Liest er ihn nicht (F-1 b), ist `Befunde` leer und der Fall bleibt grün.
  Der Repo-Fall prüft, dass mindestens 10 Einträge gelesen werden. Er prüft aber nicht, dass die
  Treffermenge eines Zitat-Eintrags im Testbaum nicht leer ist. Der Baum ist der Docker-Kontext, und
  `.dockerignore` schneidet ihn nach eigenem Kommentar bewusst zu („braucht nur go.mod + cmd/"). Fiele
  dort `docs/` heraus, liefe jeder `codepaths.ignore-refs`-Eintrag ohne Treffer grün. Fall 579 hält
  das zwar, aber nur im Nacht-Lauf von `make mutate`, nicht im Gate.
- `verifizierbar`: ja (Unit-Test über leerer Eintrags- bzw. Treffermenge)
- `klasse`: Wächter ohne Positiv-Beleg über der gemessenen Menge

### F-3 — MEDIUM

- `quelle`: `AGENTS.md` §3.6 (Fixture/Ausschnitt gegen reale Quelle); Kontext-Eskalation Gate-Pfad
- `pfad`: `.d-check.yml:435-437`; `internal/ausnahmegrund/ausnahmegrund_test.go:53-55`
- `befund`: `codepaths` prüft `.harness/skills/` (Repo-`scan.ignore` nimmt nur `.harness/baseline/**`
  aus), dort liegt `.harness/skills/reviewer.md`. Der Repo-Fall sieht `.harness/` nicht, weil es in
  `.dockerignore` steht, und das Listen-Kommando im Kommentar schließt `':!.harness'` aus. Ein künftiges
  Zitat eines Tombstone-Pfads in `.harness/skills/` würde von `d-check` stumm geschaltet und von keinem
  Wächter gesehen. Die Lücke steht im Testkopf, nicht an der Zusage in `.d-check.yml`
  („internal/ausnahmegrund haelt das gegen den Bestand"). Heute gibt es keinen Treffer
  (`git grep -n -E '<die sieben Pfade>' -- .harness/skills` → leer).
- `verifizierbar`: nein (heute kein Treffer; latent)
- `klasse`: Gate-Zusage in Prosa reicht weiter als ihr Prüfumfang

## Negativbefund (geprüft, ohne Befund)

- **Gegenstand statt Form:** `Treffer` misst Glob-Treffer über dem realen Markdown-Baum bzw.
  Inline-Code-Zitate im Prüfbereich und zählt keine Wörter. Die Zitat-Suche (`` `<pfad> ``) entspricht
  der Präfix-Semantik von `codepaths.roots` (`harness/sensors/docs-check.md:501`). Die 39 relativen
  Nennungen `` `../observations.md` `` in `docs/plan/planning/done/` prüft `codepaths` nicht, sie
  werden also auch nicht stumm geschaltet.
- **Mindest-Tiefe:** Die Herleitung steht an `tiefe()`/`zitatTiefe` (Präfix des Globs, mindestens 2;
  Zitat 4 = Lifecycle-Ebene unter `docs/plan/planning/`). Ein Glob mit ≥ 2 wörtlichen Segmenten nennt
  seinen Baum selbst, wie dort beschrieben.
- **Fixture gegen reale Quelle:** Die Grenze des emittierten Falls („Ein Baum, den nur der reale
  Kurs-Satz traefe, sieht der Fall nicht") steht im Testkopf. Die Orte unter `.harness/` legt der
  reale `run()` an.
- **Mutations-Fälle 579/580 (MR-071, Exklusivität):** Jeder `sed`-Anker trifft genau 1 Zeile im
  Quell-Bestand. Gegenprobe gefahren: Mutation angewandt, `t.Skip` nur im benannten Test, danach
  `go test ./...` im Test-Image. Beide Male ohne `FAIL`, also bindet jeweils allein der benannte Test.
- **§3.7 Kommentare:** In beiden Konfigurationen keine Befund-Kennung, keine Slice-Erzählung, kein
  Lauf-Protokoll. Die alte Messprotokoll-Passage (slice-Liste, „Gemessen (Eintrag entfernt …)") ist
  entfernt. „heute allein unter .harness/baseline/ (git ls-files '*.template.md')" (`.d-check.yml:7`)
  ist ein Zustand mit Kommando und stimmt nachgemessen (`git ls-files '*.template.md' | grep -v
  '^.harness/baseline'` → leer). Der emittierte Kommentar beschreibt Zustand (zwei Bäume, Staging,
  `.harness/state/`).
- **Dogfood vs. emittiert:** Zwei Fälle über zwei Konfigurationen, gemeinsame Regel im Paket. Der
  emittierte Fall fährt drei Lauf-Varianten.
- **§3.2:** keine Inline-Suppression im Diff (`git show f7d87bad 62758f7c | grep -E 'nolint|shellcheck disable'` → leer).
  Der Lint-Fix ist eine Zerlegung in Methoden plus ein externes Testpaket.
- **§3.5:** Die Ausnahme-Mengen sind unverändert, der Diff an beiden Konfigurationen berührt nur
  Kommentarzeilen.

## Sensoren

Formen-Probe und Gegenprobe im Test-Image (`docker build --target test`, `go test`, `--network none`);
Probe-Datei und Mutationen danach zurückgesetzt, `git status` sauber. `make gates` nicht gefahren:
der Lauf ändert allein diesen Report.
