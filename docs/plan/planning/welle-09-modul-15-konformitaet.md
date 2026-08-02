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
sie**, und zwar an `PostToolUse`/`PostToolUseFailure`, **nicht** am `PreToolUse`-Guard; eine
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
  | **deklariert** | bewusste Nicht-Umsetzung als `MR-<NNN>` — Geltungsbereich, Begründung, **Auflösungs-Trigger** |
  | **ADR-Verdikt** | die Abweichung ist **permanent** und in einer ADR entschieden — Geltungsbereich und Begründung wie bei „deklariert", aber **ohne Auflösungs-Trigger**: Modul 7 §Werkzeug-Wahl lässt ihn auf dem ADR-Pfad wegfallen. An seiner Stelle nennt die Zelle die Re-Evaluierungs-Trigger der ADR, die niemand herbeiführt, sondern bemerkt. Erster Fall: [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md) |
  | **emittiert** | im Ziel vorhanden **und dort rot gesehen** (s. u.) |
  | **nicht emittiert** | begründete Entscheidung **mit Auflösungs-Trigger** — dieselbe Pflicht wie bei „deklariert"; eine Entscheidung, die sich ohne Trigger als temporär ausgibt, ist nach Modul 7 die permanente Ausnahme, die lügt. Ist sie wirklich permanent, gehört sie in eine ADR und die Zelle trägt „ADR-Verdikt" |

  Eine leere Zelle ist ein offener Closure-Trigger — kein „passt schon".
- **Die Tool-Spalte braucht ihren eigenen Beleg, und „grün" genügt nicht.** Ein emittierter
  Mechanismus, der **nie feuert**, lässt `make full-smoke` ebenfalls grün — das ist die
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle eine Ebene weiter. Verlangt sind daher **beide** Richtungen, wie in welle-08
  etabliert: (a) das frisch gebootstrappte Ziel ist out-of-the-box grün (Lehre aus slice-028),
  **und** (b) ein Gegenbeispiel im Ziel wird **rot gesehen** — für einen emittierten Span-Emitter
  etwa: er läuft, und ein Lauf ohne Pflicht-Feld fällt auf.
- `make gates` und `make mutate` grün; jeder neue Wächter hat seinen `test/mutations/`-Fall
  ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- Carveout-Audit (Modul 7): [`CO-001`](../carveouts/CO-001-bats-shell-lint.md) geprüft, neue
  Carveouts dokumentiert oder begründet keine.
- Closure-Notiz in `welle-09-results.md` mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Geschnitten sind slice-059 (**done**), slice-060, slice-066, slice-068 und slice-071; die übrigen
bekommen ihre Datei per `cp`, wenn sie an der Reihe sind (cp-Disziplin — ein leeres `open/` ist
ehrlicher als eine driftende Vorplanung).

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
ihre eigenen Pflicht-Angaben, ihre eigene Festlegung in
[`harness/conventions.md`](../../../harness/conventions.md) und ihren eigenen Zahn. In einem
Slice zusammen waren es mehr Zusagen, als Modul 5 §Ziel-Form einem Schnitt zugesteht — die
Nenner-Angabe aus [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md) hätte als vierter
DoD-Punkt danebengestanden. Keiner der beiden wartet auf den anderen: beide setzen auf slice-060
auf, nicht aufeinander, und wer zuerst läuft, legt das gemeinsame `make`-Ziel an.

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
| slice-071 | Repo | **Cache-Rechnung**: die drei Counter getrennt, mit allen vier Angaben je Counter (Block 3) — setzt auf slice-060 auf | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-068 | Repo | **Rollen-Arbeit läuft als Rolle**: die Konvention wird vollständig (was, nicht nur wie) + die Berichtsgröße, an der sie ablesbar ist — legt für die Matrix-Zelle *Token-Attribution × Repo* fest, dass ihre Belegart **zweigeteilt** ist: der Hintergrund-Teil trägt „deklariert" mit Auflösungs-Trigger, der Haupt-Kontext das „ADR-Verdikt" aus [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md) ohne Trigger. Die Haupt-Kontext-Abweichung selbst hat slice-060 DoD (3) geliefert | keine `LH-*` (Dogfood-Prozessebene; im Slice begründet) |
| slice-061 | Repo | **Doku-Konsistenz**: behauptete Befehle existieren (Block 4) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-062 | **Tool** | **Entscheidung**: welche Modul-15-Regeln gehören in den emittierten Harness? (ADR + CR) | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |
| slice-063 | **Tool** | **Emission**: das Entschiedene emittieren, out-of-the-box grün belegt | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| slice-064 | beide | **Die Baseline-Aussage geradeziehen** + begrenzte Bestands-Stichprobe | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |

**Die Reihenfolge ist die Aussage.** Erst die **Erfassung**, dann die Auswertung: ohne Spans hat
die Token-Bilanz keine eigene Datenquelle, sondern nur das Transkript des Werkzeugs — das
außerhalb des Repos liegt, uns nicht gehört und **keine Korrelations-IDs trägt** (`agent.role`
steht dort als `general-purpose`, `slice.id` gar nicht; am 2026-07-28 gemessen). Und der
Erfassungsort **existiert** seit [slice-059](done/slice-059-telemetrie-erfassung-hook.md): der
Emitter läuft an `PostToolUse`/`PostToolUseFailure` und schreibt je Tool-Call einen Span mit den
Korrelations-Achsen. Der `PreToolUse`-Guard, den eine frühere Fassung hier als Erfassungsort
nannte, ist es **nicht** — er entscheidet und behält nichts.

**Zu slice-066 und slice-071 (der Auswertung):** die Rohdaten sind real vorhanden, und die
Quelle ist **gemessen** statt vermutet — ein `Agent`-Aufruf im **Vordergrund** trägt in
`tool_response` ein `usage`-Objekt mit getrennten Hit-/Miss-Zählern
(`cache_read_input_tokens` vs. `cache_creation_input_tokens`), also genau die Trennung, auf der
Modul 15 besteht. **Nicht** aus Sitzungs-Transkripten — beide Slices schließen jeden Zugriff
außerhalb des Repos aus. Das bequeme Argument „kein Gegenstand" ist damit ausgeschlossen; offen
ist die Zuordnung zur **Rolle** (slice-060), nicht die Datenlage. **Was die Zahlen NICHT
abdecken**, steht in [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md): der
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
umsetzenden Slice. Zu entscheiden ist mindestens: (a) bekommt ein Ziel-Repo einen Span-Emitter,
(b) zieht die emittierte `.d-check.yml` (heute `[links, anchors]`) das `targets`-Modul nach,
(c) welche Nicht-Emission wird begründet statt vergessen. Ein ADR ist wahrscheinlich, weil eine
neue Artefakt-Klasse mit Sicherheitsfläche (redigierte Tool-Argumente) im Ziel entsteht.

**Zu slice-063 (Tool, Emission):** liefert nur, was 062 entschieden hat — und belegt es dort, wo
es zählt: `make full-smoke`, out-of-the-box grün im frisch gebootstrappten Ziel. Emittierte
Artefakte tragen **keine** Quell-Repo-Identität (die Lehre aus slice-031/032/033).

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
CR-/ADR-Autor von slice-062 liest sie, um die emittierte Ebene zu beurteilen. Die Korrektur ist
darum **Vorbedingung für slice-062**, auch wenn sie in slice-064 dokumentiert wird — oder sie
wandert vor. Das entscheidet der Planner beim Schnitt von 062, nicht dieser Plan im Voraus.

**ADR-Bedarf — vor slice-059, nicht bei slice-062** (Plan-Review-Befund): Schema, Datenfluss und
Sicherheitsfläche werden faktisch im **Dogfood-Slice** entschieden, nicht erst bei der Emission.
Die Entscheidung liegt als [`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) vor —
**Accepted** am 2026-07-28 nach **sechs** Proposed-Runden (blockierende Befunde 2 → 3 → 1 → 3 →
2 → 0). Die Bedingung, unter der slice-059 in `open/` blieb, ist damit erfüllt.

## 5. Abhängigkeiten

- **Blockiert:** nichts. Diese Welle liefert Sensoren und Deklarationen, keine Nutzer-Fähigkeit;
  kein anderer Kandidat wartet auf sie.
- **Wird blockiert von:** nichts. Der Hebel ist bereits bezahlt — das gepinnte d-check-Image
  aktiviert **6 von 18** Modulen, und `targets` liegt als `make doc-targets` in
  [`d-check.mk`](../../../d-check.mk) fertig und unverdrahtet vor.

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
- **Die übrigen Achsen des Roadmap-Kandidaten** (`vcs`/`commits`-Module, Closure-Notiz-Sensor,
  Release-Text-Check, DoD-Punkte-Zähler). Sie bleiben Kandidaten; diese Welle nimmt nur, was
  Modul-15-Konformität wirklich verlangt. Wer mehr hineinzieht, verliert das Closure-Kriterium.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-09-results.md. -->
