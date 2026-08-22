# ADR-0021: Die Verbrauchs-Achse je Rolle bleibt ohne Quelle — der Ausfall ist permanent, nicht temporär

**Status:** Proposed

**Datum:** 2026-08-22

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
über leerem Prüfbereich — hier wird **kein** Gate behauptet; die Fitness Function unten nennt einen
vorhandenen Wächter und einen fälligen Fall, das Kriterium steht dort),
[`AGENTS.md`](../../../AGENTS.md) §3.6 (**der tragende Grund** für Festlegung 3: eine Zusage ohne
rot gesehenes Gegenbeispiel ist keine — daran hängt, was ein Span belegen darf und was nicht),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — Festlegung 2 schließt fremden
Inhalt aus dem Log aus und trägt damit Alternative C unten; Festlegung 3 dritter Punkt *„Kein
Beleg-Status"* ist der eine Pol der Rangfrage, die Festlegung 3 unten beantwortet),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — der **Bauplan**: dieselbe
Achse, derselbe Trichter, Option F. Ihre Festlegung 1 — kein Auflösungs-Trigger, kein Folge-Slice —
gilt hier für die zweite Hälfte derselben Lücke),
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) (**Accepted** — Festlegung 3 führt den
Ausfall als Carveout, Festlegung 4 formuliert die Messung und bindet **beide** Ausgänge; ihr
dritter Re-Evaluierungs-Trigger nennt für den negativen Ausgang ausdrücklich den Pfad von
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md)),
[ADR-0020](0020-emittierte-modul-15-regeln.md) (**Accepted** — die **Tool-Ebene ist dort schon
entschieden**: der Carveout ist Vorbedingung des Zähler-Glieds, ausdrücklich **kein**
Auflösungs-Trigger, und sein Maßstab wird dort nicht importiert)

**Schärft:**
[`spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
— die fünf Stellen, die den Ausfall heute mit einem Zeiger auf eine **offene Frage** beschreiben:
den fünften Punkt der Erfassungs-Liste, die **START-KONVENTION**, den Wächter-Absatz zu deren
Bedingung 2, **Abweichung 1** (Cache-Zähler) und **Abweichung 5**. Aufwärts-Deklaration der
Änderungskopplung: wer diese ADR ändert, zieht von hier die betroffenen Spec-Stellen nach.
**Die emittierte Ebene ist nicht berührt, und das ist gemessen, nicht angenommen:**
`git grep -ln 'span-emit\|spawned_role\|pretooluse-agent-guard' -- internal/emit/` → **leer
(Exit 1)**, und `internal/emit/templates/enforce/settings.json` führt genau einen Matcher, `Bash`.
Gegenstand ist der Dogfood dieses Repos.

---

## Kontext

### Was offen war, und was seither gefahren ist

Der Ausfall ist seit dem 2026-08-15 beschrieben und als temporäre Ausnahme geführt
([`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md)): der `Agent`-Span eines Subagenten-Aufrufs
trägt von neun erfassten Werten genau einen, `model_version`. Es fehlen `spawned_role`, die vier
`usage`-Zähler und die drei Summen — das **Kosten-Aggregat des Aufrufs**. Geführt wurde das als
Carveout und nicht als permanente Abweichung, weil **einer** von drei Wegen zurück in unserer Hand
lag: ein `PreToolUse`-Hook setzt `run_in_background: false` per `updatedInput` **nach** dem Modell
in die Tool-Argumente ein. [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 hat
die Messung dazu formuliert und beide Ausgänge gebunden.

**Die Messung ist gefahren, und sie ist negativ.** Sie steht als Zeitdokument in
[`docs/reviews/2026-08-21-updatedinput-messung.md`](../../reviews/2026-08-21-updatedinput-messung.md)
— jede Zahl dort gilt an ihrem Datum. Ihr Ergebnis in einer Zeile: `updatedInput` **wird
übernommen** — beobachtet am statischen Kontroll-`updatedInput`, dessen Marker in der Tool-Zeile
des Bestätigungs-Dialogs erschien —, und ein so übernommenes Eingabeobjekt mit
`"run_in_background": false` erzeugt trotzdem einen **Hintergrund-Start**: das Werkzeug kehrt
sofort zurück, die Sitzung meldet einen Hintergrund-Lauf, und der `Agent`-Span des Laufs trägt
weder `spawned_role` noch einen der vier Zähler.

**Was daran repo-lokal nachzumessen ist, ist hier nachgemessen** (2026-08-22, jede Zahl mit ihrem
Kommando):

- `git grep -ln 'updatedInput' -- . ':!docs' ':!spec'` → **leer (Exit 1)**. Keine ausführbare Datei
  des Baums stellt die Vordergrund-Form her; der Messaufbau war uncommittet und ist zurückgenommen.
  Damit ist die **zweite Hälfte** der Auflösungs-Schwelle von
  [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) — *„und die Mechanik, die ihn erzeugt hat,
  liegt committet im Baum"* — unerfüllt, und zwar **an `git` abzulesen, nicht am Span-Bestand**.
- `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → **sechs Zeilen
  in zwei Dateien** (fünf im Technik-Stratum, eine im Kopf des Guards). Das sind die Zeiger, die
  Folgepflicht 2 von [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) gesetzt hat; sie zeigen
  heute auf eine offene Frage und gehören nachgezogen (Folgepflicht 2 unten).
- `ls docs/plan/carveouts/CO-*.md | wc -l` → **2**. Der eine ist Gegenstand dieser Entscheidung, der
  andere betrifft eine Lint-Ausnahme und teilt mit ihm keinen Geltungsbereich.
- Die Hook-Einträge in `.claude/settings.json` gelesen: der `Agent`-Matcher führt **genau einen**
  Hook, den Guard; die übrigen sind `PreToolUse` auf `Bash`, `PostToolUse`, `PostToolUseFailure`,
  `SubagentStart` und `Stop`. **`SubagentStop` ist nicht verdrahtet** — Annahme (b) unten hat
  deshalb keinen Messwert, sondern eine gelesene Quelle.

**Was dieser Architect-Lauf NICHT nachmessen kann:** das Verhalten des Agenten-Werkzeugs. Ein
Subagent führt das `Agent`-Werkzeug nicht. Die Beobachtung des Zeitdokuments ist hier nicht
wiederholt, sondern **eingeordnet** — dieselbe Grenze, die
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) für ihren eigenen Lauf benannt hat.

### Der Trichter nach Modul 7 — Frage 1 unverändert, Frage 2 kippt

Regelwerk `v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz — Granularität **vor**
Temporalität:

1. **Granularität — einzelne Diskrepanz oder Cluster?** *Einzelne, unverändert.*
   [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) §Kontext hat die Frage für denselben
   Gegenstand beantwortet, und keine ihrer Stützen hat sich bewegt: die Faustregel des Moduls für
   *Cluster* ist der **gemeinsame Geltungsbereich**, keine Carveout-Zahl; die Nachbar-Abweichung aus
   [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) betrifft dieselbe Achse in einem **anderen**
   Geltungsbereich (dort umschließt kein Aufruf den Gegenstand, hier gibt es einen Aufruf samt
   Payload, nur ohne Zähler); und die zwei BF-Symptome liegen nicht vor — der **andere**
   geführte Carveout teilt mit dieser Diskrepanz keinen Geltungsbereich (Messung oben), und sie
   folgt nicht aus dem Muster *„Code existiert vor Doku"*: die Doku ist vollständig, es fehlt eine
   **Quelle**. → Frage 2.
2. **Temporalität — Trigger ernst zu erreichen?** **Nein.** Modul 7: *„Nein („nichts davon werden
   wir in absehbarer Zeit tun") → permanent, übergeführt in eine ADR."*
   [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) hat die Antwort *Ja* auf **einen** Weg
   gestützt — den, der in unserer Hand lag, und der ist gefahren. Es bleiben die zwei Wege im
   fremden Vertrag, die dieselbe ADR schon damals **für sich allein** mit *Nein* beantwortet hat:
   eine **wirksame** Vordergrund-Form des Werkzeugs, und ein Hook-Ereignis, das die Zähler trägt.
   Kein Aufwand dieses Repos bringt eines von beiden herbei.

**Der zweite Ausgang war vorgesehen, nicht improvisiert.**
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) §Auflösungs-Trigger sagt: *„Der zweite
Ausgang gehört in denselben Trigger: fällt die Messung aus Weg 1 negativ aus, bleiben nur die zwei
fremden Wege, und die Antwort auf Modul-7-Frage 2 kippt auf Nein."* Und er sagt, was sonst
entstünde: *„Ein Carveout, der nach einer negativen Messung stehen bliebe, wäre die permanente
Ausnahme, die behauptet, temporär zu sein."*

**Der Folge-Slice-Test dazu.** Modul 7 §Ziel-Form: *„Fehlt der Folge-Slice, ist der Carveout de
facto permanent — dann gehört er nicht in `carveouts/`, sondern über den Trichter unten in eine
ADR."* Der Folge-Slice existierte, hat seinen Gegenstand geliefert und ist damit verbraucht. Ein
**zweiter** hätte den Inhalt *„abwarten"* — das Memo unter anderem Namen
([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Alternative B).

### Woran diese Entscheidung hängt — und woran ausdrücklich nicht

Die tragende Beobachtung des negativen Ausgangs ist am **Span** abgelesen, wie
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 und
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) es anordnen.
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 dritter Punkt sagt dagegen: *„**Kein
Beleg-Status.** Ein Span ist kein Review-Gegenstand und keine Quelle für eine Zusage im Sinne von
AGENTS.md §3.6. Was belegt werden muss, wird gemessen — nicht aus dem Log gelesen."* Beide sind
**Accepted**, beide gelten, und keine kennt die andere. Der Rang gehört in eine **neue** ADR, nicht
in eine Korrektur an einer der zwei ([`AGENTS.md`](../../../AGENTS.md) §3.4) — er steht unten als
Festlegung 3.

Für den Gegenstand hier folgt daraus zuerst die Prüfung, **was ohne die Span-Lektüre trägt**:

- **Das Feld ist im Eingabe-Schema von `Agent` nicht geführt.** Gemessen an der Payload: am
  2026-07-29 trug `tool_input` über vier echte Aufrufe `subagent_type`, `prompt`, `description`
  **und** `run_in_background`; am 2026-08-15 führt das Schema den letzten nicht mehr
  ([`docs/reviews/2026-08-15-agent-guard-tool-vertrag.md`](../../reviews/2026-08-15-agent-guard-tool-vertrag.md)).
  Das ist eine Messung an der Payload, nicht am Span.
- **Vom Aufrufer gesendet wirkt es nicht** (2026-08-15 gemessen: der Aufruf wird angenommen und
  startet dennoch im Hintergrund). **Am Hook eingesetzt ebenso wenig** (2026-08-21) — und der
  **Hintergrund-Start** dieses Laufs ist zweifach beobachtet: an der sofortigen Rückkehr des
  Werkzeugs und an der Hintergrund-Meldung der Sitzung. Der Span sagt dasselbe ein zweites Mal; er
  ist nicht die einzige Stelle, an der es steht.
- **Beide fremden Wege sind unverändert.** Sie waren am 2026-08-15 *Nein* und sind es geblieben;
  nichts an ihnen hängt an dieser Messung.
- **Die zweite Hälfte der Auflösungs-Schwelle ist an `git` unerfüllt** (Messung oben). Sie ist
  span-unabhängig und für sich allein hinreichend dafür, dass
  [`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) **nicht aufzulösen** ist — sie entscheidet
  aber nicht die Trichter-Frage.

**Was ohne die Span-Lektüre NICHT trägt, und das gehört in denselben Satz:** die Aussage, dass ein
eingespeister Schalter **auch die Zähler nicht** zurückbringt. Sie ist die tragende Aussage des
negativen Zweigs, und sie steht auf drei Zeilen eines gitignorierten, maschinenlokalen Bestands
ohne Prüfsumme. Diese ADR wird deshalb **unter benannter Unsicherheit** getroffen — dieselbe
Konstruktion, mit der [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) ihre ungemessene Fläche
geführt hat (*„eine Entscheidung unter benannter Unsicherheit, und die Fläche steht unten als
Re-Evaluierungs-Trigger"*): die Beobachtung steht als **Annahme (d)**, und der dritte
Re-Evaluierungs-Trigger sagt, wer sie umstößt und woran.

### Die Kontroll-Beobachtung ist prinzipiell nicht belegbar — und was daraus folgt

Der teuerste Fehler dieser Messung wäre ein Negativ aus der falschen Ursache: ein verworfenes
`updatedInput` sähe genauso aus wie ein ignoriertes Feld. Die einzige Gegenkraft ist die
Kontroll-Beobachtung — dass die Hook-Ausgabe **übernommen** wurde. Sie ist eine Sicht am Dialog und
an der Fertigmeldung. **Im Repo trägt sie nichts:** der Span führt nach
[ADR-0011](0011-telemetrie-erfassung-policy.md) weder `description` noch Betriebsart; ein
Screenshot ist kein Artefakt dieses Repos; und die einzige Datei, die den ausgeführten Aufruf mit
seiner Eingabe aufzeichnet — das Sitzungs-Transkript —, ist als Quelle **ausgeschlossen**
([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
Abweichung 1: *„der `transcript_path` wird deshalb weder erfasst noch gelesen"*, und Abweichung 6;
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Alternative D;
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Annahme (c)). Die Umkehr ist an diesen
Stellen eine **Erlaubnis des Auftraggebers**, kein Sensor.

**Daraus folgt zweierlei, und das zweite ist das wichtigere.**

1. Diese ADR stellt ihre Entscheidung **nicht** auf die Kontroll-Beobachtung. Sie stellt sie auf
   die Kette oben, in der die Beobachtung als Annahme (d) geführt ist und in der jedes andere Glied
   unabhängig von ihr gilt.
2. **Die Unbelegbarkeit trifft allein den negativen Zweig.** Ein künftiger Lauf, der die Zähler
   trägt, braucht keine Kontroll-Beobachtung — die Zähler **sind** der Beleg, und sie stehen in der
   Payload, nicht in einer Sicht. Die Re-Evaluierung dieser Entscheidung kostet deshalb **eine
   Messung, keine Erlaubnis**: sie ist wiederholbar, ihr positiver Ausgang belegt sich selbst, und
   ihr negativer sagt nur, dass alles bleibt. Nur der vierte Trigger unten hängt an einer Erlaubnis,
   und er öffnet eine **andere** Frage — zuerst eine Sicherheitsfrage.

### Annahmen, auf denen diese ADR steht

Kippt eine, kippt die Entscheidung; alle vier stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Das Agenten-Werkzeug bietet keine **wirksam** anforderbare Vordergrund-Form an — das Feld
  wird angenommen und ändert nichts (2026-08-15 gemessen).
- **(b)** Kein Hook-Ereignis trägt die Zähler. `SubagentStop` trägt `agent_type`,
  `agent_transcript_path` und `last_assistant_message`, **keine** `usage` — der vendored Doku
  entnommen, hier **nicht** gemessen, und dieses Repo hat das Ereignis nicht verdrahtet.
- **(c)** Das Transkript bleibt als Quelle ausgeschlossen — für den Subagenten
  ([ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2: kein Byte fremden Inhalts) wie für
  die Sitzung ([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  §5 Abweichung 1: weder erfasst noch gelesen).
- **(d) — die schwächste, und sie ist neu.** Ein per `updatedInput` **nach** dem Modell eingesetztes
  `run_in_background: false` bringt die Zähler nicht zurück. Abgelesen am Span-Bestand
  (2026-08-21), gestützt auf eine Kontroll-Beobachtung, die im Repo keinen Träger hat. Sie ist eine
  **Annahme im Sinne von Festlegung 3**, kein Beleg.

## Entscheidung

**Wir wählen Option F: der Ausfall ist permanent.** Nicht als Aufschub, sondern als **Grenze**, die
wir mit der Wahl dieser Erfassungs-Mechanik angenommen haben;
[`CO-002`](../carveouts/CO-002-token-achse-je-rolle.md) wird nach Modul 7 in diese ADR übergeführt.
Fünf Festlegungen:

**1. Der Ausfall der Verbrauchs-Achse je Rolle ist permanent — kein Auflösungs-Trigger, kein
Folge-Slice.** Der Geltungsbereich wandert unverändert aus dem Carveout hierher: **acht der neun**
erfassten Werte des `Agent`-Spans — `spawned_role`, die vier `usage`-Zähler (`input_tokens`,
`output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`) und die drei Summen
(`total_tokens`, `total_duration_ms`, `total_tool_use_count`). **Nicht betroffen:**
`model_version`, der neunte Wert, und die **Rollen-Achse** `agent_type`/`agent_role` in allen
übrigen Spans — sie stammt aus der Hook-Payload *innerhalb* des Subagenten, ist von der Betriebsart
unabhängig und trägt weiter. Was ausfällt, ist das **Kosten-Aggregat des Aufrufs**, nicht die
Zuordnung der Arbeit zu einer Rolle. An die Stelle des Triggers tritt die Re-Evaluierung unten: sie
sagt, **wer** diese Entscheidung wieder aufmacht und **woran** er es merkt — und sie behauptet
nicht, dass das jemand tun wird ([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Festlegung 1).

**2. Die Erfassung bleibt unverändert: permanent ist die Abwesenheit der QUELLE, nicht die
Abwesenheit des Schemas.** Die neun Werte bleiben in der Positiv-Liste, und der Emitter nimmt sie,
sobald sie wieder ankommen. Wer sie entfernt, weil heute keine ankommt, macht aus einer fehlenden
Quelle ein fehlendes Feld — und dann ist der Unterschied zwischen *unbekannt* und *nicht vorhanden*
auch dann noch weg, wenn die Zähler zurückkommen. Das ist die Hälfte dieser Entscheidung, die einen
Wächter hat (unten).

**3. Rang zwischen Beleg und Annahme: ein Span belegt keine Zusage, er kann eine Annahme tragen.**
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 dritter Punkt gilt **wörtlich fort**
und wird hier nicht revidiert. Was eine Anordnung wie
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 verlangt, ist etwas anderes als
ein Beleg — eine **Beobachtung** an einem benannten Ablese-Ort. Die Grenze läuft zwischen zwei
Klassen:

- **Zusage** im Sinne von [`AGENTS.md`](../../../AGENTS.md) §3.6 — Doc-Kommentar, Test-Name,
  DoD-Punkt, Commit-Message: **nie** aus einem Span. Sie verlangt ein rot gesehenes Gegenbeispiel;
  ein gitignorierter Bestand ohne Prüfsumme liefert keines.
- **Annahme einer ADR:** aus einem Span zulässig, **wenn** die ADR sie als Annahme führt, den
  Ablese-Ort samt Kommando nennt und einen Re-Evaluierungs-Trigger daran hängt. Eine Annahme ist per
  Konstruktion umstoßbar — genau darin unterscheidet sie sich von einer Zusage.

Wer eine Span-Beobachtung als Beleg ausgibt, verletzt
[ADR-0011](0011-telemetrie-erfassung-policy.md); wer eine ADR-Annahme deshalb gar nicht erst am Span
abliest, verwirft die einzige Beobachtung, die es gibt. Diese ADR nimmt den zweiten Weg und führt
die Beobachtung als Annahme (d). **Der Rang ist damit keine Rangfolge, sondern eine
Klassen-Unterscheidung** — die zwei Stellen widersprechen sich nicht, sobald benannt ist, worüber
jede spricht.

**4. Die Verstetigung des `updatedInput`-Weges fällt aus — die committete Permission-Lage bleibt
unverändert.** [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 hat den Preis
vorher benannt: `updatedInput` wirkt nur mit `"allow"` oder `"ask"`; das erste überspringt für
**jeden** Agenten-Aufruf das Permission-System, das zweite fragt bei jedem nach. Der Gegenstand
dieses Preises ist entfallen — es gibt nichts zu verstetigen. Der committete `Agent`-Matcher führt
weiter genau einen Hook, den Guard, und der entscheidet die **Aufrufform**
([ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 1). **Entschieden ist auch die
Gegenrichtung:** ein Hook, der für `Agent` eine Permission-Entscheidung oder ein `updatedInput`
zurückgibt, kehrt nicht ohne Folge-ADR in den Baum zurück — er wäre eine Änderung an der
Durchsetzung ([`AGENTS.md`](../../../AGENTS.md) §3.5). Ein **uncommitteter** Messaufbau bleibt
davon unberührt; er ist geübte Praxis und war es auch hier.

**5. Der Carveout endet in `done/`, und das Verdikt steht allein hier.** Modul 7 für den ADR-Pfad:
*„ADR: Trigger fällt weg, Checkliste reduziert auf die Architektur-Folgen"*, und der Stub wandert
mit `Status: Permanent — übergeführt in ADR-<NNNN>` nach `done/`, *„damit die Werkzeug-Wahl-Spur im
Repo lesbar bleibt"* — die Nummer ist die dieser Datei. Was von der Verifikations-Checkliste bleibt,
sind die Architektur-Folgen; sie stehen unten als Folgepflichten. **Ein zweiter Ort für das Verdikt
entsteht nicht:** die Stellen, die heute auf den Carveout zeigen, ziehen auf diese ADR
([ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1: *„Ein zweiter Ort driftet"*).

**Was diese ADR NICHT entscheidet** — drei Posten aus derselben Übergabe, mit anderen Eigentümern:
(i) die **Erlaubnis**, das Transkript als Quelle zu öffnen; sie ist nach
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) und
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) eine Auftraggeber-Entscheidung, und sie
betrifft auch die Zahlen, die eine Prüfhandlung bereits committet im Baum abgelegt hat. (ii) ob
[`AGENTS.md`](../../../AGENTS.md) §3.7 §Geltungsbereich verbatim abgelegten **Skript-Text in
Dokumentation** erfasst — eine Hard-Rule-Frage, die einen eigenen Architect-Lauf und nach §3.8 einen
eigenen Commit braucht. (iii) die maschinenlokale, gitignorierte Permission-Datei neben der
committeten; sie gehört dem Auftraggeber. Festlegung 4 bindet den **committeten** Stand, und dass
kein Sensor dieses Repos dessen Verdrahtung prüft, steht unten als Grenze.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**: der Carveout bleibt aktiv | kein Aufwand; der Text ist geschrieben | sein Folge-Slice ist gefahren und hat den **zweiten** Ausgang geliefert; ein Carveout, dessen Trigger nur noch im fremden Vertrag liegt, ist nach `modul-07-carveouts.md` *de facto* permanent und behauptet dabei das Gegenteil. Das Audit je Welle müsste ihn fortan als *„weiterhin aktiv"* bestätigen, ohne dass sich etwas bewegen kann — genau die Doku-Drift, die Carveouts verhindern sollen |
| B — **zweiter Folge-Slice**: dieselbe Messung mit `"allow"` statt `"ask"` | liefe unbeaufsichtigt, ohne Rückfrage in der Sitzung | er misst dieselbe Kette an derselben Stelle. Die **Übernahme** des `updatedInput` ist gerade das, was beobachtet wurde; wirkungslos ist das **Feld**. `"allow"` erkaufte die Wiederholung mit einer Senkung der Durchsetzung ([`AGENTS.md`](../../../AGENTS.md) §3.5) — eine Permission-Änderung, um eine gemessene Wirkungslosigkeit zu bestätigen |
| C — **Träger wechseln**: Rolle aus `SubagentStop`, Zähler aus dem Transkript | das Ereignis trägt die Rolle unabhängig von der Betriebsart | ein Parser über eine Fremddatei mit dem **Prompt** — gegen [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2 (*kein Byte fremden Inhalts*), dort schon als Alternative D verworfen und in [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) als Alternative B. Die Umkehr ist eine Erlaubnis des Auftraggebers, kein Architektur-Schritt |
| D — **Mess-Slice** auf die hier nie vermessenen Ereignis-Payloads | machte aus gelesener Doku eine Messung — *„die Payload ist die Quelle, die Doku ist Herkunft"* | er **löst nichts auf**: er beobachtet den zweiten fremden Weg, er führt ihn nicht herbei. Sein Erwartungswert ist negativ — die vendored Hooks-Referenz nennt ein `usage`-Objekt über ihre ganze Länge nur für die `tool_response` des Agenten-Werkzeugs. Dieselbe Abwägung hat [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) als Alternative C geführt; das Wissen ist unten als Re-Evaluierungs-Trigger aufgehoben, ohne einen WIP-Platz zu belegen |
| E — **BF-Sub-Area-Markierung** statt Carveout oder ADR | kippte den Kontext, in dem die Diskrepanz entsteht, statt sie einzeln zu führen | Trichter-Frage 1 leitet hier nicht dorthin: einzelne Diskrepanz, kein gemeinsamer Geltungsbereich mit einem anderen Carveout, und das Symptom ist **invertiert** — die Doku ist vollständig, es fehlt die Quelle. Eine Modus-Deklaration wirkt eine Ebene höher und hätte hier keinen Gegenstand |
| **F — permanent, als ADR (gewählt)** | der Ausfall hört auf, auf einen Träger zu warten, den es nicht gibt; die Einordnung steht dort, wo Architekturentscheidungen stehen, und die Erfassung bekommt ihren Zahn statt einer Absicht | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../AGENTS.md) §3.4): kommt die Quelle zurück, entsteht eine neue ADR mit *Supersedes*, kein Federstrich. Und sie schließt keine Lücke — sie benennt sie dauerhaft. Mit dem Carveout entfällt zudem die **Wiedervorlage** (unten als Preis) |

## Konsequenzen

- **Positiv:** der Zustand ist entschieden statt aufgeschoben. Wer die fünf Stellen im
  Technik-Stratum liest, findet nach dem Nachzug (Folgepflicht 2) keinen Zeiger mehr auf eine
  offene Frage, sondern das Verdikt.
- **Positiv:** die **Rollen-Achse** der Telemetrie ist nicht betroffen und trägt weiter; betroffen
  ist das Kosten-Aggregat. Die zwei Größen werden leicht für eine gehalten, und die Trennung ist
  der Grund, warum diese Entscheidung nicht die Telemetrie insgesamt betrifft.
- **Positiv:** die Erfassung bleibt bereit und hat dafür einen Wächter — die einzige Hälfte dieser
  Entscheidung, die **überprüfbar** ist.
- **Negativ, und das ist der Preis:** die Token-Bilanz je Rolle hat für Subagenten-Läufe dauerhaft
  keinen Eingang. [`internal/report/report.go`](../../../internal/report/report.go) schreibt
  `Abdeckung: %d von %d Agent-Laeufen trugen Zaehler`, und die erste Zahl bleibt 0. Die Antwort auf
  *„was hat dieser Lauf gekostet?"* fehlt damit für **beide** Kontext-Arten — für den Haupt-Kontext
  nach [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), für Subagenten-Läufe nach dieser ADR.
  Modul 15 §Token-Attributions-Regeln bleibt insoweit **unerfüllt**, als erklärte Abweichung, nicht
  als Erfüllung.
- **Negativ — die Wiedervorlage entfällt mit dem Carveout, und das ist keine Nebenwirkung.**
  [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) hat an die Stelle eines Wächters
  ausdrücklich das `Letzte Prüfung`-Datum des Carveouts und das Audit je Welle gesetzt —
  *„Beobachtung durch Wiedervorlage, nicht durch Sensor"*. Beides endet hier. Was bleibt, sind die
  Re-Evaluierungs-Trigger unten, und die behaupten keinen Termin. Das ist der ehrliche Preis des
  permanenten Pfads: er tauscht eine wiederkehrende Frage gegen eine entschiedene Sache.
- **Grenze, benannt statt geschlossen — kein Sensor prüft die Verdrahtung dieses Repos.** Festlegung
  4 sagt eine **Abwesenheit** in `.claude/settings.json` zu. Über `test/`, `Makefile`,
  `harness/tools/` und die Go-Tests berühren fünf Prüfstellen in drei Dateien diese Datei, und
  **alle fünf** gelten dem **emittierten** Repo
  ([`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5
  Abweichung 5). Für die Verdrahtung **dieses** Repos prüft keine etwas — und eine maschinenlokale,
  gitignorierte Permission-Datei sieht ohnehin kein Sensor und kein `git status`. Träger von
  Festlegung 4 ist der Rollen-Wechsel vor der Änderung, nicht ein Gate danach.
- **Folgepflicht 1 — der Carveout wandert nach `done/`; Implementer.** Modul 7 §Carveout-Audit-Slice
  verteilt das ausdrücklich: *„Architect entscheidet bei „permanent" über die ADR-Überführung,
  Implementer führt `git mv` und Config-Updates aus."* Der Stub trägt den Status aus Festlegung 5,
  ein aktuelles `Letzte Prüfung`-Datum und eine Geschichte-Zeile. **Zwei Commits**, weil Move und
  Inhaltsänderung zusammen die Rename-Detection unterlaufen ([`AGENTS.md`](../../../AGENTS.md)
  §3.3). Das Zielverzeichnis `docs/plan/carveouts/done/` <!-- d-check:ignore (entsteht erst mit dieser Überführung) --> entsteht dabei zum ersten Mal.
- **Folgepflicht 2 — die sechs Zeiger; Spec-Eigentümer und Implementer.** Die fünf Stellen im
  Technik-Stratum sind nach **Eigenschaft** benannt, nicht nach Zeile (im `Schärft`-Kopf oben); sie
  beschreiben den Ausfall heute mit einem Zeiger auf ein Artefakt, das die Frage **stellt**, und
  gehören auf das Verdikt gezogen — samt der Sätze, die eine Messung als noch ausstehend führen. Der
  sechste Zeiger steht im Kopf von
  [`.claude/hooks/pretooluse-agent-guard.sh`](../../../.claude/hooks/pretooluse-agent-guard.sh);
  [`AGENTS.md`](../../../AGENTS.md) §3.7 bindet ihn — ein Kommentar beschreibt, was da ist.
  **Prüfkommando statt Erinnerung:**
  `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` — steht danach
  dort noch ein Zeiger auf ein abgeschlossenes Artefakt, ist der Nachzug unvollständig.
- **Folgepflicht 3 — zwei Zellen des Wellen-Closure; Planner.** Die Matrix-Zellen
  *Token-Attribution × Repo* (Hintergrund-Teil) und *Cache-Counter × Repo* führen nach dieser
  Entscheidung **ADR-Verdikt** statt *deklariert*: der Welle-Plan macht ihren Wert ausdrücklich vom
  Zustand des Carveouts abhängig, und das Vokabular führt *ADR-Verdikt* als eigenen Wert — eine
  Abweichung **ohne** Auflösungs-Trigger, an dessen Stelle die Re-Evaluierungs-Trigger der ADR
  treten. Die Zelle entsteht mit der Ergebnis-Notiz der Welle und bindet erst mit der Annahme hier.
  **Die Tool-Spalte ist nicht berührt** — [ADR-0020](0020-emittierte-modul-15-regeln.md) hat sie
  entschieden und den Maßstab des Carveouts dort ausdrücklich **nicht** importiert.
- **Folgepflicht 4 — das Carveout-Audit verliert einen Gegenstand; Planner.** Von den zwei geführten
  Carveouts bleibt einer. Ein Audit, das weiter zwei prüft, prüft eine Datei in `done/` — und ein
  Closure-Trigger, der beide nennt, ist danach nicht mehr erfüllbar, wie er dasteht.
- **Folgepflicht 5 — der fällige Mutations-Fall; Implementer.** Die Bedingung ist eine
  **Eigenschaft**, keine Adresse: ein Fall in `test/mutations/`, der die Erfassung der
  Ergebnis-Werte für `Agent` entfernt und den Test aus der Fitness Function rot färbt. Ohne ihn ist
  Festlegung 2 eine Absicht. Diese ADR benennt die Bedingung; sie schreibt den Fall nicht.
- **Folgepflicht 6 — die emittierte Ebene bleibt unberührt, und das ist eine Entscheidung.** Sie
  führt heute weder Span-Emitter noch Agent-Guard (im `Schärft`-Kopf gemessen). Bekommt sie je
  einen, gilt diese Grenze dort unverändert — sie ist keine Eigenschaft unseres Aufbaus, sondern der
  Mechanik — und gehört dort **genannt**, nicht stillschweigend mitgeliefert.

## Fitness Function (falls maschinell prüfbar)

**Die Festlegungen sind verschieden prüfbar, und sie zusammenzufassen wäre die Aussage, die zu weit
reicht.** Prüfbar ist genau **eine** — Festlegung 2, die Bereitschaft der Erfassung.

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test — `TestOnlyAgentToolGetsResponseValues` in [`internal/span/response_test.go`](../../../internal/span/response_test.go), §Gegenprobe unter dem gelisteten Namen | Für `tool_name: "Agent"` erfasst der Emitter aus einer Antwort mit `usage`, `totalTokens`, `agentType` und `resolvedModel` weiterhin **alle** diese Werte. Wer die Erfassung entfernt, weil heute keine ankommt, färbt den Test rot | `make test` (in `make gates`) |
| `test/mutations/` — **fällig (Folgepflicht 5), existiert heute nicht** | Die Erfassung der Ergebnis-Werte für `Agent` wird **entfernt**; der Test oben **muss** dabei rot werden. Der vorhandene Fall `test/mutations/133-span-werkzeugachse-geweitet.sh` färbt denselben Test aus der **anderen** Richtung — er weitet die Werkzeug-Achse — und deckt diese Richtung nicht | `make mutate` (nicht in `make gates`; CI pro Push, [`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) |

**Was die zwei Zeilen NICHT leisten.** Sie binden, dass die Erfassung **bereit bleibt** — nicht,
dass je ein Lauf Zähler trägt. Dafür gibt es kein Gegenbeispiel, das rot werden könnte
([`AGENTS.md`](../../../AGENTS.md) §3.6): solange die Zähler in keiner Payload stehen, ist die
Abwesenheit nicht mutierbar.

**Für die Festlegungen 1, 3, 4 und 5 gibt es keinen Wächter, und das ist eine Aussage, kein
Auslassen.** Festlegung 1 entscheidet eine **Abwesenheit der Quelle** — dieselbe Lage wie in
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) Festlegung 1. Festlegung 3 ist eine Urteilsregel
über Text: `make comment-claims` prüft vier Pfad-Muster (`internal/**/*.go`, `cmd/**/*.go`,
`harness/tools/*.sh`, `.claude/hooks/*.sh`) und damit **kein** Markdown, und `make docs-check`
prüft Links, Anker, Kennungen, Matrix, Codepfade und Spans — **keine Behauptungen**. Festlegung 4
sagt eine Abwesenheit in einer Datei zu, die kein Sensor dieses Repos liest (Konsequenzen, §Grenze).
Festlegung 5 ist ein Datei-Zustand, den `git` hält und kein Modul von `.d-check.yml` bewertet. Ihr
Träger ist die Rollen-Trennung vor der Änderung — [`AGENTS.md`](../../../AGENTS.md) §3.4 und §3.5 —,
nicht ein Gate danach. **Und die Wiedervorlage, die bisher an ihre Stelle trat, endet mit dem
Carveout** (Konsequenzen).

## Re-Evaluierungs-Trigger

- **Wenn `Agent` wieder eine WIRKSAME Vordergrund-Form anbietet** *(feedforward — fremder Vertrag,
  kein Sensor; wirkt nur, wenn jemand sie liest)*: **die bloße Annahme des Feldes ist es nicht** —
  die ist gemessen und wirkungslos. Beobachtbar ist der Trigger daran, dass ein so gestarteter Lauf
  **nicht sofort zurückkehrt** und seine `tool_response` die vier Zähler trägt. **Wer es merkt:**
  wer einen Agenten-Aufruf fährt und die Antwort ansieht. Dann fällt Annahme (a).
- **Wenn ein Hook-Ereignis die Zähler trägt** *(feedforward — nur sichtbar, wer das Ereignis
  verdrahtet und seine Schlüsselmenge misst)*: dann fällt Annahme (b), und der Träger wechselt, ohne
  dass die Betriebsart zurückkommen muss. **Wer es merkt:** der Slice, der ein weiteres Ereignis
  verdrahtet — heute verdrahtet dieses Repo `SubagentStop` nicht.
- **Wenn die Messung wiederholt wird und trägt** *(feedback — eine Messung, keine Erlaubnis; sie ist
  einmal gefahren und ist wiederholbar)*: die Beobachtung ist eine **Momentaufnahme** eines fremden
  Vertrags und gilt für die Werkzeug-Fassung, unter der sie lief. **Woran:** derselbe Aufbau, in
  einer **danach gestarteten** Sitzung — die Hook-Liste einer Sitzung wird beim Start eingefroren,
  der Hook-Befehl dagegen bei jedem Feuern frisch von Platte gelesen (Nebenbefund derselben
  Messung). Trägt der so gestartete Lauf die vier
  Zähler und `spawned_role`, fällt Annahme (d), und die Frage nach der Verstetigung samt
  Permission-Folge ist neu zu entscheiden — Festlegung 4 fällt mit ihr. **Der positive Ausgang
  belegt sich selbst** und braucht keine Kontroll-Beobachtung; der negative bestätigt nur den Stand.
- **Wenn die Transkript-Entscheidung kippt** *(feedforward — eine **Erlaubnis des Auftraggebers**,
  kein Sensor)*: dann fällt Annahme (c), und Alternative C ist neu zu bewerten — **zuerst als
  Sicherheitsfrage, dann als Erfassungsfrage**. Dieser Trigger öffnet nicht die Frage dieser ADR,
  sondern eine andere: was aus einer Quelle mit vollem Gesprächsinhalt überhaupt in einen Span darf.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-22 | **Proposed** | Übergabe an den Architect aus dem negativen Ausgang der Messung: [`docs/reviews/2026-08-21-updatedinput-messung.md`](../../reviews/2026-08-21-updatedinput-messung.md) §7/§8. Der Trichter aus Modul 7 ist mit derselben Frage-Reihenfolge gefahren wie in [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md); Frage 2 kippt auf *Nein*, weil der Weg, der sie auf *Ja* stellte, gefahren und negativ ist. Mit in die Übergabe kam der Rang zwischen [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 und [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) Festlegung 4 — er steht als Festlegung 3, nicht als Korrektur an einer der beiden ([`AGENTS.md`](../../../AGENTS.md) §3.4) |
