**Vorgang:** slice-197
**Fund:** Der Commit, der den Wächter umbenannte, ließ seinen Mutations-Fall zurück. Die
`# expect:`-Zeile von `test/mutations/221-ignore-refs-restbreite.sh` zitiert bis heute
*„…deckt hoechstens einen Markdown-Link ihrer Quelldatei"*, während der `@test`-Titel in
`test/ignore-refs-restbreite.bats` *„…deckt genau die an ihr deklarierte Anzahl Markdown-Links"*
lautet — beide direkt am Baum abgelesen:

```sh
grep -n '# expect:' test/mutations/221-ignore-refs-restbreite.sh
grep -n 'deckt genau die an ihr deklarierte' test/ignore-refs-restbreite.bats
git log --format='%h %ad %s' --date=short -1 e3905ccd   # slice-197: … Waechter auf deklarierte Zahl
```

Derselbe Commit `e3905ccd` entfernte den alten Titel und setzte den neuen. Die Mutation färbt ihren
Wächter weiterhin rot; nur der Abgleich der Begründung schlägt fehl, und der Treiber meldet das
fail-closed als *„falscher Grund"*. Gefunden wurde es erst zwei Vorgänge später — der Fall ist die
einzige stale `# expect:`-Zeile des Satzes, geprüft über alle Fall-Dateien.
