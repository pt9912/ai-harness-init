# Slice slice-082: Adaptions-Durchgang — jeder Eintrag bekommt seinen Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](../welle-10-re-baseline.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die Aussage,
die der Durchgang prüft), [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
[`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline),
[`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md),
[ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) (die Prozedur, nach der dieser
Durchgang läuft, und die Grenze, dass sie keinen einzelnen Eintrag vorentscheidet).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

**Jeder** Eintrag des Adaptions-Blocks ist **einzeln** geprüft
([ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md): *„einzeln, mit eigenem
Beleg"*) und trägt zwei Antworten, jede mit Beleg. Die Prozedur stellt zwei Fragen, und sie
liegen auf verschiedenen Achsen. **Wie viele Einträge das sind, sagt ein Kommando, keine Zahl in
diesem Plan** — die Menge wandert mit jedem neuen Eintrag und ist kein Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): `grep -c '^### MR-' harness/conventions.md` → am 2026-08-27 **27**.

**Achse 1 — die Bewegung der Baseline.** Die Frage stellt die Prozedur selbst: *Regelt die neue
Fassung das, wofür diese Adaption angelegt wurde?* — ausdrücklich eine Frage an das **Delta der
neuen Fassung**, nicht an den Zustand der Baseline. Die Antwort ist genau einer der **fünf
Ausgänge**, wie Modul 2 der Ziel-Fassung (`v5.12.0`) sie benennt (§*Freshness-Audit der vendored
Baseline*, vierte Eigenschaft): **gegenstandslos** → Rückbau · **bleibt gültig** → stehen lassen
(Normalfall) · **teilweise überholt** → durch eine engere Nachfolgerin ablösen · **Bezug
entfallen** (die Baseline regelt das Thema gar nicht mehr) · **widerspricht** der neuen Fassung.

**Der fünfte Ausgang ist der einzige mit einer Wahl, und er hat zwei Zweige.** Die Ziel-Fassung
schreibt beide aus: *„Entweder die Adaption gilt in ihrem Geltungsbereich weiter — dann gehört der
Widerspruch benannt, sonst adoptiert das Repo eine Regel, die es nicht befolgt —, oder das Repo
**übernimmt** die neue Regel."* Übernehmen ist ein Rückbau wie bei *gegenstandslos*, aus dem
umgekehrten Grund: *„Bei gegenstandslos hat die Baseline dem Repo recht gegeben, hier gibt das
Repo der Baseline recht."* Der Unterschied gehört in die `Begründung` des Nachfolge-Eintrags, weil
er eine **Entscheidung** ist und kein Befund. **Der Durchgang darf ihn also nicht als Befund
verbuchen** — wer bei *widerspricht* nur „gilt weiter" notiert, hat eine Wahl übersprungen, keine
Messung abgeschlossen.

**Zwei Zweige innerhalb der fünf, kein sechster Ausgang.** Erstens die Abgrenzung `MR` ↔ Carveout:
will das Repo übernehmen, kann es aber noch nicht, ist das keine `MR` mehr — *„Eine Adaption sagt
‚diese Regel gilt hier nicht', ein Carveout sagt ‚sie gilt, wir erfüllen sie noch nicht'"*,
befristet, mit Auflösungs-Trigger und Folge-Slice (Modul 7). Zweitens: *„War die Adaption eine
Lockerung und die neue Baseline verschärft, ist die richtige Antwort ein Carveout mit
Auflösungs-Trigger (Modul 7), keine stille Dauer-`MR`."* Beide entscheiden nicht, **ob** die
Adaption weitergilt, sondern in welcher **Form** — befristet und mit abfragbarem Trigger statt als
Dauerzustand. Ein Eintrag, der einer Verschärfung standhalten soll, ohne das zu tragen, ist die
stille Dauer-`MR`, die der Satz meint.

**Achse 2 — der eigene Bedarf.** Ein Eintrag kann seinen Grund verlieren, ohne dass die Baseline
sich bewegt; auf Achse 1 käme er als *„bleibt gültig"* heraus — dem Normalfall — und stünde
weiter. Deshalb wird neben dem Ausgang der **Auflösungs-Trigger** jedes Eintrags abgefragt: ist
seine Bedingung eingetreten, und braucht das Repo den Eintrag noch? Brauchen wir ihn, übernehmen
wir ihn in den neuen Stand; brauchen wir ihn nicht, löst ihn ein Nachfolger auf.

**Die zwei Sätze, die den Slice tragen.** Für Achse 1: *„Der Review geht durch die
Adaptions-Liste, nicht nur durch den Diff."* Ein Diff zeigt, was sich geändert hat; er zeigt
nicht, welche unserer Setzungen dadurch ihren Gegenstand verliert. Für Achse 2: *„Ohne diesen
Durchgang bleibt eine präzise formulierte Auflösungs-Bedingung jahrelang stehen, obwohl sie
längst erfüllt ist: Ein Trigger, den niemand abfragt, ist kein Wächter."*

## 2. Definition of Done

- [ ] **Achse 1 — jeder** Eintrag trägt genau einen der fünf Ausgänge mit Beleg;
      Vollständigkeit als **Inventar gegen Abdeckung** (`grep -c '^### MR-' harness/conventions.md`
      ist der Nenner), nicht als Trefferliste. Fällt ein Eintrag auf **widerspricht**, steht am
      Beleg, **welcher der zwei Zweige** gewählt wurde — weiter gelten und benennen, oder
      übernehmen (§1). `permanent`-Einträge sind mitgeprüft: *permanent*
      heißt „kein automatischer Auflösungs-Trigger", nicht „unauflösbar". Wo die Adaption eine
      **Lockerung** war und die neue Fassung an derselben Stelle **verschärft**, ist die Antwort ein
      **Carveout mit Auflösungs-Trigger** (Modul 7), keine stille Dauer-`MR`.
      **Der Ausgang ist nicht alles, was ein Eintrag trägt.** Viele nennen daneben eine **Messung
      mit ihrem Kommando** — Geltungsbereich, Ist-Messung, Beleg —, und deren Operand ist oft der
      vendored Baum. Wechselt der Baum, kann der Ausgang *bleibt gültig* lauten, während die Zahl
      daneben falsch ist und ihr Kommando nicht mehr läuft: ein grüner Ausgang über einem falschen
      Beleg. Je Eintrag ist deshalb **beides** zu beantworten — der Ausgang **und**, ob seine
      Messungen gegen den gepinnten Stand noch reproduzieren. Diese Hälfte hat sonst keinen Träger:
      [slice-131](../next/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) schließt
      `harness/conventions.md` ausdrücklich aus, und
      [slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) behandelt nur die **Adresse** einer
      einzelnen Referenz. Kein Gate sieht sie: eine Messung in Inline-Code ist kein Link.
- [ ] **Achse 2 — jeder Auflösungs-Trigger ist abgefragt**, und die Antwort steht am Eintrag:
      Bedingung eingetreten oder nicht, Eintrag weiter gebraucht oder nicht — bei *gebraucht*
      übernommen, sonst durch einen Nachfolger aufgelöst. Nenner ist auch hier ein Kommando,
      nicht die Zahl: `grep -c '^- \*\*Auflösungs-Trigger' harness/conventions.md` → am 2026-08-27
      **26** gegen **27** Einträge; beide Zahlen **wandern** und sind keine Erwartungswerte
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). **Welche Einträge keinen Trigger führen, ist ebenfalls ein Kommando und keine
      Liste in diesem Plan** — die Menge wächst mit jeder Aufhebung:
      `awk '/^### MR-[0-9]/{if(id!=""&&!f)print id; id=$0; f=0} /Auflösungs-Trigger/{f=1} END{if(id!=""&&!f)print id}' harness/conventions.md`.
      Ein Eintrag darin ist kein Ausreißer: ein **aufgehobener** Eintrag hat keinen Trigger mehr,
      und Achse 1 trägt ihn allein. Der Durchgang notiert je Treffer, ob die Aufhebung der Grund
      ist — ein Treffer ohne Aufhebung und ohne Trigger ist der Befund dieser Achse.
- [ ] **Was der Durchgang schreibt, hat die Form der Ziel-Prozedur:** ein Rückbau ist ein **neuer
      Eintrag, kein Edit**, und nennt den Baseline-Stand, der den Trigger gefeuert hat. Welche
      Gestalt der aufgehobene Eintrag danach behält, hängt am Ausgang von
      [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
      — er ist selbst ein Fall dieses Durchgangs (§6). **Die Frage ist nicht mehr vorausschauend:
      die erste Teil-Ablösung ist bereits vollzogen** —
      [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) hat die Zensus-Aussage von
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
      durch einen Nachfolger abgelöst, und das Original trägt keinen Zeiger auf ihn. Ob es einen
      bekommt, ist hier zu entscheiden, und der Bestand gibt **zwei** Antworten statt einer:
      `grep -c 'HISTORIE — ' harness/conventions.md` → am 2026-08-29 **2** Einträge mit einer
      Kopf-Marke auf ihren Nachfolger, und
      `awk '/^### .* — Technik-Stratum als Rang 2/,/^### .* — Aufgehobener Eintrag/' harness/conventions.md | grep -c 'HISTORIE'`
      → **0** für den Eintrag, der ohne sie steht, obwohl eine Zahl in ihm überholt ist
      ([`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
      schreibt neben sie, statt sie zu markieren — dieselbe Präzedenz, auf die sich der
      Nachfolger von
      [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
      beruft).
      Beide Zahlen wandern mit dem Block
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). Der Durchgang entscheidet die Form **einmal** und wendet sie auf den Bestand an;
      eine dritte Präzedenz entsteht nicht. Am Ende trägt
      [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) den Stand, den der
      Durchgang ergibt, und die Re-Baseline-Zeile in §Baseline nennt diesen Slice als Ort des
      Normativ-Deltas — wie sie es für die vier vorigen Re-Baselines tut.
- [ ] `make gates` grün.
- [ ] Doku-Update: `AGENTS.md` und `harness/README.md`, soweit ein Ausgang sie berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update (**neue** Einträge) | die Ausgänge beider Achsen; Append-only-Disziplin wie bei ADRs. Ob ein aufgehobener Rumpf stehen bleibt, hängt am Ausgang von [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) (§6) |
| [`AGENTS.md`](../../../../AGENTS.md) | update | §3.7 zurückführen, sobald der Vorgriff fällt |
| `docs/plan/carveouts/` | neu (bedingt) | der Zweig *Lockerung trifft Verschärfung* landet dort, per `cp` aus `carveout.template.md` plus Index-Zeile — ein Carveout ist ein eigenes Artefakt mit eigenem Trigger, kein Absatz im Block |
| `docs/plan/planning/open/` | neu | ein Delta, das eigene Arbeit verlangt, wird Slice — nicht Fracht dieses Slice |

Die ersten zwei Zeilen sind **Architect-Artefakte** ([`AGENTS.md`](../../../../AGENTS.md) §3.8):
der Norm-Text entsteht im Architect-Lauf und in eigenem Commit. Was der Durchgang liefert, ist das
Übergabe-Artefakt — Ausgang und Beleg je Eintrag, auf beiden Achsen.

## 4. Trigger

[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/` — der neue Baum ist im Repo,
sonst misst der Durchgang gegen eine Fassung, die hier nicht liegt.

Rückführungen: `in-progress` → `next`, wenn mehr als zwei Einträge eigene Umsetzung verlangen
(dann ist der Durchgang eine Welle für sich). `in-progress` → `open`, wenn ein Ausgang eine
Architektur-Entscheidung braucht, die noch nicht getroffen ist.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- **Der Durchgang entscheidet, er setzt nicht um.** Wo eine echte Umsetzung nötig wird, entsteht
  ein Slice in `open/`. Wer beides hineinzieht, hat eine Welle im Slice — und verliert das
  Closure-Kriterium der Welle mit.
- **Vier Einträge sind schon sichtbar, ihr Ausgang aber nicht entschieden** — hier steht, was zu
  messen ist, nicht, wie es ausgeht:
  - [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
    **steht zuerst, weil er die Form der übrigen Ausgänge bestimmt.** Er lockert die
    Disziplin-Regel der vendored Vorlage — der Rumpf eines vollständig aufgehobenen Eintrags
    fällt, und das ist ein Edit am alten Eintrag —, und die Ziel-Fassung verschärft an genau
    dieser Stelle: *„Rückbau ist ein neuer Eintrag, kein Edit."*
    [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) nennt die Adaption in
    ihrer Alternativen-Tabelle *„eine Lockerung der Baseline-Disziplin"* — damit steht der Zweig
    aus §1 offen, und der Eintrag ist selbst ein Fall dieses Durchgangs, kein Werkzeug für ihn.
    [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) sagt dazu, was hier gilt:
    *„zu entscheiden, nicht zu übernehmen — Fortbestand, Carveout mit Auflösungs-Trigger oder ein
    anderer der fünf Ausgänge, mit Beleg"*. Fällt der Ausgang gegen
    [`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md), ist die Antwort eine
    **Folge-ADR mit `Supersedes`**, kein Edit — und dann greift die Rückführung
    `in-progress` → `open` aus §4.
  - [`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence):
    die Ziel-Fassung führt ein eigenes Spec-Modul und einen eigenen Grundlagen-Abschnitt zur
    Source Precedence — ob die Adaption damit **gegenstandslos** wird oder **bleibt gültig**,
    entscheidet der Text, nicht die Vermutung.
  - [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
    mit [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung):
    **die Vorab-Messung trägt bis zum Zielstand nicht, und das ist ein Posten dieses Durchgangs,
    keine Fußnote.**
    [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
    misst den ersten Zweig von
    [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
    gegen `v5.3.1` vorab; dorthin ist `templates/AGENTS.template.md` **nicht** byte-gleich
    (`git diff --shortstat v5.3.1 v5.12.0 -- lab/templates/AGENTS.template.md` → **1 Datei,
    +12/−6**, lokaler Kurs-Klon), und §3.7 wächst dort um einen Absatz (*„Zustandsfelder
    ebenso"*), während Nummer, Titel, die fünf Klassen und die zwei Falsch/Richtig-Paare
    unverändert stehen. **Ob der Zweig weiter zutrifft, misst dieser Durchgang gegen den
    Zielstand** — die Vorab-Messung wird nicht fortgeschrieben, sie wird ersetzt. Zwei weitere
    Stücke fehlen ihm — die **Textprüfung**, die
    [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
    ausdrücklich offen lässt (trägt der hiesige Wortlaut die Upstream-Semantik?), und die Form des
    Vollzugs, die am ersten Punkt dieser Liste hängt. **Der Nachtrag ist ein neuer Eintrag, kein
    Edit** an
    [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung) —
    und er entsteht im Architect-Lauf ([`AGENTS.md`](../../../../AGENTS.md) §3.8, §3 dieses Plans).
  - [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), deren
    **2-Strata**-Aussage sich mit dem Technik-Stratum aus
    [`AGENTS.md`](../../../../AGENTS.md) §2 reibt — der Durchgang ist der Ort, an dem das
    auffällt.
- **Der Bestand mit je zwei Fragen ist die Obergrenze einer Review-Sitzung.** Wird sie gerissen,
  ist der Schnitt falsch; dann wird geteilt, nicht die Sitzung gedehnt — geteilt wird **die
  Liste, nicht die Achsen**: beide Fragen an einen Eintrag werden an demselben Text beantwortet,
  und wer sie trennt, liest ihn zweimal.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und die
Briefing-Dateien im Wurzelverzeichnis gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
