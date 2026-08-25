# Slice slice-078: Die Verdrahtung dieses Repos hat einen Wächter

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Neubau) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 — keine Zusage ohne rot gesehenes Gegenbeispiel; die
Verdrahtung dieses Repos ist eine Zusage ohne Gegenbeispiel.
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 —
Abweichung 5 (3)(b) hält den Zustand fest und hat ihn ausgezählt: *„Alle fünf gelten dem
**emittierten** Repo und dessen Command-Guard; für die Verdrahtung **dieses** Repos prüft keine
etwas. Ein Vorbild samt rot gesehener Mutation gibt es also, einen Sensor nicht."* Dieser Slice
macht den Satz falsch und zieht ihn mit.
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) —
die Mechanik, deren Geltungsbereich `.claude/` ist; sie beschreibt die Verdrahtung, sie bewacht
sie nicht.
[`ADR-0004`](../../adr/0004-durchsetzungs-emission.md) (**Accepted**) — die Trennung von
Dogfood- und emittierter Durchsetzungsschicht; dieser Slice zieht die Ebene nach, die den
Wächter noch nicht hat.
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — der Prüfbereich ist
**getrackt** und damit auf jedem Checkout derselbe.

**Bewusst KEINE `LH-FA`-Kennung.** Geprüft: die funktionalen Anforderungen betreffen das
**emittierte** Zielprojekt; dieser Slice bewacht die Durchsetzungsschicht **dieses** Repos und
emittiert nichts (§3). **Auch [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
wird nicht beansprucht, obwohl sie naheliegt:** ihre Falle ist der leere Prüfbereich, und der
liegt hier nicht vor — `.claude/settings.json` ist getrackt (`git ls-files .claude/`, gemessen
2026-08-08), der Wächter greift also auf frischem Klon. **Dieser Absatz steht unterhalb der
Leerzeile:** der Bezugs-Block wird bis zur ersten Leerzeile mechanisch gelesen, und eine
Ausschluss-Notiz darin trüge ein, was sie ausschließt.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-08.

---

## 1. Ziel

**Fällt ein Hook-Block aus `.claude/settings.json` heraus, wird ein Gate rot.** Heute bleibt
alles grün: die Guards laufen nicht mehr, die Spans hören auf zu entstehen, und kein Sensor sagt
es.

**Der Ist-Zustand, gemessen am 2026-08-15 (alle drei Zeilen neu gefahren):**

- `.claude/settings.json` verdrahtet **fünf** Ereignisse — `PreToolUse`, `PostToolUse`,
  `PostToolUseFailure`, `SubagentStart`, `Stop` — in **sechs** Hook-Einträgen (`PreToolUse`
  trägt zwei: Command-Guard und Agent-Guard).
- **Kein** Fall unter `test/mutations/` fasst `.claude/settings.json` an. Der einzige
  Fall über einer `settings.json` ist `32-enforce-settings-wires-guard.sh`, und seine
  `files:`-Zeile zeigt auf `internal/emit/templates/enforce/settings.json` — die **emittierte**
  Vorlage.
- **Die Hooks selbst sind bewacht, ihre Verdrahtung nicht:** **zwei** Fälle (`139`, `150`)
  mutieren `.claude/hooks/pretooluse-agent-guard.sh` (`grep -l pretooluse-agent-guard
  test/mutations/*.sh`). Ein Skript, das niemand aufruft, besteht jeden dieser Fälle — und die
  Zahl ist das schwächere Argument von beiden: sie sinkt, sobald ein Guard-Zweig entfällt, ohne
  dass die Lücke kleiner würde.

**Drei der Einträge hängen an einem Pfad, den der Bau beliefert — und diese Kopplung hat ihr
Gegenbeispiel bereits.** `grep -c 'state/bin/ai-harness-init span-emit' .claude/settings.json` →
**3** (mitwandernd) zeigen auf denselben Ablageort, den `grep -n '^HOST_BIN :=' Makefile` nennt;
zeigt einer davon woanders hin, entsteht kein Span, keine Meldung und kein rotes Gate. Gemessen im
Verifikations-Lauf zu slice-094 und hier als **fremdbelegt** ausgewiesen
([Bericht](../../../reviews/2026-08-25-slice-094-verify.md), Lauf L12): die drei Einträge in einer
Kopie außerhalb des Repos auf einen gelöschten Pfad zurückgestellt — einzige abweichende Datei —,
dann `make gates` in der Kopie → **Exit 0**, mit denselben Zahlen wie der ungestörte Lauf. Das ist
genau die zweite Richtung aus DoD (1) (*Kommando umgebogen*); ihr rotes Gegenbeispiel muss also
nicht erst gesucht werden.

**Die Lücke ist älter als der jüngste Block.** `PostToolUse` und `PostToolUseFailure` stehen seit
slice-059 ungeschützt, die zwei `PreToolUse`-Einträge und `Stop` noch länger; `SubagentStart` hat
sie um einen sechsten Eintrag verbreitert, nicht erzeugt. Ein Wächter, der nur den zuletzt
angefassten Block deckt, wäre die Lücke mit besserem Gewissen.

**Das Vorbild steht im eigenen Repo:** für die **emittierte** Vorlage leisten
`TestEnforce_SettingsWiresBothHooks` und Fall `32` genau das, was hier fehlt. Zu bauen ist keine
neue Idee, sondern dieselbe Zusicherung eine Ebene weiter.

## 2. Definition of Done

- [ ] **(1) Ein Wächter hält `.claude/settings.json` gegen die Soll-Menge der Verdrahtung — in
  beide Richtungen.** Je Ereignis-Block das Kommando, auf das er zeigt; der Wächter fällt, wenn
  ein Block **fehlt**, wenn sein Kommando **umgebogen** ist, und wenn ein Block auftaucht, den
  die Soll-Menge **nicht führt**. Die dritte Richtung ist keine Zugabe: ohne sie wächst die Datei
  am Wächter vorbei, und genau so ist der sechste Eintrag entstanden, ohne dass etwas rot wurde.
  Er läuft in `make gates` — der Prüfbereich ist getrackt und auf frischem Klon derselbe, ein
  Gate darüber steht also nicht über Leerem.
  **Was er ausdrücklich nicht behauptet:** dass das Werkzeug die Datei auch **liest**. Ein
  stiller Hook hat zwei Ursachen — *feuert nicht* und *Konfiguration nicht gelesen* —, und dieser
  Wächter unterscheidet sie nicht; er prüft eine Datei, nicht einen Prozess.
- [ ] **(2) Die Zähne, je Ausfall-Form einer, rot gesehen.** Ein Fall in `test/mutations/`
  entfernt einen Ereignis-Block, ein zweiter biegt ein Kommando auf einen anderen Pfad um; beide
  müssen den Wächter aus DoD (1) rot färben. **Nummernkreis:** die zwei Fälle schließen an die
  höchste vergebene Nummer unter `test/mutations/` an — sie wird beim Anlegen ausgezählt, nicht
  aus diesem Plan übernommen. Ein nie angelegter Fall erzeugt kein Rot — die Verdrahtung wäre
  dann weiter eine Absicht.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/` (bats) | neu | der Wächter aus DoD (1); dieselbe Klasse wie `test/agent-guard.bats` und `test/guard.bats`, die die Hook-**Skripte** prüfen — hier ihre **Verdrahtung** |
| `test/mutations/` | neu | die zwei Zähne aus DoD (2), Nummern im Anschluss an die höchste vergebene |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | §5 Abweichung 5 (3)(b) sagt heute *„für die Verdrahtung dieses Repos prüft keine etwas"* und zählt fünf Prüfstellen aus. Mit diesem Slice ist der Satz falsch und die Zählung überholt — er wird mitgezogen, nicht danebengestellt |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update, **falls** Frage A so ausgeht | nur wenn die Soll-Menge dort als Artefakt lebt; führt der Wächter sie selbst, bleibt [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) unberührt — eine zweite Liste ist der Defekt, nicht die Lösung |

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Wo lebt die Soll-Menge — im Wächter oder in einem gelesenen Artefakt?** | Im Wächter: eine Quelle, kein Drift-Risiko, aber die Menge ist nur im Test lesbar. In einem Artefakt ([`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) oder [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5): sie steht dort, wo sie ein Leser sucht, aber der Wächter hängt an einem Parser über Prosa — und eine Liste, die an zwei Orten steht, driftet. **Präzedenz auf der emittierten Ebene:** `TestEnforce_SettingsWiresBothHooks` führt die Menge im Test |
| B | **Zählt der Wächter Einträge oder prüft er Kommandos?** | Fünf Ereignisse, sechs Einträge — eine Zahl allein deckt den Fall nicht ab, dass ein Block gegen einen anderen getauscht wird. Die Antwort entscheidet, ob DoD (1) über Pfade oder über Anwesenheit redet |

**Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1**

1. **Bündel?** Nein — Wächter und Zähne landen in **einem** Schnitt.
2. **Gemeinsames Closure-Kriterium?** Nein. **Auch nicht in
   [welle-09](../welle-09-modul-15-konformitaet.md):** deren Closure ist eine 4 × 2-Matrix über
   die vier Regelblöcke von Modul 15 × {Repo, Tool}; die Durchsetzungsschicht ist keiner dieser
   Blöcke, dieser Slice füllt also keine Zelle und leert keine.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv** — eine erklärte, ausgezählte Lücke im
   Technik-Stratum, keine neue Fähigkeit.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** die Roadmap bekommt **keinen** Eintrag —
weder jetzt noch beim Abschluss.

**Dogfood oder emittiert — entschieden: DOGFOOD, und das ist keine Vertagung.** Die emittierte
Ebene hat den Wächter bereits (`TestEnforce_SettingsWiresBothHooks` samt Fall `32`); hier fehlt
er auf der anderen Ebene derselben Sache. Der Slice emittiert nichts und berührt den
Adopter-Vertrag nicht — er stellt die zwei Ebenen gleich.

## 4. Trigger

**`open` → `next`:** Frage A und B sind beantwortet. Beide sind ohne Vorarbeit anderer Slices
entscheidbar; dieser Slice wartet auf keinen.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die Soll-Menge ein eigenes Format samt eigenem Wächter verlangt
  (Frage A). Dann trennt ein Re-Schnitt das **Artefakt** vom **Wächter** darüber.
- `in-progress` → `open`: falls die effektive Verdrahtung nicht aus der getrackten Datei allein
  folgt. Der Ist-Stand kennt den Fall: `.claude/settings.local.json` liegt neben ihr, ist
  **nicht** getrackt und wird über eine Ignorier-Regel außerhalb des Repos ausgeblendet
  (gemessen 2026-08-08, `git check-ignore -v`). Zeigt sich, dass sie die Blöcke der getrackten
  Datei überschreiben kann, prüft der Wächter die falsche Quelle — dann ist zuerst zu
  entscheiden, was „verdrahtet" überhaupt heißt.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün, die zwei neuen Fälle **rot gesehen** und im
Bericht benannt; `git mv` nach `done/` in eigenem Move-Commit, eingehende Links im Zug danach;
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Wächter über einer Konfigurationsdatei prüft die Datei, nicht das Werkzeug.** Er schließt
  die Ursache *„Block entfernt"* aus, nicht die Ursache *„Konfiguration nicht gelesen"* —
  dieselbe Zweideutigkeit, die [slice-060](../done/slice-060-rollen-achse.md) mit einer
  Kontroll-Sonde umgangen hat. Die Grenze gehört in DoD (1) und steht dort, statt überspielt zu
  werden.
- **Zwei Listen driften** (Frage A). Wer die Soll-Menge in Prosa **und** im Test führt, hat den
  Fehler dieses Repos ein weiteres Mal gebaut, nur mit Gate darüber.
- **Der Wächter deckt die Anwesenheit, nicht die Wirkung.** Ob ein verdrahteter Hook seine Arbeit
  tut, prüfen die bestehenden bats-Dateien über den Skripten; ob die Ausgabeform noch stimmt,
  gehört slice-067. Wer den neuen Wächter für beides hält, überschätzt ihn.
- **Nicht in diesem Slice:** die Ausgabeform der Hooks (slice-067), die Fall-Granularität des
  Mutations-Treibers ([slice-069](slice-069-zahn-bindet-zusicherung.md)), der Prüfbereich von
  `comment-claims` ([slice-070](slice-070-comment-claims-pruefbereich.md)) und jeder Sensor über
  der **Telemetrie** ([slice-066](../done/slice-066-telemetrie-auswertung.md),
  [slice-074](slice-074-agent-vor-aufruf-protokoll.md),
  [slice-077](slice-077-verlorener-lauf-sichtbar.md)).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/`, `test/` und
`spec/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
