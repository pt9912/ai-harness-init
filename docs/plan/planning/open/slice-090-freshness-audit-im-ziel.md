# Slice slice-090: Das Ziel erfährt, dass sein vendored Baum altert — und warum kein Sensor mitkommt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-11](../welle-11-traeger-aussage.md) — er setzt den Wert der Zelle *Modul 2 ×
Freshness-Audit*, ohne den das Closure-Kriterium der Welle eine leere Zelle behielte.

**Bezug:**
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Regelwerk geht
vollständig ins Ziel — Modul 2 samt seinem Freshness-Audit ist Teil davon),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Content-Pin, den der
Audit überwacht: derselbe Tag → derselbe Baum),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (*„die Laufzeit …
braucht nur git + docker"* — die Schranke, an der ein **mitgelieferter** Sensor scheitert; der
hiesige Träger fährt `curl`),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Aufzählung der emittierten Mechanik — sie wächst hier **nicht**),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(committet-vendored statt gefetcht: die Adaption, die den Audit überhaupt nötig macht),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl mit ihrem Kommando — hier auf den emittierten Text angewandt).

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Ein frisch gebootstrapptes Repo sagt selbst, dass seine vendored Baseline still veraltet, was der
Freshness-Audit ist und dass kein Sensor dafür mitkommt — mit dem Grund.**

**Der Befund, gemessen statt vermutet.** In einem Sonden-Repo (`ai-harness-init --name Probe` in
ein leeres `git init`-Verzeichnis) trifft `grep -rni 'freshness' --exclude-dir=.git
--exclude-dir=baseline . | wc -l` **0** Zeilen — die gesamte lebende Schicht schweigt. Im
mitgelieferten Baum daneben nennt `grep -rlni 'freshness'
.harness/baseline/v3.5.2/regelwerk/ | wc -l` **2** Dateien: Modul 2 schreibt den Audit als
Pflicht-Schritt aus (*„Eine vendored Kopie driftet still von der Quelle weg, sobald ein neues
Kurs-Release erscheint; Pinnen ohne Überwachung ist die halbe Maßnahme"*), Modul 7 verweist darauf.
Der Adopter liest also die Pflicht und findet in seinem Repo nichts, was sie trüge — und nichts,
was ihm sagte, dass sie ihm gehört.

**Warum die Antwort Text ist und kein Skript.** Der hiesige Träger
([`harness/tools/component-freshness.sh`](../../../../harness/tools/component-freshness.sh), von
[`harness/tools/baseline-freshness.sh`](../../../../harness/tools/baseline-freshness.sh)
parametriert) fährt `curl` gegen die Release-Liste. Das liegt außerhalb dessen, was
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) und
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)-AC *Minimal*
dem Ziel zugestehen (*„bash + git + docker"*), und ein Skript wäre zugleich ein neues Artefakt in
der Aufzählung jener Anforderung — beides zusammen ist ein Change Request, nicht ein Slice
([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
**Die Nicht-Emission ist damit keine Nachlässigkeit, sondern eine Aussage** — und genau die fehlt
heute. Modul 2 selbst verlangt für den Audit *„beobachtbarer Auslöser, keine Kalenderpflicht"* und
*„Release-**Liste** prüfen, nicht das Asset"*; beides kann ein Adopter von Hand tun, sobald er
weiß, dass es seine Aufgabe ist.

**Was der Text nicht darf.** Er nennt **kein** `make`-Ziel, das im Ziel nicht existiert — sonst
erzeugt die Reparatur genau die Klasse, die
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) verbietet
und die slice-091 nebenan aufräumt.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6: keine Zusage ohne rot gesehenes Gegenbeispiel).

- [ ] **(1) Das frisch gebootstrappte Ziel nennt den Freshness-Audit als geschuldete Handlung** —
      mit dem gepinnten Tag, der Release-**Listen**-Quelle und der Aussage, dass ein Sensor
      **nicht** mitkommt, weil er `curl` bräuchte.
      **Rot:** `make full-smoke` — eine neue Marker-Prüfung über das Ziel-Repo schlägt fehl, wenn
      die Aussage fehlt; einmal rot gesehen, indem die Zeile emit-seitig zurückgenommen wird.
- [ ] **(2) Die Aussage steht in beiden Bootstrap-Varianten** — sprachlos **und** mit
      `--lang go`. Ein Ergebnis aus *einer* Variante deckt die andere nicht
      ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md): `--lang` ist optional).
      **Rot:** derselbe `make full-smoke`-Lauf, dessen Marker gegen `tmprepo` **und** `tmprepo_doc`
      läuft ([`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) führt beide);
      hängt der Marker nur an einem, fällt der zweite still durch — dann ist die Zusage nicht
      erfüllt.
- [ ] **(3) Der emittierte Datei-Satz wächst nicht** — die Aussage landet in einem Dokument, das
      das Ziel ohnehin bekommt.
      **Rot:** `make test` — die Ziel-Pfad-Liste in
      [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go)
      (`TestTemplates_Layout`) bleibt unverändert; ein zusätzlicher Pfad färbt sie rot.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit`](../../../../internal/emit) — der Schritt, der die Aussage in ein bereits emittiertes Dokument trägt | update | Präzedenz für emit-seitige Nachbearbeitung einer vendored Vorlage liegt vor (`NeutralizeRoadmap` in [`internal/emit/templates.go`](../../../../internal/emit/templates.go)). **Welches** Dokument die Aussage trägt, entscheidet der Implementer am Bestand — Kriterium: es wird in **jeder** Variante emittiert und ein Adopter liest es beim Einstieg |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | Marker-Prüfung über beide Bootstrap-Varianten (DoD 1/2). Marker-Grep als Here-String, nicht `printf \| grep -q` — EPIPE unter `pipefail` (slice-039) |
| `test/mutations/` — ein Fall für den neuen Marker <!-- d-check:ignore (geplante Datei) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: jeder gelistete Wächter braucht seinen Fall, sonst gilt er als unbewacht |

## 4. Trigger

**`open` → `next`:** [welle-11](../welle-11-traeger-aussage.md) ist eingetreten, also liegt
[welle-10](../welle-10-re-baseline.md) in `done/`. **`next` → `in-progress`:** WIP-Limit frei
(kein anderer Slice in `in-progress/`).

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn sich beim Schreiben zeigt, dass die
Aussage die Prozedur der neuen Baseline-Fassung nicht in einem Absatz trägt — dann ist der Schnitt
zu grob, nicht der Text zu kurz. `in-progress` → `open`, wenn die Emissions-Stelle sich nur mit
einem **neuen** Artefakt erreichen lässt: dann trägt der Slice einen Vertragspunkt, den er nicht
entscheiden darf, und die Frage geht an den Architect zurück.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün,
Closure-Notiz in §7 mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die Ziel-Fassung ändert den Gegenstand, und das ist der Grund für den Wellen-Trigger.** Der
  Freshness-Audit wächst upstream von drei auf **sieben** Eigenschaften — gemessen und
  ausgeschrieben in [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) §*Was die
  beiden Fassungen zum Freshness-Audit führen*. Wer diesen Slice vor der Re-Baseline zieht,
  beschreibt eine Prozedur, die das Ziel danach nicht mehr liest. **Der Text nennt darum die
  Eigenschaften nicht einzeln**, sondern verweist auf den Abschnitt im mitgelieferten Baum — sonst
  entsteht eine zweite Fassung, die driftet.
- **Der Ablageort ist offen und gehört zum Slice, nicht zum Plan.** Kandidaten sind die emittierte
  `harness/README.md`, die `AGENTS.md` und der Adaptions-Block der emittierten
  `harness/conventions.md` (dort steht die Baseline-Provenienz bereits als eigener
  Adaptions-Eintrag — **dessen Nummer gehört dem Ziel**, nicht diesem Repo, und wird hier deshalb
  nicht genannt: die gleichlautende Kennung meint hier etwas anderes). Der Plan legt das
  **Kriterium** fest (§3), nicht die Datei — eine Wahl ohne Blick auf den Bestand wäre eine
  Setzung, die der Implementer dann gegen die Messung verteidigen müsste.
- **Kein Kommando misst, ob die Aussage *stimmt*.** Der Marker prüft ihre Anwesenheit, nicht ihren
  Inhalt. Das ist die Grenze des Trägers und wird benannt statt behauptet: die inhaltliche Prüfung
  bleibt der Review-Runde, und ein Sensor dafür ist nicht Gegenstand dieses Slice.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
