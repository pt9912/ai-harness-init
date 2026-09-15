**Vorgang:** slice-215-commit-waechter-sieht-auch-die-ungetippten-commits
**Fund:** Der Vorgang verschiebt den Träger der Kennungs-Zusage an den **Commit** und läßt die
Klasse an genau der Stelle stehen, für die er gewählt ist: Der Träger erreicht einen Commit aus
einem Repo-Werkzeug, **sobald dessen Message eine Kennung trägt** — die vier Message-Formen der
eigenen Werkzeuge bilden sie aber ohne eine
([`ADR-0053`](../../../../../../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
Festlegung 4). Gemessen am Bestand, **keine Erwartungswerte**:

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
git log --format='%s' | grep -c '^slice-mv:'                                 # 411
git log --format='%s' | grep '^slice-mv:' | grep -vcE "$RE"                  #  44
git log --format='%s' | grep -c '^archive-welle'                             #   0
```

Alle **44** nennen einen Slice der **Namens**-Form aus
[`MR-057`](../../../../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
— die Form also, die dieser Prozess **neu** vergibt; jede Message mit einer Ziffern-Kennung im
Dateinamen geht durch (`slice-[0-9]+` trifft sie als Teilstring). Der Bruch trifft damit nicht die
Werkzeug-Klasse als ganze, sondern ihren jüngsten Namens-Zweig, und `archive-welle` als die
Message-Form, die noch keinen Beleg im Bestand hat.

**Die Commits dieses Vorgangs selbst fallen nicht in die Klasse.** Gemessen über die ganze Kette:

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
for c in $(git rev-list 7ee36939~1..dc392dd9); do
  git log -1 --format=%B "$c" | grep -qE "$RE" || git log -1 --format='KENNUNGSLOS %h %s' "$c"
done                                                                        # kein Treffer
```

Die Klasse tritt hier also **nicht** an den Rollen-Commits auf, sondern an der Werkzeug-Klasse, die
der Vorgang benennt, messend belegt und liegen läßt; ihre Behebung trägt der Kandidat
`slice-werkzeug-commits-tragen-eine-kennung`. Die zweite offene Hälfte des Eintrags — die
Bezugseinheit *jeder Commit* gegen *die Änderung als ganze* — bleibt unberührt
(`slice-121`).
