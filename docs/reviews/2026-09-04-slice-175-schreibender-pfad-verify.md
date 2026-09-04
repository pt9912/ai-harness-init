# Verifikation — slice-175, schreibender Pfad von `archive-welle` und Ablösung des Shell-Helfers

| Feld | Wert |
|---|---|
| **Rolle** | Verifier (Modul 8/11) — frischer Kontext, getrennt von Implementation, Review und Planung |
| **Frage** | „Bauen wir es richtig?" — gegen Plan (§2 DoD, §5 Closure-Trigger) und ADR-0033. **Nicht** Plan-vs.-Diff auf Maintainability-Ebene (das ist Reviewer) und **nicht** gegen realen Bedarf (das ist Validator) |
| **Gegenstand** | `docs/plan/planning/in-progress/slice-175-archive-welle-schreibender-pfad.md`, Code-Stand HEAD `007fdc7`, letzter Implementer-Commit `987d520` |
| **Eingang** | DoD-Bestätigung + Sensor-Belege aus der Commit-Message von `987d520` und den sieben Review-Runden `docs/reviews/2026-09-04-slice-175-schreibender-pfad-review{,-runde-{2..7}}.md` |
| **Bindende ADRs** | [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) (**Proposed** — Prüfmaßstab laut Plan, Acceptance-Trigger nicht Gegenstand dieser Verifikation), [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md), [ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md), [ADR-0003](../plan/adr/0003-go-native-binaries.md) |
| **Anforderungen** | [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| **Modell** | Claude Sonnet 5 |
| **Kontext frisch** | ja — kein Befund aus den sieben Review-Reports unbesehen übernommen; jede Zahl unten ist in dieser Sitzung selbst erhoben, das Kommando steht beim Befund |

---

## 1. Ist der Sensor gelaufen?

- **`make gates`** — selbst gefahren in dieser Sitzung (nicht nur der Zustands-Beleg gelesen):
  EXIT 0, `comment-claims: 55 Datei(en) geprueft, 0 Befund(e)`, `test-go` acht Pakete `ok`,
  `span-check` grün. Danach `bash harness/tools/working-tree-hash.sh` gegen
  `.harness/state/gates-passed.diffsha`: **identisch**
  (`85025010880def5a6711f07af8691c934bfe3a65f2f6c602ee4a30e7f24eb10b`), `git status --porcelain`
  leer. Der Stop-Hook-Zustand deckt den aktuellen Baum, nicht nur den Commit — der Hash ist
  inhaltsbasiert.
- **`make mutate`** — **nicht** erneut gefahren, wie vom Auftrag vorgegeben. Beleg dafür ist
  `git diff 987d520 HEAD --stat -- internal/archive/ cmd/ai-harness-init/`, selbst ausgeführt:
  **leer**. Sieben Folge-Commits (Modell-Wahl-Umstellung, ADR-0035, slice-180-Planung) berühren
  keinen der beiden Pfade. Der in `987d520`s Commit-Message berichtete Lauf — `247 ok, 0
  Befund(e)`, EXIT 0, Vollständigkeit 247 von 247 — deckt damit weiterhin den vollständigen
  aktuellen Code-Stand dieser Pfade. Gegengeprüft: `ls test/mutations/*.sh | wc -l` → **247**,
  stimmt mit der berichteten Vollständigkeits-Zahl überein.
- **Die sieben Review-Runden** sind gelaufen (sieben Report-Dateien, jede mit eigenem
  Kontext-Header „kein Beleg aus dem Implementer-Bericht übernommen" und eigenen, selbst
  gefahrenen Sonden/Mutations-Läufen). Kein Sensor fehlt, der laut Plan oder AGENTS.md hier
  laufen müsste.

## 2. Deckt der Sensor die Zusage? — Sieben Runden, Finding für Finding

Jede Runde blockierte auf mindestens einem HIGH oder MEDIUM; jede Folgerunde prüfte die Behebung
mit **eigenen** Sonden (nicht dem Wortlaut des Fixes vertraut) und fand entweder Bestätigung oder
eine neue, jeweils schmalere Lücke in derselben Familie:

| Runde | Blockierend | Nächste Runde bestätigt Fix? |
|---|---|---|
| 1 | HIGH-1 (`--vorschau`-Guard ungetestet), MEDIUM-1 (`FormOK`-Verdrahtung ungewächtert), MEDIUM-2 (Vorlagen-Wächter sieht 8/10 Platzhalter) | Runde 2: alle drei „nicht dem Wortlaut nach, sondern unter der schärferen Mutation als der gelisteten" bestätigt |
| 2 | HIGH-1 (Strecke vor dem Guard-Parameter unbewacht) | Runde 3: Seam `archiveWelleMit`/`laufEingang` gebaut, Strecke selbst nachgemessen, Vorschau-Schalter auf drei Stufen rot |
| 3 | HIGH-1 (`echterEingang()`-Verdrahtung ungetestet) | Runde 4: `archive_welle_echt_test.go` gegen ein echtes Scratch-Repo, beide benannten Sonden (a)/(b) selbst reproduziert und rot |
| 4 | HIGH-1 (Bedien-Einstieg `Makefile:322` ungekoppelt — Exit 0 statt Sperre) | Runde 5: Kopplung `test/unterkommando-kopplung.bats` gebaut, echter Bedien-Einstieg zweimal gefahren, beide Male fail-closed |
| 5 | MEDIUM-1 (Kalibrierung zählt falsche Größe), MEDIUM-2 (Reichweite reicht nicht bis zum Hook-Kanal) | Runde 6: beide mit fünf eigenen Sonden (A–D, F) nachgeprüft, `make mutate` selbst gefahren: 244 ok |
| 6 | MEDIUM-1 (Namens-Muster sieht 8 von 10 gültigen Zeichenklassen nicht) | Runde 7: vier eigene Sonden (A–D) plus Weißlisten-Gegenprobe (E), `make mutate` selbst gefahren: 246 ok |
| 7 | MEDIUM-1 (`test/mutations/256` misst nach der Runde-6-Reparatur die eigene Kalibrierung statt die Dispatch-Schleife — Kopf sagt in drei Sätzen das Gegenteil), LOW-1 (Entscheidungs-Grep unverankert, Diagnose-Grep zeilenverankert — dieselbe Prüfung, zwei Strengen) | **kein Runde-8-Report** — Behebung ist `987d520`, der letzte Implementer-Commit |

**Commit `987d520` gegen Runde 7 nachgeprüft (diese Sitzung, per Diff-Lektüre, nicht per eigenem
Mutations-Lauf — Begründung s. u.):**

- `test/mutations/256`: die angehängte zweite Trägernennung steht jetzt in
  `\"$(NOTFALL)\"` statt `$(NOTFALL)` — eine Form, aus der das Wort-Ende-Muster (Leerzeichen,
  doppeltes Anführungszeichen, Backtick) tatsächlich nichts zieht, weil das Anführungszeichen
  direkt dahinter das Wortende markiert. Der Fall-Kopf wurde neu geschrieben und behauptet jetzt
  genau die vier Betriebszustände (Vorkommen-Zählung + neue Fassung → Kalibrierung rot;
  Zeilen-Zählung + neue Fassung → grün; beide Zählungen + alte Fassung → rot), die Runde 7 als
  Diskrepanz benannt hatte — die neue Kopf-Aussage deckt sich mit Runde 7s eigenen Sonden J2/L1/L2.
- `test/unterkommando-kopplung.bats`: die Entscheidung (`grep -qF "case \"$n\":" "$MAIN"`, Runde 7
  LOW-1) ist ersetzt durch einen Vergleich gegen eine vorab extrahierte **Menge** von
  Zeilenanfang-`case`-Marken (`dispatch_muster='^[[:space:]]*case "[^"]*":'`), und Entscheidung wie
  Diagnose lesen jetzt dasselbe Muster aus einer Variablen — genau die von Runde 7 verlangte
  Vereinheitlichung. Der neue Fall `test/mutations/261-dispatch-marke-nur-im-kommentar.sh` legt eine
  `case`-Marke in eine Kommentarzeile und benennt im Kopf, dass eine reine Vorkommen-Prüfung hier
  grün bliebe.
- Beide Änderungen sind **zielgenau** auf die zwei in Runde 7 benannten Zeilen geschnitten (kein
  Nebenschauplatz), und die berichtete Sensor-Zahl (247 statt 246 Fälle) passt zur neuen Datei.

**Warum kein eigener Mutations-Lauf gegen `987d520`:** Der Auftrag dieser Sitzung schließt einen
erneuten `make mutate`-Lauf ausdrücklich aus (der Pfad-Diff seit `987d520` ist leer, s.o.); ein
isolierter Lauf nur des einen Falls ist mit dem vorhandenen Treiber nicht vorgesehen
(`harness/tools/mutate.sh` kennt keinen Einzelfall-Filter). Die Diff-Lektüre oben ist damit
**Ersatz für eine Reviewer-Bestätigung, nicht deren Äquivalent** — s. offener Punkt unten.

**Negativ-Befund, selbst geprüft:** Runde 1 LOW-1 (zwei widersprüchliche Sätze in
`harness/README.md` über die Ausnahme-Menge der Verweis-Vorprüfung) ist behoben — beide Zeilen
79 und 89 sagen heute übereinstimmend „ausgenommen allein `.git` und `.harness/baseline/**`"
(`grep -n "nimmt allein\|ausgenommen allein" harness/README.md`, selbst gefahren).

## 3. Sagt der Plan, was der Code tut? — Plan-vs-Code

| DoD-Punkt (§2) | Status | Beleg |
|---|---|---|
| `archive-welle <welle>` führt Move+Commit1, Zip, Verweis-Nachzug, Staging, Commit2 | **erfüllt** | `internal/archive/anwenden.go`, gedeckt von `TestAnwendenTrenntMoveVonInhalt` u.a., cross-geprüft über sieben Review-Runden |
| Beide Stub-Arten aus vendored Vorlage, Abbruch ohne Vorlage | **erfüllt** | `internal/archive/stub.go` (`AusVorlage`), Negativbefund Runde 1 („kein Befund"), unverändert seither |
| `make archive-welle` fährt den Träger, ist der einzige | **erfüllt** | `Makefile:321-322`; `harness/tools/archive-welle.sh` und `test/archive-welle.bats` **entfernt** (selbst geprüft, `ls` → „nicht gefunden“); vierter Bild-Pin weg (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **3**, selbst gefahren); alle sieben migrierten Mutations-Fälle einzeln zugeordnet (Negativbefund Runde 1), 24 archive-bezogene Fälle im Bestand heute (`grep -l archive test/mutations/*.sh \| wc -l`, selbst gefahren) |
| `make gates` grün | **erfüllt** | s. §1 oben, selbst gefahren |
| Doku-Update `harness/README.md` | **erfüllt** | Zeile 79/85/89/91, Träger-Beschreibung, Grenzen, Sensoren — Runde 4-7 wiederholt gegen den Text gehalten |
| Closure-Notiz mit Lerneintrag | **offen** | §7 der Plan-Datei ist noch die unausgefüllte Vorlage |
| Beobachtungs-Register fortgeschrieben | **offen** | s. unten |
| Jedes Risiko aus §6 mit Ausgang | **offen** | alle vier Risiken tragen noch den Platzhalter `<eingetreten: … \| entfallen: … \| weiter offen: …>` |
| Drei Paarungen getragen | **offen** | hängt an den drei Punkten oben |

**Kein Diff-Überschuss gefunden:** Der Code-Stand deckt sich mit §3 (Plan) — `internal/archive/`,
`cmd/ai-harness-init/archive_welle.go`, `Makefile`, die Entfernung des Shell-Helfers,
`test/mutations/`, `harness/README.md`. Nichts davon Ungeplantes ist im Diff seit dem
Trigger-Commit (slice-173 in `done/`) entstanden — insbesondere ist `test/unterkommando-kopplung.bats`
zwar nicht namentlich in §3 gelistet, fällt aber unter „`test/mutations/` — die sieben Fälle
wandern mit oder werden einzeln benannt" in seiner erweiterten Rolle als Träger der
Bedien-Einstieg-Kopplung (Runde 4/5-Fund, in derselben Sub-Area `harness/tools/`/`*`).

## 4. Was noch fehlt, bevor `done/` möglich ist

Vier Punkte sind **Planungsartefakte**, keine Code-Mängel — sie liegen nach der Rollen-Sequenz
(Modul 8) beim **Planner**, nicht bei der Implementation, und sind nach `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln Vorbedingung für den `git mv` nach `done/`:

1. **DoD-Checkboxen, §6 Risiko-Ausgänge, §7 Closure-Notiz** — alle noch Vorlage/unhakt (Vergleich
   mit dem bereits geschlossenen `docs/plan/planning/done/slice-173-archive-welle-als-unterkommando.md`,
   dessen acht DoD-Punkte alle `[x]` tragen).
2. **`BEO-025` überschreitet mit diesem Slice die 3×-Schwelle.** Register-Stand heute **2×**
   (Belege `slice-170`, `slice-173`, selbst gelesen in `docs/plan/planning/observations.md:73`).
   Round 1s Kategorie-Summary zählt in diesem Slice vier weitere Instanzen derselben Klasse
   (HIGH-1, MEDIUM-1, MEDIUM-2, LOW-1— alle in Runde 2/3 behoben, zählen als **eine** Gelegenheit
   nach der „ein Vorgang zählt einmal"-Regel). Der Lese-Schritt (`modul-05` §Zwei Schritte, hier
   ohne Wellen-Betrieb Teil der **nächsten** Slice-Planung oder — sauberer — dieser Closure) muss
   der Zeile einen Ausgang zuweisen: verkörpert oder Folge-Slice mit Kennung.
3. **Drei Registerzeilen (`BEO-025`, `BEO-026`) tragen eine Präsens-Aussage über
   `harness/tools/archive-welle.sh`**, eine Datei, die dieser Diff entfernt hat — selbst geprüft:
   `grep -n "archive-welle\.sh" docs/plan/planning/observations.md` trifft Zeile 73 und 74. `BEO-026`
   nennt zusätzlich „seine Ablösung liegt bei slice-175" (Präsens-Verweis auf einen Slice, der mit
   dieser Closure gerade abschließt) — beides ist exakt die von Round 1 MEDIUM-4 benannte Klasse
   (`BEO-009`) und wird durch diesen Diff wahr bzw. unwahr gemacht, ohne dass die Zellen es
   nachziehen.
4. **`.claude/commands/close-welle.md` Schritt 4 nennt `archive-welle` weiterhin nicht**
   (`grep -c 'archive-welle' .claude/commands/close-welle.md` → **0**, selbst gefahren) — Round 1
   MEDIUM-5, korrekt nicht von der Implementation angefasst (ADR-0028 Festlegung 1: Planner-Artefakt),
   aber ADR-0033 Festlegung 2 („ein Träger, eine Beschreibung") ist ohne diese Änderung nicht
   vollständig eingelöst. Braucht eine Planner-Aktion oder einen benannten Folge-Slice.

Keiner der vier Punkte ist ein Code- oder Test-Mangel; alle vier sind exakt dort offen, wo der
Reviewer sie in Runde 1 als „blockiert die Closure, nicht den Code" eingeordnet hatte.

## 5. Ein offener Prozess-Punkt (kein Code-Befund)

Runde 7 endete **blockierend** und ohne Freigabe für die Verifikation. Commit `987d520` behebt —
nach eigener Diff-Lektüre in dieser Sitzung — beide dort benannten Findings zielgenau, aber es
existiert **kein Runde-8-Review-Report**, der das mit eigenen, unabhängig gefahrenen Sonden
bestätigt (die Praxis, die alle sieben vorherigen Übergänge getragen hat). Die
Implementer→Verifier-Übergabe (Modul 8) setzt „nach Review-Schluss" voraus; ein Review-Schluss im
Sinne einer **nicht-blockierenden** Runde liegt für den finalen Stand nicht vor. Diese
Verifikation ersetzt das nicht — meine Prüfung in §2 ist Diff-Lektüre mit Cross-Check gegen die im
Commit genannten Vor-/Nachher-Zustände, keine unabhängig gefahrene Mutation. Empfehlung an den
Planner: entweder eine kurze Runde-8-Bestätigung nachziehen (ein frischer Reviewer-Kontext, eng auf
`987d520` begrenzt) oder diesen Verify-Bericht ausdrücklich als das Übergabe-Artefakt behandeln, das
die Lücke schließt — beides ist eine Entscheidung des Planners, nicht dieser Rolle.

---

## Verdikt

**Code-Ebene: DoD und ADR-0033 sind eingelöst.** Alle drei zentralen DoD-Punkte (Operation,
Stub-aus-Vorlage, alleiniger Träger) sind im Code verankert und über sieben Review-Runden mit
eigens gefahrenen Sonden gehalten; kein HIGH und kein blockierendes MEDIUM steht offen. `make
gates` ist in dieser Sitzung selbst gefahren und grün (EXIT 0, Hash-Deckung bestätigt), die
Mutations-Deckung ist über den leeren Pfad-Diff seit `987d520` weiterhin durch dessen `247 ok, 0
Befund(e)` belegt.

**Planungs-Ebene: Closure ist noch nicht möglich.** DoD-Checkboxen, §6-Risiko-Ausgänge und die
§7-Closure-Notiz sind unausgefüllt; das Beobachtungs-Register braucht einen Lese-Schritt für
`BEO-025` (2× → 3× mit diesem Slice) und eine Korrektur an zwei Zellen (`BEO-025`, `BEO-026`), die
einen jetzt entfernten Pfad im Präsens beschreiben; `.claude/commands/close-welle.md` nennt den
neuen Träger weiterhin nicht (Planner-Artefakt, ADR-0028).

**Closure NICHT freigegeben.** Nicht wegen eines Code- oder Test-Mangels, sondern weil die in
`modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln verlangten Planungsartefakte
(Punkte 1–4 in §4 oben) fehlen — das ist Planner-Arbeit nach dieser Verifikation, nicht vor ihr.
Zusätzlich: der letzte Implementer-Commit hat keine eigene Reviewer-Bestätigung (§5) — eine knappe
Runde 8 oder eine ausdrückliche Entscheidung, diesen Bericht als deren Ersatz zu werten, sollte vor
dem `git mv` nach `done/` stehen.
