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
- [x] **(2) Die eine Beobachtung steht mit ihrem Kommando in einem Zeitdokument unter
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
- [x] **(3) Die Übergabe ist ausgestellt, für den Ausgang, der eingetreten ist.** Der Slice endet
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
- [x] `make gates` grün, `make mutate` ohne Befund.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

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
  ([slice-074](../open/slice-074-agent-vor-aufruf-protokoll.md)); die Rechnung über die Zähler
  ([slice-071](../open/slice-071-cache-zaehler-getrennt.md)); jede Änderung an
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) selbst.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Der Weg über `PreToolUse`-`updatedInput` stellt die Vordergrund-Form **nicht** her.
Die Hook-Ausgabe war wohlgeformt und wurde als Entscheidung angenommen, das ersetzte Eingabeobjekt
trug `"run_in_background": false` — und der `Agent`-Span des so gestarteten Laufs führt weder
`spawned_role` noch einen der vier `usage`-Zähler. Das ist der **zweite** der beiden Ausgänge, die
§1 gebunden hat, und er erfüllt die DoD wie der erste: entschieden ist die Frage, nicht
herbeigeführt der Wunsch. Das Gefäß des Ergebnisses ist
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (*Proposed*) — Modul-7-Frage 2
kippt auf *Nein*, [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) wird übergeführt statt
verlängert, und die Verstetigung, die dieser Slice ausdrücklich **nicht** getan hat, fällt dort als
Festlegung 4 ganz aus: es gibt nichts zu verstetigen.

**Zwei beobachtbare Closure-Kriterien.**

1. **Die Messung ist einmal real gefahren, und ihr Beleg hält dem Nachfahren stand.** Das
   Zeitdokument [`docs/reviews/2026-08-21-updatedinput-messung.md`](../../../reviews/2026-08-21-updatedinput-messung.md)
   trägt Sondentext, Fixture, beide Läufe des Gegenbeispiels, den Kontroll-Lauf und den negativen
   Ausgang ohne Abschwächung. Der Closure-Trigger (§5) verlangt *„Review konform (Modul 10) mit
   ausgestelltem Verdikt"*: drei Runden haben je ein Verdikt ausgestellt
   ([Runde 1](../../../reviews/2026-08-22-slice-086-review.md),
   [Runde 2](../../../reviews/2026-08-22-slice-086-bestaetigungsrunde.md),
   [Runde 3](../../../reviews/2026-08-22-slice-086-verdikt-runde.md)), die ersten zwei blockierend,
   die dritte **frei**; die blockierende Menge jeder Runde ist vor dem nächsten Verdikt gezogen.
   Über alle drei Runden hat keine Befund-Klasse ein drittes Mal gefeuert.
2. **Die Verifikation (Modul 11) bestätigt die DoD mit selbst gefahrenen Sensoren.**
   [Report](../../../reviews/2026-08-22-slice-086-verify.md): DoD (2)–(5) bestätigt, DoD (1) in vier
   von fünf Teilzusagen. Der Verifier hat `make gates` **zweimal** und `make mutate` selbst
   gefahren, die fünf Zahlen des Span-Bestands einzeln reproduziert, die drei zitierten Span-Zeilen
   byte-gleich gegengelesen und den Splice aus dem Dokument extrahiert und nachgefahren — bis auf
   die Byte-Zahl `304`, die er nicht übernommen, sondern nachgerechnet hat.

Dazu die Übergabe aus DoD (3): sie ist **eingegangen**, nicht nur ausgestellt —
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) nennt die Messung als ihre
Annahme (d), samt Ablese-Ort und Re-Evaluierungs-Trigger.

**Die eine Teilzusage, die nicht bestätigt ist — und warum der Slice trotzdem schließt.** DoD (1)
sagt zu, *„die Permission-Lage des Repos ist dieselbe wie vorher"*, und bietet als Sensor
`git status` an. Der Sensor kann die Zusage strukturell nicht tragen: die Datei, die die
repo-lokale Permission-Lage führt, ist über eine Ignorier-Regel außerhalb des Repos ausgeblendet
und war nie versioniert (`git check-ignore -v`, `git log --all -- … | wc -l` → 0). Messbar ist
dagegen ihr Inhalt: `"Agent"` — ein pauschales Allow für **jeden** Subagenten-Aufruf — steht als
**letzter** Eintrag der `allow`-Liste, und die Datei wurde in der Sekunde des ersten Mess-Aufrufs
geschrieben. Dass dieser Eintrag aus **diesem** Slice stammt, ist nicht messbar, weil es keinen
Vorher-Stand gibt; genau das ist der Befund. Das DoD-Kästchen (1) bleibt deshalb **offen** — die
Zusage ist breiter als jeder Sensor, den der Slice anbietet. Sie kippt das Messergebnis nicht: ein
`Agent`-Allow erklärt keinen fehlenden Zähler, und der `ask`-Dialog ist im Zeitdokument als
erschienen berichtet. Sie trifft die **Rücknahme**, nicht die **Beobachtung** — und der
Closure-Trigger (§5) bindet die Beobachtung. Die Entscheidung über den Eintrag selbst liegt beim
Auftraggeber und steht unten mit Träger.

**Wo der Liefergegenstand in der Historie liegt.** Das Werkstück ist `31a7908`, seine vier Nachzüge
sind `b875ac0`, `2c2aeff`, `2acd074` und `49d7797`; die drei Verdikte tragen `ec687cb`, `3588e97`,
`74ac235`, die Verifikation `9f0e952`. Die Lifecycle-Commits `6c4c321` (`open → next`) und
`c874ae9` (`next → in-progress`) sind reine Moves, `3f27b7c` ist der Link-Zug danach. Wer den
Slice sucht, findet ihn über zehn Commits verteilt und **nicht** in der Roadmap:
`grep -c 'slice-086' docs/plan/planning/in-progress/roadmap.md` → **0**, wie es
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 verlangt; Setzung 3 lässt auch die Closure spurlos an ihr vorbeigehen. Der Zustand ist
das Verzeichnis.

**Was der Slice nicht deckt.**

- **Die Kontroll-Beobachtung ist mit den Mitteln dieses Repos prinzipiell nicht belegbar.** Kein
  Span trägt sie, ein Screenshot ist kein Artefakt, und die Datei außerhalb, die sie trüge, ist
  als Quelle ausgeschlossen ([`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md)
  Festlegung 2). Das ist eine Eigenschaft des Gegenstands, keine Lücke des Dokuments: jeder weitere
  Träger, auf den ein Beleg geschoben würde, ist entweder leer oder gesperrt. Sie steht im
  Zeitdokument als Grenze und geht mit der Übergabe weiter.
- **Kein Wächter, keine Fixture, kein Gate-Eintrag.** Nichts aus diesem Slice geht in `make gates`
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); die
  Vereinigung seiner Dateien liegt vollständig unter `docs/`. `make gates` und `make mutate` sind
  darum **Belege des Zustands**, nicht Belege über den Liefergegenstand.
- **[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) bewegt er nicht.** Weder Status noch
  `git mv`: der Carveout gehört dem Implementer des Folge-Schnitts, die Entscheidung dem Architect.
  Der Slice liefert die entscheidbare Frage samt Beobachtung, sonst nichts — und hat sich daran
  gehalten (die drei Zeilen, die er in `CO-002` bewegt hat, ersetzen ein Pfadsegment, keine
  Aussage).

**Steering-Loop-Eintrag — geschärfte Regel.**

**Eine DoD-Zusage reicht nur so weit wie der Sensor, den sie selbst benennt. Wer keinen benennen
kann, schreibt die Zusage auf das ein, was der genannte Sensor sieht — oder markiert sie als
sensorlos und nennt ihren Träger.** Eine Zusage, die breiter ist als ihr Sensor, ist im Gate-Bild
unsichtbar: sie ist nicht rot, weil nichts sie prüft.

**Gemessen an diesem Slice, nicht postuliert.** DoD (1) nannte `git status` als Beleg der
Rücknahme. Der Prüfbereich dieses Sensors ist der **getrackte** Baum; die Datei, die die
Permission-Lage trägt, liegt außerhalb davon. Was diese Lücke **nicht** gesehen hat, ist der Punkt:
drei Review-Runden mit neun Befunden über zwei Tage, zwei `make gates`-Läufe (Exit 0), ein
`make mutate` über 143 Fälle (0 Befunde) und ein grüner CI-Lauf über vier Jobs — alle grün, alle
gegen etwas anderes gerichtet. Gefunden hat sie **eine** Rolle, und zwar die, deren Gegenstand
genau der Abgleich *Zusage gegen Ist* ist (Modul 11). Der Slice hat den Sensor nicht falsch
gefahren; er hat eine Zusage geschrieben, für die es keinen gab.

**Anwendung, prüfbar am Text:** Zu jedem DoD-Punkt gehört das Kommando, das ihn rot färben würde
([`AGENTS.md`](../../../../AGENTS.md) §3.6 eine Ebene früher — nicht erst beim Wächter, schon beim
Schnitt). Die Probe ist eine Frage an den eigenen Entwurf: **welcher Prüfbereich deckt diesen
Satz, und liegt der Gegenstand darin?** Fällt die Antwort auf „kein Kommando", ist die Zusage zu
verengen, bis eines existiert — oder sie steht als *ohne Sensor* da, mit benanntem Träger. Beides
ist zulässig; unzulässig ist der dritte Fall, in dem ein vorhandener Sensor genannt wird, der den
Gegenstand nicht sieht.

**Ebene und Träger, benannt statt behauptet.** Die Regel gilt der **Repo**-Ebene, als
Planner-Disziplin beim Schnitt; über den emittierten Harness sagt sie nichts (dort entscheidet der
Slice, der die Tool-Ebene entscheidet, was an DoD-Form mitgeht). **Kein Sensor sieht sie:**
`make comment-claims` prüft vier Pfad-Muster über Go, Shell und Hooks und damit **kein** Markdown,
und `docs-check` prüft Links, Anker, Kennungen, Matrix, Codepfade und Spans — **keine
Behauptungen**. Ihr Träger ist deshalb der nächste Schnitt derselben Hand, und der liegt vor:
[slice-088](../in-progress/slice-088-dcheck-pin-v0620.md) und
[slice-089](../open/slice-089-carveout-co-002-ueberfuehren.md) sind im selben Planner-Lauf
geschnitten, und in beiden trägt **jeder** slice-eigene DoD-Punkt sein Kommando im Text. Ohne
diesen Griff bliebe der Eintrag ein Satz in einer Datei, die niemand wieder liest.

**Drei Beobachtungen, die keine Regel werden — mit ihrem Ort.**

- **Ein Zeitdokument, das seinen Marker verbatim abdruckt, macht die eigene Marker-Suche per
  Konstruktion fündig.** Die Suche, mit der das Dokument seine Nicht-Aufzeichnung belegte, lieferte
  am Bestand einen Treffer: das Dokument selbst. Der Reviewer hat daraus die Klasse *ein Beleg, den
  das Kommando im Dokument nicht (mehr) herstellt* gemacht und sie als Steering-Signal ausgestellt;
  im Dokument ist sie gezogen, indem die Suche den Zitat-Fall am Fundort benennt und trennt. Das
  ist die Lehre eines **Dokument-Typs**, nicht des Schnitts — sie gehört an die Ziel-Form eines
  Zeitdokuments, wenn dieses Repo je eine schreibt.
- **Die Hook-*Liste* einer Sitzung friert beim Session-Start ein; der Hook-*Befehl* wird bei jedem
  Feuern frisch von Platte gelesen.** Ein mid-session verdrahteter Hook feuert in derselben Sitzung
  nicht (Lauf 0), ein geänderter Hook-Text dagegen sofort (Kontroll-Lauf). Jeder künftige
  Messaufbau an `.claude/settings.json` braucht eine **danach** gestartete Sitzung. Steht als
  Nebenbefund im Zeitdokument; hier ohne Träger, weil es keine zweite Stelle gibt, die ihn heute
  bräuchte.
- **Der Eintritts-Move braucht denselben Link-Zug wie der Move nach `done/`.** §5 schreibt ihn nur
  für `done/`; gebraucht wurde er zweimal, weil der Slice durch drei Verzeichnisse gewandert ist
  (`3f27b7c`). Das ist ein Plan-Defekt, kein Implementations-Defekt, und er trifft **jeden**
  wellenlosen Slice dieser Bauart. **Was der Planner daran selbst ändert:** in
  [slice-088](../in-progress/slice-088-dcheck-pin-v0620.md) und
  [slice-089](../open/slice-089-carveout-co-002-ueberfuehren.md) nennt §5 den Link-Zug für **beide**
  Moves samt Prüfkommando.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) steht *Proposed*; erst *Accepted* bindet ihre fünf Festlegungen | Architect, über Review-Runden (Modul 10) mit ausgestelltem Verdikt |
| Die Folgepflichten 1–5 der ADR (Carveout nach `done/`, sechs Zeiger, zwei Matrix-Zellen, Audit-Gegenstand, Mutations-Fall) | [slice-089](../open/slice-089-carveout-co-002-ueberfuehren.md) — geschnitten, Eintritt hängt an *Accepted* |
| `"Agent"` als letzter `allow`-Eintrag der maschinenlokalen Permission-Datei neben der committeten | **Auftraggeber.** [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 4 bindet den **committeten** Stand; die gitignorierte Datei gehört ihm, und kein Sensor dieses Repos liest sie |
| Die drei Transkript-Zahlen, die eine Prüfhandlung committet im Baum abgelegt hat (`3588e97`) | **Auftraggeber** (die Öffnung des Transkripts als Quelle ist seine Erlaubnis) **und Architect** |
| [`AGENTS.md`](../../../../AGENTS.md) §3.7 §Geltungsbereich sagt nichts zu verbatim abgelegtem **Skript-Text in Dokumentation** | **Architect**, eigener Lauf und eigener Commit (§3.8) |
| Der Rang zwischen [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 3 und der Anordnung, am Span abzulesen | in [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 3 als Klassen-Unterscheidung entschieden — erledigt mit deren Annahme, nicht vorher |
| Neun Verweise in fünf Plan-Dateien zeigen auf `in-progress/` und brechen mit dem Move: [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) (3), [slice-088](../in-progress/slice-088-dcheck-pin-v0620.md) (3), [slice-089](../open/slice-089-carveout-co-002-ueberfuehren.md) (1), [welle-09](../welle-09-modul-15-konformitaet.md) (1), [slice-062](../done/slice-062-emittierte-modul-15-regeln.md) (1); dazu **ein** Link im Kopf des Verifikations-Reports — die übrigen sieben Nennungen in den Zeitdokumenten stehen in Inline-Code und fallen unter die `docs/reviews/**`-Ausnahme des `codepaths`-Moduls | der Link-Zug nach dem `git mv` (eigener Commit, Hard Rule 3.3) — `grep -rn 'planning/in-progress/slice-086' --include='*.md' docs` findet sie, `make docs-check` bestätigt den Zug |

**Gates.** Der Verifikations-Lauf auf `2acd074`: `make gates` **Exit 0** —
`baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: 329 Datei(en) geprüft, 0 Befund(e)`,
`1..143` bats ohne `not ok`, `comment-claims: 40 Datei(en) geprueft, 0 Befund(e)`, `span-check`
ok —, `make mutate` **Exit 0** mit `143 ok, 0 Befund(e)`. CI auf demselben Stand grün über vier
Jobs (`gh run view 32554104446` → `"conclusion":"success"`, `headSha` `2acd074…`, je `success` für
`gates`, `smoke`, `full-smoke`, `mutate`). `make full-smoke` hat der Verifier **nicht** selbst
gefahren und das begründet: der Emissions-Pfad ist in diesem Slice unberührt
(`git diff --name-only f93f08d..2acd074 | grep -v '^docs/' | wc -l` → 0), der CI-Beleg trägt
deshalb weiter.

Über diese Notiz selbst — sie ist nach jenen Läufen entstanden — trägt der Doku-Gate:
`make docs-check` → `d-check: 333 Datei(en) geprüft, 0 Befund(e)`, Exit 0 (getrennt erhoben). Der
volle `make gates`-Lauf gehört zum Commit dieser Notiz, nicht zu ihr.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `.claude/hooks/` und
`docs/reviews/` gehören zum Greenfield-Bestand; der Modus steht in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
