# Review — slice-173, Vorschau-Zweig von `archive-welle`, Runde 2

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Nachprüfung der Runde-1-Findings am geänderten Diff. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git diff c876d6a..HEAD` — vier Implementations-Commits `244db38` (Suchraum), `6b40c5c` (Fixture-Namen), `0358995` (Suchraum-Kommando im README), `760370d` (Dateityp-Achse der relativen Formen) |
| **Plan** | [`docs/plan/planning/in-progress/slice-173-archive-welle-als-unterkommando.md`](../plan/planning/in-progress/slice-173-archive-welle-als-unterkommando.md) |
| **Vorherige Findings am gleichen Modul** | [`2026-09-03-slice-173-vorschau-zweig-review.md`](2026-09-03-slice-173-vorschau-zweig-review.md) (1 HIGH, 4 MEDIUM, 4 LOW, 3 INFO); davor [`2026-09-03-slice-170-impl-review.md`](2026-09-03-slice-170-impl-review.md) und [`…-runde-2.md`](2026-09-03-slice-170-impl-review-runde-2.md) an der Shell-Fassung |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**; Abnahme-Kriterium 1 und die Fitness-Function-Tabelle sind Prüfmaßstab, weil der Plan sie als solchen nennt), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2, [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.6, §3.7, §3.9; [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht übernommen.** Der HIGH-Fix ist in dieser Sitzung selbst gefahren, jede Zahl unten steht neben dem Kommando, das sie ausgibt |

**Was in diesem Lauf gefahren wurde.** `make host-bin` (Docker-only, [`AGENTS.md`](../../AGENTS.md) §3.9)
und danach der **Träger selbst** über dem echten Baum:
`.harness/state/bin/ai-harness-init archive-welle --vorschau welle-09`. Der Lauf ist lesend — genau
die Eigenschaft, die dieser Slice trägt —, kein Gate und keine DoD-Abhakung. Dazu lesende Messungen
(`git grep`, `git ls-files`, `comm`, `grep`) und ein Abgleich des Go-Suchraums gegen den des
Shell-Helfers. Der Arbeitsbaum war beim Lauf sauber (`git status --porcelain` leer).

---

## Nachprüfung der Runde-1-Findings

### HIGH-1 — **behoben, selbst gemessen**

Der Suchraum kommt nicht mehr aus einem `.md`-Walk, sondern als Wert aus `git ls-files -z`
(`cmd/ai-harness-init/archive_welle.go:169-175`), gefiltert allein durch `archive.Suchraum`
(`internal/archive/scan.go:63-76`) gegen `AusgenommenePfade()`. Die Dateityp-Achse ist weg.

**Beleg aus dem eigenen Lauf** — die drei Gegenbeispiele des Runde-1-Befunds stehen jetzt in der
Sperre `[haenger]`, und der Lauf endet mit **Exit 3**:

```
internal/span/response_test.go -> docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md
test/mutations/132-span-rolle-aus-argument.sh -> docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md
test/mutations/135-span-agent-auf-gattungszeile.sh -> docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md
```

**Und nicht nur diese drei.** Die Hänger-Menge des Zweigs ist gegen die des Trägers gehalten, in
**beide** Richtungen und über **alle** 29 Ziele des Laufs. Verglichen wurden die verweisenden
Dateien der Vorschau (37) gegen `git grep -l -F` über dieselben Ziele im selben Suchraum (92): die
Differenz ist **vollständig** durch `Bestand.Verschwindend()` erklärt — 14 eingesammelte
`done/`-Slices und die 131 Review-Reports, die der Lauf selbst löscht. **Kein** Treffer nur in der
Vorschau, **kein** unerklärter Treffer nur im `git grep`:

```sh
# Ziele und verweisende Dateien aus dem Vorschau-Lauf
.harness/state/bin/ai-harness-init archive-welle --vorschau welle-09 | sed -n '/\[haenger\]/,$p' \
  | grep -oP '(?<= -> ).*\.md$' | sort -u > ziele.txt          # 29
.harness/state/bin/ai-harness-init archive-welle --vorschau welle-09 | sed -n '/\[haenger\]/,$p' \
  | grep -oP '^\s+\K\S+(?= -> )' | sort -u > go-links.txt      # 37
while read -r z; do git grep -l -F -e "$(basename "$z")" -- ':!.harness/baseline'; done < ziele.txt \
  | sort -u > gg-links.txt                                     # 92
comm -23 go-links.txt gg-links.txt                             # leer — kein Fund ohne git-grep-Deckung
comm -13 go-links.txt gg-links.txt                             # 55 — alle in Verschwindend()
```

Die Zahl der Review-Reports stimmt unabhängig nachgerechnet mit der des Laufs überein (**131** aus
`ReviewTrifft`-Nachbau gegen die Zeile `Review-Reports (ohne Stub): 131`, keine Erwartungswerte).
Der Zahn dazu existiert und trägt: `TestHaengerFindetVerweisAusNichtMarkdownDatei`,
Gegenbeispiel `test/mutations/238-archive-welle-go-suchraum-dateityp.sh`, dessen `sed`-Muster im
Zielstand genau eine Zeile trifft (`grep -cF 'if rel == "" || gesehen[rel] || Ausgenommen(rel) {' internal/archive/scan.go`
→ **1**) und dessen Mutation in `scan.go` compilierbar bleibt (`strings` ist dort importiert).

### MEDIUM-1 — **behoben, selbst gemessen**

Der Blast-Radius nennt jetzt Nicht-Markdown-Dateien: der Lauf listet `Dockerfile (1)` unter
`Verweise:`. Gegen den Träger gehalten deckt sich die Menge — `git grep -l -F -e "done/$base"` über
alle bewegten Basenamen liefert 140 Dateien, davon liegen alle in der 141er-Liste der Vorschau bis
auf zwei, und diese zwei sind ein Artefakt meiner *eigenen* Nachbau-Klassifikation: sie hängen an
`slice-166-adaptions-block-wird-ein-verzeichnis.md`, dessen Kopf-Feld `**Welle:** — (ohne Welle)`
lautet. Go (`istWellenlos`, `internal/archive/collect.go:87-89`) und Shell
(`harness/tools/archive-welle.sh:268`) prüfen beide `^ohne Welle([^A-Za-z]|$)` und ordnen die Datei
übereinstimmend als *fremd* ein — meine Nachbau-Bedingung war die lose. **Keine Divergenz.**

### MEDIUM-2 — **behoben**

Das Kommando im Kopf von `cmd/ai-harness-init/archive_welle.go:11-14` ist jetzt so fahrbar, wie es
dasteht, und liefert das behauptete Ergebnis:

```sh
git grep -cE 'os\.WriteFile|os\.MkdirAll|os\.Rename|os\.Remove|\.Create\(' \
  -- 'internal/archive/*.go' ':!internal/archive/*_test.go'   # keine Ausgabe, exit 1
```

Die Einschränkung auf den Nicht-Test-Anteil steht daneben und ist begründet; die `GRENZE:`-Zeile
sagt weiter zutreffend, dass für die Eigenschaft kein Wächter existiert.

### MEDIUM-3 — **behoben**

`TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad`
(`cmd/ai-harness-init/archive_welle_test.go:89-111`) fährt den Zweig als **Prozess** über
`runChild` und prüft drei Dinge: Exit 2, leeres `stdout`, und dass das Arbeitsverzeichnis nach dem
Lauf nur `.git` trägt — die dritte fängt den Durchfall in den schreibenden Init-Pfad.
`test/mutations/237-archive-welle-go-routing-vertauscht.sh` trifft im Zielstand genau eine Zeile
(`grep -cP '^\t\t\tos\.Exit\(archiveWelle\(os\.Args\[2:\], os\.Stdout, os\.Stderr\)\)$' cmd/ai-harness-init/main.go`
→ **1**), und die Mutation färbt den Fall: `spanReport` (`cmd/ai-harness-init/span_report.go:20-32`)
kennt keinen Rückgabewert 2 — es endet mit 0 oder 1, also fällt die Exit-Code-Prüfung.
`# verify: test-go` ist ein geführter Modus, `test-go` existiert als Target.

### MEDIUM-4 — **korrekt als Planner-Sache abgegrenzt** (mit einem Nebenbefund, LOW-6)

Der Befund verlangt die **Neufassung eines Closure-Kriteriums in §5 des Plans**. Modul 8
(§Rollen-Sequenz für einen Slice) führt den Plan als Planner-Artefakt (`P->>I: Slice in
in-progress/`), Modul 5 (§Lifecycle als State Machine) trennt `Autor:` von `Verantwortlich:`. Die
Einordnung *nicht in einem Implementations-Lauf* ist damit richtig und deckt sich mit
[`AGENTS.md`](../../AGENTS.md) §3.8 (*„die Anweisung ist die Quelle; was der laufende Kontext
liefert, ist ein Übergabe-Artefakt"*). Der Lauf hat statt einer §5-Änderung einen Risiko-Eintrag in
§6 hinterlegt, in der Form der Sektion (mit offenem `Ausgang:`-Platzhalter) — das ist das
Übergabe-Artefakt und keine Norm-Setzung. Seine **zwei Zahlen sind nachgerechnet und stimmen**:
`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l` → **0**,
`grep -l '^\*\*Welle:\*\* *ohne Welle' docs/plan/planning/done/slice-*.md | wc -l` → **44**; die
zwei Zeilenspannen des Helfers (`577–588`, `644–648`) treffen weiterhin den Untergrenzen-`exit 3`
bzw. die vier Zahlen. Der Quellen-Verweis darin trägt nicht — siehe LOW-6.

### LOW-1 · LOW-2 · LOW-3 · LOW-4 — **alle vier behoben**

- **LOW-1:** Die Verweis-Zeile trennt die Einheiten, im echten Lauf beobachtet:
  `Verweise: 141 Datei(en) betroffen (377 Praefix-, 11 geschwister-relative, 0 aufsteigende Fundstelle(n))`.
  `TestSchreibeTrenntDateienVonFundstellen` baut den Fall so, dass die Fundstellen-Summe die
  Datei-Zahl übersteigt; [`harness/README.md`](../../harness/README.md) nennt die zwei Einheiten mit.
- **LOW-2:** `planName` (`internal/archive/collect.go:212-218`) zieht die Ziffern-Grenze, die
  `nenntWelle` und `ReviewTrifft` schon tragen; `TestEinsammelnPlanAnDerZiffernGrenze` führt
  `welle-1` gegen `welle-10-*` und `welle-14-*`.
- **LOW-3:** `fundIn` übergeht mit der `zieht`-Menge den eigenen Umzugsgegenstand
  (`internal/archive/refs.go:105-110`), `TestVerweisFundUebergehtDenEigenenUmzugsgegenstand` hält es.
  Die aufsteigende Form bleibt bewusst ohne diese Ausnahme — die Dateien unter `done/<welle-x>/`
  bewegt dieser Lauf nicht.
- **LOW-4:** Die Zusage über Arbeitsbaum und Index ist nicht umformuliert, sondern **entfallen**:
  der Suchraum kommt aus dem Index, und der `KOPPLUNG:`-Absatz nennt jetzt, was dadurch draußen
  liegt (Ignoriertes, Untracktes). Das ist die stärkere Auflösung.

### INFO-1 · INFO-2 · INFO-3 — **korrekt für die Closure stehengelassen**

`BEO-026` wird bei der **Slice-Closure** eingetragen, nicht im Implementations-Lauf
(Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register: *„Eingetragen wird bei der
Slice-Closure"*). Der anders ausgegangene Risiko-1-Ausgang gehört ebenfalls dorthin
(`modul-05-planning-harness.md` §Offene Risiken werden bei Closure aufgelöst: *„Jedes bekommt beim
Übergang nach `done/` genau einen Ausgang"*). Alle vier `Ausgang:`-Felder in §6 stehen unausgefüllt
— formal richtig für einen Slice, der noch in `in-progress/` liegt. INFO-3 ist unverändert gültig:
`make archive-welle` fährt weiter den Shell-Helfer.

---

## Neue Findings

### MEDIUM-5 — Vier Stellen belegen die Dateityp-Achse mit dem `Dockerfile`, und das `Dockerfile` trägt keinen Verweis auf ein Zeitdokument

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 · [`AGENTS.md`](../../AGENTS.md) §3.7 (*Zusage*)
- **pfad:** [`harness/README.md`](../../harness/README.md):87 · `internal/archive/scan.go:21-23` · `internal/archive/scan_test.go:82-84` · `test/mutations/238-archive-welle-go-suchraum-dateityp.sh:10-12`
- **befund:** Alle vier Stellen begründen den dateityp-freien **Hänger**-Suchraum mit demselben
  Satz: *„Verweise auf ein verschwindendes Zeitdokument stehen im Bestand auch in Go-Kommentaren,
  Mutations-Fällen, im `Dockerfile` und in bats-Dateien."* Das `Dockerfile` trägt **keinen**
  Verweis auf einen Review-Report — `grep -n 'docs/reviews' Dockerfile` ist leer, und über alle
  Report-Basenamen gefragt ebenso
  (`for r in docs/reviews/*.md; do grep -lF -e "${r##*/}" Dockerfile; done` → leer, kein
  Erwartungswert). Sein Verweis ist `done/slice-057-go-kompilat-cache.md`, also die **Präfix**-Form
  auf eine bewegte Slice-Datei — die Klasse, die `TestVerweisFundPraefixAusNichtMarkdownDatei` hält
  und deren Kopf-Kommentar (`internal/archive/refs_test.go:104-108`) sie **richtig** benennt. Die
  Beleg-Datei ist zwischen den zwei Lesern vertauscht. In
  [`harness/README.md`](../../harness/README.md):87 steht das widerlegende Kommando im selben
  Satz — es nennt acht Dateien, und keine davon ist das `Dockerfile`:

  ```sh
  for r in docs/reviews/*.md; do git grep -lF -e "${r##*/}" -- ':!.harness/baseline' ':!*.md'; done | sort -u
  # .claude/hooks/pretooluse-agent-guard.sh   harness/tools/slice-mv.sh
  # internal/span/response_test.go            test/agent-guard.bats
  # test/archive-welle.bats                   test/mutations/132-span-rolle-aus-argument.sh
  # test/mutations/135-span-agent-auf-gattungszeile.sh
  # test/mutations/150-agentguard-rolle-abgewiesen.sh
  ```

  Wer die Zusage nachrechnet — wozu der Satz mit dem danebenstehenden Kommando ausdrücklich einlädt
  —, bekommt eine Liste, die sie an einem ihrer vier Glieder widerlegt. Die tatsächlich getroffene
  Klasse (Shell-Hooks und -Helfer) fehlt in allen vier Aufzählungen. Das Verhalten des Codes ist
  davon **nicht** berührt.
- **verifizierbar:** nein — kein Gate liest, worüber ein Kommentar oder ein README-Satz spricht;
  `make comment-claims` prüft nur, ob ein genannter **Sensor** existiert. Die Aussage ist an den
  zwei `grep`-Läufen oben ablesbar.
- **klasse:** genannte Messung liefert nicht das behauptete Ergebnis

### LOW-5 — Der Datei-Kopf zählt eine `git`-Stelle, zwei Absätze weiter zwei

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Kopplung*) · Maintainability
- **pfad:** `cmd/ai-harness-init/archive_welle.go:4-5` gegen `:14-15` und `:148-151`
- **befund:** Zeile 4 sagt *„hier steht der Dispatch und **die eine Stelle**, an der `git` läuft"*.
  Zeile 14 sagt *„die einzigen Fremdprozesse dieses Zweigs sind die **zwei** lesenden git-Aufrufe
  unten"*, und der Funktions-Kopf bei `:148` sagt *„`gitStatusPorcelain` und `gitLsFiles` sind die
  einzigen **zwei** Stellen"*. Der Nachzug von einer auf zwei Stellen hat den ersten Absatz stehen
  gelassen; wer nur den Datei-Kopf liest, hält eine der zwei Stellen für die einzige.
  [`harness/README.md`](../../harness/README.md):89 ist an derselben Aussage korrekt nachgezogen
  (*„in genau einer Datei … mit zwei lesenden Aufrufen"*).
- **verifizierbar:** nein — an den drei Absätzen derselben Datei ablesbar.
- **klasse:** Teilersetzung lässt die alte Kardinalität im selben Artefakt stehen

### LOW-6 — Der Quellen-Verweis des neuen Risiko-Eintrags nennt einen Abschnitt, der die Aussage nicht trägt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Rang-Zeiger*)
- **pfad:** [`docs/plan/planning/in-progress/slice-173-archive-welle-als-unterkommando.md`](../plan/planning/in-progress/slice-173-archive-welle-als-unterkommando.md) §6, dritter Risiko-Punkt
- **befund:** Der Eintrag begründet *„Die Neufassung des Kriteriums ist Planner-Arbeit"* mit
  `modul-08-agentenrollen.md` §Rollen-Regeln. Dieser Abschnitt nennt **Planner** kein einziges Mal
  (`sed -n '/^### Rollen-Regeln (Modul 8)/,/^<a id=/p' .harness/baseline/v5.18.0/regelwerk/modul-08-agentenrollen.md | grep -c 'Planner'`
  → **0**, kein Erwartungswert) und weist von den sechs Rollen nur der **ADR-Änderung** eine
  schreibende Rolle zu. Die Aussage selbst ist richtig, ihre Belegstelle aber ist §Rollen-Sequenz
  für einen Slice (`P->>I: Slice in in-progress/`) bzw. Modul 5 §Lifecycle (`Autor:`). Wer dem
  Zeiger folgt, findet die Regel nicht und kann die Abgrenzung für gesetzt statt für belegt halten
  — dieselbe Richtung, gegen die [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)
  §Kontext und [ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  ausdrücklich messen statt anzunehmen.
- **verifizierbar:** nein — `make docs-check` prüft Markdown-Links und Anker, nicht, ob ein
  Fließtext-Verweis auf einen Baseline-Abschnitt die zitierte Aussage trägt.
- **klasse:** Rang-Zeiger löst auf, trägt die zitierte Aussage aber nicht

### LOW-7 — `TrimSpace` im Suchraum nimmt zurück, wofür `-z` eine Zeile vorher steht

- **kategorie:** LOW
- **quelle:** Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.7 (*Grenze*)
- **pfad:** `internal/archive/scan.go:67` gegen `cmd/ai-harness-init/archive_welle.go:92`
- **befund:** `gitLsFiles` liest mit `-z` und begründet es: *„weil ein Dateiname ein Zeilenende
  tragen darf"*. `Suchraum` führt jeden Eintrag danach durch `strings.TrimSpace`. Ein getrackter
  Pfad mit führendem oder abschließendem Leerraum verliert ihn damit, löst im Arbeitsbaum gegen
  nichts auf und wird von `lies` still übersprungen — während `git grep` des Trägers ihn
  durchsucht. Das ist die Fehlerrichtung von HIGH-1 im Kleinen, und sie ist an keiner
  `GRENZE:`-Stelle benannt. Im Bestand tritt sie heute nicht auf: **0** von **1012** getrackten
  Pfaden tragen Randleerraum (`git ls-files -z | tr '\0' '\n' | grep -cE '^[[:space:]]|[[:space:]]$'`
  → 0, `git ls-files | wc -l` → 1012, keine Erwartungswerte).
- **verifizierbar:** ja — ein `make test`-Fall, der `archive.Suchraum([]string{" a.md"})` gegen den
  unveränderten Pfad hält, fällt heute.
- **klasse:** Normalisierung hebt eine zwei Funktionen entfernte Zusage auf

---

## Negativbefunde — geprüft, ohne Befund

- **Der `--vorschau`-Riegel steht vor beiden neuen `git`-Aufrufen.** `archiveWelle`
  (`cmd/ai-harness-init/archive_welle.go:67-103`) prüft `!vorschau` in `:72` und erreicht
  `repoWurzel()`, `gitStatusPorcelain()` und `gitLsFiles()` erst danach. Der Aufruf ohne Schalter
  endet unverändert mit Exit 2, ohne den Baum zu berühren.
- **Der lesende Charakter ist erhalten.** `exec.Command`/`CommandContext` steht im ganzen
  Vorschau-Pfad an **einer** Stelle (`archive_welle.go:181`, `git grep -n 'exec\.Command' -- internal/archive cmd/ai-harness-init/archive_welle.go`),
  gefahren mit den Argumenten `status --porcelain` und `ls-files -z`, beide mit 30-s-Kontext-Timeout.
  `internal/archive` startet keinen Prozess und schreibt nicht (Kommando siehe MEDIUM-2).
  `git` steht in [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- **Die drei Verweis-Formen decken sich mit denen des Trägers, jede in ihrem Suchraum.**
  Präfix-Form: überall und in jedem Dateityp — der Träger fährt `git grep -l -F -e "done/$base"`
  ohne Endungs-Filter (`harness/tools/archive-welle.sh:722`). Geschwister-relativ: nur aus flachem
  `done/` und nur `.md` — der Träger scannt `"$DONE"/*.md` (`:725-730`), und zwar **nach** dem Move,
  weshalb die `zieht`-Ausnahme der Go-Fassung ihn abbildet. Aufsteigend: nur aus `done/<welle-x>/`
  und nur `.md` — der Träger scannt `"$DONE"/*/*.md` (`:735 ff.`). Die zusätzliche `.md`-Achse der
  zwei relativen Formen ist damit **nicht** die Verengung aus HIGH-1, sondern die
  Auflösungs-Regel selbst; `TestVerweisFundDreiFormenInIhremSuchraum` führt für beide die
  Umkehr-Probe mit je einer `notiz.txt` im richtigen Verzeichnis.
- **Symlinks.** `lies` überspringt sie (`internal/archive/scan.go:93-95`). Das deckt sich mit dem
  Träger: `git grep -l -F -e "modul-08-agentenrollen" -- '.claude/rules'` findet **nichts**, obwohl
  vier Symlinks des Index (`git ls-files -s | awk '$1=="120000"'`) genau diesen String als Zielpfad
  tragen. Beide Fassungen lesen den Symlink nicht.
- **Fixture-Namen sind erfunden.** `TestVerweisFundPraefixAusNichtMarkdownDatei` nutzt
  `slice-900-kompilat-cache.md` statt des echten `slice-057`; der Kopf begründet es damit, dass ein
  echter Name im Blast-Radius des nächsten Laufs stünde und der Fall sich selbst umrisse. Der
  Bestand bestätigt: `slice-900` existiert nicht.
- **Alle Sensor-Namen in Kommentaren existieren.** Die acht neu genannten Testfunktionen
  (`TestHaengerFindetVerweisAusNichtMarkdownDatei`, `TestVerweisFundPraefixAusNichtMarkdownDatei`,
  `TestVerweisFundUebergehtDenEigenenUmzugsgegenstand`, `TestEinsammelnPlanAnDerZiffernGrenze`,
  `TestSchreibeTrenntDateienVonFundstellen`,
  `TestSubkommandoRouting_ArchiveWelleFaelltNichtInDenInitPfad`,
  `TestSuchraumFiltertNurDieAusgenommenenPraefixe`, `TestHaengerUebergehtFehlendeDatei`) sind je
  genau einmal definiert; die zwei genannten Mutations-Dateien existieren.
- **[`AGENTS.md`](../../AGENTS.md) §3.2 (Lint-Suppression).** Keine —
  `git diff c876d6a..HEAD | grep -nE '^\+.*(nolint|shellcheck disable)'` ist leer.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 (Chronik in Kommentaren).** Keine Befund-Kennung, keine
  Slice-Nummer als Erzählung, kein Lauf-Protokoll in den neuen Kommentaren
  (`git grep -nE '(#|//).*(Review-Befund|Runde [0-9]|frueher stand|vorher stand|rot gesehen)' -- internal/archive cmd/ai-harness-init/archive_welle.go cmd/ai-harness-init/archive_welle_test.go test/mutations/23[78]-*.sh`
  → ein Treffer, und der ist ein Fixture-**String** (`"# Runde 1\n"` in `vorschau_test.go:128`),
  kein Kommentar). Die Formulierung *„eine Messung von heute"* aus Runde 1 ist entfallen.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 (Docker-only).** Unverändert: keine neue Host-Toolchain, kein
  neues `make`-Ziel. Der Zweig hängt weiter an `make host-bin`.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).** Der Zweig
  wird weiterhin nirgends als Gate geführt; `harness/README.md` sagt *„kein Gate und in keiner
  Prerequisite-Kette"*.
- **Zahlen in [`harness/README.md`](../../harness/README.md).** Die Sperren-Zahl stimmt weiter:
  `grep -c 'Kennung: "' internal/archive/vorschau.go` → **8**, und der Lauf über `welle-09` zeigt
  vier davon (`ergebnisnotiz`, `kein-plan`, `untergrenze`, `haenger`). Der einzige README-Satz, der
  seiner eigenen Messung widerspricht, steht in MEDIUM-5.
- **`git ls-files` als Suchraum-Quelle vs. Träger.** `git grep` ohne `--cached` durchsucht die
  getrackten Dateien des Arbeitsbaums — dieselbe Menge, die `git ls-files` nennt; die
  Index-ohne-Arbeitsbaum-Lücke fängt `lies` ab (`TestHaengerUebergehtFehlendeDatei`). Die
  Ausnahme-Menge deckt sich: `AusgenommenePfade()` → `.git`, `.harness/baseline`;
  `grep_suchraum()` → `:!.harness/baseline` (`.git` führt der Index ohnehin nicht).

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 0 | — (HIGH-1 aus Runde 1 geschlossen, im eigenen Lauf belegt) |
| **MEDIUM** | 1 | genannte Messung liefert nicht das behauptete Ergebnis (MEDIUM-5) |
| **LOW** | 3 | Teilersetzung lässt alte Kardinalität stehen · Rang-Zeiger trägt die Aussage nicht · Normalisierung hebt eine entfernte Zusage auf |
| **INFO** | 0 | — |

**Wiederkehrende Klasse für die Closure §7.** MEDIUM-5 ist die **zweite** Instanz derselben Klasse
wie MEDIUM-2 aus Runde 1 (*eine Zusage nennt ein Kommando, dessen Ausgabe sie nicht deckt*), und
beide liegen in derselben `BEO-025`-Richtung (*Zusage weiter als der Code*), die schon die zwei
Runden an `slice-170` getragen hat. Runde 1 zählte in dieser Richtung vier Findings, Runde 2 zählt
zwei weitere (MEDIUM-5, LOW-7). Ob und wie das den Register-Zähler bewegt, entscheidet die Closure,
nicht dieser Report; hier steht nur, dass die Klasse sich nach ihrer Behebung an einer neuen Stelle
reproduziert hat.

## Verdikt

**Nicht freigegeben — aber der Blocker ist Text, kein Verhalten.**

Der HIGH aus Runde 1 ist geschlossen, und zwar nicht auf Zusage, sondern gemessen: der Träger
gefahren, Exit 3, die drei benannten Gegenbeispiele in der Sperre, und die vollständige
Hänger-Menge in beide Richtungen gegen `git grep` gehalten — ohne Rest. Alle vier MEDIUM und alle
vier LOW der Runde 1 sind aufgelöst, drei davon strukturell statt kosmetisch (Suchraum aus dem
Index, `zieht`-Ausnahme, Ziffern-Grenze). Die zwei neuen Mutations-Fälle treffen je genau eine
Zeile und färben ihren Wächter.

Stehen bleibt **ein MEDIUM**: vier Stellen belegen die Dateityp-Achse mit einer Datei, die den
belegten Verweis nicht trägt, und eine davon führt das widerlegende Kommando daneben. Nach
`.harness/skills/reviewer.md` §Ablage blockiert MEDIUM typischerweise, und ich weiche hier nicht ab
— die Klasse ist in derselben Sitzungsreihe zum zweiten Mal aufgetreten, und genau dagegen steht
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1. Die Korrektur berührt vier Sätze und keine Zeile ausführbaren Codes; danach ist der
Zweig aus Reviewer-Sicht bereit für die Verifikation.

**Drei Posten sind ausdrücklich nicht mein Gegenstand und richtig abgegrenzt:** der
`BEO-026`-Registereintrag, der Ausgang des ersten Risikos und die Neufassung des §5-Kriteriums
(MEDIUM-4). Alle drei hängen an der **Slice-Closure** bzw. am **Planner** (`modul-06-roadmap.md`
§Das Beobachtungs-Register, `modul-05-planning-harness.md` §Offene Risiken werden bei Closure
aufgelöst, `modul-08-agentenrollen.md` §Rollen-Sequenz für einen Slice). Dass der Lauf sie stehen
ließ, ist die richtige Entscheidung; LOW-6 betrifft allein die **Belegstelle**, mit der er sie
begründet, nicht die Abgrenzung selbst.

**Für den Acceptance-Trigger von [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md):**
Dieser Report ist wie sein Vorgänger **nicht** die dort verlangte Konsistenz-Runde. Er prüft den
Port gegen den Plan, nicht die Entscheidung gegen
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md) und
[ADR-0007](../plan/adr/0007-bootstrap-phasen.md).

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation MEDIUM-5 bestreiten, greift der
Konflikt-Pfad aus Modul 8 (§Konflikt-Pfad als Rollen-Sequenz) — Architect-Verdikt als Artefakt,
nicht Herabstufung wegen Widerspruchs.
