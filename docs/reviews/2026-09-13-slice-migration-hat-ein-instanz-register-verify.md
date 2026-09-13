# Verifikation slice-migration-hat-ein-instanz-register — Instanz-Register und Report-Form

**Rolle:** Verifier · **Datum:** 2026-09-13 · **Geprüfte Commits:** `f0d58786` (Lieferung),
`93c54d1b` (Reviewer, blockierend, 1 HIGH / 6 MEDIUM), `6fedb06b` (Nacharbeit) · **Plan:**
[`slice-migration-hat-ein-instanz-register`](../plan/planning/done/slice-migration-hat-ein-instanz-register.md)
· **Review:**
[`2026-09-13-slice-migration-hat-ein-instanz-register`](2026-09-13-slice-migration-hat-ein-instanz-register.md)
(1 HIGH · 6 MEDIUM · 4 LOW · 2 INFO, Verdikt **Blockierend**) · **Prüfgegenstand:** DoD und Spec
(`LH-QA-01`, `LH-QA-02`, `ADR-0018` §Entscheidung Festlegung 4) — **nicht** Plan/Hard Rules, das ist
Reviewer-Sache.

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein Ausfüll-Hinweis)*. Dieser Report
> friert ein; was er zitiert, bewegt sich weiter. Deshalb: **Kennung, nicht Adresse** —
> `slice-<Kennung>` statt seines Lifecycle-Pfads, `make <target>` statt eines Links auf die
> Sensor-Datei, eine Baseline-Stelle als **Tag + Pfad in Inline-Code** (`v<X.Y.Z>` ·
> `regelwerk/<datei>.md` §<Abschnitt>) statt als Link.

---

## 0. Vorfrage: ist `make gates` EXIT 0 tatsächlich für `6fedb06b` belegt, und lief `docs-check` real?

```sh
cat .harness/state/gates-passed.diffsha
# -> 468f3a4ef2e7089e4c96117539561ac8f1387ca94795f88ffb709a3ee3b5d79c
bash harness/tools/working-tree-hash.sh
# -> 468f3a4ef2e7089e4c96117539561ac8f1387ca94795f88ffb709a3ee3b5d79c
git status --porcelain   # leer
git rev-parse HEAD       # 6fedb06b47527c7fc393d6dfde5677ed6ace29ec
```

Deckungsgleich, Baum sauber, `HEAD` == `origin/main` == der geprüfte Stand. Nicht selbst neu
gefahren (Docker-Verbot dieser Rolle). Stattdessen die Rezept-Kette gelesen:

```sh
grep -n '^gates:\|^record-gates:' Makefile
# gates: record-gates
# record-gates: baseline-verify docs-check lint build test shell-lint ci-lint comment-claims host-bin span-check
```

`record-gates` trägt `docs-check` als **eigenes Prerequisite-Target** der Make-Kette — nicht als
Teilschritt eines anderen Ziels. `make` baut `record-gates` nur, wenn jedes Prerequisite exitet 0;
ein rotes `docs-check` hätte den `.harness/state/gates-passed.diffsha`-Schreibvorgang nie erreicht.
Die Implementer-Behauptung „Pfad-Existenz per `[ -f ... ]`" deckt seinen eigenen Lauf, ersetzt aber
nicht den Nachweis — den liefert dieser Hash-Abgleich: **`docs-check` ist real und separat
gelaufen, Punkt 1 der Prüfreihenfolge ist erfüllt.**

---

## 1. DoD Punkt für Punkt

### DoD-1 — Instanz-Register existiert, Zeilenzahl == `find`-Ausgabe

**Erfüllt.**

```sh
find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l    # 25
grep -c '^| `.harness/baseline/v6.7.2/templates' harness/migration.md    # 25
grep -m1 '^BASELINE_TAG' Makefile                                        # BASELINE_TAG ?= v6.7.2
```

25/25, `<tag>` aus `BASELINE_TAG` gelesen, nicht als Literal. Der Reviewer hat zusätzlich die
Bijektion beider Mengen sortiert-`diff`-geprüft (25/25 identisch) und jede der 9 Mengen-Zeilen
sowie alle 4 `keine Instanz`-Begründungen einzeln nachgefahren — ich habe die Vollständigkeits-Zahl
und drei der Mengen (ADR: 46, Slice: 229, Review-Report: 378, s. u.) unabhängig nachgemessen, alle
stimmen.

### DoD-2 — Report-Form mit vier Ausgängen, geschlossene Menge, kein Freitext

**Nicht wörtlich erfüllt — DoD-Verletzung, keine Formalie.**

Der DoD-Text sagt: *„je Vorlage genau einer von **vier** Ausgängen … Die vier sind eine
**geschlossene Menge**, kein Freitext."* Das ist eine Aussage über **alle** Zeilen des Registers.
Nach der Nacharbeit trägt `harness/migration.md` §5 **zwei** Fälle:

- Buchstabe a — vier Ausgänge, für 19 der 25 Zeilen (die „einmaligen" Vorlagen).
- Buchstabe b — **ein fünfter, disjunkter Ausgang** (`append-only`), für die 6 „wiederkehrenden"
  Zeilen (ADR, Slice, Welle, Welle-Results, Carveout, Review-Report).

```sh
grep -c '| \*\*.*\*\* |.*|.*|' harness/migration.md   # grobe Sondierung, s. u. für den Beleg-Satz
sed -n '188,200p' harness/migration.md
```

Für diese 6 Zeilen gilt **nicht** „einer von vier" — es gilt „genau der eine fünfte, den es in
Buchstabe a nicht gibt". Das ist in der Sache **richtig und gut belegt**: Es ist exakt die
Korrektur, die F-1 (blockierendes HIGH) erzwungen hat — die vier Ausgänge waren nachweislich keine
geschlossene Menge für wiederkehrende Vorlagen, weil *übernommen* das rückwirkende Umschreiben
verlangt, das die Baseline für sie ausdrücklich untersagt
(`v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
(Schritt 2); wörtlich identisch in
[ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Entscheidung Festlegung 4 —
selbst geprüft, `grep -c 'gilt die Append-only-Logik' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md`
→ 1, Wortlaut deckungsgleich).

**Der Punkt ist:** Die Reparatur von F-1 hat DoD-2 in seiner **wörtlichen** Form notwendig
verlassen — DoD-2 kodiert exakt dieselbe Universal-Vier-Annahme, die F-1 widerlegt. Das ist dieselbe
Klasse, vor der der Verifikationsauftrag warnt (*„ein Abnahmekriterium, das die gemessene Kante
nicht mehr trägt"*, Analogie zum `waves`-Slice): Der Code ist besser als der Plan, aber der
DoD-Text sagt es nicht. Ohne Planner-Entscheidung ist DoD-2 **nicht** abhakbar — weder als „passt
schon" noch stillschweigend im Sinne des ursprünglichen Wortlauts.

**Zusätzlicher, eigenständiger Befund innerhalb von DoD-2:** Drei mehrinstanzige Zeilen des
Registers — Observation-Vorlage (**104** Instanzen), `MR-NNN-titel.template.md` (**59**),
`harness/sensors/gate.template.md` (**15**), zusammen **178** Instanzen, mehr als alle sechs
„wiederkehrenden" Zeilen aus Buchstabe b zusammen — werden in §4 explizit **nicht** der
Append-only-Logik zugeordnet („nennt dieselbe Stelle **nicht**"), landen aber ohne Beleg per
Default in Buchstabe a (vier Ausgänge). Der Satz, der das begründet, endet mit einem Verweis
`([§6](#6-offene-fragen))` — ich habe §6 gelesen:

```sh
sed -n '217,236p' harness/migration.md | grep -in "observation\|MR-NNN\|sensor\|gate.template\|mehrinstanzig"
# -> kein Treffer
```

**§6 nennt diese drei Zeilen an keiner Stelle.** Der Verweis zeigt auf einen Abschnitt, der die
Frage, die er beantworten soll, nicht führt — dieselbe Fehlerklasse wie F-6 im Review
(„Beleg-Zeiger landet im falschen Abschnitt seiner Quelle"), nur an einer Stelle, die der
Nacharbeit-Commit neu eingeführt und die kein Reviewer mehr gesehen hat (§3 unten). Für DoD-2s
Auflage („was sich nicht belegen lässt, steht als offene Frage") ist das eine echte Lücke: Der
Default-Fall für die größte Instanzmenge des ganzen Registers ist weder ADR-belegt noch als offene
Frage benannt — er ist stillschweigend durchgerutscht.

### DoD-3 — jeder normative Punkt trägt eine ADR-Kennung aus der Sechser-Menge, §6 gefüllt oder Leere belegt

**Überwiegend erfüllt, mit derselben Lücke wie oben.**

Der Reviewer hat **36** Aussagen aus §1–§5 des **ersten** Commits (`f0d58786`) einzeln gegen ihre
zitierte ADR gehalten und 30 als tragend bestätigt, 6 als Findings (F-1, F-2, F-3, F-6, F-8, F-12)
eingeordnet. Ich habe versucht, diese Zahl unabhängig nachzumessen, und benenne die Grenze dieses
Versuchs offen: **„normativer Satz" ist keine grep-bare Eigenschaft.** Ein mechanischer Proxy
(Absätze/Bullets außerhalb von Tabellen und Codeblöcken in §1–§5) liefert je nach Zählweise
zwischen 21 und über 40, abhängig davon, ob Tabellenzeilen einzeln oder als ein Absatz gezählt
werden — keine Zahl davon reproduziert „36" ohne dieselbe Klassifikations-Entscheidung zu treffen,
die der Reviewer getroffen hat. Ich zähle das **nicht** als Befund gegen den Reviewer — es ist
dieselbe Grenze, die `AGENTS.md` §3.6 selbst für Muster-vs-Urteil zieht (Befund-Kennung/
Slice-Nummer sind zählbare Muster, „normativer Satz" ist ein Urteil).

Statt der Nachzählung eine **eigene, gezielte Stichprobe von 10** Aussagen — bewusst auch aus dem
**Nacharbeit-Commit**, den der ursprüngliche 36er-Durchlauf nicht erfasst haben kann (er lief gegen
`f0d58786`, vor `6fedb06b`):

| # | Aussage (Ort) | Zitierte ADR/Quelle | Ergebnis |
|---|---|---|---|
| 1 | §1 Kriterium („wird gemessen, ob die gepinnte Fassung die Migrations-Prozedur führt") | ADR-0018 Festlegung 3 | **trägt wörtlich** — Festlegung 3 selbst geprüft |
| 2 | §1 „Prozedur ≠ Ist-Maßstab" | ADR-0018 Festlegung 2 | **trägt** — Verallgemeinerung von `v3.5.2` auf „die gepinnte Fassung" ist durch die Festlegungs-Überschrift selbst gedeckt |
| 3 | §1 Tabellenzeile `v5.18.0`→`v6.0.0` (ADR-0036, ohne Festlegungsnummer) | ADR-0036 §Entscheidung | **trägt** — ADR-0036 hat genau „Eine Festlegung", Zitat ohne Nummer korrekt |
| 4 | §1 Tabellenzeile `v6.0.0`→`v6.5.0` (ADR-0038, ohne Festlegungsnummer) | ADR-0038 §Entscheidung | **trägt** — dieselbe Lage, „Eine Festlegung" |
| 5 | §1 Proposed-Markierung (Nacharbeit) | ADR-0031 §Geschichte | **trägt** — Status tatsächlich `Proposed` seit 2026-09-03 |
| 6 | §3 „Festlegung erlaubt nicht, einen Durchgang auszulassen … Kosten wachsen mit" (Nacharbeit-Fix von F-3) | ADR-0043 Festlegung 2 | **trägt** — Quelle: „Sie erlaubt **nicht**, einen Durchgang auszulassen: Fällt auch dieser aus, wächst die Basis weiter, und die Kosten wachsen mit." Nahezu wörtlich |
| 7 | §3 „unverändert angewendet durch ADR-0044 Festlegung 2" | ADR-0044 Festlegung 2 | **trägt** — Festlegung 2 nennt sich selbst „eine Anwendung, keine zweite Fassung der Leseregel" |
| 8 | §5 fünf Ausgangs-Namen, Zeiger auf ADR-0018 §Entscheidung Festlegung 4 (Nacharbeit-Fix von F-6) | ADR-0018 Festlegung 4 | **trägt** — Namen (*gegenstandslos · bleibt gültig · teilweise überholt · Bezug ist entfallen · widerspricht*) stehen tatsächlich dort, §Kontext nennt nur die Zahl |
| 9 | §4/§5 „sechs Zeilen" für die Append-only-Vorlagenklasse (Welle-Familie zählt als zwei Zeilen) — **neu in der Nacharbeit, nie geprüft** | ADR-0018 Festlegung 4 zitiert „ADR, Slice, Welle, Carveout, Review-Report" (5 Namen) | **trägt als Lesart** — die ADR nennt 5 **Kategorien**, das Register führt für „Welle" zwei separate Vorlagen (`welle.template.md`, `welle-results.template.md`); die Abbildung 5 Kategorien → 6 Registerzeilen ist eine Mengen-Übersetzung, keine inhaltliche Erweiterung der Kategorie-Liste. Modul 2 nennt „Welle" an anderer Stelle ebenfalls als eine Sammelkategorie „wiederkehrender Artefakte", ohne die zwei Dateiformen zu trennen — die Trennung ist migration.md's eigene, korrekt gekennzeichnete Präzisierung, keine stille Zusatz-Nuance |
| 10 | Bestand-Aussage „kein Ziel für einen siebten Sprung ist gesetzt" | `harness/conventions.md` §Baseline | **trägt** — `ls .harness/baseline/` → nur `v6.7.2`, keine siebte Zielstand-Zeile in §Baseline |

**Alle 10 Stichproben tragen.** Das stützt die Reviewer-Einschätzung „30 von 36 tragend" für den
ersten Commit und zeigt zusätzlich, dass die **neuen** Aussagen der Nacharbeit (#6–#9) ebenfalls
tragen — mit der einen bereits unter DoD-2 genannten Ausnahme (die §6-Verweis-Lücke, die keine
Falschaussage ist, sondern eine fehlende Aussage an der Stelle, wo eine hingehört).

### `make gates` grün

**Bestätigt** (§0).

### Review durchgeführt, kein Self-Review

**Formal nicht abhakbar — zentraler Befund dieser Verifikation, siehe §2.**

### Doku-Update (Guides-Zeile)

**Erfüllt.**

```sh
grep -n "migration" harness/README.md
# 38:| [`migration.md`](migration.md) | Instanz-Register … |
```

### Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge (§6), drei Paarungen

**Unverändert offen — korrekt.** Der Slice-Plan trägt weiterhin `- [ ]` an allen Closure-Punkten,
§6 seine fünf Platzhalter-Ausgänge, §7 ist leer. Das ist Planner-Arbeit nach `AGENTS.md` §3.10 und
nicht Gegenstand dieses Laufs; kein Befund.

---

## 2. Zentraler Befund: die Nacharbeit, die den blockierenden HIGH schließt, hat keine zweite Reviewer-Runde

Der einzige vorliegende Review-Report für diesen Slice
([`2026-09-13-slice-migration-hat-ein-instanz-register.md`](2026-09-13-slice-migration-hat-ein-instanz-register.md))
endet unverändert mit:

> **Merge-blockierend: ja.**

```sh
git log --oneline -- docs/reviews/2026-09-13-slice-migration-hat-ein-instanz-register.md
# 93c54d1b Rolle Reviewer: slice-migration-hat-ein-instanz-register -- blockierend, 1 HIGH / 6 MEDIUM
git log --oneline --all -- 'docs/reviews/*migration-hat-ein-instanz-register*'
# -> nur diese eine Review-Datei
```

Seit `93c54d1b` ist der Report nicht erneut angefasst worden. Die Nacharbeit (`6fedb06b`), die F-1
(HIGH) sowie F-2, F-3, F-4, F-5, F-6 (MEDIUM) behebt — und zusätzlich, ungenannt in der
Commit-Message, F-8 und F-10 (LOW) —, ist eine **Selbstauflösung durch dieselbe Rolle**, die den
Diff geschrieben hat, ohne dass die Rolle, die die Befunde erhoben hat (Reviewer), die Behebung an
**diesem** Artefakt bestätigt. Das ist strukturell dieselbe Lücke, die zwei vorangegangene
Verifikationen in diesem Repo bereits benannt haben
([`2026-09-13-slice-224-…-verify.md`](2026-09-13-slice-224-delta-nachweis-und-planungs-nachzug-verify.md),
[`2026-09-13-slice-225-…-verify.md`](2026-09-13-slice-225-gate-index-steht-einmal-verify.md)): Nach
Modul 8 gilt *„Reviewer prüft auf Konsistenz"* — eine Selbstkorrektur durch die behebende Rolle
ohne erneute Prüfung durch die erhebende Rolle ist genau die Klasse, die `AGENTS.md` §3.6 als
*„Behauptung ohne Bestätigung"* fasst, hier auf das Review-Verdikt selbst angewandt statt auf eine
Test-Zusage.

**Das ist kein Einwand gegen die Richtigkeit der Nacharbeit.** Meine eigene Stichprobe (§1 DoD-3,
10 Aussagen inkl. der neuen §5-Buchstabe-b-Konstruktion) und der direkte Quellenabgleich für F-2,
F-3, F-5, F-6 (§3 unten) finden die Korrekturen **substantiell korrekt**. Der Einwand betrifft die
**Form**: Auf dem Papier trägt der einzige Review-Report weiterhin „Blockierend", und eine
Verifikation ersetzt keine Reviewer-Bestätigung — sie hat einen anderen Eingabe-Kontext (DoD/Spec,
nicht Plan/Konventionen) und prüft nach Modul 11 explizit **nicht** dieselbe Frage. Ob meine
Stichprobe als ausreichende Bestätigung gilt oder eine frische Reviewer-Runde gegen `6fedb06b`
nötig ist, ist eine Entscheidung des Planners — dieselbe, die die beiden zitierten Vorgänger-
Verifikationen bereits an ihn zurückgegeben haben.

---

## 3. Direkter Quellen-Abgleich der sechs Nacharbeit-Fixes (F-1 bis F-6)

| Finding | Fix in `6fedb06b` | Quelle geprüft | Ergebnis |
|---|---|---|---|
| F-1 (HIGH) | §5 in Buchstabe a (4 Ausgänge, 19 Zeilen) / b (append-only, 6 Zeilen) gesplittet | `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit (Schritt 2); ADR-0018 §Entscheidung F4 | **schließt den Befund** — die Baseline untersagt für wiederkehrende Vorlagen das rückwirkende Umschreiben, das *übernommen* verlangt hätte; Buchstabe b umgeht genau das |
| F-2 (MEDIUM) | `Proposed`-Status von ADR-0031 an beiden Zitierstellen (§1, §2) ergänzt | ADR-0031 §Geschichte | **schließt den Befund** — Status verifiziert |
| F-3 (MEDIUM) | „erlaubt nicht auszulassen" statt „verhindert den Ausfall nicht" | ADR-0043 Festlegung 2 | **schließt den Befund** — Wortlaut jetzt deckungsgleich, kein Verbot zur Beschreibung abgeschwächt |
| F-4 (MEDIUM) | 378 statt 377 Review-Reports, mit MR-058-Zeiger | `ls docs/reviews/*.md \| wc -l` | **schließt den unmittelbaren Befund** — 378 stimmt für `6fedb06b`; Anschlussfrage in §4 unten |
| F-5 (MEDIUM) | zwei Präsens-Aussagen mit `v6.7.2 · regelwerk/…`-Tag versehen | Zeilen 125, 208 | **schließt den Befund** |
| F-6 (MEDIUM) | Zeiger von §Kontext auf §Entscheidung Festlegung 4 korrigiert | ADR-0018 | **schließt den Befund** — §Kontext nennt tatsächlich nur die Zahl, nicht die Namen |
| F-7 (MEDIUM) | nicht behandelt | — | **korrekt unbehandelt** — Review selbst erklärt F-7 für nicht mehr behebbar (Commit gepusht) und nicht merge-blockierend |

Sechs von sieben MEDIUM/HIGH-Befunden sind stofflich korrekt geschlossen; F-7 bleibt wie vom
Reviewer selbst vorgesehen im Steering-Loop-Zähler. Formal fehlt dazu weiterhin die
Reviewer-Bestätigung (§2).

---

## 4. Plan-vs-Code in beide Richtungen

**Plan → Code:** Alle drei Liefer-Punkte sind im Diff vorhanden (§1). Keine Abweichung von §1 des
Slice-Plans — Out-of-Scope-Punkte (kein `docs/migrations/`-Report, keine ADR, kein Sensor, kein
`harness/conventions.md`-Edit, kein Produkt-Code) sind eingehalten; ich habe stichprobenartig
`git diff --name-only f0d58786^..6fedb06b` gegen die Ausschlussliste gehalten:

```sh
git diff --name-only f0d58786^..6fedb06b
# harness/README.md
# harness/migration.md
```

Nur diese zwei Dateien — deckt sich mit dem Reviewer-Negativbefund für `f0d58786`, und die
Nacharbeit fügt keine dritte hinzu.

**Code → Plan (Gebautes-aber-nicht-Geplantes):** Nichts über die zwei genannten Dateien hinaus.

**Zwei kleinere Beobachtungen, keine Blocker:**

1. **Commit-Message-Zähler stimmt nicht mit dem Diff überein.** `6fedb06b` sagt „Dazu sechs weitere
   Review-Befunde behoben" und listet fünf (F-2, F-3, F-4, F-5, F-6). Der Diff zeigt zusätzlich
   F-8 (Vorspann „keine löst die vorige ab" korrigiert) und F-10 (`diff`-Fundstelle-Beleg-Art
   korrigiert) — tatsächlich behoben sind sieben LOW/MEDIUM-Befunde, benannt sind fünf. Das ist eine
   Untertreibung, kein Übertreiben, und der Commit ist bereits gepusht (unveränderlich, wie F-7 im
   Review selbst). Kein DoD-Bezug, geht in den Steering-Loop-Zähler.
2. **`ADR-0018` §Entscheidung Festlegung 4 als Quelle der Fünf-Namen und der Append-only-Klausel**
   — direkt gelesen (§1 DoD-3 #8, #9 oben). Kein Nuance-Zusatz gegenüber der Quelle gefunden: Die
   Argumentationskette in §5 Buchstabe b (*„übernommen verlangt genau das rückwirkende
   Umschreiben … das die Baseline … untersagt"*) ist migration.md's **eigene**, korrekt nicht als
   Zitat ausgegebene Schlussfolgerung aus der zitierten Klausel — §5s Kopf sagt selbst „Formvorgabe
   für einen künftigen Bericht, keine ADR-Aussage". Kein §3.8-Grenzfall.

---

## 5. `MR-058` und die Frage nach dem infiniten Regress

```sh
ls docs/reviews/*.md | wc -l
# 378   (Stand vor diesem Commit)
```

`378` ist für den Stand `6fedb06b` korrekt — MR-058 verlangt, die Messung **nach** dem Vorgang zu
nehmen, der sie bewegt (hier: dem Review-Commit `93c54d1b`, der die 377. auf 378 Dateien brachte),
statt davor. Das ist erfüllt.

**Was MR-058 nicht auflöst und nicht auflösen kann:** Dieser Verify-Report selbst liegt gleich
unter `docs/reviews/` und wird die Zahl beim Commit auf **379** bewegen. Das ist **kein** neuer
Defekt und **kein** infiniter Regress im Sinne eines ungelösten Widerspruchs — es ist dieselbe
`kein Erwartungswert`-Disziplin, die **jede** andere Mengen-Angabe in diesem Register trägt (ADR:
46, Slice: 229, Observation: 104, …): Der Text nennt das Kommando, nicht einen für alle Zeit
gültigen Betrag, und ein Leser reproduziert die aktuelle Wahrheit selbst. `MR-058` löst genau **eine**
Kausalitäts-Frage (welcher Vorgang die Zahl zuletzt bewegt hat, *bevor* gemessen wird) — es kann
strukturell nicht versprechen, dass keine *weitere* Handlung sie danach nochmals bewegt, denn jede
künftige Review- oder Verify-Datei tut das, unabhängig davon, ob sie von diesem Slice handelt. Ein
Mechanismus, der das schlösse, müsste das Schreiben weiterer `docs/reviews/`-Dateien verbieten —
das wäre eine andere und schlechtere Regel. **Befund: keiner.** Zu vermerken für die Closure-Notiz
als Beobachtung, nicht als Risiko.

---

## Was ich nicht geprüft habe

- **Die exakte Reproduktion von „36 normativen Sätzen"** — kein grep-bares Kriterium; stattdessen
  eine eigene 10er-Stichprobe (§1 DoD-3), die überlappungsfrei zu den bereits als Findings
  geführten Sätzen gewählt wurde.
- **Alle 25 Registerzeilen einzeln erneut** — der Reviewer hat das bereits vollständig getan
  (Bijektion + alle 9 Mengen-Zeilen + alle 4 `keine Instanz`-Begründungen); ich habe daraus 3
  Mengen (ADR 46, Slice 229, Review-Report 378) und die Vollständigkeitszahl (25) unabhängig
  nachgerechnet, nicht den vollen Bestand erneut durchgezählt.
- **Die übrigen sechs Doku-Gate-Module** (`links`, `anchors`, `ids`, `matrix`, `codepaths`,
  `spans`, `planning`) sowie die Go-/bats-/shellcheck-/actionlint-Gates einzeln — gedeckt durch den
  Working-Tree-Hash-Abgleich in §0, nicht separat neu gefahren (Docker-Verbot dieser Rolle).
- **`make mutate`, `make full-smoke`, `make smoke`** — nicht Gegenstand dieser Verifikation, kein
  DoD-Punkt verlangt sie für diesen Slice.

---

## Urteil

**DoD: nicht vollständig erfüllt.** Was der Planner abhaken darf und was nicht:

| DoD-Punkt | Status | Was fehlt |
|---|---|---|
| (1) Instanz-Register, Zeilenzahl == `find` | **abhakbar** | — |
| (2) Report-Form, vier Ausgänge, geschlossene Menge | **nicht abhakbar wie geschrieben** | Der Text behauptet eine universelle Vier-Menge; das Dokument trägt jetzt zu Recht zwei Fälle (vier Ausgänge / append-only). Der DoD-Text muss die Zwei-Fall-Struktur aufnehmen (Planner-Entscheidung), sonst hakt der Punkt eine Zusage ab, die der Code nicht mehr macht. Zusätzlich: die drei mehrinstanzigen Zeilen (Observation/MR/Sensor-Gate, 178 Instanzen), die per Default in Buchstabe a fallen, sind nicht als offene Frage in §6 benannt, obwohl §4 dorthin verweist |
| (3) jeder normative Punkt trägt eine ADR-Kennung, §6 gefüllt/Leere belegt | **im Wesentlichen abhakbar**, mit derselben Lücke wie (2) | die §6-Verweis-Lücke ist auch hier relevant: ein normativer Default (Observation/MR/Sensor-Gate → Buchstabe a) hat keine ADR-Kennung und steht nicht als offene Frage |
| `make gates` grün | **abhakbar** | — (Hash-Beleg §0) |
| Review durchgeführt, kein Self-Review | **nicht abhakbar** | Der einzige Review-Report trägt weiterhin „Merge-blockierend: ja"; die Nacharbeit, die das inhaltlich auflöst, hat keine Reviewer-Bestätigung. Planner-Entscheidung nötig: frische Reviewer-Runde gegen `6fedb06b`, oder diese Verifikation ausdrücklich als hinreichende Bestätigung akzeptieren |
| Doku-Update (Guides-Zeile) | **abhakbar** | — |
| Closure-Notiz, Beobachtungs-Register, Risiko-Ausgänge, drei Paarungen | unverändert offen | Planner-Arbeit, nicht Gegenstand dieses Laufs |

**Empfehlung an den Planner:**

1. DoD-Punkt (2) so umformulieren, dass er die Buchstabe-a/b-Struktur trägt, statt sie zu
   verschweigen — die Dokument-Fassung ist materiell korrekter als der ursprüngliche DoD-Text.
2. Die §6-Lücke schließen lassen (ein Implementer-Nachtrag oder eine bewusste Streichung der
   Verweis-Klausel in §4, falls die Zuordnung von Observation/MR/Sensor-Gate absichtlich offen
   bleiben soll — dann gehört sie als vierter Punkt in §6, nicht nur als Verweis ohne Ziel).
3. Entscheiden, ob eine frische Reviewer-Runde gegen `6fedb06b` eingeholt wird oder ob die
   Quellen-Abgleiche in §3 dieses Reports als hinreichende Bestätigung für F-1 bis F-6 gelten —
   erst danach ist der DoD-Punkt „Review … kein Self-Review" ehrlich abhakbar.

**Was trägt, ohne Einschränkung:** Das Instanz-Register selbst (DoD-1), der `make gates`-Nachweis,
die inhaltliche Richtigkeit aller sechs geprüften Nacharbeit-Fixes, und die Out-of-Scope-Treue
gegen §1 des Slice-Plans.
