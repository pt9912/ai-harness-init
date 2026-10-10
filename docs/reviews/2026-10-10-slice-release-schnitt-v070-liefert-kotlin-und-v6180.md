# Review: slice-release-schnitt-v070-liefert-kotlin-und-v6180

**Reviewer:** Rolle Reviewer · **Datum:** 2026-10-10
**Diff:** `00def796..5d7e7453` (Kern `5d7e7453`, lokal, ungepusht) · **Plan:** `slice-release-schnitt-v070-liefert-kotlin-und-v6180` (in-progress)
**Bezug:** LH-QA-02, LH-FA-01, ADR-0058, ADR-0059
**Nicht Gegenstand:** Tag-Push und Publikation (Schritt P).

## Summary

0 HIGH · 0 MEDIUM · 1 LOW · 1 INFO. Pin-Konsistenz und Reproduzierbarkeit gemessen und tragend; die Handbuch-Aussagen decken sich mit Vorlagen und Code.

## Findings

### LOW-1
- kategorie: LOW
- quelle: Maintainability (Doku-Drift, Ist-Zustand-Setzung des Handbuchs)
- pfad: docs/user/benutzerhandbuch.md:4
- befund: Die Zeile `**Stand:** 2026-10-06` ist unverändert, obwohl der Diff Software-Stand, Kotlin, KENNUNG, den Abschnitt zu alten Zielen und den reviews-Absatz am 2026-10-10 ändert; das Datum nennt einen Stand, den der Inhalt nicht mehr trägt.
- verifizierbar: nein
- klasse: Stand-Datum eines Dokuments wandert nicht mit dem Inhalt

### INFO-1
- kategorie: INFO
- quelle: Maintainability (Scope)
- pfad: README.md:42, README.md:82
- befund: Die README-Änderung (Sprachliste um `kotlin`) steht nicht in der Datei-Tabelle von Plan §3. Sie ist sachlich zwingend (die vorige Aussage „heute `go` und `cpp`" wäre am Tag-Baum falsch) und liegt im Messbereich von L2 („Versions-Pins … README.md"). Kein Schaden, nur eine Plan-Lücke; Verifier und Planner sollen sie wissen.
- verifizierbar: ja (`git diff 00def796 HEAD --stat`)
- klasse: Diff berührt Datei außerhalb der Plan-Tabelle

## Belege

**(a) Pin-Konsistenz / Reproduzierbarkeit.**
`make release-artifacts DEST=<scratchpad>/dist TRAEGER_VERSION=v0.7.0` auf `5d7e7453`, Exit 0, „6 Binaries + SHA256SUMS". Die sechs Zeilen der gebauten `SHA256SUMS` sind Zeichen für Zeichen gleich den sechs `TRAEGER_SHA256_*` im `Makefile` (linux-amd64 `91fe2ba5…`, linux-arm64 `90344c0b…`, darwin-amd64 `1e82a56b…`, darwin-arm64 `ec3ef089…`, windows-amd64 `ed83d926…`, windows-arm64 `40d31297…`). Der Bau auf dem committeten Stand liefert dieselben Digests wie der Bau des Implementers vor dem Commit; die Binaries tragen also keinen VCS-Stempel, der vom Commit abhinge. `TRAEGER_TAG` ist in `Makefile`, `internal/emit/templates/enforce/traeger.mk` und `test/traeger-fetch.bats` (zwei Stellen) `v0.7.0`. Eine weitere Fundstelle von `v0.6.0` in Live-Artefakten außerhalb von Zeitdokumenten gibt es nicht (`git grep`; Reste nur in Slice-Plan, Handbuch-Abschnitt zu alten Zielen und Testtext). Grenze: die Digests gelten für `internal/`, `cmd/` und `go.mod` des gebauten Stands; ein Report- oder Doku-Commit davor ändert sie nicht, jede Code-Änderung vor dem Tag schon.

**(b) Benannte Lücke „realer Makefile-Digest ungebunden".**
Rot-Probe am realen Pin: `TRAEGER_SHA256_LINUX_AMD64` im echten `Makefile` auf `0000…` (64 Zeichen) verfälscht, `make test-bats BATS_TARGET=test/traeger-fetch.bats`: Fälle 1 bis 10 `ok`, kein Fall färbt rot. Der Rot-Beleg des Implementers stimmt, die Lücke ist in §6 Risiko 5 geführt (Ausgang „weiter offen", Register-Eintrag `waechter-misst-die-fixture-statt-der-realen-quelle`) und nicht durch Fixture-Grün verdeckt. Der Test prüft für die Digests nur Anwesenheit und Länge 64 (`test/traeger-fetch.bats`, Fall `pin-kopplung`). `Makefile` danach per `git checkout` zurückgesetzt, Baum sauber.

**(c) Handbuch gegen Vorlagen und Code (alles ohne Befund):**
- Kotlin-Grenzen: `--arch hexslice` für go, cpp, kotlin; `kotlin --arch hexagonal` und `cpp --arch hexagonal` enden mit Exit 2 und „verfuegbar: flat, hexslice" (frische Emission mit dem gebauten Binary). Das hexslice-Kotlin-Layout (`hexagon/{domain,application}`, `adapters/{driving,driven}`, `Main.kt`, `GreetTest.kt`) deckt sich mit dem Handbuch.
- `SKEL_KOTLIN_VERSION` Default `9.8.1-jdk21` gleich `DefaultKotlinVersion` (`internal/gen/kotlin.go:10`); Dockerfile nutzt `FROM gradle:${GRADLE_TAG}` mit Stages build/test/lint; kein Gradle-Wrapper im Ziel.
- `handbuch-baum.sh … kotlin <ziel> <basis>` gegen frische Kotlin-Emission über einer Basis-Emission: „20 Pfade im Baum decken den Bestand ueber der Basis", Exit 0. Der Aufruf ohne Basis ist nicht die Form dieser Stufe (Phase 1 gilt der Basis).
- `KENNUNG`: `internal/archive/anwenden.go` bricht für `altbestand` ohne Kennung vor dem Move ab (`ErrKennungFehlt`), `cmd/ai-harness-init/archive_welle.go` gibt dafür Exit 2; beide Commits tragen die Kennung am Ende; für eine `<welle-id>` ist sie optional; das Werkzeug prüft sie nicht. Alles wie im Handbuch.
- Alte Ziele: `git show v0.5.0` und `v0.6.0:internal/emit/templates/d-check.yml` tragen `DC-FA-TGT-001` in Kommentaren (v0.5.0 Z. 82, v0.6.0 Z. 113) und `v0.84.0` (v0.6.0); `LH-QA-01` im ersten Kommentar nur in v0.5.0. `git diff v0.6.0 HEAD` der Vorlage ändert keine Nicht-Kommentar-Zeile; die Aussage „Kommentare, keine Prüf-Einstellungen" trägt. Dass der `reviews`-Kommentar-Block abweicht, stimmt.
- `reviews`-Absatz gegen `internal/emit/templates/d-check.yml`: fünf Schlüssel hinter `done-dir`/`reviews-dir` (`match: name`, `require-promises`, `recursive`, `skip-pattern`, `skip-allows-empty`), Pin `v0.86.1` erkennt Review-Zeile und Wortfolge, frisches Ziel ohne Slice-Plan rot, Block bleibt auskommentiert; deckungsgleich.
- Chronik/Prognose: nur der Absatz zu alten Zielen nennt Versionen, als Ist-Aussage über vorhandene Ziele; sonst keine Chronik, keine Prognose, nichts Unimplementiertes.

**(d)** Claim `00def796`: 1 Datei, 0 Zeilen, reiner Rename. Roadmap-Marker `5f15ddc6`: entfernt allein `**Nichts in Arbeit.**` bei beanspruchtem `in-progress/`, der Listen-Teil bleibt; richtig nach Modul 6 (Marker folgt dem Anspruch).

## Geprüft, ohne Befund

- Pin-Kopplung Tag ↔ Vorlage ↔ Makefile ↔ sechs Digests (gebaut und verglichen).
- Reproduzierbarkeit des Baus (zwei unabhängige Bauten, gleiche Digests).
- Ehrlichkeit der benannten Lücke (Risiko 5, Rot-Probe bestätigt).
- Handbuch: Kotlin-Tabellen und -Grenzen, Default-Version, KENNUNG, alte Ziele, `reviews`, Baum-Stufe.
- Hard Rules: kein Gate gelockert, keine ADR berührt, Claim reiner Rename (§3.3), kein Kommentar in Code/Config mit Chronik im Diff (`traeger.mk`-Zeile, `Makefile`-Pins).
- Roadmap-Zustandsfeld: Marker-Entfernung ohne Chronik.
- Gate-Läufe: keiner gefahren (vom Auftrag nicht verlangt); `test/traeger-fetch.bats` einzeln gefahren, grün.
