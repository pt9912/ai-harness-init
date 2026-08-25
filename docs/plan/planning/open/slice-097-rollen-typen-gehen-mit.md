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
[slice-096](slice-096-traeger-liegt-im-ziel.md) nicht.

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
Feldlisten-Dokument aus [slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md), nicht dieser
Slice.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Die kanonischen Rollen-Typen liegen im Ziel, generisch statt kopiert.** Emittiert wird
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
      Datei-Namen — Richtung: die Verzeichnisse existieren im Ziel, ihre Dateien nicht.
      **Rot:** `make test` — ein Go-Wächter über dem emittierten Typ-Text, der auf jede der fünf
      Klassen prüft; dazu ein `test/mutations/`-Fall mit `# verify: test-go`, der eine davon
      einträgt und das Rot erwartet.
- [ ] **(2) Die Klasse ist `skip-if-present`: ein zweiter Lauf setzt eine vom Adopter geänderte
      Typ-Datei nicht zurück.** Dieselbe Klasse wie die Commands
      ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md) Festlegung 3) — ein Rollen-Typ ist ein Text,
      den der Adopter an sein Repo anpasst.
      **Rot:** `make full-smoke` — der Idempotenz-Lauf ändert eine Typ-Datei und bootstrappt
      erneut; ein Clobber färbt rot. Dazu ein `test/mutations/`-Fall mit `# verify: full-smoke`,
      der die Klasse auf *konvergent* umstellt (der Treiber führt den Modus, `sed -n
      '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE '^[[:space:]]+[a-z*-]+\)'` →
      **7** Arme, mitwandernd).
- [ ] **(3) Die emittierten Typ-Dateien halten das Doku-Gate des Ziels — out-of-the-box, in beiden
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
  [slice-098](slice-098-feldliste-ist-ausdruck-des-traegers.md).
- **Ohne Träger bleibt der Nutzen halb.** Die Typen machen Rollen startbar, aber niemand erfasst
  ihre Läufe, solange [slice-096](slice-096-traeger-liegt-im-ziel.md) nicht liegt. Das ist ein
  **Zwischenstand, kein Widerspruch**: die Typen behaupten nichts über Erfassung, und wer sie liest,
  liest keine Zusage, die nicht gilt.
- **Berührung mit [slice-092](slice-092-traeger-inventur.md), falls jener zuerst liegt.** Seine
  Zelle für Modul 8 §Rollen-Trennung nennt das Präfix `.claude/agents/`, heute leer
  (`grep -rl '".claude/agents/' --include=*.go internal/ | wc -l` → **0**, mitwandernd). Sobald
  dieser Slice die Adresse anlegt, färbt jener Wächter rot — **gewollt**, denn genau dann ist die
  Zelle auf *Träger kommt mit* zu ziehen.

## 7. Closure-Notiz (nach `done/`)

<!--
Wird *nach* Abschluss ergänzt. Inhalt:
- Was hat funktioniert?
- Was ging anders als geplant?
- Steering-Loop-Eintrag: welcher Guide/Sensor sollte verbessert werden?
  (kanonische Definition: [`/kurs/de/grundlagen/klassifikation.md` §Steering Loop](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/klassifikation.md#steering-loop))
- Folge-Slices: welche neuen open/-Einträge?
-->

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/emit/`,
`harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
