# Implementation-Review slice-059 (3. Runde am Code, 2. Runde auf die Review-Antwort) — Span-Emitter in Go

**Datum:** 2026-07-29 · **Rolle:** Reviewer (Modul 10) · **Baseline:** v3.5.2

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Prüfgegenstand** | Commit `f88feed` — „slice-059: Review-Antwort — 4 HIGH, 7 MEDIUM, 8 LOW und zwei Verifier-Befunde" |
| **Commit-Range** | `01fe699..f88feed` = genau ein Commit |
| **Vorrunde** | `docs/reviews/2026-07-29-slice-059-go-emitter-review.md` (4 HIGH, 7 MEDIUM, 8 LOW, 4 INFO) auf `01fe699` |
| **Neue Dateien** | `test/mutations/111-span-korrelationsfeld-verschwindet.sh`, `112-span-stdout-geschwaetzig.sh`, `113-span-ablageort-getrackt.sh` |
| **Geänderte Dateien** | `AGENTS.md`, `Dockerfile`, `Makefile`, `cmd/span-emit/main.go`, `harness/README.md`, `harness/conventions.md` (`MR-005`, `MR-018`), `harness/tools/artifact-copy.sh`, `harness/tools/span-check.sh`, `internal/span/emit.go`, `internal/span/span_test.go`, Slice-Plan, welle-09-Plan |
| **Referenzierte aktive ADRs** | `ADR-0011` (Accepted, immutabel), `ADR-0003` |
| **Betroffene Anforderungen** | `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04` |
| **Hard Rules** | `AGENTS.md` §3.1–§3.6 |
| **Konventionen** | `MR-002`, `MR-003`, `MR-005`, `MR-018` |
| **Nicht geprüft (andere Rolle)** | DoD-Abhakung, Reproduktion der Gate-Läufe → Verifikation (Modul 11) |

**Vom Auftrag gesetzte Sensorlage (nicht von mir gefahren, Ressourcen-Schranke):**
`make gates` Exit 0 · `make mutate` 109 ok / 0 Befunde (`.harness/state/mutate-runde2.log`).
Ich habe **keinen** Build und **kein** Gate gefahren.

**Selbst gemessen** (billige Leseoperationen am realen Zustand, deshalb belastbar):
der Live-Bestand unter `.harness/state/spans/` — Strom-Namen, `seq`-Verläufe, Feldbestand
der geschriebenen Zeilen, Anzahl liegengebliebener Lock-Dateien, Verzeichnis-Einträge.
Diese Messungen tragen HIGH-1 und LOW-4 unten. Wo ein Befund aus dem Lesen des Codes
stammt, steht das dort als *abgeleitet*.

---

## Findings

### HIGH-1 — der Wechsel der Strom-Namen hat einen laufenden Strom in zwei Ströme mit je eigenem Nummernkreis gespalten; gemessen, nirgends benannt

- **Kategorie:** HIGH (Verstoß gegen `ADR-0011` Festlegung 3 und Folgepflicht 4 im real
  erzeugten Artefakt; die Folge einer Behebung — Vorrunden-LOW-7 —, die nicht mitgedacht ist)
- **Quelle:** `ADR-0011` Festlegung 3 (*„Je (Sitzung, Agent) ein eigener Strom"*),
  Folgepflicht 4 (*„Je Strom (Festlegung 3) ein eigener Zähler … eine Doppelvergabe erzeugt
  keine Lücke, sieht also aus wie Vollständigkeit"*), `MR-018:843`
  (*„`session`, `agent` … zusammen bilden sie den **Strom**"*)
- **Pfad:** `internal/span/emit.go:178-207` (`StreamName` + `sanitizePart`, der Trenner `-`
  wird innerhalb der Teile jetzt zu `_`), Gegenstelle `harness/conventions.md:843`
- **Befund:** `sanitizePart` schreibt seit diesem Commit **jeden** `-` innerhalb von Sitzung
  und Agent zu `_` um. Das ist gegen Kollisionen richtig (LOW-7 der Vorrunde) — es benennt
  aber **jeden bestehenden Strom um**, und der Zähler steht in einer Datei, die am
  Strom-**Namen** hängt. Gemessen am Live-Bestand dieses Repos:

  | Datei | erste `seq` | letzte `seq` | `session`-Feld in der Zeile |
  |---|---|---|---|
  | `f46473fe-d118-…-720288c591fd.jsonl` | 1 (2026-07-28T14:20:55Z) | 108 (2026-07-29T05:57:32Z) | `f46473fe-d118-4448-a6d3-720288c591fd` |
  | `f46473fe_d118_…_720288c591fd.jsonl` | 1 (2026-07-29T05:58:19Z) | 58 | `f46473fe-d118-4448-a6d3-720288c591fd` |

  Beide Dateien tragen **denselben** `session`-Wert und **denselben** (leeren) `agent`-Wert,
  sind also nach `MR-018:843` und `ADR-0011` Festlegung 3 **ein** Strom — mit zwei Zählern und
  58 doppelt vergebenen Nummern. Der Schnitt liegt exakt 47 Sekunden nach der letzten Zeile der
  alten Schreibweise, also am Deployment des neuen Emitters. Im Verzeichnis liegen daneben
  Subagenten-Ströme in beiden Schreibweisen (`…-a32313…`/`…-a4c7e9…` mit `-`, `…-a0150…`/
  `…-aa4085…` mit `_`); dort sind die Agenten-Kennungen verschieden, eine Spaltung desselben
  Paars ist für sie also **nicht** belegt — der Haupt-Strom oben reicht für den Befund.
  Die Commit-Message benennt unter „NEBENBEFUND" die **andere** Naht (awk→Go, 16 Duplikate) —
  diese, die sie selbst erzeugt, nicht; `MR-018` sagt nichts über die Stabilität des
  Strom-Namens über Emitter-Versionen; die LOW-7-Antwort im Doc-Kommentar
  (`emit.go:171-177`) spricht nur von Kollisionen, nicht von der Umbenennung.
- **Failure-Szenario:** Die Auswertung aus slice-060 tut genau das, wozu `MR-018` sie anweist:
  sie gruppiert nach (`session`, `agent`) und prüft `seq` auf Lücken. Sie sieht für diese
  Sitzung die Nummern 1…108 und 1…58, also 58 Duplikate und **keine** Lücke — die
  Doppelvergabe, die `ADR-0011` Folgepflicht 4 wörtlich als *„sieht aus wie Vollständigkeit"*
  benennt und deretwegen der Zähler überhaupt je Strom geführt wird. Jeder künftige Eingriff
  in `sanitizePart`/`maxStreamName` wiederholt das lautlos.
- **Verifizierbar:** ja, selbst gefahren —
  `ls .harness/state/spans/ | sed 's/\.[a-z]*$//' | sort -u` zeigt beide Schreibweisen
  desselben Paars; `head -1`/`tail -1` der zwei `.jsonl` zeigen identisches `session`-Feld bei
  zweimal `seq:1`. Behebbar ohne Code: `make span-clean` vor dem Umstieg **und** eine
  Migrations-Zeile in `MR-018` („ein Wechsel der Namensbildung beendet den alten Strom; der
  Bestand ist vorher zu räumen oder beim Lesen an der Datei, nicht an (session, agent), zu
  gruppieren").

### MEDIUM-1 — die flock-Zusage („kein liegengebliebenes Schloss legt einen Strom dauerhaft still") gilt nicht für das Schloss der Vorgänger-Fassung

- **Kategorie:** MEDIUM (Zusage weiter als ihre Deckung, §3.6; Restrisiko genau des
  Fehlerbilds, gegen das die Umstellung gebaut wurde)
- **Quelle:** `AGENTS.md` §3.6, `ADR-0011` Folgepflicht 4
- **Pfad:** `internal/span/emit.go:275-283` (Zusage), `:289-292` (`os.OpenFile`),
  Wächter `internal/span/span_test.go:428-452`
- **Befund:** Der Kommentar sagt unbedingt zu: *„Damit gibt es kein liegengebliebenes Schloss,
  das den Strom dauerhaft stilllegt."* `acquire` öffnet den Lock-Pfad mit
  `os.OpenFile(path, O_CREATE|O_RDWR, 0600)`. Ist unter diesem Pfad ein **Verzeichnis** —
  genau das, was die Vorgänger-Fassung dieses Commits (`01fe699`, `os.Mkdir(lock, 0700)`) bei
  einem Tod zwischen `Mkdir` und `Remove` hinterlässt —, scheitert das Öffnen mit `EISDIR`,
  `Append` gibt den Fehler zurück, `main` klemmt ihn auf Exit 0: der Strom ist **dauerhaft und
  lautlos** tot, ohne beanspruchte Nummer und damit ohne Lücke. Dasselbe gilt für eine
  Lock-Datei, die dem Prozess nicht schreibbar ist. `TestLeftoverLockFileDoesNotBlock` nennt
  das Lock-**Verzeichnis** der Vorgänger-Fassung in seinem eigenen Doc-Kommentar und prüft
  dann eine leere **Datei** — der genannte Fall ist der einzige nicht gemessene.
  **Zur Fairness:** die Umstellung auf `flock` ist die richtige Antwort auf MEDIUM-5 und
  beseitigt die Brech-Race vollständig; im hiesigen Checkout liegt kein Lock-Verzeichnis
  (selbst geprüft: `find .harness/state/spans -maxdepth 1 -type d` liefert nur `.`).
  Bemängelt ist die **unbedingte** Formulierung plus die fehlende Zeile im Wächter.
- **Failure-Szenario:** Ein Checkout, der `01fe699` gefahren hat und dessen Agenten-Prozess
  hart getötet wurde, zieht `f88feed` — ab da schreibt genau dieser Strom nie wieder einen
  Span. Kein Gate meldet es (`span-check` benutzt einen eigenen Strom-Namen je PID), keine
  Lücke entsteht, und der Kommentar sagt dem Suchenden, dass es diesen Zustand nicht geben
  kann.
- **Verifizierbar:** ja — in `TestLeftoverLockFileDoesNotBlock` `os.WriteFile` durch
  `os.Mkdir(…, 0o700)` ersetzen; der Test wird rot. *Abgeleitet aus dem Code und der
  `EISDIR`-Semantik von `open(2)`, nicht gefahren (Host-Go geblockt).*

### MEDIUM-2 — `span-check` sagt „ein Span mit den Pflichtfeldern" zu und prüft 7 von 14; die vier in diesem Commit neu erklärten Pflichtfelder fehlen

- **Kategorie:** MEDIUM (dieselbe Klasse wie Vorrunden-HIGH-2 an der zweiten Sensorstelle:
  eine Feldliste, die die Pflicht-Spalte behauptet und sie nicht ist; §3.6)
- **Quelle:** `AGENTS.md` §3.6, `MR-018` Pflicht-Spalte (`harness/conventions.md:838-850`)
- **Pfad:** `harness/tools/span-check.sh:24` (Zusage *„einen Span mit den Pflichtfeldern"*),
  `:87-90` (die Liste, Fehlermeldung *„Pflichtfeld fehlt im Span"*)
- **Befund:** Die Prüfschleife führt `seq`, `tool`, `tool_use_id`, `status`, `slice`,
  `requirement` — und `program`, das in `MR-018` **Optional** ist. Nicht geprüft werden
  `event`, `ts`, `session`, `agent` und ausgerechnet die vier Felder, die dieser Commit als
  Pflicht neu einträgt bzw. rettet: `agent_role`, `adr`, `branch`, `commit`. Der Go-Wächter
  `TestMandatoryFieldsAlwaysPresent` führt seit diesem Commit alle 14 korrekt — die
  Doppelung der Zusage an einer zweiten Stelle wurde beim Nachziehen übersehen. Es ist
  strukturell der Vorrunden-Befund HIGH-2 („der Wächter zählte 10 der 12 Pflichtfelder auf"),
  nur im Shell-Gate statt im Go-Test.
- **Failure-Szenario:** `span-check` ist der **einzige** Sensor, der das real gebaute
  Host-Binary an einer echten Payload misst (der Go-Test misst den Quellstand im Container).
  Fällt ein Pflichtfeld nur dort aus — veraltetes Binary zwischen zwei Gate-Läufen
  (Vorrunden-INFO-2), Plattform-Bau, ein `omitempty`, das der Go-Test nicht deckt —, meldet
  das Gate „Emitter vorhanden, ein Span geschrieben" und der Auswerter bekommt Zeilen ohne
  Rollen-, ADR- und Änderungs-Achse.
- **Verifizierbar:** ja — die Liste in `:87-88` gegen die Pflicht-Spalte in
  `harness/conventions.md:838-850` legen (selbst gefahren: 7 gegen 14, davon eines optional).

### MEDIUM-3 — der `correlation`-Kommentar sagt, `agent.role` sei nicht ableitbar; derselbe Commit leitet es 150 Zeilen darüber ab

- **Kategorie:** MEDIUM (falsche Zusage im Code über den Code, §3.6; widerspricht der
  normativen Stelle `MR-018`)
- **Quelle:** `AGENTS.md` §3.6, `ADR-0011` Festlegung 1.4/1.5, `MR-018` Abweichung 3
- **Pfad:** `internal/span/emit.go:323-324` gegen `:146-169` (`roleFromAgentType`) und
  `harness/conventions.md:897-907`
- **Befund:** *„Die vierte Achse, agent.role, ist NICHT ableitbar und steht als erklaerte
  Abweichung in MR-018."* — Das war bis `01fe699` richtig und ist seit diesem Commit falsch:
  `roleFromAgentType` leitet sie ab, `MR-018` Abweichung 3 sagt ausdrücklich *„`agent_role`
  wird deshalb **abgeleitet, nicht geraten**"*, und `TestAgentRoleFromKnownTypes` misst genau
  das. Der Satz ist beim Nachziehen der Ableitung stehengeblieben.
- **Failure-Szenario:** Der nächste Leser von `internal/span/` — slice-060 baut die Auswertung
  auf genau dieser Achse — findet im Code die Aussage „nicht ableitbar" und in `MR-018` die
  Aussage „abgeleitet". Bei Konflikt gilt `MR-018`; wer den Konflikt nicht bemerkt, hält das
  leere Feld für eine strukturelle Unmöglichkeit statt für den heute unbenannten Agenten-Typ
  und baut die Splitting-Regel gegen die falsche Annahme.
- **Verifizierbar:** ja — beide Stellen lesen; `make comment-claims` sieht es nicht (es prüft
  Nennung und Existenz des Sensors, nicht die inhaltliche Deckung — Vorrunden-INFO-4).

### LOW-1 — `MR-018`: die Abweichungen sind renumeriert, der Verweis auf sie nicht

- **Kategorie:** LOW (Doku-Drift; Vorrunden-LOW-1 zur Hälfte geschlossen)
- **Quelle:** Maintainability
- **Pfad:** `harness/conventions.md:849` (*„die PR-Nummer selbst ist nicht erreichbar,
  s. Abweichung 3"*) gegen `:888` (die PR-Abweichung ist jetzt Nummer **2**) und `:897`
  (Nummer 3 ist `agent_role`)
- **Befund:** Die Quell-Nummerierung `1., 3., 2.` ist behoben (jetzt `1., 2., 3., 4.`) — der
  Querverweis in der Feldtabelle zeigt weiterhin auf „Abweichung 3" und trifft damit jetzt
  `agent_role` statt der PR-Nummer. Vorher zeigte er auf den zweiten gerenderten Punkt, jetzt
  auf den dritten; falsch war und ist er.
- **Failure-Szenario:** Ein Leser der `branch`/`commit`-Zeile folgt dem Verweis und landet bei
  der Rollen-Achse.
- **Verifizierbar:** ja — `sed -n '849p;888p;897p' harness/conventions.md`.

### LOW-2 — `agent_type` ist in `MR-018` Optional, trägt im Struct aber kein `omitempty`

- **Kategorie:** LOW (Rest der Vorrunden-HIGH-2-Klasse in der harmlosen Richtung:
  Pflicht/Optional-Spalte und Struct-Tags decken sich noch nicht vollständig)
- **Quelle:** `MR-018:844`, `ADR-0011` Festlegung 1 (Schema geschlossen, Pflicht/Optional je Feld)
- **Pfad:** `internal/span/emit.go:50` (`json:"agent_type"`) gegen `:58-64` (alle anderen
  Optional-Felder tragen `omitempty`)
- **Befund:** Jedes andere Optional-Feld verschwindet bei leerem Wert, `agent_type` steht immer
  da (live geprüft: `"agent_type":""` im Haupt-Strom). Kein Schaden — aber die Regel „Pflicht ⇒
  immer da, Optional ⇒ nur bei Wert", auf der `TestMandatoryFieldsAlwaysPresent` und Fall
  110/111 aufsetzen, ist damit nur in einer Richtung wahr, und kein Wächter misst die andere.
- **Failure-Szenario:** Ein Auswerter schließt aus dem Vorhandensein eines Schlüssels auf
  „Pflichtfeld" (die Unterscheidung, die dieses Schema laut Abweichung 2/3 gerade tragen soll)
  und behandelt `agent_type` wie eine garantierte Achse.
- **Verifizierbar:** ja — Struct-Tags gegen die Pflicht-Spalte legen.

### LOW-3 — Mutation 113 wird an einer Konstanten rot, nicht an der Eigenschaft; der Sensor, der die Eigenschaft misst, hat keinen Fall

- **Kategorie:** LOW (Vorrunden-HIGH-4 formal geschlossen, seine zweite Hälfte offen)
- **Quelle:** `ADR-0011` Fitness Function Zeile 3, `AGENTS.md` §3.6
- **Pfad:** `test/mutations/113-span-ablageort-getrackt.sh:16`,
  `internal/span/span_test.go:287-296`, `harness/tools/span-check.sh:92-94`,
  `harness/tools/mutate.sh:211-225` (`narrow_sensor`)
- **Befund:** 113 zieht `Dir` auf `docs/spans`; rot wird `TestSpansLandInStateDir` an seiner
  **Zeichenketten-Gleichheit** (`span.Dir != ".harness/state/spans"`), nicht daran, dass
  `docs/spans` getrackt ist. Die Eigenschaft *„der Ablageort ist git-ignoriert"* misst allein
  `span-check.sh` mit `git check-ignore` am echten Repo — und dieser Sensor bleibt unbewacht:
  `narrow_sensor` wählt für ein `# expect: Test…` nur `test-go`, und `failure_form` kennt für
  ein Gate wie `span-check` gar kein Fehlschlag-Muster. Die Vorrunde hatte genau das
  formuliert (*„offen ist die Haltbarkeit ihrer **zwei** Wächter"*); gedeckt ist einer.
  Praktisch trägt die Kombination trotzdem: `git check-ignore` läuft in jedem `make gates`.
- **Failure-Szenario:** Jemand entfernt oder entschärft den `git check-ignore`-Block in
  `span-check.sh` (etwa als vermeintliche Beschleunigung). `make mutate` bleibt bei 109 ok,
  `make gates` grün — und die einzige Messung der `MR-003`-Kopplung am realen Repo ist weg.
- **Verifizierbar:** ja — `span-check.sh:93-94` auskommentieren und `make mutate` fahren; kein
  Fall wird rot. *Abgeleitet aus dem Treiber-Code, nicht gefahren.*

### LOW-4 — jeder Gate-Lauf lässt eine Lock-Datei im Zustands-Bereich zurück

- **Kategorie:** LOW (Müll, monoton wachsend)
- **Quelle:** Maintainability
- **Pfad:** `harness/tools/span-check.sh:71` (`trap` räumt `.jsonl` und `.seq`),
  `internal/span/emit.go:216-222` (die Lock-Datei wird geschlossen, nie entfernt)
- **Befund:** Mit `flock` ist das Entfernen nicht mehr nötig (und wäre sogar heikel) — die
  Datei bleibt aber liegen, auch die des Gates. Selbst gezählt: 16 `.lock`-Dateien in
  `.harness/state/spans/`, je 0 Byte, darunter eine je `span-check`-Lauf. `make span-clean`
  räumt sie mit.
- **Failure-Szenario:** Kein Funktionsschaden; ein Leser des Zustands-Verzeichnisses hält die
  Dateien für aktive Sperren, und der Bestand wächst mit jedem Gate-Lauf.
- **Verifizierbar:** ja, selbst gefahren — `ls -a .harness/state/spans | grep -c '\.lock$'`.

### LOW-5 — `SPAN_OS`/`SPAN_ARCH` reichen unbekannte `uname`-Werte ungeprüft durch

- **Kategorie:** LOW (Fehlerbild ohne benannte Meldung; die Abbildung selbst ist für die
  Plattform-Matrix korrekt)
- **Quelle:** `LH-QA-04`, `AGENTS.md` §3.1
- **Pfad:** `Makefile:243-244`
- **Befund:** `uname -s | tr` deckt `linux`/`darwin` ab, `uname -m` bildet `x86_64→amd64` und
  `aarch64→arm64` ab und lässt `arm64` (macOS) korrekt durch — die vier Kombinationen der
  Matrix stimmen. Alles andere geht unverändert an `GOOS`/`GOARCH`: `i686`, `armv7l`,
  `MINGW64_NT-10.0`, `FreeBSD` (→ `freebsd`, gültig). Der Fehlschlag ist laut (der
  `docker build` bricht ab), aber die Meldung kommt von Go, nicht vom Harness — und
  `span-check` hat für genau diese Klasse eine eigene, erklärende Meldung (Exit 126).
- **Failure-Szenario:** Ein Maintainer auf einer Plattform außerhalb der Matrix bekommt
  `unsupported GOOS/GOARCH pair` aus einem Container-Build und keinen Hinweis, dass die
  Ableitung aus `uname` die Ursache ist.
- **Verifizierbar:** ja — `make span-emit-build SPAN_ARCH=i686` (nicht gefahren,
  Ressourcen-Schranke).

### LOW-6 — die Reihenfolge `span-emit-build` vor `span-check` hängt an seriellem `make`

- **Kategorie:** LOW (bestehendes Repo-Muster, hier neu darauf angewiesen)
- **Quelle:** `harness/tools/span-check.sh:14-17` (*„In `make gates` steht `span-emit-build`
  als eigenes Glied DAVOR"*)
- **Pfad:** `Makefile:270` (`gates: … span-emit-build span-check record-gates`); kein
  `.NOTPARALLEL` im Repo (selbst geprüft)
- **Befund:** Das Auflösen des Prerequisites (Vorrunden-MEDIUM-1) ist richtig — die
  Ordnungs-Zusicherung ruht seitdem aber auf der Auswertungsreihenfolge von `make` ohne `-j`.
  `make -j gates` darf `span-check` vor dem Bau starten. Dasselbe gilt seit jeher für
  `baseline-verify` („läuft als ERSTER Prerequisite") und `record-gates`; der Befund ist
  deshalb kein Rückschritt, nur eine dritte Stelle mit derselben stillen Annahme.
- **Failure-Szenario:** Ein CI-Lauf mit `-j` meldet auf einem frischen Checkout „der Emitter
  fehlt", obwohl der Bau im selben Lauf steht.
- **Verifizierbar:** ja — `make -j4 gates` auf einem Baum ohne `.harness/state/bin/`
  (nicht gefahren).

### LOW-7 — `BashOutput` steht in der Werkzeug-Tabelle mit `program`/`argc`, kann sie aber nicht liefern

- **Kategorie:** LOW (Doku-Zusage weiter als die Wirklichkeit; sicherheitsseitig unschädlich)
- **Quelle:** `MR-018:869`, `ADR-0011` Festlegung 2
- **Pfad:** `harness/conventions.md:869`, `internal/span/span.go:137-138`, `:161-165`
- **Befund:** Die Ableitung zieht `program`/`argc` aus `tool_input.command`. Die
  `BashOutput`-Payload trägt kein `command` (sie identifiziert eine laufende Shell), also
  liefert `commandProgram("")` `ok=false` und der Span trägt nichts über Name und Status
  hinaus. Die Tabellenzeile verspricht mehr, als je entstehen kann. *Abgeleitet: im
  Live-Bestand kommt `BashOutput` nicht vor (gemessen: 341 `Bash`, 79 `Read`, 18 `Write`,
  7 `Edit`, 6 `Agent`, 2 `ToolSearch`, 2 `Monitor`).*
- **Failure-Szenario:** Eine Auswertung erwartet für `BashOutput` ein Programm-Token und liest
  das strukturelle Fehlen als Erfassungslücke.
- **Verifizierbar:** ja — eine `BashOutput`-Payload durch den Emitter geben.

### INFO-1 — die 64-MB-Grenze des Fingerabdrucks steht nicht in `MR-018`

- **Pfad:** `internal/span/emit.go:31` (`maxHash`), `:131-133`; Gegenstelle
  `harness/conventions.md:854`
- **Befund:** Jenseits von 64 MB trägt der Span `bytes`, aber kein `sha256_16`. Das ist als
  Kosten-Grenze richtig (Festlegung 6) und im Code begründet; die Feldtabelle nennt für
  `sha256_16` nur *„aus dem Dateisystem"*. Da `MR-018` seit diesem Commit ausdrücklich die
  **erfasste Menge** ausspricht, gehört die Grenze dorthin.

### INFO-2 — `nosession` ist ein echter Strom-Name

- **Pfad:** `internal/span/emit.go:180-182`
- **Befund:** Eine Payload ohne `session_id` schreibt nach `nosession`; eine Sitzung, die
  buchstäblich `nosession` heißt, teilte sich den Strom mit ihr. Praktisch unerreichbar
  (Sitzungs-Kennungen sind UUIDs) — hier festgehalten, weil `TestStreamNamesStayDistinct` die
  Eindeutigkeit jetzt ausdrücklich als Eigenschaft führt und dieser eine Fall außerhalb steht.

### INFO-3 — Vorrunden-INFO-1 bis -3 bestehen unverändert

- **Befund:** Der Emitter liest weiterhin payload-gesteuerte Pfade auch außerhalb des Repos
  (`emit.go:121-144`, einzige Prüfung `Mode().IsRegular()`); zwischen zwei Gate-Läufen läuft am
  Hook ein möglicherweise veraltetes Binary; auf einem frischen Checkout erzeugt jeder
  Tool-Call einen Hook-Fehler, bis `make gates` lief. Alle drei waren INFO und sind es
  geblieben — MEDIUM-2 oben verschärft den zweiten Punkt, weil `span-check` das reale Binary
  nur zu einem Drittel prüft.

---

## Status der 23 Befunde der Vorrunde

Die Commit-Message führt alle HIGH, MEDIUM und LOW als geschlossen. Nachgeprüft:

| Vorrunde | Status | Beleg / Rest |
|---|---|---|
| HIGH-1 (Werkzeug-Liste fehlt in `MR-018`) | **vollständig** | Tabelle `conventions.md:865-870` ist mit `toolClass` (`span.go:131-144`) deckungsgleich, inkl. Zeile *„jedes andere ⇒ nichts"*; die Aufnahme ist ausdrücklich als Entscheidung markiert |
| HIGH-2 (`omitempty` an Pflichtfeldern, Wächter unvollständig) | **vollständig** | `branch`/`commit` ohne `omitempty`; Wächter führt jetzt alle 14 Pflicht-Zeilen; `TestUnresolvableGitRefStillCarriesFields` misst den Worktree-Fall; Fall 111 sah es rot. Neue Reste **derselben Klasse an anderen Stellen** → MEDIUM-2, LOW-2 |
| HIGH-3 (stdout-Hälfte ohne Fall) | **vollständig** | Fall 112 schreibt `os.Stdout.WriteString` vor `io.ReadAll`; `TestClampSurvivesBrokenPayload` misst stdout am Kind-Prozess; der Kommentar `main.go:18-28` benennt die Trennung 107/112 jetzt korrekt |
| HIGH-4 (Ablageort-Zeile der Fitness Function ohne Fall) | **halb** | Fall 113 existiert und war rot — er trifft aber den Go-Test an einer Konstanten; der Sensor, der die Eigenschaft misst (`git check-ignore` in `span-check.sh`), bleibt unbewacht → LOW-3 |
| MEDIUM-1 (`span-check` konnte den Fehlt-Fall nicht melden) | **vollständig** | Prerequisite gelöst, `gates` trägt den Bau als eigenes Glied; die Zusicherung im Skript-Kopf ist auf das eingeschränkt, was sie trägt. Rest nur: Reihenfolge bei `-j` → LOW-6 |
| MEDIUM-2 (Host-Portabilität von `make gates`) | **vollständig** | `TARGET_OS`/`TARGET_ARCH` in der span-Stage, aus `uname` abgeleitet; Gate meldet Exit 126 mit erklärender Meldung; die Messung (ELF vs. Mach-O) steht als einmalig und nicht bewacht in der Quelle. Rest: unbekannte `uname`-Werte → LOW-5 |
| MEDIUM-3 (Gate-Tabellen) | **vollständig** | `AGENTS.md` §4 und `harness/README.md` führen `span-emit-build` **und** `span-check` |
| MEDIUM-4 (forbidigo-Zusage) | **vollständig** | `main.go:25-28` nennt jetzt die Form statt der Eigenschaft und verweist auf die zwei Fälle |
| MEDIUM-5 (Race beim Brechen des Schlosses) | **vollständig** | `flock` statt `mkdir`; das Brechen samt Race entfällt; `TestConcurrentEmittersGetDistinctSeq` trägt weiter (getrennte Open-File-Descriptions sperren sich auch innerhalb eines Prozesses). Neuer Rest an derselben Stelle → MEDIUM-1 |
| MEDIUM-6 (Kommandozeilen-Kanarienvogel) | **vollständig** | `TestNoCommandArgumentsReachSpan` misst die **geschriebene Zeile** gegen Token, Flag, Pfad und Sub-Kommando |
| MEDIUM-7 (`adr.id`) | **vollständig** | abgeleitet statt erklärt, `references()` liest ADR- und LH-IDs aus demselben Bezug-Block; `MR-018` führt die Zeile; live gemessen: `"adr":["ADR-0011"]`, deckungsgleich mit dem Bezug-Block des Slices |
| LOW-1 (Nummerierung der Abweichungen) | **halb** | Liste renumeriert, der Querverweis „s. Abweichung 3" zeigt jetzt auf `agent_role` → LOW-1 dieser Runde |
| LOW-2 (Selbstwiderspruch im Slice-Plan) | **vollständig** | §6 trägt die Abweichung samt Begründung und Verweis auf `MR-005` |
| LOW-3 (`MR-005`-Ausnahme) | **vollständig** | Ausnahme für kompilierte Harness-Tools benannt, mit Hinweis für slice-062/063 |
| LOW-4 (Usage von `artifact-copy.sh`) | **vollständig** | vierter Parameter in der Fehlermeldung |
| LOW-5 (Altbestände) | **vollständig** | als Abweichung 4 in `MR-018`, mit `make span-clean` als ausdrücklichem Weg |
| LOW-6 (24-ms-Zahl) | **vollständig** | 2,5 ms, und die Herkunft der alten Zahl benannt |
| LOW-7 (Strom-Kollision) | **vollständig — mit Folge** | Teile werden einzeln reduziert, beim Kürzen tritt ein Fingerabdruck an die Stelle des Restes; `TestStreamNamesStayDistinct` fährt beide Wege. Die **Umbenennung** bestehender Ströme ist die unbenannte Folge → HIGH-1 dieser Runde |
| LOW-8 (bats vs. Go in der Fitness Function) | **vollständig** | Tooling-Klarstellung in `MR-018`, nicht in der immutablen ADR |
| INFO-1 / -2 / -3 | offen (waren INFO) | s. INFO-3 dieser Runde |
| INFO-4 (`comment-claims` deckt keine Inhalte) | bestätigt | trägt auch MEDIUM-3 dieser Runde nicht |
| Verifier V-1 (`omitempty`) | **vollständig** | = HIGH-2 |
| Verifier V-2 (erfasste Menge unbenannt) | **vollständig** | `MR-018:872-879`: zwei Ereignisse, leerer Matcher, und die Lücke „geblockter Aufruf hinterlässt keinen Span" ausdrücklich als **nicht** zugesagt |

**19 von 21 Review-Befunden vollständig, 2 halb** (HIGH-4, LOW-1); beide Verifier-Befunde
vollständig. Die Halbierungs-Quote ist von 3/15 auf 2/21 gefallen, und beide Reste sind
schmaler als die der Vorrunde.

---

## Negativbefunde (geprüft, ohne Befund)

- **Die Werkzeug-Tabelle in `MR-018` ist deckungsgleich mit `toolClass`.** Vier Schreib-, ein
  Lese-, zwei Kommando-Werkzeuge, jeweils mit der Ableitung, die der Code macht; die
  `Read`-Zeile begründet den fehlenden Fingerabdruck. Keine Gattungs-Formulierung, die
  `ADR-0011` Festlegung 2 ausdrücklich verbietet.
- **Pflicht-Spalte und Struct-Tags decken sich in der tragenden Richtung.** Alle 14
  Pflicht-Zeilen aus `MR-018` stehen ohne `omitempty` im Struct und in der Feldliste von
  `TestMandatoryFieldsAlwaysPresent`; live gemessen an einer Zeile von 07:49Z:
  `"agent_role":"","adr":["ADR-0011"],"branch":"main","commit":"f88feed0ea72"` — anwesend und
  als leer erkennbar. Einzige Abweichung in der anderen Richtung: LOW-2.
- **Die Rollenliste ist gegenüber dem Regelwerk vollständig.** `roleFromAgentType` führt
  `planner, architect, implementer, reviewer, verifier, validator` — die Vereinigung aus
  Modul 15 §Token-Attributions-Regeln (*Planner · Architect · Implementer · Reviewer ·
  Verifier*) und Modul 8 (dieselben plus **Validator**). Kein Name fehlt. `MR-018:845` führt
  exakt dieselben sechs.
- **Die Lesevorschrift zu `agent_role` deckt sich mit dem Feld und zitiert Modul 15 wörtlich.**
  Der Satz *„Wo ein Span keinen Rollen-Tag trägt (Sammelposten), entscheide begründet, wie du
  ihn aufteilst (anteilig nach Tool-Calls? dem auslösenden Slice zugeschlagen?)"* stimmt
  Zeichen für Zeichen mit `modul-15-observability.md:41-43` überein (selbst verglichen). Die
  daraus abgeleiteten drei Punkte greifen nicht weiter als die Regel: Punkt 2 ist ausdrücklich
  als Repo-Zusatz markiert, Punkt 3 verbietet allein das ungeteilte Führen. „Leer heißt
  unbekannt" deckt sich mit `roleFromAgentType` (leerer Rückgabewert statt Raten) und mit der
  Pflicht-Markierung.
- **Die Ableitung `agent_role` trägt, soweit sie zusagt.** Exakte Namensgleichheit, sonst leer;
  `TestAgentRoleFromKnownTypes` fährt alle sechs Treffer **und** vier Nicht-Treffer
  (`general-purpose`, leer, `Explore`, `reviewer-2`). Anmerkung ohne Befund: `MR-018` sagt
  *„wenn `agent_type` eine Harness-Rolle **nennt**"*, der Code verlangt Gleichheit — der Test
  legt die engere Lesart ausdrücklich fest, damit ist sie entschieden und nicht offen.
- **Die drei neuen Mutations-Fälle sind fail-closed gebaut** und ihre `sed`-Anker existieren
  im heutigen Text (je selbst nachgesehen: `json:"branch"`, `^\tpayload, err := io.ReadAll`,
  `^const Dir = ".harness/state/spans"$`). 111 und 112 messen die **Eigenschaft** (Schlüssel
  anwesend bei leerem Wert; stdout bleibt leer), 113 die Konstante → LOW-3.
- **`span-check` hält, was sein Kopf jetzt sagt.** Die Zusicherung ist auf „einzeln gefahren
  meldet es den Fehlt-Fall; in `gates` steht der Bau davor" zurückgeschnitten, und der
  Makefile-Kommentar sagt dasselbe. Der Strom-Name `spancheck$$` ohne `-` ist die Folge des
  `sanitizePart`-Wechsels und im Skript begründet — die Selbstkorrektur ist belegt.
- **`ADR-0011` Fitness Function, alle vier Mutations-Zeilen belegt:** Pflichtfeld → 110/111,
  nicht namentlich gelistetes Werkzeug → 108, Ablageort → 113, unterschlagener Span → 109;
  dazu 107 (Klemme) und 112 (stdout, Folgepflicht 5).
- **`AGENTS.md` §3.4.** `git show --stat f88feed -- docs/plan/adr/ spec/` ist leer: die
  immutable `ADR-0011` und die Spec sind nicht angefasst.
- **`AGENTS.md` §3.2 / §3.3 / §3.5.** Kein `//nolint`, kein `shellcheck disable`, kein `git mv`
  im Diff; `.golangci.yml` unverändert (forbidigo weiterhin genau ein Muster); `make gates` ist
  **gewachsen** (`span-emit-build`), keine Schwelle gesenkt.
- **Die Emission ist unberührt.** `internal/emit/` steht nicht im Diff; das **Ob** eines
  Emitters für den emittierten Harness bleibt bei slice-062 samt CR.
- **Der Emitter läuft real und schreibt das neue Schema.** Live-Zeile von 07:49Z trägt
  `agent_role`, `adr`, `branch`, `commit`, `program`/`argc` und keinen Payload-Inhalt; alle
  Strom-Dateien stehen auf `-rw-------`.

---

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | **1** |
| MEDIUM | 3 |
| LOW | 7 |
| INFO | 3 |
| **Gesamt** | **14** |

**Verteilung nach Quelle:** `ADR-0011` Festlegung 3 / Folgepflicht 4 → HIGH-1 · `AGENTS.md`
§3.6 (Zusage weiter als Deckung) → MEDIUM-1, MEDIUM-2, MEDIUM-3, LOW-3 · `MR-018`-Doku-Drift →
LOW-1, LOW-2, LOW-7 · Betrieb/Reproduzierbarkeit → LOW-4, LOW-5, LOW-6.

**Das Muster hat sich weiter verschoben, und das soll benannt sein.** Die Vorrunde fand vier
HIGH, drei davon Halbierungen. Diese Runde findet **zwei** Halbierungen (HIGH-4, LOW-1) und
keine davon im Sicherheitspfad; die vier HIGH der Vorrunde sind in ihrem Kern geschlossen, drei
davon vollständig. Was **nicht** verschwunden ist: die Klasse „ein Kommentar sagt mehr zu, als
sein Code trägt" (MEDIUM-1: *„kein liegengebliebenes Schloss"*; MEDIUM-3: *„nicht ableitbar"*)
und die Klasse „eine zweite Stelle wird beim Nachziehen vergessen" (MEDIUM-2: die
Pflichtfeld-Liste im Gate; LOW-1: der Querverweis). Beide sind je durch **ein** Gegenbeispiel
widerlegbar, das der Autor selbst hätte formulieren können — dieselbe Diagnose wie in der
Vorrunde, auf kleinerem Radius.

**Der neue HIGH ist keine Halbierung, sondern eine unbedachte Folge.** Die Behebung von LOW-7
war richtig; niemand hat gefragt, was sie mit dem **Bestand** macht. Bemerkenswert daran: die
Commit-Message untersucht die Naht zwischen zwei Emitter-Generationen ausführlich und findet
dort 16 Duplikate — an genau derselben Datei, einen Tag später, erzeugt derselbe Commit 58
weitere und nennt sie nicht. Die Messung war da, die Frage wurde nur nicht ein zweites Mal
gestellt.

**Gegenläufig, und es ist substanziell:** `flock` ist die konstruktiv richtige Antwort statt
einer weiteren Heuristik; `agent_role` und `adr` schließen die Korrelations-Achsen aus Modul 15
mit einer **Ableitung** statt einer Abweichungs-Erklärung, in der von `ADR-0011` Festlegung 1.4
verlangten Reihenfolge; die Werkzeug-Tabelle in `MR-018` macht die sicherheitsentscheidende
Liste erstmals ohne Code lesbar; und die Pflichtfeld-Zusage steht jetzt an drei Stellen
konsistent (Struct, Wächter, zwei Mutations-Fälle) statt an einer.

---

## Verdikt

**BLOCKIEREND — ein HIGH, drei MEDIUM.**

Blockierend ist HIGH-1: ein (Sitzung, Agent)-Paar führt im real erzeugten Bestand **zwei**
Ströme mit zwei Nummernkreisen und 58 doppelt vergebenen Nummern. Das verletzt `ADR-0011`
Festlegung 3 und entwertet Folgepflicht 4 genau in der Form, die die ADR selbst als die
gefährlichere benennt — eine Doppelvergabe erzeugt keine Lücke und sieht deshalb aus wie
Vollständigkeit. Der Befund ist **gemessen**, nicht abgeleitet, und er ist billig zu schließen:
`make span-clean` plus eine Migrations-Zeile in `MR-018`. Solange er offen ist, liefert der
Slice ein Artefakt, dessen zentrale Lese-Eigenschaft für die Sitzungen dieses Repos nicht gilt.

Die drei MEDIUM sind vor dem Abschluss zu klären: zwei falsche Kommentar-Zusagen (MEDIUM-1,
MEDIUM-3) und eine Pflichtfeld-Liste im Gate, die vier der 14 Pflichtfelder nicht kennt —
darunter alle, die dieser Commit eingeführt hat (MEDIUM-2).

**Nicht Gegenstand dieses Reviews** (Modul 11): ob die DoD-Punkte abgehakt sind und ob
`make gates` (Exit 0) und `make mutate` (109 ok / 0 Befunde) reproduzieren. Ich habe beide
nicht gefahren; die Zahlen stammen aus dem Auftrag und sind hier nicht bestritten. Die Befunde
oben betreffen nicht die Ehrlichkeit dieser Zahlen, sondern das, was sie abdecken.
