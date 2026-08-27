# Slice slice-102: Die Messung nennt ihre Grenzen und ihren Anlass

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — vier Sätze an einem Artefakt plus ein Anlass;
einzeln lieferbar, auf keinen zweiten Slice wartend. **(2) Gemeinsames Closure-Kriterium?** Nein —
jedes denkbare wäre die Abschrift der eigenen DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv:
drei Befunde der Verifikation und einer des Reviews zu
[slice-095](../done/slice-095-hook-aufschlag-gemessen.md), alle am **Text** der Messung,
keiner am Gemessenen. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist das Mess-Skript **dieses** Repos; es geht
nicht ins Ziel (`grep -rn 'hook-overhead' internal/emit/ | wc -l` → **0**). Was ein emittiertes
Repo an Messungen bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Deckung, deren Reichweite kleiner ist als das, was der Text behauptet, ist dieselbe Klasse eine
Ebene über dem Gate — hier auf der Dogfood-Ebene und auf eine **Messung** angewandt),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — die Schwelle *50 ms im
Median*, gegen die die Messung gehalten wird; dieser Slice ändert an ihr nichts),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
ihr Re-Evaluierungs-Trigger zu Annahme (c) sagt über sich selbst: *„ohne sie merkt es niemand, und
der Trigger feuert nie"*; DoD (3) gibt diesem Trigger seinen Anlass, nicht seine Schwelle),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (**Grenze** ist eine der fünf Kommentar-Klassen — der
Kopf dieses Skripts führt eine davon vorbildlich und zwei weitere nicht),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl steht neben dem Kommando, das sie liefert — bei einer Latenz-Zahl gehört die **Last**
dazu, sonst liefert dasselbe Kommando eine andere Zahl),
[`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
(der Ablageort des berührten Werkzeugs).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Der Kopf des Mess-Skripts sagt, was die Messung *nicht* sagt — vollständig statt zu zwei
Dritteln —, stellt jede Median-Zahl neben die Last, unter der sie entstand, und ein bestehender
Ablauf nennt den Anlass, die Messung erneut zu fahren.**

### Vier Sätze fehlen, und alle vier an derselben Stelle

- **Die dritte Grenze.** Der Block *„was das nicht sagt"* nennt den Adopter-Host und den
  gesättigten Runner. Er nennt **nicht**, dass die Messung auf einem frischen Klon und in der CI
  gar nicht nachfahrbar ist: sie braucht den gitignorierten Span-Bestand, und ohne ihn bricht das
  Skript ab, statt eine Folge zu erfinden. Gemessen:
  `grep -cniE "frisch|klon|CI\b|Actions" harness/tools/hook-overhead.sh` → **0**, und
  `grep -rn 'hook-overhead' .github/ | wc -l` → **0**. Der Kopf sagt den **Mechanismus**, nicht
  die **Folge** — und die Folge ist die, nach der ein Leser sucht.
- **Die Last neben der Zahl.** Der Kopf führt *„Median 2,7 bis 2,8 ms"* unter Bedingungen, die er
  selbst mit *„loadavg 1,5 bis 3,8"* angibt. Innerhalb dieser Bedingungen ist **2,9 ms** gemessen
  worden (loadavg 3,23), über alle unabhängigen Läufe **2,6 bis 3,6 ms**. Ein Band ohne
  Last-Angabe sagt eine Wiederholbarkeit zu, die es nicht gibt; die Ausgabe des Skripts stellt
  die Last ohnehin daneben.
- **Die Kommando-Achse.** Die Deckung des Mess-Kommandos läuft über `codepaths` in
  `make docs-check` und trifft die **Datei**: verschwindet `harness/tools/hook-overhead.sh`,
  melden zwei Fundorte `codepath-missing`. Wird dagegen allein das `make`-Ziel umbenannt, bleiben
  `make docs-check` und `make comment-claims` grün — und weil der Name in `.PHONY` steht,
  antwortet `make -n hook-overhead` mit *„nichts zu tun"* und Exit 0. Das versprochene Kommando
  verschwindet nicht mit einem Fehler, es tut still nichts. Derselbe Kopf führt die
  `os.Getwd()`-Grenze ausdrücklich als *„GRENZE, benannt statt verschwiegen"*; diese führt er
  nicht.
- **Der Anlass.** Die Messung ist **fahrbar** — ein Kommando, eine Zahl, ein Datum —, aber kein
  lebendes Artefakt nennt einen Grund, sie wieder zu fahren: sie steht in keinem Gate, in keiner
  Prerequisite-Kette (`sed -n '292p' Makefile | grep -c 'hook-overhead'` → **0**) und in keinem
  Workflow. Der Re-Evaluierungs-Trigger zu Annahme (c) feuert damit weiterhin nur, wenn sich
  jemand erinnert — genau der Zustand, den jene Entscheidung über sich selbst vorhergesagt hat.

### Was dieser Slice ausdrücklich nicht tut: er baut kein Latenz-Gate

**Ein Anlass ist kein Gate.** Der Grund dagegen ist gemessen und nicht behauptet: derselbe
Gegenstand, dieselbe Quelle, dieselbe Stichprobengröße lieferten allein mit anderer Nachbar-Last
2,7 ms und wenige Minuten später 3,6 ms. Ein Schwellwert-Gate über dieser Größe röte nach
Nachbar-Last — rot ohne Befund, und nach dem dritten Fehlalarm abgeschaltet. Der Slice gibt der
Messung einen **Termin**, keine Aufhängung.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3). Der Gegenstand ist Prosa in einem Skript-Kopf
und ein Termin; wo kein Kommando rot färbt, steht das dabei statt einer Zusage
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Der Block *„was das nicht sagt"* nennt alle drei Grenzen, und jede Median-Zahl im Kopf
      steht neben der Last, unter der sie entstand.** Die dritte Grenze steht dort, wo die zwei
      anderen stehen — nicht in einer Commit-Message, die beim nächsten Mal niemand liest. Die
      berichtete Spanne deckt die Läufe, die es zu ihr gibt, oder sie nennt je Zahl ihre Herkunft.
      **Kein Kommando färbt diesen Punkt rot, und das ist der Befund, keine Vertagung.** Kein
      Sensor dieses Repos liest Prosa in einem Skript-Kopf: `make comment-claims` prüft
      Sensor-Nennungen, nicht Aussagen, `make docs-check` scannt kein `*.sh`, und `make
      shell-lint` liest Syntax. Messbar ist nur die Untergrenze: heute
      `grep -cniE "frisch|klon|CI\b|Actions" harness/tools/hook-overhead.sh` → **0**; danach
      nicht null. Ob der Satz die Grenze **trifft**, trägt das Review.
- [ ] **(2) Die Kommando-Achse steht als benannte Grenze dort, wo die Datei-Achse als Deckung
      steht.** Der Kopf nennt, was `codepaths` erreicht und was nicht — in derselben Form, in der
      er die `os.Getwd()`-Grenze führt.
      **Rot gesehen wird die Grenze selbst, nicht ihr Satz:** `hook-overhead:` im
      [`Makefile`](../../../../Makefile) umbenennen, die Datei liegen lassen → `make docs-check`
      und `make comment-claims` bleiben grün und `make -n hook-overhead` endet mit Exit 0. Der
      Punkt ist erfüllt, wenn der Kopf genau diesen Ausgang beschreibt; dass **kein** Kommando den
      fehlenden Satz rot färbt, gilt hier wie in (1).
- [ ] **(3) Ein bestehender Ablauf nennt den Anlass, die Messung erneut zu fahren.** *Bestehend*
      heißt: ein Ablauf, den dieses Repo ohnehin fährt und dessen Artefakt er dabei aufschlägt —
      naheliegend die Closure-Kriterien von
      [welle-12](../done/welle-12-erfassungsschicht-emittieren.md) §3, die der Wellen-Abschluss Punkt
      für Punkt liest. Der Anlass ist ein **beobachtbares Ereignis** (der Träger wächst · die
      Erfassungsschicht geht ins Ziel), kein Kalendertag und keine Schwelle.
      **Kein Kommando färbt ihn rot, und das ist die Wahl:** ein Gate daraus zu machen ist genau
      der Fehlalarm-Sensor, den §1 mit einer Messung ausschließt. Was den Punkt trägt, ist die
      **Position** des Satzes in einem Artefakt mit eigenem Termin — nachprüfbar daran, dass der
      Ablauf, der ihn liest, benannt ist.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/hook-overhead.sh`](../../../../harness/tools/hook-overhead.sh) — nur der Kopf | update | DoD (1) und (2). Ein Kommentar-Nachzug nach [`AGENTS.md`](../../../../AGENTS.md) §3.7 braucht einen Lauf, der die Datei anfasst; die Sätze sind hier billig und sonst ohne Träger |
| [`welle-12`](../done/welle-12-erfassungsschicht-emittieren.md) §3 | update | DoD (3): der Wellen-Abschluss liest die Closure-Kriterien Punkt für Punkt — ein Artefakt mit eigenem Termin |
| [`Makefile`](../../../../Makefile), [`AGENTS.md`](../../../../AGENTS.md) §4, [`harness/README.md`](../../../../harness/README.md) §Sensors | **unverändert** | die Zeiger stimmen und sind durch `codepaths` gehalten; der Gegenstand ist der Kopf, auf den sie zeigen |
| `test/mutations/` | **unverändert** | der Gegenstand ist Prosa und ein Termin; ein Fall darüber bräuchte erst ein Kriterium (§6) |
| `docs/plan/adr/` | **unverändert** | keine Schwelle wird bewegt und keine Entscheidung revidiert — der Slice **benennt**, was eine *Accepted*-Entscheidung über sich selbst schon sagt ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |

**Ist-Messung vor dem Text** (Modul 9 §4): welche der bereits gefahrenen Läufe tragen ihre Last?
Die acht Läufe der Verifikation nennen loadavg je Lauf, die neun der Umsetzung nicht. Ob DoD (1)
mit Ausweisung der Herkunft je Zahl auskommt oder eine neue Messreihe braucht, entscheidet diese
Zählung — **vor** dem ersten Satz, nicht danach.

## 4. Trigger

**`open` → `next`:** nichts blockiert ihn außer dem WIP-Limit. Der Gegenstand liegt vollständig
in diesem Repo, berührt keinen Produktions-Pfad und keine emittierte Ebene und wartet auf keinen
zweiten Slice. **`next` → `in-progress`:** WIP-Limit, dazu die Ist-Messung aus §3.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn sich zeigt, dass DoD (3) eine
eigene Entscheidung verlangt — welcher Ablauf den Anlass trägt, ist eine Frage über den Prozess
dieses Repos und nicht über diesen Kopf; dann sind es zwei Slices. `in-progress` → `open`, wenn
die Ist-Messung ergibt, dass die vorhandenen Zahlen ihre Last nicht hergeben und eine neue
Messreihe nötig ist — dann wartet der Text auf sie, statt eine Herkunft zu erfinden. Beide
Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt; die Untergrenze aus DoD (1) mit ihrem Kommando vor und nach dem Lauf
notiert; der Ausgang aus DoD (2) einmal selbst gefahren; der Anlass aus DoD (3) samt dem Ablauf
benannt, der ihn liest; Review konform (Modul 10); Verifikation bestätigt (Modul 11);
`make gates` grün; `git mv` nach `done/` als eigener Move-Commit; Closure-Notiz mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Gegenstand hat keinen Sensor, und dieser Slice baut ihm keinen.** Prosa in einem
  Skript-Kopf liest kein Gate dieses Repos. Was grün wird, ist die **Anwesenheit** der Sätze,
  nicht ihre Güte; die trägt das Review. Ein Wächter darüber bräuchte erst ein Kriterium dafür,
  wann eine Grenze „genannt" ist — ein Urteil über Fließtext, kein Muster.
- **Die vorhandenen Zahlen tragen ihre Last nur zur Hälfte.** Wer die Spanne mit Last berichten
  will, muss entweder je Zahl ihre Herkunft ausweisen oder neu messen — und eine neue Messreihe
  liefert wieder Zahlen eines Hosts und eines Tages. §3 stellt die Zählung deshalb vor den Text.
- **Ein Anlass kann verhungern wie eine Nennung.** DoD (3) ist erfüllt, sobald der Satz an einem
  Ort mit eigenem Termin steht; ob der Ablauf ihn dann wirklich ausführt, zeigt erst der nächste
  Wellen-Abschluss. Das ist die Grenze der Ebene, auf der dieser Slice arbeitet, und kein
  Versäumnis seines Schnitts.
- **Die dritte Grenze ist zugleich der Grund, warum kein CI-Lauf diesen Slice belegen kann.** Die
  Messung braucht den gitignorierten Span-Bestand; ein frischer Klon hat ihn nicht. Was die CI
  hier grün meldet, ist der Gate-Stack, nicht die Messung.
- **Die Kommando-Achse bleibt ungedeckt, und das ist entschieden.** Der Slice **benennt** sie; ein
  Wächter über *„ein in der Doku genanntes `make`-Ziel existiert"* ist ein eigener Gegenstand mit
  eigener Abwägung — dieselbe Auszeichnung trägt in diesen Artefakten auch Kommandos, Feldnamen,
  Marker und Pfade.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `harness/tools/` und die
Planungs-Artefakte unter `docs/plan/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
