# Review-Report — ADR-0039 und ADR-0040, Bestätigungsrunde nach zwei blockierenden Befunden

**Rolle:** Reviewer · **Datum:** 2026-09-07 · **Runde:** 2

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10)

- **Diff/Commit-Range:** `b07e7381..712e4fde` — zwei Commits:
  `cfa01076` (ADR-0039, Deklaration folgt dem Bestand) ·
  `712e4fde` (ADR-0040, Begründung auf die Aktenlage zurückgefasst). Je eine Datei je Commit.
- **Betroffene `LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (beide ADRs führen ihn in §Konsequenzen als benannte Sensor-Lücke),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Mess-Kommandos beider
  Dateien).
- **Referenzierte aktive ADRs:** [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md),
  [ADR-0017](../plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md),
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
  [ADR-0023](../plan/adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md),
  [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [ADR-0027](../plan/adr/0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md),
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
  [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md),
  [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md).
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3 — namentlich §3.4, §3.5, §3.6, §3.8, §3.11.
- **Vorherige Findings am gleichen Modul:** die Reviewer-Runde 1 vom 2026-09-07 zu denselben zwei
  Entscheidungen (2 HIGH / 7 MEDIUM / 2 LOW / 2 INFO). Ihr Verbleib ist unten je Befund als
  Negativbefund oder als Übertrag ausgewiesen.

**Kein Slice-Plan im Eingang** — der Gegenstand sind zwei ADRs, kein Slice. Die sechste
Repo-Ergänzung des Eingangs-Kontexts entfällt damit ersatzlos und nicht stillschweigend.

**Was diese Runde ist.** Der Beleg, den [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2 nach einem blockierenden Befund verlangt: eine erneute Runde derselben prüfenden
Rolle in frischem Kontext, nicht die Nachmessung des auflösenden Laufs. Zugleich die
Konsistenzprüfung, die der Acceptance-Trigger jener Datei gegen
[ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md),
[ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) und
[ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) verlangt.
[ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) trägt keinen
Acceptance-Trigger.

**Zustand des Baums vor dem Lauf:** `git status --porcelain` leer, `main`, `HEAD` = `712e4fde`.

**Gate-Lauf nach dem Lauf:** `make gates` bricht an `docs-check` ab —
`d-check: 919 Datei(en) geprüft, **36** Befund(e)`, alle `target-missing`, alle nach
`.harness/baseline/v6.0.0/`, verteilt 32 · 3 · 1 auf die drei einfrierenden Bäume. Das ist der
erklärte Zustand, den [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
§Konsequenzen als eigenen Negativposten führt, und kein Befund dieses Laufs. Die Gates nach
`docs-check` laufen dabei nicht; `make test-bats` ist einzeln gefahren — `1..231`, kein `not ok`,
darunter die zwei Breiten-Wächter-Fälle `ok 126` und `ok 127`.

---

## Findings

### MEDIUM-1 — Zwei Bezug-Zeilen von ADR-0040 sagen, die Entscheidung schließe eine Zuständigkeits-Lücke, die sie ausdrücklich offen lässt

- `kategorie`: MEDIUM
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  §Bezug gegen §Entscheidung und §Verglichene Alternativen Zeile C;
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Geschichte;
  [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1
- `pfad`: `docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md:12` und `:13`
  gegen `:146` und `:178`
- `befund`: Die erste Zeile stellt fest, [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md)
  §Geschichte messe, *„dass **keine** Quelle dieses Repos und keine der vendored Baseline einen
  annehmenden **Akteur** benennt"*, und schließt: *„diese Entscheidung füllt die Lücke, die dort
  benannt ist"*. Die zweite nennt [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)
  *„dieselbe Bauart: eine **Zuständigkeit**, die keine Quelle benennt, wird entschieden statt weiter
  offen gelassen"*. §Entscheidung derselben Datei sagt das Gegenteil — *„**Sie benennen keinen
  annehmenden Akteur.** Wer entscheidet, bleibt offen wie bisher"* —, und Zeile C der
  Alternativen-Tabelle verwirft diesen Weg eigens, weil er *„in eine Frage eingriffe, die bei
  Personalunion dem Auftraggeber gehört"*. Die Achse, die beide Bezug-Zeilen benennen, ist damit
  genau die, auf der diese Entscheidung nichts entscheidet: Festlegung 1 von
  [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) weist eine schreibende Rolle
  zu, ADR-0040 bindet den Akt und lässt das *Wer* stehen. Ab `Accepted` friert
  [`AGENTS.md`](../../AGENTS.md) §3.4 beide Zeilen ein.
- `verifizierbar`: **nein** — kein Modul aus `modules:` der [`.d-check.yml`](../../.d-check.yml)
  (`links, anchors, ids, matrix, codepaths, spans, planning`) hält eine Bezug-Zeile gegen den
  Rumpf ihrer eigenen Datei, und `make mutate` kennt dafür keine Fehlschlag-Form. Nachfahrbar von
  Hand: die zwei Zeilen gegen `:146` und `:178` derselben Datei.
- `klasse`: Bezug-Zeile behauptet eine Reichweite, die die Entscheidung ausschlägt

### LOW-1 — Der Grund, mit dem ADR-0039 die Verhaltensänderung der vier bestehenden Paare belegt, hat für eines der vier keinen Fall

- `kategorie`: LOW
- `quelle`: [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
  Festlegung 2, Absatz *Am Tag dieser Entscheidung*, gegen Absatz *Die Deklaration `0` ist eine
  Deklaration* derselben Festlegung; [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md:229`–`:231`
  gegen `:195`–`:198`
- `befund`: Der Satz lautet *„Am Tag dieser Entscheidung bleibt damit jedes der vier grün. Ihr
  Verhalten ändert sich trotzdem … Die Unterschranke ist auch für sie neu — fällt ein gedeckter
  Link weg, ist das Paar rot statt still grün."* Beide Hälften des Verdikts sind nachgefahren und
  tragen (N-2, N-3). Der genannte **Grund** trägt für drei der vier: Das dritte Paar deklariert
  **0**, und für es stellt dieselbe Festlegung 33 Zeilen höher fest, `gedeckt < 0` sei *„über einer
  Zählung unerfüllbar, die Klausel hätte keinen Fall"*. Sein Verhalten ändert sich über die
  **Ober**schranke — ein hinzutretender Link färbt es rot statt grün —, und genau das sagt die ADR
  einen Absatz davor eigens (*„wird rot, sobald der erste Markdown-Link hinzutritt"*). Die
  zusammenfassende Zeile führt diesen Fall unter der Unterschranke mit und quantifiziert damit
  einen Mechanismus über ein Mitglied, für das dieselbe Datei ihn als fallfrei ausweist.
- `verifizierbar`: **ja, indirekt** — `make test-bats` Fall 127 nach dem Umbau: Für einen Eintrag
  mit Deklaration 0 und Deckung 0 lässt sich kein Rot herstellen, indem ein gedeckter Link entfernt
  wird; das Rot entsteht nur durch Hinzutreten.
- `klasse`: Begründung quantifiziert über ein Mitglied, für das sie keinen Fall hat

### LOW-2 — Dieselbe Aussage über die vier bestehenden Paare steht einmal datiert und einmal undatiert, und die undatierte trägt das Supersedes-Argument

- `kategorie`: LOW
- `quelle`: [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
  §Entscheidung, Punkt *Kein `Supersedes`*, gegen die Implementer-Folgepflicht und gegen
  Festlegung 2
- `pfad`: `docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md:283` gegen `:329`
  und `:229`
- `befund`: Der Punkt schließt mit *„sein Verdikt über jene vier Paare bleibt dasselbe"* — ohne
  Zeitbezug. Festlegung 2 sagt dieselbe Sache mit einem: *„**Am Tag dieser Entscheidung** bleibt
  damit jedes der vier grün"*, und setzt hinzu, ihr Verhalten ändere sich trotzdem. Die
  Implementer-Folgepflicht verlangt die Deklaration an *„**allen sieben** Einträgen"*, also auch an
  jenen vier. Wer den Supersedes-Punkt allein liest — und er ist die Stelle, an der ein späterer
  Lauf nachschlägt, ob [ADR-0026](../plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [ADR-0027](../plan/adr/0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  [ADR-0032](../plan/adr/0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) und
  [ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  berührt sind —, entnimmt ihm, an den vier bestehenden Paaren sei nichts zu tun.
- `verifizierbar`: **nein** — kein Modul hält zwei Aussagen derselben Datei gegeneinander.
  Nachfahrbar von Hand: `:283` gegen `:229` und `:329`.
- `klasse`: Dieselbe Aussage einmal datiert, einmal nicht

### LOW-3 — Zeile E nennt ADR-0036 als gelebtes Vorbild der Form, die Festlegung 1 verlangt; ADR-0036 lebt die Sache und nicht die Adress-Form

- `kategorie`: LOW
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  §Verglichene Alternativen Zeile E gegen Festlegung 1 derselben Datei;
  [`AGENTS.md`](../../AGENTS.md) §3.11
- `pfad`: `docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md:181`
  gegen `:116`–`:119`
- `befund`: Zeile E führt als Pro-Argument *„die Form, die Festlegung 1 verlangt, existiert bereits
  gelebt in [ADR-0036]"*. Festlegung 1 verlangt den Beleg *„als auflösbaren Zeiger, in der Form,
  die [ADR-0027] für ein einfrierendes Artefakt vorschreibt (**Kennung, nicht Pfad-Link**)"*. Die
  Accept-Zeile von [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) nennt ihre
  drei Reports als volle Pfade in Inline-Code. Sie lebt damit die **Sache** der Festlegung — Beleg
  genannt, Befundzahl genannt, kein Rest ausdrücklich festgestellt — und nicht die **Adress-Form**,
  die derselbe Satz vorschreibt; [`AGENTS.md`](../../AGENTS.md) §3.11 nimmt die Code-Span-Achse
  ausdrücklich mit (*„über **beide** Adress-Formen"*). Ein Bruch entsteht daraus heute nicht: Die
  Reports tragen keine Slice-Kennung, `make archive-welle` sammelt nach Slice ein, und es sperrt
  fail-closed bei einem noch verwiesenen Report. Genannt, weil beide Dateien einfrieren und ein
  späterer Lauf die Zeile als Formvorbild liest.
- `verifizierbar`: **nein** — `codepaths` führt `exempt-paths: ["docs/reviews/**"]` für die
  Quellseite; solange die drei Reports liegen, ist der Pfad grün.
- `klasse`: Vorbild trägt die Sache, nicht die Form

### INFO-1 — Eine Zahl über einen wachsenden Korpus ist in einer ADR nicht einholbar, und Festlegung 2 von ADR-0040 macht das beweisbar

- `kategorie`: INFO
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2; [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 2
- `pfad`: `docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md:296` (Alternative C)
  und `docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md:75`
- `befund`: Beide Zahlen sind heute richtig und morgen falsch, und die Ursache ist nicht
  Nachlässigkeit, sondern die Bauart der Messung. Alternative C zählt
  `git ls-files 'docs/reviews/*.md' | wc -l` → **301** und die repo-internen Link-Prüfungen darüber
  → **3972**; ADR-0040 zählt
  `git grep -lF '0038-ziel-fassung-regiert-den-sprung-v650' -- 'docs/reviews/*.md'` → **3**. Alle
  drei sind an `HEAD` = `712e4fde` nachgefahren und stimmen. **Der Korpus, den sie zählen, ist
  derselbe, den das Prüfverfahren der ADR füllt:** Jede Runde legt eine Datei in `docs/reviews/`
  ab, und eine Runde über einer Entscheidung, die ADR-0038 nennt, erhöht auch die zweite Zahl.
  Dieser Report macht 301 zu **302** und 3 zu **4**.

  **Verfolgbar ist die Klasse, einholbar ist die Zahl nicht — und das ist seit
  [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) keine Empirie
  mehr, sondern eine Ableitung.** Festlegung 2 verlangt nach einem blockierenden Befund eine
  **weitere** Runde als Beleg. Damit steht fest: Zwischen dem Stand, an dem eine solche Zahl in
  eine `Proposed`-ADR geschrieben wird, und ihrer Annahme liegt mindestens ein weiterer Report.
  Eine Zahl über `docs/reviews/**` in einer ADR ist im Moment ihrer eigenen Annahme falsch — nicht
  gelegentlich, sondern immer.

  **Was der Zusatz *„keine Erwartungswerte"* dagegen nicht leistet:** Er deckt Drift **nach** dem
  Schreiben. Hier ist die Zahl bereits beim Schreiben eine andere, weil der schreibende Vorgang sie
  bewegt hat. Die beiden bisher gefahrenen Korrekturen — 299 → 301 und 2 → 3 — sind darum keine
  Nachlässigkeit, die eine dritte Korrektur beheben könnte.

  **Drei Formen halten, eine nicht** — beurteilt, nicht vorgeschlagen:
  *Datiert* (`am 2026-09-07: 301`) macht aus der Präsens-Behauptung eine Messung mit Stichtag und
  ist im selben Dokument bereits gelebt — Festlegung 2 datiert ihre Deklarations-Messung
  ausdrücklich (*„Am Tag dieser Entscheidung"*, *„am selben Tag"*), die Alternativen-Tabelle nicht.
  *Im Report statt in der ADR* verlagert die Zahl in ein Zeitdokument, das ohnehin außerhalb des
  Geltungsbereichs von [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  liegt und mit seinem Datum einfriert; die ADR verliert dabei das Gewicht des Arguments nicht,
  weil sie das Verhältnis behalten kann. *Durch ein Kriterium ersetzt, das den Gegenstand selbst
  misst* ist der zweite Ausgang, den
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2 wörtlich führt und den hier niemand genommen hat: Alternative C braucht nicht den
  Betrag, sondern das Verhältnis zu den 36 gedeckten Befunden, und das Verhältnis wandert nicht.
  *Eine Formulierung, die den eigenen Beitrag ausnimmt* (*„ohne die Reports dieses Vorgangs"*)
  trägt **nicht**: Welche Dateien zu *diesem Vorgang* gehören, ist ein Urteil und kein Muster —
  ein Wächter darüber gäbe ein Muster als Kriterium aus, das keines ist
  ([`AGENTS.md`](../../AGENTS.md) §3.6).
- `verifizierbar`: **nein** — kein Modul fährt ein zitiertes Kommando nach; die drei Kommandos sind
  von Hand an `HEAD` gefahren.
- `klasse`: Zahl misst einen Korpus, den ihr eigenes Prüfverfahren füllt

### INFO-2 — Ob Festlegung 1 die Accept-Zeile von ADR-0039 bindet, hängt an der Reihenfolge der zwei Übergänge, und beide Zeilen frieren ein

- `kategorie`: INFO
- `quelle`: [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
  Festlegung 1 und der Cutoff in §Entscheidung; [`AGENTS.md`](../../AGENTS.md) §3.4
- `pfad`: `docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md:119`–`:120`
  und `:153`–`:156`
- `befund`: Festlegung 1 sagt: *„Trägt die Datei **keinen** Acceptance-Trigger, sagt die Zeile das
  ausdrücklich; ein fehlender Trigger ist eine Aussage, kein Freibrief."*
  [ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) trägt keinen
  (`grep -i acceptance` über die Datei ist leer). Der Cutoff bindet *„den Übergang, der vollzogen
  wird"*, ab dieser Entscheidung. Beide Dateien stehen auf `Proposed` und haben denselben Beleg
  vor sich; ob die Accept-Zeile von ADR-0039 die Trigger-Aussage tragen muss, entscheidet damit
  allein, ob sie vor, mit oder nach ADR-0040 umgelegt wird. Keine der beiden Dateien sagt es, und
  nach dem Umschlag nimmt [`AGENTS.md`](../../AGENTS.md) §3.4 beiden Zeilen die Korrigierbarkeit.
- `verifizierbar`: **nein** — kein Modul liest einen Statuswert oder eine Reihenfolge zweier
  Commits; beide ADRs stellen das für sich selbst fest.
- `klasse`: Cutoff lässt die Reihenfolge zweier gleichzeitig fälliger Übergänge offen

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — HIGH-1: Der Äquivalenz-Beleg ist eine Messung, keine als Messung gesetzte Tautologie.**
  Der abgedruckte `awk`-Lauf liefert verbatim `0 Unterschiede`. Der tragende Teil ist die
  Kontrolle, und die ist eigenständig gefahren, nicht übernommen: dieselbe Schleife mit **ganz
  entfernter** Unterschranke liefert `21 Unterschiede`, mit der Schranke auf `dec > 1` statt
  `dec > 0` liefert sie `1 Unterschiede`. Der Lauf kann also Unterschiede finden; dass er über
  `dec > 0` keine findet, ist ein Ergebnis. Die Verallgemeinerung über 0…6 hinaus trägt: `cov < 0`
  ist über einer Zählung unerfüllbar, damit fällt die Unterschranke für `dec = 0` weg und stimmt
  für `dec > 0` mit der Gleichheit zusammen.
- **N-2 — HIGH-1: `1 · 1 · 0 · 1` ist zweimal unabhängig gemessen.** Einmal mit dem in der ADR
  abgedruckten Kommando (liefert `1 · 1 · 0 · 1` in Config-Reihenfolge), einmal mit der
  **unveränderten `count_links`-Funktion des Wächters selbst** aus
  [`test/ignore-refs-restbreite.bats`](../../test/ignore-refs-restbreite.bats), je Paar einzeln
  aufgerufen — dasselbe Ergebnis. Die zweite Messung ist die tragende: Der Wächter, nicht das
  Kommando, fällt später das Urteil. Das Null-Paar ist
  `docs/plan/adr/0018-…` → `docs/plan/planning/welle-10-re-baseline.md`, wie die ADR angibt.
- **N-3 — HIGH-1: Alle vier bleiben unter *„genau N"* grün, und die Verhaltensänderung ist real.**
  Alter Maßstab `n > 1 → rot`, neuer `n ≠ deklariert → rot`. Für die drei Paare mit Deklaration 1
  verschiebt sich die Grenze bei `n = 0` (vorher grün, jetzt rot), für das Null-Paar bei `n = 1`
  (vorher grün, jetzt rot). Kein Paar kippt am heutigen Stand. Was daran nicht aufgeht, steht in
  LOW-1 und betrifft die Begründung, nicht das Verdikt.
- **N-4 — HIGH-1: „alle sieben" stimmt.** `grep -c '^  - in: ' .d-check.yml` → **4** bestehende
  Einträge, Festlegung 1 legt **3** hinzu. Die erste Bedingung von Festlegung 2 (*„Jeder Eintrag
  deklariert"*) und die Folgepflicht (*„an allen sieben Einträgen"*) decken sich; ein Eintrag ohne
  Deklaration ist nach der zweiten Bedingung rot, der Ausgang ist fail-closed.
- **N-5 — HIGH-1: Die vierte rot-zu-sehende Mutation ist aufgenommen und passt zum Fall.** Die
  Implementer-Folgepflicht führt *„fehlende Deklaration, zu hohe Zahl, zu niedrige Zahl, und die
  Deklaration `0`, die von einer fehlenden zu unterscheiden ist"* — vier Gegenbeispiele
  ([`AGENTS.md`](../../AGENTS.md) §3.6). Genau die vierte ist die, ohne die das Null-Paar unter
  der zweiten Bedingung still durchginge.
- **N-6 — HIGH-1: Die drei neuen Deklarationen und die Delta-Erklärung sind nachgefahren.**
  Das abgedruckte Kommando liefert `33 · 3 · 2`. Die Erklärung des Deltas `38 − 36 = 2` nennt jetzt
  **beide** Fälle, und beide sind einzeln gemessen: eine heute auflösende Adresse in den lebenden
  Baum (`git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0/' -- <drei Bäume> | wc -l` → **1**) und
  die Inline-Code-Fundstelle mit `<tag>`-Platzhalter
  (`git grep -oE '\]\([^)]*baseline/<tag>/' -- 'docs/reviews/*.md' | wc -l` → **1**). Der zweite
  Fall war in Runde 1 unbenannt; die Angabe *„gedeckt sind für diesen Baum darum höchstens 32"*
  ist damit gedeckt. MEDIUM-3 der Vorrunde ist geschlossen.
- **N-7 — Der Bestand ist unverändert so groß wie angegeben.** `36` Adressen in `16` Dateien, mit
  den zwei abgedruckten Kommandos gefahren; verteilt `32 · 3 · 1` auf `docs/reviews/**`,
  `docs/plan/planning/done/**` und `docs/plan/planning/observations/**` — deckungsgleich mit den
  36 `target-missing`-Zeilen des `docs-check`-Laufs.
- **N-8 — MEDIUM-2 der Vorrunde ist geschlossen, und die neuen Werte sind an `HEAD` gefahren.**
  Alternative C nennt jetzt **301** und **3972**; beide abgedruckten Kommandos liefern genau das.
  Dass sie erneut altern, ist kein Befund, sondern INFO-1.
- **N-9 — HIGH-2: Die vier tragenden Zitate sind verbatim.** Aus der Reviewer-Runde vom 2026-09-07
  zu [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md): die zwei
  HIGH-Überschriften (*„Die Festlegung deckt den Sprung nicht, den der abhängige Plan führt"*,
  *„Der Zielstand `v6.5.0` ist im Repo nirgends gesetzt"*), das Verdikt (*„Nicht annahmefähig in
  dieser Runde — zwei HIGH"*) und die Selbstaussage (*„dieser Report ist es nicht; er blockiert an
  HIGH-1 und HIGH-2"*). Alle vier per `grep` an der Quelldatei belegt.
- **N-10 — HIGH-2: Die verworfene Beweisform hat keinen Rest in der Datei.** Gesucht nach
  *„geprüft und trägt"*, *„bestätigt die Entscheidung"*, *„beanstandet den Akt"* und
  *„inhaltlich geprüft"* — kein Treffer. Die frühere Prämisse steht auch nicht abgeschwächt in der
  B-Zeile der Alternativen-Tabelle; die ist auf dieselbe neue Begründung umgestellt.
- **N-11 — HIGH-2: Die neue Begründung trägt sich selbst.** Sie ruht auf drei Aussagen, von denen
  keine den Inhalt von [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md)
  beurteilt: (a) `Supersedes` setzt eine neue Entscheidung über denselben Gegenstand voraus — das
  folgt aus [`AGENTS.md`](../../AGENTS.md) §3.4 (*„Korrekturen entstehen als neue ADR mit
  Supersedes"*) und aus `v6.5.0` · `modul-08-agentenrollen.md` §Rollen-Regeln
  (*„Accepted-ADRs überschreibt niemand — Folge-ADR mit `supersedes`"*); (b) dieser Lauf hat sie
  nicht, weil er über den Übergang entscheidet und nicht über den Sprung; (c) der einzige
  Inhalts-Beleg, der zur Verfügung stünde, ist die Nachmessung, die Festlegung 2 verwirft. Die
  Umkehr auf **Nicht-Verfügbarkeit statt Entbehrlichkeit** ist damit vollzogen, nicht nur
  umformuliert. Die Aktenlage-Aussage (*„Ob die Festlegung … trägt, ist … offen"*) ist präzise: Der
  vorliegende Report ist Evidenz **gegen** den damaligen Inhalt, nicht **für** ihn, und *„es gibt
  dazu eine Nachmessung des schreibenden Kontexts und sonst nichts"* spricht über die Für-Seite.
- **N-12 — Der Acceptance-Trigger von ADR-0040 ist gegen alle drei genannten Entscheidungen
  gehalten.** Gegen [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md): Ihre
  Accept-Zeile nennt drei Reports namentlich, ihre gemeinsame Befundzahl (1 HIGH, 6 MEDIUM) und
  dass die dritte Runde keinen Rest feststellt — die Tabelle in §Der Anlass gibt das richtig
  wieder. Gegen [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md): Ihre
  Accept-Zeile nennt die Entscheidung des Auftraggebers und eine eingelöste Planner-Folgepflicht,
  keinen Beleg — ebenfalls richtig wiedergegeben. Gegen
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md): Ihre Accept-Zeile trägt die
  Messung über die gerankten Quellen, das Briefing, den Harness-Einstieg, den ADR-Index und den
  vendored Baum — sie steht dort, wie behauptet. Der vierte Punkt der Prüfung, die Charakterisierung
  dieser drei Bezüge im Kopf der Datei, steht in MEDIUM-1.
- **N-13 — MEDIUM-4 und MEDIUM-5 der Vorrunde sind geschlossen.** Der Acceptance-Trigger holt jetzt
  ausdrücklich **beide** Hälften zurück (*„Festlegung 1 gilt für diese Datei damit ebenso … Der
  Trigger holt **beide** Hälften zurück, nicht eine"*), womit die Selbst-Ausnahme nicht mehr halb
  importiert. Und der dritte Ausgang für die offene Instanz steht: Option F als mitgewählte Zeile,
  eine Planner-Folgepflicht, ein Negativ-Posten in §Konsequenzen und ein Re-Evaluierungs-Trigger für
  den Fall, dass jene Runde den Inhalt bestreitet. Die Formulierung *„fällig unabhängig von dieser
  Entscheidung"* neben *„mitgewählt"* ist geprüft und widerspruchsfrei: Geschuldet ist die Runde vom
  Trigger jener Datei, nicht von dieser Annahme.
- **N-14 — LOW-1 und LOW-2 der Vorrunde sind geschlossen.** Die zwei Wächter-Zähne stehen jetzt als
  **falsch rot** und **falsch grün** getrennt, mit dem Zusatz, dass das für einen Wächter nicht
  dasselbe Versagen ist. Die Kardinalitäts-Grenze steht doppelt: als eigene Zeile der
  §Fitness-Function-Tabelle (*„tauscht ein gedeckter Link gegen einen anderen …? — niemand"*) und
  als Einschränkung des Positiv-Postens in §Konsequenzen.
- **N-15 — Weder Commit bringt eine neue Adresse der Klasse ein, die ADR-0039 behandelt.**
  `grep -nE '\]\([^)]*\.harness/baseline/'` über beide ADRs ist leer; alle Baseline-Nennungen stehen
  als Tag in Inline-Code (`v6.5.0` zehnmal, `v6.0.0` viermal, jede über die zwei Dateien). Die
  Zählungen `36`, `16`, `919` bleiben von den zwei Commits unberührt.
- **N-16 — Der Commit-Zuschnitt hält [`AGENTS.md`](../../AGENTS.md) §3.8.** `cfa01076` berührt genau
  `docs/plan/adr/0039-…md`, `712e4fde` genau `docs/plan/adr/0040-…md`; beide nennen die Rolle in der
  ersten Zeile ihrer Message. Der ADR-Index bleibt zu Recht unberührt — beide Statuswerte stehen
  weiter auf `Proposed`, und die Bezugslisten der zwei Index-Zeilen sind mit den Kopf-Blöcken der
  Dateien deckungsgleich (je Element einzeln verglichen).
- **N-17 — Das rote Gate ist der erklärte Zustand und trägt unverändert.** `36` Befunde, alle
  `target-missing`, alle in den drei einfrierenden Bäumen, kein Befund außerhalb dieser Klasse und
  keiner, den die zwei Commits erzeugt hätten. Die geprüfte Dateizahl steht bei `919` statt `918`,
  weil der Report der Vorrunde hinzugekommen ist — sie ist kein Erwartungswert.
- **N-18 — Dieser Report bringt keine 37. Adresse ein, und das ist gemessen statt zugesagt.** Er
  nennt keine Stelle des vendored Baums als Markdown-Link und keinen Review-Report als Adresse;
  Baseline-Stellen stehen als Tag plus Modulname in Inline-Code, Reports als Kennung. Mit dieser
  Datei im Baum meldet `make docs-check` `920 Datei(en) geprüft, **36** Befund(e)` — eine Datei
  mehr, kein Befund mehr, und keine Zeile des Laufs nennt diesen Report.
- **Nicht geprüft, weil bewusst vertagt:** MEDIUM-1 der Vorrunde (der `in:`-Glob auf
  `docs/plan/planning/observations/**` deckt mit `state.md` und `README.md` zwei Datei-Klassen, die
  nicht einfrieren). Der Zuschnitt steht unverändert; die Verengung ist als eigener Vorgang
  ausgewiesen. Kein blockierender Befund daraus.
- **Übertrag, offen und außerhalb dieser zwei Commits:** MEDIUM-6 der Vorrunde
  (`harness/conventions.md:30` trägt statt des zweiten Pflichtteils von
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2
  eine Zustands-Aussage) · MEDIUM-7 (zwei Kommandos in [`AGENTS.md`](../../AGENTS.md) §1 stehen auf
  dem gefallenen Tag) · die zweite Hälfte von INFO-2 der Vorrunde: Festlegung 1 von ADR-0040
  schreibt die Kennungs-Form weiter
  [ADR-0027](../plan/adr/0027-tote-adresse-in-eingefrorener-adr.md) zu, deren Festlegung 3 aber über
  **Carveouts** spricht; die Verallgemeinerung auf jedes prozess-bewegte Artefakt steht in
  [`AGENTS.md`](../../AGENTS.md) §3.11. Die erste Hälfte jenes INFO-2 ist geschlossen — der
  Report-Pfad in §Der Anlass ist durch eine Kennung ersetzt.
- **Nicht geprüft, weil nicht meine Rolle:** die DoD-Abhakung (Verifikation), der reale Bedarf
  hinter beiden Entscheidungen (Validierung) und der **Inhalt** von
  [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) — sie steht auf `Accepted`
  und ist nach [`AGENTS.md`](../../AGENTS.md) §3.4 eingefroren. Genau diese Prüfung ist die Runde,
  die Option F als Planner-Folgepflicht einplant; dieser Lauf ist sie nicht.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | MEDIUM-1 (ADR-0040) |
| LOW | 3 | LOW-1 · LOW-2 (ADR-0039) · LOW-3 (ADR-0040) |
| INFO | 2 | INFO-1 (beide) · INFO-2 (ADR-0040) |

**Wiederkehrende Klassen für den Steering-Loop-Zähler** (Eintrag bei der Closure, nicht hier):
*Zahl misst einen Korpus, den ihr eigenes Prüfverfahren füllt* (INFO-1 — zweiter Lauf in Folge,
nach MEDIUM-2 der Vorrunde) · *Aussage einmal datiert, einmal nicht* (LOW-2) · *Bezug-Zeile
behauptet eine Reichweite, die die Entscheidung ausschlägt* (MEDIUM-1).

---

## Verdikt

**Getrennt je Entscheidung. Accept-Kriterium ist kein HIGH.**

### ADR-0039 — **annahmefähig: kein HIGH**

HIGH-1 ist behoben, und die Behebung ist gemessen statt behauptet. Die tragende Bewegung — die
Deklaration folgt dem Bestand statt einer Zusage — ist zweimal unabhängig nachgefahren, einmal mit
dem abgedruckten Kommando und einmal mit der unveränderten `count_links`-Funktion des Wächters
selbst (N-2). Der Beleg dafür, dass die Unterschranken-Ausnahme kein zweiter Ausgang ist, ist eine
echte Messung und keine als Messung gesetzte Tautologie: Die Kontrollen liefern 21 und 1
Unterschiede, der geprüfte Fall 0 (N-1). Die drei Folgen der Wahl stehen vollständig da — das
dritte Paar deklariert 0, `0` ist als vierte rot-zu-sehende Mutation von *fehlend* geschieden, und
die Deklaration gilt an allen sieben Einträgen (N-4, N-5). Die ersetzte Zusage trägt in ihrem
Verdikt: Alle vier bleiben heute grün, und ihr Verhalten ändert sich trotzdem, für drei über die
neue Unterschranke und für das Null-Paar über die Oberschranke. Was daran nicht aufgeht, ist der
Grund, mit dem der zusammenfassende Satz alle vier bedient (LOW-1) — kein Fehler im Verdikt,
sondern eine Begründung, die einen Absatz weiter oben bereits richtig und enger steht. LOW-2
betrifft dieselbe Aussage an ihrer zweiten, undatierten Fundstelle. Dazu sind MEDIUM-2, MEDIUM-3,
LOW-1 und LOW-2 der Vorrunde geschlossen und je nachgemessen (N-6, N-8, N-14).

### ADR-0040 — **annahmefähig: kein HIGH**

HIGH-2 ist behoben, und zwar an der Wurzel statt an der Formulierung. Die Prämisse, der Report
bestätige den Inhalt und beanstande den Akt, ist ersatzlos verschwunden — gesucht und nicht mehr
auffindbar (N-10) —, und an ihre Stelle tritt eine Begründung, die ohne jedes Urteil über den
Inhalt von [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) auskommt: kein
`Supersedes` aus **Nicht-Verfügbarkeit**, weil dieser Lauf über den Übergang und nicht über den
Sprung entscheidet und der einzige Inhalts-Beleg die von Festlegung 2 verworfene Nachmessung wäre
(N-11). Die Datei wendet ihre eigene Regel damit auf ihre eigene Begründung an, statt sie zu
umgehen. Die Aktenlage-Aussage ist präzise, die vier tragenden Zitate sind verbatim (N-9), und der
offene Fall hat mit Option F, Planner-Folgepflicht, Negativ-Posten und Re-Evaluierungs-Trigger
einen benannten Ausgang (N-13). Der Acceptance-Trigger dieser Datei ist gegen alle drei genannten
Entscheidungen gehalten und trägt in drei von vier Punkten (N-12). Der vierte ist MEDIUM-1: Zwei
Zeilen des Bezug-Blocks schreiben der Entscheidung eine Zuständigkeits-Klärung zu, die §Entscheidung
und Zeile C der Alternativen-Tabelle ausdrücklich ablehnen. Das blockiert nicht — die Festlegungen
selbst sind eindeutig —, es friert aber mit `Accepted` ein und ist die Stelle, an der ein späterer
Lauf nachschlägt, ob dieses Repo einen annehmenden Akteur benennt. LOW-3 und INFO-2 betreffen die
Form der eigenen Vorbild- und Cutoff-Aussagen.

### Was dieser Report für den Accept-Übergang ist

Er ist eine Runde derselben prüfenden Rolle in frischem Kontext, gefahren gegen den Stand
`712e4fde`, mit eigener Messung statt Übernahme der auflösenden Nachmessung — der Beleg, den
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
verlangt. Er blockiert keine der beiden Entscheidungen. Was die Accept-Zeilen daraus zitieren, und
in welcher Reihenfolge die zwei Übergänge vollzogen werden, entscheidet der annehmende Lauf;
INFO-2 benennt, was an dieser Reihenfolge hängt.
