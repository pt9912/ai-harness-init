# Code-Review — slice-060 DoD (3), Runde 2 (Auflösung der fünf MEDIUM aus Runde 1)

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 |
| **Datum** | 2026-07-31 |
| **Diff/Commit-Range** | `e59cec4` (+319/−48, vier Dateien, rein dokumentarisch) |
| **Slice-Plan** | [`slice-060`](../plan/planning/done/slice-060-rollen-achse.md) DoD (3) + §6 |
| **`LH-*`** | `LH-QA-03` (Satz *„Der Tool-Build läuft reproduzierbar im gepinnten Image"*) — vom Diff nicht berührt; `LH-QA-02` (Reproduzierbarkeit einer Messangabe) für LOW-2 |
| **Aktive ADRs** | [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) (**Accepted**) Festlegung 1 Punkt 4/5, §Re-Evaluierungs-Trigger |
| **Hard Rules** | [`AGENTS.md`](../../AGENTS.md) §3.4 (ADR immutable), §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel) |
| **Vorherige Findings am gleichen Modul** | [`2026-07-31-slice-060-dod3-review.md`](2026-07-31-slice-060-dod3-review.md) (0 HIGH · 5 MEDIUM · 5 LOW · 1 INFO) — Pflicht-Eingang dieses Laufs · `2026-07-30-slice-060-dod2-adr-0011-architect.md` · `2026-07-30-slice-060-dod2-review.md` + `…-runde-2.md` · `2026-07-30-slice-060-v1-review.md` + `…-runde-2.md` |
| **Regelwerk on-demand** | `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md` (vollständig gelesen), `modul-10-review-harness.md` §Ziel-Form |
| **Gate-Lage des Prüfgegenstands** | unverändert: `harness/conventions.md` und die Plandateien liegen außerhalb von `comment-claims` (vier Pfad-Muster, kein Markdown) und außerhalb dessen, was `d-check` prüft (Links/Anker/IDs, keine Sätze). **Der ganze Diff liegt außerhalb jedes Gates, das Zuschreibungen prüft** — der Commit sagt das selbst. |

**Prüfmethode.** Jede im Diff neu behauptete Fundstelle am Artefakt nachgelesen; jede Zahl mit
Wortgrenzen selbst nachgezählt; jede Vollständigkeitsaussage gegen den vom Text selbst
deklarierten Prüfbereich gemessen; der Span-Bestand selbst ausgewertet (nicht aus einem Report
übernommen); Modul 7 vollständig gelesen, statt die zitierte Stelle isoliert zu prüfen. Kein
`make mutate`-Vollauf (Nutzer-Ausschluss); die Bindung des einen genannten Zahns ist
konstruktiv geprüft (N-5), nicht gefahren.

---

## Bilanz der elf Vorgänger-Befunde

| Befund (Runde 1) | Status | Beleg |
|---|---|---|
| **MEDIUM-1** Trigger zeigt auf entfernten DoD-Punkt | **halb** | Der tote Zeiger ist weg (`harness/conventions.md:1249`), und *„Kein Slice führt diese Bedingung"* ist ausgesprochen (`:1259`) und selbst nachgemessen richtig (N-6). Die **Ersatz-Begründung** trägt nicht: sie zitiert Modul 7 falsch (**M-1**) und benennt einen Träger, der die Sache nicht trägt (**M-2**). |
| **MEDIUM-2** „nur etwas, das den Start verweigert" | **geschlossen** | `:940-948` nimmt die Vollständigkeit ausdrücklich zurück, nennt `updatedInput` und markiert es als **ungemessen**. Beide Fundstellen verbatim geprüft (N-3). |
| **MEDIUM-3** „die einzige Verdrahtungs-Prüfung" | **geschlossen** | `:1195-1204` nennt beide übersehenen Artefakte namentlich, und die Kategorie ist geschärft. Die tragende Aussage habe ich selbst repo-weit nachgemessen und sie hält (N-7). Rest: **L-1**. |
| **MEDIUM-4** „genau einen" / „unbedingt" | **geschlossen** | `:1184-1193` sagt *„höchstens einer"*, benennt `omitempty` + Schranke und schreibt *„Beobachtet ist diese Zeile nicht"*. `slice-068:62-71` trägt jetzt **beide** Ausgänge. Die Selbstbeschränkung (keine eingefrorene Bestandszahl) ist durchgehalten — repo-weit null Treffer (N-2). |
| **MEDIUM-5** Ableitung aus Schlüsselnamen | **geschlossen** | `:998-1018` trennt typisierte Schlüssel von `prompt`/`description`, benennt Letztere als ungemessene Fläche und die Sonde, die es entschiede. Substitution in `slice-060:272-284` protokolliert. Rest: **L-3**. |
| **LOW-1** „bekommt die Rolle und keine Zahl" | **halb** | `:980-985` korrigiert die falsche Hälfte („die Rolle"), führt aber eine als erschöpfend formulierte Zwei-Fall-Aufteilung ein, der der dritte Fall fehlt (**L-2**). |
| **LOW-2** zwei Paarungen derselben 4.184 ms | **geschlossen** | `:872` ordnet jede Paarung ihrem Aufruf zu und sagt ausdrücklich, dass die 4.184 ms nicht hierher gehören. Gegen `slice-060` §3 Zeile 1/3/6 geprüft. |
| **LOW-3** `done/slice-059:95` „vier erklärte Abweichungen" | **offen** | Zeile unverändert. Begründung siehe **I-1**. |
| **LOW-4** „dieselben drei Prüfschritte" | **geschlossen** | `slice-068:90-99` benennt die Nicht-Gleichheit, ordnet (a)/(b)/(c) korrekt zu und nennt den neuen zweiten Schritt. Gegen `git show c53b845:…:64-66` und `conventions.md:1228-1241` selbst nachgezählt (N-12). |
| **LOW-5** „zwei, beide beobachtbar" | **geschlossen** | `:1209-1222`: *„beobachtbar formuliert, aber verschieden belastbar"*, mit beiden Einschränkungen und dem Schlusssatz *„Von selbst feuert damit keiner der beiden"*. |
| **INFO-1** Trigger-Asymmetrie unmarkiert | **geschlossen** | `:1055-1059` markiert sie und verweigert die pauschale Kopfzeile mit Begründung. Der dort genannte Entscheidungs-Ort ist derselbe wie in **M-2** und wird dort behandelt. |

**Keine der elf ist *verschlimmert*.** Zwei sind *halb*: bei beiden hat die Korrektur den
benannten Defekt beseitigt und im selben Satz einen neuen, kleineren derselben Klasse
eingeführt (M-1/M-2 zu MEDIUM-1, L-2 zu LOW-1).

---

## Findings

### M-1 — „Modul 7 verlangt den Folge-Slice für den Fall, dass der Trigger **durch Aufwand** erreichbar ist" steht so nicht in Modul 7, und der dort geregelte Ausgang für den beschriebenen Zustand ist der entgegengesetzte

- **kategorie:** MEDIUM
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`; [`AGENTS.md`](../../AGENTS.md) §3.6; Source Precedence (`AGENTS.md` §1: bei Konflikt gilt die kanonische Quelle)
- **pfad:** `harness/conventions.md:1259-1263`
- **befund:** Der Absatz begründet die Abwesenheit eines Trägers mit einer Bedingung, die Modul 7 an dieser Stelle nicht führt. Modul 7 nennt „Aufwand" **einmal** — in Frage 2 des Werkzeug-Trichters (`modul-07-carveouts.md:63-67`), und zwar als Kriterium für **Carveout gegen ADR**: *Ja (absehbarer Aufwand, sinnvolles Verhältnis zum Nutzen) → Carveout. Nein → permanent, übergeführt in eine ADR.* Das ist genau die Prämisse, die der Text sich zu eigen macht (*„dieser ist es nicht"*) — und ihr Ausgang ist nach Modul 7 die **ADR jetzt**, nicht das Verbleiben als temporäre Abweichung. Die Folge-Slice-Pflicht selbst steht **unbedingt**: `:26-29` (*„Fehlt der Folge-Slice, ist der Carveout de facto permanent — dann gehört er nicht in `carveouts/`, sondern über den Trichter unten in eine ADR"*), `:71` (Carveout = *„mit Folge-Slice **und** ernst erreichbarem Trigger"*), `:129` (*„jeder temporäre Carveout einen Folge-Slice mit ID, der das Auflösen plant. Slice schlägt Memo."*). `:129` steht überdies unter der Überschrift *„Gegen ‚Wenn der Trigger eintritt, lösen wir den Carveout auf'"* mit der Antwort *„Realität: er bleibt liegen"* — das ist wörtlich die Haltung, die der Absatz einnimmt (*„es gibt nichts zu planen, nur etwas zu bemerken"*). Auch das „abwarten"-Argument trifft daneben: der Folge-Slice plant nach `:129` **das Auflösen**, nicht das Warten.
- **verifizierbar:** nein — kein Gate liest Modul 7 gegen `conventions.md`. Bestätigt durch Lesen des vollständigen Moduls (133 Zeilen) gegen den Absatz.
- **Failure-Szenario:** Der Absatz ist die einzige Stelle, die Abweichung 6 ihre Modul-7-Einordnung gibt, und er gibt ihr die falsche. Wer beim welle-09-Closure prüft, ob die Abweichung als „temporär mit Trägerschaft" oder als „permanent → ADR" zu führen ist, findet hier eine Ableitung, die den Trichter genau in dem Punkt umkehrt, in dem er entscheidet — und lässt die Abweichung als temporär stehen, ohne dass jemand die ADR-Frage gestellt hat. Der Absatz nennt zwei Sätze weiter selbst die richtige Regel (`:1265`, korrekt gegen `modul-07-carveouts.md:73`) und wendet sie dann auf ein Zukunfts-Ereignis an (*„Bleibt der Trigger auf absehbare Zeit aus"*), obwohl Modul 7 sie auf die **heutige** Erreichbarkeits-Frage anwendet, die der Text bereits beantwortet hat.
- **Kategorisierung, offengelegt:** HIGH erwogen und verworfen. Die Hard Rules in `AGENTS.md` §3 sind nicht berührt (§3.5 gilt für Gate-Senkungen), und `ADR-0011` Festlegung 1 Punkt 5 verlangt für die Abweichung nur *„begründet dokumentiert"* — das ist geleistet. Der Präzedenzfall derselben Klasse (falsche Zuschreibung an ein normatives Artefakt) wurde in dieser Familie zweimal als MEDIUM geführt.

### M-2 — Der Ersatz-Träger „das Wellen-Closure-Audit, das Modul 7 ohnehin über die temporären Ausnahmen verlangt" hat über diese Abweichung keinen Prüfbereich

- **kategorie:** MEDIUM
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:95-123` (§Carveout-Audit-Slice); [`welle-09`](../plan/planning/welle-09-modul-15-konformitaet.md) §3
- **pfad:** `harness/conventions.md:1266-1268` und, wortgleich in der Sache, `harness/conventions.md:1057-1059`
- **befund:** Beide Stellen benennen das Wellen-Closure-Audit als den Ort, an dem entschieden wird, ob eine Abweichung als dauerhaft gemeint ist. Das von Modul 7 verlangte Audit ist der **Carveout**-Audit-Slice: sein DoD (`modul-07-carveouts.md:105-110`) lautet *„jeder aktive Carveout trägt ein aktuelles `Letzte Prüfung:`-Datum … jeder seit > 2 Wellen ‚aktive' Carveout wird explizit als weiter-gültig bestätigt oder in eine ADR überführt"* — Gegenstand sind Artefakte unter `docs/plan/carveouts/`. Dieses Repo führt dort **eine** Datei (`docs/plan/carveouts/CO-001-bats-shell-lint.md`); die sechs `MR-018`-Abweichungen sind keine Carveouts. Der Closure-Trigger von welle-09 setzt genau diesen Umfang: `welle-09-modul-15-konformitaet.md:108-109` — *„Carveout-Audit (Modul 7): CO-001 geprüft, neue Carveouts dokumentiert oder begründet keine"*. Die gelebte Form bestätigt es: `docs/plan/planning/done/welle-08-results.md:82` schließt mit *„Keine weiteren Carveouts, keine neuen aus dieser Welle."*
- **verifizierbar:** nein — kein Gate prüft, ob ein benannter Entscheidungs-Ort den benannten Gegenstand umfasst.
- **Failure-Szenario:** welle-09 schließt regelkonform, ohne dass die Frage je gestellt wird. Die Matrix-Zelle *Token-Attribution × Repo* wird nach `welle-09-modul-15-konformitaet.md:95` als **deklariert** gebucht — *„bewusste Nicht-Umsetzung als `MR-<NNN>` — Geltungsbereich, Begründung, Auflösungs-Trigger"* —, und ein Auflösungs-Trigger **steht** ja da; die Ausschluss-Regel `:97` (*„eine Entscheidung ohne Trigger ist nach Modul 7 die permanente Ausnahme, die lügt"*) greift nicht. Parallel meldet der Carveout-Audit `CO-001` unverändert und „keine neuen Carveouts". Beide Prüfungen bestehen, keine sieht Abweichung 6 — während `conventions.md:1266` behauptet, hier werde sie entschieden. Das Ergebnis ist die stille Drift in De-facto-Permanenz, gegen die der Audit nach `modul-07-carveouts.md:97-99` überhaupt existiert. Der Satz `:1267-1268` (*„erzwungen wird sie von nichts — kein Gate sieht diesen Absatz"*) ist ehrlich über das **Gate** und verdeckt gerade dadurch, dass auch der genannte **menschliche** Träger den Absatz nicht sieht.
- **Anmerkung zur Klasse:** Das ist dieselbe Zuschreibungs-Klasse wie MEDIUM-1 aus Runde 1 — ein Trigger, dessen benannter Träger die Bedingung nicht führt —, eine Ebene gröber: statt eines entfernten DoD-Punktes jetzt ein Audit mit anderem Geltungsbereich.

### L-1 — „berühren die Verdrahtung einer `settings.json` **drei** Artefakte" — unter dem eigenen Verb sind es im selbst deklarierten Umfang vier

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; Skill-Anker „Spec-Treue-Lücke einer Messmethode"
- **pfad:** `harness/conventions.md:1195-1201`
- **befund:** Der deklarierte Umfang ist *„`test/**`, `Makefile`, `harness/tools/*.sh` und die Go-Tests"*, die Granularität ist der **einzelne Test** (der Text nennt `TestEnforce_SettingsWiresBothHooks`, nicht die Datei). In `internal/emit/enforce_test.go:33-42` fordert `TestEnforce_EmitsAllMechanicFiles` `".claude/settings.json"` in `EnforcePaths()` — ein viertes Artefakt derselben Granularität, das die Verdrahtungs-Datei „berührt", ohne zu prüfen, was sie verdrahtet. Selbst nachgemessen über den deklarierten Umfang (`test/`, `Makefile`, `harness/mk/`, `harness/tools/*.sh`, alle `*_test.go`): mehr als diese vier gibt es nicht.
- **verifizierbar:** ja, teilweise — `make test` führt beide Tests aus; die Aufzählung selbst prüft kein Gate.
- **Failure-Szenario:** Wer die Zeile als Bestandsaufnahme liest, um für die Dogfood-Verdrahtung einen analogen Zahn zu bauen, nimmt drei Vorbilder mit statt vier — konkret das, welches die **Existenz** der Verdrahtungs-Datei sichert (der Teil, der beim Dogfood-Guard zuerst fehlt: `.claude/settings.json` ist hier nicht emittiert, sondern hand-verdrahtet). Der Unterschied zu MEDIUM-3 aus Runde 1 ist die Größenordnung: dort fehlten zwei von drei und die falsche Zahl trug den Satz; hier ist die Zuordnung eine Frage des Verbs.

### L-2 — Die neue Zwei-Fall-Aufteilung zu Bedingung 1 ist als erschöpfend formuliert und lässt den Fall aus, den dieselbe Konvention zwölf Zeilen später für möglich erklärt

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code hält"*)
- **pfad:** `harness/conventions.md:980-985`
- **befund:** Der neue Satz lautet *„Wer nur Bedingung 1 einhält, bekommt keine Zahl — und je nach Typ auch keinen Span: bei einem **Rollen**-Typ verweigert der Guard den Start … bei jedem anderen Typ läuft der Aufruf durch"*, gefolgt von *„trifft damit keinen der beiden Fälle"*. Das ist eine geschlossene Fallunterscheidung, und sie unterstellt den Guard als gegeben. `:996-997` sagt im selben Abschnitt *„er kann fehlen oder abgeschaltet sein"*, und `:1193-1195` sagt, dass **kein Sensor dieses Repos** prüft, dass er verdrahtet ist. Der dritte Fall — Rollen-Typ, Guard fehlt/abgeschaltet — liefert einen Span **ohne** Zähler und **ohne** `agentType`, also einen zählerlosen Lauf unter einem Rollen-Typ. Nebenbefund: „bei jedem anderen Typ" liegt außerhalb der eigenen Prämisse, weil Bedingung 1 (`:958`) den **Rollen**-Typ einschließt.
- **verifizierbar:** ja — ein Lauf mit deaktiviertem Guard-Eintrag in `.claude/settings.json` erzeugt genau diesen Span; er ist nicht gefahren.
- **Failure-Szenario:** Die Abdeckungszahl aus `slice-066` DoD (1) ist genau für diesen Fall gebaut („wie viele `Agent`-Spans überhaupt Zähler trugen"). Wer `:980-985` als Fallgerüst nimmt, schließt zählerlose Rollen-Typ-Spans aus dem Erwartungsraum aus und liest einen realen Treffer als Datenfehler statt als das Signal, für das die Zahl existiert.

### L-3 — `model` steht in einer als Messung gerahmten Aufzählung, ist aber im selben Absatz als reiner Doku-Beleg ausgewiesen

- **kategorie:** LOW
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6; die Belegklassen-Trennung, die derselbe Abschnitt (`:955-974`) als Prinzip führt
- **pfad:** `harness/conventions.md:999-1005`
- **befund:** Der Absatz beginnt *„Gemessen über vier echte Aufrufe"*, nennt die vier gemessenen `tool_input`-Schlüssel, ergänzt *„das dokumentierte Eingabe-Schema … nennt darüber hinaus nur `model`"* — und zieht dann `model` in die Menge, für die *„die Sache entschieden"* ist. `model` ist in **keinem** der vier Aufrufe beobachtet worden; die Quelle ist `docs/user/claude-hooks-referenz.md:1561`, wo es — wie `prompt` und `description` — als *Zeichenkette* typisiert ist. Die im Text tragende Trennung „typisiert gegen Freitext" kommt damit nicht aus der zitierten Tabelle, sondern aus einer Plausibilitäts-Annahme über den Wertebereich. Die Sache selbst ist unstreitig (eine @-Erwähnung landet nicht in `model`); die Belegklasse ist es nicht.
- **verifizierbar:** nein.
- **Failure-Szenario:** Der Abschnitt beruft sich anderswo ausdrücklich darauf, dass er fremde Doku und eigene Messung nie vermischt (`:958-965`). Wer diese Zusage prüft, findet hier eine Stelle, an der ein nie beobachteter Schlüssel unter „gemessen" mitläuft — und muss danach auch die übrigen Belegklassen-Auszeichnungen des Abschnitts einzeln nachprüfen, statt sich auf das erklärte Prinzip stützen zu können.

### L-4 — `MR-018` trägt jetzt die Festlegung, die `slice-068` DoD (2).2 noch zu liefern hat

- **kategorie:** LOW
- **quelle:** Maintainability; der Grund, mit dem derselbe Commit-Vorgänger den slice-068-DoD-Punkt gestrichen hat (*„zweite Wahrheit über denselben Sachverhalt"*, `slice-068:89`)
- **pfad:** `harness/conventions.md:1191-1193` gegen `docs/plan/planning/open/slice-068-rollen-arbeit-laeuft-als-rolle.md:62-71` und `:108-109`
- **befund:** Neu in diesem Diff: *„Wer die Zeile zur Definition einer Abdeckungszahl heranzieht, hängt sie deshalb an die **Zähler** und nicht an ‚irgendein erfasster Wert'."* Das ist inhaltlich die Festlegung aus `slice-068` DoD (2).2 (*„die Definition muss an den Zählern hängen"*), die der Slice in `open/` noch vor sich hat; seine Plan-Tabelle führt dieselbe Schreibung weiterhin als Arbeit (`:108`: *„die Festlegungen aus DoD (2)/(3)"*, `:109`: die Definition in `slice-066` nachziehen). Nichts an `:1191-1193` markiert die Zeile als vorweggenommen.
- **verifizierbar:** nein.
- **Failure-Szenario:** Der slice-068-Implementer findet die Festlegung bereits in `MR-018`, hakt DoD (2).2 als geliefert ab und lässt den zweiten Teil — die Definition in `slice-066` — ungeschrieben; oder er schreibt sie neu und die zwei Formulierungen driften. Beides ist der Ausgang, dessen Vermeidung die Entfallens-Notiz als Grund für den Neuschnitt angibt.

### I-1 — Die Zurückstellung von LOW-3 existiert nur in der Commit-Message; der benannte Empfänger hat keinen Eingang

- **kategorie:** INFO
- **quelle:** dokumentationswürdige, aber undokumentierte Entscheidung; `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md:129` (*„Slice schlägt Memo"*)
- **pfad:** `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md:95` (unverändert)
- **befund:** Die Beleg-Zeile sagt weiter *„vier erklärte Abweichungen"*; `MR-018` führt sechs (`harness/conventions.md:1051`). Die Entscheidung, das nicht zu ändern, und die Weiterreichung (*„eine Lifecycle-Frage und gehört dem Planner"*) stehen ausschließlich in der Commit-Message von `e59cec4`. Kein Plan-Artefakt, keine Konventions-Zeile und kein offener Slice trägt sie; auffindbar bleibt der Sachverhalt nur über den mit-committeten Report von Runde 1. **Die Sach-Begründung trägt zur Hälfte:** *„sechs wäre falsch"* stimmt (slice-059 lieferte vier). *„Ein Datums-Zusatz legte einen neuen alternden Zeiger an"* stimmt nicht — ein datierter Stand hört gerade auf zu altern; das ist der Unterschied, den der Befund von Runde 1 als Auflösungs-Bedingung genannt hatte. Für die Zurückstellung selbst ist das folgenlos, für ihre Begründung nicht.
- **verifizierbar:** nein — `d-check` prüft Links und Anker, keine Zahlen.
- **Failure-Szenario:** Die Lifecycle-Frage („darf eine geschlossene DoD-Beleg-Zeile nachträglich korrigiert werden?") wird nie entschieden, weil sie in keinem Eingang eines Planners liegt; `MR-018` wächst weiter, und die Distanz zwischen `done/slice-059:95` und dem Ist-Stand wächst mit. INFO und nicht LOW, weil der Sachverhalt über den Report im Repo auffindbar bleibt.

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Arithmetik aller Zahlen im Diff, mit Wortgrenzen ausgezählt.** *„höchstens einer"* / *„die acht Werte an `usage`/`total*`/`agentType`"* (`:1185`, `:1188`) gegen die Neun-Werte-Rechnung in `slice-060` §3 (sechs Schlüssel, vier `usage`-Zähler einzeln); *„keinen der acht übrigen Werte"* (`slice-068:63`) gegen `conventions.md:1163-1168`; *„Sechs erklärte Abweichungen"* (`:1051`) gegen die Listenpunkte 1–6; *„vier standen hier seit slice-059, die zwei letzten kamen am 2026-07-31 dazu"* (`:1052-1053`); *„fünf undokumentierte Schlüssel in vier gemessenen Aufrufen"* (`:1253`) gegen `slice-060:259-261`; *„die vier `usage`-Zähler und die drei `total*`-Werte"* (`:1228`). **Keine Zahl im Diff ist falsch**; die einzige Zähl-Frage ist die Verb-Abgrenzung in L-1.
- **N-2 — Die Selbstbeschränkung zur Bestandszahl ist durchgehalten.** Repo-weit über `harness/`, `docs/plan/` gesucht: **null** Vorkommen von „14 von 14"/„14/14"/„13 von 13"/„15 von 15" in einem lebenden Artefakt (die vier Treffer liegen in `done/slice-025`, in drei Review-Reports und betreffen `make mutate` bzw. `span-check`). Weder `MR-018` noch `slice-068` friert eine Rechnung über den Span-Bestand ein — konsistent mit der Regel, die `MR-018:871` (Feldtabelle `total_tokens`) für sich selbst aufgestellt hat.
- **N-3 — Die `updatedInput`-Fundstellen existieren verbatim.** `docs/user/claude-hooks-referenz.md:894` — *„`PreToolUse`: `updatedInput` direkt unter `hookSpecificOutput` ersetzt die Argumente eines Tools, bevor es ausgeführt wird"* — und `:1617` in der PreToolUse-Entscheidungskontroll-Tabelle: *„Ändert die Tool-Eingabeparameter vor der Ausführung … Kombinieren Sie mit `\"allow\"`, um automatisch zu genehmigen"*. Beides deckt exakt, was `conventions.md:941-944` ihnen zuschreibt, samt der Kennzeichnung „nicht gemessen".
- **N-4 — Der `Agent`-Eingabe-Schema-Abgleich hält.** `claude-hooks-referenz.md:1556-1561` führt `prompt`, `description`, `subagent_type`, `model`; die Differenz zur gemessenen Schlüsselmenge ist genau `{model}` (`conventions.md:1001-1002`). Der Text behauptet weiterhin **nicht**, `run_in_background` sei für `Agent` dokumentiert.
- **N-5 — `test/mutations/32` bindet die genannte Zusage wirklich.** `# expect:` nennt `TestEnforce_SettingsWiresBothHooks`; die Mutation (`test/mutations/32-enforce-settings-wires-guard.sh:11`) ersetzt `pretooluse-command-guard.sh` in `internal/emit/templates/enforce/settings.json` — genau den String, den `internal/emit/enforce_test.go:91` in seiner `want`-Liste führt. Kein anderer Sensor fängt die Mutation ab: `harness/tools/smoke.sh:85` greppt nur `PreToolUse` (bleibt stehen), `TestEnforce_EmitsAllMechanicFiles` prüft Pfade statt Inhalt. Der Treiber führt Fälle über `bash "$case_file"` (`harness/tools/mutate.sh:301`), der Dateimodus ist also unerheblich (32 ist ohnehin 755). Selbst **nicht** gefahren (Nutzer-Ausschluss) — die Bindung ist konstruktiv geprüft, nicht rot gesehen; das Rot-Sehen ist Sache der Verifikation.
- **N-6 — „Kein Slice führt diese Bedingung" selbst nachgemessen.** Über `open/`, `next/`, `in-progress/`, `welle-09-*`, `roadmap.md`: die einzigen Treffer auf Haupt-Kontext-Token sind die Entfallens-Notiz (`slice-068:84`) und eine Risiko-Zeile ohne DoD-Charakter (`slice-066:155`). Die Aussage `conventions.md:1259` hält.
- **N-7 — Die tragende Aussage von MEDIUM-3 hält, repo-weit gemessen.** Über alle `*.go`, `*.sh`, `*.bats`, `Makefile`, `*.mk`, `*.awk` außerhalb der Baseline referenzieren `.claude/settings.json` nur: `harness/tools/smoke.sh:76,85`, `internal/emit/enforce.go:46` (Emit, keine Prüfung), `internal/emit/enforce_test.go:37,88`. **Kein** Artefakt prüft die Verdrahtung **dieses** Repos. Die Ebenen-Trennung Dogfood/emittiert ist in `:1201-1203` ausdrücklich gezogen.
- **N-8 — Der `Bash`-Guard-Vergleich trägt.** `conventions.md:1014-1016` schreibt dem bestehenden Guard zu, er lese die volle Kommandozeile ohne sie zu protokollieren: `.claude/hooks/pretooluse-command-guard.sh:32` zieht das Feld über `harness/tools/extract-command.awk`, und die Datei enthält keine Log-Senke (kein `>>`, kein `tee`). Zuschreibung korrekt.
- **N-9 — ADR- und Regelwerk-Zitate.** *„wirkt nur, wenn ihn jemand liest"* = `docs/plan/adr/0011-telemetrie-erfassung-policy.md:353-354` verbatim; *„nicht gepinnt"*/*„von keinem Gate geprüft"* = `:351-353`; die §Werkzeug-Wahl-Zuschreibung in `conventions.md:1265` = `modul-07-carveouts.md:73` korrekt; `ADR-0011` Festlegung 1 Punkt 4 (*„leer und als leer erkennbar"*) = `:87`. Kein fabriziertes Zitat und keine kondensierte Wiedergabe — die einzige nicht tragende Norm-Aussage ist die in M-1 behandelte, und sie ist **kein** Zitat, sondern eine Paraphrase.
- **N-10 — `AGENTS.md` §3.4 gewahrt.** `git show --stat e59cec4` listet keine Datei unter `docs/plan/adr/`; `ADR-0011` ist unberührt.
- **N-11 — Span-Bestand selbst ausgewertet, nicht übernommen.** `.harness/state/spans/` (54 Dateien, 1.854 Zeilen): **36** `Agent`-Spans. Davon tragen **15** `model_version` **und** `input_tokens` **und** `spawned_role`; die übrigen **21** tragen keinen dieser Werte. Der Schnitt ist sauber und liegt am Landen der Positiv-Liste: der letzte zählerlose `Agent`-Span steht auf `2026-07-30T07:05:02Z`, der erste zähler-tragende auf `2026-07-30T07:39:37Z`. Es existiert **kein** `Agent`-Span, an dem die Zeile `:1184-1188` beobachtbar wäre — die Selbstauskunft *„Beobachtet ist diese Zeile nicht"* ist am Bestand bestätigt.
- **N-12 — Der Migrations-Vergleich in `slice-068:90-99` selbst nachgezählt.** Gegen `git show c53b845:docs/plan/planning/open/slice-068-…md:64-66` ((a)/(b)/(c) wörtlich wie zitiert) und gegen `conventions.md:1228-1241` (Schritt 1 = (a); Schritt 2 neu, mit `ADR-0011` Festlegung 1 Punkt 4; Schritt 3 = (b)+(c)). Die Zuordnung stimmt in jedem Glied.
- **N-13 — Links und Anker des Diffs.** Neu oder berührt: `../docs/plan/adr/0011-telemetrie-erfassung-policy.md` (aus `harness/`), `../../adr/0011-telemetrie-erfassung-policy.md` (aus `open/`), `../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung` (aus `in-progress/` und `open/`), `../in-progress/slice-060-rollen-achse.md`. Alle Ziele und der Anker existieren.
- **N-14 — Die `make mutate`-Vertagung trägt.** Über alle **134** `# files:`-Köpfe in `test/mutations/` ausgewertet: die einzige `.md` in einem solchen Kopf ist `internal/emit/templates/commands/implement-slice.md`. Keine der vier geänderten Dateien ist Mutations-Ziel; das Ergebnis kann sich durch diesen Diff konstruktiv nicht ändern.
- **N-15 — Dogfood gegen emittiert.** Der Diff trifft keine Aussage über die emittierte Ebene; die einzige Stelle, an der beide Ebenen vorkommen (`:1195-1204`), benennt die Ebene jedes einzelnen der drei Artefakte ausdrücklich und zieht die Grenze in die richtige Richtung (*„für die Verdrahtung dieses Repos prüft keines etwas"*). Die Frage der Emission der Rollen-Typen bleibt korrekt an `slice-062` adressiert.
- **N-16 — Die Steering-Loop-Klasse aus Runde 1 ist nicht wiederholt.** Von den drei Instanzen „Vollständigkeitsaussage im Register einer Messung" (MEDIUM-2/3/5) ist keine im neuen Text erneut aufgetreten: `:940` nimmt die Vollständigkeit ausdrücklich zurück, `:1195-1201` zählt auf statt zu behaupten, `:1002-1011` teilt den Grund. Die verbleibenden Reste (L-1, L-2, L-3) sind engere Fälle derselben Familie, keine Neuauflagen.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | **0** | — |
| **MEDIUM** | **2** | M-1, M-2 |
| **LOW** | **4** | L-1, L-2, L-3, L-4 |
| **INFO** | **1** | I-1 |
| **Negativbefunde** | **16** | N-1 … N-16 |

**Zur Eskalations-Regel des Skills.** Die Klasse aus Runde 1 („Vollständigkeitsaussage, deren
Prüfbereich enger ist als ihr Satz") tritt in Runde 2 nur noch in LOW-Stärke auf (L-1, L-2, L-3) —
das ist eine Verbesserung, kein neuer Steering-Loop. Die **blockierende** Klasse hat gewechselt:
M-1 und M-2 sind beide *Zuschreibung an ein normatives Artefakt, das die zugeschriebene Wirkung
nicht hat* — dieselbe Klasse, die in dieser Familie zuvor als „Rot-Nachweis mit einem Artefakt,
das es nicht gibt" und als „Trigger zeigt auf einen entfernten DoD-Punkt" aufgetreten ist. Das
ist die **dritte** Instanz und damit ein Steering-Loop-Signal: für Zuschreibungen an
Regelwerk-Module und an Prozess-Schritte gibt es in diesem Repo keinen Sensor —
`comment-claims` deckt kein Markdown, `d-check` prüft Links und keine Sätze, und `slice-070`
weitet zwar den Prüfbereich, prüft aber weiterhin die *Existenz* des genannten Sensors und nicht
die *Wahrheit* des Satzes.

---

## Verdikt

**NICHT KONFORM.**

Zwei MEDIUM blockieren nach Skill (*„HIGH und MEDIUM blockieren typischerweise"*). Der Commit
löst vier der fünf blockierenden Befunde aus Runde 1 sauber und belegt auf (MEDIUM-2/3/4/5), hält
die Arithmetik durchgehend (N-1), hält die eigene Regel gegen eingefrorene Bestandszahlen durch
(N-2) und erfindet keine Fundstelle (N-9). Er scheitert an der Reparatur von MEDIUM-1: der tote
Zeiger ist entfernt, aber die an seine Stelle getretene Begründung kehrt den Modul-7-Trichter in
dem Punkt um, in dem er entscheidet (M-1), und benennt als Entscheidungs-Ort ein Audit, dessen
Geltungsbereich diese Abweichung nicht umfasst (M-2). `ADR-0011` Festlegung 1 Punkt 5 ist damit
erfüllt (*begründet dokumentiert*), Modul 7 nicht — und die Differenz zwischen beidem ist genau
das, was am welle-09-Closure hängt.
