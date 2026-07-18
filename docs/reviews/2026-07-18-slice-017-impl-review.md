# Review-Report: slice-017 Implementierung (d-check-Gate-Fragment aus `--print-mk`, `harness.mk` → `d-check.mk`) — 2026-07-18

**Review-Art:** Code — unabhängiger Reviewer (kein Selbst-Review). Re-Review der überarbeiteten
Fassung (die verworfene Single-Target-Variante wurde NICHT bewertet — nur der aktuelle Stand).
Geprüft gegen Plan (slice-017 DoD + §6-Risiken), `LH-QA-01`/`LH-QA-02`/`LH-QA-03`, Hard Rules
`AGENTS.md` §3, MR-009/MR-010, das `d-check --print-mk`-Tool-Output (v0.46.0).

**Gegenstand:**
- **Uncommitteter Working-Tree-Diff (4 Dateien):** `d-check.mk` (Inhalts-Rewrite auf das volle
  `--print-mk`-Fragment), `docs/plan/planning/in-progress/slice-017-…md`, `harness/README.md`,
  `harness/conventions.md` (§Baseline, MR-009-Auflösungs-Trigger, neuer MR-010).
- **Zwei committete slice-017-Vorbereitungs-Commits:** `61cadfa` (Eintritts-Move open→in-progress,
  0/0) und `503f186` (Rename `harness.mk → d-check.mk` per `git mv` + `Makefile`-`include`/-Kommentar).

**Skill:** `.harness/skills/reviewer.md` @ 1.1.0 ·
**Modell:** claude-opus-4-8[1m] (unabhängiger Reviewer-Agent) · **Datum:** 2026-07-18

**Eingangs-Kontext (nach reviewer.md v1.1.0 — sechs Elemente):**
1. **Diff/Range:** `git diff` (Working Tree) + `git show 61cadfa 503f186` (die zwei Vorbereitungs-Commits), oben aufgelistet.
2. **Betroffene LH:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
   (keine halluzinierten Gates), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
   (Digest-Pin), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (minimale Abhängigkeiten / Docker-only).
3. **Referenzierte ADRs:** `ADR-0003` (Docker-only, Accepted — aktiv), `ADR-0004` (Durchsetzungs-Emission, aktiv). Keine superseded ADR referenziert.
4. **Hard Rules:** `AGENTS.md` §3.1 (halluzinierte Gates), §3.3 (git mv + Inhalt = zwei Commits), §3.5 (Gate-Lockerung nur per ADR).
5. **Vorherige Findings am gleichen Modul:** `docs/reviews/2026-07-18-slice-016-impl-review.md` (d-check-Pin-Sprung, `--print-mk`-Verbatim, `harness.mk`-Digest), `docs/reviews/2026-07-18-slice-016-verification.md` (Tag→Digest-Bindung).
6. **Slice-Plan:** `docs/plan/planning/in-progress/slice-017-print-mk-fragment.md` (Diff gegen Plan geprüft; DoD-Abhakung NICHT bewertet — Verifier-Rolle).

**Ausgeführte Verifikationsmittel (Belege):**
- `git show 503f186 --find-renames` → `harness.mk => d-check.mk` mit **`similarity index 100%` / R100**, 0 Inhaltszeilen im `.mk`; `git show 61cadfa` → Eintritts-Move 0/0.
- `git log --follow d-check.mk` → tracet über `503f186` sauber zurück auf `harness.mk` (slice-016 `8429e41`, slice-013, …).
- `make gates` → **Exit 0** (baseline-verify · docs-check · test 47/47 bats ok · shell-lint · record-gates).
- `make docs-check` → **Exit 0**, „45 Datei(en) geprüft, 0 Befund(e)", `--network none` (netzlos).
- `make -n docs-check` → Digest-Ref; `make -n docs-check DCHECK_DIGEST=` → Tag-Ref (`ifeq`-Logik korrekt).
- `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.46.0` → `Digest: sha256:9c317bf1…36a1` == `DCHECK_DIGEST` (d-check.mk:13). Tag→Digest-Bindung bestätigt.
- `docker run …@sha256:9c317bf1… --print-mk` → Roh-Tool-Output; `diff` gegen `d-check.mk` (siehe Verbatim-Treue unten).
- `make doc-help` → listet `docs-check` + alle zehn `doc-*` (Grep-Erweiterung `docs?-` greift); `make -n doc-immutable`/`doc-commits` (RANGE-/STAGED-Substitution korrekt).

---

## Findings

### LOW-1 — Emit-Spec nennt weiterhin `harness.mk`, während das Repo-Dogfood auf `d-check.mk` umzieht

- **kategorie:** LOW
- **quelle:** `LH-FA-03` (Doc-Gate-Baseline emittieren) / Maintainability (Doku-Drift)
- **pfad:** `spec/lastenheft.md:52`; `docs/plan/planning/open/slice-002-doc-gate-emit.md:18,23,34`; `docs/plan/planning/open/slice-001-cli-skeleton.md:36,57`
- **befund:** Die Emit-Spec (`LH-FA-03`, `lastenheft.md:52`) und die offenen Slices 001/002 beschreiben das **vom Tool emittierte** Gate-Fragment weiterhin als `harness.mk`. slice-017 benennt das **dogfood-eigene** Fragment auf `d-check.mk` um — und das `--print-mk`-Tool-Output benennt die Datei selbst „`d-check.mk`". Damit divergiert der demonstrierte Ziel-Form-Name (`d-check.mk`) vom spezifizierten Emit-Namen (`harness.mk`); MR-010 Setzung 3 adressiert nur die **historischen** Nennungen („Zeitbezug"), nicht die **forward** Emit-Spec. Kein Gate feuert (root-level Datei, nicht unter `harness/` → kein `codepaths`; Makefile/Spec-Prosa parst d-check nicht auf diesen Namen). Nicht durch slice-017 „kaputt gemacht" (der Emitter existiert noch nicht), aber eine unaufgelöste Drift, die bei Implementierung von slice-001/002 zu reconcilen ist.
- **verifizierbar:** ja — `grep -rn 'harness\.mk' spec/ docs/plan/planning/open/`; kein Gate-Lauf bestätigt es (Doku-Drift, gate-blind).

### INFO-1 — Zwischen-Commit `503f186`: `Makefile`-Kommentar beschreibt Zustand, der erst im Folge-Commit eintritt

- **kategorie:** INFO
- **quelle:** Maintainability (transiente Commit-Ehrlichkeit)
- **pfad:** `Makefile:1-2` @ Commit `503f186`
- **befund:** Im reinen Rename-Commit `503f186` wurde der `Makefile`-Kopfkommentar bereits auf „Doc-Gate via d-check-Fragment (d-check.mk, aus `d-check --print-mk`, MR-010)" gezogen, obwohl der `d-check.mk`-Inhalt an diesem Commit noch das alte handgepflegte Fragment ist (der `--print-mk`-Rewrite folgt erst im Working-Tree-Diff) und `MR-010` in `harness/conventions.md` an diesem Commit noch nicht existiert. Die Commit-Message sagt „Inhalt des Fragments unveraendert" — konsistent für das `.mk`, aber der Kommentar nimmt den Folgezustand vorweg. Transient, im Endzustand aufgelöst; kein Gate parst Makefile-Kommentare. Failure-Szenario: ein exakt auf `503f186` gepinnter Checkout liest eine Herkunfts-/MR-Angabe, die dort noch nicht zutrifft.
- **verifizierbar:** nein (kein Gate deckt Makefile-Kommentar-Semantik; nur Sicht-Prüfung von `git show 503f186`).

### INFO-2 — MR-010 Setzung 1: „einziger manueller Handgriff" untertreibt die Re-Adaptions-Punkte

- **kategorie:** INFO
- **quelle:** `MR-010` (Setzung 1) / Maintainability
- **pfad:** `harness/conventions.md:405-411`
- **befund:** MR-010 Setzung 1 nennt die Umbenennung `doc-check`→`docs-check` „den **einzigen** manuellen Handgriff bei jeder Neu-Erzeugung (plus `DCHECK_DIGEST` pinnen)". Der `diff` gegen das Roh-`--print-mk` zeigt aber vier adaptierte Stellen: (a) Kopfkommentar-Rewrite, (b) `docs-check`-Ziel + angereicherter `##`-Hilfetext, (c) `DCHECK_DIGEST`-Pin, (d) `doc-help`-Grep `^doc-`→`^docs?-` + `##`. Setzung 1 erwähnt (c) und (d) separat, nennt (a)/(b-Hilfetext) aber nicht — ein Regenerator, der Setzung 1 wörtlich folgt, ließe den beschreibenden Kopf und den angereicherten `docs-check`-Hilfetext weg. Rein kosmetisch (kein Verhaltens-/Gate-Effekt).
- **verifizierbar:** nein (Prosa-Genauigkeit; belegbar per `diff <(docker run …--print-mk) d-check.mk`).

---

## Negativbefunde (geprüft, ohne blockierenden Befund)

- **Rename-Sauberkeit (Hard Rule 3.3):** `503f186` ist R100 (`similarity index 100%`, 0 Inhaltszeilen im `.mk`) — die Rename-Detection von `d-check.mk` ist voll erhalten. Der mitgeführte `Makefile`-`include`/-Kommentar ist ein **anderes** File (tangiert die `.mk`-Similarity nicht) und **muss** mit dem Move landen, sonst bräche der Zwischen-Checkout (`include harness.mk` auf nicht-existente Datei). Rewrite auf das `--print-mk`-Fragment liegt getrennt (Working Tree). Eintritts-Move `61cadfa` = 0/0. `git log --follow` tracet sauber zurück. Hard Rule 3.3 gewahrt. (Rand-INFO-1 betrifft nur die Kommentar-Vorwegnahme.)
- **Halluziniertes Gate (LH-QA-01):** Nur `docs-check` steht in `make gates`, `AGENTS.md` §4 und `harness/README.md` §Sensors — `grep` über AGENTS/README/Makefile findet **kein** `doc-trace`/`doc-doctor`/…/`doc-help` als behaupteten Gate. Die zehn advisory-Targets sind **verfügbar** (`make doc-help` listet sie, Dry-Runs substituieren korrekt), aber nicht behauptet — „behauptet ≠ vorhanden", exakt wie `regelwerk-check`. LH-QA-01 gewahrt.
- **Gate-Korrektheit:** `make gates` Exit 0; `docs-check` grün + netzlos (45 Dateien, 0 Befunde, `--network none`); alle Recipe-Zeilen **Tab**-eingerückt (kein „missing separator"); `ifeq`-Logik korrekt (Digest-Default, Tag bei leerem `DCHECK_DIGEST`).
- **Pin-Integrität (LH-QA-02):** `DCHECK_DIGEST` (d-check.mk:13) == `imagetools`-Digest von `:v0.46.0` (`sha256:9c317bf1…36a1`) == slice-016-Pin, unverändert. Tag→Digest-Bindung live bestätigt.
- **Verbatim-Treue:** Alle zehn advisory-Recipes + `DCHECK_IMAGE`/`ifeq`/`DCHECK_REF`/`TRACE_FLAGS`-Block sind **byte-gleich** zum `--print-mk`-Output; geändert wurden ausschließlich Kopfkommentar, `DCHECK_DIGEST`-Pin, `docs-check`-Rename (+Hilfetext) und `doc-help`-Grep. `--network none` stammt bereits aus dem Tool (keine Repo-Erfindung).
- **Namens-Konsistenz:** `docs-check` konsistent in `Makefile` (`gates`), `AGENTS.md` §4, `harness/README.md` §Sensors, `harness/conventions.md` §Baseline und `README.md`; kein **lebender** `harness.mk`-`include` mehr (Rest-Nennungen sind Spec/Plan/Review-Historie — LOW-1 für die Emit-Spec).
- **MR-010-Ehrlichkeit + ADR-0003 (Docker-only, LH-QA-03):** MR-010 deckt die Realität (Setzungen 1–3 + Begründung + Auflösungs-Trigger); `d-check.mk` hat **keinen** Host-Egress (kein `curl`/`wget`, nur `docker run`) — der einzige Host-`curl` lebt in `regelwerk-check` (Maintenance, NICHT in `gates`, von slice-017 unberührt). `--network none` härtet netzlos statt zu lockern (keine Gate-Lockerung → §3.5 nicht berührt). ADR-0003 gewahrt.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 2 |

---

## Verdikt

**Nicht merge-blockierend.** 0 HIGH, 0 MEDIUM. Der Kern des Slice ist sauber: der Rename ist ein
echter R100-Move getrennt vom Inhalts-Rewrite (Hard Rule 3.3), die zehn advisory-Recipes sind
byte-verbatim aus `d-check --print-mk`, der Digest-Pin bindet live auf `:v0.46.0`, nur `docs-check`
ist als Gate behauptet (LH-QA-01), und `make gates`/`make docs-check` laufen netzlos grün (Exit 0).
Die eine LOW (Emit-Spec nennt weiterhin `harness.mk`) und zwei INFO (Zwischen-Commit-Kommentar-
Vorwegnahme; „einziger Handgriff"-Untertreibung in MR-010) sind Doku-Drift/-Genauigkeit ohne
Gate- oder Reproduzierbarkeits-Wirkung und blockieren den Merge nicht — LOW-1 ist beim Bau des
Emitters (slice-001/002) zu reconcilen.
