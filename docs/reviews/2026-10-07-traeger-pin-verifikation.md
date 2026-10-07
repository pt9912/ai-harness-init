# Verifikation: slice-full-smoke-misst-den-emittierten-traeger-pin

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-07 · **Gegenstand:** Commit `2425712b` gegen
DoD und Plan des Slice; Review-Report `docs/reviews/2026-10-07-traeger-pin-review.md` als Eingang.
Bezug: `LH-QA-01`, `LH-QA-02`, `ADR-0058` Festlegung 1.

## Verdikte je Liefer-Punkt

- **1 — Adopter-Bedingung: bestätigt.**
  - Aufrufstellen: `grep -nE 'traeger-fetch' harness/tools/full-smoke.sh` ohne Kommentare und
    Meldungen → genau ein `make … traeger-fetch`, in `klon_traeger_fetch` (`env -u TRAEGER_TAG -u
    MAKEFLAGS -u MFLAGS`, Zeile 1820); (b) und (c) laufen darüber.
  - Rot an der realen Quelle, selbst gefahren: Baum aus `git archive HEAD`, Mutation 554 angewandt
    (`TRAEGER_TAGX ?= v0.5.0`), `make full-smoke` → `EXIT 2`, gelesen:
    `traeger-fetch: TRAEGER_TAG ist nicht gesetzt — der Release-Pin fehlt (ADR-0058 Festlegung 1, LH-QA-02).`
    und danach `full-smoke: FEHLER — AUSGANG BAUM: make traeger-fetch im frischen Klon (golang).`
    Die Meldung trägt die behauptete Ursache.
  - Gegenprobe, selbst gefahren (vom Review nur gelesen): dieselbe Kopie, `env -u …` aus
    `klon_traeger_fetch` entfernt → `make full-smoke` `EXIT 0`, Stufe meldet
    „Fetch im frischen Klon (golang): … abgelegt“. Der Fall bindet die Adopter-Bedingung.
  - 553 auf `?=` und gebunden: aus dem Review-Lauf übernommen (`make mutate`, 3 ok), nicht erneut.
- **2 — Namens-Bindung: bestätigt.** `pin_wert` liest `grep "^$2 ?="` (`test/traeger-fetch.bats`);
  Fall 555 rot und die Gegenprobe mit Präfix-Form grün aus dem Review-Lauf — Stichprobe, nicht
  nachgefahren.
- **3 — E2E-Sicht: bestätigt.** Deklaration von Stufe 5 nennt den Pin des emittierten Fragments und
  die weitergeerbten Digest-Pins; Gleichheit der erzeugten `docs/user/e2e-abdeckung.md` hält
  `test/e2e-abdeckung.bats` im `make gates`-Lauf unten.
- **`make gates`:** siehe Lauf nach dem Commit dieses Berichts.

## LOW-1 des Reviews: bestätigt

- `Makefile:53` exportiert `TRAEGER_SHA256_*`; `klon_traeger_fetch` entfernt sie nicht; das emittierte
  Skript setzt dann `erwartet="$TRAEGER_SHA256"` und nimmt `quelle="Pin"`
  (`internal/emit/templates/enforce/traeger-fetch.sh`, Payload) — `SHA256SUMS` wird nicht geladen.
- Der Negativ-Fall (c) setzt die Pin-Variable `TRAEGER_SHA256_<PLAT>_<ARCH>` und erwartet
  „nach EINMAL Laden“; er ist strukturell an den Pin-Kanal gebunden.
- `make smoke`: `grep -c 'TRAEGER\|traeger' harness/tools/smoke.sh` → `0` — kein Fetch dort.
- Damit fährt weder `full-smoke` noch `smoke` den Manifest-Kanal des Adopters; gemessen ist er nur
  hermetisch in `test/traeger-fetch.bats` (Stubs). Ausgang liegt beim Planner (§6-Risiko
  „Weitere Stufen erben Dogfood-Exporte“ ist eingetreten, an derselben Stufe).

## Plan gegen Code

- Plan §3 nennt vier Komponenten; der Diff berührt genau diese (`full-smoke.sh`, `traeger-fetch.bats`,
  drei Fälle unter `test/mutations/`, die erzeugte Sicht). Nichts gebaut ohne Plan.
- Über den Plan hinaus, aber vom DoD-Text gedeckt: `-u MAKEFLAGS -u MFLAGS` (DoD 1 nennt `MAKEFLAGS`).

## Kommandos

- `make full-smoke` (Hauptbaum, HEAD `76749b19`) → `EXIT 0`, `real 2m19,638s`.
- `make full-smoke` (Kopie + 554) → `EXIT 2`, FEHLER-Zeile oben.
- `make full-smoke` (Kopie + 554, ohne `env -u`) → `EXIT 0`.

## Offene Punkte für den Planner

- LOW-1: Ausgang für den nicht gefahrenen Manifest-Kanal (Folge-Slice oder Register).
- INFO-1 des Reviews (Laufzeit-Satz in 553/554) nicht nachgemessen.
