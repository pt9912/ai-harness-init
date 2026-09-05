# Review: ADR-0036 — Konsistenz-Bestätigung, Runde 2

**Rolle:** Unabhängiger Reviewer (Harness Modul 10) — Diff gegen Plan + ADRs + Hard Rules
(**nicht** DoD; das ist Verifier-Rolle).

**Datum:** 2026-09-05 · **Reviewer:** Claude, frischer Kontext, keines der geprüften Artefakte
selbst geschrieben, an keinem etwas geändert.

**Gegenstand und Zuschnitt.** Eng: geprüft wird ausschließlich, ob `477b326` („Rolle Architect:
ADR-0036 -- zwei blockierende Befunde der Konsistenz-Bestaetigung behoben") die zwei MEDIUM
schließt, mit denen
[`2026-09-05-adr-0036-konsistenz-bestaetigung.md`](2026-09-05-adr-0036-konsistenz-bestaetigung.md)
blockierte. Die Konsistenz gegen [`ADR-0018`](../plan/adr/0018-ziel-fassung-regiert-die-migration.md)
und [`ADR-0031`](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) hat jene
Runde ohne Befund abgedeckt und wird hier nicht wiederholt (siehe §Negativbefunde, letzter Punkt).
Jede Zahl und jedes Kommando dieses Reports ist in diesem Lauf selbst gefahren; **nichts** ist aus
der Commit-Message oder aus dem Vorbericht übernommen.

**Trigger-Bezug.** [`ADR-0036`](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md)
§Der Acceptance-Trigger macht genau diesen Report zur Bedingung ihres Umschlags auf `Accepted`:
*„wenn eine Reviewer-Runde sie gegen ADR-0018 und ADR-0031 auf Konsistenz geprüft hat und ihr
Report ohne blockierenden Befund in `docs/reviews/` liegt"*.

## Eingangs-Kontext (fünf Pflicht-Punkte + Plan)

- **Diff-Range:** `477b326` gegen `477b326^`, dazu die Gegenprobe gegen `HEAD` = `a3bdd2f`
  (sechs Commits später; keiner davon berührt die ADR —
  `git log --oneline 477b326..HEAD -- docs/plan/adr/0036-…md` ist leer).
- **`LH-*`:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (kein Gate liest, nach welcher Fassung ein Durchgang lief),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tag als
  Reproduzierbarkeits-Klammer).
- **Referenzierte aktive ADRs:** ADR-0018, ADR-0031, ADR-0015, ADR-0016, ADR-0030, ADR-0034,
  ADR-0036 selbst. Keine `Superseded`/`Deprecated` — in Runde 1 gemessen, hier nicht erneut.
- **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3, insbesondere §3.4 (ADR ab `Accepted`
  immutabel), §3.6, §3.7 samt seinem Geltungsbereich, §3.8 (Architect-Commit-Zuschnitt),
  §3.9 (Docker-only).
- **Vorherige Findings am gleichen Modul:** der Report von Runde 1 (0 HIGH, 2 blockierende MEDIUM
  am Gegenstand, 1 MEDIUM + 1 LOW daneben) und seine als wiederkehrend markierte Klasse
  *„eine Aussage nennt einen Fundort, wo eine Fundmenge steht"*.
- **Slice-Plan:** [`slice-178`](../plan/planning/done/slice-178-regierende-fassung-des-sprungs-v600.md).

**Gate-Lauf:** `make gates` → **EXIT 0** (Docker-only, §3.9). `d-check: 796 Datei(en) geprüft,
0 Befund(e)`. Die zwei Nebenbefunde von Runde 1 (N-1 fremder Agent-Worktree, N-2 präfixloser
Verweis auf `slice-184`) sind beide weg: `git worktree list` zeigt nur den Hauptbaum, und die
Verweise sind mit `3c54a0b`/`a3bdd2f` nachgezogen.

---

## Teil A — Was `477b326` erreicht

### Runde-1-M-2 (Zeilen-Zuordnung 9/11) — **behoben, ohne Restbefund**

Der Widerspruch, den Runde 1 als M-2 führte, ist weg: Die angehängte Korrektur-Zelle ist durch
konsistente Werte in Zelle und Folgeaussage ersetzt. Ist-Stand, selbst gelesen: Tabellenzeile 1
(`:102`) trägt **9**, Zeile 2 (`:103`) *„(dieselben 9)"*, der neue Absatz (`:108–112`) trägt die
restlichen **2** und die Gesamtzahl **11**, und der zuvor unveränderte Satz auf `:127` sagt jetzt
*„**Und die neun treffen die delegierte Frage** …"*. Keine Stelle der Datei behauptet noch, die 11
träfen die delegierte Frage.

Die Zahlen sind in diesem Lauf nachgemessen und stimmen:

```sh
git show d75cd8c^:.harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md > /tmp/ghd.alt
diff /tmp/ghd.alt .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | grep -c '^[<>]'                    # 13
diff /tmp/ghd.alt .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | grep -c '^[<>].*<!-- Quelle:'      # 2
diff -u /tmp/ghd.alt .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md | grep '^@@'
# -> @@ -1,5 +1,5 @@ (Herkunfts-Kommentar) · @@ -11,7 +11,7 @@ (1 raus / 1 rein) · @@ -292,8 +292,13 @@ (2 raus / 7 rein)
grep -n '^### ' .harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
# -> Verzeichniskonvention ab 4 · … · harness/conventions.md als Konventionsspeicher ab 219 · Jedes Artefakt … ab 316
```

13 roh − 2 Herkunfts-Kommentar = **11** netto; 2 davon im Hunk bei Zeile 14 (§Verzeichniskonvention,
4–25), 9 im Hunk bei 292–304 (§Konventionsspeicher, 219–315). Die Aufteilung 9/2 der Datei ist
damit richtig.

### Runde-1-M-1, zweiter Fundort (`:240`, §Entscheidung Grund 1) — **behoben**

Der beanstandete Schlusssatz *„… und der Unterschied ist an einer lebenden Stelle des
Konventionsspeichers ablesbar"* (pre-fix `:239–240`) ist ersetzt. Die drei Tatsachenbehauptungen
der neuen Fassung (`:244–251`) halten, selbst gemessen:

```sh
# (1) "war zum Zeitpunkt dieser Entscheidung ... ablesbar"
git log --oneline --diff-filter=A -- docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md   # 9ad297a
git show 9ad297a:harness/conventions.md | sed -n '/^## Modus-Deklaration pro Sub-Area/,/^| Sub-Area/p' | head -8
# -> "**Eine Kürzel-Spalte führt diese Tabelle nicht.** ... (adoptierter Stand `v5.18.0`, ...)"
# (2) "durch einen eigenen Architect-Commit nachgezogen"
git show -s --format='%s' 655c2df
# -> Rolle Architect: Modus-Deklaration bekommt die Kuerzel-Spalte (ADR-0034 Festlegung 3, Folgepflicht 2)
# (3) "(ADR-0034 Festlegung 3, Folgepflicht 2)"
grep -n 'Folgepflicht 2 (Architect, eigener Commit)' docs/plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md  # 359
```

ADR-0034 §Folgepflicht 2 lautet verbatim *„die Kürzel-Spalte und der Ersatz des Absatzes, der ihre
Leere begründet, in `harness/conventions.md`"* — der Verweis trifft. **Kein Restbefund an diesem
Fundort.**

---

## Teil B — Findings dieses Laufs

### M-1 — Der **erste** der zwei von Runde-1-M-1 benannten Fundorte ist unverändert

- **kategorie:** MEDIUM (blockierend)
- **quelle:** Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.4 (mit dem Umschlag auf
  `Accepted` wird der Text unkorrigierbar) · Klassen-Anker:
  `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (`Stand: offen`, 1 Beleg)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:185–199`
  (§*Die Wirkung ist nicht hypothetisch — sie steht heute im Konventionsspeicher*)
- **befund:** Runde-1-M-1 nannte **zwei** Fundorte — `:180–187` (die Sektion) und `:240`
  (§Entscheidung Grund 1) — und ihr Verdikt wiederholte das ausdrücklich (*„§Die Wirkung ist nicht
  hypothetisch **samt** dem Schlusssatz von §Entscheidung Grund 1"*). `477b326` hat nur den
  zweiten angefasst; die Sektion ist über den Fix-Commit **byte-gleich** und auch gegen `HEAD`
  unverändert. Sie trägt vier Aussagen im Präsens, die am Ist-Stand sämtlich falsch sind:
  (i) die Sektionsüberschrift *„sie steht **heute** im Konventionsspeicher"*; (ii) die Stelle
  *„beginnt mit dem Satz «Eine Kürzel-Spalte führt diese Tabelle nicht.»"*; (iii) sie *„begründet
  ihn mit der abgelösten Fassung (der Absatz nennt `adoptierter Stand v5.18.0` …)"*; (iv)
  *„dieses Repo vergibt keine Kennung mit Bereichssegment"*. Dazu ist die Richtungsaussage
  `:194–196` (*„Ein Durchgang nach der gepinnten Fassung liest diese Stelle grün, ein Durchgang
  nach der Ziel-Fassung rot"*) am Ist-Stand invertiert: Die Stelle trägt die Kürzel-Spalte, die die
  Ziel-Fassung unbedingt verlangt.
- **verifizierbar:** **nein** — kein Gate-Modul liest, was ein Satz über eine andere Datei
  behauptet ([`.d-check.yml`](../../.d-check.yml) führt `links, anchors, ids, matrix, codepaths,
  spans`; `make comment-claims` hat keine Markdown-Datei im Prüfbereich; `make gates` steht in
  diesem Lauf auf EXIT 0). Reproduzierbar:
  ```sh
  diff <(git show 477b326^:docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md \
           | sed -n '/^### Die Wirkung ist nicht hypothetisch/,/^### Die gepinnte Fassung/p') \
       <(sed -n '/^### Die Wirkung ist nicht hypothetisch/,/^### Die gepinnte Fassung/p' \
           docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md)   # leer, Exit 0
  grep -c 'Eine Kürzel-Spalte führt diese Tabelle nicht' harness/conventions.md   # 0
  grep -c 'adoptierter Stand' harness/conventions.md                              # 0
  sed -n '191p;214p' harness/conventions.md
  # -> "**Die Spalte ist nicht bedingt — seit `v6.0.0` trägt sie.** ..."
  #    "| Sub-Area | Kürzel | Modus | Begründung | Graduation |"
  ls -1d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                       # 45  (Kennungen mit Bereichssegment)
  ```
  Zu (iv): Zum Anlage-Zeitpunkt der ADR traf die Aussage zu — das Register lag flach
  (`git show 9ad297a:docs/plan/planning/observations.md` löst auf,
  `git ls-tree --name-only 9ad297a:docs/plan/planning/observations/` nicht). Heute vergibt das
  Repo 45 Kennungen der Form `BEO-ALL/<slug>`.
- **klasse:** *Präsens-Aussage über ein lebendes Artefakt in einem einzufrierenden Text* — und in
  zweiter Lesart *Korrektur nennt einen Fundort, wo eine Fundmenge steht*: Der Fix bearbeitete
  einen von zwei benannten Fundorten.
- **Was davon nicht fällt:** Die **Festlegung** bleibt richtig, und der Grund, der sie trägt, ist
  in `477b326` sauber auf den Ist-Zustand gezogen (Teil A). Der Befund betrifft eine
  Beleg-Sektion des §Kontext, nicht die Entscheidung.

### M-2 — Ein fünfter Fundort derselben Aussage, den keiner der beiden Reports bisher genannt hat

- **kategorie:** MEDIUM (blockierend)
- **quelle:** Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.4 · Klassen-Anker:
  `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form`
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:298`
  (§Verglichene Alternativen, Zelle *Contra* der Option B)
- **befund:** Die Zelle schließt mit *„die Kürzel-Spalten-Stelle im Konventionsspeicher wäre grün,
  wo der adoptierte Stand rot ist"*. Der Nebensatz ist Indikativ Präsens über den Ist-Stand und
  trifft nicht mehr zu: Der adoptierte Stand ist `v6.0.0`, dessen Pflichtgliederung die Spalte
  unbedingt verlangt (*„Die Spalte ist nicht bedingt."*), und
  `harness/conventions.md` §Modus-Deklaration pro Sub-Area führt sie seit `655c2df`. Die
  Beziehung, die die Zelle als Contra-Argument gegen Option B ausgibt, ist am Ist-Stand
  umgekehrt. Damit sind es fünf Stellen derselben Aussage in dieser Datei — eine korrigiert
  (`:244–251`), vier offen (`:185`, `:187–192`, `:194–196`, `:298`).
- **verifizierbar:** **nein** (dasselbe Argument wie bei M-1). Reproduzierbar:
  ```sh
  grep -n 'Kürzel-Spalten-Stelle im Konventionsspeicher' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md  # 298
  grep -n -e 'Kürzel' -e 'Konventionsspeicher' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md \
    | cut -d: -f1 | tr '\n' ' '     # 96 102 103 185 187 190 243 245 247 298  -> die Fundmenge
  sed -n '191p;214p' harness/conventions.md
  ```
- **klasse:** *Präsens-Aussage über ein lebendes Artefakt in einem einzufrierenden Text*
- **Was davon nicht fällt:** Die **Wahl** gegen Option B bleibt getragen — das erste Argument der
  Zelle (*„sie ist nicht mehr vendored"*) ist am Ist-Stand nachgemessen richtig
  (`ls -1 .harness/baseline/` → genau `v6.0.0`) und steht unabhängig.

### LOW-1 — Der neue Absatz beschreibt seinen eigenen früheren Text

- **kategorie:** LOW
- **quelle:** Maintainability (kein Hard-Rule-Anker: [`AGENTS.md`](../../AGENTS.md) §3.7 bindet
  ausweislich seines §Geltungsbereich *„Code, Konfiguration, Skripte und die Zustandsfelder der
  lebenden Register"* — ADR-Fließtext ist keines davon)
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:110–112`
- **befund:** Der Absatz schließt mit *„nur ihre Zuordnung zu genau einer Sektion **war** zu grob:
  9 treffen die delegierte Frage, 2 nicht."* Nach dem Fix trägt keine Stelle der Datei mehr eine
  Zuordnung zu genau einer Sektion; die Vergangenheitsform spricht über einen Text, der nur noch
  in `git` steht. Ein Leser nach dem Einfrieren kann nicht entscheiden, ob *„zu grob"* die
  frühere Fassung dieses Absatzes meint oder eine Aussage der gemessenen Baseline.
- **verifizierbar:** **nein**. Reproduzierbar:
  ```sh
  git show 477b326^:docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md | sed -n '102,103p'  # das "zu grobe" Etikett, nur noch hier
  grep -n 'war zu grob' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md                  # 111
  ```
- **klasse:** *Text beschreibt seine eigene Entstehung statt seinen Gegenstand*

### INFO-1 — Die Zählkonvention hinter „9 … (Zeilen 295–301)" steht nicht daneben

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:102` und `:109`
- **befund:** **9** und **2** sind `diff`-Zeilen über **beide** Bäume (Hunk 3: 2 entfernt + 7
  hinzugefügt; Hunk 2: 1 entfernt + 1 hinzugefügt), die Klammer-Angaben *„Zeilen 295–301"* und
  *„Zeile 14"* adressieren dagegen nur den **neuen** Baum. Wer bei 295–301 nachzählt, findet
  sieben Zeilen, nicht neun. Die Konvention ist dieselbe, die Runde 1 und die pre-fix-Fassung
  benutzten; sie ist nicht falsch, steht aber nirgends.
- **verifizierbar:** **nein**. Reproduzierbar: der `diff -u`-Aufruf aus Teil A.
- **klasse:** *Zahl und Ortsangabe messen verschiedene Bezugsmengen*

### INFO-2 — „ein eigener Architect-Commit" ohne Operanden

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md:247–248`
- **befund:** Grund 1 nennt den Nachzug *„durch einen eigenen Architect-Commit"* und dazu
  `ADR-0034` Festlegung 3, Folgepflicht 2 — aber keinen Commit-Operanden, während dieselbe Datei
  ihre Baseline-Messungen durchweg an `d75cd8c^` bzw. `db83415^` hängt. Runde 1 hatte dieselbe
  Beobachtung an der Vorgänger-Formulierung als Teil ihres M-1 notiert. Auflösen lässt sich der
  Verweis über den Titel (`655c2df`), nicht über die Datei.
- **verifizierbar:** **nein**. Reproduzierbar:
  ```sh
  git log --oneline -1 -S'Eine Kürzel-Spalte führt diese Tabelle nicht' -- harness/conventions.md   # 655c2df
  grep -c 'd75cd8c' docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md                      # 6
  ```
- **klasse:** *Beleg ohne auflösbaren Operanden neben Belegen, die einen tragen*

---

## Negativbefunde (geprüft, ohne Befund)

- **Commit-Zuschnitt von `477b326` — sauber.** `git show --pretty=format: --name-only 477b326`
  gibt **eine** Datei aus, die ADR. Das ist der Zuschnitt, den
  [`AGENTS.md`](../../AGENTS.md) §3.8 für Architect-Artefakte verlangt; die Message nennt die
  Rolle und beide auslösenden Befunde.
- **Kein späterer Commit hat die ADR angefasst.** `git log --oneline 477b326..HEAD --
  docs/plan/adr/0036-…md` ist leer; die sechs Commits danach betreffen `slice-184`/`slice-186`
  und den Register-Bestand. Alle Aussagen dieses Reports gelten für `HEAD` = `a3bdd2f`.
- **Status und Index stimmen überein.** Die Datei trägt `**Status:** Proposed`,
  [`docs/plan/adr/README.md`](../plan/adr/README.md) Zeile 43 führt sie mit demselben Status und
  vollständiger Bezugs-Liste. Der Umschlag ist nicht vorweggenommen.
- **Die übrigen lebenden Aussagen der ADR halten.** `ls -1 .harness/baseline/` → genau `v6.0.0`
  (`:203`); die fünf genannten Slice-Kennungen liegen dort, wo die Datei sie verortet — `152`,
  `171`, `185` in `open/`, `176`, `178` in `done/` (`ls -1 docs/plan/planning/*/slice-<N>-*.md`).
  ADR-0030 Festlegung 3 (Kennung ohne Pfad-Adresse) bleibt gewahrt.
- **Die zwei Nebenbefunde von Runde 1 sind erledigt.** `git worktree list` zeigt nur
  `/Development/KI/ai-harness-init`; `d-check` meldet `796 Datei(en) geprüft, 0 Befund(e)` statt
  `1607/5616`. `make gates` steht auf **EXIT 0**.
- **Register-Deckung der zitierten Klassen.** Beide in diesem Report zitierten Beobachtungs-Pfade
  existieren und tragen Belege:
  `BEO-ALL/praesens-aussage-in-einzufrierendem-artefakt-ohne-form` (`Stand: offen`, `slice-145.md`)
  und `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` (`Stand: geplant`, 12 Belege).
- **Docker-only (§3.9).** Kein Host-Paketmanager, keine Host-Toolchain; alles über `make`, `git`,
  `grep`, `diff`, `sed`.
- **Nicht erneut geprüft (Zuschnitt, in Runde 1 ohne Befund abgedeckt):** die Konsistenz gegen
  ADR-0018 Festlegung 2/3/4 und gegen ADR-0031 Festlegung 1/2, die Reproduktion der Mess-Stufen
  (a) und (b) in voller Breite, die Belegform nach ADR-0016 und §Fitness Function. Dieser Lauf
  hat davon nur nachgemessen, was die zwei Fix-Stellen berühren.
- **Nicht geprüft (fremde Rolle):** DoD-Abhakung und Plan-vs-Code-Konformität — Verifikation,
  getrennter Kontext.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 0 | — |
| MEDIUM | 2 (M-1, M-2) | Präsens-Aussage über ein lebendes Artefakt in einem einzufrierenden Text (2×) |
| LOW | 1 (LOW-1) | Text beschreibt seine eigene Entstehung statt seinen Gegenstand |
| INFO | 2 (INFO-1, INFO-2) | Zahl und Ortsangabe messen verschiedene Bezugsmengen · Beleg ohne auflösbaren Operanden |

**Wiederkehrende Klasse, zum fünften Mal:** *„eine Korrektur nennt einen Fundort, wo eine Fundmenge
steht"* — dreimal im Vor-Vorbericht, einmal in Runde 1, und hier erneut: Runde-1-M-1 benannte zwei
Fundorte, `477b326` bearbeitete einen; die vollständige Fundmenge derselben Aussage in dieser Datei
umfasst fünf Stellen. Passende Kennung ist
`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`; die Vergabe eines Belegs gehört in die
Closure, nicht in diesen Report.

---

## Verdikt

**Blockierender Befund: ja — M-1 und M-2.**

Von den zwei MEDIUM aus Runde 1 ist **eines ganz und eines halb** geschlossen: Runde-1-M-2 (die
9/11-Zuordnung) ist an allen von ihm benannten Stellen behoben und in diesem Lauf nachgemessen
richtig. Runde-1-M-1 ist an seinem zweiten Fundort behoben — und die drei Tatsachenbehauptungen
der neuen Fassung halten —, an seinem **ersten** Fundort dagegen unverändert: Die Sektion
§*Die Wirkung ist nicht hypothetisch* ist über `477b326` byte-gleich. Dazu ist beim Messen der
vollständigen Fundmenge ein fünfter Ort derselben Aussage aufgetaucht, den bisher kein Report
genannt hatte (M-2, Option-B-Zelle).

**Die Entscheidung selbst ist tragfähig und wird von keinem dieser Befunde berührt.** Die
Festlegung, ihre zwei tragenden Gründe und die Abgrenzung gegen ADR-0018/ADR-0031 stehen; was
blockiert, sind vier überholte Präsens-Sätze im Beleg-Teil und in einer Alternativen-Zelle — alle
vier nach dem Umschlag auf `Accepted` durch [`AGENTS.md`](../../AGENTS.md) §3.4 gesperrt und dann
nur noch über eine Folge-ADR mit `Supersedes` erreichbar.

**Anlass, ADR-0036 vor der Annahme zu ändern: ja**, an vier Stellen: `:185`, `:187–192`,
`:194–196` und `:298`. Das ist eine **Folge-Konsequenz für einen Architect-Lauf**, kein Selbst-Fix:
Dieser Report hat kein Artefakt außer sich selbst angefasst.

`make gates` → **EXIT 0**. LOW-1, INFO-1 und INFO-2 blockieren nicht.
