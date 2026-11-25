# Review-Report: slice-gates-fastpfad-ueber-stempel — 2026-11-25

**Review-Art:** Code-Review gegen Plan + ADR (nicht DoD — das prüft der
Verifier separat, `v6.18.1` · `regelwerk/modul-11-verification.md`).

**Gegenstand:** `slice-gates-fastpfad-ueber-stempel` · Diff-Range
`d3811ccd..5ddbbc8d` (4 Commits Implementer-Rolle: `4fe21917` Wrapper + Makefile +
Kanten-Wächter + bats, `f892861b` Fälle 784/785, `ee94dd40`
`harness/sensors/gates.md` + Zelle→Link, `5ddbbc8d` Fälle 211/212 an die
Wrapper-Form).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** Claude Code (`glm-5.3-flash`) · **Datum:** 2026-11-25

> **Zitier-Form:** Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. **Kennung, nicht Adresse:** `slice-gates-fastpfad-ueber-stempel`
> statt seines Lifecycle-Pfads, `make <target>` statt eines Links auf die
> Sensor-Datei, eine Baseline-Stelle als **Tag + Pfad in Inline-Code**
> (`v6.18.1` · `regelwerk/<datei>.md` §<Abschnitt>). Ein `pfad`-Feld auf den
> **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den Stand
> des Laufs und darf ihn festhalten.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-gates-fastpfad-ueber-stempel` (in `in-progress/`, Stand
  d3811ccd..5ddbbc8d)
- [ADR-0099](../plan/adr/0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
  (`Accepted`), [ADR-0083](../plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
  (Stempel-Konsum, unverändert),
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  (Wortlaut-Präzedenz benannter Rest) als Referenzen
- `LH-QA-01` (keine halluzinierten Gates), `LH-QA-02` (Reproduzierbarkeit),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  (fail-closed), [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  (Anker misst gegen den Quell-Bestand),
  [`MR-090`](../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
  (Anker am Commit),
  [`MR-091`](../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
  (CI-Branch-Schwelle)
- `AGENTS.md` §3 (§3.1, §3.6, §3.7, §3.8, §3.9, §5)
- `spec/architecture.md` §5 (Ordnungskante, unverändert)

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills
(`.harness/skills/reviewer.md` @ 2.3.0, §Klassifikation/§Output-Schema).

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die Mutations-Probe des Slice-Satzes läuft über die lokal-Schwelle hinaus: `bash harness/tools/mutate-auswahl.sh urteil slice-gates-fastpfad-ueber-stempel` meldet **23 Fall/Faelle** (`Schwelle 8 lokal`) über `9366e0c4..HEAD` und urteilt **Exit 10** (Push-Zeile `mutate/slice-gates-fastpfad-ueber-stempel-5ddbbc8d`). Der CI-Branch-Lauf, den [MR-091](../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt) Setzung 1 vor der Verifikation verlangt, steht aus — nicht gepusht (kein Push-Auftrag). Die vier Fälle, die der Diff anlegt und ändert, sind dennoch am HEAD rot gesehen (siehe Negativbefunde); der ausstehende Pflicht-Schritt blockiert die Verifikation/Closure, nicht den Code-Diff. | MR-091 | `make mutate-auswahl SLICE=slice-gates-fastpfad-ueber-stempel` · Exit 10, Zähler 23 | ja — `bash harness/tools/mutate-auswahl.sh urteil slice-gates-fastpfad-ueber-stempel` (Exit 10, Zähler 23) und der CI-Branch-Lauf über `git push origin HEAD:refs/heads/mutate/slice-gates-fastpfad-ueber-stempel-5ddbbc8d` schreibt `mutate-ergebnis.txt` | Slice-Mutations-Satz überschreitet die lokale Schwelle, CI-Branch-Lauf ausstehend |
| F-2 | LOW | `harness/conventions.md` §Zusatzklassen-Deklaration trägt drei Messzeilen und einen Prosa-Satz, die seit `ee94dd40` über dem Bestand falsch sind — gemessen über das Kommando des Blocks selbst am HEAD: `wc -l` → **47** (Block notiert 31), `grep -cE 'ADR-[0-9]{4}'` → **15** (Block notiert 8), `grep -cE '^ *— *$'` → **0** (Block notiert 1); der Satz *„`—` steht allein in der Zeile `make gates`"* stimmt nicht mehr, die gates-Zelle trägt ADR-0099 als Bindung. Der Block ist Architect-Artefakt (`AGENTS.md` §3.8) — der Implementer hat ihn korrekt nicht angefasst; die Folge ist als Übergabe-Artefakt an den Architect zu reichen, kein Slice-Liefer-Punkt (Plan §2/§3/§6 nennt die Folge an keiner Stelle). Tragend bleibt die letzte Messzeile (Zähler 0: keine Zelle trägt etwas außerhalb der Klassen) — sie wandert mit und ist unverändert wahr. | MR-025 · Maintainability | `harness/conventions.md` · §Zusatzklassen-Deklaration | ja — das Kommando des Blocks (die zwei `grep`/`wc`-Zeilen) zeigt die Abweichung; kein Sensor fährt es (d-check `targets` liest die Zeile gegen das Makefile, nicht die Zähler) | Messblock hinter Bestandsbewegung nicht nachgezogen |

## Übergabe über den Plan hinaus

Zwei Defekte am **Plan** (keine am Diff), ausdrücklich nicht als Findings
gegen den Code gezählt, aber für die Slice-Closure §7 als Originalinformation
geprüft:

1. **MR-091-Weg fehlt im Plan.** Plan §2 DoD 2 nennt die zwei Mutations-Fälle
   (MR-071, MR-090) und §3 die Anlage — an keiner Stelle den Probe-Weg je
   Schwelle ([MR-091](../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
   Setzung 1). Der Befund F-1 ist darum auch ein Plan-Defekt: der Planner
   trägt den ausstehenden CI-Branch-Lauf in §7 als Risiko-Ausgang oder
   Folge-Slice.
2. **Conventions-Folge fehlt im Plan.** Plan §6 nennt das Risiko der
   Stempel-Deckung (Risiko 1, Ausgang eingetreten) — die Folge auf
   `harness/conventions.md` (die gates-Zelle verlässt die `—`-Form und hebt
   Zähler im Zusatzklassen-Block) nennt der Plan an keiner Stelle. Der
   Architektur-Zug (Übergabe-Artefakt an den Architect, AGENTS §3.8) wird im
   F-2-Träger benannt; der Plan-Defekt trägt die Slice-Closure §7.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| `harness/tools/gates-fast.sh` gegen ADR-0099 Festlegungen 1–4 | geprüft, ohne Befund — SKIP nur über dem gedeckten Paar (diffsha **und** head), fail-closed bei leerem, unlesbarem, gestutzt-fremd geformtem Stempel wie bei HEAD unaufösbar (keine Ausnahme), `GATES_FORCE=1` über gedecktem Paar; das Skript schreibt keinen Stempel und hält den benannten Rest in der Meldung |
| `harness/sensors/gates.md` (Auftrag-Punkt 3) | geprüft, ohne Befund — die Grenze des SKIP trägt die Prosa: §Der benannte Rest (Docker-Cache, Host-Werkzeuge) und §Grenze (baum-abgeleiteter Ausschnitt, Re-Evaluierungs-Trigger der ADR statt eines Sensors); die README-Zelle verlinkt die Prosa statt sie zu kürzen, keine Aussage über den Ausschnitt hinaus |
| `test/gate-nachweis-kante.bats` an der Wrapper-Form | geprüft, ohne Befund — 5 Zustände umgezogen, nicht gestrichen: Kante byte-gleich (Erwartungsliste 12 Checks, sortiert), gates an **keinen** make-Voraussetzungen, Rezept genau eine nichtleere Zeile (der Wrapper-Aufruf), baseline-verify erster |
| `test/gates-fastpfad.bats` | geprüft, ohne Befund — SKIP-Klassen, FORCE-Boundary (`=1` voll, `=0` und Fehlen: SKIP), Verdrahtung (genau `exec make record-gates`, kein Stempel-Schreiben), `head_wert`-Kopplung über drei Fassungen text-gleich |
| Mutations-Fälle 210/213/214 (Bestand, aus der Auswahl gezogen) | geprüft, ohne Befund — ihre `# files:`-Anker treffen das Makefile und ihre Wächter binden weiter (Kante byte-gleich, Erwartungsliste, first-check); sie bedürfen der Anpassung an die wrapper-Form nicht (Kante und Reihenfolge unverändert) |
| Kommentar-Form (`AGENTS.md` §3.7) in den neuen/angefassten Dateien | geprüft, ohne Befund — die Formen tragen Zusage/Abgrenzung/Grenze; Herkunft steht als auflösbarer Anker (`FORM SEIT ADR-0099` im Makefile, `SEIT ADR-0099 …` in Fall-Köpfen), keine verworfene Alternative, kein abwesender-Text-Befund |
| ADR-Index | geprüft, ohne Befund — ADR-0099 steht mit `Accepted` |
| Exklusivitäts-Gegenprobe der vier Fälle (gelesen, nicht gefahren) | geprüft, ohne Befund — 784 färbt allein den benannten Test (die Validierungs-Zustände fallen unter der Mutation weiter in Exit 1, über die Funktion ableitbar); 785 färbt den `GATES_FORCE=0`-Test mit (mitgefärbter Test derselben Code-Stelle — struktureller Nebeneffekt, kein Befund, kein Kopf behauptet Exklusivität); 211/212 färben je allein — Rot-Belege der vier Fälle am HEAD selbst geführt: `make mutate MUTATE_CASES='784-… 785-… 211-… 212-…'` → **4 ok, 0 Befund(e)**, jede Fall-ID am benannten Grund rot |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Slice-Mutations-Satz überschreitet die
lokale Schwelle, CI-Branch-Lauf ausstehend · Messblock hinter
Bestandsbewegung nicht nachgezogen

## Verdikt

**Merge-blockierend:** nein. Der eine MEDIUM (F-1) blockiert nicht den
Code-Diff, sondern benennt den Pflicht-Schritt, den
[MR-091](../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
Setzung 1 **vor der Verifikation** verlangt; die vier Slice-eigenen Fälle
sind am HEAD rot gesehen, und die beiden umgefassten Bestandsfälle binden
ihre Wächter weiter. Der LOW (F-2) ist Architektur-Arbeit in einem eigenen
Zug (§3.8), kein Implementer-Defekt — er blockiert ebenfalls nicht. **Der
Slice ist damit nicht closable:** die Verifikation/Closure wartet auf den
CI-Branch-Lauf (F-1) und auf die beiden Plan-Defekte (Übergabe-Abschnitt),
die §7 als Risiko-Ausgänge notiert.

**Übergabe:** Findings gehen an den Implementer (F-1: ausstehender
Pflicht-Schritt — der Push ist Auftraggeber-/Planner-Entscheidung); die
**Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort
in den Zähler. Die Plan-Defekte (Übergabe-Abschnitt) gehen an den Planner.
Dieser Report selbst ist ein **Lauf-Beleg**; er ersetzt keine Verifikation
gegen DoD/Spec.
