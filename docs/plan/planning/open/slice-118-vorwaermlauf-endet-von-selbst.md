# Slice slice-118: Der Vorwärmlauf vor dem Fork endet von selbst — ohne Wanduhr und ohne den Docker-Build aus der Prozessgruppe zu nehmen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Block in einer Datei und seine bats-Ebene. **(2) Gemeinsames
Closure-Kriterium?** Nein. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: eine Grenze, die
[slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) im Treiber **benannt** und dort mit
ihrer Messung hinterlegt hat. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap.

**Ebene: Dogfood, nicht emittiert.** `grep -rln 'mutate' internal/emit/templates/ | wc -l` → **0**;
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) geht in kein Zielrepo.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Zusage *„der Lauf endet von selbst"* hat für diesen
einen Ort kein Gegenbeispiel),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Schranke, die einen langsamen Lauf ohne Befund rötet, senkt die Aussage ihres eigenen Sensors),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Prozessgruppe des
Vorlaufs entscheidet, ob ein Ctrl-C den ersten Docker-Build erreicht),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Grund, aus dem
der Treiber `SECONDS`, `kill` und `wc` benutzt statt `timeout(1)`),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (der
Pro-Push-Auslöser),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**Ein Hänger im Vorwärmlauf vor dem Fork beendet den Lauf von selbst und sagt, was gemessen ist —
ohne eine Wanduhr-Schranke und ohne den ersten Docker-Build aus der Prozessgruppe des Treibers zu
nehmen.**

### Die Lage, mit ihrer Messung

`await_workers` wird gerufen, **nachdem** die Worker gestartet sind. Alles davor ist ungedeckt, und
darin liegt der erste Docker-Build des Laufs: der Vorwärmlauf, der laut Kommentar verhindert, dass
alle Worker dieselben Stufen gleichzeitig bauen. Der Treiber sagt das an dieser Stelle selbst
(`sed -n '629,642p' harness/tools/mutate.sh` — *„OFFEN BLEIBT DAMIT: ein Haenger im VORWAERMLAUF
vor dem Fork"*), und [`harness/README.md`](../../../../harness/README.md) trägt dieselbe Grenze
öffentlich (`grep -c 'Vorwärmlauf' harness/README.md` → **1**).

**Fremdbelegt, mit Kommando:** ein hergestellter Hänger an dieser Stelle endete mit **Exit 137 nach
50,01 s** und **ohne Bericht** — nur der `timeout` von außen beendete ihn
([Verifikation Runde 2 zu slice-117](../../../reviews/2026-08-27-slice-117-verify-runde2.md) §2.2,
Gegenprobe).

### Zwei Auflagen, beide aus einem gemessenen Rückbau

[slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) hat diesen Ort schon einmal
geschlossen — mit `timeout "$STALL_SECONDS" make "$m"` — und die Zeile wieder zurückgebaut. Was
dabei gemessen wurde, ist die Auflage für den nächsten Versuch:

1. **Keine Wanduhr.** Die Zeile war eine **Dauer**-Schranke um einen Modus-Lauf, während der Entwurf
   des Treibers **Stille** begrenzt; [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §3
   Frage A hat Dauer-Schranken **vor dem Code** verworfen, weil sie je Modus verschieden bemessen
   sein müssten und auf einem langsamen Runner rot ohne Befund werden.
2. **Der Vorlauf bleibt in der Prozessgruppe des Treibers.** Gemessen: mit `timeout` lag der Treiber
   in einer anderen PGID als sein `make`, und ein `kill -INT` an die Vordergrund-Gruppe — das, was
   ein Ctrl-C im Terminal tut — ließ das `make` **leben**; ohne `timeout` lag `make` in der
   Treiber-PGID und starb
   ([Review Runde 2](../../../reviews/2026-08-27-slice-117-review-runde2.md) B-3, in beide
   Richtungen gefahren).

### Was daneben liegt und mit derselben Hand erledigt wird

**Der Ausgabe-Kanal des Laufs bleibt offen, nachdem der Lauf endet.** `main()` öffnet die
Fortschritts-Ausgabe mit `exec 3>&2` (`grep -c 'exec 3>&2' harness/tools/mutate.sh` → **1**); der
Worker und **sein Kind** erben Deskriptor 3, und der Treiber schließt ihn für die Kinder nirgends
(`grep -c '3>&-' harness/tools/mutate.sh` → **0**). Gemessen blieb eine Pipeline **25,00 s** bzw.
**135,85 s** nach der Schlusszeile des Treibers offen, weil das verwaiste Enkelkind dieselbe Pipe
hielt (beide Zahlen aus den zwei Verifikations-Runden zu
[slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md)). Die bats-Ebene desselben Slice hat den
Kanal für **ihre** Hintergrund-Prozesse bereits geschlossen
(`grep -c '3>&- 4>&-' test/mutate-driver.bats` → **4**) — der Treiber nicht. Das ist dieselbe
Konstruktions-Frage wie Auflage 2: wohin die Kinder des Treibers gehören.

**Und zwei Kommentar-Stellen im selben Block.** `grep -n 'Hier stand' harness/tools/mutate.sh` →
**1** beschreibt abwesenden Text; `grep -cE 'erste[rn]? Entwurf|frueheste[rn]? Entwurf|Vorgaenger|frueher hier stehende|die frueher' harness/tools/mutate.sh test/mutate-driver.bats`
→ **10** über beide Dateien. Sie sind **kein** DoD-Punkt und werden nicht nachgerüstet; wer den
Block ohnehin anfasst, zieht die Stellen darin nach
([`AGENTS.md`](../../../../AGENTS.md) §3.7 Cutoff).

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Ein Hänger im Vorwärmlauf vor dem Fork beendet den Lauf von selbst und benennt, was
      gemessen ist.** Der Lauf endet ohne Zutun von außen mit Exit ≠ 0, und die Meldung nennt die
      Größe, die überschritten wurde — nicht *„der Baum ist rot"*.
      **Rot:** ein `make`-Stub, der im Vorwärmlauf nicht zurückkehrt, muss **ohne** `timeout` von
      außen mit Exit ≠ 0 enden; dazu ein `test/mutations/`-Fall, der die Schranke entfernt und einen
      benannten bats-Fall rot färbt. Heute ist beides offen:
      `grep -rln 'green_prerun' test/mutations/ | wc -l` → **0**.
- [ ] **(2) Die Schranke misst Fortschritt, und der Vorlauf bleibt in der Prozessgruppe des
      Treibers.** Keine Wanduhr um einen Modus-Lauf (Auflage 1), und ein `kill -INT` an die
      Vordergrund-Gruppe erreicht den Docker-Build weiterhin (Auflage 2).
      **Rot:** eine Sonde, die `ps -o pid=,pgid=` über Treiber und `make` liest und danach
      `kill -INT -- -<Treiber-PGID>` schickt — das `make` muss danach **tot** sein. Weicht die PGID
      ab oder überlebt das `make`, ist der Schnitt falsch.
- [ ] **(3) Der Lauf-Kanal endet mit dem Lauf.** Kein Kind des Treibers hält Deskriptor 3 offen,
      nachdem der Treiber seine Schlusszeile geschrieben hat.
      **Rot:** derselbe Hänger, Ausgabe durch eine Pipe (`… 2>&1 | cat > datei`); die Pipeline muss
      innerhalb weniger Sekunden nach der Schlusszeile beendet sein. Heute bleibt sie offen —
      gemessen 25,00 s bzw. 135,85 s.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | der Vorwärmlauf-Block und die Kinder-Frage; `wc -l < harness/tools/mutate.sh` → **1512** beim Anlegen dieses Plans |
| [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) | update | die Sensor-Ebene des Treibers; `grep -c '^@test' test/mutate-driver.bats` → **48** beim Anlegen. Die neuen Fälle gehören dorthin, nicht in einen zweiten Sensor |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | die Zähne aus DoD (1) und (3); Nummern im Anschluss an die höchste vergebene (`ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1` → **205**, beim Anlegen neu auszuzählen) |
| [`harness/README.md`](../../../../harness/README.md) | update | der Nicht-Gate-Verify-Absatz nennt heute beide Grenzen als Grenzen (`grep -c 'Vorwärmlauf' harness/README.md` → **1**); schließt der Slice sie, zieht der Absatz mit |
| [`docs/plan/carveouts/CO-003-mutate-ohne-zeitschranke.md`](../../carveouts/CO-003-mutate-ohne-zeitschranke.md) | update **oder** unverändert | der Carveout führt diesen Slice als Folge-Slice; ob er hier aufgelöst wird, hängt an seiner Bedingung 1, und die ist eine Architect-Entscheidung ([slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §7 Übergabe) |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | **unverändert** | eine `timeout-minutes`-Zeile wäre eine zweite Schranke an einem Ort, den ein lokaler Lauf nicht sieht ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) |
| [`docs/plan/adr`](../../adr) | **unverändert** | die Änderung **hebt** eine Zusage an und senkt keine Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.5) |

**Drei Fragen, die vor dem Code zu beantworten sind — die Antworten gehören in diesen Plan, nicht in
den Kommentar.** Die Lehre steht in
[slice-105](../done/slice-105-mutate-messen-dann-teilen.md) und ist in
[slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) eingelöst worden.

| # | Frage — und warum sie den Schnitt entscheidet |
|---|---|
| A | **Woran misst eine Schranke Fortschritt an einer Stelle, an der es noch keine Worker gibt?** Der Vorwärmlauf schreibt keine Zug-Protokolle und keine Statusdateien — die zwei Größen, aus denen `progress_count` seinen Stand bildet. Ohne eine dritte Größe bleibt nur die Wanduhr, und die ist durch Auflage 1 verworfen |
| B | **Wohin gehören die Kinder des Treibers?** Eine eigene Prozessgruppe je Worker löst DoD (3) und die Waisen-Frage in einem Zug — nimmt aber denselben Weg, der in [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) als Regression gemessen wurde, wenn sie den Vorlauf einschließt. Die Antwort muss beide Richtungen nennen |
| C | **Was meldet der Lauf, wenn die Schranke greift?** Der Treiber misst die Überschreitung, nicht ihren Grund — die Meldung darf nur sagen, was gemessen ist ([`AGENTS.md`](../../../../AGENTS.md) §3.7). Ob sie den Modus, die Größe oder beides nennt, entscheidet, was ein späterer Leser damit anfangen kann |

## 4. Trigger

**Beginn (`open` → `next`): nichts blockiert.** Der Gegenstand liegt in einer Datei und ihrer
bats-Ebene.

**Die Reihenfolge gegenüber [slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md) und
[slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md):** alle drei fassen den
Mutations-Treiber oder seine Sensor-Ebene an. Das ist eine Beobachtung, keine Reihenfolge — wer
zuerst läuft, entscheidet die Priorisierung, nicht dieser Plan. **Was hier ausdrücklich nicht
behauptet wird:** dass sie zusammengehören. Sie teilen eine Datei, nicht ein Closure-Kriterium.

**Rückführung `in-progress` → `next`:** wenn Frage A zeigt, dass eine Fortschritts-Größe für den
Vorwärmlauf erst gebaut werden muss (ein eigenes Ereignis, das der Vorlauf schreibt) — dann ist das
ein eigener Schnitt und die Schranke wartet auf ihn.

**Rückführung `in-progress` → `open` (blockiert):** wenn sich zeigt, dass jede tragfähige Deckung
den Vorlauf aus der Prozessgruppe des Treibers nehmen muss. Dann steht Auflage 2 gegen DoD (1), und
die Abwägung gehört vor den Schnitt, nicht in ihn.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; der hergestellte Hänger im Vorwärmlauf ist **einmal
ohne Zutun von außen rot gesehen**; die Prozessgruppen-Sonde ist **in beide Richtungen** gefahren
(mit und ohne den Schnitt); Frage A, B und C sind mit ihrer Begründung **im Plan** beantwortet; der
Treiber-Kommentar und [`harness/README.md`](../../../../harness/README.md) nennen keine Grenze mehr,
die der Code nicht mehr hat; Review konform (Modul 10); Verifikation bestätigt (Modul 11);
`make gates` grün; `make mutate` ohne Befund; `git mv` nach `done/` als eigener Move-Commit;
Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen.

**Ausdrücklich nicht Teil des Closure-Triggers: eine Laufzeit-Schwelle für `make mutate`.** Eine
Zahl als Abnahme-Kriterium wäre auf einem geteilten Runner rot ohne Befund
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## 6. Risiken und offene Punkte

- **Die Stelle hat schon einmal eine Regression getragen.** Der erste Versuch hat den Docker-Build
  dem Ctrl-C entzogen, und niemand hätte es bemerkt, wenn eine zweite Rolle nicht die PGID gemessen
  hätte. Die Sonde aus DoD (2) gehört **vor** die Umsetzung, nicht hinter sie.
- **Ein Container ist kein Kind der Prozessgruppe.** Ob ein hängender `docker build` durch ein
  Signal an die Gruppe endet, ist **nicht gemessen**; Container sind Kinder des Daemons. Wer die
  Schranke baut, sagt, was sie erreicht und was nicht.
- **Der Treiber wächst weiter**, und seine Sensor-Ebene ist bats. Wächst die eine ohne die andere,
  entsteht die Klasse, gegen die dieses Werkzeug gerichtet ist — ein Wächter ohne Wächter.
- **Die bats-Stufe ist teuer.** Sie trägt im letzten Protokoll **52,6 %** der Fall-Arbeit
  (`sed -n '/Zeit je Sensor/,/Gruen-Vorlaeufe/p'` über einem `make mutate`-Protokoll). Ein neuer
  Fall, der auf Wanduhr-Ereignisse wartet, kostet **jeden** `test-bats`-Mutationsfall seine Dauer;
  der Posten ist in [slice-117](../in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §7 mit seinem
  Auflösungs-Trigger geführt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

### Sub-Area: Mutations-Treiber (`harness/tools/` + seine bats-Ebene)

Eine Sub-Area: ein Skript, sein Sensor und sein Fall-Verzeichnis. Das README ist Nutzer-Doku
desselben Gegenstands, keine eigene Sub-Area.

- **Modus:** GF. Der Treiber ist in diesem Repo entstanden (slice-026) und seither gegen den Kurs
  geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.6 definiert, wofür der
  Treiber da ist, §3.7 bindet den Text seiner Meldungen, §3.5 die Frage *Anhebung oder Senkung*,
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) seinen
  Auslöser und
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  seine Einbettung in die Sensor-Mechanik.
- **Phase-Reife:** Phase 5 (Betrieb). Der Treiber läuft pro Push über **198** Fällen
  (`ls -1 test/mutations/*.sh | wc -l`), verteilt auf Worker, mit Isolation, Lock, zwei
  Zeitschranken und fünf fail-closed Bedingungen.
- **Evidenz-/Diskrepanz-Risiko:** niedrig. Die Lage ist hergestellt und gemessen, nicht erschlossen;
  offen ist die **Konstruktion** (Fragen A und B), nicht der Befund.
- **Reconciliation-Aufwand:** gering für DoD (3), **offen für DoD (1) und (2)** — daran hängen beide
  Rückführungen in §4. Graduation-Trigger entfällt; die Sub-Area ist bereits GF.
