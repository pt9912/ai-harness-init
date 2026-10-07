# Verifikation slice-anwender-targets-leben-in-repo-mk (ADR-0080)

**Rolle:** Verifier (Modul 11). **Gegenstand:** Commits `cbc4722b`, `4c0ce2c4`, `0354ca27`,
`7a5dbdd3`, `7c9f27fb`; Review `docs/reviews/2026-10-07-repo-mk-review.md` (0 HIGH/0 MEDIUM, 4 LOW
behoben). **Datum:** 2026-10-07.

## Verdikte je DoD-Punkt

- **DoD 1 (Aggregator, Startinhalt, Vorgabe-Ort, Go-Tests): bestätigt.** `-include repo.mk` steht in
  `internal/emit/makefile.go` nach `include harness/mk/*.mk`, vor der Ordnungskante; `repo.mk` in der
  Klassentabelle `SkipIfPresent`, Startinhalt nur Kommentar; `SelbstpruefungVorgabeOrt = RepoMkPath`.
  Benannte Tests vorhanden (`TestMakefile_HasOrderEdge`, `TestEnforce_IdempotenzKlasseJePfad`,
  `TestEnforce_EmitsAllMechanicFiles`, `TestSelbstpruefung_DerGenannteVorgabeOrtWirdNieUeberschrieben`).
  Rot-Belege der Fälle 527–529 übernommen aus dem Review (`make mutate` → `3 ok, 0 Befund(e)` plus
  Gegenproben) — Stichprobe, nicht nachgefahren.
- **DoD 2 (full-smoke-Stufe `repo_mk_im_ziel`, Fitness 1–2): bestätigt.** Rot-Gegenprobe nachgetragen
  (unten), alle drei Brüche rot mit der behaupteten Ursache; Stufe in `docs/user/e2e-abdeckung.md`
  mit Teilabdeckung am selben Ort.
- **DoD 3 (Handbuch): bestätigt.** `docs/user/benutzerhandbuch.md` nennt `repo.mk` in Hinweisen beim
  Aufsetzen, Klassentabelle „nur bei fehlender Datei", Verzeichnisbaum, Zeilenenden-Absatz und FAQ
  Re-Lauf; `grep -rn 'vorgaben\.mk' internal/ harness/tools/ docs/user/` → keine Treffer,
  keine Restnennung.
- **DoD 4 (`make gates` grün): bestätigt** — `make gates` am Ende dieser Verifikation, Exit 0 (Baum inkl. dieses Berichts).
- **DoD 5 (Review-Report): bestätigt** — Report liegt vor, anderer Kontext.
- **DoD 6–9 (Closure, Register, Risiko-Ausgänge, Paarungen):** nicht Gegenstand — Planner-Closure
  (AGENTS.md §3.10).

## Rot-Gegenprobe der Stufe (Bewusstes Brechen)

`full-smoke` kennt keine Stufenauswahl. Gefahren wurde eine Kopie im Scratchpad: Vorlauf Zeilen
1–416 (Helfer, `make artifact` aus dem Arbeitsbaum) plus Stufe Zeilen 3522–3602, `HIER` auf
`harness/tools`, `e2e_abdeckung` als No-op (die Anker-Prüfung der Deklaration ist regionsgebunden
und nicht Gegenstand). Grenze: gemessen ist die Stufe allein, nicht der volle `full-smoke`-Lauf.

| Lauf | Exit | gelesene Ursache |
|---|---|---|
| unverändert | 0 | `repo.mk: ohne die Datei ist make gates gruen … ihr Gate laeuft in make gates mit.` |
| `-include repo.mk` → `include repo.mk` (ADR Rot 2) | 1 | make: `Makefile:20: repo.mk: Datei oder Verzeichnis nicht gefunden` → `ohne repo.mk ist make gates im Ziel NICHT Exit 0 — der Aggregator bindet sie nicht optional ein` |
| Zeile `-include repo.mk` gestrichen (Fall 527 im Ziel) | 1 | make: `Keine Regel, um „eigen" zu erstellen` → `make eigen laeuft im Ziel NICHT — der Aggregator liest repo.mk nicht ein` |
| Klasse `SkipIfPresent` → `Konvergent` (ADR Rot 1) | 1 | `der Re-Lauf ueberschrieb die belegte repo.mk (skip-if-present verletzt)` |

Nach jedem Lauf `git checkout -- internal/emit`; `git status --short` leer.

## Plan vs. Code

- Plan → Code: jede Zeile der Plan-Tabelle hat ihren Diff; `baumaussage.go` geprüft — führt keine
  Datei-Liste des Ziels, kein Nachzug nötig.
- Code → Plan: nichts Gebautes ohne Plan-Zeile.
- Fitness-Zeile 3 der ADR (d-check `targets`) liegt laut §1 beim Folge-Slice
  `slice-targets-modul-im-emittierten-doc-gate` — nicht offen für diesen Slice.

## Offene Punkte für den Planner

- Closure-Trigger §5 verlangt `make full-smoke` grün; ein voller Lauf ist in dieser Verifikation
  nicht gefahren (nur die Stufe, oben) — vor der Closure nachzuweisen.
