# Review-Report: ADR-0011 (Proposed, **Runde 4**) — Telemetrie-Erfassung, Policy für Agenten-Spans — 2026-07-28

**Review-Art:** **Proposed-Review einer ADR, vierte Runde** — geprüft wird die **dritte
Überarbeitung** einer noch nicht angenommenen Entscheidung ([`AGENTS.md`](../../AGENTS.md) §3.4
greift erst ab *Accepted*). Kein Produktiv-Diff. **Nicht** geprüft: Code, DoD-Abhakung (Modul 11,
getrennter Kontext, anderes Prüf-Artefakt).

**Leitfrage dieser Runde — zweigeteilt.** (1) *Was hat die vierte Fassung neu eingebaut?* Die
Eingriffe sind diesmal: Konstruktion am **Emitter** statt an der Ereignis-Wahl · **abgeleitete**
Argument-Werte statt Allowlist · **Bedrohungsmodell** benannt · „Ableiten schlägt deklarieren" ·
Folgenummer-**Vergabezeitpunkt** mit benannter Restlücke · Aufräumen ohne fremde Sitzungen ·
**Eigenschafts**-Kriterium statt Werkzeug-Aufzählung. (2) *Konvergiert das — ist noch etwas
blockierend?* **Ergebnis vorab:** die Entscheidung selbst ist so tragfähig wie nie; was blockiert,
sind **drei Defekte der Überarbeitung selbst** — ein Beleg, der seinen Wächter nicht hat, ein beim
Ersetzen stehen gebliebener Absatz, und ein neues Kernstück ohne Zahn. Keiner davon verlangt, eine
Entscheidung neu zu treffen.

**Gegenstand:** [`docs/plan/adr/0011-telemetrie-erfassung-policy.md`](../plan/adr/0011-telemetrie-erfassung-policy.md)
(Status **Proposed**, 371 Zeilen), im Kontext von
[`docs/plan/planning/welle-09-modul-15-konformitaet.md`](../plan/planning/welle-09-modul-15-konformitaet.md)
und `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` <!-- d-check:ignore (Lifecycle-Pfad: die Slice-Datei wandert durch open/next/in-progress/done) -->
sowie [`docs/plan/adr/README.md`](../plan/adr/README.md).

**Diff:** `git show 7ccec13` — sechs Dateien, 819+/57−: die ADR (164 Zeilen), welle-09 (18 Zeilen),
der Runde-3-Report als neue Datei (690 Zeilen) und drei Report-Bereinigungen à 1 Zeile.
**Gemessen** (`git show 7ccec13 --stat`): **weder** `spec/lastenheft.md` **noch**
`.claude/settings.json` **noch** `docs/plan/adr/README.md` **noch**
`docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` sind berührt. Die letzten beiden
Nicht-Berührungen tragen eigene Befunde (R4-12, R4-13).

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ 1.4.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Regelwerk (Baseline v3.5.2, vendored, Index zuerst): `modul-04-architektur-adrs.md`
  §Ziel-Form: ADR (Wortlaut gelesen, inkl. *„Eine ADR ohne Fitness Function ist eine
  Absichtserklärung"*), `modul-15-observability.md` **vollständig** gelesen (§Span-/Audit-Attribut-Regeln,
  §Token-Attributions-Regeln, §Cache-Counter-Regeln), `grundlagen-klassifikation.md`
- Ziel-Form-Vorlage: `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`
  (Block-Reihenfolge gegen die ADR abgeglichen)
- Spec: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) — **verbatim** gelesen, nicht
  aus der ADR oder den Vorrunden übernommen
- Aktive ADRs auf Kollision geprüft: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md)
- Adaptionen: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.4 und §3.6
- **Vorherige Findings am gleichen Modul:** [Runde 1](2026-07-28-adr-0011-proposed-review.md)
  (2 HIGH / 6 MEDIUM / 3 LOW), [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md)
  (3 HIGH / 7 MEDIUM / 3 LOW / 2 INFO), [Runde 3](2026-07-28-adr-0011-proposed-review-runde-3.md)
  (1 HIGH / 4 MEDIUM / 6 LOW / 1 INFO), dazu der vorgelagerte
  [welle-09-Plan-Review](2026-07-28-welle-09-plan-review.md)
- **Eigene Messungen dieser Sitzung** (nichts aus der ADR oder aus den Vorrunden übernommen):
  `make docs-check` → **d-check 232 Dateien / 0 Befunde**; `.claude/settings.json` gelesen (zwei
  Hooks: `PreToolUse`/`Bash` → Guard, **`Stop` ohne Matcher** → `stop-require-gates.sh`);
  `.claude/hooks/stop-require-gates.sh` gelesen (`{"decision":"block"}`/`{"decision":"approve"}`
  auf **stdout** bei Exit 0, `set -euo pipefail` in `:12`); `grep -n "set -" .claude/hooks/*.sh
  harness/tools/*.sh` → **alle 16 Host-Skripte und beide Hooks** fahren `set -euo pipefail`;
  `test/mutations/` durchgezählt (**102** Fälle) und **jeden** Fall mit `files: harness/tools/mutate.sh`
  gelesen (acht Stück); `.gitignore` und `.dockerignore` gelesen; `Dockerfile` (vier `COPY . .`);
  `grep -rn "cp -r\|tar -c\|rsync"` über `harness/tools/`, `Makefile`, `*.mk`, `.github/workflows/`;
  `ls .harness/state/` → Verzeichnis **0775**, Stempeldatei **0664**; **alle 63** Slice-Dateien auf
  ihren `**Bezug:**`-Block hin ausgewertet; `docs/plan/planning/in-progress/` gelistet;
  **die Hook-Doku (<https://code.claude.com/docs/de/hooks>) am 2026-07-28 gezielt abgerufen** — zur
  Exit-Code-Semantik je Ereignis, zum Timeout-Verhalten, zur **Antwort-Aggregation** und zu
  `session_id`/`agent_id` bei Subagenten

---

## Findings

### R4-1 — Der neue Beleg des Bedrohungsmodells nennt einen Wächter, den es nicht gibt: **kein** Mutations-Fall bewacht den Zustands-Ausschluss in `mutate.sh`

- `kategorie`: **HIGH** (halluzinierter Sensor —
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse eine
  Ebene tiefer, [`AGENTS.md`](../../AGENTS.md) §3.6)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„erst fertig, wenn benannt ist, was passieren
  müsste, damit sie bricht, und das einmal rot gesehen wurde"*) ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  `modul-04-architektur-adrs.md` §Kernidee
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:116-118`
- `befund`: Der neu eingebaute Absatz belegt das Bedrohungsmodell mit drei Messungen und schließt:
  *„die einzige Stelle, die den Baum kopiert (`harness/tools/mutate.sh`), schließt den
  Zustands-Bereich ausdrücklich aus, und **ein Mutations-Fall bewacht genau diese Ausnahme**."*
  Die ersten beiden Hälften habe ich nachgemessen und bestätigt (s. Negativbefunde); die dritte ist
  **falsch**. Gemessen: `grep -rln "harness/state" test/mutations/` liefert **zwei** Dateien.
  [`test/mutations/31-enforce-gitignore-selbstblockade.sh`](../../test/mutations/31-enforce-gitignore-selbstblockade.sh)
  mutiert das **emittierte** `.harness/.gitignore`-Template (`sed -i 's#^state/#build/#'`) — ein
  anderer Gegenstand. [`test/mutations/74-mutate-kopie-ohne-git.sh`](../../test/mutations/74-mutate-kopie-ohne-git.sh)
  fasst zwar die tar-Zeile an, **lässt den Zustands-Ausschluss aber unverändert** und fügt ihm einen
  zweiten hinzu: `sed -i 's|tar -cf - --exclude=./.harness/state|tar -cf - --exclude=./.git
  --exclude=./.harness/state|'`; seine `# expect:`-Zeile lautet *„die Kopie traegt den
  Sensor-Bedarf inklusive .git"*. Der Fall bewacht, dass `.git` **mitkopiert** wird (actionlint
  braucht eine git-Wurzel) — **nicht**, dass `.harness/state` ausgeschlossen bleibt. Auch die
  übrigen sieben Fälle mit `files: harness/tools/mutate.sh` (72, 73, 75, 76, 77, 97, 09) betreffen
  Isolationspfad, Fingerprint, Abbruchverhalten und Sensorwahl. **Keiner** entfernt
  `--exclude=./.harness/state`.
  Failure-Szenario: ein späterer Slice braucht in der isolierten Kopie einen Zustand (etwa einen
  vorgewärmten Stempel) und streicht den Ausschluss, oder ein Refactoring der tar-Zeile verliert
  ihn. `make mutate` bleibt **grün** — kein gelisteter Wächter deckt die Eigenschaft, also meldet
  auch der Zahnlos-Report nichts. Ab dann liegt bei jedem Mutations-Lauf eine Kopie der Span-Datei
  mit Pfaden und Kommando-Tokens in einem Temp-Verzeichnis **außerhalb** des Repos (nach
  `mutate.sh:147` rund 8 MB Baum-Kopie), also außerhalb genau der Vertrauensgrenze, auf die das
  Bedrohungsmodell seine Erlaubnis *„im Repo dürfen Pfade und Kommando-Tokens roh stehen"* stützt —
  und die ADR hat dem Leser gesagt, ein Sensor passe darauf auf. Nach *Accepted* ist der Satz nach
  [`AGENTS.md`](../../AGENTS.md) §3.4 nicht mehr korrigierbar.
- `verifizierbar`: ja, ohne Umsetzung —
  `grep -rn "exclude=./.harness/state" test/mutations/` (ein Treffer, und er **fügt hinzu**, statt
  zu entfernen) und `for f in $(grep -l mutate.sh test/mutations/*.sh); do sed -n 2,3p $f; done`.
  Kein Gate deckt es: `make docs-check` prüft Links/Anker/IDs, nicht ob ein behaupteter
  Mutations-Fall die behauptete Eigenschaft trifft.

### R4-2 — Festlegung 1 führt **zwei** Regeln „4.", die sich über `requirement.id` direkt widersprechen: die ersetzte Fassung ist beim Ersetzen stehen geblieben

- `kategorie`: **HIGH** (Basis MEDIUM; eine Stufe, weil der Widerspruch im ausdrücklich als
  **bindend** bezeichneten Teil steht und nach [`AGENTS.md`](../../AGENTS.md) §3.4 ab *Accepted*
  nicht mehr korrigierbar ist)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 · `modul-04-architektur-adrs.md` §Ziel-Form
  (*„Ein ADR ist die einzige Stelle, an der ‚weil' gegen ‚ist halt so' gewinnt"*) ·
  `modul-15-observability.md` §Audit-Span-Schema (*„jede Abweichung davon begründest du"*)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:95-98` gegen `:82-89`
- `befund`: Der Diff fügt in die Liste „Die Policy selbst ist bindend" eine neue Regel 4 ein
  (*„**Ableiten schlägt deklarieren** … `requirement.id` aus der `**Bezug:**`-Zeile der
  Slice-Datei (gemessen: jeder Slice führt seine `LH-*`-IDs maschinenlesbar) … Offen ist heute
  **genau ein Feld**: der Cache-Status"*) und dazu den Absatz „Warum diese Reihenfolge" — **löscht
  aber die alte Regel 4 nicht**. Sie steht unverändert vier Zeilen darunter, ebenfalls als „4."
  nummeriert: *„Ein nicht erschließbares Pflicht-Feld wird begründet dokumentiert, nicht
  weggelassen. **Betrifft absehbar `requirement.id` (steht nur im Slice-Plan)** und den
  Cache-Status."* Die beiden Regeln sagen über dasselbe Feld das Gegenteil: die neue erklärt
  `requirement.id` für **abgeleitet und damit erledigt**, die alte führt es als **nicht
  erschließbar** und schickt es auf den Abweichungs-Pfad; die neue zählt **ein** offenes Feld, die
  alte **zwei**. Auch die `Geschichte`-Zeile (`:368`) und die Commit-Message behaupten, die
  Abweichung sei entfallen — der Text, der sie erklärt, steht noch da.
  Failure-Szenario: der Implementer von slice-059 liest Festlegung 1, findet zwei Regeln „4." und
  folgt der zweiten — sie ist die konkretere, sie nennt sein Feld beim Namen, und sein eigener
  Slice-Plan sagt in Frage G dasselbe (`slice-059:125`: *„Für `requirement.id` ist der Slice-Plan
  die einzige Quelle … eine **begründete Abweichung** nach Modul 15"*). Er dokumentiert die
  Abweichung statt abzuleiten und tut damit genau das, was der Absatz „Warum diese Reihenfolge"
  (`:91-94`) als *„billiger zu schreiben als eine Lösung und deshalb verdächtig"* verwirft. Der
  `MR-<NNN>`-Eintrag aus Folgepflicht 2 führt dann eine Abweichung, die die ADR im selben Abschnitt
  für aufgelöst erklärt — und ab *Accepted* ist keine der beiden Regeln mehr streichbar.
- `verifizierbar`: ja, am Artefakt — `grep -n "^4\." docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → **zwei** Treffer (`:82`, `:95`). Kein Gate deckt es (`docs-check` prüft keine
  Listen-Nummerierung und keine Widerspruchsfreiheit).

### R4-3 — Die beiden Setzungen, auf denen die Trennung nach Runde 4 **allein** ruht, haben keine Fitness Function; die einzige Zeile, die Exit-Code und stdout berührt, prüft den Aufrufer und setzt einen Zustand voraus, den Setzung 2 für unmöglich erklärt

- `kategorie`: **HIGH** (Basis MEDIUM — fehlender Sensor für einen neuen bindenden Vertrag; eine
  Stufe nach §Kontext-Eskalation des Reviewer-Skills: die Eigenschaft schützt den
  Entscheidungs-Kanal, auf dem der Gate-Nachweis aus
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  sitzt)
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form (*„Jede Entscheidung mit Architektur-Wirkung
  bekommt eine Fitness Function — sonst ist sie Absichtserklärung"*) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 · ADR-0011 Folgepflicht 4 (`:308-309`, die eigene Präzedenz:
  *„ohne ihn wäre auch diese Folgepflicht nur eine Absicht"*)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:237-249` gegen `:313-320`
- `befund`: Runde 4 **entfernt** die alte Setzung 1 (die Ereignis-Meidung) ersatzlos und stellt die
  gesamte Trennung auf zwei Emitter-Eigenschaften: *„Der Emitter gibt auf stdout nichts aus"* und
  *„Sein Exit-Code ist hart auf 0 geklemmt"*. Der Text nennt sie *„beide prüfbar"* und schreibt den
  Testfall wörtlich hin: *„Und sie ist testbar: ein absichtlich fehlschlagender Emitter muss Exit 0
  liefern und stdout leer lassen"* (`:249`). In der Fitness-Function-Tabelle steht dieser Fall
  **nicht**. Die sechs Zeilen decken Pflicht-Feld, Allowlist-Feld, Ablageort, unterschlagenen Span,
  `0600` — und als sechste eine Zeile über den **Aufrufer**: *„ein Emitter mit **Exit ≠ 0** und
  einer, der auf stdout schreibt, verändern das Ergebnis des aufrufenden Skripts nicht"* (`:320`).
  Diese Zeile stammt aus Runde 3 und ist gegenüber der neuen Entscheidung doppelt schief: sie misst
  eine andere Eigenschaft (Robustheit des Aufrufers statt Klemme des Emitters), und ihr Prüfling
  ist ein Emitter mit Exit ≠ 0 — genau der Zustand, den Setzung 2 für konstruktiv ausgeschlossen
  erklärt. Damit hat die tragende Zusage dieser Runde keinen Zahn, obwohl sie hermetisch in bats
  messbar wäre; und dieselbe ADR hat für Folgepflicht 4 einen Mutations-Fall eingezogen, gerade
  weil sie sonst *„nur eine Absicht"* wäre.
  **Warum das nicht formal ist — der Leckpfad ist konkret und hausgemacht.** „Hart geklemmt" nennt
  keinen Mechanismus. Gemessen in diesem Repo: **alle 16 Host-Skripte und beide Hooks** beginnen
  mit `set -euo pipefail` (u. a. `.claude/hooks/stop-require-gates.sh:12`,
  `harness/tools/mutate.sh:65`). Unter `set -e` bricht ein Skript **vor** einem abschließenden
  `exit 0` ab und gibt den Status des gescheiterten Kommandos weiter; die ADR selbst hat gemessen,
  dass `awk` — von Festlegung 4 ausdrücklich erlaubt — bei fatalem Fehler mit **2** endet. An der
  Quelle am 2026-07-28 nachgeschlagen: Exit 2 ist der einzige blockierende Code, und für `Stop`
  heißt er *„Prevents Claude from stopping, continues the conversation"*, für `SubagentStop`
  *„Prevents the subagent from stopping"*. Da Runde 4 die Ereignis-Beschränkung gestrichen hat, ist
  eine Registrierung auf `Stop` — neben dem fail-closed `stop-require-gates.sh` — von der ADR jetzt
  **erlaubt**. Failure-Szenario: slice-059 registriert den Emitter für den Wurzel-Span auf `Stop`,
  schreibt ihn im Hausstil (`set -euo pipefail`, `awk`-Extraktion, `exit 0` am Ende); eine unlesbare
  Payload oder ein volles Dateisystem lässt `awk` fatal enden, das Skript bricht mit **2** ab, das
  abschließende `exit 0` läuft nie — und der fail-**open** gemeinte Telemetrie-Hook hindert die
  Sitzung am Beenden. Kein Sensor der ADR bemerkt das, weil keiner die Klemme misst.
  Der Nebeneffekt gehört dazu: dieselbe Lücke gilt für Setzung 1. Ein Emitter, der auf stdout
  nichts ausgeben **soll**, ist eine Regel; einer, der mit `exec >/dev/null` startet, ist eine
  Konstruktion. Die ADR beansprucht in `:247-248` das Zweite (*„dass der Emitter auf diesem Kanal
  gar nicht erst sprechen **kann**"*) und formuliert das Erste — und jeder Kindprozess des Emitters
  erbt dessen stdout (ein `tee -a` statt `>>`, ein vergessenes `echo`, ein bares `git rev-parse`
  genügt).
- `verifizierbar`: ja, in beiden Hälften ohne Umsetzung — Volltextsuche nach einer FF-Zeile zu
  Klemme/stdout des Emitters in `docs/plan/adr/0011-telemetrie-erfassung-policy.md:313-320` → kein
  Treffer; `printf 'set -euo pipefail\nawk "BEGIN{nonexistent()}"\nexit 0\n' > /tmp/x.sh; bash
  /tmp/x.sh; echo $?` → **2**; Exit-2-Tabelle je Ereignis unter <https://code.claude.com/docs/de/hooks>.
  Kein Gate deckt es (`docs-check` läuft netzlos und prüft keine FF-Vollständigkeit).

### R4-4 — Eine als „gemessen" geführte Prämisse der Festlegung 6 ist an der von der ADR selbst benannten Quelle widerlegt: die Antwort-Aggregation **ist** dokumentiert

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*„Falsch: ‚Byte-Gleichheit belegt `make smoke`',
  ohne `smoke` gelesen zu haben"*) · ADR-0011 §Kontext (*„an der Werkzeug-Doku gemessen"*) ·
  ADR-0011 §Re-Evaluierungs-Trigger 1
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:222-224`
- `befund`: Der Absatz führt drei Belege ein und leitet sie mit *„Der Grund ist **gemessen**, nicht
  vermutet"* ein. Der erste lautet: *„Hooks desselben Ereignisses laufen **parallel**, und ihre
  Ausgabe ist bei Exit 0 ein **Entscheidungs-Kanal**; wie das Werkzeug widersprüchliche Antworten
  aggregiert, ist **nicht dokumentiert**."* Die Parallelität stimmt (verbatim an der Quelle:
  *„All matching hooks are executed in parallel"*). Der zweite Halbsatz stimmt nicht: dieselbe
  Seite führt am 2026-07-28 einen Abschnitt zur **Response Aggregation** mit vier Regeln —
  `decision: "block"` → *„If **any** hook returns `block`, the action is blocked (logical OR)"*;
  `permissionDecision` → *„`deny` > `ask` > `defer` > `allow` (most restrictive wins)"*;
  `additionalContext` → alle nicht-leeren Werte werden gesammelt; `continue: false` → *„If **any**
  hook returns this, processing stops"*. Die Aussage ist damit eine unbelegte Negativbehauptung
  über eine Quelle, die die ADR im selben Satz als gemessen ausgibt. Inhaltlich ändert die
  richtige Regel die **Richtung** nicht (unter logischem OR blockt ein versehentliches
  `{"decision":"block"}` des Telemetrie-Hooks weiterhin), aber sie ändert die **Schärfe**: ein
  `approve` des Gate-Enforcers lässt sich vom Telemetrie-Hook nicht in ein `block` verdrehen, und
  die Unbestimmtheit, die der Absatz als Risiko-Verstärker führt, existiert nicht.
  Failure-Szenario: slice-059 nimmt die ADR beim Wort, hält die Aggregation für undefiniert und
  verzichtet darauf, das reale Verhalten zweier paralleler Hooks auf `Stop` zu messen — die
  Messung, die die ADR ihm ausdrücklich überlässt (`:320`). Der Slice belegt dann eine Eigenschaft
  gegen ein Modell, das die Quelle nicht hergibt; nach *Accepted* steht die falsche Prämisse
  unkorrigierbar in einer Rang-3-Quelle.
- `verifizierbar`: ja — erneuter Abruf von <https://code.claude.com/docs/de/hooks>, Abschnitt
  *Response Aggregation*, gegen `docs/plan/adr/0011-telemetrie-erfassung-policy.md:223-224`. Kein
  Gate deckt es (`docs-check` läuft `--network none`).

### R4-5 — „Ableiten schlägt deklarieren" trägt für `slice.id` heute gar nicht und für `requirement.id` nicht **eindeutig**: das Lifecycle-Verzeichnis ist leer, und ein Slice führt bis zu vier `LH-*`-IDs

- `kategorie`: **MEDIUM**
- `quelle`: `modul-15-observability.md` §Audit-Span-Schema (*„Pflicht-Minimum: Slice-ID,
  Agent-Rolle, Cache-Status, `requirement.id`"* — **ein** `requirement.id`, Singular) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 · ADR-0011 Festlegung 1.1 (beide Listen gelten)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:82-89`
- `befund`: Die neue Regel setzt zwei Ableitungen als tragend: *„`slice.id` kommt aus dem
  Lifecycle-Verzeichnis, `requirement.id` aus der `**Bezug:**`-Zeile der Slice-Datei"*. Beide habe
  ich am Bestand geprüft. (a) **`slice.id`:** `ls docs/plan/planning/in-progress/` liefert am
  2026-07-28 **genau eine Datei — `roadmap.md`**; kein Slice. Die von slice-059 §Messung C dafür
  vorgesehene Quelle (`ls docs/plan/planning/in-progress/slice-*.md`, `slice-059:121`) trifft
  nichts. Der Zustand ist nicht die Ausnahme, sondern der Normalfall für jede Sitzung, die **nicht**
  implementiert: Review-, Verifikations- und Planungs-Sitzungen laufen ohne Slice in
  `in-progress/` — und dieses Repo führt sie ausdrücklich in getrenntem, frischem Kontext, also als
  eigene Sitzungen mit eigenem Span-Bestand. (b) **`requirement.id`:** die Existenz-Aussage stimmt —
  ich habe **alle 63** Slice-Dateien ausgewertet, jede führt mindestens eine `LH-*`-ID in ihrem
  `**Bezug:**`-Block (Messung s. Negativbefunde) —, die **Eindeutigkeit** nicht:
  `slice-048-release-artefakte.md:11` führt vier (`LH-QA-04`, `LH-QA-03`, `LH-QA-02`, `LH-QA-01`),
  `slice-046` ebenfalls vier. Modul 15 verlangt **ein** `requirement.id` je Span; die Ableitung
  liefert eine Menge. Die ADR entscheidet weder, welche gewinnt, noch dass das Feld eine Liste wird.
  Failure-Szenario: slice-059 baut den Emitter, wie die ADR es verlangt, statt eine Abweichung zu
  deklarieren. Während der Umsetzung liegt slice-059 selbst in `in-progress/` und alles ist gut;
  sobald der Slice nach `done/` wandert und die nächste Review-Sitzung Spans schreibt, tragen alle
  Spans ein leeres `slice.id` und damit auch kein `requirement.id` — bei zwei Pflicht-Feldern des
  Minimums, ohne dass irgendwo eine begründete Abweichung stünde, weil die ADR das Feld für gelöst
  erklärt hat. slice-060 summiert anschließend eine Token-Bilanz über einen Bestand, in dem die
  teuersten Sitzungen (Reviews mit Subagenten) keine Zuordnung tragen — genau die
  Rekonstruktion-statt-Messung, mit der die ADR Alternative D verwirft.
- `verifizierbar`: ja — `ls docs/plan/planning/in-progress/` → nur `roadmap.md`;
  `grep -c "LH-" docs/plan/planning/done/slice-048-release-artefakte.md` bzw. der Bezug-Block
  dieser Datei. Kein Gate deckt es.

### R4-6 — Die Redaktions-Tabelle kennt drei Werkzeug-Klassen und keinen Default; der Satz „kein Byte fremden Inhalts" ist über alle Werkzeuge quantifiziert, und das `Task`-Werkzeug fällt in keine Zeile

- `kategorie`: **MEDIUM**
- `quelle`: `modul-15-observability.md` §Span-/Audit-Attribut-Regeln (`tool.arguments.redacted` →
  *„was wurde wohin geschrieben — ohne Secrets im Log?"*) ·
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 (*„die Zusage auf das einschränken, was der Code hält"*)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:104-111`
- `befund`: Die Tabelle deckt *Schreib-Werkzeuge*, *Kommando-Werkzeug* und *Lese-Werkzeuge* ab und
  schließt mit einer Aussage über **alles**: *„Damit wandert **kein Byte fremden Inhalts** ins Log:
  Massen-Abfluss über die Telemetrie ist konstruktiv ausgeschlossen, nicht per Regel verboten."*
  Die Quantifizierung reicht weiter als die Tabelle. Der Kontext derselben ADR betont, dass *„ein
  leerer Matcher **alle** Tools"* trifft und dass die Rollen-Achse gerade an den **Subagenten**
  hängt (`agent_id`/`agent_type`) — das dafür zuständige Werkzeug ist das Agenten-/`Task`-Werkzeug,
  dessen Argument ein **Freitext-Prompt** ist. Es ist weder Schreib- noch Kommando- noch
  Lese-Werkzeug; die Tabelle sagt für es nichts, und der Prompt eines Review-Subagenten enthält in
  diesem Repo regelmäßig zitierte Datei-Inhalte. Dasselbe gilt für Werkzeuge mit URL-, Muster- oder
  MCP-Argumenten. Zwei Lesarten sind möglich und die ADR entscheidet nicht zwischen ihnen: nach
  Festlegung 1.3 (geschlossenes Schema) fiele ein unbekanntes Werkzeug auf „nichts erfassen"
  zurück — dann ist `tool.arguments` für einen Teil der Tool-Calls leer und die Aussage
  *„`tool.arguments` **wird erfasst** und damit der Modul-15-Mindestsatz **erfüllt**"* (`:80-81`)
  gilt nur für drei Klassen; nach Festlegung 2 („je Werkzeug wird erfasst, was die Incident-Frage
  beantwortet") müsste die Feldtabelle den Fall regeln — und die ist nach Folgepflicht 1 ein
  `MR-<NNN>`, das erst der Slice schreibt.
  Failure-Szenario: slice-059 registriert wie empfohlen mit leerem Matcher und übernimmt die
  Tabelle wörtlich. Ein `Task`-Aufruf trifft keine Zeile; der Fall-Autor entscheidet ihn beim
  Schreiben des Emitters — naheliegend als „Argumente unverändert übernehmen", weil nur die drei
  benannten Klassen eine Vorschrift haben. Der Span trägt dann den vollständigen Subagenten-Prompt,
  auf der emittierten Ebene mit unbekannter Vertrauensgrenze, und die ADR hat für diesen Fall
  „konstruktiv ausgeschlossen" zugesagt.
- `verifizierbar`: ja, am Artefakt — die Tabelle hat drei Zeilen und keine Default-Zeile; der
  Kontext-Absatz `:34-40` nennt Subagenten als tragende Achse. Kein Gate deckt es.

### R4-7 — Der Fingerabdruck löst die Sorge auf der Repo-Ebene und verschiebt sie auf der emittierten: Länge + Hash sind dort ein Bestätigungs-Orakel, wo die ADR die Vertrauensgrenze selbst für unbekannt erklärt

- `kategorie`: **MEDIUM**
- `quelle`: ADR-0011 §Bedrohungsmodell Grund 1 und Grund 3 (`:121-128`) ·
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed) ·
  `modul-15-observability.md` (*„ohne Secrets im Log"*)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:106` im Verbund mit `:125-128` und
  `:130-132`
- `befund`: Das Bedrohungsmodell ist auf der **Repo**-Ebene sauber hergeleitet und dort trägt es
  (s. Negativbefunde). Für die **emittierte** Ebene sagt es ausdrücklich das Gegenteil: *„bei einem
  fremden Adopter kennen wir die Vertrauensgrenze **nicht** (geteilter Build-Agent, Image-Schicht,
  Backup)"* — und schickt genau dorthin die Tabelle *„unverkürzt"*, also **mit** dem Fingerabdruck
  aus **Länge und Hash** des geschriebenen Inhalts. Damit gilt auf der Ebene, für die das Modell
  nicht hergeleitet ist, eine Maßnahme, die zwei der drei eigenen Gründe nicht abdeckt. Grund 1
  (*„ein rotiertes Secret ist aus der Quelle raus und stünde im Log weiter"*) trifft den Hash
  genauso wie den Klartext: der Hash überlebt die Rotation und bestätigt den alten Wert weiterhin.
  Und wo der Leser des Logs die Quelldatei **nicht** hat — der Fall, den Grund 3 gerade als den
  stärksten benennt —, ist ein Hash über einen Inhalt mit kleinem Suchraum kein Fingerabdruck,
  sondern ein **Verifikations-Orakel**; die mitgeführte Länge grenzt den Suchraum zusätzlich ein.
  Die ADR diskutiert diesen Unterschied nicht; sie behandelt „Fingerabdruck" als inhaltsfrei.
  Failure-Szenario: ein Adopter emittiert die Erfassung (slice-062, CR erteilt). Ein Bootstrap
  schreibt eine `.env` mit einem sechsstelligen Zugangscode oder einem Token aus einem bekannten
  Format; der Span trägt Pfad, Länge und Hash. Die Span-Datei landet über eine Image-Schicht oder
  ein Backup — beides von Grund 3 wörtlich genannt — bei jemandem ohne Zugriff auf das
  Arbeitsverzeichnis. Er hat den Klartext nicht, aber Länge und Hash: er bestätigt den geratenen
  Wert offline, auch noch nachdem das Secret rotiert wurde. Die ADR hat für diese Ebene zugesagt,
  dass **kein Byte fremden Inhalts** wandert; ein invertierbarer Hash ist kein Byte und trägt den
  Inhalt trotzdem.
- `verifizierbar`: ja, am Artefakt — die Tabelle (`:106`) nennt Länge und Hash, `:130-132` zieht
  sie unverkürzt auf die emittierte Ebene, `:121-122` nennt Rotation als Grund. Kein Gate deckt es.

### R4-8 — „Nicht die Datei einer *laufenden* fremden Sitzung löschen": das benannte Erkennungsmittel ist kein Lebendigkeits-Signal, und mit ihm sind die beiden Auflagen nicht gemeinsam erfüllbar

- `kategorie`: **MEDIUM** — **Ersatz für R3-4**, dessen Fix die Frage verschiebt statt sie zu lösen
- `quelle`: Vorbefund R3-4 aus [Runde 3](2026-07-28-adr-0011-proposed-review-runde-3.md) ·
  Vorbefund R2-5 aus [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md) ·
  `modul-07-carveouts.md` §Ziel-Form (ein Kriterium, das ein anderer ohne Rückfrage anwenden kann) ·
  ADR-0011 Folgepflicht 4
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:148-158`
- `befund`: Die Aufräum-Regel trägt jetzt zwei Auflagen: der Emitter *„entfernt beim ersten Span
  einer Sitzung ältere Bestände"* **und** *„Er löscht dabei niemals die Datei einer **laufenden**
  fremden Sitzung … der Aufräum-Schritt muss **an der Sitzungs-Kennung** erkennen, was er anfassen
  darf"*. Das benannte Mittel kann die zweite Auflage nicht liefern: eine Sitzungs-Kennung ist ein
  Bezeichner, kein Lebendigkeits-Signal. Ein Emitter-Prozess sieht in der Hook-Payload seine eigene
  `session_id` und im Verzeichnis fremde Dateinamen — daraus folgt „fremd", nie „beendet". Die
  Payload trägt keine Prozess-Identität der fremden Sitzung, und der Emitter ist selbst ein
  kurzlebiger Prozess ohne Zustand. Damit bleiben nur zwei Auslegungen, und die ADR wählt keine:
  entweder er löscht Fremdes anhand einer Zeitstempel-Vermutung — dann steht R3-4 unverändert
  (er reißt der Parallelsitzung den Bestand weg, und der Verlust ist für den Lücken-Detektor
  gerade **nicht** sichtbar, weil eine ganze Datei fehlt statt einer Nummer, was die ADR in
  `:154-156` selbst so beschreibt) —, oder er fasst Fremdes nie an — dann steht R2-5 unverändert
  (der Bestand wächst, weil es keinen Löschenden gibt). Ein taugliches Mittel existiert im selben
  Verzeichnis: [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) hält für exakt diese
  Frage ein fail-closed Lock unter `.harness/state/mutate.lock` (`:25-28`, `:78`) — die ADR nennt
  weder das noch ein anderes.
  Failure-Szenario: die Implementer-Sitzung läuft seit zwei Stunden; im zweiten Terminal startet
  eine Review-Sitzung (dieses Repo führt Reviews ausdrücklich in frischem Kontext). Deren Emitter
  liest die Regel, sieht eine fremde Sitzungs-Kennung mit älterem Zeitstempel, kann „läuft noch"
  nicht feststellen und löscht — oder er löscht nichts und der Bestand aus vier Wochen
  Parallel-Sitzungen bleibt liegen, mit Pfaden und Kommando-Tokens, in einem 0775-Verzeichnis. Die
  ADR hat beides ausgeschlossen.
- `verifizierbar`: ja — die Abwesenheit eines Lebendigkeits- oder Sperr-Mittels ist per Lektüre der
  Festlegung feststellbar; `sed -n '23,30p;76,80p' harness/tools/mutate.sh` zeigt die
  Gegen-Präzedenz im selben Verzeichnis. Kein Gate deckt es.

### R4-9 — Die „ehrlich benannte" Restlücke der Folgenummer ist nicht die einzige: Subagenten teilen laut Quelle die `session_id`, und mehrere Emitter derselben Sitzung vergeben Nummern gleichzeitig

- `kategorie`: **MEDIUM**
- `quelle`: ADR-0011 Folgepflicht 4 (`:297-309`, die Sichtbarkeits-Zusage) · ADR-0011 §Kontext
  (`:37-38`, *„Hooks feuern **auch in Subagenten**"*) · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:304-309`
- `befund`: Die Runde-4-Ergänzung legt den Vergabezeitpunkt fest (*„Die Nummer wird als Erstes
  vergeben"*) und benennt eine Restlücke: *„stirbt er **davor**, wurde nie eine Nummer vergeben —
  dann entsteht keine Lücke, und dieser Fall bleibt unsichtbar. Er ist damit **nicht** gedeckt."*
  Diese Ehrlichkeit ist vorbildlich; die Ausschließlichkeit („die" Grenze) hält nicht. An der von
  der ADR selbst benannten Quelle am 2026-07-28 gemessen: *„**Subagents share the same `session_id`
  as the main session.**"* — unterschieden wird über `agent_id`. „Je Sitzung eine Datei" und „je
  Sitzung eine monoton steigende Folgenummer" heißt damit: der Haupt-Thread **und** jeder parallel
  laufende Subagent schreiben in denselben Nummernkreis. Die Vergabe „als Erstes" ist zwangsläufig
  ein Lesen (letzte Nummer ermitteln) gefolgt von einem Schreiben; zwei gleichzeitige Emitter lesen
  denselben Stand. Die ADR entscheidet weder eine Serialisierung noch einen je-`agent_id`
  getrennten Kreis, und ihr Detektor sucht ausschließlich **Lücken**.
  Failure-Szenario: eine Sitzung startet drei Subagenten parallel (in diesem Repo der Normalfall:
  slice-059 §Messung E zählt für **eine** Sitzung 189 Tool-Calls im Haupt-Kontext plus 49 und 66 in
  Subagenten). Drei Emitter ermitteln gleichzeitig die letzte Nummer 41 und schreiben je einen Span
  mit 42. Der Bestand ist lückenlos 1…42, der Leser sieht nichts, drei Tool-Calls sind auf einen
  Eintrag zusammengefallen — der Zustand *„lückenhaft und sieht vollständig aus"*, den Folgepflicht
  4 wörtlich ausschließen will. Der zugehörige Mutations-Fall (`:318`, „ein Span wird
  unterschlagen") färbt dabei nicht rot: unterschlagen wurde nichts, doppelt vergeben schon.
- `verifizierbar`: ja — <https://code.claude.com/docs/de/hooks>, Abschnitt zu `session_id`/`agent_id`,
  gegen `docs/plan/adr/0011-telemetrie-erfassung-policy.md:304-309`; die Call-Zahlen in
  `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:123`. Kein Gate deckt es.

### R4-10 — Festlegung 5 bindet die emittierte Ebene weiter an die „leere Start-Allowlist", die Festlegung 2 in derselben Überarbeitung abgeschafft hat; Alternative E schreibt Festlegung 1.3 das Gegenteil ihres neuen Inhalts zu

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.4 (ab *Accepted* nicht mehr korrigierbar) ·
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  (Festlegung 5 ist die Vorgabe an den CR) · Drift-Klasse „derselbe Stand an zwei Orten"
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:206` und `:267`
- `befund`: Runde 4 ersetzt Festlegung 2 vollständig (Allowlist → abgeleitete Werte) und Festlegung
  1.3 (leere Start-Allowlist → geschlossenes Schema, `tool.arguments` **wird** erfasst). Sieben
  Stellen der ADR sprechen weiter von der Allowlist; zwei davon sind nicht Wortwahl, sondern
  Inhalt. (a) **Festlegung 5**, `:206` — der bindende Satz für die emittierte Ebene:
  *„Wird emittiert, gelten die Festlegungen 1–4 und 6 unverändert — **leere Start-Allowlist**,
  Ablage außerhalb des versionierten Baums …"*. Er verpflichtet den Adopter auf einen Startzustand,
  den Festlegung 1.3 gerade verworfen hat, und widerspricht der neuen ebenen-abhängigen Schärfe
  (`:130-132`), nach der für Emittiertes die **Tabelle** gilt — nicht Leere. (b) **Alternative E**,
  `:267`: *„mit leerer Allowlist **ist** C genau E. **Festlegung 1.3 macht E damit zum
  Startzustand**"* — Festlegung 1.3 sagt jetzt das Gegenteil (*„`tool.arguments` **wird erfasst**
  und damit der Modul-15-Mindestsatz **erfüllt**"*), C ist also gerade **nicht** E. Die
  Vergleichstabelle beschreibt damit eine Wahl, die die Entscheidung nicht mehr trifft.
  (Die übrigen fünf Stellen sind Drift: `:266` Contra von C, `:276-277` und `:288` in den
  Konsequenzen — Letzteres begründet die Erfassungsfläche noch mit *„der Hook sieht auch
  `Write`/`Edit`-Payloads — also Datei-Inhalte"*, was Festlegung 2 konstruktiv ausschließt —,
  `:316` in der Fitness Function, `:358` im Trigger → R4-11.)
  Failure-Szenario: slice-062 schreibt den CR und liest Festlegung 5 als das, was sie zu sein
  beansprucht — die bindende Wie-Vorgabe. Er verpflichtet das Ziel auf eine leere Start-Allowlist,
  also faktisch auf Alternative E, und emittiert damit eine Erfassung ohne `tool.arguments` —
  während die ADR im Repo das Gegenteil entschieden hat und
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  für unbekannte Adopter die **strengere**, nicht die leere Seite verlangt. Nach *Accepted* stehen
  zwei Festlegungen desselben Dokuments gegeneinander und keine ist korrigierbar.
- `verifizierbar`: ja — `grep -n "Allowlist" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → sieben Treffer außerhalb der `Geschichte`. Kein Gate deckt es.

### R4-11 — Der Re-Evaluierungs-Trigger „Wenn die Allowlist … immer noch leer ist" kann nach Festlegung 1.3 nicht mehr auslösen — dieselbe Klasse wie die in Runde 1 gestrichene tautologische Fitness Function

- `kategorie`: **MEDIUM**
- `quelle`: Vorbefund H-1 aus [Runde 1](2026-07-28-adr-0011-proposed-review.md) (Zusage per
  Konstruktion) · `grundlagen-klassifikation.md` §Quadranten (ein *feedforward*-Trigger wirkt nur,
  wenn seine Bedingung eintreten kann) · [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:358-361`
- `befund`: Der Trigger lautet: *„Wenn die Allowlist nach dem ersten Auswertungs-Slice (060) immer
  noch leer ist … dann erfasst das Audit nur IDs und ist faktisch Alternative E. Das ist kein
  Fehler, aber der Anlass, die Wahl zwischen C und E ausdrücklich zu wiederholen, statt sie durch
  Nichtstun zu treffen."* Er setzt einen Zustand voraus, den dieselbe Überarbeitung unmöglich
  gemacht hat: Festlegung 1.3 entscheidet, dass `tool.arguments` erfasst wird, und Festlegung 2
  legt die Werte je Werkzeug fest. Es gibt keine leere Start-Allowlist mehr, die „immer noch leer"
  sein könnte. Der Trigger ist damit per Konstruktion nie erfüllt — genau die Eigenschaft, wegen
  der Runde 1 zwei Fitness-Function-Zeilen strich und die die ADR im Abschnitt *„Was hier bewusst
  NICHT steht"* (`:322-329`) als Lehre führt. Er trifft hier nicht ein Gate, sondern einen
  Re-Evaluierungs-Punkt; die Wirkung ist dieselbe: die einzige vorgesehene Gelegenheit, die C/E-Wahl
  bewusst zu wiederholen, wird nie kommen.
  Failure-Szenario: slice-060 wertet aus, die Erfassung beschränkt sich in der Praxis (etwa aus
  Latenzgründen, `:352-357`) auf IDs, und niemand hält inne, weil der dafür vorgesehene Trigger auf
  eine Bedingung wartet, die es nicht mehr gibt. Die Wahl zwischen C und E fällt genau durch das
  Nichtstun, gegen das der Trigger geschrieben wurde.
- `verifizierbar`: ja, am Artefakt — `:358` gegen `:75-81`. Kein Gate deckt es.

### R4-12 — slice-059 trägt weiter die abgelöste Konstruktion: „Allowlist", `requirement.id` als begründete Abweichung, „keine neue Abhängigkeit" — die Nachzieh-Kante ist zum vierten Mal in Folge halb gelaufen

- `kategorie`: **MEDIUM** — Klassen-Wiederholung (F-10 → R2-9 → R3-10/R3-8 → hier), diesmal mit
  vertauschten Rollen: welle-09 wurde gezogen, slice-059 und der Index nicht
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2 (aktive ADRs sind Rang 3, der Slice-Plan ist Rang 4) ·
  Vorbefund R3-10 · Drift-Klasse „derselbe Stand an zwei Orten, einer altert"
- `pfad`: `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md:68`, `:125`, `:129`
- `befund`: Der Diff `7ccec13` zieht welle-09 sauber nach (`:173` „nach der **vierten** Runde",
  `:186-196` ersetzt die widerlegte `LH-QA-03`-Lesart durch den Verweis auf ADR-0011 Festlegung 4 —
  gemessen, R3-10 ist damit erledigt). slice-059 ist im Diff **nicht enthalten** und trägt
  unverändert drei Stellen, die die neue Fassung überholt hat. `:68` — die DoD-Zusage *„Der zweite
  ist der wichtigere und muss als **Allowlist** gebaut sein: nur bekannte, unkritische Felder gehen
  durch, alles andere wird redigiert"* samt Denylist-Begründung: das ist die Konstruktion, die
  Festlegung 2 ersetzt hat. `:125` — Frage G: *„Für `requirement.id` ist der Slice-Plan die einzige
  Quelle (§Bezug) … Wenn eines nicht erschließbar ist, ist das eine **begründete Abweichung**"*:
  das ist der Pfad, den die neue Regel 4 gerade schließt (und zugleich der Beleg dafür, dass die
  stehen gebliebene alte Regel 4 aus R4-2 real gelesen wird). `:129` — *„Randbedingung ‚keine neue
  Abhängigkeit'"*: die Formel, die welle-09 in derselben Überarbeitung durch „nichts, das
  installiert werden muss" ersetzt bekam.
  Failure-Szenario: die ADR wird *Accepted*, slice-059 wandert unverändert nach `next/`, und der
  Implementer arbeitet die DoD-Liste ab, wie es Modul 11 verlangt. Er baut eine Feld-Allowlist
  (`:68`), deklariert für `requirement.id` eine Abweichung (`:125`) und wählt die Mechanik gegen
  eine Randbedingung, die es nicht mehr gibt (`:129`). Jeder dieser drei Schritte ist DoD-konform
  und ADR-widrig; der Verifier prüft gegen die DoD und findet nichts.
- `verifizierbar`: ja — `grep -n "Allowlist\|begründete Abweichung\|keine neue Abhängigkeit"
  docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` → `:68`, `:125`, `:129`;
  `git show 7ccec13 --stat` zeigt die Datei nicht. Kein Gate deckt es.

### R4-13 — Der ADR-Index führt „**Proposed** (Runde 3)" und beschreibt die Entscheidung weiterhin über die abgeschaffte leere Start-Allowlist

- `kategorie`: **LOW** (Kategorie bewusst wie beim identischen Vorbefund R2-11 gehalten) —
  **vierte Runde derselben Klasse ⇒ Steering-Loop-Signal** nach §Kontext-Eskalation des
  Reviewer-Skills
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §5 (*„Neue ADRs aktualisieren den ADR-Index"*) ·
  Vorbefunde F-10, R2-11, R3-8
- `pfad`: [`docs/plan/adr/README.md`](../plan/adr/README.md):19 gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:3` und `:75-81`
- `befund`: Die Index-Zeile lautet: *„Telemetrie-Erfassung — Policy für Agenten-Spans
  (Schema-**Policy** mit **leerer Start-Allowlist**, Ablage außerhalb des versionierten Baums,
  fail-**open** im Betrieb …) | **Proposed** (Runde 3)"*. Beide markierten Teile sind überholt: der
  Rundenstand ist 4 (`Geschichte`-Zeile `:368`, welle-09 `:173`), und die leere Start-Allowlist ist
  durch das geschlossene Schema mit erfasstem `tool.arguments` ersetzt. Es ist wörtlich derselbe
  Mechanismus wie bei R2-11 („der Index beschreibt, was Festlegung 1 gerade abgeschafft hat"), nur
  eine Fassung später — und wieder wurde ein Teil der Kante gezogen (welle-09) und ein Teil nicht.
  Failure-Szenario: der Leser, der über den Index einsteigt — die vorgesehene Reihenfolge nach
  [`AGENTS.md`](../../AGENTS.md) §5 —, entnimmt ihm, ADR-0011 entscheide eine leere Start-Allowlist,
  hält das für die aktuelle Fassung (der Rundenstand bestätigt ihn) und liest die ADR gar nicht
  weiter. Für einen CR-Autor bei slice-062 ist das dieselbe Fehlleitung wie R4-10, nur eine Ebene
  früher.
- `verifizierbar`: ja — `grep -n "0011" docs/plan/adr/README.md` → `:19`. Kein Gate deckt es
  (`docs-check` prüft die Existenz der Index-Zeile, nicht ihren Inhalt).

### R4-14 — [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht weiterhin nur im Bezug-Feld und nirgends im Body — vierte Runde, derselbe Befund

- `kategorie`: **LOW** — **aus Vorrunden offen** (F-11 → R2-12 → R3-11 → hier);
  vierte Wiederholung ⇒ Steering-Loop-Signal
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form (*„Der Kontext **referenziert** die
  Anforderung"*) · Vorbefunde F-11, R2-12, R3-11
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:11`
- `befund`: Volltextsuche in dieser Fassung: `grep -n "LH-QA-01"` → **nur `:11`**, also
  ausschließlich das Bezug-Feld selbst. Der Abschnitt, der die Anforderung tragen würde („Was hier
  bewusst NICHT steht", `:322-329`), begründet die Streichungen weiterhin allein mit
  [`AGENTS.md`](../../AGENTS.md) §3.6. Der Diff hat den Body an neun Stellen angefasst und diese
  nicht. Dass derselbe Befund die vierte Runde übersteht, ist selbst die Beobachtung: ein Punkt,
  den kein Sensor sieht, wird von Überarbeitungen nicht erreicht — und ausgerechnet R4-1 und R4-3
  dieser Runde sind Befunde **derselben** Anforderung.
  Failure-Szenario: eine spätere Änderung an
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) löst über
  das Bezug-Feld eine Nachzieh-Prüfung von ADR-0011 aus; der Prüfende findet außer der Kopfzeile
  keine Stelle, an der die Anforderung wirkt, und kann weder „betroffen" noch „unbetroffen" belegen.
- `verifizierbar`: ja — `grep -n "LH-QA-01" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → nur `:11`. Kein Gate deckt es.

### R4-15 — Der Rest von R3-5: `sed`/`grep` sind ergänzt, die GNU/BSD-Dialektfrage bleibt offen, während Festlegung 5 die Liste unverändert in emittierte Ziele zieht

- `kategorie`: **LOW** — **aus Vorrunden offen** (Rest von R3-5)
- `quelle`: [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (macOS und Windows
  sind erstklassig) · Vorbefund R3-5 · ADR-0011 Festlegung 5
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:169-179`
- `befund`: Runde 4 nimmt zwei von drei Hälften des Befunds auf: `sed` und `grep` stehen jetzt in
  der Erlaubt-Liste, und das Kriterium ist ausdrücklich die **Eigenschaft** (*„was auf einem
  POSIX-System vorhanden ist, ohne installiert zu werden … Das Kriterium ist die **Eigenschaft**,
  nicht diese Aufzählung"*). Die dritte Hälfte bleibt: „POSIX-System" beantwortet „vorhanden **wo**",
  aber nicht „in welchem **Dialekt**". Der Bestand, den derselbe Absatz für „nicht betroffen"
  erklärt, ist an dieser Stelle bekanntermaßen nicht portabel —
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) deklariert im eigenen Kopf *„die Fälle
  nutzen `sed -i` und GNU-BRE-Escapes, sind also **NICHT strikt POSIX**"*. Mit der Aufnahme von
  `sed`/`grep` ist die Frage nicht kleiner geworden, sondern konkreter: Festlegung 5 zieht die
  Liste unverändert in emittierte Ziele, und
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) führt macOS erstklassig.
  Failure-Szenario: der Emitter wird mit GNU-`sed`-Semantik gebaut (wie jeder Mutations-Fall dieses
  Repos); auf einem macOS-Ziel greift dieselbe Zeile anders. Betroffen ist ausgerechnet die
  Ableitung der Argument-Werte — der sicherheitstragende Teil dieser ADR: was auf BSD anders
  greift, redigiert anders, und „vorhanden" hat dem Autor nicht widersprochen.
- `verifizierbar`: ja — `sed -n '30,36p' harness/tools/mutate.sh` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:169-173`. Kein Gate deckt es.

### R4-16 — Das einzige offen gelassene Feld soll über `transcript_path` aufgelöst werden — genau die Quelle, deren Fremdheit die ADR als Contra gegen Alternative D führt

- `kategorie`: **LOW**
- `quelle`: ADR-0011 §Verglichene Alternativen, Zeile D (`:268`) · `modul-15-observability.md`
  §Cache-Counter-Regeln · Vorbefund R2-6 (Abweichungs-Begründung)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:86-89` gegen `:268`
- `befund`: Die neue Regel 4 lässt genau ein Feld offen und formuliert die Entscheidungsfrage so:
  *„ob ein Span, der den `transcript_path` trägt und die Auflösung dem Auswerter überlässt, den
  Mindestsatz erfüllt oder von ihm abweicht, entscheidet der umsetzende Slice — mit Beleg."* Die
  Frage ist für den Slice **entscheidbar** (Modul 15 verlangt für eine Abweichung nur *„jede
  Abweichung davon begründest du"*, keinen Sensor — das ist gegen den Modul-Wortlaut geprüft), also
  kein blockierender Mangel. Unaufgelöst bleibt, dass die angebotene Auflösung dieselbe Schwäche
  importiert, mit der die ADR zwei Seiten später Alternative D verwirft: *„die Datenquelle liegt
  **außerhalb** des Repos, gehört uns nicht und kann sich mit dem Werkzeug ändern"*. Verschärfend:
  nach Festlegung 3 lebt der Span-Bestand nur die Sitzung, das Transkript folgt einer
  Aufbewahrung, die wir nicht kontrollieren — die Auflösung ist also zeitkritisch, ohne dass die
  ADR das benennt.
  Failure-Szenario: slice-059 wählt den `transcript_path`-Weg und belegt ihn; slice-060 wertet
  später aus und findet das Transkript rotiert oder in einem geänderten Format. Der Cache-Status
  ist dann weder erfasst noch als Abweichung dokumentiert — die Lücke, die Festlegung 1.4 gerade
  verhindern soll, entsteht durch die von ihr angebotene Auflösung.
- `verifizierbar`: ja, am Artefakt — `:86-89` gegen `:268`. Kein Gate deckt es.

### R4-17 — Das Zustands-Verzeichnis bleibt gruppenschreibbar; entschieden ist weiterhin nur der Datei-Modus

- `kategorie`: **INFO** — **aus Vorrunden offen** (unveränderter Rest von R2-14/R3-12)
- `quelle`: Vorbefunde R2-14, R3-12 · ADR-0011 Festlegung 3, erster Punkt (`:145-147`)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:145-147`
- `befund`: Eigene Messung 2026-07-28 bestätigt die Zahlen der ADR: `.harness/state/` ist `drwxrwxr-x`
  (0775), die Stempeldatei `-rw-rw-r--` (0664). Der Diff ändert daran nichts. Ein 0600-Span in einem
  0775-Verzeichnis ist gegen Mitlesen geschützt, gegen Entfernen und Unterschieben nicht — beides
  hängt am Schreibrecht des **Verzeichnisses**. Bleibt INFO, weil Festlegung 3 dritter Punkt („Kein
  Beleg-Status") die Integritäts-Anforderung ausdrücklich absenkt. **Neu relevant** ist der Punkt im
  Verbund mit R4-8: die dort beschriebene Löschung fremder Bestände wird durch die
  Verzeichnis-Rechte nicht begrenzt.
- `verifizierbar`: ja — `ls -ld .harness/state/`. Kein Gate deckt es.

## Negativbefunde

### Runde-3-Befunde, die **sauber gelöst** sind

- geprüft, ohne Befund: **R3-1 (der einzige HIGH der Vorrunde) ist an der Wurzel behoben — die
  falsche Zusage wurde gestrichen, nicht umformuliert.** Gemessen am Diff: Setzung 1 („die
  Erfassung meidet das Entscheidungs-Event des Guards … löst die Kollision durch Konstruktion") ist
  **ersatzlos entfernt**; die drei Gegenbelege des Reviews stehen jetzt als eigene Aufzählung im
  Text (`:222-231`), einschließlich des Satzes, dass dieses Repo auf `Stop` bereits einen zweiten
  fail-closed Hook betreibt, und einer Klammer, die die eigene widerlegte Fassung benennt statt sie
  zu glätten (`:233-235`). Die drei Ereignis-Aussagen habe ich an der Quelle nachgemessen und
  bestätige sie: `Stop`/`SubagentStop` → *„Blockable? **Yes**"*; `PostToolUse`/`PostToolUseFailure`
  stehen in der Liste der Ereignisse mit Top-Level-`decision`; Hooks laufen parallel. Die
  **Richtung** des Fixes (Konstruktion am Emitter statt an der Ereignis-Wahl) ist richtig — der
  verbleibende Einwand betrifft ausschließlich die fehlende Absicherung (→ R4-3), nicht die Wahl.
- geprüft, ohne Befund: **R3-2 ist durch Streichung erledigt.** `grep -n "PermissionDenied"
  docs/plan/adr/0011-telemetrie-erfassung-policy.md` → **kein Treffer** im Body. Die an der Quelle
  nicht belegte Abdeckungs-Zusage (*„ein abgelehnter Aufruf hat mit `PermissionDenied` ohnehin sein
  eigenes Ereignis"*) ist mit Setzung 1 verschwunden. Die ADR behauptet für geblockte Aufrufe jetzt
  gar keine Abdeckung mehr — das ist die von [`AGENTS.md`](../../AGENTS.md) §3.6 verlangte Form
  („die Zusage auf das einschränken, was der Code hält") und wird **nicht** als Lücke geführt.
- geprüft, ohne Befund: **R3-3 ist in seiner tragenden Hälfte gelöst, und die Ehrlichkeit über den
  Rest ist mustergültig.** Der Vergabezeitpunkt ist jetzt festgelegt (*„Die Nummer wird als Erstes
  vergeben, vor jeder anderen Arbeit des Emitters"*), und die verbleibende Grenze steht ausgesprochen
  im Text statt in einer Fußnote (*„stirbt er davor … Er ist damit **nicht** gedeckt, und das steht
  hier, statt die Folgenummer als Vollschutz auszugeben"*). Das ist genau die Form, die §3.6
  verlangt. Beanstandet wird ausschließlich, dass diese Grenze nicht die einzige ist (→ R4-9).
- geprüft, ohne Befund: **R3-6 ist gelöst.** Die Erlaubt-Liste führt `docker` weiterhin, benennt
  aber jetzt die praktische Grenze und ihren Grund: *„ein **Container-Start pro Tool-Call** ist es
  praktisch nicht — [ADR-0004] hat diese Bauart mit 300–700 ms je Aufruf verworfen, und gegen
  Startup-Kosten hilft die Latenz-Schwelle unten nicht (sie senkt den *Umfang*, nicht den
  Prozessstart)."* Beide Hälften des Befunds (der nicht übernommene Latenz-Ausschluss und die nicht
  passende Abhilfe) sind wörtlich adressiert.
- geprüft, ohne Befund: **R3-7 ist gelöst.** Die Zuordnung ist auf das eingegrenzt, wofür sie
  gebraucht wird: *„[ADR-0004] die bindende Quelle — **für die Bauart der Durchsetzungsschicht**,
  nicht für die Frage, was ins Ziel emittiert wird; die entscheidet Festlegung 5 samt CR."* Die von
  Runde 3 beschriebene Kollision zweier aktiver Quellen über das *Ob* der Emission existiert nicht
  mehr.
- geprüft, ohne Befund: **R3-8 und R3-10 (welle-09) sind gelöst.** Gemessen am Diff:
  `welle-09-modul-15-konformitaet.md:173` führt jetzt *„nach der **vierten** Runde"*, und
  `:186-196` ersetzt die widerlegte `LH-QA-03`-Lesart (*„im Ziel zusätzlich `bash + git + docker`"*)
  durch die neue Grenze plus den Verweis auf ADR-0011 Festlegung 4, einschließlich der Feststellung,
  dass die frühere Fassung falsch zitierte. Der Widerspruch zwischen Welle und ADR ist aufgelöst.
  Offen ist die **andere** Hälfte der Kante (→ R4-12, R4-13).
- geprüft, ohne Befund: **R3-9 ist gelöst.** Eine Volltextsuche nach den beiden schließenden
  Werkzeug-Tags über `docs/reviews/*.md` (bewusst ohne die Literale hier zu wiederholen, damit
  dieser Report die Suche nicht selbst verrauscht)
  liefert nur noch Treffer **innerhalb** des R3-9-Befundtextes selbst; die drei betroffenen Reports
  (`2026-07-18-slice-004a-review.md`, `2026-07-22-slice-033-review.md`,
  `2026-07-28-adr-0011-proposed-review-runde-2.md`) sind im Diff um je eine Zeile gekürzt und enden
  jetzt sauber. Dieser Report endet ebenfalls ohne Werkzeug-Markup.
- geprüft, ohne Befund: **R3-5 ist in seiner Werkzeug-Hälfte gelöst.** `sed` und `grep` stehen in
  der Erlaubt-Liste, und das Kriterium ist von einer Aufzählung auf eine **Eigenschaft** umgestellt
  — die von `modul-07-carveouts.md` verlangte Form (ein Dritter kann sie ohne Rückfrage anwenden).
  Offen bleibt allein die Dialekt-Frage (→ R4-15).

### Was ich geprüft und **nicht** beanstandet habe (mit Beleg)

- geprüft, ohne Befund: **Das Bedrohungsmodell trägt auf der Repo-Ebene — zwei seiner drei
  Messungen habe ich bestätigt.** (a) `.gitignore:5` führt `.harness/state/`; die Span-Datei kann
  nicht committet werden. (b) *„die einzige Stelle, die den Baum kopiert"* stimmt:
  `grep -rn "cp -r\|cp -a\|tar -c\|rsync\|git archive"` über `harness/tools/*.sh`, `Makefile`,
  `*.mk` und `.github/workflows/` liefert **außer** `mutate.sh:152` keinen Baum-Kopierer, und
  `mutate.sh:152` schließt `./.harness/state` aus. Auch der Docker-Pfad ist dicht, obwohl das
  `Dockerfile` viermal `COPY . .` fährt (`:47`, `:53`, `:61`, `:80`): `.dockerignore` listet
  `.git` und `.harness`, der Zustands-Bereich gelangt also nie in den Build-Kontext und damit in
  keine Image-Schicht. Die `docker run -v "$(CURDIR):/repo:ro"`-Mounts der Gate-Targets exponieren
  die Datei zwar gegenüber Fremd-Images (d-check, shellcheck, actionlint, bats), aber im selben
  Mount liegen die Quellen — der Satz *„Wer sie lesen kann, kann auch die Dateien lesen"* hält
  dort. Falsch ist an dem Absatz **nur** die dritte Messung (→ R4-1).
- geprüft, ohne Befund: **Die Ableitbarkeit von `requirement.id` existiert wirklich — meinen
  ersten Gegenverdacht habe ich selbst widerlegt.** Ich habe **alle 63** Slice-Dateien unter
  `docs/plan/planning/` maschinell ausgewertet (Bezug-Block ab `**Bezug:**` bis zur nächsten
  Leerzeile): **63 von 63** führen mindestens eine `LH-*`-ID. Auch die Slices, deren *erste*
  Bezug-Zeile keine trägt (`slice-055:12`, `slice-056:12`, `slice-057:19`, `slice-059:10` — alle
  beginnen mit `AGENTS.md` §3.6 bzw. `MR-000`), führen sie zwei bis fünf Zeilen weiter. Die
  Parenthese der ADR (*„gemessen: jeder Slice führt seine `LH-*`-IDs maschinenlesbar"*) ist am
  Bestand **korrekt**. Mein Einwand richtet sich ausschließlich gegen Verfügbarkeit und
  Eindeutigkeit (→ R4-5), nicht gegen die Existenz.
- geprüft, ohne Befund: **„Es gibt kein entscheidungsfreies Ereignis, auf das man ausweichen
  könnte" hält unter seinem eigenen Qualifikator — REFUTED mit Zitat.** An der Quelle gibt es sehr
  wohl Ereignisse ohne Entscheidungs-Kanal: `StopFailure` → *„Output and exit code are ignored"*,
  `PermissionDenied` → *„Exit code and stderr ignored (denial already occurred)"*,
  `InstructionsLoaded` → *„Exit code is ignored"*. Keines davon feuert je Tool-Call, taugt also
  nicht als Ausweich-Ereignis für eine Span-Erfassung — der Halbsatz *„auf das man ausweichen
  könnte"* trägt die Aussage. Ich führe das ausdrücklich **nicht** als Befund.
- geprüft, ohne Befund: **Die Exit-Klemme scheitert am externen Tod, und das schadet der
  Fail-open-Eigenschaft nicht.** An der Quelle gemessen: *„When a hook exceeds its timeout: The
  hook process is terminated … treated as a **non-blocking error** … For blockable events, timeout
  does **not** block the action."* Ein vom Werkzeug getöteter Emitter kann seinen `exit 0` nicht
  mehr ausführen, aber der beobachtete Ausgang blockt nicht; ebenso liegen ein nicht startbarer
  Interpreter (127) oder ein SIGKILL (137) **nicht** auf dem einzigen blockierenden Wert (2). Die
  Formulierung der ADR ist mit *„unabhängig davon, was **intern** geschieht"* korrekt begrenzt. Der
  Befund R4-3 richtet sich deshalb **nicht** gegen die Reichweite der Klemme, sondern gegen ihre
  fehlende Absicherung und gegen den `set -e`-Leckpfad, der **innerhalb** dieser Reichweite liegt.
- geprüft, ohne Befund: **Form nach Modul 4 und Vorlage.** Gegen
  `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md` abgeglichen: die
  Block-Reihenfolge der Vorlage (Kontext · Entscheidung · Verglichene Alternativen · Konsequenzen ·
  Fitness Function · Re-Evaluierungs-Trigger · Geschichte) ist **exakt** eingehalten; alle
  Kopf-Felder vorhanden (Status · Datum · Autor · Bezug · Schärft); **fünf** Alternativen (≥ 3 nach
  §Ziel-Form), jede mit Pro **und** Contra; Konsequenzen führen Positiv, Negativ und vier
  Folgepflichten getrennt; kein Template-Hinweis-Block. Der einzige Formmangel ist die doppelte
  Listennummer aus R4-2.
- geprüft, ohne Befund: **Doc-Gate-Regeln.** Eigener Lauf dieser Sitzung: `make docs-check` →
  **d-check 232 Dateien, 0 Befunde** — die Zahl der Commit-Message ist damit unabhängig bestätigt.
  Alle `LH-`/`ADR-`/`MR-`-Kennungen der überarbeiteten Abschnitte sind als Link geführt, die
  relativen Tiefen aus `docs/plan/adr/` stimmen, die neu genannten Inline-Pfade
  (`harness/tools/mutate.sh`, `.claude/hooks/stop-require-gates.sh`) existieren.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4 und §3.5.** Die Überarbeitung betrifft
  eine *Proposed*-ADR, überschreibt keine *Accepted*-ADR, beansprucht kein *Supersedes* und lockert
  kein Gate. `.claude/settings.json` ist im Diff **nicht** enthalten (gemessen an
  `git show 7ccec13 --stat`), Guard und Stop-Hook sind unverändert. Der Status ist im Dokument
  (`:3`) und in welle-09 **Proposed**, slice-059 bleibt in `open/` (gemessen: `ls
  docs/plan/planning/open/` → genau diese Datei; `next/` ist leer).
- geprüft, ohne Befund:
  **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).**
  `git show 7ccec13 --stat` → sechs Dateien, **kein** `spec/lastenheft.md`. Die ADR ändert kein
  `LH-*`, sie referenziert nur; das *Ob* der Emission bleibt bei slice-062 ein echter Gegenstand
  (die inhaltliche Fehlleitung der Wie-Vorgabe steht als R4-10, nicht als MR-015-Verstoß).
- geprüft, ohne Befund:
  **[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  und [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption).**
  Die Herleitung von Festlegung 3 (ein Span im getrackten Baum bräche den inhaltsbasierten Nachweis
  und der Stop-Hook blockierte sich selbst) ist unverändert und in den Vorrunden als richtig
  bestätigt; der Ablageort im gitignorierten Zustands-Bereich ist der korrekte. Die ADR legt
  weiterhin keinen Ablageort für ausführbare Tools fest; slice-059 verortet den Emitter unter
  `harness/tools/`.
- geprüft, ohne Befund: **Kollision mit aktiven ADRs — weiterhin keine.**
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) bindet den Tool-Build und wird von einem
  Hook-Skript nicht berührt; [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) trägt die
  bash/awk-Bauart, an die Festlegung 4 jetzt in korrekt eingegrenzter Weise anknüpft (→ R3-7
  gelöst).
- geprüft, ohne Befund: **Die `Geschichte`-Tabelle.** Die neue Zeile (`:368`) führt Datum, Ereignis
  („Überarbeitet (Runde 4), weiter **Proposed**"), den Verweis auf den Runde-3-Report mit
  Befundzahl und benennt den HIGH **inhaltlich** als eigenen Fehler; die drei älteren Zeilen bleiben
  **unverändert** darunter stehen, nichts wurde umgeschrieben. Das entspricht der Vorlage und der
  Präzedenz aus [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md). Ihre einzige
  inhaltliche Ungenauigkeit („Damit entfällt die Abweichung") ist Folge von R4-2 und wird dort
  geführt.
- geprüft, ohne Befund: **Die übrigen Fitness-Function-Zeilen und die Runde-1-Streichungen.**
  Zeilen 1–5 (Pflicht-Feld, Schema-Feld, Ablageort, unterschlagener Span, `0600`) sind durch diesen
  Diff nicht verändert und in den Vorrunden als red-fähig geprüft; der Abschnitt „Was hier bewusst
  NICHT steht" (`:322-329`) führt beide gestrichenen Tautologien samt `--exclude-standard`-Mechanismus
  unverändert fort. Es ist **keine** neue tautologische Fitness-Function-Zeile hinzugekommen — der
  Rückfall in diese Klasse steht bei einem *Trigger*, nicht bei einer FF (→ R4-11).
- geprüft, ohne Befund: **Die Modul-15-Deckung der Erfassungs-Entscheidung.** Gegen den
  Modul-Wortlaut geprüft: die *Mindestfelder eines Tool-Call-Spans* (`tool.name`,
  `tool.arguments` redacted, `tool.result.status` + Korrelations-IDs) sind mit der neuen
  Festlegung 2 für die drei benannten Werkzeug-Klassen erfüllt — die Aussage `:80-81` ist insoweit
  richtig, und die in Runde 2/3 diskutierte selbstgemachte Abweichung ist wirklich entfallen. Die
  Incident-Frage des Moduls zu `tool.arguments.redacted` (*„was wurde wohin geschrieben — ohne
  Secrets im Log?"*) deckt sich wörtlich mit der ersten Tabellenzeile. Beanstandet werden nur die
  nicht abgedeckten Werkzeug-Klassen (→ R4-6) und die Ebenen-Asymmetrie des Fingerabdrucks
  (→ R4-7).
- geprüft, ohne Befund: **Quadranten-Kennzeichnung der Re-Evaluierungs-Trigger.** Gegen
  `grundlagen-klassifikation.md` geprüft: alle fünf Trigger tragen weiterhin eine ehrliche
  *feedforward*-Kennzeichnung, keiner behauptet einen Sensor, den es nicht gibt. Beanstandet wird
  bei einem von ihnen ausschließlich, dass seine **Bedingung** nicht mehr eintreten kann (→ R4-11).
- geprüft, ohne Befund: **Die Latenz-Schwelle und die Annahme im Kontext** sind vom Diff nicht
  berührt und in Runde 2/3 geprüft; die 50-ms-Setzung nennt ihre Herkunft und ihre Änderungsregel.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 3 |
| MEDIUM | 8 |
| LOW | 5 |
| INFO | 1 |

**Herkunft der Befunde.** **13** von 17 existieren erst seit der vierten Fassung (R4-1 bis R4-11
plus R4-12/R4-13 als Nachzieh-Folgen dieser Überarbeitung) — davon **alle drei HIGH**. **4** sind
unerledigte Reste aus den Vorrunden (R4-14 = F-11/R2-12/R3-11, R4-15 = Rest von R3-5,
R4-17 = R2-14/R3-12; R4-8 ist die nicht aufgelöste Frage aus R3-4/R2-5).

**Trend über vier Runden:** HIGH 2 → 3 → 1 → **3**. Die Zahl steigt, die **Klasse** wandert weiter
nach vorn: Runde 2 fand „präziserer Wortlaut ohne Mechanismus", Runde 3 „zu weit gefasste
Reichweiten-Zusage über einen realen Mechanismus", diese Runde findet **Defekte der Überarbeitung
selbst** — ein Beleg, der seinen Wächter nicht hat (R4-1), ein beim Ersetzen stehen gebliebener
Absatz (R4-2), ein neues Kernstück ohne Zahn (R4-3). Keiner davon ist eine falsche Entscheidung.

## Verdikt

**Kann ADR-0011 in dieser Fassung auf *Accepted* gesetzt werden: nein.** Aber der Grund hat sich
geändert, und das ist die wichtigste Aussage dieser Runde.

**Was blockiert — drei Punkte, alle mechanisch, keiner inhaltlich.**

1. **R4-1:** Der Absatz, der das neue Bedrohungsmodell belegt, behauptet einen Mutations-Fall, der
   die Eigenschaft nicht bewacht. Gemessen: **kein** Fall in `test/mutations/` entfernt
   `--exclude=./.harness/state`; der einzige Fall, der die Zeile anfasst, bewacht das Gegenteil
   (dass `.git` **mit**kopiert wird). Ein behaupteter Sensor, der nicht existiert, ist in diesem
   Repo die Kern-Fehlerklasse — und er trägt hier ausgerechnet die Erlaubnis, im Repo Pfade und
   Kommando-Tokens roh zu erfassen.
2. **R4-2:** Festlegung 1 — der ausdrücklich als **bindend** bezeichnete Teil — führt zwei Regeln
   „4.", die über `requirement.id` das Gegenteil voneinander sagen. Die ersetzte Fassung ist beim
   Ersetzen stehen geblieben, und slice-059 folgt ihr bereits.
3. **R4-3:** Die gesamte fail-open/fail-closed-Trennung ruht nach Runde 4 auf zwei
   Emitter-Eigenschaften. Die ADR nennt sie *„beide prüfbar"* und schreibt den Testfall wörtlich
   hin — in der Fitness-Function-Tabelle steht er nicht, und die einzige Zeile, die Exit-Code und
   stdout berührt, prüft den Aufrufer und setzt einen Zustand voraus, den Setzung 2 für unmöglich
   erklärt. Der Leckpfad ist konkret: alle 16 Host-Skripte und beide Hooks dieses Repos fahren
   `set -euo pipefail`, unter dem ein `awk`-Fataler (Exit **2**) das Skript vor jedem
   abschließenden `exit 0` beendet — und Runde 4 hat die Ereignis-Beschränkung gestrichen, `Stop`
   neben dem fail-closed Gate-Enforcer ist damit erlaubt.

**Zur Verdachtsstelle, die der Autor selbst benannt hat.** *„Sein Exit-Code ist hart auf 0
geklemmt"* ist **keine** überdehnte Reichweiten-Zusage. Der Qualifikator *„unabhängig davon, was
**intern** geschieht"* zieht die Grenze richtig, und die drei von außen kommenden Todesarten
(Werkzeug-Timeout, SIGKILL, nicht startbarer Interpreter) liegen an der Quelle gemessen **nicht**
auf dem einzigen blockierenden Wert 2 — der Timeout gilt dort ausdrücklich als *non-blocking
error*. Das Muster der Runde 3 wiederholt sich hier also **nicht**. Was fehlt, ist eine Ebene
tiefer: die Klemme hat keinen Mechanismus benannt bekommen, keinen Zahn, und für ihre
Schwester-Setzung („kein stdout") beansprucht der Text ein *„kann nicht"*, wo er ein *„soll nicht"*
formuliert. Das ist reparabel, ohne eine einzige Festlegung zu ändern.

**Antwort auf Leitfrage 1 — tragen die sieben Eingriffe?** Differenziert, und überwiegend ja:

- **Konstruktion am Emitter statt an der Ereignis-Wahl:** die *Richtung* trägt und ist die richtige
  Antwort auf R3-1; die falsche Zusage wurde gestrichen statt geglättet. Es fehlt die Absicherung
  (→ R4-3) und eine der drei neuen „gemessenen" Prämissen ist an der Quelle widerlegt (→ R4-4).
- **Abgeleitete Argument-Werte statt Allowlist:** der stärkste Eingriff dieser Runde. Er löst die
  Modul-15-Abweichung wirklich auf, statt sie zu deklarieren, und die drei Tabellenzeilen
  beantworten je eine echte Incident-Frage. Zwei Ränder bleiben offen: kein Default-Fall für
  Werkzeuge außerhalb der drei Klassen (→ R4-6) und der Fingerabdruck auf der emittierten Ebene
  (→ R4-7). Die Ersetzung ist zudem im Dokument nicht zu Ende geführt (→ R4-10, R4-11).
- **Bedrohungsmodell benannt statt behauptet:** methodisch genau richtig — „ohne Angabe, vor wem,
  ist sensibel eine Stimmung" ist der Satz, den diese ADR gebraucht hat. Zwei der drei Messungen
  habe ich bestätigt; die dritte ist der Blocker R4-1.
- **„Ableiten schlägt deklarieren":** die Regel ist gut und die Begründung („eine deklarierte
  Abweichung ist billiger zu schreiben als eine Lösung") ist die Art Einsicht, die eine ADR wertvoll
  macht. Die Ableitung selbst ist unvollständig belegt (→ R4-5), und die alte Regel steht daneben
  (→ R4-2).
- **Folgenummer-Vergabezeitpunkt mit benannter Restlücke:** vorbildlich in der Form, unvollständig
  in der Sache — die benannte Lücke ist nicht die einzige (→ R4-9).
- **Aufräumen ohne fremde Sitzungen:** die Auflage ist richtig, das benannte Erkennungsmittel kann
  sie nicht liefern (→ R4-8). Das ist der einzige Eingriff dieser Runde, der die Frage eher
  verschiebt als löst.
- **Eigenschafts-Kriterium statt Werkzeug-Aufzählung:** trägt. Es ist die von
  `modul-07-carveouts.md` verlangte Form, und es altert nicht mehr mit dem nächsten Werkzeug. Rest:
  die Dialekt-Frage (→ R4-15, LOW).

**Antwort auf Leitfrage 2 — konvergiert das?** **Ja, in der Sache — auch wenn die HIGH-Zahl steigt.**
Von den zwölf Runde-3-Befunden sind **acht in der Sache gelöst** (R3-1 an der Wurzel, R3-2 durch
Streichung, R3-3 in seiner tragenden Hälfte, R3-5 in seiner Werkzeug-Hälfte, R3-6, R3-7, R3-8,
R3-9/R3-10), einer ist verschoben statt gelöst (R3-4 → R4-8), drei sind nicht angefasst worden
(R4-14, R4-15, R4-17). Kein einziger Runde-3-Befund wurde umformuliert statt behoben. Die
Entscheidung selbst — lokale Erfassung, abgeleitete Werte mit benanntem Gegner, Ablage außerhalb
des versionierten Baums, fail-open im Betrieb, Randbedingung „vorhanden statt zu installieren",
Ob/Wie-Teilung — ist nach vier Runden **belastbar und in keinem Punkt mehr strittig**. Was diese
Runde findet, entsteht **nicht** aus der Entscheidung, sondern aus der Ausführung der
Überarbeitung: ein ungeprüfter Beleg, ein nicht gelöschter Absatz, eine nicht nachgezogene
Fitness Function, eine halb nachgezogene Dokumenten-Kante. Das ist die letzte Fehlerklasse vor der
Annahme.

**Trägt die ADR jetzt genug, um slice-059 zu entsperren? Nein**, und der Abstand ist kleiner als
in Runde 3, aber breiter verteilt: der Slice würde heute gegen einen Text implementieren, der ihm
für `requirement.id` zwei gegenläufige Regeln gibt (R4-2), für die zentrale Sicherheitszusage einen
nicht existierenden Wächter nennt (R4-1) und die Eigenschaft, die den Gate-Nachweis schützt, nicht
absichert (R4-3). Sein eigener Plan trägt zudem noch die abgelöste Konstruktion (R4-12).

**Was ausdrücklich trägt und nicht anzufassen ist.** Die abgeleitete Redaktion mit benanntem
Bedrohungsmodell ist der beste Teil dieser ADR und ersetzt die Allowlist zu Recht. Festlegung 4
steht nach zwei Fehlgriffen an der richtigen Quelle und ist jetzt ein Kriterium statt einer Liste.
Die Ehrlichkeit über die Folgenummer-Restlücke, die Klammer, die die eigene widerlegte Fassung
benennt, und die `Geschichte`, die ihre Fehler inhaltlich führt statt sie zu glätten, sind
Vorbilder für die Form. Die Ereignis- und Exit-Code-Aussagen sind an der Quelle bestätigt, Form
nach Modul 4 vollständig, Status nirgends vorgreifend, keine Kollision mit einer aktiven ADR,
`make docs-check` 232/0.

**Übergabe:** an den **ADR-Autor** (Rückkante Review → Architektur/Planung; die ADR bleibt
*Proposed*); die Anteile R4-12 und R4-13 zusätzlich an die **Planung** (slice-059, ADR-Index);
R4-1 zusätzlich an die **Implementation** als Sensor-Bedarf in `test/mutations/`, unabhängig vom
Ausgang dieser ADR. Es gibt keinen Produktiv-Diff. slice-059 bleibt in `open/`. Der Report ersetzt
keine Verifikation — DoD-Konformität prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt,
anderer Eingabe-Kontext).
