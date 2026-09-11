# Review — slice-124, Runde 3: Mutations-Anker und die nachgezogenen Formulierungen

**Rolle:** Reviewer · **Datum:** 2026-09-11 · **Runde:** 3

**Prüfgegenstand:** `git diff 895d07ba..5d3f13b3` — zwei Commits: `adce3be1` (*Runde 2: mutate-Fund
behoben, Anker robuster*) und `5d3f13b3` (*Runde 3: Review-Findings MEDIUM-2/LOW-2 behoben*). **Nicht**
der ganze Slice; die Mitte des Slice hat
[Runde 1](2026-09-11-slice-124-gate-tabelle-hat-einen-waechter.md) bestätigt und ist hier nicht
erneut Gegenstand.

**Baum beim Eintritt:** `git status --porcelain` leer, `HEAD` = `5d3f13b3`.

**Plan:** [`slice-124`](../plan/planning/done/slice-124-gate-tabelle-hat-einen-waechter.md)
· **Quellen:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7 · §3.8 · §3.10,
[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
[`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile),
[`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert),
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).

**Berührt (7 Dateien):** `.d-check.yml` (nur Kommentar), `.github/workflows/ci.yml` (nur Kommentar),
[`harness/README.md`](../../harness/README.md) (eine Zeile), `test/mutations/269`, `279`, `301`,
`test/targets-modul-wiring.bats`.

**Eigene Messung:** 2 `docker run`-Läufe gegen den in [`d-check.mk`](../../d-check.mk) gepinnten
Digest (`sha256:e31a372b…`), je `--network none`, Mount `:ro`, über Kopien außerhalb des Repos
(`git archive 5d3f13b3 | tar -x -C <kopie>`). Alles Übrige hermetisch mit `sed`/`awk`/`grep`/
`sha256sum`. Kein `make`-Ziel und kein `docker build` gefahren (laufender Mutations-Lauf).

---

## Findings

### MEDIUM-1 — Die ersetzte Begründung der Ausnahme-Gruppe (a) ist erneut weiter als der Bestand

- **kategorie:** MEDIUM
- **quelle:** [`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
  (*„jede Ventil-Zeile nennt, was sie ausnimmt und warum"*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.7 · Slice DoD (2)
- **pfad:** `.d-check.yml:70-71`
- **befund:** Das falsche Konjunkt aus Runde 1 (`## `-Marke) ist korrekt auf *12 von 16* verengt —
  das **ersetzende Hauptkonjunkt** behauptet dafür mehr als vorher: *„jedes Rezept ist in
  harness/README.md in Prosa erklaert, was es prueft und was nicht"*. Für `record-gates` und
  `span-clean` trägt die Datei das nicht: außerhalb des Ausnahme-Absatzes selbst steht je **eine**
  Nennung, beide als Nebensatz in einem Absatz über ein *anderes* Ziel. Zugleich sagt die zweite
  Fassung derselben Aussage in `harness/README.md:184` weiterhin das Schwächere
  (*„die in diesem Dokument in Prosa beschrieben sind"*) — die in Runde 1 benannte Divergenz
  zwischen Config und Prosa besteht fort, nur ihre Richtung ist enger geworden.
- **verifizierbar:** nein — kein Gate liest den Wahrheitsgehalt eines Config-Kommentars
  (`make comment-claims` führt `.d-check.yml` nicht im Prüfbereich:
  `grep -n -A1 '^comment-claims:' Makefile`).
- **klasse:** Sammel-Begründung behauptet eine Eigenschaft, die nicht jedes Mitglied trägt

**Gemessen — Nennungen je Ziel in `harness/README.md` ohne den Ausnahme-Absatz (Zeilen 181–192):**

```sh
for t in smoke full-smoke mutate span-clean span-report hook-overhead slice-mv archive-welle \
         vendor-baseline regelwerk-check baseline-freshness history-range-guard adr-immutable \
         doc-immutable doc-commits record-gates; do
  printf '%-20s %s\n' "$t" "$(grep -n -F "$t" harness/README.md | awk -F: '$1<181 || $1>192' | wc -l)"
done
# span-clean 1 · span-report 1 · doc-commits 1 · record-gates 1 · alle uebrigen >= 2
```

**Die beiden tragenden Fundstellen im Wortlaut** (`grep -n -F '<ziel>' harness/README.md`):

```
harness/README.md:302  … enger als der Gate-Stempel, den `record-gates` ueber den Arbeitsbaum legt …
harness/README.md:407  … `make span-clean` (sein Rezept im Ziel ist `rm -rf` plus `echo`) …
```

Beide sagen, was das Ziel *tut*, keines, was es prüft und was nicht. **Gegenprobe, dass die
Messung trennscharf ist:** `span-report` hat ebenfalls nur eine Nennung, und die trägt
(`harness/README.md:407`: *„ein Bericht prüft nichts und färbt nichts rot"*) — die Zahl allein
entscheidet also nicht, der Wortlaut tut es. `doc-commits` ist der Grenzfall (Zeile 316 nennt es als
Target des Moduls `commits`, ohne seinen Prüfgegenstand); `doc-immutable` trägt über den
`adr-immutable`-Absatz vollständig.

**Fundmenge: mindestens 2 von 16.** Umformulieren, nicht streichen — die Ausnahmen selbst sind
sachlich gedeckt, Runde 1 hat das für alle 16 gemessen.

---

### LOW-1 — Die zwei gehärteten Extraktionen treffen ihren Fall, stehen aber ohne Wächter

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 · Maintainability
- **pfad:** `test/targets-modul-wiring.bats:43-45` (`authority_table_targets`) · `:48-56`
  (`exempt_targets`)
- **befund:** Beide Härtungen sind korrekt (unten gemessen), aber ein Rückbau auf die Vorform
  bleibt heute unsichtbar: beide Fassungen liefern über dem heutigen Baum identische Mengen, kein
  `@test` fällt, und kein `test/mutations/`-Fall zielt auf eine der beiden Funktionen. Die
  Verbesserung ist damit gegen ihre eigene Rücknahme ungeschützt.
- **verifizierbar:** nein — die Gegenbeispiele existieren im Bestand nicht; mit einer synthetischen
  Sonde jederzeit reproduzierbar (unten).
- **klasse:** Härtung ohne Gegenbeispiel im Bestand

**Gemessen — alt und neu liefern heute dasselbe:**

```sh
auth_alt() { grep -E '^\| `make [a-z][a-z0-9-]*` \|' AGENTS.md | grep -oE 'make [a-z][a-z0-9-]*' | sed 's/^make //' | sort -u; }
auth_neu() { grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' AGENTS.md | grep -oE '`make [a-z][a-z0-9-]*`' | tr -d '`' | sed 's/^make //' | sort -u; }
diff <(auth_alt) <(auth_neu)   # leer, je 11
# exempt_targets: alt 36, neu 36 (dieselbe Menge)
```

**Gemessen — welcher `@test` einen Mutations-Fall hat:**

```sh
grep -oE '^@test "[^"]+"' test/targets-modul-wiring.bats | sed 's/@test "//;s/"$//' \
  | while IFS= read -r t; do printf '%s -> %s\n' "$t" "$(grep -rlF "# expect: $t" test/mutations/ | wc -l)"; done
# "targets ist in modules: aktiviert" -> 1 (301)
# "jedes .PHONY-Target ohne Tabellenzeile …" -> 1 (302)
# die uebrigen fuenf -> 0
```

Beide Fälle decken den **Bestand** der Liste, keiner die **Form der Extraktion**.

---

### LOW-2 — Der neue Kopfkommentar trägt einen hart verdrahteten Messwert und eine Obermengen-Aussage, die nicht strukturell ist

- **kategorie:** LOW
- **quelle:** Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `test/targets-modul-wiring.bats:6-8`
- **befund:** Der Kopf sagt, `docs-check` halte eine *„ANDERE, weitere Menge"* und *„heute fallen
  beide Mengen zusammen (47 von 47)"*. Die Zahl steht ohne das Kommando, das sie liefert, und
  wandert mit jedem neuen Target. Das Wort *weitere* behauptet zudem eine Obermengen-Relation: sie
  gilt heute, ist aber nicht strukturell — ein `.PHONY`-Name **ohne** Regel (etwa nach dem Löschen
  eines Rezepts) fällt in die Gegenrichtung, und der Kopf nennt nur die eine.
- **verifizierbar:** nein — `make comment-claims` führt `test/` nicht im Prüfbereich, und
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  bindet die lebenden Markdown-Artefakte, nicht ein bats-Skript.
- **klasse:** Hart verdrahteter Messwert in einem Kommentar ohne sein Kommando

**Gemessen — die Zahl stimmt heute, und die Gleichheit ist beidseitig:**

```sh
grep -h '^\.PHONY:' Makefile d-check.mk | sed -E 's/^\.PHONY:[[:space:]]*//' | tr ' ' '\n' \
  | grep -v '^$' | sort -u > /tmp/phony     # 47
grep -hE '^[a-zA-Z][a-zA-Z0-9._-]*:' Makefile d-check.mk | sed -E 's/:.*//' | sort -u > /tmp/rules  # 47
comm -3 /tmp/phony /tmp/rules   # leer
```

Die **inhaltliche** Aussage des Kopfes — dass eine Regel ohne `.PHONY`-Eintrag von diesem Wächter
nicht gesehen wird und `docs-check` trotzdem rot färbt — trägt unverändert; gemeldet ist die
Zahl und das Wort, nicht der Satz.

---

### LOW-3 — Dieselbe Anker-Klasse steht noch in einem vierten Mutations-Fall, dessen Auslöser dieses Repo bereits benennt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `test/mutations/278-vcs-exclude-sections-ohne-geschichte.sh:9`
- **befund:** Der Fall ankert auf dem **vollständigen Listen-Literal**
  `exclude-sections: [Geschichte]` — dieselbe Form, die HIGH-1 aus Runde 1 für die `modules:`-Zeile
  stumpf gemacht hat. Wächst diese Liste um einen zweiten Abschnitt, greift das `sed` nicht mehr.
  Der Auslöser ist nicht hypothetisch: [`harness/README.md`](../../harness/README.md) führt genau
  diese Erweiterung als benannte, offene Grenze (*„ob `vcs` dieselbe `exclude-sections`-Liste wie
  `matrix` braucht … ist geprüft, aber nicht übernommen"*). **Nicht von diesem Diff eingeführt** —
  gemeldet, weil es beim Nachmessen der Fundmenge anfiel.
- **verifizierbar:** ja — `make mutate` würde den Fall nach einer solchen Listen-Erweiterung
  fail-closed als *„Mutation hat nicht gegriffen"* melden (`harness/tools/mutate.sh`, Bedingung 2);
  heute greift er.
- **klasse:** Mutations-Adresse als Kopie eines Listen-Literals

**Gemessen — die Anker-Form aller 20 `.d-check.yml`-schreibenden Fälle:**

```sh
for f in $(grep -lE '^(sed|awk|perl).*\.d-check\.yml' test/mutations/*.sh | sort); do
  printf '%-52s ' "$(basename "$f")"; grep -hE '^(sed|awk|perl)' "$f" | head -1
done
# 278 ist der einzige verbleibende Fall mit einem vollstaendigen Listen-Literal als Adresse;
# die uebrigen 16 ankern auf einer Einwert-Zeile (heading/marker/dir/paths/head-allow/status-line).
```

---

## Negativbefunde (geprüft, ohne Befund)

**HIGH-1 aus Runde 1 ist behoben, und der Anker ist gegen die nächste Modul-Änderung robust —
nicht nur gegen die heutige.** Vier Prüfungen, alle hermetisch:

1. *Genau eine Zeile getroffen.* Die Adresse `/^modules: \[/` trifft in `.d-check.yml` Zeile **29**
   und nur sie (`grep -c '^modules: \[' .d-check.yml` → 1).
2. *Die richtige Zeile, und der erwartete Sensor fällt.* Mutation auf eine Kopie angewandt, danach
   die Assertion des in `# expect:` genannten `@test` nachgefahren:

   ```
   269  greift  -> "planning ist in modules: aktiviert"  ROT   (vcs, targets bleiben gruen)
   279  greift  -> "vcs ist NICHT in modules: aktiviert" ROT   (planning, targets bleiben gruen)
   301  greift  -> "targets ist in modules: aktiviert"   ROT   (planning, vcs bleiben gruen)
   ```

   Jede `# expect:`-Zeile löst auf **genau einen** existierenden `@test` auf
   (`grep -rF "@test \"<expect>\"" test/ | wc -l` → je 1).
3. *Der mutierte Baum bleibt lauffähig.* Jede der drei Mutationen hinterlässt eine wohlgeformte
   Flow-Sequenz; die geprüfte Assertion ist reines `grep`, kein YAML-Parser steht dazwischen.
4. **Die Zukunfts-Probe, selbst gefahren.** Drei synthetische Modul-Listen, je alle drei Fälle:

   ```sh
   mk() { sed "29s|.*|$1|" .d-check.yml; }     # Variante in eine Kopie ausserhalb des Repos
   # V1: [links, anchors, ids, matrix, codepaths, spans, planning, targets, foo]
   # V2: [links, anchors, foo, ids, matrix, codepaths, spans, planning, bar, targets, baz]
   # V3: [links, anchors, ids, matrix, codepaths, spans, targets, planning]   (Reihenfolge getauscht)
   # -> 9 von 9 Laeufen "greift"; jeder Fall entfernt bzw. haengt AUSSCHLIESSLICH sein eigenes
   #    Element an, alle Nachbarn bleiben Byte fuer Byte stehen (sha256-Vergleich je Lauf).
   ```

   Damit ist die Zusage der drei neuen Kommentare (*„ein weiteres, vor oder nach `planning`
   aktiviertes Modul zieht dem Zahn nicht die Zaehne"*) nicht nur plausibel, sondern gemessen.

**Die Restgrenze der Anker — benannt, kein Befund.** Steht `planning` bzw. `targets` einmal an
**erster** Listenposition, fehlt das `, `-Präfix und der jeweilige Fall wird NO-OP (gemessen mit
`modules: [planning, links, …]` → 269 NO-OP, 301 greift; und umgekehrt). Dasselbe gilt für 279 bei
einem Kommentar hinter der schließenden Klammer. Kein Anhängen eines Moduls erzeugt diese Lage — sie
bräuchte eine Umsortierung —, und sie fällt fail-closed laut auf, nicht still grün. Die
Kommentar-Zusagen sprechen ausdrücklich von *einem weiteren aktivierten Modul* und bleiben davon
unberührt.

**Die Fundmenge „drei" bestätige ich, die Bezugsmenge „27 übrige" nicht.** Genau drei Fälle fassen
die `modules:`-Zeile der repo-eigenen `.d-check.yml` an, und `295` zielt auf
`internal/emit/templates/d-check.yml` — eine andere Datei:

```sh
grep -nE '^(sed|awk|perl)' test/mutations/*.sh | grep 'modules'
#   279 · 269 · 301   -> .d-check.yml
#   295               -> internal/emit/templates/d-check.yml
grep -lE '^(sed|awk|perl).*\.d-check\.yml' test/mutations/*.sh | wc -l    # 20, nicht 30
```

Die Zahl der übrigen `.d-check.yml`-schreibenden Fälle ist **17**, nicht 27. Am Schluss ändert das
nichts — die Fundmenge der `modules:`-Anker ist drei —, aber der Nenner der Übergabe stimmt nicht.

**MEDIUM-2 aus Runde 1 ist an beiden gemeldeten Stellen nachgezogen**, und keine dritte lebende
Stelle ist offen geblieben:

```sh
git grep -n 'codepaths, spans, planning' -- ':!.harness/baseline' ':!test/mutations'
# harness/README.md:316 und .github/workflows/ci.yml:21 tragen jetzt "…, planning, targets"
# der Rest liegt in docs/reviews/**, docs/plan/planning/done/**, eingefrorenen ADRs und
# harness/conventions/** (append-only) — plus zwei offene Slice-Plaene und AGENTS.md:325,
# das schon vor diesem Slice sechs statt sieben Module nannte (Architect-Eigentum, §3.8).
```

Die Folgerung beider Stellen (*„keines davon liest Historie"*) bleibt wahr und ist hier **direkt
belegt**: meine zwei d-check-Läufe liefen über einem `git archive`-Auszug — also über einem Baum
**ohne** `.git` — und das Modul `targets` lieferte dort korrekte Befunde.

**MEDIUM-3 aus Runde 1: die Umformulierung hält.** Der Kopf behauptet keine Deckungsgleichheit mehr,
sondern nennt die zwei Mengen getrennt und die Richtung, in der sie auseinanderlaufen können. Die
Sachaussage ist gegen den Bestand gemessen (47/47, `comm -3` leer). Was daran offen bleibt, steht
oben als LOW-2.

**LOW-1 aus Runde 1 ist zu Recht zurückgezogen.**
[`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 2
spricht über **Targets**, nicht über Module — und ihre drei Aussagen halten unverändert:

```sh
grep -cE '^docs?-[a-z-]+:' d-check.mk                 # 13, wie die Setzung sagt
grep -nE '^(gates|record-gates):' Makefile            # docs-check ist das einzige darin
grep -c 'make doc-targets' AGENTS.md harness/README.md # 0 / 0 -> doc-targets bleibt advisory
```

Aktiviert wurde ein **Modul innerhalb** von `docs-check`, kein zweites Gate-Ziel — DoD (1) verbot
genau das. Als Architect-Übergabe bleibt damit
[`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids),
und das trägt: dessen Adaptions-Feld führt die über die Baseline hinaus aktivierten Module
namentlich (`matrix`, `spans`, `ids`-Politik) und nennt `targets` nicht. **Anzumerken für die
Verifikation:** DoD (3) spricht im Plan von *„die übrigen elf"*, Setzung 2 von zwölf — eine
Abweichung im Plan-Text, nicht im Diff und nicht meine Rolle.

**LOW-2 aus Runde 1: beide Härtungen treffen exakt den gemeldeten Fall.** Je eine synthetische
Sonde, alt gegen neu:

```sh
# (1) `make X` in einer SPAETEREN Spalte, Spalte 1 ist kein make-X-Feld:
printf '| Sensor-Beschreibung | `make nur-spalte-zwei` prueft etwas |\n' >> <kopie>/AGENTS.md
#   alt sieht es: 0     neu sieht es: 1
# (2) zweite Listen-Eigenschaft im targets:-Block:
#   alt: 37 Eintraege (fremder-eintrag drin)   neu: 36 (draussen)
```

**Und die Autoritäts-Härtung entfernt eine Divergenz, statt eine zu schaffen** — gemessen am Modul
selbst, zwei `docker run`-Läufe über Kopien außerhalb des Repos, netzlos, `:ro`:

```
# Sonde A: `help` aus exempt-targets entfernt UND als `make help` in SPALTE 2 einer
#          AGENTS.md-Tabellenzeile dokumentiert
d-check: 1099 Datei(en) geprüft, 0 Befund(e)                                      EXIT=0
# Sonde B (Kontrolle): dasselbe ohne die Tabellenzeile
Makefile:44  help  gate-undocumented  Makefile-Regel `help` ohne Deklaration in der
                                      Autoritäts-Doku AGENTS.md                   EXIT=1
```

Das Modul liest `make X` also aus **jeder** Spalte einer Tabellenzeile — die alte Extraktion war
enger als das Gate, die neue deckt sich mit ihm.

**Die `exempt_targets`-awk-Form ist fail-closed.** Eine Leer- oder Kommentarzeile mitten in der
Liste beendet `inlist` und kürzt die Menge — der Bijektions-`diff` fällt dann rot, nicht still
grün. Heute tritt das nicht ein: die Extraktion liefert 36, gleich der im README genannten Zahl
(`sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '` → 36).

**Der funktionale Inhalt von `.d-check.yml` ist über diesen Diff unverändert** — damit tragen die
d-check-Messungen aus Runde 1 (stilles Grün, grüner Start, beide Grund-Codes rot gesehen) ohne
Wiederholung:

```sh
strip() { git show "$1:.d-check.yml" | grep -vE '^[[:space:]]*#' | grep -vE '^[[:space:]]*$'; }
diff <(strip 6f454e15) <(strip 5d3f13b3)   # leer
```

**Die Auflage des Auftraggebers ist eingehalten.** Keine der hinzugefügten Zeilen trägt Forensik:

```sh
git diff 895d07ba..5d3f13b3 | grep -E '^\+' \
  | grep -E 'Review-Befund|früher|bis slice-|Runde [0-9]|slice-[0-9]|HIGH-|MEDIUM-|LOW-'   # kein Treffer
```

Die drei neuen Kommentarblöcke stehen im Indikativ und beschreiben die Stelle, nicht den Vorgang,
der sie erzeugt hat ([`AGENTS.md`](../../AGENTS.md) §3.7) — die Querverweise in `301`
(*„dieselbe Anker-Form wie 269/279"*) sind eine Kopplung auf Geschwister-Fälle, keine Chronik.

**[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
ist nicht berührt.** Die zwei neuen Zahlen (*12 von 16*, *47 von 47*) stehen in einer YAML-Config und
in einem bats-Skript, nicht in einem lebenden Markdown-Artefakt; die einzige geänderte
Markdown-Zeile (`harness/README.md:316`) trägt keine Zahl.

**Rollen-Grenzen gehalten.** `AGENTS.md`, `harness/conventions*` und der Slice-Plan sind über beide
Commits unberührt (`git show --stat adce3be1 5d3f13b3`) —
[`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10 eingehalten, die DoD-Häkchen stehen offen.

**Nicht geprüft (untersagt oder außerhalb meiner Rolle):** `make gates`, `make mutate`, `make test`,
`make smoke`, `make full-smoke`, `make docs-check` und `docker build` — die vom Implementer
gemeldete Sensor-Lage (`gates` Exit 0, bats 251/251, `docs-check` 0 Befunde) bleibt insoweit
unbestätigt; ich habe allein die Fallzahl nachgezählt
(`grep -rhc '^@test ' test/*.bats | awk '{s+=$1} END{print s}'` → **251**). Die DoD-Abhakung ist
Sache der Verifikation. Der abgebrochene Mutations-Lauf mit den zwei Umgebungs-Befunden (`100`,
`101`) ist auftragsgemäß nicht als Befund gewertet.

---

## Kategorie-Summary

| Kategorie | Anzahl | Kennungen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 1 | MEDIUM-1 |
| LOW | 3 | LOW-1, LOW-2, LOW-3 |
| INFO | 0 | — |

**Wiederkehrende Klasse für den Steering-Loop (§7 der Closure):** *Sammel-Begründung behauptet eine
Eigenschaft, die nicht jedes Mitglied trägt* — zum **zweiten Mal an derselben Zeile**
(`.d-check.yml:70`). Die Korrektur aus Runde 1 hat das eine Konjunkt verengt und das andere
geweitet; das Muster ist nicht die einzelne Formulierung, sondern eine Begründung, die über eine
kuratierte Menge quantifiziert, ohne dass jemand die Menge durchgezählt hat. Die in Runde 1
genannte Klasse *Mutations-Adresse veraltet nach Config-Zeilen-Änderung* ist mit LOW-3 ein zweites
Mal belegt — dort im Bestand, nicht neu eingeführt.

---

## Verdikt

**Blockierender Befund: ja** — MEDIUM-1, und nur dieser.

**HIGH-1 ist erledigt**, und zwar über die gemeldete Reparatur hinaus: die drei Anker sind gegen
drei synthetische Zukunfts-Zustände gemessen und treffen in jedem ausschließlich ihr eigenes
Element. Das ist der Unterschied zwischen *heute repariert* und *gegen die nächste Änderung robust*,
und er ist hier belegt. MEDIUM-2 und MEDIUM-3 sind sauber erledigt, LOW-1 aus Runde 1 ist zu Recht
zurückgezogen, LOW-2 trifft seinen Fall und deckt sich zusätzlich besser mit dem Modul als vorher.

**Was blockiert, ist eine Zeile.** MEDIUM-1 blindet kein Gate und macht keine Ausnahme unbegründet —
die 36 Ausnahmen sind sachlich gedeckt, das hat Runde 1 für alle gemessen. Blockierend ist er, weil
er **dieselbe Zeile zum zweiten Mal** betrifft und weil diese Zeile die einzige schriftliche
Begründung für eine Gate-Suppression ist: eine zu weite Begründung, die mit dem Merge in die
Gate-Config einfriert, ist genau die Klasse, gegen die
[`MR-009`](../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) §Kein
Rückfall auf stilles Grün steht. Der Aufwand ist ein Verb.

**Übergabe an den Verifier: nach dieser einen Umformulierung.** Die drei LOW sind keine Auflage —
LOW-3 liegt ohnehin außerhalb des Slice-Zuschnitts und gehört in einen eigenen Vorgang oder ins
Beobachtungs-Register. Der Slice ist inhaltlich fertig.
