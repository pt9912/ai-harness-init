# Review-Report: slice-066 (Code, Bestätigungsrunde) — 2026-08-09

**Review-Art:** **Code** — geprüft wird der Diff gegen **Plan, aktive ADRs und Hard Rules**
(Modul 10 §Drei Review-Arten). **Nicht** geprüft: die DoD-Abhakung — sie ist Gegenstand der
Verifikation (Modul 11, eigener Kontext, anderes Prüf-Artefakt); der Verifier hat sie am
2026-08-08 in eigenem Durchgang bestätigt und die Bilanz mit eigenem awk nachgerechnet. Eine
Doppelprüfung verwischt die Rollen-Trennung und ist hier ausdrücklich unterlassen.

**Gegenstand:** `edf739d~1..HEAD` (`b74df5d`), acht Commits — `edf739d` · `4aa910a` ·
`5468395` · `fe20d8e` · `0f41911` · `f7f086e` · `8dc3d29` · `b74df5d`. Selbst nachgezählt:
`git diff --stat edf739d~1..HEAD` = **27 Dateien, +1932/−124**; `git log --oneline` = acht
Zeilen. Der Bereich ist **weiter** als der des Erst-Reviews (`origin/main..HEAD`, drei
Commits) und deckt insbesondere die vier Reparatur-Commits, `AGENTS.md` §3.7, `MR-022` und die
Closure-Notiz ab — alles Artefakte, die kein Review gesehen hat.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-09

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf
nicht reproduzierbar):

- Slice-Plan `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md` (samt §5
  Closure-Trigger und der Closure-Notiz in §7)
- aktive ADRs, alle Statuszeilen selbst gelesen, alle **Accepted**:
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md),
  [`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md),
  [`ADR-0013`](../plan/adr/0013-technik-stratum-als-zielort.md) (via `slice-079`)
- `LH-*`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- [`AGENTS.md`](../../AGENTS.md) §2 Source Precedence, §3 Hard Rules **§3.1–§3.7**, §4
- [`harness/conventions.md`](../../harness/conventions.md) `MR-000`, `MR-002`, `MR-007`,
  `MR-016`, `MR-019`, **`MR-022`**
- [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  samt §Aufnahme-Regel
- Regelwerk `v3.5.2`: `README.md` (Index), `modul-09-implementierung.md`,
  `modul-10-review-harness.md`, `modul-08-agentenrollen.md`
- **vorherige Findings am gleichen Modul:**
  `docs/reviews/2026-08-08-slice-066-plan-review.md` (3 HIGH / 7 MEDIUM / 5 LOW / 2 INFO),
  `docs/reviews/2026-08-08-slice-066-review.md` (0/4/5/3),
  `docs/reviews/2026-08-08-slice-066-verify.md` (V1–V5)
- **Upstream-Referenz** für die `MR-022`-Sachprüfung: `/Development/KI/ai-harness-course`,
  gepinnt gelesen am Tag **`v5.3.0`** (`git show v5.3.0:<pfad>`), nicht am beweglichen HEAD

**Mess-Grundlage.** Jede Zahl unten ist in diesem Kontext selbst erhoben; kein Wert des
Implementers, des Planners oder eines Vorgänger-Reports ist übernommen worden. Gefahren wurden
ausschließlich lesende Kommandos (`git`, `grep`, `awk`, `sed`, `comm`, `python3` für das
Zählen von Zeilen-Ankern) — **keine** Host-Toolchain (`go`/`pip`/`npm`), gemäß
[`ADR-0003`](../plan/adr/0003-go-native-binaries.md).

**`make gates` und `make mutate` sind hier NICHT wiederholt worden**, und das ist eine
Rollen-Entscheidung, keine Bequemlichkeit: Modul 10 §Anti-Pattern schließt die
Gate-Lauf-Bestätigung ausdrücklich aus dem Reviewer-Auftrag aus. Was ich stattdessen selbst
gemessen habe, ist die **Deckungs-Behauptung** der Closure-Notiz — siehe Negativbefund
*Mutations-Deckung*.

---

## Status der Vorbefunde

Jede Zeile ist am Baum bei `b74df5d` selbst nachgemessen, nicht aus der Commit-Message
übernommen.

| # | Vorbefund | Status hier |
|---|---|---|
| F-1 | Spawn-Spans im Nenner der Splitting-Regel | **aufgelöst, an Daten belegt** |
| F-2 | Unverteilter Sammelposten verschwand, Ausgabe widersprach sich | **aufgelöst** |
| F-3 | Plan-Begründung und Bilanz beziffern in zwei Größen | **aufgelöst** |
| F-4 | Roadmap-Zeile in der Implementer-Rolle | **aufgelöst** (Zeile verworfen) — Restbeobachtung als B8 |
| F-5 | §5 erlaubt, was seine Prüfreihenfolge als Pflicht setzt | **aufgelöst** |
| F-6 | Ganzzahl-Rest fiel aus der Bilanz | **aufgelöst** |
| F-7 | Vier tragende Sätze der `Makefile`-Kürzung entfallen | **BESTEHT — neu eingestuft LOW → MEDIUM (B1)** |
| F-8 | Zwei Zahlen in der Commit-Message von `edf739d` | **verfallen, mit Beleg** — INFO, s. u. |
| F-9 | Zwei Angaben der Roadmap-Zeile falsch bzw. veraltet | **gegenstandslos** (Zeile existiert nicht mehr) |
| F-10 | Fall-Kommentar 145 nennt nicht den auslösenden Zweig | **WIDERLEGT, mit Beleg** — s. u. |
| F-11 | `span-report` ohne dokumentierten Ort | **aufgelöst** (bestätigt, nicht übernommen) |
| F-12 | Fehlender vs. leerer Ablageort ununterscheidbar | **Träger `slice-071` §6, eingetragen** |
| V1 | „Doku-Update erfolgt" ohne Träger | **aufgelöst** |
| V2 | Größen-Angabe an einem von zwei Fundorten | **aufgelöst** |
| V3 | Verweis „die Beträge oben" zeigt ins Leere | **aufgelöst** |
| V4 | Vier Positionen ohne Plan-Zeile | **als Notiz geführt**, §3 bewusst nicht nachgezogen — trägt (s. u.) |
| V5 | „3 Sitzung(en)" beschreibt den Ablageort | **Träger `slice-071` §6, eingetragen** |

**F-1 — aufgelöst, und zwar an realen Daten, nicht nur am Code.** `internal/report/report.go:128`
lautet jetzt `if s.AgentRole != "" && s.Tool != "" {`. Gegenprobe über
`.harness/state/spans/*.jsonl`, selbst gezählt: **11** `SubagentStart`-Spans, davon **0** mit
nicht-leerem `tool` und **9** mit gefüllter `agent_role`. Ohne den zweiten Filter gingen heute
genau diese 9 in den Nenner; mit ihm keiner. Bewacht von
`TestAggregiere_SpawnSpanZaehltNichtAlsToolCall` und `test/mutations/147`.

**F-2 — aufgelöst.** `Bilanz.Verteilt` (`report.go:44`) trägt jetzt die Fallunterscheidung, der
Ausgabe-Zweig in `Schreibe` (`report.go:276-285`) ist dreifach (kein Sammelposten · verteilt ·
NICHT verteilt), und die frühere Selbstwidersprüchlichkeit ist weg: der leere-Bestand-Satz
lautet jetzt *„Keine Rolle traegt Token."* (`report.go:260`) statt *„Der Bestand ist leer oder
ohne Zaehler"* — im F-2-Szenario (Zähler vorhanden, keine Rolle) ist das eine wahre Aussage.
Bewacht von `TestSchreibe_UnverteilterSammelpostenStehtAusserhalb` und `test/mutations/148`.

**F-3 / V2 / V3 — aufgelöst.** Frage A trägt jetzt beide Beträge samt der Angabe, welche Größe
die Bilanz ausweist (`slice-066…:141`); Frage B nennt **96,2 %** in `input+output` **und**
**90,8 %** in `total_tokens` (`:142`). Der ins Leere zeigende Satz aus V3 ist entfernt.

**F-11 — aufgelöst, und ich habe es gemessen statt übernommen.** Prüfbereich:
`git ls-files | xargs grep -ln 'span-report'`. `make span-report` steht jetzt im
Nicht-Gate-Verify-Absatz von [`AGENTS.md`](../../AGENTS.md) §4 **und** von
[`harness/README.md`](../../harness/README.md) — an beiden Stellen ausdrücklich als *Bericht,
kein Sensor* und ausdrücklich **nicht** in den Gate-Tabellen, mit
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) als
Begründung. Damit ist die Vollständigkeitslücke der `span-*`-Familie geschlossen. Der Befund
gilt als **aufgelöst**.

**F-10 — WIDERLEGT, mit Beleg, und nicht bloß „neu gefasst".** Der Vorbefund zitierte die
Mutation als *„ersetzt `if s.AgentRole != ""` durch `if true`"*; dieses Muster existiert
nicht mehr. Der heutige Fall (`test/mutations/145-report-rollenlose-im-nenner.sh:17`) ersetzt
`if s.AgentRole != "" && s.Tool != "" {` durch `if s.Tool != "" {`. Sein Kommentar (`:14-15`)
sagt: *„Faerbt zusaetzlich TestAggregiere_SammelpostenWirdAnteiligVerteilt rot: auch dessen
Bestand traegt rollenlose Calls."* — **das trifft zu.** Der Bestand von
`TestAggregiere_SammelpostenWirdAnteiligVerteilt` (`report_test.go:76-81`) enthält zwei
`Agent`-Spans **ohne** `agent_role` (die Hilfsfunktion `agentSpan`, `:24-31`, setzt das Feld
nie), also genau die rollenlosen Calls, die der Kommentar nennt. Unter der Mutation entsteht
daraus (a) ein Rollen-Eintrag mit leerem Namen und (b) ein um 2 zu großer Nenner. Nachgerechnet:
`toolCalls[""]=2`, `["planner"]=3`, `["reviewer"]=1`, `summeCalls=6` → `planner.Zugeteilt = 51`
statt der zugesicherten **75** (`report_test.go:96`). Das Zusatz-Rot hat damit **zwei
voneinander unabhängige Ursachen**; die Kausal-Aussage des Kommentars benennt die gemeinsame
Wurzel beider. Das *failure-szenario* des Vorbefunds — *„wird die `r.Name == ""`-Zusicherung
entfernt, verschwindet das Zusatz-Rot"* — ist am heutigen Code **falsch**: die
`Zugeteilt`-Zusicherung fängt es weiterhin. Kein Nachzug fällig; die Zeile *„Der Kommentar von
`test/mutations/145` …"* in der Closure-Notiz §7 (Tabelle *Offen, mit Träger*) ist damit
gegenstandslos.

**F-8 — verfallen, mit Beleg, und das trägt.** Die zwei Zahlen stehen in einer
Commit-Message; die Historie wird nach [`AGENTS.md`](../../AGENTS.md) §3.3-Logik nicht
umgeschrieben, und die gemessenen Werte stehen im Erst-Review. Kein lebendes Artefakt trägt
sie. Kein Befund.

**V4 — die Entscheidung, §3 **nicht** nachzuziehen, trägt.** Modul 9 setzt die Reihenfolge
Plan → Diff → Code; eine Plan-Tabelle, die nachträglich zur Lieferung passend gemacht wird,
verliert genau die Eigenschaft, wegen der sie existiert. Die fünf Abweichungen sind in §7
Punkt 1 einzeln benannt. Kein Befund — mit **einer** Zahl-Korrektur, s. B6.

---

## Findings

Jedes Finding folgt dem §Output-Schema des Reviewer-Skills. HIGH zuerst, dann absteigend.
**HIGH: keines.**

### B1 — Vier tragende Sätze der `Makefile`-Kürzung fehlen; einer koppelt ein Ziel **in `gates`** an den Prüfbereich eines Gates (F-7, neu eingestuft LOW → MEDIUM)

- `kategorie`: **MEDIUM** (Vorbefund F-7: LOW)
- `quelle`: [`AGENTS.md`](../../AGENTS.md) **§3.7** (*Kopplung* und *Abgrenzung* sind zwei der
  fünf Klassen, die ein Kommentar tragen darf) · Reviewer-Skill §LOW (*latente Wartungsfalle*)
  **plus** §Kontext-Eskalation (*dieselbe Beobachtung im Gate-Pfad steigt eine Stufe*)
- `pfad`: `Makefile:107-109` (`smoke`), `Makefile:142-145` (`baseline-verify`),
  `Makefile:149-155` (`regelwerk-check`), `Makefile:160-165` (`baseline-freshness`)
- `befund`: Am HEAD selbst gemessen, je Muster gegen `Makefile`: *„Logik in harness/tools"* →
  **0** Treffer, *„shell-lint sie deckt"* → **0**, *„Fetch↔Vergleich"* → **0**, *„hermetisch
  testbar"* → **0**, *„auf `sources` isoliert"* → **0**. Der erste Satz stand an **drei**
  Zielen (`smoke`, `baseline-verify`, `baseline-freshness`), und **`baseline-verify` steht in
  der `gates:`-Kette** (`Makefile:254`). Der `regelwerk-check`-Satz war die einzige Erklärung
  der **sechs** `--disable`-Flags, die in dessen Rezept unverändert stehen (selbst gezählt:
  6). Der Prüfbereich von `shell-lint` (`Makefile:126`) ist `.claude/hooks/*.sh
  harness/tools/*.sh internal/emit/templates/*.sh internal/emit/templates/enforce/*.sh
  test/mutations/*.sh` — der `Makefile`-Rezeptkörper liegt außerhalb.
- `failure-szenario`: Ein Wartungsschritt zieht die Logik von `baseline-verify` als
  mehrzeiligen Shell-Block ins Rezept zurück. `make shell-lint` deckt sie danach nicht mehr,
  bleibt aber **grün**, und `make gates` meldet weiter Erfolg über einem geschrumpften
  Prüfbereich — der Satz, der genau das verboten hätte, steht nicht mehr da. Zweiter Pfad:
  wer die sechs `--disable`-Flags streicht, kann nicht mehr erkennen, dass die Doku-Module
  dort absichtlich aus sind, weil `docs-check` sie deckt.
- `warum eine Stufe höher als F-7`: Die neue Regel greift an ihrem ersten realen Fall — aber
  **nicht** so, dass die Löschung selbst ein Hard-Rule-Bruch wäre (§3.7 bestimmt, *was ein
  Kommentar sagt*, nicht, *dass zu einer Kopplung ein Kommentar existieren muss*; deshalb
  **kein** HIGH). Was §3.7 leistet, ist die Trennschärfe, die der Kürzung gefehlt hat: sie
  liefert das Kriterium, nach dem *Deliberation* und *Herkunfts-Prosa* zu Recht fielen und
  *Kopplung* und *Abgrenzung* hätten bleiben müssen. Damit trägt der LOW-Anker des Skills
  (*Doku-Drift: Prosa-Listen, veraltete Beispiele*) für diesen Text nicht mehr — er ist nach
  der repo-eigenen Klassifikation der **tragende** Inhalt eines Kommentars. Die Eskalation um
  eine Stufe ruht auf **einer** der vier Fundstellen: `baseline-verify` läuft in `gates`, und
  die entfallene Kopplung zeigt auf den Prüfbereich eines zweiten Gates. Die drei übrigen
  Fundstellen (`smoke`, `regelwerk-check`, `baseline-freshness` — alle Nicht-Gate) trügen für
  sich LOW.
- `verifizierbar`: **nein, kein Gate** — `make comment-claims` prüft vier Pfad-Muster und
  schließt den `Makefile` dauerhaft aus ([`AGENTS.md`](../../AGENTS.md) §4); die fünf
  `grep -c`-Läufe oben belegen den Ist-Zustand, nicht seine Zulässigkeit.

### B2 — `MR-022` und `AGENTS.md` §3.7 erklären die **Platzierung** zur Abweichung; die Upstream-Fassung führt die Regel an genau derselben Stelle

- `kategorie`: **MEDIUM**
- `quelle`: [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) (der
  Adaptions-Register-Zweck: *keine stille Abweichung* — und im Umkehrschluss keine erfundene) ·
  [`MR-022`](../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
  Adaption **Punkt 2** · Reviewer-Skill §MEDIUM (*Spec-Treue-Lücke einer Messmethode*)
- `pfad`: `harness/conventions.md:1028-1030` (`MR-022`, Punkt 2 *Platzierung*) und
  `AGENTS.md:136-141` (dieselbe Aussage im Klartext)
- `befund`: Beide Stellen sagen, upstream stehe die Regel *„in den Grundlagen … **nicht als
  Hard Rule**"*, und leiten daraus eine Platzierungs-Abweichung dieses Repos ab. Gegen den
  gepinnten Upstream-Tag **`v5.3.0`** selbst gemessen (`git show v5.3.0:<pfad>`, lokales
  Kurs-Repo): `lab/templates/AGENTS.template.md:150` trägt die Überschrift **`### 3.7 Ein
  Kommentar beschreibt, was da ist`** — identischer Titel, identische Nummer, im
  Hard-Rules-Block **§3**, mit denselben fünf Klassen und denselben zwei
  Falsch/Richtig-Paaren. Und `lab/regelwerk/grundlagen-harness-dateien.md:100` schreibt
  ausdrücklich *„**Hard Rule:** *Ein Kommentar beschreibt, was da ist.*"*. Die Platzierung
  dieses Repos ist gegen die neuere Baseline **konform**, nicht abweichend. Die erste Hälfte
  des Satzes (*Grundlagen, referenziert aus dem Implementierungs-Modul*) trifft dagegen zu
  (`lab/regelwerk/modul-09-implementierung.md:181`). — Punkt **1** von `MR-022` habe ich
  ebenfalls geprüft und **bestätigt**: im vendored `v3.5.2` existiert
  `grundlagen-harness-dateien.md` nicht (21 Dateien, selbst gelistet), *„Was ein Kommentar
  trägt"* hat **0** Treffer, und `templates/AGENTS.template.md` führt dort **§3.1–§3.6** ohne
  §3.7 (`git show v3.5.2:lab/templates/AGENTS.template.md` bestätigt dasselbe upstream).
- `failure-szenario`: Der Adaptions-Durchgang der beschlossenen Re-Baseline auf `v5.3.0` liest
  den Auflösungs-Trigger von `MR-022` (*„deckt sie sich … weicht sie ab, bleibt die
  Abweichung"*), hält Punkt 2 für eine fortbestehende Abweichung und lässt sie stehen. Das
  Repo trägt danach dauerhaft eine deklarierte Adaption, die keine ist, und
  [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage)s Blankett-Klausel bleibt
  für einen Punkt aufgehoben, der sie nie gebraucht hat.
- `verifizierbar`: **nein, kein Gate** — kein Sensor dieses Repos liest den Upstream-Baum;
  `make regelwerk-check` prüft den **Hash des gepinnten Assets**, `make baseline-freshness`
  nur, dass ein neuerer Tag existiert. Reproduzierbar mit den zwei `git show v5.3.0:`-Läufen
  oben.

### B3 — Eine repo-weite Hard Rule und ihr Adaptions-Eintrag sind in der Implementer-Rolle in Kraft gesetzt worden; das ist die dritte Instanz derselben Klasse in diesem Slice

- `kategorie`: **MEDIUM**
- `quelle`: Regelwerk `modul-08-agentenrollen.md` §Rollen-Sequenz (*„keine Rolle springt
  rückwärts in eine vorhergehende, ohne Übergabe-Artefakt"*) und §Rollen-Regeln
  (*„Rollen-Trennung ist Kontext-Trennung … nicht im selben Kontextfenster"*) ·
  `modul-09-implementierung.md` §AGENTS.md-Regeln (AGENTS.md ist **Eingabe** jedes
  Implementations-Laufs) · `modul-10-review-harness.md` §Ziel-Form ¶Pflege (*„bei dreimaligem
  gleichem Finding … `AGENTS.md`-Update"* — der Steering-Loop ist der vorgesehene Weg) ·
  Präzedenz im Repo: `docs/reviews/2026-08-08-slice-066-plan-review.md` F-1 (HIGH) und
  `docs/reviews/2026-08-08-slice-066-review.md` F-4 (MEDIUM)
- `pfad`: `AGENTS.md:115-143` (§3.7) und `harness/conventions.md:1016-1048` (`MR-022`),
  beide aus Commit `f7f086e`
- `befund`: `f7f086e` setzt eine **siebte Hard Rule** und einen **Adaptions-Eintrag** in
  Kraft — zwei repo-weit normative Artefakte —, entstanden im Implementations-Kontext dieses
  Slice, ohne Übergabe-Artefakt an eine andere Rolle, ohne Zeile in Plan §3 und ohne DoD-Punkt.
  Der Slice-Plan hält das in §7 Punkt 1 selbst fest. Die **einzige** Präzedenz des Repos läuft
  anders: `c0e9955` (2026-07-20) führte §3.6 als **eigenständigen** Commit ein und nennt in
  seiner Message ausdrücklich den auslösenden Rollen-Übergang — *„Der Reviewer hat sie explizit
  eskaliert: ‚gehoert an den Guide, nicht in einen weiteren Findings-Durchlauf.'"* — also genau
  den Modul-10-Steering-Loop-Weg. Selbst gemessen: `git log -S'### 3.' -- AGENTS.md` liefert
  drei Commits (Bootstrap, `c0e9955`, `f7f086e`).
- `failure-szenario`: Der Ausfall der Rollen-Trennung ist hier nicht hypothetisch, er ist
  **materialisiert**: die falsche Platzierungs-Aussage (B2) ist genau der Befund, den ein
  zweiter Kontext gefunden hätte — sie steht in dem Kontext, der die Regel wollte, und sie ist
  in einem einzigen `git show v5.3.0:`-Lauf widerlegbar. Ebenso ungeprüft blieb, ob eine
  siebte Hard Rule ohne Geltungs-Aussage über den Ist-Bestand tragbar ist (B4). Für jede
  künftige Regel gilt derselbe Pfad: die Rolle, die sie anwendet, formuliert sie.
- `abgegrenzt`: Der **Auslöser** ist nicht zu beanstanden — `MR-022` nennt eine dreimalige
  Einforderung durch den Auftraggeber, und eine Nutzer-Anweisung ist eine legitime Quelle. Der
  Befund betrifft die **Inkraftsetzung**: Form, Ort, Reichweite und Wortlaut einer repo-weiten
  Norm sind Entscheidungen, die in diesem Slice keine zweite Rolle gesehen hat.
- `verifizierbar`: **nein, kein Gate** — der d-check-Modul `commits` ist in `.d-check.yml`
  `modules:` nicht aktiviert; `git log --format='%h %s' edf739d~1..HEAD` zeigt den Commit,
  nicht die Rolle. (Der Befund ist damit die **dritte** Instanz der Klasse in diesem Slice und
  nach Reviewer-Skill §Kontext-Eskalation ein Steering-Loop-Signal — s. Verdikt.)

### B4 — §3.7 gilt repo-weit ohne Geltungs- oder Cutoff-Aussage; der eigene Baum bricht sie am Tag ihrer Einführung in 88 Kommentarzeilen

- `kategorie`: **MEDIUM**
- `quelle`: Regelwerk `modul-09-implementierung.md` §Regeln gegen typische Fehlannahmen
  (*„Eine Hard Rule, die nur in AGENTS.md steht …, ist halbgesetzt. … **Beides ist Pflicht**"*)
  · Reviewer-Skill §MEDIUM (*fehlende Negativtests bei neuem öffentlichen Vertrag*) ·
  Repo-Präzedenz für Cutoffs:
  [`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  und die Cutoff-Begründung in der Roadmap-Achse 8
- `pfad`: `AGENTS.md:115-143` · `harness/conventions.md:1036-1040` (`MR-022`, *Kein Wächter*)
- `befund`: §3.7 erklärt *„Gilt für Code, Konfiguration und Skripte"* und nennt zwei
  Falsch-Klassen: Konjunktiv über die verworfene Alternative und Text, der abwesenden Text
  beschreibt. Weder §3.7 noch `MR-022` sagen, ob die Regel für den **Ist-Bestand** gilt oder
  ab ihrem Commit. Selbst gemessen — **Prüfbereich: alle 212 getrackten `*.go`, `*.sh`,
  `*.awk`, `Makefile`, `Dockerfile` ohne `internal/emit/templates/`** (die emittierte Ebene ist
  von `MR-022` ausdrücklich ausgenommen), gezählt werden nur Zeilen, die mit `#` oder `//`
  beginnen: **88** Zeilen tragen Befund-Kennungen oder Herkunfts-Prosa. Stichproben, selbst
  gelesen: `harness/tools/span-check.sh:18` *„Die frueher hier stehende Fassung liess das Gate
  von seinem eigenen Bau abhaengen … (Review-Befund MEDIUM-1)"*, `internal/span/span.go:108`
  *„Die frueher hier stehende Zusage …"*, `harness/tools/mutate.sh` (12× *Review-Befund*),
  `Dockerfile:93`. Keine dieser Zeilen ist im geprüften Bereich geändert worden. `MR-022`
  benennt die fehlende maschinelle Durchsetzung ehrlich — die fehlende **Geltungs-Aussage**
  benennt es nicht.
- `failure-szenario`: Ein Agent hat `AGENTS.md` nach Modul 9 in jedem Lauf-Kontext, liest §3.7
  als bindend und fasst `harness/tools/mutate.sh` an. Er schreibt entweder einen 69-Zeilen-Kopf
  um — Arbeit weit außerhalb seines Slice, an einer Datei, die den Mutations-Sensor selbst
  trägt — oder er lässt einen ihm bekannten Hard-Rule-Bruch stehen. §3.7 entscheidet das nicht,
  und die erste reale Anwendung der Regel in diesem Slice war eine Kürzung, die überschoss (B1).
- `verifizierbar`: **nein, kein Gate** — `make comment-claims` prüft, ob ein **genannter
  Sensor existiert**, nicht, worüber ein Kommentar spricht (so schreibt es `MR-022` selbst);
  der `Makefile` und `*.awk` liegen ohnehin außerhalb seines Prüfbereichs. Reproduzierbar mit
  dem `git ls-files | xargs grep -nE …`-Lauf oben.

### B5 — `slice-079` beziffert das Mutations-Fall-Format mit 144; der Commit, der die Datei anlegt, hebt den Bestand auf 145

- `kategorie`: **LOW**
- `quelle`: Maintainability · Präzedenz derselben Klasse: Erst-Review F-9 (b) (*„138 reale
  Vorkommen" … bei HEAD sind es 142, verschoben durch den nächsten Commit desselben Bereichs*)
- `pfad`: `docs/plan/planning/open/slice-079-exit-code-vertrag.md:136-137`
- `befund`: Die Zeile schreibt *„gemessen je **144** reale Vorkommen; `# verify:` dagegen nur
  **2**"*. Selbst gezählt: `git ls-tree -r --name-only 0f41911 test/mutations/` → **145**
  `.sh`-Dateien, `git grep -h '^# files:' 0f41911 -- 'test/mutations/*.sh'` → **145**. Am
  HEAD ebenso 145/145/2. Die 144 ist der Stand **vor** dem Commit, der `slice-079` anlegt —
  `0f41911` fügt `test/mutations/149` und die Plan-Datei im selben Zug hinzu (`fe20d8e`: 144
  Fälle, `0f41911`: 145). Die `# verify:`-Zahl **2** stimmt.
- `failure-szenario`: Der Implementer von `slice-079` prüft nach dessen eigener DoD (2) *„ergänzt
  wird nur, was fehlt, und die Lücke wird benannt statt behauptet"* die Zahlen nach, findet die
  erste geprüfte falsch und misst die ganze Zeile neu — genau der Aufwand, den die Angabe
  ersparen soll. Der Satz begründet zudem den **Ausschluss** des Formats aus `slice-079`, ruht
  also auf einer Zahl.
- `verifizierbar`: **ja, ohne Gate** — `ls test/mutations/*.sh | wc -l` gegen
  `git ls-tree -r --name-only 0f41911 test/mutations/ | grep -c '\.sh$'`.

### B6 — Die Closure-Notiz zählt vier von fünf `Makefile`-Hunks als `span-report`-frei; es sind drei

- `kategorie`: **LOW**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (die Zusage auf das einschränken, was der Baum
  hält) · dieselbe Klasse, die die Closure-Notiz in ihrem eigenen Steering-Loop-Eintrag 1
  benennt
- `pfad`: `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md:213-214`
- `befund`: §7 Punkt 1 schreibt *„Vier der fünf `Makefile`-Hunks betreffen `span-report`
  nicht"*. Selbst gemessen über `git diff edf739d~1..HEAD -- Makefile`: **5** Hunks, davon
  nennen **zwei** `span-report` — Hunk 1 (`@@ -34,21 +34,23 @@`, die `.PHONY`-Zeile) und
  Hunk 5 (`@@ -247,24 +225,30 @@`, das neue Ziel). `span-report`-frei sind die Hunks 2, 3 und
  4, also **drei**. Die Aussage, um die es geht — *geliefert ist mehr als §3 vorsieht* —, bleibt
  richtig; ihre Ziffer nicht.
- `failure-szenario`: Wer §7 später als Beleg für den Umfang des Beifangs heranzieht, zählt nach
  und findet die erste Zahl der Aufzählung falsch; die vier weiteren Positionen desselben
  Punktes stehen danach unter Verdacht, obwohl sie stimmen.
- `verifizierbar`: **ja, ohne Gate** —
  `git diff edf739d~1..HEAD -- Makefile | awk '/^@@/{h++} /span-report/{c[h]++} END{…}'`.

### B7 — Der Rang-Zeiger im Paket-Kommentar zeigt auf die **verworfene** Alternative statt auf die gewählte

- `kategorie`: **INFO**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (Klasse *Rang-Zeiger*: *„Wo wohnt die Norm,
  deren Umsetzung das hier ist?"*) ·
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md) §Verglichene Alternativen
- `pfad`: `internal/report/report.go:3-4`
- `befund`: Der Satz lautet *„Der Gegenstand ist NUR der Bestand unter dem Ablageort — kein
  Transkript, keine Quelle ausserhalb des Repos (ADR-0011 Alternative D)."* Alternative **D**
  ist in `ADR-0011:275` *„nur Transkripte auswerten, gar nicht erfassen"* — die **verworfene**
  Option. Die Norm, deren Umsetzung dieses Paket ist, ist die gewählte Option **C**
  (`ADR-0011:273`, dort ausdrücklich *„(gewählt)"*).
- `failure-szenario`: Ein Leser folgt dem Zeiger und liest die D-Zeile als die Festlegung, die
  dieses Paket umsetzt — sie sagt das Gegenteil dessen, was der Code tut.
- `verifizierbar`: **nein, kein Gate** — `make comment-claims` prüft Sensor-Namen, keine
  ADR-Optionsbuchstaben.

### B8 — `0f41911` trägt Implementer- und Planner-Arbeit in einem Commit; die Rollen-Zuordnung steht nur in der Message

- `kategorie`: **INFO**
- `quelle`: Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln · Erst-Review F-4 (*„die
  Rollen-Zuordnung ist am Artefakt selbst nicht ablesbar"*)
- `pfad`: Commit `0f41911` (`git show --stat`)
- `befund`: Derselbe Commit ändert `internal/report/report.go`, `spec/spezifikation.md` und
  `test/mutations/149` (Implementer-Arbeit zu F-5/F-6) **und** `docs/plan/planning/in-progress/roadmap.md`
  sowie `docs/plan/planning/open/slice-079-exit-code-vertrag.md` (Planner-Arbeit zu F-4). Die
  Trennung der Kontexte ist ausschließlich in der Commit-Message behauptet (*„vom Planner
  abgeraeumt, in frischem Kontext"*) und am Baum nicht nachvollziehbar. Die **Sache** ist
  korrekt aufgelöst: die beanstandete Kandidaten-Zeile existiert nicht mehr, ihr Substanz-Rest
  liegt als `slice-079` vor.
- `failure-szenario`: Ein späterer Rollen-Audit über `git log` kann für keinen der beiden
  Änderungsteile belegen, aus welchem Kontext er stammt — genau die Eigenschaft, die F-4
  beanstandet hat, reproduziert sich im Commit, der F-4 auflöst.
- `verifizierbar`: **nein, kein Gate** — `git show --stat 0f41911`; der d-check-Modul `commits`
  ist nicht aktiviert.

## Negativbefunde

- geprüft, ohne Befund: **Hard Rule §3.1 (keine halluzinierten Gates).** `span-report` steht an
  allen drei Orten ausdrücklich als **Nicht**-Gate — `AGENTS.md` §4 Nicht-Gate-Verify-Absatz,
  `harness/README.md` §Nicht-Gate-Verify, `Makefile:243` (`## … NICHT in gates`) — und ist in
  keiner der beiden Gate-Tabellen. Die `gates:`-Prerequisitenliste (`Makefile:254`) ist im Diff
  nur Kontext; `git diff … | grep -E '^[-+]gates:'` ist **leer**.
- geprüft, ohne Befund: **Hard Rule §3.2 (Suppression-Verbot).** Über alle getrackten `*.go`,
  `*.sh`, `Makefile`, `Dockerfile` ohne `internal/emit/templates/`: **0** Treffer für
  `//nolint` bzw. `# shellcheck disable`. Der einzige `+`-Treffer im Range-Diff ist Prosa im
  Erst-Review-Report, kein Code.
- geprüft, ohne Befund: **Hard Rule §3.3.** `git log --diff-filter=R edf739d~1..HEAD` → **0**
  Renames im Bereich. Die Closure-Notiz ist **vor** dem Move geschrieben worden (Inhalt zuerst,
  reiner `git mv` danach) — das ist die richtige Reihenfolge, nicht ihre Verletzung.
- geprüft, ohne Befund: **Hard Rule §3.4.** `git diff --name-only edf739d~1..HEAD -- docs/plan/adr/`
  → **0** Dateien. Statuszeilen von `ADR-0003`/`0011`/`0012`/`0013` einzeln gelesen, alle
  **Accepted**; keine superseded ADR referenziert.
- geprüft, ohne Befund: **Hard Rule §3.5.** Keine Modul-Aktivierung, keine Schwelle, kein
  `--disable`/`--enable` im Diff geändert; `regelwerk-check` trägt unverändert sechs
  `--disable`-Flags.
- geprüft, ohne Befund: **Hard Rule §3.6 am neuen öffentlichen Vertrag.** Der `report`-Vertrag
  hat zehn Go-Tests (`internal/report/report_test.go`, selbst gezählt: 10 `func Test…`) plus
  zwei in `cmd/span-report/main_test.go`, und zehn Mutations-Fälle (140–149), je mit einer
  `# expect:`-Zeile, die auf einen existierenden Wächter zeigt.
- geprüft, ohne Befund: **Reichweite der zwölf `sed`-Anker in 140–149.** Jedes Muster einzeln
  gegen `internal/report/report.go` gezählt (Zeilenweise, mit denselben Ankern wie die Fälle):
  **je genau ein Treffer**, kein Muster über-reicht. 145 und 147 zielen bewusst auf **dieselbe**
  Zeile mit komplementären Mutationen (erstes bzw. zweites Konjunkt) — beide Effekte sind
  getrennt bewacht.
- geprüft, ohne Befund: **Mutations-Deckung der Closure-Notiz.** Die Notiz behauptet, der
  `make mutate`-Lauf trage bis `b74df5d`, weil keine der 37 Zieldateien sich seither geändert
  habe. Selbst gemessen: `# files:`-Ziele über alle 145 Fälle = **37** eindeutige Pfade;
  `git diff --name-only 0f41911..HEAD` = 6 Dateien (`AGENTS.md`, `harness/conventions.md`,
  `harness/README.md`, zwei Plan-Dateien, ein Review-Report); **Schnittmenge leer**. Die
  Behauptung hält.
- geprüft, ohne Befund: **Formregeln von `spec/spezifikation.md` §5** (§Aufnahme-Regel), am
  **gewachsenen** bindenden Block (Zeilen 403–432, seit dem F-5/F-6-Fix vier Absätze länger als
  bei der Verifikation). Fünf Muster einzeln: `slice-[0-9]` → 0, `welle-[0-9]` → 0,
  `Slice [0-9]` → 0, `(ADR|LH|MR|CO)-[0-9]` → 0, nacktes `slice-` → 0.
- geprüft, ohne Befund: **`ADR-0012` Festlegung 2 / Folgepflicht 4 am heutigen Code.** Nenner
  (`report.go:247`), Sammelposten-Anteil (`:280`) und Abdeckungszahl (`:286`) stehen als drei
  getrennte Zeilen, jede mit eigenem Test **und** eigenem Mutations-Fall (140/141/142); keine
  ist mit einer anderen zusammengelegt.
- geprüft, ohne Befund: **`ADR-0011`.** Die Auswertung liest ausschließlich `*.jsonl` unter dem
  Ablageort, netzlos (`--network none`), read-only (`:ro`-Mount); kein Transkript, keine Quelle
  außerhalb des Repos. Die Ausgabe druckt nur Rollennamen, Summen, Prozentsätze, Sitzungszahl
  und Zeitgrenzen — keine Pfade, Kommandos oder Payload-Reste.
- geprüft, ohne Befund: **`ADR-0003` / `LH-QA-03` (Docker-only, minimale Abhängigkeiten).** Die
  neue `report`-Stage baut im per Digest gepinnten `deps`-Image mit `--build-arg GO_VERSION`,
  ohne `TARGET_OS`/`TARGET_ARCH` und ohne `artifact-copy`; sie ist die **letzte** Stage im
  `Dockerfile` und ändert keinen Default-Build, weil alle `docker build`-Aufrufe ein `--target`
  nennen. `go.mod`/`go.sum` sind im Range unverändert; dieser Review hat keine Host-Toolchain
  benutzt.
- geprüft, ohne Befund: **`slice-079` als neues Planner-Artefakt.** Struktur vollständig (§1–§8),
  zwei slice-eigene DoD-Punkte plus die drei Standard-Zeilen (Modul-5-Grenze ≤ 3 eingehalten),
  `MR-016`-Test mit allen drei Fragen samt Antwort ausgeschrieben, `open/`-Ablage konsistent mit
  dem Lifecycle-Absatz, Bezugs-Block mit vier auflösbaren Kennungen. Einzige Beanstandung: B5.
- geprüft, ohne Befund: **`slice-071` §6 als Träger.** Beide von `slice-066` abgegebenen Posten
  (F-12: fehlender vs. leerer Ablageort; V5: Bestandszeile vs. Streuung der Summe) stehen dort
  wörtlich und mit Begründung, nicht als Verweis auf eine Befund-Kennung.
- geprüft, ohne Befund: **`harness/tools/extract-agent-call.awk`.** Der Kopfkommentar nennt die
  Eigenschaft (*eine zweite Verteidigungslinie gibt es dafür heute nicht, weil die Abdeckungszahl
  innerhalb derselben Quelle zählt*) statt einer Planungs-Kennung; die Aussage trifft zu und ist
  §3.7-konform.
- geprüft, ohne Befund: **§3.7-Konformität der im Range **neu geschriebenen** Kommentare.**
  `internal/report/report.go`, `cmd/span-report/main.go`, `test/mutations/140–149` und die
  gekürzten `Makefile`-Blöcke einzeln gelesen: durchweg Indikativ über den Zustand, kein
  Konjunktiv über eine verworfene Alternative, keine Befund-Kennung, keine Beschreibung
  abwesenden Textes. `report.go:41-43` ist wörtlich das *Richtig*-Beispiel aus §3.7. Der
  Konjunktiv in den Mutations-Kommentaren beschreibt den **Bruch**, den die Mutation erzeugt —
  nach §3.7 zulässig. Einzige Ausnahme: B7.
- geprüft, ohne Befund: **Steering-Loop-Messung der Closure-Notiz.** *„57-mal, verteilt auf 32
  Dateien"* selbst nachgezählt über `docs/plan/planning/done/` (82 Dateien): **57** Treffer der
  drei kanonischen Lehr-Formen in **32** Dateien. *„Das Wort Lerneintrag kommt … nullmal vor"*:
  `AGENTS.md` 0, `harness/conventions.md` 0, `harness/README.md` 0, `.harness/skills/reviewer.md` 0.
  Beide Messungen reproduzieren exakt.
- geprüft, ohne Befund: **`MR-022` Sachaussage 1 und der Auflösungs-Trigger.** Beides gemessen
  und tragfähig (Details in B2); die Konstruktion *Vorgriff mit benanntem Auflösungs-Trigger*
  ist die richtige Form für eine Regel, die vor der Re-Baseline gebraucht wird.
- **nicht geprüft** (und deshalb nicht behauptet): (a) `make gates` und `make mutate` — nicht
  wiederholt, Rollen-Grenze Modul 10 §Anti-Pattern; die letzten Läufe sind vom Verifier bei
  `0f41911` bezeugt, die drei Commits danach berühren keine Mutations-Zieldatei (oben gemessen).
  (b) Die DoD-Abhakung — Gegenstand der Verifikation. (c) Die **inhaltliche** Richtigkeit der
  fünf Klassen aus §3.7 gegen den Upstream-Volltext von `grundlagen-harness-dateien.md`: geprüft
  ist die **Existenz und Platzierung** der Regel (B2), nicht, ob der gekürzte Repo-Wortlaut die
  Upstream-Semantik vollständig trägt — das gehört in den Adaptions-Durchgang der Re-Baseline.

## Kategorie-Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 4 |
| LOW | 2 |
| INFO | 2 |

Zum Vergleich Erst-Review (2026-08-08): 0 / 4 / 5 / 3. **Keiner** der vier damaligen MEDIUM
und keiner der zwei Verifikations-MEDIUM steht noch; alle vier neuen MEDIUM sind an Artefakten
entstanden, die der Erst-Review nicht im Gegenstand hatte.

## Verdikt

**NICHT KONFORM.** **Merge-blockierend: ja** — wegen der vier MEDIUM (B1–B4). HIGH: keines.

**Der Auswerter selbst ist konform, und das ist die wichtigere Hälfte des Verdikts.** Die
Substanz dieses Slice trägt in ihrer heutigen Fassung: die sechs blockierenden Befunde der
zwei Vorgänger-Runden sind aufgelöst (F-1 an realen Daten, F-2/F-5/F-6 im Code und in §5,
F-3/V2/V3 im Plan, F-4 durch Verwerfen, V1/F-11 in beiden Doku-Orten), die zwölf `sed`-Anker
der zehn Mutations-Fälle greifen je genau einmal, der bindende §5-Text ist auch in seiner
gewachsenen Fassung kennungsfrei, und die Hard Rules §3.1–§3.6 halten ohne Ausnahme. Ein
Verdikt allein über `cmd/`, `internal/`, `spec/` und `test/` wäre **konform**.

**Blockierend ist der Beifang, nicht die Bilanz.** Alle vier MEDIUM sitzen in Artefakten, die
im Slice-Plan §3 keine Zeile haben und deren Reichweite über den Slice hinausgeht: die
`Makefile`-Kürzung (B1) und die drei Befunde am Paar `AGENTS.md` §3.7 / `MR-022` (B2, B3, B4).
Zwei davon sind Ein-Satz-Korrekturen (B2: die Platzierungs-Aussage streichen oder auf den
gemessenen Stand ziehen; B4: eine Geltungs-/Cutoff-Zeile), B1 ist das Wiedereinsetzen von vier
Sätzen, B3 ist eine Rollen-Entscheidung.

**Zur Streitfrage F-7 — die Regel greift, aber nicht so weit, wie beide Lesarten annehmen.**
Sie ist **nicht** von Geburt an folgenlos: §3.7 liefert das Kriterium, nach dem die Kürzung
hätte trennen müssen, und hebt den Befund um eine Stufe, weil der LOW-Anker *Prosa* für Text
nicht mehr trägt, den das Repo selbst als *Kopplung* und *Abgrenzung* führt. Sie macht die
Löschung aber **nicht** zum Hard-Rule-Bruch: §3.7 bestimmt, was ein Kommentar *sagt*, nicht,
dass zu einer Kopplung einer *stehen muss*. Die zweite Stufe kommt nicht aus §3.7, sondern aus
§Kontext-Eskalation des Reviewer-Skills, und sie ruht auf genau **einer** der vier Fundstellen
— `baseline-verify` läuft in `gates`.

**Steering-Loop-Signal (Modul 10 §Pflege).** B3 ist die **dritte** gemessene Instanz der Klasse
*„ein Artefakt einer anderen Rolle ist im Implementations-Kontext geändert worden"* in diesem
einen Slice: Plan-Review F-1 (DoD, HIGH), Code-Review F-4 (Roadmap, MEDIUM), hier
`AGENTS.md` §3.7 + `MR-022`. Die dritte Wiederholung verlangt nach Skill und Modul 10 einen
**Träger** statt eines vierten Einzel-Findings — und die Closure-Notiz benennt in ihrem eigenen
Steering-Loop-Eintrag 1 genau diese Lücke (*„welchen Träger bekommt ein Lerneintrag"*), ohne sie
auf die Rollen-Grenze anzuwenden. Auffällig ist die Richtung: die Klasse hat sich in diesem
Slice **aufwärts** bewegt — DoD → Roadmap → repo-weite Hard Rule.

**Konflikt-Pfad (Modul 8).** B1–B4 sind **kein** HIGH mit Rollen-Widerspruch; die
Sequenz-Modellierung aus Modul 8 §Konflikt-Pfad ist hier nicht auszulösen. Sollte einer der
vier Befunde mit Verweis auf eine gegenläufige Einschätzung des Implementers bestritten werden,
gilt jedoch die dortige Regel unverändert: *„Reviewer-Finding herabstufen, weil der Implementer
widerspricht"* ist der ausdrücklich falsche Pfad.

**Ist die Closure jetzt frei? Nein.** Der Closure-Trigger des Slice (§5) verlangt *„Review
konform (Modul 10) mit ausgestelltem Verdikt"*. Das Verdikt ist hiermit **ausgestellt** — die
Formbedingung ist erfüllt —, es lautet aber **nicht konform**. Zusätzlich benennt die
Closure-Notiz selbst zwei Posten mit dem Träger *„dieser Slice, offen"*: der `Makefile`-Posten
besteht (B1), der `test/mutations/145`-Posten ist mit diesem Report **gegenstandslos** und
kann aus der Tabelle fallen.

**Übergabe:** B1, B2, B4, B5, B6, B7 gehen an die Implementation. B3 hat seine Ursache in der
Rollen-Führung und damit die Rückkante Review → Planner; dieser Report ist das
Übergabe-Artefakt. B8 ist eine Beobachtung ohne Nachzug. Der Report ersetzt keine Verifikation
— DoD- und Spec-Konformität hat der Verifier am 2026-08-08 separat geprüft (Modul 11, anderes
Prüf-Artefakt, anderer Eingabe-Kontext). Eine weitere Bestätigungsrunde bekommt eine **neue**
Datei; dieser Report wird nicht überschrieben.
