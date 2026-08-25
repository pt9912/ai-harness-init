# Slice slice-095: Der Aufschlag je Tool-Call ist gemessen — der Trennungs-Trigger kann feuern

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — er steht zwischen
[slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) und
[slice-096](../done/slice-096-traeger-liegt-im-ziel.md), weil sein Ausgang eine Konstruktions-Eingabe für
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
[slice-096](../done/slice-096-traeger-liegt-im-ziel.md) zu messen, weil sein negativer Ausgang eine benannte
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

- [x] **(1) Die Messung liegt vor: Median des Hook-Aufschlags über einen realen Lauf, gegen die
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
- [x] **(2) Der Ausgang ist verbindlich verortet, in beide Richtungen.** Hält die Schwelle: Annahme
      (c) ist gemessen statt vermutet, und der Re-Evaluierungs-Trigger zu (c) ist damit **scharf**
      — es gibt eine Zahl, gegen die eine spätere Messung fallen kann. Reißt sie: die Antwort ist
      **nicht** eine höhere Schwelle, sondern Umfang senken oder Einstiegspunkt trennen
      (Alternative F); dann geht ein **Befund an den Architect**, weil eine *Accepted*-Entscheidung
      nicht nachgebessert, sondern durch eine Folge-Entscheidung abgelöst wird
      ([`AGENTS.md`](../../../../AGENTS.md) §3.4) — und
      [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) bis
      [slice-099](../open/slice-099-leser-und-aufraeum-kommando.md) warten auf sie.
      **Rot:** `make docs-check` — der Ablageort des Mess-Skripts steht in
      [`AGENTS.md`](../../../../AGENTS.md) §4 und in
      [`harness/README.md`](../../../../harness/README.md) §Sensors, und beide Zeilen liegen im
      Prüfbereich des `codepaths`-Moduls
      (`sed -n '/^codepaths:/,/^ *roots:/p' .d-check.yml`): verschwindet die Datei, meldet der
      Lauf zwei `codepath-missing` und endet mit Exit 2. Das bewacht die **Existenz** des
      Mess-Skripts, nicht den Wert der Zahl — und mehr soll es nicht.
      **Gedeckt ist damit die Datei-Achse, nicht die Kommando-Achse, und diese Grenze wird
      benannt statt verschwiegen:** wer allein das `make`-Ziel umbenennt und die Datei liegen
      lässt, hält `make docs-check` und `make comment-claims` grün, und weil der Name in `.PHONY`
      steht, antwortet `make -n hook-overhead` danach mit *„nichts zu tun"* und Exit 0 — das
      versprochene Kommando verschwindet nicht mit einem Fehler, es tut still nichts.
      `make comment-claims` deckt hier **nichts**: auf **Existenz** prüft es allein Go-Testnamen,
      ein `make`-Ziel erkennt sein Sensor-Muster nur der **Form** nach
      (`grep -n '^SENSOR=' harness/tools/comment-claims.sh`).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools`](../../../../harness/tools) — ein Mess-Skript für den Hook-Aufschlag <!-- d-check:ignore (geplante Datei) --> | neu | DoD (1): der Lauf muss wiederholbar sein, sonst ist die Zahl eine Behauptung. Ablageort nach [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption) |
| [`Makefile`](../../../../Makefile) — ein Mess-Ziel, **nicht** in der Prerequisite-Kette von `gates` | neu | DoD (2): das Kommando existiert und ist nennbar; eine Aufhängung wäre der Fehlalarm-Sensor aus §1 |
| [`docs/plan/adr`](../../adr) — Befund an den Architect, **nur** im negativen Ausgang <!-- d-check:ignore (bedingtes Artefakt) --> | neu | DoD (2): eine *Accepted*-Entscheidung wird nicht nachgebessert, sondern abgelöst ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors | update | ein neues `make`-Ziel, das **kein** Gate ist, gehört als solches ausgewiesen — sonst liest der nächste Leser es als Zusage |
| [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init) — der Kopf am Unterkommando-Zweig — und der `span-report`-Kopf im [`Makefile`](../../../../Makefile) | update | **Zugewiesener Kommentar-Nachzug** ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Der erste Satz nennt einen Mutations-Fall als Wächter seiner **Position**; der Fall bindet das **Routing** — verschiebt jemand den Zweig hinter `os.Getwd()`, bleiben `make test-go` und `make span-check` Exit 0. **Kein heutiger Wächter hält die Position:** ein Zahn dafür bräuchte einen Lauf des gebauten Binärs gegen ein gelöschtes Arbeitsverzeichnis, und bis dahin gehört sie als **Grenze** benannt, wie [`harness/tools/span-check.sh`](../../../../harness/tools/span-check.sh) es zweimal vormacht. Der zweite sagt *„fuer einen Bericht soll niemand einen Container starten muessen"*, während das Rezept über `host-bin` einen startet — er gilt dem Ziel, nicht diesem Rezept. Beide Sätze stehen an dem Einstiegspunkt, den dieser Slice misst; hier sind sie billig und sonst ohne Träger |

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

**Was gilt.** Der Aufschlag je Tool-Call ist gemessen, und er hält die Schwelle mit weitem
Abstand. Der Träger — das Produkt-Binär, `wc -c < .harness/state/bin/ai-harness-init` →
**7561376** Byte — liegt im Median bei **2,7 bis 2,8 ms** (`make hook-overhead`); der
Vergleichspunkt, der getrennte Emitter aus `d686787`
(`git worktree add --detach <baum> d686787 && make -C <baum> span-emit-build`, **3199136** Byte),
bei **2,3 bis 2,5 ms**. Die Schwelle steht in
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) an genau einer Stelle
(`grep -c "50 ms" docs/plan/adr/0011-telemetrie-erfassung-policy.md` → **1**). Das Mess-Kommando
existiert und ist nennbar (`grep -c '^hook-overhead:' Makefile` → **1**), es hängt in keiner
Prerequisite-Kette (`sed -n '292p' Makefile | grep -c 'hook-overhead'` → **0**) und in keinem
Workflow (`grep -rn 'hook-overhead' .github/ | wc -l` → **0**); die Zahl samt Bedingungen und
Kommandos steht im Kopf des Mess-Skripts (`wc -l < harness/tools/hook-overhead.sh` → **256**),
[`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md)
§Sensors tragen nur den Zeiger. Alle Zahlen wandern mit ihrem Bestand und sind **kein**
Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Spanne des Verfahrens ist breiter als die einer Sitzung, und jede Zahl gehört neben ihre
Last.** Über alle **unabhängigen** Träger-Läufe zu diesem Slice liegt der Median bei **2,6 bis
3,6 ms**: 2,6 ms im Review (`SAMPLES=50 make hook-overhead`, **ohne Last-Angabe** berichtet — der
untere Rand der Spanne trägt seine Bedingung also nicht), 2,7 · 2,8 · 2,9 · 3,6 ms in der
Verifikation (`make hook-overhead`, der 2,9er als `SAMPLES=815 make hook-overhead`; loadavg 4,17 ·
3,17 · 3,23 · 4,16, in dieser Reihenfolge). Der 2,9-ms-Lauf lief bei loadavg 3,23 und damit
**innerhalb** der Bedingungen, unter denen der Skript-Kopf seine engere Spanne führt; der
3,6-ms-Lauf bei 4,16 lag außerhalb. Die ±0,05 ms des
Umsetzungs-Laufs sind die Streuung **einer** Sitzung, nicht die des Verfahrens. **Die
Schlussfolgerung trägt über die ganze Spanne:** der schlechteste gesehene Median liegt um Faktor
**13,9** unter der Schwelle (`awk 'BEGIN{printf "%.3f\n", 50/3.6}'`), und dieselbe Streuung ist
zugleich der belegte Grund gegen einen Latenz-Gate — derselbe Gegenstand schwankte allein mit der
Nachbar-Last um ein Drittel.

**Was der Umbau gekostet hat.** Gemessen an abwechselnd gefahrenen Paaren **0,3 bis 0,4 ms**, bei
einem Programm, das um Faktor **2,4** gewachsen ist
(`awk 'BEGIN{printf "%.3f\n", 7561376/3199136}'`). Der Preis skaliert nicht mit der Binärgröße.

**Was daraus folgt — und das ist der Zweck des Slice.** **Annahme (c) von
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) ist gemessen
statt vermutet, Alternative F ist nicht herbeigeführt, und
[slice-096](../done/slice-096-traeger-liegt-im-ziel.md) bis
[slice-099](../open/slice-099-leser-und-aufraeum-kommando.md) sind nicht blockiert.** Der negative
Zweig ist korrekt **nicht** gebaut: `git diff --stat f29524c^ f29524c -- docs/plan/adr/` → leer,
kein Befund an den Architect fällig. **Ob die Folgepflicht 9 jener Entscheidung damit als
eingelöst gilt, vermerkt nicht diese Notiz** — eine *Accepted*-Entscheidung wird nicht
nachgetragen, sondern gelesen ([`AGENTS.md`](../../../../AGENTS.md) §3.4); die Messung liegt vor,
die Wertung gehört dem Architect.

**Wo der Liefergegenstand in der Historie liegt.** `git log --oneline --grep='slice-095' aa8e22d
| wc -l` zählt **12** Commits — der Stand gehört ins Kommando, sonst wandert die Zahl mit jedem
weiteren. Die Sache liegt in **einem**: `f29524c`
(`git show f29524c --stat | tail -1` → `5 files changed, 303 insertions(+), 12 deletions(-)`),
neu darin `harness/tools/hook-overhead.sh`. `1b9a4eb` und `4ee70af` sind reine Lifecycle-Moves,
`fa9796d` und `2432091` die Link-Züge danach, `c81fa4a` und `aa8e22d` die Verdikte.

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1) und (2) erfüllt, mit gefahrenen Kommandos.** Bestätigt im
   [Verifikations-Report](../../../reviews/2026-08-25-slice-095-verify.md) §2, mit **acht**
   eigenen Mess-Läufen (fünf am Träger, drei am Vergleichspunkt), allen vier behaupteten Rot,
   drei zusätzlich gefundenen Abbruchpfaden und vier Gegenproben.
2. **`make gates` grün, die Zahl samt Kommando und Datum notiert.** Belege unten unter *Gates*;
   die Zahl steht im Skript-Kopf, ausdrücklich als **kein Erwartungswert** markiert.
3. **Der Ausgang nach §2 (2) verortet.** Positiver Zweig, oben ausgeschrieben; der bedingte
   Architect-Befund war nicht fällig und ist deshalb nicht geschrieben.
4. **Review konform (Modul 10).** [Code-Review](../../../reviews/2026-08-25-slice-095-review.md)
   (`c81fa4a`): **frei**, `grep -c '^### F-' docs/reviews/2026-08-25-slice-095-review.md` → **2**,
   beide MEDIUM und beide ausdrücklich dieser Closure zugewiesen.
5. **Verifikation (Modul 11).** [Bericht](../../../reviews/2026-08-25-slice-095-verify.md)
   (`aa8e22d`): **frei für die Closure**,
   `grep -c '^#### V-' docs/reviews/2026-08-25-slice-095-verify.md` → **4** Befunde, keiner am
   Gebauten, alle am Text.
6. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.

**Was anders lief als geplant: zwei Aussagen des Plans hielten der Messung nicht stand, und beide
sind ersetzt.**

- **Das Rot-Rezept zu DoD (2) beschrieb einen Wächter, den es nie gab.** `make comment-claims`
  prüft auf **Existenz** allein Go-Testnamen; ein `make`-Ziel erkennt sein Sensor-Muster nur der
  **Form** nach (`grep -n '^SENSOR=' harness/tools/comment-claims.sh`), und ein Kommentar mit
  einem erfundenen Ziel läuft grün durch (`41 Datei(en) geprueft, 0 Befund(e)`, Exit 0) — von der
  Umsetzung gemeldet, von Review und Verifikation je unabhängig reproduziert. Die Deckung liefert
  `codepaths` in `make docs-check`, und §2 trägt jetzt sie samt der Achse, die sie **nicht**
  erreicht.
- **§3 sagte *„bliebe jeder Test grün"* und *„die Position ist nicht bewachbar"*.** Gemessen sind
  zwei Sensoren — `make test-go` und `make span-check`, beide Exit 0 nach dem Verschieben des
  Blocks hinter `os.Getwd()` —, nicht *jeder* Test; und ein Zahn ist **möglich**, er bräuchte
  einen Lauf des gebauten Binärs gegen ein gelöschtes Arbeitsverzeichnis. Eine Mengen-Aussage
  ohne Messung und eine Unmöglichkeit ohne Beleg: §3 trägt jetzt beide Male, was gemessen ist.
  Die **Diagnose** des Plans war richtig und ist von der Verifikation bestätigt — der Fall
  `test/mutations/154-unterkommando-routing-vertauscht.sh` bindet das **Routing**, und der
  Kommentar, der ihn als Wächter der **Position** führte, ist mit diesem Slice geheilt.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Der Adopter-Host und der gesättigte Runner bleiben ungemessen.** Beide stehen im Skript-Kopf
  und decken sich mit der Grenze, die
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) für Annahme (a)
  zieht: was hier läuft, belegt, dass es **hier** läuft.
- **Die dritte Grenze steht nicht dort, wo die zwei anderen stehen: auf einem frischen Klon und
  in der CI ist diese Messung nicht nachfahrbar.** Sie braucht den gitignorierten Span-Bestand,
  und ohne ihn bricht das Skript ab, statt eine Folge zu erfinden — deshalb kann die CI diese
  Zahl nie erzeugen. Der Kopf sagt den Mechanismus, nicht die Folge
  (`grep -cniE "frisch|klon|CI\b|Actions" harness/tools/hook-overhead.sh` → **0**). Träger unten.
- **Die Kommando-Achse ist ungedeckt, und im Skript-Kopf ist sie nicht benannt.** §2 dieser Datei
  führt sie jetzt; der Kopf führt die `os.Getwd()`-Grenze vorbildlich als *„GRENZE, benannt statt
  verschwiegen"* und diese nicht. Träger unten.
- **Die Behauptungs-Erkennung von `make comment-claims` ist kleinschreibungs-gebunden.**
  Über denselben Prüfbereich, den der Sensor scannt, tragen **23** Kommentarzeilen in **10**
  Dateien eine Claim-Formulierung ausschließlich in einer Schreibweise, die das case-sensitive
  Muster nicht erkennt; **17** davon liegen in `internal/span/*.go`, `internal/report/report.go`
  und `cmd/ai-harness-init/span_emit.go` — dem Telemetrie-Kern, dessen Zusagen dieses Gate am
  dringendsten tragen soll. Der Reproduktionsweg steht im
  [Code-Review](../../../reviews/2026-08-25-slice-095-review.md) F-1 und ist in der
  [Verifikation](../../../reviews/2026-08-25-slice-095-verify.md) §5.3 auf die Einheit bestätigt.
  **Für diesen Slice ohne Wirkung:** `harness/tools/hook-overhead.sh` trägt kein Claim-Wort in
  irgendeiner Schreibweise
  (`grep -ciE 'garantiert|stellt sicher|bewacht|belegt|sorgt dafuer|sorgt dafür|verhindert' harness/tools/hook-overhead.sh`
  → **0**), und der Kommentar in `cmd/ai-harness-init/main.go` ist auf kleingeschriebenes
  „bewacht" gezogen und liegt damit **im** Prüfbereich. Träger unten.
- **Kein lebendes Artefakt nennt einen Anlass, die Messung erneut zu fahren.** Der
  Re-Evaluierungs-Trigger zu Annahme (c) ist **fahrbar** — es gibt eine Zahl und ein
  wiederholbares Kommando —, aber er feuert weiterhin nur, wenn sich jemand erinnert. Das ist
  **kein** verdeckter Gate-Wunsch: ein Anlass ist kein Gate, und der Grund gegen einen Latenz-Gate
  steht oben mit einer Messung dahinter. Träger unten.
- **Die Payload ist nachgebaut, die Folge ist echt.** Die sieben tragenden Felder decken sich
  fehlerfrei mit der Quelle (**0** Abweichungen von 200, Verifikation §4.3); was eine *echte*
  `Agent`-Payload zusätzlich kostet, ist von niemandem gemessen. Die Zahl bleibt insoweit eine
  **Untergrenze**, und genau so steht sie im Kopf.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Wo der Gegenstand eine Zahl ist, tritt an die Stelle des rot gesehenen Gegenbeispiels die Frage
nach der Richtung: welche Vereinfachung der Methode verschöbe die Zahl auf die Seite, die die
Schlussfolgerung stützt — und tut sie es?**

**Warum [`AGENTS.md`](../../../../AGENTS.md) §3.6 hier nichts sagt.** Sie bindet **Zusagen** und
verlangt, dass benannt und einmal rot gesehen ist, was passieren müsste, damit eine Zusage bricht.
Eine **Feststellung über einen Messwert** hat keine solche Bruchstelle. Dieser Slice spricht das
aus — *„kein Kommando färbt diesen Punkt rot"* — und begründet es auf drei Beinen, die der
Verifikation standgehalten haben. Genau dort endet die Regel, und danach verlangt **nichts** mehr
einen Beleg zweiter Ordnung.

**Die Lücke ist nicht theoretisch.** Eine Messung zu wiederholen heißt, dieselbe Methode noch
einmal zu fahren; ein systematischer Fehler der Methode kommt dabei zuverlässig wieder heraus.
Acht Nachmessungen sagen über eine Verzerrung nichts. Was etwas sagt, ist die Probe auf die
Richtung — und sie ist hier gefahren worden: die Messung spielt eine **reale** Aufruf-Folge mit
**nachgebauter** Payload nach, und die naheliegendste Verzerrung wäre, die teuerste Arbeit des
Emitters wegzulassen (`os.Stat` plus vollständiger SHA-256 über die geschriebene Datei,
`internal/span/emit.go:141`, `fingerprint()`). Gemessen: sie läuft im Nachbau **mit**, an **43**
von **47** betroffenen Aufrufen einer 200er-Stichprobe; die vier Ausfälle sind Dateien, die es
nicht mehr gibt, und die heutigen Dateien sind eher größer als die von damals. Abweichend ist der
**Wert**, nicht die **Arbeit**. Damit ist die Verzerrung **ausgeschlossen statt unterstellt**.

**Warum das weder der Eintrag aus
[slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) noch der aus
[slice-100](../done/slice-100-vorlauf-nennt-den-grund.md) ist.** Beide handeln von einem **Rot**:
dort von seiner **Reichweite** (eine Zusage mit einem *und* hat zwei Bruchstellen), hier von
seinem **Gegenstand** (der Eingriff bewegt etwas anderes als die Zusage). Dieser Eintrag handelt
vom Fall, in dem es **kein Rot gibt und mit Grund keines geben soll**, und fügt der Reihe eine
dritte Achse hinzu: Träger · Reichweite · Gegenstand — und jetzt **Richtung**.

**Träger: [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), als fünfter
Posten — ausdrücklich nicht *„der Architect"*.** Diese Form ist an diesem Repo gemessen kein
Träger: wörtlich vergeben in **3** Closure-Notizen unter `done/`
(`git grep -l '^\*\*Träger: der Architect' -- 'docs/plan/planning/done/*.md' | wc -l`), bewegtes
Artefakt keines. Die Zuständigkeit ist nicht die Lücke — sie steht in
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 —, der **Termin**
ist es, und den gibt in diesem Repo ein Schnitt.
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) ist genau dafür geschnitten,
liegt in `open/` und hat seinen Durchgang noch nicht begonnen; sein §3 verlangt, dass die Liste
**vor** der ersten Entscheidung erweitert wird und dabei steht, woran der weitere Posten erkannt
wurde. Beides ist eingelöst: der Posten steht in **seiner** Datei, mit seiner Herkunft und seinem
Erkennungsmerkmal. **Der Regeltext wird dort nicht vorentschieden** — ob die Schärfung in §3.6
wandert, anders gefasst wird oder mit Grund fällt, entscheidet der Architect am Text; dieser
Eintrag liefert den Befund und den Termin. Die Schärfung **hebt** eine Beleg-Anforderung an und
braucht darum kein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5,
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
*„Gate-Anheben → Steering-Loop"*).

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| Die Behauptungs-Erkennung von `make comment-claims` ist kleinschreibungs-gebunden; **23** Zeilen in **10** Dateien, **17** im Telemetrie-Kern, tragen eine Claim-Formulierung außerhalb des Musters | **[slice-070](../open/slice-070-comment-claims-pruefbereich.md)** — sein Ziel ist, dass die Zeile *„N Datei(en) geprueft, 0 Befund(e)"* sagt, was sie behauptet, und seine §3-Tabelle führt `harness/tools/comment-claims.sh` bereits als `update`. Die Schreibweise ist eine **vierte** Verengung neben den drei, die er zählt; der Posten steht mit seiner Zahl und seinem Kommando in **seiner** Datei |
| Der Skript-Kopf nennt zwei von drei Grenzen, führt seine Median-Spanne enger als seine eigenen Bedingungen hergeben und benennt die Kommando-Achse nicht; und kein Artefakt nennt einen Anlass, die Messung erneut zu fahren | **[slice-102](../open/slice-102-messung-nennt-grenzen-und-anlass.md)** — neu geschnitten. Alle vier liegen an **einem** Artefakt und beantworten **eine** Frage: was sagt die Messung nicht, und wann wird sie wieder gefahren. Ein Kommentar-Nachzug nach [`AGENTS.md`](../../../../AGENTS.md) §3.7 braucht einen Lauf, der die Datei anfasst — und keiner der offenen Slices fährt sie |
| Ein Wächter über die **Kommando**-Achse — dass ein in der Doku genanntes `make`-Ziel existiert | **kein neuer Sensor, und das ist entschieden.** Die Menge *„Inline-Code, der ein `make`-Ziel ist"* ist in diesen Artefakten kein Muster: dieselbe Auszeichnung trägt Kommandos, Feldnamen, Marker und Pfade. Ein Wächter darüber braucht erst ein Kriterium und dann ein Gate; die Frage gehört an den Lauf, der den d-check-Pin bewegt, nicht in diese Closure — dieselbe Abgrenzung, die [slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) für tote Inline-Pfade gezogen hat. Verlangt ist von F-2 die **Benennung** der Grenze, nicht ihr Schließen |
| Der Aufschlag auf einem Adopter-Host und unter Sättigung | **kein Träger, und das ist entschieden** — dieselbe Grenze, die [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) für Annahme (a) zieht. Sie ist im Skript-Kopf benannt; sie zu messen hieße, fremde Hardware zuzusagen |
| Was eine **echte** `Agent`-Payload gegenüber dem Nachbau zusätzlich kostet | **kein Träger, und das ist entschieden** — die Zahl ist als **Untergrenze** ausgewiesen, und die Schlussfolgerung trägt bei Faktor 13,9 auch eine Vervielfachung dieser einen Achse. Wird die Achse je tragend, ist ihr Ort der Skript-Kopf |
| Die Streuung des Schwanzes zu **bewerten** | **kein Träger, und das ist entschieden** — §6 dieser Datei führt es als Nicht-Gegenstand: dafür gibt es keine entschiedene Schwelle, und eine hier erfundene wäre eine Zusage ohne Quelle |

**Folge-Slices: ein neuer `open/`-Eintrag —
[slice-102](../open/slice-102-messung-nennt-grenzen-und-anlass.md).** Alles Übrige hat einen
bestehenden Träger oder eine begründete Ablehnung.

**Gates.** Die [Verifikation](../../../reviews/2026-08-25-slice-095-verify.md) hat sie über dem
Baum bei `c81fa4a` selbst gefahren, die Exit-Codes getrennt erhoben: `make gates` **Exit 0**
(`d-check: 378 Datei(en) geprüft, 0 Befund(e)`, bats ohne ein einziges `not ok`,
`comment-claims: 41 Datei(en) geprueft, 0 Befund(e)`, `span-check: Traeger vorhanden, span-emit
hat einen Span geschrieben, Ablageort git-ignoriert`), `make shell-lint` **Exit 0** über
`harness/tools/*.sh` einschließlich des neuen Skripts, `make docs-check` **Exit 0**,
`make comment-claims` **Exit 0**, `make mutate` **Exit 0** mit `mutate: 147 ok, 0 Befund(e)` —
darin der für diesen Slice tragende Fall `154-unterkommando-routing-vertauscht ->
TestClampSurvivesBrokenPayload rot`. Der Stempel band den Lauf an den Baum, nicht an eine
Erinnerung: `bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha`
waren byte-gleich, und `record-gates` schreibt ihn nur als **letzter** Prerequisite grüner Gates
([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)).
Die Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Diese Notiz, der `done/`-Move und der Link-Zug danach verschieben den Stempel erneut;
der Lauf, der ihn wieder bindet, gehört zu ihnen.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/tools/` und der
Bau (`Makefile`) gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
