# Review-Nachlauf slice-go-toolchain-pin-zieht-auf-1-27-3

Rolle Reviewer, Folgelauf zum Report `2026-10-21-slice-go-toolchain-pin-zieht-auf-1-27-3.md`.
Range: 0505bb60, fc18bf65, a16d1de6. Plan: slice-go-toolchain-pin-zieht-auf-1-27-3 (wellenlos).
Plattform der Laeufe: macOS (Docker-Desktop-Builds ueber `make`); unter AGENTS.md 3.9 kein Normbeleg, CI bleibt das Netz.

## Findings

### INFO-1
- kategorie: INFO
- quelle: LH-QA-02
- pfad: Dockerfile:14
- befund: Die Gleichheit des Digests mit dem heutigen Index-Digest von golang:1.27.3 ist in diesem Lauf nicht gemessen. `docker buildx imagetools inspect golang:1.27.3 --format '{{.Manifest.Digest}}'` endete dreimal mit `429 Too Many Requests` (Docker Hub). Gelesen: Dockerfile:14 traegt sha256:6928d94d...9261, der Commit 0505bb60 nennt denselben Wert als eigene Messung.
- verifizierbar: ja (Wiederholung ohne Rate-Limit; `make freshness-digest`, nur naechtlich)
- klasse: Registry-Messung im Review nicht erreichbar

### INFO-2
- kategorie: INFO
- quelle: AGENTS.md 3.6
- pfad: internal/gen/gen_test.go:305-306
- befund: Der Test-Kommentar sagt, ein Pin-Sprung neutralisiere den Test nicht. Das haelt, solange kein Pin je "1.99.7" wird; keine Pruefung haelt "Eingabe != DefaultGoVersion" fest. Der Fall-Kopf von Fall 20 und der Mutationsfall binden die Eigenschaft heute (siehe Bruchprobe); ein Pin auf 1.99.7 ist praktisch ausgeschlossen. Kein Failure-Szenario im Betrieb, nur Grenze benannt.
- verifizierbar: nein
- klasse: Test-Eingabe-Distanz zum Default nur per Kommentar zugesagt

## Bruchproben

1. `MUTATE_CASES=20-gen-go-version-threading MUTATE_JOBS=1 make mutate` -> Zeile
   `mutate: ok      20-gen-go-version-threading                -> TestGenerate_GoVersionThreaded rot`, `1 ok, 0 Befund(e)`, TEILLAUF kein Beleg. Die Zeile nennt den erwarteten Test; der Befund "falscher Grund" aus der CI-Probe tritt nicht mehr auf.
2. Von Hand im Hauptbaum (sed laut Fallkopf, danach `git checkout -- internal/gen/golang.go`, Baum sauber):
   `make test-go` -> `--- FAIL: TestGenerate_GoVersionThreaded` mit `gen_test.go:311: Dockerfile ARG GO_VERSION = "1.27.3", want 1.99.7`; zusaetzlich rot `TestRun_SkelGoVersionOverride` (cmd, Eingabe 1.29.9). Die Ursache ist die behauptete: die Eingabe faedelt nicht durch.
3. Gegenprobe Mitfaerbung: TestRun_SkelGoVersionOverride faerbt dieselbe Quell-Stelle mit (andere Schicht: cmd, Umgebungsvariable SKEL_GO_VERSION). Der Fall-Kopf von Fall 20 behauptet keine Exklusivitaet; strukturelle Mitfaerbung einer gemeinsamen Stelle, kein Befund.

## Geprueft, ohne Befund

- gen_test.go-Diff: misst jetzt die Eigenschaft "Version faedelt vom Aufrufer ins Dockerfile und go.mod" unabhaengig vom Default; 1.99.7 ist zulaessig (`goScaffolding` ruft nur `majorMinor`, keine Validierung; go.mod-Erwartung 1.99 stimmt, Test gruen im Gruen-Vorlauf von make mutate).
- Doc-Kommentar im Test: Indikativ, beschreibt die Stelle (3.7); keine Chronik, keine verworfene Alternative.
- Weitere Tests derselben Klasse: `git grep -n DefaultGoVersion -- internal cmd`: alle uebrigen Treffer nutzen den Default als Eingabe, ohne ihn zugleich als erwarteten Fremdwert gegen eine "durchgefaedelte" Eigenschaft zu halten (Zeile 16, 78-238, archgate_test, hexslice_test, TestGoProfile_PinsMatchRepo generisch). Fall 19 nutzt 1.29.9 (rot in Bruchprobe 2), Fall 18 matcht generisch.
- Commit-Messages: 0505bb60 und a16d1de6 nennen Kommando bzw. Wert und Kennungen; a16d1de6 nennt `make mutate`-Lauf (hier selbst nachgefahren, rot gelesen). fc18bf65 Verifier-Commit, nur Report.
- Dockerfile:14: nur der Digest geaendert, Tag/ARG unberuehrt (siehe INFO-1 fuer die offene Registry-Messung).
- Mutations-CI-Probe fuer den neuen Stand: nicht gefahren (Freigabe steht aus).
