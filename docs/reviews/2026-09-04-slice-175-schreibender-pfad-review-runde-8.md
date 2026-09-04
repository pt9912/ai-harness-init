# Review Runde 8 — slice-175, gezielte Nachprüfung der zwei Blocker aus Runde 7

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | **Schmale Runde, kein Voll-Review.** Nachprüfung der zwei Punkte, an denen Runde 7 blockierte, mit **selbst gebauten** Sonden. **Nicht** DoD-Abhakung und **keine** Gate-Lauf-Bestätigung (Verifier, Modul 11) |
| **Gegenstand** | `git show 987d520` — vier Dateien (`test/mutations/256-hostbin-zweite-nennung-in-derselben-zeile.sh` +18/−11, `test/unterkommando-kopplung.bats` +14/−2, `test/mutations/261-dispatch-marke-nur-im-kommentar.sh` neu, `harness/README.md` ein Absatz) |
| **Runde 7** | [`2026-09-04-slice-175-schreibender-pfad-review-runde-7.md`](2026-09-04-slice-175-schreibender-pfad-review-runde-7.md) — 0 HIGH, 1 MEDIUM, 1 LOW; Verdikt *nicht freigegeben* |
| **Plan** | [`docs/plan/planning/done/slice-175-archive-welle-schreibender-pfad.md`](../plan/planning/done/slice-175-archive-welle-schreibender-pfad.md) |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**`Proposed`**, Prüfmaßstab laut Plan), [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) (**`Accepted`**), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit); [`AGENTS.md`](../../AGENTS.md) §3.2, §3.6, §3.7, §3.8, §3.9 |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — **kein Beleg aus der Commit-Botschaft, keiner aus dem Verifier-Bericht und keiner aus den eigenen Reports der Runden 1–7 übernommen.** Jedes Rot und jedes Grün unten ist in dieser Sitzung selbst gefahren; das Kommando steht bei der Sonde |

**Wie gemessen wurde.** Elf `make test-bats`-Läufe über je einer **frischen Kopie des Baums außerhalb
des Repos** (`tar --exclude=.git --exclude=.harness/state`), dazu ein `make test-go` über einer der
mutierten Kopien. Alle Läufe Docker-only über `make` ([`AGENTS.md`](../../AGENTS.md) §3.9). Die Kopie
ist byte-gleich zum HEAD-Blob — `diff <(git show HEAD:<datei>) <kopie>` leer für
`test/unterkommando-kopplung.bats`, `Makefile`, `cmd/ai-harness-init/main.go`,
`.claude/settings.json` und die zwei Fall-Dateien. HEAD ist `007fdc7`;
`git diff --stat 987d520..HEAD -- test/ cmd/ Makefile harness/README.md .claude/settings.json` ist
leer, die Messungen gelten also unverändert für `987d520`.

**Ausgangs-Lauf, unmutiert (S0).** `1..212`, ein einziges
`not ok 127 driver: die Kopie traegt den Sensor-Bedarf inklusive .git` — ein Artefakt der Kopie ohne
`.git`, kein Befund. Beide Kopplungs-Fälle grün: `ok 211` (Makefile) und `ok 212`
(`.claude/settings.json`). Jedes Rot unten hebt sich gegen dieses Grün ab.

**`make mutate` habe ich nicht gefahren** — der Auftrag schließt es aus, der Beleg liegt beim
Verifier. Was unten steht, hängt an keiner seiner Zahlen: die zwei Fälle sind einzeln nachgestellt.

---

## Die elf Sonden dieser Sitzung

| # | Sonde | Ziel | Erwartet | Gemessen |
|---|---|---|---|---|
| S0 | unmutierte Kopie | Referenz | grün | **grün** — `ok 211`, `ok 212` |
| S1 | `bash test/mutations/256-….sh`, heutiger Sensor | trifft der Fall die Kalibrierung? | rot **über die Kalibrierung** | **rot** — Abbruch in `unterkommando-kopplung.bats:95`, *„aus 5 Nennung(en) in der Makefile sind 4 Name(n) gewonnen"* |
| S2 | Zeilen-Zählung wiederhergestellt **+** Fall `256` | Kopf-Aussage 3 des Falls | grün | **grün** — `ok 211` |
| S3 | Zeilen-Zählung, **ohne** Mutation | Kontrolle zu S2 | grün | **grün** — der Defekt ist am ruhenden Baum unsichtbar |
| S4 | Kalibrierungs-Block deaktiviert **+** Fall `256` | fällt der Fall **auch** über die Dispatch-Schleife? | grün, wenn nicht | **grün** — `ok 211`, die Schleife bleibt stumm |
| S5 | `bash test/mutations/261-….sh`, heutiger Sensor | greift die Verankerung? | rot **über die Schleife** | **rot** — Abbruch in `:104`, *„der Makefile gibt dem Traeger 'archive-welle', und main() dispatcht diesen Namen nicht"*, Dispatch-Auszug zeigt `case "archive-welle-neu":` |
| S6 | unverankerter Entscheidungs-Grep (Fassung vor `987d520`) **+** Fall `261` | Defekt reproduzieren | grün | **grün** — `ok 211`; die Zähne kommen aus diesem Commit |
| S7 | Mehrfach-Marke `case "archive-welle", "aw":` in `main.go` | benannte Grenze fail-closed? | rot | **rot** — *„gibt dem Traeger 'archive-welle'"*, die Marke fehlt auch im Diagnose-Auszug |
| S8 | Zweig zu `case "archive-welle-neu":` umbenannt **+** alte Marke in einem **Block**-Kommentar (`/* … */`) mit führendem Tabulator | ist die Kommentar-Blindheit geschlossen? | ? | **grün** — `ok 211`, während `make archive-welle` gebrochen ist; s. LOW-1 |
| S8′ | dieselbe Kopie, `make test-go` | zweiter Sensor | ? | **rot** — `--- FAIL:` in `TestArchiveWelleEchtSperrtAmUnsauberenArbeitsbaum`, `…AmHaengendenVerweis`, `…ArchiviertUndSetztZweiCommits` |
| S9 | `bash test/mutations/259-….sh`, heutiger Sensor | Bestand nach der Verankerung | rot | **rot** — *„gibt dem Traeger 'archive-welle2'"* |
| S10 | `bash test/mutations/257-….sh`, heutiger Sensor | Bestand nach der Verankerung | rot (212) | **rot** — *„.claude/settings.json gibt dem Traeger 'span-emitt'"* |

Die drei Sensor-Rückbauten sind je eine `sed`-Ersetzung: `nennungen` auf `grep -cE` (S2/S3), der
Kalibrierungs-Block auf `if false` (S4), der Entscheidungs-Grep zurück auf
`grep -qF "case \"$n\":" "$MAIN"` (S6).

---

## Findings

### LOW-1 — Der Zeilenanfangs-Anker schließt die `//`-Kommentarform, nicht die Block-Kommentarform; die Zusage daneben unterscheidet die beiden nicht

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Zusage* — die Zusage auf das
  einschränken, was der Code hält) · [`AGENTS.md`](../../AGENTS.md) §3.6 · Maintainability
- **pfad:** `test/unterkommando-kopplung.bats:66-74` (Zusage und Grenzen-Zeile) und `:78`
  (das Muster) · `harness/README.md:79`
- **befund:** Der Kommentarblock sagt, geprüft werde Mitgliedschaft in der Menge der `case`-Marken
  *„am Zeilenanfang … nicht das Vorkommen der Zeichenkette irgendwo in main.go: ein `case "…":` in
  einer KOMMENTAR-Zeile dispatcht nichts"*, und nennt daneben **eine** Grenze — die Mehrfach-Marke,
  fail-closed. Das Muster `^[[:space:]]*case "[^"]*":` unterscheidet aber nicht zwischen den zwei
  Kommentarformen von Go: eine `//`-Zeile fällt aus der Menge (S5, rot), eine Zeile **innerhalb**
  eines `/* … */`-Blocks nicht, weil vor `case` nur Leerraum steht. **Gemessen** (S8): Zweig zu
  `case "archive-welle-neu":` umbenannt und die alte Marke in einen Block-Kommentar derselben Datei
  gesetzt — `ok 211` bleibt stehen, obwohl `make archive-welle` in den Init-Pfad fällt. Die zweite
  Grenze zeigt also in die **entgegengesetzte** Richtung der einen benannten: die Mehrfach-Marke
  fällt fail-closed heraus, die Block-Kommentar-Marke fällt fail-open herein. Derselbe Satz steht
  in [`harness/README.md`](../../harness/README.md) als Erläuterung des Vergleichs. Der Restschaden
  ist begrenzt und ebenfalls gemessen: für `archive-welle` fällt derselbe Baum in `make test-go`
  mit drei `--- FAIL:` in `cmd/ai-harness-init/archive_welle_echt_test.go` (S8′), das den Träger als
  Prozess durch den echten Dispatch fährt; für `span-report` steht daneben nichts in `make gates`
  (unverändert der Stand aus Runde 7 LOW-1). Dass `cmd/ai-harness-init/main.go` heute keinen
  `/* … */`-Block führt, ist gemessen: `grep -nE '^[[:space:]]*/\*' cmd/ai-harness-init/main.go`
  liefert keinen Treffer (das ungeankerte `grep -nE '/\*|\*/'` liefert einen, und der ist das
  Glob-Muster `harness/mk/*.mk` in einer `//`-Zeile; keine Erwartungswerte, die Zahlen wandern mit
  der Datei). Über dem `switch` führt sie einen 36-zeiligen `//`-Block.
- **verifizierbar:** ja — `case "span-report":` umbenennen, die alte Marke in einen
  `/* … */`-Block derselben Datei setzen, dann `make test-bats`: heute grün.
- **klasse:** Eine Sensor-Zusage nennt einen Geltungsbereich weiter, als der Ausdruck darunter ihn
  hält ([`BEO-025`](../plan/planning/observations.md)) — **nicht** `BEO-009`: die Zusage entstand
  mit dem Ausdruck und war nie deckungsgleich

---

## Negativbefunde — geprüft, ohne Befund

- **Das MEDIUM aus Runde 7 ist geschlossen, und zwar in allen drei Kopf-Aussagen einzeln
  gemessen.** (1) *„eine, aus der das Namens-Muster nichts zieht"* — S1 zählt fünf Nennungen und
  vier Namen, die angehängte zweite Nennung gibt also keinen her. (2) *„ER TRIFFT DIE
  SELBST-KALIBRIERUNG, NICHT DIE DISPATCH-SCHLEIFE"* — S1 bricht in Zeile 95 ab (Kalibrierung),
  nicht in Zeile 104 (Schleife); und weil die Kalibrierung vor der Schleife zurückkehrt und ein
  Schleifen-Rot verdecken könnte, ist die Isolation eigens gefahren: mit deaktivierter Kalibrierung
  bleibt der Fall **grün** (S4), die Schleife sieht ihn also überhaupt nicht. (3) *„Zaehlte
  `nennungen` Zeilen statt Vorkommen, … bliebe der Fall unter genau dieser Mutation gruen"* — S2
  grün, mit S3 als Kontrolle, dass die Zeilen-Zählung allein nichts rot färbt. Der Fall
  unterscheidet die zwei Zählweisen wieder, und der Kopf sagt, was der Fall misst. Kein Befund.
- **Das LOW aus Runde 7 ist im behaupteten Umfang geschlossen.** Entscheidung und Diagnose lesen
  dasselbe Muster aus derselben Variablen (`:78`, gelesen in `:80` und `:103`), der Vergleich ist
  eine Mitgliedschaftsprüfung über einer Menge statt eines Substring-Treffers, und der neue Fall
  `261` färbt ihn rot (S5) — während die Fassung davor unter derselben Mutation grün bleibt (S6).
  Die eine im Text benannte Grenze hält wörtlich: die Mehrfach-Marke fällt fail-closed heraus (S7).
  Was offen bleibt, steht in LOW-1 und ist eine **zweite**, nicht benannte Grenze, kein Rückschritt.
  Kein Befund an der Verankerung selbst.
- **Die Verankerung nimmt dem Bestand keine Zähne.** Die zwei Fälle, die über die Dispatch-Schleife
  fallen müssen, färben unter dem neuen Vergleich weiter rot: `259` am `Makefile` (S9) und `257` am
  Hook-Kanal (S10), beide mit dem konkreten Namen in der Meldung. Der Ausgangs-Lauf S0 zeigt außer
  dem Kopie-Artefakt `127` keinen weiteren Fehlschlag über alle 212 Fälle. Kein Befund.
- **Die Meldung ist lesbar, nicht nur rot** ([`AGENTS.md`](../../AGENTS.md) §3.6). In S5, S7, S9 und
  S10 nennt die Ausgabe den Namen, den der Aufrufer gibt, die Folge im Träger (Positionsargument des
  Init-Pfads, Exit 2) und den heutigen Dispatch als Zeilen-Auszug; in S1 die zwei Zahlen und die
  fünf Nennungs-Zeilen des `Makefile`. In S7 fehlt die Mehrfach-Marke folgerichtig auch im
  Diagnose-Auszug, weil Entscheidung und Diagnose dasselbe Muster lesen. Kein Befund.
- **Die neue Zusage in `harness/README.md` trifft das Gemessene.** Der geänderte Absatz sagt
  *„Verglichen wird gegen die Menge der `case`-Marken am Zeilenanfang — Mitgliedschaft, nicht das
  Vorkommen der Zeichenkette irgendwo in der Datei"* (S5/S6), nennt `261` als den Fall, der genau
  dieser Unterscheidung die Zähne nimmt (S5), und die Mehrfach-Marke als fail-closed (S7). Alle drei
  Aussagen sind selbst nachgestellt. Die Einschränkung, die dem Absatz fehlt, steht in LOW-1.
  Sonst kein Befund.
- **Kein Artefakt einer fremden Rolle angefasst** ([`AGENTS.md`](../../AGENTS.md) §3.8).
  `git show --name-only --pretty=format: 987d520` nennt vier Dateien — `harness/README.md`, zwei
  Fall-Dateien und die bats-Datei — und trifft weder `AGENTS.md` noch `harness/conventions*`, weder
  `docs/plan/adr/` noch `docs/plan/planning/` noch `.claude/commands/`. Kein Befund.
- **Lint-Suppression-Verbot** ([`AGENTS.md`](../../AGENTS.md) §3.2).
  `git show 987d520 | grep -nE '^\+.*(nolint|shellcheck disable|d-check:ignore)'` ist leer, und
  selbst gefahrenes `make shell-lint` läuft mit Exit 0 — es führt `test/mutations/*.sh` in seiner
  Datei-Liste, also auch den neuen Fall `261` mit seinen zwei `sed`-Ausdrücken. Kein Befund.
- **Die neuen Kommentare tragen ihre Klasse und keine Chronik**
  ([`AGENTS.md`](../../AGENTS.md) §3.7). Die Blöcke in `test/unterkommando-kopplung.bats:66-74`,
  im Kopf von `256` und im Kopf von `261` stehen im Indikativ und tragen Zusage, Kopplung, Grenze
  und Rang-Zeiger; der Satz *„die Zahlen wachsen mit dem Makefile"* im Kopf von `256` vermeidet den
  Erwartungswert. `git show 987d520 -- '*.sh' '*.bats' | grep -nE '^\+[[:space:]]*#.*(Review-Befund|Runde [0-9]|MEDIUM-|HIGH-|frueher|bis slice|vorher)'`
  ist leer. Kein Befund.
- **Der Arbeitsbaum ist übergabefähig.** Selbst gefahren: `make docs-check` **594 Datei(en)
  geprüft, 0 Befund(e)**, `make shell-lint` Exit 0. `git status -sb` führt eine einzige untrackte
  Datei, den Verifikations-Report dieses Slice. Kein Befund.

**Nicht geprüft, weil nicht Reviewer-Rolle:** die DoD-Abhakung, `make gates` als Ganzes,
`make mutate`, `make full-smoke`, `make lint`, und ob
[ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) ihren Acceptance-Trigger
erreicht hat.

**Nicht geprüft, weil schmale Runde:** alles, was Runde 7 als *nicht neu geprüft, unverändert
delegiert* führt — MEDIUM-5 aus Runde 1 (`.claude/commands/close-welle.md` nennt Schritt 4 als
Handarbeit und das Ziel gar nicht, **Planner**), MEDIUM-3 und MEDIUM-4 aus Runde 2, LOW-1 aus
Runde 4 (Deckungs-Grenze des Feldes `schreibend`), LOW-1 und INFO-1 aus Runde 5 sowie LOW-1 und
INFO-1 aus Runde 6. Der Diff von `987d520` berührt keinen dieser Punkte.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| **HIGH** | 0 | — |
| **MEDIUM** | 0 | — |
| **LOW** | 1 | Eine Sensor-Zusage nennt einen Geltungsbereich weiter, als der Ausdruck darunter ihn hält |
| **INFO** | 0 | — |

**Geschlossen aus Runde 7:** MEDIUM-1 (das Gegenbeispiel misst wieder seine Eigenschaft) mit vier
eigenen Sonden einschließlich der geforderten Isolation, und LOW-1 (Verankerung) mit reproduziertem
Defekt davor.

**Warum LOW-1 dieser Runde nicht höher steht.** Der HIGH-Anker der Skill-Datei nennt den
*Stillen-Grün-Pfad in einem Gate*, und S8 ist einer. Drei gemessene Umstände halten ihn unten:
`cmd/ai-harness-init/main.go` führt heute keinen Block-Kommentar, für den Slice-Gegenstand
`archive-welle` färbt derselbe Baum in `make test-go` rot (S8′) — beides in **derselben** Gate-Kette,
`test` führt `test-bats` und `test-go` —, und der Vorgänger-Befund derselben Familie stand in
Runde 7 mit dem breiteren Pfad (jedes Vorkommen, auch `//`) bereits als LOW im Protokoll. Ihn jetzt
für den **engeren** Restpfad höher einzustufen wäre eine Verschärfung ohne neue Messung. Wer diese
Einschätzung nicht teilt, geht den Konflikt-Pfad aus Modul 8, nicht den Weg über die Kategorie.

**Fünfte Runde an derselben Familie, und die Bewegung ist beendet.** Runde 4 fand den `Makefile`
ungekoppelt, Runde 5 die Kalibrierung über der falschen Zählgröße, Runde 6 das Namens-Muster über
der falschen Zeichenklasse, Runde 7 das Gegenbeispiel mit gewechseltem Zweig. Runde 8 findet an der
reparierten Stelle **keinen** Rückschritt: die zwei Zählweisen sind wieder unterscheidbar, der
Vergleich ist eine Mitgliedschaftsprüfung, und der Bestand behält seine Zähne. Was bleibt, ist eine
Grenze des Ausdrucks, die der Text daneben nicht nennt — die schwächste Form dieser Familie
bisher. **Ob** ein Zähler-Schritt auf [`BEO-025`](../plan/planning/observations.md) fällt und was er
auslöst, entscheidet die Closure und nicht dieser Report.

---

## Verdikt

**Freigegeben für Verifikation und Closure.** Beide Punkte, an denen Runde 7 blockierte, sind
geschlossen — jeder mit einer selbst gebauten Sonde und einem reproduzierten Defekt daneben, keiner
auf Zusage des Fall-Kopfes oder der Commit-Botschaft hin:

- **`test/mutations/256` misst wieder seine Eigenschaft, und nur sie.** Es fällt über die
  Selbst-Kalibrierung (S1), unter Zeilen-Zählung bleibt es grün (S2, mit Kontrolle S3), und mit
  deaktivierter Kalibrierung erreicht es die Dispatch-Schleife nicht (S4). Der Zweigwechsel, den
  Runde 7 gemessen hatte, ist rückgängig; die drei Aussagen des Kopfes sind einzeln nachgestellt
  und treffen zu.
- **Der Dispatch-Vergleich ist verankert, und die Verankerung trägt.** Der neue Fall `261` färbt
  ihn rot (S5), die Fassung davor bleibt unter derselben Mutation grün (S6), die im Text benannte
  Mehrfach-Marken-Grenze hält fail-closed (S7), und die bestehenden Fälle `257`/`259` bleiben rot
  (S9, S10). Entscheidung und Diagnose lesen dasselbe Muster aus einer Variablen — die
  Strenge-Differenz aus Runde 7 besteht nicht mehr.

**Der eine LOW blockiert nicht** (Skill-Datei §Ablage: HIGH und MEDIUM blockieren typischerweise).
Er benennt eine zweite Grenze des Zeilenanfangs-Ankers, die der Text daneben nicht führt, und liegt
in derselben Gate-Kette, die den Fall für `archive-welle` über `make test-go` auffängt (S8′).

**Was trägt.** Vier Dateien, alle in Implementer-Hoheit; keine Lint-Suppression dazugekommen; kein
neuer Kommentar trägt Chronik; `docs-check` 594/0 und `shell-lint` Exit 0 selbst gefahren; der
Arbeitsbaum trägt nur den Verifikations-Report als untrackte Datei.

**Kein Rollen-Konflikt erkennbar.**
