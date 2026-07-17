# Slice slice-011: Baseline v3.0.0 committet vendoren

**Status:** next

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor), [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-16.

---

## 1. Ziel

Das Betriebsregelwerk wechselt vom **gefetchten, gitignorierten Cache** auf die
von der Baseline v3.0.0 vorgeschriebene **committet vendored** Form:
`.harness/baseline/v3.0.0/{regelwerk,templates}/` + `SHA256SUMS`, netzlos auf
jedem Checkout präsent. Quelle ist `lab-regelwerk.zip` vom Release-Tag `v3.0.0`
(ZIP-sha256 `86d90b97737ad79e2c7f5dce48cf9123fb2f75f01f2e33c720fcd2684190cd40`,
**vor** dem Vendoring verifiziert). Regelwerk **und** Templates liegen parallel —
die 15 `../templates/…`-Ziel-Form-Verweise des Regelwerks (in 12 der 21
Modul-Dateien) lösen dadurch netzlos lokal auf.

`make regelwerk-fetch` und `make regelwerk-check` entfallen; an ihre Stelle tritt
ein **netzloses** `baseline-verify` (`sha256sum -c SHA256SUMS`), das — anders als
der bisherige Netz-Fetch — **in `gates`** laufen kann, ohne offline-grün zu
verletzen ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).

Baseline-Vorgabe (Modul 2 §Anmerkung zur vendored Baseline, wortgleich):
„Regelwerk *und* Templates werden beim Bootstrap **committet vendored**
(`.harness/baseline/<tag>/{regelwerk,templates}/` + `SHA256SUMS`, netzlos
materialisiert), nicht pro Lauf extern gefetcht".

**Abgrenzung.** Dieser Slice nimmt **nur** die Mechanik und die Doku-Absätze mit,
**die diese Mechanik beschreiben** (`AGENTS.md` §1 Cache-Absatz, `CLAUDE.md`
Pointer) — sonst behauptet das Repo nach dem Merge weiter „gitignored, kein
committeter Fremd-Blob" und wäre eine Harness-Lüge. **Nicht** hier: die toten
externen Quellen-Pointer und `harness/conventions.md` §Baseline (slice-012), der
inhaltliche Konformitäts-Nachzug (slice-013) und der d-check-Pin-Sprung
(v0.10.0 → 0.43.1; eigenes Risiko, eigener Slice).

## 2. Definition of Done

- [ ] `.harness/baseline/v3.0.0/{regelwerk,templates}/` committet (54 Dateien;
      ZIP-sha256 `86d90b97…cd40` vor dem Entpacken verifiziert) + erzeugtes
      `SHA256SUMS`; Stichprobe belegt, dass ein `../templates/…`-Verweis aus
      `regelwerk/` lokal auflöst ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- [ ] `Makefile`: `regelwerk-fetch`/`regelwerk-check` entfernt; `baseline-verify`
      (netzlos, `sha256sum -c`, kein `curl`/`unzip`) ist Prerequisite von `gates`
      und schlägt bei manipulierter Arbeitskopie **rot** aus — real vorgeführt
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- [ ] Injektor (`harness/tools/sessionstart-inject-regelwerk.sh`) liest den Index
      unter `.harness/baseline/v3.0.0/regelwerk/README.md`; `test/sessionstart.bats`
      auf den neuen Pfad nachgezogen und grün.
- [ ] `.gitignore` (`.harness/cache/`-Block entfällt) und `.d-check.yml`
      (`scan.ignore`: `.harness/cache/**` → `.harness/baseline/**`) nachgezogen;
      `make docs-check` grün **mit** dem committeten Baum (er trägt fremde
      MR-/ADR-Kennungen, die sonst die `ids`-Link-Pflicht treffen).
- [ ] Neuer Adaptions-Eintrag in `harness/conventions.md` (nächste freie Nummer
      nach [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)): Vendoring-Mechanik, **Tradeoff drift-blind** (s. §6),
      Setzung für `SHA256SUMS`-Umfang und `<tag>`-Politik; [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis) und der
      Cache-Teil von [`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) als Historie markiert (nicht überschrieben).
- [ ] `AGENTS.md` §1 + `CLAUDE.md` beschreiben die vendored Form (Pfad, netzlos,
      Index + Modul on-demand); „gitignored", „kein committeter Fremd-Blob",
      „`make regelwerk-fetch` ausführen" und „wortgleich" entfallen dort.
- [ ] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.harness/baseline/v3.0.0/` | neu | Vendored Baseline (Regelwerk + Templates parallel) + `SHA256SUMS` |
| `Makefile` | update | `regelwerk-fetch`/`-check` raus; netzloses `baseline-verify` in `gates` |
| `harness/tools/sessionstart-inject-regelwerk.sh` | update | Index-Pfad auf `.harness/baseline/v3.0.0/regelwerk/README.md` |
| `test/sessionstart.bats` | update | Pfad + Warn-Pfad (fehlende Baseline) |
| `.gitignore` | update | `.harness/cache/`-Block entfällt (Cache obsolet) |
| `.d-check.yml` | update | `scan.ignore` auf `.harness/baseline/**` |
| `harness/conventions.md` | update | neuer MR-Eintrag; [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)/[`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor) als Historie |
| `AGENTS.md` (§1), `CLAUDE.md` | update | Mechanik-Absätze auf die vendored Form |

## 4. Trigger

Sofort startbar — reine Harness-Mechanik, unabhängig vom Go-CLI. Setzt nichts
voraus außer dem verifizierten ZIP.

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Drift-blind (bewusste Nutzer-Entscheidung).** Mit `regelwerk-check` entfällt
  die einzige Upstream-Drift-Erkennung; das Repo merkt einen neuen Kurs-Release
  nicht mehr von selbst. `baseline-verify` prüft **nur** die Integrität der
  eigenen Arbeitskopie, nicht den Upstream. v3.0.0 setzt einen „Drift-Audit gegen
  die Baseline" voraus (`AGENTS.template.md`), prozeduralisiert ihn aber nirgends
  — der Verzicht ist damit keine Baseline-Verletzung, aber eine bewusste
  Reduktion. Gehört mit **Auflösungs-Trigger** in den neuen MR-Eintrag.
- **Doku-Gate gegen den committeten Baum.** Der vendored Baum trägt fremde
  MR-/ADR-Kennungen (Kurs-eigene Beispiele, nicht die des Repos — u. a.
  `regelwerk/modul-02:153,216`, `modul-08:82`, `modul-13:143`). Ohne
  `.harness/baseline/**` in `scan.ignore` färbt `make docs-check` rot — vor dem
  Commit verifizieren, nicht danach. Ein gitignorierter Cache war nie im
  Scan-Bereich; ein committeter Blob ist es.
- **`SHA256SUMS`-Umfang ist eine Repo-Setzung, keine Vorgabe.** v3.0.0 sagt nur
  *dass* die Datei existiert; Format, Umfang und Erzeugung sind unspezifiziert,
  und das ZIP liefert **keine** mit. Vorschlag: `sha256sum` über alle 54 Dateien
  beider Bäume, Pfade relativ zu `<tag>/`. Im MR-Eintrag festschreiben.
- **`<tag>`-Politik ist eine Repo-Setzung.** Das Regelwerk sagt zu alten
  `<tag>`-Verzeichnissen nichts (Koexistenz vs. Ersetzen). Vorschlag: ein Tag zur
  Zeit (Ersetzen), Historie liegt in git. Im MR-Eintrag festschreiben.
- **~245 KB committeter Fremd-Blob.** Bewusst: `AGENTS.md` §1 verbot das bisher
  ausdrücklich. Der Gewinn ist netzlose Präsenz auf jedem Checkout und der
  Wegfall der Host-`curl`/`unzip`-Maintenance-Abhängigkeit — beides zahlt auf
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ein.
- **Presence-Garantie unverändert schwach (Codex).** Index-only-Inject bleibt wie
  in [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis); v3.0.0 deckt read-on-demand ausdrücklich („ohne das ganze
  Regelwerk im Kontext zu halten"). Kein Gate-Verlust, kein neuer Tradeoff.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.0.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`harness/tools/`, die `.codex/`-Injektion, `Makefile`/Gate-Config und die Doku
teilen die adoptierte Harness-Mechanik ([`MR-004`](../../../../harness/conventions.md#mr-004--sessionstart-regelwerk-injektor), [`MR-006`](../../../../harness/conventions.md#mr-006--regelwerk-cache-als-split-modul-verzeichnis)); GF (Doc führt).
Der vendored Baum selbst ist **kein** zu reifendes Artefakt — Modul 2 hält
ausdrücklich fest: „vendored Baseline + Tooling tragen keine Phase-Reife".
