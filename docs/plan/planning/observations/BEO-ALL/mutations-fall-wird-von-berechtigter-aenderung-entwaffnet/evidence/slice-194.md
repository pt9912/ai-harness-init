**Vorgang:** slice-194
**Fund:** Der `sed`-Anker von `test/mutations/299` zitierte die rechte Seite einer Zuweisung in
`internal/emit/templates.go`. Die Korrektur der Alias-Referenz auf `bytes.Clone` verschob sie, der
Patch griff nicht mehr, und der Fall maß nichts. Die Closure jenes Vorgangs führt die Form als
Unterklasse, die der dort gebuchte Ausgang nicht erreicht.
