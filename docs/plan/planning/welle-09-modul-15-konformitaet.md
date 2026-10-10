# Welle welle-09: Modul-15-Konformität — Regeln ohne Feedback-Quadrant schließen

**Zielmeilenstein:** kein Meilenstein-Bezug (Konformitäts-Welle, keine Nutzer-Fähigkeit).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-28.

---

## 1. Welle-Ziel

**Jeder der vier Regelblöcke von `modul-15-observability.md` trägt am Ende — auf BEIDEN Ebenen —
einen laufenden Sensor, eine deklarierte Entscheidung mit Auflösungs-Trigger oder das Verdikt
einer ADR, dass die Abweichung permanent ist; und nichts dazwischen.** Die beiden Ebenen sind:

1. **das Repo** (Dogfood: was hier läuft) und
2. **das Tool** (was `ai-harness-init` ins Ziel-Repo emittiert).

„Nichts dazwischen" ist der Kern: Schweigen — weder Umsetzung noch Entscheidung — ist der
ausgeschlossene Zustand.

**Mess-Grundlage.** Die vier Regelblöcke sind die `###`-Abschnitte *Span-/Audit-Attribut-Regeln*,
*Token-Attributions-Regeln*, *Cache-Counter-Regeln* und *Doku-Konsistenz-Drift-Regeln* von
`.harness/baseline/v6.18.0/regelwerk/modul-15-observability.md`
(`grep -n '^### ' .harness/baseline/v6.18.0/regelwerk/modul-15-observability.md`). Die Welle ist
gegen die Fassung von `v5.18.0` geschnitten; maßgeblich ist der Bestand, nicht der Schnitt-Tag:
die Überschriften stehen in beiden Fassungen in derselben Reihenfolge, und keine Zelle der Matrix
in §3 bewegt sich durch den Baum-Tausch ([welle-10](done/welle-10-re-baseline.md) §2 misst es mit
Kommando).

**Die Tool-Spalte folgt [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
(Accepted).** Sie revidiert die Festlegungen 1–3 von
[`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md)
(`grep -c '^- \*\*Festlegung [123]\*\*' docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`
→ **3**) und führt für **drei** der vier Tool-Zellen den Wert *emittiert* statt *ADR-Verdikt*
(`grep -c '^| .* \*\*emittiert\*\* —' docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`
→ **3**); die Tool-Zelle *Doku-Konsistenz-Drift* bleibt *emittiert* nach
[`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegungen 4 und 5. Den Ziel-Beleg der
drei revidierten Zellen führt [welle-12](done/welle-12-erfassungsschicht-emittieren.md).

**Warum beide Ebenen in dieselbe Welle gehören.** Das Tool emittiert das **vollständige
Regelwerk** ins Ziel — Modul 15 inklusive. Ein bootstrappedes Repo bekommt dieselben Regeln und
dieselbe Leere. Würde nur die Dogfood-Seite geschlossen, lieferte das Tool die Lücke weiter an
jedes andere Repo. Die Ebenen haben verschiedene Verträge (§3), aber es ist eine Frage.

**Begründung.** Modul 15 ist adoptiert, in keinem Block umgesetzt und nie entschieden worden; die
Welle entscheidet es. Die Baseline behauptet keine Umsetzung jeder Regel, sondern strukturelle
Konformität: die vendored Vorlage grenzt ihre Aussage ausdrücklich ein
(`grep -n 'Verzeichniskonvention' .harness/baseline/v6.18.0/templates/harness/conventions.template.md`
→ Zeile 105, *„für Verzeichniskonvention, Lifecycle-Regeln, Carveout-Disziplin, ID-Schema"*).
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) führt die Aufzählung nicht
und ist damit gegenüber der Vorlage eine nirgends deklarierte Verschärfung; sie gehört in
slice-064 auf den Tisch.

**Der Einstieg ist die Erfassung, nicht die Auswertung.** Modul 15 beschreibt einen Agentenlauf
als Trace aus Spans, einen pro Tool-Call. Sie entstehen seit
[slice-059](done/slice-059-telemetrie-erfassung-hook.md) an `PostToolUse`/`PostToolUseFailure`
und `SubagentStart` (je Spawn), nicht am `PreToolUse`-Guard, der entscheidet und nichts behält.
Die Hook-Oberfläche (Ergebnis- und Fehlschlag-Event, gemeinsame Aufruf-ID, Hooks auch in
Subagenten, leerer Matcher trifft alle Tools) belegt die Werkzeug-Doku
<https://code.claude.com/docs/de/hooks>; die Quelle ist nicht gepinnt und von keinem Gate
geprüft, die Fakten stehen in slice-059 §3 ausgeschrieben.

Die Welle **faltet den Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen* hinein**:
dessen Achse (1) — die Gate-Tabellen in [`AGENTS.md`](../../../AGENTS.md) §4 und
[`harness/README.md`](../../../harness/README.md) §Sensors werden von nichts gegen das
[`Makefile`](../../../Makefile) gehalten — **ist** Modul-15-Block-4.

## 2. Trigger (Welle startet)

Eingetreten:

- Modul 15 ist adoptiert und in keinem Block umgesetzt. Die Adoptions-Prüfung sieht bei jeder
  Re-Baseline das Normativ-Delta, nie den Bestand; kein Sensor meldet „adoptiert, aber nicht
  umgesetzt" ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  entstand aus derselben Delta-Prüfung).
- green-before-extend: `in-progress/` war leer, `make gates`/`mutate`/`full-smoke` grün.

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
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle eine Ebene weiter. Verlangt sind daher **beide** Richtungen: (a) das frisch gebootstrappte Ziel ist out-of-the-box grün,
  **und** (b) ein Gegenbeispiel im Ziel wird **rot gesehen** — für einen emittierten Span-Emitter
  etwa: er läuft, und ein Lauf ohne Pflicht-Feld fällt auf. **Wen diese Pflicht trifft, sagt der
  Zellwert:** sie gilt jeder Zelle, die *emittiert* trägt — nach [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  und [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegungen 4 und 5 sind das alle vier Tool-Zellen.
  Für *ADR-Verdikt* (Repo-Spalte) ist kein Sensor und kein Ziel-Beleg geschuldet: die Entscheidung
  trägt die Verbindlichkeit, und ein Smoke, der Anwesenheit prüft, belegt keine Abwesenheit.
  **Der Beleg ist über die Bootstrap-Varianten zu klammern:** ein Ergebnis aus *einer* Variante
  deckt die andere nicht, weil `--lang` optional ist
  ([`ADR-0007`](../adr/0007-bootstrap-phasen.md)) — wahr und falsch sind an der Ausgabe des
  Trägers sonst nicht zu unterscheiden.
- `make gates` und `make mutate` grün; jeder neue Wächter hat seinen `test/mutations/`-Fall
  ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **Carveout-Audit (Modul 7) — es liest den STATUS, nicht das Verzeichnis.**
  [`CO-001`](../carveouts/CO-001-bats-shell-lint.md) **und**
  [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) geprüft, neue Carveouts dokumentiert oder
  begründet keine. Ein übergeführter Carveout bleibt an seiner Adresse liegen; die Dateizahl
  (`ls docs/plan/carveouts/CO-*.md | wc -l` → **2**, mitwandernd) trennt *aktiv* nicht von
  *entschieden*. Gelesen wird der Kopf: `grep -n '^\*\*Status:' docs/plan/carveouts/CO-*.md`.
- **Die zwei Zellen der Repo-Spalte, die an [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md)
  hingen, tragen *ADR-Verdikt*:** *Token-Attribution × Repo* (Hintergrund-Teil) und
  *Cache-Counter × Repo* (§4). Der Ausfall ist in
  [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) als **permanent** entschieden
  — kein Auflösungs-Trigger, an seine Stelle treten deren Re-Evaluierungs-Trigger. Der Kopf von
  `CO-002` trägt den Verdikt-Status (`grep -n '^\*\*Status:' docs/plan/carveouts/CO-002-token-achse-je-rolle.md`
  → `Permanent — übergeführt`), geschrieben von
  [slice-089](done/slice-089-carveout-co-002-ueberfuehren.md), **keinem Mitglied** dieser Welle.
  **Jeder Zellwert steht an zwei Fundorten** — hier und in der **definierenden** Slice-Zeile der
  §4-Tabelle: `grep -n 'Token-Attribution × Repo\|Cache-Counter × Repo' docs/plan/planning/welle-09-modul-15-konformitaet.md`
  (der Treffer auf der Zeile des Kommandos zählt nicht mit).
- **Kein lebendes Planungs-Artefakt führt die aufgehobene Schwelle als offen.**
  `grep -rln 'CO-002' docs/plan/planning/in-progress/roadmap.md docs/plan/planning/open/` nennt
  [slice-074](open/slice-074-agent-vor-aufruf-protokoll.md) (als **Grund**, dass eine beobachtete
  Gestalt nicht mehr entsteht) und
  [slice-142](open/slice-142-verweis-form-vor-dem-einfrieren-hat-einen-waechter.md) (als
  Messgegenstand); beide nennen ihn nicht als Bedingung, auf die etwas wartet — das trennt kein
  Kommando, gelesen ist es. Die Cache-Festlegung im Spec-Stratum hat ohne Rechnung keinen
  Adressaten (Rechnung ohne Eingang, [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  Festlegung 1); *Cache-Counter × Repo* trägt **ADR-Verdikt** aus derselben ADR (Folgepflicht 3).
- **Für die Tool-Spalte ist der Carveout nicht der Träger** (slice-062 §3): er ist dort die
  **Vorbedingung** des **Zähler-Glieds**, und die Zellen zeigen auf die Frage, die er stellt, nicht
  auf ihn. Das Audit liest die Tool-Zellen **nicht** gegen seinen Zustand.
- **Alle Slices der Welle (§4) in `done/`** — Stand: `ls docs/plan/planning/*/ | grep -cE '^slice-(061|063|064)-'`
  → **0**, die drei Mitglieder slice-061, slice-063 und slice-064 haben noch keine Datei.
- Closure-Notiz in `welle-09-results.md` mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Geschnitten sind slice-059, slice-060, slice-062, slice-066, slice-068 und slice-087; die übrigen
bekommen ihre Datei per `cp`, wenn sie an der Reihe sind. **Der Zustand ist das Verzeichnis, nicht
diese Zeile** — `ls docs/plan/planning/done/ | grep -cE 'slice-(059|060|062|066|068|087)-'` → **6**.

**slice-071 ist kein Mitglied.** Er war auf die Cache-Festlegung zugeschnitten, deren Adressat
(die Cache-Rechnung) nach [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
Festlegung 1 dauerhaft keinen Eingang hat; den Zellwert setzt dieselbe ADR selbst. Der Slice
trägt die zwei Posten, die [slice-066](done/slice-066-telemetrie-auswertung.md) §7 ihm zuweist
(Ausgabe des laufenden Auswerters, nicht Modul-15-Konformität), und läuft wellenlos.

| Slice | Ebene | Titel | Bezug |
|---|---|---|---|
| slice-059 | Repo | **Erfassung**: Spans per Agenten-Hook (Block 1) | [`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) |
| slice-060 | Repo | **Rollen-Achse**: rollen-benannte Agenten-Typen + Nutzungstelemetrie der Subagenten | [`MR-018`](../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) |
| slice-066 | Repo | **Auswertung**: Token-Bilanz je Rolle, die ihren Nenner nennt (Block 2) — setzt auf slice-060 auf | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| *kein Slice* | Repo | **Cache-Counter (Block 3)** — die Zelle *Cache-Counter × Repo* trägt **ADR-Verdikt** aus [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Festlegung 1, Folgepflicht 3): die Verbrauchs-Achse je Rolle ist permanent ohne Quelle, kein Auflösungs-Trigger, an seiner Stelle die Re-Evaluierungs-Trigger jener ADR. **Kein Slice liefert diesen Wert**: eine Cache-Rechnung hat keinen Eingang, und eine Festlegung darüber hätte keinen Adressaten — sie fiele in dem Moment, in dem einer entstünde, unter ihren eigenen Auflösungs-Trigger (*eine Metrik-Senke*) | [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) |
| slice-068 | Repo | **Rollen-Arbeit läuft als Rolle**: die Konvention wird vollständig (was, nicht nur wie) + die Berichtsgröße, an der sie ablesbar ist — legt für die Matrix-Zelle *Token-Attribution × Repo* fest, dass ihre Belegart **zweigeteilt** ist: **beide Teile tragen ADR-Verdikt**, aus zwei verschiedenen ADRs und je **ohne** Auflösungs-Trigger — der Hintergrund-Teil das aus [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md), der Haupt-Kontext das aus [`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md). Die Haupt-Kontext-Abweichung selbst hat slice-060 DoD (3) geliefert | keine `LH-*` (Dogfood-Prozessebene; im Slice begründet) |
| slice-061 | Repo | **Doku-Konsistenz**: behauptete Befehle existieren (Block 4) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-062 | **Tool** | **Entscheidung**: welche Modul-15-Regeln gehören in den emittierten Harness? (**nur** ADR — kein CR) | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| [slice-087](done/slice-087-emittierte-doku-tische-init-invariant.md) | **Tool** | **Vorarbeit**: **kein** emittiertes Dokument behauptet ein nicht Init-invariantes `make`-Ziel — die Ansprüche fallen emit-seitig, ein Wächter hält die Eigenschaft über den **Dokument-Satz** | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-063 | **Tool** | **Beleg**: den mitgelieferten Träger von Block 4 im frischen Ziel wirksam machen und in beiden Richtungen belegen — setzt auf [slice-087](done/slice-087-emittierte-doku-tische-init-invariant.md) auf | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) |
| slice-064 | beide | **Die Baseline-Aussage geradeziehen** + begrenzte Bestands-Stichprobe | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |

**Reihenfolge.** Erst die **Erfassung**, dann die Auswertung: ohne Spans hätte die Token-Bilanz nur
das Transkript des Werkzeugs, das außerhalb des Repos liegt und keine Korrelations-IDs trägt.
Die Rollen-Achse (slice-060) ist Vorbedingung der Auswertung: ohne sie wäre `agent_role` in jedem
Span leer und die Bilanz eine Summe aus zwei namenlosen Eimern; sie ist ein eigener
Liefergegenstand (`.claude/agents/`, `PreToolUse`-Guard). Ob die Rollen-Typen ins Ziel gehen,
entscheidet slice-062.

**Block 2 und Block 3 sind zwei Zellen.** Sie beantworten zwei Fragen — *wer hat wie viel
verbraucht* (Token-Attribution, slice-066) und *was hat der Cache getragen* (Cache-Counter) — und
tragen je eigene Pflicht-Angaben und eine eigene Festlegung in
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
([`ADR-0013`](../adr/0013-technik-stratum-als-zielort.md)). Block 2 hat eine Rechnung samt Zahn;
Block 3 bekommt keine, der Eingang bleibt aus. Die Cache-Trennung (Hit-/Miss-Zähler) liegt im
`usage`-Objekt eines Vordergrund-`Agent`-Aufrufs; der Vordergrund ist nicht anforderbar
([slice-086](done/slice-086-vordergrund-per-updatedinput.md)), der Ausfall ist in
[`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) permanent entschieden. Die drei
Pflicht-Labels und die Unerreichbarkeit führt [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
§5 Abweichung 1 ([`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) Festlegung 1 Punkt 5).
Was die Zahlen nicht abdecken, steht in
[`ADR-0012`](../adr/0012-haupt-kontext-ohne-token-bilanz.md): der Haupt-Kontext trägt keine
Bilanz, deshalb nennt jede Bilanz ihren Nenner (slice-066 DoD (2)).

**Beide Ebenen sind drin.** Das Repo ist der Prüfstand: was ins Ziel geht, ist hier erprobt
(dieselbe Linie wie [`ADR-0006`](../adr/0006-durchsetzung-commands-tool-als-quelle.md)). Die
Reihenfolge ist **Erprobung → Entscheidung → Emission**.

**slice-062 (Tool, Entscheidung).** Was ins Ziel gehört, berührt den Adopter-Vertrag; nach
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
bewegt ihn nur ein Change Request des Auftraggebers. Der Slice liefert die ADR und keinen CR, weil
ohne neues Artefakt keine Anforderung wächst. Die Entscheidung steht mit Begründung in
[slice-062](done/slice-062-emittierte-modul-15-regeln.md) und
[`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) (Block 4 über das advisory
`make doc-targets`), revidiert durch
[`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md): Span-Emitter und
Rollen-Typen (Block 1) sowie die Auswertung (Block 2 und 3) gehen ins Ziel. Die Abzählung der
Ausgänge führen die ADRs; sie hier zu doppeln, driftete.

**slice-087 (Tool, Vorarbeit).** Die Emission von Block 4 hängt an einer Bedingung über den
**Dokument-Satz**, nicht an einer Aufzählung von Fundorten: kein emittiertes Dokument darf ein
Ziel behaupten, das die Init-Phase nicht selbst schreibt. Der Befund besteht unabhängig von
Modul 15 ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
aber die Welle kann ohne ihn nicht schließen; deshalb ist er Mitglied. Reihenfolge:
**Entscheidung (slice-062) · Vorarbeit (slice-087) · Beleg (slice-063)**; die Vorarbeit wartet
auf die Entscheidung nicht, der Beleg auf beide.

**slice-063 (Tool, Beleg).** Liefert keinen Mechanismus, sondern den Beleg für den vorhandenen —
beide Richtungen aus §3 im frisch gebootstrappten Ziel: `make gates` out-of-the-box grün **und** ein
eingeschmuggelter Drift, der `make doc-targets` mit der Befund-Art `gate-phantom` rot färbt, samt
Rücknahme. Er schuldet **beide** Bootstrap-Varianten (`--lang go` und sprachlos); `make full-smoke`
zieht im sprachlosen Repo anschließend `add-lang go` nach, ein Zahn gehört deshalb **vor** diesen
Schritt, nicht in ein drittes tmp-Repo. Emittierte Artefakte tragen keine Quell-Repo-Identität.

**slice-064 — bewusst BEGRENZT.** Zwei Dinge, keine Inventur aller Regelwerk-Abschnitte:
(a) [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) wird auf die Aussage der
Vorlage zurückgeführt (die Verschärfung aus §1 wird deklariert oder zurückgenommen); (b) eine
**Stichprobe** über die Abschnitte nahe Modul 15 (modul-14/15/16). Ergibt sie ein Muster, ist der
Sensor ein **eigener Kandidat**, nicht Teil dieser Welle. slice-062 wartet auf [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) nicht (die
ADR ruht auf dem vendored Vorlagen-Wortlaut).

## 5. Abhängigkeiten

- **Blockiert:** nichts. Die Welle liefert Sensoren und Deklarationen, keine Nutzer-Fähigkeit.
- **Wird blockiert von:** keinem fremden Vorgang; die offenen Bedingungen sind eigene Arbeit — die
  Mitglieder ohne Datei (slice-061, slice-063, slice-064).
- **Werkzeugseitig blockiert nichts.** `targets` liegt als `make doc-targets` in
  [`d-check.mk`](../../../d-check.mk) vor; im Repo steht das Modul in der Modul-Liste von
  [`.d-check.yml`](../../../.d-check.yml) (`grep -n '^modules:' .d-check.yml`), und die emittierte
  Vorlage führt es ebenfalls (`grep -n '^modules:' internal/emit/templates/d-check.yml`). Die
  Aktivierung im emittierten Ziel liegt bei [slice-targets-modul-im-emittierten-doc-gate](done/slice-targets-modul-im-emittierten-doc-gate.md);
  slice-063 hat keine Datei.
- **Offen:** Das Gate-Fragment aus [slice-099](done/slice-099-leser-und-aufraeum-kommando.md) (zwei
  Init-invariante `make`-Ziele) gehört nach
  [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 4 und dem
  Kriterium aus [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4 in den Block-4-Satz.

## 6. Out-of-Scope für diese Welle

- **Ein OTel-*Stack*** — Collector, Backend, Dashboard, Vendor-SDK. **Nicht** die Erfassung: die
  ist der Kern dieser Welle. *Spans erfassen* und *einen Observability-Stack betreiben* sind zwei
  verschiedene Dinge, und nur das zweite ist hier Overhead. **Die Randbedingung ist „nichts, das
  installiert werden muss", nicht ein bestimmtes Werkzeug** — welche Mechanik sie erfüllt,
  entscheidet die Messung im jeweiligen Slice. Die Grenze verläuft zwischen der POSIX-Basis, die
  der Harness ohnehin voraussetzt, und jeder Laufzeit, die ein Adopter installieren müsste;
  maßgeblich ist [`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) Festlegung 4. Für die
  Feld-Auswahl gilt Modul 15 selbst: *„Ein Attribut ohne Incident-Frage fliegt raus."*
- **Den Adopter-Vertrag ändern, ohne dass ein CR ihn trägt** ([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler))
  **und ohne `full-smoke`-Beleg.** Die Tool-Ebene selbst ist **drin** (slice-062/063).
- **Die Kurs-Vorlagen selbst.** `conventions.template.md` und die übrige Doc-Chain kommen aus der
  vendored Baseline und gehören dem Kurs; fehlt dort etwas, ist es ein Upstream-Befund, keine
  repo-eigene Kopie (die
  [`MR-008`](../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)-Linie).
- **Die drei Wächter über den emittierten Abwesenheiten** — *kein `.claude/agents/`*, *kein
  Span-Emitter*, *kein Token-Bericht* im gebootstrappten Ziel. Kein Closure-Kriterium: der Wert
  *ADR-Verdikt* verlangt eine Entscheidung, keinen Sensor (§3). Ihr Träger ist die ADR, die sie
  als Folgepflicht schuldet.
- **Die übrigen Achsen des Roadmap-Kandidaten** (`vcs`/`commits`-Module, Closure-Notiz-Sensor,
  Release-Text-Check, DoD-Punkte-Zähler). Sie bleiben Kandidaten; die Welle nimmt nur, was
  Modul-15-Konformität verlangt.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-09-results.md. -->
