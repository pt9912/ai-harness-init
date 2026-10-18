# Verifikation — slice-python-hexslice-layout

**Gegenstand:** `docs/plan/planning/in-progress/slice-python-hexslice-layout.md`, Range `42611489..b37cdf0c` (HEAD).
**Geprüft gegen:** DoD des Plans, ADR-0095 (Accepted), ADR-0060, MR-089, AGENTS.md §3.3/§3.6/§3.8. **Rolle:** Verifier, frischer Kontext.
**Nicht Gegenstand:** Code-Review (liegt vor: `docs/reviews/2026-10-18-slice-python-hexslice-layout.md`, 0 HIGH / 0 MEDIUM / 2 LOW / 5 INFO).

## Verdikte je DoD-Punkt

### DoD 1 — Renderer, a-check-Config, Wächter, Lauf-Zahn: **bestätigt**
- Config/Skelett gegen ADR-0095 Festlegung 4/5 gelesen und am gebootstrappten Ziel gefahren (Probe `--lang python --arch hexslice` unter `.harness/state/`, danach gelöscht):
  `make a-check` → `gesamt: 0 Befund(e)`; Hinweis nur „6 gescannte Datei(en) liegen in keiner Schicht" (sechs leere `__init__.py`); kein „Import-Symbolen"-Hinweis.
- **Kante `driven_adapters → ports_outbound` real:** Basis grün (der Adapter `in_memory_repository.py` erbt und importiert den Port). Kante in der Probe-`.a-check.yml` gestrichen →
  `wrong-direction: 2`, `gesamt: 2 Befund(e)`, `src/app/adapters/driven/memory/example/in_memory_repository.py:4: wrong-direction: driven_adapters -> ports_outbound (app.hexagon.application.example.ports.outbound.greeting_repository)`, `make` rc=2. Rot-Beleg nachgetragen.
- **L-1 nachgeprüft (Kommentar jetzt gemessen richtig):** `make lint` am frischen Bootstrap rc=0; alle Unter-Marker gelöscht, nur `src/app/__init__.py` bleibt → rc=0; auch der Wurzel-Marker weg →
  `Source file found twice under different module names: "greeting_repository" and "app.hexagon.…"`, mypy rc=2. Der Kommentar in `internal/gen/python_hexslice.go` (244254bb) sagt genau das.
- **L-2 nachgeprüft:** Marker `src/app/hexagon/__init__.py` mit `from app.adapters.driven.notify.stdout_notifier import StdoutNotifier` →
  `…/hexagon/__init__.py:1: wrong-direction: (ohne Schicht) -> driven_adapters`, `gesamt: 1 Befund(e)`, `make` rc=2. Config-Kommentar, Fall-732-Kopf und Test stimmen jetzt mit der Lage überein („ungeprüft nur bei Ziel ohne Schicht / nicht auflösend").
- **Rot-Belege (`make mutate`, seriell, `MUTATE_JOBS=1`, GNU-sed-PATH), alle gegen den korrigierten Stand b37cdf0c:**
  - 739 `python-arch-zahn-im-ziel` (full-smoke, `artifact-host`): `ok`, Meldung `full-smoke: FEHLER — Python-Arch-Gate rot, aber nicht mit core-impurity an der Domain-Datei …` (Rolle `domain`→`app`).
  - 740 `python-arch-resolution-im-ziel`: `ok`, Meldung `… das Python-Arch-Gate ist gruen, loest aber keinen Import auf (resolution der emittierten .a-check.yml?)`.
  - 742 `python-arch-kante-ports-outbound-im-ziel`: `ok`, Meldung `make gates nach add-lang python --arch hexslice faellt an wrong-direction driven_adapters -> ports_outbound: die Kante fehlt`; `# expect:` pinnt genau diese Ursache (Review-INFO-2 behoben, real bestätigt, kein allgemeines „NICHT Exit 0" mehr).
  - Text-Wächter 732 (`TestPythonHexslice_InitsLeer`), 735 und 746 (`TestArchGateConfig_PythonResolution`): je `ok`, benannter Test rot.
  - Java-Stichprobe nach den geteilten Helfern (`archConfigResolution`, `assertGlobsMatchSkeleton`): 720 und 723 (`TestArchGateConfig_JavaResolution`) `ok` — keine Java-Zähne verloren (Teillauf: „5 ok, 0 Befund(e)").
  - Vom Reviewer real gefahren und von mir nicht wiederholt: 690, 731, 733, 734, 736–738, 741, 743–747 sowie Java 719, 721, 722, 726, 728–730 (Stichproben nach Plan, Reviewer-Report Negativbefund (a)/(b)).
- Lauf-Zahn im Ziel (739/740/742) liegt in derselben Lieferung wie die Text-Wächter (Commit fb5f1c55 trägt 731–747 zusammen). Beobachtung `waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` damit gedeckt.
- **§3.3:** `git log -M --name-status 42611489..HEAD` → einzige Umbenennung `R100 690-python-hexslice-ohne-renderer.sh → 690-python-hexagonal-ohne-renderer.sh` in c069e697 (0+/0−); 67f93340 ändert nur den Inhalt (4+/4−); kein anderer Commit mischt Rename und Inhalt. Bestätigt.
- Gate `hexagonal` → Exit 2: `TestRun_AddLangPythonHexagonalIstExit2` und die full-smoke-Stufe (Exit 2, kein `apps/pythonhexagonal/pyproject.toml`) grün.

### DoD 2 — full-smoke-Stufe, Abdeckungs-Sicht, Messzahl: **bestätigt** (Gesamtdauer-Aussage siehe Befund V-2)
- `make full-smoke-host` am HEAD: `rc=0`; Stufe `Python-hexSlice-Stufe dauerte 9s`; `core-impurity`-Fall rot und Gegenprobe grün sind Teil der Stufe (Quelltext gelesen: Datei:Zeile `greeting.py:3: core-impurity: …`, Gegenprobe `a-check-apps-pythonhexslice` nach Rücknahme).
- Stufe mit `e2e_abdeckung`-Kopfzeile; `docs/user/e2e-abdeckung.md` führt 47 Stufen-Zeilen (`grep -c '^| '` = 49 abzüglich 2 Kopfzeilen); Kurzbeschreibung nennt Gemessenes und `NICHT gemessen` (übrige Richtungs-Regeln, relativer Import, voll qualifizierter Name, dynamischer Import, Marker-Import mit schichtlosem/nicht auflösendem Ziel) am selben Ort. Python-flat-Zeile führt `--arch hexagonal` → Exit 2.
- Jeder neue full-smoke-Fall (739, 740, 742) pinnt die Ursache im `# expect:` (oben, real rot gelesen).
- **Messzahl MR-089:** Message von a4fc68be nennt Kommando (`make full-smoke-host`), Lage (Image warm, colima, macOS arm64), Variante (`artifact-host`), je zwei Läufe je Stand (N V N V). Eigene Messung je ein Lauf je Stand (Vorher = Worktree 42611489, danach entfernt; beide `rc=0`):
  Stufe Python-hexSlice **9 s** (Handoff: 9 s/9 s — gestützt); Python-flat-Stufe **7 s nachher / 8 s vorher** (Handoff 7–8 / 9–10 — gestützt); Java 17/17, Kotlin-hexSlice 11/13, Java-hexSlice 12/12, C# 12/11, Kotlin-Root 6/6 (Rauschen ±2 s). Die Stufenzeit ist die belastbare Größe und deckt sich.

### DoD 3 — `spec/architecture.md`, README: **bestätigt**
- `spec/architecture.md` §Layout je Sprache: `python` trägt `flat` und `hexslice`; Verzeichnisse `src/app/{hexagon/{domain,application},adapters/{driving,driven}}`, Composition Root `src/app/main.py`, `tests/` als `exclude`, `resolution`-Block (`fixed-root`, `src/app`, `app`), Kanten der Vererbung, Entgehen von relativem Import / voll qualifiziertem Namen / dynamischem Import, `TID252` — alles gegen Code und Probe-Bootstrap sachlich richtig; keine Zeit- oder Liefersätze. README-Zeile nennt `flat` und `hexslice` für Python; `csharp` bleibt „nur das flache Layout".
- Rollenfrage (`slice-151`): **ich bestätige** die Zulässigkeit wie Reviewer I-4 und die Java-Verifikation: AGENTS.md §3.8 bindet nur Hard Rules und Adaptions-Block; Folgepflicht trägt ADR-0095 für den Slice, der Plan führt den Nachzug in §3. Kein Widerspruch.

### DoD 4 — `make gates` grün: **bestätigt**
`PATH=…gnubin:$PATH make gates` am HEAD b37cdf0c → `EXIT=0`, letzte Zeile `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`. Darin die `einordnen`-Zählung in `test/full-smoke-ausgang.bats` (b37cdf0c) grün.

### Review-/Closure-Punkte (Planner, nicht Verifier)
Review liegt vor, kein Self-Review (Reviewer ≠ Implementer-Kontext). Closure-Notiz §7, Risiko-Ausgänge §6, Register, Paarungen: offen, Planner-Arbeit (AGENTS.md §3.10). Die Messung der §6-Risiken, die ich belegen kann: (a) relativer Import — a-check extrahiert ihn nicht, `TID252` schließt ihn laut Skelett-Config; an der hexslice-Stufe von mir nicht gefahren; die Abdeckungs-Zeile nennt es als NICHT gemessen; (b) Fall-690-Umbau in zwei Commits — nicht eingetreten; (c) grobes `# expect:` — 742 war eines, behoben und real gelesen; (d) Gegenbeispiel rot im Ziel — eingetreten nicht, Stufe rot an `core-impurity`.

## Plan-vs-Code (beide Richtungen)
- Plan §3 nennt Fall 690 „wird gegenstandslos und per reinem `git mv` auf `python-hexagonal-ohne-renderer` umbenannt". Gebaut: umbenannt **und** inhaltlich zum Wächter für `hexagonal` ohne Renderer umgeschrieben (Anker `"python": {archFlat, archHexslice},` in `internal/gen/gen.go`, `expect` `TestGenerateArch_PythonOhneHexagonal`). Der Wortlaut „gegenstandslos" ist widerlegt; der Fall hat weiterhin Gegenstand. Kein Defekt, Planner trägt es in §7 nach (siehe V-1).
- Gebautes ohne Plan: `internal/gen/python_hexslice.go` als eigene Renderer-Datei (Plan nannte `python.go`/`arch.go`) — mit §3 vereinbar („Rollen-Renderer"). `internal/gen/gen.go`, `cmd/ai-harness-init/main_test.go`, `skeleton_helpers_test.go` (geteilter Helfer mit Ausnahme-Funktion) im Diff, vom Plan gedeckt (Test-Helfer gemeinsam, kein Klon).
- Out-of-Scope eingehalten: kein csharp-hexslice, kein Handbuch, `hexagonal` bleibt Exit 2, kein Python-Freshness-Werkzeug. `git diff --name-only 42611489..HEAD` führt nur `internal/`, `cmd/`, `test/`, `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md`, `spec/architecture.md`, `README.md`, `docs/reviews/` — **keine** ADR-, AGENTS.md-, `harness/conventions*`- oder Lastenheft-Änderung durch den Implementer (§3.8).
- Commit-Zuschnitt: alle Implementer-Commits tragen „Rolle Implementer", der Review-Commit „Rolle Reviewer", Kennungen LH-FA-04/LH-FA-07/ADR-0095; Review-Commit berührt nur den Report.

## Befunde
- **V-1 (INFO)** Plan §3 trägt noch „Fall 690 wird gegenstandslos"; gebaut ist die Endform (hexagonal ohne Renderer). Der Planner schreibt das in §7 als Lerneintrag (Plan-Annahme „Fall gegenstandslos" falsch), nicht der Implementer (§3.10).
- **V-2 (INFO)** Gesamtdauer nicht selbst gemessen: mein Lauf nahm je Stand nur die Stufenzeiten (je ein Lauf), keine Wanduhr-Gesamtdauer. Die Handoff-Reihe 313/311 s → 330/341 s ist damit weder gestützt noch widerlegt; sie trägt laut DoD ohnehin keinen Zuwachs allein, die Stufenzeit (9 s) ist gemessen und stimmt. Die Handoff-Aussage „Zuwachs 17–30 s, im Rauschen" ist größer als die Stufenzeit; der Rest geht (wie im Reviewer-Report I-5) auf die später im Lauf mitfahrenden Module und Rauschen — nicht gemessen.
- **V-3 (INFO, bestätigt Review INFO-1, kein Defekt)** a-check-Hinweis „6 gescannte Datei(en) liegen in keiner Schicht" bei jedem Lauf; exakt nach ADR-0095 Festlegung 4 (`exclude: ["tests/**"]`). Eine Aufnahme der Marker in `exclude` ist eine Config-Änderung gegen den ADR-Wortlaut und gehört dem Architect; Empfehlung: bei Bedarf Folge-ADR oder Beobachtungs-Eintrag, nicht in diesem Slice.
- Keine HIGH/MEDIUM/LOW-Befunde. Zwei Review-LOW (L-1, L-2) und Review-INFO-2 sind behoben und real bestätigt.

## Negativbefunde (je ein Satz)
- Sensor gelaufen: alle genannten Sensoren liefen; keiner fehlt.
- Sensor deckt Zusage: Text-Wächter binden Config-Text, die Lauf-Zähne 739/740/742 binden die Wirkung im Ziel (real rot gelesen); die Lücke „Marker-Import mit schichtlosem Ziel" ist in der Abdeckungs-Zeile als NICHT gemessen benannt.
- Kein CI-Branch-Weg (Mutations-Ergebnis) genannt; kein `mutate/…`-Branch angelegt, keiner gelöscht, kein Push.
- Aufräumen: Probe-Bootstrap, Messlogs, Worktree `wt-vorher` entfernt bzw. unter gitignoriertem `.harness/state/`; Arbeitsbaum nach den Läufen sauber.

## Empfehlung für die Closure
Alle DoD-Liefer-Punkte bestätigt; der Planner kann schließen. In §7: Lerneintrag (Fall-690-Annahme widerlegt, ein pinnendes `# expect:` erst nach Review-Befund — Beobachtung `full-smoke-fall-expect-pinnt-nicht-die-ursache` bekommt einen weiteren Beleg, Zähler im Register fortschreiben), Beobachtung `waechter-haelt-config-text-wirkung-im-ziel-ohne-lauf-zahn` (diesmal in derselben Lieferung gedeckt), Beobachtung `move-und-umschreiben-in-einem-commit` (diesmal eingehalten). Risiken §6: alle mit Ausgang *entfallen* beziehungsweise *eingetreten und behoben* (742) belegbar; relativer Import als *weiter offen*, weil die hexslice-Stufe ihn nicht misst (Abdeckungs-Zeile: NICHT gemessen).
