# Slice slice-077: Ein verlorener Subagenten-Lauf wird sichtbar

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Neubau) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 —
Abweichung 5 (3)(b) hält den Zustand fest, den dieser Slice beendet (*„er kann fehlen,
abgeschaltet oder umgangen sein, und **kein Sensor dieses Repos prüft, dass er verdrahtet
ist**"*); dasselbe §5 bindet *gedeckt* an **Zähler** statt an „irgendeinen erfassten Wert" und
nimmt die Achse aus DoD (1) als Festlegung auf.
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted**) — die
Erfassungs-Policy, unter der beide gelesenen Quellen entstehen; Festlegung 2 setzt die
Positiv-Liste, an die sich auch eine neue Achse hält.
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (**Accepted**) — falls der Sensor als Binary
entsteht, wird er Docker-only gebaut; die Formfrage steht in §3.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — der
Prüfbereich ist maschinenlokal und auf frischem Klon **leer**; daraus folgt DoD (2) *nicht in
`make gates`*.
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — zwei Läufe kurz
nacheinander dürfen sich nicht widersprechen; daraus folgt die rechte Kante aus DoD (2).
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) —
die Hook-Mechanik dieses Repos, aus der beide Quellen stammen.

**Bewusst KEINE `LH-FA`-Kennung.** Geprüft: die funktionalen Anforderungen betreffen das
**emittierte** Zielprojekt; dieser Slice legt eine Dogfood-Diagnostik an und emittiert nichts
(§3). Eine der zwölf hier zu führen, füllte die `requirement`-Achse falsch — leer und erkennbar
schlägt gefüllt und falsch. **Dieser Absatz steht unterhalb der Leerzeile:** der Bezugs-Block
wird bis zur ersten Leerzeile mechanisch gelesen, und eine Ausschluss-Notiz darin trüge ein, was
sie ausschließt.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-08.

---

## 1. Ziel

**Ein Subagenten-Lauf, der gar keinen `Agent`-Span hinterlassen hat, wird sichtbar — und zwar
unterscheidbar vom noch laufenden und vom Hintergrund-Lauf.** Das ist die Frage, die keine
Auswertung über den Span-Bestand beantworten kann: Zähler und Bezugsmenge stehen dort in
**demselben** Satz, und ein Lauf, der keinen Satz erzeugt hat, fehlt in beiden.

**Der Anlass ist zweimal belegt und keine Vorsichtsmaßnahme.**
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
Abweichung 5 (3)(b) hält fest, dass der `PreToolUse`-Guard aus
[slice-060](../done/slice-060-rollen-achse.md) fehlen, abgeschaltet oder umgangen sein kann und
**kein Sensor** das bemerkt; und
[slice-074](slice-074-agent-vor-aufruf-protokoll.md) ist aus einem realen Aufruf entstanden, der
unter einem Rollen-Typ durchlief, obwohl der Guard ihn hätte ablehnen müssen.

**Was er ausdrücklich nicht leistet:** die Token-Bilanz. Deren Abdeckungszahl
([slice-066](../done/slice-066-telemetrie-auswertung.md) DoD (1)) misst **innerhalb** der
erfassten Menge, wie viele Läufe Zähler trugen; dieser Slice misst, ob die erfasste Menge
vollständig ist. Zwei Fragen, zwei Zahlen — die zweite ist die, die kein Span beantwortet.

## 2. Definition of Done

- [ ] **(1) Die Korrelations-Achse steht als Festlegung, und sie ist gemessen statt gelesen.**
  Je Spawn ein Wert, der auf **beiden** Seiten vorliegt — beim Start des Subagenten und im
  `Agent`-Span seines Aufrufers. **Ist-Stand, gemessen am 2026-08-08: es gibt keinen.** Der
  `SubagentStart`-Span trägt `tool_use_id` **leer** und liegt im Strom des *gestarteten* Agenten
  (Schlüssel `agent`), der `Agent`-Span des Aufrufers trägt `tool_use_id` gefüllt, `agent` leer
  und liegt im Haupt-Strom. Ohne Achse bleibt nur ein Mengenvergleich, und der kann keinen
  Einzelfall benennen.
  Die Achse gehört als technische Festlegung nach
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
  nicht in den Code; **der bindende Text trägt keine Entscheidungs- und keine Planungs-Kennung**,
  auch keine nackte `slice-`-Kennung. Wird sie schwächer als eine Kennungs-Gleichheit (etwa
  Sitzung plus Zeitfenster), wird das als **Einschränkung der Zusage** geschrieben, nicht
  stillschweigend genommen.
- [ ] **(2) Ein Nicht-Gate-Ziel meldet den unpaarigen Start namentlich, nennt seine
  Prüfbereichs-Größe und schließt die zwei benignen Klassen aus.** Ein Start ohne `Agent`-Span
  ist **kein** Befund, solange er (a) noch **läuft** — der Start entsteht beim Beginn, der
  `Agent`-Span erst beim Ende — oder (b) zu einem **Hintergrund**-Lauf gehört, der nach
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  Abweichung 5 planmäßig keine Zähler trägt. **Ohne diese Ausschlüsse ist die Zahl kein Sensor:**
  am 2026-08-08T14:42Z standen **4** Starts gegen **2** zähler-tragende `Agent`-Spans — ohne
  einen einzigen Defekt, allein aus diesen zwei Klassen. Ein Sensor, dessen gesunder Stand nicht
  100 % ist, wird weggesehen.
  **Nicht in `make gates`, und das ist eine Messung, keine Bequemlichkeit:** der Span-Bestand ist
  gitignored und maschinenlokal, auf frischem Klon ist der Prüfbereich **leer** — ein Gate
  darüber wäre still grün, genau die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle.
  Das Ziel meldet deshalb seine Prüfbereichs-Größe in der letzten Zeile (dieselbe Form wie
  `make comment-claims`) und steht mit **benanntem Auslöser** in der Nicht-Gate-Verify-Liste.
  **Die Zähne:** Fixture-Paare, die je rot bzw. grün gesehen werden — ein verlorener Lauf färbt
  das Ziel rot; ein noch laufender und ein Hintergrund-Lauf erzeugen **keinen** Befund; der leere
  Prüfbereich meldet **Null** und behauptet kein Grün. Dazu ein Fall in `test/mutations/`, der
  die rechte Kante entfernt und den ersten Zahn rot färben muss.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

**Was heute vorliegt, gemessen am 2026-08-08:** `SubagentStart` ist verdrahtet (unter
[slice-066](../done/slice-066-telemetrie-auswertung.md), Schlüsselmenge in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5)
und erzeugt je Spawn einen Span mit `agent_type`, `agent` und `session` im Strom des gestarteten
Agenten. Was fehlt, ist die Brücke zur Aufrufer-Seite — nicht die Beobachtung des Starts.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | die Achse aus DoD (1) und die zwei Ausschluss-Klassen aus DoD (2) als technische Festlegungen nach §5 ([Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel)) — ohne sie lebt die Deutung im Code |
| `harness/tools/` oder ein Go-Kommando | neu | der Sensor aus DoD (2); die Formfrage steht als Frage B unten und hängt daran, welche Quellen er liest |
| [`Makefile`](../../../../Makefile) | update | das Nicht-Gate-Ziel aus DoD (2). **Nicht** in `gates` |
| [`AGENTS.md`](../../../../AGENTS.md) + [`harness/README.md`](../../../../harness/README.md) | update | das Ziel in der Nicht-Gate-Verify-Liste, **mit** seinem Auslöser — ein Sensor ohne Auslöser ist der Fehler, aus dem slice-027 entstanden ist |
| `test/` + `test/mutations/` | neu | die Fixture-Paare und der Dauer-Sensor aus DoD (2) |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | Welche **Korrelations-Achse**? | Kandidat 1: die Protokoll-Zeile aus [slice-074](slice-074-agent-vor-aufruf-protokoll.md) — sie entsteht auf der **Aufrufer**-Seite und trägt `tool_use_id`, denselben Wert wie der `Agent`-Span; die Paarung wäre eine Kennungs-Gleichheit. Kandidat 2: eine Erweiterung der Start-Seite, damit der Spawn seinen `tool_use_id` selbst mitführt — sie kostet Verdrahtung und hängt an einer Payload, die dieses Repo nicht bestimmt. Kandidat 3: Sitzung plus Zeitfenster — die schwächste, und sie wäre als Einschränkung zu schreiben. **Die Antwort entscheidet, ob dieser Slice hinter [slice-074](slice-074-agent-vor-aufruf-protokoll.md) steht oder neben ihm** |
| B | **Form** des Sensors: `bash`+`awk` wie die übrigen `harness/tools/`-Prüfer oder ein Go-Kommando ([`ADR-0003`](../../adr/0003-go-native-binaries.md))? | Er liest JSONL-Ströme; liest er zusätzlich die Protokoll-Zeile aus [slice-074](slice-074-agent-vor-aufruf-protokoll.md), liegt die Nähe zu deren Auswertungsregel, liest er nur Spans, die Nähe zum Auswerter aus [slice-066](../done/slice-066-telemetrie-auswertung.md). Zwei Prüfer über derselben Datei mit zwei JSON-Politiken sind die Form, die auseinanderdriftet |

**Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1**

1. **Bündel?** Nein — Achse, Sensor und Zähne landen in **einem** Schnitt.
2. **Gemeinsames Closure-Kriterium?** Nein; eine Welle darum hätte einen Trigger, der die DoD
   abschreibt. **Auch nicht in [welle-09](../welle-09-modul-15-konformitaet.md):** deren Closure
   ist eine 4 × 2-Matrix über vier Regelblöcke × {Repo, Tool}; dieser Slice füllt keine Zelle und
   leert keine — *Erfassung × Repo* tragen slice-059 und
   [slice-060](../done/slice-060-rollen-achse.md).
3. **Auslöser reaktiv oder gewollt?** **Reaktiv** — eine erklärte Abweichung und ein beobachteter
   Vorfall, keine neue Fähigkeit.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** die Roadmap bekommt **keinen** Eintrag —
weder jetzt noch beim Abschluss.

**Dogfood oder emittiert — entschieden: NICHT emittiert.** Der Sensor hält den Span-Bestand
dieses Repos gegen dessen Hook-Verdrahtung; ein Ziel-Repo hat heute weder Spans noch den
Rollen-Guard, und die Werkzeug-Ebene der Telemetrie ist nicht entschieden (slice-062). Ein
dorthin emittierter Prüfer liefe über leerem Prüfbereich. **Auflösungs-Trigger:** entscheidet
slice-062, dass ein Ziel-Repo den Span-Emitter bekommt, ist die Frage neu zu stellen.

## 4. Trigger

**`open` → `next`:** Frage A ist beantwortet — entweder liegt
[slice-074](slice-074-agent-vor-aufruf-protokoll.md) in `done/` und liefert die
Aufrufer-seitige Achse, oder eine **Messung** (nicht die Werkzeug-Doku) weist eine andere aus.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die Achse eine eigene Verdrahtung samt eigenen Zähnen verlangt.
  Dann trennt ein Re-Schnitt die **Achse** vom **Sensor** — die Achse ist einzeln lieferbar, der
  Sensor nicht.
- `in-progress` → `open`: falls **keine** Achse messbar ist. Dann ist zuerst zu entscheiden, ob
  die Lücke aus §5 Abweichung 5 (3)(b) eine erklärte Abweichung bleibt — das ist eine
  Architektur-Entscheidung nach Modul 7, keine Implementierungsfrage.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; das Ziel **einmal über einem echten,
nicht-leeren Bestand gefahren** und seine Prüfbereichs-Zahl berichtet; `git mv` nach `done/` in
eigenem Move-Commit, eingehende Links im Zug danach; Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Sensor kann seinen eigenen Ausfall nicht melden.** Fällt die Verdrahtung des Starts weg,
  schrumpft der Prüfbereich auf null und das Ziel meldet **Null statt Grün** — das ist die
  Gegenkraft, und sie ist schwächer als ein Gate. Der Unterschied gehört benannt, nicht
  überspielt.
- **Die rechte Kante ist eine Schätzung, solange kein Ende-Ereignis verdrahtet ist.** Der Start
  hat ein Ereignis, der Abschluss des Subagenten keines; ein Zeit-Schwellwert ist eine Konvention
  und keine Messung. Wer ihn setzt, schreibt seinen Wert und seinen Grund dazu.
- **Zwei Zahlen über derselben Fläche verwechseln sich leicht.** Die Abdeckungszahl aus
  [slice-066](../done/slice-066-telemetrie-auswertung.md) misst innerhalb der erfassten
  Menge, dieses Ziel misst deren Vollständigkeit. Beide Ausgaben nennen ihre Bezugsmenge, sonst
  liest sich die eine als die andere.
- **Nicht in diesem Slice:** die Token-Bilanz
  ([slice-066](../done/slice-066-telemetrie-auswertung.md)), das Vor-Aufruf-Protokoll
  ([slice-074](slice-074-agent-vor-aufruf-protokoll.md)), die Entscheidung des Guards (sie bleibt,
  wie [slice-060](../done/slice-060-rollen-achse.md) sie gesetzt hat) und jede Emission ins Ziel
  (slice-062/063).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `spec/`, `harness/tools/`,
`Makefile` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration
von [`harness/conventions.md`](../../../../harness/conventions.md).
