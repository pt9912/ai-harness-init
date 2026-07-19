# Slice slice-019: Re-Baseline v3.1.0 → v3.5.0 (Kurs-Welle 32)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-19.

---

## 1. Ziel

Die committet vendored Baseline vom gepinnten Kurs-Tag **v3.1.0 auf v3.5.0** heben —
eine bewusste [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Operation. Es ist ein **Content-Bump, kein reiner Pin-Bump**: der
**Dateibestand bleibt bei 42** (regelwerk 21, templates 21 — `find -type f`, unverändert), aber
nahezu jeder **Inhalt** ändert sich — alle 21 regelwerk-Module und 15 der 21 Templates differieren
(Regelwerks-Stand **Kurs-Welle 26 · 2026-07-17 → Kurs-Welle 32 · 2026-07-19**, 6 Kurs-Wellen). Der
Baum bleibt netzlos auf jedem Checkout präsent; `make baseline-verify` und `make gates` bleiben grün
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)/[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

Ausgelöst durch `make baseline-freshness` (slice-018), das den neueren Upstream-Tag real
alarmiert hat.

## 2. Definition of Done

- [x] **Vendored Baum ersetzt.** `.harness/baseline/v3.5.0/{regelwerk,templates}/` aus dem
      v3.5.0-`lab-regelwerk.zip` entpackt (**42 Dateien**, gleicher Bestand wie v3.1.0), `SHA256SUMS` neu erzeugt
      ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 2: `sha256sum` über **alle** Dateien, Pfade relativ zu `<tag>/`,
      `LC_ALL=C`-sortiert, Datei selbst ausgenommen). Das alte `.harness/baseline/v3.1.0/`
      **entfernt** (Setzung 4: ein Tag zur Zeit). Der ZIP-sha256 ist **vor** dem Entpacken
      gegen den Pin verifiziert.
- [x] **Provenienz + Integrität gepinnt** ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1). `Makefile`
      `BASELINE_TAG` → `v3.5.0`, `BASELINE_ZIP_SHA256` → `123e3383261102e6be6465e1f4bade08a474c00edc4fff89f5c4b11bd640f8ff`.
      **Herkunft des Werts (nicht zirkulär):** `sha256sum` des Assets, **frisch von der offiziellen
      Release-URL** (`releases/download/v3.5.0/lab-regelwerk.zip`) gezogen — gemessen 2026-07-19
      (nicht aus dem Freshness-Alarm übernommen). Bei Vendoring **erneut gegen einen frischen
      Download gemessen**, bevor der Wert final gepinnt wird ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); die offizielle URL
      ist der Provenienz-Anker, `SHA256SUMS` trägt nur die Integrität — [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1).
- [x] **Kopplungspunkt Fetch.** `internal/fetch/fetch.go` `DefaultTag` → `v3.5.0` — per
      `TestDefaultTag_MatchesBaseline` an `BASELINE_TAG` gekoppelt (färbt sonst `make test` rot,
      [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)/`ADR-0001`). <!-- d-check:ignore (Verweis auf die superseded Skelett-Distributions-ADR; done/-Slice eingefroren) -->
- [x] **Kopplungspunkt Doku.** `harness/conventions.md` §Baseline: vendored Tag + kanonische
      Kurs-URL + „Regelwerks-Stand" (Welle 32 · 2026-07-19). Historische Einträge (MR-Bodies)
      bleiben eingefroren.
- [x] **Kopplungspunkt Emit-Embed (voraussichtlich fällig).** `internal/emit/skel/` bettet **15 der
      21** Templates ein (gemessen `find`; **nicht** dabei: `Makefile`, `.d-check.yml`,
      `project-readme`, die Set-Index-READMEs); mehrere eingebettete gehören zu den in v3.5.0
      geänderten (`AGENTS`/`conventions`/`lastenheft`/`slice.template` u. a.) → `test/skel-drift.bats`
      feuert voraussichtlich auf der **Gleichheit**-Achse (die **Vollständigkeit**-Achse kann nicht
      feuern — der Dateibestand bleibt gleich, kein neues Template). Embed **drift-test-gesteuert**
      re-syncen (kein Blind-Sync; nur was der rote Test benennt).
- [x] **slice-019-Template-Reconciliation.** `slice.template.md` hat sich v3.1.0→v3.5.0 geändert;
      dieser Slice wurde per `cp` aus der **v3.1.0**-Vorlage erzeugt. Nach dem Vendoring gegen die
      v3.5.0-Vorlage abgleichen (Struktur-Divergenz prüfen/übernehmen — dieselbe Reconciliation-Klasse
      wie slice-013).
- [x] **Kopplungspunkt reviewer.md (kein Gate fängt es — Stilles-Grün-Klasse).**
      `.harness/skills/reviewer.md` ist ein aus der Baseline **abgeleitetes** Artefakt, gepinnt auf
      „Agents-Regelwerk v3.1.0 (Kurs-Welle 26), Modul 10 §Ziel-Form" (`reviewer.md:4`) und zählt die
      „fünf v3.1.0-Pflicht-Punkte" auf (`reviewer.md:15`). Anders als das Emit-Embed prüft **kein Gate**
      diese Prosa-Drift (`v3.1.0` ist kein ID-Muster). Modul 10 §Ziel-Form der v3.5.0/Welle-32-Fassung
      gegen die fünf Punkte / das Output-Schema abgleichen; bei Änderung reviewer.md **versionieren**
      (→ 1.2.0, analog slice-014), sonst in der Closure-Notiz **explizit begründen**, warum unverändert.
- [x] `make gates` grün (inkl. `baseline-verify`: Integrität **und** Vollständigkeit netzlos).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v3.1.0/` → `…/v3.5.0/{regelwerk,templates}/` + `SHA256SUMS` | replace | Baum neu vendoren; alter Tag raus (Setzung 4) |
| `Makefile` (`BASELINE_TAG`, `BASELINE_ZIP_SHA256`) | update | Tag + Provenienz-Pin |
| `internal/fetch/fetch.go` (`DefaultTag`) | update | Fetch-Pin gekoppelt (Tier-1-Drift-Test) |
| `harness/conventions.md` §Baseline | update | Tag + Kurs-URL + Regelwerks-Stand (Welle 32) |
| `internal/emit/skel/` | voraussichtlich update | Embed re-sync (breite Template-Änderung), drift-test-gesteuert (slice-003) |
| `README.md` (Zeile 26) | update | harter Literal-Pfad `.harness/baseline/v3.1.0/` (kein generisches `<tag>`) → sonst tote Repo-Wurzel-Referenz |
| `.harness/skills/reviewer.md` | ggf. update | Baseline-Pin v3.1.0/Welle 26 + „fünf Punkte" gegen Modul 10 §Ziel-Form v3.5.0 abgleichen (kein Gate fängt es) |
| slice-019 selbst | reconcile | gegen die geänderte v3.5.0-`slice.template.md` abgleichen |

**Vollständigkeits-Analyse (Review-korrigiert — die Erstfassung war unter-inklusiv):**
`AGENTS.md`/`CLAUDE.md` nutzen `<tag>` generisch (Glob/Variable) — kein Bump
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 4). **Aber** `README.md:26` verdrahtet den Literal-Pfad
`.harness/baseline/v3.1.0/` → **jetzt im Scope** (mein erster Grep hatte es durch die eigene
Exclude-Zeile übersehen). Zu den repo-eigenen `blob/v3.1.0/kurs/…`-Prozess-Links s. §6
(bewusste Bump-vs.-Einfrieren-Entscheidung). Historische MR-Bodies bleiben Zeitbezug.

## 4. Trigger

**Erfüllt:** v3.5.0 ist upstream publiziert (Asset `lab-regelwerk.zip` HTTP 200, kein
Draft/Prerelease; `make baseline-freshness` alarmierte den neueren Tag). Vorher (Asset 404)
**blockiert** — ein Fetch gegen ein nicht existentes Release scheitert.

- `in-progress → next`: falls zu groß (z. B. Emit-Embed-Rattenschwanz sprengt den Schnitt) →
  zurück zur Zerlegung.
- `in-progress → open`: falls das Release zurückgezogen/defekt ist → blockiert.

## 5. Closure-Trigger

DoD vollständig + Review konform (Integrität/Provenienz bestätigt) + Verifikation + Closure-Notiz
→ nach `done/`.

## 6. Risiken und offene Punkte

- **Content-Bump, nicht Pin-Bump — Emit-Embed ist die Kern-Unsicherheit.** Der Dateibestand bleibt
  bei 42, aber nahezu jeder Inhalt ändert sich (alle 21 regelwerk-Module, 15 der 21 Templates —
  gemessen `diff -rq`). `internal/emit` bettet eine Template-Teilmenge ein (`internal/emit/skel/`,
  slice-003) mit einem Gleichheit-**und**-Vollständigkeit-Drift-Wächter. Da die eingebetteten
  Templates zu den geänderten gehören, feuert der Wächter **voraussichtlich** — das Embed ist dann
  drift-test-gesteuert nachzuziehen (analog dem Emit-Pin in slice-015). Blind-Sync ohne roten Test
  wäre falsch.
- **Zahlen-Korrektur (Beleg für die Klasse).** Die Erstfassung dieses Slice behauptete „42→54
  Dateien / templates 21→32" — das waren `unzip -Z1`-**Verzeichnis-Einträge**, als Dateien
  fehlgezählt (`find regelwerk templates -type f` misst **42** je Bump-Seite; der volle Baum inkl.
  `SHA256SUMS` ergäbe 43). Genau die „behauptete statt gemessene Zahl"-Klasse, die slice-015
  adressiert; hier zweimal in *diesem* Plan aufgetreten (auch das `Makefile`-Beispiel in Do 5) und
  vom Plan-Review gemessen korrigiert.
- **Kurs-Prozess-Links (`blob/v3.1.0/kurs/…`) — bewusste Entscheidung, nicht Automatismus.** Rund
  ein Dutzend Planungs-Docs tragen solche Links. **Kanonisch** ist allein `conventions.md` §Baseline
  (DoD 4) — sie ist der eine Kurs-Pin. **Setzung:** done/-Slices bleiben **eingefroren** (Zeitbezug —
  sie hielten den Stand ihres Entstehens fest); die **live** Docs (roadmap in-progress, offene Slices,
  Wellen-Pläne) tragen die Links als *auxiliare* Prozess-Referenz, **nicht** als zweiten Pin — sie
  ziehen mit, wenn sie ohnehin angefasst werden (z. B. slice-019 selbst über die
  slice.template-Reconciliation), sonst bleiben sie Zeitbezug. Kein repo-weiter Zwangs-Bump (das wäre
  die Wartungsfalle, vor der slice-015 §6 warnt).
- **Provenienz ≠ Integrität** ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1). `SHA256SUMS` (selbst erzeugt) beweist nur,
  dass der Baum sich seit dem Vendoring nicht bewegt; die **Herkunft** hängt allein an
  `BASELINE_ZIP_SHA256` (gegen das Release-Asset). Beide sind zu führen.
- **Re-Review des Fremd-Blobs.** Der vendored Baum ist ein ~250-KB-Fremd-Blob; die Rolle
  Reviewer/Verifier bestätigt Integrität (SHA256SUMS `-c` grün + Vollständigkeit) und Provenienz
  (ZIP-sha256 == Pin), nicht Zeile-für-Zeile-Inhalt.
- **Kurs-Anker-Drift.** Regelwerk und Kurs sind zwei divergente Bäume; interne Verweise des
  vendored Baums lösen lokal auf (Geschwister-Templates). Bei Welle-32-Umbau könnten Ziel-Form-Pfade
  gewandert sein — `baseline-verify` prüft Integrität/Vollständigkeit, **nicht** die internen Links
  des Fremd-Baums (der ist `scan.ignore`).

## 7. Closure-Notiz (nach `done/`)

**Geliefert (2026-07-19).** Committet vendored Baseline **v3.1.0 → v3.5.0** (Kurs-Welle 32),
42 Dateien, `SHA256SUMS` neu; ZIP-sha256 vor dem Entpacken gegen den Pin verifiziert
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 1). **Acht** Kopplungspunkte nachgezogen — `BASELINE_TAG`/`BASELINE_ZIP_SHA256`,
`internal/fetch` `DefaultTag`, `conventions.md` §Baseline, `README.md:26`, das **Emit-Embed**
(`internal/emit/skel`, 15 Dateien, **drift-test-gesteuert** re-synct) und **reviewer.md** (→ 1.2.0).
`make baseline-verify` + `make gates` grün.

**Rollenkette (Modul 8, je frischer Kontext).** Reviewer (Modul 10): **nicht merge-blockierend**,
0 HIGH/MEDIUM/LOW (`docs/reviews/2026-07-19-slice-019-review.md`) — Provenienz (sha256 == Pin,
echtes v3.5.0), Integrität (Baum byte-gleich zum ZIP) und alle Kopplungen selbst nachgemessen.
Verifier (Modul 11): **alle 8 DoD CONFIRMED, 0 VIOLATED** (`docs/reviews/2026-07-19-slice-019-verify.md`),
inkl. selbst gefahrenem `make gates` (Exit 0) und `curl` des Release-Assets.

**Steering-Loop-Lerneintrag 1 (benannte Spec-Lücke — der eigentliche Fund).** Ein Re-Baseline hat
**ungegatete** baseline-abgeleitete Kopplungspunkte: `reviewer.md` (Baseline-Version-Pin) und
`README.md:26` (harter `.harness/baseline/<tag>/`-Pfad) driften **still** — **kein Gate** fängt sie
(Prosa bzw. Root-Datei außerhalb `codepaths.roots`; `v3.1.0` ist kein ID-Muster). Gefangen wurden sie
nur durch das **Plan-Review** (reviewer.md) und ein **manuelles Audit** (README) — nicht durch
`make gates`. **Regel/Bedarf:** Ein Re-Baseline braucht eine Checkliste **aller** baseline-abgeleiteten
Artefakte inklusive der ungegateten (Kandidat: [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Ergänzung oder ein Drift-Sensor auf
den `<tag>`-String in `reviewer.md`/`README.md`). Die **gegateten** Kopplungen (fetch-`DefaultTag`,
emit-skel) fingen ihre Drift dagegen zuverlässig — der Unterschied ist genau „hat einen Sensor".

**Steering-Loop-Lerneintrag 2 (wiederkehrende Klasse, belegt).** „Behauptete statt gemessene Zahl"
trat in *diesem* Slice **mehrfach** auf: `42→54` (`unzip`-Verzeichnis-Einträge als Dateien),
`Makefile` als embedded Template (ist nicht embedded), Wave-Count `5→6`. `codepaths.check-lines`
(slice-015) deckt nur `datei:zeile`, **nicht** freie Prosa-Zahlen — genau die Abgrenzung, die
slice-015 §6 vorhersagte. Die 3-fache Wiederholung ist selbst das Signal (reviewer.md: „dritte
Wiederholung derselben Klasse ⇒ Steering-Loop-Signal"); Prosa-Zahlen bleiben Review-Territorium,
hier von Pair-Partner + Plan-Review gefangen.

**Content-Bump bestätigt (gemessen):** 21/21 regelwerk-Module + 15/21 Templates geändert; skel-Drift
feuerte nur auf der Gleichheit-Achse (Dateibestand unverändert), exakt wie geplant.

**Gemeldet, nicht in diesem Scope (Folge-Punkte):** (a) `README.md:24` nennt „d-check **v0.46.0**"
— stale Nachhall aus slice-015 (Repo pinnt v0.50.0); bewusst außerhalb des Baseline-Scopes gelassen,
Folge-Fix. (b) `internal/fetch/fetch_test.go` trägt `v3.1.0`-Fixture-Literale — funktional inert
(gemockter Fetcher, reale Kopplung via `TestDefaultTag_MatchesBaseline`), benigne INFO.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.harness/baseline/`
(vendored Baum), `Makefile`/Gate-Config, `internal/fetch`+`internal/emit` (Pin-/Embed-Kopplung)
und die Doku teilen die adoptierte Harness-Mechanik ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)); GF (Doc führt).
