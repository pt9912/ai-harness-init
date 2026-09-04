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

**Verantwortlich:** — (bis zur Priorisierung).

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

- [ ] **(1) Der Treiber überspringt den Fall-Satz genau dann, wenn ein aufgezeichneter,
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
- [ ] **(2) Die drei Wege ins stille Grün sind je einmal rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6 — die Zusage ist
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
- [ ] **(3) Die stehenden Zusagen sagen, was der Treiber tut.** Der Kopf von
      [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) führt heute fünf
      fail-closed-Bedingungen und die Begründung, warum der Sensor nicht in `make gates` steht; der
      `make mutate`-Absatz in [`harness/README.md`](../../../../harness/README.md) beschreibt den
      Lauf für Leser von außen. Beide tragen die Übersprung-Bedingung **samt ihrer Bezugsmenge, der
      deklarierten Ausnahme und dem benannten Rest** — und die Zusage sagt nur, was der Schlüssel
      wirklich deckt (`BEO-025`). Die abgelöste Aussage wird **ersetzt, nicht ergänzt**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7: ein Kommentar beschreibt, was da ist).
- [ ] `make gates` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
   — **Ausgang:** <bei Closure>
2. **Die Bezugsmenge ist entschieden — offen bleibt, ob die eine Ausnahme trägt.**
   [ADR-0035](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 3 setzt die Isolationskopie als Menge und **eine** Definition als Quelle; §3 dieses
   Plans deklariert `.git/` als einzige Ausnahme und begründet sie. Was **kein** Wächter prüft, sagt
   die ADR selbst: ob eine deklarierte Ausnahme *berechtigt* ist, prüft nichts — der Wächter aus
   DoD (2a) prüft, dass sie **dasteht**. Die Ausnahme ist damit dauerhaft ein Urteil und kein Beleg,
   und sie ist der erste Ort, an dem eine spätere Runde nachsieht, wenn ein Fall unerklärt grün
   bleibt. — **Ausgang:** <bei Closure>
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
   — **Ausgang:** <bei Closure>
4. **Ein commit-basierter Schlüssel sähe den Arbeitsbaum nicht.** `git diff <sha> HEAD -- <pfade>`
   vergleicht zwei **Bäume aus der Historie**; eine ungespeicherte oder nur gestagte Änderung liegt
   in keinem von beiden und meldete „unverändert". Genau dieser Fehler ist in diesem Repo schon
   einmal entschieden worden: Der Gate-Nachweis ist **inhaltsbasiert** statt diff-basiert
   ([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)),
   und der Kopf von [`harness/tools/working-tree-hash.sh`](../../../../harness/tools/working-tree-hash.sh)
   nennt beide Richtungen der Begründung. **Dass ein Commit den Beleg gültig lässt, ist hier kein
   geerbter Nebengewinn, sondern die Folge der `.git`-Ausnahme aus §3** — er hängt an einem Urteil,
   das dieser Plan trifft, und fiele mit ihm weg. Das ist der Unterschied zum Gate-Nachweis, dessen
   Bezugsmenge `.git` nie enthielt. — **Ausgang:** <bei Closure>
5. **Der Nutzen ist kleiner, als er klingt, und die entschiedene Bezugsmenge macht ihn kleiner, nicht
   größer.** Der Übersprung greift nur, wenn sich am Prüfgegenstand **nichts** bewegt hat — ein
   Doku-Nachzug, eine neue Review-Datei, ein Häkchen in einer DoD bewegen ihn. Die Kopie ist dabei
   **strenger** als die zuvor erwogene Menge: sie nimmt auch gitignorierte Pfade mit, die
   `git ls-files --cached --others --exclude-standard` nicht führt (heute genau einer, §3). Was
   bleibt: derselbe Lauf zweimal um einen Commit herum — die `.git`-Ausnahme hält genau diesen Fall
   offen — und der Verifier-Lauf nach einem Implementer-Lauf, der nichts mehr angefasst hat. **Ob
   der Slice sich damit lohnt, ist eine Planungs-Frage und ausdrücklich nicht von der ADR
   beantwortet** (§Was hier nicht entschieden ist, dritter Punkt); sie ist bei der Closure gegen die
   gemessene Wanduhr-Zeit aus §5 zu beantworten. — **Ausgang:** <bei Closure>
6. **Der Übersprung wird als grüner Lauf zitiert.** Eine DoD-Zeile oder eine Closure-Notiz, die
   „`make mutate` grün" schreibt, unterscheidet nicht mehr zwischen *gemessen* und *belegt*. Das ist
   dieselbe Klasse wie `BEO-026` (ein Zähler-Label nennt eine andere Einheit als der Zähler zählt);
   die Gegenmaßnahme steht in DoD (1) — die Übersprung-Meldung behauptet keine Fall-Zahl und nennt
   den Beleg-Stand. Ungedeckt bleibt, was ein **Leser** daraus macht: kein Sensor liest eine
   Closure-Notiz. — **Ausgang:** <bei Closure>
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
   — **Ausgang:** <bei Closure>
8. **Der neue Fall misst sich selbst.** Ein `test/mutations/`-Fall, der die Übersprung-Logik in
   einer Test-Attrappe nachbaut statt die Stelle zu treffen, die `main()` benutzt, bleibt unter
   jeder Mutation grün (`BEO-028`; dieselbe Klasse, an der `test/mutations/221` hängt). Die Probe
   ist mechanisch: `make mutate` meldet auf den eigenen neuen Fall einen Befund, wenn er nicht
   trifft. — **Ausgang:** <bei Closure>
9. **Der Mutex und der Übersprung.** Der `mkdir`-Mutex trägt keine PID und ist bewusst fail-closed;
   ein hart abgebrochener Lauf lässt ihn liegen. Ein Übersprung **vor** dem Lock liefe an ihm
   vorbei und meldete Erfolg, während ein anderer Lauf noch arbeitet; ein Übersprung **hinter** dem
   Lock erbt dessen Abbruch-Meldung samt der Stale-Lock-Falle für einen Lauf, der gar nichts tut.
   Der Plan setzt ihn **hinter** den Lock (§3) — die entgegengesetzte Wahl wäre zu begründen, nicht
   stillschweigend zu treffen. — **Ausgang:** <bei Closure>
10. **Diese Datei wandert.** `open/` → `next/` → `in-progress/` → `done/` bricht Verweise auf sie;
   `make slice-mv` deckt die Präfix-Formen und die ausgehende Hälfte der präfixlosen, **nicht**
   deren eingehende (`BEO-003`, 5×, verkörpert mit benannter Grenze). — **Ausgang:** <bei Closure>
11. **Die Platzierung der neuen Stellschraube.** `MUTATE_FORCE` ist eine technische Festlegung
    dieses Repos; ob die Aufnahme-Regel von [`spec/spezifikation.md`](../../../../spec/spezifikation.md)
    diese Klasse einschließt, ist offen — die zwei vorhandenen Stellschrauben stehen dort **nicht**,
    und wer diese Frage entscheidet, ist selbst ungeklärt (`BEO-007`, dritter Teil: die Spec-Straten
    haben keine schreibende Rolle; Träger ist
    [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md)). Dieser Slice folgt
    der bestehenden Platzierung und entscheidet die Frage nicht. — **Ausgang:** <bei Closure>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

*(Vor dem `git mv` nach `done/` zu füllen.)*

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations.md`):** <neue `BEO-<NNN>` angelegt (Sub-Area, 1×, Beleg slice-NNN) | `BEO-<NNN>` auf <N>× erhöht, Beleg slice-NNN ergänzt | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations.md) ist vollständig
durchgegangen (Stand: der gemergte Hauptzweig). **Jede** Zeile trägt `*` (gesamtes Repo) — die
Spalte unterscheidet in diesem Repo nichts (`BEO-004`, 1×). Acht Zeilen berühren diesen Slice mit
ihrem Zähler-Stand, und zwei davon binden eine DoD-Formulierung:

- `BEO-025` (2×, offen) — *eine Zusage im Skript- oder Funktionskopf nennt einen Geltungsbereich,
  den der Code darunter nicht hält; in der schärfsten Form nennt sie einen Sensor, der den
  ausgegrenzten Rest nicht sieht.* **Die dem Slice am nächsten stehende Zeile:** Gegenstand von
  DoD (3) ist genau ein solcher Kopf, und der Übersprung schafft eine neue Zusage über einen
  Geltungsbereich (den Schlüssel). Tritt die Klasse in diesem Slice auf, ist sie das **dritte**
  Auftreten und braucht einen eigenen Folge-Slice statt einer Notiz — das ist bei der Closure zu
  entscheiden, nicht hier vorwegzunehmen.
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

**Keine dieser Zeilen erreicht mit diesem Slice 3×** — die zwei Kandidaten (`BEO-025`, `BEO-026`)
stehen bei 2× und träten erst durch einen **Fund** in diesem Slice über die Schwelle, nicht durch
seine Planung.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
Beide Sub-Areas stehen in der Modus-Deklaration als Greenfield (Doc führt, Code folgt, Graduation
`n/a`), und der Slice ändert daran nichts: Er schreibt zuerst die Zusage (DoD 3) und den Wächter
(DoD 2) und dann den Code, der sie hält.
