# Slice slice-128: Der Kopf von `d-check.mk` sagt, was gilt — und jede Zahl darin misst ihren Gegenstand

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Kommentarblock, drei Aussagen darin. **(2) Gemeinsames
Closure-Kriterium?** Nein. **(3) Auslöser reaktiv oder gewollt?** **Reaktiv** — der Rest eines
Pin-Sprungs, der auf ein fremdes Artefakt wartet. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap.

**Ebene: Dogfood.** [`d-check.mk`](../../../../d-check.mk) ist das gelebte Gate-Fragment dieses
Repos. Der **emittierte** Pfad adaptiert die Live-Ausgabe des gepinnten Images
([`internal/emit/emit.go`](../../../../internal/emit/emit.go)) und ist von diesem Slice
unberührt — was ein emittiertes Repo an Kopf-Aussagen bekommt, entscheidet der Slice, der die
Tool-Ebene entscheidet.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — die drei
Aussagen unten tragen die Klassen *Rang-Zeiger*, *Zusage* und *Abgrenzung*),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 und 2 (die Zahl neben ihrem Kommando; ein Erwartungswert misst seinen Gegenstand, nicht
sein Umfeld),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1 (die vier erlaubten Handgriffe am tool-generierten Fragment — der Kopfkommentar ist
Handgriff 3),
[`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript)
(`make regelwerk-check` fährt `--enable sources`, was die Abgrenzungs-Zeile heute übergeht),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (was der
Kopf über die aktiven Gates sagt, muss auf frischem Checkout stimmen).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Die drei Aussagen im Kopf von [`d-check.mk`](../../../../d-check.mk), die heute etwas anderes
sagen als der Baum darunter, sagen dasselbe — und die Zahlen darin messen den Kopf, nicht den
Baum, der um ihn herum wächst.**

### Warum das ein eigener Schnitt ist und kein Rest von [slice-122](../done/slice-122-d-check-pin-v0650.md)

Eine der drei Aussagen kann **erst nachziehen, wenn ein fremdes Artefakt existiert**: der
Rang-Zeiger in Zeile 2 nennt die Adaptions-Einträge, die den jeweiligen Sprung tragen, und für
`v0.65.0` gibt es noch keinen. Der Eintrag ist Architect-Eigentum
([`AGENTS.md`](../../../../AGENTS.md) §3.8), die Zeile nicht — das ist eine echte
Reihenfolge-Abhängigkeit, keine Auslassung. Sie an
[slice-122](../done/slice-122-d-check-pin-v0650.md) zu hängen hieße, einen fertigen Pin auf
einen fremden Lauf warten zu lassen; sie nur in dessen Closure-Notiz zu nennen hieße, sie in einem
Zeitdokument abzulegen, das kein Lauf wieder aufschlägt.

### Die drei Aussagen, jede mit dem Kommando, das ihren Ist-Stand zeigt

1. **Der Rang-Zeiger nennt keinen Eintrag, der den heutigen Sprung trägt.**
   `sed -n '2p' d-check.mk` → `# (v0.65.0) und adaptiert (MR-010/MR-011/MR-012/MR-024):` <!-- d-check:ignore (zitierte Ausgabe, kein Verweis) -->.
   Die aufgezählten Einträge tragen je einen **anderen** Sprung —
   `grep -n '^### MR-024' harness/conventions.md` <!-- d-check:ignore (zitiertes Kommando, kein Verweis) --> →
   `### MR-024 — d-check-Pin v0.62.0 (structure verfügbar)` <!-- d-check:ignore (zitierte Ausgabe, kein Verweis) -->. Der Zeiger zeigt damit auf
   die Begründung des Vorgängers, während die Zeile darüber `v0.65.0` sagt.
2. **Drei Zahl-Stellen im Kopf, und der Fehler sitzt im Kommando, nicht im Zählen.**
   **(a) Zeile 29.** `sed -n '29p' d-check.mk` → *„mit entwerteten Markern melden BEIDE Versionen
   `432 Datei(en), 26 Befund(e)`, identisch."* Die Zeile trägt kein Kommando
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 1), und **beide** Zahlen wandern. Gegenmessung, zweimal gefahren — Kopie außerhalb des
   Repos aus `git archive <ref>`, alle Marker in getracktem Markdown außerhalb der vendored
   Baseline entwertet, dann der gepinnte Digest netzlos mit `:ro`: über `be6348c` (140
   Marker-Dateien) `434 Datei(en) geprüft, 26 Befund(e)`, über `aa32e1f` (142)
   `435 Datei(en) geprüft, 37 Befund(e)`; Kontrolle über dieselbe Kopie **ohne** Entwertung
   `435 Datei(en) geprüft, 0 Befund(e)`. Die **432** lag schon über `be6348c` um zwei daneben, und
   die **26** misst **nicht** den Gegenstand, sondern die Zahl der Marker, die gerade tragen — sie
   wächst mit jedem neuen Marker so, wie die Dateizahl mit jeder neuen Datei wächst
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2, „die Dateizahl eines Gate-Laufs").
   **(b) Zeile 25** sagt *„71 der 242 Marker-Zeilen"*. Über `be6348c`, dem Baum, für den die Zeile
   geschrieben wurde, sind es **75 von 249**:
   `git grep -n 'd-check:ignore' be6348c -- '*.md' ':!.harness/baseline' | wc -l` → **249**,
   derselbe Strom nach `grep -c '<!--[^>]*d-check:ignore'` → **174**. Dieselben zwei Kommandos mit
   `aa32e1f` statt `be6348c` → **268** und **184**, also **84 von 268**.
   **(c) Zeile 26–28** führt das Kommando mit, das die Zahlen aus (b) liefern soll — und genau
   dieses Kommando ist der Grund, warum sie falsch sind: sein `grep -v '.harness/baseline'`
   schneidet **inhaltlich** statt über den Pfad. Wie viel es zu viel verwirft, sagt
   `git grep -n 'd-check:ignore' aa32e1f -- '*.md' ':!.harness/baseline' | grep -c 'harness/baseline'`
   → **12** Zeilen (über `be6348c`: **7**), die den Pfad *erwähnen*, statt in ihm zu liegen; nach
   Datei (`… | grep 'harness/baseline' | cut -d: -f2 | sort | uniq -c`) zwei in
   [`harness/conventions.md`](../../../../harness/conventions.md), drei in `docs/reviews/` und fünf
   in `docs/plan/planning/`, davon zwei in diesem Plan.
   **Die Klasse ist größer als die drei Stellen:** eine Zahl neben ihrem Kommando ist erst belegt,
   wenn das **Kommando** stimmt. (b) trägt eines, reproduziert damit — und ist trotzdem falsch.
3. **Zwei Abgrenzungen sagen weniger, als der Baum tut.** (a) Zeile 11 sagt, `sources` sei
   *„NICHT aktiviert"* — das gilt für `make gates`, nicht für das Repo:
   `grep -n 'enable sources' Makefile` → **1** Treffer (`Makefile:170`, das Rezept von
   `make regelwerk-check`,
   [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript)).
   (b) Zeile 30–31 beschreibt die Neu-Erzeugung mit **zwei** der vier Handgriffe aus
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   Setzung 1 (Rename, Digest) und lässt Kopfkommentar und `doc-help`-Grep aus — obwohl der
   Ist-Stand vier sind: frisches Fragment gegen das gelebte,
   `docker run --rm --network none <v0.65.0-digest> --print-mk > /tmp/frisch.mk` und
   `diff /tmp/frisch.mk d-check.mk | grep -c '^[0-9]'` → **4** Hunks.

### Was dieser Slice nicht ist

**Keine Neu-Adaption des Fragments.** Die vier Handgriffe sind ausgeführt und gemessen (§1
Aussage 3b); dieser Slice bewegt keinen Pin, keine Modul-Liste und kein Rezept. Er berührt
ausschließlich den Kommentarblock, den
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1 als Handgriff 3 ausdrücklich erlaubt.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Der Rang-Zeiger nennt den Eintrag, der den gelebten Pin trägt.** Zeile 2 führt neben
      den Vorgänger-Einträgen den Adaptions-Eintrag zum `v0.65.0`-Sprung.
      **Rot:** `sed -n '2p' d-check.mk` nennt eine Version, zu der
      `grep -c '^### MR-... — d-check-Pin v0\.65\.0' harness/conventions.md` **0** liefert — dann
      zeigt der Zeiger wieder auf eine fremde Begründung. Der Punkt ist **erst prüfbar**, wenn der
      Eintrag existiert (§4).
- [x] **(2) Jede Zahl im Kopf misst den Kopf, und das Kommando daneben liefert genau sie.** Für
      **jede** der drei Zahl-Stellen — Zeile 25, Zeile 26–28, Zeile 29 — gilt eines: gestrichen, an
      einen benannten Baum-Stand gebunden, oder durch ein Kriterium ersetzt, das den Gegenstand
      misst. Wo ein Kommando danebensteht, schneidet es über den Pfad statt über den Inhalt.
      **Rot:** eine Zahl im Kopf, die ein Lauf widerlegt, ohne dass am Gegenstand etwas bricht —
      über `aa32e1f` dreifach reproduzierbar: **432/26** gegen gemessene **435/37**, **71 von 242**
      gegen **84 von 268**, und ein `grep -v`, das **12** Zeilen wegen ihres Textes statt wegen
      ihres Pfades verwirft
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 1 und 2).
- [x] **(3) Die zwei Abgrenzungen sagen, was gilt.** Die `sources`-Zeile nennt den Lauf, der das
      Modul fährt; die Neu-Erzeugungs-Zeile nennt alle vier Handgriffe oder zeigt auf die Stelle,
      die sie abzählt.
      **Rot:** `grep -n 'enable sources' Makefile` liefert einen Treffer, während der Kopf
      *„NICHT aktiviert"* ohne Einschränkung behauptet; oder
      `diff <(docker run --rm --network none <digest> --print-mk) d-check.mk | grep -c '^[0-9]'`
      liefert **4**, während der Kopf zwei Handgriffe aufzählt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) Zeilen 1–31 | update | der Kommentarblock, und nur er — Handgriff 3 aus [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der Eintrag zum `v0.65.0`-Sprung ist die **Vorbedingung** dieses Slice, nicht sein Ergebnis |
| [`internal/emit/`](../../../../internal/emit/) | **unverändert** | der emittierte Pfad adaptiert die Live-Ausgabe; er trägt diesen Kopf nicht |
| `.d-check.yml`, `Makefile` | **unverändert** | kein Modul, kein Ziel, kein Pin bewegt sich |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): der Adaptions-Eintrag zum `v0.65.0`-Sprung existiert,
und das WIP-Limit ist frei.** Beobachtbar ohne Rückfrage:
`grep -c 'd-check-Pin v0\.65\.0' harness/conventions.md` steht über **0**. Bis dahin ist DoD (1)
nicht herstellbar; DoD (2) und (3) wären es, aber sie einzeln zu ziehen hieße, denselben
Kommentarblock zweimal anzufassen und den Rang-Zeiger ein zweites Mal zu vergessen.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: die Kopf-Bereinigung deckt auf, dass eine der Aussagen keine
  Kommentar-Frage ist, sondern ein Verhalten — etwa dass `make regelwerk-check` sein Modul anders
  fährt als der Kopf beschreibt. Dann ist die Korrektur eine Sache und das Verhalten eine zweite.
- `in-progress` → `open`: der Adaptions-Eintrag existiert, nennt aber eine andere Version als der
  gelebte Pin. Dann blockiert der Slice an einer fremden Rolle und geht zurück, statt den Eintrag
  nebenbei mitzunehmen.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7
mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Kopf ist der billigste Ort, an dem eine Aussage veraltet, und der teuerste, an dem sie
  gelesen wird.** Er steht in jedem Lauf im Kontext, der `d-check.mk` aufschlägt, und kein Modul
  der aktiven Sechs liest ihn. Der Handlauf sind die Kommandos in §1 — mehr trägt diesen Slice
  nicht.
- **Ein Wächter entsteht hier nicht, und das ist eine Entscheidung.** Ob die Klasse *„eine Zahl im
  Text ohne ihr Kommando"* je einen Sensor bekommt, ist die fällige Entscheidung an
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Auflösungs-Trigger und gehört dem Architect. Dieser Slice räumt drei Instanzen ab; er
  entscheidet die Klasse nicht.
- **Der Rang-Zeiger kann falsch bleiben, wenn der Architect-Lauf den Eintrag anders schneidet** —
  etwa als Ergänzung an
  [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
  statt als neuen Eintrag. Dann trägt DoD (1) trotzdem: der Zeiger nennt den Eintrag, der den
  Sprung **trägt**, nicht einen mit einer bestimmten Nummer.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-28.
**Gegenstand:** HEAD `07a1de9`, sechs Commits: `08cdaae`/`29e9aed` (Lifecycle-Moves, je 0 Zeilen),
`05964ad` (Link-Abgleich), `1edbae4` (der Kommentarblock), `f058888`/`9f17b36` (Review und
Verifikation, je ein Bericht), `07a1de9` (die Fix-Runde).

Jede Zahl unten ist in diesem Lauf erhoben; die Zahlen aus Umsetzung, Review und Verifikation
waren **Eingabe, kein Beleg**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1).

### DoD-Stand — drei Punkte, jeder mit dem Kommando, das ihn hier trug

**(1) Der Rang-Zeiger nennt den Eintrag, der den gelebten Pin trägt — ERFÜLLT.** Das Rot-Kommando
des Punktes verbatim gefahren: `sed -n '2p' d-check.mk` →
`# (v0.65.0) und adaptiert (MR-010/MR-011/MR-012/MR-024/MR-027):` <!-- d-check:ignore (zitierte Ausgabe, kein Verweis auf die Einträge) -->,
und `grep -c '^### MR-... — d-check-Pin v0\.65\.0' harness/conventions.md` → **1**. Die
Rot-Bedingung trifft nicht zu. Zusätzlich gefahren ist die Form, die die **Zusage** schneidet statt
der Existenz des Eintrags: `sed -n '2p' d-check.mk | grep -c 'MR-027'` → **1** <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) -->.
Der genannte Eintrag trägt den Sprung auch inhaltlich — sein Rumpf nennt
[`d-check.mk`](../../../../d-check.mk) samt Kopfkommentar an fünf Stellen
(`awk '/^### MR-027/,/^## Modus-Deklaration/' harness/conventions.md | grep -c 'd-check.mk'` → **5**) <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) -->.
**Die Grenze des Punktes steht unten** (Ausgänge, V-3): sein Rot-Kommando misst die **Existenz**
des Eintrags, während die Zusage den **Zeiger** betrifft.

**(2) Jede Zahl im Kopf misst den Kopf — ERFÜLLT.** Die drei benannten Zahl-Stellen sind fort und
durch keine neue ersetzt: `sed -n '1,51p' d-check.mk | grep -nE '(432|435|242|26 Befund|71 der|Datei\(en\))'`
ist **leer** (Exit 1). Was an ihre Stelle tritt, ist ein Kriterium, und **ich habe versucht, es zu
widerlegen, statt es zu übernehmen** — eigene Sonde, `git archive HEAD` in eine Kopie außerhalb des
Repos, der gepinnte Digest netzlos mit `:ro`, je ein eigener Lauf über einer unverlinkten Kennung
in vier Lagen:

| Lage der Sonden-Datei unter `docs/plan/` | Ausgabe unter `v0.65.0` |
|---|---|
| Kontrolle, Datei nicht vorhanden | `437 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| unverlinkte Kennung, **ohne** Marker | `438 … 1 Befund(e)` |
| dieselbe Zeile, Marker in echter HTML-Kommentar-Form | `438 … 0 Befund(e)` |
| dieselbe Zeile, **blanke Prosa** ohne Kommentar-Form | `438 … 1 Befund(e)`, **Exit 1** |
| dieselbe Zeile, Kommentar-Form in Inline-Code | `438 … 1 Befund(e)` |
| nach dem Aufräumen | `437 … 0 Befund(e)`, Exit 0 |

Die vierte Zeile ist das gesuchte Rot, und ich habe seine **Meldung** gelesen statt nur ihren
Exit: gemeldet wird Zeile 3 der Sonden-Datei mit der Klasse `id-unlinked` — der Befund entsteht an
der Kennung, über der die Sonde gebaut ist, nicht an einer Nebenwirkung. Damit ist
*„`make docs-check` fährt den gepinnten v0.65.0 und ist grün"* am Gegenstand falsifizierbar; die
dritte Zeile zeigt zugleich, dass die Unterdrückung in ihrer gültigen Form weiter greift. **Der
Kontrast zur gestrichenen Zahl ist der Punkt:** `432 Datei(en), 26 Befund(e)` schlug kein Lauf je
wieder auf, das Kriterium fährt in jedem `gates`-Lauf mit (`grep -n '^gates:' Makefile` → Zeile
**299**, `docs-check` als zweiter Prerequisite). Die ersetzte Zähl-Form summiert jetzt und
schneidet über den Pfad: `git grep -h 'd-check:ignore' -- '*.md' ':!.harness/baseline' | wc -l` →
**278**; dieselbe Zeile mit `git grep -c` liefert statt einer Summe **144** Zeilen der Form
`pfad:anzahl`.

**(3) Die zwei Abgrenzungen sagen, was gilt — ERFÜLLT.** Beide Rot-Kommandos verbatim gefahren.
`grep -n 'enable sources' Makefile` → **1** Treffer, `Makefile:170`, das Rezept von
`make regelwerk-check`; die Rot-Bedingung verlangt daneben, dass der Kopf *„NICHT aktiviert"* ohne
Einschränkung behauptet, und er tut es nicht mehr — er nennt den Lauf, seine Netz-Eigenschaft
(`sed -n '170p' Makefile | grep -c 'network none'` → **0**) und seine Abwesenheit aus
`make gates`. Für die Neu-Erzeugung habe ich die Zeile aus dem Kopf **so gefahren, wie sie dort
steht** — nach der Fix-Runde ist das die Probe auf die eigene Lehre dieses Slice:
`diff <(docker run --rm --network none ghcr.io/pt9912/d-check@sha256:5ea03abe…41288 --print-mk) d-check.mk | grep -c '^[0-9]'`
→ **4**, Exit 0. Der Kopf zählt vier Handgriffe auf, nicht zwei.

### Was funktionierte, und was anders lief

**Der Entwurf war zu keinem Zeitpunkt strittig, und zwei fremde Rollen sagen es unabhängig.**
Review (Modul 10, N-1/N-2/N-4) und Verifikation (Modul 11, §4) haben die Kernentscheidung — die
drei wandernden Zahlen zu **streichen** statt zu korrigieren — je eigenständig geprüft und
getragen; die Sonde oben ist die dritte Messung derselben Eigenschaft. Sämtliche Befunde lagen in
der **Ausführung einzelner Sätze**.

**Anders lief, dass die Ausführung genau den Fehler machte, gegen den der Slice geschnitten war.**
Drei Kommandos im neuen Kopf schnitten ihren Gegenstand nicht — eines lief in einer Shell gar
nicht (`$(DCHECK_REF)` ist Make-Syntax und liefert wörtlich gefahren `1` bei Exit 0), eines zählte
je Datei statt zu summieren, eines zählte Hunks statt Handgriffe —, und sie standen **in den
Zeilen, die diese Regel formulieren**. Gefunden hat sie nicht der schreibende Lauf, sondern zwei
getrennte Kontexte: Review MEDIUM-2/MEDIUM-3/LOW-1 und Verifikation V-4, unabhängig und mit
demselben Ergebnis am selben Kommando.

**Eine Rückführung nach §4 wurde nicht ausgelöst**, und beide Bedingungen sind gemessen: das
`regelwerk-check`-Rezept fährt `--enable sources` netzgebunden außerhalb von `make gates` — genau
was der Kopf sagt —, und der Adaptions-Eintrag nennt dieselbe Version wie der lebende Pin.

### Steering-Loop-Eintrag — **benannte Spec-Lücke**, und der Träger ist ein bestehender Plan

**Die Klasse.** *Ein Kommando steht neben einer Aussage und schneidet ihren Gegenstand nicht* —
weil es nicht läuft, weil es eine andere Menge zählt, oder weil es eine andere Eigenschaft misst
als die, die daneben zugesagt ist. **Fünf Stellen an einem Tag, aufgezählt statt gemustert**
(die Zugehörigkeit ist ein Urteil, kein Muster — **Untergrenze mit Absicht**): in diesem Slice
`MEDIUM-2`/`V-4` (Make-Syntax in der Shell), `MEDIUM-3` (`git grep -c` zählt je Datei), `LOW-1`
(das Kommando zählt Hunks, nicht Handgriffe) und `V-3` (das Rot-Kommando zu DoD (1) misst die
Existenz eines Eintrags, während die Zusage den Zeiger betrifft); dazu am selben Tag
[slice-122](../done/slice-122-d-check-pin-v0650.md) Verifikation `V-1` (*„vier Handgriffe
schrumpfen auf einen"* misst die Tool-Ausgabe, nicht die Handgriffe). Vier Rollen-Durchgänge, zwei
Slices.

**Wo die Lücke wirklich liegt — nicht im Regeltext.**
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 spricht die Eigenschaft vollständig aus (*„ein ungefähr passendes Kommando
danebenzustellen ist der Fehler, nicht die Lücke"*), und
[`AGENTS.md`](../../../../AGENTS.md) §3.6 führt den **Doc-Kommentar** ausdrücklich als
Zusage-Träger. Der Regeltext deckt alle fünf Stellen. Was sie **nicht** deckt, ist der
Geltungsbereich: vier der fünf liegen in [`d-check.mk`](../../../../d-check.mk), und diese Datei
liegt außerhalb **beider** Prüfmengen —
`git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | grep -c 'd-check.mk'`
→ **0** (der Geltungsbereich jener Setzung, dort per Kommando definiert) und
`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | grep -c 'd-check.mk'`
→ **0** (der Prüfbereich von `make comment-claims`). Die fünfte Stelle, `V-3`, liegt
**innerhalb** des Geltungsbereichs — ein Slice-Plan in `in-progress/` ist ein lebendes
Markdown-Artefakt. Die Lücke ist damit eine **Naht**, keine fehlende Regel: an einem Artefakt, das
eine Architect-eigene Adaption ausdrücklich als ihren Geltungsbereich führt
([`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
§Geltungsbereich nennt den Kopfkommentar), gilt die Zahl-Beleg-Setzung nach ihrem eigenen Kommando
nicht.

**Warum hier kein Wächter entsteht, und diesmal ist die Absage gemessen.** Der einzige mechanisch
trennscharfe Kandidat für die schärfste Unterform — *eine Make-Variable in einem Kommando, das in
einer Shell gefahren werden soll* — trifft
`git grep -nE '^[[:space:]]*#.*\$\([A-Z_]+\)' -- '*Makefile' '*.mk' ':!.harness/baseline'` → **3**
Zeilen, und **keine** davon ist eine Instanz: zwei sind Prosa über einen Pfad bzw. einen Aufruf,
die dritte ist die Zeile, die den Fehler **benennt**. Dasselbe für die Zähl-Unterform:
`git grep -nE '^[[:space:]]*(#|//).*git grep -c' -- '*.go' '*.sh' '*Makefile' '*.mk' ':!.harness/baseline'`
→ **1** Zeile, und das ist das Gegenbeispiel im Kopf selbst. **Beide Muster trennen die Klasse
nicht**; ein Wächter dieser Bauart stünde auf dem Artefakt rot, das die Regel aufschreibt — das
stille Grün aus
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) mit
umgekehrtem Vorzeichen. Die Fläche, mit ihrer Eigenschaft vor der Zahl — *eine Kommentarzeile in
einer repo-eigenen Nicht-Markdown-Datei, die ein Kommando führt* — ist eine **Obergrenze** und
**kein Erwartungswert**: **214** Zeilen über **73** Dateien, ausgegeben von
`git grep -cE '^[[:space:]]*(#|//).*(git (grep|ls-files|show|log|diff)|grep -|docker run|make [a-z-]+|wc -l)' -- '*.go' '*.sh' '*.awk' '*Makefile' '*.mk' 'Dockerfile' ':!internal/emit/templates' ':!.harness/baseline' | awk -F: '{s+=$2} END{print "Zeilen="s" Dateien="NR}'`.

**Warum hier auch kein vierter Slice steht.** Drei benachbarte Schnitte decken je eine andere
Achse und **keiner** diese: [slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md)
prüft die Auflösbarkeit eines Hex-Tokens in einer Commit-Message,
[slice-126](../open/slice-126-commit-message-traegt-eine-kennung.md) die Anwesenheit einer
Kennung, [slice-070](../open/slice-070-comment-claims-pruefbereich.md) den **Prüfbereich** von
`make comment-claims` — welche Dateien gelesen werden, nicht ob ein genanntes Kommando läuft. Ein
vierter Schnitt daneben wäre eine zweite Fassung derselben Frage, die driftet, und er lieferte
nach der Messung oben einen dauerhaft grünen Wächter. **Was fehlt, ist keine Regel und kein
Sensor, sondern eine Entscheidung über einen Geltungsbereich — und die gehört dem Architect**
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

**Der Träger, und er ist nicht diese Notiz.**
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) existiert genau dafür: jeder
Posten an ein Norm-Artefakt bekommt einen Ausgang. Er trägt die Frage seit diesem Lauf als
**zwölften Posten** mit eigener Achse — *Geltungsbereich* statt Setzung —, samt der Messung, die
die Sensor-Frage entscheidet. Der Eintrag steht damit dort, wo ihn der nächste Lauf aufschlägt,
statt in einem Zeitdokument.

### Ausgänge — jeder offene Posten hat einen, *„genannt"* ist keiner

| Posten | Herkunft | Ausgang |
|---|---|---|
| Prosa über abwesenden Text plus Slice-Verweis im neuen Kopf | Review HIGH-1, Verifikation V-2 | **erledigt** in `07a1de9`, hier nachgemessen: `grep -c 'schon am Tag ihrer Niederschrift' d-check.mk` → **0** und `grep -cE '^#.*slice-[0-9]{3}' d-check.mk` → **0** |
| Das Kommando neben `VIER` lief nicht (`$(DCHECK_REF)`) | Review MEDIUM-2, Verifikation V-4 | **erledigt** — der Digest steht literal; die Zeile wörtlich gefahren liefert **4** (DoD (3) oben) |
| `git grep -c` als Zähl-Form | Review MEDIUM-3 | **erledigt** — die summierende Form steht im Kopf und liefert **278**, beide Fehlformen daneben als Gegenbeispiel (DoD (2) oben) |
| Der Trage-Beleg war eine Null gegen eine Null | Review MEDIUM-1 | **erledigt** — ersetzt durch das Falsifikat, in dieser Closure unabhängig neu erzeugt (Sonden-Tabelle oben) |
| *„die advisory-Targets bleiben verbatim"* ohne Einschränkung | Verifikation V-1 | **erledigt** — `grep -c 'SONST verbatim' d-check.mk` → **1**, das Wort aus [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1 |
| Handgriff 3 beschrieb seinen Hunk als Umbenennung | Review LOW-1 | **erledigt** — die Aufzählung nennt jetzt `.PHONY`-Zeile, Target-Zeile und den erweiterten Hilfetext |
| Das Rot-Kommando zu DoD (1) deckt seine Zusage nicht | Verifikation V-3 | **erledigt ohne Retro-Änderung** — die deckende Form ist oben gefahren; §2 bleibt unangetastet, weil der Verifier gegen **diesen** Text gemessen hat und ein nachträglich korrigierter Sensor seinen Befund unlesbar machte. Die Stelle zählt als fünfte Instanz zum Steering-Loop-Eintrag |
| Die `sources`-Abgrenzung nennt [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript) nicht | Review LOW-2 | **abgelehnt, mit gemessenem Grund** — der Kopf zitiert genau die Einträge seines Rang-Zeigers: `sed -n '3,51p' d-check.mk \| grep -oE 'MR-[0-9]{3}' \| sort -u` führt **einen** Namen, und der steht in Zeile 2 <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf einen Eintrag) -->. Jener Eintrag nennt [`d-check.mk`](../../../../d-check.mk) in seinem §Geltungsbereich **nicht** (`awk '/^### MR-013/,/^### MR-014/' harness/conventions.md \| grep -c 'd-check.mk'` → **0**) <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf die Einträge) -->. Der **Grund** geht dem Leser nicht verloren: Netz-Eigenschaft und Abwesenheit aus `make gates` nennt der Kopf selbst |
| *„sechs … FUENF"* ohne Kommando | Review LOW-3, Verifikation V-5 | **Architect-Übergabe** unten — beide Zahlen wandern mit dem **Tool**, nicht mit dem Repo; ihr Ort ist der Auflösungs-Trigger, der den Re-Pin-Abgleich verlangt, und der nennt sie heute nicht |
| *„18./19./20."* aus dem Repo nicht nachprüfbar | Verifikation V-5 | **Architect-Übergabe** unten, dieselbe Klasse: eine Fremdquellen-Zahl, deren Herkunft im Kopf nicht steht |
| Die Existenz-Hälfte *„es gibt sie"* hat im Kopf keinen Sensor | Verifikation V-6 | **abgelehnt, mit Grund** — ihr Beleg ist eine wandernde Zahl (heute **94** von **278**: die Summe oben, davon `… \| grep -c '<!--[^>]*d-check:ignore'` → **184** in Kommentar-Form), und genau solche hat DoD (2) aus dem Kopf entfernt. Sie lebt in [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt), auf den Zeile 2 zeigt |
| Das Beleg-Kommando einer Commit-Message liefert am Nach-Baum `2` statt `1` | Review INFO-1 | **bestehender Posten** — [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) führt die Klasse *„ein Kommando, dessen Prüfbereich den Text enthält, der es zitiert"* bereits; dieser Lauf ist eine weitere Instanz und braucht keinen Schnitt |
| Tag und Digest hält nichts aneinander | Review INFO-2 | **Architect-Übergabe** unten — gemessen: kein Test hält die zwei Zeichenketten gegeneinander, und das gelieferte Modul dafür ist nicht adoptiert |
| Die Sonden-Beschreibung nennt einen der zwei Gegenstände | Review INFO-3 | **teilweise erledigt** in `07a1de9` (`grep -c 'unverlinkter Kennung' d-check.mk` → **1**); der Rest liegt in Zeilen, die dieser Slice nicht angefasst hat — [`AGENTS.md`](../../../../AGENTS.md) §3.7 Cutoff, kein Arbeitsauftrag |
| `citations` hat nirgends einen Lauf, der Satz sagt es nicht | Review INFO-4 | **abgelehnt, mit Grund** — der Satz definiert *„nicht aktiviert"* und zählt die Läufe auf, die es gibt; er sagt für kein Modul einen Lauf zu. Die Entscheidung selbst trägt [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines) |
| Die Zahl-Beleg-Setzung wird auf ein Artefakt außerhalb ihres Geltungsbereichs angewendet | Review INFO-5 | **zwölfter Posten in [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md)** — der Steering-Loop-Eintrag oben |

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8 — drei Posten, keiner hier geschrieben)

1. **Der Geltungsbereich der Zahl-Beleg-Setzung endet an einem Artefakt, das eine Adaption
   ausdrücklich führt.** Vier der fünf heutigen Instanzen liegen in
   [`d-check.mk`](../../../../d-check.mk); die Setzung misst ihren Geltungsbereich per Kommando
   und schließt die Datei aus (**0**, oben gefahren), während
   [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
   denselben Kopfkommentar an **5** Stellen führt. Ob daraus eine Weitung des Geltungsbereichs
   folgt, ein Zeiger aus [`AGENTS.md`](../../../../AGENTS.md) §3.6 heraus oder eine bewusst
   gezogene Grenze, ist eine Entscheidung am Text. **Die Sensor-Vorfrage ist hier beantwortet**
   (zwei Muster, **3** bzw. **1** Treffer, **0** Instanzen); der Termin liegt bei
   [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md).
2. **Der Auflösungs-Trigger des Fragment-Eintrags nennt zwei Zahlen im Kopf nicht.**
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   Setzung 2 bindet an den Re-Pin die **Target-Aufzählung**; die Kopf-Zeile *„von den sechs
   fokussierten advisory-Recipes disablen FUENF alle drei"* misst dieselbe Tool-Ausgabe und wandert
   mit ihr, steht aber in keinem Trigger. Heute stimmt sie:
   `grep -cE '^\t.*--enable' d-check.mk` → **6**, davon
   `grep -E '^\t.*--enable' d-check.mk | grep -c -- '--disable citations.*--disable sources.*--disable structure'`
   → **5**. Dieselbe Frage betrifft die Modul-Ordinalzahlen *„18./19./20."*, deren Quelle das
   CHANGELOG des Werkzeugs ist und die aus diesem Repo nicht nachprüfbar sind — die Setzung
   verlangt für Fremdquellen-Zahlen, dass **das** danebensteht.
3. **Tag und Digest des Pins hält nichts aneinander, und der Wächter dafür ist netzlos nicht
   baubar.**
   `git grep -ln 'DCHECK_DIGEST\|DCHECK_IMAGE\|DefaultDigest\|DefaultImage' -- 'test/**' 'internal/**' 'harness/**' '.github/**'`
   nennt [`harness/conventions.md`](../../../../harness/conventions.md), zwei Dateien unter
   `internal/emit/` und deren Fixture; die zwei Kopplungstests binden je **eine** Zeichenkette an
   ihre kanonische Quelle in [`d-check.mk`](../../../../d-check.mk) — keiner hält Tag gegen
   Digest. Ein Auflösen des Tags braucht die Registry; netzlos ist die Aussage nicht herstellbar.
   Das gelieferte Modul mit genau diesem Vertrag ist `versions` und nicht adoptiert
   (`grep -c 'versions' .d-check.yml` → **0**, Exit 1) — dieselbe Feststellung, die
   [`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
   für eine Versions-Nennung **in Prosa** trägt, hier für zwei Pin-Zeilen **derselben Datei**. Ein
   Muster dafür gibt es im Repo:
   [`MR-013`](../../../../harness/conventions.md#mr-013--regelwerk-check-auf-d-check-sources-tool-statt-skript)
   koppelt zwei Fassungen eines Hashes fail-closed in `make gates`.

**Was diese Übergabe nicht ist.** Kein Formulierungsvorschlag für einen Norm-Text — die Messungen
sind das Übergabe-Artefakt, der Regeltext entsteht im Architect-Lauf
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

### Verifikation dieser Closure

`make gates` grün über dem Arbeitsbaum dieser Closure (Ausgabe im Closure-Commit).
`make mutate` **nicht** in diesem Lauf gefahren (Auflage): das vorliegende Protokoll lief über
`1edbae4` mit **198 ok, 0 Befund(e)**, `MUTATE_SECONDS=748.31`, und seither bewegt kein Commit
dieses Slice eine Code-Datei — `git diff --name-only 1edbae4..HEAD` führt
[`d-check.mk`](../../../../d-check.mk) (Kommentarblock) und zwei Berichte unter `docs/reviews/`.
**Ein zweiter Review-Durchgang nach Modul 10 hat nicht stattgefunden**; was den blockierenden
HIGH-1 schließt, ist `07a1de9` **plus** die zwei Nachmessungen in der ersten Zeile der
Ausgänge-Tabelle. Das ist die Grenze dieser Closure, und sie steht hier, weil sie sonst nirgends
stünde.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Das
Gate-Fragment ist konventionell dicht bis zur Vorschrift — es ist tool-generiert, und die vier
erlaubten Handgriffe stehen abgezählt in
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1; dieser Slice bleibt in Handgriff 3.
