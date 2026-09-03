# Review — slice-173, Vorschau-Zweig von `archive-welle`

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Diff gegen Plan und Hard Rules. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git diff 3f3af46..HEAD` — vier Implementations-Commits `83a00cb` (Unterkommando + `internal/archive`), `40bee7a` (fünf Mutations-Fälle), `3d72369` (`harness/README.md`), `39b3d35` (Kopf-Kommentar); dazu der Verweis-Nachzug `65d6bad` |
| **Plan** | [`docs/plan/planning/in-progress/slice-173-archive-welle-als-unterkommando.md`](../plan/planning/in-progress/slice-173-archive-welle-als-unterkommando.md) |
| **Vorherige Findings am gleichen Modul** | [`2026-09-03-slice-170-impl-review.md`](2026-09-03-slice-170-impl-review.md) und [`2026-09-03-slice-170-impl-review-runde-2.md`](2026-09-03-slice-170-impl-review-runde-2.md) — dieselbe Operation in ihrer Shell-Fassung, aus der dieser Lauf portiert; deren Klassen `BEO-025` (Zusage weiter als der Code) und `BEO-026` (Zähler-Label ≠ Einheit) stehen offen im [Register](../plan/planning/observations.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`** — Architect-Verdikt, kein Accepted-Constraint; ihre drei Abnahme-Kriterien und die Fitness-Function-Tabelle sind hier Prüfmaßstab, weil der Plan sie als solchen nennt), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2, [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.3, §3.6, §3.7, §3.9; [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus dem Implementer-Bericht übernommen.** Jede Zahl unten ist in dieser Sitzung selbst erhoben; das Kommando steht beim Befund |

**Was in diesem Lauf gefahren wurde.** Lesende Messungen über dem Arbeitsbaum
(`grep`, `git grep`, `find`, `comm`) und ein Zeilen-für-Zeilen-Abgleich der Go-Fassung gegen
`harness/tools/archive-welle.sh`, gegen den der Plan sie in §5 ausdrücklich hält. **Kein**
Go-Lauf, **kein** `make`-Ziel: [`AGENTS.md`](../../AGENTS.md) §3.9 hält die Toolchain im Bild, und
Gate-Läufe sind nicht die Reviewer-Rolle. Wo unten „nicht bewacht" steht, ist das aus dem
Test-Bestand abgeleitet und als solches gekennzeichnet, nicht als Sensor-Ergebnis ausgegeben.

---

## Findings

### HIGH-1 — Der Hänger-Wächter sucht nur in `.md`; der Shell-Helfer sucht in jeder getrackten Datei

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7 (*Zusage* / *Grenze*) · [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Abnahme-Kriterium 1
- **pfad:** `internal/archive/scan.go:28-41` (`AusgenommenePfade`/`Ausgenommen`), `internal/archive/scan.go:50-77` (`MarkdownDateien`), verdrahtet über `internal/archive/scan.go:90-112` (`Haenger`)
- **befund:** `Haenger` liest ausschließlich `.md`-Dateien. Der Träger, dessen Verhalten die Vorschau
  vorhersagt, sucht denselben Verweis in **jeder getrackten Datei** außer `.harness/baseline`
  (`grep_suchraum()` in `harness/tools/archive-welle.sh` liefert genau `:!.harness/baseline`, und
  `git grep -l -F` kennt keine Dateityp-Einschränkung). Der Unterschied ist im Bestand belegt: drei
  getrackte **Nicht**-Markdown-Dateien tragen einen lebenden Verweis auf
  `docs/reviews/2026-07-30-slice-060-dod2-adr-0011-architect.md` —
  `internal/span/response_test.go:189`, `test/mutations/132-span-rolle-aus-argument.sh:13`,
  `test/mutations/135-span-agent-auf-gattungszeile.sh:10`
  (`for r in docs/reviews/*.md; do rb="${r##*/}"; git grep -nF -e "$rb" -- ':!.harness/baseline' ':!*.md'; done | sort -u`,
  kein Erwartungswert). `docs/plan/planning/done/slice-060-rollen-achse.md` liegt flach in `done/`
  und trägt `**Welle:** [welle-09](…)`; `ReviewTrifft` zieht den Report bei einer Archivierung von
  `welle-09` ein. Die Vorschau schriebe für diese Lage `Sperren: keine — der schreibende Lauf
  liefe.` und gäbe Exit 0 aus, während der Träger mit Exit 3 abbräche. Der Funktionskopf von
  `AusgenommenePfade` sagt dazu, die Menge außerhalb des Suchraums *„ist geschlossen und steht an
  dieser einen Stelle"* — die zweite Achse (Dateityp) liegt an einer anderen Stelle und ist an
  keiner der drei `GRENZE:`-Stellen dieses Pakets benannt.
- **verifizierbar:** ja — ein `make test`-Fall über einem synthetischen Baum, dessen verweisende
  Datei keine `.md`-Endung trägt, fällt heute; ein `test/mutations`-Fall, der `MarkdownDateien` auf
  einen anderen Suffix umstellt, färbt `TestHaengerFindetVerweisAusReviewReport` **nicht** rot —
  genau daran ist die Verengung ablesbar.
- **klasse:** Suchraum an einer zweiten, unbenannten Achse verengt (der Port sagt weniger zu, als
  das Original prüft)

### MEDIUM-1 — Derselbe `.md`-Filter untertreibt den Blast-Radius

- **kategorie:** MEDIUM
- **quelle:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1 (der Vorschau-Zweig *sagt, was die Archivierung täte*) · [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `internal/archive/refs.go:75-91` (`VerweisFund`), über `internal/archive/scan.go:50-77`
- **befund:** Der Träger zieht die Präfix-Form `done/<datei>` über `git grep -l -F -e "done/$base" -- "${suchraum[@]}"`
  nach und stagt die getroffenen Dateien in Commit 2 — ohne Dateityp-Filter. `VerweisFund` sieht sie
  nur in `.md`. Zwei flache `done/`-Slices sind heute aus Nicht-Markdown-Dateien in dieser Form
  referenziert: `slice-057-go-kompilat-cache.md` aus `Dockerfile` und
  `slice-098-feldliste-ist-ausdruck-des-traegers.md` aus `test/full-smoke-ausgang.bats`
  (`for f in docs/plan/planning/done/slice-*.md; do b="${f##*/}"; git grep -lF -e "done/$b" -- ':!.harness/baseline' ':!*.md'; done`,
  kein Erwartungswert). Für eine Welle mit einem dieser zwei Slices nennt die Vorschau eine Datei
  weniger, als der schreibende Lauf anfasst — und `Dockerfile` ist die Datei, aus der `make test`,
  `make lint` und `make build` ihre Stages ziehen.
- **verifizierbar:** ja — `make test` mit einem Fall, dessen verweisende Datei `Dockerfile` heißt.
- **klasse:** Suchraum an einer zweiten, unbenannten Achse verengt (dieselbe Klasse wie HIGH-1, ein
  Vorgang)

### MEDIUM-2 — Die Messung, die die Schreib-Freiheit belegen soll, liefert als geschriebenes Kommando nicht null

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 · [`AGENTS.md`](../../AGENTS.md) §3.7 (*Zusage*)
- **pfad:** `cmd/ai-harness-init/archive_welle.go:7-13`
- **befund:** Der Kopf sagt *„ES SCHREIBT NICHTS. Zwei Stuecke tragen das, und beide sind
  nachrechenbar statt zugesagt: internal/archive fuehrt keinen schreibenden Aufruf (grep -cE
  'os\.WriteFile|os\.MkdirAll|os\.Rename|os\.Remove|\.Create\(' ueber internal/archive/\*.go)"*. Das
  Kommando, so wie es dasteht, meldet **drei** Treffer:
  `internal/archive/collect_test.go:15` (`os.MkdirAll`), `:18` (`os.WriteFile`) und
  `internal/archive/vorschau_test.go:76` (`os.RemoveAll`, vom Alternativ `os\.Remove` getroffen) —
  `grep -nE 'os\.WriteFile|os\.MkdirAll|os\.Rename|os\.Remove|\.Create\(' internal/archive/*.go`
  (kein Erwartungswert). Der Glob `internal/archive/*.go` schließt die Testdateien ein; die
  Behauptung gilt nur für den Nicht-Test-Anteil, und der Kommentar schränkt sie darauf nicht ein.
  Wer die Zusage nachrechnet — wozu der Satz ausdrücklich einlädt —, bekommt eine Zahl, die sie
  widerlegt, und kann eine später hinzukommende echte Schreib-Stelle nicht mehr von den drei
  Test-Treffern unterscheiden. Der Absatz nennt daneben zutreffend, dass es für die Eigenschaft
  keinen Wächter gibt.
- **verifizierbar:** nein — kein Gate liest, worüber ein Kommentar spricht; `make comment-claims`
  prüft nur, ob ein genannter **Sensor** existiert, und dieser Absatz nennt keinen.
- **klasse:** genannte Messung liefert nicht das behauptete Ergebnis

### MEDIUM-3 — Der neue `main()`-Zweig ist unbewacht, und sein Durchfall-Pfad schreibt

- **kategorie:** MEDIUM
- **quelle:** [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) §Fitness Function Zeile 1 (*„Ein Träger, ein Einstiegspunkt … ein vertauschter Zweig färbt rot"*) · [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `cmd/ai-harness-init/main.go:510-511` (`case "archive-welle"`)
- **befund:** Kein Test und kein `test/mutations`-Fall fährt den Dispatch. `TestArchiveWelleOhneVorschauSchreibtNichts`
  ruft `archiveWelle()` direkt, `TestUsageNenntAlleDreiUnterkommandos` liest nur den Usage-String;
  `grep -l 'files: cmd/' test/mutations/*.sh` nennt keinen Fall über diesem Zweig. Der
  Schwester-Zweig trägt genau diesen Zahn (`test/mutations/154-unterkommando-routing-vertauscht.sh`,
  `# expect: TestClampSurvivesBrokenPayload`). Fällt der `case` weg oder wird er umgehängt, landet
  `ai-harness-init archive-welle --vorschau <welle>` nach dem Kommentar in `main.go:106-114` im
  **Init-Pfad** — der schreibt in das Arbeitsverzeichnis, und die Eigenschaft, die dieser Slice
  trägt („es schreibt nichts"), kippt still. Der Fall bleibt dabei über `make test`, `make lint`
  und `make mutate` grün.
- **verifizierbar:** ja — `make mutate` mit einem Fall, der `case "archive-welle"` auf `spanReport`
  umhängt; heute bliebe er grün und der Treiber meldete `BEFUND`.
- **klasse:** Dispatch-Zweig ohne Routing-Zahn

### MEDIUM-4 — Der Quervergleich aus §5 ist gegen den unveränderten Shell-Helfer über diesem Repo nicht fahrbar

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · Slice-Plan §5 (*„seine vier Zahlen … gegen die des Shell-Helfers gehalten — er gibt dieselben aus, und eine Abweichung ist ein Befund"*)
- **pfad:** `harness/tools/archive-welle.sh:577-588` (Untergrenzen-`exit 3`) und `:625-635` (Hänger-`exit 3`) gegen `:644-648` (die vier Zahlen)
- **befund:** Der Shell-Helfer druckt seine vier Einsammel-Zahlen **nach** beiden `exit 3`-Ausgängen.
  Über diesem Repo greifen beide: es existiert kein `done/*/archiv.zip` (`ls -d docs/plan/planning/done/*/`
  ist leer), und [`harness/README.md`](../../harness/README.md) hält im selben Abschnitt fest, dass das Werkzeug
  *„auf eine Welle dieses Repos noch nicht anwendbar"* ist und *„an beiden `exit 3`-Ausgängen
  abbricht"*. Damit gibt der Helfer für **keine** Welle dieses Repos vier Zahlen aus, gegen die sich
  etwas halten ließe; ein solcher Vergleich setzt einen geänderten oder gesourcten Helfer voraus.
  Im Diff steht dazu kein Beleg — weder in einer Commit-Message noch in §7 des Plans, dessen
  Platzhalter unausgefüllt sind. Zusätzlich adressiert das Kriterium die falsche Fläche: die vier
  Zahlen sind zwischen beiden Fassungen aus derselben Regel gerechnet, während HIGH-1, MEDIUM-1 und
  LOW-1 alle **außerhalb** dieser vier Zahlen liegen — ein Vergleich, der nur sie hält, kann keinen
  der drei finden.
- **verifizierbar:** nein — kein Gate liest ein Closure-Kriterium; die Aussage ist an den zwei
  Zeilennummern des Helfers und am leeren `ls` ablesbar.
- **klasse:** Vergleichs-Kriterium gegen ein Instrument, das im Prüf-Fall nicht bis zur Messstelle läuft

### LOW-1 — Die `Verweise:`-Zeile trägt drei Zahlen ohne eigene Einheit unter einem `Datei(en)`-Label

- **kategorie:** LOW
- **quelle:** `BEO-026` im [Beobachtungs-Register](../plan/planning/observations.md) (*Ein Zähler-Label nennt eine andere Einheit als der Zähler zählt*, offen, 1×)
- **pfad:** `internal/archive/vorschau.go:152-164` (`schreibeVerweise`)
- **befund:** Ausgegeben wird `Verweise: %d Datei(en) betroffen (%d mit Praefix, %d geschwister-relativ, %d aufsteigend)`.
  Die erste Zahl ist `len(funde)` — Dateien. Die drei in der Klammer sind über alle Dateien
  summierte **Fundstellen** und tragen kein eigenes Einheitswort; sie können die erste Zahl
  überschreiten. Der Shell-Helfer trennt an derselben Stelle ausdrücklich:
  `Verweise: N Datei(en) nachgezogen (X geschwister-relative, Y aufsteigende Ziel(e))`
  (`harness/tools/archive-welle.sh:763`). Die Klasse ist im Register offen und dort mit *„eine Zahl,
  gegen die der Aufrufer sein Ergebnis abzählt"* beschrieben — genau diese Rolle hat die Zeile hier.
- **verifizierbar:** nein — kein Gate hält ein Label gegen seinen Zähler (`BEO-026` sagt das selbst).
- **klasse:** Zähler-Label ohne Einheit für die Teilzahlen

### LOW-2 — Die Welle-Plan-Auswahl trägt die Ziffern-Grenze nicht, die ihre zwei Nachbarn tragen

- **kategorie:** LOW
- **quelle:** Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.7 (*Grenze*)
- **pfad:** `internal/archive/collect.go:178`, `:189` (`ergebnisName` / `strings.HasPrefix(name, welleID)`)
- **befund:** `nenntWelle` (`:77-83`) vergleicht an einer Ziffern-Grenze und dokumentiert sie
  (*„welle-1 trifft welle-14 nicht"*, mit Testfall); `ReviewTrifft` (`:110-116`) trägt dieselbe
  Disziplin für Slice-Nummern samt eigenem Test. Die dritte Zuordnungs-Stelle — Welle-Plan und
  Ergebnisnotiz — vergleicht roh per Präfix und Gleichheit. Für `welle-1` fielen damit
  `welle-10-re-baseline.md`, `welle-10-results.md`, `welle-12-*`, `welle-14-*` in `Plaene`; das
  Ergebnis ist die Sperre `mehrdeutiger-plan` mit einer Kandidatenliste, die die Ergebnisnotiz einer
  fremden Welle als Welle-Plan führt. Die Wirkung ist fail-closed und der Bestand dieses Repos ist
  zweistellig-genullt (`welle-01` … `welle-14`), aber die Grenze ist an dieser Stelle weder
  gezogen noch benannt.
- **verifizierbar:** ja — ein `make test`-Fall mit `Einsammeln(root, "welle-1")` über einem Baum mit
  `welle-10-results.md`.
- **klasse:** dieselbe Grenze in einer von drei Zuordnungs-Stellen nicht gezogen

### LOW-3 — Der Geschwister-Suchraum enthält die mitziehenden Dateien

- **kategorie:** LOW
- **quelle:** Maintainability · Slice-Plan §1 (*„nennt den Blast-Radius"*)
- **pfad:** `internal/archive/refs.go:94-109` (`fundIn`, `flachInDone`)
- **befund:** `fundIn` zählt die präfixlose Form in **jeder** flach in `done/` liegenden Datei — also
  auch in denen, die dieser Lauf selbst nach `done/<welle-id>/` zöge. Deren wechselseitige
  Geschwister-Links bleiben nach dem Move gültig und werden vom Träger nicht angefasst: er scannt
  für diese Form `"$DONE"/*.md` **nach** dem Move (`harness/tools/archive-welle.sh:725-730`), sieht
  dort also nur die Bleibenden. Der Blast-Radius der Vorschau ist damit für Wellen mit mehreren
  Mitgliedern zu groß. Die Fehlerrichtung ist unschädlich, die Zahl aber die, gegen die §5 vergleichen
  will. Im Bestand tragen **20** flache `done/`-Slices einen präfixlosen Geschwister-Link
  (`grep -lE '\]\(slice-[0-9]+[a-z]?-[^)]*\.md\)' docs/plan/planning/done/slice-*.md | wc -l`, kein
  Erwartungswert).
- **verifizierbar:** ja — `make test` mit zwei Mitgliedern derselben Welle, die einander präfixlos
  verlinken.
- **klasse:** Suchraum enthält den eigenen Umzugsgegenstand

### LOW-4 — „In einem sauberen Baum fallen beide Mengen zusammen" gilt für ignorierte Dateien nicht

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*Grenze*)
- **pfad:** `internal/archive/scan.go:46-49`
- **befund:** Der `GRENZE:`-Absatz begründet den Arbeitsbaum-Lauf damit, dass Arbeitsbaum und Index
  in einem sauberen Baum zusammenfielen. `git status --porcelain` — dieselbe Quelle, aus der die
  Sauberkeit dieses Zweigs stammt — listet **ignorierte** Dateien nicht. Ein sauberer Baum kann
  `.md`-Dateien unter `.harness/state/`, `/bin/` oder `/dist/` tragen (`.gitignore`), die
  `MarkdownDateien` liest und `git grep` nie sieht; enthielte eine davon einen Report-Basenamen,
  meldete die Vorschau eine `haenger`-Sperre, die der Träger nicht kennt. Heute gibt es keine solche
  Datei — `comm -23 <(find . -name '*.md' -not -path './.git/*' -not -path './.harness/baseline/*' -printf '%P\n' | sort) <(git ls-files '*.md' | grep -v '^.harness/baseline/' | sort) | wc -l`
  → **0** (kein Erwartungswert). Die Zusage ist trotzdem weiter als das, was gilt.
- **verifizierbar:** nein — die Aussage ist am `.gitignore` und an der porcelain-Semantik ablesbar.
- **klasse:** Zusage nennt einen Geltungsbereich, den der Code darunter nicht hält (`BEO-025`-Klasse)

### INFO-1 — `BEO-026` ist im Port behoben, im Register aber unverändert

- **kategorie:** INFO
- **quelle:** [Beobachtungs-Register](../plan/planning/observations.md), `BEO-026`
- **pfad:** `internal/archive/clean.go:24-27`, `:42-46`
- **befund:** `UnsauberGrund` meldet `untrackte(r) Eintrag/Eintraege` statt `Datei(en)`, mit
  Begründung im Kopf und mit `TestUnsauberGrundNenntEintragNichtDatei` als eigenem Wächter. Das ist
  der Ausgang des zweiten `BEO-026`-Fundes — allerdings nur für die Go-Fassung; der Träger
  (`harness/tools/archive-welle.sh:218`, `:222`) schreibt weiter `untrackte Datei(en)`. Die
  Registerzeile führt den Fund unverändert als offen. Ein Ausgang gehört in die Closure, nicht in
  diesen Diff — hier steht nur, dass die Lage sich bewegt hat.
- **verifizierbar:** nein
- **klasse:** —

### INFO-2 — Die Vorbild-Grenze aus Risiko 1 ist im Port geschlossen, nicht geerbt

- **kategorie:** INFO
- **quelle:** Slice-Plan §6, erstes Risiko
- **pfad:** `internal/archive/refs.go:24-35` (`ZaehlePraefix`)
- **befund:** Das Risiko sagt, der Port erbe die Grenze des Vorbilds, nach der ein
  Verzeichnis-Präfix-Verweis aus einer **Nicht-Wurzel**-Datei still übersehen wird. `ZaehlePraefix`
  ankert stattdessen mit einer Wortgrenzen-Regel am Literal `done/` und deckt damit jede
  Aufstiegstiefe; `TestZaehlePraefixAnDerWortgrenze` führt `[x](../../../docs/plan/planning/done/…)`
  als Fall. Der Ausgang dieses Risikos ist damit ein anderer als der im Plan vermutete — was er
  ist, entscheidet die Closure. Unberührt bleibt die eingehende Hälfte der präfixlosen Form
  (`BEO-003`), die `refs.go:71-74` als `GRENZE` benennt.
- **verifizierbar:** nein
- **klasse:** —

### INFO-3 — Die Abgrenzung gegen Festlegung 2 hält an einer prüfbaren Eigenschaft

- **kategorie:** INFO
- **quelle:** Slice-Plan §1 und §6, drittes Risiko · [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 2
- **pfad:** `Makefile:312-313`
- **befund:** Das Risiko antizipiert genau den Reviewer-Einwand, der Vorschau-Zweig sei die zweite
  Fassung der Operation. Er wird hier **nicht** erhoben: `make archive-welle` ist im Diff
  unverändert und fährt `harness/tools/archive-welle.sh`; `internal/archive` trägt in seinen
  Nicht-Test-Dateien keinen schreibenden Aufruf (nachgerechnet über
  `grep -nE 'os\.WriteFile|os\.MkdirAll|os\.Rename|os\.Remove|\.Create\(' internal/archive/*.go`,
  dessen drei Treffer alle in `_test.go` liegen — siehe MEDIUM-2); der einzige Fremdprozess ist
  `git status --porcelain` in `cmd/ai-harness-init/archive_welle.go:139-147`. Die Abgrenzung hängt
  damit an einer nachrechenbaren Eigenschaft, wie §1 es zusagt.
- **verifizierbar:** nein
- **klasse:** —

---

## Negativbefunde — geprüft, ohne Befund

- **`--vorschau`-Disziplin (Exit 2 vor jedem Baum-Zugriff).** Korrekt. `archiveWelle`
  (`cmd/ai-harness-init/archive_welle.go:57-88`) prüft `!vorschau` **vor** `repoWurzel()` und
  `gitStatusPorcelain()`; `parseArchiveWelle` berührt den Baum nicht. Kein Pfad erreicht
  `archive.Vorschau` ohne den Schalter. `TestArchiveWelleOhneVorschauSchreibtNichts` hält Exit-Code,
  leeres `stdout` und die Nennung des schreibenden Trägers.
- **Argument-Ausgänge.** `--vorschau` allein, zwei Kennungen, unbekanntes Flag und gar kein Argument
  enden je mit Exit 2 und Usage auf `stderr`; `--help` mit Exit 0 auf `stdout`. Ein Flag der Form
  `--vorschau=x` fällt in den Unbekannt-Zweig — fail-closed. Alles in
  `TestArchiveWelleAufrufFehler` / `TestArchiveWelleHelp` abgedeckt.
- **Die drei Verweis-Formen und ihre Suchräume.** Die Zuordnung in `fundIn` folgt der
  Markdown-Auflösungsregel: Präfix-Form überall, präfixlose nur aus `dir == done/`, aufsteigende nur
  aus `done/<welle-x>/`. `TestVerweisFundDreiFormenInIhremSuchraum` führt die Umkehr-Probe
  (präfixloses Ziel in `next/` wird **nicht** gezählt) und ist damit unter einer Mutation rot zu
  bekommen. Die Suffix-Grenze der Report-Zuordnung (`slice-001` trifft `slice-001a` nicht) ist in
  `ReviewTrifft` gezogen, in `TestReviewTrifftSuffixGrenze` an fünf Fällen geprüft — inklusive der
  Ziffern-Richtung `slice-0012` — und in `TestEinsammelnReviewsAnDerSuffixGrenze` über die
  Verdrahtung statt über die nachgebaute Regel gefahren. Zur Präfix-Auswahl siehe LOW-2, sie ist
  dort und nicht hier.
- **`test/mutations/232`–`236` als Mechanik.** Jeder `sed`-Ausdruck trifft im Zielstand genau eine
  Zeile (fünfmal `grep -c` über das jeweilige Muster → je **1**); `# verify: test-go` ist ein im
  Treiber geführter Modus (`sed -n 's/^# verify: //p' test/mutations/*.sh | sort | uniq -c` nennt
  ihn 27-fach) und `test-go` existiert als Target (`Makefile:62`). Jeder `# expect:`-Name existiert
  als Testfunktion. Die Fall-Köpfe begründen je, warum der Wächter kein Kosmetik-Test ist.
- **Sensor-Namen in Kommentaren.** Jeder in `internal/archive/*.go` und
  `cmd/ai-harness-init/archive_welle.go` genannte Test existiert
  (`TestKlasseVonMitgliedNenntDieWelle`, `…WellenlosOhneWelle`, `…FremdBleibtLiegen`,
  `TestReviewTrifftSuffixGrenze`, `TestUnsauberGrundZaehltUntrackte`,
  `TestHaengerFindetVerweisAusReviewReport`, `TestVorschauSperrtOhneUntergrenze`,
  `TestArchiveWelleOhneVorschauSchreibtNichts`) — der Prüfbereich von `make comment-claims` ist
  damit erfüllt.
- **[`AGENTS.md`](../../AGENTS.md) §3.2 (Lint-Suppression).** Keine. `git diff 3f3af46..HEAD | grep -nE '^\+.*(nolint|shellcheck disable)'`
  ist leer.
- **[`AGENTS.md`](../../AGENTS.md) §3.3 (Move und Inhalt getrennt).** Eingehalten: `3f3af46` ist der
  reine Move, `65d6bad` der Verweis-Nachzug, danach vier reine Inhalts-Commits.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 (Chronik in Kommentaren).** Keine Befund-Kennung, keine
  Slice-Nummer als Erzählung, kein Lauf-Protokoll in den neuen Kommentaren
  (`grep -nE '(#|//).*(Review-Befund|Runde |frueher|vorher stand)' internal/archive/*.go cmd/ai-harness-init/archive_welle.go test/mutations/23[2-6]-*.sh`
  → leer). Die Slice-Nummern in `collect.go` sind Beispiele für **Dateinamens-Formen**, keine
  Herkunft. Die Formulierung *„eine Messung von heute"* (`archive_welle.go:17`) ist zeitgebunden und
  am Rand der Regel; der tragende Mangel dieses Absatzes steht in MEDIUM-2.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 (Docker-only).** Der Diff fügt keine Host-Toolchain hinzu.
  Der einzige neue Fremdprozess ist `git status --porcelain` mit 30-s-Kontext-Timeout; `git` steht
  in [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).** Der Zweig
  wird nirgends als Gate geführt: kein neues `make`-Ziel, kein Eintrag in `gates`, und
  [`harness/README.md`](../../harness/README.md) sagt ausdrücklich *„kein Gate und in keiner
  Prerequisite-Kette"*. Die dort genannten Codepfade existieren.
- **Zahlen in `harness/README.md`.** Beide nachgerechnet: `grep -c 'Kennung: "' internal/archive/vorschau.go`
  → **8**, und die zehn Ausgänge des Helfers minus die zwei, die nicht am ruhenden Baum entstehen
  (fehlendes `WELLE=`, verletzte Stub-Form), ergeben genau diese acht. Beide stehen neben ihrem
  Kommando bzw. ihrer Herleitung ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
- **Reine Urteils-Logik ohne `git`.** Zutreffend: `porcelain` kommt als Wert in `archive.Vorschau`,
  und kein Test unter `internal/archive/` legt ein Repo an. Das ist die Eigenschaft, die
  [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) als *„der Prüfbereich
  wächst"* verspricht, und sie ist eingelöst.
- **Vier-Zahlen-Ausgabe gegen den Helfer.** Reihenfolge, Beschriftung und Bedeutung der vier
  Einsammel-Zahlen sind zeilenweise deckungsgleich mit `harness/tools/archive-welle.sh:644-648`;
  `TestSchreibeNenntDieVierZahlenUndDieSperren` hält sie als Literale. Die Divergenzen liegen
  außerhalb dieser vier Zahlen (HIGH-1, MEDIUM-1, LOW-1, LOW-3) — daher MEDIUM-4.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 1 | Suchraum an einer zweiten, unbenannten Achse verengt |
| **MEDIUM** | 4 | dieselbe Suchraum-Klasse (MEDIUM-1, ein Vorgang mit HIGH-1) · genannte Messung liefert nicht das behauptete Ergebnis · Dispatch-Zweig ohne Routing-Zahn · Vergleichs-Kriterium gegen ein Instrument, das nicht bis zur Messstelle läuft |
| **LOW** | 4 | Zähler-Label ohne Einheit (`BEO-026`-Nachbarschaft) · Grenze in einer von drei Zuordnungs-Stellen nicht gezogen · Suchraum enthält den eigenen Umzugsgegenstand · Zusage weiter als der Code (`BEO-025`-Klasse) |
| **INFO** | 3 | — |

**Wiederkehrende Klasse für die Closure §7.** Drei der neun Nicht-INFO-Findings — HIGH-1, MEDIUM-1
und LOW-4 — sind Instanzen von `BEO-025` (*eine Zusage nennt einen Geltungsbereich, den der Code
darunter nicht hält*), MEDIUM-2 kommt aus derselben Richtung. Das ist die Klasse, die schon die
zwei Review-Runden an `slice-170` getragen hat; ob sie damit einen Zähler-Schritt nimmt, entscheidet
die Closure, nicht dieser Report.

## Verdikt

**Blockierend.** Ein HIGH und vier MEDIUM stehen; nach `.harness/skills/reviewer.md` §Ablage
blockieren beide Kategorien typischerweise, und hier gibt es keinen Grund für eine Abweichung:
HIGH-1 macht die zentrale Aussage des Zweigs — *was die Archivierung täte* — im belegten Fall
falsch, und zwar in der fail-closed-Richtung, die [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md)
Abnahme-Kriterium 1 gerade sichern soll.

**Für den Acceptance-Trigger von [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md):**
Dieser Report ist **nicht** die dort verlangte Konsistenz-Runde. Er prüft den *Port* gegen den Plan,
nicht die *Entscheidung* gegen [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](../plan/adr/0003-go-native-binaries.md) und [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) —
das ist ein anderer Prüfgegenstand und gehört in einen eigenen Lauf. Kein Finding unten stellt die
Träger-Wahl in Frage; alle liegen in ihrer Umsetzung.

**Kein Rollen-Konflikt erkennbar.** Sollte die Implementation HIGH-1 mit Verweis auf eine
Plan-Aussage bestreiten, greift der Konflikt-Pfad aus Modul 8 (§Konflikt-Pfad als Rollen-Sequenz) —
Architect-Verdikt als Artefakt, nicht Herabstufung wegen Widerspruchs.
