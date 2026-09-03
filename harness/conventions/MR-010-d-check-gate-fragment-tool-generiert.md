# MR-010 — d-check-Gate-Fragment tool-generiert

- **Datum:** 2026-07-18
- **Geltungsbereich:** `d-check.mk` (aus `harness.mk` umbenannt), `Makefile` (`include`), §Baseline,
  [`harness/README.md`](../README.md) §Sensors; ergänzt [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile).
- **Ersetzt-Baseline-Regel:**
  [`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#gate-fragment-d-checkmk-schritt-2)
  §Gate-Fragment `d-check.mk` (Schritt 2). Der Kern jener Regel ist adoptiert — das Fragment wird
  nicht handgeschrieben, sondern aus der gepinnten d-check erzeugt und bei jedem Bump neu —, an
  **zwei** Punkten tritt der Eintrag an ihre Stelle: (a) die Einbindung ist `include d-check.mk`
  statt des dort geschriebenen `-include` (`grep -n 'd-check.mk' Makefile`), also fail-closed gegen
  ein fehlendes Fragment statt tolerant; (b) das Target `doc-check` wird von Hand zu `docs-check`,
  obwohl derselbe Abschnitt sagt *„Das Tool pflegt die Recipe-Form (`--network none`,
  Target-Set)"*. Der Rename richtet das Fragment auf den Namen aus, den die Baseline an anderer
  Stelle selbst führt —
  [`modul-13-quality-gates.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-13-quality-gates.md#hard-rule-doku-disziplin)
  nennt das genutzte Gate `docs-check` —, bleibt aber eine Hand-Änderung an einer tool-gepflegten
  Form. Setzung 2 (nur `docs-check` ist behauptet) ersetzt nichts: sie ist jene Hard Rule wörtlich.
  Gemessen am adoptierten Stand `v5.12.0`.
- **Adaption:** Das handgepflegte `harness.mk` wird durch das **tool-generierte** Fragment
  `d-check.mk` (aus `d-check --print-mk`, v0.46.0) ersetzt — die Ziel-Form
  (`.harness/baseline/<tag>/templates/Makefile`) segnet das ausdrücklich ab („Fragment frisch
  erzeugen: `d-check --print-mk`"). Effekte: (a) **`--network none`** auf jedem Run (härtet die
  Netzlosigkeit auf Container-Ebene, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten));
  (b) **`DCHECK_IMAGE` (Tag) + `DCHECK_DIGEST` (Override, sticht den Tag)** statt des inline
  gepinnten `D_CHECK_IMAGE` aus [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) —
  Re-Pin ist eine `DCHECK_DIGEST`-Zeile; (c) das **volle** Target-Set lebt tool-generiert im
  Repo, die Recipe-Form pflegt d-check — seine Größe wächst mit dem Tool und steht mit ihrem
  Kommando in Setzung 2.
- **Setzung 1 — Namens-Adaption `doc-check` → `docs-check`.** Nur das Befund-Gate wird umbenannt:
  Ziel-Form-`Makefile`, Regelwerk `modul-13` und der bestehende Repo-Stand nennen es `docs-check`
  (mit „s"); `--print-mk` erzeugt `doc-check`. Bei jeder Neu-Erzeugung sind es vier kleine,
  dokumentierte Handgriffe: `doc-check`→`docs-check` (Target **und** Hilfetext), `DCHECK_DIGEST`
  pinnen, den adaptierten Kopfkommentar setzen und `doc-help`s Grep auf `docs?-` erweitern (damit
  das umbenannte Haupt-Target gelistet wird). Die advisory-Targets bleiben sonst **verbatim**
  (`doc-`-Präfix).
- **Setzung 2 — nur `docs-check` ist ein *behaupteter* Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).** `d-check.mk`
  führt **zwölf** Targets (`grep -cE '^docs?-[a-z-]+:' d-check.mk` → **12**; `make doc-help` listet
  dieselben zwölf). Genau eines davon, `docs-check`, steht in `make gates`,
  [`AGENTS.md`](../../AGENTS.md) §4 und [`harness/README.md`](../README.md) §Sensors; die übrigen **elf**
  sind advisory/opt-in (`doc-trace`/`doc-complete`/`doc-doctor`/`doc-repair`/`doc-immutable`/
  `doc-commits`/`doc-planning`/`doc-tracked`/`doc-targets`/`doc-structure`/`doc-help`) — also
  **verfügbar, aber nicht als Gate behauptet**, exakt wie `regelwerk-check` (Makefile-Target, nicht
  in `gates`). Kein halluziniertes Gate: „behauptet" ≠ „vorhanden". Die Aufzählung **ist** die
  Grenzziehung: ein Target, das in ihr fehlt, ist weder als behauptet noch als advisory
  ausgewiesen — deshalb ist sie an den Re-Pin gebunden (§Auflösungs-Trigger) und nicht an das
  Datum dieses Eintrags.
- **Setzung 3 — `d-check.mk` (tool-eigener Name) statt `harness.mk`.** Der Rename trägt den Namen,
  den `--print-mk` selbst vergibt (Herkunft ist selbst-dokumentiert) und macht die Neu-Erzeugung
  mechanisch (`d-check --print-mk` → `d-check.mk`). Er ist ein **reiner git-mv-Commit vor** dem
  Inhalts-Rewrite (Hard Rule 3.3); `Makefile`-`include`/-Kommentar, §Baseline und der
  [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Verweis („Digest in …") sind
  nachgezogen. Historische `harness.mk`-Nennungen (z. B. im [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Body, in slice-016)
  bleiben als Zeitbezug stehen — sie feuern kein `codepaths` (root-level Datei, nicht unter `harness/`).
- **Begründung:** `--network none` schließt eine Netzlos-Lücke (das Gate erzwang es bisher nicht,
  auch wenn die aktiven Module hermetisch sind); `DCHECK_DIGEST` beseitigt die manuelle
  Digest-Chirurgie, die [`MR-009`](../conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) noch von Hand
  machte; das tool-generierte Fragment beseitigt die Drift-Klasse „Hand-mk hinkt d-check nach" und
  stellt das volle, aktuelle Target-Set bereit.
- **Auflösungs-Trigger:** permanent; bei d-check-Release `d-check --print-mk` neu erzeugen,
  `doc-check`→`docs-check` re-adaptieren, `DCHECK_DIGEST` neu pinnen und die Target-Aufzählung in
  Setzung 2 gegen `make doc-help` abgleichen — das Set wächst mit dem Tool, die Aufzählung nur von
  Hand. **Dazu gehört die Fixture** `internal/emit/testdata/raw-print-mk.txt`, an der
  `TestAdaptMK_Fixture` dieselben vier Handgriffe prüft: sie friert eine ältere Tool-Ausgabe ein,
  und nachzuziehen ist nicht ihre Zeilenzahl, sondern ob `AdaptMK` an der **frischen** Ausgabe
  noch greift. Das misst je ein `grep -c` über der frischen `--print-mk`-Ausgabe für die fünf
  Anker, an denen die Funktion hängt — `DCHECK_IMAGE ?=`, `.PHONY: doc-check`, `doc-check:` am
  Zeilenanfang, die **leere** `DCHECK_DIGEST ?=`-Zeile und `'^doc-[a-z-]+:`; steht jeder genau
  einmal (über v0.65.0 am 2026-08-28 alle fünf **1**, wie in der Fixture), kostet ihr Alter
  nichts. Fehlt einer, ist die Fixture zu erneuern, denn dann trifft der Test eine Form, die das
  Tool nicht mehr liefert. Ein **stilles** Grün ist das in keinem Fall: `AdaptMK` bricht auf drei
  der vier Handgriffe hart ab (Rename, `doc-help`-Grep, Digest-Pin) und auf dem fehlenden Anker
  dazu; der vierte Handgriff — der Adopter-Kopf — kann nicht fehlschlagen, weil der Rumpf erst am
  Anker beginnt. Maintenance-Override (Dry-Run) via `DCHECK_DIGEST=…`/`DCHECK_IMAGE=…`, nicht mehr
  `D_CHECK_IMAGE=…`.
