# ADR-0069: Ein Verzeichnis des Beobachtungs-Registers ohne Beleg ist ein Befund der Register-Paarung und keine Ausnahme — „benannt, nicht gezählt" ist ein Abschnitt des belegten Eintrags

**Status:** Accepted

**Datum:** 2026-09-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(**Accepted** — Festlegung 3: die Kennung **ist** der Pfad `BEO-<KUERZEL>/<slug>`; die
Verzeichnis-Form mit drei Dateien und der aus den Dateien abgeleitete Zähler bleiben unberührt),
[ADR-0049](0049-ausgang-traegt-die-benannte-luecke.md) (**Accepted** — welchen Ausgang ein Eintrag
ab 3× trägt; diese Entscheidung berührt die **Beleg**-Frage, nicht die Ausgangs-Frage),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (**Accepted** — der Beleg des
Accept-Übergangs),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (**Accepted** — wem `AGENTS.md` §3 und der
Adaptions-Block gehören; keines von beiden ist der Gegenstand hier),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Prüfung, die über einem Bestand rot steht, den ihre eigene Regel nicht ausnimmt, ist benannt —
nicht als grün behauptet),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung von der
Baseline schuldet einen Eintrag — diese Entscheidung ist keine, §Konsequenzen),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Sie liest eine Regel der Baseline für die Ablage
dieses Repos aus; sie setzt keine neue.

**Supersedes:** keine. Keine Festlegung einer `Accepted`-ADR wird abgelöst oder geschärft.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR); Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register und
§Wellen-Closure-Prozedur (Modul 6), Closure-Schritt 3 (die drei Paarungen), gelesen gegen `v6.9.0`;
Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln (das Architect-Verdikt ist ein
Artefakt).

---

## Kontext

### Zwei Sätze der Baseline, ein Bestand

Die Beleg-Regel sagt für ein Vorkommen ohne abgeschlossenen Vorgang, in
`modul-06-roadmap.md` §Das Beobachtungs-Register: *„Ein Vorkommen **ohne** abgeschlossenen Vorgang
bekommt keinen Beleg und bewegt den Zähler nicht; es gehört trotzdem in den Eintrag — *benannt,
nicht gezählt.*"* Die maschinelle Hälfte der Register-Paarung (c) sagt, im selben Modul:
*„ob jedes Verzeichnis ein nicht leeres `evidence/` hat"*, und in der Closure-Prozedur:
*„jede Registerzeile trägt mindestens einen Beleg"*; ihr Rot bedeutet dort *„etwas wurde versprochen
und nicht angelegt"*. Ein Eintrag, dessen **einziges** Vorkommen keinen Vorgang hat, kann die zweite
Regel nicht bestehen und darf nach der ersten keine Datei unter `evidence/` haben.

Der Fall ist eingetreten. Gemessen am Stand dieser Entscheidung (keine Erwartungswerte, der Bestand
wandert mit jeder Closure):

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do
  n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done | wc -l   # 4
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                                      # 180
```

Vier von 180 Verzeichnissen tragen keinen Beleg; jedes nennt sein Vorkommen unter *„Benannt, nicht
gezählt"*, und zwei von ihnen sagen selbst, dass die Paarung für sie rot ist
(`grep -rl 'Paarung' <die vier Verzeichnisse> | wc -l` → **2**, beide `state.md`). Die Paarung wird
heute **von Hand** gefahren — die Doku-Gate-Konfiguration hält ihre zweite Hälfte nicht:
`make docs-check` bleibt über einem Register mit einem fünften Verzeichnis ohne `evidence/` grün, und
der Block `planning:` der `.d-check.yml` führt keinen `observations`-Schlüssel:

```sh
K=$(mktemp -d); git archive HEAD | tar -x -C "$K"
mkdir "$K/docs/plan/planning/observations/BEO-ALL/sonde"
cp docs/plan/planning/observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/{observation,state}.md \
   "$K/docs/plan/planning/observations/BEO-ALL/sonde/"
docker run --rm --network none -v "$K:/repo:ro" \
  "ghcr.io/pt9912/d-check@$(sed -n 's/^DCHECK_DIGEST ?= //p' d-check.mk)" | tail -1   # d-check: <N> Datei(en) geprüft, 0 Befund(e)
awk '/^planning:/{f=1} f&&/^[a-z]/&&!/^planning:/{f=0} f' .d-check.yml | grep -c observations  # 0
```

Die Sonde liegt außerhalb des Repos; der unveränderte Baum meldet dieselbe Bilanz mit zwei Dateien weniger
(`0 Befund(e)`). Die Fähigkeit `observations` des Moduls `planning` steht in
`harness/sensors/docs-check.md` als verfügbar und nicht aktiviert; ob sie aktiviert die zweite Hälfte hielte,
ist ungemessen (§Was hier nicht entschieden ist). Eine Closure hat das Rot bisher als *„Ausnahme in der
Closure-Notiz"* benannt. Diese Ausnahme steht in keiner Norm.

### Was die zwei Lesarten sind

- **(a)** *„Benannt, nicht gezählt"* ist ein **Abschnitt innerhalb eines belegten Eintrags**. Ein
  Verzeichnis ohne Beleg ist dann eine **Form-Schuld**, und die Paarung meldet es.
- **(b)** *„Benannt, nicht gezählt"* ist ein **eigenständiger Eintrag**. Die Paarung braucht dann eine
  **Ausnahme** für ihn und eine Form, an der sie ihn von einem vergessenen Beleg unterscheidet.

### Was gegen (b) gemessen ist

Die Form, an der (b) ansetzen könnte, ist die Überschrift des Abschnitts — und die trennt nicht:

```sh
for d in docs/plan/planning/observations/BEO-ALL/*/; do
  n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); h=$(grep -c '^## Benannt, nicht gezählt' "$d"observation.md)
  [ "$h" -gt 0 ] && echo "$n"; done | awk '{t++; if ($1 > 0) b++} END {print "abschnitt="t" mit_beleg="b}'
# abschnitt=62 mit_beleg=58
```

**62** Verzeichnisse tragen den Abschnitt, **58** davon **haben** Belege. Eine Ausnahme, die am
Abschnitt hängt, nähme darum 58 belegte Verzeichnisse mit und würde bei ihnen einen künftig
**vergessenen** Beleg still durchlassen — genau die Unterscheidung, die (b) leisten soll, leistet die
Überschrift nicht. Ein unterscheidendes Merkmal müsste ein **neues Feld** sein (etwa ein Stand
*„ohne Beleg"*), das die Ziel-Form der Baseline nicht führt.

**Und das Template der Baseline stützt (a) an zwei Stellen.** Der Abschnitt gehört dort zum Rumpf **jeder**
`observation.md` (*„Benannt, nicht gezählt — <Vorkommen ohne abgeschlossenen Vorgang …>. Weglassen, wenn
keine."*), und die Vorlage sagt zum Verzeichnis: *„Erfinde keine Belege: Ein Verzeichnis entsteht beim
ERSTauftreten einer echten Beobachtung, nicht beim Adoptieren dieser Vorlage."*
(`sed -n 25,62p .harness/baseline/v6.9.0/templates/docs/plan/planning/observation.template.md`) — das
Verzeichnis entsteht mit der Beobachtung, der Abschnitt ist ein Teil von ihr, und ein Beleg wird nicht
erfunden, damit die Paarung grün wird.

## Entscheidung

**Wir wählen (a): die Baseline gilt wörtlich, ein Verzeichnis ohne Beleg ist ein Befund der
Paarung.** Vier Festlegungen.

**1. „Benannt, nicht gezählt" ist ein Abschnitt des belegten Eintrags.** Das Vorkommen ohne Vorgang
*„gehört trotzdem in den Eintrag"* — der Eintrag ist der der **Klasse**, und er trägt mindestens
einen Beleg. Es gibt **keine zweite Sorte Verzeichnis**: keinen *„Eintrag ohne Beleg"* mit eigener
Form, eigenem Stand oder eigener Marke. Ein Verzeichnis, dessen einziges Vorkommen unter *„Benannt,
nicht gezählt"* steht, ist ein Eintrag, dem sein Beleg **noch fehlt** — kein Eintrag anderer Art.

**2. Die Paarung (c), zweite Hälfte, kennt keine Ausnahme — und ihr Umfang ist das ganze Register,
auch im Closure-Schritt.** Jedes Verzeichnis ohne nicht leeres `evidence/*.md` ist ein **Befund**; es
gibt keine Liste, keinen Marker und keine Klasse, die ihn ausnimmt. Ein Befund ist **keine Senkung**
nach [`AGENTS.md`](../../../AGENTS.md) §3.5: er ändert keine Schwelle, er benennt einen Bestand.

*Der Baseline-Wortlaut*, der den Umfang trägt, ist an beiden Stellen universal: *„jede Registerzeile
trägt mindestens einen Beleg"* (Closure-Schritt 3, Paarung (c)) und *„ob **jedes** Verzeichnis ein nicht
leeres `evidence/` hat"* (§Das Beobachtungs-Register). Der Satz *„erst jetzt, weil sie die gerade
entstandenen Einträge prüfen; in Schritt 2 gäbe es sie noch nicht"* begründet den **Zeitpunkt** der
Paarungen im Ablauf — nach den Schritten, die die Einträge erzeugen —, nicht den Umfang der zweiten Hälfte
von (c): gebunden an die Closure ist die **erste** Hälfte (die *„in einer Closure-Notiz oder einem
Risiko-Ausgang genannte"* Beobachtung), die zweite nennt jede Registerzeile. Ein Umfang *„nur die von
dieser Closure angelegten oder berührten Verzeichnisse"* steht dort nicht.

*Die Folge:* die Paarung als Closure-Schritt und die Bestandsprüfung (ein Lauf von Hand, später ein
Wächter) sind **ein** Maßstab, kein Doppelmaßstab. Eine Closure, die die Paarung fährt, prüft die zweite
Hälfte über **das ganze Register** und **nennt jedes Verzeichnis ohne Beleg namentlich** als Befund — nicht
*„getragen, mit Ausnahme"*, nicht *„formal rot"* ohne Namen und nicht nur die Verzeichnisse, die sie selbst
angelegt oder berührt hat. Wer die Paarung fährt und Befunde findet, behauptet sie nicht als getragen.

*Der Preis:* bis der Bestand getilgt ist, trägt jede Closure eine Zeile mit den Namen (heute vier, das
Kommando steht in §Kontext) und das Rot der zweiten Hälfte bleibt in jeder Closure sichtbar. Das ist die
Zusage, die die Ausnahme ersetzt, und kein Nebeneffekt.

**3. Der Befund geht durch einen Beleg — und durch nichts sonst.** Er endet, wenn ein
abgeschlossener Vorgang das Vorkommen trifft und seine Kennung als Datei unter `evidence/` liegt
(Regelfall die Slice-Closure, die die Klasse beobachtet; nach der Baseline auch eine Welle oder ein
Review-Report). **Ein Beleg wird nicht erfunden:** eine Kennung als Dateiname behauptet, dass das
Vorkommen in **diesem** Vorgang aufgetreten ist (*„Der Beleg ist formgebunden"*); ein Vorgang, der
die Beobachtung nur verwaltet — das Anlegen des Verzeichnisses, ein Verdikt über sie —, ist kein
Auftreten.

**4. Eine Klasse, deren Vorkommen eine Bestands-Aussage ist, ist keine Ausnahme.** Der Einwand
*„ein Beleg je Closure zählte Closures statt Wiederholungen"* trägt keine Ausnahme: der Zähler misst
nach der Baseline **Wiederholung über Vorgänge hinweg** (*„Ein Vorgang zählt einmal"*). Trifft eine
Klasse nahezu jede Closure, hat sie Belege, und die 3×-Schwelle greift — das ist die Antwort des
Registers auf diese Lage. **Welche Vorgänge die Klasse tatsächlich trafen, urteilt der Planner je
Vorgang** (*„Mensch urteilt, Maschine prüft Deckung"*); die Entscheidung schließt keinen Weg und
schreibt keinen vor. **Ein Eintrag im Bestand nennt diesen Einwand als seinen Grund:** die
`observation.md` von `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird` begründet ihren
fehlenden Beleg wörtlich damit. Die Festlegung widerspricht diesem Rumpf; der Rumpf bleibt (unveränderlich,
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)), und ab dem
Accept gilt für die Ablage diese Festlegung. Der Eintrag ist einer der vier aus §Kontext. Trigger 1 löst
für ihn nicht aus: er verlangt das Urteil des Planners, dass die Klasse **keinen** Vorgang trifft, und der
Rumpf sagt das Gegenteil (*„nahezu jede Closure"*) — für ihn gilt der Weg über Belege nach dieser Festlegung.

**Was hier NICHT entschieden ist:**

- **Was mit einem Verzeichnis geschieht, das nie einen Beleg bekommen kann** — eine Klasse, deren
  Vorkommen nach dem Urteil des Planners **keinen** abgeschlossenen Vorgang trifft. Die Baseline
  kennt für ein nie gezähltes Verzeichnis weder `gestrichen` (*„die Beobachtung kann nicht mehr
  auftreten"*) noch den Rückbau; das ist der Re-Evaluierungs-Trigger 1, nicht eine Festlegung.
- **Der Bestand.** Die vier Verzeichnisse bleiben, wie sie stehen; ein Nachzug ist kein Auftrag
  dieser Entscheidung (Cutoff unten).
- **Die Ausgangs-Regel** ([ADR-0049](0049-ausgang-traegt-die-benannte-luecke.md)) und die
  Verzeichnis-Form ([ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)).
- **Ob die Fähigkeit `planning.observations` des gepinnten Doku-Gate-Werkzeugs, aktiviert, die zweite
  Hälfte hält.** Sie ist heute nicht aktiviert (§Kontext); ihr Prüfgegenstand ist die Existenz von
  `observation.md` zu einer zitierten Kennung, und ob sie ein leeres `evidence/` meldet, ist
  **ungemessen**. Diese Entscheidung sagt darüber nichts.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun; die Closure benennt das Rot als „Ausnahme in der Closure-Notiz" weiter | keine Norm-Arbeit | die Ausnahme steht in keiner Norm, hat keine Grenze und keinen Träger; jede Closure erfindet ihren Wortlaut neu, und ein künftiger Wächter fände eine Ausnahme vor, die niemand entschieden hat — das Gate gegen einen Widerspruch statt einer Deckung |
| B — (b): eine Ausnahme mit Form für „benannt, nicht gezählt"-Einträge | ein belegloses Verzeichnis wäre ein zulässiger Zustand; kein Dauer-Rot | die Überschrift trennt nicht (62 tragen sie, 58 davon mit Beleg, §Kontext); ein **neues Feld** wäre nötig, das die Ziel-Form der Baseline nicht führt; die Ausnahme nimmt der Paarung eine Prüfung, die die Baseline **unbedingt** formuliert — eine Lockerung nach §3.5 (ADR) **und** eine Abweichung nach [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (Eintrag im Adaptions-Block) |
| C — beleglose Verzeichnisse verbieten; ein Vorkommen ohne Vorgang wird nicht registriert | die Paarung bliebe grün; das Template sagt *„Erfinde keine Belege: Ein Verzeichnis entsteht beim ERSTauftreten einer echten Beobachtung"* — kein Verzeichnis entstünde ohne Beleg | ein Vorkommen ohne Vorgang hätte **keinen** Ort — der Befund, den ein Lauf außerhalb einer Closure macht, verschwände spurlos; die Baseline sagt das Gegenteil (*„gehört trotzdem in den Eintrag"*), und das Template führt den Abschnitt *„Benannt, nicht gezählt"* im Rumpf **jeder** `observation.md` — es verlangt einen Ort für das Vorkommen, nicht dessen Verbot. Das Erfinde-Verbot trifft den **Beleg** (Festlegung 3), nicht das Verzeichnis |
| D — den Vorgang der Aufnahme als Beleg zulassen | kein Verzeichnis bliebe beleglos | eine Kennung als Dateiname wäre kein Auftreten mehr, sondern die Buchung des Eintrags selbst; der Zähler zählte die Verwaltung der Klasse — die falsche Aussage, gegen die die formgebundene Beleg-Regel steht |
| F — die Paarung im Closure-Schritt prüft nur die *„gerade entstandenen Einträge"* | der Baseline-Satz hat grammatisch die Paarungen zum Subjekt und nennt ihren Prüfgegenstand (*„… weil **sie** die gerade entstandenen Einträge prüfen"*), F liest ihn wörtlich; die Closure-Notiz bliebe kurz, und nur die von der Closure berührten Verzeichnisse würden genannt | liest den Zeitpunkt-Grund der Baseline (*„erst jetzt, weil sie die gerade entstandenen Einträge prüfen"*) als Umfang der zweiten Hälfte, die die Baseline universal führt (*„jede Registerzeile"*); eine Closure könnte die Hälfte als getragen abhaken, ohne die vier Verzeichnisse zu nennen — die *„Ausnahme in der Closure-Notiz"*, die diese Entscheidung beenden will, unter anderem Namen |
| **E — (a): die Baseline wörtlich, der Befund benannt, der Beleg als einziger Weg (gewählt)** | keine Abweichung, keine Lockerung, kein neues Feld; der Befund hat einen Namen, eine Form der Meldung und einen Tilgungsweg; die Paarung urteilt gegen dieselbe Regel, die die Baseline schreibt — im Closure-Schritt wie in der Bestandsprüfung | ein Bestands-Rot bleibt bis zum Beleg **sichtbar** und steht als Zeile in jeder Closure: ein Wächter für die zweite Hälfte kann erst grün werden, wenn der Bestand getilgt ist; das ist der Preis der Ehrlichkeit, nicht ein Fehler der Wahl |

**Warum E und nicht A.** A ist die kleinere Handlung, und sie hält den Betrieb. Gegen A spricht, dass
die Ausnahme dann **unbenannt** bliebe — ohne Grenze, ohne Träger, ohne Aussage, wann sie endet — und
ein späterer Wächter sie als Normalzustand erbte.

## Konsequenzen

- **Positiv:** eine Lesart statt einer Ad-hoc-Ausnahme; die Meldung der Paarung ist namentlich und
  behauptet nichts, was sie nicht hält; ein späterer Wächter über der zweiten Hälfte hat eine Regel
  ohne Liste, gegen die er urteilt.
- **Negativ:** das Rot bleibt, bis der Beleg da ist — für eine Klasse, die keinen Vorgang trifft,
  **unbegrenzt** (Re-Evaluierungs-Trigger 1). Jede Closure trägt bis dahin die Zeile mit den Namen
  (Festlegung 2). Ein Wächter, der die zweite Hälfte fährt, ist bis zur Tilgung des Bestands nicht
  verdrahtbar.
- **Kein Eintrag im Adaptions-Speicher.** Eine Abweichung von der Baseline liegt nicht vor: die
  Entscheidung liest die Paarung so, wie die Baseline sie **unbedingt** formuliert, und nimmt ihr
  nichts. Die Wahl (b) hätte einen Eintrag verlangt — sie ist der Grund, warum keiner entsteht
  ([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) verlangt ihn nur für
  Abweichungen).
- **Folgepflicht 1 — der Ort der Register-Regel.** Die Register-Ablage trägt die Lesart dort, wo sie
  die Beleg-Regel führt (der Absatz *„Ein Vorgang zählt einmal"* ihrer `README.md`): ein Verzeichnis
  ohne Beleg ist ein Befund der Paarung, kein Eintrag eigener Art; die Meldung ist namentlich und
  erstreckt sich im Closure-Schritt auf das ganze Register.
  Das ist Arbeit des Planners, nicht dieser Entscheidung.
- **Folgepflicht 2 — kein Sensor liest die Existenz von `evidence/`.** Ein Sensor über dem Register
  zählt **Dateien** unter `evidence/`, nicht das Verzeichnis: ein leeres oder nur eine Nicht-`.md`-Datei
  tragendes `evidence/` ist ein Befund (Fitness Function unten, beide Fälle gesehen).
- **Cutoff — ab dieser Entscheidung, kein Nachrüsten.** Gebunden ist die Meldung, die geschrieben
  wird, und das Verzeichnis, das angelegt wird. Der Bestand aus §Kontext ist kein Arbeitsauftrag; er
  geht durch Belege, wenn Vorgänge ihn treffen. Das Nennen der Namen in der Closure ist keine Tilgung.

## Fitness Function

Keine maschinelle Durchsetzung: **ein Wächter existiert nicht** — keine aktivierte Regel der
Doku-Gate-Konfiguration hält die zweite Hälfte (die Sonde in §Kontext bleibt grün über einem fünften
Verzeichnis ohne `evidence/`), und ein Sensor darauf ist nicht gebaut. Benannt, nicht geschlossen; die
Prüfung ist ein Kommando, das ein Lauf fährt.

| Tooling | Regel | Make-Target |
|---|---|---|
| Shell-Schleife (Kommando in §Kontext; von Hand, in der Bestandsprüfung der Paarung und im Closure-Schritt) | Sie meldet **jedes** Verzeichnis ohne `evidence/*.md` — namentlich, ohne Ausnahmeliste | kein Target (`kein Gate`) |

**Rot gesehen** im Architect-Lauf dieser Entscheidung, in einer Kopie des Registers (Stand am
Tag des Entscheids): die Schleife meldet vier Verzeichnisse; ein hinzugefügtes Verzeichnis mit
`observation.md` (samt Abschnitt *„Benannt, nicht gezählt"*) ohne `evidence/` wird gemeldet (fünf);
mit leerem `evidence/` wird es gemeldet; mit einem `evidence/.gitkeep` (keine `.md`) wird es gemeldet;
mit einer `evidence/slice-x.md` wird es **nicht** mehr gemeldet (wieder vier). Die Zusage
*„die Prüfung nimmt niemanden aus"* bricht, sobald ein Abschnitt, ein Marker oder eine Liste ein
Verzeichnis ohne Datei aus der Meldung nimmt — das Gegenbeispiel ist das Verzeichnis mit Abschnitt und
ohne Datei, das die Schleife meldet.

## Re-Evaluierungs-Trigger

- **Ein Verzeichnis ohne Beleg, dessen Klasse nach dem Urteil des Planners keinen abgeschlossenen
  Vorgang treffen wird** *(beobachtbar an einem Verzeichnis, dessen `observation.md` das selbst sagt
  und für das kein Vorgang genannt ist, der es treffen könnte)*: dann trägt (a) nicht, und (b) —
  eine Ausnahme mit Form, ein Eintrag im Adaptions-Block, eine Lockerung nach §3.5 — ist mit dieser
  Evidenz neu zu wägen, als Folge-ADR.
- **Ein Wächter für die zweite Hälfte wird gebaut** und bleibt wegen des Bestands rot: der Bestand
  ist dann vor der Verdrahtung zu tilgen — durch Belege —, nicht durch eine Ausnahmeliste im Wächter.
- **Der adoptierte Baseline-Stand formuliert die Paarung (c) oder die Beleg-Regel anders.** Die Lesart
  ist dann gegen den neuen Wortlaut zu lesen.

**Wer diese Trigger beobachtet.** Kein Sensor. Der Lauf, der die Paarung fährt, nennt die
Verzeichnisse namentlich; der Planner urteilt, ob eines keinen Vorgang mehr treffen kann.
Benannt, nicht geschlossen.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`; bis dahin ist sie ein Architect-Verdikt und als solches das
Übergabe-Artefakt, das Planner und Implementer als Constraint lesen. Sie wird `Accepted`, **wenn eine
Reviewer-Runde sie gegen
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
[ADR-0049](0049-ausgang-traegt-die-benannte-luecke.md) und den Baseline-Wortlaut von
`modul-06-roadmap.md` (§Das Beobachtungs-Register, Closure-Schritt 3) auf Konsistenz geprüft hat und
ihr Report ohne blockierenden Befund an der **Substanz** der vier Festlegungen in `docs/reviews/`
liegt.** Ein blockierender Befund an der **Darstellung** wird behoben und hindert die Annahme nicht.
Der Beleg ist eine Runde der prüfenden Rolle; die Accept-Zeile der §Geschichte nennt ihn als
**Kennung**, nicht als Pfad-Link (ADR-0040 Festlegung 1). **Die Annahme selbst ist die Entscheidung
des Auftraggebers.**

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-26 | **Proposed** | Architect-Lauf: die Lesart der Beleg-Regel und der Register-Paarung (c), übergeben von einem Planner-Plan, der sie als Norm-Frage der Register-Form benannte. Der Acceptance-Trigger steht oben; Verdikt `2026-09-26-architect-verdikt-sammelauftrag-register-und-adr-0035` |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zum Konsistenz-Review `2026-09-26-review-adr-0035-0068-0069-konsistenz`, Status unverändert: Festlegung 2 hat einen Maßstab (die zweite Hälfte von (c) gilt im Closure-Schritt über das ganze Register, der Zeitpunkt-Satz der Baseline ist kein Umfang); die Aussage zum Doku-Gate ist gemessen; das Template stützt die Wahl; der Rumpf des Eintrags `planungs-bestand-waechst-schneller-als-er-abgebaut-wird` ist genannt; Verdikt `2026-09-26-architect-verdikt-korrektur-adr-0035-0068-0069` |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zur Kurzrunde `2026-09-26-review-kurzrunde-adr-0035-f5-und-adr-0069-f2`, Status unverändert: die Pro-Zelle der Alternative F nennt ihre stärkste Textstütze (der Baseline-Satz hat die Paarungen zum Subjekt); die Entscheidung bleibt |
| 2026-09-26 | **Accepted** | Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2: die Konsistenz-Runde `2026-09-26-review-adr-0035-0068-0069-konsistenz` (0 HIGH, zwei MEDIUM R-69-1 und R-69-2, Empfehlung „ja nach Korrektur") und, als erneute Runde der prüfenden Rolle nach deren Auflösung, die Kurzrunde `2026-09-26-review-kurzrunde-adr-0035-f5-und-adr-0069-f2` (0 HIGH, 0 MEDIUM, Empfehlung „ja"; sie prüfte die Fassung vor dem LOW-Punkt K69-1, die Differenz zur angenommenen Fassung ist die Pro-Zelle der Alternative F ohne Änderung der Entscheidung). Die Annahme hat der Auftraggeber am 2026-09-26 erteilt. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0069`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0069` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
