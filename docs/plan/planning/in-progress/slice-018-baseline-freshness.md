# Slice slice-018: Baseline-Freshness — Release-Listen-Sensor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** welle-03-durchsetzung-und-emission (Welle-Plan folgt) — Sibling zu slice-009
(regelwerk-check). Einordnung *(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) — dieser Slice **löst dessen benannte offene Lücke** (Sensor auf die Release-*Liste* statt aufs Asset). Baut auf slice-009 (regelwerk-check, Asset-Achse).

**Autor:** Nutzer (Plan) · Claude (Plan-Review + Anlage). **Datum:** 2026-07-18.

---

## 1. Ziel

Ein read-only `make baseline-freshness` meldet, ob upstream ein **neuerer Tag** als
`BASELINE_TAG` existiert — die Achse, die `regelwerk-check` (slice-009) **nicht** sieht:
der prüft nur, ob das *Asset des gepinnten Tags* nachträglich verändert wurde, nicht ob ein
neuer Tag erschien ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), Auflösungs-Trigger: „offene Lücke … Kandidat für einen
eigenen Slice"). Zusammen ergeben beide das volle Upstream-Bild. Netz-Operation,
**außerhalb** von `gates` (offline-grün bleibt, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

**Kernmechanismus (ohne jq/API/JSON, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)):** dem Redirect von
`…/releases/latest` folgen und die effektive URL lesen — sie endet auf
`/releases/tag/<latest>`. `curl -fsSLI -o /dev/null -w '%{url_effective}'` + `basename`,
Vergleich gegen `BASELINE_TAG`. Exakt der Stack von `regelwerk-check` (bash + coreutils +
curl); der `releases/latest`-Redirect ist in-repo bereits etabliert (der Baseline-Download
in `regelwerk/README.md` nutzt ihn).

> **Plan-Review-Vermerk (Herkunft der Idee).** Die „Release-Liste-statt-Asset"-Denkweise
> stammt aus dem Kurs-Fortschritt *oberhalb* des adoptierten Standes (die vendored Baseline
> ist **Kurs-Welle 26**). Sie wird hier **nicht** als normatives Zitat geführt, sondern auf
> die präsente Quelle gestützt: [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) benennt genau diese Lücke selbst. Sollte upstream
> tatsächlich weiter sein, ist das der erste reale Befund, den dieser Sensor liefern soll.
> **Gemessen (2026-07-18, unabhängiger Plan-Review, reine Leseoperation):** `releases/latest`
> löst auf `…/releases/tag/**v3.2.0**` auf, gepinnt ist `BASELINE_TAG=v3.1.0` — die Lücke ist
> **real, nicht hypothetisch**; der Sensor alarmierte beim ersten Lauf. Das Re-Baseline auf den
> neuen Tag ist eine **separate**, bewusste Operation ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Ablauf), nicht Teil dieses Sensor-Slice.

## 2. Definition of Done

- [x] `make baseline-freshness` löst `releases/latest` per Redirect-Follow auf, extrahiert
      den neuesten Tag, vergleicht mit `BASELINE_TAG`: gleich → exit 0 „aktuell"; neuerer Tag
      → nonzero + klare Meldung (`gepinnt: … / latest: …`); Fetch-Fehler **≠** veraltet
      (eigener Exit/Hinweis) — spiegelt die 0/1/2-Semantik von `regelwerk-check`.
- [x] Logik in `harness/tools/baseline-freshness.sh`, **Fetch↔Vergleich getrennt** (hermetisch
      testbar); shellcheck-clean (von `shell-lint` gedeckt). Reuse `BASELINE_TAG` als einzige
      Tag-Quelle ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) — kein neuer Pin-Speicher.
- [x] **Nicht in `gates`, keine Sensor-Promotion** (Netz bräche offline-grün,
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — Maintenance/CI-Target. `make gates` bleibt netzlos (offline verifiziert).
- [x] **Hermetischer bats-Test** (Docker-only, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)): der **Vergleicher** wird mit
      Fixture-Strings getestet (`latest==pinned` → ok · `latest!=pinned` → Alarm · leer/Fehler
      → eigener Exit) — der Test trifft **nie** das Netz. **Gate-tragend (Plan-Review F-1):** die
      bats-Suite läuft über `make test` **in `gates`**; die Fetch↔Vergleich-Trennung muss daher
      garantieren, dass der Vergleicher-Test das Netz nicht trifft — sonst bräche `make gates`
      offline-grün ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **Strukturell erzwungen (Review INFO-1):** `make test` läuft mit
      `--network none` — die Test-Hermetik hängt nicht mehr nur an Code-Pfad-Disziplin, sondern
      am Container.
- [x] `regelwerk-check`s Schluss-`@echo` („Release-Liste separat prüfen") **und** der
      [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Auflösungs-Trigger („offene Lücke … Kandidat für einen eigenen Slice")
      auf `make baseline-freshness` verweisen — Prosa-Hinweis wird ausführbarer Zeiger, Lücke
      als gelöst markiert.
- [x] `make gates` grün + Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/baseline-freshness.sh` | neu | Fetch↔Vergleich getrennt (hermetisch testbar), shell-lint-gedeckt |
| `Makefile` | update | `baseline-freshness`-Target, **nicht** in `gates`; `regelwerk-check`-`@echo` auf das neue Target zeigen |
| `test/baseline-freshness.bats` | neu | Vergleicher-Fixtures: aktuell / neuer Tag / Fetch-Fehler |
| `harness/conventions.md` ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) | update | Auflösungs-Trigger: offene Lücke → gelöst (slice-018) |

## 4. Trigger

Sofort startbar; setzt `BASELINE_TAG` + `regelwerk-check` (slice-009, [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) voraus —
existiert. Rückführungen: `in-progress→next` bei zu großem Schnitt; `in-progress→open` bei
Blocker (Carveout, `modul-07`).

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifier bestätigt + [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) aktualisiert +
Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Netz-Abhängigkeit: bewusst nicht in `gates`** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Anti-Ziel) — nur
  Maintenance/CI. `make gates` bleibt offline-grün, verifiziert.
- **Tag-Vergleich statt SemVer.** Alarm = „latest ≠ gepinnt". Setzung: `releases/latest` ist
  das neueste veröffentlichte Release; auf etwas anderem zu sitzen ist der Review-Auslöser.
  Ein voller „ist-neuer"-SemVer-Vergleich wird bewusst **nicht** gebaut (YAGNI,
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)). Kante: ein Pre-Release könnte `latest` verschieben — für einen
  Freshness-Alarm akzeptabel (Worst Case: ein manueller Blick).
- **Redirect-Stabilität.** Ändert GitHub das `releases/latest`-Verhalten, bricht der
  Extraktor **sichtbar** (Fetch-/Parse-Fehler → eigener Exit), nicht still — wie
  `regelwerk-check`s Fetch-Fehler-Pfad.
- **Modul-5-Größe.** Der Kern (Tool + hermetischer Test + Makefile-Verdrahtung +
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Update) hält ≤ 2 Schichten. Der **scheduled CI-Job** (`.github/workflows/`,
  periodischer Dual-Sensor-Alarm) ist eine **neue Pfad-Familie** mit eigener
  Sub-Area-Modus-Begründung — bewusst **als Folge-Slice** ausgelagert, nicht in diesem
  Kern-Slice, damit der Schnitt in einer Review-Sitzung prüfbar bleibt (Modul 5).
- **Kein neuer ADR/Werkzeug.** bash/coreutils/curl + Docker-bats + shell-lint sind der
  vorhandene Stack; der Netz/Netzlos-Schnitt folgt der `regelwerk-check`-Linie. Der Architect
  bestätigt nur diesen Schnitt.
- **Aktion bei Alarm (Prozess, kein Code):** neuerer Tag → manuelles Re-Baseline-Review (Baum
  neu vendoren + `BASELINE_TAG`/`BASELINE_ZIP_SHA256` neu pinnen, der
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Ablauf). Der Check **mutiert nichts**.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** `make baseline-freshness` (read-only) schließt die von [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
benannte Lücke: es folgt dem `releases/latest`-Redirect und meldet einen neueren Upstream-Tag als
`BASELINE_TAG` (die **Tag-Achse** neben `regelwerk-check`s Asset-Achse). Logik in
`harness/tools/baseline-freshness.sh` (Fetch↔Vergleich getrennt, shellcheck-clean); hermetischer
bats-Test (3 Fixture-Fälle); **nicht** in `gates` (Netz); `regelwerk-check`-`@echo` + der
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Auflösungs-Trigger zeigen jetzt darauf.

**Was funktionierte.** Der Smoke bewies die Lücke sofort **real**: `make baseline-freshness`
alarmierte `gepinnt v3.1.0 / latest v3.2.0` — kein hypothetischer Bedarf, sondern ein aktueller
Befund. Die Fetch↔Vergleich-Trennung machte den Test hermetisch (nur `--compare`, kein Netz). Die
Rollen-Trennung fing beide Review-Befunde: LOW-1 (make kollabiert den Exit auf 2 — Caveat ergänzt)
und INFO-1 (Härtung).

**Was anders lief.** INFO-1 des Reviews führte zu einer **Bonus-Härtung über slice-018 hinaus:**
`make test` läuft jetzt mit `--network none` — die Test-Hermetik (und damit die offline-grün-Zusage
von `make gates`, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) ist strukturell erzwungen, nicht mehr nur per
Code-Pfad-Disziplin. Das deckt **alle** Tests, nicht nur slice-018.

**Steering-Loop-Einträge.**
1. *Neuer Sensor:* `make baseline-freshness` schließt die [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Tag-Achsen-Lücke —
   beide Upstream-Achsen (Asset via `regelwerk-check`, Tag via `baseline-freshness`) sind jetzt
   bewacht; `baseline-verify` bleibt die netzlose Arbeitskopie-Prüfung. Der ausgelagerte scheduled
   CI-Job (§6, `.github/workflows/`) bleibt ein Folge-Slice.
2. *Geschärfte Praxis (Härtung):* `make test --network none` — offline-grün ist jetzt am Container
   erzwungen, nicht per Disziplin. Muster übertragbar (vgl. `docs-check --network none`, slice-017).
3. *Realer Befund → Aktion:* Der erste Sensor-Lauf zeigt, dass das Baseline **veraltet** ist
   (`v3.1.0` vendored, `v3.2.0` upstream). Ein Re-Baseline auf `v3.2.0` ist die bewusste
   [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Operation — jetzt **sensor-belegt**, nicht mehr nur vermutet.

**Folge-Slices.** (a) **Re-Baseline `v3.1.0` → `v3.2.0`** (sensor-belegt, eigene
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Operation). (b) Optional der scheduled CI-Job (§6). Beides eigene Slices, nicht Teil
von slice-018.

**Verifikation.**
- `make gates`: grün (baseline-verify + docs-check 48/0 + **50 bats mit `--network none`** +
  shellcheck), Exit 0.
- **Smoke** `make baseline-freshness` (echter Netz-Lauf, read-only): alarmiert `v3.1.0` vs `v3.2.0`;
  mutiert nichts (Re-Baseline ist die separate Operation).
- Unabhängiger **Reviewer** (Modul 10, frischer Kontext): merge-blockierend **nein** (0 HIGH/MEDIUM;
  LOW-1 + INFO-1 beide behoben). Bericht: `docs/reviews/2026-07-18-slice-018-impl-review.md`.
- Unabhängiger **Verifier** (Modul 11, frischer Kontext): **6/7 DoD CONFIRMED, 0 VIOLATED** (DoD-7
  war dieser Closure-Schritt). Bericht: `docs/reviews/2026-07-18-slice-018-verification.md`.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/tools/`,
`Makefile`/Gate-Config, `test/` und die Doku teilen die adoptierte Harness-Mechanik
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) · slice-009); GF (Doc führt, Code folgt). Der ausgelagerte CI-Job
(`.github/workflows/`) wäre eine **neue** Sub-Area — dessen Modus-Begründung entsteht mit dem
Folge-Slice, nicht hier.
