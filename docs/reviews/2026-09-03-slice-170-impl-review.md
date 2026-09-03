# Review — slice-170 (Das Archivierungs-Werkzeug der Wellen-Closure)

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 8/10) — frischer Kontext, getrennt von Implementation, Architektur und Planung |
| **Review-Art** | Code-Review — Diff gegen Plan, aktive ADRs und Hard Rules. **Nicht** DoD-Abhakung (Verifier, Modul 11) |
| **Gegenstand** | `git diff 98b9e90..0d4029e` — 12 Dateien, `924 Zeilen(+) / 15 Zeilen(-)`; die vier Commits seit dem Move nach `in-progress/`: `48351df` (Verweis-Nachzug des Move), `2aa36e8`, `4827584`, `0d4029e` |
| **Plan** | [`docs/plan/planning/in-progress/slice-170-archivierungs-werkzeug.md`](../plan/planning/in-progress/slice-170-archivierungs-werkzeug.md) |
| **Bindende ADRs** | keine — kein Commit dieses Slice nennt eine ADR-ID, `docs/plan/adr/` ist nicht berührt (`git diff --name-only 98b9e90..HEAD -- docs/plan/adr/` leer) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`AGENTS.md`](../../AGENTS.md) §3.1, §3.2, §3.3, §3.6, §3.7, §3.9 |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-08-31-slice-144-review.md` zum Präzedenz-Werkzeug `harness/tools/slice-mv.sh` (HIGH-1 Rollen-Eigentum, MEDIUM-1 Plan-Prosa weiter als DoD-Text, LOW-1 gedriftete Zahl). Das Muster *„die Zusage im Kopf ist weiter als das, was der Code hält"* wiederholt sich hier (HIGH-2, HIGH-3, MEDIUM-3) |
| **Skill-Version** | `.harness/skills/reviewer.md` 1.6.0 |
| **Modell** | Claude Opus 5 (1M context) |
| **Kontext frisch** | ja — keine Einschätzung des Implementers ungeprüft übernommen; jede Zahl und jede Mengen-Aussage unten in dieser Sitzung selbst gemessen, das Kommando steht beim Befund |

**Was in diesem Lauf gefahren wurde.** `make shell-lint` (clean, EXIT 0) · `make comment-claims`
(48/0) · `docker run … bats … test/archive-welle.bats` (21/21 `ok`) · `make docs-check` über einem
frischen Klon (569 Dateien, 0 Befunde) als Referenz-Grün. Dazu **vier eigene Scratch-Repos** mit
echten `git`- und `docker`-Läufen von `main()` (Einsammel-Regel über drei Klassen, Zwei-Commit-
Sequenz, Verweis-Nachzug, Doppel-Archivierung in Folge, untrackter Fremdbestand) und **drei
Sonden-Läufe** von `make docs-check` im Klon zur unabhängigen Nachmessung der zwei behaupteten
`.d-check.yml`-Kopplungen. Die vier neuen Mutations-Fälle wurden einzeln auf Kopien angewendet und
ihr Biss direkt an den mutierten Funktionen abgelesen. Alle Arbeitskopien liegen außerhalb des
Repos; der Arbeitsbaum dieses Repos ist unverändert (`git status --short` vor und nach dem Lauf
leer).

---

## Findings

### HIGH-1 — Der Wächter gegen „lebender Verweis auf einen zu löschenden Review-Report" schließt genau das Verzeichnis aus, in dem 83 solcher Verweise stehen

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage ohne rot gesehenes Gegenbeispiel);
  Präzedenzfall `harness/tools/slice-mv.sh` Zeilen 195–204, der dieselbe Entscheidung
  ausdrücklich **umgekehrt** trifft und begründet
- **pfad:** `harness/tools/archive-welle.sh:482`
- **befund:** Die Vorprüfung sucht lebende Verweise auf jeden Report, der gelöscht werden soll, mit
  `git grep -l -F -e "$rb" -- ':!.harness/baseline' ':!docs/reviews'` — der zweite Pathspec nimmt
  `docs/reviews/**` aus, ohne dass Kommentar, Skriptkopf oder `harness/README.md` einen Grund dafür
  nennen. Gemessen: **83** der 250 Report-Dateien sind Ziel eines echten Markdown-Links aus einem
  *anderen* Report
  (`for r in docs/reviews/*.md; do rb=$(basename "$r"); grep -rlF -e "]($rb)" docs/reviews/ | grep -v "^$r$"; done | ...`),
  und diese Verweise reisen quer über Wellen-Grenzen — etwa
  `2026-07-23-slice-034-review.md` (slice-034, `welle-05`) → `2026-07-22-slice-032-review.md`
  (slice-032, `welle-04`). `links`/`anchors` tragen für `docs/reviews/**` **keine** Ausnahme (nur
  `codepaths` und `ids` haben eine, `.d-check.yml`) — genau das steht als Begründung im
  Präzedenz-Skript. Rot gesehen: im Klon `git rm docs/reviews/2026-07-22-slice-032-review.md`,
  danach `make docs-check` → `docs/reviews/2026-07-23-slice-034-review.md:16 … target-missing`.
  Failure-Szenario: die Archivierung von `welle-04` meldet „ok", setzt zwei Commits, und
  `make docs-check` ist danach rot an einer Stelle, die der eigens dafür gebaute fail-closed-Ausgang
  vorher hätte melden sollen — der Wächter war grün, weil er dort nicht hinsieht.
- **verifizierbar:** ja — `make docs-check` nach einem `git rm` auf einen der 83 Reports; der
  Befund erscheint, während `archive-welle` denselben Fall nicht meldet
- **klasse:** Fail-closed-Wächter schließt per Pathspec genau die Population aus, gegen die er
  schützen soll

### HIGH-2 — Die Zusage „sauberer Arbeitsbaum" deckt untrackte Dateien nicht, und `git add -A` nimmt sie in den Closure-Commit

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 („die Zusage auf das einschränken, was der Code
  hält"), §3.3; Präzedenzfall `harness/tools/slice-mv.sh:221-228`
- **pfad:** `harness/tools/archive-welle.sh:35-37` (VORAUSSETZUNG), `:394` (Prüfung), `:583`
  (`git add -A`)
- **befund:** Der Skriptkopf sagt zu: *„verlangt darum einen sauberen Arbeitsbaum … sonst landet
  ein fremder Diff im Move- oder im Inhalts-Commit. Ein Verstoss bricht den Aufruf vor dem ersten
  `git mv`."* Die Prüfung dahinter ist `git diff --quiet || git diff --cached --quiet` — beide
  sehen **nur getrackte** Dateien. Commit 2 wird mit `git add -A` gesetzt, also über den gesamten
  Baum. Gemessen an einem Scratch-Repo mit zwei untrackten Dateien (`FREMDE-UNTRACKED-DATEI.txt`,
  `scratch/notiz.md`) vor dem Lauf: der Aufruf bricht **nicht** ab, und `git show --stat HEAD`
  führt beide Dateien im Inhalts-Commit neben `archiv.zip` und den Stubs. Das Präzedenz-Werkzeug
  schränkt dieselbe Zusage ausdrücklich auf getrackte Dateien ein („keine gestagten oder
  ungestagten Aenderungen an getrackten Dateien") **und** stagt mit expliziten Pfaden statt `-A`,
  mit derselben Begründung im Kommentar; die Abweichung ist unbegründet. Failure-Szenario: der
  Wave-Self-Close-Commit — der eine Punkt, an dem der Audit die Welle schließen sieht (Modul 6,
  Schritt 4) — trägt fremden Inhalt, den niemand in einem Archivierungs-Commit sucht.
- **verifizierbar:** ja — Scratch-Repo, untrackte Datei anlegen, `make archive-welle` fahren,
  `git show --stat HEAD` lesen
- **klasse:** Vorbedingungs-Zusage ist weiter als ihre Prüfung (untrackt ≠ unsauber)

### HIGH-3 — Das Werkzeug schreibt selbst eine Verweis-Form, die es beim nächsten Lauf bricht und die in der Fünfer-Grenzen-Liste nicht steht

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6, §3.7 (Grenze als Kommentar-Klasse — sie muss
  halten, was sie abgrenzt); Skriptkopf `# GRENZEN (fuenf, gemessen)`
- **pfad:** `harness/tools/archive-welle.sh:278` (erzeugt `../<datei>.md`), `:576` (Nachzug scannt
  nur `"$DONE"/*.md`), `:91-114` (Grenzen-Liste)
- **befund:** `slice_pfad_relativ` liefert für einen Folge-Slice, der noch flach in `done/` liegt,
  den Pfad `../<datei>.md`; `feld_hervorgegangen` schreibt ihn als Markdown-Link in den Stub unter
  `done/<welle-id>/`. Beim **nächsten** Archivierungslauf wandert dieses Ziel eine Ebene tiefer,
  und keine der beiden Ersetzungen greift: `rewrite_incoming_in_file` ankert am Literal `done/`
  (im Stub steht `../`), `rewrite_bare_sibling_in_file` wird nur über die **flachen**
  `"$DONE"/*.md` geführt und sieht Dateien in `done/<welle-id>/` nie. Gemessen an einem
  Scratch-Repo mit zwei Wellen: nach Archivierung von `welle-11` steht im Stub
  `**Hervorgegangen:** [slice-501](../slice-501-b.md)`; nach Archivierung von `welle-12` liegt das
  Ziel unter `done/welle-12/slice-501-b.md`, der Stub-Link steht unverändert, und der zweite Lauf
  meldet dazu „0 Datei(en) mit Praefix-Form, 0 geschwister-relative Ziel(e)". Grenze 3 grenzt den
  ungedeckten Rest ausdrücklich auf *Inline-Code ohne Verzeichnis-Segment* ein — hier bricht ein
  echter Markdown-Link, den `docs-check` prüft. Die Liste sagt „fünf, gemessen"; diese sechste ist
  gemessen und fehlt.
- **verifizierbar:** ja — zwei Archivierungsläufe hintereinander, danach `make docs-check`
  (`target-missing` auf den Stub-Link)
- **klasse:** Grenzen-Liste behauptet Vollständigkeit, während das Werkzeug die fehlende Klasse
  selbst erzeugt

### MEDIUM-1 — Review-Reports werden über einen Nummern-Substring eingesammelt: Doppelzählung und Fremd-Slice-Treffer, und die Zahl landet im Welle-Stub

- **kategorie:** MEDIUM
- **quelle:** Maintainability; Ziel-Form `archiv-stub-welle.template.md` (Bedienhinweis: *„`Archivierte Vorgaenge` ist die Zahl, gegen die sich die Vollstaendigkeit des Archivs abzaehlen laesst"*)
- **pfad:** `harness/tools/archive-welle.sh:245-248` (`slice_nummer`), `:466-472` (Sammelschleife),
  `:556` (Zahl in den Welle-Stub), `:588` (Zahl in die Lauf-Ausgabe)
- **befund:** `slice_nummer` verwirft den Buchstaben-Suffix (`slice-001a-cli-skeleton.md` → `001`,
  gemessen), und die Sammelschleife globbt damit `docs/reviews/*slice-001*.md`. Zwei Folgen, beide
  gemessen: (a) **Doppelzählung** — für `slice-001a` und `slice-001b` läuft derselbe Glob zweimal;
  über den realen `done/`-Bestand liefert die Sammelregel **210** Einträge auf **199** eindeutige
  Dateien
  (`for f in docs/plan/planning/done/slice-*.md; do … ls docs/reviews/*slice-$nr*.md; done | wc -l`
  gegen dieselbe Pipeline mit `| sort -u | wc -l`). Im Scratch-Lauf schrieb der Welle-Stub
  `**Archivierte Vorgänge:** 3 Slices, 7 Reviews`, während `unzip -l` genau **4** Report-Dateien im
  Archiv führt. (b) **Fremd-Treffer** — die Nummer `001` zieht auch die Reports von `slice-001b`
  ein; im Bestand gibt es vier solche Paare (`001a/b`, `004a/b`, `022a/b`, `045a/b`). Liegen die
  zwei Hälften in verschiedenen Wellen, löscht die erste Archivierung die Reports der zweiten.
  Failure-Szenario: die einzige Zahl, gegen die sich die Vollständigkeit eines opaken Zip abzählen
  lässt, ist zu groß — und kein Gate liest ins Zip hinein, um es zu bemerken.
- **verifizierbar:** ja — Scratch-Lauf mit zwei suffixierten Slices; `unzip -l archiv.zip` gegen
  die Zahl im Welle-Stub halten
- **klasse:** Nummern-Extraktion verwirft den Buchstaben-Suffix — Identität und Mengen kollabieren

### MEDIUM-2 — Zwei Stubs derselben Welle tragen dieselbe Identität, und keine davon ist die des archivierten Slice

- **kategorie:** MEDIUM
- **quelle:** Maintainability; Ziel-Form `archiv-stub-slice.template.md` (der Stub trägt
  *„Identitaet, Archiv-Zeiger, Zustand, und die Kennungen"*)
- **pfad:** `harness/tools/archive-welle.sh:530` (`nummer="$(slice_nummer "$base")"`), `:541`
  (`"s#<NNN>#$nummer#g"`)
- **befund:** Die H1 des Stubs wird aus `<NNN>` gebaut, und `<NNN>` ist die suffixlose Nummer.
  Gemessen im Scratch-Lauf: `done/welle-01/slice-001a-erster.md` beginnt mit
  `# slice-001 — Erster Teil`, `done/welle-01/slice-001b-zweiter.md` mit
  `# slice-001 — Zweiter Teil` — zwei Dateien im selben Verzeichnis, dieselbe behauptete Kennung,
  und beide nennen einen Slice, den es nicht gibt. Der Volltext liegt danach nur noch im opaken
  Zip; der Stub ist die einzige lesbare Identität. `stub_form_ok` prüft Archiv-Zeiger und
  Abwesenheit von `##` und sieht die H1 nicht. Im Bestand sind vier Paare betroffen; die
  Archivierung von `welle-01` und `welle-02` trifft sie sicher.
- **verifizierbar:** ja — Archivierungslauf über eine Welle mit einem `NNNa`/`NNNb`-Paar, danach
  `head -n1` auf die zwei Stubs
- **klasse:** Nummern-Extraktion verwirft den Buchstaben-Suffix — Identität und Mengen kollabieren

### MEDIUM-3 — `titel_von` sagt vier H1-Formen zu; zwei sind getestet, und eine der ungetesteten liefert unter `LC_ALL=C` einen zerhackten Titel

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6;
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- **pfad:** `harness/tools/archive-welle.sh:250-258`, `test/archive-welle.bats:132-143`
- **befund:** Der Funktionskommentar sagt zu: *„Getroffen werden die Formen `# Slice slice-NNN: T`,
  `# slice-NNN — T`, `# Welle welle-NN: T` und `# welle-NN — T`"*. Die zwei bats-Fälle prüfen
  ausschließlich die Doppelpunkt-Formen. Die Gedankenstrich-Formen laufen über die
  Klammer-Ausdrucks-Alternative `[:—-]`, in der ein Drei-Byte-Zeichen steht. Gemessen: unter
  `LC_ALL=C` liefert `titel_von` für `# slice-901 — Ein Titel mit Gedankenstrich` den Wert
  `\x80\x94 Ein Titel mit Gedankenstrich` statt `Ein Titel mit Gedankenstrich`; im UTF-8-Locale des
  Prüfrechners ist die Ausgabe korrekt. Das Skript läuft auf dem **Host** (nur das Packen geht in
  den Container), das Ergebnis hängt also am Locale des Aufrufers. Heute ist die Form latent — alle
  171 Slice-H1 und alle Welle-Plan-H1 tragen den Doppelpunkt
  (`for f in docs/plan/planning/*/slice-*.md; do head -n1 "$f"; done | …`); die Zusage ist
  trotzdem unbedingt formuliert und ohne rot gesehenes Gegenbeispiel.
- **verifizierbar:** ja — `LC_ALL=C bash -c 'source harness/tools/archive-welle.sh; titel_von <datei>'`
  über einer H1 mit Gedankenstrich
- **klasse:** Kommentar-Zusage nennt mehr Fälle, als Test und Locale-Annahme tragen

### LOW-1 — Die Verweis-Zahl der Lauf-Ausgabe heißt „Datei(en)" und zählt Paare aus Datei × bewegter Datei

- **kategorie:** LOW
- **quelle:** Maintainability
- **pfad:** `harness/tools/archive-welle.sh:567-572`, Ausgabe `:589`
- **befund:** `praefix_treffer` wird je bewegter Datei um jede Fundstelle erhöht; die Ausgabe
  schreibt `$praefix_treffer Datei(en) mit Praefix-Form`. Gemessen an einem Scratch-Repo, in dem
  **eine** Datei Präfix-Verweise auf **zwei** bewegte Dateien trägt: der Lauf meldet
  „2 Datei(en) mit Praefix-Form", während `git show --stat` genau eine geänderte Fremd-Datei
  ausweist. Failure-Szenario: wer die Meldung gegen `git show --stat` hält, findet eine Differenz
  und sucht sie im Archiv statt im Zähler. Der Präzedenzfall `slice-mv.sh` zählt für **eine**
  bewegte Datei und ist deshalb dort korrekt.
- **verifizierbar:** ja — Scratch-Lauf mit zwei bewegten Dateien und einer referenzierenden Datei
- **klasse:** Zähler-Label nennt eine andere Einheit als der Zähler zählt

### LOW-2 — Eine zeitgebundene Zustands-Aussage steht zweimal, in zwei Artefakten, ohne Sensor

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Zustand statt Chronik; eine Aussage hat einen
  Ort)
- **pfad:** `harness/tools/archive-welle.sh:83-89` und
  [`harness/README.md`](../../harness/README.md):81
- **befund:** Beide Stellen sagen — mit eigenen Worten und eigenen Belegen — dasselbe: das Werkzeug
  sei „auf keine Welle dieses Repos anwendbar", weil beide `exit 3`-Ausgänge über einem Klon
  greifen. Die Aussage ist heute richtig (in dieser Sitzung nachgemessen:
  `make archive-welle WELLE=welle-01` im Klon meldet „42 wellenlose Slice(s) … kein
  `done/*/archiv.zip`" und endet mit `Fehler 3`), wird aber mit der ersten Altbestands-Archivierung
  falsch. Kein Gate liest sie; zwei Fassungen derselben Zustandsaussage driften unabhängig
  voneinander.
- **verifizierbar:** nein — kein Gate im Repo prüft Zustandsaussagen in Prosa; der Befund ist an
  der Doppelung ablesbar
- **klasse:** Zeitgebundene Zustandsaussage doppelt abgelegt, ohne Träger für ihre Auflösung

### LOW-3 — Skriptkopf und bats-Dateiende zählen dieselbe Menge verschieden (neun gegen „die vier")

- **kategorie:** LOW
- **quelle:** Maintainability;
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 (Zahl neben ihrem Kommando)
- **pfad:** `harness/tools/archive-welle.sh:69-82` gegen `test/archive-welle.bats:218-224`
- **befund:** Der Skriptkopf zählt **neun** `exit`-Ausgänge und liefert das Kommando dazu
  (nachgemessen: `grep -vE '^[[:space:]]*#' harness/tools/archive-welle.sh | grep -cE '\bexit [0-9]'`
  → `9`, und die Einzelaufzählung deckt sich). Das Dateiende von `test/archive-welle.bats` spricht
  von „**die vier** fail-closed-Ausgaenge" und nennt vier davon. Ein Kriterium, das genau diese
  vier von den übrigen fünf trennt, steht nirgends — „Ergebnisnotiz fehlt", „kein Welle-Plan",
  „mehrdeutiger Welle-Plan" und „kein Slice eingesammelt" liegen ebenso hinter der `git`-Prüfung.
  Failure-Szenario: wer beim Erweitern nur die bats-Datei liest, sucht vier Ausgänge und übersieht
  fünf.
- **verifizierbar:** nein — kein Gate hält die zwei Aufzählungen gegeneinander
- **klasse:** Dieselbe Menge in zwei Artefakten getrennt ausgezählt, ohne gemeinsame Quelle

### INFO-1 — Der dokumentierte „zehnte Abbruch" hinterlässt einen Zustand, in den das Werkzeug selbst nicht zurückkehrt

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `harness/tools/archive-welle.sh:80-82`, `:546`, `:557`
- **befund:** Schlägt `stub_form_ok` an, beendet `set -e` den Lauf — das benennt der Kopf. Zu
  diesem Zeitpunkt ist Commit 1 gesetzt, `done/<welle-id>/archiv.zip` liegt geschrieben im Baum und
  die Stubs stehen ungestagt daneben. Ein zweiter Aufruf scheitert dann an zwei eigenen
  Vorprüfungen zugleich („Arbeitsbaum nicht sauber", „diese Welle ist archiviert"). Ein
  Wiederanlauf-Weg steht in keinem der beiden Artefakte.
- **verifizierbar:** nein — der Pfad ist nur über eine mutierte Vorlage erreichbar
- **klasse:** Abbruch ohne benannten Wiederanlauf

### INFO-2 — Ein Review-Report über mehrere Slices wird von der Einsammel-Regel nie getroffen

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `harness/tools/archive-welle.sh:24-33` (Einsammel-Regel), `:469`
- **befund:** Die Regel greift auf `*slice-<nr>*`; `docs/reviews/2026-07-17-slices-011-014-plan-review.md`
  trägt die Plural-Form und enthält keinen der vier `slice-011`…`slice-014`-Substrings
  (`ls docs/reviews/ | grep -E 'slices-'` → genau diese eine Datei). Der Report bleibt flach liegen,
  während seine vier Slices ins Archiv gehen. Das ist vertretbar (er gehört keinem einzelnen
  Slice), steht aber in keiner der fünf Grenzen.
- **verifizierbar:** nein — die Datei bleibt schlicht liegen, ohne dass etwas rot wird
- **klasse:** Sammelregel adressiert Einzel-Slices, Sammel-Artefakte fallen unbenannt heraus

---

## Negativbefunde

- **[`AGENTS.md`](../../AGENTS.md) §3.3 (Move und Inhalt = zwei Commits):** geprüft, kein Befund.
  Am Scratch-Lauf abgelesen: `git show --stat` auf Commit 1 zeigt vier reine Renames,
  `0 insertions(+), 0 deletions(-)`; Commit 2 trägt Archiv, Stubs und Nachzug. Der Slice selbst
  hält die Regel ebenfalls — `98b9e90` (Move) und `48351df` (Verweis-Nachzug) sind getrennt.
- **[`AGENTS.md`](../../AGENTS.md) §3.2 (Lint-Suppression):** geprüft, kein Befund. Kein
  `# shellcheck disable` und kein `//nolint` in den acht neuen/geänderten Dateien;
  `# shellcheck source=/dev/null` in `test/archive-welle.bats:17` ist eine Quell-Direktive, keine
  Unterdrückung, folgt `test/slice-mv.bats:23` und liegt ohnehin außerhalb des `shell-lint`-Umfangs.
  `make shell-lint` in dieser Sitzung gefahren, EXIT 0.
- **[`AGENTS.md`](../../AGENTS.md) §3.9 / [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten):**
  geprüft, kein Befund. Auf dem Host laufen nur `git`, `bash`, `sed`, `awk`, `grep`; gepackt wird im
  digest-gepinnten `ARCHIVE_IMAGE` mit `--network none` über einen `:ro`-Mount. Kein
  Paketmanager, keine Sprach-Toolchain. Dass für die vier weiteren gepinnten Bilder
  (`BATS_IMAGE`, `SHELLCHECK_IMAGE`, `ACTIONLINT_IMAGE`, `DCHECK_IMAGE`) ebenfalls keine
  Freshness-Achse existiert, macht das Fehlen einer für `ARCHIVE_IMAGE` zum Muster, nicht zur
  Abweichung.
- **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  geprüft, kein Befund. `archive-welle` steht in `.PHONY`, aber in keiner Voraussetzungsliste von
  `record-gates`/`gates` (`sed -n '/^record-gates:/,/^$/p' Makefile | grep -c archive-welle` → `0`).
  Beide Beschreibungen — Makefile-Zeile und `harness/README.md` — sagen „NICHT in gates".
- **[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), Byte-Gleichheit des
  Archivs:** geprüft, kein Befund. Zwei `git archive --format=zip`-Läufe über demselben
  Tree-Operanden, zwei Sekunden auseinander, liefern denselben `sha256sum`; die Zip-Einträge tragen
  die Commit-Zeit, nicht die Uhr des Laufs (`unzip -l` gegen die Commit-Zeit von HEAD gehalten). Der
  Risiko-Ausgang „entfallen" in Plan §6 trägt.
- **Die zwei behaupteten `.d-check.yml`-Kopplungen:** geprüft, kein Befund — **unabhängig
  nachgemessen**, nicht übernommen. Im Klon eine Sonde
  `docs/plan/planning/done/welle-probe/slice-999-sonde.md` angelegt: (1) blanke `ADR-0001` in der
  **H1** → `569 Dateien, 0 Befunde`; dieselbe Kennung im **Fließtext** →
  `slice-999-sonde.md:3 ADR-0001 id-unlinked`. Die ID-Link-Pflicht greift also zwei Ebenen tief,
  und die ATX-Überschrift ist ausgenommen — beide Hälften der Kopplungs-Aussage bestätigt.
  (2) Je ein Link aus `spec/architecture.md` auf die tiefe Sonde und auf eine flache Kontrolle →
  **beide** `matrix-forbidden`; `**` greift zwei Ebenen tief, der Stub bleibt in der Klasse `slice`.
  `feld_hervorgegangen` baut folgerichtig jede Kennung als Anker-Link.
- **Die vier neuen Mutations-Fälle (`225`–`228`):** geprüft, kein Befund. Jeder `sed` trifft auf
  einer Kopie genau **eine** Zeile, und das bewachte Verhalten kippt: `225` `wellenlos→fremd`,
  `226` `fremd→mitglied`, `228` `mitglied→fremd`, `227` macht `stub_form_ok` über einem Stub mit
  `## 1. Ziel` grün. Die Unterscheidbarkeits-Zusage in `225` („der Fall zur Klasse `fremd` fällt
  **nicht**") trägt — gemessen: nach `225` liefert `klasse_von` für ein fremdes Welle-Feld
  weiterhin `fremd`. Der `mutate`-Treiber verlangt nur, dass der genannte Fall unter den roten ist
  (`harness/tools/mutate.sh:584`), nicht dass er der einzige ist — `226`/`228` sind damit regulär.
- **`test/archive-welle.bats` (21 Fälle):** geprüft, kein Befund über MEDIUM-3 hinaus. In dieser
  Sitzung im gepinnten `BATS_IMAGE` gefahren, `21/21 ok`. Die Fälle prüfen die drei Klassen
  einschließlich der Ziffern-Grenze (`welle-1` trifft `welle-14` nicht), beide Hälften der
  Stub-Form, beide Ersetzungsrichtungen samt Teilstring-Falle und Gegenprobe, und die
  Stub-Erzeugung aus **beiden** vendored Vorlagen inklusive „kein Platzhalter, kein Bedienhinweis
  bleibt stehen".
- **Einsammel-Regel gegen Plan §2 DoD (2):** geprüft, kein Befund. Am Scratch-Lauf mit je einem
  Slice der drei Klassen: zwei Mitglieder und ein wellenloser wandern, der fremde bleibt
  unberührt flach in `done/` liegen, die Ergebnisnotiz bleibt vollständig und flach. Die Regel
  liegt im Werkzeug, nicht im Aufrufer — `Makefile:311` reicht nur `WELLE` durch.
- **Der `unzip -p`-Zeiger im Stub:** geprüft, kein Befund. Als genau das im Stub abgedruckte
  Kommando gefahren (nicht als Variante) — es gibt den archivierten Volltext wortwörtlich zurück;
  die Zip-Eintragsnamen sind repo-root-relativ und decken sich mit dem Pfad im Zeiger.
- **`make comment-claims`:** geprüft, kein Befund. `48 Datei(en) geprueft, 0 Befund(e)` — die neue
  Datei liegt im Prüfbereich (`harness/tools/*.sh`), und die genannten Sensoren
  (`test/archive-welle.bats`) existieren.
- **[`AGENTS.md`](../../AGENTS.md) §3.7 (Kommentar-Klassen) im Diff:** geprüft, kein Befund. Die
  Kommentare in `harness/tools/archive-welle.sh`, `Makefile` und den vier Mutations-Fällen tragen
  Zusage, Kopplung, Abgrenzung, Rang-Zeiger oder Grenze; kein Konjunktiv über eine verworfene
  Alternative, kein abwesender Text, keine Befund-Kennung als Grund. Der `BELEG`-Abschnitt folgt
  der in `slice-mv.sh` etablierten Form und steht im Indikativ. Die einzige Slice-Nummer im Skript
  (`:245`, `"slice-170-titel.md"`) ist ein Eingabe-**Beispiel**, keine Herkunftsangabe. LOW-2
  betrifft die Zustandsaussagen-Hälfte, nicht die Klassen.
- **Stil gegen den Präzedenzfall `harness/tools/slice-mv.sh`:** geprüft, kein Befund über HIGH-2
  hinaus. Kopf-Aufbau (`RANG-ZEIGER` / `ZUSAGE` / `VORAUSSETZUNG` / `BELEG` / `GRENZEN` /
  `KOPPLUNG`), `set -euo pipefail`, `usage()`-Heredoc, `re_escape()`, `cd "$(dirname "$0")/../.."`,
  der `BASH_SOURCE`-Wächter am Dateiende und die Wortgrenzen-Regel statt einer Präfix-Liste sind
  übernommen, nicht neu erfunden.
- **`ARCHIVE_IMAGE`-Verdrahtung:** geprüft, kein Befund. `Makefile:12` pinnt per Digest,
  `Makefile:312` reicht die Variable explizit weiter, und `:517` erzwingt sie fail-closed
  (`${ARCHIVE_IMAGE:?…}`) — das Skript rät kein Bild.
- **Aktive ADRs:** geprüft, kein Befund. Der Diff nennt keine ADR-ID und berührt
  `docs/plan/adr/` nicht; es gibt damit weder einen Verstoß gegen eine aktive noch einen Bezug auf
  eine superseded ADR.
- **DoD-Abhakung, `make gates`, Closure-Notiz, Register-Fortschreibung:** **nicht** geprüft — nicht
  Reviewer-Rolle (Verifier bzw. Planner, Modul 8). Die drei offenen Haken in Plan §2 sind
  ausdrücklich Planner-Arbeit und werden hier nicht bewertet.

---

## Kategorie-Summary

- HIGH: 3
- MEDIUM: 3
- LOW: 3
- INFO: 2

**Wiederkehrende Finding-Klasse (für Closure/Beobachtungs-Register,
[`observations.md`](../plan/planning/observations.md)):** Ein Skriptkopf sagt einen Geltungsbereich
zu, den der Code darunter nicht hält — die Vorbedingung „sauberer Arbeitsbaum" gilt nur für
getrackte Dateien (HIGH-2), die Grenzen-Liste nennt „fünf, gemessen" und lässt die vom Werkzeug
selbst erzeugte sechste aus (HIGH-3), der Funktionskommentar sagt vier H1-Formen zu und zwei sind
getestet (MEDIUM-3). Dasselbe Muster hielt der Vorlauf am Präzedenz-Werkzeug fest
(`2026-08-31-slice-144-review.md`, MEDIUM-1: Plan-Prosa weiter als DoD-Text). **Zweite Klasse:**
ein fail-closed-Wächter grenzt seinen Suchraum per Pathspec so ein, dass die Population, gegen die
er schützt, gerade herausfällt (HIGH-1). **Dritte Klasse:** eine Nummern-Extraktion verwirft den
Buchstaben-Suffix, wodurch Identität und Mengen kollabieren (MEDIUM-1, MEDIUM-2).

---

## Verdikt

**HIGH-1, HIGH-2 und HIGH-3 blockieren** den Merge- und Closure-Pfad. Alle drei sind an einem
echten Lauf gemessen, nicht abgeleitet, und alle drei treffen den Pfad, auf dem das Werkzeug
Commits setzt und Dateien löscht: HIGH-1 lässt den einzigen Wächter gegen brechende Verweise an 83
gemessenen Zielen vorbeisehen, HIGH-2 nimmt fremden untrackten Inhalt in den Closure-Commit, HIGH-3
bricht beim zweiten Lauf einen Link, den das Werkzeug beim ersten selbst geschrieben hat.

**MEDIUM-1 bis MEDIUM-3 sind vor Closure zu klären.** MEDIUM-1 und MEDIUM-2 materialisieren sich
sicher, sobald `welle-01` oder `welle-02` archiviert wird — die vier suffixierten Slice-Paare
liegen im Bestand. MEDIUM-3 ist latent, aber unbedingt zugesagt.

**LOW-1 bis LOW-3 und INFO-1/INFO-2 sind kein Closure-Hindernis.**

Unberührt bleibt: die Zwei-Commit-Disziplin, die Docker-only-Linie, die Byte-Gleichheit des
Archivs, die Einsammel-Regel über die drei Klassen, die zwei nachgemessenen
`.d-check.yml`-Kopplungen und die Zähne der vier neuen Mutations-Fälle tragen — sie sind in diesem
Lauf einzeln gefahren und halten.
