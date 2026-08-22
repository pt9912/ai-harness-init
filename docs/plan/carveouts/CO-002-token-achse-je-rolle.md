# CO-002: Der `Agent`-Span trägt keine Token-Achse je Rolle

**Status:** Aktiv.

**Datum angelegt:** 2026-08-15. **Letzte Prüfung:** 2026-08-15 (Anlage — der Ausfall ist am
selben Tag am Span-Bestand gemessen, die Zahlen stehen in
[ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md) §Kontext).

**Betroffenes Gate:** **keines — und das ist die erste Aussage dieses Carveouts.** Betroffen ist
`make span-report`, die Token-Bilanz je Rolle: ein **Bericht**, der ausdrücklich nicht in
`make gates` läuft. Gesenkt ist keine Gate-Schwelle, sondern die **Abdeckung** der Auswertung —
ihre eigene Zeile `Abdeckung: <n> von <m> Agent-Laeufen trugen Zaehler` steht auf `0 von <m>`.
Wer diesen Carveout mit [CO-001](CO-001-bats-shell-lint.md) vergleicht, findet dort eine
Gate-Konfiguration mit Ausnahme, hier eine Auswertung ohne Eingang.

**Geltungsbereich:** **acht der neun** erfassten Werte des `Agent`-Spans — `spawned_role`, die
vier `usage`-Zähler (`input_tokens`, `output_tokens`, `cache_creation_input_tokens`,
`cache_read_input_tokens`) und die drei Summen (`total_tokens`, `total_duration_ms`,
`total_tool_use_count`). **Nicht betroffen:** `model_version` — der neunte Wert, er kommt an — und
die **Rollen-Achse** `agent_type`/`agent_role` in allen übrigen Spans; sie stammt aus der
Hook-Payload *innerhalb* des Subagenten, ist von der Betriebsart unabhängig und trägt weiter
(gemessen am 2026-08-15). Der Ausfall betrifft das **Kosten-Aggregat des Aufrufs**, nicht die
Zuordnung der Arbeit zu einer Rolle.

**Folge-Slice:**
[slice-086](../planning/done/slice-086-vordergrund-per-updatedinput.md) — er fährt die Messung aus
Festlegung 4 von [ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md) und **bindet beide
Ausgänge dieses Carveouts**: hält der Weg, folgt die Entscheidung über seine Verstetigung samt
Permission-Folge in einer Folge-ADR; hält er nicht, kippt die Modul-7-Frage 2 auf *Nein* und der
Carveout ist in eine Folge-ADR zu überführen. Ein negatives Ergebnis ist damit kein Fehlschlag,
sondern der zweite Ausgang. **Der Messaufbau selbst löst diesen Carveout nicht auf** — er wird
nach dem Lauf zurückgenommen; was ihn auflöst, ist **eine** Schwelle, und sie steht unten. Der
Planner hat ihn geschnitten; über beide Ausgänge entscheidet der Architect.

---

## Begründung

**Die Zähler stehen in keiner Payload mehr, die dieses Repo erreichen kann — das ist eine
technische Werkzeuggrenze, kein „noch nicht geschafft".** Sie liegen ausschließlich in der
`tool_response` eines **Vordergrund**-`Agent`-Aufrufs. Der Vordergrund war bis zum 2026-07-29
anforderbar (`run_in_background: false`, an einem echten Aufruf gemessen); am 2026-08-15 ist er es
nicht mehr — **und nicht deshalb, weil der Schalter fehlte:** ein Aufruf **mit** dem Feld wird
angenommen und startet dennoch im Hintergrund (gemessen), und beim Hook kam der Wert nie als
`false` an (2026-08-10 beobachtet). Subagenten starten seit v2.1.198 standardmäßig im
Hintergrund. Ein Hintergrund-Lauf gibt sofort nach dem Start zurück; seine Antwort trägt weder
Zähler noch `agentType`. Die Messreihe steht in
[`docs/reviews/2026-08-15-agent-guard-tool-vertrag.md`](../../reviews/2026-08-15-agent-guard-tool-vertrag.md),
die Entscheidung, die daraus folgt, in
[ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md).

**Ein Ersatz-Träger existiert nicht.** `SubagentStop` trägt die Rolle, aber keine `usage`; die
Zähler eines Hintergrund-Laufs stehen nur noch im Subagenten-Transkript — einer Fremddatei mit
dem Prompt, die [ADR-0011](../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 als Quelle
ausschließt (*kein Byte fremden Inhalts*). Und die Fertigmeldung des Laufs nennt zwar Zahlen,
stellt sie aber in den Kontext des Aufrufers zu, nicht an einen Hook; ein Sensor, der sie liest,
existiert nicht.

**Warum Carveout und nicht permanente Abweichung.** Der Trichter aus Modul 7 (Granularität vor
Temporalität) ist in [ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md) §Kontext
gefahren und dort begründet: einzelne Diskrepanz, und der Trigger ist für **einen** Weg ernst zu
erreichen — die `updatedInput`-Messung liegt in unserer Hand und führt die Bedingung, wenn sie
trägt, selbst herbei, statt auf einen fremden Vertrag zu warten. Genau daran unterscheidet sich
dieser Fall von [ADR-0012](../adr/0012-haupt-kontext-ohne-token-bilanz.md), wo ein Folge-Slice
keinen Gegenstand hätte.

## Auflösungs-Trigger

**Eine Schwelle, beobachtbar am Bestand und nicht an einer Absicht:** ein `Agent`-Span trägt
wieder `spawned_role` **und** alle vier `usage`-Zähler (`input_tokens`, `output_tokens`,
`cache_creation_input_tokens`, `cache_read_input_tokens`) — **und die Mechanik, die ihn erzeugt
hat, liegt committet im Baum**, ist also auf einem anderen Checkout ohne Zusatzwissen
nachzufahren.

**Warum die zweite Hälfte zur Schwelle gehört und keine zweite ist.** Der Weg zurück wird zuerst
in einem **uncommitteten** Messaufbau gefahren, der danach zurückgenommen wird. Sein Span bleibt
im gitignorierten, maschinenlokalen Bestand liegen und erfüllte die erste Hälfte ab da dauerhaft
— während kein Checkout mehr etwas herstellt, was Zähler trägt. Ohne die zweite Hälfte löste
dieser Carveout sich an dem Tag auf, an dem seine Frage **gestellt** wird, statt an dem, an dem
sie beantwortet ist. Beurteilbar ohne Rückfrage bleibt sie: die `Agent`-Zeile lesen, und im Baum
nachsehen, ob die Mechanik, die sie erzeugt hat, dort steht.

**Abgelesen wird das an der `Agent`-Zeile des Span-Bestands selbst, nicht an der Abdeckungszeile
von `make span-report`** — die beiden sind nicht dieselbe Bedingung. Der Bericht zählt einen Lauf
schon als gedeckt, wenn **ein** Zähler gesetzt ist (`internal/report/report.go` kehrt erst zurück,
wenn Eingabe- **und** Ausgabe-Zähler fehlen), und er fragt nach der Rolle gar nicht: ein Span mit
`usage` und leerem `spawned_role` hebt die Abdeckungszahl über 0 und wandert im selben Durchlauf
in den Sammelposten, wo er anteilig nach Tool-Calls **geschätzt** verteilt wird. Die
Abdeckungszeile ist damit ein **notwendiges, kein hinreichendes** Zeichen: steht sie auf 0, ist
der Trigger sicher nicht erreicht; steht sie über 0, ist am Span nachzusehen, ob beide Teile da
sind. Wer nur die Zahl liest, löst diesen Carveout auf, während die Achse *je Rolle* weiter
geschätzt statt gemessen wäre — also genau der Titel offen bliebe.

Drei Wege führen zu diesem Bestand, und sie sind verschieden nah:

1. **Die `updatedInput`-Messung trägt** (der Weg in unserer Hand,
   [slice-086](../planning/done/slice-086-vordergrund-per-updatedinput.md)): ein
   `PreToolUse`-Hook setzt `run_in_background: false` in die Tool-Argumente ein, und der so
   gestartete Lauf liefert die Zähler. **Die Schwelle ist damit noch nicht erreicht** — der
   Messaufbau geht zurück, und erst die Permission-Folge, entschieden in einer Folge-ADR
   (`updatedInput` wirkt nur mit `"allow"` oder `"ask"`), bringt eine committete Mechanik in den
   Baum. Weg 1 ist der einzige der drei, bei dem zwischen Beobachtung und Schwelle noch eine
   Entscheidung liegt; die zwei fremden Wege tragen sie, sobald sie eintreten.
2. **`Agent` bietet wieder eine WIRKSAME Vordergrund-Form an** (fremder Vertrag, kein Sensor; die
   Payload-Fläche wächst belegbar). Dass ein gesendetes Feld **angenommen** wird, ist es nicht —
   das ist gemessen und wirkungslos.
3. **Ein Hook-Ereignis trägt die Zähler** (fremder Vertrag; heute trägt keines sie, gelesen in der
   vendored Doku, nicht gemessen).

**Der zweite Ausgang gehört in denselben Trigger:** fällt die Messung aus Weg 1 negativ aus,
bleiben nur die zwei fremden Wege, und die Antwort auf Modul-7-Frage 2 kippt auf *Nein*. Dann ist
dieser Carveout **in eine Folge-ADR zu überführen** (`Status: Permanent — übergeführt in
ADR-<NNNN>`) und nach `done/` zu verschieben, damit die Werkzeug-Wahl-Spur lesbar bleibt. Ein
Carveout, der nach einer negativen Messung stehen bliebe, wäre die permanente Ausnahme, die
behauptet, temporär zu sein.

## Geltungs-Konfiguration

Es gibt keine Gate-Konfiguration mit einer Ausnahme — der Ausfall liegt im Werkzeug, nicht in
unserer Verdrahtung. Was es gibt, sind die zwei Stellen, an denen er beschrieben wird; beide
tragen den Zeiger auf diesen Carveout (Folgepflichten 1 und 2 der ADR sind an ihnen vollzogen):

| Datei | Zeile/Section | Wert |
|---|---|---|
| `.claude/hooks/pretooluse-agent-guard.sh` | Kopf-Kommentar, Absatz *„DIE BETRIEBSART PRUEFT ER NICHT"* | zeigt auf die Messung im Review-Dokument **und** auf diesen Carveout (*„Gefuehrt wird dieser Ausfall als docs/plan/carveouts/CO-002-token-achse-je-rolle.md — dort stehen Geltungsbereich, Aufloesungs-Trigger und die Messung, die ihn entscheidet"*) |
| `spec/spezifikation.md` | §5 an fünf Stellen: fünfter Punkt der Erfassungs-Liste · START-KONVENTION · Wächter-Absatz · Abweichung 1 (Cache-Zähler) · Abweichung 5 | beschreibt den Stand **nach** `83cf01d` und zeigt an jeder dieser Stellen hierher; die START-KONVENTION führt nur noch Bedingung 1 |

**Die Prüfung dieser Tabelle ist ein Kommando, keine Erinnerung:**
`grep -n "CO-002" .claude/hooks/pretooluse-agent-guard.sh spec/spezifikation.md` — verschwindet ein
Zeiger, ist die Ausnahme an dieser Stelle unbegründet, und die Zeile gehört hier korrigiert statt
im Kopf behalten.

## Verifikation (nach Auflösung)

- [ ] Mindestens ein `Agent`-Span im Bestand trägt `spawned_role` **und** alle vier
      `usage`-Zähler — am Span gelesen, nicht an der Abdeckungszeile —, **und die Mechanik, die
      ihn erzeugt hat, liegt committet im Baum**; `make span-report` steht danebengehalten, seine
      Abdeckungszahl ist dann > 0.
- [ ] Die Erfassungs-Zusagen in `spec/spezifikation.md` §5 sind auf den wiederhergestellten Weg
      nachgezogen — samt der Frage, ob die Vordergrund-Form wieder **erzwungen** wird.
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`). <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-15 | Angelegt — Werkzeug-Wahl nach Modul 7, Ausgang *Carveout* | [ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md) Festlegung 3 |
| 2026-08-15 | Folge-Slice geschnitten; der Trigger wird am Span gelesen, nicht an der Abdeckungszeile; beide Zeiger der Geltungs-Konfiguration stehen | [slice-086](../planning/done/slice-086-vordergrund-per-updatedinput.md) |
| 2026-08-15 | Trigger auf **eine** Schwelle gezogen — der Span **und** die committete Mechanik, die ihn erzeugt; der Span eines zurückgenommenen Messaufbaus erfüllt sie nicht. Die Begründung nennt den gemessenen Grund: der Schalter ist sendbar und wirkungslos | [ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md) §Kontext |
