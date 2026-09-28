# Review-Report: slice-go-testlauf-bekommt-einen-ressourcendeckel — 2026-09-28

**Review-Art:** Code — geprüft gegen Plan + Konventionen (Modul 10 §Drei Review-Arten).

**Gegenstand:** `7395c803` "Rolle Implementer: Go-Testlauf bekommt einen wirksamen
Ressourcen-Deckel (docker run, kein Mount)" (Range `d7389fed..7395c803`)

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 · **Modell:** claude-sonnet-5 ·
**Datum:** 2026-09-28

**Eingangs-Kontext:**

- `docs/plan/planning/in-progress/slice-go-testlauf-bekommt-einen-ressourcendeckel.md`
- `ADR-0003` (Docker-only)
- `LH-QA-01`, `LH-QA-02`
- `AGENTS.md` §3 (Hard Rules), insbesondere §3.6, §3.7, §3.9

---

## Methodik

Alle Kern-Behauptungen wurden real nachgefahren, nicht nur gelesen:

- `test/dockerfile-teststufe.bats` gegen den Baum (grün) und gegen
  `test/mutations/98-teststufe-count.sh` (rot, exakt der im `expect:`-Kopf genannte Fall)
  gefahren — beide Male über das gepinnte bats-Image.
- `internal/resourcecap/resourcecap_test.go` (`TestFesteLastUeberschreitetPidsDeckel`) real
  im gebauten `ai-harness-init:test`-Image gefahren: mit `--pids-limit 512 --memory 1024m`
  grün, ohne beide Flags rot (Ausgabe gelesen, nicht nur Exit-Code).
- Volle Suite (`go test -count=1 ./...`) unter `--pids-limit 512 --memory 1024m` selbst
  gebaut und gefahren: grün, 5,2 s.
- Volle Suite unter `--pids-limit 32 --memory 128m` gefahren: rot (`fatal error: newosproc`),
  bestätigt die im Commit behauptete Messung.
- Speicher-Deckel isoliert geprüft (`--pids-limit 5000 --memory 128m`, ohne engen
  pids-Deckel): rot (`signal: killed`, OOM) — belegt, dass der Speicher-Deckel unabhängig
  vom pids-Deckel wirkt, nicht nur in Kombination.
- `MUTATE_CASES='163-rollentyp-repo-eigener-bezug 98-teststufe-count' make mutate` real
  gefahren: 2 von 2 Fällen ok, `# verify: test-go` löste tatsächlich das neue `test-go`-Rezept
  (Docker-Build + `docker run --pids-limit … --memory …`) aus — empirischer Beleg der
  „erbt strukturell"-Behauptung.
- `make docs-check` (0 Befunde, 2114 Dateien), `make lint` (0 issues), `make shell-lint`
  (clean) real gefahren.
- `git diff --stat` gegen den im Implementer-Bericht genannten Dateisatz abgeglichen —
  deckungsgleich, keine unerwähnten Dateien.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der neue Ressourcen-Deckel (`--pids-limit`/`--memory` im `test-go`-Rezept) hat keinen Mutations-Fall in `test/mutations/`: Eine stille Entfernung beider Flags aus dem Makefile-Rezept würde weder von `make gates` noch von `make mutate` bemerkt — `test-go-pids-guard` ist bewusst „NICHT in gates" und wird auch nicht über einen `# verify: test-go-pids-guard`-Fall vom Mutations-Sensor gefahren. Der Wächter existiert und wurde einmal von Hand rot/grün gesehen (DoD 2, AGENTS.md §3.6 erfüllt), ist aber nicht in den wiederkehrenden Steering-Loop-Zahn eingebunden. | AGENTS.md §3.6 (fehlende Negativtests bei neuem öffentlichen Vertrag) | `Makefile:94-96` (Rezept `test-go`), `test/mutations/` (kein passender Fall) | ja — ein Fall, der `--pids-limit`/`--memory` aus dem `test-go`-Rezept entfernt und `make test-go-pids-guard` als `# verify:` nennt, würde es zeigen | mutate-luecke-bei-neuem-ressourcen-deckel |
| F-2 | LOW | Der Makefile-Kommentar über `test-go` nennt eine entfernte, im Baum nicht mehr existierende Konfiguration beim Namen ("`docker run` wird nie gecacht — das trägt jetzt die Ebene, die zuvor `--no-cache-filter test` hielt") statt nur die geltende Zusage zu nennen. Der übrige Kommentar trägt die Zusage-Klasse sauber; dieser Halbsatz ist überschüssige Chronik neben einer sonst validen Zusage-Aussage (AGENTS.md §3.7, Abgrenzung zu „die frühere Fassung …"). | AGENTS.md §3.7 | `Makefile:87-89` | nein — kein Gate prüft Kommentar-Klassen | kommentar-nennt-entfernte-flag-neben-gueltiger-zusage |
| F-3 | INFO | Der Implementer hat einen vorbestehenden, unabhängigen Zählfehler in derselben `.d-check.yml`-Kommentar-Aufzählung (4 Targets — `smoke-host`, `full-smoke-host`, `artifact-host`, `hooks-install` — stehen in `exempt-targets`, aber in keiner der beiden Prosa-Gruppen (a)/(b)) bewusst nicht mitgenommen, laut Bericht bewusst abgegrenzt. Das ist als Scope-Entscheidung nachvollziehbar (anderer Gegenstand, nicht Teil der DoD), aber die Beobachtung steht nirgends im Repo — weder als Kommentar-Vermerk noch als Beobachtungs-Register-Eintrag —, ist also nach diesem Review-Lauf wieder nur im Lauf-Kontext vorhanden. | Maintainability | `.d-check.yml:150-158` | ja — eigenes `grep`/Handzählung, wie in diesem Review durchgeführt | unbenannte-teilkorrektur-eines-bestandsfehlers |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `Dockerfile` (Stufe `test`: kein `RUN go test` mehr, `COPY . .` bleibt, kein `-v` möglich weil kein Host-Mount vorgesehen) | geprüft, ohne Befund |
| `Makefile` `test-go` (Werte `TEST_PIDS_LIMIT=512`, `TEST_MEMORY=1024m`, Deckel real wirksam, volle Suite läuft real durch) | geprüft, ohne Befund |
| DoD (2) — Wirkungs-Wächter `internal/resourcecap/resourcecap_test.go` (Build-Tag-Ausschluss aus `go test ./...`, real rot/grün nachgefahren) | geprüft, ohne Befund |
| DoD (3) — Cache-Zusage (`test/dockerfile-teststufe.bats` + `test/mutations/98-teststufe-count.sh`, real rot mit Mutation, grün ohne) | geprüft, ohne Befund |
| `make mutate`-Vererbung über `make test-go` (strukturell `harness/tools/mutate.sh:809` + empirisch über Fall 163) | geprüft, ohne Befund |
| Scope-Erweiterung `test-go-pids-guard` + `.d-check.yml`/`harness/README.md`-Einträge (durch Modul 13 Hard Rule strukturell erzwungen, kein Plan-Verstoß) | geprüft, ohne Befund |
| `.d-check.yml`-Zähl-Korrektur "17 von 21" → "19 von 23" (Handzählung nachvollzogen: vor dem Diff bereits fehlerhaft — real 18/22 statt 17/21 —, nach Diff korrekt 19/23) | geprüft, ohne Befund |
| Gate-Lockerung / Netzwerk-Isolation: `--network none` ist im neuen `docker run` explizit gesetzt (strenger als der vorherige `docker build`-Lauf ohne expliziten Netzwerk-Ausschluss) | geprüft, ohne Befund — keine Lockerung |
| `make docs-check`, `make lint`, `make shell-lint` real gefahren | geprüft, ohne Befund |
| Datei-Umfang des Commits gegen den Implementer-Bericht (`git diff --stat`) | geprüft, ohne Befund |
| Slice-Plan-Datei selbst (DoD-Häkchen, §7 Closure-Notiz) — unangetastet in diesem Commit | geprüft, ohne Befund — korrekt, Closure ist Planner-Arbeit (AGENTS.md §3.10), nicht Gegenstand dieses Commits |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** mutate-luecke-bei-neuem-ressourcen-deckel ·
kommentar-nennt-entfernte-flag-neben-gueltiger-zusage ·
unbenannte-teilkorrektur-eines-bestandsfehlers

## Beantwortung der DoD-(2)-Frage des Implementers

**Frage:** Reicht ein einzelner pids-Wächter, oder verlangt DoD (2) zwingend auch einen
Speicher-Wächter?

**Antwort:** Der Wortlaut von DoD (2) operationalisiert die Anforderung *singulär* und
*konkret*: "Ein Test, der eine feste Zahl gleichzeitiger Prozesse startet und deren
Scheitern erwartet: mit Deckel grün, ohne Deckel rot." Das ist exakt das, was
`internal/resourcecap/resourcecap_test.go` liefert — kein Wortlaut in DoD (2) verlangt
einen zweiten, speicherbasierten Wächter. "Die Grenze" (Singular) im ersten Satz von DoD
(2) ist mit dem so operationalisierten Prozess-Wächter erfüllt. Der einzelne pids-Wächter
**erfüllt DoD (2) buchstabengetreu** — das ist kein HIGH und kein Blocker.

Das ändert nichts an der separat gefundenen Lücke (F-1): DoD (1) verspricht einen
"Prozess- **und** Speicher-Deckel", und der Speicher-Anteil ist real wirksam (von mir
unabhängig nachgemessen, OOM bei 128m auch ohne engen pids-Deckel), aber **ohne
automatisierten Regressions-Wächter im Steering-Loop** (`make mutate`/`make gates`) — nur
der pids-Anteil hat einen Fall, und selbst der ist nicht an `make mutate` angebunden.
Das ist der Gegenstand von F-1, nicht von der DoD-(2)-Frage selbst.

## HIGH mit Rollen-Widerspruch

Keiner. Der Implementer hat die DoD-(2)-Frage zur Bestätigung vorgelegt, nicht als
Widerspruch gegen ein Review-Finding — es gibt keine gegenläufige Position zwischen
Implementer und Reviewer, die den Konflikt-Pfad aus Modul 8 §Konflikt-Pfad auslösen würde.

## Verdikt

**Merge-blockierend:** nein. Keine HIGH-Findings; ein MEDIUM (F-1, Mutate-Lücke beim
neuen Ressourcen-Deckel) und ein LOW (F-2, überschüssige Chronik in einem Kommentar) sind
vor der Slice-Closure zu klären bzw. zu beheben, blockieren aber nicht zwingend den Merge
dieses Commits — beide sind über einen kleinen Folge-Schritt (Mutations-Fall ergänzen bzw.
Kommentar kürzen) lösbar, ohne den gelieferten Deckel selbst zu ändern. Alle drei
Plan-DoD-Punkte (1)-(3) sind real, nicht nur behauptet, belegt.

**Übergabe:** Findings gehen an den Implementer. Die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Zähler. Dieser Report ist Lauf-Beleg und ersetzt
keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
