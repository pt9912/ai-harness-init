# Review — slice-124: Die Gate-Tabellen bekommen einen Wächter

**Rolle:** Reviewer · **Datum:** 2026-09-11 · **Runde:** 1

**Prüfgegenstand:** Commit `6f454e15` (*Rolle Implementer: slice-124 — targets-Modul aktiviert,
36 Rezepte kuratiert*). Die zwei `slice-mv`-Commits davor (`d7fb8844`, `b90fb9d9`) sind reine
Lifecycle-Bewegung und nicht Gegenstand.

**Baum beim Eintritt:** `git status --porcelain` leer, `HEAD` = `6f454e15`.

**Plan:** [`slice-124`](../plan/planning/done/slice-124-gate-tabelle-hat-einen-waechter.md)
· **Quellen:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`AGENTS.md`](../../AGENTS.md) §3.1 · §3.6 · §3.7 · §3.8 · §3.10,
[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
[`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile),
[`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert),
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).

**Berührt:** `.d-check.yml`, `harness/README.md`,
`docs/plan/planning/in-progress/roadmap.md`, `test/targets-modul-wiring.bats` (neu),
`test/mutations/301-targets-modul-deaktiviert.sh` und `302-targets-exempt-eintrag-entfernt.sh`
(neu). **Nicht** berührt: `AGENTS.md`, `harness/conventions*`, der Slice-Plan selbst.

**Eigene Messung:** 8 `docker run`-Läufe gegen den in [`d-check.mk`](../../d-check.mk) gepinnten
Digest (`sha256:e31a372b…`), je `--network none`, Mount `:ro`, über Kopien außerhalb des Repos
(`git archive <ref> | tar -x -C <kopie>`). Kein `make`-Ziel gefahren (laufender
`make mutate`-Vollauf teilt sich die Docker-Tags).

---

## Findings

### HIGH-1 — Zwei bestehende Mutations-Fälle sind durch diesen Commit wirkungslos geworden; `make mutate` ist damit rot

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · Slice §5 Closure-Trigger (*„`make mutate` ohne
  Befund"*)
- **pfad:** `test/mutations/269-planning-modul-aus-modules-entfernt.sh:10` ·
  `test/mutations/279-vcs-in-modules-aktiviert.sh:10`
- **befund:** Beide Fälle verankern ihr `sed` end-anchored auf der alten `modules:`-Zeile
  (`…, spans, planning\]$`). Der Commit hängt `, targets` an, womit beide Adressen **null** Zeilen
  treffen und die Mutation nichts mehr verändert. Der Treiber erkennt das fail-closed und meldet je
  einen Befund; die zwei Wächter `planning ist in modules: aktiviert` und
  `vcs ist NICHT in modules: aktiviert` werden dabei nicht mehr geprüft.
- **verifizierbar:** ja — `make mutate` (die zwei Fälle), heute nicht gefahren; stattdessen die
  Bedingung selbst gemessen, die der Treiber prüft.
- **klasse:** Mutations-Adresse veraltet nach Config-Zeilen-Änderung

**Gemessen (Adress-Treffer):**

```sh
grep -n '^modules:' .d-check.yml
#   29:modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]
grep -cE '^modules: \[links, anchors, ids, matrix, codepaths, spans, planning\]$' .d-check.yml   # 0
grep -cE '^modules: \[links, anchors, ids, matrix, codepaths, spans, planning, targets\]$' .d-check.yml  # 1
```

**Gemessen (Wirkung, wie der Treiber sie prüft — Mutation auf eine Kopie anwenden, Hash vergleichen):**

```sh
for n in 269-planning-modul-aus-modules-entfernt 279-vcs-in-modules-aktiviert \
         301-targets-modul-deaktiviert 302-targets-exempt-eintrag-entfernt; do
  rm -rf "$T" && mkdir -p "$T" && cp .d-check.yml "$T/"
  b=$(sha256sum "$T/.d-check.yml"); ( cd "$T" && bash "$PWD_REPO/test/mutations/$n.sh" )
  a=$(sha256sum "$T/.d-check.yml"); [ "$b" = "$a" ] && echo "$n NO-OP" || echo "$n greift"
done
# 269-planning-modul-aus-modules-entfernt   NO-OP
# 279-vcs-in-modules-aktiviert              NO-OP
# 301-targets-modul-deaktiviert             greift
# 302-targets-exempt-eintrag-entfernt       greift
```

**Gegenprobe am Eltern-Stand** — beide griffen vorher, die Regression ist von diesem Commit:

```sh
git show 6f454e15^:.d-check.yml > "$T/.d-check.yml"   # danach dieselbe Schleife
# 269 … greift        279 … greift
```

**Die Meldung, die der Treiber ausgibt**, steht in
[`harness/tools/mutate.sh:678`](../../harness/tools/mutate.sh) — Bedingung (2), fail-closed:

```sh
  if [ -n "$unchanged" ]; then
    report_fail "$name" "Mutation hat nicht gegriffen bei:$unchanged — Patch veraltet?"
```

Kein stilles Grün also — der Sensor fällt korrekt. Blockierend ist der Befund, weil §5 des Plans
`make mutate` ohne Befund als Closure-Trigger führt und der laufende Vollauf genau diese zwei
Befunde zurückbringen wird.

---

### MEDIUM-1 — Die Begründung der Ausnahme-Gruppe (a) behauptet eine Eigenschaft, die vier ihrer sechzehn Einträge nicht tragen

- **kategorie:** MEDIUM
- **quelle:** [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
  (*„jede Ventil-Zeile nennt, was sie ausnimmt und warum"*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.7 · Slice DoD (2)
- **pfad:** `.d-check.yml:70-75` (Kommentarblock über `exempt-targets`, Gruppe (a); die tragende Zeile ist 71)
- **befund:** Der Block sagt *„jedes Rezept traegt einen eigenen `## `-Hilfetext mit der Angabe
  'NICHT in gates'"*. Gemessen tragen **12 von 16** diese Angabe; `span-clean`, `doc-immutable`,
  `doc-commits` und `record-gates` tragen sie nicht. Damit steht die einzige schriftliche
  Begründung der Senkung für ein Viertel der Gruppe auf einem Konjunkt, das nicht zutrifft.
- **verifizierbar:** nein — kein Gate liest den Wahrheitsgehalt eines Config-Kommentars
  (`make comment-claims` hat `.d-check.yml` nicht im Prüfbereich).
- **klasse:** Sammel-Begründung behauptet eine Eigenschaft, die nicht jedes Mitglied trägt

**Gemessen:**

```sh
for t in smoke full-smoke mutate span-clean span-report hook-overhead slice-mv archive-welle \
         vendor-baseline regelwerk-check baseline-freshness history-range-guard adr-immutable \
         doc-immutable doc-commits record-gates; do
  grep -hE "^${t}:.*## " Makefile d-check.mk | grep -qi 'NICHT in gates' || echo "ohne Marke: $t"
done
# ohne Marke: span-clean
# ohne Marke: doc-immutable
# ohne Marke: doc-commits
# ohne Marke: record-gates
```

Die vier Hilfetexte im Wortlaut:

```
span-clean:    ## Span-Bestaende entfernen (ausdruecklich, kein Automatismus)
doc-immutable: ## Doc-/ADR-Immutabilität via git-Diff (Modul vcs); RANGE=base..head oder STAGED=1 …
doc-commits:   ## Commit-Message-Traceability via Modul commits; RANGE=base..head …
record-gates:  ## Checks + Gate-Nachweis (Working-Tree-Hash für den Stop-Hook)
```

**Das zweite Konjunkt derselben Zeile trägt dagegen vollständig** — alle 16 sind in
[`harness/README.md`](../../harness/README.md) genannt; die Ausnahmen selbst sind also sachlich
gedeckt, nur ihre Begründung ist zu weit formuliert:

```sh
for t in <dieselben 16>; do
  printf '%-22s %s\n' "$t" "$(grep -cE "(make ${t}\b|\`${t}\`)" harness/README.md)"
done   # jeder Wert >= 2, kein Nulltreffer
```

**Umformulieren, nicht streichen:** Das tragfähige Konjunkt ist die Prosa-Deckung in
`harness/README.md`; die `## `-Marke „NICHT in gates" ist es nicht. Der neue Absatz in
`harness/README.md` führt die Gruppe bereits in genau dieser engeren Form („die in diesem Dokument
in Prosa beschrieben sind") — die zwei Fassungen derselben Aussage weichen voneinander ab, und die
weitere steht in der Config.

**Anzumerken ist der Umfang der Prüfung:** Ich habe **alle 36** Einträge gegen **beide**
Gruppen-Kriterien gehalten, nicht gestichprobt — Gruppe (b) (20 Einträge) hält in beiden
Konjunkten ohne Ausnahme (`## `-Hilfetext vorhanden: 20/20; keine Prosa-Erwähnung: 20/20).

---

### MEDIUM-2 — Die Modul-Aufzählung ist in zwei lebenden Artefakten falsch geworden, eines davon fasst dieser Commit an

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  [`AGENTS.md`](../../AGENTS.md) §3.7 · Roadmap-Arbeitspunkt *Doku- und Sensor-Wartung* (6)
- **pfad:** `harness/README.md:316` · `.github/workflows/ci.yml:21`
- **befund:** Beide Stellen zählen die für `docs-check` aktiven Module auf und enden bei
  `…, spans, planning`. Seit diesem Commit sind es acht; `targets` fehlt in beiden. Die daraus
  gezogene Folgerung (*„keines davon liest Historie"*) bleibt wahr — `targets` ist hermetisch —,
  die Aufzählung selbst ist es nicht mehr.
- **verifizierbar:** nein — kein Modul hält eine Prosa-Aufzählung gegen `modules:`; genau diese
  Lücke führt die Roadmap als offenen Arbeitspunkt.
- **klasse:** Prosa-Aufzählung gegen ihre Config gedriftet

**Gemessen:**

```sh
grep -m1 '^modules:' .d-check.yml
#   modules: [links, anchors, ids, matrix, codepaths, spans, planning, targets]
git grep -n 'links, anchors, ids, matrix, codepaths, spans, planning' \
  -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!.d-check.yml' ':!test/mutations'
#   .github/workflows/ci.yml:21
#   harness/README.md:316
#   docs/plan/planning/open/slice-121-…:69   (offener Plan, Zeitdokument-nah)
#   docs/plan/planning/open/slice-139-…:133  (dto.)
```

`harness/README.md` ist eine Datei, die dieser Commit ohnehin anfasst — nach
[`AGENTS.md`](../../AGENTS.md) §3.7 (*„Wer eine solche Zeile ohnehin anfasst, zieht sie nach"*)
liegt sie damit am nächsten. Die Zeile 316 selbst wurde nicht berührt, ein Hard-Rule-Verstoß liegt
darum **nicht** vor; gemeldet ist die eingeführte Unrichtigkeit, nicht ein Regelbruch.

**Nicht diesem Slice zuzurechnen:** `AGENTS.md:325` führt dieselbe Aufzählung und war **schon vor**
diesem Commit falsch (sie nennt sechs Module, `planning` fehlte bereits). Zudem ist `AGENTS.md` §3
Architect-Eigentum ([`AGENTS.md`](../../AGENTS.md) §3.8).

---

### MEDIUM-3 — Der neue Wächter behauptet „dieselbe Bijektion" wie `docs-check`, misst aber eine andere Menge

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7
- **pfad:** `test/targets-modul-wiring.bats:5-7` (Kopfkommentar)
- **befund:** Der Kopf sagt, `docs-check` halte *„dieselbe Bijektion"*, die der Wächter hermetisch
  prüfe. Gemessen liest das Modul **Makefile-Regeln** (die Meldung lautet wörtlich
  „Makefile-Regel `…` ohne Deklaration…"), der Wächter dagegen die Namen aus `^\.PHONY:`-Zeilen.
  Zwei verschiedene Mengen, die heute zufällig zusammenfallen (je 47).
- **verifizierbar:** ja — ein Regel-Target ohne `.PHONY`-Deklaration färbt `docs-check` rot, während
  `test/targets-modul-wiring.bats` grün bleibt.
- **klasse:** Wächter-Kommentar behauptet Deckungsgleichheit mit dem Gate, misst aber eine engere Menge

**Gemessen (Sonde 7, Kopie außerhalb des Repos, netzlos, `:ro`):** ein Regel-Target **ohne**
`.PHONY` an den `Makefile` angehängt —

```
Makefile:413   ohne-phony   gate-undocumented   Makefile-Regel `ohne-phony` ohne Deklaration
                                                in der Autoritäts-Doku AGENTS.md
d-check: 1098 Datei(en) geprüft, 1 Befund(e)      EXIT=1
```

Der Wächter sähe dieses Target nicht — seine `phony_targets()` liest ausschließlich
`^\.PHONY:`-Zeilen. **Heute folgenlos**, weil beide Mengen deckungsgleich sind:

```sh
grep -h '^\.PHONY:' Makefile d-check.mk | sed -E 's/^\.PHONY:[[:space:]]*//' | tr ' ' '\n' \
  | grep -v '^$' | sort -u > /tmp/phony     # 47
grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk | sed -E 's/:.*//' | sort -u > /tmp/rules  # 47
comm -3 /tmp/phony /tmp/rules   # leer
```

**Kein stilles Grün im Gate:** `docs-check` und `test-bats` laufen beide in `make gates`, der Fall
fiele also auf. Zu eng ist allein die Zusage des Kommentars — *„dieselbe Bijektion"* ist über die
`.PHONY`-Menge nicht haltbar. **Umformulieren**, nicht streichen.

---

### LOW-1 — Die Übergabe aus DoD (3) ruht auf einer Prämisse, die ich als nicht eingetreten messe

- **kategorie:** LOW
- **quelle:** [`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  Setzung 2 · Slice DoD (1)
- **pfad:** Slice-Plan §2 DoD (3) / Übergabe-Meldung des Implementers
- **befund:** DoD (3) setzt voraus, dass MR-010 Setzung 2 nach diesem Slice nicht mehr stimmt.
  Gemessen stimmt sie weiter: DoD (1) verbot ausdrücklich ein zweites Gate-Ziel, und `doc-targets`
  steht in keiner Prerequisite-Kette — aktiviert wurde das **Modul** innerhalb von `docs-check`,
  nicht das **Ziel**. Die Aufzählung „`docs-check` ist das einzige behauptete, die übrigen zwölf
  sind advisory" ist unverändert zutreffend.
- **verifizierbar:** nein — kein Modul liest den Wahrheitsgehalt einer MR-Aufzählung (DoD (3) sagt
  das selbst).
- **klasse:** Übergabe-Prämisse nicht gegen den Ist-Stand nachgemessen

**Gemessen:**

```sh
grep -n 'doc-targets' Makefile d-check.mk .github/workflows/*.yml
#   d-check.mk:106  .PHONY: doc-targets
#   d-check.mk:107  doc-targets: ## …          -> kein Aufrufer, keine Kette
grep -nE '^(gates|record-gates):' Makefile
#   408:record-gates: baseline-verify docs-check lint build test shell-lint ci-lint comment-claims host-bin span-check
#   411:gates: record-gates
grep -cE '^docs?-[a-z-]+:' d-check.mk    # 13 — die Zahl, die Setzung 2 nennt, steht unverändert
```

Die Übergabe selbst ist formal richtig platziert (§3.8: der Norm-Text entsteht im Architect-Lauf);
gemeldet ist, dass der Architect sonst eine zutreffende Setzung änderte. Der **zweite** Posten der
Übergabe (`MR-001` braucht einen Eintrag für die Aktivierung) ist davon unberührt und trägt.

---

### LOW-2 — Zwei Extraktionen im neuen Wächter sind nicht an das verankert, was sie benennen

- **kategorie:** LOW
- **quelle:** Maintainability
- **pfad:** `test/targets-modul-wiring.bats:45-48` (`exempt_targets`) · `:40-43`
  (`authority_table_targets`)
- **befund:** `exempt_targets()` sammelt **jede** `^    - `-Zeile des `targets:`-Blocks, nicht die
  unterhalb von `exempt-targets:`; eine zweite Listen-Eigenschaft in demselben Block vermischte sich
  still. `authority_table_targets()` verlangt `make X` in **Spalte 1** der Tabellenzeile; eine
  Nennung in einer späteren Spalte bliebe für den Wächter unsichtbar. Beide Fallen sind heute nicht
  eingetreten.
- **verifizierbar:** nein — beide Formen existieren im Bestand nicht.
- **klasse:** Extraktion weiter gefasst als der Schlüssel, den sie benennt

**Gemessen:** im `targets:`-Block trägt allein `exempt-targets` `    - `-Zeilen (36 Stück,
Schlüssel `makefiles`/`doc-tables`/`authority` sind inline); und alle 11 `make X`-Nennungen in
`AGENTS.md`-Tabellenzeilen stehen in Spalte 1 —

```sh
grep -cE '^\| `make [a-z][a-z0-9-]*` \|' AGENTS.md   # 11
grep -cE '^\|.*`make [a-z][a-z0-9-]*`'   AGENTS.md   # 11
```

---

### INFO-1 — Wem der Ruhe-Marker beim Übergang `next → in-progress` gehört, ist nirgends normiert

- **kategorie:** INFO
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.10 (deckt den *Abschluss*, nicht diesen Übergang) ·
  `BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext`
- **pfad:** `docs/plan/planning/in-progress/roadmap.md:23`
- **befund:** Der Implementer ersetzt den Ruhe-Marker durch die Zustandszeile
  ``​`slice-124` (welle-13) liegt in [`in-progress/`](../in-progress).`` Die Rolle ist durch den
  Bestand gedeckt — vier vorangehende Übergänge wurden ebenso vom Implementer gesetzt —, die
  **Form** weicht ab: dort jeweils ein eigener Commit, hier im Umsetzungs-Commit gebündelt. Eine
  Quelle, die das entscheidet, führt das Repo nicht.
- **verifizierbar:** nein — kein Modul des Doku-Gates liest Commits.
- **klasse:** Rollen-Eigentum eines Lifecycle-Nebenschritts nur durch Praxis belegt

**Gemessen:**

```sh
git log --format='%h %s' -12 -- docs/plan/planning/in-progress/roadmap.md
#   220930db Rolle Implementer: slice-194 -- Ruhe-Marker faellt, in-progress/ traegt Arbeit
#   9bced90f Rolle Implementer: slice-073 -- Ruhe-Marker … nach next->in-progress nachgezogen
#   1d7cd066 Rolle Implementer: slice-140 -- … nach next->in-progress
#   c4c20ed2 Rolle Implementer: slice-129 -- Ruhe-Marker faellt, in-progress/ traegt Arbeit
grep -rn "Ruhe-Marker\|Nichts in Arbeit" .claude/commands/ .harness/skills/   # kein Treffer
```

Die Zeile selbst ist in der richtigen Form — Zustand plus auflösbarer Anker, keine Chronik
([`AGENTS.md`](../../AGENTS.md) §3.7). Kein Befund gegen den Inhalt; benannt ist die fehlende
Quelle. **Praxis ist keine Norm** — deshalb INFO und nicht höher.

---

## Negativbefunde (geprüft, ohne Befund)

**Das stille Grün — die Zusage, an der der Slice hängt (Sonde 1).** Am Eltern-Stand, mit den
Flags des `doc-targets`-Rezepts, ohne `targets:`-Block:

```
d-check: 1098 Datei(en) geprüft, 0 Befund(e)        EXIT=0
```

Exakt die gemeldete Zahl. Das Modul war inert — `make doc-targets` meldete grün und prüfte nichts.
Bestätigt.

**Grüner Start nach der Aktivierung (Sonde 2 und 8).** Mit `targets:`-Block, dieselben Flags:
`1098 Datei(en), 0 Befund(e)`, EXIT 0. Und der **volle** `docs-check` (alle acht Module der
`.d-check.yml`) über demselben Baum: `1098 Datei(en) geprüft, 0 Befund(e)`, EXIT 0 — `planning` und
`targets` vertragen sich, die Roadmap-Änderung hält die Marker-Invariante.

**Die zwei Gegenbeispiele, je einzeln rot gesehen (Sonden 3 und 4).**

```
AGENTS.md:500   phantom-gate  gate-phantom       dokumentiertes Target `make phantom-gate` ohne Makefile-Regel
Makefile:414    neues-ziel    gate-undocumented  Makefile-Regel `neues-ziel` ohne Deklaration in der
                                                 Autoritäts-Doku AGENTS.md
```
Beide EXIT 1, je genau 1 Befund. Die Zusage aus DoD (1) trägt in beide Richtungen.

**Ist der Wächter durch die 36 Ausnahmen zahnlos? Nein — gemessen, nicht abgewogen.** Die Zusage
aus §1 des Plans lautet: ein dokumentiertes Gate ohne Rezept färbt rot, *und umgekehrt* fällt ein
undokumentiertes Target auf. Beide Hälften sind oben rot gesehen, und zwar an **neuen** Elementen —
genau der Fläche, die die Ausnahmeliste nicht deckt. Die 36 entscheiden den **Bestand**; jedes
künftige Target ist nicht exempt und fällt. Das ist die Zusage, nicht weniger als sie. Der Plan
verlangte dazu (Risiko 1 in §6), dass der Ausschnitt benannt wird — der neue Absatz in
`harness/README.md` nennt Ausnahme-Zahl, beide Gruppen, die Tabellenzeilen-Grenze und die
Autoritäts-Asymmetrie. Erfüllt.

**Die Zwei-Orte-Asymmetrie — Aussage stimmt *und* ist vollständig (Sonden 5 und 6).** Geprüft in
beide Richtungen, weil eine halb bewachte Dopplung, die sich für bewacht ausgibt, schlimmer wäre
als eine unbewachte:

```
# Phantom in der ZWEITEN doc-tables-Datei:
harness/README.md:460  phantom-readme  gate-phantom  …            EXIT=1   -> README ist phantom-bewacht
# Rezept existiert, dokumentiert NUR in einer harness/README.md-TABELLENZEILE:
Makefile:414  nur-im-readme  gate-undocumented  … ohne Deklaration in der Autoritäts-Doku AGENTS.md
                                                                  EXIT=1   -> README zaehlt NICHT als Autoritaet
```

Damit ist beides belegt: `harness/README.md` trägt Richtung 2, und eine dortige Tabellenzeile
erfüllt Richtung 1 **nicht**. Genau das sagen der Config-Kommentar und der README-Absatz. Heute
existiert kein Ziel, das die Asymmetrie auslöst (die 11 README-Tabellen-Targets sind identisch mit
den 11 `AGENTS.md`-Targets) — die Aussage ist also korrekt und die Lage latent.

**Die Bijektion — laufender Wächter, keine einmalige Messung.** Ich habe sie mit eigener Extraktion
nachgefahren (nicht mit den Funktionen des Tests):

```sh
comm -23 <(phony) <(authority_tabelle) | diff - <(exempt)   # identisch
comm -12 <(exempt) <(authority_tabelle)                     # leer
# 47 .PHONY = 11 Autoritäts-Zeilen + 36 Ausnahmen
```

Und sie ist **verdrahtet**: `test/targets-modul-wiring.bats` liegt in `test/`, `test-bats` fährt
`docker run … $(BATS_IMAGE) test/` über das ganze Verzeichnis, `test` hängt daran, `record-gates`
an `test`, `gates` an `record-gates`. Ein neuer Eintrag wird ohne Zutun mitgeprüft. Damit bekommt
die **dritte** kuratierte Liste dieses Repos als einzige einen Vollständigkeits-Wächter — der
Roadmap-Arbeitspunkt *„Beide kuratierten Listen prüfen ihre Einträge, nie ihre Vollständigkeit"*
bleibt über `upstream-drift` und `make mutate` unverändert offen und wird durch diesen Slice nicht
vergrößert. Das ist bemerkenswert und nicht selbstverständlich.

**Die zwei neuen Mutations-Fälle treffen die Stelle, die der Aufrufer benutzt.** `301` greift die
reale `modules:`-Zeile, `302` den realen Listeneintrag. Je genau eine Zeile getroffen
(`grep -c` → 1 und 1; `^    - help$` trifft `doc-help` nicht). Beide `# expect:`-Zeilen lösen auf
genau **einen** existierenden `@test`-Namen auf (`grep -rF "@test \"<expect>\"" test/ | wc -l` → je
1), und beide Wächter fallen unter ihrer Mutation. Der Beleg des Implementers gegen
Wegwerf-Kopien trägt.

**`AGENTS.md` und `harness/conventions*` sind unberührt** (`git show --stat 6f454e15`) —
[`AGENTS.md`](../../AGENTS.md) §3.8 eingehalten, die zwei Norm-Posten korrekt als Übergabe
ausgewiesen statt in Eigenmacht geschrieben. Der Slice-Plan ist ebenfalls unberührt, die
DoD-Häkchen stehen offen: richtig, das ist Closure-Arbeit des Planners
([`AGENTS.md`](../../AGENTS.md) §3.10).

**Die Auflage des Auftraggebers ist eingehalten.** Gemessen statt auf Sicht beurteilt:

```sh
git show 6f454e15 | grep -cE '^\+.*slice-[0-9]'                                   # 1
git show 6f454e15 | grep -nE '^\+.*(Review-Befund|frueher stand|bis slice|Runde [0-9])'  # kein Treffer
```

Die eine Fundstelle ist die Roadmap-Zustandszeile, die der `planning`-Wächter erzwingt — Zustand
mit Anker, keine Chronik. Keine Forensik, keine Befund-Kennungen, keine Runden-Verweise in den
neuen Kommentaren.

**[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
im neuen README-Absatz.** Die einzige Zahl (36) steht neben ihrem Kommando, und das Kommando liefert
sie wörtlich:

```sh
sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '   # 36
```

**DoD (2), die heikelste Hälfte.** Der Plan färbt den Punkt rot, wenn eines der sechs in Prosa
beschriebenen Ziele ausgenommen wird, *ohne dass daneben steht, dass sie dokumentiert sind und nur
außerhalb des Prüfbereichs liegen*. Der README-Absatz schließt mit genau diesem Satz („Beide
Gruppen sind dokumentiert — die `exempt-targets`-Zeile sagt nur, dass keine dieser Dokumentationen
eine `make X`-Tabellenzeile in der `authority`-Datei ist"), der Config-Kommentar mit der
entsprechenden Aussage zur zweiten `doc-tables`-Datei. Erfüllt — und sauber gelöst.

**`docs-check` ist per Config-Korrektur gehalten, nicht per Ausnahme** (DoD (2)):
`makefiles: [Makefile, d-check.mk]`, `docs-check` steht in der Autoritäts-Tabelle und **nicht** in
`exempt-targets` (`comm -12 <(exempt) <(auth)` leer). Der im Plan §1 benannte Warnschuss ist damit
richtig beantwortet.

**Kein Glob in der Ausnahmeliste** — 36 exakte Namen, kein `*`, `?` oder `[`
(`grep -cE '[*?[]'` über die Einträge → 0), wie §1 des Plans es als Modul-Eigenschaft misst.

**Nicht geprüft (außerhalb meiner Rolle oder untersagt):** die DoD-Abhakung selbst (Verifier);
`make gates`, `make mutate`, `make test`, `make smoke`, `make full-smoke`, `make docs-check` und
`docker build` wurden auftragsgemäß **nicht** gefahren — die Sensor-Lage des Implementers ist
insoweit unbestätigt geblieben, mit Ausnahme der acht oben belegten d-check-Läufe.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 1 | HIGH-1 |
| MEDIUM | 3 | MEDIUM-1, MEDIUM-2, MEDIUM-3 |
| LOW | 2 | LOW-1, LOW-2 |
| INFO | 1 | INFO-1 |

**Wiederkehrende Klassen für den Steering-Loop (§7 der Closure):**
*Mutations-Adresse veraltet nach Config-Zeilen-Änderung* (HIGH-1) und
*Prosa-Aufzählung gegen ihre Config gedriftet* (MEDIUM-2) — beide sind dieselbe Ursache aus zwei
Richtungen: eine Änderung an **einer** Zeile von `.d-check.yml` entwertet Kopien dieser Zeile, die
an vier Orten liegen (Mutations-Fälle, Prosa, CI-Kommentar, MR-Einträge). Die Roadmap führt die
zweite Hälfte bereits als Arbeitspunkt; die erste — Mutations-`sed`-Adressen als Kopien einer
Config-Zeile — ist dort **nicht** erfasst.

---

## Verdikt

**Blockierender Befund: ja.** HIGH-1 blockiert. Er ist kein Meinungsunterschied, sondern eine
Messung: zwei Mutations-Fälle, die am Eltern-Stand griffen, sind durch diesen Commit wirkungslos,
und der `mutate`-Treiber wird sie fail-closed als Befund melden. Damit ist der Closure-Trigger §5
des Plans (*„`make mutate` ohne Befund"*) nicht erfüllt — unabhängig davon, was der laufende
Vollauf sonst zurückbringt.

**Übergabe an den Verifier: noch nicht.** Der Slice geht mit den Findings zurück an die
Implementation. HIGH-1 ist zu beheben; MEDIUM-1 und MEDIUM-3 sind Umformulierungen zu eng bzw. zu
weit gefasster Zusagen und gehören in denselben Durchgang, weil sie beide in Artefakten stehen, die
dieser Commit angelegt hat. MEDIUM-2 berührt mit `.github/workflows/ci.yml` eine Datei außerhalb
des Slice-Zuschnitts — ob sie hier nachgezogen oder als eigener Vorgang geführt wird, ist eine
Planungs-Entscheidung, keine Review-Auflage.

**Was ausdrücklich trägt:** Der Kern des Slice ist solide. Das stille Grün ist real und exakt wie
gemeldet, die Aktivierung startet grün, beide Grund-Codes sind einzeln rot gesehen, die
Autoritäts-Asymmetrie ist in beide Richtungen gemessen und korrekt beschrieben, die Kuratierung ist
sachlich gedeckt, und die neue Liste bekommt als einzige der drei kuratierten Listen dieses Repos
einen laufenden Vollständigkeits-Wächter. Die Findings betreffen die Ränder, nicht die Mitte —
mit der einen Ausnahme, dass ein Rand hier ein anderer Sensor ist.
