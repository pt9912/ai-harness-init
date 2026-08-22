# Slice slice-092: Die Träger-Inventur — je Regelblock ein Wert, Inventar gegen Abdeckung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-11](../welle-11-traeger-aussage.md) — er schließt die Liste und ist damit der
Slice, an dem das Closure-Kriterium der Welle wahr wird. Er läuft **nach**
[slice-090](slice-090-freshness-audit-im-ziel.md) und
[slice-091](slice-091-vendored-baum-ohne-anspruch.md), deren Werte er entgegennimmt statt sie zu
erarbeiten.

**Bezug:**
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das Regelwerk geht
vollständig ins Ziel — diese Inventur ist die Aussage darüber, was davon dort trägt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (nichts
behaupten, was nicht läuft — hier auf die **Abwesenheit** angewandt: eine Regel ohne Träger, die
sich nicht als solche zu erkennen gibt, ist dieselbe Lüge mit umgekehrtem Vorzeichen),
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Aufzählung der emittierten Mechanik — sie wächst hier **nicht**; die Schranke, an der der Slice
gemessen wird),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
die Zusage, die ein Text nicht bricht, ein Sensor aber bräche),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (**Accepted** — sie setzt die Werte für
die vier Modul-15-Zellen und benennt in ihren Konsequenzen die Grenze, die dieser Slice schließt:
*„Und das Ziel erfährt es nicht"*; ihre Auslegung ist die Eintritts-Vorfrage, §6),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — der Nenner misst seinen Gegenstand, nicht sein Umfeld).

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Das gebootstrappte Repo führt je Abschnitt seines mitgelieferten Regelwerks einen Wert dazu, ob
ein Träger mitkommt — vollständig über das Verzeichnis, nicht über die auffälligen Fälle.**

**Der Wert-Vorrat ist geschlossen, drei Werte:**

| Wert | Bedeutung | Beispiel nach heutigem Stand |
|---|---|---|
| **Träger kommt mit** | die Mechanik oder Ziel-Form liegt im Ziel und ist dort benutzbar | Modul 10 §Ziel-Form: Reviewer-Skill — `.harness/skills/reviewer.md` wird emittiert |
| **liegt bei, nicht verdrahtet** | der Träger ist da, hängt aber an keinem Trigger | Modul 15 §Doku-Konsistenz-Drift — `doc-targets` existiert im Ziel, `modules:` führt ihn nicht |
| **kommt nicht mit** | mit Grund und Dauer; bei permanenter Entscheidung mit Zeiger auf die ADR statt auf einen Auflösungs-Trigger | Modul 15 §Erfassung — [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) Festlegung 1 |

**Vollständigkeit heißt Inventar gegen Abdeckung.** Der **Nenner** wird zur Laufzeit gelesen
(`ls .harness/baseline/*/regelwerk/*.md | wc -l` im gebootstrappten Ziel), nicht notiert. Eine
notierte Zahl bräche beim nächsten Baseline-Sprung, ohne dass am Gegenstand etwas bricht —
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2 schließt genau diese Form von Erwartungswert aus. Dieselbe Lücke — *kuratierte Liste
statt Inventar* — führt die Roadmap seit dem 2026-07-25 als eigenen Kandidaten, und
[welle-10](../welle-10-re-baseline.md) hängt ihren Adaptions-Durchgang an dieselbe Mechanik.

**Was verwiesen und nicht abgeschrieben wird.** Wo
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) den Wert schon gesetzt hat — die vier
Modul-15-Blöcke und die Rollen-Typen —, zeigt die Inventur auf die Entscheidung. Eine zweite
Fassung derselben Festlegung wäre die zweite Wahrheit, die driftet; und sie stünde in einem
emittierten Dokument, das kein Lauf dieses Repos je gegen die ADR hält.

**Was der Slice ausdrücklich nicht ist.** Kein Sensor, der Träger und Regel automatisch aufeinander
abbildet. Der Nenner ist mechanisch, die **Zuordnung** ist ein Urteil — sie mechanisch auszugeben
hieße, ein Muster als Kriterium zu verkaufen, das keines ist
([`AGENTS.md`](../../../../AGENTS.md) §3.6). Bewacht wird die **Abdeckung**, nicht die Richtigkeit
der Zuordnung; die Grenze steht in §6.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Jeder Abschnitt des mitgelieferten Regelwerks trägt im Ziel genau einen der drei
      Werte** — Nenner zur Laufzeit gelesen, keine leere Zelle.
      **Rot:** `make full-smoke` — die Prüfung zählt die Regelwerk-Dateien des gebootstrappten
      Ziels und hält sie gegen die belegten Einträge; einmal rot gesehen, indem ein Eintrag
      emit-seitig entfernt wird (die Differenz wird gemeldet, nicht überlesen).
- [ ] **(2) Die Aussage steht out-of-the-box in beiden Bootstrap-Varianten, und ihre Rücknahme
      wird rot gesehen** — beide Richtungen, wie in welle-08 etabliert. Nur die erste wäre die
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle
      eine Ebene weiter.
      **Rot:** `make full-smoke` über `tmprepo` **und** `tmprepo_doc`
      ([`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh)), plus ein
      `test/mutations/`-Fall, der den Wächter entzahnt und ihn rot erwartet.
- [ ] **(3) Kein neues Artefakt: der emittierte Datei-Satz wächst nicht.**
      **Rot:** `make test` — die Ziel-Pfad-Liste in
      [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go)
      (`TestTemplates_Layout`) fällt, sobald ein Pfad hinzukommt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/emit`](../../../../internal/emit) — der Schritt, der die Inventur in ein bereits emittiertes Dokument trägt | update | kein neues Artefakt (DoD 3). Präzedenz für emit-seitige Nachbearbeitung: `NeutralizeRoadmap` in [`internal/emit/templates.go`](../../../../internal/emit/templates.go) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | Abdeckungs-Prüfung Nenner ↔ Einträge über beide Varianten (DoD 1/2) |
| `test/mutations/` — ein Fall für den Abdeckungs-Wächter <!-- d-check:ignore (geplante Datei) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht |

## 4. Trigger

**`open` → `next`:** [slice-090](slice-090-freshness-audit-im-ziel.md) **und**
[slice-091](slice-091-vendored-baum-ohne-anspruch.md) liegen in `done/` — beide setzen einen Wert,
den diese Inventur sonst als offen führte. **`next` → `in-progress`:** WIP-Limit frei **und** die
Eintritts-Vorfrage aus §6 ist vom Architect beantwortet.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn die Inventur in einem Dokument nicht
lesbar bleibt (mehr als eine Bildschirmseite) — dann ist der Gegenstand zu grob geschnitten und
zerfällt nach Phase, nicht nach Schicht. `in-progress` → `open`, wenn die Vorfrage aus §6 gegen die
erste Lesart entschieden wird: dann braucht die Welle eine Folge-ADR, und dieser Slice wartet auf
sie.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün,
`make mutate` grün mit dem neuen Fall, Closure-Notiz in §7 mit Steering-Loop-Eintrag geschrieben.

## 6. Risiken und offene Punkte

- **Eintritts-Vorfrage, und sie gehört dem Architect.**
  [`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) §Konsequenzen schreibt: *„eine
  Deklaration im Ziel wäre ein Artefakt, und genau das ist hier ausgeschlossen — die Grenze wird
  benannt, nicht geschlossen."* Zu entscheiden ist, ob *Artefakt* dort die **neue Datei** meint
  oder **jede Aussage**. Die Messung stützt die erste Lesart — die Entscheidung heißt *„nur Block
  4, ohne neues Artefakt"*, und ein Satz in einem ohnehin emittierten Dokument lässt weder die
  Aufzählung aus
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) noch das
  Budget aus [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  wachsen. Entscheiden darf das der Slice nicht: die ADR ist ab *Accepted* immutabel
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4), ihre Auslegung ist eine Architektur-Frage. Trägt die
  zweite Lesart, ist dieser Slice blockiert und die Welle schuldet eine Folge-ADR.
- **Bewacht ist die Abdeckung, nicht die Richtigkeit.** Der Wächter zählt, ob jeder Abschnitt einen
  Wert trägt; ob der Wert **stimmt**, prüft er nicht. Das ist benannt statt behauptet — die
  Zuordnung Regel ↔ Träger ist ein Urteil, und ein Sensor darüber wäre der Doku-Konsistenz-Agent
  aus Modul 15, der hier ausdrücklich nicht Gegenstand ist.
- **Die Inventur altert mit dem Baum.** Sie steht deshalb hinter
  [welle-10](../welle-10-re-baseline.md) (§2 der Welle) und nennt ihren Nenner als Kommando, nicht
  als Ziffer. Kommt upstream ein Abschnitt hinzu, meldet der Wächter die Differenz — das ist der
  gewollte Ausgang, kein Fehlalarm.
- **Ein Wert ist fremdbestimmt:** *Doku-Konsistenz-Drift* hängt am Ausgang von slice-063 in
  [welle-09](../welle-09-modul-15-konformitaet.md). Er wird **entgegengenommen**, nicht hier
  entschieden; die Trigger-Reihenfolge stellt sicher, dass er vorliegt.

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
