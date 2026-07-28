# Review-Report: ADR-0011 (Proposed, **Runde 3**) — Telemetrie-Erfassung, Policy für Agenten-Spans — 2026-07-28

**Review-Art:** **Proposed-Review einer ADR, dritte Runde** — geprüft wird die **zweite
Überarbeitung** einer noch nicht angenommenen Entscheidung ([`AGENTS.md`](../../AGENTS.md) §3.4
greift erst ab *Accepted*). Kein Produktiv-Diff. **Nicht** geprüft: Code, DoD-Abhakung (Modul 11,
getrennter Kontext).

**Leitfrage dieser Runde — zweigeteilt.** (1) *Was hat die dritte Fassung neu eingebaut?* Die
Eingriffe waren diesmal konstruktiv (Ereignis-Trennung, Folgenummern, POSIX-Basis-Kriterium) statt
sprachlich — tragen sie? (2) *Konvergiert das?* Runde 1 fand 2 HIGH, Runde 2 fand 3 HIGH, **alle
drei erzeugt von dem Fix, der Runde 1 beheben sollte**. Diese Runde beantwortet ausdrücklich, ob
noch etwas Blockierendes übrig ist — und benennt genauso ausdrücklich, was jetzt trägt. **Ergebnis
vorab:** die Konvergenz ist real (3 HIGH → **1** HIGH; 7 der 8 Runde-2-MEDIUM sind in der Sache
gelöst, nicht umformuliert), aber die neue Ereignis-Trennung hält ihre eigene Zusage *„durch
Konstruktion"* nicht.

**Gegenstand:** [`docs/plan/adr/0011-telemetrie-erfassung-policy.md`](../plan/adr/0011-telemetrie-erfassung-policy.md)
(Status **Proposed**, 296 Zeilen), im Kontext von
[`docs/plan/planning/welle-09-modul-15-konformitaet.md`](../plan/planning/welle-09-modul-15-konformitaet.md)
und `docs/plan/planning/open/slice-059-telemetrie-erfassung-hook.md` <!-- d-check:ignore (Lifecycle-Pfad: die Slice-Datei wandert durch open/next/in-progress/done) -->
sowie [`docs/plan/adr/README.md`](../plan/adr/README.md).

**Diff:** `git show 69cc416` — vier Dateien, 799+/53−: die ADR (131 Zeilen), der ADR-Index
(1 Zeile), slice-059 (23 Zeilen), plus der Runde-2-Report als neue Datei (696 Zeilen).
**Gemessen:** `git show 69cc416 --name-only` → **weder** `spec/lastenheft.md` **noch**
`.claude/settings.json` **noch** `docs/plan/planning/welle-09-modul-15-konformitaet.md` sind
berührt. Die Überarbeitung ist rein dokumentarisch; die Nicht-Berührung der Welle trägt einen
eigenen Befund (R3-10).

**Skill:** [`.harness/skills/reviewer.md`](../../.harness/skills/reviewer.md) @ 1.4.0 ·
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Regelwerk (Baseline v3.5.2, vendored, Index zuerst): `modul-04-architektur-adrs.md`
  §Ziel-Form: ADR (Wortlaut gelesen), `modul-15-observability.md` §Span-/Audit-Attribut-Regeln
  (Wortlaut gelesen), `grundlagen-klassifikation.md`, `modul-07-carveouts.md` §Auflösungs-Trigger
- Spec: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) — **verbatim** gelesen
  (`spec/lastenheft.md:255-290`), nicht aus der ADR oder aus den Vorrunden übernommen
- Aktive ADRs auf Kollision geprüft: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) (**Volltext** gelesen — die neue
  Herleitung von Festlegung 4 steht und fällt mit ihm),
  [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md),
  [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md),
  [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md)
- Adaptionen: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
  [`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption),
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
- Hard Rules: [`AGENTS.md`](../../AGENTS.md) §3, besonders §3.4 und §3.6
- **Vorherige Findings am gleichen Modul:** [`2026-07-28-adr-0011-proposed-review.md`](2026-07-28-adr-0011-proposed-review.md)
  (Runde 1: 2 HIGH, 6 MEDIUM, 3 LOW) und
  [`2026-07-28-adr-0011-proposed-review-runde-2.md`](2026-07-28-adr-0011-proposed-review-runde-2.md)
  (Runde 2: 3 HIGH, 7 MEDIUM, 3 LOW, 2 INFO), dazu der vorgelagerte
  [`2026-07-28-welle-09-plan-review.md`](2026-07-28-welle-09-plan-review.md)
- **Eigene Messungen dieser Sitzung** (nichts aus der ADR oder aus den Vorrunden übernommen):
  `make docs-check` → **d-check 231 Dateien / 0 Befunde**; `.claude/settings.json` gelesen
  (**zwei** registrierte Hooks: `PreToolUse`/`Bash` → Guard, **`Stop` ohne Matcher** →
  `stop-require-gates.sh`); `.claude/hooks/stop-require-gates.sh` **vollständig** gelesen (er
  schreibt `{"decision":"block"}` bzw. `{"decision":"approve"}` auf **stdout** bei Exit 0);
  `harness/tools/` gezählt → **16 Dateien** (14 `.sh` + 2 `.awk`); `harness/tools/mutate.sh`
  §Kopf gelesen (Fall-Format, fünf fail-closed-Bedingungen, GNU-`sed`-Abhängigkeit im eigenen
  Kopf deklariert); `ls -la .harness/state/` → Verzeichnis **0775**, Stempeldatei **0664**;
  `awk`-Exit-Status bei fatalem Fehler **gemessen** (GNU Awk 5.2.1 → **2**);
  **die Hook-Doku (<https://code.claude.com/docs/de/hooks>) zweimal gezielt abgerufen** — zur
  vollständigen Ereignis-Liste, zur Exit-2-Tabelle je Ereignis, zur Entscheidungskontroll-Tabelle
  und zur Parallelität

---

## Findings

### R3-1 — Die neue Ereignis-Trennung löst die Kollision **nicht** durch Konstruktion: die benannten Ersatz-Ereignisse sind selbst Entscheidungs-Kanäle, und auf den „Lauf-Grenzen" sitzt der **zweite** fail-closed Hook dieses Repos

- `kategorie`: **HIGH** (Basis MEDIUM, eine Stufe nach §Kontext-Eskalation des Reviewer-Skills —
  dieselbe Beobachtung im Gate-/Sicherheitspfad; der betroffene Hook **ist** der Gate-Nachweis)
- `quelle`: [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  (*„der Stop-Hook vergleicht den Hash"*) ·
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 · `modul-04-architektur-adrs.md` §Kernidee
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:174-177` (Setzung 1), im Verbund mit
  `:168-172` (die Prämisse „mechanisch, nicht durch Disziplin") und `:178-180` (Setzung 2)
- `befund`: Die ADR stellt richtig fest, dass eine Trennung **mechanisch** herzustellen ist
  (`:168`), und setzt dann: *„Die Erfassung meidet das Entscheidungs-Event des Guards. Sie hängt
  an den Ereignissen nach der Entscheidung (Ergebnis und Fehlschlag) und an den **Lauf-Grenzen**
  … Das löst die Kollision **durch Konstruktion** statt durch Sorgfalt."* Beides ist am
  gemessenen Bestand und an der Quelle nicht haltbar.
  (a) **Der Guard ist nicht der einzige Entscheidungs-Hook dieses Repos.** Gemessen in
  `.claude/settings.json`: neben `PreToolUse`/`Bash` ist **`Stop` ohne Matcher** registriert —
  [`.claude/hooks/stop-require-gates.sh`](../../.claude/hooks/stop-require-gates.sh), der
  Gate-Nachweis-Enforcer aus
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung).
  Er ist fail-closed und entscheidet **auf stdout bei Exit 0** (`:22-24`, `:36-42`, `:49-56`,
  `:58-60`: `{"decision":"block"}` / `{"decision":"approve"}`). `Stop` ist eine **Lauf-Grenze** —
  genau der Ort, an den Setzung 1 die Erfassung schickt. Die Kollision wird also nicht aufgelöst,
  sondern von `PreToolUse` nach `Stop` verschoben, auf denselben Kanal und in dieselbe
  Parallelität. An der Quelle am 2026-07-28 verbatim gemessen: *„Alle passenden Hooks werden
  parallel ausgeführt"*; Exit-2-Tabelle: `Stop` → *„Kann blockiert werden? **Ja** — Verhindert,
  dass Claude stoppt, setzt das Gespräch fort"*, `SubagentStop` → *„**Ja** — Verhindert, dass der
  Subagent stoppt"*; Entscheidungskontrolle: `Stop`/`SubagentStop` akzeptieren Top-Level
  `decision: "block"`. Eine Aggregationsregel für widersprüchliche Antworten zweier paralleler
  Hooks ist **nicht dokumentiert**.
  (b) **Auch die „Nach"-Ereignisse sind Entscheidungs-Kanäle.** Dieselbe Tabelle führt
  `PostToolUse` und `PostToolUseFailure` in der Zeile *„Top-Level `decision` — `decision:
  "block"`, `reason`"*. Sie können den Aufruf nicht mehr verhindern (*„Kann blockiert werden?
  Nein"*), aber ihr stdout wird bei Exit 0 als Entscheidungsdokument geparst und speist Text an
  das Modell zurück. Das stdout-Problem besteht auf den Ersatz-Ereignissen also fort; was übrig
  bleibt, ist **Setzung 2** (*„auf stdout gehört nichts"*) — eine **Disziplin**-Regel, und die
  Prämisse desselben Absatzes erklärt Disziplin für unzureichend. Der Absatz widerlegt sich damit
  auf zwölf Zeilen selbst.
  Failure-Szenario, konkret und ohne Absicht eines Beteiligten: slice-059 braucht für die
  Rollen-Achse (`agent_id`/`agent_type`) und den Wurzel-Span einen Abschluss je Lauf und
  registriert den Emitter auf `Stop`/`SubagentStop` — von Setzung 1 ausdrücklich erlaubt. Der
  Emitter ist nach Festlegung 4 in `awk` geschrieben. **Gemessen (GNU Awk 5.2.1): ein fataler
  awk-Fehler endet mit Exit-Status 2.** Ein Tippfehler in einem Feldausdruck, eine unlesbare
  Payload, ein volles Dateisystem — und der fail-**open** gemeinte Telemetrie-Hook liefert auf
  `Stop` genau den einen Exit-Code, der laut Doku *„verhindert, dass Claude stoppt"*: die Sitzung
  kann nicht mehr enden. Die Gegenrichtung ist genauso erreichbar: schreibt der Emitter im
  Fehlerfall irgendetwas auf stdout (den Span, weil die Umleitung fehlschlug; eine Diagnose), läuft
  das parallel zur `{"decision":"block"}`-Antwort des Gate-Enforcers, und wie das Werkzeug beides
  zusammenführt, ist nicht dokumentiert — der fail-closed Boden aus
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
  hängt dann an einer undokumentierten Aggregation. Beide Ausgänge sind mit der angenommenen ADR
  vereinbar, weil sie nur eine Regel dagegen stellt, keine Konstruktion. Nach *Accepted* ist der
  Satz „durch Konstruktion" nicht mehr korrigierbar ([`AGENTS.md`](../../AGENTS.md) §3.4).
- `verifizierbar`: ja, in beiden Hälften ohne Umsetzung — `cat .claude/settings.json` (zwei
  Ereignisse registriert), `grep -n "decision" .claude/hooks/stop-require-gates.sh` (vier
  Treffer, stdout), `awk 'BEGIN{nonexistent()}'; echo $?` → 2, und die Exit-2-/Entscheidungs-Tabelle
  unter <https://code.claude.com/docs/de/hooks>. Kein Gate deckt es (`docs-check` läuft netzlos und
  prüft keine Widerspruchsfreiheit).

### R3-2 — „Ein abgelehnter Aufruf hat mit `PermissionDenied` ohnehin sein eigenes Ereignis": die Quelle bindet dieses Ereignis an den Auto-Mode-Klassifikator, nicht an eine Hook-Ablehnung — die vom Guard geblockten Aufrufe fallen damit aus dem Span-Strom

- `kategorie`: **MEDIUM** (Eskalation erwogen und **nicht** vorgenommen: der Guard selbst bleibt
  unberührt; betroffen ist die *Abdeckungs-Zusage* der Erfassung, nicht der Sicherheitspfad)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („die Zusage auf das einschränken, was der Code
  hält") · `modul-15-observability.md` §Audit-Span-Schema (Incident-Frage als Erfassungs-Kriterium)
  · ADR-0011 §Re-Evaluierungs-Trigger 1 (die Quelle ist ungepinnt)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:174-177`
- `befund`: Setzung 1 begründet den Verzicht auf das Guard-Ereignis unter anderem damit, dass die
  Ablehnung ohnehin anderweitig erfasst werde: *„ein abgelehnter Aufruf hat mit `PermissionDenied`
  ohnehin sein eigenes Ereignis."* Am 2026-07-28 an der zitierten Quelle nachgeschlagen: das
  Ereignis **existiert** — die Ereignis-Tabelle führt es mit der Beschreibung *„Wenn ein Tool-Call
  vom Auto-Mode-Klassifikator abgelehnt wird"* (mit `{retry: true}` als Antwortfeld). Ob eine
  Ablehnung durch einen **`PreToolUse`-Hook** — also durch den Command-Guard dieses Repos — dasselbe
  Ereignis auslöst, steht dort **nicht**. Das „ohnehin" ist damit nicht belegt, und es trägt in der
  Konstruktion Gewicht: es ist der einzige Satz, der begründet, warum das Auslassen des
  Guard-Ereignisses keine Lücke reißt. `PostToolUse` scheidet für den Fall aus (das Tool lief nie),
  `PostToolUseFailure` ebenso (es ist nicht fehlgeschlagen, sondern verweigert worden).
  Failure-Szenario: die Incident-Frage, die dieses Repo am ehesten stellt — *„hat ein Agentenlauf
  versucht, die Host-Toolchain zu benutzen?"* — ist genau die Klasse, die der Guard blockt
  ([`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks): Go-Toolchain und
  Paketmanager). Der geblockte Versuch erzeugt keinen Span, die Folgenummer zeigt keine Lücke
  (es wurde nie eine vergeben), und slice-060 wertet einen Bestand aus, der die
  sicherheitsrelevantesten Ereignisse strukturell nicht enthält — während die ADR den Verzicht
  ausdrücklich damit begründet, dass sie erfasst *seien*.
- `verifizierbar`: ja — <https://code.claude.com/docs/de/hooks>, Ereignis-Tabelle Zeile
  `PermissionDenied`, gegen `docs/plan/adr/0011-telemetrie-erfassung-policy.md:176`. Kein Gate
  deckt es (`docs-check` läuft `--network none`).

### R3-3 — Die Folgenummer erkennt den Verlustfall nicht, für den sie eingeführt wurde: ihr Vergabezeitpunkt ist nicht festgelegt, und wer vor der Vergabe stirbt, hinterlässt keine Lücke

- `kategorie`: **MEDIUM**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 („Eine Zusage ist erst fertig, wenn benannt ist,
  was passieren müsste, damit sie bricht") ·
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
  Vorbefund R2-3 (HIGH) aus [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:228-236` (Folgepflicht 4) gegen
  `:245` (der zugehörige Mutations-Fall) und `:164-166` (der eigene harte Timeout)
- `befund`: Die Setzung lautet: *„jeder Span trägt eine je Sitzung monoton steigende Folgenummer,
  sodass eine Lücke im Bestand erkennbar ist — von dem, der ihn liest, **ohne Zutun dessen, der ihn
  schreibt**."* Der zweite Halbsatz ist die tragende Behauptung, und er ist unvollständig: **die
  Vergabe der Nummer ist selbst ein Zutun des Schreibers**. Die ADR legt nicht fest, *wann* sie
  vergeben wird, und die beiden möglichen Konstruktionen verhalten sich im namensgebenden Fall
  entgegengesetzt. (a) Nummer aus dem Bestand abgeleitet (letzte Zeile + 1) — die naheliegende
  Bauart für einen zustandslosen Per-Call-Hook: ein Emitter, der **vor** dem Schreiben stirbt
  (der von Festlegung 6 verlangte harte Timeout, ein Kill, ein `set -e`-Abbruch), vergibt keine
  Nummer; der Bestand läuft lückenlos weiter, und der Verlust ist **unsichtbar** — exakt der
  Zustand, den Runde 2 als R2-3 beschrieben hat. (b) Nummer aus einem separaten, **vor** dem
  Schreiben erhöhten Zähler: dann entsteht die Lücke, aber nur für Tode *zwischen* Erhöhung und
  Schreiben; stirbt der Emitter davor, gilt wieder (a). Die ADR sagt zu, was nur (b) teilweise
  hält, und delegiert die Wahl implizit an den Slice. Der neue Mutations-Fall (`:245`,
  *„der Emitter überspringt einen Aufruf"*) erzeugt für diese Frage zwar Druck — bleibt der
  Wächter unter (a) grün, meldet `make mutate` ihn als zahnlos —, aber er entscheidet sie nicht:
  wie „überspringen" mutiert wird, wählt der Fall-Autor, und ein Überspringen *nach* der Vergabe
  färbt ihn rot, ohne dass die Timeout-Hälfte je gemessen wurde.
  Failure-Szenario: der Emitter läuft in 3 von 400 Tool-Calls in seinen Timeout und wird
  abgebrochen, bevor er schreibt. Der Bestand trägt 397 Zeilen mit lückenlosen Nummern 1…397.
  Der Leser, dem Folgepflicht 4 die Erkennung zusagt, sieht nichts; slice-060 summiert daraus eine
  Token-Bilanz je Rolle, und die Closure-Matrix von welle-09 trägt für Block 1/Repo „Sensor". Der
  Beleg fehlt nicht — er ist unbemerkt falsch.
- `verifizierbar`: ja, am Artefakt — Volltextsuche nach einem Vergabezeitpunkt („bevor", „vor dem
  Schreiben", „reserviert") in `docs/plan/adr/0011-telemetrie-erfassung-policy.md` → kein Treffer.
  Kein Gate deckt es (`make docs-check` → 231/0 mit der Folgepflicht im Baum).

### R3-4 — Die neue Aufräum-Regel „beim Anlegen" löscht bei parallelen Sitzungen den Bestand der **laufenden** anderen Sitzung, und dieser Verlust ist für den Folgenummern-Leser gerade nicht sichtbar

- `kategorie`: **MEDIUM**
- `quelle`: `modul-15-observability.md` §Audit-Span-Schema · ADR-0011 Folgepflicht 4 (`:228-236`,
  die Sichtbarkeits-Zusage, die hier nicht greift) · Vorbefund R2-5 aus
  [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md) · Maintainability
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:109-115` (Festlegung 3, zweiter
  Aufzählungspunkt)
- `befund`: Die Regel lautet: *„Jede Sitzung schreibt in ihre eigene Datei; **beim ersten Span
  einer Sitzung** entfernt der Emitter die Bestände älterer Sitzungen."* Sie löst den
  Runde-2-Befund (kein Löschender) und führt eine Voraussetzung ein, die die ADR nicht prüft:
  dass zu jedem Zeitpunkt **höchstens eine** Sitzung schreibt. Ein Emitter kann am Dateisystem
  nicht unterscheiden, ob eine fremde Span-Datei zu einer *beendeten* oder zu einer *gerade
  laufenden* Sitzung gehört — „älter" ist eine Zeitstempel-Vermutung, kein Lebendigkeits-Signal.
  Dass parallele Läufe in diesem Repo der Normalfall und nicht die Ausnahme sind, ist
  dokumentiert: [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) §Kopf beschreibt
  ausdrücklich, dass *„parallele Gate-/Test-Läufe unbedenklich"* sein müssen, und hält dafür ein
  eigenes fail-closed Lock — im selben Verzeichnis, in das die Spans sollen. Verschärfend: der
  so entstehende Verlust ist gerade **kein** Fall für Folgepflicht 4. Gelöscht wird eine ganze
  Datei; die überlebende Sitzung schreibt danach mit ihrer nächsten Nummer weiter, und im Bestand
  fehlt ein **Präfix**, keine Lücke. Der einzige Detektor, den die ADR aufstellt, sucht Lücken.
  Failure-Szenario: In einem Terminal läuft die Implementer-Sitzung seit zwei Stunden und hat 300
  Spans geschrieben; im zweiten Terminal startet eine Review-Sitzung (dieses Repo führt Reviews
  ausdrücklich in *frischem Kontext*). Deren erster Span löscht den Bestand der noch laufenden
  Sitzung. Für den späteren Auswertungs-Slice ist die Implementer-Sitzung mit den Nummern 301 ff.
  vertreten, die ersten 300 Tool-Calls existieren nicht, und nichts im Bestand weist darauf hin —
  das Audit-Log ist lückenhaft und sieht vollständig aus, also genau der Zustand, den die ADR bei
  Folgepflicht 4 wörtlich ausschließen will.
- `verifizierbar`: ja — die Abwesenheit einer Lebendigkeits-/Sperr-Bedingung ist per Lektüre der
  Festlegung feststellbar; `sed -n '23,33p' harness/tools/mutate.sh` zeigt die Gegen-Präzedenz
  (Lock im selben `.harness/state/`). Kein Gate deckt es.

### R3-10 — Die in Runde 2 widerlegte `LH-QA-03`-Lesart ist aus slice-059 entfernt und in welle-09 stehen geblieben; die Welle widerspricht Festlegung 4 jetzt direkt

- `kategorie`: **MEDIUM** — **aus Vorrunden offen** (Rest von R2-9, dort ebenfalls MEDIUM)
- `quelle`: [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Rang 1,
  [`AGENTS.md`](../../AGENTS.md) §2) · Vorbefund R2-9 aus
  [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md) · Vorbefund F-4 aus
  [Runde 1](2026-07-28-adr-0011-proposed-review.md) · Drift-Klasse „derselbe Stand an zwei Orten"
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:189` und `:191-193` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:120-134` und `:136-144`
- `befund`: Runde 2 hat die Doppelverteilung **namentlich** gemeldet (drei Orte: slice-059 §Bezug,
  slice-059 §1, welle-09 §6). Der Diff `69cc416` zieht slice-059 an beiden Stellen sauber nach —
  gemessen: `:16-18` nennt jetzt die emittierte Zusage und `ADR-0011`, `:40` ersetzt „die schärfere
  Grenze bindet erst slice-063" durch „Sie gilt **schon hier**". `welle-09` ist im Diff **gar
  nicht enthalten** (`git show 69cc416 --name-only`), und dort steht unverändert: `:189` *„Die
  Randbedingung ist ‚keine neue Abhängigkeit', nicht ein bestimmtes Werkzeug"* — die Formel, die
  Festlegung 4 in derselben Überarbeitung durch „nichts, das installiert werden muss" **ersetzt**
  hat —, und `:191-193` *„im Repo Docker-only ([`ADR-0003`](../plan/adr/0003-go-native-binaries.md)),
  im Ziel zusätzlich [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  (`bash + git + docker`)"* — die auf das Ziel verengte Lesart, die die ADR in ihrer eigenen
  Klammer (`:146-149`) für widerlegt erklärt. Der Widerspruch ist nach Runde 3 sogar **schärfer**
  als vorher, weil die ADR jetzt eine ausformulierte Gegenposition hat.
  Failure-Szenario: der Planner, der slice-062 schneidet, liest den **Wellen**-Plan als
  maßgebliches Planungsartefakt (`AGENTS.md` §6 zeigt ihn dorthin), entnimmt ihm „im Ziel
  zusätzlich `bash + git + docker`" und behandelt die Randbedingung als reine Ziel-Anforderung —
  während die angenommene ADR sie als Repo-Grenze führt, die *schon hier* gilt. Nach *Accepted*
  stünde eine Rang-3-Quelle gegen ein Plan-Artefakt, und
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  verbietet die Reparatur über das Lastenheft.
- `verifizierbar`: ja — `grep -n "keine neue Abhängigkeit\|bash + git" docs/plan/planning/welle-09-modul-15-konformitaet.md`
  → `:189`, `:193`. Kein Gate deckt es.

### R3-5 — Die „Erlaubt"-Liste ist eine geschlossene Aufzählung ohne Plattform-Anker; `sed`/`grep` fehlen darin, während derselbe Absatz den Bestand für gedeckt erklärt, der GNU-`sed` benutzt

- `kategorie`: **LOW**
- `quelle`: `modul-07-carveouts.md` §Ziel-Form (Kriterium, das *ein anderer Mensch ohne Rückfrage*
  anwenden kann) · [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (macOS und
  Windows sind erstklassig) · ADR-0011 Festlegung 5 (`:151-160`, die Liste gilt im Ziel unverändert)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:126-130`
- `befund`: Das neue Kriterium („vorhanden vs. zu installieren") ist in seiner **Ausschluss**-Hälfte
  scharf und in seiner **Erlaubnis**-Hälfte eine Aufzählung: *„die POSIX-Basis, die der Harness
  ohnehin voraussetzt — `bash`, `awk`, Coreutils, `git`, `docker`."* `sed` und `grep` sind keine
  Coreutils (eigene Pakete) und stehen nicht in der Liste; der Bestand, den derselbe Absatz für
  „nicht betroffen" erklärt, benutzt beides — [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh)
  deklariert im eigenen Kopf sogar *„bash, coreutils, **GNU sed**"* und *„die Fälle nutzen `sed -i`
  und GNU-BRE-Escapes, sind also NICHT strikt POSIX"*. Zweitens fehlt dem Wort „vorhanden" ein
  **Plattform-Anker**: vorhanden *wo*? Auf dem Rechner des Autors ist GNU-`awk` vorhanden, auf
  einem macOS-Ziel BSD-`awk`, auf Windows keines von beidem —
  [`LH-QA-04`](../../spec/lastenheft.md#lh-qa-04--plattform-matrix) führt beide als erstklassig,
  und Festlegung 5 zieht die Liste ausdrücklich in emittierte Ziele.
  Failure-Szenario: der Implementer schreibt den Emitter mit `sed -i` (wie jeder Mutations-Fall
  dieses Repos); ein Reviewer misst gegen die Aufzählung und meldet einen Verstoß, ein zweiter
  liest „POSIX-Basis" als Gattungsbegriff und sieht keinen — zwei Leser, zwei Grenzen, und die ADR
  entscheidet nicht. Die schärfere Variante liegt hinter Festlegung 5: die **Redaktion** ist der
  sicherheitstragende Teil dieser ADR; eine mit GNU-spezifischer Regex-Semantik gebaute
  Allowlist-Filterung, die auf einem BSD-Ziel anders greift, lässt genau das durch, was sie
  zurückhalten soll — und „vorhanden" hat dem Autor nicht widersprochen.
- `verifizierbar`: ja — `sed -n '32,36p' harness/tools/mutate.sh` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:126-130`. Kein Gate deckt es.

### R3-6 — Das neue Kriterium lässt die Per-Call-Container-Bauart durch, die [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) aus Latenzgründen verworfen hat — und die Abhilfe der 50-ms-Schwelle greift bei Startup-Kosten nicht

- `kategorie`: **LOW**
- `quelle`: [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) §Option B (verbatim:
  *„`docker run` pro Bash-Call (~300–700 ms Kaltstart) — der Hook feuert ständig; interaktiv zu
  zäh"*) · [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) / [`CLAUDE.md`](../../CLAUDE.md)
  (Docker-only als Repo-Reflex) · ADR-0011 §Re-Evaluierungs-Trigger (`:279-284`)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:126-130` (`docker` in der
  Erlaubt-Liste) gegen `:279-284` (die Latenz-Schwelle)
- `befund`: Die Erlaubt-Liste führt `docker`, weil es vorhanden ist — richtig gemessen, aber die
  Grenze „vorhanden vs. zu installieren" ist gegenüber **Latenz** blind, und genau dort hat
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) seine Option B begraben. Die ADR zitiert
  ADR-0004 zwei Zeilen vorher als *„die bindende Quelle"*, übernimmt aber nur dessen
  POSIX-Basis-Satz, nicht dessen Latenz-Ausschluss. Verstärkend wirkt der Repo-Reflex: `CLAUDE.md`
  und [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) schreiben „Docker-only, keine
  Host-Toolchain" — ein Implementer, der die Erlaubt-Liste liest, hat für einen Container-Emitter
  gleich zwei zustimmende Quellen. Die Sicherung, die die ADR dagegen stellt, ist die
  Re-Evaluierungs-Schwelle — und ihre **Abhilfe** passt nicht auf den Fehler: *„überschreitet der
  Aufschlag je Tool-Call 50 ms im Median, ist nicht die Grenze zu erhöhen, sondern **der Umfang zu
  senken**."* Bei einem Kaltstart-dominierten Aufschlag senkt kein Umfang irgendetwas; die Kosten
  hängen an der Bauart, nicht an der Feldzahl.
  Failure-Szenario: slice-059 misst wie geplant, baut den Emitter als `docker run` (von
  Festlegung 4 gedeckt), misst 300–700 ms je Aufruf gegen eine Schwelle von 50 ms, und die einzige
  von der ADR vorgesehene Reaktion — Umfang senken — bringt den Wert um Größenordnungen nicht unter
  die Grenze. Der Slice steht dann vor einer Entscheidung, die die ADR getroffen zu haben
  behauptet, und zieht die in slice-059 §4 vorgesehene Rückführungskante.
- `verifizierbar`: ja — `sed -n '46,52p' docs/plan/adr/0004-durchsetzungs-emission.md` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:126-130` und `:279-284`. Kein Gate deckt es.

### R3-7 — Festlegung 4 erklärt [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) pauschal zur bindenden Quelle für die Erfassung; ADR-0004 entscheidet dort auch die Emission, die Festlegung 5 dem CR vorbehält

- `kategorie`: **LOW**
- `quelle`: [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler) ·
  [`AGENTS.md`](../../AGENTS.md) §2 (aktive ADRs sind Rang 3 und normativ) · Vorbefund F-7 aus
  [Runde 1](2026-07-28-adr-0011-proposed-review.md) (Fait-accompli-Klasse)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:140-142` gegen `:151-157`
  (Festlegung 5)
- `befund`: Die neue Herleitung sagt: *„Für die Durchsetzungsschicht — und **die Erfassung gehört
  dorthin** — ist [ADR-0004] die bindende Quelle."* Für den beabsichtigten Zweck (die
  POSIX-Basis-Linie) reicht ein Verweis auf ADR-0004s Begründungssatz; die gewählte Formulierung
  ordnet die Erfassung dagegen **einer anderen aktiven ADR als Ganzes** unter. ADR-0004 entscheidet
  dort aber nicht nur die Sprache, sondern in §Entscheidung 1 auch *„Emission ins Zielrepo: **ja**"*
  und in §Konsequenzen *„Durchsetzung ‚immer dabei'"*. Genau das behält Festlegung 5 dem Change
  Request vor (*„das **OB** der Emission entscheidet der Change Request"*). Zwei aktive Quellen
  sagen dann Verschiedenes über dasselbe *Ob*. Milderung, die ich ausdrücklich festhalte: Festlegung
  5 ist unmissverständlich und steht im selben Dokument sieben Zeilen weiter — die Fehllesart ist
  möglich, nicht naheliegend. Eine zweite Spannung derselben Zuordnung bleibt unaufgelöst: nach
  Festlegung 6 ist die Erfassung gerade **nicht** von der Art des Guards (*„der Guard verhindert
  … die Telemetrie beobachtet"*), während Festlegung 4 sie in dessen Schicht einordnet, um sich
  dessen Randbedingung zu leihen.
  Failure-Szenario: der CR-/ADR-Autor von slice-062 prüft, ob das *Ob* der Emission überhaupt noch
  offen ist, findet in ADR-0011 die Zuordnung zur Durchsetzungsschicht und in ADR-0004 deren
  Emissions-Entscheidung, und behandelt den von
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  verlangten vorgelagerten Vorgang als Formsache.
- `verifizierbar`: ja — `sed -n '29,33p' docs/plan/adr/0004-durchsetzungs-emission.md` gegen
  `docs/plan/adr/0011-telemetrie-erfassung-policy.md:140-142`. Kein Gate deckt es.

### R3-8 — welle-09 führt ADR-0011 als „nach der zweiten Runde"; Index und Slice wurden nachgezogen, die Welle nicht

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §5 („Neue ADRs aktualisieren den ADR-Index") ·
  Drift-Klasse „derselbe Stand an zwei Orten, einer altert" · Vorbefund F-10 aus
  [Runde 1](2026-07-28-adr-0011-proposed-review.md)
- `pfad`: `docs/plan/planning/welle-09-modul-15-konformitaet.md:172-175` gegen
  [`docs/plan/adr/README.md`](../plan/adr/README.md):19 („**Proposed** (Runde 3)")
- `befund`: Der in Runde 2 ergänzte Rückverweis der Welle nennt den Rundenstand mit: *„Status
  **Proposed**, nach der zweiten Runde."* Der Diff `69cc416` aktualisiert den ADR-Index auf
  „(Runde 3)" und slice-059 auf die neue Randbedingung, lässt die Welle aber unberührt. Der
  Rundenstand an drei Orten driftet damit erneut auseinander — dieselbe Klasse wie F-10 (Runde 1)
  und R2-11 (Runde 2), nur mit vertauschten Rollen: diesmal ist der Index aktuell und das
  Plan-Artefakt alt.
  Failure-Szenario: wer über die Welle einsteigt (das Planungs-Artefakt, auf das §4 zeigt), hält
  den Runde-2-Stand für den aktuellen, sucht die Runde-3-Änderungen nicht und beurteilt die
  Entsperr-Bedingung für slice-059 gegen eine Fassung, die es nicht mehr gibt.
- `verifizierbar`: ja — `grep -n "zweiten Runde" docs/plan/planning/welle-09-modul-15-konformitaet.md`
  → `:173`; `grep -n "Runde 3" docs/plan/adr/README.md` → `:19`. Kein Gate deckt es.

### R3-9 — Der mit `69cc416` committete Runde-2-Report endet mit Werkzeug-Markup (`</content>` / `</invoke>`) — dritter Fall derselben Klasse im Review-Korpus

- `kategorie`: **LOW**
- `quelle`: `modul-10-review-harness.md` §Ablage (der Report ist das Prüf-Artefakt) ·
  [`AGENTS.md`](../../AGENTS.md) §3.6 (kein Beleg, dessen Vollständigkeit man nicht sehen kann) ·
  Maintainability
- `pfad`: `docs/reviews/2026-07-28-adr-0011-proposed-review-runde-2.md:695-696` (mit dem
  Diff `69cc416` neu in den Baum gekommen)
- `befund`: Die letzten beiden Zeilen des Reports sind `</content>` und `</invoke>` — Reste eines
  Werkzeug-Aufrufs, die in das committete Dokument gerutscht sind. Der Report ist zugleich der
  Beleg, auf den sich die `Geschichte`-Tabelle der ADR (`:295`) und die Übergabe an den ADR-Autor
  stützen. Gemessen ist es kein Einzelfall: `grep -n "</content>" docs/reviews/*.md` liefert drei
  Treffer — [`2026-07-18-slice-004a-review.md`](2026-07-18-slice-004a-review.md):177,
  [`2026-07-22-slice-033-review.md`](2026-07-22-slice-033-review.md):220 und dieser. Nach der
  §Kontext-Eskalation des Reviewer-Skills ist die dritte Wiederholung derselben Klasse ein
  **Steering-Loop-Signal**: kein Sensor sieht sie (`make docs-check` → 231/0 mit allen drei im
  Baum), also wiederholt sie sich.
  Failure-Szenario: ein späterer Leser (oder ein Verifier, der die Befundzahlen der
  `Geschichte`-Zeile gegen den Report prüft) sieht hinter dem letzten Verdikt-Absatz Markup, das
  nicht dorthin gehört, und kann ohne git-Archäologie nicht entscheiden, ob das Dokument
  vollständig ist oder beim Schreiben abgeschnitten wurde.
- `verifizierbar`: ja — `grep -n "</content>\|</invoke>" docs/reviews/*.md` → drei Dateien.
  Kein Gate deckt es (`docs-check` prüft Links/Anker/IDs, nicht Fremd-Markup).

### R3-11 — [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht weiterhin nur im Bezug-Feld und nirgends im Body — dritte Runde, derselbe Befund

- `kategorie`: **LOW** — **aus Vorrunden offen** (F-11 Runde 1 → R2-12 Runde 2 → hier)
- `quelle`: `modul-04-architektur-adrs.md` §Ziel-Form („Der Kontext *referenziert* die Anforderung")
  · Vorbefunde F-11 und R2-12
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:11-12`
- `befund`: Volltextsuche: `grep -n "LH-QA-01" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → **nur `:11`**. Der Abschnitt, der die Anforderung tragen würde („Was hier bewusst NICHT steht",
  `:249-256`), begründet die Streichungen weiterhin ausschließlich mit
  [`AGENTS.md`](../../AGENTS.md) §3.6. Der Diff `69cc416` hat den Body an fünf Stellen angefasst
  und diese nicht. Dass derselbe Befund die dritte Runde übersteht, ist selbst die Beobachtung:
  ein Punkt, den kein Sensor sieht und den drei Überarbeitungen nicht erreichen.
  Failure-Szenario: eine spätere Änderung an
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) löst über
  das Bezug-Feld eine Nachzieh-Prüfung von ADR-0011 aus; der Prüfende findet außer der Kopfzeile
  keine Stelle, an der die Anforderung wirkt, und kann weder „betroffen" noch „unbetroffen" belegen.
- `verifizierbar`: ja — `grep -n "LH-QA-01" docs/plan/adr/0011-telemetrie-erfassung-policy.md`
  → nur `:11`. Kein Gate deckt es.

### R3-12 — Das Zustands-Verzeichnis bleibt gruppenschreibbar; entschieden ist weiterhin nur der Datei-Modus

- `kategorie`: **INFO** — **aus Vorrunden offen** (unveränderter Rest von R2-14)
- `quelle`: Vorbefund R2-14 aus [Runde 2](2026-07-28-adr-0011-proposed-review-runde-2.md) ·
  ADR-0011 Festlegung 3 (`:106-108`)
- `pfad`: `docs/plan/adr/0011-telemetrie-erfassung-policy.md:106-108`
- `befund`: Eigene Messung 2026-07-28 bestätigt die Zahlen der ADR: `.harness/state/` ist
  `drwxrwxr-x` (0775), die Stempeldatei `-rw-rw-r--` (0664). Der Diff ändert an diesem Punkt
  nichts. Ein `0600`-Span in einem `0775`-Verzeichnis ist gegen Mitlesen geschützt und gegen
  Entfernen oder Unterschieben nicht — Löschen hängt am Schreibrecht des **Verzeichnisses**. Der
  Befund bleibt INFO, weil Festlegung 3 dritter Punkt („Kein Beleg-Status") die
  Integritäts-Anforderung ausdrücklich absenkt. **Neu relevant** ist er nur im Verbund mit R3-4:
  die dort beschriebene Löschung fremder Bestände wird durch die Verzeichnis-Rechte nicht
  begrenzt.
- `verifizierbar`: ja — `ls -ld .harness/state/`. Kein Gate deckt es.

## Negativbefunde

### Runde-2-Befunde, die **sauber gelöst** sind

- geprüft, ohne Befund: **R2-1 + R2-10 (HIGH/MEDIUM, die zu weite Randbedingung) sind gelöst — und
  die neue Herleitung hält am Wortlaut beider Quellen.** Ich habe beide selbst gelesen, nicht aus
  der ADR übernommen. (a) [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  verbatim (`spec/lastenheft.md:268-276`): die „keine Host-Sprachlaufzeit"-Klammer steht im Satz
  *„die Laufzeit **beim Bootstrap** braucht nur git + docker"*, und die Messmethode lautet
  *„Smoke: Binary auf frischem System mit nur git + docker → Bootstrap grün"* — die ADR-Aussage
  „das meint die **Nutzer**-Laufzeit" ist am Wortlaut korrekt, ebenso das übernommene Zitat für
  die emittierte Seite (*„Emittierte Ziel-Repos bleiben make/docker-getrieben."*). (b)
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) §Entscheidung 2 verbatim: *„`awk` ist
  POSIX-Basis (überall vorhanden, wo die bash-Hooks laufen) — **kein neuer Dep**"*, §Konsequenzen:
  *„emittierter Ziel-Harness bleibt auf `bash + git + docker` (awk POSIX-Basis)"*. Die Linie, auf
  die sich Festlegung 4 beruft, existiert dort wirklich und in dieser Bedeutung. (c) Die
  Selbst-Treffer-Prüfung ist ebenfalls korrekt: `harness/tools/` enthält **16** Dateien (14 `.sh`
  + 2 `.awk`), dazu die zwei Hooks — die von der ADR genannte Zahl stimmt, und unter der neuen
  Grenze ist keines davon betroffen. Beanstandet werden nur zwei **Ränder** der Erlaubnis-Hälfte
  (→ R3-5, R3-6) und die zu breite Zuordnung (→ R3-7), **nicht** die Grenze selbst: sie ist die
  richtige Achse, sie ist an der richtigen Quelle verankert, und sie trifft den eigenen Bestand
  nicht mehr. Bemerkenswert und ausdrücklich anzuerkennen: die ADR glättet die zwei Fehlgriffe
  nicht, sondern führt sie im Text (`:146-149`) und in der `Geschichte` als solche.
- geprüft, ohne Befund: **R2-6 (die leere Allowlist als unbegründete Abweichung) ist gelöst.**
  `modul-15-observability.md:33-34` verlangt für den Mindestsatz *„jede Abweichung davon
  begründest du"* — mehr nicht; ein Nachweis im Sinne eines Sensors ist dort **nicht** gefordert.
  Festlegung 1.3 leistet jetzt genau das Verlangte: sie **benennt** die Abweichung als solche
  (*„leer zu starten weicht davon ab"*), gibt eine inhaltliche Begründung (die Erfassungsfläche
  wüchse um `Write`/`Edit`-Payloads, also um Datei-Inhalte), grenzt sie gegen Regel 4 ab (*„die
  gilt für nicht erschließbare Felder — dieses hier ist erschließbar und wird bewusst nicht
  erfasst"*) und verortet ihre Fortschreibung im `MR`-Eintrag. Der Runde-2-Vorwurf „eine
  Abweichungs-Begründung ohne Auslöser" trifft nicht mehr zu. Die verbleibende Spannung zu
  Festlegung 1.1 („beide Listen gelten") ist durch die ausdrückliche Deklaration aufgelöst und
  wird hier **nicht** als Befund geführt.
- geprüft, ohne Befund: **R2-4 (die Fail-open-Fitness-Function behauptete mehr, als bats messen
  kann) ist mustergültig gelöst.** Die Zeile (`:247`) sagt jetzt ausdrücklich, was sie **nicht**
  prüft: *„**Die Wirkung im Werkzeug** (blockt ein Exit-Code den Tool-Call? was tut sein Timeout?)
  prüft dieser Sensor **nicht** — sie gehört zur Messung im Slice und ist dort zu belegen, nicht
  hier zu behaupten."* Das ist exakt die von [`AGENTS.md`](../../AGENTS.md) §3.6 verlangte Form
  („die Zusage auf das einschränken, was der Code hält"), und der Rest-Gegenstand (Exit ≠ 0 und
  stdout verändern das Ergebnis des aufrufenden Skripts nicht) ist in bats real rot zu bekommen.
- geprüft, ohne Befund: **R2-7 (falsche Quadranten-Kennzeichnung) ist gelöst.** Beide beanstandeten
  Trigger tragen jetzt *feedforward*: `:273` *„(feedforward — ein CR ist ein menschlicher Vorgang,
  kein Sensor)"* und `:279` *„(feedforward, bis ein Slice den Sensor baut)"*. Gegen
  `grundlagen-klassifikation.md` §Quadranten geprüft: **kein** Trigger der ADR behauptet mehr einen
  Sensor, den es nicht gibt. Alle fünf Kennzeichnungen sind jetzt ehrlich.
- geprüft, ohne Befund: **R2-8 (die zwei Schein-Schwellen) ist gelöst.** Die Latenz-Schwelle steht
  jetzt **hier** und ist eine Zahl (*„50 ms im Median"*, `:281`) mit ausgesprochener Herkunft
  (*„Die Zahl ist eine Setzung, keine Messung"*) und einer Änderungsregel (*„Wer sie ändert, ändert
  sie hier — nicht im Skript"*). Sie ist nach `modul-07-carveouts.md` §Ziel-Form **messbar** — ein
  Dritter kann den Aufschlag je Tool-Call mit und ohne Hook erheben und den Median bilden, ohne
  rückzufragen. Der Allowlist-Trigger ist von „dauerhaft" auf ein **Ereignis** umgestellt
  (*„nach dem ersten Auswertungs-Slice (060)"*, `:285`). Beide sind ehrlich als feedforward
  gekennzeichnet, also wird nichts behauptet, was nicht getragen wird. Die verbleibende Frage
  „wer misst?" ist damit **beantwortet** (der Leser des Triggers, im Slice 060) und wird nicht als
  Befund geführt; die inhaltliche Schwäche der 50-ms-Zeile liegt woanders (→ R3-6, die Abhilfe
  passt nicht auf eine Startup-dominierte Bauart).
- geprüft, ohne Befund: **R2-13 (asymmetrische Contra-Spalte von C) ist gelöst.** Die C-Zeile führt
  jetzt beide Kosten, die die ADR anderswo als ihre größten benennt: *„**C erzeugt die
  Sicherheitsfläche, die A und E gar nicht erst haben** — jede Erweiterung der Allowlist ist eine
  Einzelfall-Abwägung, und diese Pflege endet nie."* Die von Runde 2 beanstandete Asymmetrie
  gegenüber A/D/E existiert nicht mehr.
- geprüft, ohne Befund: **R2-11 (ADR-Index) ist gelöst.**
  [`docs/plan/adr/README.md`](../plan/adr/README.md):19 führt
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) nicht mehr, ersetzt
  „Schema-Minimum" durch „Schema-**Policy** mit leerer Start-Allowlist" und nennt zusätzlich
  fail-**open** und den Rundenstand. Der Index verspricht jetzt, was die ADR hält. Dass er
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) aus dem Bezug-Feld nicht mitführt, ist keine
  Regelverletzung (die Index-Spalte führt Anforderungen; ADR-0004 steht dort als Zusatz) und wird
  **nicht** als Finding geführt.
- geprüft, ohne Befund: **R2-9 ist in seiner slice-059-Hälfte gelöst.** Gemessen an `69cc416`:
  §Bezug nennt jetzt die *emittierte* Zusage statt „bash+awk, keine neue Abhängigkeit" und
  verweist auf ADR-0011 samt der Bedingung, dass der Slice bis *Accepted* in `open/` bleibt; §1
  ersetzt „die schärfere Grenze bindet erst slice-063" durch „Sie gilt **schon hier**" und nennt
  den eigenen früheren Satz als widerlegt. Offen ist allein die **welle-09**-Hälfte (→ R3-10).

### Sonstige geprüfte Bereiche ohne Befund

- geprüft, ohne Befund: **die Ereignis-Aussagen der Festlegung 6 sind an der Quelle bestätigt —
  die Ereignisse existieren wirklich.** Eigener Abruf von <https://code.claude.com/docs/de/hooks>
  am 2026-07-28: die dokumentierte Ereignis-Liste führt `PostToolUse` (*„Nach einem erfolgreichen
  Tool-Call"*), **`PostToolUseFailure`** (*„Nachdem ein Tool-Call fehlschlägt"*) und
  **`PermissionDenied`** als **eigenständige** Ereignisse, dazu `PostToolBatch`, `SubagentStart`,
  `SubagentStop`, `Stop`, `SessionStart`, `SessionEnd`. Die ADR erfindet also **kein** Ereignis;
  „ein Nach-Event mit dem Tool-Ergebnis und ein eigenes Fehlschlag-Event" trifft zu, und die in
  Runde 1 dreifach bestätigten Kontext-Aussagen (`tool_use_id`, `transcript_path`, Subagenten mit
  `agent_id`/`agent_type`, leerer Matcher = alle Tools) sind unverändert im Text und wurden nicht
  angetastet. Beanstandet wird ausschließlich, was aus der Ereignis-**Wahl** folgt (→ R3-1) und
  eine überdehnte Abdeckungs-Aussage zu `PermissionDenied` (→ R3-2) — **nicht** die Existenz.
- geprüft, ohne Befund: **Setzung 2 ist inhaltlich richtig und die schärfste neue Aussage der
  Fassung.** *„Ihr Ausgabekanal ist die Span-Datei; auf stdout gehört nichts, auch keine
  Diagnose"* ist am gemessenen Verhalten korrekt (stdout ist bei Exit 0 auf **allen** relevanten
  Ereignissen der Auswertungs-Kanal) und beschreibt die einzige Regel, die real trägt. Der Befund
  R3-1 richtet sich **nicht** gegen diese Setzung, sondern gegen die Behauptung, Setzung 1 mache
  sie durch Konstruktion entbehrlich.
- geprüft, ohne Befund: **der neue Mutations-Fall ist im realen Harness ausführbar.**
  [`harness/tools/mutate.sh`](../../harness/tools/mutate.sh) §Kopf und der Bestand in
  `test/mutations/` (durchgezählt, u. a. `09-treiber-failure-form.sh`,
  `31-enforce-gitignore-selbstblockade.sh`) zeigen das Format: ein Fall-Skript patcht eine
  Zieldatei in der isolierten Kopie, `# expect:` benennt den rot erwarteten Wächter, die bats-Stufe
  ist zulässig. Ein Fall *„der Emitter überspringt einen Aufruf"* ist damit **bauartlich**
  umsetzbar; beanstandet wird nur, dass er die tragende Hälfte der Zusage nicht erzwingt
  (→ R3-3), nicht seine Ausführbarkeit.
- geprüft, ohne Befund: **Fitness-Function-Zeilen 1–5 sind red-fähig, und die Runde-1-Streichungen
  stehen unverändert.** Zeilen 1–3 (Pflicht-Feld, Allowlist, Ablageort) sind in den Vorrunden
  geprüft und durch diesen Diff nicht verändert; Zeile 5 (`0600` unabhängig von den
  Verzeichnis-Rechten) ist in bats direkt beobachtbar; der Abschnitt „Was hier bewusst NICHT steht"
  (`:249-256`) führt beide gestrichenen Tautologien samt `--exclude-standard`-Mechanismus fort.
  Es ist **keine** neue tautologische Zeile hinzugekommen.
- geprüft, ohne Befund: **Kollision mit aktiven ADRs — weiterhin keine.**
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) bindet den Tool-Build (Cross-Compile, kein
  Host-`go`) und wird von einem Hook-Skript nicht berührt;
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md) trägt die bash/awk-Bauart, an die
  Festlegung 4 jetzt korrekt anknüpft;
  [`ADR-0006`](../plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) und
  [`ADR-0007`](../plan/adr/0007-bootstrap-phasen.md) sind unberührt. Beanstandet wird die
  **Breite** einer Zuordnung (→ R3-7) und ein von ADR-0004 nicht übernommener Ausschluss
  (→ R3-6), kein Widerspruch in der Sache.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.4 und §3.5.** Die Überarbeitung
  betrifft eine *Proposed*-ADR, überschreibt keine *Accepted*-ADR, beansprucht kein *Supersedes*
  und lockert kein Gate — `.claude/settings.json` ist im Diff **nicht** enthalten (gemessen),
  Guard und Stop-Hook sind unverändert. Der Status ist nirgends vorgreifend gesetzt: Dokument
  (`:3`) und Index führen **Proposed**, slice-059 bleibt in `open/` und nennt die Bedingung selbst.
- geprüft, ohne Befund: **[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  zum jetzigen Zeitpunkt.** `git show 69cc416 --name-only` → vier Dateien, **kein**
  `spec/lastenheft.md`. Die ADR ändert kein `LH-*`, sie referenziert nur; der CR bleibt bei
  slice-062 verortet und behält mit dem *Ob* einen echten Gegenstand (die Randbemerkung zur
  Zuordnungs-Breite steht als R3-7).
- geprüft, ohne Befund: **[`MR-005`](../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption).**
  Die ADR legt weiterhin keinen Ablageort für ausführbare Tools fest; slice-059 verortet den
  Emitter korrekt unter `harness/tools/`.
- geprüft, ohne Befund: **Form nach Modul 4 und Vorlage.** Alle Kopf-Felder vorhanden (Status ·
  Datum · Autor · Bezug · Schärft); Body-Blöcke vollständig und in Vorlagen-Reihenfolge (Kontext ·
  Entscheidung · Verglichene Alternativen · Konsequenzen · Fitness Function ·
  Re-Evaluierungs-Trigger · Geschichte); **fünf** Alternativen (≥ 3 nach §Ziel-Form), jede mit Pro
  **und** Contra; Konsequenzen führen Positiv, Negativ und vier Folgepflichten getrennt; kein
  Template-Hinweis-Block. Kein Formmangel.
- geprüft, ohne Befund: **die `Geschichte`-Tabelle.** Die neue Zeile (`:295`) führt Datum, Ereignis
  („Überarbeitet (Runde 3), weiter **Proposed**"), den Verweis auf den Runde-2-Report mit
  Befundzahlen und benennt die drei HIGH **inhaltlich** als eigene Fehler — einschließlich des
  Satzes, dass alle drei von der eigenen Runde-2-Fassung erzeugt wurden. Die Runde-2-Zeile bleibt
  **unverändert** darunter stehen; nichts wurde umgeschrieben. Das entspricht der Vorlage und der
  Präzedenz aus [`ADR-0010`](../plan/adr/0010-hexagonal-arch-realisierung.md). Beanstandet wird
  allein, dass der Rundenstand in welle-09 nicht mitwandert (→ R3-8).
- geprüft, ohne Befund: **Doc-Gate-Regeln.** Eigener Lauf dieser Sitzung: `make docs-check` →
  **d-check 231 Dateien, 0 Befunde**. Alle `LH-`/`ADR-`/`MR-`-Kennungen der überarbeiteten ADR sind
  als Link geführt, die relativen Tiefen aus `docs/plan/adr/` stimmen, die neu genannten
  Inline-Pfade existieren.
- geprüft, ohne Befund: **Festlegung 2 (Allowlist statt Denylist) ist vom Diff nicht berührt und
  bleibt der tragfähigste Teil der ADR.** Die Begründung („eine Denylist kann unter keiner
  **realen** Lücke rot werden") hält und ist mit der
  [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)-Linie
  konsistent.
- geprüft, ohne Befund: **Festlegung 5 (Ob/Wie) und der Ort aus Festlegung 3** sind vom Diff nicht
  berührt und in den Vorrunden bereits als tragfähig bzw. richtig hergeleitet bestätigt; die
  [`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)-Kollision
  ist real und der gewählte Ort korrekt. Beanstandet wird nur die **neue Auflage** dazu (→ R3-4).
- geprüft, ohne Befund: **R2-15 (E ist Alternative und Startzustand zugleich) ist unverändert und
  bleibt eine Einordnung ohne Handlungsdruck** — Runde 2 hat sie ausdrücklich nicht als Formmangel
  geführt, und der Diff ändert an der Konstruktion nichts.
- geprüft, ohne Befund: **die Annahme im Kontext (`:54-56`) und `Schärft: —`** sind unverändert und
  in Runde 1 geprüft.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 4 |
| LOW | 6 |
| INFO | 1 |

**Herkunft der Befunde.** **9** von 12 existieren erst seit der dritten Fassung (R3-1 bis R3-9) —
davon **vier** unmittelbar in den drei konstruktiven Eingriffen (R3-1/R3-2 in der
Ereignis-Trennung, R3-3 in den Folgenummern, R3-4 in der Aufräum-Regel) und **drei** an den
Rändern des neuen POSIX-Kriteriums (R3-5, R3-6, R3-7). **3** sind unerledigte Reste aus den
Vorrunden, die der Diff nicht angefasst hat (R3-10 = Rest von R2-9, R3-11 = F-11/R2-12,
R3-12 = R2-14).

**Trend über drei Runden:** HIGH 2 → 3 → **1**; das Muster „der Fix erzeugt den nächsten HIGH"
ist **abgeschwächt, aber nicht verschwunden** — der verbliebene HIGH sitzt wieder im größten
Eingriff dieser Runde.

## Verdikt

**Kann ADR-0011 in dieser Fassung auf *Accepted* gesetzt werden: nein — aber knapp, und aus einem
einzigen Grund.**

**Was blockiert.** Genau **ein** HIGH, und es ist eng umrissen. **R3-1:** Festlegung 6.1 sagt zu,
die Kollision zwischen fail-open-Telemetrie und fail-closed-Durchsetzung *„durch Konstruktion"* zu
lösen, indem die Erfassung das Entscheidungs-Event des Guards meidet. Am gemessenen Bestand trägt
das nicht: dieses Repo hat einen **zweiten** Entscheidungs-Hook, `stop-require-gates.sh` auf dem
Ereignis `Stop` — der Gate-Nachweis-Enforcer aus
[`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)/[`MR-003`](../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung),
der bei Exit 0 auf **stdout** `{"decision":"block"}` schreibt. `Stop` ist eine der drei
Ereignis-Klassen, an die Setzung 1 die Erfassung ausdrücklich schickt („die Lauf-Grenzen"), und
`Stop`/`SubagentStop` sind laut Quelle **blockierbar** (Exit 2 verhindert das Stoppen). Auch die
„Nach"-Ereignisse sind keine stumme Zone: `PostToolUse`/`PostToolUseFailure` akzeptieren
Top-Level `decision`, ihr stdout wird also ebenfalls ausgewertet. Was von der mechanischen
Trennung bleibt, ist Setzung 2 — eine **Regel**, während der eigene Absatz zwölf Zeilen vorher
festhält, dass Regeln nicht genügen. Die Konstellation ist nicht theoretisch: der von Festlegung 4
erlaubte `awk` endet bei einem fatalen Fehler **gemessen mit Exit 2** — auf `Stop` genau der Code,
der den Lauf am Beenden hindert, aus einem Hook, der fail-open sein soll.

**Was das *nicht* ist.** Kein Architektur-Fehler und keine falsche Wahl. Die Entscheidung (lokale
Erfassung, Allowlist, Ablage außerhalb des versionierten Baums, fail-open im Betrieb) trägt; der
Blocker ist eine **Reichweiten-Aussage** über einen Mechanismus — welche Ereignisse „Entscheidungs-
Event" sind und wodurch die Trennung wirklich hergestellt wird.

**Antwort auf Leitfrage 1 — tragen die drei Eingriffe, oder sind sie anders formuliert?**
Differenziert, und das ist der ehrliche Befund dieser Runde:

- **Das POSIX-Basis-Kriterium (Festlegung 4) trägt.** Es ist die richtige Achse, es ist an der
  richtigen Quelle verankert ([`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md), verbatim
  geprüft), die verworfene Herleitung über die Bootstrap-Klausel ist korrekt als falsch benannt
  (ebenfalls verbatim geprüft), und die 16 eigenen Host-Skripte samt Guard und Stop-Hook sind
  wirklich nicht mehr getroffen. Es lässt an zwei Rändern etwas durch (`docker` als
  Per-Call-Container, R3-6; keine Plattform-/Werkzeug-Präzision, R3-5) und ordnet sich einer
  fremden ADR breiter unter als nötig (R3-7) — alles LOW.
- **Die Ereignis-Trennung (Festlegung 6.1/6.2) verschiebt die Kollision, statt sie aufzulösen**
  (R3-1, HIGH), und stützt sich zusätzlich auf eine an der Quelle nicht belegte Abdeckungs-Aussage
  zu `PermissionDenied` (R3-2, MEDIUM). Die *Richtung* ist richtig — Setzung 2 ist die schärfste
  Aussage der ganzen Fassung —, nur die Begründung „durch Konstruktion" ist es nicht.
- **Die Folgenummern sind ein echter Fortschritt mit einer Lücke an der entscheidenden Stelle**
  (R3-3, MEDIUM): Sie verlagern die Erkennung wirklich zum Leser, aber nur, wenn die Nummer **vor**
  der riskanten Arbeit vergeben wird — und genau das legt die ADR nicht fest. Für den Fall, der die
  Setzung ausgelöst hat (Tod im eigenen Timeout), entsteht unter der naheliegenden Bauart **keine**
  Lücke. Der zugehörige Mutations-Fall ist ausführbar und erzeugt Druck, entscheidet die Frage aber
  nicht.
- **Die Aufräum-Regel schließt die Runde-2-Lücke und öffnet eine parallele** (R3-4, MEDIUM):
  „Löschen beim Anlegen" setzt voraus, dass nur eine Sitzung schreibt — in einem Repo, das
  Parallelität andernorts ausdrücklich absichert.

**Antwort auf Leitfrage 2 — konvergiert das?** **Ja, messbar.** Von den 15 Runde-2-Befunden sind
**7 MEDIUM/LOW in der Sache gelöst** (R2-4, R2-6, R2-7, R2-8, R2-11, R2-13 und die slice-059-Hälfte
von R2-9), zwei HIGH sind an ihrer Wurzel behoben (R2-1/R2-10), einer ist wesentlich abgeschwächt
(R2-3 → R3-3), einer ist verschoben statt gelöst (R2-2 → R3-1), und **drei** sind schlicht nicht
angefasst worden (R3-10, R3-11, R3-12). Nichts davon ist eine Umformulierung ohne Mechanismus —
das Muster, das Runde 2 dreimal fand („der Wortlaut wurde präziser, der Mechanismus blieb aus"),
tritt in dieser Fassung **nicht** mehr auf. Was diese Runde neu findet, entsteht durch **zu weit
gefasste Zusagen über real eingebaute Mechanismen**, nicht durch fehlende Mechanismen. Das ist
eine andere und deutlich spätere Fehlerklasse.

**Trägt die ADR jetzt genug, um slice-059 zu entsperren? Nein**, aber der Abstand ist klein und
benennbar: der Slice müsste heute ein Ereignis wählen, für das die ADR eine Eigenschaft zusagt, die
sie nicht hält (R3-1), und würde dabei auf denselben Kanal geraten wie der Gate-Nachweis. Alles
Übrige — Schema-Policy, Redaktions-Richtung, Ablageort, Modus, Fehlerrichtung, Randbedingung —
ist entschieden und belastbar.

**Was ausdrücklich trägt und nicht anzufassen ist.** Festlegung 2 (Allowlist statt Denylist) bleibt
der stärkste Teil. Festlegung 4 ist nach zwei Fehlgriffen an der richtigen Quelle angekommen und
trifft den eigenen Bestand nicht mehr. Setzung 2 (nichts auf stdout) ist am gemessenen Verhalten die
einzige Regel, die die Trennung wirklich hält. Die Fitness-Function-Zeile zu fail-open ist zum
Vorbild dafür geworden, wie eine Zusage ihre eigene Grenze mitschreibt. Die `Geschichte`-Tabelle
benennt die eigenen Fehler inhaltlich, statt sie zu glätten, und schreibt nichts um. Die
Ereignis-Existenz-Aussagen sind an der Quelle bestätigt. Form nach Modul 4 vollständig, Status
nirgends vorgreifend, Index korrekt nachgezogen, keine Kollision mit einer aktiven ADR,
`make docs-check` 231/0.

**Übergabe:** an den **ADR-Autor** (Rückkante Review → Architektur/Planung; die ADR bleibt
*Proposed*); die Anteile R3-8 und R3-10 zusätzlich an die **Planung** (welle-09). Es gibt keinen
Produktiv-Diff; nichts geht an die Implementation. slice-059 bleibt in `open/`. Der Report ersetzt
keine Verifikation — DoD-Konformität prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt,
anderer Eingabe-Kontext).
