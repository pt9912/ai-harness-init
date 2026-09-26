**Vorgang:** slice-emittierte-dateien-behalten-lf-im-autocrlf-klon
**Fund:** Der Lifecycle-Wechsel `open/ -> next/` dieses Slice (Nachzug-Commit `a380aca6`) schrieb in
einem Verifikations-Report zu `slice-program-feld-nennt-weder-operator-noch-wertfragment` die
Adresse in einer Mess-Zeile um: Die Zeile hält die Ausgabe eines `git diff --name-only` fest, die
einen fremden Slice unter dem Pfad nennt, unter dem er **zum Messzeitpunkt** lag (`open/`); nach dem
Nachzug stand dort `next/` — ein Ort, an dem die Datei bei der Messung nie lag. Die Adresse stand
in einem Code-Span, kein Link; `make docs-check` sah davon nichts, weil `codepaths` den Baum
`docs/reviews/` ausnimmt. Der Ausgang war ein Planner-Commit von Hand (`bd76d800`), der die
Tatsachenaussage wiederherstellte; seine Begründung trug nicht, und die Reichweite des Nachzugs in
diesem Baum ist seither in
[`ADR-0070`](../../../../../../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Festlegung 1 entschieden.
