# Verifikation slice-018 — Baseline-Freshness (Release-Listen-Sensor `make baseline-freshness`)

**Rolle:** Verifier (Modul 11, Verification Harness) — unabhängig, frischer Kontext,
NICHT Implementer, NICHT Reviewer.
**Datum:** 2026-07-18.
**Eingabe:** DoD + Spec + Plan (Modul 11) —
`docs/plan/planning/in-progress/slice-018-baseline-freshness.md` §2 (DoD) / §3 (Plan-Tabelle) /
§1 (Ziel) / §6 (Risiken); `spec/lastenheft.md` `LH-QA-01` (keine halluzinierten Gates / offline-grün),
`LH-QA-02` (Reproduzierbarkeit), `LH-QA-03` (minimale Abhängigkeiten); realer Stand aus
Working-Tree-Diff (4 Sach-Dateien + 1 Review-Artefakt) **plus** dem committeten
Eintritts-Move `2a7c84a` (slice-018 → `in-progress/`).
**Frage:** „Hat das Gebaute umgesetzt, was Plan/DoD/Spec verlangt?" (nicht „ist es gut?" = Review).
**Mittel:** ausgeführte Gates/Docker/Skript/`git`/`curl` — jede Zeile mit Beleg-Befehl. Der Verifier
committet/verschiebt nichts.

**Vorbemerkung zum Abhak-Zustand.** Die DoD-Kästchen in §2 stehen im Working Tree auf `[ ]`
(unabgehakt), §7 trägt den Platzhalter. Es liegt also **keine** positive Implementer-Behauptung
„`[x]`" vor — der Verifier prüft die **Substanz** jedes DoD-Punkts gegen den realen Stand. §2
listet **sechs** Kästchen; das letzte („`make gates` grün + Closure-Notiz") wird hier — der
Verifier-Aufgabe folgend — in **zwei** Verifikationspunkte zerlegt (DoD-6 = `make gates`, DoD-7 =
Closure-Notiz), macht **sieben** Punkte.

---

## DoD-Punkt für DoD-Punkt (§2)

### DoD-1 — Redirect-Follow → Tag-Extraktion → Vergleich mit `BASELINE_TAG`, 0/1/2-Semantik (gleich=0, neuer=nonzero, Fetch-Fehler=eigener Exit ≠ veraltet) — **CONFIRMED (ausgeführt)**
- **Vergleicher-Semantik live (hermetisch, kein Netz):**
  - `bash harness/tools/baseline-freshness.sh --compare v3.1.0 v3.1.0` → „aktuell", **Exit 0**.
  - `--compare v3.1.0 v3.2.0` → „VERALTET … gepinnt: v3.1.0 / latest: v3.2.0", **Exit 1**.
  - `--compare v3.1.0 ''` → „FETCH-FEHLER (kein Freshness-Urteil) …", **Exit 2** — Fetch-Fehler ist
    **eigene Klasse**, gibt **nicht** „VERALTET" aus (in `compare_tags`, `baseline-freshness.sh:28-31`,
    vor dem Gleichheits-Check).
- **Echter Netz-Lauf (read-only):** `make baseline-freshness` → `VERALTET … gepinnt: v3.1.0 /
  latest: v3.2.0`; der Fetch löst den `releases/latest`-Redirect auf und extrahiert den Tag
  (`fetch_latest_tag`, `baseline-freshness.sh:45-52`: `curl -fsSLI -o /dev/null -w '%{url_effective}'`
  → `case */releases/tag/*) basename`). **Unabhängig gegenbelegt:**
  `curl -fsSLI -o /dev/null -w '%{url_effective}' …/releases/latest` →
  `…/releases/tag/v3.2.0` — die Lücke ist real (gepinnt v3.1.0, latest v3.2.0).
- **`make`-Kollaps notiert (nicht DoD-widrig):** der Skript-Exit 1 (VERALTET) erscheint am
  `make`-Target als Exit 2 (`make` kollabiert jeden Nonzero-Recipe-Exit) — gemessen: Skript
  `--compare … v3.2.0` = **1**, `make baseline-freshness` (VERALTET) = **2**. Der Makefile-Kommentar
  (`Makefile:81-84`) und die DoD verlangen die 0/1/2-Semantik am **Skript**, das der Vergleicher
  exakt liefert; der make-Kollaps ist im Makefile-Kommentar seit dem Review explizit vermerkt
  („`make` kollabiert … 0 = aktuell, !=0 = Alarm; ob veraltet oder Fetch-Fehler sagt die echo-Meldung,
  wie bei regelwerk-check") — konsistent zum Schwester-Target `regelwerk-check`.

### DoD-2 — Logik in `harness/tools/baseline-freshness.sh`, Fetch↔Vergleich getrennt, shellcheck-clean, `BASELINE_TAG` einzige Tag-Quelle (kein neuer Pin-Speicher) — **CONFIRMED**
- **Logik im geplanten Pfad:** `harness/tools/baseline-freshness.sh` existiert (untrackt, im Diff).
  Cross-Check: der d-check-Gate-Lauf meldet **0 Befunde** (48 Dateien) — die im Slice-Doc früher
  nötigen `d-check:ignore`-Kommentare (geplante Datei) sind im Diff **entfernt**, weil die Datei nun
  real existiert und der Pfad-Verweis auflöst.
- **Fetch↔Vergleich getrennt:** `compare_tags()` (rein, netzlos, `:26-41`) und `fetch_latest_tag()`
  (Netz, `:45-52`) sind sauber getrennt; `--compare` dispatcht **nur** den Vergleicher (`:55-58`),
  ohne je `fetch_latest_tag`/`curl` zu erreichen — die Basis der Test-Hermetik (DoD-4).
- **shellcheck-clean:** `make shell-lint` (Teil von `make gates`) läuft `koalaman/shellcheck` über
  `.claude/hooks/*.sh harness/tools/*.sh` (schließt `baseline-freshness.sh` ein) → **0 Befunde**,
  keine Inline-`# shellcheck disable` im neuen Skript.
- **`BASELINE_TAG` einzige Tag-Quelle:** das Skript liest `pinned="${BASELINE_TAG:?…}"` (`:62`) und
  `url="${RELEASES_LATEST_URL:?…}"` (`:63`) per `:?`-Guard aus der vom Makefile durchgereichten
  Umgebung; `make -n baseline-freshness` → `BASELINE_TAG='v3.1.0' RELEASES_LATEST_URL='…/releases/latest'
  bash harness/tools/baseline-freshness.sh`. **Kein zweiter Pin/Tag-Speicher** — der Tag-String hat
  weiter genau eine Quelle (`BASELINE_TAG` im Makefile, MR-007-Setzung); die `releases/latest`-URL ist
  kein Tag-Pin (sie enthält keinen Tag, sondern folgt dem Redirect).

### DoD-3 — Nicht in `gates`, keine Sensor-Promotion; `make gates` netzlos grün — **CONFIRMED (LH-QA-01)**
- **Nicht in `gates`:** `Makefile:96` = `gates: baseline-verify docs-check test shell-lint record-gates`
  — `baseline-freshness` **nicht** enthalten. Das Target ist als „Maintenance/CI, NICHT in gates"
  deklariert (`Makefile:87`).
- **Keine Sensor-Promotion:** `grep 'baseline-freshness' AGENTS.md harness/README.md` → **leer**;
  weder die §4-Tabelle (`AGENTS.md:85` nennt nur `make docs-check`) noch §Sensors
  (`harness/README.md:41` nennt nur `make docs-check`) behaupten es als Gate — exakt die
  `regelwerk-check`-Linie („behauptet ≠ vorhanden", LH-QA-01).
- **`make gates` netzlos grün:** Exit 0 (siehe DoD-6). Kein Netz-Zugriff im Gate-Lauf (Fetch nur im
  nicht-Gate-Target); der Netz-Sensor bricht offline-grün **nicht**.

### DoD-4 — Hermetischer bats-Test (nur `--compare`, nie Netz); `make test` grün mit `--network none` (strukturell erzwungen) — **CONFIRMED**
- **Nur `--compare`:** `test/baseline-freshness.bats` ruft ausschließlich `run bash "$FRESH"
  --compare "$1" "$2"` (`:16`), drei Fixtures: `latest==gepinnt`→ok · `latest!=gepinnt`→Alarm ·
  `leer`→eigener Exit 2 (nicht VERALTET). **Kein** `fetch_latest_tag`/Voll-Lauf-Aufruf → trifft nie
  das Netz.
- **`make test` grün, strukturell netz-isoliert:** `make -n test` →
  `docker run --rm --network none -v … bats/bats@sha256:e8f18e0a… test/` — das `--network none`-Flag
  ist am Target gesetzt (Diff: `test:`-Recipe von `docker run --rm …` auf `docker run --rm
  --network none …` umgestellt). Im `make gates`-Lauf grün: `1..50 … ok 50`, darunter die drei
  Freshness-Tests (`ok 1/2/3`). Die Hermetik hängt damit **nicht mehr nur** an Code-Pfad-Disziplin,
  sondern am Container — der INFO-1-Nachzug ist umgesetzt.

### DoD-5 — `regelwerk-check`-`@echo` + MR-007-Auflösungs-Trigger verweisen auf `baseline-freshness` — **CONFIRMED**
- **`regelwerk-check`-Schluss-`@echo` (`Makefile:76`):** jetzt
  „… Ein NEUER Tag upstream bleibt hier unsichtbar — **'make baseline-freshness' prüft die
  Release-Liste** (slice-018, MR-007)." — der frühere vage „Release-Liste separat prüfen"-Prosa-Hinweis
  ist ein ausführbarer Zeiger geworden.
- **MR-007-Auflösungs-Trigger (`harness/conventions.md:270-282`):** die frühere „**offene Lücke**,
  kein gelöstes Problem … Kandidat für einen eigenen Slice" ist ersetzt durch „**Diese Lücke schließt
  `make baseline-freshness` (slice-018)** …" (Tag-Achse gegen `regelwerk-check`s Asset-Achse
  abgegrenzt, „mutiert nichts", „nicht in gates"). Cross-Check: `grep 'Kandidat für einen eigenen
  Slice' harness/conventions.md` → **leer** (alte Trigger-Prosa vollständig entfernt); der `anchors`-Modul
  in `make gates` meldet 0 Befunde (kein toter Verweis).

### DoD-6 — `make gates` grün (Exit 0) — **CONFIRMED (ausgeführt)**
- `make gates` → **Exit 0**. Teilläufe: `baseline-verify: v3.1.0 OK — 42 Dateien` (netzlos) ·
  `d-check: 48 Datei(en) geprüft, 0 Befund(e)` (`--network none`, Digest-Ref
  `sha256:9c317bf1…36a1`) · bats `1..50 … ok 50` (drei neue Freshness-Tests grün, `--network none`) ·
  shellcheck ohne Befund · `record-gates`.
- Nuance (wie in slice-016/017): Lauf auf dem Working Tree, nicht auf frischem Klon — der
  Frisch-Klon-Beweis bleibt die bekannte MR-003-CI-Restlücke nach Commit; kein Blocker.

### DoD-7 — Closure-Notiz mit Steering-Loop-Lerneintrag — **AUSSTEHEND (Planner-Schritt, kein VIOLATED)**
- `slice-018-…md` §7 (`:111-113`) trägt weiter den Platzhalter „`<!-- Erst nach Abschluss füllen. -->`".
  Die Closure-Notiz wird per Prozess **nach** der Verifikation in der Planner-Rolle geschrieben (wie in
  der Aufgabe vorgegeben) — daher **erwartet leer**, kein VIOLATED. Vor `git mv → done/` mit echtem
  Steering-Loop-Lerneintrag nachzutragen (Modul 5).

---

## Plan-vs-Code-Diff (Verifier-spezifisch)

**Plan-Tabelle §3 vollständig gedeckt:**
- `harness/tools/baseline-freshness.sh` (neu, Fetch↔Vergleich getrennt, shell-lint-gedeckt): vorhanden,
  shellcheck-clean, Trennung real. ✓
- `Makefile` (update: `baseline-freshness`-Target **nicht** in `gates`; `regelwerk-check`-`@echo` auf das
  neue Target): `.PHONY` ergänzt (`:30`), Target `:87-88` (Maintenance/CI, nicht in `gates`), `@echo`
  umgestellt (`:76`). ✓
- `test/baseline-freshness.bats` (neu, Fixtures aktuell/neuer-Tag/Fetch-Fehler): drei hermetische Tests,
  in `make test`/`make gates` grün. ✓
- `harness/conventions.md` MR-007 (update: Auflösungs-Trigger offene Lücke → gelöst): umgesetzt
  (`:276-282`). ✓

**Im Review ergänzte Änderungen — plan-konsistent nach DoD-4-Nachzug:**
- **`make test --network none`** (Review INFO-1): die DoD-4-Prosa wurde **nachgezogen** („Strukturell
  erzwungen (Review INFO-1): `make test` läuft mit `--network none`") und das Makefile-`test`-Recipe
  trägt das Flag. Der Nachzug macht die strukturelle Netz-Isolation zum **DoD-Bestandteil** —
  plan-konsistent (der Diff und die DoD stimmen jetzt überein). Wirkungs-Nuance: das Flag härtet die
  **gesamte** bats-Suite netzlos, nicht nur die Freshness-Tests; alle 50 Tests laufen netzlos grün,
  kein Test brauchte Netz — Härtung im Sinn der offline-grün-Zusage, kein Scope-Creep.
- **Makefile-`make`-Kollaps-Caveat** (Review LOW-1): der `baseline-freshness`-Kommentar nennt jetzt den
  make-Exit-2-Kollaps analog zum Schwester-Target `regelwerk-check` (`Makefile:58-61`). Reine
  Doku-Ehrlichkeit/Konsistenz — plan-konsistent (die DoD verlangt „spiegelt die 0/1/2-Semantik von
  `regelwerk-check`"; der Caveat spiegelt dessen Kommentar mit), kein Scope-Creep.
- **Slice-Doc-Diff** entfernt zudem zwei `d-check:ignore`-Kommentare (die „geplante Datei"-Ausnahmen),
  weil die Datei nun existiert — konsistenter Nachzug „Doc führt, Code folgt", kein Widerspruch.

**Realer Änderungs-Umfang:** Working Tree = 4 Sach-Dateien (`Makefile`, `harness/conventions.md`,
`harness/tools/baseline-freshness.sh`, `test/baseline-freshness.bats`) + `slice-018-…md` (Plan-Schärfung)
+ 1 untrackt (`…-slice-018-impl-review.md`, Modul-10-Review-Artefakt); committet = `2a7c84a`
(Eintritts-Move). **Kein Scope-Creep** — alles innerhalb §3. Bewusst **ausgelagert** und nicht im Diff:
der scheduled CI-Job (`.github/workflows/`, Plan §6 — Folge-Slice, neue Sub-Area).

## ADR-Konformität

- **Keine ADR berührt:** `git diff --name-only` trifft kein `docs/plan/adr/000*.md`; der `matrix`-Sensor
  in `make gates` meldet 0 Befunde.
- **ADR-0003 (Docker-only Build) gewahrt:** der Host-`curl` im read-only Freshness-Sensor folgt exakt der
  etablierten Maintenance/Netz-Ausnahme des Schwester-Targets `regelwerk-check` (slice-009, ebenfalls
  Host-`curl`, ebenfalls **nicht** in `gates`). ADR-0003 normiert den Tool-**Build** (Go-Toolchain im
  gepinnten Image), **nicht** read-only Maintenance-Netzsensoren. Kein Host-`go`/`pip`/`npm`; die Gates
  (`test`/`shell-lint`/`docs-check`) bleiben Docker-only, `test` und `docs-check` zusätzlich
  `--network none`. Kein Verstoß.

## Read-only / Pin-Integrität (LH-QA-02/03)

- **Read-only:** `make baseline-freshness` nutzt `curl -fsSLI -o /dev/null` (HEAD); `git status --short`
  **vor und nach** dem Netz-Lauf identisch (dieselben 6 Einträge) — keine Mutation.
- **Minimale Abhängigkeiten (LH-QA-03):** nur bash + coreutils (`basename`) + curl; kein
  jq/API/JSON/node/python (die einzigen `jq`/`node`-Nennungen sind Kommentar-Negationen „ohne jq/API/JSON").
- **Reproduzierbarkeit (LH-QA-02):** kein neuer Pin; `BASELINE_TAG=v3.1.0` bleibt einzige Tag-Quelle,
  `BATS_IMAGE`/d-check-Digest unverändert.

---

## Verdikt

- **DoD substanziell bestätigt: JA** — **6 CONFIRMED, 0 VIOLATED, 1 AUSSTEHEND** (DoD-7 Closure-Notiz =
  erwarteter Planner-Schritt nach der Verifikation). Jede Behauptung mit ausgeführtem Beleg (Vergleicher
  0/1/2 live, echter Netz-Lauf `latest v3.2.0` + unabhängiger `curl`-Redirect-Beleg, Fetch↔Vergleich
  getrennt, shellcheck-clean, `baseline-freshness` **nicht** in `gates`/§4/§Sensors, `make test`
  `--network none` grün, MR-007-Trigger + `regelwerk-check`-`@echo` umgestellt, `make gates` **Exit 0**).
- **Plan-vs-Code:** §3-Tabelle vollständig gedeckt; die zwei im Review ergänzten Änderungen
  (`make test --network none`, Makefile-Kollaps-Caveat) sind nach dem DoD-4-Nachzug plan-konsistent;
  kein Scope-Creep; der CI-Job bleibt bewusst ausgelagert.
- **ADR-Konformität:** keine ADR berührt; ADR-0003 Docker-only gewahrt (Host-`curl` = etablierte
  `regelwerk-check`-Maintenance-Ausnahme, kein Verstoß).
- **`make gates`:** **Exit 0**, netzlos grün (50/50 bats, d-check + test unter `--network none`).
- **Reif für `done/`:** **NOCH NICHT — zwei Buchführungs-Schritte offen:** (1) die DoD-Kästchen in §2
  abhaken (Implementer), (2) §7 Closure-Notiz mit echtem Steering-Loop-Lerneintrag füllen (Planner).
  Die **Substanz** aller DoD-Punkte ist erfüllt; sobald Abhakung + Closure-Notiz stehen (und MR-007 ist
  bereits aktualisiert), ist der `git mv → done/` frei (der Verifier verschiebt nichts). Die
  Working-Tree-vs-Frisch-Klon-Nuance bleibt als MR-003-CI-Restlücke nach Commit offen, kein Blocker.
