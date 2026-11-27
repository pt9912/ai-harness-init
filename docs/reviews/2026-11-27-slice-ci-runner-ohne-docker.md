# Review — slice-ci-runner-ohne-docker

**Datum:** 2026-11-27
**Diff:** `3dfd114d..cd50eff4` (7 Implementer-Commits: `381f2a0e`, `61d089ed`, `cd835db5`,
`86807aec`, `ee3bb1e0`, `d5dab8e6`, `cd50eff4`)
**Plan:** `docs/plan/planning/in-progress/slice-ci-runner-ohne-docker.md`
**ADRs im Geltung:** ADR-0109 (Pflicht-Weg docker-los, Image opt-in), ADR-0003
(Release-Bau bleibt docker-getrieben); MR-014 (CI frischer Klon), MR-071/MR-090
(Fall-Anlage); Hard Rules §3.5, §3.6, §3.7, §3.9.
**Grenze:** Review prüft Code gegen Plan und ADRs (Modul 10); die DoD-Abhakung
(Liefer-Punkte 1–3, Verifikations-Bericht) prüft die Verifikation.

## Findings

### F-1 — Die „eine Quelle"-Wächter (Fall 6/7) binden nur die heutigen Pin-Werte; ein Soll-Literal mit fremdem Wert geht grün

* **kategorie:** MEDIUM
* **quelle:** AGENTS.md §3.6 (*„ein Test, dessen Name eine Eigenschaft behauptet,
  muss die Eigenschaft messen, nicht ihre heutige Implementierung"*)
* **pfad:** `test/ci-runner-ohne-docker.bats:108-120`
* **befund:** Die Fälle 6 und 7 behaupten, **kein** Soll-Wert stehe literal in den
  drei Workflows bzw. im Setup-Skript (die `EINE QUELLE`-Zusage des Skriptkopfs,
  `ci-runner-setup.sh:13-18`), messen aber über den literal geprüften Mustern
  `v?1\.27\.4|v?2\.15\.0` — den **heutigen** Werten der Pin-Stellen. Gegenprobe am
  Bestand (je mit Rücksetzen): `# probe go 1.27.4` an `ci.yml` → `not ok 6`;
  `# probe go 1.30.0` an `ci.yml` → `ok 6`. Eine Änderung, die ein Soll-Literal mit
  einem künftigen Pin-Wert trägt (exakt die Drift gegen die Inventar-Eine-Quelle,
  die der Wächter behauptet), färbt keinen der beiden Fälle rot. Der Wächter trägt
  daneben selbst die zwei Soll-Werte als Literale
  (`test/ci-runner-ohne-docker.bats:110,118`) — ein zweiter Ort derselben Werte.
  Der Wächter bindet nachweisbar (not ok 6 über dem heutigen Wert), aber die
  Eigenschaft seines Namens misst er nur für den heutigen Bestand.
* **verifizierbar:** ja — die beiden Bruchproben oben; kein kuratierter Fall in
  `test/mutations/` bindet die Proben (`grep -rl ci-runner test/mutations/` →
  0 Treffer).
* **klasse:** waechter-misst-heutigen-pin-statt-die-eigenschaft

### F-2 — LP2 des Plans verspricht „ci.yml läuft grün … `make full-smoke` docker-los"; die gelieferte ci.yml nennt den full-smoke-Job selbst die daemon-gebundene Rest-Spur — der Plan-Text trägt die Restmenge nicht

* **kategorie:** MEDIUM
* **quelle:** Plan §2 (LP2), §5 (Closure-Trigger); ADR-0109; derselbe
  Klassenbefund wie F-3 des Reviews
  [`2026-11-27-slice-smoke-und-full-smoke-ohne-docker.md`](2026-11-27-slice-smoke-und-full-smoke-ohne-docker.md)
* **pfad:**
  `docs/plan/planning/in-progress/slice-ci-runner-ohne-docker.md:59-61,110-112`
  vs. `.github/workflows/ci.yml` (full-smoke-Job, GRENZE-Kommentar)
* **befund:** Plan LP2: „ein Push/PR-Lauf (`ci.yml`) auf frischem Klon läuft
  **grün** — `make gates` + `make smoke` + `make full-smoke` docker-los". Die
  gelieferte ci.yml trägt am selben Job: „GRENZE (ADR-0109): … bis dahin ist
  dieser Job **die daemon-gebundene Rest-Spur** dieses Workflows, **kein
  docker-loses Glied**" — die Rest-Stufen trägt
  `slice-full-smoke-gates-echt-gruen` (`next/`), benannt nur in Kommentar und
  Commit-Message. §1/§2/§5 des Plans fassen den Zustand nicht: kein Plan-Zug
  nennt die daemon-gebundene Rest-Spur, trägt eine Abgrenzung oder eine
  LP2-Lesart, und der Closure-Trigger §5 setzt den vollgrünen Push-Lauf als
  Bedingung über einem Job, den die Lieferung selbst als Rest-Spur benennt. Der
  Slice kann über §5 so nicht geschlossen werden — derselbe Zustand, den der
  Vorgänger-Review als `plan-code-abweichung-nur-im-kommentar-getragen` meldet.
  Die LP2-LP3-Form „der reale Lauf im Verifikations-Bericht" ist hingegen sauber
  (Plan verweist auf reale Runner-Läufe, nicht auf die hermetische PLAN-Form).
* **verifizierbar:** ja — beide Zitate; `git diff 3dfd114d..cd50eff4 --
  docs/plan/planning/in-progress/` → leer (kein Plan-Zug im Diff).
* **klasse:** plan-code-abweichung-nur-im-kommentar-getragen

### F-3 — Der idempotente go-Zweig verfehlt seinen Ablagepfad: `mv "$tmp/go/bin/"* "$PREFIX/"` legt das Binary auf `$PREFIX/go`, die PREFIX-Prüfform prüft `$PREFIX/bin/go`

* **kategorie:** LOW
* **quelle:** Maintainability; AGENTS.md §3.7 (Skriptkopf „Idempotent: ein Lauf
  meldet je Werkzeug Soll · Ist · Entscheidung")
* **pfad:** `harness/tools/ci-runner-setup.sh:84-86,99`
* **befund:** Der Install verschiebt die `bin/`-Inhalte direkt auf `PREFIX`
  (korrekt für den `PATH`-Ansatz — `go` landet auf `.harness-ci/bin/go`), aber der
  Idempotenz-Zweig prüft `[ -x "$PREFIX/bin/go" ]` — einen Pfad, den die
  Install-Form nie erzeugt. Layout-Stub-Probe (Scratch, `mkdir -p go/bin prefix;
  mv go/bin/* prefix/`; `[ -x prefix/bin/go ]`): `PREFIX-PRUEFFORM-VERFEHLT`.
  Folge: der Zweig „im PREFIX — OK" greift nie für `go`; ein zweiter Lauf im
  selben Workspace fällt zum Re-Install durch, statt das Vorhandene zu melden
  (die `meldung … "im PREFIX — OK"`-Zeile ist für `go` tot). Der golangci-lint-Zweig
  ist symmetrisch korrekt (`install.sh -b "$PREFIX"` → `$PREFIX/golangci-lint`,
  Prüfform `"$PREFIX/golangci-lint"`). Auf dem CI-Runner (frisches Workspace je
  Lauf) trägt die PATH-Probe die Wirkung; die Lücke zeigt im Wiederhol-Lauf
  desselben Baums.
* **verifizierbar:** ja — Stub-Layout-Probe oben; ein echter Lauf über die
  Install-Zweige bleibt an der Netz/Sudo-Grenze (Skriptkopf trägt sie, siehe
  Negativbefunde).
* **klasse:** prefix-pruefform-verfehlt-die-mv-form

### F-4 — Zwei Grenze-Aussagen in ci.yml widersprechen sich: Kopf „keine Zeile dieser Datei setzt einen Docker-Daemon voraus" vs. full-smoke-Job „kein docker-loses Glied"

* **kategorie:** LOW
* **quelle:** AGENTS.md §3.7; Maintainability (Grenze-Formulierung im selben Diff)
* **pfad:** `.github/workflows/ci.yml` — RUNNER-WERKZEUGE-Kopf-Kommentar gegen den
  GRENZE-Kommentar des `full-smoke`-Jobs
* **befund:** Der neue Kopf-Kommentar sagt: „keine Zeile dieser Datei setzt einen
  Docker-Daemon voraus." Der neue full-smoke-Job-Kommentar sagt: „… bis dahin ist
  dieser Job die daemon-gebundene Rest-Spur dieses Workflows, kein docker-loses
  Glied." Zwei Sätze desselben Diffs über dieselbe Grenze mit entgegengesetzter
  Aussage — der Leser der Kopf-Aussage liest im selben File einen Job, der die
  Daemon-Voraussetzung trägt. (Der Rest-Zustand selbst ist richtig benannt und
  getragen — siehe F-2; der Befund ist der Widerspruch der beiden Grenze-Sätze.)
* **verifizierbar:** ja — beide Zitate; `grep -n 'Docker-Daemon voraus'
  .github/workflows/ci.yml` und der GRENZE-Block am full-smoke-Job.
* **klasse:** grenz-aussagen-widersprechen-sich-im-selben-file

### F-5 — `upstream-drift.yml` bleibt Daemon-gebunden (`make regelwerk-check` fährt `docker run`) und steht in keiner Out-of-Scope-Zeile des Plans

* **kategorie:** LOW
* **quelle:** Modul 5 §Ziel-Form: Slice (Out-of-Scope-Disziplin); ADR-0109
  (Geltung Gates/Lab-Läufer); Klasse der Grenz-Aufzählung (F-4 des
  Vorgänger-Reviews)
* **pfad:** Plan §1 (Ausdrücklich NICHT) vs. `.github/workflows/upstream-drift.yml:48`
  + `Makefile:523`
* **befund:** Der Plan schließt ausdrücklich aus: Tag-Workflow, d-check-Pin-Ebene,
  macOS-Runner — nicht `upstream-drift.yml`. Der unberührte Workflow bleibt über
  `make regelwerk-check` daemon-gebunden (`docker run --rm … --enable sources`,
  Makefile:523); die übrigen sechs Stufen des Jobs tragen die curl-Form und sind
  daemon-frei. ADR-0109 verlangt für diese Netz-Sensoren den docker-los Weg nicht
  (keine Gates-/Lab-Läufer) — kein Regelverstoß. Aber die Rest-Aufzählung des
  Diffs (release.yml am gepinnten Bild, adr-immutable am gepinnten Bild,
  full-smoke-Rest-Spur) nennt die dritte Daemon-gebundene Stelle im
  Workflow-Baum nicht — weder eine Plan-Zeile noch eine Grenze-Formulierung, und
  kein `next/`-Slice trägt sie.
* **verifizierbar:** ja — `sed -n '522,524p' Makefile` (docker run); Plan §1;
  `ls docs/plan/planning/next/` (kein benannter Träger).
* **klasse:** restmenge-im-workflow-baum-ungezaehlt

### F-6 — Die lint-Vorbestand-Klasse `gochecknoglobals` am `inventoryBasissatz` ist in keiner Übergabe-Fassung benannt

* **kategorie:** INFO
* **quelle:** dokumentationswürdige, aber undokumentierte Annahme (Vorbestand)
* **pfad:** `internal/emit/environment.go:57` (`var inventoryBasissatz`;
  Vorgänger-Slice `slice-emittierte-gates-host-pfad`, Commit `9bd6f440`)
* **befund:** `make lint` ist rot über `gochecknoglobals: 1` am
  `inventoryBasissatz` (am HEAD bestätigt). Der Befund liegt nicht im Diff
  dieses Slices, ist aber in den Übergabe-Fassungen des Vorgänger-Slices nicht
  benannt (`grep -l gochecknoglobals
  docs/reviews/2026-11-27-slice-emittierte-gates-host-pfad*.md` → 0 Treffer); die
  Klasse wandert darum je Träger-Form mit dieser Übergabe an den Aufrufer, nicht
  als stiller Bestand.
* **verifizierbar:** ja — `make lint` (rot, unten); der grep über die
  Vorgänger-Reporte.
* **klasse:** vorbestand-messung-ohne-benannten-traeger

### F-7 — Die Probe-Gleichziehung ist am Ort gelesen, aber kein Sensor hält die Gleichheit der Probe-Formen

* **kategorie:** INFO
* **quelle:** dokumentationswürdige Annahme, Feedforward getragen
* **pfad:** `harness/tools/ci-runner-setup.sh:64-69` vs.
  `harness/tools/environment-check.sh:291-293`
* **befund:** Die „zweite Probe-Form"-Abgrenzung im Skriptkopf trägt am Ort: die
  Probe ist **identisch gelesen** — `"$w" version | grep -oE '[0-9]+(\.[0-9]+)*' |
  head -n1` (environment-check exakt-Zweig) ≙ `version_ist`
  (`ci-runner-setup.sh:68`). Die Gleichheit selbst hält kein kuratierter Fall —
  eine Mutation an der Probe-Form des Skripts färbt keinen Fall; Träger bleibt
  der Lauf, der die Form liest (dieser Review).
* **verifizierbar:** ja — beide Zeilen gelesen; kein Fall im Bestand
  (`grep -rl version_ist test/mutations/` → 0).
* **klasse:** probe-gleichziehung-ohne-sensor

## REFUTED

* **Soll-Eine-Quelle am Ort (E-Form):** die Soll-Spalte wird aus dem Inventar
  gelesen (`soll()`, Spalte 4, Präfix-Stripping), kein Versions-Soll steht im
  Skript oder in den drei Workflows literal — Fall 6 ist rot über dem heutigen
  Wert (Bruchprobe oben); die Reichweite der Bindung ist F-1.
* **Install-Zweige ungemessen (Netz/Sudo):** die Grenze trägt am Skriptkopf
  („der reale Runner-Lauf trägt sie (DoD welle-ohne-docker,
  slice-ci-runner-ohne-docker)"), und der Plan weist LP2 auf reale Läufe („der
  reale Lauf im Verifikations-Bericht"), nicht auf die hermetische Form — die
  Form „gelesen, nicht gefahren; Träger CI" wie bei den Vorgänger-Reviews.
* **`.d-check.yml`-Zug (Fall 606):** ein Eintrag, kein Glob, kein zweiter
  Eintrag; Form gegen den Bestand identisch (Kommentar-Aufzählung und
  `exact-targets`-Liste je eine Zeile). Der Eintrag ist **keine** Senkung (§3.5):
  das Ziel `ci-runner-setup` existiert ohne Prosa-Erwähnung in der
  Autoritäts-Doku und ist als reines Utility-Ziel mit eigenem `## `-
  Hilfetext gerechtfertigt; die Bruchprobe bestätigt die Rot-Form an seiner
  Stelle — Entfernen des Eintrags → `129 Befunde` mit `gate-undocumented` an
  `Makefile:762`; Bestand → `128 Befunde`.
* **`adr-immutable`-Kommentar-Form (§3.7):** Zustand („bleibt … das gepinnte
  Bild (opt-in) als Träger"), Grenze (vcs-Modul über d-check.mk) und
  Träger-Verweis (`slice-full-smoke-gates-echt-gruen`, liegt in `next/`) —
  Indikativ über den Zustand des Jobs, keine Chronik.
* **Carrier-Verkabelung:** `make dcheck-fetch` vor dem make-Gang je Job
  (Fall 1–3 grün); der `DCHECK_CARRIER`-Zug des shard-Steps liest den absoluten
  Ablage-Pfad derselben Form wie mutate.yml (`mutate.yml:75,79` gelesen) —
  dieselbe Form, Fall 5 grün.
* **Der full-smoke-Rest-Zustand:** die Restmenge ist an der Jobstufe benannt und
  trägt einen benannten Folge-Slice im `next/`
  (`slice-full-smoke-gates-echt-gruen`, Stufen-Gruppen 1a–1d) — der Befund F-2
  trägt die Plan-Seite, nicht die Restbenennung.
* **PLAN-Modus:** `CI_RUNNER_SETUP_PLAN=1 make ci-runner-setup` am HEAD grün
  (Soll/Ist je Werkzeug gemeldet, kein Install, Exit 0) — der hermetische
  Vorlauf trägt die Meldungs-Form; die Probe-Gleichziehung siehe F-7.
* **Mutations-Bindung:** `make mutate-greift` am HEAD: „801 Fall/Faelle, 801
  greifen, 0 Befunde" — der Diff legt keine kuratierten Fälle an; die acht
  Wächter-Bruchproben sind Lauf-Belege (M2, M5, Fall 6 beide Richtungen, Fall
  606 — je oben nachgefahren), die kuratierte Entstehung ist Übergabe an den
  Verifier.
* **`register-ausgang`:** am HEAD `0 Befunde` — der Diff legt keinen
  `evidence/`-Bestand an (`register-ausgang` bleibt grün).
* **gitignore `.harness-ci/`:** kein `scan.ignore`-Zug (§3.5 nicht berührt); der
  Kommentar trägt die Grenze („scan.ignore respektiert .gitignore nicht, hier
  steht kein gescannter Text").
* **Grenzen-Formen mutate-branch/release:** die Kommentare tragen Zustand,
  Grenze und Träger-Verweis in Indikativ-Form; keine verworfenen Alternativen,
  keine Lauf-Protokolle (§3.7 gelesen).

## Negativbefunde — geprüft, ohne Befund

* **docs-check am Bestand:** `128 Befunde` am HEAD, am Claim byte-identisch
  (A/B-Zahl der Übergabe bestätigt); **keine** Befund-Zeile über irgendeiner der
  neun geänderten Dateien (`make docs-check-host | grep -E
  'github/workflows|ci-runner|\.d-check\.yml|\.gitignore'` → leer).
* **shell-lint:** rot über dem Bestand (`SC2254` an `harness/tools/gates-keys.sh`,
  `SC2016` an `test/mutations/797-…`) — `0` Treffer über den geänderten Dateien
  (`make shell-lint | grep -c ci-runner` → 0); beide betroffenen Dateien liegen
  außerhalb des Diffs — Vorbestand, in der Übergabe unten je Träger aufgenommen.
* **test-bats:** die acht neuen Fälle am HEAD grün (`1..8 ok`); der Voll-Bestand
  rot — Vorbestand der Brief-Übergabe („158/281, A/B am Claim"), am HEAD rot
  ohne Befund am neuen File.
* **test-go:** rot über zwei Vorbestand-Klassen je Brief-Übergabe („2 Klassen"),
  am HEAD bestätigt: `TestStopHook_CommitBindung` (`internal/emit`) und
  `TestGoProfile_PinsMatchRepo` (`internal/gen`) — kein diff-naher Befund.
* **mutate.yml-Carrier:** `make dcheck-fetch` + `DCHECK_CARRIER` je Shard — aus
  den Vorgänger-Commits gelesen; der neue ci-runner-setup-Step reiht vor dem
  Lauf, Fall 2 grün.
* **Wächter-Struktur:** die Job-Auflösung streift Kommentarzeilen und nennt die
  Zeilenpositions-Grenze im Kopf („die Prüfung liest die Form … nicht die
  YAML-Semantik") — die Bruchproben bestätigen beide Richtungen.
* **Inventar-Parser:** `soll()` liest Spalte 4 und strukturiert die
  Herkunfts-Präfixe (`abgeleitet:`/`manifest:`); `anwesend`/`probe:*` enden laut
  (Exit 2) — die Anwesenheits-Werkzeuge laufen über `command -v`, nicht über
  `soll()`; am Inventar gelesen (Spaltenform §Form).
* **release.yml-Grenze:** der Workflow bleibt im gepinnten Bild; der
  GRENZE-Kommentar trägt den Zustand (docker-getriebene Bauform, LH-QA-03,
  ADR-0003) — passend zum Plan-§1-Ausschluss.
* **`.gitignore .harness-ci/`:** gitignore statt scan.ignore; kein
  Senkungs-Gegenstand.

## Sensoren dieses Laufs

* `make test-bats BATS_TARGET=test/ci-runner-ohne-docker.bats` — grün `1..8 ok`.
* Bruchproben (je mit Rücksetzen am Bestand):
  - M2 (`docker run`-Step an ci.yml) → `not ok 4`; M5 (release-Form-Zug) →
    `not ok 8`.
  - Fall 6 heutiger Wert (`1.27.4` literal) → `not ok 6`; fremder Wert
    (`1.30.0`) → `ok 6` (F-1).
  - Fall 606 (exempt-Eintrag entfernt) → `make docs-check-host` → `129 Befunde`
    mit `gate-undocumented` an `Makefile:762`; mit Eintrag → `128 Befunde`.
* Stub-Layout-Probe (Scratch): mv-Form des go-Installs vs. `$PREFIX/bin/go`-
  Prüfform → `PREFIX-PRUEFFORM-VERFEHLT` (F-3).
* `CI_RUNNER_SETUP_PLAN=1 make ci-runner-setup` — grün, Soll/Ist je Werkzeug,
  kein Install, Exit 0.
* `make gates` (Fast-Pfad) — rot an der ersten gedrifteten Stufe
  `docs-check-host` (128 Vorbestand-Befunde, am Claim byte-identisch); die
  übrigen Stufen einzeln am HEAD: `make lint` rot (`gochecknoglobals: 1` an
  `inventoryBasissatz`, F-6), `make shell-lint` rot (Bestand: `SC2254`
  gates-keys.sh, `SC2016` test/mutations/797), `make test-bats` rot (Bestand),
  `make test-go` rot (Bestand: `TestStopHook_CommitBindung` internal/emit,
  `TestGoProfile_PinsMatchRepo` internal/gen), `make ci-lint` grün,
  `make comment-claims` grün (107 Dateien, 0 Befunde),
  `make register-ausgang` grün (292 Einträge, 0 Befunde), `make mutate-greift`
  grün (801/801).
* Vorbestand-Differenz gegen die Brief-Übergabe: docs-check 128 ✓
  (byte-identisch), lint `gochecknoglobals` ✓ (Vorgänger-Commit, F-6),
  test-bats rot ✓ (Bestand), test-go 2 Klassen ✓ (oben benannt); shell-lint rot
  ist als Vorbestand-Zeile je Träger unten aufgenommen (über den geänderten
  Dateien sauber).

## Übergabe (je Träger-Form)

* **mutate-auswahl-Posten:** 61 Fälle über der Schwelle — der CI-Branch-Weg
  (`make mutate-auswahl` → Push auf `mutate/<kennung>-<sha8>`) ist an den
  Verifier/Auftraggeber; kein Push dieser Rolle.
* **LP2/LP3-Runner-Läufe:** die reale Messung (Push-Lauf + Nacht-Shard) trägt
  der Verifikations-Lauf am Push; die hermetische PLAN-Form ist Vorbereitung,
  kein Beleg.
* **lint-Vorbestand `gochecknoglobals`** am `inventoryBasissatz`
  (`internal/emit/environment.go:57`, Vorgänger-Commit `9bd6f440`) — F-6; die
  Klasse gehört in die Verifikations-Übergabe, nicht in die DoD-Abhakung dieses
  Slices.
* **shell-lint-Vorbestand** (`SC2254` gates-keys.sh ×4, `SC2016`
  test/mutations/797) — je Träger benannt; die geänderten Dateien tragen keinen
  Befund.
* **test-go-Vorbestand:** `TestStopHook_CommitBindung` (internal/emit, 12
  dogfood-Unterfälle) und `TestGoProfile_PinsMatchRepo` (internal/gen 1.27.3
  generiert vs. 1.27.4 im Repo-Dockerfile) — letzterer trägt den gleichen
  Tool-Schicht-Posten, den F-7 des Vorgänger-Reviews benannte
  (`slice-full-smoke-gates-echt-gruen` §6).
* **Doku-Nachzug:** F-4 (zwei Grenze-Sätze ci.yml), F-5
  (upstream-drift-Restmenge) sind Kandidaten für
  `slice-doku-nachzug-ohne-docker`; F-2 braucht einen Plan-Zug vor der
  Verifikation.
* **Mutations-Entstehung** für die acht Wächter-Fälle (M2, M5, Fall 6 —
  je kuratiert mit `# expect:`) bleibt Offen-Empfehlung an den Verifier; ohne
  sie sind die Bruchproben nur Lauf-Belege.
