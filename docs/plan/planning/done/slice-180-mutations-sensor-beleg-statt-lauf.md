# Slice slice-180: Der Mutations-Sensor gibt einen Beleg aus, statt ihn neu zu erarbeiten

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Auslöser-Test ist nicht die Größe der Arbeit, sondern die Frage nach
dem *Mehr*: Gibt es eine beobachtbare Closure-Bedingung, die mehr beobachtet, als die DoD dieses
Slice ohnehin belegt
([`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst),
Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Die gibt es hier nicht:
Der Gegenstand ist **ein** Sensor, sein Beleg entsteht in seinem eigenen Lauf, und ein repo-weiter
Verifikations-Beleg über die DoD hinaus — die Übergabe, die eine Welle definiert — fällt nicht an.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — die
tragende Anforderung: ein Lauf, der nichts prüft und trotzdem einen Beleg ausgibt, ist der
halluzinierte Gate eine Ebene tiefer. Der Sensor misst die **Abwesenheit** von Rot und kann darum
selbst still grün werden; jede der fünf fail-closed-Bedingungen im Kopf von
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) schließt einen Weg dorthin, und
ein Übersprung eröffnet einen sechsten ·
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — die Bedingung, unter der
ein Beleg überhaupt wiederverwendbar ist: dieselbe Eingabe, dasselbe Verdikt. Es ist dieselbe Linie,
auf der `MUTATE_JOBS` eine Zeit- und keine Verdikt-Stellschraube sein darf ·
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — der Schlüssel
entsteht aus `git` und coreutils, die der Host ohnehin trägt; keine neue Abhängigkeit ·
[`MR-050`](../../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)
— das **Kriterium** dieses Slice, in diesem Repo schon einmal entschieden: *„Der Griff steht dort,
wo ein Cache-Treffer ein Urteil ersetzen könnte, und fehlt dort, wo der Cache-Schlüssel genau den
Prüfgegenstand deckt."* ·
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
— die Präzedenz des **Prinzips**, nicht des Trägers: ein Nachweis hängt am **Inhalt**, nicht am
git-Zustand. Der dortige Träger
[`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh) ist als
Schlüssel dieses Slice **nicht** zulässig
([ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 3) — er ist eine zweite, für den Gate-Nachweis gepflegte Definition desselben Wortes ·
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) — der
mechanische Pro-Push-Auslöser läuft auf **frischem Klon**; der Beleg ist Laufzustand unter
`.harness/state/` und damit dort nie vorhanden.

**ADR-Bezug (Architect, 2026-09-04):**
[ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(`Proposed`) beantwortet die zwei Fragen, an denen der Start-Trigger (§4) hängt.
**Festlegung 1 und 2:** Der Übersprung ist **keine** Schwellen-Senkung nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 — er lässt die Verdikt-Funktion unberührt und verschiebt
allein den Auswertungs-Zeitpunkt. Zulässig ist er unter **gezeigter** Deckung; fehlt sie, ist der
Fehlermodus nicht ein laxer Gate, sondern eine falsche Aussage
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), und
der Default ist *kein Übersprung*. **Festlegung 3:** Die Bezugsmenge ist die **Isolationskopie**
aus `prepare_isolation`, abgeleitet aus **einer** Definition mit dem Kopier-Schritt; die in §3
vorgesehene Wiederverwendung von
[`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh) ist damit
**nicht** zulässig — §3 und §6 Risiko 2 tragen den Nachzug. **Festlegung 4:**
Docker-Cache-Zustand und Host-Werkzeuge bleiben benannter Rest an `MUTATE_FORCE` und der
Übersprung-Meldung; ein Image-Digest gehört **nicht** in den Schlüssel, weil die Digests bereits in
getrackten Dateien stehen. Ein Adaptions-Eintrag entsteht nicht.

**Berührte Spec-Stellen:** `—`. Der Slice bewegt einen repo-lokalen Sensor, keinen Wert des
Technik-Stratums. Die zwei bestehenden Stellschrauben des Treibers stehen **nicht** in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) §3, sondern im Skript
(`grep -c 'MUTATE_' spec/spezifikation.md` → **0**; kein Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — mit der Begründung im Rezept, dass eine zweite Vorgabe eine zweite Quelle wäre. Eine
dritte folgt derselben Platzierung. **Was das nicht entscheidet:** ob die Aufnahme-Regel der
Spezifikation diese Klasse eigentlich einschlösse; das ist eine Frage an das Stratum und steht als
Risiko in §6.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner (ai-harness-init-Team, pt9912). **Datum:** 2026-09-04.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

`make mutate` gibt über einem Baum, für den ein vollständig grüner Lauf bereits einen Beleg
hinterlassen hat, **diesen Beleg** aus, statt den Fall-Satz erneut zu fahren — und jeder Weg, auf
dem der Beleg falsch wäre, färbt rot.

**Was der Lauf heute kostet und warum das eine Rolle spielt.** Der Treiber sammelt in `main()` per
Glob **jede** Fall-Datei ein (`ls test/mutations/*.sh | wc -l` → **247**; kein Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), und je Fall läuft ein voller Sensor-Lauf. Die Verteilung der Sensor-Modi steht im
Bestand selbst: `sed -n 's/^# verify: //p' test/mutations/*.sh | sort | uniq -c` führt **43**
`test-go`, **13** `test-bats`, **6** `full-smoke`, je **1** `smoke` und `ci-lint`, und
`grep -L '^# verify:' test/mutations/*.sh | wc -l` → **183** Fälle ohne eigene Modus-Zeile, deren
Sensor `narrow_sensor` aus der `# expect:`-Zeile wählt. Der Sensor steht **außerhalb** von
`make gates` — sein Platz ist DoD-Verify, Closure und CI —, und genau dort trifft ihn die Laufzeit
mehrfach hintereinander.

**Der Lieferwert ist nicht „schneller", sondern „kein zweites Mal ohne neue Frage".** Ein zweiter
Lauf über einem Baum, der sich seit dem ersten nicht bewegt hat, stellt keine Frage, die der erste
nicht beantwortet hätte — er wiederholt eine Messung über unveränderter Eingabe. Zulässig ist das
**nur**, solange der Schlüssel, an dem „unverändert" hängt, den Prüfgegenstand deckt
([`MR-050`](../../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt));
deckt er ihn nicht, ist der Übersprung genau das stille Grün, gegen das der Sensor antritt.

**Präzedenz im selben Treiber, und sie trägt die Form dieses Slice.** Die Sensor-Wahl je Fall
(`narrow_sensor`, slice-056) ist bereits eine Laufzeit-Reduktion: Bis dahin fuhr jeder Fall ohne
`# verify:`-Zeile **beide** Stufen. Sie ist zulässig, weil sie fail-closed auf den vollen Satz
zurückfällt, und sie ist bewacht — `test/mutations/97-mutate-sensorwahl.sh` nimmt ihr die Zähne und
muss den Treiber-Test röten. Der Kommentar darüber sagt, wovor das schützt: *„Ein schnellerer Lauf,
der weniger prueft, waere genau das stille Gruen, gegen das make mutate antritt"* — und nennt
dieselbe Anforderung wie dieser Plan
(`grep -c 'Ein schnellerer Lauf, der weniger prueft' harness/tools/mutate.sh` → **1**; kein
Erwartungswert). **Der Unterschied zu diesem Slice ist kategorial und gehört benannt:**
`narrow_sensor` fährt weiter *jeden* Fall und wählt nur dessen Stufe — ein Übersprung fährt
**keinen**. Deshalb hängt dieser Slice an einer Entscheidung und nicht nur an einem Fall (§4).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Der Treiber überspringt den Fall-Satz genau dann, wenn ein aufgezeichneter,
      vollständig grüner Lauf denselben Baum-Zustand belegt.** Vier Eigenschaften, alle vier
      prüfbar: der **Zustand** liegt unter `.harness/state/` (gitignored, dieselbe Ablage wie der
      Gate-Nachweis — und **außerhalb** der Bezugsmenge, weil `prepare_isolation` genau dieses
      Verzeichnis von der Kopie ausnimmt; das Schreiben des Belegs bewegt den Schlüssel damit
      strukturell nicht) · der **Schlüssel** ist ein Inhalts-Hash über der **Isolationskopie**,
      abgeleitet aus derselben Definition wie der Kopier-Schritt, mit **einer** deklarierten
      Ausnahme (§3, §6 Risiko 2) — kein Commit-Vergleich (§6, Risiko 4)
      · geschrieben wird er an **einem** Punkt, und der liegt hinter der Bedingung, unter der
      `main()` heute seinen Exit-Status bildet (`fail_count` gleich null) — ein abgebrochener, ein
      roter und ein fail-closed beendeter Lauf hinterlassen keinen · der **Übersprung** endet mit
      Exit 0, nennt den Beleg-Stand und behauptet **keine** Fall-Zahl (`BEO-026`). Dazu ein
      Ausschalter (`MUTATE_FORCE`), weil der Schlüssel nachweislich nicht alles deckt, was in das
      Verdikt eingeht (§6, Risiko 1).
- [x] **(2) Die drei Wege ins stille Grün sind je einmal rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6 — die Zusage ist
      erst fertig, wenn benannt ist, was passieren müsste, damit sie bricht). Es sind genau die drei
      Zeilen der Fitness Function aus
      [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md),
      und sie entstehen nach Folgepflicht 2 **in diesem Slice**: **(a)** jeder Pfad, den
      `prepare_isolation` in die Kopie legt, geht **entweder** in den Schlüssel ein **oder** steht in
      der deklarierten Ausnahmeliste derselben Definition — ein dritter Fall ist rot, und der Test
      rechnet beide Mengen aus der Definition, die der Lauf benutzt, statt sie nachzubauen;
      **(b)** ein Baum, der einen bewachten Wächter trifft, bewegt den Schlüssel — Gegenbeispiel ist
      eine Mutation an einer `# files:`-Zieldatei, nach der der Übersprung **nicht** greift;
      **(c)** ein Lauf mit Befund hinterlässt keinen Beleg — Gegenbeispiel ist der rote Lauf, nach
      dem der nächste wieder voll fährt. Träger sind `test/mutate-driver.bats` **und** ein neuer Fall
      unter `test/mutations/`, der einen Pfad aus dem Schlüssel nimmt, ohne ihn in die Ausnahmeliste
      zu setzen — nach dem Muster von `test/mutations/97-mutate-sensorwahl.sh`, und er trifft die
      Stelle, die der Lauf wirklich benutzt, nicht eine im Test nachgebaute (`BEO-028`).
- [x] **(3) Die stehenden Zusagen sagen, was der Treiber tut.** Der Kopf von
      [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) führt heute fünf
      fail-closed-Bedingungen und die Begründung, warum der Sensor nicht in `make gates` steht; der
      `make mutate`-Absatz in [`harness/README.md`](../../../../harness/README.md) beschreibt den
      Lauf für Leser von außen. Beide tragen die Übersprung-Bedingung **samt ihrer Bezugsmenge, der
      deklarierten Ausnahme und dem benannten Rest** — und die Zusage sagt nur, was der Schlüssel
      wirklich deckt (`BEO-025`). Die abgelöste Aussage wird **ersetzt, nicht ergänzt**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7: ein Kommentar beschreibt, was da ist).
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — sechs neue Kennungen
      (`BEO-031`…`BEO-036`) und zwei Zähler-Schritte (`BEO-025` 3× → 4×, `BEO-030` 1× → 2×), alle
      mit Beleg `slice-180`; eingetragen bei der Slice-Closure, wie §8 den Schreibpunkt setzt (§7,
      Block *Closure — Planner*).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — nach dem `git mv` gefahren,
      weil sie in `done/` suchen: Anker entfällt (nichts verkörpert, kein Feld `liegt in <Zielort>`),
      Folge-Slice grün (sechs genannte Kennungen, alle als Datei im Lifecycle), Register grün in
      beiden Hälften. Kommandos und Ergebnis in §7, Block *Closure — Planner*.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) — `prepare_isolation` und ihre Umgebung | update | **Hier liegt der Schlüssel, und zwar an derselben Stelle wie die Kopie.** Die Ausschluss-Menge, die heute als `--exclude=` am `tar`-Aufruf steht, wird zu **einer** benannten Definition, aus der *beides* folgt: was kopiert wird und was in den Schlüssel eingeht. Zwei Ableitungen aus einer Quelle statt zweier Quellen — das ist die Anforderung aus [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 3, und sie ist der Grund, warum die Änderung `prepare_isolation` berührt und nicht nur `main()` |
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) — `main()` | update | Der Übersprung sitzt **hinter** dem `mkdir`-Mutex und **vor** der Isolations-Kopie; der Beleg wird an dem einen Punkt geschrieben, an dem der Lauf heute seinen Exit-Status bildet. Dazu der Kopf-Text aus DoD (3) |
| [`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh) | **nicht** verwendet — als Schlüssel unzulässig | [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 3 schließt ihn aus: nicht weil er falsch rechnet, sondern weil er eine **zweite**, für den Gate-Nachweis gepflegte Definition desselben Wortes ist, die gegen die Kopier-Definition driftet, ohne dass jemand eine der beiden anfasst. Die Datei bleibt unberührt; ändert der Slice sie doch, ist das eine Änderung an der Grundlage des Stop-Hooks und gehört gesondert begründet |
| `.harness/state/mutate-passed.*` | neu (Laufzustand) | Der Beleg, neben `gates-passed.diffsha`. Gitignored (`grep -n 'state' .gitignore` → `.harness/state/`), damit er weder in den Baum-Hash noch auf einen frischen Klon gerät. **Der Name trägt die Form:** `.diffsha` beim Nachbarn ist historisch, hier steht ein Baum-Hash — ein Name, der `commit` oder `diff` sagt, sagte etwas Falsches |
| `test/mutate-driver.bats` | update | Die zwei Gegenbeweise aus DoD (2); die Datei sourct den Treiber bereits für seine Funktionen |
| `test/mutations/` (ein neuer Fall) | neu | Nimmt dem Übersprung die Zähne. Ohne ihn ist die neue Logik der nächste unbewachte Wächter — *kuratiert heißt unvollständig*, und wer keinen Fall hat, ist unbewacht |
| [`harness/README.md`](../../../../harness/README.md) | update | Der `make mutate`-Absatz unter *Nicht-Gate-Verify*; er ist die Außensicht auf den Sensor |
| `Makefile` (Rezept `mutate`) | offen — nur falls `MUTATE_FORCE` eine Vorgabe braucht | `MUTATE_JOBS` steht im Rezept, sein **Default** im Skript. Ein Ausschalter braucht keinen Default; reicht die Umgebungsvariable durch, bleibt das Rezept unberührt |

### Die eine deklarierte Ausnahme: `.git/` — Entscheidung mit Begründung

[ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 3 lässt Ausnahmen zu, aber nur (a) an der Stelle der Definition deklariert, (b) mit
genanntem Grund, (c) **als Rest gezählt, nicht als Deckung** — und ihr Alternativen-Vergleich (Option
D) verlangt ausdrücklich, dass die Umsetzung den Ausgleich *sichtbar* trifft. Hier ist er, mit beiden
Seiten gemessen.

**Die Menge.** Die Kopie trägt **4353** Pfade, davon **3303** unter `.git/`, also **1050** daneben;
die Menge, die `working-tree-hash.sh` hasht, trifft **1049** davon:

```sh
export LC_ALL=C
A=$(tar -cf - --exclude=./.harness/state . | tar -tf - | sed 's|^\./||;/^$/d' | grep -v '/$' | sort -u)
B=$(git ls-files --cached --others --exclude-standard | sort -u)
printf '%s\n' "$A" | wc -l                                            # 4353  Kopie gesamt
printf '%s\n' "$A" | grep -c '^\.git/'                                # 3303  davon .git/
printf '%s\n' "$A" | grep -vc '^\.git/'                               # 1050  Kopie ohne .git/
printf '%s\n' "$B" | wc -l                                            # 1049  working-tree-hash-Menge
comm -23 <(printf '%s\n' "$A" | grep -v '^\.git/') <(printf '%s\n' "$B")   # .claude/settings.local.json
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Der letzte Ausdruck ist der Gewinn, den die neue Bezugsmenge *heute schon* trägt: eine
Datei, die die Kopie mitnimmt und `git` nicht führt, geht ab jetzt in den Schlüssel ein.

**Die Entscheidung: `.git/` steht in der Ausnahmeliste.** Drei Gründe, in dieser Reihenfolge.

1. **Der dokumentierte Grund für `.git` in der Kopie ist die Projektwurzel, nicht der Inhalt.**
   `prepare_isolation` sagt es selbst: *„inklusive `.git`: `make ci-lint` faehrt actionlint, und das
   bricht ohne git-Projektwurzel ab"*
   (`grep -n 'git-Projektwurzel' harness/tools/mutate.sh` → **1** Treffer). Dazu nimmt
   `.dockerignore` `.git` aus **jedem** Docker-Build-Kontext (`grep -c '^\.git$' .dockerignore` →
   **1**) — die Stufen, die die Fälle rot färben sollen, sehen das Verzeichnis also gar nicht.
2. **Ein Schlüssel über `.git/` stirbt am Commit, und das ist an diesem Repo heute gemessen** —
   nicht behauptet: der Commit, der
   [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   ablegte, bewegte den `.git`-Inhalt von `df91db81bda8fd35` auf `ed6d62bfda6d2482`, während der
   Inhalts-Hash des Arbeitsbaums **unverändert** blieb
   (`find .git -type f -exec sha256sum {} + | LC_ALL=C sort | sha256sum | cut -c1-16` vor und nach
   dem Commit gegen `bash harness/tools/working-tree-hash.sh`; keine Erwartungswerte). **Ein
   *lesender* git-Aufruf bewegt ihn dagegen nicht** — dasselbe Kommando um ein
   `git status --porcelain` herum liefert zweimal denselben Wert; die Instabilität kommt vom Commit,
   nicht vom Betrieb, und die Begründung darf nicht mehr behaupten als das.
3. **Die Ausnahme stellt die Eigenschaft her, die die Baseline für einen Nachweis vorsieht** — nicht
   eine Bequemlichkeit: *„Nachweis über Inhalt, nicht Diff"*
   (`grundlagen-durchsetzungsschicht.md` §Vier Design-Eigenschaften, zitiert in
   [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   §Konsequenzen). Ein Beleg, den das bloße Anlegen eines Commits ohne Inhaltsänderung entwertet,
   hinge am git-Zustand statt am Inhalt.

**Was die Ausnahme kostet, und es steht als Rest, nicht als Deckung:** Nicht gedeckt bleibt alles,
was ein Sensor aus der git-**Historie** oder aus `.git/hooks/` lesen könnte. Die Aussage *„keiner tut
das"* wird hier **nicht** getroffen — sie wäre eine Vollständigkeitsbehauptung über 247 Fälle und
ihre Sensoren. Der Rest wandert nach Festlegung 4 zu `MUTATE_FORCE` und in die Übersprung-Meldung,
neben den Docker-Cache-Zustand. **Und er kann nicht still wachsen:** die Ausnahmeliste ist Gegenstand
des Wächters aus DoD (2a), also sichtbar und einzeln zu begründen — anders als die Differenz zur
Menge von `working-tree-hash.sh`, die mit jedem neuen `.gitignore`-Eintrag wächst, ohne dass jemand
eine der beiden Definitionen anfasst.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Eine **Architect-Entscheidung liegt als Datei in
[`docs/plan/adr/`](../../../../docs/plan/adr/)** und beantwortet zwei Fragen, die dieser Plan
stellt, aber nicht entscheidet: **(a)** Ist ein Beleg-Übersprung in einem Sensor, der die
*Abwesenheit von Rot* misst, zulässig — und wenn ja, ist er eine Schwellen-Senkung im Sinn von
[`AGENTS.md`](../../../../AGENTS.md) §3.5 oder die Anwendung des schon entschiedenen
Deckungs-Kriteriums aus
[`MR-050`](../../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)?
**(b)** Welche **Bezugsmenge** trägt der Schlüssel — der ganze Arbeitsbaum, oder eine benannte,
engere Menge samt der Messung, die ihre Deckung belegt? Warum das eine Entscheidung
und keine Planung ist, steht in §6, Risiko 7.

**Warum der Trigger so und nicht als Datum:** Ein anderer Mensch kann ohne Rückfrage sagen, ob eine
ADR mit diesen zwei Festlegungen existiert.

**Stand: erfüllt.**
[ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
liegt vor und beantwortet beide Fragen; §2, §3, §5 und §6 dieses Plans tragen ihre Folgen. **Der
Trigger verlangt die Existenz des Verdikts, nicht den Status `Accepted`** — und das bleibt so, aus
zwei Gründen, die sich ergänzen: Ein `Proposed`-Stand ist bereits ein Verdikt und kein Vorsatz, und
er ist die Fassung, an der Widerspruch noch *ohne* Folge-ADR möglich ist
([`AGENTS.md`](../../../../AGENTS.md) §3.4 friert erst ab `Accepted`). Was daraus folgt, ist keine
Sperre, sondern eine **Prüfung vor dem Beginn**: Der übernehmende Lauf liest die Geschichte-Tabelle
der ADR und beginnt nicht, wenn Festlegung 3 sich seit diesem Plan bewegt hat — sie ist die
Festlegung, an der §3 und §5 hängen. Der Fall steht als Risiko 7.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): sobald sich beim Bau zeigt, dass der
  Schlüssel **je Sensor-Modus verschieden** sein muss — ein `# verify: full-smoke`-Fall bootstrappt
  in ein tmp-Repo und fährt dort echte Docker-Gates, ein `test-go`-Fall übersetzt im gepinnten Bild.
  Fallen die zwei Bezugsmengen auseinander, sind es zwei Schnitte und nicht einer.
- `in-progress` → `open` (blockiert — Carveout?): wenn das Verdikt aus dem Start-Trigger *unzulässig*
  lautet, **oder** wenn sich die Deckung des Schlüssels nicht herstellen lässt, weil ein
  verdikt-tragender Anteil außerhalb jedes Baum-Zustands liegt (Docker-Bilder, Build-Cache,
  Registry-Antwort — §6, Risiko 1). Dann ist der richtige Ausgang ein Carveout mit benannter
  Rest-Unsicherheit oder das Verwerfen des Slice, nicht ein Übersprung mit Vorbehalt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig, `make gates` grün, Closure-Notiz geschrieben — und dazu **zwei beobachtbare
Kriterien, die auf verschiedenen Achsen messen**:

1. **Der Übersprung greift und ist an seiner Ausgabe erkennbar.** Zwei `make mutate`-Läufe
   hintereinander über einem Baum, der sich dazwischen nicht bewegt: der erste fährt den vollen
   Satz und endet mit `0 Befund(e)`, der zweite endet mit Exit 0, nennt den Beleg-Stand und fährt
   **keinen** Fall — nachweisbar daran, dass die Zeit-Aufschlüsselung des zweiten Laufs keine Zeile
   trägt. Die Wanduhr-Zeit beider Läufe wird notiert; sie ist eine **Messung**, kein Kriterium.
2. **Der Übersprung greift nicht, wenn er nicht darf — auf der Achse, die die neue Bezugsmenge von
   der alten trennt.** Drei Proben, und die dritte ist die tragende: **(a)** derselbe Baum mit einer
   Änderung an einer beliebigen `# files:`-Zieldatei → der Lauf fährt wieder voll · **(b)**
   `MUTATE_FORCE` erzwingt den vollen Satz auch über unverändertem Prüfgegenstand · **(c)** eine
   Änderung an einem Pfad, den die **Kopie trägt** und `git ls-files --cached --others
   --exclude-standard` **nicht** führt → der Lauf fährt wieder voll. Probe (c) ist genau der Punkt,
   an dem ein Schlüssel aus
   [`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh)
   fälschlich überspränge; sie belegt die Deckung, die
   [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 2 **gezeigt** und nicht angenommen sehen will. Der Pfad für (c) wird zur Laufzeit aus
   der Differenz bestimmt, nicht als Dateiname vorweggenommen — heute steht dort genau einer (§3),
   morgen kann es ein anderer sein.

**Warum das zweite Kriterium danebensteht und nicht im ersten aufgeht** (`BEO-029` — ein
Closure-Kriterium, das zwei Fassungen auf einer Fläche vergleicht, auf der sie nicht auseinander
laufen können): Kriterium 1 allein wäre auch dann erfüllt, wenn der Treiber **immer** überspränge.
Die Achse, auf der sich ein richtiger von einem kaputten Übersprung unterscheidet, ist die
**Verneinung** — und die misst nur Kriterium 2. **Aus demselben Grund ist Probe (c) keine Zugabe:**
ohne sie liefen beide Kriterien auf einer Fläche, auf der der abgelehnte und der gewählte Schlüssel
dasselbe sagen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Baum ist nicht die ganze Eingabe.** In das Verdikt gehen Anteile ein, die in keinem
   Baum-Zustand stehen: die gepinnten Docker-Bilder, der lokale Build-Cache und die Antwort der
   Registry. Der Kopf des Treibers misst diesen Posten selbst — zwei unmutierte `full-smoke`-Läufe
   über **demselben** Baum kosteten **90.00 s** und **136.16 s**, *„dazwischen hat ein `make mutate`
   den Docker-Cache umgewaelzt"* (`sed -n '60,72p' harness/tools/mutate.sh`; der dort festgehaltene
   Mess-Stand, kein Erwartungswert). Ein Beleg über unverändertem Baum konserviert damit ein Verdikt, das
   ein anderer Docker-Zustand kippen könnte. **Das ist die Lücke, die `MUTATE_FORCE` benennt statt
   schließt** — und der Grund, warum der Ausschalter kein Komfort ist, sondern Teil der Zusage.
   — **Ausgang: weiter offen.** Der Rest ist mit der Implementierung strukturell so geblieben, wie
   er hier vorhergesagt war — kein baum-abgeleiteter Schlüssel kann Docker-Cache-Zustand oder
   Host-Werkzeuge je decken. `MUTATE_FORCE` und die Übersprung-Meldung benennen ihn, wie DoD (1)
   verlangt; das ist Milderung, keine Schließung. Kandidat für einen neuen Registereintrag,
   vorgeschlagen als `BEO-031` in §7 — Eintragung ist Sache der Slice-Closure, nicht dieses
   Implementer-Laufs (§8).
2. **Die Bezugsmenge ist entschieden — offen bleibt, ob die eine Ausnahme trägt.**
   [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 3 setzt die Isolationskopie als Menge und **eine** Definition als Quelle; §3 dieses
   Plans deklariert `.git/` als einzige Ausnahme und begründet sie. Was **kein** Wächter prüft, sagt
   die ADR selbst: ob eine deklarierte Ausnahme *berechtigt* ist, prüft nichts — der Wächter aus
   DoD (2a) prüft, dass sie **dasteht**. Die Ausnahme ist damit dauerhaft ein Urteil und kein Beleg,
   und sie ist der erste Ort, an dem eine spätere Runde nachsieht, wenn ein Fall unerklärt grün
   bleibt. — **Ausgang: weiter offen.** Der Wächter aus DoD (2a) prüft und hält weiter nur, **dass**
   die Ausnahmeliste dasteht (`ISOLATION_KEY_EXEMPT` mit genau `.git`) — nicht, **ob** ein
   künftiger Eintrag darin berechtigt ist. Das bleibt dauerhaft ein Urteil, mechanisch nicht
   entscheidbar. Kandidat für einen neuen Registereintrag, vorgeschlagen als `BEO-032` in §7 —
   Eintragung ist Sache der Slice-Closure, nicht dieses Implementer-Laufs (§8).
3. **Eine engere Bezugsmenge ist verlockend und gemessen falsch, wenn sie am Dateityp ansetzt.**
   Ein Schlüssel über `*.go` + `test/mutations/**` + dem Treiber + `go.mod`/`go.sum` ließe genau
   die Mutationen unbemerkt, die **nicht** auf Go-Dateien zeigen: `sed -n 's/^# files: //p'
   test/mutations/*.sh | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u | grep -cv '\.go$'` → **28**
   Ziele in **20** Verzeichnissen (dasselbe Kommando mit `sed 's|/[^/]*$||' | sort -u | wc -l`),
   darunter `Makefile`, `Dockerfile`, `.claude/hooks/`, `.github/workflows/`,
   [`harness/tools/`](../../../../harness/tools/), [`harness/conventions/`](../../../../harness/conventions/),
   `internal/emit/templates/` und die Vorlagen des vendored Baums. Keine Erwartungswerte
   ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2). **Und die Ziel-Liste ist selbst zu eng als Bezugsmenge:** sie sagt, was eine Mutation
   *anfasst*, nicht, was ein Sensor *liest* — eine geschwächte Testdatei, die keine `# files:`-Zeile
   nennt, steht in keiner der beiden Mengen. **Die Isolationskopie ist die fail-closed Antwort und
   entschieden** ([ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 3); jede Verengung darunter ist eine eigene Entscheidung mit eigener Deckungs-Messung
   und liegt außerhalb dieses Slice (§Was hier nicht entschieden ist, zweiter Punkt derselben ADR).
   — **Ausgang: entfallen.** Implementiert ist die entschiedene Isolationskopie-Bezugsmenge:
   `isolation_key_files()` zieht dieselbe `ISOLATION_EXCLUDES`-Definition wie `prepare_isolation()`
   (§3-Tabelle), keine Dateityp-Filterung. Das hier beschriebene Risiko einer versehentlichen
   Verengung trat nicht ein, weil der Code die abgelehnte Alternative nie enthielt.
4. **Ein commit-basierter Schlüssel sähe den Arbeitsbaum nicht.** `git diff <sha> HEAD -- <pfade>`
   vergleicht zwei **Bäume aus der Historie**; eine ungespeicherte oder nur gestagte Änderung liegt
   in keinem von beiden und meldete „unverändert". Genau dieser Fehler ist in diesem Repo schon
   einmal entschieden worden: Der Gate-Nachweis ist **inhaltsbasiert** statt diff-basiert
   ([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)),
   und der Kopf von [`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh)
   nennt beide Richtungen der Begründung. **Dass ein Commit den Beleg gültig lässt, ist hier kein
   geerbter Nebengewinn, sondern die Folge der `.git`-Ausnahme aus §3** — er hängt an einem Urteil,
   das dieser Plan trifft, und fiele mit ihm weg. Das ist der Unterschied zum Gate-Nachweis, dessen
   Bezugsmenge `.git` nie enthielt. — **Ausgang: entfallen.** `isolation_key()` hasht den
   **Inhalt** von `isolation_key_files()` (`fingerprint_of_list`, Zeile ~331–340) — kein
   `git diff`/`git log`-Aufruf im Schlüsselpfad. Verifiziert: `grep -n 'git diff\|git log'
   harness/tools/mutate.sh` trifft keine Zeile zwischen `isolation_key_files` und `finalize_belief`.
   Das hier beschriebene Risiko einer diff-basierten Fassung trat nicht ein.
5. **Der Nutzen ist kleiner, als er klingt, und die entschiedene Bezugsmenge macht ihn kleiner, nicht
   größer.** Der Übersprung greift nur, wenn sich am Prüfgegenstand **nichts** bewegt hat — ein
   Doku-Nachzug, eine neue Review-Datei, ein Häkchen in einer DoD bewegen ihn. Die Kopie ist dabei
   **strenger** als die zuvor erwogene Menge: sie nimmt auch gitignorierte Pfade mit, die
   `git ls-files --cached --others --exclude-standard` nicht führt (heute genau einer, §3). Was
   bleibt: derselbe Lauf zweimal um einen Commit herum — die `.git`-Ausnahme hält genau diesen Fall
   offen — und der Verifier-Lauf nach einem Implementer-Lauf, der nichts mehr angefasst hat. **Ob
   der Slice sich damit lohnt, ist eine Planungs-Frage und ausdrücklich nicht von der ADR
   beantwortet** (§Was hier nicht entschieden ist, dritter Punkt); sie ist bei der Closure gegen die
   gemessene Wanduhr-Zeit aus §5 zu beantworten. — **Ausgang: entfallen.** Gemessen (Closure-Notiz
   §7, Closure-Trigger 1 aus §5): ein voller `MUTATE_FORCE=1`-Lauf über 248 Fällen kostet
   **1105.02 s** (`/usr/bin/time`, `248 ok, 0 Befund(e)`), der Übersprung über demselben,
   unveränderten Baum **0.10 s** — zweimal gemessen, exit 0, keine Fall-Zahl behauptet. Für den
   abgedeckten Fall (Verifier-Lauf nach einem
   Implementer-Lauf, der nichts mehr angefasst hat) ist der Nutzen real und nicht kleiner als
   erhofft.
6. **Der Übersprung wird als grüner Lauf zitiert.** Eine DoD-Zeile oder eine Closure-Notiz, die
   „`make mutate` grün" schreibt, unterscheidet nicht mehr zwischen *gemessen* und *belegt*. Das ist
   dieselbe Klasse wie `BEO-026` (ein Zähler-Label nennt eine andere Einheit als der Zähler zählt);
   die Gegenmaßnahme steht in DoD (1) — die Übersprung-Meldung behauptet keine Fall-Zahl und nennt
   den Beleg-Stand. Ungedeckt bleibt, was ein **Leser** daraus macht: kein Sensor liest eine
   Closure-Notiz. — **Ausgang: weiter offen.** DoD (1) hält die Meldungs-Form (kein Fall-Zähler im
   Übersprung), aber kein Wächter prüft, ob ein **späterer** Text — eine DoD-Zeile, eine
   Closure-Notiz, ein Review-Kommentar — „`make mutate` grün" schreibt, ohne zwischen echtem Lauf
   und Übersprung zu unterscheiden. Kandidat für einen neuen Registereintrag, vorgeschlagen als
   `BEO-033` in §7 — Eintragung ist Sache der Slice-Closure, nicht dieses Implementer-Laufs (§8).
7. **Die Zulässigkeits-Frage gehört nicht in den Implementations-Kontext.** Ob ein Übersprung eine
   Schwellen-Senkung ist, entscheidet [`AGENTS.md`](../../../../AGENTS.md) §3.5 (Senkung → ADR) gegen
   [`MR-050`](../../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)
   (Deckung → kein Griff nötig), und die Antwort ist eine **Entscheidung**, keine Planung
   (Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle: *„Wer beide in
   einem Kontext erledigt, setzt Schwellen ohne ADR-Bezug"*). Läuft der Slice ohne dieses Verdikt
   an, entsteht die Norm im Lauf, der sie braucht. Der Start-Trigger (§4) hängt darum daran.
   **Das Verdikt liegt vor** ([ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md),
   `Proposed`), **und was offen bleibt, ist seine Beweglichkeit:** ein Stand vor `Accepted` darf sich
   noch ändern, ohne Folge-ADR. Bewegte sich Festlegung 3 **nach** der Umsetzung, wäre die gelieferte
   Deckungs-Zusage falsch — und eine falsche Deckungs-Zusage ist nach Festlegung 2 derselben ADR
   nicht ein laxer Gate, sondern
   [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
   Ebene tiefer. Beobachtbar ist der Fall an der Geschichte-Tabelle der ADR; der Rückweg ist die
   Rückführung `in-progress` → `open` aus §4. **Ein Adaptions-Eintrag entsteht nicht, und das ist
   gemessen statt angenommen** — die ADR hält dasselbe Ergebnis in §Konsequenzen fest:
   `make mutate` hat in der adoptierten Baseline kein Gegenstück, von dem abgewichen
   werden könnte — er ist der repo-eigene Träger des Feedback-Quadranten zu
   [`AGENTS.md`](../../../../AGENTS.md) §3.6. Im Adaptions-Speicher kommt er in **sechs** Dateien
   vor (`grep -ril 'mutate' harness/conventions.md harness/conventions/ | wc -l`; kein
   Erwartungswert,
   [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2), und **keine** dieser Stellen regelt die Fall-Auswahl des Treibers: dreimal steht dort
   *„`make mutate` kennt keine Fehlschlag-Form dafür"*, einmal *„fährt nur die Fall-Dateien, die es
   findet"*, einmal der CI-Auslöser
   ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)),
   einmal eine Herkunfts-Nennung (`grep -n 'mutate' <jede der sechs Dateien>`).
   — **Ausgang: entfallen.** `git log --oneline -- docs/plan/adr/0035-...md` zeigt **einen** Commit
   (den anlegenden) — Festlegung 3 hat sich seit der Plan-Erstellung nicht bewegt, der Status ist
   unverändert `Proposed`. Der befürchtete Fall (Bewegung während der Umsetzung, gelieferte Deckung
   wird falsch) trat nicht ein.
8. **Der neue Fall misst sich selbst.** Ein `test/mutations/`-Fall, der die Übersprung-Logik in
   einer Test-Attrappe nachbaut statt die Stelle zu treffen, die `main()` benutzt, bleibt unter
   jeder Mutation grün (`BEO-028`; dieselbe Klasse, an der `test/mutations/221` hängt). Die Probe
   ist mechanisch: `make mutate` meldet auf den eigenen neuen Fall einen Befund, wenn er nicht
   trifft. — **Ausgang: eingetreten, aufgelöst im selben Slice, kein Carveout/Folge-Slice nötig.**
   Die Probe schlug real an: der erste vollständige `make mutate`-Lauf gegen den fertigen Diff (Job
   `bj9e7dr8v`) meldete `246 ok, 2 Befund(e)`, exit 2 — einer davon
   `test/mutations/262-mutate-schluessel-ausnahme-nicht-deklariert.sh`
   (`make test-bats blieb GRUEN — '...hat keine Zaehne mehr'`). Ursache war **nicht** eine
   Test-Attrappe (der Fall trifft die reale `isolation_key_files()`-Funktion, die `main()` benutzt),
   sondern eine Portabilitäts-Lücke in der neuen bats-Zusicherung selbst: `find … -printf '%P\n'`
   ist eine GNU-`find`-Erweiterung, die das gepinnte, Alpine/BusyBox-basierte `bats/bats`-Testbild
   nicht kennt (`docker run --entrypoint sh $(BATS_IMAGE) -c 'cat /etc/os-release'` →
   `Alpine Linux v3.19`, `tar (busybox) 1.36.1`) — der `find`-Aufruf scheiterte lautlos im
   `$(...)`-Capture, die Vergleichsmenge blieb leer, der Test konnte unter **keiner** Mutation rot
   werden. Behoben durch das im Repo bereits etablierte portable Muster (`baseline-verify.bats`,
   `courseset-fixture.bats`): `find … | sed 's|^\./||'`. Beide Richtungen gegen das **echte**
   gepinnte Bild nachgemessen, nicht nur gegen Host-`bash`: unmutiert `ok 49 ...`, mit der Mutation
   aus Fall 262 angewendet `not ok 49 ...`. Derselbe Vollständigkeits-Kanal fand einen zweiten,
   unabhängigen Befund am selben Lauf: `test/mutations/74-mutate-kopie-ohne-git.sh` traf nicht mehr
   (Risiko 8 ist damit auch der Beleg für Risiko 4 unten — zwei getrennte fail-closed-Bedingungen,
   ein Lauf). Der volle Fall-Satz lief danach zweimal sauber durch (`248 ok, 0 Befund(e)`, Jobs
   `bmvjdd30s` und die getimte Wiederholung in §7).
9. **Der Mutex und der Übersprung.** Der `mkdir`-Mutex trägt keine PID und ist bewusst fail-closed;
   ein hart abgebrochener Lauf lässt ihn liegen. Ein Übersprung **vor** dem Lock liefe an ihm
   vorbei und meldete Erfolg, während ein anderer Lauf noch arbeitet; ein Übersprung **hinter** dem
   Lock erbt dessen Abbruch-Meldung samt der Stale-Lock-Falle für einen Lauf, der gar nichts tut.
   Der Plan setzt ihn **hinter** den Lock (§3) — die entgegengesetzte Wahl wäre zu begründen, nicht
   stillschweigend zu treffen. — **Ausgang: entfallen.** Die geplante Reihenfolge ist implementiert
   und verifiziert: `mkdir "$LOCK"` und `HAVE_LOCK=1` stehen bei Zeile 1424/1430, der
   Beleg-Schlüssel-Check (`belief_key=...`, Übersprung-Pfad) erst ab Zeile ~1462 — der Übersprung
   sitzt hinter dem Lock, wie geplant. Das Risiko der entgegengesetzten (unbegründeten) Reihenfolge
   trat nicht ein.
10. **Diese Datei wandert.** `open/` → `next/` → `in-progress/` → `done/` bricht Verweise auf sie;
   `make slice-mv` deckt die Präfix-Formen und die ausgehende Hälfte der präfixlosen, **nicht**
   deren eingehende (`BEO-003`, 5×, verkörpert mit benannter Grenze). — **Ausgang: weiter offen,
   bereits gedeckt.** Der `git mv` dieser Datei nach `done/` läuft nicht in diesem Implementer-Lauf
   (Übergabe an Reviewer, s. Kopf dieser Datei) und ist damit kein Vorkommen dieses Slice — die
   strukturelle Grenze ist bereits als `BEO-003` verkörpert (`make slice-mv`, 5× Beleg); kein neuer
   Registereintrag.
11. **Die Platzierung der neuen Stellschraube.** `MUTATE_FORCE` ist eine technische Festlegung
    dieses Repos; ob die Aufnahme-Regel von [`spec/spezifikation.md`](../../../../spec/spezifikation.md)
    diese Klasse einschließt, ist offen — die zwei vorhandenen Stellschrauben stehen dort **nicht**,
    und wer diese Frage entscheidet, ist selbst ungeklärt (`BEO-007`, dritter Teil: die Spec-Straten
    haben keine schreibende Rolle; Träger ist
    [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md)). Dieser Slice folgt
    der bestehenden Platzierung und entscheidet die Frage nicht. — **Ausgang: weiter offen, bereits
    gedeckt.** Zitiert dieselbe offene Teilfrage wie `BEO-007` (4×, **geplant** → `slice-151`); dieser
    Slice folgt der bestehenden Platzierung (`MUTATE_FORCE` im Skript, keine Spec-Stelle) und bewegt
    die Frage nicht — kein neuer Beleg, kein neuer Registereintrag.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

*(Implementer-Übergabe an den Reviewer — der `git mv` nach `done/` selbst folgt erst nach Review
und Verifikation, s. Kopf dieser Datei und Baseline-Regelwerk `modul-08-agentenrollen.md`
§Rollen-Sequenz für einen Slice. Diese Sektion ist die dafür vorgesehene Vorarbeit.)*

- **Was hat funktioniert:** Die Fitness-Function-Struktur aus §2/§5 (drei benannte Wege ins stille
  Grün, je einer mit Gegenbeispiel) fing real, was sie fangen sollte — nur nicht am erwarteten Ort.
  `make mutate` selbst meldete auf den eigenen, in diesem Slice neu geschriebenen Fall
  (`test/mutations/262`) einen Befund, bevor irgendeine Behauptung „fertig" stand. Genau das ist der
  Mechanismus, den Risiko 8 vorab benannte, und er hat gegriffen.
- **Was ging anders als geplant:** Zwei Funde, beide über den echten `make mutate`-Lauf gegen den
  fertigen Diff, keiner über eine reine Code-Review-Lektüre. **Erstens:** die neue bats-Zusicherung
  (DoD 2a) benutzte `find … -printf '%P\n'` — eine GNU-`find`-Erweiterung, die im gepinnten
  Alpine/BusyBox-`bats/bats`-Testbild keine gültige Option ist; der Aufruf scheiterte dort lautlos,
  die Zusicherung war strukturell grün unter jeder Mutation (Risiko 8, Kandidat `BEO-034`). Host-`bash` mit
  GNU-Coreutils maskierte den Defekt vollständig — „von Hand geprüft" hätte ihn nicht gefunden.
  **Zweitens:** die im Slice fällige Refaktorierung von `prepare_isolation`s Ausschluss (inline
  `--exclude=` → benannte `ISOLATION_EXCLUDES`-Definition, DoD 1) machte den `sed`-Anker eines
  *bereits bestehenden* Falls (`test/mutations/74`) ungültig; der Fall scheiterte fail-closed an
  Bedingung 2 („Mutation ändert die Datei nicht"), statt unbemerkt durchzurutschen (Risiko 4). Beide
  Funde wurden in diesem Diff behoben und gegen das **echte** gepinnte Testbild — nicht nur gegen
  Host-`bash` — in beiden Richtungen (grün unmutiert, rot mutiert) nachgemessen, danach zwei
  vollständige `make mutate`-Läufe mit `248 ok, 0 Befund(e)` gefahren (Jobs `bmvjdd30s` und die
  getimte Wiederholung unten). **Drittens, aus dem Review** (`docs/reviews/2026-09-04-slice-180-…md`,
  blockiert mit 2 HIGH/3 MEDIUM/3 LOW/1 INFO, danach behoben): der Beleg-Slot überlebte einen
  Abbruch nach der Beleg-Prüfung — real reproduziert, Fix ist eine sofortige `clear_belief` am
  Entscheidungspunkt „kein Übersprung" statt erst am Lauf-Ende (neuer Fall
  `test/mutations/263`, neuer main()-Prozess-Test, der die echte Verdrahtung trifft statt der
  isolierten Funktion) · der Kommentar am Schlüssel-Punkt benannte die fünfte fail-closed-Bedingung
  fälschlich als Träger für den vollen Baum (**57** von **1058** Pfaden gedeckt — dieselben zwei
  Kommandos wie in §8, `BEO-025`; keine Erwartungswerte) — korrigiert,
  ohne die Deckungslücke selbst zu schließen. Dazu drei LOW (rohe Pipes in der damaligen
  `BEO-034`-Zeile, fehlende Untergrenze in Fitness-Function-Zeile 1, Chronik-Satz in einer
  `Stand`-Zelle) behoben. Danach erneut `make test`/`make gates`/`make mutate` — `249 ok,
  0 Befund(e)`, exit 0.
- **Vierter Zug, aus der zweiten Review-Runde** (`docs/reviews/2026-09-04-slice-180-…-runde-2.md`,
  erneut blockiert mit 1 HIGH/3 MEDIUM/1 LOW): **N-1** — der Gleichheits-Vergleich im dritten Teil
  der Übersprung-Bedingung (`belief_key` gegen den Beleg-Dateiinhalt) war ohne eigenen Wächter; ein
  neuer Fall (`test/mutations/264`) entfernt genau diesen Vergleich, ein neuer main()-Prozess-Test
  (`test/mutate-driver.bats`) legt eine Beleg-Datei mit abweichendem Inhalt vor und verlangt einen
  vollen Lauf statt eines Übersprungs — unmutiert GRÜN, mit der Mutation aus Fall 264 ROT, real
  gemessen. **N-2** — eine Runden-Kennung (`Review-Fund MEDIUM-1`) und eine veraltete Zeilennummer
  im Testkommentar (`AGENTS.md` §3.7) entfernt bzw. durch eine Stellenbeschreibung ohne Zeilenzahl
  ersetzt; der Testname und die `# expect:`-Zeile von Fall 263 verlieren ihr Freitext-Label
  `HIGH-1`. **N-3** — die vier Registerzeilen aus dem vorigen Zug sind aus `../observations.md`
  zurückgenommen (dieser Lauf schreibt nicht ins Register, wie §8 selbst sagt); ihr Inhalt steht
  jetzt als vorbereiteter Vorschlag in §7 (unten), das DoD-Häkchen ist entsprechend auf „vorbereitet,
  nicht eingetragen" korrigiert. **N-4** — ein Satz zur Ein-Slot-Eigenschaft des Belegs ergänzt in
  `harness/tools/mutate.sh` (Kopf) und [`harness/README.md`](../../../../harness/README.md).
  **N-5** — die beiden `57 von 1055`-Stellen tragen jetzt ihr Kommando und die
  Nicht-Erwartungswert-Marke, mit dem aktuellen Stand `57`/`1058`.
- **Schwellen-Stand:** kein Regel-Übertritt — keine der vier vorgeschlagenen Kandidaten-Zeilen
  (§Kandidaten für das Beobachtungs-Register unten) erreicht bei ihrer Übernahme 3×; alle vier sind
  Erstauftreten. Kein Eintrag `— liegt in …` (nichts verkörpert). Die wertvollste einzelne Lehre —
  GNU-only Shell-Optionen in bats-Zusicherungen gegen ein Alpine/BusyBox-Testbild (Kandidat unten) —
  bleibt darum **gezählt, nicht verkörpert**; ein Lint-Schritt oder eine Hard-Rule-Ergänzung wäre bei
  einem dritten Auftreten fällig. Den Lerneintrag, den der `done/`-Übergang verlangt, trägt der Block
  §Closure — Planner (Form *neuer Sensor*).
- **Beobachtungs-Register (`../observations.md`):** vom **Implementer**-Lauf nicht fortgeschrieben —
  §8 dieses Plans hält den Schreibpunkt für die Slice-Closure. Er hinterließ vier Kandidaten-Zeilen
  unten; eingetragen sind sie samt zwei Zähler-Schritten und zwei weiteren Zeilen beim
  Closure-Schritt (§Closure — Planner).
- **Folge-Slices:** keine — jedes Risiko trägt einen Ausgang, der entweder abgeschlossen ist
  (entfallen/eingetreten-aufgelöst) oder bereits an einer bestehenden Kennung hängt (`BEO-003`,
  `BEO-007`), ohne einen neuen Träger zu brauchen.
- **Risiken aus §6:** Risiko 1 weiter offen (Kandidat `BEO-031`) · Risiko 2 weiter offen (Kandidat
  `BEO-032`) · Risiko 3 entfallen · Risiko 4 entfallen · Risiko 5 entfallen (Messung unten) · Risiko 6
  weiter offen (Kandidat `BEO-033`) · Risiko 7 entfallen · Risiko 8 eingetreten, im selben Slice
  aufgelöst · Risiko 9 entfallen · Risiko 10 weiter offen, bereits `BEO-003` · Risiko 11 weiter offen,
  bereits `BEO-007`.
- **Wanduhr-Zeit (Risiko 5, Closure-Trigger 1 aus §5):** sechs reale Läufe insgesamt über den
  fertigen Diff, kein Erwartungswert
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — jeder einzelne `248 ok, 0 Befund(e)`, Vollständigkeit 248/248, exit 0: **vier**
  vollständige `MUTATE_FORCE=1`-Läufe (`bj9e7dr8v` mit 2 Befund(en) vor der Reparatur zählt nicht
  mit; danach `bmvjdd30s`, `bzr6op537` mit **1105.02 s**, `b8o8h2kkp` mit **1113.78 s**, `bte64frb1`
  mit **1105.67 s** — Streuung < 1 %, `/usr/bin/time -f '%e'`), **zwei** Übersprünge auf dem
  danach unveränderten Baum, direkt hintereinander gemessen: **0.08 s** und **0.07 s** (Exit 0,
  „… liegt vor … Kein Fall-Lauf.", keine Fall-Zahl behauptet). Das Verhältnis trägt Risiko 5 als
  *entfallen*: für den abgedeckten Fall (unveränderter Prüfgegenstand) ist der Übersprung praktisch
  kostenlos gegen einen vollen Lauf von rund 18,4 Minuten. **Gegenprobe live nachgezogen, zweimal
  unabsichtlich:** zwischen `bzr6op537` und `b8o8h2kkp` liefen redaktionelle Zwischen-Edits an
  getrackten Dateien dieses Diffs (der `.git`-Anker-Fix in dieser Plan-Datei **und** in
  `../observations.md`, dazu die Kommentar-Vereinfachung in
  `test/mutations/74-mutate-kopie-ohne-git.sh`); zwischen `b8o8h2kkp` und `bte64frb1` das
  Eintragen der `FULL_SECONDS`-Zahl samt Risiko-5-Text in dieser Datei. Beide Male lief der
  jeweils nächste `make mutate`-Aufruf **wieder voll**, statt zu überspringen — real ausgelöst,
  aber **nicht** der Beleg, den Closure-Trigger 2 (c) verlangt: alle drei angefassten Pfade sind
  getrackt und stehen in `git ls-files --cached --others --exclude-standard`; die definierende
  Bedingung von Probe (c) (dieselbe Menge **nicht** zu führen) trifft auf keinen von ihnen zu
  (Review-Runde 3, Fund R3-2 —
  [`2026-09-04-slice-180-mutations-sensor-verify-runde-3.md`](../../../reviews/2026-09-04-slice-180-mutations-sensor-verify-runde-3.md)).
  Was die zwei Zwischen-Edits real zeigen, ist die allgemeinere Eigenschaft, aus der (a) folgt:
  **jede** getrackte Datei bewegt den Schlüssel, nicht nur ein `# files:`-Ziel. **Probe (c) selbst
  ist real gefahren, gesondert und gezielt, im Verifier-Durchgang**
  ([`2026-09-04-slice-180-mutations-sensor-beleg-statt-lauf-verify.md`](../../../reviews/2026-09-04-slice-180-mutations-sensor-beleg-statt-lauf-verify.md)):
  einzige Änderung an `.claude/settings.local.json` — dem einen Pfad, den §3 als Kopie-ohne-`git
  ls-files` misst — verschob `isolation_key()` von `ff9dd097…` auf `29b501f0…`; ein direkt danach
  gestarteter `bash harness/tools/mutate.sh` lief messbar in den Grün-Vorlauf statt in die
  Übersprung-Meldung (Protokoll im genannten Verifier-Report), die Datei wurde danach
  byte-identisch zurückgesetzt. Erst der seither unangetastete Baum (`bte64frb1` → die zwei
  letzten Läufe, **0.08 s**/**0.07 s**) übersprang.
- **Drei Paarungen (nur Repo ohne Wellen-Betrieb):** **noch nicht geprüft** — sie laufen am
  formalen Closure-Schritt (`git mv` nach `done/`), den dieser Implementer-Lauf nicht ausführt.
  Vorprüfbar war bereits: Anker-Paarung entfällt (kein Feld `liegt in <Zielort>` in dieser Notiz, da
  nichts verkörpert wurde); Folge-Slice-Paarung entfällt (keine genannten Folge-Slices);
  Register-Paarung war zum Zeitpunkt der Übergabe **nicht anwendbar** — die Kandidaten-Zeilen unten
  entstehen in `../observations.md` erst mit dem Closure-Schritt, und die formale Prüfung setzt
  ohnehin voraus, dass diese Datei bereits in `done/` liegt. Ihr Ergebnis trägt §Closure — Planner.

### Kandidaten für das Beobachtungs-Register — bei der Closure eingetragen

Regel dieser Sektion: §8 unten hält den Schreibpunkt für `../observations.md` für Sache der
Slice-Closure (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register, *„Eingetragen
wird bei der Slice-Closure"*) — dieser Implementer-Lauf trägt darum **keine** Zeile dort ein. Die
vier Beobachtungen, die während der Umsetzung anfielen, stehen hier als vorbereiteter Inhalt für den
Übernahme-Schritt; **Kennung, Zähler und Beleg sind Vorschläge** — die tatsächliche Vergabe (nächste
freie `BEO-<NNN>`, gegen den dann aktuellen Registerstand) liegt beim Planner.

- **Kandidat `BEO-031`** (Risiko 1) — *Ein baum-abgeleiteter Beleg deckt nicht den vollen
  Prüfgegenstand: Docker-Cache-Zustand und Host-Werkzeuge (bash, tar, git, docker selbst) bleiben
  strukturell außerhalb jedes Inhalts-Hashs über einem Arbeitsbaum — ein Übersprung kann ein Verdikt
  konservieren, das ein anderer, nicht baum-abgeleiteter Zustand widerlegt hätte.* Sub-Area `*`
  (gesamtes Repo), vorgeschlagener Zähler 1×, Beleg `slice-180`, Stand `offen — Erstauftreten`,
  gemessen an [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 4 und der Umsetzung in diesem Slice §6 Risiko 1: `isolation_key()` hasht ausschließlich
  Pfade der Isolationskopie (`prepare_isolation`/`isolation_key_files`, dieselbe
  `ISOLATION_EXCLUDES`-Definition); Docker-Image-Digests stehen zwar in getrackten Dateien und
  bewegen den Schlüssel mit, aber der **gebaute Layer-Cache** und die **Host-Werkzeug-Version** selbst
  stehen in keinem Baum-Zustand. Gemildert, nicht geschlossen, durch `MUTATE_FORCE` und eine
  Übersprung-Meldung, die den Rest explizit benennt (`grep -n 'MUTATE_FORCE=1 erzwingt'
  harness/tools/mutate.sh`). Kein Modul aus `modules:` der `.d-check.yml` und kein Fall aus
  `test/mutations/` kann diese Klasse prüfen — der ungedeckte Anteil liegt außerhalb jedes
  Baum-Zustands, den ein Sensor lesen könnte; Träger ist die Zusage selbst (Kopf von
  `harness/tools/mutate.sh`, Absatz *BELEG STATT LAUF*).
- **Kandidat `BEO-032`** (Risiko 2) — *Eine deklarierte Ausnahmeliste (Ausschluss von einer sonst
  geltenden Regel) wird mechanisch nur auf **Existenz/Form** geprüft, nie auf **inhaltliche
  Berechtigung** — ob ein Eintrag darin richtig ist, bleibt dauerhaft ein Urteil, kein Beleg.*
  Sub-Area `*`, vorgeschlagener Zähler 1×, Beleg `slice-180`, Stand `offen — Erstauftreten`, gemessen
  an [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  Festlegung 3 und §6 Risiko 2: `ISOLATION_KEY_EXEMPT` trägt heute genau `.git`, mit
  schriftlicher Begründung in §3 des Plans (drei Gründe, gemessene Kosten). Der Wächter aus DoD (2a)
  desselben Slice (`test/mutate-driver.bats` „driver: jeder von prepare_isolation kopierte Pfad geht
  in den Schluessel ein oder steht in der Ausnahmeliste") hält nur, **dass** jeder kopierte Pfad im
  Schlüssel oder in der Ausnahmeliste steht — nicht, **ob** ein Eintrag in der Ausnahmeliste sachlich
  gerechtfertigt ist. Ein zweiter, unbegründet hinzugefügter Ausnahme-Eintrag bliebe für diesen
  Wächter unsichtbar. Kein Modul aus `modules:` der `.d-check.yml` prüft die Berechtigung eines
  Ausnahme-Eintrags gegen seine schriftliche Begründung; Träger ist die Review-Runde, die eine
  Erweiterung der Liste liest.
- **Kandidat `BEO-033`** (Risiko 6) — *Eine Aussage „X lief grün"/„`make mutate` grün" unterscheidet
  sprachlich nicht zwischen einem echten Fall-Lauf und einem Beleg-Übersprung — beide tragen denselben
  Wortlaut mit anderer Herkunft (*gemessen* vs. *belegt*), und kein Sensor liest eine Closure-Notiz
  oder DoD-Zeile gegen die tatsächliche Lauf-Art.* Sub-Area `*`, vorgeschlagener Zähler 1×, Beleg
  `slice-180`, Stand `offen — Erstauftreten`, gemessen an §6 Risiko 6: DoD (1) desselben Slice hält
  die **Meldungs-Form** des Übersprungs selbst frei von einer Fall-Zahl (`BEO-026`-Klasse vermieden),
  aber kein Wächter prüft einen **späteren** Text — eine künftige DoD-Zeile, Closure-Notiz oder ein
  Review-Kommentar könnte „`make mutate` grün" schreiben, ohne zu sagen, ob ein Fall-Satz lief oder
  ein Beleg zitiert wurde. Abgrenzung zu `BEO-026`: dort nennt ein Zähler-**Label** eine falsche
  Einheit; hier fehlt die Unterscheidung nicht am Zähler, sondern an der **Herkunfts-Angabe** einer
  Grün-Aussage selbst. Kein Modul aus `modules:` der `.d-check.yml` hält eine Grün-Behauptung gegen
  die Lauf-Art, aus der sie stammt; Träger ist der Review, der eine solche Aussage liest.
- **Kandidat `BEO-034`** (Risiko 8) — *Eine neu geschriebene bats-Zusicherung benutzt eine GNU-only
  Shell-/Coreutils-Erweiterung (hier `find … -printf`), die im gepinnten **Alpine/BusyBox**-Testbild
  lautlos scheitert — die Vergleichsmenge bleibt leer statt zu warnen, und die Zusicherung ist
  strukturell grün unter **jeder** Mutation, unabhängig vom geprüften Code.* Sub-Area `*`,
  vorgeschlagener Zähler 1×, Beleg `slice-180`, Stand `offen — Erstauftreten`, gemessen an
  `test/mutate-driver.bats` „driver: jeder von prepare_isolation kopierte Pfad geht in den Schluessel
  ein oder steht in der Ausnahmeliste" (§6 Risiko 8): der Test lief unter Host-`bash`/GNU-`find`
  korrekt rot/grün, und *derselbe Wortlaut* blieb unter dem gepinnten `bats/bats`-Image (`docker run
  --entrypoint sh $(BATS_IMAGE) -c 'cat /etc/os-release'` → `Alpine Linux v3.19`, `tar (busybox)
  1.36.1`) strukturell grün, weil `find -printf '%P\n'` dort keine BusyBox-Option ist und der Aufruf
  im `$(...)`-Capture lautlos scheiterte. Der Fehler ist an der **Wahl des Testwerkzeugs** entstanden,
  nicht am Code, den der Test prüft — Host-`bash` maskiert ihn vollständig, weil GNU-`coreutils` dort
  `-printf` kennt. Das im Repo bereits etablierte Gegenmittel (`find … | sed 's|^\./||'`, benutzt in
  `baseline-verify.bats`, `courseset-fixture.bats`, `emitted-baseline-verify.bats`) trägt jetzt auch
  die betroffene Zusicherung in `test/mutate-driver.bats`. Kein Modul aus `modules:` der
  `.d-check.yml` und kein `shellcheck`-Lauf prüft eine bats-Datei gegen den Options-Umfang des
  gepinnten `$(BATS_IMAGE)`; Träger ist der Autor, der eine neue Zusicherung schreibt, und — bei 3× —
  eine Prüf-Regel oder ein Lint-Schritt gegen bekannte GNU-only `find`/`tar`/`sed`-Optionen in
  `test/*.bats`.

### Closure — Planner

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md` §Closure- und
Lerneintrag-Regeln (zwei beobachtbare Kriterien **und** ein Lerneintrag) · `modul-06-roadmap.md`
§Das Beobachtungs-Register (Schreibpunkt ist die Slice-Closure) · [`AGENTS.md`](../../../../AGENTS.md)
§3.3 (Move und Inhalt in getrennten Commits).

- **Lerneintrag, Form *neuer Sensor*.** Der Slice hinterlässt drei neue Mutations-Fälle
  (`262`/`263`/`264`) und drei neue Zusicherungen in `test/mutate-driver.bats`, je eine pro Zeile
  der Fitness Function aus
  [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md).
  Zwei davon treffen `main()` als Prozess statt der isolierten Funktion — das ist der Unterschied,
  an dem der erste Entwurf scheiterte. **Was der Lerneintrag nicht behauptet:** dass damit die
  Klasse geschlossen wäre, die den Slice teuer machte. Die schärfste Einzel-Lehre — eine
  GNU-only-Option in einer bats-Zusicherung ist unter dem gepinnten Alpine/BusyBox-Bild unter jeder
  Mutation grün — hat keinen Sensor und liegt als `BEO-034` im Register: **gezählt, nicht
  verkörpert**.
- **Beobachtungs-Register fortgeschrieben** (`../observations.md`) — sechs neue
  Kennungen und zwei Zähler-Schritte, alle mit Beleg `slice-180`:
  - `BEO-031` (§6 Risiko 1) · `BEO-032` (Risiko 2) · `BEO-033` (Risiko 6) · `BEO-034` (Risiko 8) —
    die vier vorbereiteten Kandidaten oben, unverändert in der Sache, mit den vorgeschlagenen
    Kennungen: `BEO-030` war der Höchststand, es gibt keine Kollision.
  - `BEO-035` (neu, Planner-Beobachtung) — die Namensformen zweier Rollen-Reports sind nicht
    disjunkt. Entschieden statt offen gelassen: **benannt und gezählt, nicht korrigiert.** Der
    Bestand in `docs/reviews/**` sind Zeitdokumente, ein Umzug bräche eingehende Verweise, und
    keine Quelle verbietet der Reviewer-Form ihren freien Gegenstands-Teil — die Reparatur wäre
    eine Verschärfung einer der beiden Vorgaben und damit eine Entscheidung, kein Nachzug.
  - `BEO-036` (neu, im Closure-Lauf selbst ausgelöst) — der Verweis-Nachzug des `git mv` ersetzt
    auch einen Pfad, der als Tree-Operand an einer Commit-Kennung hängt, und macht das Kommando
    kaputt. Reparatur im selben Lauf, Messung unten.
  - `BEO-025` **3× → 4×**. Geprüft statt angenommen: der Slice hat die Klasse nicht nur benannt,
    sondern in einer **neu geschriebenen** Zusage erzeugt — der Kommentar am
    `isolation_key`-Aufrufpunkt nannte einen Sensor als Träger für den vollen Baum, dessen
    `# files:`-Ziele **57** von **1060** Schlüssel-Pfaden decken. Ein eigener Vorgang, ein
    Zähler-Schritt; der Ausgang bleibt **geplant** auf
    [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md).
  - `BEO-030` **1× → 2×**, zwei Funde in einem Vorgang. §8 dieses Plans führte `BEO-025` als 2×
    gegen 3× im Register (im Diff korrigiert) und führt `BEO-009` als 9× gegen 10× (steht). Der
    zweite Stand war beim Schnitt richtig und ist durch die dazwischenliegende Closure von
    `slice-175` veraltet; er wird hier **nicht** nachgezogen, weil er der Beleg für den
    Registereintrag ist, den diese Closure schreibt.
- **Lese-Schritt.** **Keine** Zeile erreicht **mit diesem Slice** 3×: `BEO-025` stand schon darüber
  und trägt seinen Ausgang, `BEO-030` steht bei 2×, die sechs neuen bei 1×. **Der
  Schwellen-Lese-Schritt liegt trotzdem nicht hier:** Das Repo führt Wellen-Betrieb —
  [`roadmap.md`](../in-progress/roadmap.md) §Offene Wellen trägt **2** Zeiger neben **4** flachen
  Welle-Dateien (`awk '/^## Offene Wellen/,/^## Nächste Wellen/' docs/plan/planning/in-progress/roadmap.md \| grep -c '^- \[welle-'`
  gegen `ls docs/plan/planning/welle-*.md \| wc -l`; die Differenz ist die dort erklärte Abweichung,
  geschnitten vor dem Start-Trigger; keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) —, und für diesen Fall gibt
  [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md) Schritt 24
  den Lese-Schritt der laufenden Welle-Closure. `BEO-017` steht bei 3× ohne Ausgang und benennt dafür
  selbst die Closure von [welle-15](welle-15-re-baseline.md); diese Slice-Closure bewegt die Zeile
  nicht.
- **Ausgang für den offenen Rest aus dem Review (Datei-Modus):** `isolation_key()` hasht Inhalt,
  nicht Metadaten — ein reiner `chmod` bewegt den Schlüssel nicht. Kein Fehlerpfad ist benannt, weil
  jeder Fall über `bash "$case_file"` läuft und kein Bit auswertet. **Weiter offen → Register:** der
  Punkt steht als zweiter, benannter Anteil in `BEO-031`, in derselben Klasse wie Docker-Cache und
  Host-Werkzeuge (ein Anteil des Prüfgegenstands, den der Schlüssel nicht liest) und darum kein
  eigener Zähler.
- **Roadmap.** Der Ruhe-Marker *Nichts in Arbeit* in
  [`roadmap.md`](../in-progress/roadmap.md) §Offene Wellen stand während der Laufzeit dieses Slice
  neben einem beanspruchten `in-progress/` — nach Baseline-Regelwerk `modul-06-roadmap.md`
  §Roadmap-Struktur derselbe Defekt wie ein fehlender Marker bei leerem Verzeichnis. Mit dem Move
  dieses Slice trifft er wieder zu; die Roadmap bleibt darum unberührt. Die Invariante ist unbewacht,
  der Abschnitt sagt das über sich selbst, und ihr Träger ist
  [slice-125](../open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) — kein neuer
  Registereintrag für eine bereits benannte Lücke mit benanntem Träger.
- **Drei Paarungen (Repo ohne Wellen-Betrieb, dieser Slice):** gefahren **nach** dem `git mv`, weil
  sie in `done/` suchen. **(a) Anker-Paarung — entfällt:** die Notiz trägt kein Pflichtfeld
  `liegt in <Zielort>`; die drei Treffer auf die Zeichenkette sind zwei Nennungen des Feldnamens in
  seiner Verneinung und ein Satz gewöhnlicher Prosa (`grep -n 'liegt in ' <diese Datei>`) — nichts
  ist mit diesem Slice verkörpert, also gibt es nichts zu paaren. **(b) Folge-Slice-Paarung — grün:**
  jede in dieser Datei genannte Slice-Kennung liegt als Datei im Lifecycle, geprüft über den
  vollständigen Ist-Bestand statt über eine Stichprobe (`grep -ohE 'slice-[0-9]{3}[a-z]?' <diese
  Datei> \| sort -u`, je Treffer ein `ls docs/plan/planning/{open,next,in-progress,done}/<id>-*.md`)
  — `slice-056`, `slice-125`, `slice-151`, `slice-175`, `slice-180`, `slice-181`, kein Fehltreffer.
  **(c) Register-Paarung — grün in beiden Hälften:** jede unter
  `docs/plan/planning/done/**` zitierte `BEO-<NNN>` hat eine Registerzeile (Differenz der zwei
  sortierten Mengen leer, `git grep -ohE 'BEO-[0-9]{3}' -- 'docs/plan/planning/done/**'` gegen
  `grep -oE '^\| BEO-[0-9]{3}' ../observations.md`), und jede Registerzeile trägt mindestens einen
  Beleg. **Über die Pflicht hinaus gemessen:** für jede Zeile stimmt der Zähler mit der **Anzahl**
  der Belege überein — die formgebundene Bedingung *so viele wie der Zähler sagt*, die die
  maschinelle Hälfte der Paarung nicht verlangt. Die Umkehrung *jede Zeile ist irgendwo zitiert* ist
  nach Baseline-Regelwerk `modul-06-roadmap.md` ausdrücklich **nicht** Gegenstand und ist nicht
  geprüft.
- **Ein Befund aus dem Closure-Lauf selbst, im selben Lauf repariert:** Der Verweis-Nachzug des
  `git mv` hängte einen **Tree-Operanden** um — `git show <sha>:…/in-progress/slice-180-…md` wurde
  zu `…/done/…`, und für diesen Stand meldet `git` *„befindet sich im Dateisystem, aber nicht in"*
  der Kennung. Der alte Pfad ist dort der richtige; er ist zurückgesetzt. Der Bestand ist gemessen:
  **37** Tree-Operanden in den lebenden Markdown-Artefakten, davon war genau der eben erzeugte tot
  (`git grep -ohE '\b[0-9a-f]{7,40}:[A-Za-z0-9_./-]+\.md' -- '*.md' ':!.harness/baseline' | sort -u`,
  je Eintrag `git cat-file -e`; keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Die Klasse liegt als `BEO-036` im Register, ihre Zusage-Hälfte — der Skriptkopf von
  `harness/tools/slice-mv.sh` führt *drei* Grenzen und diese ist die vierte — als zweiter, **nicht
  gezählter** Fund an `BEO-025`. `make docs-check` meldet über beiden Ständen dasselbe: kein Gate
  sieht die Klasse.

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** der drei Sub-Areas, die die
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) führt;
`.codex/` ist nicht berührt.

- **`harness/tools/`** — die drei Inklusions-Achsen (`grundlagen-bootstrap.md` §Was ist eine
  Sub-Area?, Schwelle ≥ 2): eigene Konventions-Härte **ja** (mehrere Adaptions-Einträge tragen
  ausdrücklich Rezepte und Helfer dieses Verzeichnisses, etwa
  [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  und [`MR-049`](../../../../harness/conventions.md#mr-049--drei-eigene-gate-rezepte-reichen-den-baum-read-only-herein-statt-ihn-per-copy-ins-bild-zu-nehmen))
  · eigene Pfad-Familie **ja** · eigene Inventur-Linie **ja** (die Helfer sind gegen `shell-lint`,
  `comment-claims` und `make mutate` als Paar abgleichbar, ohne eine Nachbar-Sub-Area mitzuziehen).
  Drei von drei.
- **`*` (gesamtes Repo)** — berührt über [`harness/README.md`](../../../../harness/README.md), die
  Außensicht auf den Sensor. Sie ist keine eigene Sub-Area und fällt darum in die repo-weite.

**Ausdifferenziert wird hier nichts:** `test/` steht in der Deklaration nicht als eigene Sub-Area
und wird von diesem Slice auch nicht zu einer — die zwei Test-Artefakte aus DoD (2) sind Wächter
der Änderung in `harness/tools/`, nicht ein eigener Träger einer Modus-Entscheidung.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist vollständig
durchgegangen (Stand: der gemergte Hauptzweig). **Jede** Zeile trägt `*` (gesamtes Repo) — die
Spalte unterscheidet in diesem Repo nichts (`BEO-004`, 1×). Acht Zeilen berühren diesen Slice mit
ihrem Zähler-Stand, und zwei davon binden eine DoD-Formulierung:

- `BEO-025` (**3×**, **geplant** → [slice-181](../open/slice-181-grenzen-liste-vollstaendig-oder-fail-closed.md))
  — *eine Zusage im Skript- oder Funktionskopf nennt einen Geltungsbereich, den der Code darunter
  nicht hält; in der schärfsten Form nennt sie einen Sensor, der den ausgegrenzten Rest nicht
  sieht.* **Die dem Slice am nächsten stehende Zeile:** Gegenstand von DoD (3) ist genau ein
  solcher Kopf, und der ursprüngliche Kommentar am `isolation_key`-Aufrufpunkt in `main()` trug
  tatsächlich genau diese Klasse — der `main()`-Kopf benannte die fünfte fail-closed-Bedingung als
  Träger für den ganzen Host-Baum, sie deckt aber nur **57** von **1058** Schlüssel-Pfaden
  (`# files:`-Ziele, nicht die volle `isolation_key_files`-Menge —
  `sed -n 's/^# files: //p' test/mutations/*.sh | tr ' ' '\n' | sed '/^$/d' | LC_ALL=C sort -u | wc -l`
  gegen `bash -c "source harness/tools/mutate.sh 2>/dev/null||true; isolation_key_files | wc -l"`;
  keine Erwartungswerte, [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2, beide Zahlen wandern mit dem Fall- bzw. Datei-Bestand). Im Diff korrigiert: die falsche
  Sensor-Zuschreibung entfernt, `BEO-025` benannt statt eine nicht existierende Deckung zu
  behaupten.
- `BEO-026` (2×, offen) — *ein Zähler-Label nennt eine andere Einheit als der Zähler zählt.* Bindet
  die Ausgabe-Form in DoD (1): die Übersprung-Meldung nennt keinen Fall-Zähler. Auch hier wäre ein
  Auftreten das dritte.
- `BEO-028` (1×, offen) — *ein Mutations-Fall nennt eine andere Datei als die, die sein Wächter
  liest.* Bindet DoD (2) und steht als Risiko 8 in §6.
- `BEO-029` (1×, offen) — *ein Closure-Kriterium hält zwei Fassungen auf einer Fläche gegeneinander,
  auf der sie nicht auseinanderlaufen können.* Bindet §5 — deshalb stehen dort zwei Kriterien auf
  zwei Achsen und nicht zwei Lesarten derselben.
- `BEO-009` (9×, geplant) — *ein Fix ändert die Ableitung, die Zusage daneben bleibt stehen.* Die
  Ableitung ist hier der Treiber, die Zusagen daneben stehen in seinem Kopf und in
  [`harness/README.md`](../../../../harness/README.md); DoD (3) ist die Antwort. Die Zeile ist
  bereits **geplant** und wird von diesem Slice nicht bewegt.
- `BEO-003` (5×, verkörpert) — *Verweise brechen beim Ortswechsel.* Steht als Risiko 10 in §6.
- `BEO-007` (4×, geplant) — *wer ein Norm-nahes Artefakt schreiben darf, sagt keine Quelle.* Betrifft
  diesen Slice über seinen dritten Teil (die Spec-Straten); steht als Risiko 11 in §6.
- `BEO-016` (1×, offen) — *ein Slice-Plan dieses Repos trägt ein Vielfaches der Zeilenzahl, die das
  Schwester-Repo für dieselbe Arbeitsklasse braucht.* **Dieser Plan liegt in derselben Klasse und
  sagt es selbst**, statt es dem Review zu überlassen: `wc -l` dieser Datei gegen die im Eintrag
  genannte Vergleichsklasse (kein Erwartungswert,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Was den Umfang hier trägt, ist die Beweislast des Start-Triggers — die Deckungs-Frage
  aus §4 ist ohne die Messungen in §6 nicht entscheidbar. Ob das die Klasse rechtfertigt oder ein
  zweites Auftreten ist, entscheidet der Lauf, der den Plan übernimmt; sie hier zu verneinen wäre
  das Urteil des Autors über sein eigenes Artefakt.

**`BEO-025` steht bereits bei 3×/geplant** — nicht durch diesen Slice, sondern durch den
`slice-175`-Lese-Schritt, der vor diesem Implementer-Lauf lag; die Sichtung oben zitiert den
korrekten, gemergten Stand. `BEO-026` bleibt bei 2×, offen, und träte erst durch einen weiteren
**Fund** über die Schwelle, nicht durch seine bloße Planung. Ob der im Diff korrigierte Fund an
`BEO-025` (Kommentar am `isolation_key`-Aufrufpunkt) einen weiteren Beleg für diese Zeile
begründet, ist beim Closure-Schritt zu entscheiden — Eintragungen in
`../observations.md` sind Sache der Slice-Closure, nicht dieses
Implementer-Laufs.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
Beide Sub-Areas stehen in der Modus-Deklaration als Greenfield (Doc führt, Code folgt, Graduation
`n/a`), und der Slice ändert daran nichts: Er schreibt zuerst die Zusage (DoD 3) und den Wächter
(DoD 2) und dann den Code, der sie hält.
