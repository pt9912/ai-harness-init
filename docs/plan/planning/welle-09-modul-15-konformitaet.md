# Welle welle-09: Modul-15-Konformität — Regeln ohne Feedback-Quadrant schließen

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-09-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug (Konformitäts-Welle, keine Nutzer-Fähigkeit).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-28.

---

## 1. Welle-Ziel

**Jeder der vier Regelblöcke von `modul-15-observability.md` trägt am Ende — auf BEIDEN Ebenen —
einen laufenden Sensor, eine deklarierte Entscheidung mit Auflösungs-Trigger oder das Verdikt
einer ADR, dass die Abweichung permanent ist; und nichts dazwischen.** Die beiden Ebenen sind:

1. **das Repo** (Dogfood: was hier läuft) und
2. **das Tool** (was `ai-harness-init` ins Ziel-Repo emittiert).

„Nichts dazwischen" ist der Kern: der heutige Zustand ist auf beiden Ebenen weder Umsetzung noch
Entscheidung, sondern Schweigen.

**Warum beide Ebenen in dieselbe Welle gehören.** Das Tool emittiert das **vollständige
Regelwerk** ins Ziel — Modul 15 inklusive. Ein bootstrappedes Repo bekommt also dieselben Regeln
und dieselbe Leere. Würden wir nur die Dogfood-Seite schließen, reparierten wir **ein** Repo und
lieferten die Lücke weiter an jedes andere. Die Ebenen haben verschiedene Verträge (unten §3),
aber es ist eine Frage, und sie hier zu trennen hieße, die zweite Hälfte zu vergessen.

**Zur Begründung — korrigiert gegenüber der ersten Fassung dieses Plans (2026-07-28, gemessen).**
Die erste Fassung stützte die Welle darauf, dass
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) *„keine inhaltlichen
Adaptionen"* erkläre und die Nicht-Umsetzung damit eine **nicht deklarierte Abweichung** sei.
Das war **über-gelesen**: die vendored Vorlage
(`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`) grenzt dieselbe Aussage
ausdrücklich ein — *„für Verzeichniskonvention, Lifecycle-Regeln, Carveout-Disziplin,
ID-Schema"*. Die Baseline behauptet **nirgends**, jede Regel jedes Moduls sei umgesetzt; sie
behauptet strukturelle Konformität. Unser [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) hat die Aufzählung fallen lassen und daraus
eine pauschale Aussage gemacht.

Die tragfähige Begründung ist deshalb die schwächere und wahre: **Modul 15 ist adoptiert,
in keinem Block umgesetzt und nie diskutiert — niemand hat je entschieden, ob das in Ordnung
ist.** Genau das entscheidet diese Welle. *(Nebenbefund, der eigenständig zählt: unser [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)
ist gegenüber der Vorlage eine **Verschärfung**, die als solche nirgends deklariert ist — eine
Adaption, die behauptet, es gebe keine. Sie gehört in slice-062 mit auf den Tisch.)*

**Der Einstieg ist die Erfassung, nicht die Auswertung.** Modul 15 beschreibt einen Agentenlauf
als *Trace aus Spans — einen pro Tool-Call*. Diese Spans entstanden bei uns bis
[slice-059](done/slice-059-telemetrie-erfassung-hook.md) **nirgends**: der `PreToolUse`-Guard sah
jeden Bash-Aufruf samt Argumenten, entschied und **vergaß ihn sofort**. Genau dort setzte die
Welle an — die Mechanik war verdrahtet, es fehlte die Senke. **Seit slice-059 (done) entstehen
sie**, und zwar an `PostToolUse`/`PostToolUseFailure` (seit dem 2026-08-08 zusätzlich an
`SubagentStart`), **nicht** am `PreToolUse`-Guard; eine
frühere Fassung dieses Absatzes stand im Präsens und beschrieb damit einen überholten
Ist-Zustand.

Dass die Oberfläche das hergibt, ist **gemessen, nicht angenommen** (2026-07-28, Werkzeug-Doku
<https://code.claude.com/docs/de/hooks>): Ergebnis- und Fehlschlag-Event, eine gemeinsame
Aufruf-ID über beide, `transcript_path` als **damals angenommene** Brücke zu den Token-Zählern, Hooks feuern **auch in
Subagenten**, und ein leerer Matcher trifft **alle** Tools. Die Quelle ist dabei **nicht
gepinnt** und wird von keinem Gate geprüft — sie belegt die Aussagen, sie ersetzt sie nicht;
die Fakten stehen in slice-059 §3 ausgeschrieben.

Die Welle **faltet den Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen* hinein**,
statt eine zweite Wahrheit danebenzustellen: dessen Achse (1) — die Gate-Tabellen in
[`AGENTS.md`](../../../AGENTS.md) §4 und [`harness/README.md`](../../../harness/README.md)
§Sensors werden von nichts gegen das [`Makefile`](../../../Makefile) gehalten — **ist**
Modul-15-Block-4.

## 2. Trigger (Welle startet)

- **Nutzer-Befund 2026-07-28**, mechanisch belegt: Modul 15 liegt seit `554cade`
  (2026-07-17, slice-011) im Repo und taucht seither in **vier** Commits auf — 011, 019, 043,
  049, allesamt Re-Vendor-Läufe, die es mitkopiert haben. Commits, die es inhaltlich behandeln:
  **0**. Commits mit „Observability"/„Telemetrie" im Betreff: **0**.
- **Warum es nie in den Blick kam** (die eigentliche Lücke, und sie ist größer als Modul 15):
  die Adoptions-Mechanik prüft bei jeder Re-Baseline das **Normativ-Delta** — so entstand
  [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).
  Modul 15 war nie ein Delta; es kam am ersten Tag vollständig mit. **Delta-Prüfung sieht
  Änderungen, nie den Bestand** — kein Sensor meldet „adoptiert, aber nicht umgesetzt".
- slice-058 ist `done/`, `in-progress/` ist leer, `make gates`/`mutate`/`full-smoke` grün
  (green-before-extend).

## 3. Closure-Trigger (Welle schließt)

- Alle Slices dieser Welle in `done/`.
- **Je Regelblock UND je Ebene ein belegter Zustand** — die Closure-Tabelle in
  `welle-09-results.md` ist eine **4 × 2-Matrix** (vier Blöcke × {Repo, Tool}), jede Zelle mit
  einem Wert aus der Tabelle unten und dem Kommando daneben. Welche Werte in Frage kommen, hängt
  an der Spalte: **Sensor** und **deklariert** gelten der Repo-Spalte, **emittiert** und **nicht
  emittiert** der Tool-Spalte, **ADR-Verdikt** beiden — permanent ist eine Eigenschaft der
  Abweichung, nicht der Ebene. Bündelt eine Zelle mehrere Abweichungen, nennt sie den Wert **je
  Abweichung**; die Zelle *Token-Attribution × Repo* ist genau dieser Fall (slice-068 DoD (3)).
  **Für sie ist der Wert *Sensor* ausgeschlossen:** ablesbar ist die Regel dahinter zum Teil
  an einer Berichtsgröße, und ein Bericht ist kein Wächter — er läuft nicht als Gate, er färbt
  nichts rot, er hat keinen `test/mutations/`-Fall. Welchen der übrigen Werte die Zelle je
  Abweichung führt, steht in ihrer Slice-Zeile in §4.

  | Wert | Bedeutung |
  |---|---|
  | **Sensor** | läuft real, mit `test/mutations/`-Fall ([`AGENTS.md`](../../../AGENTS.md) §3.6) |
  | **deklariert** | bewusste Nicht-Umsetzung, ausgeschrieben mit Geltungsbereich, Begründung und **Auflösungs-Trigger**. Diese drei Angaben sind der Wert; das Gefäß folgt dem Gegenstand nach [`ADR-0013`](../adr/0013-technik-stratum-als-zielort.md): eine Abweichung von der adoptierten Baseline steht als `MR-<NNN>` im Adaptions-Block, eine technische Festlegung dieses Repos als erklärte Abweichung im Technik-Stratum ([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder), Rang 2). Wer den Wert am Gefäß statt an den drei Angaben festmacht, erklärt eine vollständige Deklaration am falschen Ort für keine |
  | **ADR-Verdikt** | die Abweichung ist **permanent** und in einer ADR entschieden — Geltungsbereich und Begründung wie bei „deklariert", aber **ohne Auflösungs-Trigger**: Modul 7 §Werkzeug-Wahl lässt ihn auf dem ADR-Pfad wegfallen. An seiner Stelle nennt die Zelle die Re-Evaluierungs-Trigger der ADR, die niemand herbeiführt, sondern bemerkt. Erster Fall: [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md) |
  | **emittiert** | im Ziel vorhanden **und dort rot gesehen** (s. u.) |
  | **nicht emittiert** | begründete Entscheidung **mit Auflösungs-Trigger** — dieselbe Pflicht wie bei „deklariert"; eine Entscheidung, die sich ohne Trigger als temporär ausgibt, ist nach Modul 7 die permanente Ausnahme, die lügt. Ist sie wirklich permanent, gehört sie in eine ADR und die Zelle trägt „ADR-Verdikt" |

  Eine leere Zelle ist ein offener Closure-Trigger — kein „passt schon".
- **Die Tool-Spalte braucht ihren eigenen Beleg, und „grün" genügt nicht.** Ein emittierter
  Mechanismus, der **nie feuert**, lässt `make full-smoke` ebenfalls grün — das ist die
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle eine Ebene weiter. Verlangt sind daher **beide** Richtungen, wie in welle-08
  etabliert: (a) das frisch gebootstrappte Ziel ist out-of-the-box grün (Lehre aus slice-028),
  **und** (b) ein Gegenbeispiel im Ziel wird **rot gesehen** — für einen emittierten Span-Emitter
  etwa: er läuft, und ein Lauf ohne Pflicht-Feld fällt auf. **Wen diese Pflicht trifft, sagt der
  Zellwert:** sie gilt jeder Zelle, die *emittiert* trägt — nach dem Schnitt von slice-062 ist das
  **eine**, *Doku-Konsistenz-Drift × Tool*. Die drei übrigen tragen *ADR-Verdikt*, und für den
  Wert ist nach der Tabelle oben **kein** Sensor und kein Ziel-Beleg geschuldet: seine
  Verbindlichkeit trägt die Entscheidung. Wer für sie einen Ziel-Beleg verlangt, verlangt den
  Beleg einer **Abwesenheit** aus einem Smoke, der Anwesenheit prüft. **Und der Beleg der einen
  Zelle ist über die Bootstrap-Varianten zu klammern:** ein Ergebnis aus *einer* Variante deckt
  die andere nicht, weil `--lang` optional ist ([`ADR-0007`](../adr/0007-bootstrap-phasen.md)) —
  wahr und falsch sind an der Ausgabe des Trägers sonst nicht zu unterscheiden (slice-062 §6).
- `make gates` und `make mutate` grün; jeder neue Wächter hat seinen `test/mutations/`-Fall
  ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **Carveout-Audit (Modul 7) — es liest den STATUS, nicht das Verzeichnis.**
  [`CO-001`](../carveouts/CO-001-bats-shell-lint.md) **und**
  [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) geprüft, neue Carveouts dokumentiert oder
  begründet keine. **Der Ort trägt die Aussage *aktiv* nicht mehr:** ein übergeführter Carveout
  bleibt an seiner Adresse liegen, `ls docs/plan/carveouts/CO-*.md | wc -l` zählt deshalb weiter
  **2** — diese Zahl bewegt sich mit der Überführung **nicht**. Wer *aktiv* von *entschieden*
  trennen will, liest den Kopf: `grep -n '^\*\*Status:' docs/plan/carveouts/CO-*.md`. Ein Audit,
  das einen übergeführten Carveout als *„weiterhin aktiv"* bestätigt, bestätigt eine Entscheidung
  als offene Frage.
- **Die zwei Zellen der Repo-Spalte, die an [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md)
  hingen, tragen *ADR-Verdikt*:** *Token-Attribution × Repo* (Hintergrund-Teil) und
  *Cache-Counter × Repo* (§4). Der Ausfall ist in
  [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) als **permanent** entschieden
  — kein Auflösungs-Trigger, an seine Stelle treten deren Re-Evaluierungs-Trigger; genau der Wert,
  den die Tabelle oben unter *ADR-Verdikt* führt. **Die Reihenfolge gehört zum Kriterium:** der
  Kopf des Stubs trägt den Verdikt-Status, **bevor** die Ergebnis-Notiz die Zellen setzt — sonst
  liest das Audit *Aktiv* und schreibt *deklariert* gegen eine angenommene ADR. Geschrieben wird
  der Status vom Slice, der Folgepflicht 1 jener ADR vollzieht
  ([slice-089](next/slice-089-carveout-co-002-ueberfuehren.md), **kein Mitglied dieser Welle** —
  [`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  Setzung 2 lässt für wellenlose Arbeit auch keinen Roadmap-Eintrag zu). **Prüfkommando statt
  Erinnerung:** `grep -n '^\*\*Status:' docs/plan/carveouts/CO-002-token-achse-je-rolle.md` zeigt
  den Verdikt-Status, nicht `Aktiv`. **Jeder Zellwert steht an zwei Fundorten** — hier und in der
  **definierenden** Slice-Zeile der §4-Tabelle, auf die der Punkt *Je Regelblock UND je Ebene*
  oben ausdrücklich verweist. Wer einen ändert, findet beide:
  `grep -n 'Token-Attribution × Repo\|Cache-Counter × Repo' docs/plan/planning/welle-09-modul-15-konformitaet.md`
  — der Treffer auf der Zeile des Kommandos ist das Kommando selbst und zählt nicht mit.
- **Zwei lebende Planungs-Artefakte führen die aufgehobene Schwelle noch als offen und sind vor
  dem Abschluss zu ziehen — Planner, an lebendem Plan.** Die Roadmap schreibt für slice-071 *„die
  Rechnung liegt hinter dem Auflösungs-Trigger von `CO-002`"*, und
  [slice-071](open/slice-071-cache-zaehler-getrennt.md) nennt den Carveout auf **10** Zeilen
  (`grep -c 'CO-002' docs/plan/planning/open/slice-071-cache-zaehler-getrennt.md`); wie viele davon
  die Schwelle als **offen** führen, trennt kein Kommando — das ist von Hand zu lesen. **Und seine
  Rückführung ist ausgelöst:** sein §4 nennt für den Fall, dass `CO-002` **negativ** entschieden
  wird, eine **Architect-Frage** — ob das Spec-Stratum die Cache-Festlegung ohne Rechnung trägt.
  Sie ist heute fällig, sie gehört dem **Architect**, und das Kriterium *„alle Slices dieser Welle
  in `done/`"* hängt an ihrer Beantwortung.
- **Für die Tool-Spalte ist der Carveout weiterhin ausdrücklich nicht der Träger** (slice-062 §3):
  dort ist er die **Vorbedingung** des **Zähler-Glieds**, und die Zellen zeigen auf die Frage, die
  er stellt, statt auf ihn — eine Zelle, die auf einen fremden Auflösungs-Trigger als offenen
  Trigger zeigt, sagt nicht mehr, ob sie offen oder erledigt ist. Das Audit liest die Tool-Zellen
  deshalb **nicht** gegen seinen Zustand.
- Closure-Notiz in `welle-09-results.md` mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Geschnitten sind slice-059, slice-060, slice-062, slice-066 und slice-068 — diese fünf in
`done/` — sowie slice-071 und slice-087 in `open/`; die übrigen bekommen ihre Datei per `cp`, wenn
sie an der Reihe sind (cp-Disziplin — ein leeres `open/` ist ehrlicher als eine driftende
Vorplanung). **Der Zustand ist das Verzeichnis, nicht diese Zeile.**

**Warum die Rollen-Achse ein eigener Slice vor der Auswertung ist:** `agent_role` ist heute in
**jedem** Span leer. Eine Token-Bilanz hätte damit genau zwei namenlose Eimer —
`general-purpose` und den Haupt-Kontext — und wäre eine Summe, keine Rechnung. Die Rollen-Achse
ist deshalb **Vorbedingung**, nicht Teilaufgabe. Sie ist zudem ein eigener Liefergegenstand mit
eigener Vertragsfläche: sie berührt `.claude/agents/` und den `PreToolUse`-Guard. **Nicht** die
emittierte Seite — ob die Rollen-Typen in die Ziel-Repos mitgehen, entscheidet slice-062
(slice-060 Frage B).

**Warum Block 2 und Block 3 getrennte Slices sind.** Die Closure-Matrix führt sie als zwei
Zellen, und sie beantworten zwei Fragen: *wer hat wie viel verbraucht* (Token-Attribution, Block
2, slice-066) und *was hat der Cache getragen* (Cache-Counter, Block 3, slice-071). Jede trägt
ihre eigenen Pflicht-Angaben und ihre eigene Festlegung im Technik-Stratum
([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5,
[`ADR-0013`](../adr/0013-technik-stratum-als-zielort.md)). In einem
Slice zusammen waren es mehr Zusagen, als Modul 5 §Ziel-Form einem Schnitt zugesteht — die
Nenner-Angabe aus [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md) hätte als vierter
DoD-Punkt danebengestanden. Keiner der beiden wartet auf den anderen: beide setzen auf slice-060
auf, nicht aufeinander. **Was sie unterscheidet, ist der Eingang:** Block 2 hat seine Rechnung
gebaut, solange die Zähler ankamen, und trägt deshalb einen Zahn; Block 3 hat die Festlegung, und
sein Zahn hinge an einer Rechnung, deren Eingang nach
[`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) **dauerhaft** ausbleibt — einen
Auflösungs-Trigger von [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md), hinter dem sie
läge, gibt es nicht mehr.

**Beide Ebenen sind drin — Repo und Tool.** Die erste Fassung dieses Plans schob die Tool-Ebene
unter „aufgeschoben"; auf Nutzer-Entscheidung vom 2026-07-28 gehört sie zur Welle (slice-062/063).
Die Aussage stand bis zum 2026-07-29 als Verneinung im Out-of-Scope-Abschnitt („nicht
out-of-scope, sondern drin") — an einer Stelle also, die auflistet, was **nicht** dazugehört. Wer
sie überflog, las das Gegenteil. Sie steht deshalb hier, wo der Umfang festgelegt wird; §6 führt
nur noch, was wirklich ausgeschlossen ist.

| Slice | Ebene | Titel | Bezug |
|---|---|---|---|
| slice-059 | Repo | **Erfassung**: Spans per Agenten-Hook (Block 1) | [`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) |
| slice-060 | Repo | **Rollen-Achse**: rollen-benannte Agenten-Typen + Nutzungstelemetrie der Subagenten | [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) |
| slice-066 | Repo | **Auswertung**: Token-Bilanz je Rolle, die ihren Nenner nennt (Block 2) — setzt auf slice-060 auf | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-071 | Repo | **Cache-Festlegung**: die drei Counter getrennt, mit allen vier Angaben je Counter, im Spec-Stratum (Block 3) — setzt auf slice-060 auf. Er legt für die Matrix-Zelle *Cache-Counter × Repo* fest, **was gerechnet wird**; ihren Wert trägt sie als **ADR-Verdikt** — die **Rechnung** hat keinen Eingang, und einen Auflösungs-Trigger dafür gibt es nach [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) nicht mehr ([`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) trug ihn). Ob das Spec-Stratum die Festlegung ohne Rechnung trägt, ist die Architect-Frage aus seinem eigenen §4 | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-068 | Repo | **Rollen-Arbeit läuft als Rolle**: die Konvention wird vollständig (was, nicht nur wie) + die Berichtsgröße, an der sie ablesbar ist — legt für die Matrix-Zelle *Token-Attribution × Repo* fest, dass ihre Belegart **zweigeteilt** ist: **beide Teile tragen ADR-Verdikt**, aus zwei verschiedenen ADRs und je **ohne** Auflösungs-Trigger — der Hintergrund-Teil das aus [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md), der Haupt-Kontext das aus [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md). Die Haupt-Kontext-Abweichung selbst hat slice-060 DoD (3) geliefert | keine `LH-*` (Dogfood-Prozessebene; im Slice begründet) |
| slice-061 | Repo | **Doku-Konsistenz**: behauptete Befehle existieren (Block 4) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-062 | **Tool** | **Entscheidung**: welche Modul-15-Regeln gehören in den emittierten Harness? (**nur** ADR — kein CR, gemessen in dessen §3) | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| [slice-087](open/slice-087-emittierte-doku-tische-init-invariant.md) | **Tool** | **Vorarbeit**: **kein** emittiertes Dokument behauptet noch ein nicht Init-invariantes `make`-Ziel — die Ansprüche fallen emit-seitig, ein Wächter hält die Eigenschaft über den **Dokument-Satz**. Betroffen sind heute **drei** Dokumente: die zwei Gate-Tabellen und der Closure-Note-Reviewer-Skill (unten). Ohne ihn ist die Zelle *Doku-Konsistenz-Drift × Tool* nicht belegbar | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-063 | **Tool** | **Beleg**: den mitgelieferten Träger von Block 4 im frischen Ziel wirksam machen und in beiden Richtungen belegen — setzt auf [slice-087](open/slice-087-emittierte-doku-tische-init-invariant.md) auf | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| slice-064 | beide | **Die Baseline-Aussage geradeziehen** + begrenzte Bestands-Stichprobe | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |

**Die Reihenfolge ist die Aussage.** Erst die **Erfassung**, dann die Auswertung: ohne Spans hat
die Token-Bilanz keine eigene Datenquelle, sondern nur das Transkript des Werkzeugs — das
außerhalb des Repos liegt, uns nicht gehört und **keine Korrelations-IDs trägt** (`agent.role`
steht dort als `general-purpose`, `slice.id` gar nicht; am 2026-07-28 gemessen). Und der
Erfassungsort **existiert** seit [slice-059](done/slice-059-telemetrie-erfassung-hook.md): der
Emitter läuft an `PostToolUse`/`PostToolUseFailure` — und seit dem 2026-08-08 zusätzlich an
`SubagentStart`, das je **Spawn** feuert statt je Tool-Call — und schreibt je Tool-Call einen Span mit den
Korrelations-Achsen. Der `PreToolUse`-Guard, den eine frühere Fassung hier als Erfassungsort
nannte, ist es **nicht** — er entscheidet und behält nichts.

**Zu slice-066 und slice-071 (Auswertung und Festlegung):** die Trennung, auf der Modul 15 besteht, liegt
im `usage`-Objekt der `tool_response` eines **Vordergrund**-`Agent`-Aufrufs — getrennte
Hit-/Miss-Zähler (`cache_read_input_tokens` vs. `cache_creation_input_tokens`), am 2026-07-29
an echten Aufrufen gemessen. **Nicht** aus Sitzungs-Transkripten — beide Slices schließen jeden
Zugriff außerhalb des Repos aus. **Der Vordergrund ist seit dem 2026-08-15 nicht mehr
anforderbar, und die Messung dazu ist gefahren und negativ**
([slice-086](done/slice-086-vordergrund-per-updatedinput.md)): von den zwei Ausgängen, die
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) führte, ist der **zweite** genommen — der
Ausfall ist in [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) **permanent**
entschieden, und der Carveout ist dorthin übergeführt, ohne seine Adresse zu verlassen.
**„Kein Gegenstand" trägt trotzdem nicht:** die Festlegung, welche Zähler unter welchen Namen
und in welcher Counter-Form geführt werden, ist ohne Bestand entscheidbar (slice-071 DoD (1));
am Bestand hängt die Rechnung, nicht die Festlegung.

**Was der Ausfall für die Closure-Kriterien dieser Welle bedeutet, ist je Kriterium verschieden —
und für jedes einzeln gezeigt:**

- *Je Regelblock und je Ebene ein belegter Zustand.* Betroffen sind **zwei** Zellen, und beide
  tragen **ADR-Verdikt**: *Token-Attribution × Repo* für den Hintergrund-Teil (slice-068 DoD (3))
  und *Cache-Counter × Repo* für die Rechnung, die keinen Eingang hat (slice-071). Geltungsbereich
  und Begründung stehen in
  [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md); einen Auflösungs-Trigger gibt
  es nicht mehr, an seiner Stelle stehen deren Re-Evaluierungs-Trigger. Das Carveout-Audit aus §3
  liest dafür den **Status** des Stubs, nicht sein Verzeichnis.
- *Alle Slices dieser Welle in `done/`.* slice-071 ist auf die **Festlegung** zugeschnitten, aber
  seine Grundlage hat sich bewegt: seine eigene Rückführung nennt für den negativen Ausgang eine
  **Architect-Frage**, und die ist vor seinem Eintritt zu beantworten (Closure-Trigger oben). Die **Rechnung** ist
  kein Mitglied dieser Welle und wird es nicht mehr: sie lag hinter einem Auflösungs-Trigger, den
  [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) aufgehoben hat. Eine
  Nicht-Umsetzung mit **ADR-Verdikt** ist ein zulässiger Endzustand dieser Welle.

**Was die Zahlen NICHT abdecken**, steht in
[`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md): der
Haupt-Kontext trägt keine, dauerhaft — deshalb nennt jede Bilanz aus diesem Bestand ihren
Nenner (slice-066 DoD (2)).

**Warum die Repo-Seite zuerst kommt — und die Tool-Seite nicht bloß „danach".** Das Repo ist der
Prüfstand: was wir ins Ziel legen, haben wir hier erprobt (dieselbe Linie wie
[`ADR-0006`](../adr/0006-durchsetzung-commands-tool-als-quelle.md), wo die emittierte
Durchsetzung aus dem Dogfood abgeleitet wurde). Ein Span-Emitter, den wir ungeprüft emittieren,
verstößt gegen die eigene Regel „nichts behaupten, was nicht läuft". Die Reihenfolge ist damit
**Erprobung → Entscheidung → Emission**, nicht „Dogfood jetzt, Ziel irgendwann".

**Zu slice-062 (Tool, Entscheidung):** Was ins Ziel gehört, ist **keine** Implementer-Frage. Es
berührt den Adopter-Vertrag und damit das Lastenheft — nach
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
bewegt das nur ein **Change Request des Auftraggebers**, in eigenem Commit **vor** dem
umsetzenden Slice. **Die Entscheidung ist am 2026-08-16 in zwei Setzungen gefallen** und steht
mit ihren Begründungen in [slice-062](done/slice-062-emittierte-modul-15-regeln.md): (a) ein
Ziel-Repo bekommt **keinen** Span-Emitter; (b) Block 4 bekommt **kein neues Artefakt** — Träger
ist das advisory `make doc-targets`, das mit `d-check.mk` ohnehin ins Ziel geht; (c) die
Rollen-Typen unter `.claude/agents/` gehen **nicht** mit. **Der Slice liefert die ADR — und
keinen CR:** ohne neues Artefakt wächst keine Anforderung, damit hat der Fußabdruck aus
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 2/3 keinen Gegenstand (am Volltext beider Kandidaten gemessen, slice-062 §3). Was die ADR
trägt, sind die drei Nicht-Emissionen samt ihrem Trichter-Ausgang und die zwei Fragen, die am
Träger hängen — ob ein Wächter außerhalb von `make gates` den Wert *emittiert* verdient, und ob
die Zelle ihn trägt, solange der Träger im Ziel wirkungslos ist. Eine neue Artefakt-Klasse mit
Sicherheitsfläche (redigierte Tool-Argumente) entsteht im Ziel **nicht** — der Span-Emitter geht
nicht mit.

**Die drei Nicht-Emissionen tragen *ADR-Verdikt*, nicht *nicht emittiert mit Trigger* — und das
ist eine Aussage über die Dauer, nicht über die Setzung.** Die Schwelle, die die Frage wieder
öffnete, wäre *die Erfassung läuft ohne Kompilat*; ihre Ausgänge sind abgezählt und zu — der
handgeführte Scanner ist in **diesem** Repo gebaut und gemessen gescheitert
([slice-059](done/slice-059-telemetrie-erfassung-hook.md)), die übrigen scheitern an der Natur des
Gegenstands, an getroffenen Entscheidungen dieses Repos oder liegen bei einem fremden Vertrag. **Die
Abzählung selbst führt die ADR** ([slice-062](done/slice-062-emittierte-modul-15-regeln.md) §3
verweist auf sie, statt sie zu doppeln): jeder Ausgang steht auf seinem eigenen Argument und ist
einzeln widerlegbar, und eine zweite Fassung hier driftete an genau der Stelle, an der der
Trichter-Ausgang hängt. Modul-7-Frage 2 fällt auf *Nein*, der Auflösungs-Trigger entfällt, und an
seine Stelle treten Re-Evaluierungs-Trigger. **Für das Closure heißt das:** die drei Zellen sind mit dem
**Accepted**-Zustand von [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) belegt, nicht mit einem Ziel-Beleg — der Wert ist nach §3 in beiden
Spalten zulässig (Präzedenz [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md)), und die
Tool-Spalte ist damit vollständig belegbar: drei Zellen über die Entscheidung, eine über
[slice-087](open/slice-087-emittierte-doku-tische-init-invariant.md) → `slice-063`.

**Zu [slice-087](open/slice-087-emittierte-doku-tische-init-invariant.md) (Tool, Vorarbeit) — und
warum er Mitglied ist.** Die Emission von Block 4 hängt an einer Bedingung, die nicht die
Doc-Gate-Konfiguration betrifft, sondern die **emittierten Dokumente**: keines von ihnen darf ein
Ziel behaupten, das die **Init-Phase** nicht selbst schreibt. **Die Bedingung ist eine Regel über
den Dokument-Satz, keine Aufzählung von Fundorten** — heute verletzen sie **drei** Dokumente: die
zwei Gate-Tabellen (`AGENTS.md`, `harness/README.md`) und der emittierte
`.harness/skills/closure-note-reviewer.md`, der zweimal `make verify-closure-notes` behauptet, ein
Ziel, das in keiner Variante und auch in diesem Repo nicht existiert. Wer sie als Aufzählung führt,
ist beim vierten Dokument wieder falsch, und still. Gemessen ist der Grund, nicht vermutet — der
heutige Tisch erzeugt im Ziel **13 Befunde, davon 4 falsch**; die naheliegende Teil-Reparatur
erzeugt **4 Befunde, alle falsch**; wahre und falsche Meldung sind **byte-gleich**; nur der
invariante Tisch schweigt in **beiden** Bootstrap-Varianten. Der Befund selbst besteht unabhängig
von Modul 15 (die Ansprüche verletzen
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) auch ohne
jede Konfiguration), aber **die Welle kann ohne ihn nicht schließen** — und ein Closure-Trigger,
der auf ein Nicht-Mitglied ohne Eintritts-Trigger zeigt, ist keine Bedingung, sondern eine
Verschiebung. Er ist deshalb Mitglied statt wellenlos. Die Reihenfolge folgt daraus und ist die
einzige, die trägt: **Entscheidung (slice-062) · Vorarbeit (slice-087) · Beleg (slice-063)** —
wobei die Vorarbeit auf die Entscheidung **nicht** wartet (sie ist ohne sie lieferbar), der Beleg
aber auf beide.

**Zu slice-063 (Tool, Beleg):** liefert keinen Mechanismus, sondern den Beleg für den, der schon
da ist — beide Richtungen aus §3, im frisch gebootstrappten Ziel: `make gates` out-of-the-box
grün **und** ein eingeschmuggelter Drift, der `make doc-targets` mit der benannten Befund-Art
`gate-phantom` rot färbt, samt Rücknahme. Dazwischen liegt die Konfiguration, die den Träger
überhaupt reden lässt (slice-062 §6). **Zwei Bedingungen hängen an ihm, und beide sind
gemessen:** sein Eintritt fragt
[slice-087](open/slice-087-emittierte-doku-tische-init-invariant.md) ab, nicht nur slice-062 — vor
der Vorarbeit meldet der Träger Grundrauschen, und ein Beleg, der immer rot ist, ist keiner. Und
er schuldet **beide** Bootstrap-Varianten: `make full-smoke` fährt heute beide (`--lang go` und
sprachlos), zieht im sprachlosen Repo aber anschließend `add-lang go` nach — die Lücke ist deshalb
nicht die fehlende Variante, sondern die **Platzierung**: ein Zahn, der erst danach greift, misst
die sprachlose Variante nie und gehört **vor** diesen Schritt, nicht in ein drittes tmp-Repo.
Emittierte Artefakte tragen **keine** Quell-Repo-Identität (die Lehre aus slice-031/032/033).

**Zu slice-064 — bewusst BEGRENZT.** Er liefert zwei Dinge und **nicht** eine Inventur aller 21
Regelwerk-Abschnitte: (a) unser
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) wird auf das zurückgeführt,
was die Vorlage sagt (die Verschärfung aus §1 wird entweder deklariert oder zurückgenommen);
(b) eine **Stichprobe** über die Abschnitte, die Modul 15 am nächsten liegen (Phase 05:
modul-14/15/16), als Beleg dafür, ob der Befund Einzelfall oder Muster ist. Ergibt die
Stichprobe ein Muster, ist der Sensor dafür ein **eigener Kandidat** — nicht Teil dieser Welle.
Sonst zöge eine unbegrenzte Bestandsaufnahme das Closure-Kriterium ins Unabsehbare, und die
Welle verlöre genau das, was sie in §6 von sich selbst verlangt.

**Wann [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) geradegezogen wird — nicht erst am Ende.** Die als überzogen gemessene Fassung
steht bis dahin in [`harness/conventions.md`](../../../harness/conventions.md), und der
CR-/ADR-Autor von slice-062 liest sie, um die emittierte Ebene zu beurteilen. **Der Schnitt von
slice-062 hat entschieden (2026-08-16): keine Vorbedingung.** Die Begründung der ADR ruht auf dem
vendored Vorlagen-Wortlaut — der primären Quelle, die die Baseline-Aussage selbst eingrenzt (§1) —
und nicht auf unserer überzogenen Fassung; damit hängt slice-062 an keiner fremden Korrektur, und
Modul 5 §Ziel-Form („kein Slice wartet auf den nächsten") bleibt gewahrt. Der Nebenbefund bleibt
bei slice-064.

**ADR-Bedarf — vor slice-059, nicht bei slice-062** (Plan-Review-Befund): Schema, Datenfluss und
Sicherheitsfläche werden faktisch im **Dogfood-Slice** entschieden, nicht erst bei der Emission.
Die Entscheidung liegt als [`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) vor —
**Accepted** am 2026-07-28 nach **sechs** Proposed-Runden (blockierende Befunde 2 → 3 → 1 → 3 →
2 → 0). Die Bedingung, unter der slice-059 in `open/` blieb, ist damit erfüllt.

## 5. Abhängigkeiten

- **Blockiert:** nichts. Diese Welle liefert Sensoren und Deklarationen, keine Nutzer-Fähigkeit;
  kein anderer Kandidat wartet auf sie.
- **Wird blockiert von:** **zwei Bedingungen aus §3**, beide an fremden Vorgängen und beide vor
  der Ergebnis-Notiz zu erfüllen. **(1) Reihenfolge:** der Kopf von
  [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) trägt den Verdikt-Status, bevor die
  Zellen gesetzt werden — geschrieben wird er von einem Slice, der **kein Mitglied** dieser Welle
  ist; Prüfkommando in §3. **(2) Eine fällige Architect-Frage:** ob das Spec-Stratum die
  Cache-Festlegung ohne Rechnung trägt — an ihrer Beantwortung hängt der Eintritt von
  [slice-071](open/slice-071-cache-zaehler-getrennt.md) und damit das Kriterium *„alle Slices
  dieser Welle in `done/`"*. **Werkzeugseitig blockiert nichts:** Der Hebel ist bereits bezahlt —
  das gepinnte d-check-Image aktiviert **6 von 18** Modulen, und `targets` liegt als `make doc-targets` in
  [`d-check.mk`](../../../d-check.mk) fertig vor. **„Fertig" heißt hier: lauffähig, nicht
  wirksam.** Das Modul wertet erst mit einem `targets:`-Block der Konfiguration aus, und den
  führt weder [`.d-check.yml`](../../../.d-check.yml) noch die emittierte Vorlage (gemessen,
  slice-062 §6). Block 4 kostet auf beiden Ebenen denselben Handgriff: Konfigurations-Block plus
  Zahn, nicht Neubau.

## 6. Out-of-Scope für diese Welle

- **Ein OTel-*Stack*** — Collector, Backend, Dashboard, Vendor-SDK. **Nicht** die Erfassung: die
  ist der Kern dieser Welle. Die Unterscheidung ist die Pointe — *Spans erfassen* und *einen
  Observability-Stack betreiben* sind zwei verschiedene Dinge, und nur das zweite ist hier
  Overhead. **Die Randbedingung ist „nichts, das installiert werden muss", nicht ein bestimmtes
  Werkzeug** — welche Mechanik sie erfüllt, entscheidet die Messung im jeweiligen Slice, nicht
  dieser Plan. Die Grenze verläuft zwischen der POSIX-Basis, die der Harness ohnehin voraussetzt,
  und jeder Laufzeit, die ein Adopter **installieren** müsste; maßgeblich ist
  [`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) Festlegung 4 (die frühere Fassung
  dieses Absatzes zitierte
  [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) falsch und ist
  damit überholt). Für die Feld-Auswahl gilt Modul 15 selbst: *„Ein Attribut ohne Incident-Frage
  fliegt raus."*
- **Den Adopter-Vertrag ändern, ohne dass ein CR ihn trägt** ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler))
  **und ohne `full-smoke`-Beleg.** Die Tool-Ebene selbst ist **drin** (slice-062/063, s. §4) —
  ausgeschlossen ist nur, sie ohne diese zwei Belege in den Adopter-Vertrag zu schieben.
- **Die Kurs-Vorlagen selbst.** `conventions.template.md` und die übrige Doc-Chain kommen aus der
  vendored Baseline; sie gehören dem Kurs, nicht uns. Wenn dort etwas fehlt, ist das ein
  Upstream-Befund — kein Grund, eine repo-eigene Kopie zu pflegen (die
  [`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Linie).
- **Die drei Wächter über den emittierten Abwesenheiten** — *kein `.claude/agents/`*, *kein
  Span-Emitter*, *kein Token-Bericht* im gebootstrappten Ziel. Sie sind **kein** Closure-Kriterium
  dieser Welle, und der Grund steht in §3: der Wert *ADR-Verdikt* verlangt keinen Sensor, sondern
  eine Entscheidung. **Undenkbar sind sie trotzdem nicht** — `internal/emit/enforce_test.go`
  bewacht heute eine Abwesenheit im Ziel ohne jede geschlossene Datei-Liste, und ein Wächter
  dieser drei hat exakt dieselbe Gestalt. Sie sind darum als **Folgepflicht der Entscheidung**
  geführt, nicht als offener Punkt dieses Plans: ihr Träger ist die ADR, die sie schuldet, und die
  bleibt lesbar, wenn diese Welle geschlossen ist.
- **Die übrigen Achsen des Roadmap-Kandidaten** (`vcs`/`commits`-Module, Closure-Notiz-Sensor,
  Release-Text-Check, DoD-Punkte-Zähler). Sie bleiben Kandidaten; diese Welle nimmt nur, was
  Modul-15-Konformität wirklich verlangt. Wer mehr hineinzieht, verliert das Closure-Kriterium.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-09-results.md. -->
