# Slice slice-017: d-check-Gate-Fragment aus `--print-mk` statt handgepflegter `harness.mk`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-18.

---

## 1. Ziel

Das handgepflegte `harness.mk` durch das **tool-generierte** d-check-Gate-Fragment ablösen —
die Ziel-Form segnet das ausdrücklich ab (`.harness/baseline/v3.1.0/templates/Makefile`:
„Fragment frisch erzeugen: `d-check --print-mk`"). Der Gewinn ist konkret, nicht kosmetisch:

- **`--network none`** auf jedem Gate-Run (die generierte Form hat es, unser `harness.mk`
  nicht) — härtet die Netzlosigkeit auf Container-Ebene ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **`DCHECK_DIGEST`-Override** (Digest sticht Tag) — beseitigt die manuelle Digest-Chirurgie,
  die [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)/slice-016 gerade von Hand machen musste.
- **Recipe lebt in d-check** — bei künftigen Pin-Bumps wird das Fragment neu erzeugt statt
  handgepatcht (Wartungs-Drift-Klasse beseitigt).

**Adaption nötig (kein Verbatim-Übernehmen).** `--print-mk` erzeugt Target `doc-check` (ohne
„s") + zehn advisory/opt-in-Targets. Die Ziel-Form-`Makefile` **und** Regelwerk `modul-13`
nennen das Gate `docs-check` (mit „s"). Der Slice übernimmt das Fragment als **Startpunkt** und
adaptiert es auf `docs-check` — die Ziel-Form beschreibt genau dieses Generieren-dann-Anpassen.

## 2. Definition of Done

- [ ] Das d-check-Gate wird aus dem `d-check --print-mk`-Fragment (v0.46.0) abgeleitet und
      adaptiert: Target heißt **`docs-check`** (Ziel-Form-/`modul-13`-Konsistenz), Pin via
      **`DCHECK_DIGEST`** (Digest aus den Release-Notes, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)), **`--network none`** aktiv.
- [ ] **Struktur-Entscheidung dokumentiert:** separates Fragment (`include`, wie heute
      `harness.mk`) **oder** inline in `Makefile` (wie die Ziel-Form) — begründet im MR-Eintrag.
- [ ] **Nur genutzte Targets** (kein halluziniertes Gate, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): `docs-check` in
      `gates`; die advisory-Targets (`doc-trace`/`doc-complete`/`doctor`/`repair`/`immutable`/
      `commits`/`planning`/`tracked`/`targets`) **nur** mit existierendem Bedarf/Target aufnehmen —
      sonst weglassen, nicht als „vorhanden" behaupten.
- [ ] **Netzlos belegt:** Trockenlauf zeigt `docs-check` mit `--network none` grün (keine aktive
      Modul-Zeile braucht Netz; nur `external` wäre die Netz-Tür und ist nicht aktiv).
- [ ] `make gates` grün auf frischem Checkout; Target-Name/Version konsistent in
      [`AGENTS.md`](../../../../AGENTS.md) §4, [`harness/README.md`](../../../../harness/README.md) §Sensors und `harness/conventions.md` §Baseline.
- [ ] Neuer Adaptions-Eintrag in `harness/conventions.md` (nächste freie Nummer): Fragment
      tool-generiert + adaptiert statt handgepflegt, mit Begründung; ergänzt [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness.mk` (bzw. `Makefile`) | refactor | Gate aus `--print-mk`-Fragment ableiten (adaptiert: `docs-check`, `DCHECK_DIGEST`, `--network none`); Struktur-Entscheidung separat-vs-inline |
| `harness/conventions.md` | update | neuer Adaptions-Eintrag (Fragment-Herkunft); §Baseline ggf. |
| [`AGENTS.md`](../../../../AGENTS.md) §4, [`harness/README.md`](../../../../harness/README.md) §Sensors | update | Target-Name/Version konsistent halten (nur falls berührt) |
| `README.md` | update | falls das Gate dort mit Name/Version genannt ist |

## 4. Trigger

Sofort startbar — unabhängig, reine Gate-Struktur. Setzt slice-016 (Pin auf v0.46.0) als
Ausgangszustand voraus (bereits umgesetzt). Rückführungen: `in-progress`→`next` bei zu großem
Schnitt (falls die Ziel-Form-Adaption doch mehr rippelt als erwartet).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Target-Namens-Divergenz ist das Kern-Detail.** `--print-mk` liefert `doc-check`, das Repo/
  die Ziel-Form/`modul-13` nutzen `docs-check`. Die Adaption (Rename im Fragment) ist Pflicht,
  sonst rippelt ein Rename durch `gates`/AGENTS/README/conventions. Die generierte Form ist
  **Startpunkt, nicht Endprodukt** (so die Ziel-Form selbst).
- **Regenerations-Drift (Tradeoff, bewusst).** Die Adaption `doc-check`→`docs-check` ist manuell;
  bei einem d-check-Bump muss das Fragment neu erzeugt **und** re-adaptiert werden. Das ist ein
  kleiner, wiederkehrender Handgriff — abzuwägen gegen den Wegfall der Digest-Handpflege. Im
  MR-Eintrag zu benennen, nicht zu verschweigen.
- **`--network none` vs. `external`.** `--network none` ist sicher, **solange** kein aktives
  Modul Netz braucht. Nur `external` ist die Netz-Tür (opt-in, nicht aktiv). Trockenlauf belegt.
- **Kein Rauschen durch advisory-Targets.** Die zehn Extra-Targets aus `--print-mk` nur
  übernehmen, wenn Bedarf/Target existiert — sonst wären sie in AGENTS/README ein halluziniertes
  Gate ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Default: nur `docs-check`.
- **Verhältnis zu slice-016.** slice-016 pinnte v0.46.0 im bestehenden `harness.mk`; dieser Slice
  ändert die **Herkunft/Struktur** des Fragments, nicht die Version. Kein Rückschnitt von slice-016.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `Makefile`/Gate-Config und
die Doku teilen die adoptierte Harness-Mechanik ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)); GF (Doc führt, Code folgt).
