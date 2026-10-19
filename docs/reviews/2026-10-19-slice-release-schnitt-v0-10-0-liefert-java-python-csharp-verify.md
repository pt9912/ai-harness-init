# Verifikation slice-release-schnitt-v0-10-0-liefert-java-python-csharp (HEAD 8a1c062b)

Rolle Verifier. Frage: bauen wir es richtig, gegen Plan und DoD. Geprüft ist die DoD vor Schritt P (L1, L2, L3-Vorbedingungen);
Push, Tag und Publikation sind nicht angestoßen. Eingang: Implementer-Commit `9e60c01d` (Pin, Vorlage, Bats-Tag, Handbuch),
Reviewer-Report `86f8e9df`, Leerzeilen-Fix `8a1c062b`. Messungen mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`.
Bau und Ausgaben unter `.harness/state/` (gitignoriert, per `git check-ignore` bestätigt, am Ende gelöscht), Scratchpad für Skripte.

**Gefahren vs. gelesen.** Gefahren: Neubau der sechs Binaries, `release-sums.sh verify`, Bestand-Messung (neun Sätze), Fehlertexte am gebauten
Binary, die zwei Brech-Läufe (Tag, Digest), die sechs `freshness-*`-Ziele (Netz, read-only), Gates. Gelesen, nicht gefahren: der
Release-Text gegen Quellen, `release.yml`/`start-smoke.sh`, das Mutations-Ergebnis des CI-Branch, die Prosa der Sprachbäume im Handbuch.

## Verdikte je DoD-Punkt

- **L1 Version gezogen, Tag-Baum vorbereitet und verifiziert — bestätigt, mit benannter Lücke (F-1 unten).**
  - (a) `make release-artifacts DEST=.harness/state/vf-dist TRAEGER_VERSION=v0.10.0` → `release-artifacts: OK — 6 Binaries + SHA256SUMS`
    (58 s, Exit 0). Die sechs Digests sind byte-gleich mit den sechs `TRAEGER_SHA256_*` des `Makefile` (Zeilen 46-51):
    linux-amd64 `fd7738a0…`, linux-arm64 `e87d9ef1…`, darwin-amd64 `6f17f018…`, darwin-arm64 `046c0206…`, windows-amd64 `26616442…`,
    windows-arm64 `f87b07b4…` (Sichtvergleich der vollen 64 Zeichen gegen `cat SHA256SUMS`, alle sechs gleich).
  - `bash harness/tools/release-sums.sh verify <dist>` → sechs `OK`, Exit 0.
  - (b) `git diff --name-only 9e60c01d..HEAD` nennt nur `docs/reviews/2026-10-19-…md` und `docs/user/benutzerhandbuch.md`: kein Treffer in
    `internal/`, `cmd/`, `go.mod`, `Dockerfile`. Der Neubau lief auf HEAD und trifft die Digests; die Zusage „Binary-Eingang unverändert seit
    `9e60c01d`" ist damit am Bau gemessen, nicht nur am Diff.
  - (c) `TRAEGER_TAG` == `v0.10.0` an drei Stellen: `Makefile:45`, `internal/emit/templates/enforce/traeger.mk:25`, `test/traeger-fetch.bats:121-122`.
    `git grep 'v0\.9\.0'` (ohne `docs/reviews`, Zeitdokumente, ADRs, Baseline) nennt nur: den Slice selbst (Vorgänger), Beobachtungs-Belege,
    Lastenheft-Historie `0.9.0` (Dokumentversion, unabhängig), `test/tap-nachzug.bats:774-776` (Vergleichspaare des Tap-Vorwärts-Schutzes,
    `0.10.0` gegen `v0.9.0` — gewollt) und im Handbuch zwei Zeilen, die `v0.9.0` als Vorgänger nennen (Z. 840, 888). Die `v0.10.0`-Treffer
    in `harness/conventions/MR-009` sind der d-check-Tag `v0.10.0`, kein Release-Tag dieses Repos.
  - (d) Handbuch: `grep -n 'Quellstand\|v0\.9\.0' docs/user/benutzerhandbuch.md` → nur Z. 840 und 888, beide „ältere Programme nennen weniger".
    Kein Quellstand-Hinweis am Kopf, kein Rest-Verweis. `Software-Stand` (Z. 3) und „aktuell ausgeliefert wird" (Z. 81) auf `v0.10.0`,
    `Stand: 2026-10-19`. Fehlertexte am **selbst gebauten** darwin-arm64-Binary (`--version` → `v0.10.0`):
    `--lang foo` → `Fehler: unbekannte Sprache "foo"; verfuegbar: cpp, csharp, go, java, kotlin, python` (Exit 2) — gleich der Liste der
    Handbuch-Überschrift Z. 838; `--lang python --arch hexagonal` → `Fehler: unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice`
    (Exit 2) — wörtlich wie im Handbuch; `--lang cpp --arch hexagonal` → dieselbe Meldung (`flat, hexslice`), passt zu „nennt die Bauformen,
    die diese Sprache kann"; `--lang go --arch bogus` → `verfuegbar: flat, hexagonal, hexslice`.
  - **Rot 1 (selbst):** ein Byte an die Kopie von `ai-harness-init-linux-arm64` angehängt → `ai-harness-init-linux-arm64: FAILED`,
    `sha256sum: WARNING: 1 computed checksum did NOT match`, Exit 1, die Datei ist genannt.
  - **Rot 2 (selbst, im Arbeitsbaum, sofort per `git checkout -- Makefile` zurück, `git status` danach leer):** `TRAEGER_TAG` im realen
    `Makefile` auf `v0.10.1` → `make test-bats BATS_TARGET=test/traeger-fetch.bats`: `not ok 1 pin-kopplung: der Tag haelt an beiden Stellen …`,
    die übrigen neun Fälle `ok`. Die Kopplung färbt also aus dem behaupteten Grund (Tag-Trennung Vorlage/Makefile).
  - **Rot 3, reale Quelle (selbst, gleiche Rückstellung):** `TRAEGER_SHA256_LINUX_AMD64` im realen `Makefile` von `fd77…` auf `0d77…` →
    `bats test/traeger-fetch.bats`: 0 `not ok`, zehn von zehn `ok`. **Kein Fall färbt — die bekannte Lücke ist belegt.** Der Test prüft
    pro Digest nur „vorhanden, 64 Zeichen" (`traeger-fetch.bats:125-130`); den Wert hält erst `make traeger-fetch` nach der Publikation.
    Der Slice führt sie ehrlich (§2 L1 Rot, §6 Risiko 3). Für die sechs Digests trägt die Nachrechnung oben (a) die Zusage, nicht ein Wächter.
  - `make gates`: siehe Schluss.
- **L2 Release-Text bereit — bestätigt, mit zwei Hinweisen.** Datei
  `/private/tmp/claude-501/-Users-dburkard-Dev-pt9912-ai-harness-init/a53f3db9-533d-499d-9b47-39ae95c4c111/scratchpad/release-v0.10.0.md`:
  Titelzeile, **Stand**, **Assets**, **Grenze**, *Full Changelog* vorhanden; kein Changelog im Repo.
  - *Stand* gegen Quellen: Sprachliste = Fehlermeldung des gebauten Binary; Standard-Tags `9.8.1-jdk21` (`internal/gen/java.go:10`),
    `3.14.8-slim` (`python.go:10`), `10.0.402` (`csharp.go:14`); Bauform-Aussage = gemessene Meldungen oben.
  - *Assets*: „acht Dateien" und Start-Smoke mit Markern `ai-harness-init`/`add-lang` gegen `releasing.md` Schritt 5 und
    `harness/tools/start-smoke.sh` (Marker-Schleife Z. 47-50) gelesen; „mehr nicht" deckt die Aussage, die der Text unter Grenze wiederholt.
  - *Grenze (nach F-1)*: a-check wird nicht als „aktuell" behauptet; „nur der Tag gegen seinen Digest gehalten, neuerer Tag nicht abgefragt"
    stimmt mit `internal/emit/archgate.go:24-25` (Tag + Digest) und dem Fehlen eines a-check-Freshness-Ziels im `Makefile` (Liste:
    baseline, golangci, dcheck, go, cpp, kotlin, digest) überein; „für Python- und dotnet-Image kein Aktualitäts-Sensor" stimmt mit derselben
    Liste. Die Freshness-Aussagen **selbst gefahren**: `freshness-go` (1.27.2), `-golangci` (v2.15.0), `-dcheck` (v0.86.1), `-cpp` (26.04),
    `-kotlin` (9.8.1-jdk21), `baseline-freshness` (v6.18.1) — alle „aktuell". Das deckt die Textzeile „Go, golangci-lint, d-check, die
    Baseline, die C++-Basis und den gradle-Tag … aktuell". Grenze der Messung: Stand heute, nicht der Stand des Hinweis-Laufs des Implementers.
  - **Bestand** — Abschnitt fehlt im Text, zu Recht. Wiederholt mit dem Träger `v0.9.0` (darwin-arm64, sha256 gleich dem `Makefile`-Pin
    des Vorgängers `0422691f…`, `--version` → `v0.9.0`) gegen den frisch gebauten `v0.10.0`, je frisches `git init`, neun Sätze,
    `diff -rq -x .git`: Sätze 1-6 (ohne `--lang`, go, go hexagonal, go hexslice, cpp, kotlin) beide Exit 0, Differenz genau zwei Dateien:
    `.harness/state/bin/ai-harness-init` (Träger selbst, gitignoriert) und `harness/mk/traeger.mk` (Tag-Zeile). Sätze 7-9 (java, python,
    csharp): Vorgänger Exit 2, neuer Exit 0 (neue Sprachen, „kein Diff"). Ein Re-Lauf des neuen Binary über einen v0.9.0-Lauf hebt
    `harness/mk/traeger.mk` auf `TRAEGER_TAG ?= v0.10.0` und lässt `git status` unauffällig — `traeger.mk` ist erste Klasse (wird neu geschrieben,
    Handbuch Z. 211), der Träger ist Zustand. Keine Datei der zweiten Klasse ändert sich → Abschnitt entfällt nach `releasing.md` Schritt 5.
  - Hinweis 1: die Zusage „das Handbuch beschreibt diesen Stand" ist für die **Prosa der Sprachbäume** nur gelesen (Reviewer), nicht von mir
    gefahren; der Sensor dafür (Handbuch-Baum in `full-smoke`, Mutations-Fälle 616/617/767-770) hing im CI-Probelauf (siehe unten).
  - Hinweis 2: MR-089 — der Text enthält keine Laufzeit-/Kosten-Aussage; ich habe keine gefunden.
- **L3 Veröffentlichung benannt, nicht gefahren — bestätigt (Vorbedingungs-Teil).** §3 Schritt P nennt Vorbedingungen und Befehle, Freigabe-Vermerk
  „ausstehend"; nichts gepusht, kein Tag, `git ls-remote` nennt nur den `mutate/`-Branch. Offen bleibt die Vorbedingung „Mutations-Probe ohne Befund" (unten).

## Mutations-Ergebnis vom CI-Branch (einmal gelesen)

`git fetch origin mutate/slice-release-schnitt-v0-10-0-liefert-java-python-csharp-9e60c01d && git show FETCH_HEAD:mutate-ergebnis.txt`:
geprüfter Commit `9e60c01d1bb5…` (= der Implementer-Commit; Binary-Eingang seit dann unverändert, siehe (b)), Basis `e89d611a`.
**Fallmenge 31, 22 ok, 9 `BEFUND (kein Ergebnis im Log)`, Urteil BEFUND**, Shards 0-8 Exit 2, Shard 9 Exit 0 (809 s).
Befund-Fälle, je der erste Fall seines Shards: `305-rollenachse-ziel-verliert-rolle-fullsmoke`, `553-ausgang-unveroeffentlichter-traeger-tag`,
`554-traeger-tag-im-fragment-umbenannt-full-smoke`, `616-handbuch-baum-erfundener-pfad`, `617-handbuch-baum-emittiert-ungenannt`,
`767/768/769/770-handbuch-baum-{kotlin,java,python,csharp}-pfad-ohne-nennung`. Ok u. a. `555-traeger-tag-im-fragment-umbenannt-pin-kopplung`
(deckt Rot 2 oben), `403-fassungs-pin-default`, die `release-*`-Fälle 78-81.
- **Nicht bestätigt, Ursache nicht gelesen.** „Kein Ergebnis im Log" heißt: kein `mutate: ok`/`BEFUND`-Zeile für den Fall; die Shard-Logs liegen
  mir nicht vor. **Vermutung, ungeprüft:** die neun Fälle laufen über `full-smoke` (Fälle 553/554 nennen „make traeger-fetch im frischen Klon",
  616/617/767-770 sind Handbuch-Baum-Stufen), das den Träger am Tag `v0.10.0` holt — der ist nicht veröffentlicht (§6 Risiko 2, 404).
  Das trifft die Sensoren, die das Handbuch und den Pin im Ziel halten, also genau die Zähne zu L1/L2. Die Datei benennt weder Ursache noch Log.
- Folge: die Zähne der Handbuch-Baum-Stufen und der Träger-Tag-Fälle im Ziel sind für diesen Schnitt **unbelegt**. Weder mein Lauf noch die CI belegt
  sie. Entscheidung Planner/Nutzer: Shard-Logs (`gh run view`) lesen, um die Vermutung zu prüfen, und die neun Fälle nach der Publikation
  (Tag vorhanden) erneut fahren — oder den Schnitt mit der benannten Lücke fahren.

## Findings

- **F-1 (MEDIUM, Zusage breiter als Sensor): Mutations-Probe mit 9 von 31 Fällen ohne Ergebnis** — Beleg oben. Blocker für „Verifier-Bericht ohne Blocker"
  nur, wenn der Planner die Zähne der neun Fälle verlangt; sonst bedingte Freigabe mit der Lücke im Closure-Lerneintrag.
- **F-2 (LOW, benannt): realer `Makefile`-Digest ungebunden** — Rot 3. Erwartet, im Plan geführt; Schließung nach Publikation durch
  `make traeger-fetch` im frischen Klon (Slice §3 / `releasing.md`), nicht vorher.
- **F-3 (INFO): Review-F-4 (`internal/gen/gen.go` Kommentar STAND) bleibt offen** — bewusst; eine Änderung unter `internal/` ändert das Binary und
  alle sechs Digests. Bestätigt: der Kommentar ist die einzige Abweichung, das Verhalten stimmt (Meldungen oben).
- **Plan-vs-Code:** beide Richtungen gelesen am Diff `9e60c01d~1..HEAD` (Makefile, Vorlage, Bats, Handbuch, Slice-Datei, Review-Report): nichts Gebautes
  ohne Plan, nichts Zugesagtes ohne Code. Der Slice nennt `releasing.md` unverändert; so ist es.
- Negativbefunde: kein Binary-Eingang nach `9e60c01d`; keine tote v0.9.0-Stelle im lebenden Bestand; keine Laufzeit-Aussage im Handbuch-Diff; kein
  Quellstand-Rest.

## Für den Tag

Binary-Eingang und Pin sind identisch auf `9e60c01d`, `86f8e9df`, `8a1c062b` und diesem Bericht-Commit; die sechs Digests gelten für alle.
**Der Tag stünde auf dem Commit, der diesen Bericht trägt (der gates-gestempelte HEAD)** — dessen Hash der Planner an `git log -1 --format=%H -- docs/reviews/2026-10-19-slice-release-schnitt-v0-10-0-liefert-java-python-csharp-verify.md` abliest.
Wird danach ein weiterer Commit (Planner-Marke, Closure) vor dem Tag gemacht, ist `make gates` auf dem neuen HEAD neu zu fahren; ein Tag auf
`8a1c062b` wäre ebenso binär-gleich, trüge aber keinen Gates-Stempel (Risiko 1 des Slice).

## Offene Punkte für Planner/Architect

1. Mutations-Probe: Ursache der neun Befunde klären (Logs) und entscheiden, ob vor Schritt P ein erneuter Lauf nötig ist (er kann erst nach Publikation
   des Tags grün werden, wenn die Vermutung stimmt — dann bleibt die Lücke bis Schritt 8 und gehört in den Lerneintrag).
2. Freigabe-Vermerk Schritt P bleibt beim Nutzer.
3. Branch `mutate/…-9e60c01d` auf origin: Löschen nach Auftrag des Aufrufers (nicht gepusht, nicht gelöscht von mir — die Rolle verlangt Löschen nach dem Lesen;
   hier nicht ausgeführt, weil der Lauf des Aufrufers noch in der Auswertung steht).
