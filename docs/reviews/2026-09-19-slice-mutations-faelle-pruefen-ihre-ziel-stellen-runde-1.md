# Review-Report: slice-mutations-faelle-pruefen-ihre-ziel-stellen — 2026-09-19 (Runde 1)

**Review-Art:** Code — geprüft gegen Slice-Plan + `AGENTS.md` §3.6/§3.7 + `ADR-0037`
Festlegung 4, dynamisch je Zahn im Wegwerf-Klon.

**Gegenstand:** Diff `09f9d89f..f3743466` — genau ein Commit (`f3743466`, 4 Dateien,
+23/−28): `internal/gen/archgate_test.go` (Schlussform des Zahn-Kommentars),
`test/mutations/29-roadmap-nicht-neutralisiert.sh`,
`275-planning-readme-carveouts-done-ref-nicht-neutralisiert.sh`,
`114-span-lock-verzeichnis.sh`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 ·
**Modell:** GLM (glm-5.3-flash) · **Datum:** 2026-09-20

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext:**

- Slice-Plan `slice-mutations-faelle-pruefen-ihre-ziel-stellen` (`in-progress/`)
- `ADR-0037` (`Accepted`) Festlegung 4 — in Commit-Message und Kommentar 275 zitiert
- `AGENTS.md` §3.6 (`make mutate`), §3.7 (Kommentar-/Zustandsform)
- Verifikations-Report und Runde-1 des Vorgänger-Slice
  `slice-stumme-mutations-faelle-folgen-der-config-form` — F-1 (drei
  Bestand-Fundstellen) und F-2-Rest (Schlussform) als Übergaben, die dieser
  Diff einlöst
- Register-Eintrag `BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`
  (`state.md`: Ausgang *geplant*, 5×)

## Dynamische Belege (dieser Lauf)

Drei Fälle je im eigenen Wegwerf-Klon (`git clone` von `f3743466`) gefahren:
Fall-Skript angewandt (Zieldatei laut `git status` geändert), `make test-go`
gefahren, rot gelesen; der Klon ist danach verworfen — die Zurücknahme ist die
des Wegwerf-Klons, der Host-Baum blieb unangetastet.

| Fall | Rotation | Meldung (gelesen, nicht nur Exit) |
|---|---|---|
| `29` | `make test-go` → Exit 2 | `--- FAIL: TestTemplates_RoadmapGateSafe` — `templates_test.go:804: emittierte Roadmap traegt noch einen broken ../done/-Link` |
| `275` | `make test-go` → Exit 2 | `--- FAIL: TestTemplates_PlanningReadmeCarveoutsDoneRefGateSafe` — `templates_test.go:880: emittierte docs/plan/planning/README.md traegt keinen d-check:ignore-Marker auf der docs/plan/carveouts/done/-Zeile` |
| `114` | `make test-go` → Exit 2 | `--- FAIL: TestLeftoverLockDirectoryDoesNotBlock` — `span_test.go:547: Emit: open …/.s1.lock: is a directory` |

Alle drei färben ihren **benannten** `# expect:`-Wächter, und zwar aus dem
behaupteten Grund: bei `114` ist die Meldung der Chmod-statt-Rmdir-Defekt (das
Verzeichnis überlebt den Chmod, der zweite `OpenFile` scheitert mit EISDIR);
bei `29`/`275` fehlt die Neutralisierung in der emittierten Ausgabe.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Der Plan verankert die Verkörperung der 5×-Regel („die Fall-Anlage misst ihr sed-Muster gegen den Quell-Bestand") an „Liefer-Punkt 2 und 3 dieses Plans" — §2 führt nur Liefer-Punkt 1 und 2, und keiner von beiden trägt die Regel; auch §3 (Plan vor Code) hat keine Zeile dafür. Der Register-Eintrag nennt diesen Slice als Schreiber; schließt er ohne Verkörperung, löst der *geplant*-Ausgang ins Leere und die Klasse läuft weiter. | `v6.9.0` · `regelwerk/modul-06-roadmap.md` §Das Beobachtungs-Register (*geplant* ist ein Ausgang mit Kennung, kein Vorsatz) | `docs/plan/planning/in-progress/slice-mutations-faelle-pruefen-ihre-ziel-stellen.md:146` | ja — der Lese-Schritt/Register-Paarung bei der Slice-Closure würde der nicht tragende Ausgang auffallen | Register-Ausgang verweist auf Liefer-Punkte, die den Gegenstand nicht tragen |
| F-2 | INFO | Die Commit-Message sagt zum Fall 114 „kein syscall.Rmdir mehr" ohne Ort; `internal/span/lock_unix.go:25` trägt `syscall.Rmdir` weiter (innerhalb `removeStaleDir`). Der Plan scope't präzise auf `internal/span/emit.go` — die Message liest sich ohne den Ort weiter. | Maintainability | Commit-Message `f3743466` (Fall-114-Absatz) | ja — `grep -rn 'syscall.Rmdir' internal/span/` | Aussage ohne Ort liest sich weiter als Paket-Aussage |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Die drei umgeschnittenen Zähne gegen die reale Quell-Form | geprüft, ohne Befund — je Fall trifft das sed-Muster genau 1 Stelle (`internal/emit/templates.go:414`, `:428`, `internal/span/emit.go:346`); die Alt-Formen (`body = NeutralizeRoadmap(body)`, `body = NeutralizePlanningReadmeCarveoutsDoneRef(body)`, `syscall.Rmdir` in `emit.go`) stehen auf 0; je Fall im Wegwerf-Klon rot am benannten Wächter (Tabelle oben) |
| Fall 114-Unterschied (Chmod statt Rmdir) | geprüft, ohne Befund — `syscall.Rmdir` steht nur in `internal/span/lock_unix.go:25` (in `removeStaleDir`), genau die Reichweite, die der Plan §1 nennt; `os` ist in `emit.go` importiert (Zeilen 258/373), die Kompilat-Klausel trägt |
| Kommentar-Formen der drei Fall-Skripte (`AGENTS.md` §3.7) | geprüft, ohne Befund — Zustands-/Kopplungsform im Indikativ (Verhalten nach der Mutation, kompilierender leerer case-Fall, Reichweite von `removeStaleDir`); die Chronik-Formen der Alt-Kommentare („Review Runde 2, MEDIUM-1", „ANKER NACHGEZOGEN am 2026-07-29", „Befund aus slice-024s Voll-Smoke") sind entfernt |
| F-2-Rest-Form `internal/gen/archgate_test.go:233` | geprüft, ohne Befund — der Kommentar trägt den Sensor im Indikativ („die rot faerbende Aenderung ist der Pin-Wert selbst und faerbt diesen Test") statt Beleg-Existenz ohne auflösbaren Ort; kein Fall für den Pin: `grep -rln DefaultArchImage test/mutations/` → 0 |
| Commit-Umfang | geprüft, ohne Befund — genau die vier Dateien der Plan-§3-Tabelle, nichts weiter; die zwei Zitate der Message (`internal/emit/templates.go:414`/`:428`) lösen auf |
| ADR-0037-Festlegung-4-Kennung (Kommentar 275) | geprüft, ohne Befund — `ADR-0037` (`Accepted`), Festlegung 4 trägt die Tag-0-Formen samt dem `d-check:ignore`-Marker auf der `docs/plan/carveouts/done/`-Zeile, den der Test fordert |
| Fremd-Kennungen in zugefügten Zeilen | geprüft, ohne Befund — ein Muster-Treffer ist die Zitat-Form `../done/welle-NN-results.md` (Platzhalter des emittierten Broken-Links), keine Kennung eines fremden Vorgangs oder Repos |
| Treiber-Bilanz und Fallzahl | geprüft, ohne Befund — 365 Fall-Skripte unter `test/mutations/`; die Bilanzform `mutate: $pass_count ok, $fail_count Befund(e)` steht in `harness/tools/mutate.sh:1719`, die Abbruchform („keine vollständige Messung") separat in `:519`; die Meldung „365 ok, 0 Befund(e)" des Implementer-Laufs ist damit die Vollständigkeit-Form, und die drei Fälle sind als ok-Kontrast von diesem Lauf rot belegt |
| §6-Risiko (nächtlicher Lauf nach dem Umschnitt) | geprüft, ohne Befund — das Risiko trägt einen Ausgang der geschlossenen Menge („weiter offen"); der Implementer hat die Plan-Datei nicht angefasst (Diff: 4 Dateien), die Ausgangs-Zuweisung bleibt bei der Planner-Closure (§3.10) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** Register-Ausgang verweist auf Liefer-Punkte, die
den Gegenstand nicht tragen · Aussage ohne Ort liest sich weiter als Paket-Aussage

## Verdikt

**Merge-blockierend:** nein — Abweichung von der typischen MEDIUM-Wirkung mit
Begründung: F-1 betrifft den Slice-Plan (Planner-Artefakt) und die
Closure-Route, nicht den Diff; die Liefer-Punkte 1 und 2 des Plans sind durch
den Diff erfüllt und hier belegt. Der Befund geht als Übergabe an den
Planner: vor oder bei der Closure verortet er die Verkörperung der 5×-Regel
(Architect-Zug der Closure oder eigener Plan-Punkt) — sonst löst der
*geplant*-Ausgang des Registers bei diesem Übergang ins Leere.

**Übergabe:** F-1 und F-2 gehen an den Planner (Plan-Rest vor der Closure);
die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort
in den Zähler. Dieser Report selbst ist ein **Lauf-Beleg** — er wird über
Läufe hinweg nicht wieder gelesen, und muss es nicht. Der Report ersetzt
keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).