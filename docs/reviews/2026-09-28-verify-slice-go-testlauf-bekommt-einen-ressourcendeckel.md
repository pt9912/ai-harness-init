# Verifikations-Report: slice-go-testlauf-bekommt-einen-ressourcendeckel — 2026-09-28

**Rolle:** Verifier (Modul 11) — DoD-/ADR-Konformität und Plan-vs-Code-Diff an den Planner.
Frischer Kontext, kein Selbst-Verifizieren. Nicht der Reviewer-Maßstab (Diff gegen Plan/ADR/Hard
Rules — das war der Reviewer in drei Runden, `docs/reviews/2026-09-28-slice-go-testlauf-bekommt-einen-ressourcendeckel.md`)
und nicht der Validator.

**Gegenstand:** Slice `slice-go-testlauf-bekommt-einen-ressourcendeckel`
(`docs/plan/planning/in-progress/slice-go-testlauf-bekommt-einen-ressourcendeckel.md`, §1–§8
vollständig gelesen). Commit-Kette `7395c803` → `fb11116f` → `99dfbec3` → `fa94d667` →
`91acbd7a`, danach `a5f1f08c` (nur Review-Report). Keine der übergebenen Behauptungen ungeprüft
übernommen; jede unten berichtete Messung ist selbst gefahren.

**Maßstab:** DoD (§2 des Slice-Plans, drei Liefer-Punkte), `LH-QA-01`/`LH-QA-02`,
`AGENTS.md` §3.6/§3.9, Baseline-Regelwerk Modul 11 (Bewusstes Brechen für
DoD-Testbehauptungen; sicherheits- oder korrektheitskritischer Rot-Beleg trägt der Verifier
nach), Modul 5 (Offene Risiken werden bei Closure aufgelöst), Modul 13 (Hard Rule
Doku-Disziplin).

## Ergebnis

| Punkt | Verdikt |
|---|---|
| DoD-Liefer-Punkt 1 — wirksamer Prozess-/Speicher-Deckel, kein Mount, mutate erbt strukturell | **bestätigt, eigene Messung + Struktur-Nachweis** |
| DoD-Liefer-Punkt 2 — Wächter rot, wenn der Deckel fällt | **bestätigt — Rot und Grün am realen Ort eigenständig gesehen** |
| DoD-Liefer-Punkt 3 — Cache-Zusage umgeschrieben (nicht gelöscht), Wächter decken die NEUE Mechanik | **bestätigt, Anker und expect-Zuordnung einzeln geprüft** |
| `make gates` grün / `make mutate` ohne Befund | **bestätigt auf CI-Basis — Nachlauf des mutate-Sweeps entfällt, weil `91acbd7a` kein Gate-/Wächter-/Test-Verhalten berührt** |
| Doku-Update bei berührtem öffentlichem Vertrag | **bestätigt** (`91acbd7a`: Usage-Block + `docs/user/benutzerhandbuch.md`) |
| F-7 (INFO, Nachtrag 3) — Komposition Override + falsche SHA ungebunden | **berührt keine DoD-Zusage dieses Slice** |
| Plan-vs-Code | **keine unbeanstandete Abweichung; vier über-§3-Posten benannt (siehe unten)** |
| §6-Risiken 1–4 | je ein Ausgang empfohlen — Urteil beim Planner |

## DoD-Liefer-Punkt 1 — wirksamer Deckel, kein Mount, mutate-Erbe

**Bricht, wenn:** die Flags fehlen oder nur anstehen, ohne zu begrenzen; wenn ein Mount die
Isolation unterläuft; oder wenn `make mutate` den Deckel nicht über dieselbe Aufruf-Kette erbt.

1. **Rezept (Baum):** `Makefile:84-85` (`TEST_PIDS_LIMIT ?= 512`, `TEST_MEMORY ?= 1024m`);
   `Makefile:109-111`: `docker build --build-arg GO_VERSION=… --iidfile=/tmp/.ai-harness-test-go-<CURDIR>.iid --target test -t …` →
   `docker run --rm --network none --pids-limit $(TEST_PIDS_LIMIT) --memory $(TEST_MEMORY) "$$(cat …iid)" go test -count=1 ./...`.
   Kein `-v`, kein Mount. `Dockerfile:49-50`: Stufe `test` = `FROM warm AS test` + `COPY . .`,
   **kein** `RUN go test` — der Quellcode kommt per `COPY` ins Image, wie der Plan es verlangt.
2. **Zahlenwahl aus realem Bedarf (`7395c803`-Message):** empirisch bisektioniert — 128 m/32
   Pids scheitern zuverlässig, realer Bedarf der vollen Suite rund 190 MB / 230 Pids auf einem
   20-Kern-Host, 512/1024 m mit Sicherheitsabstand, volle Suite über mehrere Wiederholungen
   stabil. Der Reviewer hat beide Rot-Richtungen unabhängig nachgefahren (32 Pids →
   `fatal error: newosproc`; 128 m isoliert ohne engen pids-Deckel → OOM) — deckungsgleich.
3. **Feste Last, beide Richtungen — eigenständig gefahren (Modul 11):** `make test-go-pids-guard`
   mit aktiven 512 Pids → `ok … internal/resourcecap 2.065s`, exit 0 (die feste Last scheitert
   unter dem Deckel wie erwartet). Dieselbe Last mit entzogenem Deckel → **rot** — siehe
   Liefer-Punkt 2; das ist zugleich der Beleg, dass die feste Last ohne Deckel durchläuft.
4. **Mutate-Erbe strukturell:** `harness/tools/mutate.sh:696-709` liest `# verify:` aus dem
   Fall-Kopf und fährt das genannte Make-Ziel; mindestens zehn Fälle in `test/mutations/`
   tragen `# verify: test-go` (z. B. `315-`, `232-`, `394-…`) und rufen damit genau dieses
   Rezept mit Deckel. Empirisch: der Reviewer fuhr `MUTATE_CASES='163-… 98-teststufe-count'
   make mutate` und sah `test-go`'s `docker build`/`docker run`-Paar tatsächlich aufgerufen.

**Verdikt: bestätigt.**

## DoD-Liefer-Punkt 2 — Wächter am realen Ort rot/grün gesehen

**Bricht, wenn:** der Wächter die gelaufene Verdrahtung nicht trifft (Fixture statt reale
Quelle), oder sein Rot nicht die behauptete Ursache trägt.

- **Form:** `internal/resourcecap/resourcecap_test.go` — Build-Tag `resourcecap` hält die Datei
  aus `go test ./...` heraus (Makefile-Kommentar: Grund — die Last träfe Pakete, die selbst
  Prozesse starten). `forkCount = 700`, fest, nicht rekursiv. Der Test startet eine Shell mit
  700 `sleep 2 &` und erwartet **beobachtet** mindestens einen Fork-Fehler — er misst die
  Eigenschaft (Shell bricht ab), nicht die Konfiguration (kein cgroup-Lesen): §3.6-konform, der
  Testname behauptet die Eigenschaft und misst sie.
- **Verdrahtung:** `make test-go-pids-guard` (`Makefile:123-126`) — eigenes Rezept, eigene
  `--iidfile`-Datei, dieselben `TEST_PIDS_LIMIT`/`TEST_MEMORY`. Präzisierung zur Auftrags-Frage:
  der Wächter ist **kein bats-Fall** (`grep -rln 'test-go-pids-guard' test/` → leer) — er ist
  ein Go-Test hinter einem Make-Ziel. Bewusst **nicht in `make gates`** (`harness/README.md:78`,
  Marke „kein Gate", und `.d-check.yml:178` exempt-targets): er prüft eine Umgebungs- statt
  Code-Eigenschaft, und das ist dort deklariert, nicht verschwiegen.
- **Grün (eigenständig):** `make test-go-pids-guard` → exit 0, `ok … 2.065s`, `--pids-limit 512`
  in der Ausgabe.
- **Rot (eigenständig, am realen Ort):** `make test-go-pids-guard TEST_PIDS_LIMIT=100000` —
  die reale Quelle entzogen (dieselbe Variable, die das Rezept an `docker run` reicht, kein
  Fixture, kein Stellvertreter) — → `FAIL` mit **exakt der behaupteten Ursache**:
  `Ressourcen-Deckel greift nicht: 700 gleichzeitig gestartete Prozesse liefen alle durch
  (Shell endete regulaer) …`, make exit 2. Das Rot trägt die behauptete Ursache, nicht
  irgendeine; `git status` danach leer.

**Verdikt: bestätigt — „mit Deckel grün, ohne Deckel rot" ist damit ein zweites Mal, am
gepinnten Stand dieses Berichts, rot gesehen; der von Hand belegte Nachweis aus `7395c803`
bleibt daneben bestehen.**

## DoD-Liefer-Punkt 3 — Cache-Zusage umgeschrieben, Bewachung auf der neuen Mechanik

**Bricht, wenn:** ein Wächter noch die alte Flag-Form (`--no-cache-filter test`) prüft, oder
die neue Stelle ungebunden bliebe.

- **Wortlaut der Zusage jetzt:** „jeder Lauf misst wirklich neu" — getragen durch `docker run`
  (ein Run wird nie gecacht) + `-count=1` im Makefile-Rezept (`Makefile:111`).
- **`test/dockerfile-teststufe.bats` (vollständig gelesen):** sechs Assertionen — `-count=1` im
  `test-go`-Rezept, `docker run` statt RUN-in-Dockerfile, `--pids-limit`, `--memory`,
  Dockerfile-`test`-Stufe frei von `go test`, warm-Stufe vorhanden. **Keine** Assertion prüft
  die alte Flag-Form — die Bewachung zeigt auf die neue Mechanik, nicht auf eine abwesende.
- **`test/mutations/98-teststufe-count.sh`:** `sed '/^test-go:/,/^$/ s/ -count=1 / /'` — der
  Anker trifft genau die Rezept-Zeile des neuen Ortes; `expect:` nennt die bats-Assertion
  „makefile: der Go-Testlauf (docker run) erzwingt die Test-Ausführung (-count=1)" (Zeile
  17–21 der bats-Datei, existiert, exakt dieser Wortlaut). Real rot gefahren vom Reviewer
  („exakt der im expect-Kopf genannte Fall").
- **`test/mutations/498`/`499`:** entfernen `--pids-limit $(TEST_PIDS_LIMIT)` bzw.
  `--memory $(TEST_MEMORY)` aus dem `test-go:`-Block; beide `expect:`-Zeilen nennen die
  zugehörigen, in der bats-Datei vorhandenen Assertionen; Anker in doppelten
  Anführungszeichen (SC2016). Real rot gefahren vom Reviewer (2 Fälle über `make mutate`).
- **Rotes Gegenbeispiel je Fall benannt:** 98 (Reviewer, real) · 498/499 (Reviewer, real; im
  vollen CI-Sweep enthalten) · Deckel-Wirkung selbst (dieser Report, rot/grün am realen Ort).
- **`-count=1` bleibt:** im Rezept bestätigt; ein Run wird nie gecacht — die erste Ebene ist
  architektonisch, die zweite bleibt bewacht.

**Verdikt: bestätigt.**

## `make gates` / `make mutate` — Beleg-Lage und der fehlende Nachlauf, der keiner ist

- **CI `ci` auf `91acbd7a`: success** (run 36449424445, push, 5m17s) — selbst per `gh run list`
  gezogen, nicht nur übernommen.
- **Voller `mutate`-Sweep (5 Shards, workflow_dispatch 36442261258): success, headSha
  `fa94d667`.** Der Sweep deckt damit **alle verhaltensrelevanten Slice-Commits** —
  `99dfbec3` und `fa94d667` sind in ihm enthalten.
- **`91acbd7a` eigenständig gelesen (Kern-Aufgabe 1):** vier Dateien — Makefile (nur
  `#`-Kommentarzeilen über `test-go`; die Rezept-Zeilen `test-go:`/`docker build`/`docker run`
  sind unveränderte Kontext-Zeilen, per Changed-Line-Filter gegengeprüft: keine einzige
  Nicht-Kommentar-Zeile geändert), `cmd/ai-harness-init/main.go` (Usage-String),
  `docs/user/benutzerhandbuch.md` (eine Tabellenzeile), `internal/fetch/baseline.go`
  (Kommentar). **Kein Gate-, Wächter- oder Test-Verhalten berührt.** Der fehlende Nachlauf
  des Sweeps ist damit keiner — der Sweep bleibt tragend.
- **Drift `91acbd7a` → `a5f1f08c` (HEAD):** `git diff --stat` → genau eine Datei, der
  Review-Report (+109 Zeilen Markdown). Der geprüfte Baumbestand der Liefer-Dateien ist
  identisch.
- **Lokale Stempel:** nicht mein Gegenstand — der Planner fährt `make gates` vor der Closure;
  der Arbeitsbaum ist clean (`git status` leer, auch nach meinen beiden Guard-Läufen).

## F-7 (INFO, Nachtrag 3) — keine DoD-Zusage dieses Slice betroffen

**Faktisch geprüft, nicht nur übernommen:** `internal/fetch/baseline_test.go:191`
(`TestBaseline_SHA256Mismatch_NothingWritten`) bindet die SHA-Prüfung mit injiziertem Fetch;
`cmd/ai-harness-init/main_test.go:960-961` setzt Override **und** passende Summe (`sum` aus dem
real servierten Fixture); kein Test kombiniert Override mit Mismatch — die Befund-Lage stimmt.

**Urteil:** Die Zusage „BASELINE_SHA256 wird unbedingt geprüft, unabhängig von der Fetch-Quelle"
stammt aus der Fix-Doku von `fa94d667` (Konstanten-Kommentar) bzw. aus der in `91acbd7a`
ergänzten Doku — **nicht** aus einer DoD-Zeile dieses Slice. DoD (1)–(3) lauten Deckel,
Wächter, Cache-Zusage; der URL-Override ist Mittel zum Zweck (Erhalt des Unfall-Vektor-Wächters
unter der vom Plan §3 verlangten `--network none`-Isolation). F-7 ist damit eine
Bindungstiefen-Bemerkung zu einer Neben-Zusage, **keine DoD-Verletzung** — er geht als INFO in
die Slice-Closure §7 bzw. ins Beobachtungs-Register, nicht in die DoD-Bilanz.

## §6-Risiken — Ausgangs-Empfehlung

Alle vier Risiken tragen in §6 leere Ausgangs-Felder (Planner-Arbeit bei der Closure). Die
Empfehlungen:

- **Risiko 1 („Ein Deckel, der nicht greift, ist schlimmer als keiner"):** Empfehlung
  **entfallen** — die Sorge ist durch Messung widerlegt: Bisektion in `7395c803`, der
  Reviewer-Nachlauf beider Rot-Richtungen, und in diesem Bericht das eigenständige Rot/grün-Paar
  am realen Ort (entzogener Deckel → lastseitiges Scheitern sichtbar).
- **Risiko 2 („Der zu enge Deckel"):** Empfehlung **entfallen** — gemessener realer Bedarf
  (~230 Pids / ~190 MB) gegen 512/1024 m mit Abstand; volle Suite über Wiederholungen stabil;
  CI grün auf jedem Slice-Commit.
- **Risiko 3 („Cache-Zusage ist der eigentliche Arbeitsanteil"):** Empfehlung **entfallen** —
  die Zusage ist umgeschrieben, beide Wächter (bats + Mutation 98) zeigen auf die neue Mechanik
  und sind real rot gesehen; die Flag-Entfernung ist seit `fb11116f` zusätzlich in `make gates`
  bewacht (498/499 → `test-bats`).
- **Risiko 4 („Wächter misst eine Umgebungs-Eigenschaft"):** Empfehlung **entfallen** — die
  Sorge trifft zu und ist durch Struktur beantwortet: der Wächter ist als „kein Gate"
  deklariert (`harness/README.md` §Werkzeuge, `.d-check.yml` exempt-targets) und stützt als
  einziges Gate-Kriterium nichts; die Flag-Präsenz ist in `make gates` bewacht, die Wirkung ist
  einmalig von Hand belegt und hier erneut gesehen. (Urteil über die Tragfähigkeit beim Planner.)

## Plan-vs-Code-Diff

§3 des Plans (fünf Tabellen-Zeilen) und der Code decken sich:

| Plan-Zeile | Ist | Abweichung |
|---|---|---|
| `Dockerfile` update (Stufe mit Quellcode, ohne `RUN go test`) | `FROM warm AS test` + `COPY . .` | keine |
| `Makefile` (`test-go`) — `docker run --rm --network none --pids-limit … --memory … <image> go test -count=1 ./...`, kein `-v` | exakt; `<image>` über `--iidfile`-Datei | keine — die Bild-Adressierung ist vom Plan als Platzhalter offengehalten |
| Wächter für die Grenze, neu | `internal/resourcecap` + `make test-go-pids-guard` | keine — Sprache/Ort nicht vorgeschrieben |
| `test/dockerfile-teststufe.bats` update | auf `docker run`/`-count=1` umgeschrieben | keine |
| `test/mutations/98-teststufe-count.sh` update | Anker am neuen Ort, `expect` benennt die neue Assertion | keine |
| Zahlenwahl aus realem Bedarf, mit Abstand | 512/1024 m gegen ~230 Pids/~190 MB gemessen | keine — Beleg in der `7395c803`-Message |

**Gebautes-aber-nicht-Geplantes (in beide Richtungen geprüft, alle vier verarbeitet):**

1. **`test-go-pids-guard` als eigenständiges Make-Ziel** nein Registrierung in
   `harness/README.md` (Markierung „kein Gate") und `.d-check.yml` (exempt-targets, Zähl-Korrektur
   18/22 → 19/23): durch die Modul-13-Doku-Disziplin strukturell erzwungen (kein Target ohne
   Deklaration, keine Regel ohne Eintrag) — kein Plan-Verstoß, vom Reviewer als Negativbefund
   „ohne Befund" geprüft.
2. **Mutations-Fälle 498/499:** über den §3-Umfang hinaus — Reaktion auf Review F-1 (MEDIUM,
   Mutate-Lücke). §3.6 verlangte diese Zähne („Zusage ohne rot gesehenes Gegenbeispiel"), der
   Plan-Punkt „mutate erbt nachweislich" allein hätte sie nicht gestellt. Korrekte Ergänzung.
3. **`--iidfile` statt gelesenem `-t`-Namen (`99dfbec3`):** Regression-Fix für den
   Tag-Wettlauf paralleler mutate-Worker; liegt in der Freiheit des Plan-Platzhalters `<image>`
   und erhält die von `plan_self_contained` geforderte Zeilen-Form (Klassifikation bleibt
   LEICHT — vom Reviewer strukturell nachgeprüft).
4. **`AI_HARNESS_INIT_BASELINE_URL_BASE` (`fa94d667`):** der einzige echte Eingriff in
   Produkt-Code über den §3-Plan hinaus. Anlass: die Plan vorgeschriebene `--network none`-Isolation
   brach den bestehenden Unfall-Vektor-Test (der testete via Netz). Der Override ist Opt-in,
   der SHA-Pin bleibt unangetastet (Reviewer in Nachtrag 2 nach Code-Lektüre bestätigt), und die
   Dokumentations-Asymmetrie (F-6, MEDIUM) ist in `91acbd7a` an allen drei Stellen geschlossen.
   Als Abweichung vom Plan benannt und durch Review-Verdikt getragen — nichts davon offene
   Wette auf Zukunft, aber für die Closure §7 festzuhalten.

## Was nur gelesen, nicht gemessen ist

- `make gates` lokal — nicht gefahren (Planner vor Closure; CI-Lauf auf `91acbd7a` grün).
- Volles `make test-go` und volle `make mutate`-Sweep-Wiederholung lokal — nicht gefahren;
  durch die CI-Läufe (ci auf `91acbd7a`, mutate-Sweep auf `fa94d667`) und die realen
  Reviewer-Läufe gedeckt.
- Mutation 98/498/499 nicht eigenständig angewendet — die Anker und `expect:`-Zuordnungen sind
  hier einzeln gegen den Baum geprüft, das reale Rot ist vom Reviewer gefahren und im
  CI-Sweep enthalten; die eigene Rot-Pflicht (Modul 11) habe ich am Deckel-Wächter selbst
  erfüllt, wo der Sweep keinen Zahn trägt (`test-go-pids-guard` ist kein Mutations-Ziel).

## Übergabe an den Planner

**DoD bestätigt: ja — alle drei Liefer-Punkte.** Die DoD-Häkchen in §2 des Slice-Plans sind
(ausdrücklich Planner-Arbeit, §3.10) noch nicht gesetzt; die Closure-Notiz §7, die
Register-Fortschreibung und der `git mv` nach `done/` stehen aus. Hinweise für die Closure:

1. **F-7 (INFO)** geht als benannte Beobachtung oder kleiner Folge-Schritt in §7 — nicht als
   DoD-Verletzung.
2. **Finding-Klassen** aus allen drei Review-Runden in §7 aufnehmen (Mutate-Lücke,
   Kommentar-Klassen ×2, Protokoll-Kommentar, Override-Dokumentation, Komposition-ungebunden).
3. **§6-Risiken** mit den oben empfohlenen Ausgängen (je „entfallen" mit der dortigen
   Begründung) versehen — das Urteil darüber ist Deine Seite der Arbeitsteilung.
4. **`make gates` vor dem `git mv`** frisch fahren (Stop-Hook), da der letzte lokale
   Stempel-Beleg in diesem Bericht nicht geführt wird.
