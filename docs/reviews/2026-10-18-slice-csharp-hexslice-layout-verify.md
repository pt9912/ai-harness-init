# Verifikation slice-csharp-hexslice-layout

**Rolle:** Verifier (Modul 11). **Datum:** 2026-10-18. **Gegenstand:** `docs/plan/planning/in-progress/slice-csharp-hexslice-layout.md`,
Range `3e91174c..ddbee1df` (HEAD), ADR-0096 und ADR-0097 (beide Accepted). **Bezug:** LH-FA-04, LH-FA-07, ADR-0097.

## Summary

- **Verdikt: alle DoD-Punkte bis auf die Closure-Pflichten (Planner, §3.10) bestätigt.** 0 HIGH, 0 MEDIUM, 2 LOW, 3 INFO.
- Gelesen: Plan, `csharp_hexslice.go`, `full-smoke.sh`-Diff, `spec/architecture.md`-Diff, Test-Diffs, Fälle 705, 749, 755–758, 761–766,
  beide Reviews, die Messzahl-Message. Gemessen, nicht übernommen: sieben Lauf-/Text-Wächter-Fälle plus Stichproben, ein
  Ziel-Bootstrap, je ein `make full-smoke-host` je Stand, `make gates` einmal am Ende.
- Mutations-Läufe: `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_JOBS=1 MUTATE_CASES=<Fall> make mutate`,
  je Fall seriell, kein Push, `mutate: 1 ok, 0 Befund(e)`, Exit 0, die Meldung je Fall gelesen.

## Rot-Beleg (Modul 11 §Bewusstes Brechen)

| Fall | gebrochene Ursache | gelesene Meldung (Ursache stimmt) |
|---|---|---|
| 761 | Rolle der Domain-Schicht `app` statt `domain` | `full-smoke: FEHLER — C#-Arch-Gate rot, aber nicht mit core-impurity an der Domain-Datei (rot aus falschem Grund?)` |
| 762 | `resolution`-Block verfälscht | `full-smoke: FEHLER — das C#-Arch-Gate ist gruen, loest aber kein using auf (resolution …)` |
| 763 | Kante `driven_adapters → ports_outbound` entfernt | `… faellt an wrong-direction driven_adapters -> ports_outbound: die Kante fehlt …` |
| 764 | `outbound` groß in Renderer und Config | `full-smoke: FEHLER — das emittierte C#-Arch-Gate bleibt bei einem fremden Port-using im Handler gruen (port-locality an Handler.cs bleibt aus` |
| 749 | `resolution.mode` | `TestArchGateConfig_CsharpResolution` rot |
| 755 | Pfad außerhalb des Roots | `TestArchGateConfig_CsharpResolution` rot |
| 765 | `inbound` groß (Renderer und Config konsistent) | `TestCsharpHexslice_RichtungsOrdnerKlein` rot |
| 766 | Port-Glob groß | `TestArchGateConfig_CsharpGlobsMatchRenderedDirs` rot |
| 756 | Verzeichnis klein ≠ Glob | `TestArchGateConfig_CsharpGlobsMatchRenderedDirs` rot |
| 757, 758 | Kante fehlt / überzählig (beide Richtungen) | `TestArchGateConfig_CsharpEdgesMatchSkeleton` rot |
| 705 | `hexagonal` ohne Renderer | `TestGenerateArch_CsharpOhneHexagonal` rot |
| 734, 745 (Python), 720 (Java) | Stichprobe geteilter Helfer `assertArchConfigResolution` | `TestArchGateConfig_PythonResolution` bzw. `…JavaResolution` rot: kein Zahn-Verlust |

Alle `# expect:` der Lauf-Fälle 761–764 pinnen die Ursache der Stufen-Meldung, nicht „rot". 764 pinnt `port-locality` und `Handler.cs`
(der Zweig „bleibt gruen" ist nur bei ausgefallenem `port-locality` erreichbar). Die anderen drei Zweige des Stufen-Codes
(`core-impurity`, `Import-Symbolen`, `wrong-direction`) sind je durch 761/762/763 abgedeckt.

## Ziel real (gebootstrappt, nicht Fixture)

Probe: `ai-harness-init --lang csharp --arch hexslice <dir>` (Träger aus `make host-bin`) in einem gitignorierten Verzeichnis unter
`.harness/state/`; vor `make gates` gelöscht, `git status` danach sauber.

- Bootstrap Exit 0; `Ports/inbound`, `Ports/outbound` klein im Baum.
- `make a-check`: Exit 0, `gesamt: 0 Befund(e)`; `grep -c 'erreichen den App-Baum nicht\|Import-Symbolen'` → **0**.
- Kante `driven_adapters → ports_outbound` entfernt: Exit 2 (über `make`), `InMemoryRepository.cs:2: wrong-direction: driven_adapters -> ports_outbound (…)`
  und `StdoutNotifier.cs:2` (Datei:Zeile).
- Zweite Slice `Other` nach der Vorschrift des Config-Kommentars, fremder Port-`using` im Handler: Exit 2,
  `Handler.cs:1: port-locality: app außerhalb Port-Scope src/App/Hexagon/Application/Example/Other: …`.
- Zurückgenommen: `make build lint test a-check` Exit 0 (xunit), `0 Befund(e)`.

## Verdikt je DoD-Punkt

1. **Renderer und a-check-Config: bestätigt.** `languages: csharp ["**/*.cs"]`, `exclude: tests/**`,
   `resolution: fixed-root`, Root `src/App`, `package_base "App"`; Richtungs-Ordner klein, Globs `…/Ports/{inbound,outbound}/**`;
   `langArchs` führt `csharp: flat, hexslice`; sieben Kanten einschließlich Vererbungs-Kante, Test in beide Richtungen (757/758);
   `hexagonal` → Exit 2 (705, `TestRun_AddLangCsharpHexagonalIstExit2` per Review, `make gates` grün); `I`-Präfix im Renderer.
   Text-Wächter je Schlüssel (749–760, 765, 766) **und** Lauf-Zähne im Ziel (761–764) in derselben Lieferung (§3.6). Config-Kommentar nennt
   die gemessene Ursache (kleines Richtungs-Segment), die Anleitung für eine neue Slice und, seit `ddbee1df`, die Gegenrichtung;
   Ziel-Probe ohne die zwei Hinweise.
2. **full-smoke-Stufe: bestätigt.** `core-impurity` und `port-locality` rot mit Meldung, Gegenproben grün (im Lauf gelesen, `make full-smoke-host`
   Exit 0 an HEAD). Abdeckungs-Zeile in `docs/user/e2e-abdeckung.md` trägt Gemessenes und NICHT Gemessenes am selben Ort (Schreibweise beim
   Adopter, Gegenrichtung, Namensraum/Verzeichnis-Abweichung, CI-Linux, `<Using>`, Reflection, voll qualifizierter Name, `exclude`). Fall 177
   bleibt grün: `make gates` Exit 0 (enthält `make test`); die zwei neuen `make`-Läufe tragen je ein eigenes `einordnen`, keine Umgehung, keine
   Lockerung (§3.5). Die Pausen stehen im Stufenkommentar mit gemessenem Anlass (Bind-Mount unter macOS/colima, Message von 745af124);
   die Aussage ist benannt, ich habe sie nicht eigens reproduziert (L-1 des Reviews bleibt Register-Kandidat).
   **Messzahl (MR-089)** im Lieferstand: Message von `1765e7aa` nennt Kommando, Lage (Images warm), Variante (macOS arm64/colima,
   hexslice/csharp), vier Läufe V,N,V,N abwechselnd. **Eigene Messung** (`make full-smoke-host`, ein Lauf je Stand, Images warm, macOS
   arm64/colima, V = Worktree `4541d7e9`, N = HEAD, beide Exit 0): Stufe der C#-hexSlice-Stufe **V 12 s, N 28 s**; Zuwachs 16 s, Implementer
   9–12 s (V 10–11 s, N 19–22 s). Ein Lauf je Stand trägt weniger als vier Läufe; die Größenordnung (Verdopplung bis Verdreifachung der
   Stufenzeit, darin 6 s Pausen) stimmt, die genaue Zahl streut (INFO I-1). Gesamtdauer nicht ausgewertet (rauscht, trägt nichts allein).
3. **`spec/architecture.md`: bestätigt.** C#-Absatz sachlich gegen Code (Pfade, Namensraum gleich Pfad, kleine Richtung,
   `Program.cs`, `tests/App.Tests`, Kanten-Menge, `resolution`, Gegenrichtung); Beschreibung des Ist-Layouts ohne Zeit- und Liefersätze.
   README: einziger Eingriff `a8d32951` am Satz zu `csharp` („die Layouts `flat` und `hexslice`"); sie nennt die Richtungs-Ordner nicht
   (`grep -n 'Richtungs\|inbound' README.md` leer).
4. **`make gates` grün: bestätigt** (Exit 0, ein Lauf am Ende, nach Löschung von Probe und Worktree).
5. **Review durchgeführt: bestätigt** (Erst-Review, Nacharbeits-Review vorhanden).
6. **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: offen, Planner-Arbeit** (§7 leer, §3.10).

## Weitere Prüfpunkte

- **Fall 705:** `git diff -M --summary 50b65502^ 50b65502` → `rename … (100%)`, Inhalt in `fc260961` getrennt (§3.3 gehalten); Fall färbt
  `TestGenerateArch_CsharpOhneHexagonal` rot.
- **Plan-Wechsel:** im Plan-Kopf benannt („Planner-Änderung der Abnahme (2026-10-18, nach ADR-0097)"), Commit `4541d7e9` Rolle Planner.
- **L-2 (Nacharbeits-Review):** behoben in `ddbee1df`; der absolute Satz „faerbt nichts" ist aus dem Config-Kommentar entfernt, die
  Gegenrichtung steht in Config-Kommentar, `spec/architecture.md`, Stufenkopf und Abdeckungs-Zeile übereinstimmend (Text gegen Text gelesen).
- **Out-of-Scope:** kein Handbuch, `hexagonal` Exit 2, keine a-check-Anforderung. **Normen:** `git diff 3e91174c..HEAD --stat` über
  ADR/AGENTS/conventions/Lastenheft zeigt nur ADR-0097 und ADR-Index, beide in Architect-Commits (`3f5fd184`, `93d02103`); ADR-0096
  unberührt; der Implementer schrieb keine Norm. Commit-Zuschnitt: Rollen in allen Messages.
- **Rollenfrage `spec/architecture.md`/README durch den Implementer: bestätigt zulässig.** DoD 3 weist `spec/architecture.md` dem Slice zu
  (Folgepflicht der ADRs), die Änderung beschreibt nur das Ist-Layout und ändert keine Norm; die README-Zeile ist ein öffentlicher Vertrag
  (Workflow Schritt 7, Implementer-Pflicht). §3.8 bindet nur Hard Rules und Adaptions-Block.
- **Vier Aussage-Orte** (Config-Kommentar, `spec/architecture.md`, Abdeckungs-Zeile, Stufen-Kopf): sagen dasselbe; kein Sensor hält das
  (ADR-0097 nennt die Lücke) — nicht gefahren, gelesen.

## Befunde

- **L-1 (LOW) — Abdeckungs-Zeile vs. Config-Kommentar bei „Verzeichnis in anderer Schreibweise".** Die Zeile nennt „ein Verzeichnis in anderer
  Schreibweise ausser dem Richtungs-Segment … stilles Gruen"; der Config-Kommentar sagt, eine Abweichung der Schreibweise färbe
  `wrong-direction`, wo ein Adapter in die Slice importiert (gemessen nur für das Richtungs-Segment, ADR-0097 Messung 6). Die Zeile benennt
  „im Ziel nicht gefahren", die Unschärfe bleibt dadurch eine benannte Lücke; ein Adopter liest zwei Ausprägungen derselben Klasse. Kein
  Beleg, dass eine falsch ist. Vorschlag: bei Gelegenheit einen Satz angleichen; kein Bruch von §3.6.
- **L-2 (LOW) — Zuwachs der Stufenzeit nur an einem Lauf je Stand bestätigt** (siehe DoD 2). Zusage „Zuwachs 9–12 s" ist an vier Läufe des
  Implementers gebunden, meine Messung liegt mit 16 s darüber. Kein Verstoß gegen MR-089 (Zahl mit Kommando, Lage, Variante,
  Lauf-Anzahl steht in der Message); wer die Zahl weiterführt, nennt „rund 10 bis 16 s".
- **I-1 (INFO)** Messstreuung wie oben; belastbar bleibt die Größenordnung.
- **I-2 (INFO)** Gebaut ohne Plan-Nennung: Fälle 765 und 766 (Text-Wächter für `inbound` und für den Port-Glob). Der Plan nennt „748 bis 763 plus
  ein neuer Fall"; 764 ist der genannte Fall, 765/766 folgen aus ADR-0097 Festlegung 1/2 und DoD 1 („einmal rot gesehen durch Großschreiben"),
  und beide sind gemessen rot. Keine Abweichung der Abnahme.
- **I-3 (INFO)** `IDE1006`, `CA1707`, `CS8981` stehen in ADR-0097 als nicht gemessen, nicht in der Abdeckungs-Zeile. Das Gerüst bleibt
  im Ziel grün (`make gates`-Lauf der Stufe); der Plan verlangt die Nennung nicht. Wer die Zeile ergänzt, nennt die drei am selben Ort.

Negativbefunde: kein Plan-vs-Code-Widerspruch außer I-2; kein Gate gelockert; keine ADR/AGENTS/conventions-Änderung durch den Implementer; keine
Suppression; keine Host-Toolchain (alle Läufe über `make`/Docker); kein verlorener Zahn der geteilten Helfer.

## Offene Punkte für Planner / Architect

- Register-Kandidat aus dem Nacharbeits-Review L-1 (Pausen `sleep 2` ohne Gegenprobe) bleibt: nicht beheben, in §7 notieren.
- Risiken aus §6 für die Closure: CI-Linux-Lauf von `port-locality` ungemessen (→ *weiter offen* bzw. Trigger 3 der ADR-0097);
  Schreibweise beim Adopter ohne Sensor (→ *weiter offen*); Gegenrichtung nur bei Adapter-Import rot (→ benannt, *weiter offen*);
  Messzahl und `# expect:`-Ursache (→ *entfallen*, im Verify gemessen/geprüft); Kante `driven_adapters → ports_outbound` und
  Ziel-Zahn `core-impurity` (→ *entfallen*, rot gesehen).
- Observation `full-smoke-fall-expect-pinnt-nicht-die-ursache`: kein weiteres Auftreten in diesem Slice (alle neuen `# expect:` pinnen
  die Ursache).

## Empfehlung für die Closure

Der Planner kann schließen: DoD 1 bis 4 bestätigt, Rot-Belege nachgetragen bzw. selbst gefahren, kein HIGH/MEDIUM offen. Vor dem
`git mv` §7 (Lerneintrag, Register-Eintrag zu L-1 des Nacharbeits-Reviews, Risiko-Ausgänge nach §6), Messzahl mit „10 bis 16 s" statt „9 bis 12 s"
oder mit Verweis auf beide Messreihen; die drei Paarungen nach dem Move.
