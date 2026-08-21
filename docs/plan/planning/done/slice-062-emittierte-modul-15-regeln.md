# Slice slice-062: Welche Modul-15-Regeln der emittierte Harness bekommt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — die **Tool**-Ebene,
Entscheidungsteil. Die Vorarbeit liefert
[slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md), den Beleg danach `slice-063`;
jener ist benannt, nicht geschnitten.

**Bezug:**
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte Doc-Gate-Baseline: ihr `d-check.mk` **trägt den Block-4-Check schon**, und ihre
Wachstums-Bedingung deckt dessen Konfiguration — gemessen in §3),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
emittierte Durchsetzungs-Mechanik — geprüft und **nicht** berührt: ihre Aufzählung wächst nicht,
§3),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (das
Abhängigkeitsbudget `bash + git + docker` — unberührt, weil kein Artefakt hinzukommt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) und
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (die Zusage
*out-of-the-box grün*, an der der Beleg für Block 4 hängt — §6),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der
emittierte Stand ist gate-sicher),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(Setzung 1: die Entscheidung geht dem Slice voraus; Setzung 2/3 haben hier **keinen Gegenstand**
— §3),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop: die Klasse, in der die Konfiguration des Trägers liegt),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (die Phasen-Trennung, aus der die Begründung
der ersten Nicht-Emission stammt),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (die Erfassungs-Policy des Dogfood),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (die permanente Grenze der
Token-Achse),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (das Gefäß folgt dem Gegenstand —
der Grund, warum eine permanente Nicht-Umsetzung in die ADR und nicht ins Lastenheft gehört),
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) (die **Vorbedingung** des
**Zähler-Glieds** zweier Zellen — verwiesen, nicht abgeschrieben, und ausdrücklich **kein**
Auflösungs-Trigger von Zellen dieser Matrix, §3).
Regelwerk-Quellen: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` (die vier
Regelblöcke) und `.harness/baseline/v3.5.2/regelwerk/modul-13-quality-gates.md`
(§Hard Rule Doku-Disziplin, die der emittierte Check durchsetzt).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-16.

---

## 1. Ziel

**Die Tool-Spalte der Modul-15-Matrix bekommt ihre vier Werte — je Nicht-Emission mit dem
Trichter-Ausgang aus Modul 7, und für Block 4 mit dem Träger, der im Ziel schon liegt.**

**Die Entscheidung ist gefallen und geht diesem Slice voraus** (Auftraggeber, 2026-08-16, zwei
Setzungen desselben Tages;
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 1). Dieser Slice **trifft** sie nicht — er schreibt sie in das eine Gefäß, das sie tragen
kann: eine **ADR** für Geltungsbereich, Begründung und Dauer. **Die Dauer ist dabei keine zweite
Setzung, sondern ihre ehrliche Frist:** was der Auftraggeber als *„geht nicht mit"* gesetzt hat,
heißt nach dem Trichter *„geht nicht mit, bis ein fremder Vertrag sich ändert"* — und nicht
*„vorerst nicht"*. Die Alternative wäre der Trigger, der Temporalität behauptet und sie nicht
einlösen kann. **Ein zweites Gefäß hat keinen
Gegenstand:** Block 4 bekommt **kein neues Artefakt**, damit wächst keine Anforderung, und ein
Change Request ohne Vertragsänderung ist keiner (gemessen in §3). Was der Slice zusätzlich
leistet, ist die Grenze: er benennt, was die ADR noch zu **entscheiden** hat und was sie nur noch
**feststellt**, statt beides unter die Entscheidung zu schieben.

**Welche Zellen er füllt.** Die Matrix selbst entsteht in `welle-09-results.md`; hier stehen nur
die Zellen und der Wert, den dieser Slice ihnen festlegt:

| Zelle der Closure-Matrix | Wert, den dieser Slice festlegt |
|---|---|
| *Span-/Audit-Attribut-Regeln × Tool* (Block 1) — **zwei Abweichungen in einer Zelle**, darum je Abweichung ein Wert ([welle-09](../welle-09-modul-15-konformitaet.md) §3): (a) die **Erfassung**, (b) die **Rollen-Typen** unter `.claude/agents/`, denn `agent.role` ist ein Pflichtfeld genau dieses Blocks | **ADR-Verdikt** für **beide** — sie sind nicht zwei Fragen, sondern eine mit einem Pflichtfeld: ohne Erfassung im Ziel hat die Rolle dort keinen Abnehmer, und dass die Erfassung nicht mitgeht, ist permanent (§3) |
| *Token-Attribution × Tool* (Block 2) | **ADR-Verdikt** |
| *Cache-Counter × Tool* (Block 3) | **ADR-Verdikt** |
| *Doku-Konsistenz-Drift × Tool* (Block 4) | **emittiert**, Träger ist das bereits mitgelieferte `make doc-targets` — der Wert ist hier **festgelegt**, nicht belegt: `emittiert` verlangt nach [welle-09](../welle-09-modul-15-konformitaet.md) §3 *im Ziel vorhanden **und dort rot gesehen***, und beide Richtungen liefert erst `slice-063`. **Mit benanntem Gegen-Ausgang**, damit ein gescheiterter Beleg keine leere Zelle hinterlässt: lässt sich der Drift im Ziel nicht rot sehen, fällt die Zelle auf *nicht emittiert*, und ihr Auflösungs-Trigger ist dann der konfigurierte Träger — dieser eine liegt, anders als die drei oben, **in unserer Hand** |

**Warum drei Zellen *ADR-Verdikt* tragen und nicht *nicht emittiert* mit Trigger** — die Dauer
ändert sich, nicht die Setzung. Ein Trigger behauptet eine Frist; die einzige Schwelle, die die
Frage wieder öffnete, wäre *die Erfassung läuft ohne Kompilat*, und ihre Ausgänge sind abgezählt
und zu (§3). Die Zellen zeigen deshalb auf die **Re-Evaluierungs-Trigger** der Entscheidung — sie
werden **bemerkt**, nicht herbeigeführt. [welle-09](../welle-09-modul-15-konformitaet.md) §3 lässt
den Wert in **beiden** Spalten zu (*„permanent ist eine Eigenschaft der Abweichung, nicht der
Ebene"*); die Präzedenz der Nachbarspalte ist
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md).

Die Frage, die [slice-060](slice-060-rollen-achse.md) ausdrücklich hierher übergeben hat
(Frage B: gehen die Rollen-Typen in die Ziel-Repos mit?), ist damit beantwortet — **nein, und
dauerhaft**. Ihr einziger belegter Zweck ist die Rollen-Achse der Telemetrie; ohne Erfassung im
Ziel hat sie dort keinen Abnehmer, und ein rollen-benannter Lauf ohne Span misst nichts.

## 2. Definition of Done

- [x] **(1) Eine ADR trägt die vier Werte der Tool-Spalte — Accepted, mit dem Trichter-Ausgang je
  Nicht-Emission und mit dem Träger von Block 4.** Für jede der drei Nicht-Emissionen stehen
  **Geltungsbereich und Begründung**, und für jede ist der Trichter aus Modul 7 **beide Fragen
  weit** beantwortet (§3): fällt Frage 2 auf *Nein*, entfällt der Auflösungs-Trigger, die Zelle
  trägt **ADR-Verdikt**, und an seine Stelle treten die **Re-Evaluierungs-Trigger** der ADR — am
  Bestand ablesbar, aber von niemandem herbeiführbar. Was
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) dabei ist, gehört ausdrücklich
  benannt: **Vorbedingung** des **Zähler-Glieds**, **kein** Auflösungs-Trigger dieser Zellen — verwiesen,
  nicht abgeschrieben, denn eine zweite Fassung derselben Schwelle wäre die zweite Wahrheit, die
  driftet, und ein Carveout endet nach Modul 7 in **beiden** Ausgängen in `done/`. Für Block 4
  hält die ADR den Träger fest — `make doc-targets`, advisory, verbatim aus dem gepinnten Image —
  und entscheidet die zwei Fragen, die daran hängen: **(a)** ob ein Wächter, der **nicht** in `make gates` des Ziels hängt, den Matrix-Wert
  *emittiert* nach [welle-09](../welle-09-modul-15-konformitaet.md) §3 verdienen kann — er endet
  auf Befund mit Exit 1, *rot gesehen* und *im Gate-Lauf* sind also zweierlei, und die Antwort
  entscheidet zugleich, wie
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  für advisory Träger zu lesen ist; **(b)** ob die Zelle den Wert überhaupt trägt, denn er ist im Ziel
  heute **wirkungslos** und die zwei Hindernisse dazwischen sind gemessen (§6). Ebenfalls in der
  ADR: die Entkräftung der konditionalen Emission nach dem
  [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Muster
  (§6), die Folgepflicht, dass `slice-063` nichts emittiert, was der Dogfood nicht selbst
  fährt, und die **Reihenfolge-Bedingung über alle Bootstrap-Varianten**: der `targets:`-Block
  geht erst mit, wenn kein emittiertes Dokument mehr ein Ziel behauptet, das *irgendeiner*
  Variante fehlt. Diese Bedingung ist die Eintritts-Bedingung von `slice-063` und der Gegenstand
  von [slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md) — sie steht hier, weil sie
  die Emission bindet, und dort, weil sie dort geleistet wird.
- [x] `make gates` grün.
- [x] Doku-Update für den berührten öffentlichen Vertrag — **er ist nicht berührt**, gemessen in
  §3: [`spec/lastenheft.md`](../../../../spec/lastenheft.md) bleibt unverändert, belegt per
  `git diff --stat`.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Wer was schreibt

Drei schreibende Instanzen, getrennte Commits — die Trennung ist an `git log --stat` ablesbar,
nicht an der Prosa.

| Rolle | Artefakt | Commit-Disziplin |
|---|---|---|
| **Planner** | diese Datei; der Nachzug in [welle-09](../welle-09-modul-15-konformitaet.md) §4 und in der [Roadmap](../in-progress/roadmap.md) | mit dem Schnitt |
| **Architect** | die ADR aus DoD (1) und der ADR-Index | **eigener** Commit, nur Artefakte der schreibenden Rolle, Rolle in der Message ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| **Implementer** ([slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md), dann `slice-063`) | zuerst die emit-seitige Neutralisierung **jedes** emittierten Dokuments, das ein nicht Init-invariantes `make`-Ziel behauptet, samt Wächter über den Dokument-Satz, danach die emittierte Doc-Gate-Konfiguration und die zwei Beleg-Richtungen in [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | berührt **weder** ADR **noch** Lastenheft; die Reihenfolge ist keine Vorliebe, sondern die Bedingung aus DoD (1) |

**Weder die ADR noch dieser Slice ändern `LH-*` — sie referenzieren nur**
([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
adoptierter Wortlaut). Eine **Auftraggeber-Zeile fehlt in dieser Tabelle nicht aus Versehen**:
sie hätte keinen Gegenstand, s. u.

### Bewegt die Entscheidung eine Anforderung? — gemessen, nicht fortgeschrieben

**Nein.** Beide Kandidaten wurden im **Volltext** erneut gelesen (Zeilenbereiche nennt
`grep -n '^### LH-' spec/lastenheft.md`), diesmal gegen den Gegenstand, den die zweite
Auftraggeber-Setzung vom 2026-08-16 stehen lässt: **kein neues Artefakt**.

- [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
  **wird nicht bewegt.** Sie zählt die emittierte Durchsetzungs-**Mechanik** auf (Stop-Hook,
  Gate-Nachweis-Mechanik, `.claude/settings.json`, `CLAUDE.md`, Reviewer-Skill, Command-Guard)
  und bindet in ihren Akzeptanzkriterien das Budget einer tool-eigenen, ausführbaren
  Durchsetzung: **bash + awk**, kein node/jq/OCI, *„über `bash + git + docker` hinaus nichts"*.
  Der Träger war genau diese Aufzählung — und ihr Wachsen um **eine** Artefakt-Klasse war der
  ganze Grund, sie zu bewegen. Wächst sie nicht, ist die Anforderung erfüllt und unverändert.
- [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
  **wird ebenfalls nicht bewegt — sie deckt den Träger schon.** Sie sagt `.d-check.yml` +
  `d-check.mk` zu, letzteres als d-checks `--print-mk`-Fragment
  ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)),
  und genau darin liegt `make doc-targets` **verbatim**: der Emitter schreibt in den Kopf des
  Fragments *„advisory `doc-*`-Targets verbatim"*
  ([`internal/emit/emit.go`](../../../../internal/emit/emit.go)), und das Rezept schaltet das
  Modul selbst frei (`--enable targets`, [`d-check.mk`](../../../../d-check.mk)) — die
  Modul-Liste der Konfiguration steht ihm nicht im Weg. Ihre einzige Modul-Bedingung
  (*„`ids`/`codepaths` nur mit existierenden Targets/roots aktivieren — der Gate-Config wächst
  mit den Artefakten"*) wird von einer Konfiguration des Trägers **erfüllt**, nicht geändert:
  die Artefakte, die sie prüfen würde, entstehen beim Bootstrap. Das ist ein **Anheben** nach
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  — dieselbe Einordnung, die [slice-073](../open/slice-073-emittierte-doc-gate-module.md) §3 für seine
  Modul-Liste gemessen hat.
- [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ist **erfüllt,
  nicht geändert**, und diesmal ohne Zutun: es kommt nichts hinzu, das ein Budget verbrauchen
  könnte. [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  ist die Regel, die der Träger im Ziel durchsetzen **würde**, sobald er konfiguriert ist — und
  zugleich die Regel, gegen die der emittierte Bestand heute selbst verstößt (§6).

**Folge, und sie ist ein Ergebnis, kein Fehlschlag.** Der Fußabdruck aus
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 2/3 — Version-Bump, eine Historie-Zeile, eine geänderte `LH-*` — hat **keinen
Gegenstand**; ein Change Request ohne Vertragsänderung ist keiner. Dieser Slice trägt damit
**einen** Liefergegenstand, die ADR, und `slice-063` hat keine Vorbedingung mehr in
[`spec/lastenheft.md`](../../../../spec/lastenheft.md).

**Warum die drei Nicht-Emissionen ohnehin nicht ins Lastenheft gehören.** **Keine** von ihnen
trägt einen Auflösungs-Trigger — das ist die Definition des Werts, den sie führen; an seiner
Stelle tragen sie die **Re-Evaluierungs-Trigger der ADR**, die niemand herbeiführt, sondern
bemerkt. Das Lastenheft ist das **vertraglich abnahmebindende** Stratum, und eine **permanente
Nicht-Umsetzung** ist darin ein Widerspruch in sich: sie stünde als Klausel, die nie abgenommen
wird. Das Gefäß folgt dem Gegenstand
([`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md)): eine begründete, **permanente**
Nicht-Umsetzung gehört in die ADR — sie ist das einzige Gefäß, das Geltungsbereich, Begründung und
Dauer zugleich trägt. Dieses Argument steht unabhängig vom Ausgang oben — es trüge auch dann, wenn
ein CR daneben stünde.

### Warum keine Auflösungs-Trigger, sondern drei ADR-Verdikte

**Der Trichter aus Modul 7 (§Werkzeug-Wahl bei Diskrepanz) ist beide Fragen weit zu gehen**, und
die Plan-Ebene hält hier nur fest, welchen Ausgang er nimmt — die Begründung schuldet die ADR.

**Frage 1 (Granularität) leitet nicht auf die BF-Sub-Area-Markierung.** Ihr Symptom-Muster ist
*„Code existiert vor Doku"*; hier ist es **invertiert** — das vollständig emittierte Regelwerk
existiert vor jedem Träger, und ein frisch gebootstrapptes Ziel ist der reinste Greenfield-Fall,
den dieses Werkzeug erzeugen kann. Der Träger passt zudem nicht: der Adaptions-Block registriert
Abweichungen **dieses** Repos von seiner Baseline, und die emittierte Ebene ist keine Sub-Area
dieses Repos, sondern ein fremdes Repo, das wir nicht betreiben.

**Frage 2 (Temporalität) fällt auf *Nein*.** Die Schwelle, die die Frage wieder öffnete, hieße
*die Erfassung läuft ohne Kompilat*. Sie ist am Bestand ablesbar — und nicht ernst zu erreichen:
ihre Ausgänge sind **abgezählt**, und jeder trägt sein eigenes Argument und seine eigene
**Trigger-Art** (Messung · Eigenschaft des Gegenstands · Entscheidung dieses Repos · fremder
Vertrag). **Die Abzählung selbst schuldet die ADR, und sie steht dort — verwiesen, nicht
abgeschrieben.** Eine zweite Fassung derselben Abzählung hier wäre die zweite Wahrheit, die
driftet; und weil die Ausgänge einzeln widerlegbar sind, driftete sie an genau der Stelle, an der
der Trichter-Ausgang hängt. Was die Plan-Ebene festhält, ist der **Ausgang**: Frage 2 fällt auf
*Nein*.

**Was nach der Abzählung übrig bleibt, sind fremde Verträge** — das Agenten-Werkzeug führt seine
Telemetrie selbst, oder ein Hook-Ereignis liefert eine Form ohne eigenen Parser. Beides kann
eintreten; niemand von uns führt es herbei. Ein Auflösungs-Trigger wäre damit die Frist, die
niemand einlösen kann — nach Modul 7 die permanente Ausnahme, die behauptet, temporär zu sein. Die
Zellen tragen deshalb **ADR-Verdikt** und zeigen auf **Re-Evaluierungs-Trigger**.

**Die zwei abgeleiteten Zellen folgen mit, und ihre Kopplung ist zu benennen, nicht zu
verdoppeln.**

- **Die Rollen-Typen** hängen an Block 1: `agent.role` ist Pflichtfeld genau dieses Blocks, ohne
  Erfassung im Ziel hat die Rolle dort keinen Abnehmer, und **ohne Abnehmer wären die sechs
  Dateien eine Behauptung** — die Klasse, die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
  Ebene höher verbietet. Rollenlos wird das Ziel dadurch nicht: es bekommt die Workflow-Commands
  und den Reviewer-Skill; was fehlt, ist allein der rollen-benannte **Span**.
- **Token-Attribution und Cache-Counter** hängen an einer **Konjunktion aus zwei benannten
  Gliedern** — dem **Erfassungs-Glied** (*erfasst das Ziel überhaupt?*) und dem **Zähler-Glied**
  (*trägt ein `Agent`-Span Rolle und Zähler?*). Die Benennung ersetzt die Ordinalzahl mit Absicht:
  *erstes* und *zweites Glied* zeigen je nach Leserichtung auf verschiedene Seiten, und wer sie
  verwechselt, erklärt eine offene Frage für permanent entschieden. Das **Erfassungs-Glied** ist
  nach dem Obigen permanent verschlossen, also ist die Konjunktion keine Schwelle.
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) ist die **Vorbedingung des
  Zähler-Glieds** und ausdrücklich **kein** Auflösungs-Trigger dieser Zellen:
  ein Carveout endet nach Modul 7 in **beiden** Ausgängen in `done/` — aufgelöst per `git mv` oder
  in eine Folge-ADR überführt —, und eine Zelle, die auf ein abgeschlossenes Artefakt als offenen
  Trigger zeigt, gibt keine Auskunft mehr darüber, ob sie offen oder erledigt ist. Die Zelle zeigt
  stattdessen auf die **Frage**, die er stellt: *trägt ein `Agent`-Span wieder Rolle und Zähler?*
  Beide Ausgänge dieser Frage sind Re-Evaluierungs-Trigger der ADR.

### Dateien

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr/`](../../adr/) | neu | die ADR aus DoD (1) samt Index-Eintrag; Architect-Commit |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | keine Anforderung wird bewegt (gemessen oben); der Nachweis ist `git diff --stat` über den ganzen Slice, nicht eine Zusicherung in Prosa |
| `internal/emit/**`, [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh), `test/mutations/` | **unverändert** | die Neutralisierung der emittierten Dokumente ist [slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md), der Beleg und die Konfiguration des Trägers sind `slice-063`. Ein Slice, der entscheidet **und** belegt, hätte den Beleg im selben Lauf wie die Entscheidung — genau die Trennung, die [welle-09](../welle-09-modul-15-konformitaet.md) mit *Erprobung → Entscheidung → Emission* zieht |

## 4. Trigger

**`open` → `next`:** die Auftraggeber-Entscheidung liegt vor (2026-08-16). Sie ist die
Eintritts-Bedingung, kein anderer Slice.

**Zwei Vorbedingungen, die dieser Slice ausdrücklich NICHT hat** — beide Fragen stellt
[welle-09](../welle-09-modul-15-konformitaet.md) an den Schnitt, hier stehen die Antworten:

1. **`slice-061` (Doku-Konsistenz im Repo) ist keine Eintritts-Bedingung für die
   *Entscheidung*** — wohl aber für den *Beleg*. Die Erprobungs-Regel der Welle (*„ein
   Mechanismus, den wir ungeprüft emittieren, verstößt gegen die eigene Regel"*) bindet
   `slice-063` — und sie greift hier besonders scharf: **derselbe** Träger,
   **dieselbe** Konfigurations-Frage, einmal im Repo und einmal im Ziel. Auch der Dogfood bindet
   sein [`d-check.mk`](../../../../d-check.mk) per `include` ein und liefe damit in dasselbe
   fail-closed (§6). Die ADR trägt die Folgepflicht. Andernfalls wartete ein lieferbarer Slice
   auf den nächsten, was Modul 5 §Ziel-Form ausschließt.
2. **Die Korrektur von
   [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) ist keine
   Eintritts-Bedingung.** Die Begründung der ADR ruht auf dem **vendored Vorlagen-Wortlaut**
   (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, der die
   Baseline-Aussage auf Verzeichniskonvention, Lifecycle-Regeln, Carveout-Disziplin und
   ID-Schema eingrenzt) — der primären Quelle, netzlos zitierbar —, **nicht** auf unserer
   überzogenen Fassung. Damit ist die ADR von der Korrektur unabhängig; der Nebenbefund selbst
   bleibt bei `slice-064`, und er ist hier benannt statt vorausgesetzt.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die ADR den Wert *emittiert* für Block 4 nur vergeben kann, indem
  sie die Konfiguration des Trägers selbst festlegt (§6, zweites Hindernis) — dann sind
  Entscheidung und Konfigurations-Entwurf zwei Schnitte, und der zweite braucht die Messung an
  einem frisch gebootstrappten Ziel, die dieser Slice bewusst nicht führt.
- `in-progress` → `open`: falls einer der abgezählten Ausgänge der Schwelle *„die Erfassung läuft
  ohne Kompilat"* währenddessen fällt — etwa weil das Agenten-Werkzeug seine Telemetrie selbst
  führt (§3; die Abzählung führt die ADR). Dann trägt Frage 2 des Trichters
  wieder *Ja*, drei Zellen wechseln von **ADR-Verdikt** zurück auf *nicht emittiert mit
  Auflösungs-Trigger*, und das ist eine andere ADR-Frage als die hier gestellte. **Der Ausgang von
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) ist es dagegen NICHT:** er berührt
  nur das **Zähler-Glied** der Konjunktion; das **Erfassungs-Glied** bleibt geschlossen, und die
  zwei Zellen bleiben, wo sie sind.

## 5. Closure-Trigger

DoD vollständig; die ADR **Accepted** nach Review (Modul 10) mit ausgestelltem Verdikt;
Verifikation bestätigt (Modul 11); `make gates` grün;
[`spec/lastenheft.md`](../../../../spec/lastenheft.md) über den ganzen Slice unangetastet —
nachprüfbar mit `git log --stat -- spec/lastenheft.md`; `git mv` nach `done/` (eigener
Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Träger liegt im Ziel und schweigt — gemessen, und es ist das erste von zwei
  Hindernissen vor dem Wert *emittiert*.** Das Modul `targets` wertet erst aus, wenn ein
  `targets:`-Block es beschickt (`makefiles:` · `doc-tables:` · `authority:`); die
  Startkonfiguration des Werkzeugs führt ihn auskommentiert mit, und die emittierte
  `.d-check.yml` führt ihn **gar nicht**. Sonde im Arbeitsbaum, zurückgenommen: eine Tabelle mit
  zwei erfundenen `make`-Zeilen liefert unter der heutigen Konfiguration `0 Befund(e)`, Exit 0;
  mit `targets: {makefiles: [Makefile], doc-tables: [<sonde>]}` liefert dieselbe Tabelle
  `2 Befund(e)` der Art `gate-phantom`, Exit 1. **Ein `make doc-targets` im frischen Ziel ist
  heute also nicht grün, sondern stumm** — genau die Falle, die
  [welle-09](../welle-09-modul-15-konformitaet.md) §3 für die Tool-Spalte benennt, eine Ebene
  tiefer.
- **Das zweite Hindernis ist die Fragment-Architektur, und es ist fail-closed.** Das Modul liest
  **nur** die in `makefiles:` genannten Dateien und folgt `include` **nicht**: dieselbe Sonde
  meldet `docs-check` und `doc-targets` als `gate-phantom`, obwohl beide real sind — sie stehen
  im eingebundenen [`d-check.mk`](../../../../d-check.mk), nicht im
  [`Makefile`](../../../../Makefile). Globs trägt das Feld nicht:
  `makefiles: [Makefile, "*.mk"]` endet mit *„das Modul targets kann das Makefile \"\*.mk\" nicht
  lesen (DC-FA-TGT-001, fail-closed)"*. Der emittierte Harness hält seine Gate-Belange aber
  gerade als Fragmente (`harness/mk/*.mk` plus die tool-generierten `d-check.mk`/`a-check.mk`),
  und **welche** davon existieren, hängt an `--lang`/`--arch`. Ein statischer `targets:`-Block
  müsste jede Fragment-Datei einzeln nennen und stürbe fail-closed an jeder Bootstrap-Variante,
  die eine davon nicht hat. **Das ist die Frage, die die ADR beantworten muss, bevor die Zelle
  den Wert *emittiert* trägt** — und sie ist eine Architektur-Frage, weil sie die
  Doc-Gate-Konfiguration an die Fragment-Assembly koppelt, nicht ein Konfigurations-Detail.
- **Bericht oder Gate ist entschieden; die Messung dahinter bleibt trotzdem ein Befund.**
  Auftraggeber-Setzung: der Träger bleibt **advisory**, die Verdrahtung in `make gates` des Ziels
  ist die verworfene Alternative. Damit kollidiert er nicht mehr mit
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) /
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) —
  aber der Bestand, den die Messung fand, ist unverändert falsch: die zwei Vorlagen, die ein Ziel
  bei Init bekommt (`.harness/baseline/v3.5.2/templates/AGENTS.template.md` und
  `.harness/baseline/v3.5.2/templates/harness/README.template.md`), behaupten in ihren
  Gate-Tabellen **20 Nennungen** von **9 verschiedenen** `make`-Zielen (2026-08-16 ausgezählt:
  `grep -noE 'make [a-z][a-z0-9-]+'`; gezählt sind Nennungen, nicht Tabellenzeilen).
  **Init-invariant sind zwei** — `gates` und `help`. **Sieben nicht**, und sie
  zerfallen in zwei ungleiche Hälften: `arch-check`, `ci`, `coverage-gate`,
  `coverage-gate-critical` und `fullbuild` existieren in **keiner** Variante (`arch-check` auch
  dann nicht, wenn ein Arch-Gate emittiert wird — das Target heißt dort `a-check`), `lint` und
  `test` **nur** mit `--lang`, im Code-Gate-Fragment `harness/mk/<lang>.mk`
  ([`internal/gen/golang.go`](../../../../internal/gen/golang.go),
  [`internal/gen/cpp.go`](../../../../internal/gen/cpp.go)). Die Zahlen sind aus den
  Emissions-Quellen **gerechnet**, nicht an einem frischen Ziel gemessen — wer auf ihnen aufbaut,
  misst sie dort zuerst nach. **Und die zwei Vorlagen sind nicht der ganze Bestand:** derselbe
  Befund steht in einem dritten emittierten Dokument — `.harness/skills/closure-note-reviewer.md`
  behauptet zweimal `make verify-closure-notes`, ein Ziel, das in keiner Bootstrap-Variante und
  auch in diesem Repo nicht existiert. Der Gegenstand ist deshalb der **Dokument-Satz** und keine
  Aufzählung von Fundorten ([slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md) §1).
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  (*laut falsch schlägt leise falsch*) ist damit nicht erledigt, sondern verschoben: die
  Behauptungen bleiben ein Befund mit eigenem Schnitt, unten.
- **„Gar nicht" ist nicht die einzige Alternative zu „immer" — auch das schuldet die ADR.**
  [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) emittiert
  sein Gate **konditional**: nur ein Ziel, dessen Layout einen Prüfbereich trägt, bekommt es. Auf
  die Erfassung übertragen hieße das: ein Ziel **mit** Sprachskelett bekäme sie, ein sprachloses
  nicht. Die Begründung der Nicht-Emission spricht ausdrücklich vom **sprachlosen** Ziel; die
  ADR hat die konditionale Variante deshalb zu entkräften statt zu übergehen.
- **Der Beleg für Block 4 verlangt beide Richtungen, und keine davon liefert dieser Slice.**
  [welle-09](../welle-09-modul-15-konformitaet.md) §3: ein emittierter Mechanismus, der nie
  feuert, lässt `make full-smoke` ebenfalls grün. `slice-063` schuldet daher (a) das frisch
  gebootstrappte Ziel out-of-the-box grün **und** (b) einen im Ziel **rot gesehenen** Drift — eine
  behauptete Zeile ohne Target, gemeldet als `gate-phantom`, und die Rücknahme danach. Beides
  hängt an den zwei Hindernissen oben: ohne `targets:`-Block ist Richtung (b) nicht erreichbar
  (der Träger schweigt), und solange die Behauptungen im emittierten Bestand stehen, ist
  Richtung (a) für **`make doc-targets` selbst** nicht zeigbar — `make gates` bleibt grün, der
  Träger meldet Grundrauschen. Der Beleg wäre dann „rot, und zwar immer", und das ist keiner.
  **Dazu kommt eine Varianten-Klammer:** der Beleg ist in **beiden** Bootstrap-Varianten zu
  führen, und im sprachlosen Ziel **vor** dessen `add-lang`-Schritt — sonst misst er die Variante
  nie, die er zu decken behauptet
  ([slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md) §6, am Voll-Smoke gemessen).
- **Die Behauptungen sind ein eigener Schnitt — und er ist Mitglied dieser Welle, nicht
  wellenlos.** Sie sind ein Befund **unabhängig** von Modul 15: die emittierten Dateien
  sind heute falsch, ob sie jemand prüft oder nicht, und sie verletzen die erste Hälfte von
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (*„Jeder emittierte Gate-Target läuft auf frischem Checkout"*), die deren Messmethode
  (`make gates`, Exit 0) nicht sieht. **Und sie sind zugleich die Vorbedingung der Emission von
  Block 4** — ohne sie ist die Zelle *Doku-Konsistenz-Drift × Tool* nicht belegbar, und ein
  Closure-Trigger dieser Welle hinge an einem Nicht-Mitglied ohne Eintritts-Trigger. Der Schnitt
  liegt deshalb als
  [slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md) in `open/` und **in** dieser
  Welle. Drei Gründe trennen ihn von diesem Slice und von `slice-063`:
  (1) er liegt in einer anderen Vertikale — die Kurs-Vorlagen sind nach
  [welle-09](../welle-09-modul-15-konformitaet.md) §6 ausdrücklich **nicht** unser Gegenstand,
  und der Ausweg ist die emit-seitige Neutralisierung, die
  [`internal/emit/templates.go`](../../../../internal/emit/templates.go) für die Roadmap-Vorlage
  bereits vormacht (die Kurs-Korrektur bleibt durch die immutable vendored Baseline versperrt,
  [`AGENTS.md`](../../../../AGENTS.md) §3.4); (2) in `slice-063` gäbe er einen zweiten
  Liefergegenstand neben dem Beleg; (3) **keine Auftraggeber-Frage** — er bewegt keine
  Anforderung, sondern stellt eine bestehende her. **Kein Grund ist dagegen, dass
  [slice-073](../open/slice-073-emittierte-doc-gate-module.md) DoD (3) ihn schon abnähme** — das trägt
  nicht: dessen Auflösungs-Trigger nennt zwei
  `codepath-missing`-Stellen der emittierten AGENTS- und Konventions-Datei, die Gate-Ansprüche
  liegen in der AGENTS-Vorlage und der Vorlage von
  [`harness/README.md`](../../../../harness/README.md). Dieselbe Klasse und derselbe Ausweg,
  aber andere Befund-Art und nur **eine** gemeinsame Vorlage — wer sie gleichsetzt, hakt eine
  fremde Nicht-Emission an einer Messung ab, die sie nicht getroffen hat.
- **Nicht in diesem Slice:** der Beleg selbst (`slice-063`), die Repo-Seite von Block 4
  (`slice-061`), die emittierte Modul-Liste von `.d-check.yml`
  ([slice-073](../open/slice-073-emittierte-doc-gate-module.md) — sie nimmt `targets` ausdrücklich
  nicht), die Neutralisierung der Behauptungen im emittierten Dokument-Satz
  ([slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md)), die Rechnung hinter
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md), und jede Migration für bereits
  gebootstrappte Ziele: die emittierten Konfigurationen sind *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)), ein bestehendes Ziel bekommt nichts davon —
  auch keinen `targets:`-Block.
- **Ebenfalls nicht hier, und ausdrücklich benannt statt vergessen: die drei
  Abwesenheits-Wächter.** Drei Zellen tragen *ADR-Verdikt*, und dieser Wert verlangt nach
  [welle-09](../welle-09-modul-15-konformitaet.md) §3 **keinen** Sensor — die Verbindlichkeit
  trägt die Entscheidung. Baubar ist er trotzdem, und das ist eine Feststellung, keine Vermutung:
  `internal/emit/enforce_test.go` bewacht bereits eine **Abwesenheit** im gebootstrappten Ziel
  ohne jede geschlossene Datei-Liste (`os.Stat` nach `Bootstrap`, `t.Errorf`, wenn der Pfad
  existiert). Ein Wächter über *kein `.claude/agents/`*, *kein Span-Emitter*, *kein Token-Bericht*
  hat exakt diese Gestalt. Er ist damit **weder Closure-Bedingung dieser Welle noch dieses
  Slice**, sondern Folgepflicht der Entscheidung — sein Träger ist die ADR, die ihn schuldet, und
  nicht eine Zeile in einem Plan, der schließt.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Die Tool-Spalte der Modul-15-Matrix trägt ihre vier Werte, und ihr Gefäß ist
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) — *Accepted*, damit nach
[`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren. Drei Zellen tragen **ADR-Verdikt**, in
Block 1 für **beide** Abweichungen: die Erfassung und die Rollen-Typen unter `.claude/agents/`.
Die vierte, *Doku-Konsistenz-Drift × Tool*, trägt **emittiert** mit `make doc-targets` als Träger
— **festgelegt, nicht belegt**, mit benanntem Gegen-Ausgang. An die Stelle der Auflösungs-Trigger
treten die Re-Evaluierungs-Trigger der ADR: sie werden bemerkt, nicht herbeigeführt. Damit ist
auch die Frage beantwortet, die [slice-060](slice-060-rollen-achse.md) hierher übergeben
hat — die Rollen-Typen gehen **nicht** mit, und dauerhaft: ohne Erfassung im Ziel hat `agent.role`
dort keinen Abnehmer.

**Zwei beobachtbare Closure-Kriterien.**

1. **Der Liefergegenstand liegt eingefroren vor.**
   [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) führt den Status *Accepted* und die
   vier Werte in einer Tabelle; die Index-Zeile in [`docs/plan/adr/README.md`](../../adr/README.md)
   trägt denselben Status. Der Closure-Trigger (§5) verlangt *„Accepted nach Review (Modul 10) mit
   ausgestelltem Verdikt"*: drei Runden haben je ein Verdikt ausgestellt, alle drei liegen als
   Zeitdokumente unter [`docs/reviews/`](../../../reviews/), und die blockierende Menge der letzten
   Runde ist **vor** dem Einfrieren gezogen.
2. **Die Verifikation (Modul 11) bestätigt die DoD mit selbst gefahrenen Sensoren.**
   [Report](../../../reviews/2026-08-21-slice-062-verify.md): `make gates` Exit 0
   (`baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: … 0 Befund(e)`, bats ohne `not ok`,
   `comment-claims: … 0 Befund(e)`, `span-check` ok); die acht Bestandteile von DoD (1) einzeln in
   der ADR aufgesucht; die vier blockierenden MEDIUM der letzten Runde per
   `git show --unified=0 325411c` **unabhängig nachgemessen** (sieben Hunks, blockierende Menge
   vollständig gedeckt), und die einzige Zahl darin am Bestand nachgerechnet. DoD (3) in beide
   Richtungen: `git log --stat --since=2026-08-16 -- spec/lastenheft.md` leer, jüngste Berührung
   des Vertrags-Stratums am 2026-07-28 — neunzehn Tage vor dem Schnitt.

**Wo der Liefergegenstand in der Historie liegt.** In `325411c`: drei Dateien, alle
Architect-Artefakte, Rolle in der Message. [`AGENTS.md`](../../../../AGENTS.md) §3.8 bindet auf
**Rollen**-Granularität, nicht auf ADR-Granularität, und ist erfüllt; derselbe Commit trägt
[`ADR-0019`](../../adr/0019-agent-guard-prueft-die-aufrufform.md) mit und entsperrt damit
[slice-086](../in-progress/slice-086-vordergrund-per-updatedinput.md). Wer den Liefergegenstand dieses
Slice in der Historie sucht, findet ihn nicht allein — für die Closure-Buchführung festgehalten,
nicht als Fund.

**Was der Slice nicht deckt.**

- **Die vierte Zelle ist festgelegt, nicht belegt.** *emittiert* verlangt nach
  [welle-09](../welle-09-modul-15-konformitaet.md) §3 *im Ziel vorhanden **und dort rot gesehen***;
  beide Hälften stehen aus. Der Gegen-Ausgang ist benannt, damit ein ausbleibender Beleg keine
  leere Zelle hinterlässt.
- **Kein Sensor über den drei Nicht-Emissionen.** Für *ADR-Verdikt* ist keiner geschuldet — die
  Verbindlichkeit trägt die Entscheidung. Baubar ist er trotzdem; er ist Folgepflicht der ADR,
  nicht Closure-Bedingung.
- **Nichts an der emittierten Ebene selbst.** Kein Emissions-Pfad, kein Wächter, keine
  Mutations-Datei wurde berührt — deshalb tragen `make mutate`, `make smoke` und `make full-smoke`
  über diesen Slice nichts aus und stehen im Closure-Trigger der **Welle**, nicht in dem dieses
  Slice.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Ein Lifecycle-Trigger nennt ein Ereignis. Steht in der Zeile `next → in-progress` nur das
WIP-Limit, steht dort eine Bedingung — sie sagt, wann der Übergang *erlaubt* ist, nicht wann er
*fällig* ist.** Schreibt zusätzlich eine **fremde Rolle** den einzigen Liefergegenstand, fällt der
Eintritt hinter dessen Fertigstellung, und `in-progress` deckt null Minuten der Arbeit ab, die es
benennt.

**Gemessen an diesem Slice, nicht postuliert.** Der Schnitt legte die Datei am 2026-08-16 um 13:09
in `open/` (`430f358`). Der Liefergegenstand entstand und wurde geprüft zwischen 13:55 (`3e1939e`,
*Proposed*) und 19:34 (`325411c`, *Accepted*) — die Slice-Datei lag diese fünf Stunden und
39 Minuten in `open/`, samt der drei Fortschreibungen, die der Plan darin erhielt (`6b27edf`
13:31, `af73707` 17:37, `0b6c676` 18:43). Die drei
Lifecycle-Commits `f74e267` (`open → next`), `c1c1d49` (`next → in-progress`) und `ed11fab`
(Link-Reconciliation) tragen alle den 2026-08-21, 15:27 — **dieselbe Minute**, fünf Tage nachdem
der Liefergegenstand eingefroren war.

**Was daran nicht Buchführung ist.** §4 weist zwei Rückführungen aus `in-progress` aus. Beim
Eintritt konnte keine von beiden den Liefergegenstand noch bewegen: eine Accepted-ADR ist nach
[`AGENTS.md`](../../../../AGENTS.md) §3.4 immutabel, jeder Ausgang wäre eine **neue** ADR gewesen.
Ein Zustand, dessen Rückkanten beim Eintritt unerreichbar sind, ist keine Station der State
Machine, sondern ein Stempel. Das WIP-Limit hat dabei nichts bewacht: `git ls-tree` über
`docs/plan/planning/in-progress/` liefert bei `3e1939e` wie bei `325411c` **nur die Roadmap** —
das Limit war frei, während die Arbeit lief, und wurde erst fünf Tage später in Anspruch genommen.

**Anwendung, prüfbar am Text:** Wer in §3 die Spalte *Wer was schreibt* führt und den einzigen
Liefergegenstand in eine **fremde** Rollen-Zeile setzt, formuliert die `next → in-progress`-Zeile
als **Ereignis dieser Rolle, das vor ihrem Ergebnis liegt** — für eine ADR: *sie existiert als
Proposed*. Das WIP-Limit steht daneben, als Bedingung. Die Probe ist eine Frage an den eigenen
Entwurf: **welches Ereignis lässt diesen Zustand beginnen, und liegt es vor dem Closure-Trigger?**
Fällt die Antwort mit dem Closure-Trigger zusammen — hier trug *die ADR ist Accepted* beides —,
ist der Zustand leer, bevor er betreten wird.

**Ebene und Träger, benannt statt behauptet.** Die Regel gilt der **Repo**-Ebene, als
Planner-Disziplin beim Schnitt; über den emittierten Harness sagt sie nichts. **Kein Sensor sieht
sie:** ihr Prüfbereich wäre der Abstand zwischen dem `next → in-progress`-Commit und den Commits
am Liefergegenstand, und **welche** Datei der Liefergegenstand ist, steht nur in Prosa (§3). Ihr
Träger ist deshalb der nächste Schnitt derselben Bauart — im heutigen Bestand
[slice-082](../open/slice-082-adaptions-durchgang.md), dessen §3 zwei Norm-Artefakte in die
Architect-Zeile legt und dessen §4 für `next → in-progress` kein Ereignis nennt. Ohne diesen Griff
bleibt der Eintrag ein Satz in einer Datei, die niemand wieder liest.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| *Doku-Konsistenz-Drift × Tool* trägt einen Wert, dessen **beide** Hälften geschuldet bleiben (vorhanden · rot gesehen) | `slice-063`, dessen Eintritt [slice-087](../open/slice-087-emittierte-doku-tische-init-invariant.md) abfragt. Bleibt der Beleg aus, greift der Gegen-Ausgang: die Zelle fällt auf *nicht emittiert*, und ihr Auflösungs-Trigger ist der konfigurierte Träger |
| Die drei Abwesenheits-Wächter (kein `.claude/agents/`, kein Span-Emitter, kein Token-Bericht im Ziel) | Folgepflicht der ADR. Nach [welle-09](../welle-09-modul-15-konformitaet.md) §3 **kein** Closure-Kriterium: der Wert *ADR-Verdikt* verlangt keinen Sensor |
| [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) bleibt offen — Vorbedingung des **Zähler-Glieds**, ausdrücklich **kein** Auflösungs-Trigger der Tool-Zellen | das Carveout-Audit der Wellen-Closure (Modul 7), nicht dieser Slice |
| Festlegung 3 der ADR führt keine mit `Geltungsbereich:` beschriftete Zeile; der Bereich ist aus ihrem Text eindeutig und an Festlegung 1 gekoppelt | keiner. Eine Nachschärfung wäre nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eine neue ADR mit *Supersedes* und stünde in keinem Verhältnis zum Mangel |

**Gates.** `make gates` **Exit 0**: `baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet +
Vollstaendigkeit, netzlos)`, `d-check: 325 Datei(en) geprüft, 0 Befund(e)`, `1..143` bats ohne
`not ok`, `comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`, `span-check: Emitter vorhanden,
ein Span geschrieben, Ablageort git-ignoriert`. `make mutate` ist über diesen Slice ohne Aussage
und nicht gefahren — gemessen, nicht plausibilisiert: die Vereinigung der Dateien über **alle**
Commits dieses Slice (Schnitt, Fortschreibungen, die vier Architect-Commits, die drei
Lifecycle-Commits, diese Closure) liegt **vollständig** unter `docs/plan/`, und von den **37**
eindeutigen `# files:`-Zielen in `test/mutations/` liegt **keines** darin (`comm -12` → 0 Zeilen).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `docs/plan/adr/` und
`spec/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
