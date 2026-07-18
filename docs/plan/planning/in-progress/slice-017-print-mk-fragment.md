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

**Adaption (minimal, kein Verbatim-Zwang).** `--print-mk` erzeugt elf Targets: `doc-check`
(ohne „s") + zehn advisory/opt-in-Targets. Das Repo übernimmt das **volle** Fragment und
adaptiert **nur** den Befund-Gate `doc-check` → `docs-check` (mit „s"; Ziel-Form-`Makefile`,
Regelwerk `modul-13` und der bestehende Repo-Stand nennen es so). Die zehn advisory-Targets
bleiben **verbatim** (`doc-`-Präfix) und sind verfügbar, aber **nicht als Gate behauptet**. Das
Fragment ist tool-generiert (Startpunkt), die eine Rename-Adaption der einzige Handgriff je
Neu-Erzeugung.

## 2. Definition of Done

- [x] Das d-check-Gate wird aus dem `d-check --print-mk`-Fragment (v0.46.0) abgeleitet und
      adaptiert: Target heißt **`docs-check`** (Ziel-Form-/`modul-13`-Konsistenz), Pin via
      **`DCHECK_DIGEST`** (Digest aus den Release-Notes, [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)), **`--network none`** aktiv.
- [x] **Struktur-Entscheidung dokumentiert ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)):** das Fragment trägt den
      tool-eigenen Namen `d-check.mk` (aus `harness.mk` **umbenannt** per `git mv`, reiner
      Move-Commit vor dem Inhalt — Hard Rule 3.3), separat via `include` (nicht inline);
      `Makefile`-`include`/-Kommentar, §Baseline und der [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Verweis nachgezogen.
- [x] **Volles Target-Set, nur `docs-check` als Gate *behauptet*** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)): `d-check.mk`
      trägt alle elf `--print-mk`-Targets; **nur** `docs-check` steht in `make gates`,
      [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors.
      Die zehn advisory-Targets sind **verfügbar, aber nicht als Gate behauptet** (wie
      `regelwerk-check`) — „behauptet" ≠ „vorhanden", kein halluziniertes Gate.
- [x] **Netzlos belegt:** Trockenlauf zeigt `docs-check` mit `--network none` grün (keine aktive
      Modul-Zeile braucht Netz; nur `external` wäre die Netz-Tür und ist nicht aktiv).
- [x] `make gates` grün auf frischem Checkout; Target-Name/Version konsistent in
      [`AGENTS.md`](../../../../AGENTS.md) §4, [`harness/README.md`](../../../../harness/README.md) §Sensors und `harness/conventions.md` §Baseline.
- [x] Neuer Adaptions-Eintrag in `harness/conventions.md` (nächste freie Nummer): Fragment
      tool-generiert + adaptiert statt handgepflegt, mit Begründung; ergänzt [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness.mk` → `d-check.mk` (`git mv`) | rename | tool-eigener Name; reiner Move-Commit (Hard Rule 3.3) |
| `d-check.mk` (Inhalt) | refactor | volles `--print-mk`-Fragment; `doc-check`→`docs-check`, `DCHECK_DIGEST` gepinnt, `--network none` |
| `Makefile` | update | `include harness.mk` → `include d-check.mk` + Kommentar |
| `harness/conventions.md` | update | neuer Adaptions-Eintrag ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); §Baseline + [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Pointer |
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
- **Advisory-Targets: verfügbar, nicht behauptet.** Das volle `d-check.mk` trägt alle zehn
  advisory-Targets (`doc-trace`/`doc-doctor`/…), aber **keines** steht in AGENTS/README/`gates` —
  nur `docs-check` ist der behauptete Gate. Verfügbar-aber-nicht-behauptet ist
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-konform (wie `regelwerk-check`); die advisory-Targets sind opt-in-Werkzeuge,
  kein halluziniertes Gate. (Falls eines je in `gates` gehoben wird, muss es dann erst grün laufen.)
- **Verhältnis zu slice-016.** slice-016 pinnte v0.46.0 im bestehenden `harness.mk`; dieser Slice
  ändert die **Herkunft/Struktur** des Fragments, nicht die Version. Kein Rückschnitt von slice-016.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** Das handgepflegte `harness.mk` ist durch das tool-generierte `d-check.mk`
(aus `d-check --print-mk`, v0.46.0, elf Targets) ersetzt: `--network none` auf jedem Run,
`DCHECK_IMAGE` (Tag) + `DCHECK_DIGEST` (gepinnt, sticht Tag), nur `doc-check`→`docs-check`
adaptiert, advisory-Targets verbatim. Neuer [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert); §Baseline +
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Pointer + README §Sensors nachgezogen.

**Was funktionierte.** Der `--print-mk`-Byte-Vergleich (Reviewer) belegte, dass die zehn
advisory-Recipes verbatim vom Tool stammen — die einzige Repo-Adaption ist Gate-Rename +
Digest-Pin + Kopfkommentar + `doc-help`-Grep. Die Rollen-Trennung fing real: Reviewer
(0 HIGH/MEDIUM), Verifier (6/7 CONFIRMED, 0 VIOLATED), je frischer Kontext.

**Was anders lief.** Der ursprüngliche Plan (mein Entwurf) hätte `harness.mk` behalten und nur
`docs-check` übernommen (advisory weggelassen). Auf Nutzer-Direktive umgeschwenkt auf (a) den
tool-eigenen Namen `d-check.mk` und (b) das **volle** Target-Set — beides konsistenter mit dem
Slice-Zweck („tool-generiert"). Der Plan (§1/§2/§3/§6) wurde nachgezogen, damit er die
Implementierung trägt (Doc führt). Kosten: ein verworfener Reviewer-Lauf + ein Rename-Commit.

**Steering-Loop-Einträge.**
1. *Benannte Spec-Lücke (Review-LOW-1):* Die **emittierte** Struktur ([`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)) und die
   offenen Slices 001/002 nennen das Ziel-Repo-Gate-Fragment weiter `harness.mk`, während der
   Repo-Dogfood auf `d-check.mk` zieht (und `--print-mk` es selbst so benennt). Das ist **kein**
   slice-017-Fehler (Emitter ≠ Dogfood), aber eine reale Reconciliation-Pflicht beim Emitter-Bau
   (slice-001/002/003): entscheiden, ob das emittierte Fragment `d-check.mk` heißt und das volle
   Target-Set trägt. Kein Gate fängt es (Spec/Prosa).
2. *Geschärfte Praxis:* Tool-generierte Fragmente **voll** übernehmen und nur die repo-spezifische
   Divergenz (hier: der Gate-Name) adaptieren, statt sie auf „nur was ich brauche" abzumagern —
   „verfügbar ≠ behauptet" (wie `regelwerk-check`) hält [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), ohne das aktuelle
   Tool-Set zu verstümmeln.

**Folge-Slices.** Keiner zwingend aus slice-017. Der Emit-Fragment-Name (Steering-Loop 1) ist beim
Emitter-Bau zu klären. slice-018 (Baseline-Freshness) bleibt startbereit.

**Verifikation.**
- `make gates`: grün (baseline-verify + docs-check 46/0 netzlos + 47 bats + shellcheck), Exit 0.
- Unabhängiger **Reviewer** (Modul 10, frischer Kontext): merge-blockierend **nein** (0 HIGH/MEDIUM;
  1 LOW = Emit-Drift, 2 INFO). Bericht: `docs/reviews/2026-07-18-slice-017-impl-review.md`.
- Unabhängiger **Verifier** (Modul 11, frischer Kontext): **6/7 DoD CONFIRMED, 0 VIOLATED** (DoD-7
  war dieser Closure-Schritt). Bericht: `docs/reviews/2026-07-18-slice-017-verification.md`.
- `--print-mk`-Byte-Vergleich: zehn advisory-Recipes verbatim; Digest `sha256:9c317bf1…` ==
  slice-016-Pin, imagetools-gebunden an `:v0.46.0`.
- Rename `503f186` = R100 (reiner Move, Hard Rule 3.3); `git log --follow d-check.mk` → `harness.mk`.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `Makefile`/Gate-Config und
die Doku teilen die adoptierte Harness-Mechanik ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)); GF (Doc führt, Code folgt).
