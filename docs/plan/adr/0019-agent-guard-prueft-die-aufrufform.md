# ADR-0019: Der Agent-Guard prüft die Aufrufform, nicht die Betriebsart

**Status:** Proposed

**Datum:** 2026-08-15

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Guard bleibt
`bash` + `awk`; die Alternative, die diese ADR mit offener Messschuld führt, ebenfalls),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Fitness Function unten muss rot werden **können** — hier ausnahmsweise mit zwei Zeilen, deren
Dateien existieren),
[ADR-0004](0004-durchsetzungs-emission.md) (**Accepted** — die Guard-Bauart in `bash`/`awk`, an
der diese Entscheidung ansetzt; der Guard ist ein Stolperdraht, keine Sandbox),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 1 Punkt 5 verlangt,
das nach der Ableitung Unerreichbare *begründet zu dokumentieren*; Festlegung 2 schließt fremden
Inhalt aus dem Log aus und trägt damit Alternative B unten),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — die Nachbar-Abweichung auf
derselben Achse. Sie hat den Modul-7-Trichter für **ihren** Fall gefahren und ausdrücklich offen
gelassen, ob der hiesige denselben Pfad nehmen muss; diese ADR beantwortet genau das),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (**Accepted** — die Form, in der die
Regelwerks-Belege unten stehen: Tag, Dateiname, Abschnitt, Zitat)

**Schärft:**
[`spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
— die **START-KONVENTION** für Rollen-Läufe samt ihrer Bedingung 2, den Wächter-Absatz zu dieser
Bedingung, den fünften Punkt der Erfassungs-Liste und **Abweichung 5**. Aufwärts-Deklaration der
Änderungskopplung: wer diese ADR ändert, zieht von hier die betroffenen Spec-Stellen nach.
**Die emittierte Ebene ist nicht berührt, und das ist gemessen, nicht angenommen:**
`internal/emit/templates/enforce/` führt den Command-Guard, den Stop-Hook, die
Gate-Nachweis-Mechanik und die `settings.json` des Ziels — **keinen** Agent-Guard. Gegenstand ist
der Dogfood dieses Repos.

---

## Kontext

### Die Reihenfolge ist umgekehrt, und das gehört an den Anfang

[`AGENTS.md`](../../../AGENTS.md) §3.5 verlangt für eine Senkung der Durchsetzung eine ADR. Die
Senkung ist am 2026-08-15 vollzogen (`83cf01d`); diese ADR datiert vom selben Tag und folgt ihr.
Der Grund liegt im Gegenstand: die gesenkte Bedingung wies **jeden Rollen-Typ** ab, auch den der
Rolle, die ADRs schreibt — Regelwerk `v3.5.2`, `modul-08-agentenrollen.md` §Rollen-Regeln:
*„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als
Constraint"*. **Von innen, durch einen Agenten, war die Schleife nicht aufzuschneiden:** wer die
eigene Durchsetzung abhängt, um schreiben zu dürfen, ist genau der Fall, gegen den ein Guard
steht.

**Ein Weg mit erhaltener Reihenfolge stand dem Auftraggeber jedoch offen — und er ist weder
gefahren noch erwogen worden.** Die Verdrahtung liegt in `.claude/settings.json`, und der
Arbeitsbaum ist frei: den `"matcher": "Agent"`-Eintrag **uncommittet** für genau einen
Architect-Lauf abzuhängen, die ADR schreiben zu lassen und die Verdrahtung danach zurückzunehmen,
hätte die **committete** Durchsetzung unverändert gelassen und die Reihenfolge aus §3.5 erhalten.
Der uncommittete Messaufbau ist in diesem Repo geübte Praxis — die Sonden hinter
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) sind im Arbeitsbaum gebaut, gefahren und
zurückgenommen worden. Diese ADR behauptet deshalb **nicht**, die umgekehrte Reihenfolge sei
alternativlos gewesen; sie hält fest, dass sie eingetreten ist, und verengt ihre Prämisse auf das,
was trägt: für einen **Agenten** war die Schleife geschlossen, für den Auftraggeber nicht.

**Der Fußabdruck, und seine Grenze.** Der annehmende Akt ist eine Auftraggeber-Entscheidung in der
Sitzung; das Repo hält von ihr die **Reihenfolge** fest, nicht die Zustimmung. `60e4370` trägt
allein das Messdokument, das die Schleife benennt, und liegt **vor** der Senkung `83cf01d` — zwei
getrennte Commits, an `git log --stat` ablesbar. Was daraus **nicht** folgt: dass jemand
zugestimmt hat; das steht nirgends im Baum. Die Berufung auf
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
ist darum ausdrücklich eine **Analogie und keine Anwendung**: sein Geltungsbereich ist
`spec/lastenheft.md` §7 und die Commit-Disziplin um diese Datei, und ein Lastenheft ist hier nicht
geändert — es liegt kein Change Request vor. Übertragbar ist allein der Satz, mit dem seine
Setzung 1 sich selbst begründet: *„Was die Baseline-Regel trägt, ist nicht die Externalität des
Ticket-Systems, sondern die **Trennung der Entscheidung von der Umsetzung**"*.

**Was daraus für diese ADR folgt: sie entscheidet die Sache, nicht die Reihenfolge.** Die
Reihenfolge steht hier, weil sie sonst niemand mehr sieht — und weil der Fall **keine** Präzedenz
für *„erst senken, dann begründen"* trägt. Er trägt eine engere: **eine Durchsetzung, die ihre
eigene schreibende Rolle blockiert, öffnet der Auftraggeber, und die Öffnung steht in der ADR.**
Wer sich später auf diesen Fall beruft, hat zweierlei zu zeigen: dass die Senkung die Rolle
blockierte, die sie hätte entscheiden müssen — **und** dass der uncommittete Weg oben geprüft und
für seinen Fall verworfen ist. Dieser Lauf hat ihn nicht geprüft; die Präzedenz deckt darum nur,
was hier vorlag, nicht die Behauptung, es habe keinen anderen Weg gegeben.

### Was der Guard verlangte, und woran er scheiterte

Bis `83cf01d` verlangte
[`.claude/hooks/pretooluse-agent-guard.sh`](../../../.claude/hooks/pretooluse-agent-guard.sh) von
jedem Aufruf mit erkennbarem **Rollen**-Typ die Betriebsart `run_in_background: false`; ein
fehlender Schalter galt als Hintergrund. Am 2026-08-15 fiel eine Probe mit
`subagent_type: architect` darauf, und die Ablehnung kam wörtlich beim Aufrufer an — nicht am Typ-Zweig, sondern am
Betriebsart-Zweig; der Extraktor hatte den Typ gelesen (Messung §1). **Gemessen ist eine Probe,
getroffen sind alle sechs:** der Zweig fragt, ob `.claude/agents/<name>.md` existiert, und das
Verzeichnis führt genau die sechs Rollen — Planner, Architect, Implementer, Reviewer, Verifier,
Validator. Nicht-Rollen-Typen (`general-purpose`, `Explore`, `Plan`) liefen unverändert durch.

Alle Messungen dieses Abschnitts stehen in
[`docs/reviews/2026-08-15-agent-guard-tool-vertrag.md`](../../reviews/2026-08-15-agent-guard-tool-vertrag.md)
(Zeitdokument, jede Zahl gilt an ihrem Datum). Hier steht, was sie **entscheiden**, nicht was sie
sind.

### Die Vertragsänderung — und die Beleglage genauer als der Anlass

Der Grund für Festlegung 1 ist kein Abwägen von Nutzen gegen Kosten, sondern eine **Änderung des
Eingabe-Vertrags**. Zwei Enden — und sie sind **nicht von derselben Art**; das gehört in denselben
Satz wie der Befund:

- **2026-07-29 war der Vordergrund herstellbar, und das ist an der Payload gemessen.**
  `tool_input` trug über vier echte Aufrufe die Schlüssel `subagent_type`, `prompt`, `description`
  **und** `run_in_background`; ein Rollen-Typ mit `true` wurde abgelehnt, derselbe Typ mit `false`
  lief unmittelbar davor durch — und die `usage`-Zähler lagen an diesem Tag in der `tool_response`
  eines Vordergrund-Aufrufs (`docs/reviews/2026-08-02-span-schema-messreihen.md` §1, §2 und §3).
- **2026-08-15 ist er es nicht mehr — und dieses Ende ist keine Payload-Beobachtung.** Beobachtet
  ist eine **Ablehnung**: die Probe fiel in den letzten Zweig der damaligen Guard-Fassung, und
  dieser Zweig feuerte für **jeden** Wert, der nicht `false` war — für `true` genauso wie für ein
  fehlendes Feld (`git show 60e4370:.claude/hooks/pretooluse-agent-guard.sh`, die zwei letzten
  Zeilen: `[ "$rib" = "false" ] && exit 0`, danach `emit_deny`). **Gemessen ist damit genau eines:
  kein Aufruf trug `run_in_background: false`.** Dass das Feld ganz *fehlte*, folgt nicht aus
  dieser Beobachtung, sondern aus der **Schema-Selbstauskunft** desselben Laufs (`prompt`,
  `description`, `subagent_type`, `model`, `isolation`, keine zusätzlichen Felder). Die Rohpayload
  ist an dem Tag nicht ausgeworfen worden.

**Was die vendored Werkzeug-Doku dazu NICHT beiträgt — hier nachgemessen.** Ihre
`Agent`-Eingabetabelle führt vier Felder (`prompt`, `description`, `subagent_type`, `model`), und
sie führte **dieselben vier schon beim Vendoring**: gegen den Vendoring-Commit gehalten
(`git show 73a4d86:docs/user/claude-hooks-referenz.md`, Abschnitt *Agent*) ist die Tabelle
unverändert. Ein `run_in_background` hat für `Agent` **nie** darin gestanden. Die Tabelle kann
eine Vertragsänderung deshalb weder belegen noch widerlegen — sie sagt heute, was sie damals
sagte, als der Schalter nachweislich wirkte. **Was sie sehr wohl belegt**, steht eine Tabelle
weiter, in der Beschreibung des Antwort-Feldes `status`: *„Ab v2.1.198 werden Subagenten
standardmäßig im Hintergrund ausgeführt, daher erzeugt ein weggelassenes `run_in_background` auch
`"async_launched"`"* — der Hintergrund ist der **Standard**, ein weggelassener Schalter also kein
Versehen des Aufrufers. Der Beleg für die Änderung selbst ist die Payload-Messung von 2026-07-29
gegen die Ablehnung und die Schema-Selbstauskunft vom 2026-08-15, nicht die Doku.

**Die Grenze dieser Beleglage, benannt statt geglättet.** Für Festlegung 1 reicht, was gemessen
ist: der Guard sah eine Payload ohne `run_in_background: false`, und eine Bedingung, die keine
Payload mehr erfüllt, verweigert alles und schützt nichts. Ungemessen bleiben **zwei** Aussagen,
und jede hat ihre eigene Sonde:

- *Das Modell sendet den Schalter nicht mehr.* **Sonde:** im `PreToolUse`-Hook die
  **Schlüsselmenge** von `tool_input` auswerfen — nur die Namen, keine Werte
  ([ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2) — und gegen die vier vom
  2026-07-29 halten. Sie unterscheidet ein fehlendes Feld von `true`; der Deny-Text konnte das
  nicht. Repo-lokal, in `bash` + `awk` wie der vorhandene Extraktor.
- *Der Schalter ist überhaupt nicht mehr sendbar.* **Sonde:** das Feld **nach** dem Modell
  einsetzen und beobachten, ob das Werkzeug es annimmt. Das ist die Messung aus Festlegung 4; sie
  entscheidet dieselbe Frage von der anderen Seite und ist deshalb dort geführt, nicht hier.

Für Alternative D unten macht die zweite den ganzen Unterschied: sie setzt das Feld nach dem
Modell ein und umgeht dessen Schema.

**Dieser Architect-Lauf kann das Tool-Schema nicht nachmessen:** ein Subagent führt das
`Agent`-Werkzeug nicht. Nachgemessen ist hier, was repo-lokal messbar ist — die Doku-Historie
oben und der Span-Bestand unten.

### Was ausfällt — und was nicht (am 2026-08-15 selbst gemessen)

Der Span-Bestand liegt gitignored und maschinenlokal; die Zahlen gelten diesem Tag und dieser
Maschine, die **Gestalt** ist die Aussage. Drei `Agent`-Spans des Tages, dazu drei
`SubagentStart`-Ereignisse zu denselben drei Zeitstempeln in derselben Sitzung
(15:38:17Z · 16:06:10Z · 16:08:11Z) — eine saubere Paarung, kein Rest:

- **Der `Agent`-Span trägt von den neun erfassten Werten genau einen:** `model_version`. Kein
  `spawned_role`, keiner der vier `usage`-Zähler, kein `total_tokens`, `total_duration_ms`,
  `total_tool_use_count`. Seine `duration_ms` sind 6 · 3 · 3 — die Dauer des **Aufrufs**, nicht
  die des Laufs.
- **Der zugehörige Subagenten-Strom trägt den Typ in jeder Zeile:** `agent_type` steht schon im
  `SubagentStart` (zweimal `architect`, einmal `general-purpose`) und in jedem Span des Laufs — im
  Lauf, in dem diese ADR entsteht, in **allen** seinen Spans zum Zeitpunkt der Messung. `agent_role`
  steht daneben, aber es trägt **nicht dasselbe**: gefüllt, wo der Typ eine Rolle ist, und leer bei
  `general-purpose`, weil die Ableitung Nicht-Rollen auf leer normalisiert.

**Damit fällt genau eine Achse aus, und die andere trägt.** Die Rollen-Achse stammt aus der
Hook-Payload *innerhalb* des Subagenten und ist von der Betriebsart unabhängig; der Ausfall
betrifft das **Kosten-Aggregat des Aufrufs**: `spawned_role`, die vier `usage`-Zähler und die drei
Summen — acht der neun Werte, einer bleibt.

**Die Folge für die Auswertung, aus dem Code gelesen:**
[`internal/report/report.go`](../../../internal/report/report.go) zählt jeden `Agent`-Span als
Lauf und kehrt zurück, sobald Eingabe- und Ausgabe-Zähler beide fehlen. Bei durchgehendem
Hintergrund-Betrieb wächst `AgentLaeufe`, `MitZaehlern` bleibt 0, und die Token-Bilanz je Rolle
hat keinen einzigen Eingang. Der Bericht sagt es von selbst: er schreibt
`Abdeckung: %d von %d Agent-Laeufen trugen Zaehler`, und die erste Zahl ist dann 0. `make
span-report` ist ausdrücklich **kein** Gate; nichts wird hier rot.

### Der Trichter nach Modul 7 — für den Ausfall, nicht für den Guard

Die Änderung am Guard ist eine Senkung der Durchsetzung und damit eine ADR-Frage
([`AGENTS.md`](../../../AGENTS.md) §3.5). Der **Ausfall der Token-Achse** ist eine zweite Frage:
eine Diskrepanz zum Regelwerk (`v3.5.2`, `modul-15-observability.md`
§Token-Attributions-Regeln: *„Summiere Input- und Output-Token pro `agent.role` … und gib an,
welche Rolle den größten Anteil trägt — als Zahl und als Prozentsatz der Gesamtsumme"*). Für sie
gilt der Trichter aus `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz — Granularität **vor**
Temporalität:

1. **Granularität — einzelne Diskrepanz oder Cluster?** *Einzelne.* Modul 7 macht daraus keinen
   Schwellwert; seine Faustregel für *Cluster* ist der **gemeinsame Geltungsbereich**, keine
   Carveout-Zahl. Die Nachbar-Abweichung aus [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md)
   betrifft dieselbe Achse, aber einen anderen Geltungsbereich: dort umschließt **kein** Aufruf
   den Gegenstand, hier gibt es einen Aufruf samt Payload, nur ohne Zähler. Und die zwei
   BF-Symptome liegen nicht vor: dieses Repo führt bislang **einen** Carveout, mit dem diese
   Diskrepanz keinen Geltungsbereich teilt, und sie folgt nicht aus dem Muster *„Code existiert
   vor Doku"* — die Doku ist vollständig, es fehlt eine **Quelle**. → Frage 2.
2. **Temporalität — Trigger ernst zu erreichen?** *Ja, für genau einen Weg, und der liegt in
   unserer Hand.* Modul 7: *„Ja (absehbarer Aufwand, sinnvolles Verhältnis zum Nutzen) →
   Carveout … Nein (‚nichts davon werden wir in absehbarer Zeit tun') → permanent, übergeführt in
   eine ADR."* Zwei der drei denkbaren Trigger liegen im fremden Vertrag (ein Schema, das die
   Vordergrund-Form wieder anbietet; ein Hook-Ereignis, das die Zähler trägt) — für sie allein
   wäre die Antwort *Nein*, und der Pfad wäre der von
   [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md). Der dritte ist **eine Messung, die dieses
   Repo selbst fahren kann** (Festlegung 4), und er ist kein bloßes Nachsehen: hält der Weg, dann
   **stellt unser eigener Hook** den Vordergrund her, statt eine fremde Bedingung abzuwarten.
   Genau daran scheiterte der Carveout-Pfad in
   [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (*„er hat keinen Gegenstand … Ein Slice mit
   dem Inhalt ‚abwarten' ist das Memo unter anderem Namen"*) — hier hat der Folge-Slice einen
   Gegenstand und einen entscheidbaren Ausgang. → **Carveout**
   ([CO-002](../carveouts/CO-002-token-achse-je-rolle.md)).

**Und die Kehrseite gehört in dieselbe Antwort:** fällt die Messung negativ aus, bleiben nur die
zwei fremden Trigger, und dann ist die Antwort auf Frage 2 *Nein*.
[CO-002](../carveouts/CO-002-token-achse-je-rolle.md) ist deshalb mit **zwei** Ausgängen angelegt — Auflösung oder Überführung in eine Folge-ADR —, und beide hängen an derselben
Messung.

### Annahmen, auf denen diese ADR steht

Kippt eine, kippt die Entscheidung; alle drei stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Das Agenten-Werkzeug bietet keine anforderbare Vordergrund-Form mehr an.
- **(b)** Kein Hook-Ereignis trägt die Zähler. `SubagentStop` trägt `agent_type`,
  `agent_transcript_path` und `last_assistant_message`, **keine** `usage` — das ist der vendored
  Doku entnommen, hier **nicht** gemessen, und dieses Repo hat das Ereignis nicht verdrahtet
  (`.claude/settings.json` führt `PreToolUse` zweimal, `PostToolUse`, `PostToolUseFailure`,
  `SubagentStart` und `Stop`).
- **(c)** Das Subagenten-Transkript bleibt als Quelle ausgeschlossen
  ([ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2: kein Byte fremden Inhalts).

## Entscheidung

**Wir wählen Option A: die Schalter-Forderung fällt, der Verlust wird geführt.** Vier
Festlegungen:

**1. Der Guard entscheidet die AUFRUFFORM — lesbar oder nicht —, und die Betriebsart ist kein
Gegenstand mehr.** Vier fail-closed-Zweige bleiben: fehlendes `awk`, fehlender Extraktor,
Parse-Zweifel und fehlender Subagent-Typ. Ein lesbarer Typ läuft durch, auch ein Rollen-Typ.
**Der tragende Grund ist die Vertragsänderung, nicht eine Abwägung:** eine Bedingung, die kein
Aufruf mehr erfüllen kann, ist keine strenge Durchsetzung, sondern ein **Ausfall** — sie
verweigert alles und schützt nichts. Ein Guard, der auf ein Feld prüft, das der Vertrag nicht
mehr führt, misst nicht mehr die Wirklichkeit, sondern seine eigene Entstehungszeit.

**2. Der Guard führt keine verweigernde Rollen-Frage mehr.** Die Ableitung *„ein Typ ist eine
Rolle, wenn `.claude/agents/<name>.md` existiert"* fällt mit der Betriebsart-Forderung — sie hatte
genau **einen entscheidenden** Abnehmer; ohne ihn stünde ein Zweig da, dessen beide Ausgänge
`exit 0` sind. **Was mit ihr fällt und hier genannt gehört:** sie war die einzige Stelle im Repo,
die Rollen-Zugehörigkeit aus dem Verzeichnis **ableitete**, statt sie zu notieren; die Grenze, die
dadurch sichtbar wird, steht unten in den Konsequenzen.
**Was hier NICHT entschieden ist:** ob der Guard eine **nicht entscheidende** Rollen-Frage bekommt
— protokollieren statt verweigern. Das gehört dem Slice, der das Vor-Aufruf-Protokoll baut, und
er hat zwei Constraints: der Zweig darf die Aufrufform **nicht** entscheiden (sonst wird der
bats-Fall unter Festlegung 1 rot, und das zu Recht), und er unterliegt
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2 wie jede andere Erfassung.
**Entschieden ist die Gegenrichtung:** eine **verweigernde** Rollen-Frage kehrt nicht ohne
Folge-ADR zurück — sie widerspräche Festlegung 1, und ab *Accepted* führt der Weg dahin über
[`AGENTS.md`](../../../AGENTS.md) §3.4.

**3. Der Ausfall der Token-Achse je Rolle wird als Carveout geführt**
([CO-002](../carveouts/CO-002-token-achse-je-rolle.md))**, nicht als permanente Abweichung.**
Begründung ist der Trichter oben; der Unterschied zu
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) ist der **Gegenstand des Folge-Slice**, nicht
die Achse. Geltungsbereich, Trigger und die zwei Ausgänge stehen dort, nicht hier — ein zweiter
Ort driftet.

**4. Der `updatedInput`-Weg wird als Alternative mit OFFENER MESSSCHULD geführt, nicht
verworfen.** Ein `PreToolUse`-Hook kann die Tool-Argumente vor der Ausführung ersetzen; die
vendored Doku sagt dazu: *„Ändert die Tool-Eingabeparameter vor der Ausführung. Ersetzt das
gesamte Eingabeobjekt, daher müssen Sie unveränderte Felder zusammen mit geänderten einbeziehen.
Kombinieren Sie mit `"allow"`, um automatisch zu genehmigen, oder mit `"ask"`, um die geänderte
Eingabe dem Benutzer zu zeigen."* **Ob das Agenten-Werkzeug ein so eingespeistes
`run_in_background` befolgt, hat niemand geprüft.** Seit das Modell das Feld nicht mehr senden
kann, ist das der einzige denkbare Weg zurück in den Vordergrund, der nicht am fremden Vertrag
hängt — denn er setzt das Feld **nach** dem Modell ein.

**Die Messung, die ihn entscheidet, in einer Zeile:** ein Hook auf `Agent` gibt die Eingabe
unverändert zurück und ergänzt `run_in_background: false`; entschieden ist der Weg an genau einer
Beobachtung — **trägt der `Agent`-Span des so gestarteten Laufs `spawned_role` und die vier
`usage`-Zähler, hält er; trägt er sie nicht, hält er nicht.** Abgelesen wird das an der
`Agent`-Zeile des Span-Bestands, nicht an der Abdeckungszahl des Berichts: die zählt einen Lauf
schon als gedeckt, wenn **ein** Zähler gesetzt ist, und fragt nach der Rolle nicht. Der Preis
gehört vorher benannt, weil er die Verstetigung mitbestimmt: die Doku nennt zwei Kombinationen und
erklärt das Feld für `"defer"` als ignoriert — `"allow"` überspringt für **jeden**
Agenten-Aufruf das Permission-System, `"ask"` fragt bei jedem nach. Beides ist eine Entscheidung
über die Durchsetzung und nicht nebenbei zu treffen; die Messung selbst ist davon nicht betroffen,
ihre Verstetigung sehr wohl.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| **A — Schalter-Forderung fällt, der Verlust wird geführt (gewählt)** | die sechs Rollen laufen sofort wieder; die vier übrigen fail-closed-Zweige bleiben unberührt; der Guard sagt danach, was er wirklich entscheidet | die Token-Achse je Rolle fällt aus, und keine Zusage dieses Repos ersetzt sie. Der Preis ist geführt, nicht bezahlt ([CO-002](../carveouts/CO-002-token-achse-je-rolle.md)) |
| B — **Träger wechselt auf `SubagentStop`**: die Rolle kommt vom Ereignis, die Zähler aus `agent_transcript_path` | das Ereignis trägt die Rolle unabhängig von der Betriebsart | ein neuer Parser in `bash` + `awk` über ein undokumentiertes Format, der eine Datei mit dem **Prompt** liest — gegen [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2 (*kein Byte fremden Inhalts*), dieselbe Quelle, die dort schon als Alternative D verworfen wurde. Und das Ereignis ist heute nicht verdrahtet: der Weg löste den Blocker erst an seinem Ende |
| C — **der Guard bleibt, wie er war** | keine Änderung an der Durchsetzung, keine ADR nötig | die Rollen-Trennung dieses Repos ist unbenutzbar: Planner, Architect, Implementer, Reviewer, Verifier und Validator sind nicht startbar. Eine Bedingung, die niemand erfüllen kann, hält keine Strenge aufrecht — sie hält den Prozess an |
| D — **`updatedInput` sofort verdrahten**, ohne Messung | stellte den Vordergrund her, **wenn** das Werkzeug das eingespeiste Feld befolgt — die Token-Achse käme zurück | ungemessen; und die Verdrahtung koppelt jeden Agenten-Aufruf an `"allow"` oder `"ask"`, also eine Änderung an der Permission-Lage nebenbei. Eine Zusage ohne rot gesehenes Gegenbeispiel ([`AGENTS.md`](../../../AGENTS.md) §3.6). **D ist deshalb keine verworfene Alternative, sondern der Auflösungsweg von Festlegung 3** — mit benannter Messschuld statt mit Verdrahtung |
| E — **die Existenzprüfung behalten**, nur den Schalter-Zweig entfernen | der Guard behielte eine Rollen-Frage, und ein späterer Zweig hätte seinen Anker schon da | ein Zweig, dessen beide Ausgänge `exit 0` sind, entscheidet nichts. Er sieht aus wie Durchsetzung, ist aber tote Mechanik — und der nächste Lauf liest ihn als Zusage. Wer eine Rollen-Frage braucht, baut sie mit ihrem Abnehmer; `git` hält die gelöschte Form |

## Konsequenzen

- **Positiv:** die sechs Rollen sind wieder startbar, und die Rollen-Achse der Telemetrie trägt
  weiter — für die sechs **notierten** Rollen gemessen, nicht gehofft (oben); ihre Grenze steht
  vier Punkte tiefer.
- **Positiv:** der Guard sagt jetzt, was er entscheidet. Sein Kopf behauptet keine Telemetrie-
  Wirkung mehr, die er nicht herstellen kann.
- **Negativ, und das ist der Preis:** die Token-Bilanz je Rolle hat keinen Eingang mehr; die
  Abdeckungszahl des Berichts steht auf 0 von N. Die Antwort auf *„was hat dieser Lauf
  gekostet?"* fehlt damit für **beide** Kontext-Arten — für den Haupt-Kontext dauerhaft
  ([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md)), für Subagenten-Läufe bis zur Auflösung
  von [CO-002](../carveouts/CO-002-token-achse-je-rolle.md).
- **Negativ:** der Guard schützt weniger, als seine Verdrahtung nahelegt. Was von ihm bleibt, ist
  fail-closed gegen **unlesbare** Aufrufe — kein Schutz gegen falsch **gestartete**.
- **Grenze, benannt statt nachgerüstet — die Rollen-Achse hängt an einer notierten Liste, nicht am
  Verzeichnis.** Die Zuordnung Typ → Rolle entsteht im Emitter aus einer **hart notierten
  Sechser-Liste** (`roleFromAgentType` in `internal/span/emit.go`), und kein Go-Code koppelt sie an
  `.claude/agents/`: `grep -rn "claude/agents" --include=*.go .` liefert **null** Treffer (am
  2026-08-15 gefahren). Eine siebte Datei im Verzeichnis liefe nach Festlegung 1 durch, jeder Span
  ihres Laufs trüge `agent_role: ""`, und nichts würde rot. Die Lücke ist **älter** als diese ADR
  und wird von ihr nicht verursacht; Festlegung 2 entfernt aber die einzige andere Stelle, die
  Rollen-Zugehörigkeit aus dem Verzeichnis **ableitete** — danach ist die Liste der einzige Träger.
  Ein Nachrüst-Auftrag steht hier bewusst nicht; die Grenze steht, damit die Positiv-Konsequenz
  oben nicht als Zusage für **jede künftige** Rolle gelesen wird.
- **Folgepflicht 1 — [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  §5 nachziehen; die Stellen nach Eigenschaft, nicht nach Zeile:** der fünfte Punkt der
  Erfassungs-Liste (*„Die Zähler kommen nur im Vordergrund an"* — der Vordergrund ist nicht mehr
  herstellbar, und der dort schon benannte `updatedInput`-Weg wird von Festlegung 4 aufgenommen);
  die **START-KONVENTION**, deren Bedingung 2 ihren Gegenstand verliert — sie ist keine Regel
  mehr, sondern eine Beschreibung dessen, was das Werkzeug nicht mehr anbietet, und ihre zwei
  Belegklassen gelten weiter für die **Wirkung**, nicht für die Wahl; der Wächter-Absatz zu dieser
  Bedingung, der eine Zusage des Guards nennt, die er nicht mehr gibt; und **Abweichung 5**, deren
  Prüfschritt 2 (*„Vermeidbar? … ja"*) und deren Fall-Liste in Prüfschritt 3 den Guard als
  Verkleinerer der Lücke führen. Der Nachzug gehört dem Eigentümer des Spec-Stratums, nicht dieser
  ADR; er trägt den Zeiger auf
  [CO-002](../carveouts/CO-002-token-achse-je-rolle.md).
- **Folgepflicht 2 — der Zeiger auf den Carveout.** Modul 7 verlangt, dass die Stelle, an der die
  Ausnahme wirkt, auf den Carveout zeigt (`v3.5.2`, `modul-07-carveouts.md` §Ziel-Form: Carveout:
  *„Gate-Konfiguration zeigt per `# CO-<NNN>`-Kommentar auf den Carveout — sonst ist die
  Pfad-Ausnahme im `make gates`-Output eine stille Senkung ohne Begründung"*). Eine
  Gate-Konfiguration gibt es hier nicht; die Stellen, an denen der Ausfall beschrieben wird, sind
  der Kopf des Guards und Abweichung 5 im Spec-Stratum. Beide zu setzen ist Implementer- und
  Spec-Arbeit, keine dieser ADR; welche Stelle den Zeiger trägt, führt
  [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) §Geltungs-Konfiguration.
- **Folgepflicht 3 — der Folge-Slice zur Messung aus Festlegung 4, geschnitten vom Planner.** Ohne
  ihn ist [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) nach `modul-07-carveouts.md`
  §Ziel-Form: Carveout *de facto* permanent (*„Fehlt der Folge-Slice, ist der Carveout de facto
  permanent — dann gehört er nicht in `carveouts/`, sondern über den Trichter unten in eine
  ADR"*) und in eine Folge-ADR zu überführen. Die Bedingung ist eine **Eigenschaft**, keine
  Adresse: ein Slice in `docs/plan/planning/`, der die Messung aus Festlegung 4 fährt und **beide**
  Ausgänge bindet. Er trägt den Zeiger auf den Carveout, nicht umgekehrt; welcher es ist, führt
  [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) §Folge-Slice. Diese ADR benennt die
  Bedingung; sie schreibt den Slice nicht.
- **Folgepflicht 4 — die emittierte Ebene bleibt unberührt, und das ist eine Entscheidung.** Sie
  führt heute keinen Agent-Guard (oben gemessen). Bekommt sie je einen, gilt diese Grenze dort
  unverändert — sie ist keine Eigenschaft unseres Aufbaus, sondern der Mechanik — und gehört dort
  **genannt**, nicht stillschweigend mitgeliefert.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| bats — `test/agent-guard.bats`, Fall *„guard: JEDER Typ in .claude/agents/ laeuft durch"* | Kein Typ mit einer Datei in `.claude/agents/` wird abgewiesen; der Fall fährt über **jede** Datei des Verzeichnisses, eine neue Rolle ist damit im **Durchlass** mitgeprüft, ohne dass der Fall zu ändern wäre. **Nicht** gedeckt ist ihre Aufnahme in die **Rollen-Achse** der Telemetrie — die hängt an der notierten Liste im Emitter (Konsequenzen, §Grenze) | `make test` (in `make gates`) |
| Mutation — `test/mutations/150-agentguard-rolle-abgewiesen.sh` | Baut einen verweigernden Zweig für Rollen-Typen wieder ein; der bats-Fall oben **muss** dabei rot werden. Ohne diesen Fall wäre Festlegung 1 eine Absicht | `make mutate` (nicht in `make gates`; CI pro Push, [`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) |

**Beide Dateien existieren** — am 2026-08-15 in diesem Lauf nachgesehen, samt dem Namen des
bats-Falls. **Rot gesehen** sind sie im Commit, der die Änderung trägt (`83cf01d`, Message:
*„Rot gesehen, beide in isolierter Kopie: 150 faerbt ‚JEDER Typ in .claude/agents/ laeuft durch',
139 faerbt ‚Agent-Aufruf ohne Subagent-Typ -> DENY'"*). **Dieser Architect-Lauf hat die Läufe
nicht wiederholt** — er schreibt die Begründung, nicht den Nachweis; der gehört dem Verifier.

**Was die zwei Zeilen NICHT leisten.** Sie binden, dass der Guard Rollen-Typen **durchlässt** —
nicht, dass ein Rollen-Lauf am Ende Zähler trägt, und nicht, dass seine Rolle in der Telemetrie
ankommt. Für Festlegung 3 gibt es keinen Wächter, und das ist eine Aussage, kein Auslassen:
solange die Zähler in keiner Payload stehen, gibt es kein Gegenbeispiel, das rot werden könnte
([`AGENTS.md`](../../../AGENTS.md) §3.6). An seine Stelle tritt das `Letzte Prüfung`-Datum von
[CO-002](../carveouts/CO-002-token-achse-je-rolle.md) und das Carveout-Audit je Welle —
Beobachtung durch Wiedervorlage, nicht durch Sensor.

## Re-Evaluierungs-Trigger

- **Wenn das Eingabe-Schema von `Agent` wieder eine Vordergrund-Form anbietet** *(feedforward —
  fremder Vertrag, kein Sensor; die Payload-Fläche wächst belegbar: vier gemessene Aufrufe zeigten
  fünf undokumentierte Schlüssel)*: dann fällt Annahme (a), Festlegung 1 ist neu zu prüfen und
  [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) aufzulösen.
- **Wenn ein Hook-Ereignis die Zähler trägt** *(feedforward — nur sichtbar, wer das Ereignis
  verdrahtet und seine Schlüsselmenge misst)*: dann fällt Annahme (b), und der Träger wechselt,
  ohne dass die Betriebsart zurückkommen muss.
- **Wenn die Messung aus Festlegung 4 gefahren ist** *(feedback — sie hat einen entscheidbaren
  Ausgang, und beide Ausgänge binden)*: trägt der Weg, ist die wiederhergestellte Vordergrund-Form
  samt ihrer Permission-Folge in einer Folge-ADR zu entscheiden; trägt er nicht, liegt der Trigger
  vollständig im fremden Vertrag, und [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) ist in
  eine Folge-ADR zu überführen — die Lage, für die
  [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) den permanenten Pfad gewählt hat.
- **Wenn die Transkript-Entscheidung kippt** *(feedforward — eine Erlaubnis des Auftraggebers,
  kein Sensor)*: dann fällt Annahme (c), und Alternative B ist neu zu bewerten — zuerst als
  Sicherheitsfrage, dann als Erfassungsfrage.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-15 | **Proposed** | Architect-Auftrag zur bereits vollzogenen Senkung `83cf01d`. Grundlage ist die Messung in [`docs/reviews/2026-08-15-agent-guard-tool-vertrag.md`](../../reviews/2026-08-15-agent-guard-tool-vertrag.md); der Eintritt in die blockierte Schleife war eine Auftraggeber-Entscheidung |
| 2026-08-15 | **Überarbeitet, weiter Proposed** | Die Beleglage von Festlegung 1 trennt jetzt zwei Arten von Beleg — Payload-Messung (2026-07-29) gegen Ablehnung plus Schema-Selbstauskunft (2026-08-15) —, und die zwei ungemessenen Aussagen tragen je ihre Sonde. Die Reihenfolge-Prämisse ist auf den Agenten-Weg verengt: der uncommittete Weg des Auftraggebers steht als offen und ungeprüft da und ist Teil der Berufungslast. Der [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)-Bezug ist als **Analogie** gekennzeichnet, der reale Fußabdruck ist die Commit-Reihenfolge `60e4370` → `83cf01d`. Die Fitness Function sagt **Durchlass** statt Rollen-Achse; deren Träger — die notierte Liste im Emitter — steht als Grenze in den Konsequenzen |
