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

**Folge-Slice:** noch nicht geschnitten — fällig als **Folgepflicht 3** von
[ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md); Gegenstand ist die
`updatedInput`-Messung aus deren Festlegung 4. Solange er nicht in `docs/plan/planning/` liegt,
ist dieser Carveout nach Modul 7 *de facto* permanent und gehört in eine ADR statt hierher. Der
Planner schneidet ihn; über den negativen Ausgang entscheidet der Architect.

---

## Begründung

**Die Zähler stehen in keiner Payload mehr, die dieses Repo erreichen kann — das ist eine
technische Werkzeuggrenze, kein „noch nicht geschafft".** Sie liegen ausschließlich in der
`tool_response` eines **Vordergrund**-`Agent`-Aufrufs. Der Vordergrund war bis zum 2026-07-29
anforderbar (`run_in_background: false`, an einem echten Aufruf gemessen); am 2026-08-15 führt das
Eingabe-Schema von `Agent` das Feld nicht mehr und lässt keine zusätzlichen Felder zu, und
Subagenten starten seit v2.1.198 standardmäßig im Hintergrund. Ein Hintergrund-Lauf gibt sofort
nach dem Start zurück; seine Antwort trägt weder Zähler noch `agentType`. Die Messreihe steht in
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

**Beobachtbar am Bestand, nicht an einer Absicht:** ein `Agent`-Span trägt wieder `spawned_role`
und die vier `usage`-Zähler — ablesbar an `make span-report`, dessen Abdeckungszeile dann eine
Zahl größer 0 führt. Drei Wege führen dorthin, und sie sind verschieden nah:

1. **Die `updatedInput`-Messung trägt** (der Weg in unserer Hand, Folgepflicht 3 der ADR): ein
   `PreToolUse`-Hook setzt `run_in_background: false` in die Tool-Argumente ein, und der so
   gestartete Lauf liefert die Zähler. Dann ist zusätzlich die Permission-Folge zu entscheiden
   (`updatedInput` wirkt nur mit `"allow"` oder `"ask"`) — eine Folge-ADR, kein Federstrich.
2. **Das Eingabe-Schema von `Agent` bietet wieder eine Vordergrund-Form an** (fremder Vertrag,
   kein Sensor; die Payload-Fläche wächst belegbar).
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
tragen den Zeiger auf diesen Carveout **noch nicht** (Folgepflichten 1 und 2 der ADR):

| Datei | Zeile/Section | Wert |
|---|---|---|
| `.claude/hooks/pretooluse-agent-guard.sh` | Kopf-Kommentar, Absatz *„DIE BETRIEBSART PRUEFT ER NICHT"* | zeigt auf die Messung im Review-Dokument; ein `CO-002`-Zeiger fehlt |
| `spec/spezifikation.md` | §5, Abweichung 5 samt START-KONVENTION und Wächter-Absatz | beschreibt den Stand vor `83cf01d`; Nachzug samt `CO-002`-Zeiger steht aus |

## Verifikation (nach Auflösung)

- [ ] `make span-report` weist für mindestens einen `Agent`-Lauf Zähler aus (Abdeckungszeile > 0).
- [ ] Die Erfassungs-Zusagen in `spec/spezifikation.md` §5 sind auf den wiederhergestellten Weg
      nachgezogen — samt der Frage, ob die Vordergrund-Form wieder **erzwungen** wird.
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`). <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
- [ ] Folge-Slice geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-15 | Angelegt — Werkzeug-Wahl nach Modul 7, Ausgang *Carveout* | [ADR-0019](../adr/0019-agent-guard-prueft-die-aufrufform.md) Festlegung 3 |
