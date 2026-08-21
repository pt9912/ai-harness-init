# Slice slice-086: Trägt ein per `updatedInput` erzwungener Vordergrund die Zähler?

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktive Messung) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3.

**Bezug:**
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — die Sonde bleibt
`bash` + `awk`; **kein `jq`, kein `node`, kein gebautes Binär**. Das ist hier keine Formalie,
sondern die Größe, die den Bauweg entscheidet (§3, *Splice statt Serialisierung*).
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — dieser
Slice liefert eine **Beobachtung**, keinen Wächter, und behauptet keinen: nichts aus ihm geht in
`make gates` — **auch keine Fixture unter `test/`** (§3, *Berührte Dateien*) —, und die Sonde
bleibt nicht stehen (§2, DoD (1)).
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted**) — Festlegung 2 nennt den
Prompt als das, was nie ins Log darf. Die Sonde reicht ihn durch, und genau deshalb steht die
Nicht-Aufzeichnung als Zusage in DoD (1).
[`ADR-0019`](../../adr/0019-agent-guard-prueft-die-aufrufform.md) — Festlegung 4 formuliert die
Messung dieses Slice und benennt ihren Preis; Festlegung 3 hängt den Werkzeug-Weg des Ausfalls an
sie. Der Slice nennt die Entscheidung; die Entscheidung nennt ihn nicht.
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) — der Carveout, dessen
Auflösungs-Trigger Weg 1 dieser Slice entscheidet. **Beide Ausgänge binden** (§5).

**Autor:** Planner. **Datum:** 2026-08-15.

---

## 1. Ziel

**Es ist am Bestand entschieden, ob ein `PreToolUse`-Hook den Vordergrund eines `Agent`-Aufrufs
herstellen kann — die eine Beobachtung, an der der Weg zurück zur Token-Achse je Rolle hängt.**

Der Aufrufer kann die Betriebsart nicht mehr wählen: das Eingabe-Schema von `Agent` führt
`run_in_background` nicht mehr, und Subagenten starten standardmäßig im Hintergrund. Ein
Hintergrund-Lauf gibt sofort zurück; seine Antwort trägt weder `agentType` noch die vier
`usage`-Zähler, und damit hat die Token-Bilanz je Rolle keinen Eingang. Ein `PreToolUse`-Hook
setzt Tool-Argumente **nach** dem Modell ein — er ist der einzige Weg zurück, der nicht an einem
fremden Vertrag hängt.

**Was der Slice entscheidet, in einer Zeile:** trägt der `Agent`-Span des so gestarteten Laufs
`spawned_role` **und** die vier `usage`-Zähler, hält der Weg; trägt er sie nicht, hält er nicht.

**Was er ausdrücklich NICHT tut: den Weg verstetigen.** `updatedInput` wirkt nur zusammen mit
`"allow"` oder `"ask"`, und beides ändert die Permission-Lage für **jeden** Agenten-Aufruf.
`"allow"` überspränge das Permission-System — eine Senkung der Durchsetzung, die nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 in eine ADR gehört und nicht in einen Messaufbau.
Dieser Slice misst mit `"ask"` und nimmt die Verdrahtung danach zurück (§3). Über die dauerhafte
Form entscheidet eine Folge-ADR, nicht dieser Schnitt.

## 2. Definition of Done

- [ ] **(1) Die Sonde ist gebaut, gefahren und zurückgenommen — und sie hat den Prompt nicht
  angefasst.** Ein `PreToolUse`-Hook mit `"matcher": "Agent"` gibt in `hookSpecificOutput`
  `permissionDecision: "ask"` und `updatedInput` zurück; `updatedInput` ist das **unveränderte**
  Eingabeobjekt plus `"run_in_background": false`. Gebaut in `bash` + `awk`
  ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
  **Nach dem Lauf ist der Arbeitsbaum sauber** — die Verdrahtung in `.claude/settings.json`, die
  Hook-Datei **und die Fixture** sind zurückgenommen, `git status` ist leer und `make gates` grün;
  die Permission-Lage des Repos ist dieselbe wie vorher.

  **Der Prompt wird durchgereicht, nicht gelesen und nirgends festgehalten**
  ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2): die Sonde schreibt
  in **keine** Datei — kein Log, kein Zwischenstand, kein Debug-Auswurf —, ihr einziger Ausgang
  ist stdout an das Werkzeug. Belegt wird das an einer Fixture, deren `prompt` eine Markierung
  trägt: nach einem Sonden-Lauf über diese Fixture findet die Markierung sich in keiner Datei
  unterhalb des Repos wieder.

  **Das Gegenbeispiel läuft in derselben Sitzung, nicht in einem Dauer-Fall**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6): eine Sonden-Variante, die die Markierung in eine
  Datei schreibt, wird von derselben Suche **gefunden** — erst danach zählt der Fund-freie Lauf.
  Beide Läufe stehen mit Kommando und Ergebnis im Zeitdokument aus DoD (2). Ein stehender Fall
  hätte nach der Rücknahme keinen Prüfgegenstand mehr (§3, *Berührte Dateien*).
- [ ] **(2) Die eine Beobachtung steht mit ihrem Kommando in einem Zeitdokument unter
  `docs/reviews/`** — und sie wird **am Span gelesen, nicht an einer Abdeckungszahl.** Geprüft
  wird die `Agent`-Zeile des Laufs im Span-Bestand auf `spawned_role` **und** alle vier Zähler
  (`input_tokens`, `output_tokens`, `cache_creation_input_tokens`, `cache_read_input_tokens`);
  ein Ergebnis, in dem eines von beidem fehlt, ist ein **negativer** Ausgang und wird so notiert.
  Der Bericht aus `make span-report` steht daneben, nicht an ihrer Stelle: er zählt einen Lauf
  schon dann als gedeckt, wenn **ein** Zähler gesetzt ist, und fragt nicht nach der Rolle.

  **Ohne Kontroll-Beobachtung ist der negative Ausgang wertlos, und deshalb hängt sie in
  derselben Zeile:** `"ask"` zeigt die geänderte Eingabe vor der Ausführung an. Erst wenn dort
  `run_in_background: false` steht, ist belegt, dass die Hook-Ausgabe wohlgeformt war und
  übernommen wurde — fehlt sie, misst der Lauf die eigene Sonde und nicht das Werkzeug, und die
  Messung ist zu wiederholen statt zu deuten.
- [ ] **(3) Die Übergabe ist ausgestellt, für den Ausgang, der eingetreten ist.** Der Slice endet
  mit einem benannten Auftrag an den Architect, nicht mit einem Befund:
  - **Positiv** — die wiederhergestellte Vordergrund-Form **und ihre Permission-Folge** gehören in
    eine Folge-ADR; erst danach wird verdrahtet, und erst danach löst sich
    [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) auf.
  - **Negativ** — es bleiben nur die zwei Trigger im fremden Vertrag, Modul-7-Frage 2 kippt auf
    *Nein*, und [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) ist in eine Folge-ADR
    zu überführen. **Das ist kein Fehlschlag dieses Slice, sondern sein zweites Ergebnis.**

  Beide Zweige berühren Artefakte, die dieser Slice nicht schreibt: die ADR gehört dem Architect,
  der Status-Wechsel und der `git mv` des Carveouts dem Implementer. Was der Slice liefert, ist
  die **entscheidbare Frage samt Beobachtung**.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Warum die Sonde uncommittet läuft und wieder verschwindet

Die Verdrahtung eines Hooks mit `permissionDecision` ist eine Aussage über die Durchsetzung. Sie
committet stehen zu lassen, hieße die Entscheidung zu treffen, die dieser Slice gerade **vorbereiten**
soll — und im Fall von `"allow"` wäre es eine Senkung nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5. Die Präzedenz für den uncommitteten Messaufbau steht im
Repo: die Sonden hinter
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) sind im Arbeitsbaum gebaut, gefahren
und zurückgenommen worden, und ihr Ergebnis trägt das Dokument, nicht die Konfiguration.

`"ask"` ist dabei nicht die zurückhaltende, sondern die **messende** Wahl: es senkt nichts und
liefert die Kontroll-Beobachtung aus DoD (2) frei Haus, weil es die geänderte Eingabe vor der
Ausführung sichtbar macht. `"allow"` liefert sie nicht.

### Splice statt Serialisierung — die Größe, an der der Bauweg hängt

`updatedInput` ersetzt das **gesamte** Eingabeobjekt; unveränderte Felder müssen mit zurück. Zwei
Bauwege, und nur einer ist unter
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) bezahlbar:

| Weg | Was er verlangt | Urteil |
|---|---|---|
| **Splice (vorgesehen)** | den Byte-Bereich von `tool_input` aus der Payload unverändert übernehmen und vor der schließenden Klammer `,"run_in_background":false` einfügen | kein JSON-Encoder, keine Kenntnis der Feldinhalte; der Prompt wird als Bytes durchgereicht und nie interpretiert — das ist zugleich die Mechanik hinter der Zusage aus DoD (1) |
| Parsen und neu ausgeben | ein JSON-Encoder in `awk` — Escapes, Unicode, eingebettete Zeilenumbrüche im `prompt` | fällt an [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); ein halber Encoder ist schlimmer als keiner, weil er still falsch kodiert |

**Die offene technische Frage ist der Splice selbst, nicht die Messung:** den Bereich von
`tool_input` ohne Parser zu finden, ist die eigentliche Arbeit.
[`harness/tools/extract-agent-call.awk`](../../../../harness/tools/extract-agent-call.awk) ist der
Präzedenzfall und zugleich die Grenze — er liest zwei **Werte** heraus, er gibt kein **Objekt**
zurück. Fällt der Splice nicht in einer Sitzung, greift die Rückführung aus §4; die Antwort darauf
ist nicht „dann eben `jq`".

### Was gemessen wird, und wo es abzulesen ist

Der Emitter nimmt `spawned_role` aus `agentType` der `tool_response` und die vier Zähler aus deren
`usage`-Objekt ([`internal/span/response.go`](../../../../internal/span/response.go)). Gelesen wird
deshalb die `Agent`-Zeile des Laufs im Span-Bestand unter `.harness/state/spans/` — gitignored,
maschinenlokal, wächst mit jedem Lauf. **Hier steht bewusst keine Zahl:** eine eingefrorene
Auszählung wäre beim nächsten Aufruf falsch und auf einem anderen Checkout nicht nachvollziehbar.
Das Zeitdokument aus DoD (2) trägt Kommando, Datum und Ergebnis.

### Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1

1. **Bündel?** Nein. Sonde, Beobachtung und Übergabe landen in **einem** Schnitt; kein zweiter
   Slice muss mitlanden, damit die Aussage stimmt. Die Folge-ADR ist keine Mitlandung, sondern der
   Adressat der Übergabe — sie setzt das Ergebnis voraus, statt es zu teilen.
2. **Gemeinsames Closure-Kriterium?** Nein — eine Welle darum hätte einen Trigger, der die DoD
   abschreibt. **Auch nicht in [welle-09](../welle-09-modul-15-konformitaet.md):** deren Closure
   ist eine 4 × 2-Matrix, und die Zelle *Token-Attribution × Repo* trägt für den Hintergrund-Teil
   bereits den Wert *deklariert* — Geltungsbereich, Begründung und Auflösungs-Trigger stehen in
   [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md). Dieser Slice füllt die Zelle nicht
   und leert sie nicht; er entscheidet später, ob ihr Wert auf *Sensor* oder auf *ADR-Verdikt*
   wechselt, und beide sind für jene Welle zulässig. **Auch nicht in
   [welle-10](../welle-10-re-baseline.md):** deren Closure sind die drei Durchgänge der
   Migrations-Prozedur und der Pin; dieser Slice trägt zu keinem davon bei, und er hängt nicht am
   getauschten Baum — er nennt den vendored Pfad an keiner Stelle und wird von jener Welle damit
   nicht blockiert.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv.** Der Auslöser ist ein fremder Vertrag, der sich
   unter dem Repo geändert hat, und ein Bericht, dessen Abdeckungszeile daraufhin auf 0 steht —
   kein Wunsch nach einer neuen Fähigkeit. Wiederhergestellt würde eine Zusage, die schon einmal
   getragen hat.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** die Roadmap bekommt **keinen** Eintrag —
weder jetzt noch beim Abschluss. Der Zustand dieses Slice ist sein Verzeichnis.

### Dogfood oder emittiert — entschieden: NICHT emittiert

Die emittierte Ebene führt heute keinen Agent-Guard und keinen Span-Emitter —
`internal/emit/templates/enforce/` legt Command-Guard, Stop-Hook, Gate-Nachweis und die
[`settings.json`](../../../../internal/emit/templates/enforce/settings.json) des Ziels ab, sonst
nichts; ein dort abgelegter Sonden-Hook schriebe in eine Auswertung, die es nicht gibt. Der Gegenstand ist der
Dogfood dieses Repos. **Auflösungs-Trigger:** entscheidet slice-062, dass ein Ziel-Repo den
Span-Emitter bekommt, ist die Frage neu zu stellen — dann gäbe es dort einen Leser.

### Berührte Dateien

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.claude/hooks/` | **temporär**, nicht committet | die Sonde aus DoD (1); sie verschwindet mit dem Lauf, ihr Text steht im Zeitdokument aus DoD (2) und ist von dort reproduzierbar |
| `.claude/settings.json` | **temporär**, nicht committet | der dritte `PreToolUse`-Eintrag für die Dauer der Messung. Der bestehende Agent-Guard läuft weiter und schweigt im Pass-Fall; die Vorrangregel (`deny` > `defer` > `ask` > `allow`) lässt die `ask`-Entscheidung der Sonde stehen |
| `docs/reviews/<datum>-updatedinput-messung.md` | neu | das Zeitdokument aus DoD (2) — Kommando, Kontroll-Beobachtung, Ergebnis, Sondentext. Zeitdokument: jede Zahl gilt an ihrem Datum |
| die Fixture aus DoD (1), **neben der Sonde** | **temporär**, nicht committet — und **nicht** unter `test/` | `make test-bats` fährt `bats test/` über das **ganze** Verzeichnis; jede dort abgelegte Datei liefe damit in `make test` und in `make gates` — der Zusage aus dem Bezugs-Block genau entgegen. Dazu verschwindet ihr Prüfgegenstand nach DoD (1) planmäßig: ein stehender Fall wäre danach rot oder vakuös grün, und `make mutate` hätte für ihn keinen Fall. Die Fixture teilt deshalb die Lebensdauer der Sonde; ihr Text, das Kommando und beide Läufe des Gegenbeispiels stehen im Zeitdokument aus DoD (2) und sind von dort reproduzierbar |
| `Makefile`, `.d-check.yml`, `spec/`, `test/` | **unverändert** | kein Gate, keine Zusage, keine Spec-Festlegung — eine Beobachtung ist nichts davon ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |

## 4. Trigger

**`open` → `next`:** [`ADR-0019`](../../adr/0019-agent-guard-prueft-die-aufrufform.md) ist
*Accepted*. Vorher steht die Festlegung, die diesen Slice beauftragt, noch zur Debatte — und die
Rollen-Agenten sind ohnehin erst seit der Senkung startbar, die sie begründet.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls der Splice aus §3 nicht in einer Sitzung fällt. Dann trennt ein
  Re-Schnitt die **Extraktion des `tool_input`-Bereichs** von der **Messung**; die Extraktion ist
  einzeln lieferbar und prüfbar (Fixtures rein, Bytes raus), die Messung nicht.
- `in-progress` → `open`: falls sich zeigt, dass ein wohlgeformtes `updatedInput` in `bash` + `awk`
  **nicht** herstellbar ist. Das ist keine Implementierungs-Frage mehr, sondern eine an
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): der dritte Weg
  liegt dann nicht mehr in unserer Hand, und Modul-7-Frage 2 ist mit demselben Ergebnis wie beim
  negativen Ausgang neu zu stellen. Der Slice geht dann mit **dieser** Frage an den Architect
  zurück, nicht mit einem Werkzeug-Wunsch.

## 5. Closure-Trigger

DoD vollständig; die Messung **einmal real gefahren** und ihre Kontroll-Beobachtung berichtet;
Review konform (Modul 10) mit ausgestelltem Verdikt; `make gates` und `make mutate` grün; die
Übergabe aus DoD (3) beim Architect eingegangen; `git mv` nach `done/` in eigenem Move-Commit,
eingehende Links im Zug danach; Closure-Notiz mit Steering-Loop-Eintrag.

**Der Slice schließt bei beiden Ausgängen.** Ein negatives Ergebnis erfüllt seine DoD ebenso wie
ein positives — was ihn offen hält, ist eine **unentschiedene** Beobachtung (fehlende
Kontroll-Beobachtung, unklarer Span), nicht eine unwillkommene.

## 6. Risiken und offene Punkte

- **Ein negativer Ausgang aus der falschen Ursache ist der teuerste Fehler dieses Slice.** Bleibt
  die Hook-Ausgabe unwohlgeformt oder wird sie verworfen, sieht das Ergebnis exakt aus wie ein
  Werkzeug, das das eingespeiste Feld ignoriert — und die Antwort auf Modul-7-Frage 2 kippte auf
  Grund einer Eigenschaft der Sonde. Die Kontroll-Beobachtung aus DoD (2) ist die einzige
  Gegenkraft; ohne sie wird nicht gedeutet.
- **Die Messung ist eine Momentaufnahme eines fremden Vertrags.** Sie gilt an ihrem Datum und für
  die Werkzeug-Fassung, unter der sie lief. Ein positiver Ausgang belegt, dass der Weg **heute**
  trägt — die Frage, ob er morgen trägt, entscheidet die Folge-ADR mit ihrem
  Re-Evaluierungs-Trigger, nicht dieser Slice.
- **`"ask"` unterbricht.** Die Messung braucht eine Sitzung, in der jemand die Rückfrage
  beantwortet; unbeaufsichtigt läuft sie nicht. Das ist ein Preis der Wahl, kein Defekt — die
  Alternative `"allow"` erkaufte die Unbeaufsichtigtheit mit einer Senkung.
- **Zwei Hooks auf demselben Matcher sind eine Kopplung.** Der Agent-Guard entscheidet die
  Aufrufform und schweigt im Pass-Fall; die Sonde entscheidet die Permission-Frage. Dass sie sich
  nicht in die Quere kommen, folgt aus der dokumentierten Vorrangregel und ist an dieser Stelle
  **gelesen, nicht gemessen** — es gehört an die DoD-Verifikation.
- **Nicht in diesem Slice:** die Verstetigung des Weges und ihre Permission-Folge (Folge-ADR); das
  Vor-Aufruf-Protokoll und die protokollierende Rollen-Frage
  ([slice-074](slice-074-agent-vor-aufruf-protokoll.md)); die Rechnung über die Zähler
  ([slice-071](slice-071-cache-zaehler-getrennt.md)); jede Änderung an
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) selbst.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/hooks/` und
`docs/reviews/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
