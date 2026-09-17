# Review `slice-d-check-pin-liest-fremde-packs-und-loest-jede-range` (Runde 2) — 0 HIGH · 0 MEDIUM · 0 LOW · 2 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `b103adff` (HEAD), Basis
`60b4f42b` (der Report der Runde 1); zwei Commits, beide **lokal** · **Review-Art:** Nachprüfung
der Befunde F-1 bis F-5 aus Runde 1 plus Neu-Review des Nacharbeits-Diffs gegen Plan,
Adaptions-Block und Hard Rules · **Nicht Gegenstand:** die DoD-Abhakung (Verifikation) und die
Befunde, die Runde 1 bereits als Negativbefund führte.

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `claude-opus-5[1m]`

**Eingangs-Kontext:** Report `docs/reviews/2026-09-17-slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.md`
(Runde 1) · Slice-Plan §1 und §2 · `AGENTS.md` §3.5, §3.6, §3.7, §3.8 · `MR-025`, `MR-032`,
`MR-046`, `MR-053`, `MR-066` · `harness/conventions.md` §Adaptions-Block.

---

## Eigene Messung

Die zwei neuen Beleg-Kommandos aus `MR-066` sind selbst gefahren, read-only im Arbeitsbaum.

| Gegenstand | Kommando | Ergebnis |
|---|---|---|
| Beleg 1, Kommentar am `commits`-Block | `grep -c 'Praefix .pack-. oder$' .d-check.yml` | `1` — deckt die Zahl im Eintrag |
| Beleg 2, die zwei Sensor-Dateien | `git grep -l 'Index oder lose liegen' -- harness/sensors/ \| wc -l` | `2`, und zwar `harness/sensors/commit-msg-check.md` und `harness/sensors/history-range-guard.md` — genau die zwei Träger, über die der Eintrag spricht |
| E2E-Tabelle nach der Skript-Änderung | `bash harness/tools/e2e-abdeckung.sh harness/tools/full-smoke.sh <scratchpad>`, dann `diff` gegen `docs/user/e2e-abdeckung.md` | identisch (Link-Tiefe des Sonden-Ziels normalisiert) — die Tabelle ist der aktuelle Ausgang des Erzeugers |
| Rollen-Grenze | `git show --pretty=format: --name-only` je Commit | `51cad34c` berührt nur zwei Dateien unter `harness/conventions/`, `b103adff` nur `harness/tools/full-smoke.sh` und `docs/user/e2e-abdeckung.md` |

`make gates` und `make full-smoke` sind nicht selbst gefahren; ihr EXIT 0 ist Angabe des
Koordinators und Gegenstand der Verifikation. Für die Aussage „am Modul `vcs` nicht" ist das kein
blinder Punkt: Die Stufe ruft `blind_gruen_ohne_waechter "$klon" doc-immutable` am **flachen**
Klon und bricht mit Exit 1 ab, sobald dort nicht `0 Befund(e)` bei Exit 0 steht. Ein grünes
`full-smoke` ist damit der laufende Beleg für genau diese Hälfte.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| G-1 | INFO | Im selben Kommentarblock steht unverändert „eine Haelfte ohne eigene Messung waere eine verlinkte Behauptung (AGENTS.md §3.6)" — dieselbe Konjunktiv-Form, die F-2 an den zwei geänderten Stellen behoben hat. Die Zeile ist nicht angefasst und fällt unter den Cutoff aus `AGENTS.md` §3.7 („wer sie stehen lässt, bricht nichts"); sie steht damit bewusst. Zuständig: Implementer, wenn er die Zeile ohnehin einmal anfasst. | `AGENTS.md` §3.7, Cutoff | `harness/tools/full-smoke.sh`, Kopf von `blind_gruen_ohne_waechter`, dritte Zeile | nein | Altbestands-Konjunktiv im frisch geänderten Block |
| G-2 | INFO | Der Satz „die faengt der gepinnte Stand am Modul `commits` selbst ab (Exit 2), am Modul `vcs` nicht" ist an **diesem** Aufbau und dieser Range gemessen und im Satz an den flachen Klon gebunden. Aus dem Block herausgelöst läse er sich als Eigenschaft von `vcs`; `MR-064` §Grenze misst für `vcs` sehr wohl einen Abbruch, nur an einem unlesbaren Unterbaum. Zuständig: Implementer, als Won't-Fix vertretbar. | `MR-055` (eine Stellen-Messung trägt keine Folgerung über eine Eigenschaft) | `harness/tools/full-smoke.sh`, Block (d) in `vorlauf_waechter_im_ziel` | nein | Stellen-Messung, deren Bindung nur aus dem Satzsubjekt folgt |

Kein HIGH, kein MEDIUM, kein LOW. Kein Rollen-Konflikt; beide INFO gehen an die ausführende Rolle.

## Nachprüfung der Befunde aus Runde 1

| Befund | Stand | Beleg |
|---|---|---|
| F-1 MEDIUM — Zahl von ihrem eigenen Kommando widerlegt | **erledigt** | Der Beleg steht auf zwei Kommandos, beide selbst gefahren: `1` und `2`. Das Muster endet jetzt am Zeilenende (`oder$`), und der Eintrag sagt daneben, warum — „die Zeile bricht nach *oder* um". Beide Zahlen tragen „keine Erwartungswerte" (`MR-025` Setzung 2) |
| F-2 MEDIUM — Konjunktiv über die verworfene Alternative | **erledigt** | Beide Stellen stehen im Indikativ über den Zustand: „`<aufbau>` ist PFLICHT und nennt den Klon in der Beleg-Zeile … ein Aufruf ohne das Argument bricht ab" und „`doc-commits` traegt die Klasse am VOLLSTAENDIGEN Klon, `doc-immutable` am FLACHEN". Der zweite Block trägt jetzt zusätzlich die Klasse **Kopplung** ausdrücklich („KOPPLUNG: … `test/full-smoke-ausgang.bats`") |
| F-3 LOW — Ablösungs-Beleg beschreibt die Zieltexte anders, als sie lauten | **erledigt** | Der Eintrag unterscheidet die zwei Träger jetzt ausdrücklich: Sensor-Dateien **ersetzt** (Index-Bedingung), Kommentar am `commits`-Block **daneben** (Präfix `loose-`). Beides ist mit je eigenem Kommando belegt und trifft den Ist-Stand |
| F-4 LOW — Marke nennt den permanenten Trigger eingelöst | **erledigt** | „Sein Auflösungs-Trigger bleibt `permanent`; eingelöst ist der Neu-Prüf-Satz darin, und die Datei bleibt aktiv in `conventions/`." Die Marke legt damit keinen `git mv` nach `done/` mehr nahe, sondern schließt ihn aus |
| F-5 LOW — Vorbelegung eines Beleg-Etiketts | **erledigt** | `aufbau="${4-}"` plus fail-closed: fehlt das Argument, meldet die Funktion es und endet mit Exit 1, vor jedem Modul-Lauf. Die Meldung nennt den Grund („Das Etikett des Aufbaus steht in der Beleg-Zeile; es wird genannt, nicht vorbelegt") |
| F-6, F-7 INFO | offen, wie in Runde 1 vermerkt | an Implementer bzw. Architect; nicht Gegenstand dieser Runde |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Kopf-Marke, Form (`MR-032` Setzung 1) | geprüft, ohne Befund: die **ältere** Marke (Ziel `MR-065`) ist unangetastet; geändert ist allein die Marke, die dieser Vorgang selbst gesetzt hat, und zwar vor dem Push. Das ist die Korrektur eines noch nicht angenommenen Eintrags, nicht das Überschreiben eines fremden — genau der Weg, den Plan §6 Risiko 3 offen hält |
| Eintrags-Disziplin (`harness/conventions.md` §Adaptions-Block, `MR-046`) | geprüft, ohne Befund: `MR-064` und `MR-066` bleiben in `conventions/`, kein Feld wurde zum Status-Feld umgedeutet, die Index-Zeile ist unverändert und damit weiter richtig |
| `MR-066` Zahlen und Datierung (`MR-025`, `MR-053`) | geprüft, ohne Befund: die zwei neuen Zahlen stehen neben ihren Kommandos und sind nachgemessen; die Werkzeug-Aussage bleibt auf `v0.76.1`/`v0.76.3` datiert |
| Fail-closed-Zweig | geprüft, ohne Befund: `"${4-}"` ist die `set -u`-sichere Form, der Abbruch läuft **vor** dem Range- und dem Modul-Lauf, und `exit 1` steht nicht in einer Subshell — er beendet den Lauf |
| Vorbedingung und Rot-Bedingung der Stufe | geprüft, ohne Befund: unverändert (`HEAD..HEAD` auflösbar **und** `0`; sonst Exit 1) — die Klasse *blind und grün* ist weiter der Gegenstand, die Nacharbeit hat nur Etikett und Begründungstext berührt |
| `docs/user/e2e-abdeckung.md` | geprüft, ohne Befund: mitgezogen und byte-gleich zum Erzeuger-Ausgang; die `e2e_abdeckung`-Deklarationen selbst sind unverändert, `test/e2e-abdeckung.bats` braucht nichts |
| `AGENTS.md` §3.5 | geprüft, ohne Befund: der Diff schaltet nichts ab und senkt nichts; der neue Zweig **verschärft** (ein bisher stillschweigend etikettierter Aufruf bricht jetzt ab) |
| `AGENTS.md` §3.8 | geprüft, ohne Befund: `51cad34c` berührt ausschließlich Architect-Artefakte und nennt die Rolle; `b103adff` fasst keines an |
| Plan-Treue §1 | geprüft, ohne Befund: keine der fünf Abgrenzungen berührt; `.d-check.yml`, `d-check.mk`, `internal/emit/` und die Modul-Liste sind im Nacharbeits-Diff gar nicht enthalten |
| Neue Befunde im Diff | geprüft: nur G-1 und G-2, beide INFO |

## Summary

**0 HIGH · 0 MEDIUM · 0 LOW · 2 INFO.** F-1 bis F-5 sind erledigt, jeder mit einem Beleg, den
diese Runde selbst gefahren oder im Diff gelesen hat. Für die Closure §7 trägt diese Runde **keine
neue** wiederkehrende Klasse bei; die Klasse aus Runde 1 (*Zahl von ihrem eigenen Kommando
widerlegt*) bleibt die zu zählende — sie ist behoben, nicht ungeschehen.

## Verdikt

**Push frei.** Der Grund, der in Runde 1 gegen den Push stand, ist entfallen: Die drei Befunde im
Architect-Commit sind vor dem Einfrieren behoben, und der Eintrag friert jetzt mit einem Beleg
ein, der trägt. Die zwei INFO sind Won't-Fix-fähig und halten nichts auf.

**Closure:** weiterhin offen — sie setzt die Verifikation gegen die DoD voraus (`make gates`,
`make full-smoke`, die vier Messungen); dieser Report sagt darüber nichts.
