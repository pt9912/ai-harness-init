# Review-Report: slice-018 Implementierung (Baseline-Freshness — Release-Listen-Sensor) — 2026-07-18

**Review-Art:** Code — unabhängiger Reviewer (kein Selbst-Review). Skeptische Prüfung eines
read-only Netz-Sensors (`make baseline-freshness`), der einen neueren Upstream-Tag als
`BASELINE_TAG` meldet (Tag-Achse neben `regelwerk-check`s Asset-Achse). Geprüft gegen Plan
(slice-018 DoD + §6-Risiken), `LH-QA-01`/`LH-QA-02`/`LH-QA-03`, Hard Rules `AGENTS.md` §3,
`ADR-0003` (Docker-only), `MR-007`.

**Gegenstand (uncommitteter Working-Tree-Diff, 4 Dateien):**
- **neu** `harness/tools/baseline-freshness.sh` (Fetch↔Vergleich getrennt),
- **neu** `test/baseline-freshness.bats` (hermetisch, nur `--compare`),
- **update** `Makefile` (`baseline-freshness`-Target + `.PHONY` + `regelwerk-check`-`@echo`-Pointer),
- **update** `harness/conventions.md` (MR-007-Auflösungs-Trigger: Lücke → gelöst).

Der committete Eintritts-Move (`2a7c84a`, slice-018 → `in-progress/`) ist **nicht** Review-Gegenstand.

**Skill:** `.harness/skills/reviewer.md` @ 1.1.0 · **Modell:** claude-opus-4-8[1m] (unabhängiger
Reviewer-Agent) · **Datum:** 2026-07-18

**Eingangs-Kontext (nach reviewer.md v1.1.0 — sechs Elemente):**
1. **Diff/Range:** `git diff` (Working Tree, 4 Dateien oben).
2. **Betroffene LH:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   (offline-grün / keine halluzinierten Gates), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
   (Reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
   (minimale Abhängigkeiten — kein jq/API/node).
3. **Referenzierte ADRs:** `ADR-0003` (Docker-only Build, Accepted — aktiv). Keine superseded ADR referenziert.
4. **Hard Rules:** `AGENTS.md` §3.1 (halluzinierte Gates), §3.2 (Lint-Suppression-Verbot), §3.5 (Gate-Lockerung nur per ADR).
5. **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-07-18-slice-017-impl-review.md`
   (Sensor-Promotion / „behauptet ≠ vorhanden", Host-`curl` nur in Maintenance-Targets, Docker-only).
6. **Slice-Plan:** `docs/plan/planning/in-progress/slice-018-baseline-freshness.md` (Diff gegen Plan
   geprüft; DoD-Abhakung NICHT bewertet — Verifier-Rolle).

**Ausgeführte Verifikationsmittel (Belege):**
- `make gates` → **Exit 0** (baseline-verify · docs-check · test **50/50** bats ok · shell-lint · record-gates); **netzlos grün**.
- `make test` → **Exit 0**; die drei Freshness-Tests laufen und sind grün: `ok 1 freshness: latest == gepinnt -> aktuell (exit 0)` · `ok 2 … VERALTET/Alarm (exit 1)` · `ok 3 … leerer latest (Fetch-Fehler) -> eigener Exit 2, NICHT veraltet`.
- `make shell-lint` → **Exit 0** (shellcheck über `harness/tools/*.sh`, keine Inline-Suppression im neuen Skript).
- `make -n baseline-freshness` → `BASELINE_TAG='v3.1.0' RELEASES_LATEST_URL='…/releases/latest' bash harness/tools/baseline-freshness.sh` (BASELINE_TAG durchgereicht, kein zweiter Pin-Speicher).
- `bash …/baseline-freshness.sh --compare v3.1.0 v3.1.0` → Exit **0** („aktuell"); `--compare v3.1.0 v3.2.0` → Exit **1** („VERALTET", beide Tags genannt); `--compare v3.1.0 ''` → Exit **2** („FETCH-FEHLER", nicht „VERALTET"). Semantik 0/1/2 korrekt und Fetch-Fehler als eigene Klasse.
- **Echter Netz-Lauf** `make baseline-freshness` → alarmiert korrekt: `VERALTET … gepinnt: v3.1.0 / latest: v3.2.0`; read-only, keine Mutation (Working-Tree danach unverändert). `curl -fsSLI …/releases/latest` bestätigt effektive URL `…/releases/tag/v3.2.0` (die Lücke ist real).
- `grep` bestätigt: `baseline-freshness` steht **nicht** in der `gates:`-Zeile (Makefile:93), **nicht** in `AGENTS.md` §4 und **nicht** in `harness/README.md` §Sensors (wie `regelwerk-check` — beide bewusst Maintenance/CI, nicht Gate). Kein jq/API/JSON/node/python im Skript/Test.

---

## Findings

### LOW-1 — Makefile-`baseline-freshness`-Kommentar zählt Exit `0/1/2` auf, ohne den make-Kollaps zu nennen (den das Schwester-Target dokumentiert)

- **kategorie:** LOW
- **quelle:** Maintainability (Doku-Drift / latente CI-Falle; Inkonsistenz zum Sibling-Präzedenzfall `regelwerk-check`)
- **pfad:** `Makefile:81-82` (Kommentar `Exit: 0 = aktuell, 1 = VERALTET, 2 = Fetch-Fehler.`)
- **befund:** Der Skript-Kern liefert korrekt 0/1/2, aber `make` kollabiert jeden Nonzero-Recipe-Exit auf sein eigenes Exit 2 — gemessen: `bash …--compare v3.1.0 v3.2.0` → **1**, `make baseline-freshness` (VERALTET) → **2**; auch der Fetch-Fehler-Pfad ergibt make-Exit 2. Das Schwester-Target `regelwerk-check` warnt vor genau diesem Kollaps explizit im Makefile-Kommentar (Makefile:58-61: „`make` kollabiert jeden Recipe-Fehler auf Exit 2 … 0 = OK, !=0 = Alarm; ob Drift oder Fetch-Fehler sagt die echo-Meldung"). Der neue Kommentar zählt `0/1/2` am make-Target auf, ohne diesen Caveat — der Distinktions-Anker bleibt allein die echo-Meldung (VERALTET vs. FETCH-FEHLER).
- **failure-szenario:** Der (im Plan §6 auf einen Folge-Slice ausgelagerte) scheduled CI-Job verzweigt auf den Exit-Code von `make baseline-freshness`, um VERALTET (erwartet 1) von Fetch-Fehler (erwartet 2) zu trennen — beide liefern make-Exit 2, der Alarm wird fehlgeleitet/nicht unterschieden.
- **verifizierbar:** ja — `make baseline-freshness; echo $?` (=2 bei VERALTET) gegen `bash harness/tools/baseline-freshness.sh --compare v3.1.0 v3.2.0; echo $?` (=1).

### INFO-1 — Hermetik des bats-Tests hängt an Code-Pfad-Disziplin, nicht an Netz-Isolation (`make test` ohne `--network none`)

- **kategorie:** INFO
- **quelle:** `LH-QA-01` (offline-grün) / Maintainability (dokumentationswürdige Annahme)
- **pfad:** `test/baseline-freshness.bats:6-9`; `Makefile:35-36` (`test:`-Recipe)
- **befund:** Die offline-grün-Zusage für die Freshness-Tests ist ausschließlich dadurch garantiert, dass der Test nur `--compare` (den reinen Vergleicher) aufruft und der Fetch im Skript davon getrennt ist — `make test` läuft **ohne** `--network none` (kein Make-Target trägt das Flag; nur `docs-check` härtet via d-check netzlos). Fügt ein künftiger Autor einen Voll-Lauf-Test (mit `fetch_latest_tag`) hinzu, träfe `make test` — und damit `make gates` — still das Netz und bräche offline-grün, ohne dass eine Netz-Isolationsschicht das abfängt. Aktuell korrekt und im Testkopf explizit gewarnt; die Setzung ist eine bewusste Konvention, keine erzwungene Grenze (defense-in-depth-Lücke, kein aktueller Defekt).
- **failure-szenario:** Ein späterer `run bash "$FRESH"` ohne `--compare` (Voll-Lauf) im selben `.bats` trifft in `make gates` das Netz; auf einem netzlosen Checkout wird `make gates` rot statt der zugesicherten offline-grün.
- **verifizierbar:** ja — `grep -rn network Makefile` zeigt kein Flag auf `test`; ein hypothetischer Voll-Lauf-Test würde es in einer netzlosen Umgebung sichtbar machen.

---

## Negativbefunde (geprüft, ohne blockierenden Befund)

- **Offline-grün / halluziniertes Gate (LH-QA-01, HIGH-Anker):** `baseline-freshness` steht **nicht** in der `gates:`-Zeile (Makefile:93 — `baseline-verify docs-check test shell-lint record-gates`), **nicht** in `AGENTS.md` §4 und **nicht** in `harness/README.md` §Sensors (exakt wie `regelwerk-check`; „behauptet ≠ vorhanden"). `make gates` lief netzlos grün (Exit 0). Kein Netz-Zugriff in `make test`: die bats-Suite ruft ausschließlich `--compare` (Fixtures), nie den Fetch. LH-QA-01 gewahrt.
- **Skript-Korrektheit (Fetch↔Vergleich-Trennung, Exit-Semantik):** `fetch_latest_tag` (Netz) und `compare_tags` (rein, netzlos) sind sauber getrennt; `--compare` dispatcht nur den Vergleicher. Exit 0/1/2 real bestätigt (aktuell / veraltet / Fetch-Fehler). Leerer/kaputter Fetch ist eigene Klasse: `compare_tags` liefert bei leerem `latest` Exit 2 („FETCH-FEHLER", nicht „VERALTET"); `fetch_latest_tag` gibt bei curl-Fehler **oder** unerwarteter effektiver URL (`case */releases/tag/*)` sonst `return 2`) sichtbar 2 — ein Repo ohne Releases (Redirect auf `…/releases`) wird korrekt als Fetch-Fehler klassifiziert, nicht als „aktuell". `set -euo pipefail`-Fallen entschärft: beide Nonzero-Rückgaben über `|| rc=$?` bzw. `|| latest=""` abgefangen, kein Errexit-Abbruch.
- **shellcheck (Hard Rule 3.2):** `make shell-lint` grün; keine Inline-`# shellcheck disable` im neuen Skript/Test.
- **Hermetik des Tests:** `make test` grün mit 50 Tests; die drei neuen Freshness-Tests (1–3) rufen garantiert nur `--compare` — kein Netz-Kontakt (Einschränkung als INFO-1 notiert: garantiert durch Code-Pfad, nicht durch `--network none`).
- **LH-QA-03 (minimale Abhängigkeiten):** Nur bash + coreutils (`basename`) + curl; kein jq/API/JSON/node/python (die einzigen `jq`/`node`-Vorkommen sind Kommentar-Negationen „ohne jq/API/JSON").
- **BASELINE_TAG als einzige Tag-Quelle (MR-007):** Das Skript liest `BASELINE_TAG`/`RELEASES_LATEST_URL` per `:?`-Guard aus der vom Makefile durchgereichten Umgebung; kein zweiter Pin/Tag-Speicher eingeführt. `make -n` bestätigt die Durchreichung.
- **ADR-0003 (Docker-only Build):** Host-`curl` im read-only Sensor folgt exakt der etablierten Maintenance/Netz-Ausnahme des Schwester-Targets `regelwerk-check` (slice-009, ebenfalls Host-`curl`, NICHT in `gates`). Kein Host-`go`/`pip`/`npm`; die Gates (test/shell-lint) bleiben Docker-only. Kein ADR-0003-Verstoß (der ADR normiert den Tool-**Build**, nicht read-only Maintenance-Netzsensoren).
- **Doku-Ehrlichkeit (MR-007-Trigger + regelwerk-check-@echo):** Das `harness/conventions.md`-Update deckt die Realität — Tag-Achse (`releases/latest`-Redirect, Vergleich gegen `BASELINE_TAG`) explizit gegen `regelwerk-check`s Asset-Achse abgegrenzt; „mutiert nichts" und „Re-Baseline bleibt bewusste Operation" stimmen mit dem Skript-Verhalten überein. Der `regelwerk-check`-Schluss-`@echo` (Makefile:76) zeigt jetzt korrekt auf `make baseline-freshness` statt auf den vagen „Release-Liste separat prüfen"-Prosa-Hinweis.
- **Read-only / keine Mutation:** `make baseline-freshness` (echter Netz-Lauf) nutzt `curl -fsSLI -o /dev/null` (HEAD); Working-Tree nach dem Lauf unverändert (die einzige geschriebene Datei `.harness/state/gates-passed.diffsha` aus `record-gates` ist gitignored).
- **Diff gegen Plan:** Alle vier Plan-§3-Tabellenzeilen umgesetzt (Tool neu, Makefile-Target nicht in `gates` + `@echo`-Pointer, bats-Fixtures aktuell/neuer-Tag/Fetch-Fehler, conventions.md-Update). Bewusst ausgelagert und **nicht** in diesem Diff: der scheduled CI-Job (`.github/workflows/`, Plan §6 — Folge-Slice). SemVer-Vereinfachung (Alarm = „latest ≠ gepinnt") und der Slash-im-Tag-/Pre-Release-Randfall sind im Plan §6 bewusst YAGNI-akzeptiert — kein Finding.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 1 |

---

## Verdikt

**Nicht merge-blockierend.** 0 HIGH, 0 MEDIUM. Der Kern des Slice ist sauber: Fetch↔Vergleich
sind getrennt (hermetisch testbar), die Exit-Semantik 0/1/2 stimmt real (inkl. Fetch-Fehler als
eigener Klasse, nicht „veraltet"), `baseline-freshness` ist weder in `gates` noch als Sensor
promotet (offline-grün bleibt, LH-QA-01), es nutzt nur bash/coreutils/curl (LH-QA-03), reicht
`BASELINE_TAG` als einzige Tag-Quelle durch (MR-007) und mutiert nichts. `make gates` (50/50 bats),
`make test`, `make shell-lint` liefen netzlos grün (Exit 0); der echte Netz-Lauf alarmierte korrekt
(gepinnt v3.1.0 vs. latest v3.2.0). Der Host-`curl` folgt der etablierten `regelwerk-check`-Maintenance-
Ausnahme (kein ADR-0003-Verstoß). Die eine LOW (Makefile-Kommentar zählt Exit 0/1/2 ohne den
make-Kollaps-Caveat, den das Schwester-Target trägt) und die eine INFO (Test-Hermetik durch
Code-Pfad statt `--network none` garantiert) sind Doku-/Defense-in-depth-Genauigkeit ohne
aktuellen Gate- oder Reproduzierbarkeits-Effekt und blockieren den Merge nicht — beide sind beim
Bau des ausgelagerten CI-Folge-Slice zu berücksichtigen.
