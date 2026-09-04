# MR-014 — CI auf frischem Klon (GitHub Actions)

- **Datum:** 2026-07-20
- **Geltungsbereich:** `.github/workflows/ci.yml` (neu), `Makefile` (`ACTIONLINT_IMAGE`,
  `ci-lint`-Target, in `gates`), [`AGENTS.md`](../../AGENTS.md) §4, [`harness/README.md`](../README.md) §Sensors;
  löst die seit [`MR-003`](../conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) offene
  „CI ist dort das Netz"-Restlücke ein.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und er setzt keine Abweichung: er löst eine Lücke ein, die die Baseline selbst benennt.
  [`grundlagen-durchsetzungsschicht.md`](../../.harness/baseline/v6.0.0/regelwerk/grundlagen-durchsetzungsschicht.md#grenzen--ehrlich-benannt)
  §Grenzen — ehrlich benannt sagt zum inhaltsbasierten Nachweis: *„Der Inhalts-Nachweis hat eine
  Lücke bei frischem Klon bzw. gelöschtem State mit cleanem Tree (kein Nachweis prüfbar) — dort ist
  **CI das Netz**."* Genau diesen Satz baut der Eintrag. Die vier Setzungen treten an keine Regel:
  das Regelwerk am adoptierten Stand `v5.12.0` schreibt keinen CI-Aufbau vor — es verlangt, dass
  lokal und CI dasselbe gepinnte Image fahren
  ([`modul-14-docker-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#multi-stage-build-die-operativen-disziplinen-modul-14)),
  und `ci-lint` als Gate hält
  [`modul-13-quality-gates.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin)
  §Hard Rule (Doku-Disziplin) ein, statt von ihr abzuweichen: der Prüfbereich ist nicht leer.
- **Adaption:** GitHub Actions fährt bei **jedem Push und PR** `make gates` + `make smoke` +
  `make mutate` — jeder Job **frisch ausgecheckt**. Das schließt die
  [`MR-003`](../conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke: der lokale
  Stop-Hook gibt einen cleanen Tree **ohne** `.harness/state/` frei (kein Nachweis prüfbar), CI ist
  dort die Absicherung. Zugleich bekommt `make mutate` (slice-026) seinen mechanischen
  **Pro-Push-Auslöser** — die Durchsetzungs-Hälfte von dessen Befund N-6, die der lokale Hook nicht
  leisten kann (er deckt nur `make gates`).
- **Setzung 1 — nur `make`-Targets, keine zweite Gate-Definition.** Die Workflow-Steps rufen
  ausschließlich `make <target>` auf; was ein Gate *ist*, steht weiterhin allein im Makefile
  (Geist von [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert): eine Quelle, nicht zwei). Ein
  CI-Step, der Build-Logik dupliziert, driftet gegen den lokalen Lauf und ist verboten.
  **Nachtrag 2026-07-25 (slice-048) — Präzisierung, keine Aufweichung.** Die Setzung meint
  „**eine** Quelle je Check", und `make <target>` ist die **Regelform**, in der das erreicht wird —
  nicht der Zweck selbst. Deshalb gilt: **ein Check wird nie in der Workflow-YAML definiert.** Er
  lebt als versioniertes, von `shell-lint` gedecktes Artefakt im Repo (ein `make`-Target oder ein
  Skript unter `harness/tools/`); der Workflow-Step **ruft** ihn nur auf. Ein Inline-Prüfblock in
  der YAML bleibt verboten — unabhängig davon, auf welchem Runner er liefe.
  **Warum die Regelform hier nicht greift (gemessen, nicht angenommen):** der Plattform-Start-Smoke
  in `release.yml` läuft auf sechs Runnern, und `make` ist auf den Windows- und macOS-Images
  **nicht** installiert (an den Runner-Images-Readmes für `windows-2025` und `macos-26` geprüft,
  <https://github.com/actions/runner-images>, Stand 2026-07-25; die übrigen `make`-losen Labels
  wurden nicht einzeln geprüft). Ein Aufruf `make start-smoke` wäre dort schlicht nicht
  ausführbar. Der Check liegt daher als `harness/tools/start-smoke.sh` im Repo und wird auf
  **allen** sechs Runnern gleich aufgerufen — bewusst **nicht** gesplittet in „`make` auf Linux,
  Skript sonst": ein Split erzeugte genau die zwei Definitionen, die die Setzung verhindert.
- **Setzung 2 — Frequenz nach Sensor-Klasse.** „Alles pro Push" für die hermetischen Sensoren
  (`gates`/`smoke`/`full-smoke`/`mutate`); die **Netz-Sensoren** (`regelwerk-check`,
  `baseline-freshness`, `freshness-golangci`/`-dcheck`/`-go`) laufen **nur nächtlich**
  (`schedule`). Grund: sie erreichen einen Fremd-Host (Kurs-Release, golangci-lint/d-check/Go);
  ein Upstream-Ausfall ist kein Defekt des Commits und darf keinen Push röten — sonst werden Gates
  umgangen ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Geist auf Prozess-Ebene).
  **Seit dem Split (Nachtrag unten) ist diese Trennung strukturell** (zwei Workflow-Dateien) statt
  per `if: github.event_name` in einer Datei.
- **Setzung 3 — `ci-lint` ist ein Gate.** actionlint prüft `.github/workflows/` (gepinntes Image,
  Docker-only, [`ADR-0003`](../../docs/plan/adr/0003-go-native-binaries.md)) und läuft **in** `make gates`:
  der Workflow ist ein reales committetes Artefakt (nicht-leerer Prüfbereich,
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und ein Syntaxfehler
  darin ist **lokal vor dem Push** fangbar statt erst im ersten Actions-Lauf — das lokale
  Gegenbeispiel-Gate zur Zusage „die CI läuft" ([`AGENTS.md`](../../AGENTS.md) §3.6).
- **Setzung 4 — Runner + Actions gepinnt, so weit es geht ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).** `runs-on: ubuntu-24.04`
  (benannte Version, **nicht** `ubuntu-latest`); `actions/checkout` per **Commit-SHA** gepinnt
  (`@fbc6f399…` = v5.1.0, seit dem Nachtrag unten; zuvor `@11bd719…` = v4.2.2), nicht per
  wanderndem `@v5`. **Grenze:** ein GitHub-**hosted** Runner-Image
  ist nicht *digest*-pinnbar (das erlauben nur self-hosted/Container-Jobs) — `ubuntu-24.04` benennt
  eine Version, deren Paketstand GitHub periodisch aktualisiert. Die Reproduzierbarkeit der *Checks*
  trägt daher nicht der Runner, sondern die **digest-gepinnten Tool-Images** der `make`-Targets
  (bats/shellcheck/actionlint/d-check/golang/golangci); der Runner liefert nur Docker + Checkout.
- **Grenze — nicht lokal rot-sehbar.** Der Workflow selbst läuft auf GitHub; `ci-lint` belegt nur
  seine **Syntax**, nicht sein **Verhalten**. Ob `make gates` auf einem *wirklich* frischen Klon grün
  ist, zeigt erst der erste Actions-Lauf. **Lokal so weit belegt wie möglich** (Verifikation
  slice-027): `git clone` in ein frisches tmp ohne `.harness/state/` → `make gates` Exit 0; offen
  bleibt allein die GitHub-gehostete Ausführung.
- **Nachtrag 2026-07-24 — Split + `workflow_dispatch` + checkout v5.** Der Workflow ist in **zwei
  Dateien** getrennt: `.github/workflows/ci.yml` trägt nur die hermetischen Pro-Push-Sensoren
  (`gates`/`smoke`/`full-smoke`/`mutate`), `.github/workflows/upstream-drift.yml` die Netz-Sensoren.
  Damit ist die Sensor-Klassen-Trennung (Setzung 2) strukturell statt per `if: github.event_name`.
  `upstream-drift.yml` trägt **`schedule` (01:00 UTC) + `workflow_dispatch`** — Letzteres gibt einen
  „Run workflow"-Button, um den Drift-Lauf **manuell** anzustoßen (z. B. sofortige Gegenprüfung nach
  einem gemeldeten Release), ohne bis zum Nachtlauf zu warten. Beide Dateien folgen weiter Setzung 1
  (nur `make`-Targets); `ci-lint`/actionlint (Setzung 3) prüft `.github/workflows/` **glob**, deckt
  also beide. Zugleich `actions/checkout` **v4.2.2 → v5.1.0** (`@fbc6f399…`, weiter SHA-gepinnt,
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) — Auslöser war die GitHub-Warnung
  „Node.js 20 is deprecated"; v5 läuft auf Node 24, `ubuntu-24.04` trägt das, die `checkout`-API ist
  unverändert.
- **Auflösungs-Trigger:** permanent; `ACTIONLINT_IMAGE` bei Bedarf neu pinnen (wie
  `BATS_IMAGE`/`SHELLCHECK_IMAGE`); `actions/checkout` bei Node-Deprecation neu auf den dann
  aktuellen SHA-Pin heben.
