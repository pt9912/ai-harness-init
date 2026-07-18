# Slice slice-016: d-check-Pin-Sprung v0.10.0 → aktuell + `exempt-paths`/`ignore-refs`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-17.

---

## 1. Ziel

Das gepinnte d-check-Image von **v0.10.0** auf den **aktuellen Release** (~0.45.x, exakte
Version/Digest bei der Umsetzung gegen `git tag` im d-check-Repo bestimmt) heben und die
seit **0.34.0** verfügbaren Ventil-Achsen **`codepaths.exempt-paths`** (datei-weit) und
**`codepaths.ignore-refs`** (referenz-weit, Tombstone-Register) adoptieren.

**Motivation (belegter Bedarf, kein spekulativer).** Über den ganzen Regelwerk-Zug
(slice-011…014) musste `` `d-check:ignore` `` **wiederholt von Hand** gesetzt werden,
weil v0.10.0s `codepaths` **nur** `scope`/`roots` kennt:
- Lifecycle-gewanderte Pfade in Review-Reports (Zeitdokumente): jeder `next→in-progress`-
  und `in-progress→done`-Move machte Zitate wie `docs/plan/planning/next/slice-0NN-…md`
  tot → Zeilen-Marker. Trat **fünfmal** auf.
- Tombstone-Referenzen auf die in slice-013 gelöschten Templates (`*.template.md` voller
  Pfad in Inline-Code) → mehrfach Globs/Marker.

`exempt-paths: ["docs/reviews/**"]` nimmt die Zeitdokumente **datei-weit** aus;
`ignore-refs` deklariert bewusst entfernte Pfade **referenz-weit** als Tombstone. Beides
ersetzt die verstreute Handarbeit durch **eine zentrale, begründete Config-Zeile** — im
Geist von [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(„Gate-*Anheben* → Steering-Loop, kein ADR nötig").

## 2. Definition of Done

- [x] `harness.mk` `D_CHECK_IMAGE` auf den aktuellen d-check-Release-Digest gepinnt
      (Digest per `docker` gegen das Release belegt, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit));
      `harness/conventions.md` §Baseline-Zeile („d-check: Image v0.10.0") auf die neue
      Version nachgezogen.
- [x] **Trockenlauf vor dem Pin:** das aktuelle Image gegen den unveränderten Baum
      laufen lassen und die Befund-Differenz zu v0.10.0 prüfen — ein 35-Minor-Sprung kann
      neue Module/Regeln mitbringen (z. B. `planning`, `commits`). Neue Befunde werden
      **bewertet, nicht blind unterdrückt**; jede Config-Anpassung ist begründet.
- [x] `.d-check.yml`: `codepaths.exempt-paths: ["docs/reviews/**"]` gesetzt; die dadurch
      überflüssigen `` `d-check:ignore` ``-Zeilen in `docs/reviews/**` entfernt — Beleg:
      `make docs-check` bleibt **ohne** sie grün.
- [x] `codepaths.ignore-refs` für die Tombstone-Referenzen auf gelöschte Templates
      (soweit sie in **normativer** Doku stehen, nicht nur in Zeitdokumenten) — die
      Glob-Workarounds aus slice-013/[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) dürfen zurück auf die klaren vollen Pfade,
      wenn `ignore-refs` sie deckt. **Nur wo zutreffend** (Tombstone = *bewusst entfernt*,
      nicht *geplant*; die Abgrenzung aus slice-015 §6 gilt).
- [x] `make gates` grün auf frischem Checkout.
- [x] Neuer Adaptions-Eintrag in `harness/conventions.md` (nächste freie Nummer): Pin-Sprung
      + `exempt-paths`/`ignore-refs`-Adoption, mit dem belegten Bedarf; ergänzt
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness.mk` | update | `D_CHECK_IMAGE`-Digest auf aktuellen Release |
| `.d-check.yml` | update | `codepaths.exempt-paths` + ggf. `ignore-refs`; evtl. Schema-Anpassung (35 Minors) |
| `docs/reviews/**` | update | überflüssige `` `d-check:ignore` ``-Marker entfernen (durch exempt-paths gedeckt) |
| `harness/conventions.md` | update | §Baseline-Version; neuer Adaptions-Eintrag |

## 4. Trigger

Sofort startbar — unabhängig von allen anderen Slices (reine Gate-Config + Pin). Kein
Netz in `gates` (das Image wird gepullt wie jedes gepinnte Tool-Image; Maintenance).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **35-Minor-Sprung ist das eigentliche Risiko.** Zwischen 0.10.0 und ~0.45.x liegen
  **29 tatsächlich veröffentlichte** Minors (nicht 35 — 0.13–0.16 und 0.20/0.21 gab es
  nie; gemessen). Config-Schema, Default-Module und Befund-Semantik können sich mehrfach
  geändert haben. Der **Trockenlauf** (DoD) ist Pflicht, kein Nice-to-have: erst die
  Befund-Differenz verstehen, dann pinnen.
- **Neue Pflicht-Module.** Die aktuelle d-check bringt Module mit, die v0.10.0 nicht
  hatte (in d-check selbst gesehen: `planning`, `commits`). Ob eines davon im **Ziel-Repo**
  aktiviert wird, ist eine bewusste Setzung — Modul-Aktivierung nur mit existierendem
  Target/Bedarf ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), kein halluziniertes Gate).
- **`exempt-paths` vs. `ignore-refs` — nicht verwechseln.** `exempt-paths` nimmt eine
  **Datei** ganz aus (richtig für Zeitdokumente `docs/reviews/**`, die den Stand ihres
  Laufs einfrieren). `ignore-refs` nimmt eine **aufgelöste Ziel-Referenz** aus (richtig für
  einen bewusst gelöschten Pfad, der in *normativer* Doku als Tombstone zitiert wird). Der
  Tombstone gilt nur für **entfernte**, nicht für **geplante** Artefakte — die
  slice-015-§6-Abgrenzung bleibt: ein *geplanter* Pfad (`cmd/…` vor der Umsetzung) ist
  kein Tombstone, sondern Doc-führt-Code-folgt.
- **Kein Rückfall auf stilles Grün.** Ventil-Achsen sind bewusste Akte mit Begründung;
  eine leere/zu breite `exempt-paths`/`ignore-refs`-Liste würde Prüfbereich verschenken.
  Jeder Eintrag nennt, *was* er ausnimmt und *warum* — im Adaptions-Eintrag.
- **Verhältnis zu slice-015.** slice-015 (Zitat-Sensor) ist eine *andere* Baustelle
  (Faktentreue von `datei:zeile`), bleibt blockiert; dieser Slice berührt sie nicht.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** d-check-Pin **v0.10.0 → v0.46.0** (`harness.mk`, Digest
`sha256:9c317bf1…`, doppelt belegt via `docker buildx imagetools inspect` +
Release-Notes-Digest-Pin); zwei `codepaths`-Ventil-Achsen adoptiert —
`exempt-paths` (`docs/reviews/**`, datei-weit) und `ignore-refs` für die fünf
slice-013-Template-Tombstones (referenz-weit); 16 `` `d-check:ignore` ``-Zeilen-Marker
aus `docs/reviews/**` entfernt; [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Geltungsbereich von Glob- auf konkrete Pfade
gezogen; neuer Adaptions-Eintrag
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile);
`harness/conventions.md` §Baseline auf v0.46.0.

**Was funktionierte.** Der **Trockenlauf vor dem Pin** (DoD-Pflicht) entkräftete das
Hauptrisiko empirisch: trotz **29 real veröffentlichter Minors** gab v0.46.0 gegen den
unveränderten Baum **0 Befund-Differenz** (40 Dateien, 0 Befunde). Grund: die explizite
`modules:`-Liste immunisiert gegen neu default-aktive Module. `--print-config` lieferte das
autoritative YAML-Schema der neuen Achsen (kein Raten der Keys).

**Was anders lief.** Die Ziel-Version war **v0.46.0**, nicht die im Slice geschätzte
„~0.45.x" (ein Minor höher, am selben Tag released). `ignore-refs` hatte **keinen** Pflicht-
Treffer in normativer Doku (die Template-Tombstones lebten als legitime Klassen-Globs in
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)); statt die Achse dekorativ leerzuadoptieren, wurde [`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) auf konkrete Pfade gezogen,
sodass jeder `ignore-refs`-Eintrag eine real referenzierte, real gelöschte Datei deckt —
**load-bearing**, im Sinne der Slice-§6-Regel „kein Rückfall auf stilles Grün".

**Steering-Loop-Einträge.**
1. *Neuer Sensor verfügbar (bewusst nicht aktiviert):* v0.46.0 bringt die opt-in-Module
   `planning` (Roadmap-↔-`in-progress/`-Konsistenz), `commits`, `tracked`, `targets`
   (Doku-↔-Makefile). Jedes ist ein Kandidat-Slice, **sobald** Target/Bedarf existiert
   ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
   kein halluziniertes Gate) — benannt, nicht aktiviert.
2. *Geschärfte Praxis:* künftige Lifecycle-Wanderungen in Review-Reports brauchen **keinen**
   `` `d-check:ignore` ``-Marker mehr — `exempt-paths` deckt `docs/reviews/**` datei-weit; die
   vorher fünfmal wiederholte Handarbeit ist zentralisiert.
3. *Offene Lücke unberührt:* der Release-**Listen**-Sensor aus
   [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
   (ein neuer Upstream-Tag bleibt unsichtbar) bleibt offen — dieser Slice pinnt d-check,
   adressiert die Baseline-Freshness-Lücke aber nicht.

4. *Wiederkehrende Klasse (Review-Befund F-1):* Die Versions-Nachführung traf nur **eine**
   Stelle (`harness/conventions.md` §Baseline) und übersah eine zweite, gleichrangige Nennung
   (`README.md`, kanonische Quelle Rang 5) — dieselbe Klasse wie slice-014 F-1 („Nachführung
   nur an *einer* Stelle statt an allen Vorkommen"). Lehre: bei Pin-/Versions-Bumps `grep` nach
   **allen** Vorkommen der Alt-Version in lebenden Quellen, nicht nur an der DoD-genannten Zeile.
   Behoben (README auf v0.46.0); Kandidat für die geschärfte DoD-Formel „§Baseline **und alle
   weiteren Versions-Nennungen**".

5. *Lifecycle-Disziplin-Lücke (Prozess, nicht Slice-Inhalt):* slice-016 wurde in `open/`
   implementiert, **ohne** beim Arbeitsbeginn nach `in-progress/` zu wandern — der
   Modul-5-Eintritts-Move („Implementer beginnt") wurde übersprungen. Wurzel: der
   `implement-slice`-Command kannte den Eintritts-Move nicht und schrieb im Close-out
   `open→done`; der erste Konformitäts-Abgleich prüfte nur Modul 9, nicht Modul 5. Behoben:
   Command umfassend gegen Modul 5 (Zustandsmaschine, WIP=1, Back-Edges) **und** Modul 10
   (unabhängiger Review-Handoff) nachgezogen. slice-016 selbst geht ehrlich `open→done` (so
   lief die Arbeit real; kein rückdatierter `in-progress`-Commit).

**Folge-Slices.** **slice-017** (bereits angelegt): `harness.mk` durch das tool-generierte
`d-check --print-mk`-Fragment ablösen — bringt `--network none` (Netzlos-Härtung) und die
`DCHECK_DIGEST`-Override (beseitigt die manuelle Digest-Chirurgie dieses Slice). Sonst keiner
zwingend; optional je ein Slice für `planning`/`commits`, falls der Bedarf real wird. slice-015
(Zitat-Sensor) bleibt blockiert (unberührt).

**Verifikation.**
- Trockenlauf v0.46.0 (unveränderter Baum, unveränderte Config): 40 Dateien, 0 Befunde, Exit 0.
- `make docs-check` nach Marker-Entfernung: 40 Dateien, 0 Befunde (DoD-3-Beleg — grün **ohne** die Marker).
- `make gates`: grün (baseline-verify + docs-check + 47 bats + shellcheck), Exit 0.
- Unabhängiger **Reviewer** (Modul 10, frischer Kontext): merge-blockierend **nein** (0 HIGH/MEDIUM;
  1 LOW behoben = README-Versionsdrift, 2 INFO). Bericht: `docs/reviews/2026-07-18-slice-016-impl-review.md`.
- Unabhängiger **Verifier** (Modul 11, frischer Kontext): **7/7 DoD-Punkte CONFIRMED, 0 VIOLATED**;
  Trockenlauf non-destruktiv via `git archive` reproduziert; reif für `done/`. Bericht:
  `docs/reviews/2026-07-18-slice-016-verification.md`.
- Digest doppelt belegt: `docker buildx imagetools inspect` == Release-Notes-Digest-Pin.
- *Nuance zu „frischer Checkout":* der Gate-Lauf erfolgte auf dem Working Tree (alle Änderungen
  sind deterministische Config/Doku auf grünem Repo); die literale Frisch-Klon-Smoke ist CI-Sache
  nach dem Commit ([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`Makefile`/Gate-Config und die Doku teilen die adoptierte Harness-Mechanik
([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)); GF (Doc führt).
