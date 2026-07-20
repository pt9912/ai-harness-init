# Slice slice-026: Mutations-Sensor für Hard Rule 3.6 (`make mutate`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung) — wie slice-015…021. Einordnung
*(Kontext, nicht normativ)*: [roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-20.

---

## 1. Ziel

> **Herkunft: eine Hard Rule mit nur einem Quadranten.** [`AGENTS.md`](../../../../AGENTS.md) §3.6
> („keine Zusage ohne rot gesehenes Gegenbeispiel") entstand am 2026-07-20 aus neun
> Instanzen derselben Befund-Klasse in zwei Slices. Sie hat **kein computational
> feedback** — anders als 3.1–3.5, die je an einem Gate hängen. Modul 9 ist dazu
> eindeutig: *„Jede Hard Rule liegt in zwei Quadranten … Hard Rule nur in einem
> Quadranten ist halb durchgesetzt"* und *„Erst mit Fitness Function ist sie
> durchgesetzt. **Beides ist Pflicht.**"* Der Beleg kam prompt: **N-1** des
> 022b-Re-Reviews ist eine Instanz der Klasse, entstanden **nach** dem Formulieren
> von 3.6 und von `make gates` (EXIT=0) nicht bemerkt.

`make mutate` als **Nicht-Gate-Sensor**: ein kuratiertes Set aus *(Mutation →
erwartet rot färbender Test)*. Jede Mutation wird angewandt, `make test` gefahren,
ein **roter** Lauf erwartet und die Quelle zurückgesetzt. Färbt eine Mutation
**nicht** rot, hat der zugehörige Wächter seine Zähne verloren — und `make mutate`
schlägt an. Dazu der fehlende Feedforward-Haken in der Pre-completion-Checkliste.

## 2. Definition of Done

- [x] `make mutate` existiert und fährt den Startbestand — je mit **namentlich** erwartetem rot färbendem Test. *(Gewachsen auf **neun** Fälle: die sechs Proben der 022a/022b-Sitzung — Pin-Kopplung, Sortier-Achse, Symlink-Achse, `inScope`, Fixture-Drift, **Escape-Vorbedingung**; dazu 07/08 für `checkRoot` und den smoke-Wächter sowie 09 für den Treiber selbst. Der ursprünglich als 6. genannte „tote Leer-Guard" **kann** nicht Fall sein — in slice-022b als unerreichbar entfernt, eine Mutation an nicht existierendem Code ist unmöglich; die Escape-Vorbedingung ist die echte Sonde an seiner Stelle.)*
- [x] **Der Sensor hat selbst Zähne** (Selbstanwendung von §3.6): eine Mutation, die den erwarteten Test **nicht** rot färbt, lässt `make mutate` rot werden — rot gesehen, nicht behauptet. Das ist der Kern: der Sensor misst die **Abwesenheit** von Rot, und genau das ist die Stelle, an der er selbst still grün werden könnte.
- [x] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): `make mutate` ist **nicht** in `make gates` (jede Mutation kostet einen vollen Docker-`test`-Zyklus) und steht als **Nicht-Gate-Verify** in [`AGENTS.md`](../../../../AGENTS.md) §4 und [`harness/README.md`](../../../../harness/README.md) §Sensors — dieselbe Zeile wie `make smoke`. Kein behaupteter Gate.
- [x] **Die Grenze ist dokumentiert, nicht überdehnt:** der Sensor prüft die **Haltbarkeit** vorhandener Zähne, nicht die **Entstehung** neuer. Er fängt „ein Wächter hat Zähne verloren", nicht „eine neue Zusage wurde ohne Zähne geschrieben". Wer das nicht hinschreibt, begeht §3.6 am Sensor selbst.
- [x] **Feedforward-Hälfte:** `.claude/commands/implement-slice.md` bekommt einen neuen **Schritt 19**, der zu jedem neuen/geänderten Wächter die rot färbende Mutation verlangt (Schritt 18 verlangt bis dahin nur den grünen Gate-Lauf) — die Lücke aus Befund N-6. *(Ursprünglich als „Schritt 18 erweitern" formuliert; als eigener Schritt 19 geliefert, damit die Fehl-Semantik „keine Antwort ist ein Befund" nicht die Gate-Beleg-Pflicht verwässert.)*
- [x] [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): bash + coreutils, kein neues Werkzeug; die Mutationen laufen über die vorhandenen `make`-Targets.
- [x] **Mitgenommen aus dem 022b-Re-Review:** N-3 (der `emit.Templates`-Aufruf in `run()` ist von keinem Test beobachtet) und N-4 (`checkRoot` hängt an *einem* hart verdrahteten Dateinamen) — beide berühren dieselbe Fläche.
- [x] `make gates` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` <!-- d-check:ignore (geplanter Pfad, Doc führt Code) --> | neu | Treiber: Quelle beiseite → Mutation → `make test` → **rot erwarten** → zurücksetzen. Fail-closed: ein grüner Lauf ist der Befund |
| `test/mutations/` | neu | Das kuratierte Set als Daten (Mutation + erwarteter Test), nicht als Code — damit ein neuer Wächter eine Zeile kostet, keine Funktion |
| `Makefile` | update | `mutate`-Target, **nicht** in `gates` |
| [`AGENTS.md`](../../../../AGENTS.md), [`harness/README.md`](../../../../harness/README.md) | update | Nicht-Gate-Verify-Zeile neben `make smoke`; §3.6 bekommt den Verweis auf ihr Feedback |
| `.claude/commands/implement-slice.md` | update | Schritt-18-Haken (Feedforward-Hälfte von N-6) |
| `cmd/ai-harness-init`, `internal/emit` | update | N-3 (Test auf die `run()`-Verdrahtung) und N-4 (robusterer Wurzel-Anker) |

**Nachgeführt 2026-07-20.** Beim Berichten der Restrisiken gemessen: es gibt **keine CI**, und
`make mutate` stand in **keinem** Closure-Trigger — ein Sensor ohne Auslöser. Damit hätte der
Slice §3.6 einen zweiten Quadranten gegeben, der nie feuert. Zwei Nachträge:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `welle-02`/`welle-03` §3 | update | `make mutate` als Closure-Kriterium — dieselbe mechanische Verankerung, die `make smoke` schon hatte. Ohne sie ist das Target dokumentiert und unaufgerufen |
| `harness/tools/smoke.sh` | update | N-3: die Template-Schicht wird jetzt beobachtet (Tier 2 ist die einzige Stelle, an der die volle Kette real läuft) |

**Nachgeführt 2026-07-20 (aus der Review-Runde).** Zwei Findings verlangten mehr als eine
Korrektur — sie erweiterten den Liefergegenstand:

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | **F-1**: Bedingung 4 zählt nur noch Fehlschlag-Zeilen (`bats` druckt Testnamen auch beim Bestehen — der Vergleich war für bats-Fälle wirkungslos). **F-6**: Grün-Vorlauf je Sensor. **F-5**: `# verify:`-Kopfzeile, damit ein Fall gegen `make smoke` statt `make test` laufen kann |
| `test/mutations/07`, `08` | neu | **F-5**: der in diesem Slice geänderte Wächter `checkRoot` und der Tier-2-Wächter aus `smoke.sh` bekommen ihre Mutation. Ohne sie wäre „Wächter hat Zähne" für genau die Wächter unbelegt, die dieser Slice anfasst |
| `.claude/commands/implement-slice.md` | update | **Modul-11-Lücke** (Verifikations-Befund): Schritt 18 verlangt jetzt die Nicht-Gate-Sensoren, die den Slice betreffen. Modul 11 verankert `verify:`-Sensoren dort — ein Sensor, der erst zur Wellen-Closure feuert, ist pro Slice keiner |

## 4. Trigger

slice-022b in `done/`. Als Harness-Wartung hängt der Slice an keiner Welle —
die Roadmap sequenziert ihn (Modul 6: sie ist die Sequenzierungs-Autorität).

**Er sollte vor den verbleibenden welle-02-Slices landen** (025, 023, 004b). Nicht
weil er sie technisch blockiert, sondern weil die Befund-Klasse in **jedem** Slice
dieses Zuges auftrat: je früher der Sensor steht, desto mehr fängt er. Das ist eine
Empfehlung mit Begründung, keine Abhängigkeit — er wird nicht Mitglied von welle-02,
deren Ziel der Distributions-Umbau ist.

Rückführungen: `in-progress → next`, wenn Treiber und Mutations-Set nicht in eine
Sitzung passen (dann den Treiber mit **einer** Mutation, das Set als Folge-Slice).
`in-progress → open`, wenn sich zeigt, dass die Mutationen nicht stabil
anwendbar sind (dann ist die Datenform falsch gewählt — s. §6).

## 5. Closure-Trigger

DoD vollständig + Review konform + Closure-Notiz → nach `done/`. Damit ist
[`AGENTS.md`](../../../../AGENTS.md) §3.6 zweiquadrantig.

## 6. Risiken und offene Punkte

- **Der Sensor kann selbst still grün werden** — und das ist das Kernrisiko, weil er
  die *Abwesenheit* von Rot misst. Bricht der Treiber (Mutation greift nicht mehr,
  Patch veraltet, `make test` scheitert aus anderem Grund), sieht „kein Rot" wie
  „Zähne intakt" aus. Er muss **fail-closed** sein: greift eine Mutation nicht
  nachweisbar, ist das ein Befund, kein Übersprung. Ohne diese Setzung baut der
  Slice genau das, wogegen er gerichtet ist.
- **Mutationen sind Patches und veralten.** Wandert der mutierte Code, greift die
  Mutation ins Leere. Darum als **Daten** mit benanntem Ziel-Symbol statt als
  Zeilennummern-Patch — und der vorige Punkt macht das Veralten sichtbar.
- **Kuratiert heißt unvollständig.** Das Set deckt die Invarianten ab, die jemand
  aufgeschrieben hat. Ein neuer Wächter ohne Mutation ist unbewacht. Das ist
  akzeptiert (3.1s Gate deckt auch nur die *behaupteten* Targets), gehört aber in
  die Doku statt in die stille Annahme.
- **Laufzeit:** jede Mutation ist ein voller Docker-`test`-Zyklus. Sechs Proben sind
  vertretbar, sechzig nicht. Wächst das Set, ist die Tier-Frage neu zu stellen.
- **Selbstbezug beim Review:** dieser Slice wird von denselben Rollen geprüft, deren
  Befunde ihn ausgelöst haben. Der Reviewer sollte den Sensor gegen sich selbst
  wenden — eine Mutation am Treiber, die unbemerkt bliebe, wäre der aussagekräftigste
  Befund.

## 7. Closure-Notiz (nach `done/`)

**Geliefert.** `make mutate` ist der computational-feedback-Quadrant zu
[`AGENTS.md`](../../../../AGENTS.md) §3.6: `harness/tools/mutate.sh` fährt neun kuratierte
Fälle (`test/mutations/`), jeder eine *(Mutation → erwartet rot färbender Wächter)*-Paarung,
fail-closed über vier Bedingungen. Der Sensor deckt beide `make test`- **und**
`make smoke`-Wächter (`# verify:`-Kopf) und **sich selbst** (`test/mutate-driver.bats` +
Fall 09). Verankert als Closure-Kriterium in welle-02/03 und als Schritt-19-Pflicht in der
Pre-completion-Checkliste — damit ist §3.6 zweiquadrantig, was Modul 9 verlangt.

**Was anders lief — und der eigentliche Lerneintrag.** Der Slice brauchte **drei
Review-Runden**. Das ist nicht der Steering-Punkt; die Runden konvergierten sauber (blockierende
Befunde **2/4 → 0/2 → 0/0**, vom dritten Reviewer an der Rate belegt, nicht am Gefühl). Der
Steering-Punkt ist, **wodurch** sie konvergierten.

### Steering-Loop-Eintrag — geschärfte Regel (Meta-Ebene)

Die Befund-Klasse dieses ganzen Zuges — *„ein Wächter besteht, weil seine Fixture zufällig
passt"* — trat **fünfmal** auf (022a N2 → 022b F-1 → 026 F-2 → F-3 → N-1), zuletzt zweimal in
Reparaturen, die genau diese Klasse schließen sollten. Solange ich sie **strukturell**
anging (`checkRoot`: „Template an der Wurzel", dann „an der Wurzel und tiefer"), erzeugte jeder
Fix eine neue Instanz. Erst der Wechsel der **Frage** hielt: von *„welche Form hat die
Wurzel"* (beantwortbar durch eine zufällig passende Fixture) zu *„welcher Satz liegt hier"*
(`rootMarkers`, Identität). §3.6 sagt „rot gesehen"; die Schärfung ist: **wenn dieselbe Klasse
den Fix überlebt, ist nicht der Fix zu schwach, sondern die Frage falsch.** Ein zweiter
strukturell gleicher Versuch ist ein Signal, keine Iteration.

Zweite, konkretere Hälfte: der Wendepunkt war, **den Sensor gegen sich selbst zu wenden**
(§6 hatte es verlangt). `mutate.sh` fing beim Bau einen eigenen Fehler (`tar -d` verglich
Metadaten, Bedingung 2 feuerte nie), beim Umbau einen veralteten Fall (07 mutierte gelöschten
Code → Bedingung 2), und seine Treiber-Tests fingen den Top-Level-Lock, der beim Sourcen
mitlief. **Drei Fehler von Werkzeugen statt von Reviewern gefangen** — das ist der Beleg, dass
der zweite Quadrant trägt, am Sensor, der ihn baut.

### Was diese Closure NICHT behauptet

- **Durchsetzungs-Hälfte von N-6 offen:** Schritt 19 verlangt die Sensoren, aber **kein Gate
  erzwingt** ihren Lauf — der Stop-Hook deckt nur `make gates`. Träger ist
  [slice-027](../in-progress/slice-027-ci.md) (CI); dort ausdrücklich als DoD-Punkt.
- **NR-1** (stale Lock nach SIGKILL blockiert bis manuellem `rmdir`) und **NR-2** (die neuen
  `run_case`-Zweige jenseits `failure_form` sind nicht selbst-bewacht) sind **bewusste
  Grenzen**, am Code benannt — fail-closed bzw. die schon deklarierte „kuratiert =
  unvollständig"-Grenze.
- **N-8**: `checkRoot`s Rename-Toleranz bekommt keinen eigenen Mutations-Fall, weil die
  2-von-3-Schwelle eine Ein-Marker-Mutation per Konstruktion wirkungslos macht und
  `TestCheckRoot_EinRenameGenuegtNicht` sie direkt prüft. Begründung am Code.

### Folge-Slices

- [slice-027](../in-progress/slice-027-ci.md) — trägt die Durchsetzungs-Hälfte (N-6) und die
  [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Restlücke „frischer Klon".
- Kein neuer Slice aus diesem hier — die offenen Punkte haben Träger oder sind begründete Grenzen.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example);
`harness/tools/` ist im Adaptions-Block als GF geführt.
