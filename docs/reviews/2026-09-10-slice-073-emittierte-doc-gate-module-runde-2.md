# Review-Report — slice-073: Welche Doc-Gate-Module ein frisch gebootstrapptes Ziel bekommt

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 2

> Jede Zahl in diesem Report steht neben dem Kommando, das genau sie ausgibt
> ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
> Keine ist ein Erwartungswert; alle wandern mit dem Baum. Die d-check-Sonden liefen gegen
> **real gebootstrappte** Ziele außerhalb des Repos, netzlos, Mount `:ro`, über dem in
> [`d-check.mk`](../../d-check.mk) gepinnten Digest. Kein Grün-Satz dieses Reports stützt sich
> auf einen Bericht des Implementers.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `84613d65..aeb6edbd` — zwei Commits, **7** Dateien
  (`git diff --name-only 84613d65 HEAD | wc -l`): der Planner-Commit `81748d84` (zwei
  Plan-Dateien) und der Behebungs-Commit `aeb6edbd` (fünf Dateien —
  `internal/emit/templates/d-check.yml`, `harness/tools/full-smoke.sh`,
  `internal/emit/emit_test.go`, `test/mutations/296-…`, `test/mutations/297-…`).
  Arbeitsbaum sauber (`git status --porcelain` → leer).
- **Slice-Plan (Repo-Ergänzung):**
  [`slice-073`](../plan/planning/done/slice-073-emittierte-doc-gate-module.md).
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte ADRs, mit selbst gelesenem Status:**
  [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) — `Accepted`, normativ
  (`grep -n '^\*\*Status:\*\*' docs/plan/adr/0007-*.md`).
- **Aktive `MR-*`:** MR-001, MR-017, MR-019, MR-020, MR-025, MR-037.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.8, §3.10.
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-10-slice-073-emittierte-doc-gate-module.md) — 2 HIGH / 2 MEDIUM / 1 LOW /
  2 INFO, blockierend. Jeder Befund ist unten einzeln gegen den Behebungs-Commit gehalten.

## Stand der Runde-1-Befunde

| Runde-1-Befund | Ausgang in Runde 2 |
|---|---|
| HIGH-1 — Kriterium 1 in beide Richtungen ausgelegt | **an der Wurzel richtig angesetzt, im Artefakt nicht angekommen** → HIGH-1 (R2), MEDIUM-1 (R2) |
| HIGH-2 — Trigger bereits eingetreten | **behoben** → N-1 |
| MEDIUM-1 — Übergabe-Artefakt fehlt im Repo | **behoben** → N-2 |
| MEDIUM-2 — emittiertes Artefakt nennt den Ursprungs-Repo | **nicht behoben, Klasse gewachsen** → MEDIUM-2 (R2) |
| LOW-1 — Zusage ohne Mutations-Fall | **behoben, selbst rot gesehen** → N-3 |
| INFO-1 / INFO-2 | unverändert, s. N-9 |

## Findings

### HIGH-1 — Der Kommentar, der HIGH-1 aus Runde 1 schließen soll, behauptet eine Messung, die die genannte Quelle nicht trägt — und widerspricht sich zwei Sätze später selbst

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7,
  [`slice-073`](../plan/planning/done/slice-073-emittierte-doc-gate-module.md) DoD (1),
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
- **pfad:** `internal/emit/templates/d-check.yml:25-27`
- **befund:** Der neue Kommentar sagt: *„order:/direction: auf spec-straten und `token:` auf
  slice/welle samt `{from: adr, to: slice}` stehen dort im auskommentierten matrix-Block — sie
  gehen mit."* Für `welle` trifft das nicht zu: Die genannte Ziel-Form führt **keine**
  `welle`-Position, auch keinen `token:`-Modus darauf. Der **nächste Satz** sagt das Gegenteil
  (*„welle als eigene Klasse … stehen dort nicht"*) — `token: 'welle-\d{2}'` ist ein Attribut
  genau dieser Klasse und kann nicht zugleich mitgehen und nicht dastehen. Der **Slice-Plan sagt
  es richtig** (DoD (1): *„und die `welle`-Positionen gar nicht"*); falsch ist die Übertragung ins
  Artefakt, das ein fremdes Repo bekommt.
- **verifizierbar:** ja — gegen die genannte Vorlage selbst, netzlos:

  ```sh
  T=.harness/baseline/v6.5.0/templates/.d-check.yml
  grep -cF "token: 'slice" "$T"   # 1  — geht mit, richtig benannt
  grep -cF "token: 'welle" "$T"   # 0  — geht NICHT mit, falsch benannt
  grep -cF 'welle'         "$T"   # 0  — die Klasse existiert dort gar nicht
  ```

  Keine Erwartungswerte — die Zahlen wandern mit dem vendored Stand; tragend ist die Null.
  Kein Gate fängt es: `make comment-claims` erreicht `internal/emit/templates/` nicht (dauerhaft
  außerhalb seiner vier Pfad-Muster), und `codepaths` liest Markdown, keine YAML-Kommentare.
- **klasse:** Kommentar behauptet eine Messung, die die von ihm genannte Quelle nicht trägt

**Warum das HIGH ist und nicht Kosmetik.** DoD (3) verlangt einen Eintrag im Adaptions-Block, und
die Einträge dieses Blocks sind append-only
([`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)).
Der Architect läuft nach Rollen-Definition in frischem Kontext und liest, was im Baum steht. Steht
im Baum, `token:` auf `welle` sei von der Vorlage gedeckt, wird genau diese Falschmessung in ein
Artefakt geschrieben, dessen Rumpf nachträglich nicht korrigiert wird — dieselbe Mechanik, die
Runde-1-HIGH-2 als teuersten Befund führte, nur mit vertauschter Ursache.

### MEDIUM-1 — Die Zusage „jede Position trägt dieselbe Autorität" ist an zwei Positionen nicht eingelöst, und an einer davon bleibt das Ziel hinter der Ziel-Form zurück

- **kategorie:** MEDIUM
- **quelle:** [`slice-073`](../plan/planning/done/slice-073-emittierte-doc-gate-module.md)
  §1 (Entscheidungsregel) und DoD (1),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- **pfad:** `internal/emit/templates/d-check.yml:23-30` (die Aufzählung), `:34` (`adr`-Klasse),
  `:47` (`exclude-sections`)
- **befund:** Der Kommentar eröffnet mit *„Jede Position dieses Blocks trägt dieselbe Autorität"*
  und zählt dann drei Gruppen auf. Zwei Positionen des Blocks kommen darin nicht vor, und bei
  einer läuft das Ziel der Ziel-Form **hinterher** statt voraus: Die Vorlage führt
  `token: 'ADR-\d{4}'` auf der `adr`-Klasse (mit eigener Begründung: *„auch die bloße Kennung im
  Fließtext zählt als Referenz"*), der emittierte Stand führt ihn nicht. Die zweite ist
  `exclude-sections`: Die Vorlage spricht dort ausdrücklich **negativ** (*„Ohne
  `exclude-sections`"*), der emittierte Stand setzt den Schlüssel. Das ist dieselbe Klasse, die
  Runde-1-HIGH-1 benannte — die Ziel-Form gilt für die aufgezählten Positionen und für die
  nicht aufgezählten nicht —, nur an anderen Stellen.
- **verifizierbar:** ja — die Positions-Bilanz ist ein Zwei-Zeilen-Vergleich, und die Folge ist an
  einem real gebootstrappten Ziel gemessen:

  ```sh
  T=.harness/baseline/v6.5.0/templates/.d-check.yml; E=internal/emit/templates/d-check.yml
  grep -cF "token: 'ADR" "$T"; grep -cF "token: 'ADR" "$E"   # 1 · 0   (Ziel ist ENGER)
  grep -cF 'exclude-sections' "$T"                            # 1  — als Wort „ohne", kein Schluessel
  ```

  Wirkung im Ziel, drei Sonden gegen dasselbe frisch gebootstrappte Repo (Träger aus
  `make host-bin`), je eine Zeile in Abschnitt 1 von `spec/lastenheft.md`:

  ```text
  bare  ADR-0001                       -> spec/lastenheft.md:21  id-unlinked      (aus ids, nicht aus matrix)
  [ADR-0001](../docs/plan/adr/0001-…)  -> spec/lastenheft.md:21  matrix-forbidden Referenz spec-straten → adr
  bare  slice-001                      -> spec/lastenheft.md:21  matrix-forbidden Token-Referenz spec-straten → slice
  ```

  Die Decken-Regel greift für `slice` auch auf die bloße Kennung, für `adr` nur auf den Link; die
  bloße ADR-Kennung hängt allein an `ids`, das in derselben *skip-if-present*-Datei steht und dem
  Adopter gehört. **Kein stilles Grün heute** — deshalb MEDIUM und nicht HIGH.
- **klasse:** Entscheidungskriterium in derselben Änderung in beide Richtungen ausgelegt

**Nicht beanstandet ist die Entscheidung.** `exclude-sections` ist von DoD (1) ausdrücklich
verlangt und in Runde 1 (N-8) auf seine Sache geprüft. Beanstandet ist der Universal-Satz: Er
behauptet Vollständigkeit über einen Block, den er nicht vollständig durchgeht.

### MEDIUM-2 — Der Ursprungs-Repo-Vergleich im emittierten Artefakt ist nicht gestrichen, sondern gewachsen; im Ziel bestreitet er eine Eigenschaft der Datei, in der er steht

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7,
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
- **pfad:** `internal/emit/templates/d-check.yml:28-30`
- **befund:** Der beanstandete Nachsatz (*„anders als im Dogfood …"*) ist gestrichen. An seine
  Stelle ist ein neuer Satz getreten: *„Der Dogfood (`.d-check.yml`) führt order:/direction: heute
  nicht — das emittierte Ziel ist an dieser Position weiter als der Dogfood."* Im Ziel gibt es
  genau **eine** Datei dieses Namens: die, in der der Satz steht — und sie führt `order:` und
  `direction: no-downward` drei Zeilen darunter. Für den Adopter liest der Satz sich damit nicht
  nur als Verweis auf ein Repo, das er nicht kennt, sondern als Verneinung einer Eigenschaft, die
  die Datei sichtbar hat. Dieselbe Zeile trägt zusätzlich die Begründung *„weil dieses Repo drei
  Lifecycle-Klassen fährt statt der zwei der Vorlage"* — auch das eine Aussage über
  `ai-harness-init`, nicht über das Ziel (s. INFO-1).
- **verifizierbar:** teilweise — die Wort-Bilanz im Emissions-Baum ist messbar und **gestiegen**,
  ein Gate fängt es weiterhin nicht (`full-smoke.sh` keilt auf `$tmprepo/.claude/commands/`,
  `comment-claims` erreicht `internal/emit/templates/` nicht):

  ```sh
  grep -rc 'Dogfood\|dogfood' internal/emit/templates/d-check.yml   # 2  (Runde 1: 1)
  ```
- **klasse:** Emittiertes Artefakt nennt den Ursprungs-Repo-Mechanismus

**Der Commit erklärt diesen Befund für behoben** (*„MEDIUM-2 behoben: der Satz … ist
gestrichen"*). Gestrichen ist der **Satz**; die **Klasse**, unter der Runde 1 ihn führte, steht
jetzt zweimal statt einmal. Das ist der Grund, warum dieser Befund nicht als LOW durchgeht: eine
als behoben gemeldete Klasse, die gewachsen ist, kostet die nächste Runde denselben Weg noch
einmal.

### LOW-1 — Der Doc-Kommentar der Funktion, die die Konfiguration liefert, beschreibt den Stand vor diesem Slice

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `internal/emit/emit.go:47`
- **befund:** Die Zeile lautet *„DCheckConfig liefert die eingebettete minimale `.d-check.yml`
  (links/anchors)."* Die Vorlage führt seit `bcf652b9` — einem Commit **dieses** Slice —
  `modules: [links, anchors, ids, matrix, spans]`. Der Kommentar beschreibt damit einen Zustand,
  den derselbe Slice abgelöst hat. `DCheckConfig()` und der schreibende Pfad
  (`writeSkipIfPresent`, `emit.go:106`) lesen dieselbe eingebettete Variable; die Zusage steht
  also am API-Eingang genau des Artefakts, um das dieser Slice geht.
- **verifizierbar:** ja —
  `grep -n 'minimale .d-check.yml' internal/emit/emit.go` gegen
  `git show bcf652b9 -- internal/emit/templates/d-check.yml | grep -E '^[-+]modules:'`.
  Kein Gate: `make comment-claims` deckt `internal/**/*.go` im Prüfbereich, prüft aber nur, ob ein
  **genannter Sensor existiert**, nicht, ob die Aussage stimmt.
- **klasse:** Kommentar beschreibt den vom eigenen Slice abgelösten Zustand

### LOW-2 — Der emittierte Kommentar verdrahtet den Baseline-Tag hart, außerhalb der gekoppelten Menge

- **kategorie:** LOW
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`harness/conventions.md`](../../harness/conventions.md) §Adoptierte Konventions-Quellen
- **pfad:** `internal/emit/templates/d-check.yml:24`
- **befund:** Der Kommentar nennt die Ziel-Form als
  `.harness/baseline/v6.5.0/templates/.d-check.yml` — mit festem Tag. Die
  [`harness/conventions.md`](../../harness/conventions.md) führt **fünf** Stellen, die diesen Tag
  pinnen und fail-closed aneinander hängen; diese ist eine sechste und hängt an keiner. Alle
  übrigen `.harness/baseline/…`-Nennungen des Emissions-Baums stehen mit Platzhalter
  (`<tag>`). Der Ort im Ziel wird aus `internal/fetch.DefaultTag` benannt, und der ist gekoppelt —
  nach dem nächsten Bump zeigt der Kommentar in jedem neu gebootstrappten Ziel auf ein
  Verzeichnis, das dort nicht existiert.
- **verifizierbar:** ja — die Kopplung ist an ihren Tests ablesbar, die neue Stelle ist es nicht:

  ```sh
  grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile                       # die kanonische Quelle
  grep -nE 'Default(Tag|BaselineSHA256) =' internal/fetch/baseline.go  # gekoppelt (TestDefaultTag_MatchesBaseline)
  grep -rn 'v6\.5\.0' internal/emit/templates/                          # 1 — ungekoppelt
  grep -rn '<tag>'    internal/emit/templates/ | wc -l                  # die Platzhalter-Form daneben
  ```

  Kein Gate: `codepaths` erreicht `.harness/**` nicht (benannte Lücke,
  [`harness/README.md`](../../harness/README.md) §Sensors), und eine YAML-Kommentarzeile liegt
  ohnehin außerhalb seines Formats.
- **klasse:** Hart verdrahteter Tag außerhalb der gekoppelten Pin-Menge

### INFO-1 — Die `welle`-Positionen haben im frischen Ziel einen leeren Prüfbereich, und der Baseline-Default lässt ihn leer

- **kategorie:** INFO
- **quelle:** [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `internal/emit/templates/d-check.yml:36,45`
- **befund:** Ein frisch gebootstrapptes Ziel trägt **null** Dateien, auf die die `welle`-Klasse
  und die Regel `{from: adr, to: welle}` keilen könnten. Seit
  [`MR-037`](../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
  ist wellenlose Arbeit der Baseline-Default — ein Adopter kann dauerhaft dabei bleiben, und die
  zwei Positionen prüften dann nie etwas. **Kein Befund und kein Gate-Bruch:** das Modul `matrix`
  hat über `spec-straten` einen nicht-leeren Prüfbereich, und die leeren Klassen erzeugen kein
  `matrix-inactive`. Unter
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  ist der strengere Default die richtige Richtung; dokumentiert ist die Annahme nirgends — der
  Kommentar begründet sie mit einer Eigenschaft des Ursprungs-Repos (MEDIUM-2).
- **verifizierbar:** ja — an einem real gebootstrappten Ziel:

  ```sh
  find <ziel>/docs/plan/planning -name 'welle-*.md' | wc -l   # 0
  find <ziel>/docs/plan/planning -name 'slice-*.md' | wc -l   # 0
  docker run --rm --network none -v <ziel>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" | tail -1
  #   19 Datei(en) geprüft, 0 Befund(e)  — kein matrix-inactive
  ```
- **klasse:** Emittierte Klasse mit im Default leerem Prüfbereich, Annahme undokumentiert

### INFO-2 — Runde-1-INFO-2 steht unverändert

- **kategorie:** INFO
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `harness/README.md:287`
- **befund:** Die CI-Beschreibung nennt weiterhin *„`make gates` + `make smoke` + `make mutate`"*,
  während `.github/workflows/ci.yml` **sechs** Jobs führt — darunter `full-smoke`, in dem die vier
  Zähne dieses Slice tatsächlich pro Push laufen, und `adr-immutable`. Außerhalb dieses Diffs;
  hier nur festgehalten, damit der Befund nicht mit Runde 1 verfällt.
- **verifizierbar:** ja — `grep -c '^  [a-z-]*:$' .github/workflows/ci.yml` gegen
  `harness/README.md:287`.
- **klasse:** Deckungs-Aussage über einen Nicht-Gate-Sensor

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — HIGH-2 aus Runde 1 ist an der Wurzel behoben, nicht umetikettiert.** Die
  Richtungs-Prüfung ist von DoD (3) nach DoD (1) gewandert; DoD (3) führt jetzt *„zwei, nicht
  drei"* Nicht-Emissionen und benennt den Grund (append-only,
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)).
  Es entsteht damit kein Eintrag, dessen Auflösungs-Trigger bei seiner Anlage schon gilt. Die
  **Adresse für die Dogfood-Seite nimmt die Sendung an**:
  [slice-072](../plan/planning/open/slice-072-adr-verweist-nicht-auf-lifecycle.md) hat in
  demselben Planner-Commit eine eigene DoD-(1)-Hälfte für `order:`/`direction:` und eine
  DoD-(2)-Zeile für den `matrix-downward`-Fall bekommen — kein Ausschluss, kein Weiterreichen ins
  Leere (Modul 5 §1, Out-of-Scope-Klasse 1).
- **N-2 — MEDIUM-1 aus Runde 1 ist geheilt: die Übergabe liegt dauerhaft im Baum.** §3 des
  Slice-Plans trägt jetzt den Abschnitt *Übergabe an den Architect — der Eintrag aus DoD (3)* mit
  drei nummerierten Inhalts-Punkten, dem Kommando für die Kennungs-Vergabe, der Mess-Tabelle und
  der Begründung, warum kein Change Request nötig ist. **Er trägt ohne Sitzungs-Kontext:** Ich
  habe die zwei Messungen, an denen die Entscheidung hängt, aus dem Plan heraus nachgefahren und
  sie reproduzieren exakt — frisches Ziel `19 Datei(en) geprüft, 0 Befund(e)`; derselbe Baum mit
  Abwärtslink rot; derselbe Abwärtslink mit entfernter Regel wieder `0 Befund(e)`. Die
  Rollen-Wahl ist ebenfalls belegt statt behauptet (Modul 8: *„Planner→Architect: Slice-Plan mit
  LH-Bezug"*). Was der Plan **nicht** vorgibt — die Pflichtfelder der Eintrags-Ziel-Form — ist
  kein Mangel: die trägt die Vorlage, und die gehört dem Architect.
- **N-3 — LOW-1 aus Runde 1 ist geschlossen, und ich habe beide Fälle selbst rot gesehen.** Über
  je einer Kopie außerhalb des Repos (`git archive HEAD | tar -x -C …`), Mutation angewandt, dann
  `make test-go` im gepinnten Bild:

  ```text
  296 -> EXIT 2, --- FAIL: TestDCheckConfig_EntschiedeneModulListe
         emit_test.go:49: die beiden neuen matrix-Regeln (adr->slice, adr->welle) fehlen
  297 -> EXIT 2, --- FAIL: TestDCheckConfig_EntschiedeneModulListe
         emit_test.go:52: die Richtungspruefung (order:/direction: no-downward) auf spec-straten fehlt
  ```

  Zwei verschiedene Zeilen, also **nicht** rot aus dem Grund des jeweils anderen Falls. Und der
  Zahn trifft die Stelle, die der Aufrufer benutzt: `DCheckConfig()` und der schreibende Pfad
  lesen dieselbe `//go:embed`-Variable (`grep -rn 'dcheckConfig' --include='*.go' .` →
  Deklaration, Getter und `writeSkipIfPresent` in `emit.go:106`, sonst nichts). Der Test baut die
  Verdrahtung nicht nach.
- **N-4 — Der vierte `full-smoke`-Zahn ist echt, und seine Kausalität hält in beide
  Tiefen.** Gemessen an einem **real gebootstrappten** Ziel (Träger aus `make host-bin`,
  `--lang go`), nicht am Bericht:

  ```text
  Abwaertslink Vertrag -> Technik eingeschmuggelt:
    spec/lastenheft.md:7  spezifikation.md  matrix-downward  Abwärtsverweis innerhalb
    spec-straten: Rang 0 → 1 ist nicht erlaubt          (19 Datei(en), 1 Befund)
  dieselbe Verletzung unter modules: [links, anchors]:   19 Datei(en), 0 Befund(e)
  dieselbe Verletzung, order:/direction: entfernt:       19 Datei(en), 0 Befund(e)
  ```

  Zeile und Wortlaut decken sich mit dem, was der Commit zitiert. Die dritte Zeile ist die
  schärfere Gegenprobe: Der Fund kommt aus **dieser Regel**, nicht nur aus **diesem Modul**. Im
  Skript steht `modul_zahn_alte_module_gruen "$tmprepo" "matrix-downward-Zahn"` (Zeile `370`)
  **vor** der Rücknahme (`mv "$matrixdown_doc.orig"`), misst also den richtigen Zustand — wie bei
  den drei anderen Zähnen (`343`, `396`, `418`). Beide Sperren sind gesetzt (Exit ungleich 0
  **und** `grep -qE 'matrix-downward'`), das schließt „rot aus falschem Grund" aus.
- **N-5 — Die `AUSGANG`-Einordnungs-Gleichung geht nach der Erweiterung auf.** Nachgerechnet nach
  der in [`harness/README.md`](../../harness/README.md) §Nicht-Gate-Verify dokumentierten Form,
  über beiden Ständen:

  ```sh
  F=harness/tools/full-smoke.sh
  A=$(grep -cE '\|\| [a-z_0-9]+=\$\?$' "$F")
  B=$(grep  -E '\|\| [a-z_0-9]+=\$\?$' "$F" | grep -cE ' -n |span-clean|bash "\$wrapper"')
  C=$(grep  -E '\|\| [a-z_0-9]+=\$\?$' "$F" | grep -c 'tmpbin/ai-harness-init')
  E=$(grep -cE '^[[:space:]]*einordnen "' "$F")
  echo "$((A-B-C)) == $((E-2))"      # 27 == 27   (Basis 84613d65: 26 == 26)
  ```

  Eine neue make-Stufe, eine neue `einordnen`-Zeile. Und die Einordnung sitzt auf dem Zweig, den
  ein Leitungs-Fehlschlag erreicht: Bricht `docs-check` aus Netz-Gründen ab, ist `rc` ungleich 0
  und `matrix-downward` fehlt in der Ausgabe — genau die Bedingung, unter der `einordnen`
  aufgerufen wird. Der Grün-Zweig braucht keine, weil dort nichts fehlgeschlagen ist.
- **N-6 — Der `make mutate`-Beleg trägt; ich habe ihn nicht geglaubt, sondern nachgerechnet.**
  Der hinterlegte Schlüssel und der über dem heutigen Baum berechnete sind identisch:

  ```sh
  cat .harness/state/mutate-passed.key
  bash -c 'source harness/tools/mutate.sh 2>/dev/null || true; isolation_key'
  # beide: 9fbf951e58da8aaec8154a8b5e2040fe038af35963078253d5cb5ba942631d3f
  ```

  Die Bezugsmenge ist `isolation_key_files` mit der deklarierten Ausnahme `.git`
  ([ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)) — der
  Commit zwischen Lauf und jetzt bewegt den Schlüssel deshalb nicht, jede Inhaltsänderung würde
  es. Die zwei neuen Fälle lagen im Lauf: `ls test/mutations/*.sh | wc -l` → **283**, davon
  `grep -l 'internal/emit/templates/d-check.yml' test/mutations/*.sh | wc -l` → **3** (295, 296,
  297). Ein Wiederholungslauf war damit nicht nötig. **Was der Schlüssel nicht deckt**, benennt
  der Treiber selbst: Docker-Cache-Zustand und Host-Werkzeuge.
- **N-7 — Der Diff-Umfang ist sauber, in beide Richtungen geprüft.** `git diff --name-only
  84613d65 HEAD` nennt sieben Dateien, davon fünf im Implementer-Commit und zwei Plan-Dateien im
  Planner-Commit. `… | grep -c '^harness/conventions'` → **0**: Architect-Territorium
  ([`AGENTS.md`](../../AGENTS.md) §3.8) ist unberührt. `grep -c '^- \[x\]'` im Slice-Plan → **0**
  bei `grep -c '^- \[ \]'` → **5**: kein DoD-Haken gesetzt
  ([`AGENTS.md`](../../AGENTS.md) §3.10). `spec/lastenheft.md` unberührt, wie §3 des Plans es
  zusagt. Die Rollen-Trennung ist an `git log --stat` ablesbar: Plan-Änderungen im
  Planner-Commit, Code im Implementer-Commit.
- **N-8 — Die Emissions-Seite ist nach der Erweiterung weiterhin grün, ohne Regression.** Ein
  frisch gebootstrapptes Ziel mit der neuen Konfiguration: `19 Datei(en) geprüft, 0 Befund(e)` —
  gleich dem Stand ohne `order:`/`direction:`. Auch mit einer echten ADR-Datei daneben
  (`20 Datei(en) geprüft, 0 Befund(e)`). Die zwei neuen Zeilen kosten kein Falsch-Rot.
- **N-9 — INFO-1 aus Runde 1 (`MR-016`-Argument im Plan) ist unverändert und weiterhin
  Planner-Nacharbeit.** §6 des Plans führt sie mit offenem Ausgang; der Behebungs-Commit hat sie
  zu Recht nicht angefasst. Kein neuer Befund.
- **N-10 — Nicht geprüft (fremde Rolle):** die DoD-Abhakung, die Gate-Lauf-Bestätigung
  (`make gates`, `docs-check 1064/0`, `comment-claims 57/0`, die zwei `full-smoke`-Läufe) und der
  Gate-Stempel. Das ist Verifikation (Modul 11); der Reviewer-Skill nimmt sie ausdrücklich aus.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Kommentar behauptet eine Messung, die die von ihm genannte Quelle nicht trägt |
| MEDIUM | 2 | Entscheidungskriterium in derselben Änderung in beide Richtungen ausgelegt · Emittiertes Artefakt nennt den Ursprungs-Repo-Mechanismus |
| LOW | 2 | Kommentar beschreibt den vom eigenen Slice abgelösten Zustand · Hart verdrahteter Tag außerhalb der gekoppelten Pin-Menge |
| INFO | 2 | Emittierte Klasse mit im Default leerem Prüfbereich · Deckungs-Aussage über einen Nicht-Gate-Sensor |

**Wiederkehrende Klasse für den Steering-Loop-Zähler.** Zwei Klassen haben in diesem Slice die
zweite Runde erreicht und gehören bei der Slice-Closure ins Beobachtungs-Register
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)):

1. *Eine Aussage über die Ziel-Form steht als Behauptung im Artefakt, statt gemessen zu sein.*
   Runde 1: die Ziel-Form gilt für drei Positionen und für eine vierte nicht. Runde 2: sie gilt
   angeblich für alle, und die Aufzählung ist an einer Stelle falsch und an zwei Stellen leer.
   Auffällig ist, **wo** die Klasse überlebt: Der Plan misst richtig, das emittierte Artefakt
   nicht — die Messung wurde beim Übertragen verloren.
2. *Ein emittiertes Artefakt begründet sich mit dem Ursprungs-Repo.* Runde 1 einmal, Runde 2
   zweimal — als behoben gemeldet und dabei gewachsen.

## Verdikt

**Blockierend — ja.** Ein HIGH und zwei MEDIUM.

**Was gut ist und nicht kleingeredet gehört.** Die zwei teuersten Runde-1-Befunde sind an der
Wurzel behoben, nicht umetikettiert: HIGH-2 ist durch die Planner-Entscheidung aufgelöst, statt
einen Trigger gegen einen anderen zu tauschen, und die Adresse für die Dogfood-Seite nimmt die
Sendung nachweislich an. Die Übergabe an den Architect liegt jetzt dauerhaft im Plan und trägt
ohne Sitzungs-Kontext — ich habe ihre Messungen aus dem Plan heraus reproduziert. Der vierte Zahn
ist echt, mit einer Kausalitäts-Gegenprobe, die eine Stufe schärfer misst als die drei
bestehenden, und die Einordnungs-Gleichung geht auf. Die zwei neuen Mutations-Fälle habe ich
selbst rot gesehen, mit je eigener Fehlerzeile, an der Stelle, die der Aufrufer benutzt.

**Warum es trotzdem nicht durchgeht.** Der Satz, der HIGH-1 schließen sollte, ist an der
entscheidenden Stelle falsch — und er ist es in dem einen Artefakt, das ein fremdes Repo bekommt
und aus dem der Architect als Nächstes einen **append-only** Eintrag schreibt. Der Plan sagt es
richtig; die Übertragung ins Artefakt hat die Messung verloren. Dazu bleibt die Zusage *„jede
Position"* an zwei Positionen uneingelöst, an einer davon zuungunsten des Ziels, und der
Ursprungs-Repo-Vergleich ist als behoben gemeldet, während er gewachsen ist. Alle drei sind mit
`grep` gegen die vendored Vorlage bzw. an einem gebootstrappten Ziel in Minuten entscheidbar.

**Reif für den Verifier — nein.** Nicht wegen des Umfangs der Nacharbeit, sondern wegen ihrer
Richtung: Was ansteht, sind Sätze in einem Kommentarblock, kein Verhalten. Der Verifier prüft DoD
gegen Code; DoD (1) verlangt ausdrücklich, dass *„die Autorität für alle Positionen dieses Blocks
dieselbe"* ist — dieser Punkt ist heute nicht abhakbar, und ein Verifier, der ihn abhakt, hätte
denselben Satz gelesen wie ich.

**Kein Rollen-Konflikt-Pfad ausgelöst.** Modul 8 verlangt die Konflikt-Sequenz ab *HIGH mit
Rollen-Widerspruch*. Ein Widerspruch liegt nicht vor: Der Implementer hat der Planner-Entscheidung
nicht widersprochen, sondern sie beim Übertragen verfälscht, und die Ziel-Form-Bilanz ist eine
Messung, keine Meinung. Wird HIGH-1 bestritten, ist der Konflikt-Pfad zu eröffnen — herabgestuft
wird er nicht.

**Was nicht in die Behebung gehört.** Die Adaptions-Einträge und der Adaptions-Block bleiben
Architect-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.8), die DoD-Haken und die Closure-Notiz
bleiben Planner-Arbeit (§3.10). Die vier Positionen aus MEDIUM-1 sind eine Frage an den Plan,
nicht an den Kommentar allein: Ob `token: 'ADR-\d{4}'` mitgeht, entscheidet DoD (1) — und DoD (1)
schreibt der Planner.
