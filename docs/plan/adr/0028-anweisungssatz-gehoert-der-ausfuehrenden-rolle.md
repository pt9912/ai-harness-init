# ADR-0028: Ein Rollen-Anweisungssatz gehört der Rolle, die ihn ausführt

**Status:** Proposed

**Datum:** 2026-08-31

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (dieselbe Lücke — besetzt zwei
Norm-Artefakte und lässt die Frage für alle übrigen ausdrücklich offen; diese ADR nimmt eine
davon auf), [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (die
Präzedenz, wie dieses Repo eine solche Lücke schließt — durch Ableitung statt Liste),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (die Form jedes Belegs unten: Tag ·
Regelwerks-Dateiname und Abschnittsname · Zitat verbatim, in die Festlegung 3 (a) vor dem
Accept-Übergang bringt; ihre Festlegung 4 regelt die **Gegenrichtung** — den Verweis *in* einem
Zeitdokument, nicht den *auf* eines),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; welche davon eine Ref tragen und
welche nicht, sagt §Mess-Basis dieses Dokuments)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

---

## Kontext

### Mess-Basis dieses Dokuments

Jede Zahl unten über den wandernden Repo-Bestand ist gegen den Commit **`7485be3`** gefahren und
nennt ihn im Kommando. Der Grund ist
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) §Geschichte: Werte
über einen wandernden Bestand *„bewegen sich mit jedem Commit … statt im selben Zug zu veralten, in
dem §3.4 sie einfriert"*. **Zwei Zahlen sind ausgenommen, und sie können es nicht anders sein:**
die Proben-Zählung und die Link-Zählung in §Verbatim-Proben messen **diese Datei**, die sich mit
jeder Korrektur ändert — ihr Gegenstand ist der Text, den der Leser vor sich hat, und nicht der
Stand einer Ref.

**Dieselbe Pinnung gilt für das Beobachtungs-Register, und sie hat dort eine Grenze.** Übernommen
sind Bezeichnung, Zähler und Belege der Zeile; die `Stand`-Zelle schreibt jede Slice-Closure fort
und ist darum weder zitiert noch als Beleg geführt — ein Wortlaut daraus wäre in dem Moment
eingefroren, in dem die Zeile weiterläuft.

Alle Baseline-Zitate sind gegen den adoptierten Stand **`v5.18.0`**
gehalten; die Probe steht im Anhang §Verbatim-Proben.

### Der Anlass, gemessen

`slice-144` führte `.claude/commands/implement-slice.md` in seiner §3-Plan-Tabelle als
Liefergegenstand — Schritt 9 und 23 schickten dort zum blanken `git mv`, den der Slice ersetzt,
und am Anlege-Commit dieser ADR war die Zeile nicht geliefert. **Nachgetragen hat sie die
Nacharbeit `fc1fc54`** (*„slice-144: Nacharbeit -- fehlender Liefergegenstand nachgezogen …"*);
seither schicken beide Schritte zum Werkzeug, an der Mess-Basis oben ebenso. Die Aussage hängt
darum an festen Ständen und nicht am Zeitpunkt des Schreibens; die drei Werte sind **keine
Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
for r in 2dc505a fc1fc54 7485be3; do
  git show $r:.claude/commands/implement-slice.md | grep -c 'slice-mv'
done
# 0   2dc505a — Anlege-Commit dieser ADR
# 3   fc1fc54 — die Nacharbeit
# 3   7485be3 — die Mess-Basis oben

git log --format='%h %ai' -S'make slice-mv' 7485be3 -- .claude/commands/implement-slice.md
# fc1fc54 2026-08-31 10:11:46 +0200
```

Die berichtete Begründung für das Auslassen war eine Analogie zu
[`AGENTS.md`](../../../AGENTS.md) §3.8: das eigene Briefing aus dem Kontext heraus zu ändern, der
unter ihm läuft, sei „dasselbe Muster". Der Review
(`2026-08-31-slice-144-review.md`, HIGH-1) weist das zurück: §3.8 begrenzt sich im
eigenen Text ausdrücklich auf **zwei** benannte Artefakte (Hard Rules dieser Datei §3,
Adaptions-Block in `harness/conventions.md`) und sagt selbst: *„Über andere Norm-Artefakte sagt
diese Regel nichts. … wo keine sie benennt, bleibt die Frage offen."* `.claude/commands/
implement-slice.md` ist keines der zwei benannten Artefakte.

Die eigentlich einschlägige, seit `slice-137` offene Frage ist `BEO-007` im
[Beobachtungs-Register](../planning/observations.md): *„Wer die Anweisungssätze unter
[`.claude/commands/`](../../../.claude/commands/) schreiben darf, sagt keine Quelle"*. Das ist eine
echte Lücke, keine durch §3.8 beantwortete. **Der Kern des Befunds ist nicht, dass der Implementer
falsch entschieden hätte — sondern dass er allein entschieden hat, wo keine Quelle die Rolle
benennt.**

**Die Registerzeile führt heute mehr als ihren Erstauftritts-Ort.** Zähler und Belege wandern mit
jeder Slice-Closure und sind darum **keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); sie stehen hier an der oben gepinnten Mess-Basis:

```sh
git show 7485be3:docs/plan/planning/observations.md \
  | awk -F'|' '$2 ~ /BEO-007/{print $5, $6}'
#  4×   slice-137, slice-144, slice-147, slice-148
```

Zwei der vier Belege — `slice-147` und `slice-148` — liegen **außerhalb** von
`.claude/commands/`; sie betreffen die Spec-Straten. Die Zeile führt damit die **Klasse** *„ein
Norm-Artefakt ohne benannte schreibende Rolle"*, und diese ADR beantwortet davon genau **einen**
Teil: die Anweisungssatz-Artefakte (Festlegung 1). Für die Spec-Straten trifft sie keine Aussage
(§Was hier NICHT entschieden ist). Welchen Ausgang die Registerzeile am Ende trägt, entscheidet
die Closure, die sie schreibt — nicht diese ADR.

### Zwei Auslöser, und der frühere ist der Konflikt-Pfad

Der Auslöser dieser ADR ist der **Konflikt-Pfad**. `v5.18.0`, `modul-08-agentenrollen.md`
§Konflikt-Pfad als Rollen-Sequenz legt fest, wann die Sequenz *Pflicht* wird — *„bei isolierten
LOW/INFO-Findings ist die Sequenz Overkill … Sie greift ab **HIGH mit Rollen-Widerspruch** oder ab
dem **dritten** gleichen Konflikttyp"*. HIGH-1 des auslösenden Reviews **ist** ein HIGH mit
Rollen-Widerspruch (Implementer entscheidet eine Rollenfrage allein, gegen den im Plan selbst
vorgesehenen Weg). Dieser Trigger zählt unabhängig vom Register.

Der zweite Auslöser ist inzwischen ebenfalls fällig, war es beim Anlegen dieser ADR aber noch
nicht: `BEO-007` steht an der Mess-Basis oben bei **4×** und damit über der Schwelle, die
`v5.18.0`, `modul-06-roadmap.md` §Das Beobachtungs-Register setzt — *„**Bei 3×** wandert der
Eintrag in die Steering-Loop-Einträge der laufenden Welle-Closure und wird zur verkörperten
Regel"*. Die beiden Auslöser fallen nicht zusammen, und der Unterschied trägt: der Konflikt-Pfad
war zuerst fällig und trägt diese ADR; der Zähler ist der **breitere** und deckt eine Klasse, von
der diese ADR nur den Anweisungssatz-Teil beantwortet.

### Was die Baseline regelt — und was sie nicht regelt

`v5.18.0`, `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse führt:
*„**Briefing** (`AGENTS.md` + 8-Schritt-Workflow) … Implementer"*.
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) §Kontext warnt ausdrücklich davor, diese
Tabelle als Eigentums-Aussage zu lesen: sie sagt, *welche Artefaktklasse eine Rolle führt*, nicht
*wer sie schreibt* — „sie als Eigentums-Aussage zu lesen kehrte die Frage genau um". Diese ADR
macht denselben Fehler nicht: aus der Artefaktklassen-Tabelle allein folgt für
`.claude/commands/*.md` nichts.

Eine andere Stelle derselben Baseline-Datei — `v5.18.0`, `modul-08-agentenrollen.md`
§Konflikt-Pfad als Rollen-Sequenz, Verdikt-Tabelle, zweite Zeile — sagt aber sehr wohl, wer ein
rollen-eigenes Arbeitsartefakt schreibt, konkret und nicht über die Artefaktklasse vermittelt:

```
| ADR wird per Folge-ADR `supersedes`d | A → R Folge-ADR (`supersedes`); R aktualisiert Skill-Datei | Folge-ADR (Accepted) · Skill-Patch |
```

*Der Reviewer aktualisiert seine eigene Skill-Datei*, ausgelöst durch einen Architect-Folge-ADR,
aber ausgeführt von der Rolle selbst. Das ist der Baseline-eigene Präzedenzfall für „eine Rolle
pflegt ihr eigenes operatives Ausführungsartefakt" — an der Skill-Datei ausgesprochen, in der Form
tragfähig auch für die übrigen Rollen, die keine Skill-Datei, sondern einen Command als ihren
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
`.claude/commands/close-welle.md` (Abschluss)."* Beide Commands sagen es in ihrem eigenen
Eröffnungssatz noch einmal: `plan-welle.md` — *„Dieser Command führt die **Planner**-Rolle für
*eine* Welle"*; `close-welle.md` — *„Dieser Command führt die **Planner**-Rolle für die
**Wellen-Closure**"*; `implement-slice.md` — *„Dieser Command führt die **Implementation**-Rolle
(Modul 9) für *einen* Slice"*. Jeder der drei Commands benennt seine ausführende Rolle selbst, an
derselben Stelle, im selben Satzmuster.

**Was `BEO-007` beiträgt, ist die Frage — nicht der Befund.** Die Registerzeile hält fest, dass für
diese Artefakte *keine Quelle* eine schreibende Rolle benennt; dass die Praxis daneben längst
existiert, tragen der Gründungs-Commit und die vier heute lebenden Dateien oben. Was diese ADR
festhält, ist damit keine neue Regel, sondern die bisher nur gelebte Fassung dessen, was die
Dateien selbst schon sagen.

**Was der Commit-Bestand dazu NICHT hergibt.** Die Rollen-Präfix-Konvention in den Commit-Messages
ist für beide Verzeichnisse zu jung, um ein Muster zu tragen — anders als bei
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md), deren §Kontext für
die dort projizierte Datei ein eindeutiges Muster misst. Gefahren gegen die Mess-Basis oben, alle
vier Werte **keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
git log --format='%s' 7485be3 -- .claude/commands/ | wc -l                    # 13
git log --format='%s' 7485be3 -- .claude/commands/ | grep -c '^Rolle '        #  1
git log --format='%s' 7485be3 -- .claude/agents/   | wc -l                    #  4
git log --format='%s' 7485be3 -- .claude/agents/   | grep -c '^Rolle '        #  0
```

Der eine Treffer ist `20a3e33` *„Rolle Architect: …"*; er berührt `.claude/commands/close-welle.md`
**und** `.harness/skills/reviewer.md` (`git show 20a3e33 --stat --format=`) — nach Festlegung 1
unten Planner- bzw. Reviewer-Territorium. Er ist damit **kein Beleg für** die Regel, sondern ein
Fall der Klasse, die sie regelt; der Cutoff unten deckt ihn, und
Re-Evaluierungs-Trigger 4 beginnt erst danach zu zählen. Die vier Zahlen tragen zur Entscheidung
**nichts** bei und werden hier nur genannt, um sie nicht stillschweigend zu übergehen
([`AGENTS.md`](../../../AGENTS.md) §3.1 sinngemäß — eine Messung, die nichts zeigt, ist trotzdem
eine Messung).

### Warum `.claude/agents/*.md` eine andere Klasse sind

Sechs Dateien, aber strukturell keine sechs unabhängigen „Anweisungssätze". Ihr Gründungs-Commit
sagt selbst, dass sie *„ABSICHTLICH DUENN"* sind und *„zeigen … und wiederholen nichts"* — sie sind
Zeiger und Identitätskarte, kein Ablauf. Ihre Konsistenz ist an eine **Menge** gebunden, nicht an
eine einzelne Datei: derselbe Commit prüft die sechs Namen gegen zwei weitere Stellen desselben
Repos — Stand des Commits: *„DIE NAMEN SIND GEGENGEPRUEFT … Verzeichnis / [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) / `emit.go` …
Drei Stellen, dieselbe Menge"*. Die dortige [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)-Nennung ist heute überholt, und zwar durch
[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben):
jener Eintrag hebt [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
*„**vollständig** auf"* — Kopf und Zeiger bleiben, den Rumpf trägt `git` — und verlagert die
Feldtabelle samt der sechs kanonischen Namen nach
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5.
[`MR-030`](../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
verlagert nichts; er löst in derselben §5 allein die Abweichung *„`implementer` statt
Implementation"* auf. Der Cross-Check-Charakter bleibt derselbe, nur die dritte Stelle hat
gewechselt. Eine spätere Änderung hat die Cross-Role-Bindung praktisch ausgeübt: der Commit
`b39d4ff` änderte `reviewer.md` **und** `verifier.md` in einem Zug, weil beide Dateien dieselbe
Struktur-Ergänzung (*„Report-Datei ist das Werkstück der Rolle"*) tragen mussten:

```sh
git show b39d4ff --stat --format=
#  .claude/agents/reviewer.md | 8 ++++++++
#  .claude/agents/verifier.md | 8 +++++++-
```

Eine Datei, deren Konsistenz-Anforderung Änderungen regelmäßig über Rollen-Grenzen hinweg in einem
Commit erzwingt, ist kein „eigenes Werkzeug einer Rolle" im Sinne, den dieser ADR unten für
Anweisungssätze festlegt. Sie fällt strukturell eher in die Nähe eines Registers mit gemischten
Originalen ([ADR-0025](0025-register-mit-gemischten-originalen.md)) als in die eines einzelnen
Anweisungssatzes — aber selbst diese Analogie entscheidet diese ADR nicht; sie hält nur fest, warum
die Ableitung unten nicht unbesehen übertragbar ist.

## Entscheidung

**Wir wählen Option C: Ein Rollen-Anweisungssatz — ein Artefakt, das die operative Ausführung
genau einer Rolle für deren eigenen Ablauf distilliert, ohne selbst neue rollenübergreifende Norm
zu setzen — wird von der Rolle geschrieben, die ihn ausführt.** Drei Festlegungen:

**1. Eigentum ist eine Eigenschaft des Ablaufs, den ein Anweisungssatz operationalisiert, nicht der
Datei-Existenz.** Kriterium: welche Rolle führt diesen Ablauf aus, wenn sie dem Artefakt folgt?

**Gebunden ist die Artefaktklasse, nicht die Datei-Form** — ein `.claude/commands/`-Command und
eine `.harness/skills/`-Skill-Datei fallen gleichermaßen darunter, sofern sie den Ablauf **einer**
Rolle distillieren. Die Baseline spricht die Zuordnung für die Skill-Form aus (*„R aktualisiert
Skill-Datei"*, oben zitiert); diese ADR dehnt sie auf die Command-Form derselben Klasse.

**Angewandt** auf den heutigen Bestand — vier Dateien, gemessen an der Mess-Basis oben
(`git ls-tree -r --name-only 7485be3 -- .claude/commands .harness/skills`, **kein** Erwartungswert):

| Artefakt | Rolle | woran ablesbar |
|---|---|---|
| `.claude/commands/implement-slice.md` | **Implementer** | Eröffnungssatz: *„Dieser Command führt die **Implementation**-Rolle (Modul 9) für *einen* Slice"* |
| `.claude/commands/plan-welle.md` | **Planner** | Eröffnungssatz: *„Dieser Command führt die **Planner**-Rolle für *eine* Welle"* |
| `.claude/commands/close-welle.md` | **Planner** | Eröffnungssatz: *„Dieser Command führt die **Planner**-Rolle für die **Wellen-Closure**"* |
| `.harness/skills/reviewer.md` | **Reviewer** | der Baseline-Präzedenzfall selbst: *„R aktualisiert Skill-Datei"* |

Dass die drei Commands das Kriterium in ihrem eigenen Eröffnungssatz beantworten, ist **keine
Voraussetzung** der Regel, sondern macht ihre heutige Anwendung trivial. Der Satz steht in allen
drei Dateien an derselben Stelle — nach der Überschrift und der `Argument:`-Zeile, nicht in
Zeile 1 (`git grep -n 'Dieser Command führt die' 7485be3 -- .claude/commands/` → je `:5`, **kein**
Erwartungswert). Zur
Planner-Zuordnung der Wellen-Closure: `v5.18.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur
weist die Eröffnung dem Planner zu — *„Die Eröffnung ist Planner-Arbeit"* —, und `v5.18.0`,
`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle hält für die Closure fest: *„Nur 1, 2
und 3b tragen einen Rollenwechsel; 3a, 3c, 4, 5 und 6 laufen im Planner-Kontext"*. Der Planner ist
also die Rolle, die den Ablauf **hält** und die anderen anruft. Diese Zuordnung liest die Aussage,
die die Dateien selbst schon treffen — sie erfindet keine.

**2. Die Ableitung endet dort, wo ein Anweisungssatz eine bindende Aussage über den Gegenstand
trägt, die kein Original in den kanonischen Quellen hat** — etwa eine neue Hard Rule einführt oder
eine Baseline-Abweichung behauptet oder verneint, ohne dass eine ADR oder ein `MR`-Eintrag das
trägt. **Über diesen Teil sagt diese ADR nichts, und sie weist ihn auch keiner Rolle zu.** Ein
Artefakt, das bloß bestehende Regeln (Modul 5/6/8/9/10/11, `AGENTS.md`, den MR-Block) für die
eigene Ausführung distilliert, fällt nicht darunter; das ist der Normalfall der vier heutigen
Dateien.

**Warum hier keine Rolle steht, obwohl eine naheläge.**
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) besetzt **zwei benannte Artefakte**
(`AGENTS.md` §3, den Adaptions-Block) und sagt in Festlegung 1: *„Über die übrigen Norm-Artefakte
trifft diese ADR **keine** Aussage — sie bestätigt keine fremde Zuordnung und setzt keine neue"*;
ihr §Was hier NICHT entschieden ist nimmt *„eine Eigentums-Aussage über irgendein drittes
Artefakt"* namentlich aus. Eine Norm-Aussage ohne Original in einem Anweisungssatz ist genau ein
solches drittes Artefakt. Sie hier dem Architect zuzuschreiben, hieße
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) eine Zuordnung zu unterstellen, die deren
eigene Verengung ausschließt — und wäre dieselbe Ableitung ohne Quelle, gegen die diese
ADR-Familie angetreten ist. Der Rest bleibt darum offen, wie ihn auch
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) offen lässt: *„die
Rolle für eine bindende Aussage ohne Original, falls eine in ein Register gerät"*.

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
Bestand mitprüfte, wäre dauerhaft rot und entwertete die Setzung. Die 13 bzw. 4 Commits aus
§Kontext werden nicht nachgezogen — einschließlich `20a3e33`.

**Was hier NICHT entschieden ist:** der Inhalt der vier Anweisungssätze; die Rolle für eine
bindende Aussage ohne Original in einem Anweisungssatz (Festlegung 2 grenzt sie ab und beantwortet
sie nicht); ob `.claude/agents/*.md` eine eigene Regelung braucht und welche (Festlegung 3 grenzt
nur ab); **die schreibende Rolle für die Spec-Straten** (`spec/spezifikation.md`,
`spec/architecture.md`) — die zwei jüngsten Belege von `BEO-007` liegen dort, und diese ADR
erreicht sie nicht; und die emittierte Ebene.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, `BEO-007` bleibt offen | kein neuer Norm-Text | der Konflikt-Pfad ist **jetzt** fällig, unabhängig vom Zähler (`v5.18.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz: *„Sie greift ab **HIGH mit Rollen-Widerspruch**"*) — ein HIGH mit Rollen-Konflikt blockiert den Closure-Pfad bereits, „nichts tun" verlängert nur die Blockade. Und der Zähler steht inzwischen bei 4×, also über der Schwelle |
| B — den ADR-Index-Weg kopieren: **jedes Artefakt einzeln** benennen | kürzest formulierbar; deckt den akuten Fall | dieselbe Ablehnung wie in [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md): eine abgeschriebene Liste ist eine zweite Fassung, die driftet, sobald ein fünfter Anweisungssatz entsteht. Die Tabelle in Festlegung 1 ist **abgeleitet**, keine Zuweisung — sie zeigt die Anwendung, sie trägt sie nicht |
| **C — Ableitung: wer den Ablauf ausführt, schreibt seinen Anweisungssatz (gewählt)** | beantwortet jede künftige Command- oder Skill-Datei ohne neue Liste; liest eine Aussage, die die Dateien selbst schon treffen; deckt sich mit dem Baseline-Präzedenzfall „R aktualisiert Skill-Datei" | die Vorfrage (welche Rolle führt den Ablauf aus, trägt das Artefakt Norm-Aussagen ohne Original?) ist ein Urteil, kein Muster — für Grenzfälle liefert sie nichts (Festlegung 2) |
| D — **Architect** schreibt alle Anweisungssätze, analog zu [`AGENTS.md`](../../../AGENTS.md) §3.8 | kürzeste Analogie; der Architect trägt schon zwei Norm-Artefakte | §3.8 begrenzt sich im eigenen Text ausdrücklich auf zwei Artefakte, deren Gemeinsamkeit die **Baseline-Abweichungs-Frage** ist (Adaptions-Block: *ob* eine Abweichung besteht; Hard Rules: derselbe Gegenstand allgemeiner). Ein Anweisungssatz, der bestehende Regeln bloß operationalisiert, stellt diese Frage nicht. Die Analogie würde außerdem jede operative Kleinigkeit — wie den in `slice-144` versäumten Tool-Verweis-Swap — zu einem Architect-Gate machen, gegen den eigenen Baseline-Präzedenzfall „R aktualisiert Skill-Datei" |
| E — **Planner** schreibt alle Commands, weil sie unter `docs`-nahen Planungs-Artefakten liegen | einfache Regel | dieselbe Ablehnung wie [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Option D: der Pfad ist keine Rolle. Der Planner vollzieht `implement-slice.md`s Ablauf nicht selbst — der Implementer tut es. Und für `.harness/skills/reviewer.md` läge der Pfad ganz woanders, während die Antwort dieselbe bleiben muss |
| F — `.claude/agents/*.md` **gleich mitentscheiden**, dieselbe Ableitung anwenden | eine Entscheidung für beide Artefaktklassen, weniger offene Fragen | genau die Fehllesart, vor der [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) warnt: die sechs Dateien sind gemessen strukturell anders (dünn, Set-Konsistenz-Zwang, Cross-Role-Commits, §Kontext) — die Ableitung liefert für sie keine eindeutige Antwort, und sie unbesehen anzuwenden wäre dieselbe Inversion, die die Artefaktklassen-Tabelle schon einmal verursacht hat |

## Konsequenzen

- **Positiv:** die Frage *„durfte dieser Lauf das schreiben?"* ist für Anweisungssätze vor
  der Änderung beantwortbar, ohne dass ein Register von Zuordnungen entsteht, das driftet.
- **Positiv, und nur für einen Teil:** `BEO-007` bekommt für die **Anweisungssatz**-Artefakte eine
  benannte Quelle statt einer gelebten, nirgends festgehaltenen Praxis. **Die übrigen Teile der
  Zeile bleiben offen** — `.claude/agents/*.md` nimmt Festlegung 3 ausdrücklich aus, und die zwei
  jüngsten Belege der Zeile liegen bei den Spec-Straten, für die diese ADR nichts sagt (§Kontext,
  §Was hier NICHT entschieden ist). Wer die Zeile auf *verkörpert* setzt, ohne das zu trennen,
  verliert genau die Beobachtung, für die der Zähler zählt.
- **Positiv:** kein zusätzlicher Rollenwechsel für die Regelfälle — die ausführende Rolle pflegt ihr
  eigenes Werkzeug weiter selbst, mit der normalen Review-Prüfung (Diff gegen Plan/ADR/Hard Rules)
  als Kontrolle, statt jeder operativen Änderung ein Architect-Gate vorzuschalten.
- **Negativ, und das ist der Preis:** die Grenze aus Festlegung 2 (Norm-Aussage ohne Original) ist
  ein Urteil je Änderung, kein Muster — wer sie falsch zieht, verschiebt genau die Klasse Fehler,
  die [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) beheben sollte, nur an eine andere
  Stelle. Und **wer sie richtig zieht, steht ohne Adresse da**: Festlegung 2 benennt keine Rolle
  für den ausgenommenen Teil.
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
| — | **keine.** Der prüfbare Teil wäre *„ein Anweisungssatz-Artefakt ändert sich, ohne dass die Rolle, die seinen Ablauf ausführt, den Commit trägt"* — eine **Commit**-Bedingung, und sie ist hier so wenig gebaut wie bei [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 2, [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und [ADR-0025](0025-register-mit-gemischten-originalen.md) | — |

**Was hier bewusst NICHT steht.** Ein Sensor müsste **Commits** lesen; kein Modul der heutigen
`.d-check.yml`-Konfiguration tut das (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors,
ids, matrix, codepaths, spans`), und `make mutate` kennt zwei Fehlschlag-Formen — `--- FAIL:` der
Go-Stufe, `not ok N` der bats-Stufe —, keine, in der ein Commit-Zuschnitt rot wird. Auch die
Vorfrage aus Festlegung 2 ist unbewacht: ob ein Anweisungssatz eine Norm-Aussage ohne Original
trägt, sieht kein `grep`. Behauptet wird hier **kein** Gate
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Träger
ist der Rollen-Wechsel vor der Änderung.

## Re-Evaluierungs-Trigger

- **Wenn ein künftiger Baseline-Stand eine schreibende Rolle für Command- oder Skill-Artefakte
  allgemein benennt** *(feedforward — eine Textänderung upstream, kein Sensor)*: dann ist diese ADR
  gegenstandslos und wird durch eine Nachfolge-ADR mit *Supersedes* auf den Baseline-Abschnitt
  zurückgeführt. `v5.18.0` benennt keine über den Skill-Datei-Fall hinaus (§Kontext); die einzige
  Nennung der Command-Form im ganzen Baum führt sie als Glied eines Artefakt-Sets ohne
  Rollen-Aussage — die Fundstelle nennt das Kommando selbst, **kein** Erwartungswert:
  `grep -rl 'claude/commands' .harness/baseline/v5.18.0/` → `grundlagen-durchsetzungsschicht.md`.
- **Wenn ein Anweisungssatz entsteht, der nicht eindeutig einer einzelnen Rolle als Ausführer
  zuzuordnen ist** *(feedforward — der erste Command, der mehrere Rollen gleichrangig
  orchestriert)*: dann liefert Festlegung 1 keine eindeutige Antwort, und die Frage braucht eine
  eigene Entscheidung nach demselben Muster wie
  [ADR-0025](0025-register-mit-gemischten-originalen.md) für gemischte Originale.
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

## Verbatim-Proben

Die Wortlaute unten belegen **zehn** Baseline-Aussagen — der Konflikt-Pfad ist über zwei Fragmente
belegt, darum sind es **elf** Kommandos —, und jeder steht am adoptierten Stand `v5.18.0` genau
einmal; whitespace-normalisiert geprüft, wie
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 *verbatim* definiert (*„der Wortlaut
ohne Auszeichnung, Whitespace normalisiert"*). Die Ausgabe jedes Kommandos ist **1**. Die Zahl der
Proben ist selbst gemessen und **kein** Erwartungswert
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):
`awk '/^## Verbatim-Proben/,/^## Geschichte/' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md | grep -c '^tr '`
→ **11**.

```sh
M8=.harness/baseline/v5.18.0/regelwerk/modul-08-agentenrollen.md
M6=.harness/baseline/v5.18.0/regelwerk/modul-06-roadmap.md
M10=.harness/baseline/v5.18.0/regelwerk/modul-10-review-harness.md
GB=.harness/baseline/v5.18.0/regelwerk/grundlagen-bootstrap.md
M4=.harness/baseline/v5.18.0/regelwerk/modul-04-adrs.md

tr '\n' ' ' < $M8 | tr -s ' ' | grep -cF 'bei isolierten LOW/INFO-Findings ist die Sequenz Overkill'
tr '\n' ' ' < $M8 | tr -s ' ' | grep -cF 'Sie greift ab **HIGH mit Rollen-Widerspruch** oder ab dem **dritten** gleichen Konflikttyp'
tr '\n' ' ' < $M8 | tr -s ' ' | grep -cF '**Briefing** (`AGENTS.md` + 8-Schritt-Workflow)'
tr '\n' ' ' < $M8 | tr -s ' ' | grep -cF 'R aktualisiert Skill-Datei'
tr '\n' ' ' < $M8 | tr -s ' ' | grep -cF 'Nur 1, 2 und 3b tragen einen Rollenwechsel; 3a, 3c, 4, 5 und 6 laufen im Planner-Kontext'
tr '\n' ' ' < $M6 | tr -s ' ' | grep -cF 'Die Eröffnung ist Planner-Arbeit'
tr '\n' ' ' < $M6 | tr -s ' ' | grep -cF '**Bei 3×** wandert der Eintrag in die Steering-Loop-Einträge der laufenden Welle-Closure'
tr '\n' ' ' < $M10 | tr -s ' ' | grep -cF 'Die Aussage gehört an den zitierenden Ort, die Report-Kennung bleibt im Text'
tr '\n' ' ' < $GB | tr -s ' ' | grep -cF 'ADR-Review-Runde abgeschlossen → bindend'
tr '\n' ' ' < $M4 | tr -s ' ' | grep -cF 'Eine ADR mit Status `Accepted` wird nicht inhaltlich überschrieben'
tr '\n' ' ' < $M6 | tr -s ' ' | grep -cF 'Review-Reports bekommen keinen Stub; sie haben keine Identität jenseits ihres Slice.'
```

Der lokale Pfad steht hier als **Gegenstand der Probe**, nicht als Adresse eines Belegs — die
Unterscheidung, die [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) §Geschichte für sich selbst
zieht. Die Belege oben tragen Tag, Dateiname, Abschnittsname und Zitat; kein Markdown-Link dieser
Datei zeigt in den vendored Baum
(`grep -c ']([^)]*\.harness/baseline/' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md` → **0**).

**Aus demselben Grund nennt diese Datei Review-Reports bei ihrer Kennung und nie unter ihrer
Adresse.** `v5.18.0`, `modul-10-review-harness.md` §Reviewer berichtet auch, was er nicht gefunden
hat hält für ein Rang-Dokument fest: *„Die Aussage gehört an den zitierenden Ort, die
Report-Kennung bleibt im Text."* Das ist dieselbe Trennung, die
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 für die Gegenrichtung zieht — dort
verliert ein Verweis *in* einem Zeitdokument seine Adresse und behält seinen Text, hier ein Verweis
*auf* eines. Der Grund ist derselbe wie beim vendored Baum: die Adresse verfällt, die Aussage
nicht. `v5.18.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur sagt für die Archivierung
ausdrücklich: *„Review-Reports bekommen keinen Stub; sie haben keine Identität jenseits ihres
Slice."* Nach `Accepted` sperrt [`AGENTS.md`](../../../AGENTS.md) §3.4 die Ein-Zeilen-Korrektur,
mit der ein toter Report-Pfad sonst nachgezogen würde.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-31 | **Proposed** | Architect-Verdikt auf eine Reviewer-Eskalation, Report `2026-08-31-slice-144-review.md` HIGH-1. Ausgelöst über den Konflikt-Pfad aus `v5.12.0`, `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz (Pflicht ab HIGH mit Rollen-Widerspruch). Gewähltes Verdikt der drei aus dessen Tabelle: *„Lockerung legitim, aber undokumentiert"* — Selbst-Autorschaft des eigenen operativen Anweisungssatzes war durch den Baseline-eigenen Konflikt-Pfad-Präzedenzfall („R aktualisiert Skill-Datei") bereits der Form nach gedeckt, nur nie für die Command-Form derselben Artefaktklasse als Norm festgehalten. Der Acceptance-Trigger der Baseline (`v5.12.0`, `grundlagen-bootstrap.md` §Vier Trigger-Klassen: *„ADR-Review-Runde abgeschlossen → bindend"*) hat **nicht** stattgefunden — dieselbe Zurückhaltung wie bei [ADR-0025](0025-register-mit-gemischten-originalen.md): der Bestand begründet keinen Status |
| 2026-09-02 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-02-adr-0028-konsistenz-review.md`, Verdikt *Konsistenz NICHT bestätigt*, Statuswechsel blockiert. Vier Befunde treffen den Text, alle im `Proposed`-Fenster behoben. **HIGH-1:** die acht Baseline-Belege trugen den Tag nicht, den [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 verlangt und deren Festlegung 3 (a) zur Vorbedingung genau dieses Übergangs macht; jeder Beleg bekam Tag, Dateiname, Abschnittsname und Zitat, und §Verbatim-Proben wurde als nachfahrbarer Block angelegt. Eine Verortung war falsch: *„Nur 1, 2 und 3b …"* steht in `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, nicht in `modul-06-roadmap.md`. **MEDIUM-1:** die vier `git log`-Kommandos liefen ohne Ref gegen `HEAD` und gaben dort **13/1/4/0** statt der abgedruckten **10/0/3/0**; sie tragen jetzt die Mess-Basis `7485be3` und sind als *keine Erwartungswerte* gekennzeichnet, und der von ihnen getragene Satz („kein Rollen-präfigiertes Commit") ist durch den gemessenen Befund ersetzt. **MEDIUM-2:** Festlegung 2 wies den ausgenommenen Teil dem Architect zu und schrieb die Zuordnung [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) zu, deren §Was hier NICHT entschieden ist *„eine Eigentums-Aussage über irgendein drittes Artefakt"* ausdrücklich ausnimmt; der Teil bleibt jetzt offen. **MEDIUM-3** trifft die Plan-Datei, wirkt aber hierher: `BEO-007` steht nicht bei 1×, sondern bei 4×, und zwei seiner Belege liegen bei den Spec-Straten — §Kontext, der zweite Positiv-Punkt und §Was hier NICHT entschieden ist trennen die beantwortete von der offenen Hälfte. Dazu **LOW-1** (die Verlagerung der sechs kanonischen Namen vollzog [`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) mit **vollständiger** Aufhebung von [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung), nicht [`MR-030`](../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) mit einer Teil-Aufhebung) und **INFO-1** (der Geltungsbereich ist jetzt ausgesprochen — gebunden ist die Artefaktklasse, nicht die Datei-Form; die Anwendungs-Tabelle führt `.harness/skills/reviewer.md` mit) |
| 2026-09-03 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-03-adr-0028-konsistenz-review-runde-2.md`, Verdikt *Konsistenz NICHT bestätigt*: die sechs Befunde der Vorrunde sind behoben, dazwischen ist der Baseline-Tausch auf `v5.18.0` gefallen. **HIGH-1:** die Belege waren gegen den abgelösten Stand gemessen; jede Präsens-Aussage über den vendored Baum ist am adoptierten Stand neu gefahren, und §Verbatim-Proben trägt die `v5.18.0`-Pfade. **Ein Tag-Tausch allein trug nicht:** `v5.18.0` schreibt *„3a, 3c, 4, 5 und 6 laufen im Planner-Kontext"*, weil die Wellen-Closure einen sechsten Schritt (Zeitdokumente archivieren) bekommen hat — das Zitat in Festlegung 1 ist wortgetreu nachgezogen, die Planner-Zuordnung, die es trägt, bleibt unverändert. Die übrigen Wortlaute stehen am neuen Stand je einmal; die tragende Negativ-Prämisse (Re-Evaluierungs-Trigger 1) hält, mit dem Mess-Kommando daneben. Die Tags in den zwei Zeilen oben datieren ihre eigene Runde und bleiben stehen. **MEDIUM-1:** die zwei Markdown-Links auf Review-Reports und die eine Pfad-Nennung in §Kontext sind durch die Report-Kennung ersetzt; der Grund und die zwei Quellen stehen am Ende von §Verbatim-Proben. Dazu **LOW-1** (der Kopf von §Verbatim-Proben zählte sieben Aussagen bei neun Kommandos — jetzt neun Aussagen, zehn Kommandos, mit Zähl-Kommando) und **LOW-2** (die Anwendungs-Tabelle sagte *erste Zeile*, gemessen steht der Satz im Eröffnungssatz). **INFO-1** betrifft [ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md), **MEDIUM-2** den Planner-Plan; beide sind hier nicht behoben und blockieren diesen Text nicht. Der Statuswechsel bleibt offen: eine dritte Runde prüft diese Korrektur |
| 2026-09-03 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-03-adr-0028-konsistenz-review-runde-3.md`, Verdikt *Konsistenz NICHT bestätigt*, ohne inhaltlichen Einwand gegen die Entscheidung selbst; beide Befunde treffen die Beleg-Form. **HIGH-1:** der Beleg für den Verfall einer Report-Adresse trug Tag, Dateiname und Abschnittsname, statt des Zitats aber die Ordnungszahl *Schritt 4* — und deren Gegenstand hat sich beim letzten Baseline-Sprung verschoben. Er trägt jetzt den Wortlaut *„Review-Reports bekommen keinen Stub; sie haben keine Identität jenseits ihres Slice."* und keine Nummer mehr; §Verbatim-Proben führt ihn als elfte Probe, und der zuvor unbelegte Satz über die fehlende Identität eines Reports ist in diesem Zitat aufgegangen. **MEDIUM-1:** das `BEO-007`-Zitat *„Umgangen, nicht gelöst …"* stand an keinem der zwei Refs, die diese Datei nennt — die `Stand`-Zelle hat es verloren und ist seither erneut umgeschrieben worden. Aus dem Register übernimmt diese Datei jetzt Bezeichnung, Zähler und Belege und **keinen** Wortlaut der `Stand`-Zelle (§Mess-Basis dieses Dokuments); §Kontext trägt die Aussage über die gelebte Praxis auf dem Gründungs-Commit und den vier Dateien, und der zweite Positiv-Punkt spricht von **drei** offenen Teilen der Zeile statt von zwei Hälften. Dazu **LOW-1** (die `Bezug:`-Zeile schrieb [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 die Verweis-Form *auf* Zeitdokumente zu; die Festlegung regelt die Gegenrichtung) und **LOW-2** (die Mess-Basis-Klausel galt für *jede* Zahl, während zwei selbstbezügliche sie nicht tragen können — die Klausel nimmt sie jetzt ausdrücklich aus, und der Eröffnungssatz-Fund läuft gegen die Ref). **INFO-1** betrifft [ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md), **MEDIUM-2** den Planner-Plan; beide sind hier nicht behoben und blockieren diesen Text nicht. Der Statuswechsel bleibt offen: eine vierte Runde prüft diese Korrektur |
| 2026-09-03 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-03-adr-0028-konsistenz-review-runde-4.md`, Verdikt *Konsistenz NICHT bestätigt*, ohne inhaltlichen Einwand gegen die Entscheidung selbst; die **vier** Befunde der Vorrunde am ADR-Text sind einzeln nachgemessen und behoben — von Hand gezählt, weil die Zuordnung ein Urteil und kein Muster ist ([`AGENTS.md`](../../../AGENTS.md) §3.6) —, ihr fünfter (**INFO-1**) betrifft [ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md) und kehrt unten als **INFO-2** wieder. **MEDIUM-1:** §Der Anlass beschrieb den Liefergegenstand im Präsens und ohne Ref — *„Schritt 9 und 23 dort verweisen auf den blanken `git mv`"* und *„Geliefert wurde die Zeile nicht"*. Beides traf schon an der Mess-Basis dieser Datei nicht mehr zu: die Zeile ist mit `fc1fc54` nachgetragen, noch am Tag des Anlege-Commits. Die Stelle nennt jetzt den Nacharbeits-Commit, bindet ihre Werte an drei feste Stände und trägt die zwei Kommandos daneben. Der Kern des Anlasses — der Implementer entschied allein, wo keine Quelle die Rolle benennt — ist von der Nachlieferung unberührt, ebenso die drei Festlegungen. **MEDIUM-2** trifft den Planner-Plan, **INFO-1** einen Commit nach der Mess-Basis (vom Cutoff gedeckt, Re-Evaluierungs-Trigger 4 zählt ihn nicht), **INFO-2** [ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md); keiner ist hier behoben, keiner blockiert diesen Text. Der Statuswechsel bleibt offen: eine fünfte Runde prüft diese Korrektur |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0028` (Baseline-Regelwerk `v5.18.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs: *„Eine ADR mit Status `Accepted` wird nicht inhaltlich
überschrieben"*).
