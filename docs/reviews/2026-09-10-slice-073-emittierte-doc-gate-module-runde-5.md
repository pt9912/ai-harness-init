# Review-Report — slice-073: Welche Doc-Gate-Module ein frisch gebootstrapptes Ziel bekommt

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 5 (enge Schlussrunde)

> Jede Zahl in diesem Report steht neben dem Kommando, das genau sie ausgibt
> ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
> Keine ist ein Erwartungswert. **Kein Satz dieses Reports stützt sich auf den Sensor-Bericht des
> Implementers** — die vier Punkte des Diffs sind je an der Stelle nachgemessen, nicht am Lauf.
>
> **Gate-Verifikation aufgeschoben, auf Weisung.** `make gates`, `make mutate`, `make full-smoke`,
> `make test` und `docker build` sind in diesem Lauf **nicht** gefahren (ein `make mutate`-Vollauf
> läuft im Hintergrund und teilt sich die Docker-Tags; dazu OOM-Empfindlichkeit des Rechners).
> Gefahren ist **ein** Aufruf des in [`d-check.mk`](../../d-check.mk) gepinnten Digests
> (`--network none`, Mount `:ro`, gegen einen Drei-Datei-Baum außerhalb des Repos) — er entscheidet
> den einen Punkt, an dem beide Hälften einer neu hinzugefügten Zusage hängen. Die vom Implementer
> gemeldeten Zahlen (`make gates` EXIT 0, `docs-check` 1069/0, 244 bats ok, `comment-claims` 57/0)
> sind hier **als Behauptung notiert und nicht als Beleg verwendet**.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `37ca5c58..71f3fd9b`. Die Range enthält **zwei** Commits
  (`git log --format='%h %s' 37ca5c58..71f3fd9b`); der Prüfgegenstand ist allein `71f3fd9b`
  (slice-073, vier Dateien). `3472f47a` ist der parallele Architect-Lauf an
  `docs/plan/adr/0033-*.md` und ist hier **weder gelesen noch bewertet**. Arbeitsbaum sauber
  (`git status --porcelain` → leer).
- **Slice-Plan (Repo-Ergänzung):**
  [`slice-073`](../plan/planning/done/slice-073-emittierte-doc-gate-module.md) — §1, DoD (1),
  DoD (2), §6.
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte aktive ADRs:** [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) (`Accepted`).
- **Aktive `MR-*`:** MR-001, MR-017, MR-025.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.6, §3.7, §3.10.
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-10-slice-073-emittierte-doc-gate-module.md) ·
  [Runde 2](2026-09-10-slice-073-emittierte-doc-gate-module-runde-2.md) ·
  [Runde 3](2026-09-10-slice-073-emittierte-doc-gate-module-runde-3.md) ·
  [Runde 4](2026-09-10-slice-073-emittierte-doc-gate-module-runde-4.md).

## Stand der Runde-4-Befunde

| Runde-4-Befund | Ausgang in Runde 5 |
|---|---|
| HIGH-1 — Zeilen-Marker als „der einzige Ausweg" | **im emittierten Artefakt behoben und selbst nachgemessen** → N-1. Rest-Fundstelle im Plan → MEDIUM-1 |
| MEDIUM-1 — Out-of-Scope-Grenze §6 / Adresse `slice-072` | **nicht angefasst, korrekt** — Übergabe an den Planner steht → N-7 |
| MEDIUM-2 — Trägeraussage lässt `links`/`anchors` unbesprochen | **behoben, und die Ergänzung hält in beiden Richtungen** → N-2 |
| MEDIUM-3 — `exclude-sections` ohne Test und ohne Zahn | **behoben; Wächter und Mutations-Fall tragen** → N-3, N-4, N-5, N-6 |
| INFO-1 / INFO-2 | unverändert, außerhalb dieses Diffs |

**Die Betriebsregel dieser Runde hat gewirkt.** Der Implementer hat an beiden beanstandeten
Zusagen **gestrichen statt neu formuliert** — das Absolutheits-Wort ist weg, und die ergänzte
Deckungs-Aussage ist die erste dieses Slice, die ich in **beiden** Richtungen selbst nachmessen
konnte, ohne dass eine Hälfte kippt. Der neu gebaute Wächter (MEDIUM-3) ist der bestgebaute
Sensor dieses Slice: er misst die Eigenschaft und nicht ihre Implementierung, und seine Mutation
trifft die Stelle, die der Aufrufer benutzt.

## Findings

### MEDIUM-1 — Die von Runde 4 widerlegte Exklusivitäts-Aussage ist aus dem emittierten Artefakt verschwunden, steht aber unverändert in §1 des Slice-Plans, aus dem sie stammt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6, §3.10 (Plan-Text ist Planner-Artefakt),
  [Runde 4](2026-09-10-slice-073-emittierte-doc-gate-module-runde-4.md) HIGH-1
- **pfad:** `docs/plan/planning/done/slice-073-emittierte-doc-gate-module.md:89-92`
- **befund:** §1 sagt: *„Der Marker ist im Ziel der **einzige** Ausweg für eine bewusst deklarierte
  Provenance: die Bestands-Vorschaltung, die slice-072 im Dogfood wählt, hat im frischen Ziel
  keinen Bestand, den sie vorschalten könnte."* Das ist wörtlich die **enge** Lesart, die Runde-4-HIGH-1
  ausdrücklich mitwiderlegt hat (*„als enge … ebenso, denn `exclude-sections` steht in jedem
  frischen Ziel ab Tag eins"*). Derselbe Plan verlangt in DoD (1) *„den **vorgesehenen** Ausweg"* —
  §1 und DoD (1) desselben Dokuments sagen damit Unvereinbares, und §1 ist die Fassung, die
  gemessen falsch ist.
- **verifizierbar:** ja — die **gemessene Fundmenge** ist genau eine lebende Fundstelle, und sie
  ist nicht die reparierte:

  ```sh
  git grep -n 'einzig' -- '*.md' '*.yml' '*.go' '*.sh' \
    ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done' \
    | grep -iE 'ausweg|marker|provenance'
  # docs/plan/adr/0023-…:242            -- anderer Gegenstand (zeilengenauer Ausweg), kein Treffer der Klasse
  # docs/plan/planning/in-progress/slice-073-…:90   -- DIESE Fundstelle
  # docs/plan/planning/observations/…/slice-123.md:2 -- anderer Gegenstand
  ```

  In `internal/emit/templates/d-check.yml` ist die Aussage restlos weg
  (`grep -c 'einzige' internal/emit/templates/d-check.yml` → **0**). Die drei weiteren Treffer
  einer Suche mit `docs/reviews/` liegen in Zeitdokumenten
  (`git grep -c 'einzige[nrs]* Ausweg' -- ':!.harness/baseline'` → drei Report-Dateien) und sind
  nach [`AGENTS.md`](../../AGENTS.md) §3.7 Chronik von Beruf.
- **klasse:** Korrektur an einem Fundort statt an der Fundmenge

**Einschätzung: streichen, nicht umformulieren.** Es ist der **zweite** Befund an derselben
Zusage; die Betriebsregel dieser Runde trägt hier genauso wie im emittierten Artefakt. Zu streichen
ist der ganze Nebensatz einschließlich der `slice-072`-Begründung — sie ist es, die die enge
Lesart erzeugt, und genau die ist gemessen falsch. Was §1 an dieser Stelle tragfähig sagen kann,
steht bereits in DoD (1).

**Warum MEDIUM und nicht HIGH.** Runde-4-HIGH-1 war HIGH, weil der Satz **ausgeliefert** wird: Ein
Adopter liest ihn in seiner eigenen `.d-check.yml`, hält `exclude-sections` für totes Gewicht und
entfernt den Schlüssel. Diese Fundstelle erreicht keinen Adopter — sie steht in einem
Planungs-Dokument dieses Repos. Der Schaden ist der nächste Lauf, der §1 als Begründung liest,
nicht ein rotes Gate beim Fremden.

**Und sie gehört nicht dem Implementer.** §1 eines Slice-Plans ist Planner-Text;
[`AGENTS.md`](../../AGENTS.md) §3.10 hält die ausführende Rolle davon ab, ihre eigene
Begründungs-Grundlage umzuschreiben. Derselbe Weg wie Runde-4-MEDIUM-1.

### LOW-1 — Der neue Mutations-Fall nennt einen nackten Commit-Hash als Herkunft; er ist damit der einzige unter 284 Fall-Dateien

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (Herkunft als **ein** auflösbares Feld — `LH-*`,
  `ADR-*`, `· seit welle-<NN>`, `· seit slice-<NNN>` — *„und sonst gar nicht"*)
- **pfad:** `test/mutations/298-emittierte-matrix-exclude-sections-faellt-zurueck.sh:6`
- **befund:** Der Kopfkommentar sagt *„auf die fruehere, weitere Dogfood-Liste zurueck (den Wert
  vor `497e3980`)"*. Ein nackter Commit-Hash ist keine der vier zulässigen Feld-Formen und die am
  wenigsten auflösbare von allen: Er löst über keinen Index auf und zeigt nach einem Rebase oder
  Squash auf nichts. Der Fall braucht ihn auch nicht — der Wert, den die Mutation setzt, steht in
  derselben Zeile ausgeschrieben und im `sed` darunter.
- **verifizierbar:** ja — die **gemessene Fundmenge ist 1 von 284**, das ist keine Bestands-Form,
  sondern eine neue:

  ```sh
  ls test/mutations/*.sh | wc -l                                    # 284
  grep -nE '^#.*\bvor [0-9a-f]{7,8}\b' test/mutations/*.sh          # nur 298-…:6
  ```

  Die Präteritum-Hälfte (*„die fruehere … Liste"*) ist dagegen **etablierter Bestand** und wird
  hier ausdrücklich nicht beanstandet — ein Mutations-Fall hat einen kontrafaktischen Wert zum
  Gegenstand: `grep -cE '^#.*[Ff]rueher' test/mutations/*.sh | grep -v ':0$'` → **8** Dateien,
  298 eingeschlossen.
- **klasse:** Herkunft außerhalb der zulässigen Feld-Form

**Einschätzung: streichen.** Die Klammer ersatzlos entfernen — der Satz trägt ohne sie unverändert,
und `git` hält, was sie sagen wollte. Kein Ersatz durch eine Slice-Nummer nötig.

### LOW-2 — Die neu geschriebene Kommentar-Zeile in `emit.go` führt eine Slice-Nummer als Herkunft

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*„Ein Sensor-Name ist keine Herkunft: er nennt
  etwas, das jetzt läuft, und gehört zur Zusage"*)
- **pfad:** `internal/emit/emit.go:14`
- **befund:** Die ergänzte Zusage lautet *„links traegt seinen eigenen Zahn im selben Skript
  (Feldlisten-Zahn, `slice-098`, `target-missing`)"*. `Feldlisten-Zahn` ist der Sensor-Name und
  `target-missing` die Befund-Art, die er verlangt — beide gehören zur Zusage. `slice-098` ist der
  Vorgang, der ihn gebaut hat, und steht nicht in der zulässigen Feld-Form `· seit slice-098`.
  §3.7 bindet den Kommentar, der **geschrieben** wird; diese Zeile ist in diesem Diff entstanden.
- **verifizierbar:** ja — und die Messung sagt zugleich, warum das LOW ist und nicht mehr:

  ```sh
  grep -nE '^[[:space:]]*//.*slice-[0-9]' internal/emit/emit.go   # 6 Zeilen: 3, 14, 57, 75, 99, 161
  git grep -c '· seit slice-' -- '*.go' '*.sh'                    # (leer) -- 0 Dateien
  ```

  Zeile 14 ist die neue; die fünf übrigen sind cutoff-geschützter Bestand. Die zulässige
  Feld-Form kommt in **keiner** `.go`- oder `.sh`-Datei des Repos vor — die Inline-Form ist hier
  die durchgängige, und [`AGENTS.md`](../../AGENTS.md) §3.7 sagt zum Bestand ausdrücklich
  *„der Bestand ist kein Arbeitsauftrag"*.
- **klasse:** Herkunft außerhalb der zulässigen Feld-Form

**Einschätzung: umformulieren, nicht streichen — und nur, wenn die Zeile ohnehin angefasst wird.**
Anders als LOW-1 ist das die repo-weit gelebte Form; ein einzelner Nachzug hier erzeugt eine
Insel. Trägt der Satz ohne die Nummer (*„Feldlisten-Zahn, `target-missing`"*), ist er die
sauberere Fassung — verpflichtend ist das nach dem Cutoff nicht.

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — HIGH-1 ist im emittierten Artefakt vollständig behoben, der neue Satz ist exakt die
  DoD-Fassung, und er hält.** `internal/emit/templates/d-check.yml:54-55` sagt jetzt *„Er ist der
  vorgesehene Ausweg."*; DoD (1) verlangt wörtlich *„Der Kommentar nennt den Zeilen-Marker als den
  vorgesehenen Ausweg"* — **nicht weniger, nicht mehr**, keine Verschärfung und keine
  Abschwächung. Und *„vorgesehen"* ist die messbar richtige Vokabel, nicht bloß die schwächere:
  Die Baseline-Vorlage führt den Marker selbst als die Zeilen-Ausnahme
  (`grep -n 'status-provenance' .harness/baseline/v6.5.0/templates/.d-check.yml` → Zeile 35,
  *„Ausnahme je Zeile"*), und das Werkzeug nennt ihn in seiner **eigenen** Meldung als Ausweg
  (*„Provenance via `<!-- d-check:status-provenance -->` deklarieren"*, am gepinnten Digest in
  Runde 1 N-3 gemessen). Die erste Hälfte des Satzes (*„nimmt die Zeile aus"*) ist unveränderter
  Bestand und dort ebenfalls belegt: Sonden-ADR, markierte Zeile **0** Befunde, unmarkierte
  zwei `matrix-forbidden`.
- **N-2 — MEDIUM-2 hält in beiden Richtungen, und die Attribution ist gemessen statt übernommen.**
  Die ergänzte Zusage macht zwei Aussagen; ich habe beide selbst geprüft. **Erstens: `links` trägt
  wirklich einen eigenen Zahn, und zwar einen echten Gegenbeispiel-Zahn derselben Form.**
  `harness/tools/full-smoke.sh:275-289` schmuggelt einen toten Verweis in die Feldliste **im
  gebootstrappten Ziel**, verlangt Rot **und** den Befund `target-missing` **auf dieser Datei**
  (*„rot aus falschem Grund?"*), und nimmt zurück; das Skript nennt die vier ids/matrix/spans-Zähne
  selbst *„nach derselben Form wie der Feldlisten-Zahn oben"*. **Zweitens: `target-missing` ist
  wirklich ein `links`-Befund und nicht `anchors`.** Das ist der eine Punkt, an dem beide Hälften
  kippen könnten — wäre die Zuordnung vertauscht, wäre die Aussage in *beide* Richtungen falsch.
  Gemessen mit dem einen erlaubten Lauf, Drei-Datei-Baum außerhalb des Repos, `--network none`,
  Mount `:ro`, `modules: [links]` **allein**:

  ```text
  d-check: 2 Datei(en) geprüft, 1 Befund(e)
  docs/a.md:3	./gibt-es-nicht.md	target-missing	Linkziel existiert nicht
  ```

  Der tote **Link** färbt unter `links` allein rot → `target-missing` gehört `links`. Der im selben
  Baum liegende tote **Anker** (`./b.md#gibt-es-nicht`, Datei existiert) bleibt im selben Lauf
  stumm → er braucht `anchors`, und `anchors` hat keinen Zahn
  (`grep -rn 'anchor' harness/tools/*.sh` → nur Prosa, keine Befund-Art;
  `git grep -nE 'anchor-(missing|broken|dup|unknown)' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`
  → nur ADR- und Slice-Prosa, kein Zahn). Damit ist die Restmenge arithmetisch geschlossen: fünf
  aktive Module, gedeckt sind `links`, `ids`, `matrix` (zwei), `spans` — **allein `anchors` bleibt**.
  Die Zusage ist genau so weit, wie die Deckung reicht.
- **N-3 — Der neue Wächter misst die Eigenschaft, nicht die heutige Implementierung.** Das ist die
  §3.6-Kernfrage, und sie hat hier eine mechanische Antwort: `DCheckConfig()` ist
  `func DCheckConfig() string { return dcheckConfig }` über `//go:embed templates/d-check.yml`
  (`internal/emit/emit.go:43-44,55`) — **keine Transformation**. Der Test bindet damit
  byte-genau die Zeichenkette, die der Adopter bekommt. Der in §3.6 genannte Fehlerfall („Test
  prüft Quell-Namen, während der Code transformierte Ziel-Namen schreibt") kann hier konstruktiv
  nicht eintreten, weil Quelle und Ziel dieselbe Zeichenkette sind.
- **N-4 — Der Mutations-Fall trifft die Verdrahtung des Aufrufers und baut sie nicht nach.**
  Mutiert wird `internal/emit/templates/d-check.yml` — genau die Datei, die `//go:embed` einbindet
  und die der Bootstrap ins Ziel schreibt. Der Kopf ist die Form, die der Treiber liest
  (`sed -n 's/^# files: //p'` bzw. `s/^# expect: //p'`, `harness/tools/mutate.sh:581-582`), er ist
  einfach statt mehrfach (der Treiber meldete sonst *„mehrfacher '# …:'-Kopf"*), und
  `narrow_sensor` (`harness/tools/mutate.sh:521-535`) trifft mit dem Muster `Test[A-Z]*` auf
  `TestDCheckConfig_EntschiedeneModulListe` → Modus `test-go`, Fehlschlag-Form `--- FAIL:`
  (`failure_form`, Zeile 540). Keine Nummern-Kollision (`ls test/mutations/ | grep -c '^298-'` →
  **1**), keine Registry, die nachzuziehen wäre (der Treiber leitet `total` selbst ab,
  `harness/tools/mutate.sh:1348`), und der Dateimodus ist folgenlos, weil der Treiber
  `bash "$case_file"` ruft (Zeile 627) — 755 liegt ohnehin im Bestand
  (`find test/mutations -name '*.sh' -printf '%m\n' | sort | uniq -c` → 187×775, 48×755, 47×664,
  2×644). Kopf und Bau sind Zeile für Zeile die des Geschwister-Falls
  `test/mutations/295-emittierte-modulliste-verliert-matrix.sh`, der im laufenden Satz steht.
- **N-5 — Die Mutation nimmt dem Wächter wirklich die Zähne; es gibt keine zweite Fundstelle, die
  ihn grün hielte.** Das ist die Falle bei einem `strings.Contains`-Wächter, und sie ist gemessen:

  ```sh
  grep -n 'exclude-sections' internal/emit/templates/d-check.yml   # 30 (Prosa), 59 (der Schluessel)
  ```

  Nur Zeile 59 trägt das gesuchte Literal `exclude-sections: [Geschichte]`; Zeile 30 ist Fließtext
  ohne Doppelpunkt-Form. Das `sed` des Falls ist auf `^  exclude-sections: \[Geschichte\]$`
  verankert und trifft Zeile 59 exakt (`sed -n '59p' … | cat -A` → `  exclude-sections: [Geschichte]$`,
  zwei Leerzeichen). Auf einer Kopie außerhalb des Repos angewandt:
  `grep -cF 'exclude-sections: [Geschichte]'` → **0** — `strings.Contains` ist danach falsch, der
  Wächter fällt. Der `Contains`-Wächter ist dabei nicht zahnlos: Er fängt alle drei Formen, die
  sein eigener Kommentar nennt — Entfernen, Weiten und Leeren —, weil die schließende Klammer die
  Zeichenkette effektiv exakt macht.
- **N-6 — Der manuelle Rot-Beleg trägt für die Hälfte, auf die es ankommt; die andere ist hier
  statisch gemessen.** Was der Implementer belegt hat (isolierte Kopie, Mutation,
  `docker build --target test` → `internal/emit` FAIL), ist die Strecke *Mutation → benannter
  Sensor wird rot* — das ist die Zusage, die [`AGENTS.md`](../../AGENTS.md) §3.6 verlangt, und sie
  ist dieselbe Stufe, die der Treiber unter `test-go` fährt, mit derselben Fehlschlag-Form
  `--- FAIL:`. Ich komme über N-5 unabhängig zum selben Ergebnis, ohne Docker. Was der manuelle
  Lauf **nicht** zeigt, ist die Strecke *Treiber → Fall* (Auffinden, Kopf-Parsen, Sensor-Wahl,
  Bilanz) — genau die Lücke, in der ein Fall still nie läuft. Diese Hälfte ist in N-4 Stück für
  Stück am Treiber-Code nachgewiesen; ihr Laufzeit-Beleg ist der aufgeschobene
  `make mutate`-Vollauf, und *ob* ein Fall rot färbt, ist ohnehin Verifikation und nicht Review
  (so schon Runde 4, N-8). **Der Beleg trägt** — mit dieser benannten Grenze.
- **N-7 — MEDIUM-1 aus Runde 4 ist wirklich nicht angefasst.** `git show --stat 71f3fd9b` nennt
  **vier** Dateien, alle unter `internal/` bzw. `test/mutations/`;
  `git show --name-only --format='' 71f3fd9b | grep -E 'slice-073|slice-072|planning'` → **kein
  Treffer**. Weder DoD noch §6 noch `slice-072` sind berührt; letzterer liegt unverändert in
  `open/` (`git log --oneline -1 -- docs/plan/planning/open/slice-072-*.md` → `81748d84`, ein
  Planner-Commit von vor dieser Runde). Das ist das nach
  [`AGENTS.md`](../../AGENTS.md) §3.10 richtige Verhalten und ausdrücklich kein Versäumnis.
- **N-8 — Der Diff-Umfang ist geprüft, und der fremde Commit ist nicht mitgeprüft.** Die Range
  `37ca5c58..71f3fd9b` trägt zwei Commits; `3472f47a` (`docs/plan/adr/0033-*.md`) gehört dem
  parallelen Architect-Lauf. Er ist hier weder gelesen noch bewertet — die ADR-Zeilen im
  `git diff` der Range stammen ausschließlich von dort.
- **N-9 — Die übrigen neuen Kommentare tragen eine der fünf Klassen und stehen im Indikativ.** Der
  ergänzte Doc-Kommentar über `TestDCheckConfig_EntschiedeneModulListe` (*„exclude-sections traegt
  genau [Geschichte], nicht die weitere Dogfood-Liste und nicht leer"*) ist **Abgrenzung**; der
  Inline-Kommentar im Test-Rumpf (*„weder leer (dann faengt {from: adr, to: slice} auch die
  legitime … Provenance-Zeile)"*) ist **Kopplung** — er sagt, warum der Schlüssel steht, im
  Präsens über die geltende Wirkung, nicht im Konjunktiv über eine verworfene Fassung. Das ist
  dieselbe Form, die Runde 4 in N-6 am `d-check.yml`-Block bereits als zulässig gemessen hat.
  Keine Befund-Kennung, kein Runden-Verweis, kein Lauf-Protokoll in einem der drei neuen Blöcke.
- **N-10 — `MR-017` und §3.5 sind unberührt.** Der Diff senkt keine Schwelle: Er fügt einen
  Wächter und einen Mutations-Fall hinzu (Anhebung), streicht ein Absolutheits-Wort und ergänzt
  eine Deckungs-Aussage. Kein Modul verlässt die emittierte Liste, kein Ausnahme-Schlüssel wird
  geweitet (`git diff 37ca5c58..71f3fd9b -- internal/emit/templates/d-check.yml` berührt genau
  zwei Kommentarzeilen).
- **N-11 — Nicht geprüft (fremde Rolle):** die DoD-Häkchen
  (`grep -c '^- \[x\]' docs/plan/planning/in-progress/slice-073-*.md` → **0** bei
  `grep -c '^- \[ \]'` → **5**, also unberührt), die Gate-Lauf-Bestätigung und der Gate-Stempel.
  Das ist Verifikation (Modul 11) bzw. Planner-Arbeit ([`AGENTS.md`](../../AGENTS.md) §3.10); der
  Reviewer-Skill nimmt beides ausdrücklich aus.

### INFO

- **INFO-1 — Die neu hinzugefügte Hälfte der Deckungs-Aussage ruht auf festerem Grund als die
  Hälfte, die sie ergänzt.** Der `links`-Zahn ist selbst bewacht: `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh`
  zieht die Feldliste unter `.harness/` und erwartet, dass `full-smoke` rot wird — verschwände der
  Zahn aus dem Skript, bliebe der Lauf grün und `make mutate` meldete einen Befund auf Fall 171.
  Für die **vier** ids/matrix/spans-Zähne existiert kein solcher Fall:
  `grep -ln 'matrix-forbidden\|matrix-downward\|id-unlinked\|span-unclosed' test/mutations/*.sh`
  → **kein Treffer**. Ihr Wegfall wäre still. Das ist Bestand, nicht von diesem Diff erzeugt, und
  die Zusage *„vier Befund-Arten fuer drei der fuenf"* hat Runde 4 in N-4 als wörtlich richtig
  gemessen — festgehalten, damit die Asymmetrie nicht als Deckungs-Gleichstand gelesen wird.
- **INFO-2 — Die INFO-Befunde der Runden 3 und 4 stehen unverändert** (`slice-004a` im emittierten
  Artefakt, leere `welle`-Klasse im frischen Ziel, CI-Beschreibung in `harness/README.md`). Alle
  außerhalb dieses Diffs.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | Korrektur an einem Fundort statt an der Fundmenge |
| LOW | 2 | Herkunft außerhalb der zulässigen Feld-Form (2×: nackter Commit-Hash · Slice-Nummer) |
| INFO | 2 | Deckungs-Asymmetrie zwischen bewachtem und unbewachtem Zahn · Bestands-INFO unverändert |

**Der Steering-Loop-Zähler.** Die Klasse aus Runde 4 — *„Eine Grenz-Aussage zählt auf, statt eine
Eigenschaft zu nennen"* — wächst in dieser Runde **nicht**: Die ergänzte Aussage in `emit.go`
spricht ihre Bezugsmenge jetzt vollständig durch (N-2). Neu sichtbar ist stattdessen
*„Korrektur an einem Fundort statt an der Fundmenge"* (MEDIUM-1) — ein Befund nennt einen
Fundort, die Reparatur zieht genau diesen und lässt die Quelle stehen, aus der er stammt. Die
zwei LOW gehören einer zweiten Klasse an (*Herkunft außerhalb der zulässigen Feld-Form*), die in
diesem Slice zum ersten Mal auftritt. Ob eine der drei einen bestehenden Eintrag des
Beobachtungs-Registers trifft, entscheidet der Planner beim Eintragen
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)), nicht
dieser Report.

## Verdikt

**Blockierender Befund — nein.**

**Der Slice kann an den Verifier übergeben werden.** Alle drei Punkte, an denen der Implementer in
dieser Runde gearbeitet hat, sind erledigt, und jeder einzeln von mir nachgemessen statt vom
Sensor-Bericht übernommen:

- **HIGH-1 ist weg, nicht abgeschwächt.** Der Satz trägt exakt die DoD-(1)-Fassung — nicht weniger,
  nicht mehr — und *„vorgesehen"* ist die belegte Vokabel: Die Baseline-Vorlage führt den Marker
  als Zeilen-Ausnahme, und das Werkzeug nennt ihn in seiner eigenen Meldung (N-1).
- **MEDIUM-2 hält in beiden Richtungen.** `target-missing` gehört gemessen `links` — ein Lauf am
  gepinnten Digest mit `modules: [links]` allein färbt den toten Link rot und lässt den toten
  Anker im selben Baum stumm; damit ist der Feldlisten-Zahn wirklich der `links`-Zahn und
  `anchors` wirklich der einzige ohne (N-2). Die Zusage war die riskanteste dieser Runde und ist
  die erste dieses Slice, die die Nachprüfung ohne Abstrich übersteht.
- **MEDIUM-3 ist sauber gebaut.** Der Wächter misst die Eigenschaft und nicht die Implementierung,
  weil `DCheckConfig()` die Vorlage unverändert zurückgibt (N-3); der Mutations-Fall trifft genau
  die eingebettete Datei, die der Aufrufer benutzt, und baut die Verdrahtung nicht nach (N-4); die
  Mutation nimmt dem Wächter wirklich die Zähne, weil das gesuchte Literal genau einmal vorkommt
  (N-5). **Der manuelle Rot-Beleg trägt** für die Hälfte, auf die §3.6 zielt; die Treiber-Hälfte
  ist hier statisch am Treiber-Code nachgewiesen, ihr Laufzeit-Beleg ist Verifier-Arbeit (N-6).
- **MEDIUM-1 aus Runde 4 ist korrekt liegen gelassen** — vier Dateien im Commit, keine davon im
  Plan (N-7). Das ist §3.10 richtig angewandt, kein Versäumnis.

**Was vor der Closure noch fällt, gehört dem Planner und nicht dem Implementer.** Zwei Posten, und
beide blockieren die Verifikation nicht: die Out-of-Scope-Grenze aus Runde-4-MEDIUM-1 samt der
Adresse, die die Sendung nicht annimmt — und **MEDIUM-1 dieser Runde**, die Exklusivitäts-Aussage
in §1 des Plans, aus dem der reparierte Satz stammte. Sie ist der zweite Befund an derselben
Zusage; die Betriebsregel dieser Runde sagt **streichen**, und zwar den ganzen Nebensatz
einschließlich der `slice-072`-Begründung, die die falsche enge Lesart trägt. DoD (1) sagt bereits
das Richtige, und wo §1 und DoD desselben Plans auseinanderfallen, trägt die DoD die Abnahme —
deshalb steht der Verifikation nichts im Weg.

**Warum ich hier nicht blockiere, obwohl ein MEDIUM steht.** Der Reviewer-Skill sagt, HIGH und
MEDIUM blockierten *typischerweise*, und verlangt für die Abweichung eine Begründung. Sie lautet:
Der Befund liegt nicht im geprüften Diff, er erreicht keinen Adopter, und er gehört einer anderen
Rolle. Die vier Runden dieses Slice sind über Begründungs-Prosa zu 31 Zeilen Config gelaufen; eine
sechste Runde, in der ein Implementer auf einen Planner-Satz wartet, den er nicht schreiben darf,
wäre genau die Kostenform, die der Auftraggeber beanstandet hat. Die zwei LOW sind Ein-Wort- bzw.
Ein-Klammer-Korrekturen und blockieren nichts.

**Kein Rollen-Konflikt-Pfad ausgelöst.** Modul 8 verlangt die Konflikt-Sequenz ab *HIGH mit
Rollen-Widerspruch*; kein HIGH steht, und der Implementer hat keiner Entscheidung widersprochen.

**Aufgeschobene Gate-Verifikation.** `make gates`, `make mutate`, `make full-smoke` und `make test`
sind in diesem Lauf nicht gefahren (siehe Kopf). Kein Befund und kein Negativbefund dieses Reports
hängt an einem dieser Läufe. Der laufende `make mutate`-Vollauf ist der ausstehende Laufzeit-Beleg
für `test/mutations/298` und damit **Prüfgegenstand des Verifiers**, nicht dieses Reports.
