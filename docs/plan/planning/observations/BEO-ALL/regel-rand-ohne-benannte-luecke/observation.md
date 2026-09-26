# Regel-Rand ohne benannte Lücke

**Sub-Area:** `*` (gesamtes Repo)

Eine Regel, die syntaktisch statt semantisch erkennt, ist an ihren Rändern enger als die Sprache, über
die sie spricht — hier ein Link, den der Nachzug nur bis `)` oder `#` liest. Die Sensor-Doku nennt
einen Teil der Ränder als Grenze und lässt andere aus (Titel- und Spitzklammer-Form, Klammern im Ziel,
ein Ziel hinter dem Zeilenumbruch); erst der Review oder die Verifikation fährt sie. Die Fehlerrichtung
ist *die genannte Grenze ist vollständig*.

## Benannt, nicht gezählt

Ein Vorkommen ohne abgeschlossenen Vorgang: `harness/sensors/commit-msg-check.md` nennt in seiner
Grenze `-F -` und den `-m`-Aufruf, aber zwei weitere Formen eines `git commit`-Aufrufs nicht, die der
Matcher des Hooks `.claude/hooks/pretooluse-commit-msg-guard.sh` nicht erkennt — `git commit -Fmsg.txt`
(Wert am Flag angehängt) und `git -C . commit -F msg.txt` (Option zwischen `git` und `commit`):

```sh
bash .claude/hooks/pretooluse-commit-msg-guard.sh --match 'git commit -Fmsg.txt'        # Exit 1, keine Ausgabe
bash .claude/hooks/pretooluse-commit-msg-guard.sh --match 'git -C . commit -F msg.txt'  # Exit 1, keine Ausgabe
bash .claude/hooks/pretooluse-commit-msg-guard.sh --match 'git commit -F msg.txt'       # Exit 0, msg.txt (Gegenprobe)
```

Das Vorkommen entstand außerhalb einer Slice-Closure und bewegt keinen Zähler.
