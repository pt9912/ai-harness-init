# Slice slice-095: Der Aufschlag je Tool-Call ist gemessen — der Trennungs-Trigger kann feuern

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — er steht zwischen
[slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) und
[slice-096](../open/slice-096-traeger-liegt-im-ziel.md), weil sein Ausgang eine Konstruktions-Eingabe für
alles ist, was danach ins Ziel geht.

**Bezug:**
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — sie setzt die Schwelle:
*50 ms im Median* je Tool-Call, und sie sagt dazu, die Antwort auf ein Reißen sei *„nicht die
Grenze zu erhöhen, sondern der Umfang zu senken"*),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
ihre **Annahme (c)** steht ungemessen, ihre **Folgepflicht 9** ist die Schuld, die dieser Slice
begleicht, und ihr Re-Evaluierungs-Trigger zu (c) sagt selbst: *„ohne sie merkt es niemand, und der
Trigger feuert nie"*),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
Grund, warum die Entscheidung für diese Messung **keine** Fitness-Function-Zeile führt: eine Zeile
über einem nicht existierenden Target wäre der halluzinierte Gate),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(die Messung steht mit ihrem Kommando im Text, sonst ist sie nicht nachfahrbar).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Der Median des Hook-Aufschlags je Tool-Call ist über einen realen Lauf gemessen, gegen die
Schwelle aus [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) gehalten und gegen den
heutigen getrennten Emitter als Vergleichspunkt — und das Mess-Kommando steht neben der Zahl.**

**Warum das ein eigener Slice ist und kein DoD-Punkt woanders.** Der Gegenstand ist eine **Zahl**,
kein Artefakt: sie ändert nichts am Verhalten des Repos und wird auch von nichts erzwungen. Ihr
Wert liegt darin, dass sie eine getroffene Entscheidung entweder trägt oder umstößt — und beides
ist ein Ergebnis, das eine eigene Prüfsitzung verdient. Als vierter Punkt an
[slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) angehängt bräche sie dessen Schnitt
(Modul 5 §Ziel-Form: ≤ 3) und verschwände hinter einem Umbau.

**Warum sie hier steht und nicht am Ende der Welle.** Der Aufschlag ist erst messbar, wenn der Hook
dieses Repos das Produkt-Binär ruft; das tut er nach
[slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md). Und er ist **vor**
[slice-096](../open/slice-096-traeger-liegt-im-ziel.md) zu messen, weil sein negativer Ausgang eine benannte
Antwort hat: **Alternative F** — ein eigenes Emitter-Binär, ins Produkt-Binär eingebettet, mit
denselben vier Konstruktions-Eigenschaften und getrenntem Einstiegspunkt. Das ist ein **anderer
Träger**. Nach der Emission gemessen wäre dieselbe Zahl ein Abriss-Trigger statt einer
Konstruktions-Eingabe.

**Warum ein Vergleichspunkt dazugehört und nicht nur eine Schwelle.** Der Preis, den die
Entscheidung ausspricht, ist relativ: *„der Hook startet je Tool-Call ein **größeres**
Programm"*. Eine absolute Zahl gegen 50 ms sagt, ob die Schwelle hält; erst der Vergleich mit dem
heutigen getrennten Emitter sagt, **was der Umbau gekostet hat**. Reißt die Schwelle schon vor dem
Umbau, ist der Befund ein anderer — dann trägt nicht dieser Weg die Schuld, sondern die Schwelle
steht gegen eine Mechanik, die sie nie halten konnte, und das gehört vor den Architect statt in
eine Rückbau-Entscheidung.

**Was dieser Slice ausdrücklich nicht tut: er baut kein Gate.** Ein Latenz-Gate misst auf geteilten
Runnern die Auslastung des Nachbarn mit; es würde rot ohne Befund und grün ohne Deckung. Ein
rot-ohne-Befund-Gate ist kein halber Wächter, sondern ein Sensor, den man nach dem dritten
Fehlalarm abschaltet — und dann ist die Zusage schlechter gestellt als vorher. Der Slice liefert
ein **wiederholbares Kommando** und eine datierte Zahl, keine Aufhängung.

## 2. Definition of Done

Zwei slice-eigene Punkte — der Gegenstand ist eine Messung, und für den ersten färbt **kein
Kommando** rot; das steht dabei statt einer Zusage
([`AGENTS.md`](../../../../AGENTS.md) §3.6, Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Die Messung liegt vor: Median des Hook-Aufschlags über einen realen Lauf, gegen die
      Schwelle und gegen den Vergleichspunkt gehalten, mit ihrem Kommando im Text.** Real heißt:
      über einer Folge von Tool-Calls, wie sie ein Lauf dieses Repos erzeugt — nicht über einem
      synthetischen Einzelaufruf, dessen Verteilung niemand kennt. Berichtet wird der **Median**
      (so steht es in der Schwelle), und daneben die Streuung, weil ein Median ohne Streuung nicht
      sagt, wie oft der Einzelfall darüber liegt.
      **Rot:** **kein Kommando färbt diesen Punkt rot** — und das ist eine Entscheidung, keine
      Lücke. Ein Sensor existiert heute nicht (`grep -niE 'latenz|latency|median|bench' Makefile
      d-check.mk` → leer, Exit 1), die tragende Entscheidung führt für diese Messung
      **ausdrücklich keine** Fitness-Function-Zeile, und ein neu gebautes Latenz-Gate wäre auf
      geteilten Runnern rot ohne Befund. Verbindlich ist die Messung durch
      [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
      Folgepflicht 9, nicht durch einen Gate — genau so, wie jene Quelle es selbst sagt.
- [ ] **(2) Der Ausgang ist verbindlich verortet, in beide Richtungen.** Hält die Schwelle: Annahme
      (c) ist gemessen statt vermutet, und der Re-Evaluierungs-Trigger zu (c) ist damit **scharf**
      — es gibt eine Zahl, gegen die eine spätere Messung fallen kann. Reißt sie: die Antwort ist
      **nicht** eine höhere Schwelle, sondern Umfang senken oder Einstiegspunkt trennen
      (Alternative F); dann geht ein **Befund an den Architect**, weil eine *Accepted*-Entscheidung
      nicht nachgebessert, sondern durch eine Folge-Entscheidung abgelöst wird
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4) — und
      [slice-096](../open/slice-096-traeger-liegt-im-ziel.md) bis
      [slice-099](../open/slice-099-leser-und-aufraeum-kommando.md) warten auf sie.
      **Rot:** `make gates` — das Mess-Kommando wird als `make`-Ziel abgelegt und ist damit im
      Prüfbereich von `make comment-claims`, das prüft, ob ein in einem Kommentar **genannter**
      Sensor existiert (`sed -n '133,134p' Makefile`); ein Verweis auf ein Ziel, das es nicht gibt,
      färbt rot. Das bewacht die **Existenz** des Kommandos, nicht den Wert der Zahl — und mehr
      soll es nicht.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools`](../../../../harness/tools) — ein Mess-Skript für den Hook-Aufschlag <!-- d-check:ignore (geplante Datei) --> | neu | DoD (1): der Lauf muss wiederholbar sein, sonst ist die Zahl eine Behauptung. Ablageort nach [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) |
| [`Makefile`](../../../../Makefile) — ein Mess-Ziel, **nicht** in der Prerequisite-Kette von `gates` | neu | DoD (2): das Kommando existiert und ist nennbar; eine Aufhängung wäre der Fehlalarm-Sensor aus §1 |
| [`docs/plan/adr`](../../adr) — Befund an den Architect, **nur** im negativen Ausgang <!-- d-check:ignore (bedingtes Artefakt) --> | neu | DoD (2): eine *Accepted*-Entscheidung wird nicht nachgebessert, sondern abgelöst ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors | update | ein neues `make`-Ziel, das **kein** Gate ist, gehört als solches ausgewiesen — sonst liest der nächste Leser es als Zusage |
| [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init) — der Kopf am Unterkommando-Zweig — und der `span-report`-Kopf im [`Makefile`](../../../../Makefile) | update | **Zugewiesener Kommentar-Nachzug** ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Der erste Satz nennt einen Mutations-Fall als Wächter seiner **Position**; der Fall bindet das **Routing** — verschöbe jemand den Zweig hinter `os.Getwd()`, bliebe jeder Test grün. Die Position ist nicht bewachbar und gehört als **Grenze** benannt, wie [`harness/tools/span-check.sh`](../../../../harness/tools/span-check.sh) es zweimal vormacht. Der zweite sagt *„fuer einen Bericht soll niemand einen Container starten muessen"*, während das Rezept über `host-bin` einen startet — er gilt dem Ziel, nicht diesem Rezept. Beide Sätze stehen an dem Einstiegspunkt, den dieser Slice misst; hier sind sie billig und sonst ohne Träger |

## 4. Trigger

**`open` → `next`:** [slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) liegt in `done/` —
erst dann ruft der Hook dieses Repos den Einstiegspunkt, dessen Aufschlag gemessen werden soll.
Beobachtbar ohne Rückfrage: die Plan-Datei liegt in `done/`. **`next` → `in-progress`:** WIP-Limit
frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn die Messung zwei Gegenstände
vermengt — der Aufschlag des Hooks gegen die Laufzeit des Tool-Calls selbst. Dann ist zuerst zu
schneiden, **was** gemessen wird, und erst danach zu messen. `in-progress` → `open`, wenn sich
zeigt, dass der reale Lauf keine reproduzierbare Grundlage hergibt (die Streuung überdeckt den
Unterschied, den der Vergleich zeigen soll) — dann schuldet die Welle eine Entscheidung über die
Messmethode, und dieser Slice wartet auf sie. Beide Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1) und (2) erfüllt mit gefahrenen Kommandos, `make gates` grün, die Zahl samt ihrem Kommando
und ihrem Datum notiert, der Ausgang nach §2 (2) verortet — im negativen Fall mit abgesetztem
Befund an den Architect —, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Die Messung kann die Entscheidung umstoßen, und das ist ihr Zweck.** Fällt sie negativ aus,
  steht [slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) teilweise zum Rückbau und die
  Welle wartet auf eine Folge-ADR. Das ist kein Risiko des Slice, sondern der Grund, ihn früh zu
  fahren: derselbe Ausgang nach der Emission kostet vier Slices statt einen.
- **Eine Zahl ohne genannte Bedingungen ist nicht nachfahrbar.** Host, Auslastung, Kaltstart gegen
  Warmstart und die Zahl der Aufrufe bestimmen den Median mit. Sie gehören neben die Zahl, sonst
  misst die nächste Messung etwas anderes und niemand merkt es
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
- **Der Vergleichspunkt verschwindet mit dem Slice davor.** Nach
  [slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) gibt es den getrennten Emitter nicht
  mehr im Arbeitsbaum; er ist über einen ausgecheckten Vorgänger-Stand zu messen. Wer das erst beim
  Messen merkt, hat nur noch die absolute Zahl — und die beantwortet die Frage *„was hat der Umbau
  gekostet?"* nicht.
- **Die Schwelle bindet den Median, der Betrieb spürt den Ausreißer.** Ein Median unter 50 ms mit
  einem langen Schwanz ist gegen die Schwelle grün und im Gebrauch trotzdem spürbar. Der Slice
  berichtet die Streuung darum mit; sie zu **bewerten** ist nicht sein Gegenstand — dafür gäbe es
  keine entschiedene Schwelle, und eine hier erfundene wäre eine Zusage ohne Quelle.
- **Was dieser Slice nicht misst:** den Aufschlag im **Zielrepo**. Dort läuft dasselbe Bild, aber
  auf fremder Hardware; die Zahl dieses Repos sagt über einen Adopter-Host nichts. Das ist keine
  Lücke des Slice, sondern dieselbe Grenze, die
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) für Annahme (a)
  zieht: was hier läuft, belegt, dass es **hier** läuft.

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

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/tools/` und der
Bau (`Makefile`) gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
