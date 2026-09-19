# Eine Prozedur-Zeile trägt die Disziplin, kein Sensor fängt ihren Bruch

**Sub-Area:** * (gesamtes Repo)

Eine Prozedur-Zeile, die einen harten Schritt trägt, hat keinen Sensor: ihr
Bruch — der Schritt wird übersprungen — bricht kein Gate. Erstanlage in
`slice-releasing-doku-traegt-den-release-vorgang`: die zwei Disziplin-Zeilen
des Release-Vorgangs (Gates am Tag-Baum vor dem Tag-Push · CI am Tag abwarten,
bevor der Schnitt vollzogen gemeldet wird) stehen als Schritte 4 und 6 in
`releasing.md`, und kein Gate hält ihre Schritt-Folge — die Release-Workflow
führt kein `docs-check` und kein `make gates`
(`grep -nE 'docs-check|make gates' .github/workflows/release.yml` → 0
Treffer), und das Abwarten des CI-Verdikt ist ein Schritt ohne Wächter.