# Verifikation slice-span-sperre-haelt-den-test-unter-last (HEAD 33ebb12c)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Diff `ca666533..HEAD`: `11f921a8` (`lockTries` 200 -> 750 in
`internal/span/emit.go`), `33ebb12c` (Kommentar nach Review). Nicht im Diff: `internal/span/span_test.go`, `spec/`, `docs/plan/adr/`,
`AGENTS.md`, `harness/conventions*` (`git diff ca666533..HEAD --stat -- <Pfade>` leer). Geprueft ist die DoD vor Closure; Closure, Register,
Paarungen und Haekchen sind Planner-Arbeit (`AGENTS.md` §3.10).
Von Hand gebrochen in einer `git archive`-Kopie unter `~/.colima-tmp` (Image `--target test`, `docker run --network none`, `sed` im
Container), Kopie und Image am Ende entfernt.

## Verdikte je DoD-Punkt

- **D1 Ursache gemessen und benannt — NICHT erfuellt (eingeschraenkt: Rechnung ja, Ursachen-Messung nein).**
  - Der Wortlaut verlangt „Ursache gemessen und benannt … die Messung steht in §7 mit dem Aufruf, an dem sie genommen ist“. §7 ist leer
    (Closure steht aus); eine lokale Messung der Ursache gibt es nicht: am Quelltext-Kommentar selbst „die Ursache liess sich lokal nicht
    reproduzieren“. Benannt ist sie nur als Herleitung (Budget 200 x 2 ms nominal zu knapp bei Test-Gleichzeitigkeit 8 plus vier Worker).
  - Selbst gemessen: `lockTries=200` war unter meiner Last (Container `--cpus 1`, 16 bzw. 40 Busy-Loops, `-count=10` bzw. 15)
    **gruen**; auch ohne Last. Die Rot-Lage der CI ist lokal nicht herstellbar, die Herleitung also unbewiesen.
  - Der CI-Befund selbst stimmt (Run 38865723125, Job `mutate (7)`): `--- FAIL: TestConcurrentEmittersGetDistinctSeq (0.57s)`,
    `span_test.go:813: Emit: span: Sperre nicht erhalten` (3x), `span_test.go:820: 5 Zeilen, erwartet 8`, im Gruen-Vorlauf `make test-go`;
    vier Worker (`65 Faelle auf 4 Worker`) fuhren gleichzeitig denselben Vorlauf (`go test ./...`, Pakete parallel). 0,57 s Wanduhr fuer
    nominal 0,4 s Budget heisst: die Schlafzeiten dehnten sich um ca. 1,4x. Das stuetzt „Last verlaengert die Schlafzeit“, misst aber kein
    Budget-Defizit; die Last der Worker-Kopie ist aus dem Log nicht rekonstruierbar (kein Lastmass).
  - Die Worst-Case-Rechnung (der vom Plan geforderte Beleg bei Budget-Erhoehung) ist **bestaetigt**: `750 x 2 ms = 1,5 s` nominal; Hook-`timeout`
    5 s in `.claude/settings.json` Zeilen 74/86/98 (`grep -n timeout`) -> 30 %. Mit dem CI-Dehnungsfaktor 1,4x ca. 2,1 s, weiter unter 5 s.
    `make hook-overhead` wird nicht als Beleg zitiert (Kommentar nennt es nur als blind). Zahl und Grenze stehen als Kommentar an den Konstanten.
  - Urteil: Das Budget-Argument traegt rechnerisch (Obergrenze unter dem Hook-timeout), die Ursachen-Messung ist nicht erbracht. Der Planner
    entscheidet, ob „benannt als Herleitung, Messung als Luecke“ den Wortlaut tragen darf; ich lese ihn streng: nicht erfuellt.
- **D2 Gewaehlte Aenderung laesst den Test unter erzeugter Last wiederholt gruen, ohne ihn zu schwaechen — eingeschraenkt.**
  - Bestaetigt: `n = 8` unveraendert (`span_test.go` nicht im Diff); Test nicht geschwaecht. HEAD (`lockTries=750`): `-count=10` ohne Last
    `ok 0.212s`; Last 16 Loops `--cpus 1` `-count=10` `ok 2.111s`; Last 40 Loops `--cpus 1` `-count=15` `ok 3.002s`.
  - **Nicht belegt: eine Vorher/Nachher-Aussage.** Unter derselben Last lief `lockTries=200` ebenfalls gruen (`-count=10`, Last 16: `ok 2.001s`;
    `-count=15`, Last 40: `ok 4.102s`). „Wiederholt gruen unter Last“ gilt also fuer 200 wie fuer 750; der Test haelt die Wirkung der
    Aenderung nicht. Haerterer Versuch (`--cpus 0.25`, 48 Loops) starb an Zeitablauf (Compile unter Last, abgebrochen), kein Messwert; `lockTries=20`
    daher nicht gefahren. Ehrlich: fuer die CI-Last ist die Wirkung der Aenderung **nicht gemessen** — das sagt der Kommentar selbst.
  - Der Closure-Trigger (§5) „zehn aufeinanderfolgende Laeufe unter erzeugter Last, Aufruf in §7“ ist als Lauf erfuellbar (oben), der Aufruf steht
    noch nicht in §7.
- **D3 Rot gesehen — bestaetigt, mit Grenze.**
  - `lockTries = 1` (sed im Container), `-run TestConcurrentEmittersGetDistinctSeq -count=10 ./internal/span/`: `10 --- FAIL`, 68x
    `span_test.go:813: Emit: span: Sperre nicht erhalten`, `span_test.go:820: 1 Zeilen, erwartet 8` (8x) bzw. `2 Zeilen, erwartet 8` (2x). Derselbe
    Test, die behauptete Meldung, die behauptete Ursache (der Wert ist die einzige Aenderung, die Zeilen 47 per `grep` bestaetigt).
  - Grenze: das Rot haengt am Extremwert 1. Der Test unterscheidet 200 von 750 nicht (D2). Die Eigenschaft „Sperre wird erhalten“ ist gebunden,
    der Wert des Budgets nicht. Der Kommentar sagt genau das („fällt nur bei praktisch null Versuchen … unterscheidet 750 nicht von 200“): Zusage
    und Beleg decken sich.
- **D4 `make gates` — bestaetigt.** `make gates` EXIT 0 am HEAD `33ebb12c`; `.harness/state/gates-passed.head` == `git rev-parse HEAD`;
  `git status --short` leer. `make docs-check`: `d-check: 2732 Datei(en) geprueft, 0 Befund(e)`.
- **D5 Review — Report liegt vor** (`docs/reviews/2026-10-16-slice-span-sperre-haelt-den-test-unter-last.md`, 2 MEDIUM 2 LOW 1 INFO nach
  Aussage des Auftrags); Inhalt nicht neu beurteilt, nur der Kommentar-Nachzug `33ebb12c` gelesen (unten).
- **D6–D9 Closure, Register, Risiko-Ausgaenge, Paarungen — nicht dran** (Planner). §7 und §2-Haekchen sind unberuehrt.

## Auflagen A2 (Architect-Verdikt, §1 Nicht-Ziele)

- `n = 8` unveraendert; kein Eingriff in `spec/spezifikation.md`, `docs/plan/adr/`, `AGENTS.md`, `harness/conventions*` (Diff leer).
  Die Aenderung ist eine Konstante plus Kommentar — konsistent mit „Konstanten- oder Test-Aenderung genuegt“.
- `make hook-overhead` ist nicht als Beleg zitiert. Bestaetigt.
- Kein Wiederholungslauf des Gruen-Vorlaufs, kein `MUTATE_JOBS` — `harness/tools/mutate.sh`/`Makefile` nicht im Diff. Bestaetigt.

## fail-open-Kette (am Quelltext gelesen)

`acquire` (`internal/span/emit.go` ~375-381: `for range lockTries { tryLockExclusive … time.Sleep(lockWait) }`, dann `errors.New("span: Sperre nicht
erhalten")`) -> `span.Emit` -> `mustEmit` (`cmd/ai-harness-init/span_emit.go` ~85-87: `panic(err)`) -> `clamp()` (Zeilen 62-64:
`_ = recover(); os.Exit(0)`), registriert per `defer clamp()` in `spanEmit`. Der Hook endet also mit Exit 0, ohne Meldung; der wartende Aufruf
verliert seinen Span. Der Kommentar an den Konstanten beschreibt das richtig (Fehler -> `mustEmit`/`clamp` -> Exit 0, Span geht verloren, Tool-Call
laeuft weiter) und nennt den Preis (bis 1,5 s statt 0,4 s je wartendem Tool-Call, nominal) und die Grenze (nominal, Wanduhr unter Last groesser
und unbegrenzt). **Beachte:** „unbegrenzt“ heisst, dass die 5 s des Hook-`timeout` ueber den Kill (nicht ueber fail-open) greifen koennten; die
Rechnung 30 % ist nominal. Der Kommentar nennt das; ein Messwert fuer die obere Dehnung fehlt.

## Kommentar (§3.7 / §3.6)

- Indikativ, keine Befund-Kennung, keine Chronik, kein Konjunktiv ueber verworfene Alternativen (Block an `lockTries`, Zeilen 32-46 gelesen).
  Genannte Sensor-Namen (`TestConcurrentEmittersGetDistinctSeq`, `make hook-overhead`) existieren; `make hook-overhead` ist in `harness/README.md` §Werkzeuge gefuehrt.
- Eine Stelle fuer Nachfrage (kein Finding): „der Anlass der Erhoehung“ und „die Ursache liess sich lokal nicht reproduzieren“ beschreiben die
  Herkunft der Aenderung — Grenzfall zwischen Klasse *Grenze* und Vorgangsbeschreibung. Die Zusage-Grenze („Wirkung am CI-Anlass nicht gemessen“)
  steht dort und ist sachlich richtig. Verstoss gegen den Cutoff sehe ich nicht (Klasse *Grenze*).

## CI-Nachpruefung

- `gh run list --workflow mutate.yml --limit 6`: letzter Lauf 38865723125 (2026-10-16 07:12, schedule, failure); vorher 10-15, 10-14, 10-13, 10-12,
  10-11 — **alle** `failure`. Es gibt keinen Lauf auf einem Commit mit `lockTries=750`; kein Nachher-Beleg. (Die Fehler der Vortage sind laut Slice
  teils andere Ursachen; Shard 7 wurde nur am 10-16 am Span-Test gelesen — die Slice-Aussage „10-14 rot, 10-15 grün, 10-16 rot“ habe ich nicht
  shard-genau nachgemessen.)
- `make mutate-auswahl SLICE=slice-span-sperre-haelt-den-test-unter-last` urteilt CI-Branch: `Error 10`, Zeile
  `git push origin HEAD:refs/heads/mutate/slice-span-sperre-haelt-den-test-unter-last-33ebb12c`; **nicht gepusht**, `git ls-remote` zeigt keinen
  solchen Ref. Dadurch **nicht belegt**: dass die Mutations-Faelle (u. a. 305, die `internal/span/emit.go` mutiert) mit `lockTries=750` weiter
  greifen, und dass der Gruen-Vorlauf der Worker (Shard 7) mit der Aenderung gruen bleibt — der eigentliche Anlass. Das ist der Anlass-Sensor, und er
  ist unbelegt. `make mutate-greift` nicht gefahren (kein Fall-Skript im Diff; die Konstanten-Aenderung beruehrt keinen `sed`-Anker, nicht geprueft).

## Plan-vs-Code

- Plan §3 nennt `emit.go` (update, falls Budget) oder `span_test.go` (falls Test). Gebaut: `emit.go` (Budget) — Budget-Zweig; passt.
  Nichts Gebautes ausserhalb des Plans (Diff `ca666533..HEAD` ausser Plan-/Review-Dateien: nur `emit.go`).
- Plan-§1-Nicht-Ziele eingehalten (kein Wiederholungslauf, kein `MUTATE_JOBS`, keine Spec/ADR, Worker-Sterben nicht angefasst).
- Planlogik: „die Messung entscheidet“ Budget vs. Test — die Messung (D1) liegt nicht vor; die Wahl „Budget“ ist durch Rechnung, nicht durch
  Messung entschieden. Der Plan lasst fuer diesen Fall die Rueckfuehrung nach `open` nur bei unmoeglichem Budget zu; sie greift nicht.

## Befunde

- **F-1 (MEDIUM, DoD-Wortlaut): D1 „Ursache gemessen“ ist nicht erbracht.** Herleitung und Rechnung, keine Messung; §7 enthaelt keinen Aufruf.
  Entscheidung beim Planner: DoD-Wortlaut anpassen (Uebergabe-Artefakt, nicht vom Implementer) oder Messung nachholen (Last am CI-Runner nur in CI).
- **F-2 (MEDIUM, Zusage): D2 „wiederholt gruen unter Last“ ist keine Wirkungs-Aussage.** 200 und 750 sind unter meiner Last beide gruen; der
  Test haelt die Aenderung nicht. Der Kommentar sagt es ehrlich; die DoD-Zeile nicht. Die Wirkung ist erst ein CI-Lauf mit dem Commit (Shard 7)
  belegt — er steht aus.
- **F-3 (INFO): Der Mutations-Weg lief nicht** (CI-Branch nicht gepusht, bewusst); damit keine Aussage ueber die Fall-Menge auf `emit.go`.
  Wer ihn will, fuehrt `git push` (Planner/Mensch) und liest `mutate-ergebnis.txt`; Loeschpflicht des Branches laut Verifier-Regel faellt dann an.

## Gesamturteil

Code und Kommentar sind sauber, A2 eingehalten, `make gates` und `make docs-check` gruen, Rot-Beleg (D3) bestaetigt, Worst-Case-Rechnung
bestaetigt. **Nicht bestaetigt** sind D1 (Messung) und die Wirkung in D2; das ist keine DoD-Verletzung des Codes, sondern eine Luecke zwischen
Wortlaut und Beleglage. Empfehlung an den Planner: nicht als „Ursache gemessen“ schliessen, sondern die Luecke in §7 benennen und den
Anlass-Sensor (naechster geplanter `mutate`-Lauf nach dem Merge, Shard 7) als Folge-Beleg fuehren, oder den DoD-Wortlaut per
Planner-Entscheidung auf „Ursache benannt, Wirkung ungemessen“ ziehen.

## Offene Punkte

- Anlass-Sensor (Shard-7-Gruen-Vorlauf) nach dem Fix unbelegt; naechster `mutate`-Lauf entscheidet.
- Das Sterben des Workers beim roten Gruen-Vorlauf bleibt Gegenstand von §6 (nicht dieses Slice).
