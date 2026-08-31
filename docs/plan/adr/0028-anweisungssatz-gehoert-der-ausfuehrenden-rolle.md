# ADR-0028: Ein Rollen-Anweisungssatz gehört der Rolle, die ihn ausführt

**Status:** Proposed

**Datum:** 2026-08-31

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (dieselbe Lücke — besetzt zwei
Norm-Artefakte und lässt die Frage für alle übrigen ausdrücklich offen; diese ADR nimmt eine
davon auf), [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (die
Präzedenz, wie dieses Repo eine solche Lücke schließt — durch Ableitung statt Liste),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

---

## Kontext

### Der Anlass, gemessen

`slice-144` führte `.claude/commands/implement-slice.md` in seiner §3-Plan-Tabelle als
Liefergegenstand — Schritt 9 und 23 dort verweisen auf den blanken `git mv`, den der Slice
ersetzt. Geliefert wurde die Zeile nicht. Die berichtete Begründung war eine Analogie zu
[`AGENTS.md`](../../../AGENTS.md) §3.8: das eigene Briefing aus dem Kontext heraus zu ändern, der
unter ihm läuft, sei „dasselbe Muster". Der Review
(`docs/reviews/2026-08-31-slice-144-review.md`, HIGH-1) weist das zurück: §3.8 begrenzt sich im
eigenen Text ausdrücklich auf **zwei** benannte Artefakte (Hard Rules dieser Datei §3,
Adaptions-Block in `harness/conventions.md`) und sagt selbst: *„Über andere Norm-Artefakte sagt
diese Regel nichts. … wo keine sie benennt, bleibt die Frage offen."* `.claude/commands/
implement-slice.md` ist keines der zwei benannten Artefakte.

Die eigentlich einschlägige, seit `slice-137` offene Frage ist `BEO-007` im
[Beobachtungs-Register](../planning/observations.md): *„Wer die Anweisungssätze unter
[`.claude/commands/`](../../../.claude/commands/) schreiben darf, sagt keine Quelle"* — Zähler
**1×**, Beleg `slice-137`. Das ist eine echte Lücke, keine durch §3.8 beantwortete. **Der Kern des
Befunds ist nicht, dass der Implementer falsch entschieden hätte — sondern dass er allein
entschieden hat, wo keine Quelle die Rolle benennt.**

### Der Auslöser ist der Konflikt-Pfad, nicht der Steering-Loop-Zähler

`BEO-007` steht bei **1×**, unter der 3×-Schwelle, die
`modul-06-roadmap.md` §Das Beobachtungs-Register für eine Verkörperung verlangt — ein Verdikt
jetzt ist also keine Schwellen-Pflicht. Der tatsächliche Auslöser ist ein anderer, unabhängig
zählender: `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz legt fest, wann die
Sequenz *Pflicht* wird — *„bei isolierten LOW/INFO-Findings ist die Sequenz Overkill … Sie greift
ab **HIGH mit Rollen-Widerspruch** oder ab dem **dritten** gleichen Konflikttyp"*. HIGH-1 dieses
Reviews **ist** ein HIGH mit Rollen-Widerspruch (Implementer entscheidet eine Rollenfrage allein,
gegen den im Plan selbst vorgesehenen Weg). Der Konflikt-Pfad ist damit unabhängig vom
`BEO-007`-Zähler bereits fällig — dieselbe ADR wäre bei einem zweiten Auftreten der Klasse ohnehin
über den Zähler fällig geworden, hier trägt sie der frühere, HIGH-spezifische Trigger.

### Was die Baseline regelt — und was sie nicht regelt

`modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse führt: *„**Briefing**
(`AGENTS.md` + 8-Schritt-Workflow) … Implementer"*. [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md)
§Kontext warnt ausdrücklich davor, diese Tabelle als Eigentums-Aussage zu lesen: sie sagt, *welche
Artefaktklasse eine Rolle führt*, nicht *wer sie schreibt* — „sie als Eigentums-Aussage zu lesen
kehrte die Frage genau um". Diese ADR macht denselben Fehler nicht: aus der Artefaktklassen-Tabelle
allein folgt für `.claude/commands/*.md` nichts.

Eine andere Stelle derselben Baseline-Datei sagt aber sehr wohl, wer ein rollen-eigenes
Arbeitsartefakt schreibt — konkret, nicht über die Artefaktklasse vermittelt.
§Konflikt-Pfad als Rollen-Sequenz, Verdikt-Tabelle, zweite Zeile:

```
| ADR wird per Folge-ADR `supersedes`d | A → R Folge-ADR (`supersedes`); R aktualisiert Skill-Datei | Folge-ADR (Accepted) · Skill-Patch |
```

*Der Reviewer aktualisiert seine eigene Skill-Datei*, ausgelöst durch einen Architect-Folge-ADR,
aber ausgeführt von der Rolle selbst. Das ist der Baseline-eigene Präzedenzfall für „eine Rolle
pflegt ihr eigenes operatives Ausführungsartefakt" — begrenzt auf die Skill-Datei, aber in der Form
tragfähig für die übrigen Rollen, die keine Skill-Datei, sondern einen Command als ihren
Anweisungssatz führen (unten).

### Was dieses Repo für die übrigen Rollen bereits sagt, ohne es als Norm zu benennen

Dieses Repo hat die Zuordnung „ein Anweisungssatz gehört seiner Rolle" für **Command**-Artefakte
längst getroffen — nur nie als Norm festgehalten. Der Commit, der die sechs `.claude/agents/*.md`
anlegte, sagt es im Klartext (`git log -1 --format=%B e30e0fd`):

```
DIE DATEIEN SIND ABSICHTLICH DUENN. Zwei Rollen haben ihren Anweisungssatz
laengst — der Reviewer in .harness/skills/reviewer.md, der Implementer in
.claude/commands/implement-slice.md, der Planner in plan-welle.md und
close-welle.md. Ihre Typ-Dateien ZEIGEN darauf und wiederholen nichts.
```

Die heute lebenden Dateien tragen dieselbe Aussage weiter. `.claude/agents/implementer.md`:
*„Dein Anweisungssatz steht in `.claude/commands/implement-slice.md` — lies ihn als Erstes und
folge ihm. … Diese Datei wiederholt ihn nicht, sie zeigt darauf."* `.claude/agents/planner.md`:
*„Deine Anweisungssätze stehen in `.claude/commands/plan-welle.md` (Schnitt) und
`.claude/commands/close-welle.md` (Abschluss)."* Beide Commands sagen es in ihrer eigenen ersten
Zeile noch einmal: `plan-welle.md` — *„Dieser Command führt die **Planner**-Rolle für *eine*
Welle"*; `close-welle.md` — *„Dieser Command führt die **Planner**-Rolle für die
**Wellen-Closure**"*; `implement-slice.md` — *„Dieser Command führt die **Implementation**-Rolle
(Modul 9) für *einen* Slice"*. Jeder der drei Commands benennt seine ausführende Rolle selbst, an
derselben Stelle, im selben Satzmuster.

`BEO-007` selbst hält fest, dass dieses Muster in der Praxis schon gilt, ohne je entschieden worden
zu sein: *„Umgangen, nicht gelöst: geschrieben wurde nur in Abschnitten, die die Planner-Rolle
bereits im Titel führen."* Genau das ist die informelle Fassung der Regel, die diese ADR jetzt
formalisiert.

**Was der Commit-Bestand dazu NICHT hergibt** — anders als bei
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md), wo die
Rollen-Präfix-Konvention in den Commit-Messages ein klares 27/0-Muster zeigte, ist die Konvention
für `.claude/commands/` und `.claude/agents/` zu jung, um als Beleg zu taugen:

```sh
git log --format='%s' -- .claude/commands/ | wc -l                    # 10
git log --format='%s' -- .claude/commands/ | grep -c '^Rolle '        #  0
git log --format='%s' -- .claude/agents/   | wc -l                    #  3
git log --format='%s' -- .claude/agents/   | grep -c '^Rolle '        #  0
```

Keine der beiden Dateimengen trägt ein einziges Rollen-präfigiertes Commit — nicht, weil eine
zweite Rolle geschrieben hätte, sondern weil beide Verzeichnisse zuletzt vor Einführung der
Präfix-Konvention berührt wurden. Diese Zahlen tragen darum **nichts** zur Entscheidung bei und
werden hier nur genannt, um sie nicht stillschweigend zu übergehen ([`AGENTS.md`](../../../AGENTS.md)
§3.1 sinngemäß — eine Messung, die nichts zeigt, ist trotzdem eine Messung).

### Warum `.claude/agents/*.md` eine andere Klasse sind

Sechs Dateien, aber strukturell keine sechs unabhängigen „Anweisungssätze". Ihr Gründungs-Commit
sagt selbst, dass sie *„ABSICHTLICH DUENN"* sind und *„zeigen … und wiederholen nichts"* — sie sind
Zeiger und Identitätskarte, kein Ablauf. Ihre Konsistenz ist an eine **Menge** gebunden, nicht an
eine einzelne Datei: derselbe Commit prüft die sechs Namen gegen zwei weitere Stellen desselben
Repos — Stand des Commits: *„DIE NAMEN SIND GEGENGEPRUEFT … Verzeichnis / [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) / `emit.go` …
Drei Stellen, dieselbe Menge"*. Die dortige [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)-Nennung ist heute überholt: die sechs
kanonischen Namen stehen seit
[`MR-030`](../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
in [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5;
[`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) selbst trägt seit seiner Teil-Aufhebung nur noch den Kopf. Der Cross-Check-Charakter
bleibt derselbe, nur die dritte Stelle hat gewechselt. Eine spätere Änderung hat die
Cross-Role-Bindung praktisch ausgeübt: der Commit `b39d4ff` änderte `reviewer.md` **und**
`verifier.md` in einem Zug, weil beide Dateien dieselbe Struktur-Ergänzung (*„Report-Datei ist das
Werkstück der Rolle"*) tragen mussten:

```sh
git show b39d4ff --stat --format=
#  .claude/agents/reviewer.md | 8 ++++++++
#  .claude/agents/verifier.md | 8 +++++++-
```

Eine Datei, deren Konsistenz-Anforderung Änderungen regelmäßig über Rollen-Grenzen hinweg in einem
Commit erzwingt, ist kein „eigenes Werkzeug einer Rolle" im Sinne, den dieser ADR unten für
Commands festlegt. Sie fällt strukturell eher in die Nähe eines Registers mit gemischten
Originalen ([ADR-0025](0025-register-mit-gemischten-originalen.md)) als in die eines einzelnen
Anweisungssatzes — aber selbst diese Analogie entscheidet diese ADR nicht; sie hält nur fest, warum
die Ableitung unten nicht unbesehen übertragbar ist.

## Entscheidung

**Wir wählen Option C: Ein Rollen-Anweisungssatz — ein Artefakt, das die operative Ausführung
genau einer Rolle für deren eigenen Ablauf distilliert, ohne selbst neue rollenübergreifende Norm
zu setzen — wird von der Rolle geschrieben, die ihn ausführt.** Drei Festlegungen:

**1. Eigentum ist eine Eigenschaft des Ablaufs, den ein Command operationalisiert, nicht der
Datei-Existenz.** Kriterium: welche Rolle führt diesen Ablauf aus, wenn sie dem Command folgt? Die
drei heutigen Commands beantworten das mechanisch, weil jeder es in seiner eigenen ersten Zeile
sagt (*„Dieser Command führt die `<Rolle>`-Rolle für …"*, oben zitiert) — das ist keine
Voraussetzung der Regel, sondern macht ihre heutige Anwendung trivial. **Angewandt:**
`.claude/commands/implement-slice.md` gehört dem **Implementer**;
`.claude/commands/plan-welle.md` und `.claude/commands/close-welle.md` gehören dem **Planner**
(die Welle-Eröffnung ist nach `modul-06-roadmap.md` §Wellen-Closure-Prozedur reine Planner-Arbeit;
die Closure trägt zwar zwei Rollenwechsel — Verifier, Architect —, aber *„Nur 1, 2 und 3b tragen
einen Rollenwechsel; 3a, 3c, 4 und 5 laufen im Planner-Kontext"*, und der Planner ist die Rolle, die
den Ablauf **hält** und die anderen anruft). Diese Zuordnung liest die Aussage, die die Dateien
selbst schon treffen — sie erfindet keine.

**Der Baseline-Präzedenzfall trägt dieselbe Form:** *„R aktualisiert Skill-Datei"* (oben zitiert)
weist der Reviewer-Rolle ihr eigenes operatives Artefakt zu, ausgelöst durch einen
Architect-Folge-ADR, ausgeführt von der Rolle selbst. Diese ADR wendet dieselbe Form auf die
Command-Form derselben Artefaktklasse an.

**2. Die Ableitung endet dort, wo ein Command eine bindende Aussage über den Gegenstand trägt, die
kein Original in den kanonischen Quellen hat** — etwa eine neue Hard Rule einführt oder eine
Baseline-Abweichung behauptet oder verneint, ohne dass eine ADR oder ein `MR`-Eintrag das trägt.
Über **diesen Teil** sagt diese ADR nichts; er bleibt bei der Rolle, die
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) für genau solche Aussagen bestimmt hat —
dem Architect. Ein Command, der bloß bestehende Regeln (Modul 5/6/8/9/10/11, `AGENTS.md`, den
MR-Block) für die eigene Ausführung distilliert, fällt nicht darunter; das ist der Normalfall der
drei heutigen Dateien.

**3. `.claude/agents/*.md` sind von dieser Ableitung ausgenommen — nicht mitentschieden.**
§Kontext oben nennt den Grund: die sechs Dateien sind strukturell kein einzelner Anweisungssatz je
Rolle, sondern eine bewusst dünne, konsistenz-gebundene Menge (Cross-Check gegen die kanonischen
Namen in `spec/spezifikation.md` §5 und `emit.go`s `roleFromAgentType`, Cross-Role-Commits wie
`b39d4ff`). Die Frage bleibt offen — genau wie
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) sie für „alle übrigen Norm-Artefakte" offen
lässt.

**Cutoff: geprüft wird ab dem Commit, der diese ADR annimmt.** Dieselbe Begründung wie in
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md): ein Maßstab, der den
Bestand mitprüfte, wäre dauerhaft rot und entwertete die Setzung. Die zehn bzw. drei Commits aus
§Kontext werden nicht nachgezogen.

**Was hier NICHT entschieden ist:** der Inhalt der drei Commands; ob `.claude/agents/*.md` eine
eigene Regelung braucht und welche (Festlegung 3 grenzt nur ab, beantwortet nicht); und die
emittierte Ebene.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, `BEO-007` bleibt offen bei 1× | kein neuer Norm-Text | der Konflikt-Pfad ist **jetzt** fällig, unabhängig vom Zähler (`modul-08-agentenrollen.md` §Konflikt-Pfad: „greift ab HIGH mit Rollen-Widerspruch") — ein HIGH mit Rollen-Konflikt blockiert den Closure-Pfad bereits, „nichts tun" verlängert nur die Blockade |
| B — den ADR-Index-Weg kopieren: **jedes Artefakt einzeln** benennen | kürzest formulierbar; deckt den akuten Fall | dieselbe Ablehnung wie in [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md): eine abgeschriebene Liste ist eine zweite Fassung, die driftet, sobald ein vierter Command entsteht |
| **C — Ableitung: wer den Ablauf ausführt, schreibt seinen Anweisungssatz (gewählt)** | beantwortet jede künftige Command-Datei ohne neue Liste; liest eine Aussage, die die Dateien selbst schon treffen; deckt sich mit dem Baseline-Präzedenzfall „R aktualisiert Skill-Datei" | die Vorfrage (welche Rolle führt den Ablauf aus, trägt der Command Norm-Aussagen ohne Original?) ist ein Urteil, kein Muster — für Grenzfälle liefert sie nichts (Festlegung 2) |
| D — **Architect** schreibt alle Commands, analog zu [`AGENTS.md`](../../../AGENTS.md) §3.8 | kürzeste Analogie; der Architect trägt schon zwei Norm-Artefakte | §3.8 begrenzt sich im eigenen Text ausdrücklich auf zwei Artefakte, deren Gemeinsamkeit die **Baseline-Abweichungs-Frage** ist (Adaptions-Block: *ob* eine Abweichung besteht; Hard Rules: derselbe Gegenstand allgemeiner). Ein Command, der bestehende Regeln bloß operationalisiert, stellt diese Frage nicht. Die Analogie würde außerdem jede operative Kleinigkeit — wie den in `slice-144` versäumten Tool-Verweis-Swap — zu einem Architect-Gate machen, gegen den eigenen Baseline-Präzedenzfall „R aktualisiert Skill-Datei" |
| E — **Planner** schreibt alle Commands, weil sie unter `docs`-nahen Planungs-Artefakten liegen | einfache Regel | dieselbe Ablehnung wie [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Option D: der Pfad ist keine Rolle. Der Planner vollzieht `implement-slice.md`s Ablauf nicht selbst — der Implementer tut es |
| F — `.claude/agents/*.md` **gleich mitentscheiden**, dieselbe Ableitung anwenden | eine Entscheidung für beide Artefaktklassen, weniger offene Fragen | genau die Fehllesart, vor der [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) warnt: die sechs Dateien sind gemessen strukturell anders (dünn, Set-Konsistenz-Zwang, Cross-Role-Commits, §Kontext) — die Ableitung liefert für sie keine eindeutige Antwort, und sie unbesehen anzuwenden wäre dieselbe Inversion, die die Artefaktklassen-Tabelle schon einmal verursacht hat |

## Konsequenzen

- **Positiv:** die Frage *„durfte dieser Lauf das schreiben?"* ist für Command-Anweisungssätze vor
  der Änderung beantwortbar, ohne dass ein Register von Zuordnungen entsteht, das driftet.
- **Positiv:** `BEO-007` bekommt einen Ausgang, der nicht bloß „umgangen" (die eigene Formulierung
  der Beobachtung) bleibt, sondern die schon gelebte Praxis als Norm festhält.
- **Positiv:** kein zusätzlicher Rollenwechsel für die Regelfälle — die ausführende Rolle pflegt ihr
  eigenes Werkzeug weiter selbst, mit der normalen Review-Prüfung (Diff gegen Plan/ADR/Hard Rules)
  als Kontrolle, statt jeder operativen Änderung ein Architect-Gate vorzuschalten.
- **Negativ, und das ist der Preis:** die Grenze aus Festlegung 2 (Norm-Aussage ohne Original) ist
  ein Urteil je Änderung, kein Muster — wer sie falsch zieht, verschiebt genau die Klasse Fehler,
  die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) beheben sollte, nur an eine andere
  Stelle.
- **Negativ:** `.claude/agents/*.md` bleiben ohne Regel. Wer diese sechs Dateien anfasst, steht vor
  derselben offenen Frage wie vor dieser ADR.
- **Negativ:** **kein Wächter**, siehe unten.
- **Folgepflicht 1 — der Zeiger im Briefing, fällig erst mit der Annahme.**
  [`AGENTS.md`](../../../AGENTS.md) §3.8 zeigt heute auf [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  und endet dort, wo dessen Geltungsbereich endet; ein Leser findet diesen Fall nicht. Der
  **Architect** setzt den Zeiger, **wenn diese ADR angenommen ist** — nicht vorher, dieselbe
  Begründung wie [ADR-0025](0025-register-mit-gemischten-originalen.md) Folgepflicht 2: eine Hard
  Rule, die auf eine `Proposed`-Entscheidung zeigt, behauptet Bindung, die nicht besteht. Bis dahin
  trägt der ADR-Index die Auffindbarkeit. Dieser Lauf schreibt `AGENTS.md` nicht — außerhalb seines
  Schreibziels.
- **Folgepflicht 2 — kein Eintrag im Adaptions-Block.** Die Regel weicht von der Baseline nicht ab,
  sie füllt eine Lücke, die die Baseline selbst offen lässt (§Kontext); ein Eintrag dort wäre eine
  erfundene Abweichung und verstieße gegen den Zweck, den
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) dem Block gibt — dieselbe
  Folgepflicht führen [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0025](0025-register-mit-gemischten-originalen.md) aus demselben Grund.
- **Folgepflicht 3 — die emittierte Ebene bleibt unberührt.** Ob ein erzeugtes Repo eine
  Eigentums-Aussage über seine Anweisungssatz-Artefakte bekommt, entscheidet der Slice, der die
  Tool-Ebene entscheidet — nicht diese ADR.
- **Folgepflicht 4 — `slice-144`.** Diese ADR beantwortet dessen §6 Risiko 2 in Richtung *entfallen:
  die Zeile ist ohne Rollen-Konflikt geschrieben* — die Prämisse der Rückführungs-Bedingung in
  dessen §4 (*„der Eigenbau berührt eine Norm-Aussage, die nach `AGENTS.md` §3.8 der Architect
  schreibt"*) trifft nicht zu, weil §3.8 diesen Fall nie erfasst hat (Reviewer-Befund HIGH-1,
  bestätigt). Ob und wie der Slice das einträgt, ist Sache der Rolle, die ihn hält; diese ADR
  schreibt keine Plan-Datei.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| — | **keine.** Der prüfbare Teil wäre *„ein Command-Artefakt ändert sich, ohne dass die Rolle, die seinen Ablauf ausführt, den Commit trägt"* — eine **Commit**-Bedingung, und sie ist hier so wenig gebaut wie bei [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 2, [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und [ADR-0025](0025-register-mit-gemischten-originalen.md) | — |

**Was hier bewusst NICHT steht.** Ein Sensor müsste **Commits** lesen; kein Modul der heutigen
`.d-check.yml`-Konfiguration tut das (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors,
ids, matrix, codepaths, spans`), und `make mutate` kennt zwei Fehlschlag-Formen — `--- FAIL:` der
Go-Stufe, `not ok N` der bats-Stufe —, keine, in der ein Commit-Zuschnitt rot wird. Auch die
Vorfrage aus Festlegung 2 ist unbewacht: ob ein Command eine Norm-Aussage ohne Original trägt,
sieht kein `grep`. Behauptet wird hier **kein** Gate
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Träger
ist der Rollen-Wechsel vor der Änderung.

## Re-Evaluierungs-Trigger

- **Wenn ein künftiger Baseline-Stand eine schreibende Rolle für Command- oder Skill-Artefakte
  allgemein benennt** *(feedforward — eine Textänderung upstream, kein Sensor)*: dann ist diese ADR
  gegenstandslos und wird durch eine Nachfolge-ADR mit *Supersedes* auf den Baseline-Abschnitt
  zurückgeführt. `v5.12.0` benennt keine über den Skill-Datei-Fall hinaus (§Kontext).
- **Wenn ein Command entsteht, der nicht eindeutig einer einzelnen Rolle als Ausführer zuzuordnen
  ist** *(feedforward — der erste Command, der mehrere Rollen gleichrangig orchestriert)*: dann
  liefert Festlegung 1 keine eindeutige Antwort, und die Frage braucht eine eigene Entscheidung nach
  demselben Muster wie [ADR-0025](0025-register-mit-gemischten-originalen.md) für gemischte
  Originale.
- **Wenn `.claude/agents/*.md` praktisch tief und rollen-exklusiv geschrieben werden, statt dünn
  und zeigend zu bleiben** *(feedforward — beim Lesen, nicht durch ein Kommando)*: dann ist die
  Ausnahme in Festlegung 3 neu zu prüfen — die Begründung dafür ruht auf der heutigen, gemessenen
  Dünnheit.
- **Wenn die Klasse ein weiteres Mal ohne Träger auftritt, obwohl der Träger jetzt steht**
  *(feedforward — am Commit-Bestand ablesbar)*: dann trägt der Ort nicht, und die Trägerwahl ist der
  Befund, nicht die Wiederholung — dieselbe Probe, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0025](0025-register-mit-gemischten-originalen.md) an sich selbst anlegen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-31 | **Proposed** | Architect-Verdikt auf eine Reviewer-Eskalation, [`docs/reviews/2026-08-31-slice-144-review.md`](../../reviews/2026-08-31-slice-144-review.md) HIGH-1. Ausgelöst über den Konflikt-Pfad aus `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz (Pflicht ab HIGH mit Rollen-Widerspruch, unabhängig vom `BEO-007`-Zähler bei 1×). Gewähltes Verdikt der drei aus dessen Tabelle: *„Lockerung legitim, aber undokumentiert"* — Selbst-Autorschaft des eigenen operativen Anweisungssatzes war durch den Baseline-eigenen Konflikt-Pfad-Präzedenzfall („R aktualisiert Skill-Datei") bereits der Form nach gedeckt, nur nie für die Command-Form derselben Artefaktklasse als Norm festgehalten. Der Acceptance-Trigger der Baseline (`grundlagen-bootstrap.md` §Vier Trigger-Klassen: „ADR-Review-Runde abgeschlossen → bindend") hat **nicht** stattgefunden — dieselbe Zurückhaltung wie bei [ADR-0025](0025-register-mit-gemischten-originalen.md): der Bestand begründet keinen Status |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0028` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
