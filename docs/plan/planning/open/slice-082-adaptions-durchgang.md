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

Jeder der **24** Einträge des Adaptions-Blocks ist **einzeln** geprüft
([ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md): *„einzeln, mit eigenem
Beleg"*) und trägt zwei Antworten, jede mit Beleg. Die Prozedur stellt zwei Fragen, und sie
liegen auf verschiedenen Achsen.

**Achse 1 — die Bewegung der Baseline.** Die Frage stellt die Prozedur selbst: *Regelt die neue
Fassung das, wofür diese Adaption angelegt wurde?* — ausdrücklich eine Frage an das **Delta der
neuen Fassung**, nicht an den Zustand der Baseline. Die Antwort ist genau einer der **fünf
Ausgänge**, wie Modul 2 der Ziel-Fassung (`v5.3.1`) sie benennt (§*Freshness-Audit der vendored
Baseline*, vierte Eigenschaft): **gegenstandslos** → Rückbau · **bleibt gültig** → stehen lassen
(Normalfall) · **teilweise überholt** → durch eine engere Nachfolgerin ablösen · **Bezug
entfallen** (die Baseline regelt das Thema gar nicht mehr) · **widerspricht** der neuen Fassung —
dann gilt die Adaption weiter, aber der Widerspruch gehört benannt.

**Ein Zweig innerhalb dieser fünf, kein sechster Ausgang:** *„War die Adaption eine Lockerung und
die neue Baseline verschärft, ist die richtige Antwort ein Carveout mit Auflösungs-Trigger
(Modul 7), keine stille Dauer-`MR`."* Er entscheidet nicht, **ob** die Adaption weitergilt, sondern
in welcher **Form** — befristet und mit abfragbarem Trigger statt als Dauerzustand. Ein Eintrag,
der einer Verschärfung standhalten soll, ohne das zu tragen, ist die stille Dauer-`MR`, die der
Satz meint.

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

- [ ] **Achse 1 — alle 24** Einträge tragen genau einen der fünf Ausgänge mit Beleg;
      Vollständigkeit als **Inventar gegen Abdeckung** (`grep -c '^### MR-' harness/conventions.md`
      ist der Nenner), nicht als Trefferliste. `permanent`-Einträge sind mitgeprüft: *permanent*
      heißt „kein automatischer Auflösungs-Trigger", nicht „unauflösbar". Wo die Adaption eine
      **Lockerung** war und die neue Fassung an derselben Stelle **verschärft**, ist die Antwort ein
      **Carveout mit Auflösungs-Trigger** (Modul 7), keine stille Dauer-`MR`.
- [ ] **Achse 2 — jeder Auflösungs-Trigger ist abgefragt**, und die Antwort steht am Eintrag:
      Bedingung eingetreten oder nicht, Eintrag weiter gebraucht oder nicht — bei *gebraucht*
      übernommen, sonst durch einen Nachfolger aufgelöst. Nenner ist auch hier ein Kommando,
      nicht die Zahl: `grep -c '^- \*\*Auflösungs-Trigger' harness/conventions.md` → heute **23**
      von 24. Der eine ohne Trigger
      ([`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung))
      ist kein Ausreißer, sondern bereits aufgehoben; ihn trägt allein Achse 1.
- [ ] **Was der Durchgang schreibt, hat die Form der Ziel-Prozedur:** ein Rückbau ist ein **neuer
      Eintrag, kein Edit**, und nennt den Baseline-Stand, der den Trigger gefeuert hat. Welche
      Gestalt der aufgehobene Eintrag danach behält, hängt am Ausgang von
      [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
      — er ist selbst ein Fall dieses Durchgangs (§6) und wird **vor dem ersten Rückbau**
      entschieden. Am Ende trägt
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

[slice-081](slice-081-baum-tauschen-pin-ziehen.md) liegt in `done/` — der neue Baum ist im Repo,
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
    der Ausgang ist dort vorab gemessen und vom Durchgang zu vollziehen. Zwei Stücke fehlen ihm
    trotzdem — die **Textprüfung**, die
    [`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
    ausdrücklich offen lässt (trägt der hiesige Wortlaut die Upstream-Semantik?), und die Form des
    Vollzugs, die am ersten Punkt dieser Liste hängt.
  - [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), deren
    **2-Strata**-Aussage sich mit dem Technik-Stratum aus
    [`AGENTS.md`](../../../../AGENTS.md) §2 reibt — der Durchgang ist der Ort, an dem das
    auffällt.
- **24 Einträge mit je zwei Fragen sind die Obergrenze einer Review-Sitzung.** Wird sie gerissen,
  ist der Schnitt falsch; dann wird geteilt, nicht die Sitzung gedehnt — geteilt wird **die
  Liste, nicht die Achsen**: beide Fragen an einen Eintrag werden an demselben Text beantwortet,
  und wer sie trennt, liest ihn zweimal.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und die
Briefing-Dateien im Wurzelverzeichnis gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
