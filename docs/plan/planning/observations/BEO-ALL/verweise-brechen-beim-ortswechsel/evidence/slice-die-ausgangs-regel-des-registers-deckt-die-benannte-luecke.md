**Vorgang:** slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke

**Fund:** Der Slice ist **zweimal** gewandert — `next/` → `in-progress/` und
`in-progress/` → `done/` —, und die präfixlose Form brach dabei **drei** Verweise, von denen das
Werkzeug **keinen** sah. Jeder Übergang steht für sich, weil die Fundstelle jedes Mal eine andere
ist:

```sh
make slice-mv … TO=in-progress      # eingehend: 0 — gebrochen: 2 (die Schwester unter next/, :43 und :99)
make slice-mv … TO=done             # eingehend: 3 — gebrochen: 1 mehr, das die Suche nicht traf:
                                    #   docs/plan/planning/in-progress/roadmap.md:23  target-missing
```

Der dritte ist der, der die Regel des Repos **selbst** trägt: die In-Arbeit-Zeile der Roadmap
verweist auf ihren Slice als Geschwister — die Zeile entsteht mit dem `next → in-progress`-Übergang
und fällt mit der Closure, und beide Male steht der Verweis präfixlos. Der erste Übergang:

```sh
make slice-mv SLICE=slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke TO=in-progress
#   eingehend: 0 Datei(en) mit Verweisen nachgezogen
make docs-check
#   docs/plan/planning/next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md:43
#     slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.md  target-missing
#   … :99  target-missing
```

Beide stehen in der **präfixlosen Geschwister-Form** `](slice-….md)`, und genau die sucht die
eingehende Hälfte nicht: sie sucht das Literal `"$from/$base"`, also `next/slice-….md` — ein
präfixloses Ziel enthält dieses Literal nicht. Die **ausgehende** Hälfte kennt dieselbe Form
(`rewrite_outgoing_bare_in_file`); es ist damit keine Auslassung, sondern die **Asymmetrie**, die die
Grenze dieser Beobachtung schon benennt.

Von Hand auf den Nachbarort im `in-progress`-Verzeichnis nachgezogen. Der Beleg ist die zweite Messung am Eltern-Commit, weil
der Fix selbst die Grundmenge bewegt
([`MR-058`](../../../../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)):

```sh
git show 36ec0151^:docs/plan/planning/next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md \
  | grep -c '](slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke\.md)'   # 2
```
