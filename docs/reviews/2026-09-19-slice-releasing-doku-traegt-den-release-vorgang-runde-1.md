# Review-Report: slice-releasing-doku-traegt-den-release-vorgang — 2026-09-19

**Review-Art:** Code — geprüft gegen Plan + Konventionen (Modul 10 §Drei
Review-Arten); die Prozedur-Zeilen zusätzlich gegen den realen Mechanik-Stand
(Makefile, Release-Workflow, `release-sums.sh`) nachgefahren.

**Gegenstand:** Diff `fc40ff67..e0862836` — ein Commit (`e0862836`, neu:
`docs/user/releasing.md`, 115 Zeilen).

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
**Modell:** claude (glm-5.3-flash) · **Datum:** 2026-09-19

**Eingangs-Kontext:**

- Slice-Plan `slice-releasing-doku-traegt-den-release-vorgang` (in
  `docs/plan/planning/in-progress/`, Kennung, nicht Lifecycle-Pfad)
- ADR-0058 (Accepted), ADR-0059 (Accepted)
- LH-QA-04 (Plattform-Matrix), LH-QA-02 (Reproduzierbarkeit)
- `AGENTS.md` §3 (Hard Rules); `v6.9.0` ·
  `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) für die
  Grenz-Zeilen-Disziplin
- Die zwei eingefrorenen Register-Belege, die die Belegbasis zitiert:
  `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md`
  (Klassen-Beleg) und
  `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md`
  (Unfall-Beleg, Abschnitte CI-Lage und Schaden)
- Stand laut Übergabe (nicht wiederholt): `make gates` grün,
  `make docs-check` 1742/0

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die Grenz-Zeile der Belegbasis behauptet „kein Sensor der Gate-Kette liest diese Datei" — falsifiziert durch denselben Gate-Lauf, den die rote Gegenprobe des Plans (Liefer-Punkt 3) benennt: `make docs-check` liest die Datei (`scan.roots: ["."]` in `.d-check.yml`, die Datei steht in keiner `ignore`-Zeile); ihre Fundstellen-Links reisen im grünen 1742/0-Lauf mit. Der erste Halbsatz („die Zustandsform prüft das Review, kein Gate") trägt; nur der zweite behauptet mehr Abwesenheit, als besteht. | `v6.9.0` · `regelwerk/modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin) — Grenze benannt statt zu weit behauptet | `docs/user/releasing.md:101-102` | ja — `make docs-check` (Modul `links`) liest die Datei; ein nicht auflösender Anker in der Belegbasis färbt rot, während die Zeile das Gegenteil behauptet | Grenze-Aussage behauptet Sensor-Abwesenheit, die der Gate-Lauf widerlegt |
| F-2 | INFO | Planseitig: das §6-Risiko „Die tragenden ADRs sind Proposed" ist überholt — beide tragenden ADRs tragen `**Status:** Accepted` (Zeile 3 je Datei, gemessen). Die Datei erbt die überholte Aussage nicht (sie führt keinen ADR-Status); der Ausgang des Risikos gehört der Closure. | Maintainability (Plan-Defekt, Rückkante Review → Plan) | Plan §6 | ja — `grep -m1 '^\*\*Status' docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md` | Plan-Risiko trägt überholten ADR-Status |
| F-3 | INFO | Planseitig: Plan §1 Fundstelle 3 nennt `77471f53` als Tag-Position; gemessen `git rev-parse --short v0.2.1` → `28337be5` — deckungsgleich mit dem eingefrorenen Klassen-Beleg, der dieselbe Position trägt; `git merge-base --is-ancestor 77471f53 v0.2.1` → NEIN, auch gegen HEAD NEIN. `77471f53` ist der slice-release-schnitt-Pin-Commit („die Pins tragen die v0.2.1-Assets") und liegt außerhalb des Tag- und des main-Bestands — der Plan hat die Pin-Commit-Position mit der Tag-Position verwechselt. Die Datei-Fassung trägt (Wiegung im Abschnitt unten). | Maintainability (Plan-Defekt, Rückkante Review → Plan) | Plan §1 Fundstelle 3 | ja — dieselben zwei Kommandos, daneben zitiert | Plan-Messung verwechselt Pin-Commit-Position mit Tag-Position |
| F-4 | INFO | Planseitig: die erste Disziplin-Position des Plans („zwischen Asset-Publikation und Tag-Push") ist gegen die Mechanik unerfüllbar — der Lauf publiziert nur tag-gekoppelt (`if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')`, `.github/workflows/release.yml:113`); eine Vor-dem-Tag-Push-Publikation existiert nicht. Die Datei löst die Position als „Schritte 1–3 legen nur lokale Artefakte · Schritt 4 (Gates) unmittelbar vor Schritt 5 (Tag-Push + Publikation)" und hält die zweite Plan-Position exakt. Wiegung: trägt (Abschnitt unten); die Plan-Fassung bleibt als Plan-Korrektur beim Planner. | Maintainability (Plan-Defekt, Rückkante Review → Plan) | Plan §3 | ja — der Job-`if`-Guard der Release-Workflow-Datei | Plan-Position setzt eine Publikations-Reihenfolge voraus, die die eigene Mechanik nicht führt |

## Übergaben gewogen (Auftrag Punkt 2 und 3)

**Übergabe 3 — Schritt-Position der zwei Disziplin-Zeilen.** Der Plan
verlangt beide Zeilen „in der Schritt-Folge … nicht als Hinweis-Box";
die Datei führt sie als Schritte 4 und 6 von sieben. Die zweite Position
(zwischen Tag-Push und Meldung) ist exakt erfüllt. Die erste Position
(„zwischen Asset-Publikation und Tag-Push") messen gegen die Mechanik:
`make release-artifacts` (Makefile-Zeilen 108–123) legt Assets und SUMS
lokal ins `DEST`; der publish-Job läuft allein unter dem Tag-`if`-Guard —
gemessen, dass nichts publiziert, bevor der Tag geht. Die Datei hält die
Semantik der Position: nichts ist publiziert, bevor Schritt 4 (Gates) und
Schritt 5 (Tag-Push, der die Publikation auslöst) durchlaufen sind. **Trägt**
— gemeldet als Übergabe 3, nicht still verengt; die planseitige
Reihenfolge-Annahme ist F-4.

**Übergabe 1 — Fundstelle 3.** Gemessen: `git rev-parse --short v0.2.1` →
`28337be5`, identisch mit der Position, die der eingefrorene Klassen-Beleg
trägt („Der `v0.2.1`-Tag (`28337be5`)"); `git rev-parse --short v0.2.0` →
`70139992`, ebenfalls mit Kommando daneben. Die Datei übernimmt die
planseitigen CI-Verdikt-Detail-Aussagen („am Tag-Baum fiel `make docs-check`
rot, der CI-Lauf … bricht FAILURE") **nicht** — sie trägt die
klassen-relevanten Sätze in der Zustandsform und verweist die Unfall-Erzählung
auf die eingefrorenen Belege; die Klausel „die CI-Meldung traf nach der
Veröffentlichung ein" steht verbatim im Klassen-Beleg (dessen Fund-Zeile)
und ist in der Datei im selben Satz mit dem Anker zitiert. **Trägt.** Die
planseitige Messung ist F-3; die Plan-Korrektur gehört dem Planner
(Rollen-Trennung) — die Datei ist an ihr nicht beteiligt.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Schritt 1 gegen die Mechanik: `make release-artifacts DEST=<dir>` (Makefile-Zeilen 108–123), `RELEASE_PLATFORMS` (Zeile 106) = genau die sechs Plattformen, die der Datei-Absatz aufzählt; `release-sums.sh generate "$(DEST)"` legt die SUMS ins DEST | geprüft, ohne Befund |
| Schritt 2: Makefile-Zeilen 45–51 (`TRAEGER_TAG ?= v0.2.1` + sechs `TRAEGER_SHA256_*`); `internal/emit/templates/enforce/traeger.mk` trägt nur den Tag (Zeile 25) — genau die Emissions-Hälfte nach der ADR-0059-Teil-Ablösung; der Tag-Stand trägt denselben Pin (`git show 28337be5:Makefile`, Zeilen 45–51) | geprüft, ohne Befund |
| Schritt 3: `release-sums.sh verify <dir>` — vier Bruch-Fälle genau wie im Datei-Satz (fehlende SUMS · Zeilen-Form je Zeile · Menge in beide Richtungen · Inhalt via `sha256sum -c`), Aufruf-Form stimmt | geprüft, ohne Befund |
| Schritt 5: publish-Job hält die SUMS fail-closed vor dem Upload (Form · Menge · Inhalt am Ruheort, Release-Workflow-Datei Zeilen 129–137); `gh release create "$tag" dist/*` = 6 Binaries + SUMS = 7 Assets; `--generate-notes`; der Job-`if`-Guard hält den workflow_dispatch-Lauf vom Upload fern; Start-Smoke auf allen sechs Runnern | geprüft, ohne Befund |
| Schritt 4: Release-Workflow-Datei führt kein `docs-check`/`make gates` (grep → 0 Treffer) | geprüft, ohne Befund |
| Grenze gegen ADR-0058: der Re-Evaluierungs-Trigger für „kein Signier-Schritt" steht dort (dritter Bullet); der Kanal-Satz trägt gegen die Option-A-Abwägung der ADR-0059 („ein gemeinsamer Ersatz beider geht durch") | geprüft, ohne Befund |
| §3.7 Zustandsform: die drei rückwärtszeitlichen Klauseln der Fundstellen spiegeln die eingefrorenen Belege wörtlich und tragen ihre Anker; keine weitere Chronik-Stelle im Prozedur- oder Zweck-Text | geprüft, ohne Befund — mit F-1 als Grenz-Aussage-Defekt im selben Abschluss |
| Zitat im Schritt 5: verbatim aus dem Kasten „Was wo geprüft wird" (benutzerhandbuch.md §Systemanforderungen); Abweichung allein die Satzanfangs-Kleinschreibung der Einbettung; Anker `#systemanforderungen` existiert (Zeile 55) | geprüft, ohne Befund |
| Verdrahtung: `harness/README.md` Zeile 22 trägt Rang 6 als Verzeichnis `docs/user/` — keine Änderung nötig; das Handbuch ist nicht im Diff (ein Commit, nur `releasing.md`) | geprüft, ohne Befund |
| MR-025: Messwert-Zahlen tragen ihr Kommando im selben Absatz (`gh release view <tag> --json assets --jq '.assets | length'` → `7`; zwei `git rev-parse --short` je Tag); die „sechs"-Zahlen stehen in Aufzählungs-Rolle (Setzung 1 bindet Aufzählungen nicht) | geprüft, ohne Befund |
| Fremd-Kennungen: `grep -c 'd-check\|a-check\|ai-harness-course' docs/user/releasing.md` → 0; Commit-Message trägt LH-QA-04 · LH-QA-02 · ADR-0058 · ADR-0059 · slice-Kennung | geprüft, ohne Befund |
| `git check-ignore .harness/state/gates-passed.diffsha` → Pfad, exit 0 — die Pfad-Aussage der Belegbasis stimmt | geprüft, ohne Befund |
| ADR-Status der tragenden ADRs: beide Accepted (Zeile 3 je Datei); die Datei trägt keinen Status und erbt die planseitige Proposed-Aussage nicht | geprüft, ohne Befund (planseitig: F-2) |
| Dateiende ohne Zeilenumbruch — kein Konventions-Anker benannt, kein Befund | geprüft, ohne Befund |
| Zitierform `ADR-0059 Festlegung 1` in den Schritten 1/5 und der Grenze: gegen die Option-A-Überschrift und die Dogfood-Hälfte der Festlegung nachgefahren; der volle Festlegungs-Text wurde (Budget) nicht Zeile für Zeile nachgefahren — offen gehalten, keine Messung dagegen | offen gehalten, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 3 |

**Finding-Klassen dieses Laufs:** Grenze-Aussage behauptet
Sensor-Abwesenheit, die der Gate-Lauf widerlegt · Plan-Risiko trägt
überholten ADR-Status · Plan-Messung verwechselt Pin-Commit-Position mit
Tag-Position · Plan-Position setzt eine Publikations-Reihenfolge voraus, die
die eigene Mechanik nicht führt

## Verdikt

**Merge-blockierend:** nein — ein LOW in einer Grenz-Zeile; die zwei
Übergaben des Implementers (Fundstelle 3, Schritt-Position) tragen gegen den
Plan, mit Messung in diesem Report. Die INFO-Findings sind planseitig und
gehören in die Plan-Korrektur vor der Closure, nicht in einen zweiten
Implementer-Lauf.

**Übergabe:** Findings gehen an den Implementer (F-1: die Grenz-Zeile auf
„die Zustandsform prüft das Review, kein Gate" zurücknehmen oder auf die
Haltungs-Differenz umschreiben); die **Finding-Klassen** gehen zusätzlich in
die Slice-Closure §7 und von dort in den Zähler. Dieser Report selbst ist
ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen. Der
Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der
Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).