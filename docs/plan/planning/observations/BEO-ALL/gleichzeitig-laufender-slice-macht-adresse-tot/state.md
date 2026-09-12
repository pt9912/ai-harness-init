**Stand:** offen

Ein Wächter besteht nicht, und er fehlt an der schmalsten Stelle: Die Adresse ist **Prosa in einem
Makefile-Fragment**, und keines der Module aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) urteilt darüber. `links` und `anchors` sehen nur
Markdown-Link-Ziele, `codepaths` existenzprüft Inline-Code-Pfade unter den Wurzeln aus
`codepaths.roots` — die genannte Datei existierte weiter, gestorben war der Abschnitt in ihr —, und
`targets` liest `d-check.mk` allein auf die Entsprechung zwischen Rezept und Gate-Tabellenzeile.
`make comment-claims` nimmt jede Markdown-Datei und jedes `Makefile` dauerhaft aus. Träger ist das
Review des zweiten Laufs über demselben Slice.
