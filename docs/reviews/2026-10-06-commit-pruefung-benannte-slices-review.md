# Review: slice-emittierte-commit-pruefung-erkennt-benannte-slices

Reviewer-Lauf, Diff `2085fc00` und `ce5e37d0`, gegen Plan, ADR-0053, MR-057/059/071 und AGENTS.md §3.5/§3.6/§3.7.

## Findings

1. **LOW** · Quelle: AGENTS.md §3.5/§3.6 · `internal/emit/templates/enforce/commit-msg-traceability.sh:58` ·
   Das Muster `slice-[a-z][a-z0-9-]*` hat keine Wortgrenze und keine Mindestlänge: `slice-x`, `slice-based`, `a slice-wise fix` und
   `noslice-foo` gelten als Kennung (gefahren mit `grep -E`; `slice-`, `sliced`, `slice_x`, `Slice-12` nicht). Der Plan nennt
   nur `slice-based` im Fließtext als akzeptiertes Negativ, nicht das Mittendrin-Wort (`noslice-…`). Die Schwelle „mindestens eine
   Kennung" bleibt formal, ist für das Wort-Präfix `slice-` aber nur noch eine Anwesenheitsprüfung des Präfixes. Die
   Aussage „Schärfung, nicht Senkung" trägt für die Form, nicht für die Trennschärfe; sie ist im Plan §1/§6 als akzeptiertes Negativ benannt.
   verifizierbar: ja · klasse: Kennungs-Muster ohne Wortgrenze
2. **INFO** · Gegenmessung am Bestand (`git log --format=%s`, 4180 Betreffe): ohne Kennung nach altem Muster 994, nach neuem 363;
   die 631 neu erkannten tragen reale Slice-Namen. Von 784 `slice-mv:`-Betreffen erkennt schon das Präfix `slice-mv` alle,
   der Name wird nicht gebraucht (ohne das Präfix bleibt nur 1 ohne Kennung). Die Messung „alle benannten Werkzeug-Commits erkannt"
   belegt darum die Namens-Form nicht; sie tragen der bats-Fall 9 (Bezug im Rumpf, Gegenprobe unten) und die full-smoke-Stufe.
   Der dritte Teil von Fall 9 (`slice-mv: …`) wäre auch mit dem alten Muster grün.
3. **INFO** · Obermengen-Fall: stimmt mit dem Plan überein (nur emittiert ⊇ Dogfood). Die Dogfood-Zeile
   (`harness/tools/commit-msg-traceability.sh:58`) führt die Namens-Form nicht; die Lücke hält der Plan-Ausschluss.

## Geprüft, ohne Befund

- (b) `make test-bats BATS_TARGET=test/commit-msg-emission.bats`: 12 ok.
- (c) `make mutate MUTATE_CASES="520-… 521-… 356-…"` (ausgeschrieben, ohne `.sh`): 3 ok, 0 Befund. Gegenprobe 520: Mutation angewandt, Fall 9
  allein per `skip` ausgesetzt: Suite grün, also bindet Fall 9 die Namens-Form allein. Die sed-Anker treffen die Zeile `patterns=`
  im Quellbestand (MR-071), Baum danach sauber.
- (d) full-smoke-Deklaration nennt Gemessenes (EIN benannter Slice im Ziel) und Nicht-Gemessenes am selben Ort; `make e2e-abdeckung`
  hinterlässt keinen Diff gegen `docs/user/e2e-abdeckung.md`.
- (e) Kopf und Meldung beschreiben die Menge im Indikativ, keine `LH-`/`ADR-`-Kennung des Werkzeugs im emittierten Skript außer den
  Klassen-Mustern; `sort -u` in der Kopf-Kopplung verdeckt nur die doppelte Klasse `slice`, Fall 356 färbt weiter rot.
- `make gates`: Exit 0.

Laufzeit: 815 s
