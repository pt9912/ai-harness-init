**Vorgang:** slice-lifecycle-move-geht-ins-ziel
**Fund:** Der lebende Norm-Eintrag, der die Namens-Form der Kennungen setzt, führt in seiner
`Grenze`-Sektion **zwei** Dogfood-Stellen namentlich als die, die die Slice-Kennung an Ziffern
binden, und stellt daneben das Kommando, das sie zeigen soll. Das Kommando liefert heute **keine**
der zwei mehr, sondern eine dritte Stelle:

```sh
git grep -lE 'slice-(\[0-9\]|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'
# harness/tools/commit-msg-traceability.sh
```

Die zwei genannten Stellen sind gewandert, statt zu bleiben: die eine hat ihre Ziffern-Bindung
verloren, die andere führt inzwischen eine namensfähige Alternative derselben Erkennung
(`grep -n 'slice-(?:\[0-9\]' internal/archive/stub.go` → die eine Regex-Zeile, deren zweiter Zweig
`[a-z0-9]+(?:-[a-z0-9]+)*` lautet). Die Aufzählung nennt damit Adressen, die ihre Eigenschaft nicht
mehr tragen, und das Kommando daneben führt eine, die sie trägt.

**Nicht Gegenstand dieses Registers ist der Einzelfall:** ob der Eintrag auf die heutige Menge
gezogen wird, ist eine Änderung an einem Norm-Artefakt und liegt bei dem, der ihn schreibt
([`MR-057`](../../../../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
§Grenze, Nachfolger-Eintrag). Gezählt wird hier die **Klasse**; ihr Zielort fehlt, und keiner der
beiden Nachbarn deckt sie (siehe `observation.md`).
