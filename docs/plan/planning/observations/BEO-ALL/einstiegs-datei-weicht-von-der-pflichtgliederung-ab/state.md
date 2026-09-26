**Stand:** gestrichen

**Begründung — die Ursache ist entfallen, am lebenden Baum gemessen.** Die Beobachtung sagt, die
Einstiegs-Datei führe weniger Sektionen als die Pflichtgliederung und lasse `## Safety and scope boundaries`
aus, und `## Sensors` laufe als Fließtext um eine kleine Tabelle. Beides trifft nicht mehr zu (Kommandos gegen
den lebenden Baum und die Vorlage des vendored Stands `v6.9.0`, keine Erwartungswerte):

```sh
grep -c '^## ' harness/README.md                                                    # 8
grep -c '^## ' .harness/baseline/v6.9.0/templates/harness/README.template.md        # 8
grep -c '^## Safety and scope boundaries' harness/README.md                         # 1
awk '/^## Sensors/{f=1;next} /^## /{f=0} f' harness/README.md | wc -l              # 55 Zeilen der Sektion
awk '/^## Sensors/{f=1;next} /^## /{f=0} f && /^\|/' harness/README.md | wc -l      # davon 40 Tabellenzeilen
```

Acht Sektionen stehen gegen acht der Vorlage; zwei tragen einen abweichenden Namen
(`## Guides (Feedforward)` gegen `## Guides (Feedforward-Quellen)`, `## Traceability` gegen
`## Traceability rules`), keine fehlt. `## Sensors` ist tabellengetragen.

**Grenze der Streichung, benannt.** Ein Wächter besteht nicht: die einzige Regel des Moduls `structure` in der
[`.d-check.yml`](../../../../../../.d-check.yml) hält `docs/plan/planning/done/slice-*.md`
(`awk '/^structure:/{f=1;next} /^[a-z]/{f=0} f' .d-check.yml | grep -c 'files:'` → 1), keine Regel hält die
Sektionsfolge der `harness/README.md`. Die Streichung sagt, dass **diese Aussage** nicht mehr zutrifft — nicht,
dass die Sektionsfolge nicht erneut abweichen kann; ein neues Vorkommen wäre ein neues Auftreten mit eigenem
Beleg. Was an der Datei von der Vorlage abweicht, ist heute die **Masse**, nicht die Gliederung:
`## Traceability` misst 101 Zeilen gegen 6 der Vorlage
(`awk '/^## Traceability/{f=1;next} /^## /{f=0} f' <datei> | wc -l`), Gegenstand von
`slice-114` (liegt in `next/`), nicht dieser Beobachtung.
