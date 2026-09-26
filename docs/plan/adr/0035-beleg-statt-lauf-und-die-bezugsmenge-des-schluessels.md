# ADR-0035: Ein Sensor darf einen Beleg statt eines Laufs ausgeben — seine Bezugsmenge ist der Prüfgegenstand, nicht der Arbeitsbaum

**Status:** Accepted

**Datum:** 2026-09-04

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Lauf,
der nichts misst und trotzdem ein Verdikt ausgibt, ist der halluzinierte Gate eine Ebene tiefer —
die Anforderung, die den **Fehlermodus** benennt),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (dieselbe Eingabe, dasselbe
Verdikt — die Invariante, die einen Beleg überhaupt wiederverwendbar macht),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Schlüssel entsteht
aus dem, was der Host ohnehin trägt),
[`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)
(das Deckungs-Kriterium, in diesem Repo schon einmal entschieden — diese ADR wendet es ein zweites
Mal an und legt seine **Beweisrichtung** fest),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(der inhaltsbasierte Nachweis und sein Zweck — der Gate-Nachweis, nicht ein zweiter Sensor),
[ADR-0013](0013-technik-stratum-als-zielort.md) (der Zielort technischer Festlegungen — hier
ausdrücklich **nicht** entschieden, §Was hier nicht entschieden ist),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (der Beleg des
Accept-Übergangs — §Der Acceptance-Trigger),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung von der
Baseline schuldet einen Eintrag — diese Entscheidung ist keine, §Konsequenzen),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Sie setzt eine Zulässigkeits-Bedingung für einen
repo-lokalen Sensor und keinen Wert; die Frage, ob eine Stellschraube dieses Sensors ins
Technik-Stratum gehört, bleibt offen und liegt bei einem anderen Träger.

---

## Kontext

`make mutate` ist der einzige operative Träger der Hard Rule
[`AGENTS.md`](../../../AGENTS.md) §3.6. Sein Kopf sagt selbst, warum: §3.6 ist die einzige Hard
Rule, die am ruhenden Baum nicht prüfbar ist — ein Wächter mit Zähnen und einer ohne sehen
identisch aus, und die einzige Messung, die den Unterschied sichtbar macht, ist Mutation. Der
Sensor misst damit die **Abwesenheit von Rot** und kann darum selbst still grün werden; sein Kopf
führt fünf fail-closed-Bedingungen, deren jede einen Weg dorthin schließt.

Er ist teuer. Der Treiber sammelt per Glob jede Fall-Datei ein und fährt je Fall einen vollen
Sensor-Lauf (`ls test/mutations/*.sh | wc -l` → **247** am 2026-09-04; **kein Erwartungswert**,
die Zahl wandert mit dem Bestand). Ein Plan schlägt darum vor, den Fall-Satz zu überspringen, wenn ein
aufgezeichneter vollständig grüner Lauf denselben Baum-Zustand belegt, und
[`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh) als Schlüssel
wiederzuverwenden. Zwei Fragen hat er nicht entschieden, sondern übergeben: ob ein solcher
Übersprung eine Schwellen-Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 ist, und welche
Bezugsmenge der Schlüssel trägt.

**Die Lage, gemessen** (Stand 2026-09-26; jeder Betrag dieses Abschnitts ist ein Stand, kein
Erwartungswert). `mutate` steht nicht in der Gate-Tabelle von `harness/README.md`, sondern in der
Werkzeug-Tabelle daneben, deren Zeilen die Marke `kein Gate` tragen, und nicht in der
Voraussetzungsliste des Nachweises:

```sh
awk '/^## Sensors/{f=1} /^### Werkzeuge/{f=0} f' harness/README.md | grep -c 'make mutate'    # 0  Gate-Tabelle
awk '/^### Werkzeuge/{f=1} /^## Traceability/{f=0} f' harness/README.md | grep -c 'make mutate'  # 1  Werkzeug-Tabelle
grep -c '^record-gates:.*mutate' Makefile                                                      # 0  Nachweis
```

Nach dem Etikett wäre §3.5 damit schon erledigt. Nach der Sache nicht: der Sensor trägt eine
**Hard Rule**, nicht ein Gate, und steht auf der Achse *Strenge* damit höher, nicht tiefer.

**Und der vorgeschlagene Schlüssel deckt den Prüfgegenstand nicht.** Der Prüfgegenstand von
`make mutate` ist nicht der Arbeitsbaum, sondern die **Isolationskopie**: `prepare_isolation` legt
sie je Worker außerhalb des Repos an, und jeder Sed und jeder Sensor-Lauf trifft nur sie. Diese
Kopie entsteht aus einer eigenen Definition — `tar` über alles außer `.harness/state/`, `.git`
ausdrücklich eingeschlossen, weil `# verify: ci-lint` ohne git-Projektwurzel abbricht.
`working-tree-hash.sh` ist eine **zweite**, unabhängig gepflegte Definition desselben Wortes
*Baum*, geschrieben für einen anderen Zweck (den Gate-Nachweis,
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)),
und sie fällt mit der ersten auseinander (Beträge: Stand des Entscheids am 2026-09-04):

```sh
export LC_ALL=C
A=$(tar -cf - --exclude=./.harness/state . | tar -tf - | sed 's|^\./||;/^$/d' | grep -v '/$' | sort -u)
B=$(git ls-files --cached --others --exclude-standard | sort -u)
printf '%s\n' "$A" | wc -l                                                 # 4352  von prepare_isolation kopiert
printf '%s\n' "$B" | wc -l                                                 # 1048  von working-tree-hash.sh gehasht
comm -23 <(printf '%s\n' "$A") <(printf '%s\n' "$B") | wc -l               # 3304  kopiert, nie gehasht
comm -13 <(printf '%s\n' "$A") <(printf '%s\n' "$B") | wc -l               #    0  gehasht, nicht kopiert
comm -23 <(printf '%s\n' "$A") <(printf '%s\n' "$B") | grep -vc '^\.git/'  #    1  davon ausserhalb von .git/
```

**Keine Erwartungswerte** — die Beträge wandern mit dem Baum; tragend ist die Richtung: der
Schlüssel ist eine **echte Teilmenge** dessen, was der Sensor liest. Der Rest ist heute fast
vollständig `.git/`, und der eine Pfad daneben ist `.claude/settings.local.json`. Beide sind
plausibel verdikt-irrelevant — aber die Differenz ist **nicht begrenzt**: sie wächst mit jedem
künftigen `.gitignore`-Eintrag, ohne dass eine der beiden Dateien angefasst würde. Das ist der
tragende Befund, nicht der Betrag 3304.

## Entscheidung

**Fünf Festlegungen.**

1. **Ein Beleg-Übersprung ist keine Schwellen-Senkung.** [`AGENTS.md`](../../../AGENTS.md) §3.5
   greift auf die **Verdikt-Funktion**: eine Senkung sagt über *derselben* Eingabe grün, wo sie
   rot sagte. Ein Beleg-Übersprung lässt die Verdikt-Funktion unberührt und verschiebt allein den
   **Zeitpunkt der Auswertung**, unter der Invariante *dieselbe Eingabe, dasselbe Verdikt*
   ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Es ist dieselbe
   Invariante, unter der `MUTATE_JOBS` in diesem Treiber eine Zeit- und keine Verdikt-Stellschraube
   sein darf. §3.5 ist damit das falsche Instrument, und die Frage *Gate oder nicht* entscheidet
   hier gar nichts — sie wäre über die Etiketten-Zeile der Tabelle beantwortet und über die Sache
   nicht.

2. **Was stattdessen bindet: die Deckung, und sie ist zu zeigen.** Ein Beleg-Übersprung ist genau
   dann zulässig, wenn der Schlüssel alles deckt, was der Sensor **liest**. Wo er das tut, ist der
   Rückgriff verdikt-neutral. Wo er es nicht tut, ist der Fehlermodus **nicht** ein laxer Gate,
   sondern eine **falsche Aussage**: Der Sensor behauptet ein Verdikt, das er nicht hält — und das
   ist [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
   Ebene tiefer. Das Kriterium ist nicht neu; es steht in
   [`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)
   (*„Der Griff steht dort, wo ein Cache-Treffer ein Urteil ersetzen könnte, und fehlt dort, wo der
   Cache-Schlüssel genau den Prüfgegenstand deckt"*). Diese ADR legt seine **Beweisrichtung** fest:
   Deckung wird **gezeigt**, nicht angenommen. Ohne die Messung, die sie belegt, ist der Default
   *kein Übersprung* — fail-closed, wie die fünf Bedingungen daneben.

3. **Die Bezugsmenge ist die Isolationskopie, und sie hat eine Definition, nicht zwei.** Für
   `make mutate` ist der Prüfgegenstand der Baum, den `prepare_isolation` anlegt. Der Schlüssel
   wird aus **derselben** Definition abgeleitet, an **einer** Stelle. Ausnahmen sind zulässig,
   aber nur (a) an genau dieser Stelle deklariert, (b) mit genanntem Grund, und (c) gezählt als
   **Rest** nach Festlegung 4, nicht als Deckung.
   [`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh) ist als
   Schlüssel **nicht zulässig** — nicht weil es falsch rechnet, sondern weil es eine zweite,
   für einen anderen Zweck gepflegte Definition desselben Wortes ist, die gegen die erste driftet,
   ohne dass jemand sie anfasst.

4. **Der Rest wird benannt, nicht geschlossen — und `MUTATE_FORCE` ist sein Träger.** Zwei
   Eingaben liegen außerhalb **jedes** baum-abgeleiteten Schlüssels und bleiben es:
   **(a) der lokale Docker-Cache-Zustand.**
   [`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)
   hat gemessen, dass ein Cache-Treffer ein Urteil ersetzen kann, wo der Griff fehlt, und nennt die
   emittierten Make-Fragmente (`lint`, `build`) als eine solche Stelle. Genau die fährt der Modus
   `# verify: full-smoke`, der in tmp-Repos echte Docker-Gates fahren lässt — betroffen sind
   **19** von **446** Fällen am 2026-09-26 (`grep -l '^# verify: full-smoke' test/mutations/*.sh | wc -l`
   gegen `ls test/mutations/*.sh | wc -l`; am 2026-09-04 waren es 6 von 247; keine
   Erwartungswerte). **(b) die Host-Werkzeuge des Treibers** (bash, coreutils, GNU sed, tar,
   git, docker), die außerhalb jedes Repo-Zustands stehen — derselbe Rest, den der Gate-Nachweis
   schon trägt.
   **Kein Digest gehört deshalb in den Schlüssel:** Die vier externen Images und beide externen
   `FROM`-Zeilen sind bereits auf Digest gepinnt, und diese Digests stehen in getrackten Dateien
   (`grep -cE '@sha256:' Makefile d-check.mk` → **1** bzw. **3**;
   `grep -cE '^FROM [^ ]*@sha256:' Dockerfile` → **2**, die übrigen vier `FROM`-Zeilen verweisen auf
   Stufen derselben Datei). Der Image-**Inhalt** ist damit transitiv im Schlüssel; ein
   Cache-**Zustand** ist keine Adresse und in keinem Schlüssel darstellbar. Träger des Rests ist
   darum der Ausschalter `MUTATE_FORCE` **zusammen mit der Meldung**: Die Übersprung-Ausgabe nennt
   den Beleg-Stand und den benannten Rest und behauptet **keine** Fall-Zahl. Der Ausschalter ist
   kein Komfort, sondern der Teil der Zusage, der den Rest sichtbar hält.

5. **Der Beleg-Slot gehört dem vollen Lauf; ein Teillauf berührt ihn nicht.** Ein Lauf, der nur
   einen Ausschnitt des Fall-Satzes fährt (`MUTATE_CASES`), beantwortet weniger, als der Slot
   behauptet: der Slot sagt *„der letzte **volle** Lauf über diesem Prüfgegenstand war grün"*.
   Darum **übergeht** ein Teillauf einen stehenden Beleg nie — der Filter ist eine ausdrückliche
   Anfrage —, **schreibt** ihn nie, auch bei grünem Ausgang nicht (ein grüner Ausschnitt wäre die
   falsche Aussage aus Festlegung 2), und **löscht** ihn nie, auch bei einem Befund nicht. Der
   Befund eines Teillaufs steht in dessen Exit und Ausgabe. Für den **vollen** Lauf gilt
   unverändert: er entwertet den Slot, bevor er den ersten Fall fährt, und ein Befund hinterlässt
   keinen Beleg. Zwei Abgrenzungen, die die Entscheidung tragen:

   - **Der Grund für das Nicht-Löschen ist der Preis, nicht die Unterscheidbarkeit.** Ein Befund
     an der Infrastruktur (Registry-Zeitüberschreitung, Daemon-Zustand) ist in der Exit-Form von
     einem Befund des Falls nicht zu unterscheiden — beim Teillauf ebenso wie beim vollen Lauf, und
     der volle Lauf löscht. Der Unterschied liegt darin, was das Löschen kostet: der volle Lauf muss
     den Slot ohnehin neu verdienen, die Entwertung kostet ihn nichts; ein Teillauf kann ihn nicht
     neu verdienen, und löschte er bei einem Befund, kostete jedes rote Nachsehen über unverändertem
     Prüfgegenstand einen vollen Lauf.
   - **Der Rest, und wohin er gehört.** Nach einem grünen vollen Lauf und einem Teillauf mit Befund
     über **demselben** Schlüssel gibt ein nachfolgender, nicht erzwungener voller Aufruf den
     stehenden Beleg aus (`Kein Fall-Lauf`, Exit 0): über einer Eingabe stehen zwei Verdikte, ein
     rotes Teilergebnis und ein grüner Exit. Bei einem deterministischen Sensor über einer Eingabe,
     die der Schlüssel deckt, gibt es diese zwei Verdikte nicht; gibt es sie doch, variiert etwas
     **außerhalb** des Schlüssels (Docker-Cache-Zustand, Host-Werkzeuge) oder der Fall flackert.
     Das ist, soweit die Ursache außerhalb des Schlüssels liegt, **der Rest aus Festlegung 4 in der
     Form, in der er sich zeigt**; ein flackernder Fall gehört nicht zu ihm. Beide haben denselben
     Träger, `MUTATE_FORCE`: wer den Befund des Teillaufs für echt hält, erzwingt den vollen Lauf.
     Er fällt damit weder unter Festlegung 1 (die Verdikt-Funktion bleibt unberührt: jeder gefahrene
     Fall urteilt wie zuvor) noch unter Festlegung 2 (die Deckung der **Menge** — die Kopie — ist
     gezeigt; was ihr fehlt, steht in Festlegung 4). Er ist aber eine **Lockerung der Strenge**
     gegenüber der Alternative E unten, und [`AGENTS.md`](../../../AGENTS.md) §3.5 verlangt für
     eine solche eine ADR: diese Festlegung ist sie, mit dem Preis der Gegenwahl (ein voller Lauf
     je rotem Nachsehen), der Grenze (er entsteht nur über unverändertem Schlüssel — jede
     Baumänderung entwertet den Slot ohnehin; ob der Kontext, der danach den vollen Aufruf fährt, den Befund des Teillaufs kennt, ist
     **nicht** zugesagt — über die Grenze zwischen Implementer und Verifier trägt ihn weder die
     Meldung noch der Slot, er bleibt der benannte Rest, den Trigger 4 beobachtet) und dem Trigger 4 unten. Die Übersprung-Meldung nennt den roten Teillauf nicht; dafür
     müsste ein Teillauf einen Merker neben dem Slot schreiben, einen zweiten Zustand, den diese
     ADR nicht einführt.

   Die Abwägung der Alternativen (Teillauf löscht · Teillauf schreibt · Teillauf berührt nie) steht
   in §Verglichene Alternativen, Zeilen E bis G.

## Was hier nicht entschieden ist

- **Wo eine Stellschraube dieses Treibers lebt.** [ADR-0013](0013-technik-stratum-als-zielort.md)
  Festlegung 1 weist *„Werte, die als Schranke oder Default fest sind"* dem Technik-Stratum zu; die
  zwei vorhandenen Stellschrauben stehen dort nicht (`grep -c 'MUTATE_' spec/spezifikation.md` →
  **0**). Ob die Aufnahme-Regel diese Klasse einschließt und wer sie entscheidet, ist offen und hat
  einen eigenen Träger. Diese ADR folgt der bestehenden Platzierung und beantwortet die Frage
  nicht — mein Schweigen dazu ist keine Antwort.
- **Ob eine engere Bezugsmenge lohnt.** Festlegung 3 nennt die Kopie als Menge, nicht als Optimum.
  Eine Verengung ist eine eigene Entscheidung mit eigener Deckungs-Messung; sie hier vorwegzunehmen
  hieße, eine Deckung ohne Messung zu behaupten, was Festlegung 2 gerade verbietet.
- **Ob der Übersprung sich lohnt.** Das ist eine Nutzen-Frage und Planungs-Arbeit. Diese ADR sagt,
  unter welcher Bedingung er zulässig ist, nicht dass er gebaut werden muss.
- **Ob ein Bericht die Aussage mehrerer Läufe tragen darf.** Die Zusammensetzung zweier Läufe über
  demselben Prüfgegenstand zu einer Aussage im Bericht ist eine Lese-Regel des Sensors und kein
  Beleg-Übersprung: sie ändert weder Exit noch Slot und lässt jeden Fall die Verdikt-Funktion
  durchlaufen, die Festlegung 1 unberührt lässt. Sie steht im Sensor-Dokument; diese ADR trägt sie
  nicht und bindet sie nicht. Dass ein voller Lauf seinen Prüfgegenstand-Schlüssel auch bei einem
  Befund nennt, ist Ausgabe-Form des Werkzeugs, keine Festlegung.

## Verglichene Alternativen

Die Zeilen A bis D tragen die Festlegungen 1 bis 4, die Zeilen E bis G die Festlegung 5.

| Option | Pro | Contra |
|---|---|---|
| A — **Übersprung als Schwellen-Senkung behandeln** (§3.5, eigener ADR-Beschluss je Absenkung) | Nimmt die Hard-Rule-Trägerschaft von `mutate` ernst; maximale Vorsicht | Falsche Diagnose: die Verdikt-Funktion wird nicht angetastet. Wer sie so nennt, muss dieselbe Kategorie auch dem Stop-Hook geben, der seit [`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) genau dies tut — und träfe die eigentliche Gefahr (die falsche Aussage) trotzdem nicht |
| B — **Reine Anwendung von [`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt), Schlüssel = `working-tree-hash.sh`** | Kein neuer Beschluss nötig; der Träger steht schon, und ein Commit ohne Inhaltsänderung ließe den Beleg gültig | Das Kriterium fällt **negativ** aus: der Schlüssel ist eine echte Teilmenge des Gelesenen (Messung in §Kontext), und die Differenz wächst still mit jedem `.gitignore`-Eintrag. Der Slice lieferte eine Deckungs-Zusage, die von Anfang an nicht hält |
| C — **Übersprung ganz ablehnen** | Kein neuer Weg ins stille Grün; der Sensor bleibt, was er ist | Verwirft eine Wiederverwendung, die unter benannter Deckung nachweislich zulässig ist, und erklärt nebenbei den Gate-Nachweis dieses Repos für unzulässig. Der Preis (ein voller Sensor-Lauf je Fall, mehrere hundert Fälle) bleibt an einer Stelle stehen, an der er DoD-Verify und Closure mehrfach trifft |
| **D — Deckung als Kriterium, Kopie als Bezugsmenge, Rest benannt (gewählt)** | Trifft den wirklichen Fehlermodus ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) statt eines Etiketts; eine Definition statt zweier, damit die Drift von §Kontext strukturell verschwindet; der nicht schließbare Rest steht im Ausschalter und in der Meldung statt in einem Vorbehalt | Teurer als B: der Schlüssel wird gebaut, nicht wiederverwendet. Und er verliert den Nebengewinn, den `working-tree-hash.sh` mitbrächte — deckt die Kopie `.git` mit ab, stirbt der Beleg bei jedem Commit; wird `.git` ausgenommen, ist das eine deklarierte Ausnahme und keine Deckung. Diesen Ausgleich muss die Umsetzung sichtbar treffen, nicht stillschweigend |
| E — **der Teillauf löscht den Slot bei einem Befund** | fail-closed; schließt den Rest aus Festlegung 5, sobald ein Befund vorliegt; ein Slot ist nie zugleich mit einem roten Ergebnis über demselben Schlüssel sichtbar | Jedes rote Nachsehen über unverändertem Prüfgegenstand entwertet einen Beleg, den nur ein voller Lauf neu verdient — ein voller Lauf je Nachsehen. Das Argument *„ein Befund an der Infrastruktur ist vom Befund des Falls nicht zu unterscheiden"* trägt sie nicht: es gilt für den vollen Lauf ebenso; der Unterschied ist der Preis. Sie schließt den Rest nur für den sichtbaren Fall, nicht für den Rest aus Festlegung 4 ohne Teillauf |
| F — **der Teillauf schreibt den Slot bei grünem Ausgang** | Ein grüner Nachsehen-Lauf würde wieder verwertbar | Der Slot behauptete einen vollen Lauf, den es nicht gab: die falsche Aussage aus Festlegung 2, [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene tiefer |
| **G — der Teillauf berührt den Slot nie (gewählt)** | Der Slot bleibt eine Aussage über genau einen Lauf-Typ; kein Nachsehen kostet einen Beleg; der Rest hat seinen Ausschalter und seinen Trigger | Der Rest aus Festlegung 5: ein roter Teillauf über unverändertem Schlüssel neben einem stehenden grünen Beleg, den ein unerzwungener voller Aufruf ausgibt — eine Lockerung gegenüber E, die diese ADR trägt (Festlegung 5, Trigger 4) |

## Konsequenzen

- **Positiv:** Die Zulässigkeitsfrage ist entschieden, bevor Code entsteht — der Slice läuft nicht
  in den Kontext, in dem die Norm von dem geschrieben würde, der sie braucht.
- **Positiv:** Das Kriterium ist allgemein. Jeder weitere Sensor, der einen Beleg statt eines Laufs
  ausgeben will, hat dieselbe Beweislast und dieselbe Beweisrichtung.
- **Negativ:** Der Slice wird teurer. Der geplante Wiedergebrauch von
  [`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh) entfällt, und
  die Ausnahme-Frage (`.git`) muss der Plan sichtbar treffen und begründen, statt sie zu erben.
- **Negativ:** Der Rest aus Festlegung 4 bleibt bestehen. Ein Beleg über unverändertem
  Prüfgegenstand konserviert ein Verdikt, dessen Docker-Cache-Anteil niemand adressiert;
  `MUTATE_FORCE` macht ihn behebbar, nicht abwesend.
- **Negativ:** Der Rest aus Festlegung 5 bleibt bestehen. Ein Befund eines Teillaufs entwertet den
  Beleg nicht; wer ihn für echt hält, erzwingt den vollen Lauf. Der Preis der Gegenwahl ist ein
  voller Lauf je rotem Nachsehen; er wird gezahlt, wenn Trigger 4 eintritt.
- **Kein Eintrag im Adaptions-Speicher.** Eine Abweichung von der Baseline liegt nicht vor:
  `make mutate` hat in der adoptierten Fassung kein Gegenstück, von dem abgewichen werden könnte,
  und der inhaltsbasierte Nachweis ist deren eigene Design-Eigenschaft 2
  (`grundlagen-durchsetzungsschicht.md` §Vier Design-Eigenschaften: *„Nachweis über Inhalt, nicht
  Diff. Ein Content-Hash des Arbeitsbaums belegt ‚die Gates liefen auf genau diesem Stand'"*), hier
  **angewendet** und nicht ersetzt.
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) verlangt einen Eintrag nur
  für Abweichungen; es entsteht keiner.
- **Folgepflicht 1:** Der Slice-Plan trägt diese ADR im Kopf und zieht §3 (Bezugsmenge) sowie sein
  Risiko zur Zulässigkeitsfrage nach. Das ist Planner-Arbeit, nicht Teil dieser Entscheidung.
- **Folgepflicht 2:** Die Fitness Function unten entsteht **im selben Slice** wie der Übersprung.
  Ein Übersprung ohne sie wäre eine Absichtserklärung an genau der Stelle, an der der Sensor sonst
  still grün wird.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats (`test/mutate-driver.bats`) | Jeder Pfad, den `prepare_isolation` in die Kopie legt, geht **entweder** in den Schlüssel ein **oder** steht in der deklarierten Ausnahmeliste derselben Definition. Ein dritter Fall ist rot. Der Test rechnet die Mengen aus der Definition, die der Lauf benutzt — er baut sie nicht nach | `make test` (in `make gates`) |
| `test/mutations/` (ein neuer Fall) | Eine Mutation, die einen Pfad aus dem Schlüssel nimmt, ohne ihn in die Ausnahmeliste zu setzen, färbt den Wächter darüber rot | `make mutate` |
| `test/mutate-driver.bats` | Ein **voller** Lauf mit mindestens einem Befund hinterlässt keinen Beleg — `finalize_belief` schreibt nur bei `fail_count` 0 und löscht sonst, und `fail_count` ist der Zähler, aus dem `main()` auch seinen Exit-Status bildet | `make test` (in `make gates`) |
| `test/mutate-driver.bats` (die Fälle *„ein Teillauf faehrt trotz stehendem Beleg zum aktuellen Schluessel"*, *„ein Teillauf schreibt den Beleg-Slot nie"* und *„ein Teillauf mit Befund laesst einen stehenden Beleg byte-gleich stehen"*) | Ein **Teillauf** (`MUTATE_CASES`) übergeht einen stehenden Beleg nie, hinterlässt bei grünem Ausgang keinen Beleg und lässt einen stehenden Beleg auch bei einem Befund byte-gleich stehen (Festlegung 5). Schwächung, unter der die Fälle rot werden: die Bedingung des Übersprungs verliert ihre Teillauf-Ausnahme → der erste Fall färbt sich rot; der Teillauf ruft am Ende den Schreibpunkt des vollen Laufs → der zweite Fall (und der dritte) färben sich rot; die Sofort-Entwertung läuft auch im Teillauf → der dritte Fall färbt sich rot | `make test` (in `make gates`) |

**Rot gesehen** (Architect-Läufe am 2026-09-26, in Kopien des Baums, `bats` im gepinnten Bild des
Makefiles, Filter auf die fünf Teillauf-Fälle): die Zeile `[ -n "$partial" ] || clear_belief`
ohne ihre Bedingung färbt *„…laesst einen stehenden Beleg byte-gleich stehen"* rot; `report_partial`
um einen Aufruf von `finalize_belief` ergänzt färbt *„…schreibt den Beleg-Slot nie"* und den
Befund-Fall rot; die Bedingung des Übersprungs ohne `[ -z "$partial" ] &&` färbt *„…faehrt trotz
stehendem Beleg zum aktuellen Schluessel"* rot (`Kein Fall-Lauf` steht in der Ausgabe); der
unveränderte Baum ist über alle fünf Fälle grün.

**Was kein Wächter hält, und das gehört dazu.** Ob eine deklarierte Ausnahme **berechtigt** ist,
prüft nichts — die Regel oben prüft, dass sie *dasteht*, nicht dass sie trägt. Den Rest aus
Festlegung 4 prüft ebenfalls nichts: ein Docker-Cache-Zustand hat keine Fehlschlag-Form. Ebenso
den Rest aus Festlegung 5: dass ein unerzwungener voller Aufruf nach einem Teillauf mit Befund den
Beleg ausgibt, ist die benannte Folge der Entscheidung, kein Fehlschlag. Und kein
Modul des Doku-Gates prüft, was ein Shell-Skript oder ein Make-Rezept tut
(`grep -m1 '^modules:' .d-check.yml` führt am 2026-09-26
`links, anchors, ids, matrix, codepaths, spans, planning, targets, structure`; `targets` hält die
Makefile-Rezepte gegen die Gate-Tabellen der Doku, nicht den Inhalt eines Rezepts —
`harness/sensors/docs-check.md` §Modul `targets`). Träger
dieser Lücken sind die Re-Evaluierungs-Trigger unten, geprüft im Trigger-Audit der Closure.

## Re-Evaluierungs-Trigger

Nicht permanent. Vier beobachtbare Bedingungen, jede einzeln auslösend:

1. **Die Ausschluss-Menge von `prepare_isolation` ändert sich**, oder ein neuer `# verify:`-Modus
   kommt hinzu, dessen Sensor etwas liest, das die Kopie nicht trägt. Dann ist die Deckung aus
   Festlegung 3 neu zu zeigen, bevor der Übersprung weiter greifen darf.
2. **Der `--no-cache-filter`-Griff erreicht die emittierten `lint`/`build`-Fragmente**, oder der
   Modus `full-smoke` verliert seine Fall-Belegung. Dann schrumpft Rest (a) aus Festlegung 4, und
   die Begründung für `MUTATE_FORCE` ist neu zu fassen.
3. **Ein zweiter Sensor dieses Repos will einen Beleg statt eines Laufs ausgeben.** Dann ist zu
   prüfen, ob die Festlegungen 1, 2 und 4 als allgemeine Regel taugen oder ob Festlegung 3 (die
   Bezugsmenge) je Sensor eine eigene Entscheidung bleibt.
4. **Ein Teillauf mit Befund über einem Prüfgegenstand mit stehendem Beleg, und der Befund erweist
   sich im vollen Lauf als echt** *(beobachtbar an zwei Läufen, die ein Lauf liest, der beide Berichte vor sich hat: ein
   Teillauf mit `BEFUND` bei stehendem Beleg, danach ein erzwungener voller Lauf, der denselben Fall
   rot färbt)*. Dann ist der Rest aus Festlegung 5 kein Rauschen, sondern ein Weg ins stille Grün,
   und die Alternative E — ein Teillauf mit Befund löscht den Slot — ist mit dieser Evidenz neu zu
   wägen (Code-Folge: eine Bedingung in `main()`, und der Fall *„…laesst einen stehenden Beleg
   byte-gleich stehen"* wechselt seine Aussage). Beobachter ist kein Sensor, sondern der Lauf, der
   beide Berichte liest; benannt, nicht geschlossen.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`; bis dahin ist sie ein Architect-Verdikt und als solches das
Übergabe-Artefakt, das der Implementer als Constraint liest. Sie wird `Accepted`, **wenn eine
Reviewer-Runde sie gegen
[`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
und [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) auf Konsistenz geprüft hat
und ihr Report ohne blockierenden Befund an der **Substanz** der fünf Festlegungen in `docs/reviews/`
liegt.** Ein blockierender Befund an der **Darstellung** wird behoben und hindert die Annahme nicht.
Der Beleg ist eine Runde der prüfenden Rolle; die Accept-Zeile der §Geschichte nennt ihn als
**Kennung**, nicht als Pfad-Link (ADR-0040 Festlegung 1). **Die Annahme selbst ist die Entscheidung
des Auftraggebers.**

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-04 | **Proposed** | Architect-Verdikt auf zwei Fragen, die ein Planner-Plan ausdrücklich übergeben hat (Start-Trigger des Slice, `slice-180` — Kennung ohne Adresse nach [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3). Beide Antworten weichen von den angebotenen Optionen ab: die erste, weil §3.5 die Verdikt-Funktion regelt und ein Übersprung sie nicht anfasst; die zweite, weil das Deckungs-Kriterium aus [`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt) für den vorgeschlagenen Schlüssel **negativ** ausfällt. Tragend ist die Mengen-Messung in §Kontext, gefahren gegen den Arbeitsbaum am Tag des Entscheids |
| 2026-09-26 | **Proposed, geschärft** | Architect-Lauf, Status unverändert: Festlegung 5 (der Teillauf berührt den Beleg-Slot nie) und die Fitness-Zeile des Teillaufs; die Fitness-Zeile des vollen Laufs nennt ihren Gegenstand; der Acceptance-Trigger steht neu; Verdikt `2026-09-26-architect-verdikt-sammelauftrag-register-und-adr-0035` |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zum Konsistenz-Review `2026-09-26-review-adr-0035-0068-0069-konsistenz`, Status unverändert: der Grund des Nicht-Löschens in Festlegung 5 ist der Preis, der Rest ist eingeordnet und trägt Trigger 4; die Abwägung steht in §Verglichene Alternativen (E bis G); die Lage-Messungen sind aktualisiert; die Fitness-Zeile des Teillaufs nennt den dritten Fall; Verdikt `2026-09-26-architect-verdikt-korrektur-adr-0035-0068-0069` |
| 2026-09-26 | **Proposed, korrigiert** | Architect-Lauf zur Kurzrunde `2026-09-26-review-kurzrunde-adr-0035-f5-und-adr-0069-f2`, Status unverändert: der Verweis der Festlegung 5 nennt die Alternative E; die Grenze des Rests sagt nicht mehr zu, dass der Bediener den Befund des Teillaufs kennt (über die Kontext-Grenze bleibt er benannter Rest mit Trigger 4); ein flackernder Fall gehört nicht zum Rest aus Festlegung 4; Trigger 4 nennt keinen bestimmten Leser der zwei Läufe |
| 2026-09-26 | **Accepted** | Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2: die Konsistenz-Runde `2026-09-26-review-adr-0035-0068-0069-konsistenz` (0 HIGH, ein MEDIUM R-35-1, Empfehlung „ja nach Korrektur") und, als erneute Runde der prüfenden Rolle nach dessen Auflösung, die Kurzrunde `2026-09-26-review-kurzrunde-adr-0035-f5-und-adr-0069-f2` (0 HIGH, 0 MEDIUM, Empfehlung „ja nach Korrektur"; sie prüfte die Fassung vor den zwei LOW-Punkten, die Differenz zur angenommenen Fassung ist Wortlaut — ein Bezeichner, die Grenze des Rests, Trigger 4 ohne bestimmten Leser — ohne Änderung der Entscheidung). Die Annahme hat der Auftraggeber am 2026-09-26 erteilt. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0035`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0035` (Baseline-Regelwerk `v5.18.0`, `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs: *„Eine ADR mit Status `Accepted` wird nicht inhaltlich
überschrieben"*).
