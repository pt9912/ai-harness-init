# Review — slice-labor-gates-host-rezepte (welle-ohne-docker)

**Reviewer-Lauf:** frisch (ein vorheriger Lauf brach auf, ohne Werkstück zu hinterlassen)
**Diff:** `a62fbfce..HEAD` (a62fbfce = `git mv` nach `in-progress/`, HEAD = 2bbc4495)
**Umfang:** 39 Dateien, +689/-113. Fremde Einlagen im Range, als Overlap eingeordnet, nicht
als Slice-Scope: `9b921b22` (Konsum-Commit `slice-binraire-ziehen-ohne-docker`) und Teile von
`f1045699` (`.viper.sh`-Zug zweier Slices).
**Gegenstand:** die sechs Image-Rezepte der Gates-Kante fahren host-native Äquivalente
(ADR-0109); `docs-check-host` über das fetched d-check-Binary; Inventar-Zeile
`golangci-lint` (exakt, abgeleitet); Mutations-Fälle 806–810, Umankerungen 498/499/98,
neuer bats-Tree `test/rezept-host.bats`; zwei Wächter weg-agnostisch umgebaut (2bbc4495).

**Abgrenzung dieses Reviews:** Code gegen Plan und ADR. DoD-Abhakung, CI-Kausalität im
Vollen und Closure sind nicht Teil dieses Berichts; der Slice wird hier nicht geschlossen.

---

## Findings

### F-1 — HIGH

- `kategorie`: HIGH
- `quelle`: Plan §1/Ziel + ADR-0109 (Pflicht-Weg der Gates), Modul-10-Kontext-Eskalation —
  die Beobachtung liegt im Gate-Pfad (`shell-lint` hängt an `record-gates`, Makefile:888)
- `pfad`: `harness/tools/bats-lint.sh:96-107`
- `befund`: Der Host-Weg von `bats-lint.sh` löst den Pfad des `bats-preprocess` auf, setzt
  aber `BATS_ROOT`/`BATS_LIBDIR` nicht — genau die zwei Variablen, die der Image-Weg
  ausdrücklich übergibt (`-e BATS_ROOT=/opt/bats -e BATS_LIBDIR=lib`, Zeile 92). Der
  gelöste `bats-preprocess` sourced `"$BATS_ROOT/$BATS_LIBDIR/bats-core/common.bash"`
  (brew-Fassung 1.14.0, Zeile 41) und bricht bei leerer Variable an `//bats-core/common.bash`
  — für **jede** Datei, deterministisch. `make shell-lint` endet damit laut in der Kante
  „der Extrakt ist unvollstaendig"; der docker-lose Pflicht-Weg dieses Slices ist an dieser
  Stelle nicht lauffähig (Plan §1: „die sechs Image-Rezepte … fahren host-native Äquivalente
  ohne Docker-Daemon"). Live belegt, s. Kommando-Protokoll unten.
- `verifizierbar`: ja — `make shell-lint` (bzw. `BATS_HOST=1 bash harness/tools/bats-lint.sh`);
  Beleg im Protokoll unten
- `klasse`: „Zweiträger-Läufer löst den Pfad des Werkzeugs auf, aber nicht dessen
  Umgebung (BATS_ROOT/BATS_LIBDIR)"

### F-2 — MEDIUM

- `kategorie`: MEDIUM
- `quelle`: Plan §2/Liefern-Punkt 1 („die gepinnten Image-Pfade bleiben als opt-in Weg
  gepinnt … und tragen denselben Exit-Vertrag") · Maintainability
- `pfad`: `test/rezept-host.bats:31,104,116` (`run make -C …`, `git check-ignore`),
  `test/dockerfile-teststufe.bats:50` (`run make -n test-go`)
- `befund`: Die neuen Rezept-Wächter hängen an `make -n` und `git` — Werkzeuge, die der
  gepinnte `bats/bats`-Image-Weg (`test-bats-image`, Pin-Zeile unverändert, Image-Größe
  laut Registry ~19 MB) nicht trägt. Vor diesem Slice rief kein bats-Test `make` zur
  Laufzeit; nach ihm hängt die Suite (die `test-bats-image` komplett fährt) an Host-Werkzeugen.
  Der Exit-Vertrag „derselbe Lauf im gepinnten Image" hält für den bats-Stage-Image-Weg nicht
  mehr. **Gelesen, nicht gefahren:** docker trägt am Reviewer-Host nicht (Beleg-Ort:
  Image-Lauf `make test-bats-image`); die Befund-Stärke steht auf dem Registry-Maß
  (Image-Größe 18,7–21 MB für amd64, keine Platzform für `make`+`git`), nicht auf einem
  Lauf.
- `verifizierbar`: ja — `make test-bats-image` (docker-getrieben, opt-in); rote Wächter
  voraussichtlich `rezept: …` 1–12 und `dockerfile: der Host-Testlauf …`
- `klasse`: „Weg-agnostik der Wächter endet an den Werkzeugen des zweiten Trägers"

### F-3 — LOW

- `kategorie`: LOW
- `quelle`: Maintainability (Doku-Drift · `harness/README.md` §Sensors-Zelle `docs-check-host`)
- `pfad`: `harness/sensors/docs-check.md:5` (und Prosa passim: nur `docker run … /repo:ro`-Formen)
- `befund`: Die README-Zelle des neuen Pflicht-Wegs verlinkt `sensors/docs-check.md`, dessen
  Prosa ausschließlich den gepinnten Image-Transport beschreibt (`docker run --network none …`,
  „derselbe Digest"); der Transportwechsel des Slices (fetched Carrier `$(DCHECK_CARRIER)`,
  Makefile:836-846, `make dcheck-fetch` als Besorgung) steht nur im Makefile-Kommentar und in
  der Zelle, nicht im von der Zelle verlinkten Sensor-Text.
- `verifizierbar`: ja — `make docs-check-host`-Kontrast gegen die Sensor-Posa; kein Sensor
  liest die Zelle gegen die verlinkte Prosa
- `klasse`: „Sensor-Zelle verlinkt eine Prosa, die den zugesagten Träger nicht trägt"

### F-4 — INFO

- `kategorie`: INFO
- `quelle`: Maintainability (`test/mutations/810` Rot-Beleg)
- `pfad`: `test/mutations/810-zitate-byte-semantik-entzaubert.sh:12`; `test/spec-zitate.bats:18-25,39`
- `befund`: Der Rot-Beleg der Mutation ist an die Zeichen-Semantik des Host-`awk` gebunden:
  auf einem Host, dessen `awk` in einer Nicht-UTF-8-Locale byte-zählt, ändert der sed-Patch
  (`^  LC_ALL=C awk →   awk`) das Verhalten der Zitat-Routinen nicht, und der benannte Wächter
  bleibt grün. Die Annahme „Host-awk läuft in einer UTF-8-Locale" ist undokumentiert; die
  Formen-Probe über zwei Locales ist im Protokoll unten. CI (GitHub-Runner, `C.UTF-8`) wird
  getroffen.
- `verifizierbar`: ja — `make mutate` auf einem POSIX-Locale-Host (Fall bleibt grün);
  nicht in einem Gate getragen
- `klasse`: „Rot-Beleg einer Mutation an die Werkzeug-Semantik des Ausführungsorts gebunden"

### CI-Lage — Einordnung, kein Finding gegen diesen Diff

`gh run list --workflow=ci` (Protokoll unten): der Push 2bbc4495 ist rot in den Jobs
`gates` (Annotation `Out of memory.`, keine rote Step-Ausgabe — das Job-Log-Blob fehlt,
`gh api …/actions/jobs/140403895882/logs` → HTTP 404) und `full-smoke`
(`Konsumenten-Aufruf`-Stufe des Traeger-Fetch-E2E, `make archive-welle` endet an der
Sperre `[untergrenze]` mit make Error 3 statt Vollzug, ADR-0058 Festlegung 2). Beide
Signaturen bestehen **vor** der Range: denselben OOM-Annotaitonstext und dieselbe
Konsumenten-Aufruf-`[untergrenze]`-Meldung liefert der Lauf von `a6c70467`
(`slice-binraire-ziehen-ohne-docker`, Vorfahr-Beleg `git merge-base --is-ancestor` → ja)
sowie `d4da2fde` (06:47). Der letzte grüne `ci`-Lauf im Repo ist `d8312c3b`
(2026-10-21) — der frische-Klon-Beleg ist seither nicht grün belegt, über mehrere
Slices hinweg. **Antwort auf die Prüffrage:** die beiden roten Jobs sind kein Finding
gegen `a62fbfce..HEAD`; die `[untergrenze]`-Kausalität liegt am E2E-Konsum des
`slice-binraire-ziehen-ohne-docker`/ADR-0058-Gegensatz (gefetchter Carrier vs. Seed
`done/` des frischen Klons) — die offenen Slices
(`slice-smoke-und-full-smoke-ohne-docker`, `slice-ci-runner-ohne-docker`) tragen die
Folge-Arbeit, wie die Plan-Abgrenzung §1 es ansetzt.

---

## Kommando-Protokoll (Belege)

**F-1 (live gefahren):**

```
BATS_HOST=1 bash harness/tools/bats-lint.sh
  …
  .../bats-core/bats-preprocess: line 41: //bats-core/common.bash: No such file or directory
  bats-lint: FEHLER — bats-preprocess scheitert an test/traeger-pins-check.bats
  … (alle test/*.bats)
  bats-lint: FEHLER — der Extrakt ist unvollstaendig (bats-preprocess oder docker gescheitert)
```

Gegenprobe zur Ursache (`sed -n '40,41p'` der gelösten bats-core-Fassung):
`source "$BATS_ROOT/$BATS_LIBDIR/bats-core/common.bash"` — der Image-Weg übergibt beide
Variablen (`-e BATS_ROOT=/opt/bats -e BATS_LIBDIR=lib`), der Host-Weg nicht.

**Wächter-Formen-Probe (lokal, docker-los):**

```
bats test/rezept-host.bats   -> 1..12, alle ok
shellcheck -S warning harness/tools/{bats-lint,environment-check}.sh test/mutations/{806..811}-*.sh
                             -> Exit 0
MUTATE_CASES=806,…,811 make mutate-greift (fuhr den vollen Bestand)
                             -> 795 Faelle, 792 greifen, 3 Befunde — 784/785/794
                                (harness/tools/gates-fast.sh, gates-keys.sh — Anker veraltet);
                                die Dateien liegen außerhalb der Range, Alt-Befund, nicht
                                dieser Slice. 806–811 greifen (Teil der 792).
bats test/rezept-host.bats   -> 12/12 grün (Happy-Formen der Rezept-Texte)
```

**F-4-Formen-Probe:**

```
printf '%s' '„test“' | LC_ALL=C awk '{print substr($0,5)}'         -> est“   (Byte-Semantik)
printf '%s' '„test“' | LC_ALL=en_US.UTF-8 awk '{print substr($0,5)}' -> t“   (Zeichen-Semantik)
```

**CI-Beleg (Netz-Träger, kein lokaler Gate-Lauf):**

```
gh run list --workflow=ci --limit 15          -> letzter Erfolg d8312c3b (2026-10-21)
gh run view 45968155326                       -> gates: Out of memory. (Annotation .github#0)
                                                 full-smoke: exit 2, Konsumenten-Aufruf
gh api …/actions/jobs/140403895882/logs       -> HTTP 404 (Log-Blob fehlt)
gh run view 45960465554 --log | grep untergrenze -> dieselbe [untergrenze]-Meldung am
                                                    Vorfahr-Commit a6c70467
git merge-base --is-ancestor a6c70467 a62fbfce -> ja
```

Anweisungsgemäß **nicht** gefahren: `make gates` (Auftraggeber-Beschluss: Docker aus,
Lauf-Stabilität).

---

## Geprüft, ohne Befund

- **Makefile — die sechs Ziel-Rezepte:** `test-bats`, `test-go`, `lint`, `build`,
  `shell-lint`, `ci-lint` host-native; `go test`-Rezept ohne zweite Pin-Stelle
  (`make -n test-go` ohne `GO_VERSION`, Wächter-Zeile bestätigt), `lint` ohne
  Ablage-Fallback und ohne `GOLANGCI_LINT_CARRIER`, `build`/`host-bin` mit
  TRAEGER_VERSION-Injektion als fehlendem Operanden (leerer Default byte-identisch,
  `test/release-matrix.bats`-Erweiterung gelesen). Kein Befund.
- **Opt-in Image-Weg:** alle `*-image`-Ziele gepinnt und ungestrichen; die Pin-Zeilen
  (BATS/SHELLCHECK/ACTIONLINT, GO_VERSION, GOLANGCI_LINT_VERSION) unverändert — der
  Vertrag „Pin-Zeilen unverändert" hält; der Vertragsbruch des bats-Image-Wegs steht als
  F-2, nicht hier. Kein weiterer Befund.
- **Exit-Klassen:** `docker build`-Wege und Host-Rufe enden in derselben make-Fehlschlag-
  Klasse; die Deckel-Grenze des Host-Wegs trägt zwei benannte Kommentare
  (Makefile bei `TEST_PIDS_LIMIT`, `test/dockerfile-teststufe.bats`-Kopf) und einen
  Negativ-Wächter („der Host-Testlauf trägt den Ressourcen-Deckel NICHT"). Kein Befund.
- **environment-check.sh — Umstrukturierung des Prüff-Blocks** (else-Zweig →
  `if [ "$gut" -eq 1 ] && command -v …`): Verhalten bei vorhandenem, fehlendem und
  Ablage-gefundenem Werkzeug gelesen; die case-Bedingung deckt dieselbe Werkzeug-Menge
  wie der vorige else-Zweig, die d-check-Ablage-Sonderrolle bleibt am selben Ort und
  schließt den case weiterhin aus. Kein Befund.
- **Inventar-Zeile `golangci-lint` + SPEC-099-Schärfung + Sensoren-Posa** (`environment-check.md`):
  exakt/abgeleitet an GOLANGCI_LINT_VERSION (Makefile + Dockerfile), reine PATH-Probe;
  die drei neuen bats-Fälle (Soll-Abweichung 9.99.0, Fehlen am PATH, Gelingen am stub)
  decken die Negative; die `nichtvorhanden-werkzeug`-Ersatz-Form repariert den Warn-Fall
  über einer sonst leeren Bedingung. Kein Befund.
- **pinsync:** das neue Pin `golangci-lint` (drei Quellen) und sein
  `pinsync-modul-wiring`-Wächter; die GNU-portable Lesung der `go`-Paarung. Kein Befund.
- **d-check.mk:** das Fragment unberührt (`docs-check` byte-genau, `DCHECK_REF`-Pin);
  `docs-check-host` ohne eigene Flags-Definition; `record-gates`-Kanten-Erwartungsliste
  aktualisiert (Mutations-Fall 807 greift an derselben Zeile). Kein Befund.
- **Mutations-Anlagen:** 806–810 (neu) und 498/499/98 (Umankerung auf
  `test-go-image`): `# expect:`-Namen jeweils exakt gegen die `@test`-Namen abgeglichen;
  Greift-Messung im Protokoll; kein `# expect:`-Fall mit Exklusivitäts-Behauptung.
  Kein Befund (außer F-4 bei 810).
- **Weg-agnostische Wächter-Probe (2bbc4495):** `811-stub-listing-sed-anker` und der
  Bash-Loop-Ersatz `sed 's|^\./||' → while-read -d ''` im Stub `ls-files`; Varianten-Form
  gelesen (NUL-Record-Restauration). Kein Befund.
- **harness/README §Sensors-Zellen** gegen den Makefile-Bestand: die umgeschriebenen
  Bindungen (`test`, `lint`, `build`, `shell-lint`, `ci-lint`, `host-bin`,
  `docs-check-host`) nennen nur existierende Targets; die neue Image-Reihe nennt
  `test-bats-image` … `docs-check`, alle im Makefile/d-check.mk vorhanden (§3.1
  Negativbefund). Zell-Kürzung host-bin (49f97352) unter 150 Zeichen. Kein Befund.
- **Kommentar-Klassen (AGENTS.md §3.7)** über die neu angelegten/geänderten
  Kommentar-Blöcke (Makefile ADR-0109-Blöcke, bats-lint.sh-Kopf, environment-check.sh,
  Inventar-Grund-Spalte, Sensoren-Posa): Zusage-/Kopplung-/Grenz-/Rang-Zeiger-Formen,
  Herkunft als `· seit slice-…`-Anker. Die aktualisierten Zeilen des
  `PROTOKOLL DER BREAK-TESTS`-Abschnitts in `environment-check.sh` werden als Fortschreibung
  des bestehenden §3.6-Rot-Beleg-Orts gelesen (Abschnitts-Form und Beleg-Funktion
  unverändert) — nicht als neues Herkunft-Feld. Kein Befund auf dieser Grundlage.
- **`.viper.sh` und Teile von `f1045699`** als Overlap-Kontext (Werkzeug-Anschaffung zweier
  Slices): golangci-lint exakt zum Pin, Symlink-Nachzug, `make dcheck-fetch` als Eintrag —
  außerhalb des Prüfumfangs dieses Slices angeordnet und nicht gegen ihn bewertet.
- **`9b921b22`** (Konsum-Commit des Nachbars-Slices) als Overlap-Kontext gelesen; keine
  Slice-Artefakte darin.

## Restrisiken

- F-2 ist maßstärker statt laufbelegt (docker am Reviewer-Host aus); der Beleg liegt am
  `make test-bats-image`-Lauf.
- Die `gates`-Job-OOM ist am CI-Ausgangslauf wegen fehlendem Log-Blob nicht kausal
  aufschlüssbar — die Einordnung stützt sich auf die Signatur-Gleichheit mit Vorfahr-Läufen.
