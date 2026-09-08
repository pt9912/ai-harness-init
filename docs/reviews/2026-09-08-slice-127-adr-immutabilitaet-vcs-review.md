# Review-Report — slice-127: Hard Rule §3.4 bekommt ihren Sensor (`vcs`-Modul)

**Rolle:** Reviewer · **Datum:** 2026-09-08 · **Runde:** 1

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `6a2e0d5f..0a20eff6` — sieben Commits: `6a2e0d5f` (Planner,
  priorisiert), `34969a16`/`9e37ba86` (`git mv` `open/` → `next/` plus Nachzug), `44427bec`
  (die Umsetzung), `a847bfb8`/`fcd146b1` (`git mv` `next/` → `in-progress/` plus Nachzug),
  `0a20eff6` (Ruhe-Marker). Berührt: [`.d-check.yml`](../../.d-check.yml) (`vcs:`-Block, neu),
  `Makefile` (Ziel `adr-immutable`, neu), `.github/workflows/ci.yml` (Job `adr-immutable` plus
  Kopfkommentar), `.github/workflows/release.yml` und `.github/workflows/upstream-drift.yml`
  (Zähler nachgezogen), [`harness/README.md`](../../harness/README.md), neu
  `test/vcs-modul-wiring.bats` und `test/mutations/277`–`279`.
- **Betroffene `LH-*`:**
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Modul
  ohne Config-Block meldet 0 Befunde und prüft nichts; und ein Ziel, das kein Gate ist, wird
  keines behauptet) und
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Messungen des Slice
  müssen über dem gepinnten Digest wiederholbar sein).
- **Referenzierte aktive ADRs:**
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (`Accepted`,
  Festlegung 4 — die Entscheidung vor dem Move),
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  (`Accepted`, Ortsfestigkeit der Register-Ablage),
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  (`Accepted`, Beleg statt Lauf — im Auftrag als möglicher Adressat eines Vorbefunds genannt).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.1, §3.3, §3.4 (der Gegenstand), §3.5, §3.6,
  §3.7, §3.9, §3.11.
- **Aktive `MR-*`:** [`MR-001`](../../harness/conventions.md#mr-001),
  [`MR-007`](../../harness/conventions.md#mr-007) (Setzung 3, *blind und grün*),
  [`MR-010`](../../harness/conventions.md#mr-010),
  [`MR-025`](../../harness/conventions.md#mr-025).
- **Vorherige Findings am gleichen Modul:** der Review zu `slice-201` vom 2026-09-08
  (3 HIGH / 5 MEDIUM / 2 LOW / 2 INFO), dessen LOW-2 (*„Zwei Commits lang stand `planning-drift`
  auf dem Hauptzweig"*) hier als MEDIUM-4 wiederkehrt — im Vorlauf war dieselbe Klasse INFO-1 des
  Reviews zu `slice-197` vom selben Tag. Dazu der Review zu `slice-123` vom 2026-09-06, der den
  Vorlauf-Wächter abnahm, den dieses Ziel jetzt als Prerequisite führt.
- **Slice-Plan (Repo-Ergänzung):** `slice-127`, gelesen in `in-progress/`.

**Zustand des Baums vor dem Lauf:** `git status --porcelain` leer. **`HEAD` war beim Start
`0a20eff6`** und ist es beim Schreiben dieses Reports **nicht mehr** — s. INFO-2.

**Instrumente dieses Laufs.** Docker-only ([`AGENTS.md`](../../AGENTS.md) §3.9): der in
`d-check.mk` gepinnte Digest `sha256:e31a372b…` (Tag `v0.74.1`) über
`git clone --local --no-hardlinks`-Kopien außerhalb des Arbeitsbaums, alle mit `--network none`,
alle Läufe über das Ziel `make doc-immutable` bzw. `make adr-immutable` des jeweiligen Klons. Der
Arbeitsbaum ist dabei nicht angefasst worden.

**Die fünf Proben des Slice sind nachgefahren, bevor geurteilt wurde.** Klon auf `0a20eff6`,
`BASE=0a20eff6`, je ein Commit, dann `make doc-immutable RANGE=$BASE..HEAD`:

| Probe | Ergebnis |
|---|---|
| ein Satz in `## Entscheidung` von `docs/plan/adr/0003-go-native-binaries.md` | `987 Datei(en) geprüft, 1 Befund(e)` · `core-drift-vcs` · *Core einer immutablen Datei hat sich über die Commit-Range geändert* |
| **derselbe Satz** in `## Geschichte` derselben Datei | `987 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| Supersede-Übergang auf `**Status:** Superseded by [ADR-0040](0040-x.md)` | `0 Befund(e)`, Exit 0 |
| derselbe Übergang, `head-allow` per `test/mutations/277-…` auf die bare Werkzeug-Form | `1 Befund(e)` · `core-drift-vcs` · *unzulässiger Status-Übergang einer immutablen Datei* |
| `make adr-immutable RANGE=HEAD..HEAD` | `history-range-guard: Range 'HEAD..HEAD' ist aufloesbar, aber LEER (0 Commits).`, Exit 2 — während `make doc-immutable RANGE=HEAD..HEAD` **allein** `0 Befund(e)`, Exit 0 meldet |

**Alle fünf tragen.** Das Paar aus Probe 1 und 2 belegt, was allein keine von beiden belegt: das
Modul trennt Kern von Chronik. Probe 5 belegt, dass die Kettung den fail-open-Fall wirklich
schließt und nicht nur behauptet, ihn zu schließen. Die Beanstandungen unten betreffen die
**Breite** der Konfiguration und die Abdeckung ihres Wächters, nicht die Kernaussage des Slice.

**Die drei Mutations-Fälle sind einzeln gefahren**, je in einer eigenen Kopie
(`git clone --local --no-hardlinks`, dann `bash test/mutations/<fall>.sh`, dann `make test-bats`):

| Fall | `make`-Exit | rot gewordener Wächter |
|---|---|---|
| `277-vcs-head-allow-bare-kennung.sh` | 2 | `not ok 236 vcs: head-allow traegt die gelebte Link-Form, nicht die bare Werkzeug-Vorgabe` |
| `278-vcs-exclude-sections-ohne-geschichte.sh` | 2 | `not ok 235 vcs: exclude-sections nimmt Geschichte aus dem Kern` |
| `279-vcs-in-modules-aktiviert.sh` | 2 | `not ok 232 vcs ist NICHT in modules: aktiviert (braucht eine Range, LH-QA-01)` |

Jeder trifft **genau** den Wächter seiner `# expect:`-Zeile und keinen zweiten; die Kontrolle
(`make test-bats` ohne Mutation) ist Exit 0 mit `ok 232`–`ok 237`. Kein Fall misst sich selbst.

---

## Findings

### HIGH-1 — Die Status-Zeile einer angenommenen ADR lässt sich überschreiben, und der Sensor bleibt grün

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 (*„ADRs sind nach Accepted immutable"* —
  Korrekturen entstehen als neue ADR mit Supersedes, **nicht durch Überschreiben**);
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `.d-check.yml`, Zeile `head-allow:` des `vcs:`-Blocks
- `befund`: `head-allow` trägt keinen End-Anker. Der Ausdruck
  `'^\*\*Status:\*\* (Accepted|Superseded by \[ADR-[0-9]{4}\])'` ist ein **Präfix**-Muster; jeder
  Text hinter `Accepted` fällt darunter. Damit ist genau die Zeile, um die §3.4 geht, die am
  schwächsten geschützte Zeile der Datei. Gemessen im Wegwerf-Klon, ein Commit, `BASE=0a20eff6`:

  ```sh
  sed -i '3s|.*|**Status:** Accepted (ueberholt, gilt nicht mehr — siehe ADR-0041)|' \
    docs/plan/adr/0003-go-native-binaries.md
  git commit -aqm "Status-Zeile einer Accepted-ADR ueberschrieben"
  make doc-immutable RANGE=0a20eff6..HEAD     # 987 Datei(en) geprüft, 0 Befund(e), EXIT 0
  ```

  Die Kontrolle trennt die Ursache sauber ab: **derselbe** Zusatz an einer beliebigen Zeile im
  Kern (`sed -i '31s|$| (ueberholt, gilt nicht mehr)|'`) meldet `1 Befund(e)`, `core-drift-vcs`.
  Nicht der Zusatz ist erlaubt, sondern seine **Lage** in der Status-Zeile. Das Versagen ist
  konkret: eine angenommene ADR wird durch Überschreiben ihrer Status-Zeile faktisch außer Kraft
  gesetzt — der Vorgang, den §3.4 verbietet und für den sie den Supersede-Weg vorschreibt —, und
  der Job, der dafür gebaut wurde, bleibt grün. Verschärfend: `test/vcs-modul-wiring.bats` pinnt
  den Ausdruck als Literal und `test/mutations/277-…` hält den Pin scharf, die Breite ist damit
  **gegen Änderung gesichert**.
- `verifizierbar`: ja — die zwei Kommandos oben über dem gepinnten Digest; `make gates` sieht den
  Befund **nicht** (`vcs` steht bewusst nicht in `modules:`), gesehen wird er allein vom Ziel
  `make adr-immutable` bzw. vom CI-Job gleichen Namens.
- `klasse`: stilles Grün auf der Zeile, um die die Regel geht

### MEDIUM-1 — `head-allow` blockt zwei der vier Status-Werte, die der ADR-Index als Vokabular führt

- `kategorie`: MEDIUM
- `quelle`: [`docs/plan/adr/README.md`](../plan/adr/README.md) §*`Status` spiegelt das Kopffeld*
  (*„ein Zustand aus dem Vokabular der Vorlage (`Proposed` · `Accepted` · `Deprecated` ·
  `Superseded by ADR-NNNN`), kein Satz"*); die vendored ADR-Vorlage
  `.harness/baseline/v6.5.0/templates/docs/plan/adr/NNNN-titel.template.md` Zeile 11, die dieselbe
  Aufzählung trägt
- `pfad`: `.d-check.yml`, Zeile `head-allow:` des `vcs:`-Blocks
- `befund`: Der Wert ist gegen den **Bestand** gesetzt (zwei superseded ADRs in Link-Form) und
  nicht gegen das **deklarierte Vokabular**. Über alle vier Ausgänge aus `Accepted` gemessen, je
  ein Commit im Klon, `make doc-immutable RANGE=0a20eff6..HEAD`:

  | Status-Zeile im Head-Stand | Ergebnis |
  |---|---|
  | `**Status:** Superseded by [ADR-0040](0040-x.md)` — gelebter Bestand | `0 Befund(e)` |
  | `**Status:** Superseded by ADR-0040` — Form der Vorlage und der Index-Aufzählung | **`1 Befund(e)`** · *unzulässiger Status-Übergang* |
  | `**Status:** Deprecated` — deklariertes Vokabular | **`1 Befund(e)`** · *unzulässiger Status-Übergang* |
  | `**Status:** Accepted (…)` — freier Zusatz | `0 Befund(e)` (das ist HIGH-1) |

  `Deprecated` wird in Slice-Plan, Commit-Message und
  [`harness/README.md`](../../harness/README.md) an keiner Stelle erwähnt; die Klasse ist nicht
  entschieden, sondern übersehen. Das Versagen: die erste ADR, die den in der Vorlage
  vorgeschriebenen Übergang nimmt, färbt den CI-Job rot — dieselbe Fehlform, die der Slice für
  die Supersede-Zeile ausdrücklich abstellt, an zwei anderen Werten desselben Feldes.
  Die Fehlrichtung ist fail-closed (falsches Rot, kein stilles Grün) — deshalb MEDIUM und nicht
  HIGH.
- `verifizierbar`: ja — die vier Zeilen der Tabelle, je ein Commit im Klon; heute schlägt keine
  an, weil kein ADR den Übergang bisher genommen hat
  (`grep -h -m1 '^\*\*Status:\*\*' docs/plan/adr/[0-9]*.md | sort | uniq -c` → 33 `Accepted`,
  5 `Proposed`, je 1 der zwei Supersede-Zeilen in Link-Form; keine Erwartungswerte).
- `klasse`: Muster gegen den Bestand gesetzt statt gegen das deklarierte Vokabular

### MEDIUM-2 — Der Wächter hält vier der fünf Schlüssel; der fünfte ist der, an dem DoD (2) hängt

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel);
  der Kopf von `test/vcs-modul-wiring.bats` (*„Dieser Waechter haelt nur die KONFIGURATION gegen
  Regression"*) und [`harness/README.md`](../../harness/README.md) (*„`test/vcs-modul-wiring.bats`
  hält beide Felder gegen Regression"*)
- `pfad`: `test/vcs-modul-wiring.bats` gegen den `vcs:`-Block in `.d-check.yml`
- `befund`: Der Block führt fünf Schlüssel, der Wächter pinnt vier — `status-line` ist der eine
  ohne Fall:

  ```sh
  awk '/^vcs:[[:space:]]*$/{i=1;next} i&&/^[^[:space:]]/{i=0} i' .d-check.yml \
    | grep -oE '^  [a-z-]+:'                        # paths immutable-when exclude-sections status-line head-allow
  for k in paths immutable-when exclude-sections status-line head-allow; do
    grep -q "  $k:" test/vcs-modul-wiring.bats || echo "ungepinnt: $k"; done   # status-line
  ```

  Er ist nicht der harmloseste der fünf, sondern der, auf dem DoD (2) ruht. Gemessen im Klon,
  eine Zeile entfernt (`sed -i "/^  status-line: /d" .d-check.yml`): der **erlaubte**
  Supersede-Übergang auf die Link-Form kippt von `0 Befund(e)` auf `1 Befund(e)`
  (`core-drift-vcs`, *Core einer immutablen Datei hat sich über die Commit-Range geändert*) —
  ohne `status-line` zählt die Status-Zeile in den Kern, und `head-allow` hat nichts mehr, worauf
  es angewandt würde. **Alle sechs Wächter bleiben dabei grün** (`ok 232` bis `ok 237`). Das
  Versagen: die Zusage der zwei Köpfe („hält die Konfiguration gegen Regression") deckt genau den
  Schlüssel nicht, dessen Verlust die Zusage des Slice aufhebt.
- `verifizierbar`: ja — die zwei Kommandos oben plus `make test-bats` in derselben Kopie.
- `klasse`: Zusage nennt Sensor, der die Form nicht sieht

### MEDIUM-3 — Der Plan verspricht eine Entscheidung über `## Geschichte`, geliefert ist eine offene Frage

- `kategorie`: MEDIUM
- `quelle`: Slice-Plan `slice-127` §1 (*„Was dort stehen darf, ohne die Immutabilität zu
  verletzen, **entscheidet dieser Slice mit**"*) und §6 (*„Welche der beiden Fehlformen dieses
  Repo lieber trägt, gehört aufgeschrieben — der Sensor entscheidet es sonst stillschweigend"*)
- `pfad`: [`harness/README.md`](../../harness/README.md), Absatz *Drei Grenzen bleiben offen*
- `befund`: Geliefert ist der Satz *„was innerhalb von `## Geschichte` stehen darf, ohne die
  Immutabilität faktisch zu unterlaufen, bleibt eine offene Frage der gelebten Praxis, keine des
  Sensors"* — also die Feststellung, dass nicht entschieden wurde, an der Stelle, an der der Plan
  eine Entscheidung vorsah. Der Umfang der unbewachten Fläche ist dabei nicht klein und wächst mit
  jeder Fortschreibung:

  ```sh
  t=0; g=0; for f in docs/plan/adr/[0-9]*.md; do
    t=$((t+$(wc -c < "$f"))); g=$((g+$(awk '/^## Geschichte/{i=1} i' "$f" | wc -c))); done
  awk -v a=$g -v b=$t 'BEGIN{printf "%d von %d Bytes = %.1f%%\n", a, b, 100*a/b}'   # 8.0 %
  ```

  je Datei bis **28,1 %** (`0012-haupt-kontext-ohne-token-bilanz.md`, dieselbe Rechnung je Datei;
  keine Erwartungswerte). Das Versagen ist noch nicht eingetreten und ist benennbar: heute steht
  keine normative Aussage in einem `## Geschichte`-Abschnitt — die drei Teil-Supersede-Anordnungen
  liegen im geschützten Kern (`git grep -n 'Revidiert (Teil-Supersede)' -- 'docs/plan/adr/0*.md'`
  gegen die Zeilennummer von `^## Geschichte` derselben Datei) —, aber nichts hindert die nächste
  daran, dort zu landen, und dort ist sie beliebig änderbar (Probe 2 oben).
- `verifizierbar`: nein — kein Gate hält einen Plan gegen seine Umsetzung; der Träger ist genau
  dieses Review.
- `klasse`: Plan-Zusage wird in der Umsetzung zur benannten offenen Frage

### MEDIUM-4 — Der Anspruch kam nach der Arbeit, und kein Sensor kann das sehen

- `kategorie`: MEDIUM (im Vorlauf INFO, dann LOW; dritte Wiederholung in Folge —
  Kontext-Eskalation)
- `quelle`: Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine
  (*„`next → in-progress` landet auf dem Hauptzweig, **vor der Arbeit**"* — der Übergangs-Commit
  macht den Anspruch sichtbar, **bevor** jemand anderes dieselbe Arbeit beginnt)
- `pfad`: Commits `44427bec` (Arbeit, 12:01:28) vor `a847bfb8` (Anspruch, 12:01:35)
- `befund`: Der Lauf berichtet den Verstoß selbst. Was daraus **über** eine Register-Zeile hinaus
  folgt, ist gemessen: `docs-check` über frische Klone jedes der sieben Commits (derselbe gepinnte
  Digest) —

  | Commit | `docs-check` |
  |---|---|
  | `6a2e0d5f` | 987/0 |
  | `34969a16` | **13 Befunde** (bekannte Zwei-Commit-Form des `slice-mv`, §3.3) |
  | `9e37ba86` | 987/0 |
  | `44427bec` — **die Arbeit** | **987/0** |
  | `a847bfb8` | **14 Befunde**, darunter `planning-drift` |
  | `fcd146b1` | **1 Befund** — `planning-drift` |
  | `0a20eff6` | 987/0 |

  Zwei Aussagen stecken darin. Erstens: `44427bec` ist **grün**, obwohl dort die vollständige
  Arbeit eines Slice auf dem Hauptzweig liegt, `in-progress/` leer ist und die Roadmap
  *„Nichts in Arbeit."* trägt. Das Modul `planning` hält den Ruhe-Marker gegen das Verzeichnis —
  beide waren konsistent —, es hält **nicht** Arbeit gegen Anspruch. Der Verstoß ist damit für
  jeden Sensor dieses Repos unsichtbar, nicht nur unbewacht: er hinterlässt am Ort der Arbeit
  keine Spur, an der ein Wächter ansetzen könnte. Zweitens: `planning-drift` stand über **zwei**
  Commits auf dem Hauptzweig — wörtlich derselbe Verlauf, den der Review zu `slice-201` als LOW-2
  gemessen hat, und der Review zu `slice-197` davor als INFO-1. Die Register-Klasse
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  steht bei `ls …/evidence/*.md | wc -l` → **5** und auf `Stand: offen`, also seit mehreren
  Closures über der Schwelle ohne Ausgang.
- `verifizierbar`: ja für die zweite Hälfte (`make docs-check` über einem Klon auf `a847bfb8`
  bzw. `fcd146b1`); **nein** für die erste — dass `44427bec` grün ist, ist gerade der Befund.
- `klasse`: Lifecycle-Move macht ein bewachtes Zustandsfeld falsch

### MEDIUM-5 — Der Verweis-Nachzug schrieb zweimal in ein eingefrorenes Artefakt, ohne die vorgeschriebene Vorab-Entscheidung

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.11 (*„Und der Ortswechsel wird entschieden, bevor er
  vollzogen wird … Findet er einen, gehört die Entscheidung **vor** den Move"*);
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
- `pfad`: Commits `9e37ba86` und `fcd146b1`, je
  `docs/plan/planning/done/slice-123-ci-sieht-die-historie.md`
- `befund`: Beide Nachzugs-Commits ändern die Bytes eines abgeschlossenen Slice-Plans — vier
  Zeilen je Commit, `](../next/slice-127-…)` → `](../in-progress/slice-127-…)`. §3.11 verlangt vor
  dem Move die Messung über beide Adress-Formen und, wenn ein eingefrorenes Artefakt das bewegte
  als Pfad nennt, die **Entscheidung vor dem Move**; einer wurde gefunden, und kein Artefakt des
  Vorgangs hält eine solche Messung oder Entscheidung fest. Die Klasse steht als
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  bei `ls …/evidence/*.md | wc -l` → **4** und auf `Stand: offen`. Nicht HIGH, und der Grund ist
  benennbar: das Schreiben selbst ist die **dokumentierte** Zusage von `make slice-mv`
  ([`harness/README.md`](../../harness/README.md): *„`docs/plan/planning/done/**` und
  `docs/reviews/**` sind **nicht** ausgenommen"*), der Lauf hat es also nicht erfunden, und die
  Register-Zeile weist die Auflösung ausdrücklich dem Architect zu. Beanstandet ist die auf den
  Lauf entfallende Hälfte — die Vorab-Entscheidung —, nicht das Werkzeug.
- `verifizierbar`: nein — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml) hält
  den Status eines Artefakts gegen die Form seiner Adressen, und die Reihenfolge zweier Commits
  liest keines; §3.11 stellt diese Lücke für sich selbst fest.
- `klasse`: Verweis-Nachzug schreibt in ein eingefrorenes Artefakt

---

### LOW-1 — Eine der drei „offenen Grenzen" ist mit einem Kommando beantwortbar, und die Antwort ist nicht neutral

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.1 (ein Gate wird nicht schwächer beschrieben, als es
  ist); Slice-Plan `slice-127` §6 (*„Ob das Modul das trennt, ist **nicht gemessen**"*)
- `pfad`: [`harness/README.md`](../../harness/README.md), Absatz *Drei Grenzen bleiben offen*
- `befund`: Die Datei führt als erste Grenze *„ob das Modul einen reinen `git mv` einer ADR-Datei
  (Hard Rule 3.3) von einer Kern-Änderung trennt, ist nicht gemessen"*. Ein Lauf beantwortet es:

  ```sh
  git mv docs/plan/adr/0003-go-native-binaries.md docs/plan/adr/0003-umbenannt.md
  git commit -qm "reiner git mv einer Accepted-ADR"
  make doc-immutable RANGE=0a20eff6..HEAD
  # docs/plan/adr/0003-go-native-binaries.md:1  core-drift-vcs
  #   immutable Datei geloescht oder umbenannt — der Pfad einer immutablen Datei ist stabil
  ```

  Das Modul trennt **nicht**, und zwar ausdrücklich: es zählt die Pfad-Stabilität zur
  Immutabilität und meldet mit eigenem Grund-Text. Dasselbe gilt für die Löschung. Die
  Konsequenz ist operativ (ein reiner `git mv` einer angenommenen ADR färbt den CI-Job rot) und
  steht heute als Unwissen im meistgelesenen Einstiegs-Dokument.
- `verifizierbar`: ja — die drei Kommandos oben in einem Klon.
- `klasse`: benannte Grenze, die ein Kommando auflöst

### LOW-2 — Drei der sechs neuen Wächter tragen keinen `test/mutations/`-Fall, darunter beide mit stiller Fehlform

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„gelistet heißt: wer keinen Fall in
  `test/mutations/` hat, ist unbewacht"*); Slice-Plan `slice-127` §6 (*„Ein Muster, das die
  Kopfzeile nicht trifft, macht das Modul **still**"*)
- `pfad`: `test/vcs-modul-wiring.bats` gegen `test/mutations/277`–`279`
- `befund`: Sechs `@test`, drei Fälle. Ohne Fall bleiben *„vcs: schuetzt genau die
  ADR-Datei-Klasse"* (`paths`), *„vcs: immutable-when trifft die Accepted-Kopfzeile"* und
  *„vcs: genau eine head-allow-Zeile"*. Die ersten zwei sind genau die Felder, deren Fehlform der
  Plan als **still** benennt: ein `paths`, das die Klasse verfehlt, und ein `immutable-when`, das
  die Kopfzeile verfehlt, machen das Modul grün über einer Menge, die es nicht prüft — die
  laute Fehlform (`head-allow`, `exclude-sections`) hat einen Fall, die stille nicht. Auf der
  Datei-Ebene ist die Klasse
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  **nicht** getroffen — drei Fälle nennen die Datei; getroffen ist die Test-Ebene darunter.
- `verifizierbar`: nein — `make mutate` urteilt über seinen Fall-Satz, nicht über dessen
  Vollständigkeit; Träger ist dieses Review.
- `klasse`: stille Fehlform ohne Mutations-Fall

### LOW-3 — Der Makefile-Kommentar verspricht hinter „NICHT in gates:" einen Grund und liefert einen Aufrufer

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (ein Kommentar trägt eine der fünf Klassen und
  schreibt an den, der die Stelle ändert)
- `pfad`: `Makefile`, Kopfkommentar über `history-range-guard`
- `befund`: Die Stelle lautet jetzt *„NICHT in gates: der Aufrufer in `.github/workflows/ci.yml`
  (Job `adr-immutable`) ruft dieses Ziel vor `make doc-immutable`"*. Der Doppelpunkt kündigt eine
  Begründung an, es folgt eine Kopplungs-Aussage; der eigentliche Grund (die Range variiert pro
  Lauf, also kein hermetischer Prüfbereich) steht acht Zeilen tiefer beim neuen Ziel. Vorher trug
  die Stelle einen tragenden Grund (*„kein hiesiger CI-Job ruft heute …"*), der mit diesem Slice
  entfallen musste; ersetzt wurde er nicht.
- `verifizierbar`: nein — `make comment-claims` führt den `Makefile` dauerhaft außerhalb seines
  Prüfbereichs ([`harness/README.md`](../../harness/README.md), Punkt 2 der drei Verengungen).
- `klasse`: Kommentar kündigt eine Klasse an und trägt eine andere

---

### INFO-1 — Der Vorbefund an `test/mutations/221` gehört `slice-197`, nicht `ADR-0035`, und er ist der einzige seiner Art

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6;
  [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
- `pfad`: `test/mutations/221-ignore-refs-restbreite.sh`, Zeile `# expect:`
- `befund`: Drei Teil-Aussagen, alle gemessen.

  **(a) Die Zuordnung zu `slice-197` trägt.** Die `# expect:`-Zeile nennt
  *„…deckt hoechstens einen Markdown-Link ihrer Quelldatei"*; der Wächter heißt heute
  *„…deckt genau die an ihr deklarierte Anzahl Markdown-Links"*.
  `git log --oneline -S '<alter Titel>' -- test/` nennt `29f91b52` (Anlage) und `e3905ccd`,
  `git log --oneline -S '<neuer Titel>' -- test/` nur `e3905ccd` — derselbe Commit entfernt den
  einen und setzt den anderen, die Fall-Datei reiste nicht mit.

  **(b) `ADR-0035` hat nichts verdeckt.** Die Bezugsmenge des Beleg-Schlüssels ist
  `isolation_key_files`, also der Baum ohne `./.harness/state` (`ISOLATION_EXCLUDES`) und ohne
  `./.git` (`ISOLATION_KEY_EXEMPT`) — nachgebaut:
  `tar -cf - --exclude=./.harness/state --exclude=./.git . | tar -tf - | … | sort -u | wc -l` →
  **1472** Einträge, davon **290** unter `test/`, darunter `test/ignore-refs-restbreite.bats`
  (keine Erwartungswerte). `e3905ccd` änderte genau diese Datei und entwertete den Beleg damit
  selbst. Dazu kommt: ein Beleg entsteht nur nach einem **vollständig grünen** Lauf
  (`finalize_belief`), ein roter schreibt keinen. Der Mechanismus kann einen roten Fall darum
  strukturell nicht überspringen. Der Grund, warum es erst jetzt auffiel, liegt nicht am Beleg,
  sondern daran, dass zwischen `e3905ccd` und heute — **42** Commits, alle vom selben Tag,
  `git rev-list --count e3905ccd..HEAD` — kein `make mutate` gefahren wurde oder sein Rot nicht
  aufgegriffen wurde. Ein CI-Lauf hätte ihn gesehen: der Job klont frisch, ohne `.harness/state/`,
  also ohne jeden Beleg.

  **(c) Es ist die einzige stale Zeile.** Über alle **265** Fall-Dateien geprüft, ob die
  `# expect:`-Zeile Teilstring einer Fehlschlag-Zeile ihres Sensors sein kann — Bedingung 4 des
  Treibers (`grep -E "$form" | grep -qF "$expect"`): für `# verify: test-bats`/leer gegen die
  `@test`-Titel (mit aufgelöstem `\$`), für `Test[A-Z]*` gegen die Go-Funktionsnamen, für
  `smoke`/`full-smoke` gegen den Text der jeweiligen Sensor-Skripte. Alles außer `221` löst auf;
  die vier Fälle um `$(HOST_BIN)` und `189` (`AUSGANG LEITUNG`, emittiert in
  `harness/tools/full-smoke-ausgang.sh` auf einer Zeile, die `full-smoke: FEHLER` trägt) sind
  Fehlalarme der ersten, zu strengen Prüfform.

  **(d) Der Wächter selbst hat seine Zähne behalten.** Fall `221` einzeln in einer Kopie gefahren:
  `make test-bats` Exit 2, `not ok 127 … deckt genau die an ihr deklarierte Anzahl
  Markdown-Links`. Die Mutation färbt ihren Wächter rot; nur die Buchhaltung des Kopfes zeigt
  daneben. Der Treiber meldet das fail-closed als *„falscher Grund"* statt still durchzuwinken —
  das ist der Mechanismus, der funktioniert, nicht der, der versagt. Kein Befund gegen dieses
  Repo-Design; ein Befund gegen die Nacharbeit von `slice-197`, den dessen Review, Verifikation
  und Closure nicht fanden.
- `verifizierbar`: ja — `make mutate` (Nicht-Gate-Verify), heute mit einem Befund; die vier
  Teil-Messungen oben je einzeln.
- `klasse`: Mutations-Fall überlebt die Umbenennung seines Wächters

### INFO-2 — Der Baum hat sich während dieses Reviews bewegt

- `kategorie`: INFO
- `quelle`: der Auftrag dieses Laufs (*„`HEAD` = `0a20eff6`, Baum sauber — prüf beides selbst"*)
- `pfad`: `0eb06110`, `.claude/settings.json`
- `befund`: Beim Start dieses Laufs war `HEAD` `0a20eff6`. Beim Schreiben dieses Reports ist es
  `0eb06110` — *„.claude/settings.json: `git reset --hard` fragt nicht mehr nach"*, ein Commit von
  13:04 desselben Tages, der die `ask`-Regel `Bash(git reset --hard *)` entfernt. Er trägt keinen
  `Rolle …:`-Präfix, nennt seine eigenen Kosten (*„Was damit fällt: der Schutz vor dem Verwerfen
  uncommitteter Arbeit"*) und weist sich als Entscheidung des Auftraggebers aus. Er gehört **nicht**
  zu `slice-127` und ist in keinem der vier Commits des Auftrags enthalten. Für dieses Review folgt
  daraus nichts an den Befunden: alle Messungen oben sind gegen `0a20eff6` gefahren, und
  `0eb06110` berührt keine Datei, die dieser Slice anfasst (`git show --name-only 0eb06110` nennt
  nur `.claude/settings.json`). Festgehalten wird es, weil die Prämisse des Auftrags — ein
  stillstehender Baum — beim Abschluss nicht mehr gilt und ein Nachfolger sonst gegen einen
  anderen Stand misst als dieser Lauf.
- `verifizierbar`: ja — `git log --format='%h %cd %s' --date=iso -1 0eb06110`.
- `klasse`: Prüfgegenstand bewegt sich während der Prüfung

---

## Negativbefunde (geprüft, ohne Befund)

- **`make gates` nach diesem Lauf: EXIT 0.** `baseline-verify: v6.5.0 OK — 54 Dateien`,
  `d-check: 987 Datei(en) geprüft, 0 Befund(e)`, `comment-claims: 57 Datei(en) geprueft,
  0 Befund(e)`, `span-check` grün. `git status --porcelain` danach leer.
- **Die Zählung der Checkouts trägt.** Der Kopfkommentar behauptet *„vier der fuenf"* in `ci.yml`
  und *„repo-weit acht Checkouts, genau einer mit `fetch-depth: 0`"*. Gemessen:
  `grep -rc 'uses: actions/checkout' .github/workflows/` → 5 + 2 + 1 = **8**;
  `grep -rn 'fetch-depth: 0' .github/workflows/` trifft genau eine Deklarationsstelle
  (`ci.yml:104`, Job `adr-immutable`); `ci.yml` führt fünf Jobs (`gates`, `smoke`, `full-smoke`,
  `mutate`, `adr-immutable`). Beide Geschwister-Workflows sind auf denselben Zähler nachgezogen,
  ohne Verhalten zu ändern.
- **Keine stehengebliebene Gegenaussage.** Der Satz *„Heute steht der Wächter bereit, ohne einen
  Aufrufer zu haben"* und die Zahl *„sieben Checkouts"* sind repo-weit entfernt
  (`grep -rn 'ohne einen Aufrufer\|sieben Checkouts' --include=*.md --include=*.yml .` außerhalb
  von `.harness/baseline/`, `docs/reviews/` und `done/` — leer).
- **`vcs` steht nicht in `modules:`.** Damit läuft es in keinem hermetischen `docs-check`-Lauf
  ins Leere; die Entscheidung ist in `.d-check.yml`, im `Makefile`, in
  [`harness/README.md`](../../harness/README.md) und in einem eigenen Wächter samt Mutation
  (`279`) getragen —
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  eingehalten.
- **`adr-immutable` wird nirgends als Gate behauptet.** Weder in der Sensor-Tabelle von
  [`harness/README.md`](../../harness/README.md) noch in [`AGENTS.md`](../../AGENTS.md) §4 —
  dieselbe Behandlung wie `history-range-guard`, `slice-mv`, `archive-welle` und
  `vendor-baseline`.
- **`exclude-sections` nimmt nur aus, was einheitlich vorhanden ist.** Alle **40** ADRs
  (`ls docs/plan/adr/[0-9]*.md | wc -l`) führen `## Geschichte` als letzte `##`-Überschrift
  (`for f in …; do grep -E '^## ' "$f" | tail -1; done | sort | uniq -c` → eine Zeile mit
  Zähler 40; keine Erwartungswerte). Die Aussage, dass die zwei zusätzlichen `matrix`-Einträge
  nicht gebraucht werden, trägt: `grep -lE '^#+ (7\. )?Historie' docs/plan/adr/[0-9]*.md` liefert
  keine Datei.
- **Die Bestandszahlen der Commit-Message stimmen.** 40 ADRs, 33 `Accepted` / 5 `Proposed` /
  2 `Superseded` — beide Kommandos stehen in der Message und geben aus, was sie behaupten.
- **`Proposed` → `Accepted` bleibt grün.** Der häufigste legitime Übergang ist gemessen
  (`0 Befund(e)`): `immutable-when` bindet auf den **Base**-Stand, eine `Proposed`-ADR ist damit
  nicht geschützt und ihre Annahme kein Befund. Ohne diese Eigenschaft wäre der Job bei jeder
  ADR-Annahme rot.
- **Der leere `RANGE=` ist fail-closed.** Fällt der CI-Schritt *Range bestimmen* aus, läuft der
  Folgeschritt mit leerem `RANGE`; `make adr-immutable RANGE=` bricht im Vorlauf-Wächter mit der
  Usage-Zeile und Exit 2 ab, statt eine leere Range durchzureichen.
- **[`AGENTS.md`](../../AGENTS.md) §3.3 eingehalten.** `34969a16` und `a847bfb8` sind reine Moves
  (`git show --stat` → `1 file changed, 0 insertions(+), 0 deletions(-)`), der Inhalts-Nachzug
  liegt je im Folge-Commit.
- **§3.5 nicht berührt.** Der Diff senkt keine Schwelle: `modules:` ist unverändert, kein
  `ignore-refs`-Paar kommt hinzu, kein Gate wird entfernt. Der `vcs:`-Block ist additiv und
  aktiviert einen Sensor, wo vorher keiner stand.
- **§3.7 in den neuen Artefakten.** Weder `test/vcs-modul-wiring.bats` noch `277`–`279` noch der
  neu eingefügte Text in `.d-check.yml`, `Makefile` und `ci.yml` tragen Befund-Kennung,
  Slice-Nummer als Erzählung, Lauf-Protokoll im Perfekt oder einen Verweis auf abwesenden Text
  (`grep -nE 'Review-Befund|slice-[0-9]|rot gesehen|hier und heute|frueher stand|zuvor stand'` über
  die vier neuen Dateien und über die `^+`-Zeilen des Diffs — leer).
- **§3.8 eingehalten.** Der Diff berührt weder [`AGENTS.md`](../../AGENTS.md) §3 noch
  [`harness/conventions.md`](../../harness/conventions.md) noch `harness/conventions/` — genau die
  Selbstbindung, die der Plan §3 in seiner letzten Tabellenzeile setzt.
- **§3.9 eingehalten.** Kein Host-Paketmanager, keine Host-Toolchain; der neue CI-Job ruft
  ausschließlich ein `make`-Ziel, und dieses fährt den gepinnten Digest.
- **Keine superseded ADR im Bezugsfeld.** Die drei referenzierten ADRs stehen auf `Accepted`.
- **Der `git mv`-Grenzfall ist operativ folgenlos.** Dass ein reiner Move einer ADR-Datei rot
  färbt (LOW-1), trifft heute keine reale Bewegung: ADR-Pfade sind ortsfest, und §3.11 nimmt sie
  ausdrücklich von der wandernden Klasse aus.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | stilles Grün auf der Zeile, um die die Regel geht |
| MEDIUM | 5 | Muster gegen den Bestand statt gegen das deklarierte Vokabular · Zusage nennt Sensor, der die Form nicht sieht · Plan-Zusage wird zur benannten offenen Frage · Lifecycle-Move macht ein bewachtes Zustandsfeld falsch · Verweis-Nachzug schreibt in ein eingefrorenes Artefakt |
| LOW | 3 | benannte Grenze, die ein Kommando auflöst · stille Fehlform ohne Mutations-Fall · Kommentar kündigt eine Klasse an und trägt eine andere |
| INFO | 2 | Mutations-Fall überlebt die Umbenennung seines Wächters · Prüfgegenstand bewegt sich während der Prüfung |

**Wiederkehrende Klassen für die Slice-Closure §7.** Drei Findings tragen eine Klasse, die das
Register bereits führt und die mit diesem Vorgang je einen weiteren Beleg bekäme. Die Zähler sind
mit `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` abgelesen und sind
keine Erwartungswerte:
`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` (MEDIUM-4; 5× → 6×, seit mehreren
Closures über der Schwelle und weiterhin `offen`),
`verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (MEDIUM-5; 4× → 5×, ebenfalls über der
Schwelle und `offen`) und
`zusage-nennt-sensor-der-form-nicht-sieht` (MEDIUM-2; 9× → 10×). HIGH-1, MEDIUM-1 und MEDIUM-3
tragen Klassen, die das Register heute nicht führt. Das Eintragen ist Planner-Arbeit bei der
Closure, nicht Sache dieses Reports.

---

## Verdikt

**Blockiert.** Ein HIGH und fünf MEDIUM.

**Die Sache des Slice trägt.** Die Kernfrage ist gegen den heutigen Bestand neu gemessen statt aus
dem Plan übernommen; das Paar aus Kern-Änderung und Chronik-Änderung ist der richtige Beleg und
hält beim Nachfahren; die Kettung des Vorlauf-Wächters schließt den fail-open-Fall wirklich, und
der Unterschied zwischen `make adr-immutable RANGE=HEAD..HEAD` (Exit 2) und
`make doc-immutable RANGE=HEAD..HEAD` (`0 Befund(e)`, Exit 0) macht sichtbar, dass die Kette und
nicht das Modul die Zusage trägt. `vcs` bleibt zu Recht aus `modules:`, das Ziel wird nirgends als
Gate behauptet, und die drei Mutations-Fälle treffen jeder genau ihre Stelle. Beanstandet ist
nicht die Entscheidung, ein `vcs` zu aktivieren, sondern die **Breite** des einen Feldes, das die
ganze Zusage trägt.

**Der blockierende Kern ist HIGH-1.** `head-allow` ohne End-Anker lässt die Status-Zeile einer
angenommenen ADR frei fortschreiben. Damit ist die Zeile, um die
[`AGENTS.md`](../../AGENTS.md) §3.4 geht, die einzige Zeile der Datei, die der neue Sensor nicht
schützt — und die Kontrolle zeigt, dass derselbe Text an jeder anderen Stelle rot färbt. Ein
Sensor, der für §3.4 gebaut wird und den Überschreib-Weg offenlässt, den §3.4 verbietet, trägt
weniger, als sein Ziel-Name und der Absatz in
[`harness/README.md`](../../harness/README.md) behaupten. Dass die Breite über den bats-Wächter
und `test/mutations/277` jetzt regressions-gesichert ist, macht es dringender, nicht milder.

**Die fünf MEDIUM zerfallen in zwei Gruppen.** MEDIUM-1 bis MEDIUM-3 gehören dem Slice: dasselbe
Feld ist an zwei Werten des deklarierten Vokabulars zu **eng** (MEDIUM-1), der eine Schlüssel,
auf dem DoD (2) ruht, ist von keinem Wächter gehalten (MEDIUM-2), und die tragende
Konfigurations-Entscheidung über `## Geschichte`, die der Plan diesem Slice zuwies, ist als
offene Frage abgelegt statt entschieden (MEDIUM-3). MEDIUM-4 und MEDIUM-5 gehören dem **Vorgang**:
beide sind Klassen, die das Beobachtungs-Register längst über der Schwelle führt und die diesen
Slice zum sechsten bzw. fünften Mal treffen. Bei MEDIUM-4 ist die Messung der eigentliche Ertrag —
`44427bec` ist grün, obwohl dort die vollständige Arbeit ohne Anspruch auf dem Hauptzweig liegt;
der Verstoß ist nicht nur unbewacht, sondern für jeden Sensor dieses Repos unsichtbar. Was daraus
folgt, ist mehr als eine Register-Zeile: der Ausgang beider Klassen steht seit mehreren Closures
aus, und das Regelwerk lässt einen Eintrag, der eine Closure ohne Ausgang übersteht, nicht zu.

**Der Vorbefund an `test/mutations/221` blockiert diesen Slice nicht** (INFO-1). Er gehört
`slice-197`; `ADR-0035` hat ihn nicht verdeckt und kann es strukturell nicht, weil ein roter Lauf
keinen Beleg schreibt und `e3905ccd` den Schlüssel ohnehin selbst entwertete. Er ist die einzige
stale `# expect:`-Zeile unter 265 Fällen, der Wächter darunter ist intakt, und der Treiber meldet
fail-closed. Er gehört als eigener Vorgang aufgenommen, nicht in die Nacharbeit dieses Slice.
