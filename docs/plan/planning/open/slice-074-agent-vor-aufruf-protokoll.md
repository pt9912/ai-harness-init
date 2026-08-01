# Slice slice-074: Vor-Aufruf-Protokoll auf `Agent` — hat der Hook den Aufruf gesehen?

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Neubau) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) —
Abweichung 5, Prüfschritt 3 (c) benennt diesen Slice als das, was die dort offene Frage
entscheidbar macht (*„ein nur protokollierender zweiter `PreToolUse`-Eintrag … geschnitten
als slice-074, gebaut ist er nicht"*); dasselbe
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
hält das Span-Schema für **geschlossen** und die erfasste Menge auf den *abgeschlossenen*
Aufruf begrenzt — das Protokoll dieses Slice ist deshalb **kein Span** und ändert daran nichts,
§3.
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted**) — Festlegung 2 nennt
den Prompt namentlich als das, was nie ins Log darf, und setzt die Positiv-Liste; der zweite
Erfassungsort übernimmt beides. Ob die Festlegung einen **zweiten** Ort trägt oder ob es dafür
eine eigene Entscheidung braucht, gehört dem Architect (§4) — die ADR bleibt unberührt.
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) —
die Hook-Mechanik dieses Repos, in der der zweite Eintrag verdrahtet wird.
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — der Satz über
den **Tool-Build** im gepinnten Image; das Protokoll bleibt bei `bash` + `awk`, kein `jq`, kein
`node`, und ausdrücklich auch kein gebautes Binär (§6).

**Bewusst KEINE `LH-FA`-Kennung.** Geprüft: die funktionalen Anforderungen betreffen das
**emittierte** Zielprojekt; dieser Slice legt eine Dogfood-Diagnostik an und emittiert nichts
(§3, Abschnitt *Dogfood oder emittiert*). Eine der zwölf hier zu führen, füllte die
`requirement`-Achse falsch — leer und erkennbar schlägt gefüllt und falsch. **Dieser Absatz steht
unterhalb der Leerzeile:** der Bezugs-Block wird bis zur ersten Leerzeile mechanisch gelesen, und
eine Ausschluss-Notiz darin trüge ein, was sie ausschließt.

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-01.

---

## 1. Ziel

**Ein zweiter `PreToolUse`-Eintrag auf `Agent`, der nichts entscheidet, macht am Bestand
entscheidbar, ob der Hook einen Aufruf überhaupt gesehen hat — und eine Auswertungsregel stellt
die Frage von sich aus, statt auf ihr nächstes Auftreten zu warten.**

**Der Anlass, und er ist eingegrenzt, nicht geklärt.** Ein Aufruf unter einem **Rollen**-Typ ist
durchgelaufen, obwohl der Guard aus [slice-060](../in-progress/slice-060-rollen-achse.md)
verdrahtet ist und ihn hätte ablehnen müssen. Drei Beobachtungen grenzen die Ursache ein:

1. **Der Guard scheidet aus.** Die Fassung vor der letzten Änderung lehnt dieselbe Aufrufform mit
   demselben Grund ab, direkt gefahren über den regulären Extraktor-Pfad; eine Sonde mit exakt
   derselben Form wurde abgelehnt. Logik, Extraktor und der fail-closed-Zweig sind damit
   ausgeschlossen.
2. **Die Span-Gestalt passt in keine bekannte.** Der Bestand kennt drei saubere Gestalten eines
   `Agent`-Spans — Hintergrund (Dauer im einstelligen Millisekunden-Bereich, keine Zähler),
   Vordergrund (Dauer in der Größenordnung des ganzen Laufs, Zähler **und** Rolle) und Fehlschlag
   (`status` auf Fehler). Der strittige Span trägt die **Vordergrund-Dauer** bei `status ok`, aber
   **weder Zähler noch Rolle**. **Hier steht bewusst keine Zahl:** der Bestand unter
   `.harness/state/spans/` ist gitignored, maschinenlokal und wächst mit jedem Lauf — eine
   eingefrorene Auszählung wäre beim nächsten Aufruf falsch und auf einem anderen Checkout nicht
   nachvollziehbar. Die unterscheidende Probe gehört **gefahren**: alle `Agent`-Spans auf das Paar
   *Dauer* × *Vorhandensein der Zähler* auszählen; die Gestalt ohne Zähler bei Vordergrund-Dauer
   ist der Gegenstand.
3. **Von innen ist es nicht entscheidbar.** Die `PreToolUse`-Payload wird nirgends protokolliert.
   Ob der Hook lief und seine Entscheidung folgenlos blieb, oder ob er gar nicht feuerte, ist am
   Bestand nicht ablesbar — beide Ursachen erzeugen exakt dieselbe Spur, nämlich keine.

**Was der Slice daraus macht.** Beim nächsten Auftreten ist die Frage sofort entschieden:
**Zeile vorhanden → der Hook lief, seine Entscheidung wurde ignoriert. Keine Zeile → der Hook
feuerte nicht.** Der Slice liefert dafür drei Gegenstände, die alle heute planbar sind — den
Hook, seine Zähne und die Auswertungsregel; **das Warten bildet nicht den Kern** (§3, Abschnitt
*Warum das kein Memo ist*).

**Was er ausdrücklich nicht leistet:** den bereits gelaufenen Aufruf erklären. Für ihn existiert
keine Zeile, und es kann keine mehr entstehen. Der Slice macht das **nächste** Auftreten
entscheidbar, nicht das vergangene.

## 2. Definition of Done

- [ ] **(1) Ein zweiter `PreToolUse`-Eintrag mit `"matcher": "Agent"` protokolliert jeden Aufruf
  und entscheidet nichts.** Er schreibt **vor allem anderen** genau eine Zeile in den
  gitignorierten Zustands-Bereich und endet auf **jedem** Pfad mit **Exit 0 und leerer Ausgabe** —
  auch bei fehlendem `awk`, fehlendem Extraktor und Parse-Zweifel. Kein `permissionDecision`,
  kein `decision`, kein Exit 2, unter keiner Bedingung.

  **Schweigen ist der einzige verbotene Ausgang, und das ist die tragende Zusage dieses Punktes.**
  Der ganze Slice deutet eine Abwesenheit: *keine Zeile* heißt *der Hook feuerte nicht*. Darf der
  Hook aus **eigenen** Gründen schweigen — unlesbare Payload, fehlendes Werkzeug —, hat die
  Abwesenheit zwei Ursachen und die Deutung ist wertlos. Wo der Nachbar-Guard **verweigert**,
  protokolliert dieser mit einem Feld-Wert für *unlesbar* und läuft weiter. Die zwei Hooks stehen
  damit auf **entgegengesetzten** fail-Politiken am selben Ereignis, und beide sind richtig: der
  eine entscheidet und zweifelt zugunsten der Ablehnung, der andere beobachtet und zweifelt
  zugunsten der Aufzeichnung.

  **Der Zahn** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): eine Fixture-Matrix über die
  Fehlpfade — kein `awk`, kein Extraktor, abgeschnittenes JSON, `tool_input` ohne Typ — die je
  **Exit 0, leere Ausgabe und genau eine Zeile** prüft; rot gesehen wird sie über Mutationen, die
  (a) den Hook vor dem Schreiben zurückkehren lassen und (b) ihn auf einem Fehlpfad eine
  Entscheidung ausgeben lassen. Ein Hook, der nichts entscheidet, ist über sein **Ergebnis** nicht
  mutierbar; mutierbar ist sein **Kontrakt**, und der besteht aus genau diesen drei Größen.
- [ ] **(2) Die Zeile trägt ausschließlich Felder fester Form und ist einem `Agent`-Span
  zuordenbar.** Die Feldliste steht mit je einer Incident-Frage im Adaptions-Block von
  [`harness/conventions.md`](../../../../harness/conventions.md) (§3), nicht im Code.
  **Korrelations-Achse ist `tool_use_id`**, mit `session` + Zeitstempel als Rückfall-Achse, falls
  die Messung zeigt, dass das Feld an diesem Ereignis nicht ankommt; ein Rückfall wird **benannt**,
  nicht stillschweigend genommen. **Nie in die Zeile gelangt der Inhalt eines Freitext-Feldes** —
  `prompt`, `description` und jeder ungelistete Schlüssel; ihre **Namen** dürfen, ihre **Werte**
  nicht.

  **Zwei Sorten Zähne, und die zweite ist die tragende.** Namentliche Fälle für `prompt` und
  `description` belegen die **Zusage**; sie unterscheiden eine Positiv-Liste nicht von einer
  Implementierung, die genau diese zwei ausfiltert. Der **Grenz-Zahn** füttert eine Payload, deren
  `tool_input` einen **erfundenen, ungelisteten** Schlüssel mit einer Markierung im Wert trägt, und
  prüft, dass die Markierung die Zeile nicht erreicht. Dazu ein Fall, der die Korrelations-Achse
  aus der Zeile entfernt und die Auswertung aus DoD (3) rot färbt.
- [ ] **(3) Die Auswertungsregel läuft, nennt die Größe ihres Prüfbereichs und steht NICHT in
  `make gates`.** Ein eigenes `make`-Ziel hält den Span-Bestand gegen das Protokoll: **zu jedem
  `Agent`-Span, dessen Zeitstempel hinter der ersten Protokoll-Zeile liegt, muss eine Zeile mit
  derselben `tool_use_id` existieren**; jeder unpaarige Span wird namentlich gemeldet. Der
  **Stichtag ist die erste Zeile des Protokolls selbst** — ältere Spans können konstruktiv keine
  Zeile haben und liegen außerhalb des Prüfbereichs; damit gibt es kein notiertes Datum, das
  altert.

  **Die Gegenrichtung ist KEIN Befund und wird nicht als solcher gemeldet:** eine Zeile ohne Span
  entsteht bei jedem vom Guard abgelehnten, jedem fehlgeschlagenen und jedem noch laufenden Aufruf.
  Wer beide Richtungen gleich behandelt, misst mit einem Muster, das weiter ist als die Frage.

  **Nicht in `make gates`, und das ist eine Messung, keine Bequemlichkeit:** Span-Bestand und
  Protokoll sind gitignored und maschinenlokal. Auf frischem Klon ist der Prüfbereich **leer** —
  ein Gate darüber wäre still grün, genau die
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle.
  Das Ziel meldet deshalb seine Prüfbereichs-Größe in der letzten Zeile (dieselbe Form wie
  `make comment-claims`) und gehört zu den Nicht-Gate-Verifiern neben `make mutate` und
  `make smoke` — **mit benanntem Auslöser** (§3), damit kein zweiter Sensor ohne Trigger entsteht.

  **Der Zahn:** ein Fixture-Paar aus Span-Bestand und Protokoll, in dem ein Span keine Zeile hat →
  das Ziel wird rot; und der leere Prüfbereich → das Ziel meldet **Null** und behauptet kein Grün.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Belegklassen — was gemessen ist und was gelesen

| # | Aussage | Belegklasse |
|---|---|---|
| 1 | `PreToolUse` feuert für `Agent`, und `tool_input` trägt `subagent_type` und `run_in_background` schon **vor** dem Lauf | **gemessen** — [slice-060](../in-progress/slice-060-rollen-achse.md) §3 Zeile 8, an einer echten Sonde mit `"matcher": "Agent"` |
| 2 | `PreToolUse`-Hooks erhalten `tool_name`, `tool_input` **und `tool_use_id`** | **dokumentiert, nicht gemessen** — `docs/user/claude-hooks-referenz.md` §PreToolUse-Eingabe. Die Sonde protokollierte den Wert nicht; damit ist die Korrelations-Achse gelesen und nicht belegt |
| 3 | Der Span führt `tool_use_id` als **Pflichtfeld**, mit der Incident-Frage *„welche Ereignisse gehören zu einem Aufruf?"* | **läuft** — [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Feldtabelle |
| 4 | Dass Vor- und Nachereignis desselben Aufrufs **denselben** Wert tragen | **weder gemessen noch dokumentiert-verglichen** — die Referenz sagt es für die zwei Nach-Ereignisse, für das Paar Vor↔Nach steht es nirgends |
| 5 | Das dokumentierte Eingabe-Schema von `Agent` führt `prompt`, `description`, `subagent_type`, `model` — **kein** `run_in_background`, obwohl die Messung es zeigt | **gelesen + gemessen, und sie widersprechen sich** — der Grund, weshalb der Guard *fehlend* wie *Hintergrund* behandelt |

**Zeile 4 ist die einzige echte Vorbedingung, und sie wird beim ersten Aufruf nach der
Verdrahtung beantwortet — nicht beim nächsten Vorfall.** Der Hook ist seine eigene Sonde: er
schreibt die Kennung, der Emitter schreibt sie in den Span, und der Vergleich ist eine Zeile.
Fällt er negativ aus, tritt die Rückfall-Achse (`session` + Zeitstempel) in Kraft und wird als
**Einschränkung der Zusage** geführt, nicht als stille Ersetzung: eine Zeit-Fenster-Zuordnung ist
schwächer als eine Kennungs-Gleichheit, und wer sie nimmt, schreibt das dazu.

### Was in die Zeile gehört — mit Incident-Frage, sonst gar nicht

| Feld | Incident-Frage | Form |
|---|---|---|
| Zeitstempel | *Wann sah der Hook den Aufruf?* — und die Rückfall-Achse zu Zeile 4 | ISO-8601, UTC |
| `tool_use_id` | *Welchem Span gehört diese Zeile?* — **die** Korrelations-Achse; ohne sie belegt das Protokoll nur, dass irgendwann etwas lief | undurchsichtige Kennung des Werkzeugs, im Zeichensatz gebunden wie der Typname |
| `session` | *Welchem Strom?* — der Span-Bestand liegt je Sitzung und Agent getrennt; ohne sie ist die Rückfall-Achse mehrdeutig | Kennung |
| `subagent_type` | *Welcher Typ wurde angefordert?* — der erste der beiden Werte, aus denen der Guard entscheidet; ohne ihn ist nicht rekonstruierbar, ob eine Rolle startete | roh, aber **durch den bestehenden Extraktor auf `[A-Za-z0-9_:-]+` gebunden**, sonst `?` |
| `run_in_background` | *In welcher Betriebsart?* — der zweite Wert; die Betriebsart ist der Grund, aus dem eine Antwort ohne Zähler zurückkommt | genau drei Werte: `true`, `false`, `ABSENT` |

**Warum der Typname ROH und nicht gegen `.claude/agents/` normalisiert wird** — die naheliegende
Härtung wäre hier die falsche. Eine Normalisierung bildete jeden Wert auf *Rolle* oder *keine
Rolle* ab; genau ein **Beinahe-Treffer** (`Architect` statt `architect`, ein Tippfehler, ein
Namensraum-Präfix) ist aber eine der wenigen Erklärungen dafür, dass ein rollen-aussehender Aufruf
am Guard vorbeikommt — der prüft die **Existenz der Datei** `.claude/agents/<name>.md`. Die
Normalisierung löschte die unterscheidende Information aus der Zeile und ließe genau die Klasse
unsichtbar, deretwegen das Protokoll entsteht. Die Bindung an eine feste Form leistet der
**bestehende** Extraktor, der denselben Wert schon heute zu einem Pfad macht und bei jedem anderen
Zeichen verweigert — der Wert ist damit *durch Konstruktion* von fester Form, nicht durch eine
neue Zusage.

**Geprüft und ABGELEHNT, damit die Liste nicht durch Weglassen entsteht:** `agent_id` — die
Zuordnung läuft über `tool_use_id`, den Strom trägt `session`. `prompt_id` (*„welche Aufrufe
gehören zu einer Nutzer-Anweisung?"*) ist ein ernsthafter Kandidat und bleibt es; ein neues Feld
ist eine Entscheidung und keine Gelegenheit. `cwd`, `permission_mode`, `effort` — keine
Incident-Frage für diese Frage. Und **die Schlüsselnamen von `tool_input` als Menge**: sie sind
erlaubt (Namen, keine Werte) und wären der breitere Griff, den
[`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
Abweichung 5 vorschlägt — die zwei Namen, die etwas entscheiden, stehen aber schon als eigene
Felder da, und der Rest beantwortete keine benannte Frage. Wer die Menge später braucht, trägt sie
mit ihrer Incident-Frage nach.

### Warum das Protokoll KEIN Span ist

- Das Span-Schema ist **geschlossen**, und die erfasste Menge ist ausdrücklich der
  **abgeschlossene** Aufruf. `seq` steigt je Strom monoton mit der Lesart *„fehlt ein Span?"* —
  ein Vor-Aufruf-Satz im selben Strom gäbe jedem `Agent`-Aufruf **zwei** Sätze verschiedener
  Bedeutung und machte diese Lesart falsch.
- [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) sagt
  zugleich, was das Schema **nicht** beantwortet: *„ein vom PreToolUse-Guard geblockter Aufruf
  hinterlässt keinen Span"*. Das Protokoll erfasst ihn, weil es vor der Entscheidung schreibt —
  das ist ein **Nebeneffekt**, den dieser Slice benennt und **nicht** als Zusage führt; eine Zeile
  ohne Span hat mehrere Ursachen (§ DoD (3)).
- Der Emitter ist ein **gebautes Binär** im gitignorierten Zustands-Bereich. Fehlt es, schweigt
  der Hook — und Schweigen ist der einzige Ausgang, den DoD (1) verbietet. `awk` ist POSIX-Basis
  und liegt in derselben Klasse wie der bestehende Guard.

### Wer die Zeilen liest, und wann

- **Ein eigenes `make`-Ziel** ist der Leser; es liest sie **fortlaufend als Rate**, nicht anlässlich
  eines Vorfalls: *wie viele `Agent`-Spans seit dem Stichtag haben keine Vor-Zeile*.
- **Wann es läuft:** an der DoD-Verifikation jedes Slice, der die Hooks oder die Telemetrie
  berührt; an jeder Wellen-Closure; und auf Zuruf, sobald ein `Agent`-Span ohne Zähler auffällt.
  Es steht dazu in der Nicht-Gate-Verify-Liste von [`AGENTS.md`](../../../../AGENTS.md) §4 und
  [`harness/README.md`](../../../../harness/README.md), **mit** seinem Auslöser — ein Sensor ohne
  Auslöser ist der Fehler, aus dem slice-027 entstanden ist.
- **Ein mechanischer Auslöser ist nicht erreichbar, und das gehört hierher statt in eine
  Fußnote:** die CI fährt auf frischem Klon, dort sind Span-Bestand und Protokoll leer. Das Ziel
  liefe grün über einen leeren Prüfbereich. Der Auslöser bleibt darum **prozessual**, und die
  Gegenkraft ist die Prüfbereichs-Zahl in der letzten Zeile: ein Lauf über Null Spans sagt Null
  und behauptet nichts.
- **Zweiter Leser, ohne Abhängigkeit in eine der beiden Richtungen:** die Abdeckungszahl aus
  [slice-066](slice-066-telemetrie-auswertung.md) bekommt mit dem Protokoll eine **zweite**
  Nenner-Quelle neben `SubagentStart`. Keiner der beiden Slices wartet auf den anderen.

### Warum das kein Memo ist

Modul 7 trennt scharf: ein Vorhaben, dessen Kern das **Warten** auf einen Trigger ist, gehört als
Carveout oder ADR geführt — *Slice schlägt Memo*. Hier ist das Warten nicht der Kern:

1. **Der Hook ist heute baubar und heute prüfbar.** Seine ganze DoD (1) hängt an einer
   Fixture-Matrix; kein echter Aufruf ist nötig, um sie rot oder grün zu sehen.
2. **Die einzige Vorbedingung fällt beim ersten Aufruf nach der Verdrahtung** (Belegklassen-Zeile
   4), nicht beim nächsten Vorfall.
3. **Die Auswertungsregel misst eine Rate, keinen Einzelfall.** Sie beantwortet ab dem ersten Tag
   eine Zahl-Frage; ein zweites Auftreten ist für ihr Funktionieren nicht nötig.

Was wirklich wartet, ist allein die **Erklärung** des einen beobachteten Falls — und die ist
ausdrücklich nicht Gegenstand (§1, letzter Absatz).

**Die Auswertungsregel ist zugleich die Kontrolle, und deshalb braucht dieser Slice keine zweite
Verdrahtung.** [slice-060](../in-progress/slice-060-rollen-achse.md) hat gelernt, dass ein stiller
Hook zwei Ursachen hat — *feuert nicht für dieses Werkzeug* und *Konfiguration nicht gelesen* —
und hat dafür damals eine Kontroll-Sonde auf `Bash` mitverdrahtet. Hier leistet das der **Span**:
er entsteht aus derselben Konfigurationsdatei am Nachereignis. Liegt ein `Agent`-Span vor und
fehlt seine Vor-Zeile, liegt der Ausfall im `PreToolUse`-Zweig und nicht darin, dass die Datei
ungelesen blieb. Genau dieser Vergleich **ist** DoD (3).

### Betriebskosten — der Preis, benannt

Ein zweiter Hook läuft bei **jedem** `Agent`-Aufruf: ein zusätzlicher Prozess (`bash` + `awk`) je
Aufruf. Einordnung statt Beteuerung: der Guard läuft schon heute bei jedem `Agent`-Aufruf, der
Span-Emitter bei **jedem Tool-Call überhaupt** — `Agent` ist unter den verdrahteten Ereignissen
das seltenste. Die Zeile misst rund 120 Byte; das Protokoll wächst monoton und wird
**ausdrücklich** geleert, nie nebenbei — dieselbe Disziplin wie beim Span-Bestand
([`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung)
Abweichung 4). Der teure Fall wäre ein Hook, der bei jedem `Bash`-Aufruf schriebe; genau den
schließt der Matcher aus.

### Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1

1. **Bündel?** Nein. Hook, Zahn und Auswertungsregel landen in **einem** Schnitt; kein zweiter
   Slice muss mitlanden, damit die Aussage stimmt.
2. **Gemeinsames Closure-Kriterium?** Nein — eine Welle darum hätte einen Trigger, der die DoD
   abschreibt. **Auch nicht in [welle-09](../welle-09-modul-15-konformitaet.md):** deren Closure
   ist eine 4 × 2-Matrix über vier Regelblöcke × {Repo, Tool}; dieser Slice füllt keine Zelle und
   leert keine — *Erfassung × Repo* tragen slice-059 und
   [slice-060](../in-progress/slice-060-rollen-achse.md). Ihn hineinzuziehen erweiterte den Umfang,
   ohne das Kriterium zu bewegen; §6 jener Welle schließt genau das aus.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv** — ein beobachteter Vorfall, keine neue Fähigkeit.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** die Roadmap bekommt **keinen** Eintrag —
weder jetzt noch beim Abschluss. Der Zustand dieses Slice ist sein Verzeichnis.

### Dogfood oder emittiert — entschieden: NICHT emittiert

Der Grund ist **strukturell**, nicht „später": das Protokoll hat genau einen Leser, und der hält
es gegen den **Span-Bestand**. Ein Ziel-Repo hat heute weder Spans noch den Rollen-Guard; die
emittierte Seite kennt `.claude/agents/` nicht, und die Werkzeug-Ebene der Telemetrie ist gar
nicht entschieden (slice-062). Ein dorthin emittierter Protokoll-Hook schriebe in eine Datei, die
niemand liest — nach Modul 15 das Attribut ohne Incident-Frage, eine Ebene höher. Dazu berührt
neue Mechanik im Ziel den Adopter-Vertrag und bewegt sich nach
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
nur über einen Change Request.

**Auflösungs-Trigger:** entscheidet slice-062, dass ein Ziel-Repo den Span-Emitter bekommt, ist
diese Frage neu zu stellen — dann gäbe es dort einen Leser. Was hier **nicht** behauptet wird: dass
die Frage erledigt sei. Sie ist für den **heutigen** Ziel-Vertrag entschieden.

### Berührte Dateien

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/settings.json` | update | der zweite `PreToolUse`-Eintrag mit `"matcher": "Agent"` aus DoD (1). Beide Hooks laufen; der protokollierende gibt **keine** Entscheidung zurück, die des Guards bleibt damit unberührt |
| `.claude/hooks/` | neu | der protokollierende Hook — Geschwister des Guards, ohne dessen Entscheidungs-Zweig und mit der entgegengesetzten fail-Politik aus DoD (1) |
| `harness/tools/extract-agent-call.awk` | update | **die einzige Stelle, an der dieser Slice geteilten Boden berührt** — additive Erweiterung um `tool_use_id` und `session_id`. Der Guard liest die ersten zwei Ausgabezeilen einzeln adressiert; angehängte Zeilen ändern seinen Kontrakt nicht, und sein Skript bleibt unverändert. Die Alternative wäre ein **zweiter** Scanner mit einer zweiten JSON-Politik, die auseinanderdriftet. Das Netz gegen einen Fehler liegt bereits: `test/agent-guard.bats` und die Mutations-Fälle, die den Guard bzw. den Extraktor als Zieldatei führen (gemessen über den Inhalt der Fälle, nicht über ihre Namen: `grep -l pretooluse-agent-guard test/mutations/*.sh` → **4**, `grep -l extract-agent-call test/mutations/*.sh` → **3**). **Ungedeckt bleibt der Kopfkommentar der Datei** — er sagt heute *„Stdout = GENAU zwei Zeilen"* und wird falsch; `.awk` liegt dauerhaft außerhalb des `comment-claims`-Prüfbereichs, dort trägt allein das Review |
| `harness/tools/` | neu | die Auswertungsregel aus DoD (3) |
| [`Makefile`](../../../../Makefile) | update | das Nicht-Gate-Ziel aus DoD (3) und sein ausdrückliches Aufräum-Pendant. **Nicht** in `gates` |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | ein neuer Eintrag im Adaptions-Block: Feldliste mit Incident-Fragen, die Stichtags-Regel, Leser und Auslöser, die Abgrenzung *kein Span*, die Nicht-Emissions-Entscheidung samt Auflösungs-Trigger. Dazu der Nachtrag in [`MR-018`](../../../../harness/conventions.md#mr-018--span-schema-der-telemetrie-erfassung) Abweichung 5, Prüfschritt 3 (c) — dort steht dieser Eintrag als *nicht gebaut* |
| [`AGENTS.md`](../../../../AGENTS.md) + [`harness/README.md`](../../../../harness/README.md) | update | das neue Ziel in der Nicht-Gate-Verify-Liste, mit seinem Auslöser und der Aussage, warum es nicht in `gates` steht |
| `test/` | neu | die Fixture-Matrix aus DoD (1), die Freitext- und Grenz-Fälle aus DoD (2), die Fixture-Paare aus DoD (3) |
| `test/mutations/` | neu | die Dauer-Sensoren zu allen drei DoD-Punkten |
| `.gitignore` | unverändert | `.harness/state/` ist bereits ignoriert; der Ablageort wird **real** mit `git check-ignore` geprüft, nicht angenommen — dieselbe Linie wie bei `make span-check` |

## 4. Trigger

**`open` → `next`:** der Architect hat entschieden, ob
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) einen **zweiten** Erfassungsort trägt
oder ob dafür eine eigene Entscheidung nötig ist. Die Frage ist echt und nicht rhetorisch: die
ADR setzt ihren fail-closed Default am **Werkzeug-Namen** für die Span-Erfassung; hier entsteht
eine zweite Senke mit eigener Datei, eigenem Format und eigener Politik — die Positiv-Liste
übernimmt sie, aber ob das eine Anwendung oder eine Erweiterung ist, entscheidet nicht der
Planner. Präzedenz ist derselbe Schritt bei
[slice-060](../in-progress/slice-060-rollen-achse.md), wo ein Architect-Verdikt die Grenzen der
Erfassung geprüft und benannt hat. **Kein vierter DoD-Punkt:** die Entscheidung ist Vorbedingung
des Schnitts, keine Zusage des Slice.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die Auswertungsregel aus DoD (3) einen eigenen Prüfbereich, eine
  eigene Stichtags-Verwaltung oder ein eigenes Format verlangt, das sie über die Fixture-Ebene
  hinaus wachsen lässt. Dann trennt ein Re-Schnitt den **Hook** von der **Regel** — der Hook ist
  einzeln lieferbar, die Regel nicht.
- `in-progress` → `open`: falls die Messung zu Belegklassen-Zeile 4 negativ ausfällt **und** die
  Rückfall-Achse die Zuordnung nicht eindeutig macht. Dann ist zuerst zu entscheiden, ob ein
  Protokoll ohne belastbare Korrelation die Frage überhaupt beantwortet — es beantwortete dann
  nur noch *dass* der Hook feuerte, nicht *für welchen Aufruf*.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt
(Modul 11); `make gates` und `make mutate` grün; die Auswertungsregel **einmal über einem echten,
nicht-leeren Bestand gefahren** und ihre Prüfbereichs-Zahl berichtet; `git mv` nach `done/` in
eigenem Move-Commit, eingehende Links im Zug danach; Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Protokoll, das der Hook nicht schreiben KANN, ist stumm — und Stummheit ist genau die
  Beobachtung, die dieser Slice deutet.** Ist der Zustands-Bereich nicht beschreibbar, entsteht
  keine Zeile, und die Deutung *„der Hook feuerte nicht"* ist falsch. Der Hook legt das
  Verzeichnis darum selbst an und blockiert auch dann nicht, wenn das misslingt. **Die
  Rest-Mehrdeutigkeit bleibt und wird nicht wegerklärt:** ein Hook, der feuert und vor dem
  Schreiben stirbt, ist von einem, der nicht feuert, nicht unterscheidbar. Was sie kleiner macht,
  ist die Reihenfolge — die Zeile entsteht **vor** jeder anderen Arbeit des Hooks —, nicht ein
  Beweis.
- **Der Slice erklärt den beobachteten Fall nicht.** Er macht das nächste Auftreten entscheidbar.
  Wer das verwechselt, hält den Slice für gescheitert, weil die alte Frage offen bleibt.
- **Zwei Hooks auf demselben Matcher sind eine Kopplung.** Der protokollierende gibt keine
  Entscheidung zurück, die des Guards steht damit allein — belegt an der dokumentierten
  Vorrangregel (`deny` > `defer` > `ask` > `allow`) und daran, dass ein Hook **ohne** Ausgabe gar
  keine Entscheidung beisteuert. **Gemessen ist das Zusammenspiel zweier Hooks auf einem Matcher
  hier nicht**; es gehört an die DoD-Verifikation, nicht in diesen Plan als Behauptung.
- **Der geteilte Extraktor ist die riskanteste Berührung.** Ein Fehler dort trifft den Guard,
  nicht nur das Protokoll. Die additive Form (angehängte Ausgabezeilen, unveränderte erste zwei)
  und das vorhandene Netz aus bats-Fällen und Mutations-Fällen sind die Gegenkraft; die
  Alternative — ein zweiter Scanner — tauschte ein akutes Risiko gegen ein dauerhaftes.
- **Die Zeile trägt den Typnamen roh.** Das ist eine bewusste Wahl gegen die Normalisierung
  (§3) und sie kostet: der Wert stammt vom Aufrufer. Er ist im Zeichensatz gebunden, aber ein
  Typname, der sich einer Rolle nur **ähnlich** schreibt, fällt hier so wenig auf wie am Guard —
  der ist ein Stolperdraht, keine Sandbox
  ([`ADR-0004`](../../adr/0004-durchsetzungs-emission.md)).
- **Das Ziel aus DoD (3) hat keinen mechanischen Auslöser und kann keinen bekommen** (§3). Es ist
  damit ein Sensor, dessen Lauf an einer Prozess-Regel hängt — schwächer als ein Gate, und der
  Unterschied gehört benannt, nicht überspielt.
- **Nicht in diesem Slice:** die Entscheidung des Guards (sie bleibt, wie
  [slice-060](../in-progress/slice-060-rollen-achse.md) sie gesetzt hat); die veraltete
  Ausgabeform des Nachbar-Guards (slice-067); die Rechnung über die Zähler
  ([slice-066](slice-066-telemetrie-auswertung.md),
  [slice-071](slice-071-cache-zaehler-getrennt.md)); jede Emission ins Ziel (slice-062/063); und
  jede Ausweitung des Span-Schemas.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/`,
`harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
