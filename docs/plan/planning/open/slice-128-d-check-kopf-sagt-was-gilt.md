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

### Warum das ein eigener Schnitt ist und kein Rest von [slice-122](../in-progress/slice-122-d-check-pin-v0650.md)

Eine der drei Aussagen kann **erst nachziehen, wenn ein fremdes Artefakt existiert**: der
Rang-Zeiger in Zeile 2 nennt die Adaptions-Einträge, die den jeweiligen Sprung tragen, und für
`v0.65.0` gibt es noch keinen. Der Eintrag ist Architect-Eigentum
([`AGENTS.md`](../../../../AGENTS.md) §3.8), die Zeile nicht — das ist eine echte
Reihenfolge-Abhängigkeit, keine Auslassung. Sie an
[slice-122](../in-progress/slice-122-d-check-pin-v0650.md) zu hängen hieße, einen fertigen Pin auf
einen fremden Lauf warten zu lassen; sie nur in dessen Closure-Notiz zu nennen hieße, sie in einem
Zeitdokument abzulegen, das kein Lauf wieder aufschlägt.

### Die drei Aussagen, jede mit dem Kommando, das ihren Ist-Stand zeigt

1. **Der Rang-Zeiger nennt keinen Eintrag, der den heutigen Sprung trägt.**
   `sed -n '2p' d-check.mk` → `# (v0.65.0) und adaptiert (MR-010/MR-011/MR-012/MR-024):` <!-- d-check:ignore (zitierte Ausgabe, kein Verweis) -->.
   Die aufgezählten Einträge tragen je einen **anderen** Sprung —
   `grep -n '^### MR-024' harness/conventions.md` <!-- d-check:ignore (zitiertes Kommando, kein Verweis) --> →
   `### MR-024 — d-check-Pin v0.62.0 (structure verfügbar)` <!-- d-check:ignore (zitierte Ausgabe, kein Verweis) -->. Der Zeiger zeigt damit auf
   die Begründung des Vorgängers, während die Zeile darüber `v0.65.0` sagt.
2. **Die Dateizahl im Kopf ist eine mitwandernde Zahl und steht als Erwartungswert da.**
   `sed -n '29p' d-check.mk` → *„mit entwerteten Markern melden BEIDE Versionen
   `432 Datei(en), 26 Befund(e)`, identisch."* Über dem Baum, der diese Zeile einführt
   (`be6348c`), sind es **434**: Kopie außerhalb des Repos aus `git archive be6348c`, alle Marker
   in getracktem Markdown außerhalb der vendored Baseline entwertet, dann beide Digests netzlos
   mit `:ro` — beide melden `434 Datei(en) geprüft, 26 Befund(e)`, `diff` der sortierten Ausgaben
   leer. Die Zahl steigt seither weiter; sie ist hier **Befund, nicht Erwartungswert**. Die **26** misst
   den Gegenstand (die Marker-Menge trägt, und beide Versionen sehen dieselbe), die **432** misst
   den Baum ringsum und wächst mit jeder neuen Datei —
   [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2 nennt genau diesen Fall („die Dateizahl eines Gate-Laufs").
   **Dieselbe Zeile trägt kein Kommando** (Setzung 1); die zwei Zahlen der Zeilen 25–28 tragen
   eines, und es reproduziert **über dem Baum, für den es geschrieben wurde** —
   `grep -rn 'd-check:ignore' --include='*.md' . | grep -v '.harness/baseline'` nach `wc -l` →
   **242**, derselbe Strom nach `grep -c '<!--[^>]*d-check:ignore'` → **171**, Differenz **71** wie
   im Kopf behauptet (gemessen über `be6348c`; auch diese zwei wachsen mit jedem Dokument, das den
   Marker erwähnt). Sein `grep -v` schneidet zudem **inhaltlich** statt über den Pfad:
   `git grep -n 'd-check:ignore' be6348c -- '*.md' ':!.harness/baseline' | grep -c 'harness/baseline'`
   → **7** Zeilen fallen heraus, weil sie den Pfad *erwähnen*, nicht weil sie in ihm liegen; nach
   Datei (`… | cut -d: -f2 | sort | uniq -c`) sind es **3** in `docs/plan/planning/done/`, **3** in
   `docs/reviews/` und **1** im Slice-Plan zum Pin selbst.
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

- [ ] **(1) Der Rang-Zeiger nennt den Eintrag, der den gelebten Pin trägt.** Zeile 2 führt neben
      den Vorgänger-Einträgen den Adaptions-Eintrag zum `v0.65.0`-Sprung.
      **Rot:** `sed -n '2p' d-check.mk` nennt eine Version, zu der
      `grep -c '^### MR-... — d-check-Pin v0\.65\.0' harness/conventions.md` **0** liefert — dann
      zeigt der Zeiger wieder auf eine fremde Begründung. Der Punkt ist **erst prüfbar**, wenn der
      Eintrag existiert (§4).
- [ ] **(2) Jede Zahl im Kopf misst den Kopf, und ihr Kommando steht daneben.** Die Dateizahl aus
      Zeile 29 ist entweder gestrichen, ausdrücklich als **kein** Erwartungswert gekennzeichnet
      oder durch ein Kriterium ersetzt, das den Gegenstand misst; die Befundzahl **26** behält ihr
      Kommando, und das `grep -v` der Zeilen 25–28 schneidet über den Pfad statt über den Inhalt.
      **Rot:** eine Zahl im Kopf, die ein Lauf über einem gewachsenen Baum widerlegt, ohne dass am
      Gegenstand etwas bricht — heute reproduzierbar als **432** gegen gemessene **434**
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).
- [ ] **(3) Die zwei Abgrenzungen sagen, was gilt.** Die `sources`-Zeile nennt den Lauf, der das
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

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Das
Gate-Fragment ist konventionell dicht bis zur Vorschrift — es ist tool-generiert, und die vier
erlaubten Handgriffe stehen abgezählt in
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1; dieser Slice bleibt in Handgriff 3.
