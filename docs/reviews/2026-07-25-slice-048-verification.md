# Verifier-Report slice-048 — Release-Artefakte (Plattform-Matrix)

Rolle: Verifier (Modul 11). Frischer Kontext, **strikt read-only** — kein `make`-Lauf
(Schaden-Präzedenz slice-044/047: ein Verifier-Subagent mutierte per Hintergrund-`make mutate`
den Haupt-Baum). Commits `5c4930b` (CR, Schritt 0) → `dfca6c6` → `4219db9` → `067e928`.
Datum: 2026-07-25.

**Was ich unabhängig gemessen habe** (statt Behauptungen nachzuerzählen):

- **Gate-Stempel gegen den Baum:** `harness/tools/working-tree-hash.sh` (read-only) liefert
  `38ac3874da28c48699143d08d30a6f37d6cc2857adb416ea47c3f2a02e99556e` — **byte-gleich** mit
  `.harness/state/gates-passed.diffsha` (mtime 17:36, nach dem letzten Commit 17:35);
  `git status` clean. `make gates` lief real **auf genau diesem Baum** grün.
- **Die sechs Artefakte selbst gelesen** (`scratchpad/rel1`, `rel2`): `sha256sum` aller zwölf
  Dateien, **Header-Felder per `od`** statt `file` nachgeschlagen, **mtimes auf die Sekunde**.
- **Byte-Identität des Default-Pfads** an den beiden Artefakt-Extrakten `bin1`/`bin2` nachgerechnet.
- `git show/diff/log`, vollständiges Lesen von `test/release-matrix.bats`, `test/mutations/78…81`,
  `Makefile`, `Dockerfile`, `.github/workflows/release.yml` + `ci.yml`, `spec/lastenheft.md`
  §LH-QA-01…04, `harness/conventions.md` MR-014, `AGENTS.md` §3.6/§4.
- Logs: `mutate11.log` (17:17), `fullsmoke7.log` (17:30).

---

## DoD Punkt für Punkt

### 1. Schritt 0 — CR am Lastenheft vor Code — **BESTÄTIGT**

- **Sauber getrennt und in der richtigen Reihenfolge.** `5c4930b` (16:46) fasst **ausschließlich**
  `spec/lastenheft.md` an (`git show --stat`: 1 Datei, +18/−3) und liegt vor dem ersten
  Code-Commit `dfca6c6` (17:17). Doc führt, Code folgt — strukturell eingehalten.
- **Keine verdeckte Absenkung der Anforderung.** Der Diff-Hunk ersetzt genau die zwei
  Messmethoden-Zeilen; die **Anforderungs**-Zeilen (`spec/lastenheft.md:257-260`, „linux · macos ·
  windows × amd64 · arm64, cross-kompiliert im gepinnten Image") sind im Diff **nicht enthalten**,
  also byte-unverändert. Die zugesagte Menge bleibt sechs Kombinationen.
- **Die Präzisierung erhöht die Abdeckung, sie senkt sie nicht.** Der alte Wortlaut
  („Plattform-Smoke in der CI-Matrix") hatte **null** Abdeckung — es gab weder Matrix-Build noch
  Release-Workflow. Danach steht ein real definierter, abgestufter Nachweis. Es gibt keinen Stand,
  gegen den hier etwas verloren ginge.
- **Die Grenze ist für Dritte verständlich** (`:267-276`): sie nennt die Ursache (macOS-Images ohne
  Container-Runtime; Windows-Images nur mit Windows-Containern), die Konsequenz (der Start-Smoke
  belegt, dass das Binary **läuft**, nicht dass ein Bootstrap durchläuft) und die
  Auflösungsbedingung (Runner, die Linux-Container fahren). Das ist ohne Rückfrage lesbar.
- Zwei LOW-Punkte, siehe R-5/R-6: die Historien-Zeile 0.13.0 steht **vor** 0.12.0 (Tabelle sonst
  aufsteigend), und die Tatsachenbehauptung über die Runner-Images trägt im Lastenheft **keine
  Quelle und kein Datum** — nur die Commit-Message sagt „an den Runner-Images-Readmes geprueft".

### 2. Cross-Compile mit byte-identischem Default — **BESTÄTIGT (unabhängig nachgerechnet)**

- Verdrahtung: `Dockerfile:57-60` — `ARG TARGET_OS=` / `ARG TARGET_ARCH=` (leerer Default),
  `RUN CGO_ENABLED=0 GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH} go build …`. `make build`
  (`Makefile:55`) reicht keine `--build-arg` durch → leere Werte = ungesetzt.
- **Byte-Identität ist eine echte Messung, kein Cache-Artefakt** (das habe ich getrennt geprüft):
  `bin2/ai-harness-init` mtime **16:47:01**, `bin1/ai-harness-init` mtime **16:51:33** — die
  Dateizeit stammt aus dem Image-Layer, zwei verschiedene Zeiten bedeuten **zwei verschiedene
  Layer**, also zwei echte `go build`-Läufe (der Dockerfile-Inhalt unterschied sich zwischen
  gestashtem und neuem Stand, der Cache-Key also auch). Beide sha256
  `5d44bc4c640f1a835e911fef429303ff9ee2ad3d0296abc479be73167538146a`. Der Default-Pfad hat sich
  nicht bewegt.
- Zusatzbefund, der die Aussage stärkt: derselbe Hash trägt auch
  `rel1/ai-harness-init-linux-amd64` (mtime 16:52:10, wieder eigener Layer, weil eigene
  `--build-arg`) — der Default-Pfad und ein **explizites** `linux/amd64` erzeugen aus zwei
  unabhängigen Übersetzungen dasselbe Kompilat.
- Ein LOW: der Dockerfile trägt den Abschnitts-Banner `# ---- build ---` jetzt **zweimal**
  (`Dockerfile:42` und `:48`) — der neue Kommentarblock wurde **ergänzt** statt den alten
  umzuschreiben, siehe R-4.

### 3. Matrix-Target — **BESTÄTIGT**

- `Makefile:75` `RELEASE_PLATFORMS ?= linux/amd64 linux/arm64 darwin/amd64 darwin/arm64
  windows/amd64 windows/arm64`; `:77-92` Schleife mit `docker build --build-arg TARGET_OS/TARGET_ARCH
  --target build`, `docker create` + `docker cp` — **nur** Docker, kein Host-`go` (ADR-0003).
- `DEST` Pflicht mit Exit 2: `Makefile:78`, wortgleich zur bestehenden `artifact`-Zusage
  (`Makefile:63`). Wächter `test/release-matrix.bats:101`, Mutation 81 rot gesehen.
- **Plattform-tragende Namen + Formate unabhängig geprüft** (ich habe die Header-Bytes gelesen,
  nicht `file` zitiert), `scratchpad/rel1`:

  | Datei | Magic | CPU-Feld | Ergebnis |
  |---|---|---|---|
  | `…-linux-amd64` | `7f454c46` (ELF) | `e_machine=0x3e` | x86-64 ✓ |
  | `…-linux-arm64` | `7f454c46` (ELF) | `e_machine=0xb7` | AArch64 ✓ |
  | `…-darwin-amd64` | `cffaedfe` (Mach-O 64) | `cputype=0x01000007` | x86_64 ✓ |
  | `…-darwin-arm64` | `cffaedfe` (Mach-O 64) | `cputype=0x0100000c` | arm64 ✓ |
  | `…-windows-amd64.exe` | `4d5a` (MZ/PE) | `machine=0x8664` | x86-64 ✓ |
  | `…-windows-arm64.exe` | `4d5a` (MZ/PE) | `machine=0xaa64` | AArch64 ✓ |

- **Zur gestellten Frage — belegt `file` mehr als das Containerformat?** Ja: `file` liest genau
  diese CPU-Felder, es belegt also **Ziel-OS und Ziel-Architektur des Kompilats**, nicht nur den
  Dateityp. Was es **nicht** belegt, ist, dass das Binary auf der Plattform *läuft* (Linker-,
  libc-, Gatekeeper-Fragen) — das ist Aufgabe des Start-Smokes, und der ist nie gelaufen
  (DoD-Punkt 6).

### 4. Reproduzierbarkeit (`LH-QA-02`) — **TEILWEISE**

Der Wortlaut der Messmethode ist erfüllt, die **Eigenschaft** ist von diesem Beleg nicht gedeckt.

- Gemessen habe ich es selbst: `rel1` und `rel2` sind in allen sechs sha256 identisch.
- **Aber:** die mtimes stimmen **auf die Sekunde** überein — `16:52:10`, `:17`, `:25`, `:32`,
  `:39`, `:45`, je paarweise in `rel1` und `rel2`. `docker cp` überträgt die Dateizeit aus dem
  Image-Layer. Gleiche Sekunde in beiden Läufen heißt: **derselbe Layer**. Der zweite Lauf hat
  nichts übersetzt, er hat den Build-Cache getroffen und dieselben Bytes ein zweites Mal
  extrahiert. Byte-Gleichheit ist unter dieser Bedingung **tautologisch** und wäre auch bei einer
  völlig undeterministischen Toolchain eingetreten.
- Das ist genau die Beleg-Klasse, die `AGENTS.md` §3.6 meint: der Test misst die heutige
  Implementierung (Cache-Treffer), nicht die behauptete Eigenschaft (gleiche Version → gleiche
  Ausgabe).
- **Was real trägt:** die einzige unabhängige Doppel-Übersetzung in den Artefakten ist
  `bin1` (16:51:33, Default-Pfad) gegen `rel1/…-linux-amd64` (16:52:10, explizite Build-Args) —
  verschiedene Cache-Keys, verschiedene Layer, identischer sha256. Das ist ein echter
  Reproduzierbarkeits-Datenpunkt, aber **nur für linux/amd64**. Für die anderen fünf Plattformen
  existiert keine unabhängige zweite Übersetzung.
- Billige Schließung, mit Präzedenz im eigenen Repo: `make lint` und `make test` fahren bereits
  `--no-cache-filter` (`Makefile:49`, `:52`). Ein Lauf mit `--no-cache-filter build` gegen den
  ersten Lauf misst, was die DoD meint.

### 5. Release-Workflow — **BESTÄTIGT**

- **Tag-getrieben + `workflow_dispatch`:** `release.yml:25-29` (`push: tags: v*`,
  `workflow_dispatch`). Der Upload ist zusätzlich auf einen echten Tag gegatet
  (`:102` `if: startsWith(github.ref, 'refs/tags/')`) — ein Dispatch-Lauf baut und smoked, lädt
  nichts hoch. Die Zusage aus der Commit-Message hält der Code.
- **MR-014 Setzung 1 (nur `make`-Targets):** der einzige Bau-Schritt ist `:48`
  `make release-artifacts DEST=dist`. Es gibt keine zweite Build-Definition — Download/Upload und
  `gh release` sind Transport, kein Build. Die Abgrenzung ist im Kopf (`:11-13`) benannt.
- **MR-014 Setzung 4:** alle Actions per Commit-SHA gepinnt (checkout `fbc6f399…`,
  upload-artifact `ea165f8d…`, download-artifact `d3f86a10…`), alle sechs Runner mit **benannter**
  Version (kein `-latest`).
- **Setzung 3:** `ci-lint` prüft `.github/workflows/` per Glob (`Makefile:131`, actionlint über
  `/repo`), deckt die neue Datei automatisch; und `ci-lint` läuft **in** `make gates`, dessen
  Stempel ich oben gegen den Baum verifiziert habe — das Grün ist real, nicht zitiert.
- **`gh release upload` legt kein Release an** — der Fix in `067e928` (`:127-132`: `view` →
  `upload` oder `create`, Vorab-Tag mit `--prerelease`) ist an `gh release upload --help` belegt und
  behebt einen sicheren Fehlschlag auf dem einzigen Pfad ohne lokalen Sensor. Sachlich richtig; der
  Inline-`shellcheck disable` wurde korrekt wieder entfernt statt unterdrückt (AGENTS §3.2).
- **Nicht in `ci.yml`, aber trotzdem gate-gedeckt** (selbst geprüft, weil es sonst ein Loch wäre):
  `ci.yml:25-26` triggert auf `push:` **ohne** Branch-/Tag-Filter — ein Tag-Push fährt also
  zusätzlich `gates`/`smoke`/`full-smoke`/`mutate`. Ein Release kann nicht aus einem Baum
  entstehen, den die CI nie gesehen hat. Diese Kopplung ist allerdings **implizit** (siehe R-3).
- Restrisiko R-1: `harness/conventions.md` MR-014 und `AGENTS.md` §4 kennen die dritte
  Sensor-Klasse noch nicht.

### 6. Plattform-Smoke nach dem CR + Verortungs-Entscheidung — **TEILWEISE**

- **Strukturell geliefert:** `release.yml:60-96` Matrix über sechs Runner, `fail-fast: false`;
  geprüft wird nicht bloß Exit 0, sondern per Marker (`:95-96`
  `grep -qF -- 'ai-harness-init'` / `'add-lang'`) — LH-QA-01-Geist eingehalten. Ich habe die
  Marker gegen die Quelle geprüft: `cmd/ai-harness-init/main.go:34` (`usage`) enthält beide
  Zeichenketten, `:102-104` gibt Usage auf stdout mit **Exit 0** aus, gedeckt vom bestehenden
  `main_test.go:91`. Der Start-Smoke kann also grundsätzlich grün werden.
- **Verortung dokumentiert:** die vier Gründe stehen im Slice §2 (`slice-048…:49-57`) **und** im
  Workflow-Kopf (`release.yml:5-20`), inklusive des benannten Preises (Feedback erst beim Tag) und
  der Gegenmaßnahme (`workflow_dispatch`). Der Anspruch „mit vier Gründen dokumentiert" hält.
- **Warum trotzdem TEILWEISE:** dieser DoD-Punkt ist derjenige, der die frisch präzisierte
  `LH-QA-04`-Messmethode einlöst — und er hat **null Ausführungen**. Kein Start-Smoke ist je
  gelaufen; `ci-lint` belegt allein die Syntax. Die sechs `runs-on`-Werte sind, wie der
  Implementer offen deklariert, lokal nicht verifizierbar (`runs-on: ${{ matrix.runner }}`,
  `:78` — actionlint sieht dort keinen Label-Literal). Der Nachweis ist **gebaut**, aber noch
  **nicht erbracht**. Das ist ehrlich benannt (Slice §6), bleibt aber der Unterschied zwischen
  „geliefert" und „belegt".

### 7. `make gates` grün · `make mutate` grün mit rot gesehener Mutation **je neuem Wächter** — **TEILWEISE**

- **`make gates`: BESTÄTIGT, unabhängig.** Stempel == selbst berechneter Baum-Hash (oben),
  Tree clean, `record-gates` schreibt nur nach grünen Gates.
- **`make mutate`: der Lauf ist echt.** `mutate11.log` Schlusszeile `mutate: 77 ok, 0 Befund(e)`;
  `ls test/mutations/*.sh | wc -l` = **77** (die Zahl passt zum Bestand, nicht nur zur Behauptung).
  Die vier neuen Fälle je **rot gesehen**, `mutate11.log:79-82`:
  78 → „die Plattform-Liste deckt GENAU die Matrix des Lastenhefts rot", 79 → „.exe rot",
  80 → „der Default-Pfad reicht KEINE Zielplattform durch rot", 81 → „DEST ist Pflicht rot".
- **Die DoD-Formulierung ist damit nicht voll erfüllt.** `test/release-matrix.bats` bringt
  **sechs** neue Wächter, es gibt **vier** Mutationen. Zuordnung:

  | Wächter (`test/release-matrix.bats`) | rot gesehen durch |
  |---|---|
  | `:52` Plattform-Liste deckt GENAU die Matrix | 78 |
  | `:60` sechs Kombinationen | 78 (mit-gedeckt: 78 lässt drei übrig) |
  | `:66` Windows-Artefakte tragen `.exe` | 79 |
  | `:71` **die build-Stage nimmt eine Zielplattform entgegen** | **keine** |
  | `:80` Default-Pfad reicht KEINE durch | 80 |
  | `:101` `DEST` ist Pflicht | 81 |

- Der unbewachte Wächter ist ausgerechnet der, den die DoD als **„Cross-Compile-Verdrahtung"**
  beim Namen nennt. Ich habe das gegengeprüft: **keine einzige** Mutation im Repo trägt
  `# files: Dockerfile` (alle 78–81 mutieren `Makefile`); die vier Fälle, die überhaupt
  Dockerfile-Text anfassen (15, 18, 20, 57), mutieren `internal/gen/*.go`, also den **generierten**
  Dockerfile des Zielrepos, nicht den eigenen.
- **Warum das mehr als Formalismus ist:** fiele `GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH}` aus
  `Dockerfile:60`, liefe `make release-artifacts` weiter fehlerfrei durch und legte **sechs
  plattform-benannte Dateien** ab, die alle `linux/amd64` wären. Kein Sensor im Repo prüft das
  erzeugte Binary gegen seinen Namen (die Header-Prüfung oben war Handarbeit, kein Gate), und der
  Start-Smoke, der es fangen würde, läuft erst beim Tag. Das ist exakt die Klasse „Fehler, der
  erst beim Anwender sichtbar wird", die 78/79 begründen. Ein Fall
  `# files: Dockerfile` mit `sed -i 's|GOOS=${TARGET_OS} GOARCH=${TARGET_ARCH} ||'` schließt es.

### 8. `make full-smoke` unverändert grün — **BESTÄTIGT**

- `fullsmoke7.log` (17:30, also **nach** `dfca6c6` 17:17) trägt **11** `full-smoke: OK`-Zeilen
  (`:1850-1860`), darunter unverändert Bootstrap/doc-only/Nachweis-Kreis/Guard/Mono-Repo/C++/
  Arch-Achse/Arch-Gate/Idempotenz. Der Lauf endet auf einer OK-Zeile; kein Abbruch.
- Nuance ohne Folgen: nach `067e928` (17:35) lief `full-smoke` nicht erneut — dieser Commit fasst
  nur `release.yml` und das Slice-Dokument an, beides außerhalb jeder `full-smoke`-Fläche.
  `make gates` **ist** danach gelaufen (Stempel 17:36).

### 9. Closure-Notiz mit Steering-Loop-Lerneintrag — **NOCH OFFEN (erwartet)**

§7 des Slice ist leer, der Slice liegt in `in-progress/`. Regulär — Planner-Rolle nach diesem Urteil.

---

## Plan (§3-Tabelle) gegen Code

| Geplant | Ist | Urteil |
|---|---|---|
| `spec/lastenheft.md` update (CR), **vor** dem Code | `5c4930b`, nur diese Datei, vor `dfca6c6` | OK |
| `Dockerfile` update — Zielplattform-Build-Args, Default byte-identisch | `Dockerfile:57-60`; Byte-Identität nachgerechnet | OK |
| `Makefile` update — Matrix-Target, `artifact` bleibt unverändert | `Makefile:75-92`; der `artifact`-Block (`:62-66`) ist im Diff **nicht** enthalten | OK |
| `.github/workflows/release.yml` neu — tag-getrieben (+ `workflow_dispatch`), nur `make`-Targets, Upload **und** Start-Smoke-Matrix | genau so, 114 → 133 Zeilen | OK |
| `test/` + `test/mutations/` — Wächter je neuer Zusage, jeder mit rot färbender Mutation | 6 Wächter, 4 Mutationen | **Lücke**, s. DoD-7 |
| ~~`.github/workflows/ci.yml` update — Start-Smoke-Matrix~~ (Zeile **während** des Slice entfernt) | ersetzt durch die Verortung im `release.yml` | OK — **begründet dokumentiert**: die Zeile wurde in `4219db9` durch die vier-Gründe-Passage in §2 abgelöst, die Tabellenzeile zu `release.yml` entsprechend umgeschrieben. Änderung des Plans, nicht stilles Weglassen |
| **nicht geplant** | `docs/plan/planning/in-progress/roadmap.md`: der Kandidat „Freshness-Luecke schliessen" ist in `dfca6c6` zu „Vollstaendigkeits-Waechter fuer kuratierte Listen" umgeschrieben | **Abweichung (LOW)**: inhaltlich sinnvoll und thematisch verwandt (sie beschreibt genau die Lücke aus DoD-7), aber es ist **Planner-Arbeit in einem Implementer-Commit** und gehört nicht zu slice-048. Kein Laufzeit-Verhalten |

Nichts Geplantes fehlt. Kein ungeplantes Laufzeit-Verhalten.

**Risiken aus §6 — Stand:**

- *Messmethode ist die eigentliche Schwierigkeit:* korrekt vorweggenommen und im CR aufgelöst.
- *Windows-Runner haben Docker, aber für Windows-Container:* im Lastenheft und im Workflow-Kopf
  benannt; nicht angenommen, sondern als Grenze ausgewiesen.
- *Byte-Identität des Default-Pfads:* gehalten und real gemessen (DoD-2).
- *Release-Upload nicht lokal rot-sehbar:* unverändert wahr; durch `067e928` immerhin **probierbar**
  (Vorab-Tag/`--prerelease`) statt nur behauptet.
- *Signatur/Notarisierung out-of-scope:* unberührt.

---

## Restrisiken / Befunde

### R-1 (MEDIUM) — `MR-014` und `AGENTS.md` §4 kennen die dritte Sensor-Klasse nicht

Der Slice **argumentiert** durchgehend mit MR-014 Setzung 2 („tag-getrieben ist die dritte
Klasse"), aber die Konvention selbst sagt weiterhin das Gegenteil des Ist-Standes:

- `harness/conventions.md:588` „**Seit dem Split … ist diese Trennung strukturell (zwei
  Workflow-Dateien)**"
- `harness/conventions.md:609-612` „Der Workflow ist in **zwei Dateien** getrennt: `ci.yml` …
  `upstream-drift.yml` …" (abschließende Aufzählung, kein „u. a.")
- `harness/conventions.md:567` Geltungsbereich nennt nur `ci.yml`
- `AGENTS.md:131` „GitHub Actions fährt `make gates` + `make smoke` + `make mutate` pro Push/PR …;
  die Netz-Sensoren nur nächtlich" — die tag-getriebene Klasse fehlt

Es gibt jetzt **drei** Workflow-Dateien. Das ist dieselbe Doku-Overclaim-Klasse, die dieses Repo
am 2026-07-25 schon einmal gefangen hat (der Drift-Job „deckte jede versions-gepinnte Komponente"
ab, `2abda63`). Ein MR-014-Nachtrag (dritte Klasse, dritte Datei, `ci-lint` deckt sie per Glob mit)
schließt es; der Text dafür steht bereits fertig im Kopf von `release.yml`.

### R-2 (MEDIUM) — der Reproduzierbarkeits-Beleg misst den Docker-Cache, nicht die Toolchain

Siehe DoD-4. `rel1`/`rel2` tragen paarweise **dieselben mtimes auf die Sekunde**, stammen also aus
denselben Layern; der zweite Lauf hat nichts übersetzt. Der Beleg kann nicht zwischen
„reproduzierbar" und „gecacht" unterscheiden. Ein zweiter Lauf mit `--no-cache-filter build`
(Präzedenz: `Makefile:49`/`:52`) macht daraus eine echte Messung. Bis dahin ist `LH-QA-02` für
fünf der sechs Plattformen unbelegt.

### R-3 (LOW) — die Gate-Deckung eines Release hängt an einer impliziten Kopplung

Dass ein Tag-Push auch `ci.yml` auslöst, folgt allein daraus, dass `ci.yml:25` ein
filterloses `push:` trägt. `release.yml` hat keinerlei Abhängigkeit zu den Gates (GitHub kann das
zwischen Workflows auch nicht ausdrücken). Ergänzt jemand später `branches:` in `ci.yml` — eine
naheliegende Aufräum-Änderung —, entstehen Releases aus ungegateten Bäumen, **ohne dass irgendein
Sensor das meldet**. Mindestens ein Kommentar an `ci.yml:25`, der die Kopplung als beabsichtigt
festhält; besser ein `gates`-Job in `release.yml` vor `artifacts`.

### R-4 (LOW) — doppelter `# ---- build ---`-Banner: ergänzt statt umgeschrieben

`Dockerfile:42` und `:48` tragen denselben Abschnittskopf; dazwischen steht der **alte**
Kommentarblock, dessen erster Satz („Cross-Compile des Binaries im gepinnten Image") sich jetzt mit
dem neuen Block überschneidet, ohne die neuen Args zu kennen. Genau die slice-032-Lehre
(„wandernde Grenze **umschreiben** statt ergänzen") — hier nicht angewandt. Kein Verhaltensfehler,
aber der nächste Leser findet zwei Erklärungen derselben Stage.

### R-5 (LOW) — Historien-Zeile 0.13.0 steht vor 0.12.0

`spec/lastenheft.md:310` (0.13.0) liegt **über** `:311` (0.12.0); die Tabelle ist sonst
durchgehend aufsteigend (0.2.0 … 0.11.0). Reine Reihenfolge, aber die Versionshistorie ist das
Traceability-Artefakt des CR-Prozesses.

### R-6 (LOW) — die Tatsachenbasis der neuen Grenze ist im Lastenheft nicht belegbar

`spec/lastenheft.md:267-276` behauptet über die gehosteten Runner-Images: kein Container-Runtime
auf macOS, nur Windows-Container auf Windows. Das ist die **einzige** Begründung für die abgestufte
Messmethode — und sie steht ohne Quelle und ohne Datum. Nur die Commit-Message von `5c4930b` nennt
die Herkunft. Ein Dritter kann die Absenkungs-Begründung nicht nachprüfen, und wenn GitHub morgen
colima ausliefert, altert der Satz still. Ein Halbsatz („Stand 2026-07-25, `actions/runner-images`")
genügt und entspricht der Repo-Regel, auf autoritative Quellen zu zeigen statt sie zu kondensieren.

### R-7 (LOW) — die „in BEIDE Richtungen"-Zusage des Kopplungs-Wächters gilt nur in einer

`test/release-matrix.bats:30-46` kommentiert: „Faellt dort eine Plattform weg **oder kommt eine
hinzu** …, ist das ein Befund — in beide Richtungen." Real prüft `lh_platforms()` nur die
**Anwesenheit** der fest verdrahteten Tokens (`linux macos windows`, `amd64 arm64`) und gibt danach
eine **hartkodierte** Sechser-Liste aus (`:45`). Nimmt jemand `macos` aus der Anforderung, wird der
Test rot (fail-closed via `[ -n "$erwartet" ]`, `:55`) ✓. **Fügt** jemand eine siebte Plattform
hinzu, bleibt er grün ✗. Die Zusage im Kommentar ist um eine Richtung zu breit (AGENTS §3.6:
Zusagen im Kommentar zählen).

### R-8 (INFO) — zwei Wächter greifen dateiweit statt rezeptweit

`:66-69` (`grep -q 'ext=".exe"' "$MK"`) und `:71-75` (drei `grep -q` über den ganzen `Dockerfile`)
sind nicht auf das Rezept bzw. die Stage eingegrenzt — anders als `:80`/`:101`, die per
`sed -n '/^target:/,/^$/p'` sauber scoped sind. Ein auskommentiertes oder an anderer Stelle
stehengebliebenes Vorkommen hielte sie grün. Kein leerer Prüfbereich (`LH-QA-01`), aber weniger
Zähne, als der Testname verspricht.

### R-9 (INFO) — `ls -l dist` ist als Beleg deklariert, prüft aber nichts

`release.yml:49-51` heißt „Inventar zeigen (Beleg im Lauf-Log, **nicht nur Exit 0** geprueft)".
`ls -l` **loggt** sechs Dateien, es **behauptet** sie nicht. Ein `test "$(ls dist | wc -l)" -eq 6`
macht aus der Zeile das, was ihr Name sagt. (Ein Teil-Erzeugnis kann derzeit ohnehin nicht
entstehen, weil `set -e` im Recipe abbricht — der Punkt ist die Formulierung, nicht die Lücke.)

### R-10 (INFO) — die Start-Smoke-Marker sind an keinen lokalen Wächter gekoppelt

`release.yml:95-96` greift auf `ai-harness-init` und `add-lang` im `--help`-Text. Beide stehen in
`cmd/ai-harness-init/main.go:34-38`; nichts hält sie zusammen. Eine Umbenennung des Subkommandos
röte den Release-Lauf erst beim Tag. Fail-closed (schlimmstenfalls falsches Rot), darum nur INFO —
aber es ist dieselbe Kopplungs-Idee, die `release-matrix.bats` für das Makefile bereits umsetzt.

---

## Gesamturteil

**DoD im Kern BESTÄTIGT — mit zwei TEILWEISE-Punkten (4 und 7) und einem strukturell gelieferten,
aber noch nicht erbrachten Nachweis (6).**

Die Substanz ist da und hält der unabhängigen Nachmessung stand: die `build`-Stage nimmt die
Zielplattform entgegen und lässt den Default byte-identisch (zwei echte Übersetzungen, gleicher
sha256 — an den Layer-mtimes verifiziert, nicht am Sensor geglaubt); das Matrix-Target erzeugt
sechs korrekt benannte Binaries, deren **Ziel-OS und Ziel-Architektur ich aus den Header-Feldern
selbst gelesen** habe (Mach-O cputype, ELF e_machine, PE machine — je zwei verschiedene Werte);
`DEST` bleibt Pflicht; der Release-Workflow ist tag-getrieben, `workflow_dispatch`-fähig, SHA- und
runner-gepinnt und trägt **keine** zweite Build-Definition; `make gates` lief nachweislich auf
**genau diesem** Baum grün (Stempel == selbst berechneter Tree-Hash); `make mutate` steht bei
77 ok/0 mit vier neu rot gesehenen Fällen; `full-smoke` zeigt unverändert 11 OK-Zeilen. Der CR ist
sauber vorangestellt, fasst nur das Lastenheft an, senkt die **Anforderung** nachweislich nicht
(die Anforderungszeilen sind im Diff nicht enthalten) und benennt die Grenze so, dass ein Dritter
sie versteht.

Nicht bestätigt sind zwei Beleg-Fragen, beide aus derselben Familie — *deckt der Beleg, was er zu
decken vorgibt?*:

1. **Reproduzierbarkeit (DoD-4).** Die zwei Matrix-Läufe sind nicht zwei Übersetzungen, sondern
   eine Übersetzung und ein Cache-Treffer — bewiesen durch sekundengleiche mtimes in `rel1`/`rel2`.
   Byte-Gleichheit ist unter dieser Bedingung nicht falsifizierbar. Echte Evidenz existiert nur für
   `linux/amd64`.
2. **„Mutation je neuem Wächter" (DoD-7).** Sechs Wächter, vier Mutationen; unbewacht bleibt
   ausgerechnet `test/release-matrix.bats:71`, also die von der DoD namentlich genannte
   **Cross-Compile-Verdrahtung**. Keine Mutation im Repo fasst den eigenen `Dockerfile` an. Der
   Ausfall, den dieser Wächter fangen soll, wäre still: sechs plattform-benannte Dateien, alle
   `linux/amd64`, und kein anderer Sensor, der Namen gegen Kompilat hält.

Dazu kommt (DoD-6), dass der Plattform-Nachweis, der die frisch präzisierte `LH-QA-04`-Messmethode
einlöst, **gebaut, aber nie gelaufen** ist. Der Implementer deklariert das offen; es ist keine
Fehl-Behauptung, aber es ist der Unterschied zwischen geliefert und belegt.

**Vor der Closure zu erledigen:**

1. **DoD-7 / höchste Priorität:** Mutation `# files: Dockerfile` gegen `Dockerfile:60`
   (`GOOS`/`GOARCH` entfernen) anlegen und rot sehen — dann trägt die DoD-Formulierung.
2. **DoD-4 / R-2:** einen Matrix-Lauf mit `--no-cache-filter build` gegen den ersten halten, oder
   den Reproduzierbarkeits-Anspruch in Commit/Closure auf das ehrliche Maß zurücknehmen
   („zwei Läufe, davon einer aus dem Build-Cache; unabhängig belegt nur linux/amd64").
3. **R-1:** MR-014-Nachtrag „dritte Sensor-Klasse / dritte Workflow-Datei" +
   `AGENTS.md:131` — die Doku sagt heute „zwei Dateien", es sind drei.
4. **R-5, R-6, R-7:** Historien-Zeile umsortieren, Quelle+Datum an die Lastenheft-Grenze,
   den „in beide Richtungen"-Kommentar auf die Richtung kürzen, die der Test wirklich prüft.
5. **R-3, R-4, R-8, R-9, R-10** als Backlog-Notizen in die Closure-Notiz.
