**Vorgang:** slice-flache-welle-ist-eroeffnet-nicht-geplant
**Fund:** Dreimal derselbe Mechanismus in einem Vorgang — für den Zähler **eine** Gelegenheit. Der
Slice glich vier Planungs-Artefakte an ihre vendored Ziel-Form an, und drei Stellen des Fremdtexts
trugen etwas, das dieses Repo nicht so führt: die `Lifecycle:`-Kopfnote von `welle-13` übernahm den
Platzhalter `welle-<Kennung>-results.md`, wo die zwei Geschwister ihre Kennung nennen (Runde 1,
F-3); der Satz *„Sie stehen in der Roadmap … und nirgends sonst"* steht neben einer Roadmap, die
für eine Welle mit Abhängigkeit zusätzlich eine gerichtete Kante im Abhängigkeitsgraphen verlangt
(Runde 1, F-4); und der Satz *„Der aktive Durchlauf `open/` → `next/` → `in-progress/` nimmt
ausschließlich **Slices** auf"* steht zwei Zeilen unter einem Link auf `in-progress/roadmap.md`
(Runde 2, R2-1).

**Was den dritten Fall schärft:** Die vendored Vorlage adressiert den Pfad **selbst**, und das
Regelwerk daneben — der Satz widerspricht damit nicht nur dem adoptierenden Repo, sondern seinem
eigenen Baum:

```sh
grep -rl 'in-progress/roadmap' .harness/baseline/v6.8.0/ | wc -l   # 7
```

**Kein Erwartungswert.** Das Gegenmittel des Plans — *Angleichung der Aussage, nicht Byte-Übernahme
des Absatzes* — hat die ersten zwei Fälle abgefangen und den dritten nicht: Er entstand in dem
Nachzug, der die Ziel-Form **korrekt** gewählt hatte. Ausgang von §6 Risiko 1 dieses Slice ist
damit *eingetreten*, mit dem Folge-Slice
`slice-planning-readme-beschreibt-die-eigenen-lifecycle-verzeichnisse`.
