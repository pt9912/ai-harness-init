**Vorgang:** slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset
**Fund:** In `test/tap-nachzug.bats`, Fall `tag-eingabe:`, decken zwei Assertions dieselbe Ursache: das
weite `[[ "$output" == *"Tag"* ]]` und das enge `*"Tag-Form falsch"*`. Der Zahn 413 (Formprüfung
entfernt) färbt den Fall an der weiten rot, weil die Meldung der nachgelagerten Feldform-Stufe „Tag"
nennt. Gegenprobe des Verifiers: beide Assertions gelöscht → grün; nur `Tag-Form falsch` gelöscht,
`*"Tag"*` bleibt → weiter rot. Die enge Assertion trägt allein die Aussage *die Meldung nennt die
Tag-Form*, und ihre Bindung ist durch die weite verdeckt
(`docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`
§4 Tag-Form-Zeile und §7).
