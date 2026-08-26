# Slice slice-097: Die Rollen-Typen gehen mit — generisch, Tool-als-Quelle, `skip-if-present`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — er hat **keine** Vorbedingung
innerhalb der Welle und darf parallel zu
[slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md) und
[slice-095](../done/slice-095-hook-aufschlag-gemessen.md) laufen.

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (*„Die
**Rollen-Typen** unter `.claude/agents/` sind Teil der Emission, nicht ihr Beiwerk — ohne sie
bliebe das Pflichtfeld `agent.role` dauerhaft leer"*, und die §Benannte Grenze dazu),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
emittierte Anleitung, die die Rollen-Sequenz im Ziel bereits fährt — ihr fehlt nur der **Typ**,
unter dem eine Rolle startbar ist; das ist der eigenständige Lieferwert dieses Slice),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
ein toter relativer Verweis in einer Typ-Datei färbt das `make gates` eines frischen Ziels rot und
bräche diese Zusage; DoD 3),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
emittierte Typ-Datei, die ein `make`-Ziel oder einen Pfad des **Dogfoods** nennt, behauptet über
das Ziel etwas, das dort nicht gilt),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 3: generisch, Tool-als-Quelle, `skip-if-present`, und die Kopplung *„der Träger füllt
`agent.role` genau dann, wenn der Agenten-Typ eine der sechs kanonischen Rollen **nennt**"* wird
benannt, nicht geschlossen),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (**Accepted** — Festlegung 3 gibt die
Idempotenz-Klasse: ein Rollen-Typ ist ein Text, den der Adopter anpasst; ein Re-Lauf, der ihn
zurücksetzte, wäre derselbe Clobber, den jene Entscheidung für die Commands ausgeschlossen hat),
[`ADR-0020`](../../adr/0020-emittierte-modul-15-regeln.md) (**Accepted** — ihre Festlegung 2
*„Die Rollen-Typen gehen nicht mit"* ist von
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) **vollständig**
revidiert; dieser Slice führt das Gegenteil aus),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — jede Zahl unten wandert mit ihrem Bestand).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Das gebootstrappte Zielrepo führt unter `.claude/agents/` die kanonischen Rollen-Typen in einer
generischen, aus Dogfood und Regelwerk abgeleiteten Fassung — nicht als Kopie der Typ-Dateien
dieses Repos —, und ein Re-Lauf überschreibt sie nicht.**

**Der Slice ist einzeln nützlich, auch ohne Träger.** Die emittierten Workflow-Commands fahren die
Rollen-Sequenz im Ziel bereits; *„was fehlt, ist der **Typ**, unter dem eine Rolle startbar ist"*.
Ein Ziel mit Typen und ohne Träger kann seine Rollen starten — das ist der Lieferwert, den
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) heute
offen lässt. Umgekehrt führte ein Ziel mit Träger und ohne Typen eine Achse, die **dauerhaft leer**
bleibt.

**Der Zweig ist unbedingt, und das ist aus der Entscheidung ablesbar, nicht geraten.** Die
Eigenschaft: *ein Artefakt, das
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a)
namentlich nennt oder das dort als zweig-teilend ausgewiesen ist.* Namentlich genannt sind Träger,
Wrapper und Hook-Eintrag; als zweig-teilend ausgewiesen ist allein die Feldliste (*„Die Feldliste
entsteht mit dem Träger … und teilt darum seinen Zweig"*). Die Rollen-Typen stehen in **keiner** der
beiden Aufzählungen — sie sind Text, sie hängen an keinem Laufzeit-Ausgang, und sie werden darum
**unbedingt** emittiert. Daraus folgt der Schnitt: dieser Slice wartet auf
[slice-096](../done/slice-096-traeger-liegt-im-ziel.md) nicht.

**Warum die Kopie unserer sechs Dateien falsch wäre.** `ls -1 .claude/agents/ | wc -l` → **6**
(mitwandernd); dieselbe Sechser-Zuordnung notiert der Emitter (`sed -n '182,189p'
internal/span/emit.go`: `planner`, `architect`, `implementer`, `reviewer`, `verifier`,
`validator`). Aber unsere Dateien tragen **die Slices, Konventionen und Befunde dieses Repos**. Das
Regelwerk sagt selbst, was ein Rollen-Typ ist (`v3.5.2`, `modul-08-agentenrollen.md`
§Rollen-Regeln): *„Rollen-Trennung ist Kontext-Trennung, nicht Personen-Trennung. Eine Person kann
mehrere Rollen spielen — aber nicht im selben Kontextfenster, sonst wiederholen sich blinde
Flecken."* Ein Typ trägt danach einen **Kontext-Zuschnitt**, keinen Repo-Inhalt — genau das macht
die generische Fassung tragfähig und die Kopie falsch.

**Die Kopplung wird benannt, nicht geschlossen.** Der Träger füllt `agent.role` genau dann, wenn
der Agenten-Typ eine der sechs kanonischen Rollen **nennt**; benennt der Adopter seine Typen um,
bleibt das Feld **leer**, und leer heißt *unbekannt*, nie *rollenlos*. Ein Wächter darüber wäre
einer über einem fremden Vertrag; die Grenze wird ausgesprochen — ihr stehender Ort ist das
Feldlisten-Dokument aus [slice-098](../next/slice-098-feldliste-ist-ausdruck-des-traegers.md), nicht dieser
Slice.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **(1) Die kanonischen Rollen-Typen liegen im Ziel, generisch statt kopiert.** Emittiert wird
      je Rolle eine Typ-Datei, deren Inhalt einen **Kontext-Zuschnitt** beschreibt und keinen
      Repo-Inhalt.
      **Der Sensor misst die Adresse, der Gegenstand ist die Aussage — darum die Aussagen-Menge,
      aufgezählt und mit ihrer Richtung.** Die Eigenschaft, über die gezählt wird: *eine Kennung
      oder ein Pfad, der nur in **diesem** Repo existiert und darum in einer emittierten Typ-Datei
      eine Falschaussage über das Ziel wäre.* **(a)** Slice-IDs (`slice-NNN`) — Richtung: sie
      benennen Vorgänge dieses Repos; im Ziel zeigen sie ins Leere.
      **(b)** Adaptions-Kennungen (`MR-NNN`) — Richtung: sie zeigen auf
      [`harness/conventions.md`](../../../../harness/conventions.md) **dieses** Repos, das kein Ziel
      bekommt. **(c)** Entscheidungs-Kennungen (`ADR-NNNN`) — Richtung: das Ziel führt **eigene**
      Entscheidungen unter denselben Nummern; ein Verweis wäre nicht bloß tot, sondern
      **falsch-treffend**, und das ist der schlimmere Fall. **(d)** `make`-Ziele, die nur der
      Dogfood führt — Richtung: dieselbe
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse,
      die im Ziel bereits als Befund geführt wird. **(e)** Pfade unterhalb von
      [`docs/plan/planning`](../../planning) und [`docs/plan/adr`](../../adr) mit konkreten
      Datei-Namen — Richtung: das Ziel führt unter diesen Verzeichnissen **eigene** Dateien
      (`b=$PWD/.harness/state/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe
      >/dev/null); find "$p/docs/plan/planning" "$p/docs/plan/adr" -type f | wc -l` → **6** an
      einem frisch gebootstrappten Ziel, mitwandernd), ein Verweis auf einen Datei-Namen darin
      träfe also entweder ins Leere oder — schlimmer — auf ein fremdes Dokument. Ein
      Kontext-Zuschnitt braucht keinen Datei-Pfad; die **Verzeichnisse** darf ein Typ nennen. Die
      Klasse ist damit strenger als die Menge der im Ziel abwesenden Pfade, und diese Richtung ist
      die gewollte.
      **Rot:** `make test` — ein Go-Wächter über dem emittierten Typ-Text, der auf jede der fünf
      Klassen prüft; dazu ein `test/mutations/`-Fall mit `# verify: test-go`, der eine davon
      einträgt und das Rot erwartet.
- [x] **(2) Die Klasse ist `skip-if-present`: ein zweiter Lauf setzt eine vom Adopter geänderte
      Typ-Datei nicht zurück.** Dieselbe Klasse wie die Commands
      ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Festlegung 3) — ein Rollen-Typ ist ein Text,
      den der Adopter an sein Repo anpasst.
      **Rot:** `make full-smoke` — der Idempotenz-Lauf ändert eine Typ-Datei und bootstrappt
      erneut; ein Clobber färbt rot. Dazu ein `test/mutations/`-Fall mit `# verify: full-smoke`,
      der die Klasse auf *konvergent* umstellt (der Treiber führt den Modus, `sed -n
      '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE '^[[:space:]]+[a-z*-]+\)'` →
      **7** Arme, mitwandernd).
- [x] **(3) Die emittierten Typ-Dateien halten das Doku-Gate des Ziels — out-of-the-box, in beiden
      Bootstrap-Varianten.** Die emittierte `.d-check.yml` fährt `modules: [links, anchors]` über
      `roots: ["."]` (`grep -m1 '^modules:' internal/emit/templates/d-check.yml`); ein toter
      relativer Verweis in einer Typ-Datei färbt das `make gates` eines frischen Ziels rot und
      bräche [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen).
      **Rot:** `make full-smoke` — das gebootstrappte Ziel fährt sein **eigenes** `make gates`,
      sprachlos und mit `--lang go`. Nur dieser Lauf fängt den Fall; ein Test in diesem Repo prüft
      den Text gegen **unsere** Konfiguration, nicht gegen die des Ziels.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/agents/` — je Rolle eine generische Typ-Datei <!-- d-check:ignore (geplante Dateien) --> | neu | Festlegung 3: dieselbe Herkunftsklasse wie die Durchsetzungs-Mechanik und die Workflow-Commands — Tool-als-Quelle, nicht Kopie |
| [`internal/emit`](../../../../internal/emit) — Emissionsstelle und Pfad-Liste für `.claude/agents/` | neu | heute liest **kein** emittiertes Artefakt das Verzeichnis: `grep -rn "claude/agents" --include=*.go . \| wc -l` → **0** (mitwandernd) — die Zahl war der tragende Beleg der abgelösten Festlegung 2 und wird hier zum Arbeitsauftrag |
| [`internal/emit/commands.go`](../../../../internal/emit/commands.go) — die `skip-if-present`-Mechanik der Commands als Muster | update | DoD (2): die Klasse **folgt** den Commands; eine zweite Mechanik für dieselbe Klasse driftete |
| [`internal/emit`](../../../../internal/emit) — Go-Wächter über den fünf Kennungs-Klassen | neu | DoD (1), in der Stufe, die `make mutate` erreicht |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | DoD (2) und (3): Idempotenz-Lauf und das eigene `make gates` des Ziels über beide Varianten |
| `test/mutations/` — je ein Fall für DoD (1) und (2) <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht |

## 4. Trigger

**`open` → `next`:** der Trigger von [welle-12](../welle-12-erfassungsschicht-emittieren.md) ist
erfüllt — er ist es heute (dort §2). Dieser Slice wartet auf **keinen** anderen; der Grund steht in
§1 (der unbedingte Zweig, aus Festlegung 5(a) abgelesen). **`next` → `in-progress`:** WIP-Limit
frei.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn die generische Fassung je Rolle mehr
trägt als einen Kontext-Zuschnitt — dann schreibt der Slice Prozess-Anleitung, und die gehört zu
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), nicht
hierher. `in-progress` → `open`, wenn sich zeigt, dass eine Rolle ohne repo-eigene Verweise nicht
beschreibbar ist — dann ist zu entscheiden, ob sie überhaupt emittiert wird, und das ist eine
Entscheidung, kein Slice. Beide Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün über beide
Varianten einschließlich des Idempotenz-Laufs, `make mutate` grün mit den neuen Fällen,
Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der teuerste Fehler ist die Kopie, die wie eine generische Fassung aussieht.** Sechs Dateien
  dieses Repos, aus denen jemand die Slice-IDs streicht, sind noch immer unsere Rollen — mit
  unseren Konventionen, unseren Befunden und unserem Prozess-Stand. DoD (1) fängt die **Kennungen**,
  nicht die **Haltung**; die bleibt Gegenstand des Reviews, und das steht hier statt einer Zusage.
- **Der Wächter aus DoD (1) prüft fünf Klassen, nicht Vollständigkeit.** Eine sechste Klasse
  repo-eigener Bezüge, die niemand vorhergesehen hat, bliebe still. Die Menge ist kuratiert und
  wächst mit jedem gefundenen Fall — dieselbe Haltbarkeits-Seite, die
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 für Mutations-Fälle ausdrücklich führt.
- **`skip-if-present` heißt, dass Fehler im emittierten Text nie geheilt werden.** Ein Adopter, der
  einmal gebootstrappt hat, bekommt jede spätere Korrektur **nicht** — anders als bei einem
  konvergenten Artefakt. Das ist der Preis der Klasse, und er ist bewusst bezahlt: ein Re-Lauf, der
  die Anpassungen des Adopters zurücksetzte, wäre der teurere Fehler.
- **Die Rollen-Achse ruht im Ziel auf Adopter-Disziplin.** Benennt jemand seine Typen um, bleibt
  `agent.role` leer. Das ist **keine Folge dieses Slice**, sondern die Grenze, die
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) selbst
  ausspricht — sie wird gesagt, nicht bewacht, und ihr stehender Ort ist
  [slice-098](../next/slice-098-feldliste-ist-ausdruck-des-traegers.md).
- **Ohne Träger bleibt der Nutzen halb.** Die Typen machen Rollen startbar, aber niemand erfasst
  ihre Läufe, solange [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) nicht liegt. Das ist ein
  **Zwischenstand, kein Widerspruch**: die Typen behaupten nichts über Erfassung, und wer sie liest,
  liest keine Zusage, die nicht gilt.
- **Berührung mit [slice-092](../open/slice-092-traeger-inventur.md), falls jener zuerst liegt.** Seine
  Zelle für Modul 8 §Rollen-Trennung nennt das Präfix `.claude/agents/`, heute leer
  (`grep -rl '".claude/agents/' --include=*.go internal/ | wc -l` → **0**, mitwandernd). Sobald
  dieser Slice die Adresse anlegt, färbt jener Wächter rot — **gewollt**, denn genau dann ist die
  Zelle auf *Träger kommt mit* zu ziehen.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Ein frisch gebootstrapptes Ziel führt unter `.claude/agents/` sechs Rollen-Typen, je
einen für eine kanonische Rolle, und jede Datei nennt ihren Rollen-Namen im Frontmatter — die
Bedingung, unter der die Erfassung die Rollen-Achse überhaupt besetzen kann
([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3).
Gemessen an einem Ziel, das dieser Lauf selbst gebootstrappt hat:
`b=$PWD/.harness/state/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); ls -1 "$p/.claude/agents/" | wc -l`
→ **6**, und für jede der sechs trifft `grep -qxF "name: <rolle>"` zu (dieselbe Schleife, `n` je
Treffer erhöht → **6**). Die Texte sind **generisch**: sie tragen einen Kontext-Zuschnitt — Eingang,
Ausgang, Abgrenzung, Grenze — und keine Kennung und keinen Pfad, der nur in diesem Repo auflöst. Ein
zweiter Init-Lauf lässt eine vom Adopter geänderte Typ-Datei unberührt; die Klasse ist
`skip-if-present` wie bei den Workflow-Commands
([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Festlegung 3), und sie ist **eine** Mechanik, nicht
zwei: `grep -rn 'func writeSkipIfPresent' internal/emit/` → genau **eine** Definition
([`internal/emit/enforce.go`](../../../../internal/emit/enforce.go)), und
`grep -rn 'writeSkipIfPresent(' internal/emit/*.go | grep -v 'func '` → **5** Aufrufer, darunter je
einer in [`internal/emit/agents.go`](../../../../internal/emit/agents.go) und
[`internal/emit/commands.go`](../../../../internal/emit/commands.go). Alle Zahlen wandern mit ihrem
Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1)–(3) erfüllt, mit gefahrenen Kommandos.** Bestätigt in der
   [Verifikation](../../../reviews/2026-08-25-slice-097-verify.md) §3, deren Rot-Sonden auf einer
   Kopie außerhalb des Repos und an einem eigens gebootstrappten Probe-Ziel liefen.
2. **`make gates` grün.** Eigener Lauf, Belege unten unter *Gates*.
3. **`make full-smoke` grün über beide Varianten einschließlich des Idempotenz-Laufs.**
   **Fremdbelegt** — von der Verifikation über genau diesem Baum gefahren
   ([Bericht](../../../reviews/2026-08-25-slice-097-verify.md) §1.1, Lauf L2), nicht von dieser
   Rolle. Die Laufzeit steht dort und **nicht** hier: sie ist ein Maschinen- und Cache-Zustand.
4. **`make mutate` grün mit den neuen Fällen.** Ebenfalls **fremdbelegt** (§1.1, Lauf L3); die zwei
   neuen Fälle erscheinen dort einzeln als `ok` mit dem erwarteten Wächter rot.
   `ls -1 test/mutations/*.sh | wc -l` → **157**.
5. **Review konform (Modul 10).** [Code-Review](../../../reviews/2026-08-25-slice-097-review.md):
   *nicht frei*, `grep -c '^### F-' docs/reviews/2026-08-25-slice-097-review.md` → **3** (0 HIGH ·
   1 MEDIUM · 2 LOW). Die MEDIUM (F-3, fehlender go-test-Tier-Fall für `skip-if-present`) ist
   **behoben**, F-2 ebenfalls; F-1 bleibt offen und ist unten als Delta geführt.
6. **Verifikation (Modul 11).** [Bericht](../../../reviews/2026-08-25-slice-097-verify.md): *frei
   für die Closure*, `grep -c '^### V-' docs/reviews/2026-08-25-slice-097-verify.md` → **9**, eine
   davon MEDIUM, keine am Verhalten des Gebauten.
7. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.

**Drei Plan-vs-Code-Deltas — benannt, nicht geglättet.**

- **(1) Die Zelle für [`internal/emit/commands.go`](../../../../internal/emit/commands.go) ist zur
  Hälfte eingelöst.** §3 führt die Datei als *update*;
  `git diff HEAD --stat -- internal/emit/commands.go` → **leer**. Die Plan-**Absicht** — *„eine
  zweite Mechanik für dieselbe Klasse driftete"* — ist am **Endpunkt** eingelöst: derselbe
  `writeSkipIfPresent`, eine Definition, kein zweiter Schreibweg. Sie ist an der **Hülle darüber**
  nicht eingelöst: `agentFiles()` / `AgentPaths()` / `AgentFile()` sind eine zweite, fast wörtliche
  Ausfertigung von `commandFiles()` / `CommandPaths()` / `CommandFile()`, und keine der drei greift
  auf eine gemeinsame Hilfsfunktion zurück (`grep -n 'func \(agentFiles\|AgentPaths\|AgentFile\)\b' internal/emit/agents.go`
  und dasselbe Muster über `commands.go` → je **3** Treffer in gleicher Reihenfolge). Wer künftig
  die Schleife in `Commands()` ändert, wird von nichts gezwungen, `Agents()` mitzuziehen — genau die
  Drift, vor der die Plan-Begründung warnt, eine Ebene über dem Schreib-Aufruf. **Kein Träger, und
  das ist entschieden:** eine Zusammenlegung wäre ein Refactor an zwei Emittern ohne eigenen
  Lieferwert, und die Zelle beschreibt einen Zustand, den ein Leser in zwei `grep` sieht.
- **(2) [`cmd/ai-harness-init/main.go`](../../../../cmd/ai-harness-init/main.go) ist im Diff und
  steht in keiner Zeile von §3.** `git diff HEAD --numstat -- cmd/ai-harness-init/main.go` →
  **12** Einfügungen, **5** Löschungen. Der Plan verortet die Emissionsstelle unter
  `internal/emit`; der **Aufruf** liegt in `emitAll`, und genau dort sitzt die Verdrahtung, an der
  V-3 hängt. Weil die Zeile fehlte, hat auch kein Rot-Rezept sie bedacht: der Plan hat für sie
  keinen Sensor verlangt, und gebaut wurde einer nur auf der `full-smoke`-Stufe. **Das ist die
  teuerste der drei Abweichungen** — nicht weil etwas Falsches gebaut wurde, sondern weil eine
  Tabelle, die eine berührte Datei nicht führt, die Stelle auch nicht mit einer Zusage belegt.
- **(3) DoD (2) verlangt einen `test/mutations/`-Fall mit `# verify: full-smoke`; gebaut ist
  `# verify: test-go`.** `sed -n 's/^# verify: //p' test/mutations/164-rollentypen-konvergent.sh` →
  `test-go`. Die **Entscheidung** ist gemessen richtig — der schmalere Sensor fällt unter dieser
  Mutation, und `make mutate` bestätigt es über den echten Pfad —, der **Plan-Text** ist es nicht
  mehr.

**Was am Plan korrigiert wurde, was bewusst stehen blieb, und wo die Grenze zwischen beidem läuft.**

Mit dem Zug nach `done/` wird diese Datei zum **Zeitdokument**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Geltungsbereich); eine Korrektur ist danach keine mehr, sondern ein Eingriff in die Geschichte.
Also entscheidet diese Closure, und sie sagt, was sie getan hat.

- **Korrigiert: die Begründung von DoD (1)(e).** Dort stand, die Verzeichnisse existierten im Ziel,
  ihre Dateien nicht. Das ist falsch, und zwar messbar:
  `b=$PWD/.harness/state/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); find "$p/docs/plan/planning" "$p/docs/plan/adr" -type f | wc -l`
  → **6**. Korrigiert ist die **Tatsachenbehauptung über das Ziel**, nicht das Kriterium: die
  Klasse verbietet unverändert jeden Datei-Pfad unter diesen zwei Verzeichnissen und ist damit
  strenger als die Menge der dort abwesenden Pfade — fail-closed, und das ist die gewollte
  Richtung. Der gebaute Wächter ist von dieser Korrektur **nicht** berührt; er war schon vorher
  strenger als der Satz, der ihn rechtfertigte.
- **Nicht korrigiert: die zwei Rot-Kommandos.** DoD (1) nennt weiterhin `make test` für *„liegen im
  Ziel"*, DoD (2) weiterhin `# verify: full-smoke`. Beides ist gemessen unzutreffend (V-3, V-7) —
  und beides bleibt stehen, weil eine DoD, die man am Ende an das Gebaute anpasst, aufhört, ein
  Maßstab zu sein. Ein Rot-Rezept, das im Lauf falsch war, ist ein **Befund über den Schnitt**; wer
  ihn wegschreibt, hat nur die Spur getilgt. Die Sache selbst ist unbeschädigt: beide Zusagen sind
  rot gesehen, nur je eine Stufe neben der, die der Text nennt.
- **Die Grenze zwischen beiden Fällen, damit sie beim nächsten Mal ohne Abwägung liegt:** eine
  **Tatsachenbehauptung über die Welt** wird korrigiert, sobald sie widerlegt ist — sie war nie
  Maßstab, sondern Begründung. Ein **Abnahme-Kriterium samt seinem Rot-Kommando** wird nicht
  korrigiert, sondern in der Closure als Delta ausgewiesen — es *ist* der Maßstab, an dem der Lauf
  gemessen wurde.
- **Nicht angefasst: der Code.** Zwei Ein-Zeilen-Ungenauigkeiten liegen in
  [`internal/emit/agents_test.go`](../../../../internal/emit/agents_test.go) — der Klassen-Kommentar
  beziffert die Emissions-Menge unter `docs/plan/` mit *zwei* (gemessen **6**, Kommando oben), und
  das `richtung`-Feld derselben Klasse sagt *„keinen Datei-Pfad unter `docs/plan/`"*, während das
  Muster nur `planning|adr` deckt. Der Planner schreibt keinen Code; beide stehen unten mit Träger.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Die Rollen-Achse ruht im Ziel auf Adopter-Disziplin.** Benennt jemand seine Typen um, bleibt
  `agent.role` leer, und leer heißt *unbekannt*, nie *rollenlos*. Das ist die Grenze, die
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) selbst
  ausspricht; alle sechs emittierten Typ-Dateien sagen sie mit. Ein Wächter darüber wäre einer über
  einem fremden Vertrag — **kein Träger, und das ist entschieden**.
- **Der Wächter über den Kennungs-Klassen prüft fünf Klassen, nicht Vollständigkeit.**
  `grep -c 'richtung:' internal/emit/agents_test.go` → **5**. Eine sechste Klasse repo-eigener
  Bezüge bliebe still, bis jemand sie findet; die Verifikation hat mit sechs eigenen Gegenproben
  keine gefunden, und das ist eine Messung über den ganzen Text, keine Vollständigkeitsaussage.
- **`skip-if-present` heißt, dass Fehler im emittierten Text nie geheilt werden.** Wer einmal
  gebootstrappt hat, bekommt keine spätere Korrektur der sechs Dateien. Der Preis ist bewusst
  bezahlt; der Re-Lauf, der die Anpassungen des Adopters zurücksetzte, wäre der teurere Fehler.
- **Ob das Agenten-Werkzeug die Typ-Dateien im fremden Repo lädt, belegt kein Lauf.** Geprüft ist
  die **Form** (Kopf-Felder, Frontmatter-Name); ein Lauf des fremden Werkzeugs gegen ein
  Adopter-Repo ist netzlos nicht führbar — dieselbe Klasse Annahme wie beim Hook-Feuern
  ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Annahme (a)).

**Steering-Loop-Eintrag — geschärfte Regel.**

**Der Text, mit dem ein Wächter seinen Treffer begründet, ist Teil des Wächters. Er wird
ausschließlich im Rot ausgegeben — ein grüner Lauf liest ihn nie. Also gehört zu „rot gesehen"
([`AGENTS.md`](../../../../AGENTS.md) §3.6) das Lesen der Meldung und die Prüfung, ob ihre
Begründung auf die Sache zutrifft, die sie erklärt.**

**Der gemessene Anlass.** Beim Rot-Sehen der eigenen neuen Klasse fiel auf, dass die Meldung ihren
Treffer mit einer Aussage über das Ziel begründete, die dort nicht gilt: *unter diesen
Verzeichnissen lägen keine Dateien.* Gemessen liegen dort **6**
(`… find "$p/docs/plan/planning" "$p/docs/plan/adr" -type f | wc -l`, Vollform oben). Der Wächter
war richtig — er verbietet den Datei-Pfad und trifft damit nichts Falsches —, seine **Erklärung**
war es nicht; gefunden hat es kein Gate, sondern der Blick auf die Ausgabe
eines absichtlich roten Laufs. Die Nachfolge-Fassung derselben Meldung ist heute noch immer breiter
als ihr Muster — sie sagt *„keinen Datei-Pfad unter `docs/plan/`"*, gedeckt sind `planning|adr` —,
was zeigt, dass die Klasse nicht mit einem Fund erledigt ist.

**Die Größe der unbeschienenen Fläche, mit ihrer Eigenschaft vor der Zahl.** Die Eigenschaft: *eine
Zeichenkette, die ein Wächter ausschließlich in seinem Fehlschlag-Zweig ausgibt.* **20** stehen in
der einen neuen Wächter-Datei dieses Slice
(`grep -cE 't\.(Fatalf|Errorf|Fatal|Error)\(' internal/emit/agents_test.go`), **86** allein im
Voll-E2E-Sensor, den er erweitert
(`grep -c 'FEHLER —' harness/tools/full-smoke.sh`); beide Zahlen wandern mit ihrem Bestand.
Keine davon liest ein grüner Lauf, und keine liest ein Gate: `make comment-claims`
prüft, ob ein **genannter Test existiert**, nicht ob eine Meldung zutrifft, und sein Prüfbereich
nimmt `_test.go` ohnehin dauerhaft aus; `make docs-check` prüft Form, nicht Aussage; `make mutate`
vergleicht die Ausgabe gegen `--- FAIL:` und den erwarteten Wächter-Namen — nie gegen die
Begründung, die daneben steht.

**Warum eine Regel und kein Sensor.** Ob eine Begründung *zutrifft*, ist ein Urteil über Prosa, kein
Muster; ein Wächter darüber bräuchte zuerst ein Kriterium — dieselbe Absage, die
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) §1 ihrem Weg (C) erteilt. Was
mechanisch bleibt, ist der **Zeitpunkt**: die Meldung ist genau dann lesbar, wenn das Gegenbeispiel
läuft, und dieser Moment ist in §3.6 bereits vorgeschrieben. Die Schärfung kostet also keinen
zusätzlichen Lauf, sondern einen zusätzlichen Blick in den, den es schon gibt.

**Träger: [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) — als sechster
Posten, ausdrücklich nicht *„der Architect"*.** Jener Slice ist genau für diese Klasse geschnitten
und trägt seinen Termin selbst; sein §3 verlangt, dass ein weiterer Posten **vor** der ersten
Entscheidung aufgenommen wird und dass dabei steht, woran er erkannt ist. Erkannt ist er an drei
Merkmalen, die er mit den fünf vorhandenen teilt: er adressiert dieselbe Regel
([`AGENTS.md`](../../../../AGENTS.md) §3.6), er **hebt** eine Beleg-Anforderung an (und braucht
darum kein ADR — [`AGENTS.md`](../../../../AGENTS.md) §3.5,
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
und er hat dieselbe Herkunft: eine Closure hat ihn formuliert und gemessen. Verschieden ist die
**Achse** — die vier, die an derselben Regel hängen, handeln von den **Trägern** eines Rot-Belegs,
seiner **Reichweite**, seinem **Gegenstand** und der **Richtung** seines Fehlers; dieser von seiner
**Ausgabe**. Der Posten ist dort eingetragen;
**der Regeltext wird hier nicht vorentschieden**, er entsteht im Architect-Lauf
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| DoD (1) nennt für *„liegen im Ziel"* `make test`; gemessen bleibt `make test` grün, wenn der Aufruf aus `emitAll` fällt, und rot wird nur `make full-smoke`. Für die **Verdrahtung** gibt es keinen `test/mutations/`-Fall — nach [`AGENTS.md`](../../../../AGENTS.md) §3.6 also unbewacht in der Haltbarkeits-Achse | **[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md)** — der Zahn, der hier fehlt, muss den Wächter in [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) rot färben, und genau diese Datei ist der dritte Fundort, den jener Slice bindet. Ein Artefakt, eine Frage |
| Der neue Wächter in [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) ist selbst unbewacht: `grep -l '^# files:.*full-smoke' test/mutations/*.sh` → **leer**. Streicht man eine Rolle aus seiner Schleife, bleibt jeder Sensor grün | **[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md)** — dieselbe Zeile, dieselbe Frage |
| Der Slice legt den **dritten** Produktions-Fundort der Sechser-Namensliste an: `grep -rn 'planner.*architect.*implementer' --include='*.go' --include='*.sh' . \| grep -v '_test.go' \| wc -l` → **3** | **[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md)** — er schließt die Kopplung, die [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3 *„benannt, nicht geschlossen"* lässt |
| Der Klassen-Kommentar in [`internal/emit/agents_test.go`](../../../../internal/emit/agents_test.go) beziffert die Emissions-Menge unter `docs/plan/` mit *zwei* (gemessen **6**), und das `richtung`-Feld derselben Klasse ist breiter als sein Muster | **[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md)** — beide liegen in der Datei, deren Wächter er ohnehin auf eine Quelle zieht; zwei Zeilen, kein eigener Schnitt |
| `emit.AgentFile()` ist exportiert und hat **null** Aufrufer (`grep -rn 'AgentFile' --include=*.go . \| wc -l` → **1**, die Definition); der Doc-Kommentar sagt *„(fuer Tests/Inspektion)"* | **[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md)** — als **§3-Zelle**, nicht als §6-Aufzählung: sein Bestands-Nachweis braucht genau diesen Zugriff, also bekommt die Funktion einen Aufrufer oder sie fällt. Ein Posten ohne Ort in der Plan-Tabelle ist die Form, die dieses Repo als wirkungslos gemessen hat |
| Der Text einer Fehlschlag-Meldung ist Teil des Wächters und wird nur im Rot gelesen | **[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md)** — der Steering-Loop-Eintrag oben, dort als sechster Posten eingetragen |
| `make mutate` kostet **1166** Sekunden für **157** Fälle (Messung der [Verifikation](../../../reviews/2026-08-25-slice-097-verify.md) §1.1, **fremdbelegt**), und sein Grün-Vorlauf wirft sein Protokoll bei Erfolg weg — ein grüner Lauf belegt darum **nicht**, dass die Zähne dieses Slice in `full-smoke` gelaufen sind | **[slice-105](../open/slice-105-mutate-messen-dann-teilen.md)** — er misst zuerst je Fall und je Sensor und entscheidet dann über die Teilung; die Protokoll-Frage hängt an derselben Mechanik |
| Die Hülle über `writeSkipIfPresent` ist zweimal geschrieben (Delta 1) | **kein Träger, und das ist entschieden** — ein Refactor ohne Lieferwert; der Zustand ist in zwei `grep` sichtbar und in dieser Notiz benannt |
| Ob das Agenten-Werkzeug die Typ-Dateien im Ziel lädt | **kein Träger, und das ist entschieden** — netzlos nicht führbar, und die Grenze steht in [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Benannte Grenze wie in allen sechs emittierten Dateien |

**Folge-Slices: zwei neue `open/`-Einträge.**
[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md) (die Rollen-Namen bekommen **eine**
Quelle, und die drei Produktions-Fundorte leiten aus ihr ab) und
[slice-105](../open/slice-105-mutate-messen-dann-teilen.md) (`make mutate` wird **erst gemessen**,
dann geteilt). **Beide sind wellenlos** — die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 sind in ihren Kopfzeilen einzeln beantwortet. Sie füllen **keine** Zeile der
Abdeckungs-Tabelle von [welle-12](../welle-12-erfassungsschicht-emittieren.md): die Zeile
*„Rolle besetzt"* ist mit diesem Slice geliefert, und Sensor-Wartung am Dogfood ist kein
Akzeptanzkriterium von
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren). Die Roadmap
bekommt daher keinen Eintrag
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2).

**Die Welle bekommt keinen Fortschritts-Eintrag.** Der Zustand jedes Slice ist sein
Lifecycle-Verzeichnis; §4 der Welle sagt es, und die Roadmap sagt es noch einmal. Eine
Fortschritts-Zeile wäre eine zweite Fassung derselben Aussage, die driftet, sobald der nächste Move
sie nicht mitnimmt.

**Gates.** Eigener Lauf über dem Baum, den diese Closure hinterlässt — Notiz, Plan-Korrektur und die
zwei geschnittenen Slices eingerechnet: `make gates` **EXIT=0**, `baseline-verify: v3.5.2 OK — 42
Dateien`, `d-check: 393 Datei(en) geprüft, 0 Befund(e)`, golangci-lint `0 issues.`, bats
`grep -c '^ok '` → **153** und `grep -c '^not ok'` → **0**,
`comment-claims: 42 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün; danach sind
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` byte-gleich. Die
Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); jede weitere Zeile an dieser Notiz verschiebt den Stempel, und der Lauf, der ihn wieder
bindet, gehört zu ihr. Die zwei teuren Sensoren stehen oben als **fremdbelegt** — von der
Verifikation über diesem Baum erhoben, nicht von dieser Rolle.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
