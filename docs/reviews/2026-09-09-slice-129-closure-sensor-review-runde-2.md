# Review — slice-129: Die Closure-Notiz-Pflicht bekommt ihren Sensor (Runde 2)

**Rolle:** Reviewer (Modul 10, frischer Kontext) · **Datum:** 2026-09-09
· **Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) v1.7.0

## Eingangs-Kontext (die fünf Pflicht-Punkte + Slice-Plan)

| Punkt | Wert |
|---|---|
| **Diff/Commit-Range** | `2a2ceafd` — der Behebungs-Commit zu Runde 1. Geprüft wird, ob die sechs Befunde aus Runde 1 **tragen**, und ob der Behebungs-Commit selbst neue trägt. |
| **Slice-Plan** | [`docs/plan/planning/done/slice-129-closure-notiz-hat-einen-sensor.md`](../plan/planning/done/slice-129-closure-notiz-hat-einen-sensor.md) |
| **`LH-*`** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| **Aktive ADRs im Bezug** | Im Diff neu referenziert wird allein [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (`Proposed`) — als Zeiger auf ein Werkzeug in Bau, nicht als normative Stütze. Keine superseded ADR referenziert. |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.1, §3.3, §3.5, §3.6, §3.7, §3.9, §3.10 |
| **Vorherige Findings am gleichen Modul** | [`2026-09-09-slice-129-closure-sensor-review.md`](2026-09-09-slice-129-closure-sensor-review.md) (Runde 1, 2 HIGH / 2 MEDIUM / 2 LOW / 3 INFO) · [`2026-09-06-slice-125-planning-modul-review.md`](2026-09-06-slice-125-planning-modul-review.md) F-1 (HIGH, *Mutations-Deckung trifft den lauten Pfad*) — diese Klasse tritt in Runde 2 erneut auf. |

**Nicht Gegenstand:** die DoD-Abhakung als Konformitäts-Frage — das prüft die Verifikation. Dass
die Häkchen **von wem** gesetzt sind, ist dagegen eine Hard-Rule-Frage und bleibt hier.

## Prüfmittel und Sonden

Alle Messungen netzlos gegen **Kopien außerhalb des Repos** (`git archive HEAD | tar -x`), Mount
`:ro`, mit dem in [`d-check.mk`](../../d-check.mk) gepinnten Digest (`sha256:e31a372b…`, `v0.74.1`)
bzw. dem in `Makefile` gepinnten `BATS_IMAGE`. Der Arbeitsbaum wurde für keine Sonde angefasst
(`git status --porcelain` vor und nach dem Lauf leer). Das Sonden-Kommando ist **byte-gleich mit
dem `docs-check`-Rezept** (`d-check.mk:72`), nicht eine Annäherung daran.

| Sonde | Kommando (gekürzt) | Ergebnis |
|---|---|---|
| Basis | `docker run … d-check@<digest>` | `1009 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 |
| DoD-Text vor/nach | `diff` der §2-Kriterien gegen `3b6c81af^`, `Erfüllt:`-Blöcke und Häkchen normalisiert | **byte-gleich** (einzige Abweichung ist eine vom Filter entfernte Leerzeile) |
| Zitat HIGH-2 | Zeilenumbruch-normalisierter `grep` in `.harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md` | Treffer, Z. 225–226, innerhalb Schritt 3 (Z. 207–251) |
| MR-016 im Plan | `git blame` je Fundstelle | alle **4** Zeilen aus `829910a5` (2026-08-28); `MR-016` retiriert in `447bb097` (2026-08-31) |
| Rekursion | identische §7-dünne Sonden-Datei flach in `done/` **und** in `done/welle-99/` | flach `closure-note-thin`; tief **0** Treffer — bei `1011` geprüften Dateien, die tiefe wird also gescannt und fällt nur aus dem Kandidaten-Filter |
| MEDIUM-2 | `grep -lE '^# .*[Cc]losure' docs/plan/planning/done/welle-*-results.md \| wc -l` | **8** von **12**; `welle-06/07/08/12` je `0` Closure-Überschriften |
| Mutationen 288/289/290 | je isolierte Kopie, `bats test/closure-modul-wiring.bats` | jede färbt **ihre benannte** Zusicherung rot; unmutiert **6/6 ok** |
| 288 in `docs-check` | dieselbe Mutation, Rezept-Kommando | **45** `closure-note-thin`, EXIT **1** |
| 289 in `docs-check` | dieselbe Mutation, Rezept-Kommando | **1** Befund: `Closure-Verzeichnis … fehlt oder ist unlesbar (fail-closed)`, EXIT **1** |
| 290 in `docs-check` | dieselbe Mutation, Rezept-Kommando | **10** `closure-note-boilerplate`, EXIT **1** |
| Stub-Ziel-Form | `.harness/baseline/v6.5.0/templates/…/archiv-stub-slice.template.md` | *„Der Stub trägt keine Abschnittsüberschriften"* — also kein §7 |
| `mutate`-Beleg | `isolation_key` gegen `.harness/state/mutate-passed.key` | **deckungsgleich** (`55a93abb…`); `276` Fall-Dateien, `288/289/290` in der Bezugsmenge |
| Gate-Stempel | `.harness/state/gates-passed.diffsha` gegen `harness/tools/working-tree-hash.sh` | deckungsgleich (`10b55495…`) |
| `make comment-claims` | Gate | `57 Datei(en) geprueft, 0 Befund(e)` |

**Keine Erwartungswerte** — alle Zahlen wandern mit dem Bestand
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

## Befunde aus Runde 1 — trägt die Behebung?

| Runde 1 | Verdikt Runde 2 | Beleg |
|---|---|---|
| **HIGH-1** Abnahmekriterien umgeschrieben **und abgehakt** | **halb behoben — offen** | Kriterien-Text byte-gleich wiederhergestellt; die drei Häkchen stehen unverändert auf `[x]` (→ HIGH-1/R2) |
| **HIGH-2** tote `MR-016`-Berufung | **behoben** | Zitat verbatim in Schritt 3 des `v6.5.0`-Moduls; Abgrenzung zum Plan trägt (s. INFO-1/R2) |
| **MEDIUM-1** Nicht-Rekursion unbenannt | **behoben** | Grenze mit Mechanismus, Messung, Auslöser, Adressat und den zwei vom Regelwerk verlangten Zweigen |
| **MEDIUM-2** 12 pauschal statt 8 von 12 | **behoben** | selbst nachgemessen: 8/12, die vier Ausreißer namentlich und richtig |
| **LOW-1** Kommentar 286 „jeden" | **behoben** | nennt jetzt 8 von 12 Welle-Plänen und alle 12 Ergebnisnotizen |
| **LOW-2** drei Zusicherungen ohne Fall | **behoben (Deckung), neu belastet (Begründung)** | 288/289/290 färben je ihre Zusicherung rot — zwei ihrer Begründungen sind falsch bzw. rangfremd (→ HIGH-1/R2 … MEDIUM-2/R2) |

## Findings

### HIGH-1 — Die DoD-Häkchen des ausführenden Laufs stehen weiter; nur die Text-Hälfte von Runde 1 ist zurückgenommen

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10 (Hard Rule)
- `pfad`: `docs/plan/planning/done/slice-129-closure-notiz-hat-einen-sensor.md:104,121,151`
- `befund`: Runde 1 benannte zwei Hälften — der ausführende Lauf hat die Kriterien *umgeschrieben*
  **und** *abgehakt*. Die erste ist zurückgenommen: der Kriterien-Text der drei DoD-Punkte ist
  gegenüber `3b6c81af^` byte-gleich wiederhergestellt, beide `**Rot:**`-Klauseln stehen wieder da,
  und die getroffene Entscheidung liegt additiv als `**Erfüllt:**`-Block daneben, ohne das Kriterium
  zu verschieben. Die zweite steht unverändert: alle drei Punkte tragen `[x]`, gesetzt vom
  Implementations-Commit `3b6c81af` und vom Behebungs-Commit `2a2ceafd` — wieder `Rolle
  Implementer` — nicht angefasst. §3.10 zählt die gebundenen Artefakte auf und nennt **die
  DoD-Häkchen** darin ausdrücklich; das Rücksetzen eines unbefugt gesetzten Häkchens ist dieselbe
  Wiederherstellung wie die des Kriterien-Textes und verlangt keinen Planner-Lauf. Der Verifier
  (Modul 11) und der Planner lesen damit eine Abnahme, die der geprüfte Lauf für sich selbst
  erklärt hat — genau die Tautologie, gegen die §3.10 antritt, nur eine Ebene über dem
  Kriterien-Text. Die Commit-Message führt HIGH-1 als behoben und erwähnt die Häkchen nicht.
- `verifizierbar`: nein — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Commits, und
  `make mutate` kennt keine Fehlschlag-Form für einen Rollen-/Commit-Zuschnitt; §3.10 stellt diese
  Wächter-Lücke für sich selbst fest. Beobachtbar an `grep -n '^- \[' <plan>` und `git log --stat`.
- `klasse`: fremdes Rollen-Artefakt im Implementations-Kontext — Register:
  [`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`](../plan/planning/observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md),
  Stand `verkörpert` (§3.10), Zähler heute 7

### HIGH-2 — Der Kommentar von Fall 289 behauptet `fail-open`; das gepinnte Werkzeug meldet `fail-closed` und sagt es wörtlich

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt — oder dass nichts
  deckt"*), §3.7 (ein Kommentar beschreibt, was da ist)
- `pfad`: `test/mutations/289-closure-dir-nicht-existent.sh:8`
- `befund`: Der Kommentar begründet den neuen Wächter mit *„`docs-check` selbst faende in einem
  solchen Verzeichnis keine Kandidaten und liefe **fail-open** ins Leere statt die Config als kaputt
  zu melden"*. Gemessen mit dem Kommando, das `docs-check` selbst fährt
  (`d-check.mk:72`, gegen eine Kopie außerhalb des Repos): der Lauf meldet
  `docs/plan/planning/does-not-exist-289:1 … closure-note-missing  Closure-Verzeichnis
  docs/plan/planning/does-not-exist-289 fehlt oder ist unlesbar (**fail-closed**)` und endet mit
  EXIT 1. Das Werkzeug trägt die Eigenschaft, deren Fehlen der Kommentar behauptet, und schreibt
  das Wort selbst in seine Meldung. Wer die Zeile liest, schließt, ohne diesen bats-Fall bliebe eine
  kaputte `closure.dir`-Config unentdeckt — und wer das später prüft, findet das Gegenteil und
  entfernt den Fall mit einer Begründung, die auf den gemessenen Fakten richtig wäre. **Zweite
  Fundstelle desselben Vorgangs:** `test/mutations/288-closure-dir-anderer-pfad.sh:8` sagt
  *„`docs-check` prueft dann offene statt abgeschlossene Pakete, **ohne das je zu melden**"*;
  gemessen sind es **45** `closure-note-thin` und EXIT 1. Eine wohlwollende Lesart („meldet nicht,
  *dass der Bestand der falsche ist*") trägt den Satz, die nächstliegende nicht. Kein Gate sieht
  beides: der Prüfbereich von `make comment-claims` sind vier Pfad-Muster
  (`internal/**/*.go`, `cmd/**/*.go`, `harness/tools/*.sh`, `.claude/hooks/*.sh`) — `test/` liegt
  dauerhaft draußen —, und `make mutate` prüft nur, ob die benannte Zusicherung rot wird; das tut
  sie, weshalb der Satz im Grün mitfährt.
- `verifizierbar`: ja — die Mutation in einer Kopie außerhalb des Repos anwenden und
  `docker run --rm --network none -v <kopie>:/repo:ro ghcr.io/pt9912/d-check@<digest>` fahren:
  1 Befund und EXIT 1 statt des behaupteten stillen Durchlaufs.
- `klasse`: Mutations-Deckung trifft den lauten Pfad (Begründung eines Wächters behauptet ein
  stilles Versagen, das der Sensor laut meldet) — dieselbe Klasse wie
  [`2026-09-06-slice-125-planning-modul-review.md`](2026-09-06-slice-125-planning-modul-review.md)
  F-1

### MEDIUM-1 — Die neue Regelwerk-Berufung nennt den Tag nicht, gegen den sie gemessen ist

- `kategorie`: MEDIUM (Ableitung: Doku-Drift LOW, eine Stufe hoch nach §Kontext-Eskalation — die
  Aussage trägt die Begründung einer Gate-Prüfbereichs-Entscheidung)
- `quelle`: [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  Setzung 1 (*„Ein Kommando, dessen Pfad den Tag enthält, erfüllt die Setzung; ein Satz ohne Tag
  erfüllt sie nicht"*), Cutoff 2026-08-29
- `pfad`: `harness/README.md:159`
- `befund`: Der neue Absatz stützt sich auf *„die vom Regelwerk (`modul-06-roadmap.md`
  §Wellen-Closure-Prozedur Schritt 4) **vor der ersten Archivierung** verlangte
  Geltungsbereichs-Prüfung"* und erklärt diese Forderung für erfüllt. Das ist eine Aussage darüber,
  was die Baseline führt, und der Absatz nennt weder den Tag noch ein Kommando, dessen Pfad ihn
  enthält, noch ein wörtliches Zitat (`awk`-Absatz-Extraktion über `harness/README.md`: der Absatz
  enthält keine Zeichenkette `v6.5.0`). Der **Nachbar-Absatz derselben Änderung** erfüllt die
  Setzung — er nennt `.harness/baseline/v6.5.0/templates/…/welle-results.template.md:1` —, die Form
  war dem Lauf also verfügbar. Der Schaden ist der von `MR-033` benannte: die Aussage ist heute wahr
  (nachgeprüft am `v6.5.0`-Baum), aber nicht *prüfbar*, sobald der vendored Baum weiterzieht — und
  er zieht: [`harness/conventions.md`](../../harness/conventions.md) §Baseline führt den Sprung auf
  `v6.5.0` mit *„Delta-Nachweis steht aus"*. Wer nach der nächsten Re-Baseline liest, kann nicht
  entscheiden, ob eine erfüllt gemeldete Regelwerks-Forderung gegen den dann geltenden Modul-Text
  gemessen wurde.
- `verifizierbar`: nein durch ein Gate — die Modul-Liste der [`.d-check.yml`](../../.d-check.yml)
  führt kein `versions`, und `make comment-claims` hat keine Markdown-Datei im Prüfbereich; `MR-033`
  §*Kein Wächter* stellt das für sich selbst fest. Beobachtbar an der Absatz-Extraktion oben.
- `klasse`: Baseline-Aussage ohne Mess-Tag

### MEDIUM-2 — Der Kommentar von Fall 290 belegt seine Zusicherung mit dem Slice-Plan, einer Quelle in keinem Rang

- `kategorie`: MEDIUM
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (Quellen-Klausel: *„Herkunft steht darum als **ein**
  auflösbares Feld in den Formen der Begründung unten und sonst gar nicht"*), Cutoff 2026-08-30
- `pfad`: `test/mutations/290-closure-boilerplate-gesetzt.sh:6`
- `befund`: Die tragende Begründung des Falls steht als Zitat-Zuschreibung *„(Slice-Plan slice-129
  §6: „Die Floskel-Liste ist die Stelle, an der dieser Slice sich selbst rot faerben kann")"*. Ein
  Slice-Plan steht in keinem der neun Ränge der Source Precedence, und die Adresse hat eine kurze
  Lebensdauer: mit der Closure wandert die Datei nach `done/`, das §3.7 selbst als Zeitdokument
  führt; fährt später ein `make archive-welle`-Lauf darüber, bleibt an ihrer Stelle ein Stub, dessen
  Ziel-Form Abschnittsüberschriften ausdrücklich streicht (*„Der Stub trägt keine
  Abschnittsüberschriften"*) — die Adresse „§6" existiert dann nicht mehr. Die Aussage steht
  nirgends sonst: [`harness/README.md`](../../harness/README.md) nennt `boilerplate` nur als
  Bedingung (Z. 89), nicht die Rückwirkung auf alle Kandidaten. **Kalibrierung gegen die
  Geschwister:** die drei Fälle desselben Satzes aus dem Vor-Commit (285, 286, 287) tragen **keine**
  Slice-Nummer und berufen sich auf `harness/README.md` bzw. das Werkzeug-Handbuch — die
  rangkonforme Form ist in derselben Datei-Familie bereits vorgemacht. Kein Gate sieht das: `test/`
  liegt außerhalb von `make comment-claims`.
- `verifizierbar`: nein durch ein Gate — beobachtbar an
  `grep -nE 'slice-[0-9]+' test/mutations/28[5-9]-*.sh test/mutations/290-*.sh` (einziger Treffer:
  290).
- `klasse`: Kommentar beruft sich auf eine Quelle in keinem Rang

### INFO-1 — Die `MR-016`-Zitate im Slice-Plan tragen denselben Defekt und gehören dem Planner

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10; Runde-1-HIGH-2
- `pfad`: `docs/plan/planning/done/slice-129-closure-notiz-hat-einen-sensor.md:28,183,203,251`
- `befund`: Der Plan beruft sich an vier Stellen auf `MR-016`, im Kopf mit derselben Aussage, die
  Runde 1 im README als tot beanstandet hat (*„die Welle-Ebene, deren Closure-Notiz dieses Repo auf
  **zwei** Dateien verteilt"*). Die Abgrenzung des Implementers trägt, und zwar zweifach: `git blame`
  weist alle vier Zeilen dem Anlage-Commit `829910a5` vom 2026-08-28 zu, während `MR-016` erst am
  2026-08-31 (`447bb097`) retiriert wurde — sie waren bei ihrer Niederschrift korrekt; und der Plan
  trägt `**Autor:** Planner`, seine Norm-Aussagen im Implementations-Lauf umzuschreiben wäre genau
  die Klasse, die HIGH-1 sanktioniert. Runde 1 hatte den `pfad` selbst auf `harness/README.md:109`
  begrenzt. Der Eintrag steht als **Übergabe an den Planner**, nicht als Auftrag an diesen Slice.
- `verifizierbar`: nein — der Anker `#mr-016--…` bleibt nach
  [`MR-020`](../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  mit Absicht stehen, `links`/`anchors` bleiben grün.
- `klasse`: retirierter Adaptions-Eintrag als lebende Begründung zitiert (zweite Fundstelle
  desselben Vorgangs — zählt nach Modul 6 nicht zweimal)

### INFO-2 — Die drei INFO-Punkte aus Runde 1 sind zu Recht liegengeblieben; einer musste es sogar

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10; [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
- `pfad`: Commit-Message `838cc6d6` · `d-check.mk:99` ·
  `docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/`
- `befund`: **INFO-1/R1** (Commit-Message zitiert die `Proposed`-ADR-0029 — Status heute unverändert
  `Proposed`) ist in einer bereits geschriebenen Commit-Message nicht behebbar, ohne Historie zu
  schreiben; Runde 1 hielt das Ergebnis der Änderung selbst für richtig. **INFO-2/R1**
  (`doc-planning` beschreibt sich weiter als *„Planning-Lifecycle-Konsistenz (Roadmap <-> in-progress)"*,
  obwohl derselbe Aufruf jetzt `closure-note-*` liefern kann) liegt in einem nach `MR-010`
  tool-generierten Fragment, das Ziel ist kein Gate und hat keinen Aufrufer — die Beschreibung von
  Hand nachzuziehen erzeugte Drift gegen den Generator. **INFO-3/R1** (Register-Zähler bei 6, Stand
  `offen` — nachgemessen) durfte dieser Lauf nicht anfassen: §3.10 bindet *„die Fortschreibung des
  Beobachtungs-Registers"* ausdrücklich an den Planner. Keine der drei gehört in den Umfang dieses
  Slice; die dritte gehört ausdrücklich nicht hinein.
- `verifizierbar`: nein — Commit-Messages und Register-Stände liest kein Modul.
- `klasse`: Abgrenzung geprüft, trägt

## Negativbefunde (geprüft, ohne Befund)

- **HIGH-1/R1, Text-Hälfte: vollständig, nicht teilweise.** Die §2-Kriterien der drei DoD-Punkte
  sind gegen `git show 3b6c81af^:…` byte-gleich; nach Normalisierung der Häkchen und Entfernung der
  additiven `**Erfüllt:**`-Blöcke ist der `diff` bis auf eine vom Filter selbst entfernte Leerzeile
  leer. Beide `**Rot:**`-Klauseln stehen wieder da, einschließlich des mechanischen Falsifikators
  (*„ein **neues** Paket ohne Notiz wandert nach `done/` und der Lauf meldet es **nicht**"*) und des
  Beleg-Vergleichs (`grep -c '^doc-' d-check.mk` → 11 gegen `grep -c 'doc-' Makefile` → 0). Die
  `Erfüllt:`-Blöcke verschieben kein Kriterium — sie berichten Belege daneben.
- **HIGH-2/R1: das neue Zitat trägt.** *„Und die Welle-Plan-Datei wandert per `git mv` von flach
  nach `done/`"* steht wörtlich in
  `.harness/baseline/v6.5.0/regelwerk/modul-06-roadmap.md` (Z. 225–226, zeilenumbruch-normalisiert
  geprüft) und liegt innerhalb von Schritt 3 (Z. 207–251), wie behauptet. Der Halbsatz *„— neben
  ihre Ergebnis-Notiz"* trägt die Zwei-Datei-Form, die der README-Absatz aus ihm ableitet. `MR-016`
  kommt in `harness/README.md` nicht mehr vor.
- **MEDIUM-1/R1: die Formulierung ist eine Grenze, keine Beobachtung.** Sie nennt den Mechanismus
  (`closure.dir` öffnet nur das Verzeichnis selbst), die Messung, den Auslöser (der erste
  `archive-welle`-Lauf), den Adressaten (*„Wer `archive-welle` produktiv nimmt"*) und **beide**
  Zweige, die das Regelwerk verlangt (*„zieht den Geltungsbereich mit — oder benennt, dass die
  Zusage für Stubs nicht mehr gilt"*). Selbst nachgemessen: dieselbe §7-dünne Datei erzeugt flach
  `closure-note-thin` und unter `done/welle-99/` **null** Treffer, bei 1011 geprüften Dateien — die
  tiefe Datei wird also gescannt und fällt allein aus dem Kandidaten-Filter, was die Aussage
  schärfer macht als „wird nicht gesehen". Die Zusatz-Begründung stimmt ebenfalls: die Stub-Ziel-Form
  streicht Abschnittsüberschriften und trägt damit kein §7, wäre für `closure` also kein sinnvoller
  Kandidat. `find docs/plan/planning/done -mindepth 1 -maxdepth 1 -type d | wc -l` → 0 reproduziert;
  der Kandidaten-Bestand steht bei 141, die Vakuitäts-Sorge ist heute gegenstandslos, und
  `archive-welle` ist laut `harness/README.md` auf keine Welle dieses Repos anwendbar.
- **MEDIUM-2/R1: die Zahl stimmt jetzt, und die vier sind richtig benannt.** Eigene Messung: 8 von
  12; `welle-06`, `welle-07`, `welle-08`, `welle-12` führen als H1 *„… — Results-Notiz"* und
  `grep -cE '^#{1,6} .*[Cc]losure'` → 0 je Datei. Die vendored Ziel-Form setzt in Zeile 1
  `# Welle <NN> — <Titel> — Closure-Notiz`, die Abweichungs-Aussage trägt. Der frühere pauschale
  Satz ist durch *„überwiegend"* ersetzt, und die vier sind als *benannte, nicht nachgezogene
  Abweichung* geführt statt der Ursache untergeschoben.
- **LOW-1/R1: Kommentar und Quelle stimmen jetzt überein.** Fall 286 sagt *„8 von 12 Welle-Plaenen
  und alle 12 Welle-Ergebnisnotizen"* — deckungsgleich mit der Messung und mit
  `harness/README.md`.
- **LOW-2/R1, Deckungs-Hälfte: die drei neuen Fälle treffen.** Unmutiert sind alle sechs
  Zusicherungen grün (`1..6`, 6× `ok`). 288 fällt Zusicherung 2, 289 fällt Zusicherung 3 (zusätzlich
  2 — dieselbe Latitüde, die der Treiber schon Fall 285 gewährt: er verlangt nur, dass die
  `# expect:`-Zeile in der Fehlschlag-Ausgabe steht), 290 fällt Zusicherung 6. Jede `# expect:`-Zeile
  deckt wörtlich einen `@test`-Namen. Damit trägt jede der sechs Zusicherungen einen Fall.
- **Der `mutate`-Beleg trägt; ein Wiederholungslauf war nicht nötig.**
  `.harness/state/mutate-passed.key` enthält `55a93abb…`; derselbe Wert entsteht, wenn man
  `isolation_key` aus `harness/tools/mutate.sh` gegen den heutigen Baum auswertet (dasselbe
  `source`-Idiom, das der Skriptkopf selbst benutzt). Die Bezugsmenge ist `isolation_key_files`, nicht
  `working-tree-hash.sh` — geprüft wurde gegen die richtige. `ls test/mutations/*.sh | wc -l` → 276
  deckt sich mit dem gemeldeten `276 ok`, und 288/289/290 liegen in der Bezugsmenge des Schlüssels,
  waren also Teil des grünen Laufs. **Was der Beleg nicht deckt und nicht decken kann:** ob die
  *Begründungen* in den Fall-Kommentaren zutreffen — genau dort liegen HIGH-2/R2 und MEDIUM-2/R2.
- **Gate-Stempel und Arbeitsbaum decken sich.** `.harness/state/gates-passed.diffsha` ==
  `harness/tools/working-tree-hash.sh` (`10b55495…`); der Basis-`docs-check` über einer Kopie
  außerhalb des Repos meldet `1009 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 — die Null ist gemessen,
  nicht leer (141 Kandidaten). `make comment-claims` selbst gefahren: `57/0`.
- **Der Behebungs-Commit ist sauber geschnitten.** Kein Pfad unter `docs/plan/planning/done/` oder
  `.harness/baseline/` berührt (0), kein Rename im Commit (0) — §3.3 ist nicht einschlägig, weil
  kein Move stattfindet. Die Plan-Zeile *„wird eine `done/`-Datei geändert, um den Gate grün zu
  bekommen, ist das ein Befund"* ist gehalten.
- **Kein Gate gelockert.** `modules:` unverändert; die `.d-check.yml`-Änderung ist ein Kommentar,
  kein Schalter. Kein `ignore`/`ignore-refs`-Eintrag berührt — §3.5 nicht einschlägig.
- **§3.9 gehalten.** Keine Host-Toolchain und kein Host-Paketmanager in einem Rezept oder in einer
  der neuen Mutations-Dateien; alle Läufe über `make` bzw. gepinnte Images.
- **Keine superseded ADR referenziert.** Einzige im Diff neu genannte ADR ist ADR-0033
  (`Proposed`) — und zwar als Zeiger auf ein Werkzeug in Bau (*„Werkzeug in Bau"*), nicht als
  normative Stütze; das unterscheidet die Stelle von INFO-1 aus Runde 1.
- **Der `.d-check.yml`-Kommentar trägt seine Klasse.** Der neue Halbsatz *„FLACH in `dir` (nicht
  rekursiv — Begruendung und Sonden-Beleg in harness/README.md)"* ist Abgrenzung plus Rang-Zeiger im
  Indikativ, ohne Slice-Nummer, ohne Konjunktiv über die verworfene Alternative, ohne
  Lauf-Protokoll — §3.7 gehalten.
- **Der README-Absatz zu MEDIUM-1 ist keine Chronik.** Er beschreibt den Prüfbereich und seine
  Grenze im Indikativ; `harness/README.md`-Prosa ist zudem weder Code/Config/Skript noch ein
  Zustandsfeld eines lebenden Registers und liegt damit außerhalb des §3.7-Geltungsbereichs. Der
  Mangel dieses Absatzes ist der fehlende Mess-Tag (MEDIUM-1/R2), nicht seine Form.

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 2 |
| MEDIUM | 2 |
| LOW | 0 |
| INFO | 2 |

**Wiederkehrende Klassen dieses Laufs** (Modul 5 §Closure-Regeln, dritte Speisungs-Quelle):
*fremdes Rollen-Artefakt im Implementations-Kontext* (Rest-Hälfte aus Runde 1) ·
*Mutations-Deckung trifft den lauten Pfad* (dritte Sitzung in Folge, nach slice-125 F-1 — ein
Steering-Loop-Signal, kein Einzelfall) · neu: *Baseline-Aussage ohne Mess-Tag* · neu: *Kommentar
beruft sich auf eine Quelle in keinem Rang* · *retirierter Adaptions-Eintrag als lebende Begründung
zitiert* (zweite Fundstelle, ein Vorgang).

## Verdikt

**Merge-blockierend: ja** — zwei HIGH und zwei MEDIUM.

**Vier der sechs Befunde aus Runde 1 tragen vollständig**, und sie tragen belegt, nicht behauptet:
HIGH-2 (Zitat verbatim am richtigen Ort), MEDIUM-1 (Grenze mit beiden vom Regelwerk verlangten
Zweigen, Nicht-Rekursion selbst nachgemessen), MEDIUM-2 (8 von 12 selbst nachgezählt, die vier
Ausreißer richtig benannt) und LOW-1. Die **Substanz des Slice ist unverändert intakt** — der
Sensor ist verdrahtet, seine Null ist gemessen und nicht leer, alle sechs Zusicherungen tragen jetzt
einen Mutations-Fall, und der `mutate`-Beleg ist gegen die richtige Bezugsmenge geprüft und
deckungsgleich.

Blockierend sind zwei verschiedene Dinge:

- **HIGH-1 ist der Befund aus Runde 1, halb zurückgenommen.** Der Kriterien-Text ist wörtlich
  wiederhergestellt — das war die schwerere Hälfte —, die drei `[x]` stehen unverändert. §3.10 nennt
  die DoD-Häkchen ausdrücklich unter den an den Planner gebundenen Artefakten; ihr Rücksetzen ist
  dieselbe Wiederherstellung wie die des Textes und braucht keinen Planner-Lauf. **Er folgt dem
  Konflikt-Pfad aus Modul 8 nur, wenn ihm widersprochen wird**; unwidersprochen ist er eine
  Rücknahme, die vor der Verifikation liegt.
- **HIGH-2 und MEDIUM-2 sind neu und stammen aus der Behebung selbst.** LOW-2 wurde in seiner
  Deckungs-Hälfte korrekt geschlossen — jede der drei neuen Zusicherungen wird rot gesehen —, aber
  zwei der drei neuen Fälle tragen eine Begründung, die ihrer eigenen Messung widerspricht (289:
  `fail-open` behauptet, `fail-closed` gemessen und vom Werkzeug wörtlich so benannt; 288: „ohne das
  je zu melden" gegen 45 Befunde und EXIT 1) bzw. sich auf eine Quelle in keinem Rang stützt (290:
  Slice-Plan §6). Das ist dieselbe Klasse, die dieser Slice bekämpft, eine Ebene tiefer: ein
  Wächter, dessen Zusage stimmt und dessen Begründung nicht. Kein Gate erreicht sie —
  `test/mutations/` liegt außerhalb von `make comment-claims`, und `make mutate` prüft die
  Zusicherung, nicht den Satz daneben.
- **MEDIUM-1 ist die Kehrseite der HIGH-2-Behebung aus Runde 1:** die tote `MR-016`-Berufung ist
  durch eine lebende Regelwerks-Berufung ersetzt, die ihren Mess-Tag nicht nennt. Sie ist heute wahr
  und morgen unprüfbar — der Nachbar-Absatz derselben Änderung macht es richtig vor.

Die beiden INFO blockieren nicht; INFO-2 hält ausdrücklich fest, dass die drei INFO-Punkte aus
Runde 1 zu Recht liegengeblieben sind und einer davon — die Fortschreibung des
Beobachtungs-Registers — nach §3.10 gar nicht in diesen Lauf gehörte.
