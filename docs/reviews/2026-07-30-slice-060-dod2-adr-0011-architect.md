# Architect-Verdikt: slice-060 DoD (2) gegen ADR-0011 Festlegung 2

**Rolle:** Architect (Modul 8). **Datum:** 2026-07-30. **Autor:** ai-harness-init-Team (pt9912).

**Gegenstand:** `docs/plan/planning/in-progress/slice-060-rollen-achse.md` DoD (2) —
`Agent` wird ein namentlich gelistetes Werkzeug mit Positiv-Liste über `tool_response`.

**Prüfgegenstand:** `docs/plan/adr/0011-telemetrie-erfassung-policy.md` (Status **Accepted**,
`0011-telemetrie-erfassung-policy.md:3`), Festlegung 1 und 2, Konsequenzen, Folgepflicht 1,
Re-Evaluierungs-Trigger.

---

## 1. Das Verdikt

**Innerhalb Festlegung 2 — kein Folge-ADR nötig: die ADR entscheidet den *Mechanismus* des
fail-closed Defaults (Achse = Werkzeug-Name) und delegiert die *namentliche Liste* samt Feldtabelle
ausdrücklich an `MR-018`; DoD (2) bewegt nur die delegierten Artefakte und lässt jeden Satz der
Festlegung unberührt.**

Das gilt **unter fünf prüfbaren Bedingungen** (§6). Wird eine davon gebrochen, kippt das Verdikt —
nicht weil dann eine andere ADR-Lesart gilt, sondern weil DoD (2) dann etwas anderes täte als das,
was hier geprüft wurde.

## 2. Abgrenzung: warum das nicht die Arbeit des Reviewers doppelt

Modul 8 (`.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md:75-78`): Mehrfachzuweisung
ist nur sauber, wenn jede Rolle einen **anderen Eingabe-Kontext** hat.

Der Reviewer hat dieselbe Frage am **Plan** entschieden und kam zum gleichen Ergebnis
(`docs/reviews/2026-07-29-slice-060-066-plan-review.md:385-388` und `:510-513`: *„das **Listen** von
`Agent` ist ADR-konform … Eine Supersedes-ADR ist **nicht** nötig"*). Mein Eingabe-Kontext ist ein
anderer: der **Code** (`internal/span/`), die **Wächter** (`test/mutations/`), der **reale
Span-Bestand** und Modul 15. Was dadurch neu ist und im Plan-Review nicht steht, sind vier Dinge:

- der **gemessene** Beleg, dass der Default-Zeile die Argument-Achse gehört (§4.1) — bisher eine
  Lesart, jetzt eine Messung am Bestand;
- der Befund, dass die Hypothese des Auftraggebers nur **halb** trägt, weil `tool_response` selbst
  vier Freitext-Felder führt, `content` darunter (§5);
- `resolvedModel` als der **einzige** Rohstring unter den neun Werten und damit die eigentliche
  Grenze (§6, B5);
- zwei **Zählfehler** und zwei **Fehlzitate** im Bestand (§7).

Die ADR selbst wird nicht angefasst; ich habe kein `Edit` und §3.4 verbietet es ohnehin.

## 3. Die drei Fragen, die entschieden werden mussten

| # | Frage | Antwort |
|---|---|---|
| A | Welche **Achse** regelt die Default-Zeile von Festlegung 2 — Argumente (`tool_input`) oder den ganzen Span? | **Argumente.** Gemessen, nicht gelesen (§4.1) |
| B | Trägt die Delegation aus Festlegung 1 auch die **Werkzeug**-Tabelle oder nur die Feldtabelle? | **Beide** — der Wortlaut delegiert die Feldtabelle, die Default-Zeile delegiert die Namens-Abbildung, und die Konsequenzen nennen die namentliche Aufnahme als *laufende Pflege* (§4.2) |
| C | Beschreibt ein **Re-Evaluierungs-Trigger** genau diese Situation? | **Zwei tun es — und beide sind vorentschieden zugunsten von DoD (2)** (§4.3) |

## 4. Die tragenden Fundstellen, verbatim

### 4.1 Frage A — die Default-Zeile regelt die Argument-Achse (gemessen)

Der Titel von Festlegung 2 nennt seinen Gegenstand
(`docs/plan/adr/0011-telemetrie-erfassung-policy.md:100-102`):

> **Festlegung 2 — Argument-Werte werden ABGELEITET erfasst, und die Schärfe ist je Ebene
> verschieden.** „Redigiert" im Sinne von Modul 15 heißt nicht *weggelassen*, sondern *abgeleitet
> statt roh*. Je Werkzeug wird erfasst, was die Incident-Frage beantwortet — nicht der Rohwert:

Die Default-Zeile, um die es geht (`…0011-telemetrie-erfassung-policy.md:109`, gekürzt an den
tragenden Stellen — die Zeile ist eine Tabellenzelle):

> | **jedes andere, auch künftige** | *welches Werkzeug lief, mit welchem Ausgang?* | **nur** Name
> und Status — **keine** Argumente. Der Default entscheidet über den **Werkzeug-NAMEN**, nicht über
> eine Gattung: die Zeilen oben sind auf konkrete Namen abzubilden, und was nicht namentlich
> gelistet ist, fällt hierher … Betrifft **heute** u. a. das Agenten-Werkzeug mit seinem
> **Freitext-Prompt** — ausgerechnet das, auf dessen Subagenten-Hooks die Rollen-Achse beruht

**Zwei Wörter dieser Zelle sind tragend, und beide zeigen in dieselbe Richtung:** *„keine
**Argumente**"* benennt die Achse; *„Betrifft **heute**"* markiert die `Agent`-Zuordnung als
Momentaufnahme, nicht als Zuweisung auf Dauer. Der genannte **Grund** ist der Freitext-**Prompt** —
und `prompt` liegt in `tool_input` (`slice-060-rollen-achse.md:175`, Messzeile 5).

**Der Beweis, dass „nur Name und Status" nicht den ganzen Span meint, ist eine Messung, keine
Lesart.** Ein heute geschriebener `Agent`-Span — `Agent` sitzt auf der Default-Zeile — trägt
**18** Felder. Gemessen am realen Bestand (2026-07-30, jüngster `Agent`-Span in
`.harness/state/spans/`; Schlüssel, keine Werte):

```
seq ts event tool tool_use_id session agent agent_type agent_role slice requirement adr
branch commit status permission_mode duration_ms result_bytes
```

Darunter `result_bytes` — abgeleitet **aus `tool_response`**
(`internal/span/span.go:101-103`) — und `duration_ms`, beide **unbedingt für jedes Werkzeug**
gesetzt (`internal/span/emit.go:114-121`, kein `toolClass`-Zweig davor). Läse man die Default-Zeile
als Aussage über den ganzen Span, wäre `MR-018` **seit dem Accepted-Tag** für *jedes* Werkzeug
regelwidrig — und die `Bash`-Zeile („erstes Token + Argument-Anzahl") hieße, ein `Bash`-Span trage
kein `seq` und kein `ts`. Diese Lesart ist nicht haltbar.

`MR-018` schreibt die Achse deshalb in die Spaltenüberschrift seiner Werkzeug-Tabelle
(`harness/conventions.md:877`):

> | Werkzeug-Name | erfasst zusätzlich zu Name und Status |

**Der Code hält dieselbe Trennung strukturell.** `Agent` fällt heute in `classNone`
(`internal/span/span.go:159-176`), und der Eingabe-Pfad kann die Freitext-Felder von `Agent` gar
nicht sehen — `ToolInput` führt genau drei Felder (`internal/span/span.go:61-65`):

```go
type ToolInput struct {
	FilePath     string `json:"file_path"`
	NotebookPath string `json:"notebook_path"`
	Command      string `json:"command"`
}
```

`subagent_type`, `prompt`, `description`, `run_in_background` sind hier **nicht vorhanden**. `Agent`
in `toolClass` aufzunehmen öffnet den Eingabe-Pfad also nicht von selbst: `Derive`
(`internal/span/span.go:188-201`) liest ausschließlich aus `ToolInput`. Die Gegenerwägung des
Auftraggebers — „namentlich gelistet" entscheide die Behandlung der Argumente mit — ist damit im
Code **nachgesehen und nicht eingetreten**; sie bleibt aber die Bedingung B1/B2 in §6, denn sie
*könnte* durch eine unachtsame Implementierung eintreten.

### 4.2 Frage B — die Delegation trägt beide Tabellen

Festlegung 1 delegiert die Feldtabelle wörtlich
(`docs/plan/adr/0011-telemetrie-erfassung-policy.md:64-66`):

> **Festlegung 1 — die Schema-POLICY, nicht die Feldtabelle.** Diese ADR entscheidet, *wie* das
> Schema zustande kommt und was mit Lücken geschieht; die konkrete Feldtabelle ist ein
> `MR-<NNN>`-Artefakt (Folgepflicht 1).

Und Folgepflicht 1 nennt den Ort und den Grund
(`docs/plan/adr/0011-telemetrie-erfassung-policy.md:293-295`):

> - **Folgepflicht 1:** das Span-Schema (Feld · Pflicht/Optional · Incident-Frage) wird als
>   `MR-<NNN>` in [`harness/conventions.md`](../../harness/conventions.md) geführt — es ist eine
>   Strukturregel, kein Implementierungsdetail, und der nächste Leser muss es ohne Code finden.

**Der Wortlaut delegiert nur die Feldtabelle — die Werkzeug-Tabelle wird an zwei anderen Stellen
delegiert, und die Delegation ist deshalb nicht schwächer, sondern anders begründet:**

1. Die Default-Zeile selbst enthält einen **Abbildungsauftrag**, keine Namensliste: *„die Zeilen
   oben sind auf konkrete Namen abzubilden"* (`:109`). Die ADR führt **keinen einzigen** konkreten
   Werkzeug-Namen in ihrer Tabelle — nur drei Gattungen und den Default. Wer die konkreten Namen
   dort suchte, fände sie nicht; sie stehen in `harness/conventions.md:877-883`, und `MR-018` sagt
   ausdrücklich, warum dort (`harness/conventions.md:869-875`): *„Ein Werkzeug aufzunehmen ist eine
   **Entscheidung** und wird hier eingetragen, nicht im Code nachgezogen."*
2. Die **Konsequenzen** stufen die namentliche Aufnahme als Dauervorgang ein
   (`docs/plan/adr/0011-telemetrie-erfassung-policy.md:282-284`):

> - **Negativ:** die Auswertung ist Eigenbau; wer OTel-Werkzeuge erwartet, findet keine. Das
>   geschlossene Schema kostet laufende Pflege — jedes Werkzeug, dessen Argumente erfasst werden
>   sollen, muss namentlich aufgenommen werden (der Preis von fail-closed, und er ist gewollt).

*„laufende Pflege"* ist kein ADR-Ereignis. Und die Alternativen-Tabelle sagt dasselbe von der
anderen Seite (`:274`): *„E ist damit nicht die verworfene Alternative, sondern Cs **Default**;
entschieden ist, für welche Werkzeuge wir davon abweichen und wie weit"*.

**Was Festlegung 1 dagegen NICHT delegiert, und was DoD (2) darum einhalten muss** (`:75-81`):

> 3. **Das Schema ist GESCHLOSSEN: erfasst wird, was darin steht — sonst nichts.** Der Grund ist
>    **nicht** Geheimhaltung, sondern Kontrolle über die eigene Datenform: bei offener Erfassung
>    bestimmt der **Werkzeug-Hersteller**, was in unserem Log landet.

Diese Regel gilt **flächen-unabhängig** und ist die eigentliche Rechtsgrundlage von DoD (2): die
neun Werte aus `tool_response` sind erlaubt, **weil** sie in das geschlossene Schema eingetragen
werden, und nur solange nichts Ungelistetes mitgeht. Die Positiv-Liste ist damit nicht eine
Vorsichtsmaßnahme des Slice, sondern die Bedingung des Verdikts.

Dazu Punkt 2 (`:73-74`), der jedes einzelne Feld bindet:

> 2. **Ein Feld ohne Incident-Frage wird nicht erfasst** — und die Frage steht neben dem Feld,
>    nicht in einem Kommentar.

### 4.3 Frage C — zwei Trigger beschreiben die Lage, und beide sind vorentschieden

**Trigger 2** (`docs/plan/adr/0011-telemetrie-erfassung-policy.md:356-362`):

> - **Wenn `agent_type` nicht auf unsere Rollen abbildbar bleibt** *(feedforward — kein Sensor;
>   wirkt nur, wenn ihn jemand liest)*. … **Schwelle:** sobald ein Auswertungs-Slice (060) eine Zahl
>   *je Rolle* ausweisen soll, ist die Abbildung zu entscheiden — vorher nicht.

Der Trigger nennt slice-060 **namentlich** und legt seine Auflösung fest: *die Abbildung ist zu
entscheiden*. Er verlangt keinen Folge-ADR, sondern eine **Entscheidung** — und die ist gefallen und
im delegierten Artefakt festgehalten (`harness/conventions.md:949-954`: die sechs kanonischen
Typnamen, *„Festlegung vom 2026-07-29, slice-060 Frage A"*). `MR-018` sagt zugleich, welche Sorte
Entscheidung das ist (`harness/conventions.md:946-948`): *„eine **Prozess**-Entscheidung
(slice-060), nach der sich das Feld **ohne** Änderung an der Erfassung füllt."*

**Trigger 6** (`:375-378`):

> - **Wenn nach dem ersten Auswertungs-Slice (060) kein Werkzeug über den Default hinaus erfasst
>   wird** *(feedforward — an ein Ereignis geknüpft, nicht an ein Gefühl)*: dann ist das Audit
>   faktisch Alternative E. Das ist **kein Fehler**, aber der Anlass, die Wahl zwischen C und E
>   ausdrücklich zu wiederholen, statt sie durch Nichtstun zu treffen.

Dieser Trigger feuert bei **Unterlassung**, nicht bei Aufnahme. Er setzt voraus, dass bei slice-060
ein Werkzeug über den Default hinaus erfasst *werden kann*, ohne dass die ADR bewegt wird — sonst
wäre er unerfüllbar formuliert. DoD (2) ist die Erfüllung dieses Triggers, nicht sein Auslöser.

**Ein dritter Punkt, den die ADR ausdrücklich dem umsetzenden Slice überlässt** (`:88-92`):

> Offen bleibt genau ein Feld: der **Cache-Status** steht im Transkript, nicht in der Payload; ob
> ein Span, der den `transcript_path` trägt und die Auflösung dem Auswerter überlässt, den
> Mindestsatz erfüllt oder von ihm abweicht, entscheidet der umsetzende Slice — mit Beleg, nicht per
> Vorab-Freistellung.

Die **Tatsachen-Prämisse** dieses Satzes (*„steht im Transkript, nicht in der Payload"*) ist
inzwischen für Vordergrund-`Agent`-Aufrufe **widerlegt**: die vier Zähler liegen in
`tool_response.usage` (`slice-060-rollen-achse.md:171`, Messzeile 1; in `MR-018` schon nachgetragen,
`harness/conventions.md:921-928`). Eine überholte Prämisse ist hier **kein** Anlass für einen
Folge-ADR, denn die Regel, die auf ihr steht, verlangt gerade das Nachziehen: Festlegung 1 Punkt 4
*„Ableiten schlägt deklarieren"* (`:82`) und Punkt 5 (*„Was auch nach der Ableitung nicht erreichbar
ist, wird begründet dokumentiert"*, `:93-95`). DoD (2) **löst** damit den letzten offenen Punkt der
Festlegung 1 ein, statt ihn zu verletzen; DoD (3) liefert die Rest-Abweichung.

## 5. Die Hypothese des Auftraggebers: sie trägt HALB

**Hypothese:** *„es bleibt drin, weil die ADR-Zeile von Argumenten spricht (`tool_input`), die
sieben Werte aber aus `tool_response` kommen — zwei verschiedene Flächen."*

**Was trägt (§4.1):** die Flächen-Zuordnung ist richtig, und sie ist jetzt gemessen statt gelesen.
Die Default-Zeile regelt die Argument-Achse; DoD (2) liest aus `tool_input` nichts und weist
`tool_input.subagent_type` ausdrücklich zurück (`slice-060-rollen-achse.md:126-127`).

**Was NICHT trägt — und das ist die gefährlichere Hälfte:** die Hypothese liefert nur ein
**Nicht-Verbot**, keine **Erlaubnis**. Unter einer fail-closed ADR mit geschlossenem Schema ist
„von Festlegung 2 nicht erfasst" gleichbedeutend mit „wird nicht erfasst" — Festlegung 1 Punkt 3
regelt *jede* Fläche. Die Erlaubnis kommt erst aus der Delegation (§4.2). Wer nur mit der
Flächen-Trennung argumentiert, hat die Hälfte des Verdikts nicht.

**Und der Satz, an dem die Hypothese kippen würde, wenn man sie zur Regel machte:**
`tool_response` ist **nicht** die harmlose Fläche. Sie trägt vier gemessene Freitext-Felder
(`slice-060-rollen-achse.md:171-172`, Messzeilen 1–2): `content`, `prompt`, `description`,
`outputFile` — darunter mit `content` den **größten Freitext-Block des ganzen Aufrufs**, den
vollständigen Bericht des Subagenten. `prompt`, das die ADR namentlich fürchtet, steht in **beiden**
Flächen. Das Argument „andere Fläche, also unbedenklich" wäre also gerade dort falsch, wo es am
bequemsten klingt.

Zusätzlich bindet Festlegung 2 mit einem **nicht flächen-gebundenen** Satz
(`docs/plan/adr/0011-telemetrie-erfassung-policy.md:111-112`):

> Damit wandert **kein Byte fremden Inhalts** ins Log: Massen-Abfluss über die Telemetrie ist
> konstruktiv ausgeschlossen, nicht per Regel verboten.

Dieser Satz greift auf `tool_response` durch. Acht der neun Werte aus DoD (2) sind Zahlen oder ein
gegen sechs Namen normalisiertes Etikett und damit strukturell unbedenklich. Der neunte ist es
nicht — siehe B5.

**Fazit zu 3.:** die Hypothese **trägt halb**. Sie ist die richtige Antwort auf die falsche Frage:
sie widerlegt das Verbot, begründet aber nicht die Erlaubnis, und sie legt eine Fläche als sicher
nahe, die es nicht ist.

## 6. Die Grenze: fünf prüfbare Bedingungen für den Verifier

Das Verdikt „innerhalb" gilt genau, solange DoD (2) diese fünf Grenzen hält. Jede ist als
**Gegenbeispiel** formuliert (`AGENTS.md` §3.6) — der Verifier prüft nicht die Absicht, sondern das
Rot.

**B1 — Aus `Agent`s `tool_input` erreicht nichts den Span.**
*Prüfung:* `internal/span/span.go` `ToolInput` führt weiterhin **genau drei** Felder (`file_path`,
`notebook_path`, `command`) — kein `subagent_type`, kein `prompt`, kein `description`, kein
`run_in_background`. `spawned_role` kommt aus `tool_response.agentType`, nie aus
`tool_input.subagent_type`.
*Gegenbeispiel, das rot werden muss:* eine Payload mit `tool_input.subagent_type: "reviewer"` und
**fehlendem** `tool_response` erzeugt einen Span mit **leerem** `spawned_role`. Steht dort
`reviewer`, ist die Argument-Achse geöffnet und das Verdikt fällt.
*Warum diese Grenze das Verdikt trägt:* §4.1 — genau diese Achse regelt die Default-Zeile.

**B2 — `Agent` wird auf KEINE der drei Gattungszeilen von Festlegung 2 abgebildet.**
*Prüfung:* ein `Agent`-Span trägt niemals `path`, `program`, `argc`, `bytes`, `sha256_16`.
`toolClass("Agent")` liefert keinen der Werte `classFileRead`/`classFileWrite`/`classCommand`
(`internal/span/span.go:150-176`); der `fingerprint`-Aufruf bleibt an `classFileWrite` gebunden
(`internal/span/emit.go:126-128`).
*Gegenbeispiel:* eine `Agent`-Payload, deren `tool_input` zusätzlich `command` und `file_path`
trägt, erzeugt einen Span **ohne** `program`, `argc`, `path`.

**B3 — Die Positiv-Liste ist EINE benannte Liste, und der Grenz-Zahn existiert.**
*Prüfung:* die Auswahl der erfassten Schlüssel steht an einer Stelle, über die die Erfassung
iteriert (die Form-Vorgabe des Plans, `slice-060-rollen-achse.md:149-155`), und
`test/mutations/` bekommt die **fünf** Zähne aus DoD (2) — vier namentliche plus den Grenz-Zahn.
*Gegenbeispiel:* eine `tool_response` mit einem **erfundenen, ungelisteten** Schlüssel erreicht den
Span nicht; die Mutation „einen Eintrag aus der Liste entfernen und alles Nicht-Gelistete
durchlassen" färbt einen Wächter rot.
*Warum diese Grenze das Verdikt trägt:* sie **ist** Festlegung 1 Punkt 3 (`:75-81`). Ohne B3 ist
DoD (2) keine Schema-Erweiterung, sondern eine Schema-Öffnung — und **das** wäre ADR-Gebiet, weil
Punkt 3 nicht delegiert ist.

**B4 — Jeder neue Wert steht mit Incident-Frage in `MR-018`, und `MR-018` bekommt seine
`Agent`-Zeile.**
*Prüfung:* die Feldtabelle (`harness/conventions.md:847-867`) führt alle neun neuen Werte je mit
Incident-Frage; die Werkzeug-Tabelle (`harness/conventions.md:877-883`) bekommt eine `Agent`-Zeile
**vor** oder mit dem Code, nicht danach. Kein Feld im Code ohne Zeile im Artefakt.
*Gegenbeispiel:* ein Feld im `Span`-Struct (`internal/span/emit.go:42-66`) ohne Zeile in `MR-018`.
*Warum:* Festlegung 1 Punkt 2 (`:73-74`) und Folgepflicht 1 (`:293-295`, *„der nächste Leser muss es
ohne Code finden"*). Die Delegation ist die Grundlage des Verdikts — wird sie nicht eingelöst, ruht
die Erweiterung auf nichts.

**B5 — `resolvedModel` ist der EINZIGE Rohstring unter den neun Werten und braucht eine
konstruktive Schranke.**
*Der Befund:* acht Werte sind Zahlen oder das gegen sechs Namen normalisierte `spawned_role`
(`slice-060-rollen-achse.md:134-139`). `resolvedModel` ist eine **unbegrenzte Zeichenkette aus der
Payload des Herstellers**. Sein Mandat ist echt — Modul 15 verlangt `model.version` als Label
(`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md:55`) —, aber Festlegung 2 sagt
*„konstruktiv ausgeschlossen, **nicht per Regel verboten**"* (`:111-112`). Eine wörtliche Kopie
eines unbegrenzten Fremdstrings ist genau „per Regel verboten".
*Prüfung:* `resolvedModel` wird **strukturell** begrenzt — Längenschranke **und**
Zeichensatz-Normalisierung (die Linie, die `sanitizePart` schon fährt,
`internal/span/emit.go:206-218`) oder Abgleich gegen ein geschlossenes Muster.
*Gegenbeispiel, das rot werden muss:* eine `tool_response.resolvedModel` mit 100 kB Text und einem
eingebetteten `AWS_SECRET_ACCESS_KEY=…` landet **nicht** verbatim im Span.
*Zulässige Alternative:* `resolvedModel` **nicht** erfassen und die Modul-15-Label-Anforderung als
erklärte Abweichung nach Festlegung 1 Punkt 5 (`:93-95`) in `MR-018` führen. Beides bleibt innerhalb
der ADR; **nichts von beidem zu tun** verlässt sie.

**B0 (Rahmen, nicht Grenze) — es wird nichts emittiert.** Festlegung 5 (`:211-221`) hängt das *Ob*
der Emission an slice-062 samt CR; der Slice emittiert nichts (`slice-060-rollen-achse.md:26-28`,
§6). Solange das gilt, ist die ebenen-abhängige Schärfe aus Festlegung 2 (`:140-146`, kein
Inhalts-Hash im Emittierten) nicht berührt. Wandern die Agenten-Typen später mit, ist es slice-062
und ein CR, nicht dieser Slice.

## 7. Nebenbefunde: zwei Zählfehler, zwei Fehlzitate

Sie berühren das Verdikt nicht, aber sie gehören dem Planner und dem Implementer gemeldet —
in dieser Slice-Familie sind schon zwei Zitate an falschen Zählungen gescheitert.

**Z1 — „sieben Werte" ist falsch, und zwar unter beiden Zählweisen.**
`slice-060-rollen-achse.md:191` sagt *„sobald sieben benannte Werte aus `tool_response` gelesen
werden"*. Die Aufzählung in DoD (2) (`:125-128`) ergibt nachgezählt:

| Zählweise | Ergebnis |
|---|---|
| Top-Level-Schlüssel von `tool_response` | **6** — `usage`, `totalTokens`, `totalDurationMs`, `totalToolUseCount`, `agentType`, `resolvedModel` |
| Blatt-Werte (die vier `usage`-Zähler einzeln) | **9** — 4 + 3 Summen + `agentType` + `resolvedModel` |
| neue Span-Felder | **9**, falls je Blatt eines entsteht |

**7** ist keine der drei Zahlen; sie entsteht, wenn man die vier Zähler und die drei Summen zählt
und Rolle und Modell vergisst — genau die zwei Werte, die B5 und B1 tragen. Die Zeile sollte „neun
Werte aus sechs Schlüsseln" sagen. Dieselbe Zählung steht auch in der Aufgabenstellung dieses
Prüfauftrags.
*Nicht betroffen:* „vier Freitext-Felder" (`:232`, nachgezählt 4: `content`, `prompt`,
`description`, `outputFile`), „fünf Zähne" (`:195`, nachgezählt 4 + 1) und „einer von sieben Werten"
(`:204` — sechs Rollennamen plus leer, korrekt).

**Z2 — Der Bezug-Block des Slice formuliert eine ADR-Änderung, wo eine MR-Änderung gemeint ist.**
`slice-060-rollen-achse.md:15-16` sagt: *„**Accepted** — Festlegung 2, der fail-closed Default am
Werkzeug-Namen, wird um genau ein Werkzeug erweitert"*. **Festlegung 2 wird nicht erweitert** — sie
enthält keine Namensliste (§4.2). Erweitert wird die namentliche Liste in `MR-018`
(`harness/conventions.md:877-883`), die Festlegung 2 delegiert. Der Satz liest sich wie eine
Änderung an einer immutablen ADR und sollte umformuliert werden; die Sache selbst ist in Ordnung.

**Z3 — `test/mutations/115-span-ergebnis-inhalt.sh` zitiert die falsche Festlegung.** Sein
Kopfkommentar sagt: *„Vom Ergebnis darf ausschliesslich die GROESSE erfasst werden (ADR-0011
Festlegung 2, dieselbe Linie wie bei `tool_input`)"*. Festlegung 2 regelt die Argumente; das Verbot
von Ergebnis-**Inhalt** ruht auf Festlegung 1 Punkt 3 plus dem „kein Byte fremden Inhalts"-Satz. Die
Zusage *„ausschliesslich die GROESSE"* wird durch DoD (2) **falsch**; der Wächter selbst bleibt
richtig und ist umzuformulieren auf *kein Freitext aus dem Ergebnis* — nicht zu löschen. Er ist der
einzige bestehende Zahn, der die Fläche überhaupt bewacht.

**Z4 — Dieselbe falsche Zusage steht an zwei weiteren Stellen** und der Slice nennt bisher zwei
davon: `internal/span/span.go:98-100` (*„Vom ERGEBNIS wird ausschliesslich die LAENGE genommen, nie
der Inhalt — dieselbe Linie wie bei `tool_input` (ADR-0011 Festlegung 2)"*) und
`harness/conventions.md:1030` (§Bewacht: *„vom Ergebnis darf nur die Länge in den Span"*). Beide
werden mit DoD (2) falsch. `make comment-claims` fängt es nicht — es prüft die Existenz des
Sensors, nicht die Wahrheit des Satzes (so schon `slice-060-rollen-achse.md:195`).

**Z5 — Randnotiz zur ADR-Lesbarkeit, kein Befund:** die Trigger 2 und 6 nennen „(060)" als *den*
Auswertungs-Slice; die Auswertung liegt inzwischen in slice-066
(`docs/plan/planning/welle-09-modul-15-konformitaet.md:137-138`). Die ADR ist immutabel; wer die
Trigger liest, liest sie ab jetzt als „060 **und** 066". Das gehört in `MR-018`, nicht in die ADR —
dieselbe Bauart wie die dortige Tooling-Klarstellung (`harness/conventions.md:993-998`).

## 8. Was einen Folge-ADR erzwingen WÜRDE

Damit das Verdikt nicht als „geht schon" gelesen wird, hier die Gegenprobe. Ein Folge-ADR mit
`supersedes` wäre nötig, sobald einer dieser vier Fälle einträte — dann **schreibt der Architect
ihn**, und niemand bessert `ADR-0011` nach (Modul 8
`.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md:70-74`; `AGENTS.md` §3.4):

| Fall | Welche Stelle er superseden müsste | Warum die Delegation ihn nicht trägt |
|---|---|---|
| Ein Freitext-Feld aus `tool_input` **oder** `tool_response` (`prompt`, `content`, `description`, `outputFile`) soll erfasst werden — auch abgeleitet | Festlegung 2, Default-Zeile (`:109`) **und** der Satz *„kein Byte fremden Inhalts"* (`:111-112`) | Die Default-Zeile nennt den Freitext-Prompt als ihren **Grund**; ihn zu erfassen kehrt die Begründung um, nicht nur die Liste |
| Das Schema soll **offen** werden (alles Nicht-Ausgeschlossene wandert mit) | Festlegung 1 Punkt 3 (`:75-81`) | Punkt 3 ist die **einzige** Regel von Festlegung 1, die nicht delegiert ist — er ist die Policy selbst |
| Die Achse des Defaults soll von der **Gattung** statt vom **Namen** entschieden werden | Festlegung 2, Default-Zeile (`:109`) | Die Zeile verwirft die Gattungs-Achse ausdrücklich und mit Begründung |
| Für die **emittierte** Ebene sollen mildere Regeln gelten als hier | Festlegung 5 (`:211-221`) und Festlegung 2 §Schärfe (`:140-146`) | Festlegung 5 delegiert nur das **Ob**, nicht das **Wie** |

Keiner dieser vier Fälle liegt in DoD (2). Die Hülle für Verdikt 2 aus Modul 8 bleibt bereitgehalten
(`.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`), damit ein Folge-ADR
nicht die aufwändigste und deshalb ungewählte Option ist — sie wird hier **nicht** gebraucht.

## 9. Gate-Lauf

`make gates`, gefahren am 2026-07-30 nach dem Anlegen dieses Artefakts. **Exit-Code 0.** Die
tragenden Zeilen der echten Ausgabe:

```
baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)
d-check: 254 Datei(en) geprüft, 0 Befund(e)
1..149
149x "ok", 0x "not ok"
comment-claims: 37 Datei(en) geprueft, 0 Befund(e)
ok  	github.com/pt9912/ai-harness-init/internal/span	0.033s
span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert
```

Dieses Artefakt ändert nur Dokumentation unter `docs/reviews/**` (dort sind `ids` und `codepaths`
ausgenommen, `.d-check.yml:27-35` und `:57-60`; `links`/`anchors` gelten weiter und sind in den
254 geprüften Dateien enthalten). `make mutate` wurde **nicht** gefahren — dieses Artefakt ändert
keinen Wächter und keinen bewachten Pfad; die fünf Zähne aus DoD (2) entstehen erst mit dem Code.

**Rollen-Grenze:** dieses Artefakt entscheidet die **ADR-Lage vor dem Code**. Es ersetzt weder das
Implementations-Review (Diff gegen Plan) noch die Verifikation (Modul 11) — B1 bis B5 sind Eingaben
für beide, keine Erledigungen.
