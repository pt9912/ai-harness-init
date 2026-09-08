**Vorgang:** slice-127
**Fund:** **Drei** Verweis-Nachzüge dieses Vorgangs schreiben in einen abgeschlossenen Slice-Plan
unter `done/` — je einer pro Lifecycle-Übergang. Betroffen ist jedes Mal
`docs/plan/planning/done/slice-123-ci-sieht-die-historie.md`, der Slice, an dem dieser hier tragend
hängt. Gemessen an den zwei bereits gefahrenen Übergängen mit
`git show <commit> -- docs/plan/planning/done/slice-123-ci-sieht-die-historie.md | grep -c '^+[^+]'`
→ **8** geänderte Zeilen je Commit, sämtlich Pfad-Ersetzungen der Form
`](../<verzeichnis>/slice-127-adr-immutabilitaet-hat-einen-sensor.md)`: `9e37ba86` (`open/` →
`next/`) und `fcd146b1` (`next/` → `in-progress/`). Der dritte ist der Closure-Move nach `done/`.

**Die ersten beiden liefen ohne die von [`AGENTS.md`](../../../../../../../AGENTS.md) §3.11
verlangte Vorab-Messung; der dritte nicht.** Vor dem Closure-Move ist über beide Adress-Formen
gemessen worden, wer diesen Slice als Pfad nennt:

```sh
git grep -lF -e 'in-progress/slice-127-….md' -e 'next/slice-127-….md' -e 'open/slice-127-….md' \
  -- ':!.harness/baseline'                              # 2 Dateien
git grep -lF -e '](slice-127-….md)' -- ':!.harness/baseline'   # praefixlose Form: keine
```

Zwei Treffer, davon **einer eingefroren** — genau `done/slice-123`. **Die Entscheidung, vor dem
Move getroffen: der Nachzug läuft.** Ihn zu unterdrücken hinterließe einen toten Pfad, den `links`
rot färbt; die Adresse stattdessen im eingefrorenen Artefakt auf eine pfadlose Kennung zu ziehen,
änderte dieselben Bytes und nähme obendrein eine Norm-Entscheidung vorweg, die
[`state.md`](../state.md) ausdrücklich dem **Architect** zuweist. Was hier bleibt, ist damit keine
Panne mehr, sondern eine benannte, gemessene Wiederholung — und der dritte Anlass in einem einzigen
Vorgang, den Zähler unverändert **einmal** bewegt.
