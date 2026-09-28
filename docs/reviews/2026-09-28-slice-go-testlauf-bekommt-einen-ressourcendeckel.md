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

---

## Nachtrag — Nachrunde zu Commit `fb11116f`

**Gegenstand:** `fb11116f` "Rolle Implementer: Ressourcendeckel bekommt einen
Mutations-Wächter, Kommentar auf Ist-Zustand gekürzt" — Implementer-Reaktion auf F-1
(MEDIUM) und F-2 (LOW) dieses Reports.

### Methodik (Nachtrag)

Real nachgefahren, nicht nur gelesen:

- `Makefile`-Rezepte `test-go` (Zeile 93-96) und `test-go-pids-guard` (Zeile 104-106)
  gelesen und die Widerlegung strukturell nachvollzogen: eine `sed`-Mutation mit dem Bereich
  `/^test-go:/,/^$/` gegen eine Kopie des realen Makefiles gefahren (beide neuen Fälle
  einzeln) — betroffen ist ausschließlich Zeile 95 (`test-go`s eigener `docker run`),
  Zeile 106 (`test-go-pids-guard`s eigener, separat geschriebener `docker run` mit eigenen
  `--pids-limit $(TEST_PIDS_LIMIT) --memory $(TEST_MEMORY)`) bleibt unverändert.
- `MUTATE_CASES='498-testgo-pids-limit-entfernt 499-testgo-memory-limit-entfernt' make mutate`
  real gefahren (Hintergrundlauf, `docker` real): **2 ok, 0 Befund(e)** — beide Fälle färben
  exakt die im `# expect:`-Kopf genannte bats-Assertion rot, Sensor `test-bats` (narrow,
  korrekt aus `narrow_sensor` abgeleitet, da `# expect:` keinen `Test[A-Z]*`-Namen trägt).
- Beide `sed`-Anker der neuen Fälle gegen den realen `Makefile`-Bestand geprüft (Kopie +
  `diff`): beide treffen exakt die Ziel-Zeile, kein Fehlschlag, keine Nebenwirkung auf
  andere Zeilen — MR-071-konform (Anker gegen den Quell-Bestand, nicht gegen eine
  angenommene Fassung).
- `make test-bats` real gefahren: 442/442 grün, darunter die zwei neuen Assertionen
  (`ok 114`/`ok 115`), keine `not ok`-Zeile.
- `git show fb11116f -- Makefile` gelesen; `Makefile:160-165` (`release-artifacts`-Kontext)
  separat gelesen und per `git blame` gegen den Diff geprüft.
- `grep shellcheck disable` auf die zwei neuen Mutationsfälle und `Makefile` — keine
  Suppression; `make shell-lint` real gefahren, clean.
- `ls test/mutations/ | sort -t- -k1 -n | tail` — Numerierung 498/499 lückenlos
  fortgesetzt, keine Kollision.

### Prüfung der vier Punkte

**1. Trägt die Widerlegung des ursprünglichen Vorschlags?** Ja, real bestätigt. Anders als
im ursprünglichen Report vermutet, ist `test-go-pids-guard` **kein** Aufrufer von
`test-go`: Es ist ein eigenes Rezept mit einer eigenen, textuell separaten
`docker run`-Zeile (Zeile 106), die dieselben Variablen `$(TEST_PIDS_LIMIT)`/
`$(TEST_MEMORY)` referenziert, aber unabhängig geschrieben ist. Eine auf den
`test-go:`-Block begrenzte Mutation (Bereich bis zur nächsten Leerzeile) erreicht Zeile 106
strukturell nicht — bestätigt durch reale `sed`-Anwendung gegen eine Kopie des Makefiles.
Der im vorigen Report skizzierte Lösungsweg (Mutation gegen `test-go`, Verify über
`test-go-pids-guard`/`resourcecap_test.go`) hätte den Wächter also nie rot gefärbt. Der
Implementer hat richtig erkannt und richtig widerlegt.

**2. Trägt der neue Ansatz?** Ja. Baseline grün (442/442), beide Mutationen einzeln real
rot mit exakt der erwarteten Zeile (`# expect:`-Text), kein Fall färbt eine andere
Assertion. MR-071-Konformität real geprüft: beide `sed`-Anker matchen den tatsächlichen
Makefile-Bestand exakt (nicht eine angenommene oder frühere Fassung).

**3. Schließt das beide Anteile von F-1 (pids UND memory)?** Ja — zwei unabhängige
bats-Assertionen, zwei unabhängige Mutationsfälle, beide über `test-bats` → `test` →
`record-gates` → `gates` strukturell in `make gates` eingebunden (`gates: record-gates`,
`record-gates: … test …`, `test: test-bats test-go`, real nachvollzogen). Eine stille
Entfernung einer der beiden Flags aus dem `test-go`-Rezept würde jetzt `make gates` rot
färben. Keine benannte Lücke bleibt zu F-1 offen; F-1 gilt als behoben.

**4. F-2 — Kommentar auf Ist-Zustand gekürzt?** Ja, an der Fundstelle (`Makefile:87-89`
alt, jetzt 87-88): Die Chronik-Nennung "das trägt jetzt die Ebene, die zuvor
`--no-cache-filter test` hielt" ist entfernt; der verbleibende Text beschreibt nur noch
die geltende Zusage. F-2 gilt als behoben.

Die bewusst **nicht** angefasste Nachbar-Stelle (`Makefile:160-165`, Kommentar über
`--no-cache-filter build` im `release-artifacts`-Kontext, Zeile 163: "Dieselbe Begründung
wie beim `--no-cache-filter test` des test-Targets") ist real dieselbe Fehlerklasse wie
F-2: `--no-cache-filter test` existiert im `test-go`-Rezept seit Commit `7395c803`
(2026-09-28) nicht mehr — der Vergleichssatz zeigt seither auf eine abwesende
Konfiguration. `git blame` bestätigt: Zeile 163 stammt aus Commit `e34ef1de2`
(2026-09-19) und wurde weder von `7395c803` noch von `fb11116f` berührt — sie ist
**Bestand** relativ zu beiden geprüften Commits. Die Entscheidung, sie in `fb11116f`
nicht anzufassen, ist eine **korrekte Abgrenzung**: §3.7-Cutoff bindet den Kommentar, der
*geschrieben oder geändert* wird, nicht den, dessen referenzierter Gegenstand sich an
anderer Stelle ändert; und der Fund liegt außerhalb des Diffs von `fb11116f` (das nur
Makefile-Zeilen 87-89 berührt) wie auch außerhalb des Umfangs von F-1/F-2 selbst.

Diese Stelle wurde im ursprünglichen Review-Lauf (gegen `7395c803`) **nicht** gefunden —
sie ist ein Fund dieser Nachrunde, kein neuer durch `fb11116f` erzeugter Verstoß. Sie wird
darum als eigenständiges, nicht merge-blockierendes Finding dieser Nachrunde geführt (siehe
F-4 unten), nicht als Fortsetzung von F-2.

**5. Scope-Check:** Kein Creep. Vier geänderte Dateien, alle direkt F-1/F-2 zugeordnet
(`Makefile`, `test/dockerfile-teststufe.bats`, zwei neue `test/mutations/*.sh`). Die
SC2016-Anpassung (doppelte statt einfache Anführungszeichen im `sed`-Aufruf, analog zu
`test/mutations/264`) ist eine notwendige Konsequenz der neuen Fälle, kein eigenständiger
Umbau. Kein Plan-Abschnitt wurde über den zwei Findings hinaus berührt.

### Neue Findings dieser Nachrunde

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-4 | LOW | `Makefile:163` vergleicht die Begründung von `--no-cache-filter build` mit "`--no-cache-filter test` des test-Targets" — dieser Vergleichsgegenstand existiert seit `7395c803` nicht mehr (Zeile ist seit `e34ef1de2`, 2026-09-19, unverändert, also Bestand relativ zu `7395c803`/`fb11116f`, aber inhaltlich seit `7395c803` unzutreffend). Gleiche Fehlerklasse wie das ursprüngliche F-2, andere Fundstelle; im ursprünglichen Review-Lauf übersehen. | AGENTS.md §3.7 | `Makefile:163` | nein — kein Gate prüft Kommentar-Klassen | kommentar-vergleich-referenziert-entfernte-flag-an-zweiter-stelle |

### Negativbefunde (Nachtrag)

| Bereich | Ergebnis |
|---|---|
| `test-go-pids-guard`-Isolation von `test-go`-Mutation (reale `sed`-Kopie + `diff`) | geprüft, ohne Befund — bestätigt die Widerlegung |
| `make mutate` mit `MUTATE_CASES=498,499` (real, Docker) | geprüft, ohne Befund — 2 ok, 0 Befund(e) |
| MR-071-Konformität beider neuer `sed`-Anker gegen den realen Makefile-Bestand | geprüft, ohne Befund |
| `make test-bats` Vollsuite (442/442) inkl. der zwei neuen Assertionen | geprüft, ohne Befund |
| `make shell-lint` sowie Suppression-Scan auf die neuen Dateien | geprüft, ohne Befund |
| Numerierung/Kollision der neuen Mutationsfälle (498/499) | geprüft, ohne Befund |
| Scope des Commits (`git show --stat fb11116f`) gegen F-1/F-2 | geprüft, ohne Befund |
| F-2-Fundstelle (`Makefile:87-89`, jetzt gekürzt) | geprüft, ohne Befund — behoben |

### Aktualisiertes Verdikt

**Merge-blockierend: nein.** F-1 (MEDIUM) und F-2 (LOW) aus der ersten Runde sind real
behoben und real verifiziert — kein HIGH, keine offene Lücke zu den zwei ursprünglichen
Findings. Die Nachrunde selbst trägt ein neues LOW (F-4, an einer vom Diff nicht berührten
Bestandsstelle), das ebenfalls nicht merge-blockierend ist und vor der Slice-Closure als
eigener kleiner Folge-Schritt oder als benannte Beobachtung zu führen ist, damit die
Fehlerklasse nicht ein zweites Mal unbenannt bleibt.

**Finding-Klassen dieser Nachrunde:** kommentar-vergleich-referenziert-entfernte-flag-an-zweiter-stelle

**Übergabe:** F-4 geht an den Implementer bzw. in die Slice-Closure §7. Dieser Nachtrag
ersetzt nicht die Verifikation (Modul 11).

---

## Nachtrag 2 — Zwei Folge-Fixes: Tag-Wettlauf (`99dfbec3`) und Netz-Isolations-Regression (`fa94d667`)

**Gegenstand:**
- `99dfbec3` "Rolle Implementer: test-go/test-go-pids-guard lesen das Docker-Image ueber --iidfile statt ueber den geteilten -t-Namen"
- `fa94d667` "Rolle Implementer: Unfall-Vektor-Waechter haelt unter --network none seine Zaehne"

### Methodik (Nachtrag 2)

Real nachgefahren, nicht nur gelesen — inklusive eines eigenen, unabhängigen
Rot/Grün-Zyklus gegen den realen Baum (nicht nur den Implementer-Beleg gelesen):

- `Makefile` (`test-go`, `test-go-pids-guard`) gelesen: beide Rezepte nutzen jetzt
  `docker build --iidfile=<eindeutiger Pfad>` + `docker run "$$(cat <Pfad>)" …` statt eines
  gelesenen `-t ai-harness-init:test`-Namens. Der `-t`-Tag bleibt zusätzlich gesetzt
  (Mensch-Komfort), trägt aber nachweislich kein Urteil mehr — der `run`-Aufruf liest
  ausschließlich über die `.iid`-Datei.
- `make --no-print-directory -n test-go` / `test-go-pids-guard` real gefahren (kein `MAKEFLAGS`-
  Störeinfluss) und die Ausgabe gegen `harness/tools/mutate.sh`s `plan_self_contained` gelesen:
  beide Zeilen beginnen nach Abzug führender Variablen-Zuweisungen weiterhin mit
  `docker build` bzw. `docker run` — die neue `"$$(cat …)"`-Kommandosubstitution steht als
  drittes+ Wort der `run`-Zeile und ändert die Klassifikation nicht. Damit bleiben beide Modi
  strukturell `LEICHT` (parallelfähig), wie im Commit behauptet — durch Lektüre der
  Erkennungsfunktion selbst bestätigt, nicht nur durch die im Commit zitierte
  `plan_self_contained`-Ausgabe.
- `docker build --iidfile=<pfad>` gegen ein bereits mit Alt-Inhalt belegtes Pfad-Ziel real
  gefahren (eigener Wegwerf-Dockerfile): die Datei wird bei jedem erfolgreichen Build
  überschrieben, kein Anhäng-/Kollisions-Verhalten — ein liegen gebliebener `.iid`-Rest aus
  einem vorherigen Lauf verfälscht den nächsten `run` nicht.
- **Eigener Rot/Grün-Zyklus gegen den realen Baum** (nicht nur den Implementer-Bericht
  übernommen): `test/mutations/378-init-argumentlos-bricht-aber-schreibt.sh` angewandt,
  `make test-go` real unter `--network none` gefahren → `TestUnfallVektor_OhneArgumentImRepoWurzel`
  fällt mit exakt der im Fall-Kopf erwarteten Meldung ("das stehende Repo wurde angefasst …
  der Unfall fuhr wieder"); Mutation zurückgesetzt, `make test-go` erneut gefahren → grün,
  8/8 Pakete ok. Danach zusätzlich `test/mutations/377-init-argumentlos-stiller-init.sh`
  angewandt und real gefahren → derselbe Test fällt mit **mehr** roten Assertionen als bei
  377 zuvor beschrieben (zusätzlich `TestRun_OhneZielordnerBrichtLaut` sowie zwei weitere
  Prüfzeilen innerhalb von `TestUnfallVektor…`, u. a. eine neue, im Container erwartungsgemäß
  scheiternde `docker`-Weiterreichung) — keine Regression, strengerer Fang, wie vom
  Implementer berichtet; Mutation zurückgesetzt, Baum wieder sauber (`git status --short` leer).
- `internal/fetch/baseline.go` vollständig gelesen: `Baseline()` (Produktionscode, von
  `main.go:492` mit `src.baselineSHA`/`src.baseline` aufgerufen) prüft den sha256 **immer**
  gegen das übergebene `wantSHA` — unabhängig davon, ob `fetch` (`AssetFetch`) über den neuen
  URL-Override umgeleitet wurde oder nicht. Der Override wirkt ausschließlich in
  `DownloadBaseline()` (welche URL geholt wird), nie im Vergleich selbst.
- `cmd/ai-harness-init/main_test.go` gelesen: der Testserver liefert das reale Fixture-Asset,
  `sum` wird aus **genau diesem** Inhalt berechnet und als `BASELINE_SHA256` gesetzt — die
  SHA-Prüfung ist im Test-Override also nicht umgangen, sondern korrekt gegen den servierten
  Inhalt geführt.
- `grep -rn AI_HARNESS_INIT_BASELINE_URL_BASE` über `*.go`/`*.md`: die Variable erscheint
  ausschließlich in der Konstante, im Test-Kommentar und im Testaufruf selbst — **nicht** in
  `main.go`s `Usage()`-Block "Umgebung (bewusster Opt-in-Override der gepinnten Werte —
  LH-QA-02)", der `COURSE_TAG`, `BASELINE_SHA256`, `DCHECK_IMAGE`, `DCHECK_DIGEST`,
  `A_CHECK_IMAGE`, `A_CHECK_DIGEST`, `SKEL_<LANG>_VERSION` listet, und nicht in
  `docs/user/` oder `AGENTS.md`.
- `git status --short` nach allen eigenen Mutations-Anwendungen: leer (Baum sauber
  zurückgesetzt, keine Nebenwirkung dieses Review-Laufs im Commit-Bestand).

### Prüfung der fünf Punkte

**1. Tag-Race-Fix trägt strukturell.** Bestätigt durch eigene Lektüre von
`plan_self_contained` (`harness/tools/mutate.sh:1045-1073`) und durch einen realen
`make -n`-Trockenlauf beider Rezepte: Erkennung bleibt `docker build`/`docker run` je Zeile,
`LEICHT`/parallelfähig unverändert. Die im Commit referenzierte Busybox-Mikroreproduktion und
der vierfache `git worktree`-Realnachweis wurden nicht erneut gefahren (kostenintensiv,
extern reproduziert) — die **strukturelle** Behauptung (Klassifikation bleibt `LEICHT`) wurde
jedoch unabhängig verifiziert, nicht nur gelesen.

**2. Netz-Isolations-Fix — sicherheitskritisch.** Das Ergebnis ist differenziert:

- **Der SHA-Pin ist NICHT umgangen.** `Baseline()` verifiziert `wantSHA` unbedingt, unabhängig
  von der Fetch-Quelle; der Test-Override berechnet die erwartete Summe aus dem real
  servierten Inhalt. Ein Angreifer, der **nur** die URL umleitet, ohne auch `BASELINE_SHA256`
  zu kontrollieren, erhält einen `SHA256Mismatch` und keinen stillen Erfolg.
- **`AI_HARNESS_INIT_BASELINE_URL_BASE` ist real ein reiner Opt-in — aber kein reiner
  Test-Build-Hook.** Er ist nicht hinter einem Build-Tag verborgen, sondern fester Bestandteil
  von `DownloadBaseline()`, der Funktion, die `main.go:709` als produktiven Fetcher
  verdrahtet. Jeder, der die Umgebung des Prozesses kontrolliert (Shell, CI-Workflow-`env:`,
  Wrapper-Skript), kann ihn setzen — dieselbe Voraussetzung, die für die **bereits
  bestehenden** Overrides `COURSE_TAG`/`BASELINE_SHA256` gilt und die dieses Repo unter
  LH-QA-02 ausdrücklich als "bewussten Opt-in" akzeptiert. Insofern ist die Behauptung "kein
  Weg für einen echten Nutzer/Angreifer" streng genommen falsch — richtig ist: **kein neuer
  Weg über die bestehende Sicherheits-Schranke (den SHA-Pin) hinaus**, aber eine reale
  Erweiterung der Reichweite eines bereits akzeptierten Override-Mechanismus von "beliebiger
  Tag/Hash **innerhalb** des fest verdrahteten `github.com/pt9912/ai-harness-course`-Release-
  Pfads" auf "beliebiger Tag/Hash **von einer beliebigen URL**". Vor diesem Commit hätte ein
  Angreifer mit Env-Kontrolle zwar `BASELINE_SHA256`/`COURSE_TAG` frei wählen können, aber
  weiterhin nur Inhalte akzeptiert bekommen, die tatsächlich unter dem fest verdrahteten
  GitHub-Repo veröffentlicht sind — er bräuchte dafür Schreibzugriff auf ein fremdes Repo. Mit
  dem neuen Override genügt derselbe Env-Zugriff, um **beliebigen** selbst gehosteten Inhalt
  unterzuschieben, solange auch der passende Hash mitgesetzt wird. Das ist dieselbe
  Angreifer-Voraussetzung, aber eine größere Konsequenz bei Erfüllung.
- **Kommentar korrekt, Dokumentation asymmetrisch.** Der Kommentar auf der Konstante
  (`internal/fetch/baseline.go:80-91`) beschreibt akkurat, was die Variable ist, ihren
  einzigen vorgesehenen Konsumenten und das Produktions-Verhalten (leer = gepinnter Default)
  — AGENTS.md §3.7-konform. Es gibt jedoch **keine** Dokumentations-Pflicht-Verletzung im
  engen Sinn (keine Spec-/ADR-Stelle verlangt, jeden Override im `--help`-Text zu listen);
  die Lücke ist eine **Inkonsistenz zum etablierten Muster** dieses Repos: alle bisherigen
  "bewussten Opt-in-Overrides" (`COURSE_TAG`, `BASELINE_SHA256`, `DCHECK_IMAGE` …) stehen im
  `Usage()`-Block, dieser — mit identischem Wirkradius auf denselben Fetch-Pfad — bewusst
  nicht. Ein Audit, der sich auf `ai-harness-init --help` verlässt, um alle
  vertrauensrelevanten Override-Variablen zu kennen, sieht diese nicht. Das ist der
  eigentliche, real bestehende Befund (siehe F-6 unten) — nicht ein Bruch des SHA-Pins.

**3. Mutation 378 real nachvollzogen.** Siehe Methodik: eigener Rot/Grün-Zyklus, Meldung
gelesen (nicht nur Exit-Code) — deckt sich exakt mit dem im Fall-Kopf benannten `expect`.

**4. Mutation 377 plausibilisiert.** Real gefahren (nicht nur gelesen): zusätzliche, vorher
nicht auftretende Fehlschläge (`TestRun_OhneZielordnerBrichtLaut` sowie zwei weitere
Prüfzeilen) bestätigen "strengerer Fang, keine Regression".

**5. AGENTS.md §3.6/§3.7 der neuen Kommentare.**

§3.6 (rot gesehenes Gegenbeispiel als **Handlung**) ist für beide Commits real erfüllt — vom
Implementer laut Commit-Message und von diesem Review unabhängig nachvollzogen (Mutation 378,
zusätzlich 377).

§3.7 (Kommentar beschreibt, was da ist) ist **nicht durchgehend** erfüllt:

- `internal/fetch/baseline.go:80-91` (Kommentar auf `baselineURLBaseOverrideEnv`): sauber —
  Zusage, Kopplung (nennt den einzigen Konsumenten-Test), Grenze (Produktionsverhalten) und
  ein korrekt geformter Herkunfts-Anker (`seit slice-go-testlauf-bekommt-einen-
  ressourcendeckel`).
- `Makefile:102-111` (Kommentar auf `test-go`): der Haupttext ist eine gültige
  Grenze-Beschreibung ("ohne `--iidfile` läse `docker run` den zuletzt geschriebenen
  `-t`-Namen — … das Urteil wäre falsch, nicht nur verzögert"), **aber** die eingeschobene
  Klammer "(real reproduziert: vier von fünf `make mutate`-Shards zeigten genau dieses Bild,
  ein anderer Test als der erwartete fiel; ein isolierter Mikro-Versuch … traf denselben
  ungültigen Namen in rund 58 % der Fälle, 0 % mit `--iidfile`)" berichtet das **Protokoll
  eines konkreten Diagnose-Laufs** — exakt die Kommentar-Klasse, die AGENTS.md §3.7 als
  "Falsch" benennt ("Was hier und heute REAL rot gesehen wurde …" — Perfekt, an einen
  bestimmten Lauf gebunden). Die Zahl selbst ist zudem intern nicht konsistent: die
  Commit-Message desselben Commits nennt für die (offenbar identische) Mikro-Reproduktion
  "143/240 Fehlzuordnungen (~60 %)" — 143/240 ≈ 59,6 %, der Makefile-Kommentar spricht von
  "rund 58 %". Ob es sich um zwei separate Läufe mit natürlicher Streuung handelt oder um
  einen Transkriptionsfehler, ist von hier aus nicht entscheidbar — genau das Symptom, das
  entsteht, wenn Lauf-Protokoll statt Zustand in einem Kommentar landet: die Zahl ist im
  Diff dupliziert (Commit-Message + Makefile-Kommentar) und kann bei der nächsten
  Nachmessung auseinanderlaufen, ohne dass ein Gate es bemerkt. Das eigentliche Fehlverhalten
  ("Angreifer-`docker run` liest den fremden Tag") ist bereits im Hauptsatz ohne Zahlen
  vollständig und korrekt beschrieben — die Klammer trägt nichts zur Zusage bei, nur Chronik.

### Neue Findings dieser Nachrunde

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-5 | LOW | Der `test-go`-Kommentar trägt eine Klammer-Passage, die das Protokoll eines konkreten Diagnose-Laufs berichtet ("real reproduziert: vier von fünf … Shards …", "rund 58 % der Fälle") statt nur die geltende Zusage/Grenze zu beschreiben — dieselbe Kommentar-Klasse wie das bereits im ersten Review-Lauf gefundene und behobene F-2/F-4 (Chronik statt Zustand), hier als „Protokoll eines Laufs" statt als „abwesender Text". Die zitierte Zahl ist zudem intern inkonsistent mit der Commit-Message desselben Commits (58 % vs. ~60 % für scheinbar dieselbe Messung). Einordnung als LOW konsistent mit der Einordnung von F-2/F-4 in diesem Report für dieselbe Kommentar-Fehlerklasse. | AGENTS.md §3.7 | `Makefile:103-105` | nein — kein Gate prüft Kommentar-Klassen | kommentar-traegt-protokoll-eines-diagnose-laufs |
| F-6 | MEDIUM | Der neue, produktiv verdrahtete Override `AI_HARNESS_INIT_BASELINE_URL_BASE` (`internal/fetch/baseline.go:91`, gelesen in `DownloadBaseline()`, die `main.go:709` als produktiven Fetcher registriert) fehlt im `main.go`-`Usage()`-Block „Umgebung (bewusster Opt-in-Override der gepinnten Werte — LH-QA-02)", der alle strukturell gleichartigen Geschwister-Overrides (`COURSE_TAG`, `BASELINE_SHA256`, `DCHECK_IMAGE`, `DCHECK_DIGEST`, `A_CHECK_IMAGE`, `A_CHECK_DIGEST`, `SKEL_<LANG>_VERSION`) listet. Der SHA-Pin bleibt unverändert wirksam und wird durch den neuen Override nicht umgangen — aber ein Angreifer mit derselben Env-Kontrolle, die für die bestehenden Overrides bereits als akzeptiertes Risiko geführt wird, kann jetzt zusätzlich die Fetch-**Quelle** frei wählen (vorher: nur Tag/Hash **innerhalb** des fest verdrahteten GitHub-Release-Pfads), was die Konsequenz bei Ausnutzung von „inhaltlich begrenzt" auf „beliebiger selbst gehosteter Inhalt" erweitert. Ein Audit, der sich auf `--help` verlässt, um alle vertrauensrelevanten Overrides zu kennen, übersieht diesen. | AGENTS.md §3.7 (Kommentar korrekt) / Reproduzierbarkeits- und Trust-Boundary-Risiko (LH-QA-02) | `internal/fetch/baseline.go:80-99`, `cmd/ai-harness-init/main.go:90-118` (Usage-Block ohne Eintrag) | ja — `grep AI_HARNESS_INIT_BASELINE_URL_BASE cmd/ai-harness-init/main.go` bleibt leer | undokumentierter-produktiver-fetch-override-asymmetrisch-zu-geschwistern |

### Negativbefunde (Nachtrag 2)

| Bereich | Ergebnis |
|---|---|
| `plan_self_contained`-Klassifikation beider neuer Rezepte (`make -n` real + Funktionslektüre) | geprüft, ohne Befund — bleibt `LEICHT` |
| `--iidfile`-Überschreibverhalten bei vorbelegtem Pfad (reale Docker-Probe) | geprüft, ohne Befund — überschreibt sauber, kein Kollisions-/Anhäng-Risiko |
| Eigener `.iid`-Dateiname je Rezept (`test-go` vs. `test-go-pids-guard`) gegen Kollision bei sequenziellem Lauf in derselben Baumkopie | geprüft, ohne Befund |
| SHA256-Pin in `fetch.Baseline()` gegen den URL-Override (Code-Lektüre: `wantSHA`-Vergleich unbedingt) | geprüft, ohne Befund — nicht umgangen |
| SHA256-Pin im Test-Override (`main_test.go`: Summe aus real serviertem Fixture-Inhalt) | geprüft, ohne Befund — nicht umgangen |
| Mutation 378 real rot (Fall angewandt) / real grün (zurückgesetzt) gegen `make test-go` unter `--network none` | geprüft, ohne Befund — deckt sich mit dem Implementer-Beleg |
| Mutation 377 real rot, Vergleich der Fehlschlags-Breite gegen den Implementer-Bericht | geprüft, ohne Befund — strengerer Fang bestätigt, keine Regression |
| Arbeitsbaum nach allen eigenen Mutations-Anwendungen (`git status --short`) | geprüft, ohne Befund — sauber zurückgesetzt |
| `AI_HARNESS_INIT_BASELINE_URL_BASE` in `docs/user/`, `AGENTS.md`, `harness/README.md` | geprüft, ohne Befund im positiven Sinn — taucht nirgends auf (Grundlage für F-6, kein zusätzlicher Fund) |

### Aktualisiertes Gesamt-Verdikt (nach Nachtrag 2)

**Merge-blockierend: nein.** Keine HIGH-Findings in `99dfbec3` oder `fa94d667`. Der
Tag-Wettlauf-Fix trägt strukturell und real geprüft (eigener Rot/Grün-Zyklus für die
Netz-Isolations-Regression, nicht nur der Implementer-Beleg gelesen). Der sicherheitskritische
Punkt (Netz-Isolations-Fix / neuer URL-Override) hält die entscheidende Schranke — den
SHA256-Pin — unangetastet; der reale, benennbare Befund ist die **Dokumentations-Asymmetrie**
zu den Geschwister-Overrides (F-6, MEDIUM), nicht ein Bruch der Integritätsprüfung. F-5 (LOW)
ist ein kleiner Kommentar-Form-Fehler, konsistent zur bereits in diesem Report etablierten
Einordnung derselben Fehlerklasse (F-2/F-4).

Offen vor der Slice-Closure: F-5 (Klammer-Passage aus dem Makefile-Kommentar entfernen, Zahl
ggf. in der Commit-Message belassen) und F-6 (Override entweder in `main.go`s `Usage()`-Block
aufnehmen — konsistent mit den Geschwister-Overrides — oder explizit als bewusste Ausnahme mit
Begründung dort vermerken, damit ein `--help`-Audit ihn nicht übersieht).

**Finding-Klassen dieser Nachrunde:** kommentar-traegt-protokoll-eines-diagnose-laufs ·
undokumentierter-produktiver-fetch-override-asymmetrisch-zu-geschwistern

**Übergabe:** F-5/F-6 gehen an den Implementer bzw. in die Slice-Closure §7. Dieser Nachtrag
ersetzt nicht die Verifikation (Modul 11); die sicherheitsrelevante Einordnung von F-6 (real
kein SHA-Pin-Bruch, aber reale Reichweiten-Erweiterung eines akzeptierten Override-Musters)
ist für den Verifier/Architect-Kontext hervorgehoben, falls dort eine ADR- oder
Hard-Rule-Einordnung gewünscht wird.
