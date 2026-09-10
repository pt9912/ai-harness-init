# Review-Report — slice-073: Welche Doc-Gate-Module ein frisch gebootstrapptes Ziel bekommt

**Rolle:** Reviewer · **Datum:** 2026-09-10 · **Runde:** 4

> Jede Zahl in diesem Report steht neben dem Kommando, das genau sie ausgibt
> ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
> Keine ist ein Erwartungswert. **Kein Satz dieses Reports stützt sich auf den Sensor-Bericht des
> Implementers** — was tragend ist, ist an der Stelle nachgemessen, nicht am Lauf.
>
> **Gate-Verifikation aufgeschoben, auf Weisung.** `make gates`, `make mutate`, `make full-smoke`,
> `make test` und `docker build` sind in diesem Lauf **nicht** gefahren (OOM-Empfindlichkeit des
> Rechners). Gefahren sind **zwei** Aufrufe des in [`d-check.mk`](../../d-check.mk) gepinnten
> Digests (`--network none`, Mount `:ro`, gegen einen synthetischen Baum außerhalb des Repos).
> Die Weisung nannte einen; der zweite steht hier offen statt still, und er hat einen Grund:
> Der erste Lauf war **grün**, und Grün allein ist von „prüft nichts" nicht zu unterscheiden
> ([`AGENTS.md`](../../AGENTS.md) §3.6). Der zweite Lauf trägt darum **beide** Richtungen in
> **einem** Aufruf (dieselbe Referenz einmal innerhalb, einmal außerhalb des ausgenommenen
> Abschnitts) — er ersetzt zwei weitere Läufe, statt einen hinzuzufügen. Prüfgegenstand ist ein
> Drei-Datei-Baum; die Last liegt um Größenordnungen unter den ausgeschlossenen Zielen.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10, plus die Repo-Ergänzung)

- **Diff/Commit-Range:** `4fea35cf..HEAD`. Von den fünf berührten Dateien gehören **zwei** zu
  diesem Slice (`git log --oneline 4fea35cf..HEAD -- internal/` → `497e3980`, `3fffd93e`):
  `internal/emit/emit.go`, `internal/emit/templates/d-check.yml`. Die drei übrigen
  (`docs/plan/adr/0033-*.md`, zwei Reports in `docs/reviews/`) stammen aus dem parallelen
  ADR-0033-Lauf und sind **nicht** geprüft. Arbeitsbaum sauber (`git status --porcelain` → leer).
- **Slice-Plan (Repo-Ergänzung):**
  [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md) — §1, DoD (1),
  DoD (2), §6.
- **Betroffene `LH-*`:**
  [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
  [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- **Referenzierte aktive ADRs:** [ADR-0007](../plan/adr/0007-bootstrap-phasen.md) (`Accepted`).
- **Aktive `MR-*`:** MR-001, MR-017, MR-019, MR-020, MR-025.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.5, §3.6, §3.7, §3.10.
- **Vorherige Findings am gleichen Modul:**
  [Runde 1](2026-09-10-slice-073-emittierte-doc-gate-module.md) ·
  [Runde 2](2026-09-10-slice-073-emittierte-doc-gate-module-runde-2.md) ·
  [Runde 3](2026-09-10-slice-073-emittierte-doc-gate-module-runde-3.md).

## Stand der Runde-3-Befunde

| Runde-3-Befund | Ausgang in Runde 4 |
|---|---|
| HIGH-1 — `exclude-sections`-Begründung nennt die falschen Klassen | **behoben, und die neue Begründung ist selbst nachgemessen und trägt** → N-1, N-2 |
| MEDIUM-1 — `emit.go:7-9` führt die abgelöste Modul-Liste als LH-QA-01-Garantie | **behoben; die zwei Zahlen halten** → N-4. Rest-Lücke als MEDIUM-2 |
| MEDIUM-2 — `mutate`-Beleg in der Commit-Message trägt nicht | nicht wiederholt; die Message von `497e3980` behauptet keinen Alt-Beleg |
| INFO-1 — `slice-004a` im emittierten Artefakt | unverändert → INFO-1 |
| INFO-2 — leere `welle`-Klasse · CI-Zeile | unverändert → INFO-2 |

**Die Reparatur selbst ist diesmal richtig — und sie legt einen Satz frei, der seit `bcf652b9`
falsch in derselben Datei steht** (HIGH-1 unten). Das ist ausdrücklich **nicht** das Muster der
Runden 2 und 3: Der Implementer hat in dieser Runde keine neue Über-Zusage eingesetzt.

## Findings

### HIGH-1 — Dieselbe Datei sagt an zwei Stellen Unvereinbares über die Ausgänge aus `{from: adr, to: slice}`: der Zeilen-Marker sei „der einzige Ausweg", und `exclude-sections: [Geschichte]` sei genau ein solcher

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage ohne rot gesehenes Gegenbeispiel), §3.7,
  [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md) DoD (1)
- **pfad:** `internal/emit/templates/d-check.yml:52-55` gegen `internal/emit/templates/d-check.yml:30-34`
- **befund:** Zeile 54-55 sagt über den Zeilen-Marker `<!-- d-check:status-provenance -->`:
  *„Er ist im frischen Ziel der einzige Ausweg."* Zweiundzwanzig Zeilen darüber begründet der in
  `497e3980` neu geschriebene Block `exclude-sections: [Geschichte]` damit, dass die
  Geschichte-Zeile einer ADR *„legitime rueckwaertige Provenance"* trage, *„die
  {from: adr, to: slice} sonst faelschlich faengt"* — also mit genau der Eigenschaft eines
  Auswegs, für genau dieselbe Regel. Gemessen ist der Abschnitts-Ausschluss ein **zweiter,
  marker-freier** Ausweg. Die Aussage ist unter **beiden** möglichen Lesarten falsch: als
  absolute („der einzige") ohnehin, und als enge („der einzige, den ein *frisches* Ziel hat" —
  im Gegensatz zur Bestands-Vorschaltung aus
  [slice-072](../plan/planning/open/slice-072-adr-verweist-nicht-auf-lifecycle.md)) ebenso, denn
  `exclude-sections` steht in jedem frischen Ziel ab Tag eins.
- **verifizierbar:** ja — **ein** d-check-Lauf über dem gepinnten Digest trägt beide Richtungen,
  weil dieselbe, byte-gleiche Referenz zweimal in derselben ADR steht: einmal außerhalb und
  einmal innerhalb von `## Geschichte`. Synthetischer Baum außerhalb des Repos, `.d-check.yml`
  ist die unveränderte Kopie von `internal/emit/templates/d-check.yml`:

  ```text
  docs/plan/adr/0001-beispiel.md:7    Entstanden aus [slice-004](../planning/done/slice-004-beispiel.md).
  docs/plan/adr/0001-beispiel.md:13   | 2026-10-01 | Proposed | [slice-004](../planning/done/slice-004-beispiel.md) |

  d-check: 2 Datei(en) geprüft, 1 Befund(e)
  docs/plan/adr/0001-beispiel.md:7  ../planning/done/slice-004-beispiel.md  matrix-forbidden  Referenz adr → slice ist nicht erlaubt
  ```

  Zeile 7 rot → die Regel ist scharf. Zeile 13, **dieselbe Zeichenkette**, ohne Befund und ohne
  jeden Marker → `exclude-sections: [Geschichte]` **ist** der zweite Ausweg. Kein Gate fängt den
  Widerspruch: `make comment-claims` erreicht `internal/emit/templates/` dauerhaft nicht
  ([`harness/README.md`](../../harness/README.md) §Was `comment-claims` nicht deckt, Punkt 2),
  und kein Modul liest YAML-Kommentare.
- **klasse:** Zusage behauptet Exklusivität, die dieselbe Datei widerlegt

**Warum HIGH und kein Wortstreit — beide Sätze gehören diesem Slice, und der Schaden ist im
Auslieferungszustand auslösbar.** Der ganze `matrix`-Block ist in diesem Slice entstanden
(`git show 3164c66e:internal/emit/templates/d-check.yml | grep -c matrix` → **0**), und beide
Sätze stammen aus `bcf652b9`
(`git show bcf652b9:internal/emit/templates/d-check.yml | grep -n 'einzige Ausweg\|exclude-sections'`
→ Zeilen 35 und 40). Der Cutoff aus [`AGENTS.md`](../../AGENTS.md) §3.7 schützt hier nichts — es
ist kein Altbestand. Das Versagen: Die emittierte ADR-Vorlage fordert den Adopter in ihrer
Geschichte-Tabelle zur Slice-Nennung auf (`| YYYY-MM-DD | Proposed | <Slice-Datei> |`,
`.harness/baseline/v6.5.0/templates/docs/plan/adr/NNNN-titel.template.md:118` ff.). Wer Zeile 55
liest, hält `exclude-sections` für totes Gewicht — es gibt ja nur *einen* Ausweg, und der ist der
Marker — und entfernt den Schlüssel. Danach färbt **jede** nach der eigenen Vorlage ausgefüllte
ADR das Gate rot, mit dem Befund oben. Das ist dieselbe Wirkungskette, die Runde-3-HIGH-1 trug,
nur an der Gegenstelle: dort führte der Kommentar in die Entfernung des Schlüssels über eine
falsche *Begründung*, hier über eine falsche *Exklusivität*.

**Und der Kommentar sagt mehr, als seine eigene DoD verlangt.** DoD (1) fordert: *„Der Kommentar
nennt den Zeilen-Marker als den **vorgesehenen** Ausweg."* Im Baum steht *„der **einzige**
Ausweg"*. Die Verschärfung ist nicht gefordert und nicht messbar gedeckt.

### MEDIUM-1 — Die Verengung von `exclude-sections` öffnet eine vierte Abweichung zwischen Emissions-Vorlage und Dogfood, die die Out-of-Scope-Grenze des Plans nicht aufzählt und die die genannte Adresse nicht annehmen kann

- **kategorie:** MEDIUM
- **quelle:** Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice (*„Die Adresse
  muss die Sendung annehmen"*), [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md) §6,
  [`AGENTS.md`](../../AGENTS.md) §3.10 (die Out-of-Scope-Grenze ist ein Übergabe-Artefakt)
- **pfad:** `internal/emit/templates/d-check.yml:59` gegen `.d-check.yml:194` ·
  `docs/plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md:305-319`
- **befund:** Vor `497e3980` trugen beide Seiten **denselben** Wert
  (`git show 497e3980^:internal/emit/templates/d-check.yml | grep -n exclude-sections` → Zeile 57,
  `[Historie, "7. Historie", Geschichte]`; `sed -n '194p' .d-check.yml` → derselbe Wert). Seit
  `497e3980` trägt die Emissions-Vorlage `[Geschichte]`, der Dogfood unverändert die Dreier-Liste.
  §6 des Plans zählt die Positionen, in denen das Ziel dem Dogfood vorausläuft, ausdrücklich
  abschließend auf — *„Das gilt seit diesem Schnitt für **alle** Positionen gleich: die zwei
  Lifecycle-Klassen im `token:`-Modus, die zwei Regeln `{from: adr, to: …}` **und** die
  Richtungs-Prüfung innerhalb der Spec-Straten"*. `exclude-sections` ist keine davon. Und die
  benannte Adresse nimmt diese Sendung nicht an: Die DoD (1) von
  [slice-072](../plan/planning/open/slice-072-adr-verweist-nicht-auf-lifecycle.md) nennt
  `exclude-sections` **nicht**, und beide Messungen jenes Plans setzen den weiten Dogfood-Wert
  voraus — §1 (*„sechs Nennungen liegen unter `Historie`/`Geschichte`, das `exclude-sections`
  schon heute ausnimmt"*) und §6 (*„ihre Slice-Nennungen liegen sämtlich unter `## 7. Historie`,
  das ausgenommen ist"*).
- **verifizierbar:** ja — der Dogfood **kann** den emittierten Wert heute nicht fahren, und das
  ist nachzählbar statt zu vermuten:

  ```sh
  awk '/^## 7\. Historie/{i=1} i' spec/lastenheft.md \
    | grep -cE 'slice-[0-9]{3}|welle-[0-9]{2}|ADR-[0-9]{4}'      # 15
  ```

  Fünfzehn Zeilen unter `## 7. Historie` von `spec/lastenheft.md` tragen ADR-Links bzw.
  Slice-Kennungen; sie sind allein durch `Historie`/`"7. Historie"` in `exclude-sections` grün.
  Damit trägt auch der Satz aus §6 *„Erprobt ist sie hier trotzdem — beide Richtungen über beiden
  Bäumen (§3)"* für **diese** Position nicht: Die Tabelle in §3 misst `order:`/`direction:`, und
  ihr Dogfood-Lauf (`1064 Datei(en) geprüft, 0 Befund(e)`) lief gegen den weiten Wert.
- **klasse:** Out-of-Scope-Grenze zählt eine Abweichung nicht auf, die derselbe Lauf erzeugt

**Was das nicht ist.** Kein Einwand gegen den Wert `[Geschichte]` — er ist der strengere und
damit der richtige (N-3). Beanstandet ist, dass eine **neue, dauerhafte** Divergenz entsteht,
während §6 die Divergenz-Liste als abgeschlossen führt und ihre Auflösung einer Adresse zuweist,
deren Plan sie strukturell nicht aufnehmen kann. **Und das ist ausdrücklich nicht vom Implementer
zu reparieren:** [`AGENTS.md`](../../AGENTS.md) §3.10 nennt eine Out-of-Scope-Grenze beim Namen
als Änderung, die *„kein Closure-Schritt, sondern ein **Übergabe-Artefakt** an den Planner"* ist —
die ausführende Rolle schreibt ihr eigenes Abnahmekriterium nicht um.

### MEDIUM-2 — Die neue LH-QA-01-Trägeraussage in `emit.go` ist enger als die gemessene Deckung und lässt zwei der fünf Module unbesprochen; für eines davon existiert ein roter Zahn in derselben Datei

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„benennen, was wirklich deckt — oder dass
  nichts deckt"*),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `internal/emit/emit.go:7-13`
- **befund:** Der Kommentar widerruft die Minimalität als Träger der LH-QA-01-Garantie für **alle
  fünf** aktiven Module (*„Die LH-QA-01-Garantie traegt nicht Minimalitaet"*) und setzt einen
  neuen Träger für **drei** ein (*„vier Befund-Arten fuer drei der fuenf aktiven Module"*). Zu
  `links` und `anchors` sagt er danach nichts — weder dass etwas sie deckt noch dass nichts sie
  deckt. Die naheliegende Schlussfolgerung wäre für eines der beiden falsch: `links` **hat** einen
  rot gesehenen Zahn im selben Skript, den Feldlisten-Zahn aus slice-098, der auf
  `target-missing` (*„Linkziel existiert nicht"*) prüft. Ohne Deckung bleibt allein `anchors`.
- **verifizierbar:** ja — die Zahlen und der fünfte Zahn, netzlos:

  ```sh
  grep -n '^modules:' internal/emit/templates/d-check.yml   # modules: [links, anchors, ids, matrix, spans]
  grep -ohE 'matrix-forbidden|matrix-downward|id-unlinked|span-unclosed' harness/tools/full-smoke.sh | sort -u
  # id-unlinked / matrix-downward / matrix-forbidden / span-unclosed -- vier Arten, ids+matrix+spans
  grep -n 'target-missing' harness/tools/full-smoke.sh      # 287 -- der links-Zahn
  grep -rn 'anchor-' harness/tools/*.sh                     # (leer) -- anchors bleibt ungedeckt
  ```

  Die zwei Zahlen des Kommentars halten also (N-4); was fehlt, ist der Satz über die zwei
  ungenannten Module.
- **klasse:** Trägeraussage lässt einen Teil ihrer eigenen Bezugsmenge unbesprochen

**Warum das mehr ist als Genauigkeit.** Der Kommentar ist die einzige Stelle, an der steht,
*woran* die LH-QA-01-Garantie des emittierten Doc-Gates hängt. Dieses Repo trägt solche Sätze
nachweislich weiter — in Adaptions-Einträge, in Slice-Pläne, in `harness/README.md`. Wer aus
*„drei der fuenf"* die Aussage *„zwei Module sind ungedeckt"* ableitet, schreibt eine Zahl fest,
die um eins danebenliegt.

### MEDIUM-3 — Die in dieser Runde verengte Position `exclude-sections` der Emissions-Vorlage ist von keinem Test und keinem Zahn gebunden, obwohl das Repo denselben Schlüssel an anderer Stelle bewacht

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6,
  [`slice-073`](../plan/planning/in-progress/slice-073-emittierte-doc-gate-module.md) DoD (2)
  (*„eine Regel ohne eigenes Gegenbeispiel ist gelistet-aber-unbewacht"*)
- **pfad:** `internal/emit/templates/d-check.yml:59`
- **befund:** `TestDCheckConfig_EntschiedeneModulListe` bindet die Modul-Liste, das ADR-Muster,
  die zwei `{from: adr, to: …}`-Regeln und `order:`/`direction:` — `exclude-sections` nicht. Auch
  keiner der vier `full-smoke`-Zähne berührt den Schlüssel. Der Wert kann damit still auf die
  frühere Dreier-Liste zurückfallen oder ganz entfallen, ohne dass ein Sensor das meldet — und
  der Kommentar in Zeile 30-37 macht über ihn eine konkrete, prüfbare Zusage.
- **verifizierbar:** ja — der Prüfbereich ist leer, und die Gegenstelle zeigt, dass er es nicht
  sein müsste:

  ```sh
  grep -rn 'exclude-sections' internal/ test/ --include=*.go --include=*.sh --include=*.bats \
    | grep -v 'templates/d-check.yml'
  # test/vcs-modul-wiring.bats:48          -- bindet exclude-sections des DOGFOOD-vcs-Blocks
  # test/mutations/278-vcs-exclude-sections-ohne-geschichte.sh -- und nimmt ihm die Zaehne
  # (kein Treffer fuer den emittierten matrix-Block)
  ```

  Das Repo bewacht denselben Schlüssel für `vcs` mit einem bats-Fall **und** einem
  Mutations-Fall; für den emittierten `matrix`-Block mit nichts. Das Gegenbeispiel selbst ist
  wohlfeil — es ist der Lauf aus HIGH-1.
- **klasse:** Neu gesetzte Vertrags-Position ohne Negativtest

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Runde-3-HIGH-1 ist behoben, und die neue Begründung trägt in beiden Hälften — selbst
  gemessen, nicht übernommen.** Hälfte eins: Die ADR-Vorlage führt in ihrem Geschichte-Abschnitt
  tatsächlich eine `Verweis`-Spalte, deren erste Zeile eine Slice-Datei nennt —
  `awk '/^## Geschichte/{i=1} i' .harness/baseline/v6.5.0/templates/docs/plan/adr/NNNN-titel.template.md`
  liefert `| YYYY-MM-DD | Proposed | <Slice-Datei> |`. Und `{from: adr, to: slice}` fängt die
  ausgefüllte Form wirklich — Zeile 7 des Probe-Laufs in HIGH-1, `matrix-forbidden`. Hälfte zwei:
  Die Historie-Abschnitte der Spec-Straten-Vorlagen tragen wirklich keine solche Ausnahme, und
  sie sagen es selbst — `lastenheft.template.md` §7: *„Auch hier gilt die Decken-Regel: keine ADR,
  kein Slice, kein Carveout, keine Welle … in keiner Spalte. Kein Spec-Stratum nimmt seine
  Historie davon aus. Die Spalte ‚Verweis' trägt den **externen** CR"*; `spezifikation.template.md`
  §7: *„Regeln dieser Sektion: **kein ADR- und kein Slice-Verweis.**"* Damit ist auch die
  **zweite falsche Fassung** aus `3fffd93e` — `exclude-sections` schütze die `spec-straten`-Klasse
  — nicht nur ersetzt, sondern durch die Quelle widerlegt, die sie behauptet hatte.
- **N-2 — Die Streichung von `Historie`/`"7. Historie"` ist für ein frisches Ziel folgenlos, und
  das ist gemessen statt angenommen.** Keine der drei emittierten Spec-Dateien trägt irgendwo —
  in oder außerhalb ihres Historie-Abschnitts — ein Token oder einen Link, den `matrix` oder `ids`
  fangen könnte:

  ```sh
  B=.harness/baseline/v6.5.0/templates
  for f in lastenheft spezifikation architecture; do
    grep -cE 'slice-[0-9]{3}|welle-[0-9]{2}|ADR-[0-9]{4}' "$B/spec/$f.template.md"
    grep -cE '\]\([^)]*(docs/plan/adr|planning)[^)]*\)' "$B/spec/$f.template.md"
  done
  # sechsmal 0
  ```

  Die übrigen drei `matrix`-Klassen (`adr`, `slice`, `welle`) haben im frischen Ziel ohnehin einen
  leeren Prüfbereich. Der Grün-Lauf des frischen Ziels kann durch die Streichung also nicht
  kippen.
- **N-3 — Das Ergebnis ist mit [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  vereinbar, und es ist keine Senkung nach [`AGENTS.md`](../../AGENTS.md) §3.5.** Eine Ausnahme-Liste
  zu **verkürzen** macht den emittierten Prüfbereich strenger, nicht laxer: Was vorher in drei
  Abschnitts-Namen von `matrix` ausgenommen war, ist jetzt nur noch in einem ausgenommen. Das ist
  die fail-closed-Richtung, die MR-017 verlangt, und eine **Anhebung** im Sinne von
  [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  — Steering-Loop, kein ADR. §3.5 bindet Schwellen-**Senkungen** und greift nicht.
- **N-4 — Die zwei Zahlen in `emit.go` halten, einzeln nachgezählt.** `modules:` führt
  `[links, anchors, ids, matrix, spans]` → **fünf**
  (`grep -n '^modules:' internal/emit/templates/d-check.yml`). `full-smoke.sh` führt genau die
  vier genannten Befund-Arten — `matrix-forbidden`, `matrix-downward`, `id-unlinked`,
  `span-unclosed` — und sie verteilen sich auf `matrix` (zwei), `ids` und `spans` → **drei**
  Module; die vier Arten einzeln aufgezählt statt Zeilen gezählt:
  `grep -ohE 'matrix-forbidden|matrix-downward|id-unlinked|span-unclosed' harness/tools/full-smoke.sh | sort -u`.
  *„Vier Befund-Arten für drei der fünf aktiven Module"* ist damit wörtlich richtig; die Lücke
  ist, was daneben **nicht** steht (MEDIUM-2).
- **N-5 — Die zweite Richtung ist bei allen vier Zähnen verdrahtet, nicht nur behauptet.**
  `grep -n 'modul_zahn_alte_module_gruen' harness/tools/full-smoke.sh` → Definition in Zeile 304
  und **vier** Aufrufe (343, 370, 396, 418), je einer pro Zahn. Die Funktion schaltet die Vorlage
  im Ziel auf `modules: [links, anchors]` zurück und verlangt Grün — damit belegt jeder Zahn
  *„erst dieses Modul findet sie"* statt *„irgendein Modul findet sie"*, wie DoD (2) es fordert.
- **N-6 — Der neue Kommentar-Block trägt keinen Konjunktiv über eine verworfene Fassung.**
  Zeile 30-37 nennt keine frühere Fassung, keine Befund-Kennung, keinen Runden-Verweis und kein
  Lauf-Protokoll; die Sätze stehen im Indikativ und tragen die Klassen **Kopplung** (*„die
  {from: adr, to: slice} sonst faelschlich faengt"* — warum der Schlüssel steht) und
  **Abgrenzung** (*„traegt dafuer nur Geschichte, nicht Historie/‚7. Historie'"*). Das ist die
  Form, die [`AGENTS.md`](../../AGENTS.md) §3.7 verlangt; der bereits in Runde 3 geprüfte
  *„waere redundant"*-Satz (dort N-8) ist unverändert und bleibt zulässig.
- **N-7 — Der Diff-Umfang ist geprüft, und die drei fremden Dateien sind nicht mitgeprüft.**
  `git diff --stat 4fea35cf..HEAD` nennt fünf Dateien; `git log --oneline 4fea35cf..HEAD -- internal/`
  weist zwei davon diesem Slice zu. `docs/plan/adr/0033-*.md` und die zwei ADR-0033-Reports
  gehören dem parallelen Reviewer-Lauf und sind hier weder gelesen noch bewertet.
- **N-8 — Die netzlosen Wächter aus DoD (2) existieren und sind nicht zahnlos formuliert.**
  `TestDCheckConfig_EntschiedeneModulListe` prüft die **exakte** Zeichenkette
  `modules: [links, anchors, ids, matrix, spans]` statt „mindestens zwei Module", schlägt bei
  unkommentiertem `codepaths:` an und verlangt das auskommentierte `<PREFIX>`-Muster; dazu bindet
  er das ADR-Muster, beide neuen `matrix`-Regeln und `order:`/`direction:`. Der Mutations-Fall
  `test/mutations/295-emittierte-modulliste-verliert-matrix.sh` liegt vor. Ob er rot färbt, ist
  Verifikation, nicht Review.
- **N-9 — `slice-072` existiert im Lifecycle, liegt offen, und für die **drei** in §6 aufgezählten
  Positionen nimmt die Adresse an.** `ls docs/plan/planning/*/slice-072*` →
  `docs/plan/planning/open/slice-072-adr-verweist-nicht-auf-lifecycle.md`. Seine DoD (1) hebt
  ausdrücklich die `welle`-Klasse, den `token:`-Modus auf beiden Ziel-Klassen, die Regeln
  `{from: adr, to: slice}`/`{from: adr, to: welle}` **und** — namentlich, mit eigener Messung —
  `order:`/`direction: no-downward` auf `spec-straten`; er schließt keine davon aus. Der Ausschluss
  in §6 von slice-073 trägt für diese drei Positionen. **Allein `exclude-sections` fällt heraus**,
  und das ist MEDIUM-1 — kein Einwand gegen den Rest der Abgrenzung.
- **N-10 — Nicht geprüft (fremde Rolle):** die DoD-Häkchen
  (`grep -c '^- \[x\]'` → **0** bei `grep -c '^- \[ \]'` → **5**, also unberührt), die
  Gate-Lauf-Bestätigung und der Gate-Stempel. Das ist Verifikation (Modul 11) bzw. Planner-Arbeit
  ([`AGENTS.md`](../../AGENTS.md) §3.10); der Reviewer-Skill nimmt beides ausdrücklich aus. Die
  vom Implementer genannten Zahlen (`make test` EXIT 0, `make full-smoke` EXIT 0, `make gates`
  EXIT 0 mit d-check 1067/0, `make mutate` 283 ok) sind hier **als Behauptung notiert und nicht
  als Beleg verwendet** — kein Finding dieses Reports hängt an einem davon.

### INFO

- **INFO-1 — `slice-004a` steht unverändert im emittierten Artefakt.**
  `grep -n 'slice-[0-9]' internal/emit/templates/d-check.yml` → Zeile 7, einziger Treffer: eine
  Kennung dieses Repos in einer Datei, die ein fremdes Repo bekommt und in der sie gegen nichts
  auflöst. Bestand, von `497e3980` nicht angefasst; der Cutoff in §3.7 bindet nur den Kommentar,
  der geschrieben wird. Festgehalten, damit die Klasse nicht mit Runde 3 verfällt.
- **INFO-2 — Die zwei INFO-Befunde aus Runde 3 stehen unverändert.** Die `welle`-Positionen haben
  im frischen Ziel weiterhin einen leeren Prüfbereich, und die CI-Beschreibung in
  `harness/README.md` nennt weiterhin drei Targets. Beide außerhalb dieses Diffs.

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Zusage behauptet Exklusivität, die dieselbe Datei widerlegt |
| MEDIUM | 3 | Out-of-Scope-Grenze zählt eine selbst erzeugte Abweichung nicht auf · Trägeraussage lässt einen Teil ihrer Bezugsmenge unbesprochen · Neu gesetzte Vertrags-Position ohne Negativtest |
| LOW | 0 | — |
| INFO | 2 | Emittiertes Artefakt nennt eine Kennung des Ursprungs-Repos · Emittierte Klasse mit leerem Prüfbereich / Deckungs-Aussage über einen Nicht-Gate-Sensor |

**Der Steering-Loop-Zähler aus Runde 3 wächst nicht — und das ist der Befund, nicht seine
Abwesenheit.** Runde 3 führte *„Eine Aussage über die Ziel-Form steht als Behauptung im Artefakt,
statt gemessen zu sein"* bei drei Wiederholungen. In dieser Runde ist die Aussage **gemessen**:
Beide Hälften der neuen Begründung halten der Nachprüfung stand (N-1), und die Streichung ist
gegen ihre Wirkung geprüft (N-2). Die Klasse wandert diesmal nicht weiter.

**Was stattdessen sichtbar wird, ist eine andere Klasse, und sie steht bei zwei:** *Eine
Grenz-Aussage zählt auf, statt eine Eigenschaft zu nennen.* §6 des Plans zählt drei divergente
Positionen auf, und die vierte, die derselbe Lauf erzeugt, fällt heraus (MEDIUM-1); `emit.go`
zählt drei gedeckte Module auf, und die Aussage über den Rest der Menge fehlt (MEDIUM-2). Beide
Male wäre eine Eigenschaft — *jede Position, die vom Dogfood abweicht* bzw. *jedes aktive Modul* —
haltbar geblieben, wo die Aufzählung altert. Für die Slice-Closure §7 gehört das ins
Beobachtungs-Register
([`docs/plan/planning/observations/README.md`](../plan/planning/observations/README.md)); ob eine
der beiden Instanzen einen bestehenden Eintrag trifft, entscheidet der Planner beim Eintragen,
nicht dieser Report.

## Verdikt

**Blockierender Befund — ja.** Ein HIGH und drei MEDIUM.

**Was in dieser Runde gut ist und ausdrücklich nicht kleingeredet gehört.** Die Vorgeschichte
dieses Slice war zweimal dieselbe: Jede Reparatur setzte eine neue Über-Zusage ein. **Das ist
diesmal nicht passiert.** Ich habe die neue Begründung in beiden Hälften gegen ihre eigenen
Quellen gehalten — die `Verweis`-Spalte der ADR-Vorlage existiert wirklich, `{from: adr, to: slice}`
fängt ihre ausgefüllte Form wirklich, und die Spec-Straten-Vorlagen sagen die behauptete
Decken-Regel wörtlich selbst. Die Streichung von `Historie`/`"7. Historie"` ist geprüft und für
ein frisches Ziel folgenlos, sie geht in die fail-closed-Richtung, und die zwei Zahlen in
`emit.go` sind richtig. Die zweite falsche Fassung aus `3fffd93e` ist nicht nur ersetzt, sondern
von genau der Quelle widerlegt, die sie angerufen hatte.

**Warum es trotzdem nicht durchgeht.** Der HIGH ist keine Wiederholung des Musters, sondern seine
Kehrseite: Indem die neue Begründung endlich richtig sagt, **wofür** `exclude-sections` da ist,
macht sie einen Satz aus demselben Slice messbar falsch, der vier Zeilen über dem `matrix`-Block
steht und den Marker zum *einzigen* Ausweg erklärt. Beide Sätze stammen aus `bcf652b9`; kein
Cutoff schützt sie. Der Rückfall ist auf dem Auslieferungszustand auslösbar, und die Messung
dafür ist ein einziger Lauf mit zwei byte-gleichen Zeilen.

**Reif für den Verifier — nein.** Zwei der vier Befunde stehen einer DoD-Abnahme direkt im Weg:
DoD (1) verlangt wörtlich, dass *„der Kommentar den Zeilen-Marker als den **vorgesehenen** Ausweg
nennt"* — im Baum steht *„der einzige"*, und das ist widerlegt (HIGH-1). Und ein Verifier, der
`make full-smoke` als Beleg für DoD (2) nimmt, bekommt für die in dieser Runde geänderte Position
`exclude-sections` keinen Zahn geliefert (MEDIUM-3), obwohl das Repo denselben Schlüssel an der
`vcs`-Gegenstelle mit bats-Fall **und** Mutations-Fall bewacht.

**Ein Teil gehört nicht zurück an den Implementer.** MEDIUM-1 bewegt eine **Out-of-Scope-Grenze**,
und [`AGENTS.md`](../../AGENTS.md) §3.10 nennt genau das als Übergabe-Artefakt an den Planner: Die
ausführende Rolle schreibt ihr eigenes Abnahmekriterium nicht um. Ebenso bleiben die
Adaptions-Einträge Architect-Arbeit (§3.8) und die DoD-Häkchen samt Closure-Notiz Planner-Arbeit
(§3.10).

**Kein Rollen-Konflikt-Pfad ausgelöst.** Modul 8 verlangt die Konflikt-Sequenz ab *HIGH mit
Rollen-Widerspruch*. Ein Widerspruch liegt nicht vor — der Implementer hat keiner Entscheidung
widersprochen, und HIGH-1 ist eine Messung, kein Urteil: Zwei byte-gleiche Zeilen in einer Datei,
eine rot, eine stumm. Wird er bestritten, ist der Konflikt-Pfad zu eröffnen; herabgestuft wird er
nicht.

**Was nicht wieder aufgemacht wird.** Ob `exclude-sections` mitgeht, ist entschieden (DoD (1)),
und der Wert `[Geschichte]` ist in dieser Runde als der richtige **bestätigt** (N-1, N-2, N-3).
Beanstandet ist der Satz daneben, der ihn für unmöglich erklärt.

**Aufgeschobene Gate-Verifikation.** `make gates`, `make mutate`, `make full-smoke` und
`make test` sind in diesem Lauf nicht gefahren (siehe Kopf). Kein Befund und kein Negativbefund
dieses Reports hängt an einem dieser Läufe; sie sind vom Auftraggeber selbst nachzuholen.
