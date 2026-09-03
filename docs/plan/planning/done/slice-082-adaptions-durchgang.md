# Slice slice-082: Adaptions-Durchgang — jeder Eintrag bekommt seinen Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-10](welle-10-re-baseline.md).

**Bezug:** [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (die Aussage,
die der Durchgang prüft), [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
[`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline),
[`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung),
[`ADR-0014`](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md),
[ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) (die Prozedur, nach der dieser
Durchgang läuft, und die Grenze, dass sie keinen einzelnen Eintrag vorentscheidet).

**Verantwortlich:** Architect (pt9912) — §3 nennt die zwei Haupt-Dateien
(`harness/conventions.md`, `AGENTS.md`) ausdrücklich **Architect-Artefakte**
([`AGENTS.md`](../../../../AGENTS.md) §3.8): der Norm-Text der Ausgänge (neue Einträge im
Adaptions-Block, ggf. der §3.7-Rückbau) entsteht im Architect-Lauf und in eigenem Commit; was der
Durchgang liefert, ist das Übergabe-Artefakt dafür. Derselbe Liefergegenstand trägt beim
Präzedenzfall [slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) dieselbe Besetzung
(*„der Adaptions-Block schreibt der Architect — dieser Slice ist geschnitten, nicht ausgeführt vom
Planner"*). Das Feld weicht damit von der Default-Besetzung ab, die Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine nennt (*„den Rolleninhaber der
Implementer-Rolle"*).

**Autor:** Planner. **Datum:** 2026-08-09.

---

## 1. Ziel

**Jeder** Eintrag der **eingefrorenen Bezugsmenge** ist **einzeln** geprüft
([ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md): *„einzeln, mit eigenem
Beleg"*) und trägt zwei Antworten, jede mit Beleg. Die Prozedur stellt zwei Fragen, und sie
liegen auf verschiedenen Achsen.

**Die Menge steht nicht in diesem Plan, sondern in
[welle-10](welle-10-re-baseline.md) §3, und sie ist geschlossen:**
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) bis
[`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt),
der Bestand am Tausch-Commit `b902b60`
(`git show b902b60:harness/conventions.md | grep -c '^### MR-'` → **29**). **Nicht** der heutige
Bestand: `grep -c '^### MR-' harness/conventions.md` wächst mit jedem Architect-Lauf, und dieser
Durchgang erzeugt selbst Einträge — ein Kriterium über die laufende Menge könnte er nie erfüllen.
Warum die Grenze am Tausch liegt und nicht am Wellen-Schnitt, und was die Einträge außerhalb
schulden, steht in [welle-10](welle-10-re-baseline.md) §3 und §6; dieser Plan doppelt es nicht.

**Eingefroren ist die Mitgliedschaft, nicht der Text.** Gelesen wird jeder Eintrag im **heutigen**
Wortlaut — zwei von ihnen sind seit dem Tausch aufgehoben worden und tragen ihren Ausgang bereits
(§6).

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

- [x] **Achse 1 — jeder** Eintrag der eingefrorenen Menge trägt genau einen der fünf Ausgänge mit
      Beleg; Vollständigkeit als **Inventar gegen Abdeckung**
      (`git show b902b60:harness/conventions.md | grep -c '^### MR-'` ist der Nenner — der
      Tausch-Stand, nicht der Arbeitsbaum), nicht als Trefferliste. Fällt ein Eintrag auf
      **widerspricht**, steht am
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
      [slice-131](../done/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) schließt
      `harness/conventions.md` ausdrücklich aus, und
      [slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) behandelt nur die **Adresse** einer
      einzelnen Referenz. Kein Gate sieht sie: eine Messung in Inline-Code ist kein Link.
- [x] **Achse 2 — jeder Auflösungs-Trigger der eingefrorenen Menge ist abgefragt**, und die Antwort
      steht am Eintrag: Bedingung eingetreten oder nicht, Eintrag weiter gebraucht oder nicht — bei
      *gebraucht* übernommen, sonst durch einen Nachfolger aufgelöst. Der Nenner ist auch hier ein
      Kommando über den **Tausch-Stand**, nicht über den Arbeitsbaum:
      `git show b902b60:harness/conventions.md | grep -c '^- \*\*Auflösungs-Trigger'` → **28**
      gegen **29** Einträge. **Welche Einträge keinen Trigger führen, ist ebenfalls ein Kommando
      und keine Liste in diesem Plan** — und es läuft über den heutigen Wortlaut, weil eingefroren
      die Mitgliedschaft ist und nicht der Text:
      `awk '/^### MR-[0-9]/{if(id!=""&&!f)print id; id=$0; f=0} /Auflösungs-Trigger/{f=1} END{if(id!=""&&!f)print id}' harness/conventions.md`.
      Dass die zwei Zahlen auseinanderlaufen — **28** von **29** am Tausch, heute mehr ohne
      Trigger —, ist der Normalfall und kein Befund: eine Aufhebung nimmt den Trigger mit.
      Ein Eintrag darin ist kein Ausreißer: ein **aufgehobener** Eintrag hat keinen Trigger mehr,
      und Achse 1 trägt ihn allein. Der Durchgang notiert je Treffer, ob die Aufhebung der Grund
      ist — ein Treffer ohne Aufhebung und ohne Trigger ist der Befund dieser Achse.
- [x] **Was der Durchgang schreibt, hat die Form der Ziel-Prozedur:** ein Rückbau ist ein **neuer
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
- [x] `make gates` grün.
- [x] Doku-Update: `AGENTS.md` und `harness/README.md`, soweit ein Ausgang sie berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
  Closure-Kriterium der Welle mit. — **Ausgang: entfallen.** Nicht eingetreten: kein Ausgang
  dieses Durchgangs verlangt eigene Umsetzung außerhalb dieses Slice (§9 *Was das für §4
  (Trigger) heißt* — drei neue Adaptions-Block-Einträge, zwei Kopf-Marken, ein
  `Aufgehoben-durch`-Zeiger, eine Rumpf-Löschung, alles in `harness/conventions.md`); die
  Zwei-Einträge-Schwelle aus §4 ist nicht erreicht, `in-progress → next` griff nicht.
- **Vier Posten der eingefrorenen Menge sind schon sichtbar** — hier steht, was zu messen ist,
  nicht, wie es ausgeht. Bei einem der vier ist der Ausgang inzwischen geschrieben und nur noch zu
  verbuchen:
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
    **beide sind aufgehoben, und ihr Ausgang liegt damit vor diesem Durchgang statt in ihm.** Ein
    Architect-Lauf hat ihn geschrieben, in genau der Form, die dieser Punkt verlangt — ein **neuer
    Eintrag, kein Edit**:
    [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
    misst die Regel gegen `v5.12.0` und hebt beide auf
    (`grep -c 'Aufgehoben durch.*031' harness/conventions.md` → **2**). **Was der Durchgang
    hier noch tut, ist verbuchen, nicht entscheiden.** Offen bleibt allein die **Textprüfung** —
    trägt der hiesige Wortlaut die Upstream-Semantik? —, und sie steht in
    [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
    selbst als gemessene Lücke. **Der liegt außerhalb der eingefrorenen Menge** (§1) und ist damit
    kein Posten dieses Durchgangs; wer ihn schließt, ist der Architect
    ([`AGENTS.md`](../../../../AGENTS.md) §3.8, §3 dieses Plans).
  - [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), deren
    **2-Strata**-Aussage sich mit dem Technik-Stratum aus
    [`AGENTS.md`](../../../../AGENTS.md) §2 reibt — der Durchgang ist der Ort, an dem das
    auffällt.

  **Ausgang: entfallen.** Alle vier Posten tragen ihren Beleg jetzt in §9, keiner verlangte einen
  Carveout oder einen Folge-Slice: [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  ist teilweise überholt, Nachfolge-Eintrag
  [`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte)
  (Option C geprüft, nicht widersprochen — keine Folge-ADR, keine Rückführung
  `in-progress → open`);
  [`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
  bleibt gültig, geprüft statt vermutet;
  [`MR-022`](../../../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)/[`MR-023`](../../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  liegen außerhalb der eingefrorenen Menge, nur verbucht — ihre einzige Restfrage (Textprüfung)
  hat mit
  [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
  bereits einen Träger (dort als gemessene Lücke geführt, Architect-Sache, kein neuer Träger aus
  diesem Slice nötig);
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) bleibt gültig — die
  genannte Reibung ist bereits vor diesem Durchgang durch eine Teil-Ablösung zu
  [`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
  aufgelöst (§9, Eintrag 000).
- **Der Bestand mit je zwei Fragen ist die Obergrenze einer Review-Sitzung.** Wird sie gerissen,
  ist der Schnitt falsch; dann wird geteilt, nicht die Sitzung gedehnt — geteilt wird **die
  Liste, nicht die Achsen**: beide Fragen an einen Eintrag werden an demselben Text beantwortet,
  und wer sie trennt, liest ihn zweimal. — **Ausgang: entfallen.** Nicht eingetreten: der
  Durchgang blieb eine Sitzung; §9 *Was das für §4 heißt* bestätigt, dass die
  Zwei-Einträge-Schwelle nicht erreicht wurde und `in-progress → next` nicht griff.

## 7. Closure-Notiz (nach `done/`)

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **DoD vollständig.** Alle Punkte aus §2 sind gehakt —
   `grep -c '^- \[ \]' docs/plan/planning/done/slice-082-adaptions-durchgang.md` → **0**
   offene Punkte (Kommando läuft vor dem `git mv`, solange die Datei noch unter diesem Pfad
   liegt).
2. **`make gates` grün** nach dem Commit dieser Closure-Notiz — der Stop-Hook-Stempel deckt den
   Arbeitsbaum.

- **Was hat funktioniert:** Das Fünf-Ausgänge-Schema aus Modul 2 (gegenstandslos · bleibt gültig
  · teilweise überholt · Bezug entfallen · widerspricht) trug für alle 29 Einträge der
  eingefrorenen Menge — 26 `bleibt gültig`, drei mit echtem Befund (015, 016, 020), kein
  sechster Ausgang nötig. Die bereits vorher entschiedene `ÜBERHOLT`-Form
  ([`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger))
  ließ sich unverändert auf alle drei Rückbauten anwenden (015 und 020 Teil-Ablösung,
  016 vollständige Aufhebung nach
  [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf));
  neben den zwei bereits im Bestand liegenden Beschriftungen (`HISTORIE`, `ÜBERHOLT`) entstand
  keine dritte.
- **Was ging anders als geplant:** Zwei der 29 Prüfungen (§9, Einträge 019 und 020) widerlegten
  den naheliegenden ersten Eindruck — *„die Baseline behandelt das Thema jetzt, also
  gegenstandslos"* trug in beiden Fällen nicht. Erst die Prüfung gegen den genauen Wortlaut
  (*„erfüllt der neue Text die Pflicht, für die dieser Eintrag angelegt wurde?"*) ergab den
  tatsächlichen Ausgang — bei 019 `bleibt gültig` (die Deklarationspflicht bleibt bestehen, auch
  wenn die drei Straten jetzt obligatorisch sind), bei 020 `teilweise überholt` mit **bestätigter**
  statt vermuteter Fortgeltung von Option C.
- **Steering-Loop-Eintrag:** geschärfte Regel — Achse 1 eines Adaptions-Durchgangs (*„regelt die
  neue Fassung das, wofür diese Adaption angelegt wurde?"*) ist nicht mit *„die Baseline behandelt
  jetzt dasselbe Thema"* beantwortet, sondern nur mit *„die Baseline erfüllt jetzt genau die
  Pflicht, für die der Eintrag entstand"* — Beleg: §9, Einträge 019 und 020 dieses Plans. Auslöser:
  `BEO-008` (slice-082 — 1×; noch nicht verkörpert, siehe Register).
- **Beobachtungs-Register (`../observations.md`):** neue `BEO-008` angelegt (Sub-Area `*`, 1×,
  Beleg slice-082).
- **Folge-Slices:** keine. Kein Ausgang dieses Durchgangs verlangt eigene Umsetzung außerhalb
  dieses Slice (§9 *Was das für §4 heißt*).
- **Risiken aus §6:** alle drei mit Ausgang `entfallen` (siehe §6 je Risiko) — keines eingetreten,
  keines weiter offen.
- **Drei Paarungen:** entfällt hier — dieses Repo führt Wellen-Betrieb, `welle-10` bleibt nach
  dieser Closure offen (weitere Slices in `open/`). Die Paarungen (Anker · Folge-Slice · Register)
  prüft die nächste Welle-Closure, auch für diesen Slice
  (`modul-06-roadmap.md`
  §Wellen-Closure-Prozedur, Schritt 3, *„Zum Schluss alle drei Paarungen prüfen"*).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/` und die
Briefing-Dateien im Wurzelverzeichnis gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).

## 9. Inventar — Achse 1 und Achse 2 je Eintrag (Übergabe-Artefakt des Durchgangs)

**Nenner:** `git show b902b60:harness/conventions.md | grep -c '^### MR-'` → **29** (Kennungen 000
bis 028). Alle 29 sind unten geführt — Inventar gegen Abdeckung, keine Trefferliste. Gelesen ist
jeder Eintrag im **heutigen** Wortlaut (§1); wo ein Eintrag außerhalb dieses Durchgangs bereits
aufgehoben wurde (Kennungen 018, 022, 023 — alle vor bzw. an `b902b60` retiriert), ist das hier
nur **verbucht**, nicht entschieden (§6 des Plans). Kreuzverweise auf andere Adaptions-Einträge
stehen in dieser Tabelle absichtlich **ohne** `MR-`-Präfix (nur die Nummer) — der Präfix bindet
nach [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
Link-Pflicht, und eine Tabelle mit 29 Zeilen voller Vollpfad-Links wäre nicht mehr lesbar; die vier
Posten mit echtem Befund tragen ihre Zitate darum ausgeschrieben **unterhalb** der Tabelle.

| Nr. | Achse 1 — Ausgang | Achse 2 — eigener Bedarf | Messungen reproduzieren? |
|---|---|---|---|
| 000 | bleibt gültig (Rest nach den beiden vorbestehenden Teil-Ablösungen 2-Strata→019, Blankett-Klausel→Kommando); ID-Schema/Verzeichniskonvention unverändert Kurs-konform | permanent, Initial-Setzung, kein Trigger | ja (`grep -n Blankett-Klausel harness/conventions.md` reproduziert) |
| 001 | bleibt gültig (Rest nach vorbestehender Teil-Ablösung Zensus→029); Modul-Aktivierung (matrix/spans/ids-Link-Pflicht) bleibt Tool-Entscheidung, kein Baseline-Bezug | permanent; `codepaths.roots` steht weiterhin auf `[spec, docs, harness]`, nicht gewachsen → nicht ausgelöst | ja (`.d-check.yml`-Grep aktuell) |
| 002 | bleibt gültig — Mechanik (Working-Tree-Hash, PreToolUse-Guard, Host-Go-Block) deckt sich mit `grundlagen-durchsetzungsschicht.md` (PreToolUse-Hook, Sub-Shell-Rekursion) | permanent, nicht ausgelöst | keine Messwert-Zahlen im Rumpf |
| 003 | bleibt gültig | permanent; die genannte Restlücke ("CI ist dort das Netz") ist durch die CI-Adaption (014) bereits geschlossen — repo-intern, kein Baseline-Bezug | keine Messwert-Zahlen im Rumpf |
| 004 | bereits Teil-abgelöst (HISTORIE → Baseline-committet-vendored-Eintrag 007, vor `b902b60`); Rest (Injektor-Mechanik: Codex Volltext, Claude on-demand) bleibt gültig, kein Widerspruch in `grundlagen-durchsetzungsschicht.md`/`modul-02` gefunden | kein neuer Trigger | — |
| 005 | bleibt gültig (Layout-Wahl `harness/tools/`, kein Baseline-Bezug) | permanent; offene Emissions-Reconciliation bleibt offen — keine Umsetzung hier (§6 des Plans) | — |
| 006 | bereits Teil-abgelöst (HISTORIE → 007, vor `b902b60`) | kein neuer Trigger | — |
| 007 | bleibt gültig — bestätigt gegen `v5.12.0`: `grep -n 'werden beim Bootstrap' .harness/baseline/v5.12.0/regelwerk/modul-02-harness-bootstrap.md` trägt weiterhin "committet vendored" als Baseline-Vorgabe | permanent; Upstream-Überwachung läuft weiter (`regelwerk-check`/`baseline-freshness`), kein Rückbau-Trigger | ja (`make baseline-verify` → 51 Dateien, deckt sich mit welle-10 §1) |
| 008 | bleibt gültig — Mechanismus (`cp` aus vendored Templates) funktioniert unverändert; Ziel-Baum trägt 25 Templates (welle-10 §1) | permanent, "solange das Repo seine Templates nicht adaptiert" — nicht eingetreten | ja |
| 009 | bleibt gültig (Tool-Pin-Wahl, kein Baseline-Bezug — d-check-Versionen sind kein Kursgegenstand) | permanent; Re-Pin ist laufende Wartung, aktueller Pin `v0.65.0` (Kettenschritt 027) | ja — Vergleiche fester Digests sind zeitlos |
| 010 | bleibt gültig | permanent; Fixture/Anker-Zahlen gegen `v0.65.0` durch Kettenschritt 027 bereits bestätigt | ja |
| 011 | bleibt gültig | permanent | ja |
| 012 | bleibt gültig (historischer Kettenschritt, weiter durch 013/024/027 fortgesetzt) | permanent | ja |
| 013 | bleibt gültig (aktueller Mechanismus für `regelwerk-check`) | permanent | ja |
| 014 | bleibt gültig (CI-Tool-Wahl; kein Baseline-Text zu GitHub-Actions-Scheduling gefunden) | permanent | ja |
| 015 | **gegenstandslos → Rückbau, als Teil-Ablösung** (Nachfolge-Eintrag unten) | Setzung-3-Trigger ("externer Auftraggeber existiert") nicht eingetreten, bleibt an diesem Eintrag hängen | Zitat reproduziert wörtlich |
| 016 | **teilweise überholt (gegenstandslos + widerspricht→übernehmen) → vollständige Aufhebung** (Nachfolge-Eintrag unten) | eigener Trigger ("Setzung 2/3 fallen, sobald Modul 6 einen Ort vorsieht") eingetreten | Ist-Messung (21/56) war Zeitpunkt-Messung ohne laufendes Versprechen, kein Reproduktions-Problem |
| 017 | bleibt gültig (ADR-Verweis, Tool-Policy für emittierte Configs — kein Kurs-Gegenstand) | permanent | keine Messwert-Zahlen im Rumpf |
| 018 | bereits vollständig aufgehoben (vor `b902b60`) — Ziel (`spec/spezifikation.md` §5, Messreihen-Zeitdokument) weiterhin aktuell und vorhanden | kein Trigger mehr (aufgehoben) | — |
| 019 | **bleibt gültig** — geprüft: `v5.12.0` verlangt weiterhin die explizite Deklaration jedes Spec-Dokuments in `harness/conventions.md`, trotz jetzt **obligatorischer** 3-Strata-Struktur (Details unten) | permanent; "letzter Abschnitt mit Bestand" ist nicht weggefallen (§3/5/6/7 gefüllt) | die eigene "ÜBERHOLT"-Marke (→021) ist bereits korrekt |
| 020 | **teilweise überholt → engere Nachfolgerin, Option C bestätigt, kein Widerspruch** (Details unten) | Re-Evaluierungs-Trigger der zugehörigen ADR eingetreten, neu begründet — ADR bleibt Accepted, keine Folge-ADR, keine Rückführung `in-progress → open` | — |
| 021 | teilweise überholt, größtenteils bereits verbucht (ein Punkt bereits anderweitig abgelöst, außerhalb des Rahmens); der verbleibende Punkt (Sensor-Spalte) bleibt gültig — gegengeprüft: `modul-15-observability.md` §Span-/Audit-Attribut-Regeln trägt weiterhin nur Attribut-Name/Pflicht/Incident-Frage, keine vierte Spalte | permanent, kein neuer Trigger | ja |
| 022 | bereits vollständig aufgehoben (außerhalb des Rahmens) — nur verbucht | kein Trigger mehr | — |
| 023 | bereits vollständig aufgehoben (außerhalb des Rahmens) — nur verbucht | kein Trigger mehr | — |
| 024 | bleibt gültig | permanent; operativ durch Kettenschritt 027 fortgeführt | ja |
| 025 | bleibt gültig — "Harness-Lüge"-Konzept unverändert in `grundlagen-begriffe.md` vorhanden | keiner (bewusst Feedforward-Quadrant, wie im Eintrag selbst begründet) | ja (Zitat reproduziert) |
| 026 | bleibt gültig — These (Nummer ist Adresse, keine Baseline-Entsprechung) durch eine zusätzliche Koinzidenz (§3.7 seit dem Vorgriff-eingeholt-Commit, neben dem seit je bestehenden §3.3) eher gestützt als widerlegt | Auflösungs-Trigger im **strukturellen** Sinn nicht ausgelöst (Einzel-Koinzidenzen zählten schon bei §3.3 nicht als Trigger); als Beobachtung notiert, kein Rückbau | ja |
| 027 | bleibt gültig (aktueller d-check-Pin) | permanent; kein Re-Pin fällig für diesen Durchgang — `v0.66.1` liegt bereits als eigener, wellenloser Slice in `open/`, unabhängig von diesem Durchgang | ja |
| 028 | bleibt gültig — Mechanismus (blanke Slice-Nummer statt Link) wird weiterhin gelebt | permanent | ja |

### Die vier Posten mit echtem Befund

**015 ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) — gegenstandslos.**
`grundlagen-source-precedence.md`
trägt seit `v5.12.0` einen eigenen Absatz *„Fallen Auftraggeber- und Entwickler-Rolle
zusammen"*, der [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)s drei Setzungen Satz für Satz deckt: *„Die Rolle ist besetzt … der
annehmende Akt ist die Entscheidung, die vor der Umsetzung fällt"* (Setzung 1), *„Der Träger ist
dann der Commit: … ausschließlich das Lastenheft … vor dem Slice"* (Setzung 2, wörtlich). Die
Lücke, die [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) selbst benannte (*„dieses Repo hat keinen externen Auftraggeber"*), ist
geschlossen. **Rückbau als Teil-Ablösung, nicht Vollentfernung:** der Cutoff-Absatz von [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
bindet an zwei Stellen fort — [`AGENTS.md`](../../../../AGENTS.md) §3.7 und
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
zitieren ihn als Präzedenz (*„dieselbe Begründung trägt den Cutoff in [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)"*). Nach
[ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a) bleibt der
Rumpf deshalb vollständig stehen; nur eine Kopf-Marke ist gesetzt — Nachfolge-Eintrag
[`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline).

**016 ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)) — teilweise überholt, praktisch vollständige Aufhebung.**
`modul-06-roadmap.md`
trägt [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)s Platzierungs-Regel (Setzung 2/3: wellenlose Arbeit nicht in der Roadmap, Zustand ist
die Verzeichnis-Position) jetzt wörtlich als Baseline-Default. Gleichzeitig **widerspricht** die
neue Fassung [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)s dritter Schnitt-Frage ausdrücklich: [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) sagte *„'Wir wollen eine neue
Fähigkeit' → gewollt, Welle — auch wenn es zunächst nach einem Slice aussieht"*; die neue Fassung
sagt *„auch eine neue Fähigkeit kann ein einzelner Slice sein"*. Das eigene Register dieses Repos
stützt die neue Fassung: [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)s eigene drei Gegenbeispiele (slice-027/039/048) wurden *„fast
immer nachgeschnitten"* — sie wurden zu Wellen, als sich ein Bündel zeigte, nicht weil "gewollt"
allein schon eine Welle verlangte. Gewählt: **übernehmen** (nicht "weiter gelten und benennen"),
weil das eigene Register die alte Regel widerlegt statt stützt. Da nichts vom Rumpf mehr
eigenständig bindet, ist dies eine vollständige Aufhebung — durchgeführt in zwei zusätzlichen,
additionsfreien Commits (Zeiger setzen, dann Rumpf löschen), wie
[ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (c) verlangt.
Nachfolge-Eintrag [`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst).

**019 ([`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)) — bleibt gültig (Normalfall), keine Vermutung.**
Der erste Eindruck — *„3 Strata sind jetzt obligatorisch, also gegenstandslos"* — trägt nicht:
`grundlagen-referenz-richtung.md`
verlangt unverändert, dass **jedes** Spec-Dokument sein Stratum in `harness/conventions.md`
deklariert (*„Ein Spec-Dokument ohne deklariertes Stratum ist eine stille Setzung … und nicht
normativ zitierbar, bis es deklariert ist"*) — einer von zwei genannten Mechanismen. Die
Obligatorik der drei Straten ändert **was** normal ist, nicht **ob** eine Deklaration nötig ist.
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence) bleibt darum der Ort dieser Deklaration für `spec/spezifikation.md`. Kein
Nachfolge-Eintrag.

**020 ([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)) — teilweise überholt, geprüft statt vermutet.**
[ADR-0014](../../adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md)s dritter
Re-Evaluierungs-Trigger (*„Wenn die Baseline die Disziplin-Regel aus dem Vorlagen-Kommentar in
ein Prosa-Modul hebt … Abweichung ist gegen den neuen Wortlaut neu zu begründen"*) ist
eingetreten — genau das ist bei `v5.12.0` geschehen
([`MR-029`](../../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
hat es für einen Nachbar-Fall schon gemessen). Geprüft, nicht nur behauptet: **Option C
widerspricht dem neuen Wortlaut nicht.** *„Nicht überschrieben"* und *„kein Edit"* richten sich
gegen das Verändern einer bestehenden Aussage; Option C ändert nichts, sie entfernt den Rumpf per
eigenem, additionsfreien Commit und lässt Nummer, Überschrift wörtlich und Datum stehen — genau
den stabilen Anker, den *„ein Nachfolger, der sie auflöst"* voraussetzt. Neu ist ein
Formerfordernis (Baseline-Stand im `Aufgehoben durch`-Feld nennen), kein Widerspruch. **Ergebnis:
keine Folge-ADR, keine Rückführung `in-progress → open`.** Nachfolge-Eintrag
[`MR-038`](../../../../harness/conventions.md#mr-038--ein-retirierender-eintrag-nennt-den-baseline-stand-der-seinen-trigger-feuerte).

### Was das für §4 (Trigger) heißt

Kein Ausgang dieses Durchgangs verlangt eigene Umsetzung außerhalb dieses Slice (drei neue
Adaptions-Block-Einträge, zwei Kopf-Marken, ein `Aufgehoben-durch`-Zeiger, eine
Rumpf-Löschung — alles `harness/conventions.md`); die Zwei-Einträge-Schwelle aus §4 ist damit
nicht erreicht, `in-progress → next` greift nicht. Der einzige Kandidat für
`in-progress → open` — [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf) gegen die zugehörige ADR — ist geprüft und fällt **für** die
bestehende Festlegung aus (oben); die Rückführung greift nicht. Kein Zweig fällt auf *Lockerung
traf Verschärfung* mit Bedarf an einem Gate — kein Carveout. Kein Ausgang berührt den Text von
[`AGENTS.md`](../../../../AGENTS.md) oder [`harness/README.md`](../../../../harness/README.md)
inhaltlich; die einzige AGENTS.md-Berührung (§3.7-Zitat von [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)) bleibt unverändert korrekt,
weil [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) als Teil-Ablösung seinen zitierten Absatz behält.
