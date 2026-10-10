# Review slice-a-check-pin-bringt-den-go-sicherheitsfix

Range: f4e7410f..HEAD, Gegenstand 57f1fa9a (Pin), 70ed9c0c (Roadmap), d3868345 (MR-093 + Index-Zeile). 62f91f8b ist anderer Slice.

**Summary:** 0 HIGH, 0 MEDIUM, 1 LOW, 0 INFO.

## Findings

### LOW-1
- kategorie: LOW
- quelle: MR-093, MR-084
- pfad: harness/conventions/MR-093-a-check-pin-v0232-go-sicherheitsfix.md:7-9 und :13-20 (Geltungsbereich, Ersetzt-Baseline-Regel); harness/conventions.md Index-Zeile MR-093
- befund: MR-093 "setzt MR-084 fort", nennt MR-084 als den Eintrag, der den Sprung v0.23.0 "trug", und begründet den Fork "aus demselben Grund wie MR-084". MR-084 Geltungsbereich (Z. 9-10) schließt den a-check-Pin ausdrücklich aus ("Nicht der a-check-Pin desselben Slice"); die Fortsetzung ist keine, die Kette a-check-Pin v0.23.0 -> v0.23.2 hat in MR-084 kein Glied.
- verifizierbar: ja (`sed -n 5,12p harness/conventions/MR-084*.md`)
- klasse: Fortsetzungs-Zeiger auf Eintrag, der den Gegenstand ausschließt

## Geprüft, ohne Befund

- (a) Pin-Stellen: genau eine Stelle (`internal/emit/archgate.go`: Tag, Digest, Kopfkommentar). Reste von `v0.23.0`/`97cb6d4` stehen nur in Zeitdokumenten, ADR-0088 (immutable) und im `emit_test.go`-Kommentar (laut Plan §1 bewusster Bestand). Kopplungstests (`TestArchImagePin_CouplesToDirectionPorts`: Tag >= v0.20.0, Digest-Form; Fall `66-archgate-pin.sh`) tragen den neuen Wert ohne Anpassung. Stichprobe: `docker buildx imagetools inspect ghcr.io/pt9912/a-check:v0.23.2` liefert Index-Digest sha256:2368f7b3...f422, amd64 e824afcc..., arm64 aeaf033e... (gleich MR-093).
- (b) Go-Fassung: Binär aus dem amd64-Manifest gezogen, Versionsabfrage im Bild golang:1.27.2 ergibt go1.27.2 (Stichprobe wiederholt, stimmt). Rot am echten Pin (verfälschter Digest, full-smoke Exit 2, manifest unknown) und Gegenmessung go/cpp/kotlin (grün byte-gleich, core-impurity an beiden Digests) stehen in der Commit-Message 57f1fa9a und stimmen mit den Tabellenwerten in MR-093 überein; die core-impurity-Läufe und den Byte-Diff habe ich gelesen, nicht wiederholt. Die Zusage "Prüfverhalten unverändert" ist damit in beiden Richtungen (grün und rot) belegt, nicht nur über das Rot des Pins.
- (c) MR-093 gegen MR-092/MR-084: Pflichtfelder (Datum, Wirksamkeits-Anlass, Geltungsbereich, Ersetzt-Baseline-Regel, Adaption, Begründung, Auflösungs-Trigger) vollständig; keine Adresse in `.harness/baseline/<tag>/`; Slice-Kennung nur im Feld Wirksamkeits-Anlass; Index-Zeile kürzt Geltungsbereich/Ersetzt mit `…` und trägt beide Anker. d3868345 berührt nur `conventions.md` und die MR-Datei (§3.8), Rolle in der Message genannt.
- (d) Grenzen (nur amd64 gemessen, Tag/Digest ungekoppelt mit Verweis auf BEO-ALL/pin-digest-ohne-waechter, Messbild per Tag) sind ehrlich benannt.
- (e) Trigger ADR-0009/ADR-0088: "nicht eingetreten" stützt sich auf identische Befunde (core-impurity, Schema grün) in allen drei Sprachen an beiden Digests; trägt.
- Roadmap 70ed9c0c: Ruhe-Marker entfällt bei beanspruchtem `in-progress/`, korrekt, keine Chronik.
- Gates: nicht von mir gefahren (Hintergrund-Task des Auftraggebers hält `make gates`).
