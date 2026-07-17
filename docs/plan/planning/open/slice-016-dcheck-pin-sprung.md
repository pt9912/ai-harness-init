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

- [ ] `harness.mk` `D_CHECK_IMAGE` auf den aktuellen d-check-Release-Digest gepinnt
      (Digest per `docker` gegen das Release belegt, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit));
      `harness/conventions.md` §Baseline-Zeile („d-check: Image v0.10.0") auf die neue
      Version nachgezogen.
- [ ] **Trockenlauf vor dem Pin:** das aktuelle Image gegen den unveränderten Baum
      laufen lassen und die Befund-Differenz zu v0.10.0 prüfen — ein 35-Minor-Sprung kann
      neue Module/Regeln mitbringen (z. B. `planning`, `commits`). Neue Befunde werden
      **bewertet, nicht blind unterdrückt**; jede Config-Anpassung ist begründet.
- [ ] `.d-check.yml`: `codepaths.exempt-paths: ["docs/reviews/**"]` gesetzt; die dadurch
      überflüssigen `` `d-check:ignore` ``-Zeilen in `docs/reviews/**` entfernt — Beleg:
      `make docs-check` bleibt **ohne** sie grün.
- [ ] `codepaths.ignore-refs` für die Tombstone-Referenzen auf gelöschte Templates
      (soweit sie in **normativer** Doku stehen, nicht nur in Zeitdokumenten) — die
      Glob-Workarounds aus slice-013/[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert) dürfen zurück auf die klaren vollen Pfade,
      wenn `ignore-refs` sie deckt. **Nur wo zutreffend** (Tombstone = *bewusst entfernt*,
      nicht *geplant*; die Abgrenzung aus slice-015 §6 gilt).
- [ ] `make gates` grün auf frischem Checkout.
- [ ] Neuer Adaptions-Eintrag in `harness/conventions.md` (nächste freie Nummer): Pin-Sprung
      + `exempt-paths`/`ignore-refs`-Adoption, mit dem belegten Bedarf; ergänzt
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

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

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`Makefile`/Gate-Config und die Doku teilen die adoptierte Harness-Mechanik
([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)); GF (Doc führt).
