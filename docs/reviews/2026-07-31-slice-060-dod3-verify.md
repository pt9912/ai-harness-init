# Verifikation (Modul 11) — slice-060 DoD (3) und der nachgelieferte DoD-(1)-Rest

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Verifier (Modul 11) — „Bauen wir es richtig?" gegen Plan und DoD |
| **Datum** | 2026-07-31 |
| **Prüfbereich** | `ff1f1a1..HEAD` (`65e3b1c`), verengt auf die DoD-(3)- und DoD-(1)-Rest-Commits: `a4199c9` · `ae33b40` · `0738bc3` · `e59cec4` · `7fc86eb` · `52da26e` · `ac06b9a` · `111fcdd` · `04c1b1e` · `1950020` |
| **Prüfgegenstand** | `harness/conventions.md` `MR-018` (Start-Konvention, Abweichungen 5 und 6) + `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md` (Proposed) + `docs/plan/adr/README.md` |
| **Plan** | `docs/plan/planning/in-progress/slice-060-rollen-achse.md` DoD (1) letzte Zeile, DoD (3), §3-Dateitabelle |
| **Normquellen** | `ADR-0011` (Accepted) Festlegung 1 Punkt 4/5 · `AGENTS.md` §3.1, §3.5, §3.6 · `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md` §Werkzeug-Wahl |
| **Gefahrene Sensoren** | `make gates` (voll, Exit 0) · CI-Lauf `30642607568` auf `65e3b1c` (vier Jobs grün, `make mutate`) · Guard direkt gegen sechs Payload-Formen · Auswertung des Span-Bestands unter `.harness/state/spans/` (45 `Agent`-Spans) |
| **Nicht gefahren** | `make mutate` lokal (Nutzer-Ausschluss, Host-Speicher) — die CI hat ihn auf frischem Runner gefahren, Ergebnis unten verbatim |

---

## 1. Das Urteil

**Nicht bestätigt.** DoD (3) und der DoD-(1)-Rest sind der Substanz nach geliefert — beide Lücken
stehen als erklärte Abweichung, in der von `ADR-0011` verlangten Reihenfolge, und die
Start-Konvention steht in `MR-018` statt in einem Gedächtnis —, aber beide ruhen auf **derselben
Zusage**, die der Span-Bestand dieses Repos seit dem 2026-07-31T14:22:54Z **widerlegt**: dass der
`PreToolUse`-Guard den Vordergrund für Rollen-Typen erzwingt.

---

## 2. Zusage für Zusage

### DoD (3) — „Was die Erfassung nicht abdeckt, steht als erklärte Abweichung"

| # | Zusage | Urteil | Beleg |
|---|---|---|---|
| 3.1 | Lücke 1 (Hintergrund-Läufe liefern weder Zähler noch `agentType`) ist benannt | **bestätigt** | `harness/conventions.md:1172` Abweichung 5, Kopf und Prüfschritt 1 (`:1178-1186`). Die acht dort aufgezählten Hintergrund-Schlüssel decken sich Zeichen für Zeichen mit der Ist-Messung in `slice-060-rollen-achse.md:193` (§3 Zeile 2) |
| 3.2 | Lücke 2 (kein `Agent`-Aufruf umschließt den Haupt-Kontext) ist benannt | **bestätigt** | `harness/conventions.md:1238` Abweichung 6, Prüfschritt 1 (`:1243-1248`) |
| 3.3 | Reihenfolge **Prüfung vor Abweichung** (`ADR-0011` Festlegung 1 Punkt 5) | **bestätigt** | Abweichung 5: drei nummerierte Prüfschritte `:1178`, `:1187`, `:1196`, danach erst `**Die Abweichung:**` `:1221`. Abweichung 6: drei Prüfschritte `:1243`, `:1249`, `:1255`, danach `**Die Abweichung:**` `:1271`. Der Grund für die Reihenfolge ist an Ort und Stelle zitiert (`:1176-1177`, verbatim gegen `docs/plan/adr/0011-telemetrie-erfassung-policy.md:97-98`) |
| 3.4 | Die Prüfung ist **gezeigt**, nicht behauptet | **bestätigt, mit einer Ausnahme** | Selbst nachgemessen: die Vollständigkeitsaussage in Abweichung 6 Prüfschritt 3 (`:1263-1268`) über die vendored Werkzeug-Doku hält — `docs/user/claude-hooks-referenz.md` (3.383 Zeilen) nennt ein `usage`-Objekt und ein `totalTokens` **nur** in `:1571` und `:1574`, beide in der `tool_response`-Tabelle des `Agent`-Werkzeugs; die übrigen Treffer sind URL-Fragmente (`:641`, `:655`) und der Fehlertyp `max_output_tokens` (`:225`, `:2419`). **Die Ausnahme** ist Prüfschritt 2 von Abweichung 5 — siehe V-1 |
| 3.5 | Die Abweichung reicht so weit wie die Lücke | **NICHT bestätigt** | `:1196-1219` zählt auf, was der Guard **nicht** deckt, und nennt genau zwei Posten: (a) Typen ohne Datei in `.claude/agents/`, (b) der Guard kann fehlen/abgeschaltet/umgangen sein. Der Fall, der real eingetreten ist — **Rollen-Typ, Guard verdrahtet, Aufruf passiert ihn trotzdem** — steht in keinem der beiden. Siehe V-1/V-2 |
| 3.6 | Abweichung 6 trägt statt eines Triggers ein **Verdikt** (permanent, `ADR-0012`) | **bestätigt** | `:1277-1282`; der Modul-7-Trichter ist in der Reihenfolge des Moduls durchlaufen (`:1283-1296`). **Das verfehlt DoD (3) nicht:** der DoD-Text verlangt die *erklärte* Abweichung, nicht die *temporäre*. Die Beschreibung samt Prüfung steht unverändert in `MR-018`; das ADR fügt die Permanenz-Einordnung hinzu, es ersetzt die Deklaration nicht |

### DoD (1), letzte Zeile — „Beide Bedingungen als Konvention in `MR-018` … belegt an einem echten Lauf"

| # | Zusage | Urteil | Beleg |
|---|---|---|---|
| 1.1 | Hälfte a: **beide** Bedingungen stehen als Konvention in `MR-018` | **bestätigt** | `harness/conventions.md:955` Start-Konvention; Bedingung 1 (@-Erwähnung) `:958-965`, Bedingung 2 (Vordergrund) `:966-974`. Nachgemessen, dass die Zeile wirklich neu ist: `git show 0738bc3^:harness/conventions.md \| grep -c "Erwähnung"` = **0**, am Arbeitsbaum = **7**. Sie kam mit `0738bc3`, also nach dem ersten DoD-(3)-Commit `a4199c9` — die Nachlieferung ist real |
| 1.2 | Hälfte a': die beiden Belegklassen sind getrennt geführt | **bestätigt** | Bedingung 1: *„Belegklasse: fremde Doku, im Repo NICHT vorliegend"* (`:960`). Bedingung 2: *„Belegklasse: gemessen, und zusätzlich repo-lokal dokumentiert"* (`:968`). Was erzwungen ist und was nur behauptet, steht in demselben Punkt (`:987-1020`) |
| 1.3 | Hälfte b: **belegt an einem echten Lauf, nicht am Test** | **halb** | `:991-996` führt den Lauf: ein Rollen-Typ mit `run_in_background: true` abgelehnt, Grund wörtlich beim Aufrufer, Subagent lief nicht. **Nicht nachprüfbar** (siehe §5), und **in seiner Reichweite widerlegt** (V-1): der Satz darüber — *„Bedingung 2 ist für Rollen-Typen erzwungen"* (`:990`) — ist breiter als das, was der Guard hält |
| 1.4 | Die Zusage ist auf das eingeschränkt, was der Code hält (`AGENTS.md` §3.6) | **NICHT bestätigt** | V-1, V-2 |

---

## 3. Befunde

### V-1 — Ein Rollen-Typ ist am 2026-07-31 im Hintergrund gelaufen; die zwei Sätze, auf denen DoD (1) und Abweichung 5 ruhen, sind damit breiter als ihr Gegenstand

**Kategorie: blockierend.**

**Gemessen** (Span-Bestand `.harness/state/spans/`, selbst ausgewertet, nicht übernommen):

1. Der Subagenten-Strom `b8b2e34b_8a2b_4d52_845f_7081dfc9ec0b-ad048039fd60fec5f.jsonl` läuft von
   `2026-07-31T14:12:16Z` bis `14:25:16Z` und trägt **37 von 37** Spans mit
   `"agent_type":"architect"` und `"agent_role":"architect"` — ein **Rollen**-Typ, und
   `.claude/agents/architect.md` existiert.
2. Der zugehörige Eltern-Span steht im Haupt-Strom als `"seq":469`,
   `"ts":"2026-07-31T14:22:54Z"`, `"tool":"Agent"`, `"duration_ms":640572`,
   `"result_bytes":5186` — und trägt von den neun erfassbaren Werten **genau einen**:
   `"model_version":"claude-opus-5[1m]"`. Kein `spawned_role`, keiner der vier `usage`-Zähler,
   kein `total_*`. Startzeitpunkt `14:22:54Z` minus `640.572 s` = `14:12:13Z`, also derselbe
   Aufruf (bei den übrigen Rollen-Läufen liegt derselbe Versatz bei 2–3 s).
3. Der Aufruf hat **nicht blockiert**: der Haupt-Strom führt `Bash`-Spans `seq` 470–473 zu
   `14:23:17Z`, `14:23:44Z`, `14:24:12Z`, `14:25:07Z`, während der Architekten-Strom noch bis
   `14:25:16Z` schreibt. Bei jedem anderen Rollen-Lauf des Bestands endet der Unterstrom **vor**
   dem Eltern-Span (Kontrolle: Architekt `13:30:14Z`, Unterstrom `a6608e18882bf267c` endet
   `13:29:22Z`).

Damit ist das der Fall, den `harness/conventions.md:1200-1207` als „nicht beobachtet" führt:
ein `Agent`-Span aus einem Hintergrund-Lauf, der von den neun Werten höchstens einen trägt. Die
**Vorhersage** dieser Zeile ist bestätigt; die **Zusage**, die sie einrahmt, ist es nicht.

**Was dadurch falsch wird — zwei Sätze, beide im Prüfbereich:**

- `harness/conventions.md:990` — *„**Bedingung 2 ist für Rollen-Typen erzwungen.** Der
  `PreToolUse`-Guard `.claude/hooks/pretooluse-agent-guard.sh` verweigert den Start."* Er hat
  ihn hier nicht verweigert. Der Satz kam mit `0738bc3`, dem DoD-(1)-Rest-Commit.
- `harness/conventions.md:1187` — *„**Vermeidbar? Für Rollen-Typen ja — und dieser Teil ist
  gelöst, nicht erklärt.**"* Der Satz kam mit `a4199c9`, dem DoD-(3)-Commit, und trägt
  Prüfschritt 2 von Abweichung 5.

**Der Guard selbst ist in Ordnung — die Zusage ist es nicht.** Ich habe ihn direkt gegen sechs
Payload-Formen gefahren (`.claude/hooks/pretooluse-agent-guard.sh`, stdin, Repo-Arbeitsbaum):

| Form | Ergebnis |
|---|---|
| `architect` + `run_in_background` fehlt | **DENY** |
| `architect` + `run_in_background: true` | **DENY** |
| `architect` + `run_in_background: false` | PASS |
| `architect` **nach** `prompt`, Schalter fehlt | **DENY** |
| `general-purpose`, Schalter fehlt | PASS |
| **kein `subagent_type` im `tool_input`** | **PASS** |

Die Entscheidungsfunktion tut also, was `MR-018` ihr zuschreibt. Was kein Sensor prüft und was
der Bestand widerlegt, ist die **Erreichbarkeit**: dass jeder reale Rollen-Aufruf den Guard
überhaupt in einer Form erreicht, in der er entscheiden kann. Welcher der Mechanismen (Payload
ohne `subagent_type`, Hook feuert für diese Aufrufform nicht, dritter Weg) zutrifft, ist aus dem
Repo **nicht** entscheidbar — siehe §5.

**Berührt das DoD (1)?** Ja, und zwar genau seine letzte Zeile. Die Konvention steht in
`MR-018` (Hälfte a, bestätigt). Der rot gesehene echte Lauf existiert für die Form
`run_in_background: true` (Hälfte b, wie geschrieben). Aber der Satz, den beide tragen sollen,
sagt *erzwungen* — und `AGENTS.md` §3.6 verlangt wörtlich, *„die Zusage auf das einschränken, was
der Code hält"*. Sie hält heute: *der Guard lehnt ab, wenn er den Aufruf mit erkennbarem
Rollen-Typ sieht*. Nicht: *ein Rollen-Lauf startet nicht im Hintergrund*.

**Nebenbefund zur Vorgeschichte, nicht wieder aufgemacht:** genau dieser dritte Fall stand als
`L-2` im Report `docs/reviews/2026-07-31-slice-060-dod3-review-runde-2.md` — dort als LOW
eingestuft und als *„verifizierbar: ja — … er ist nicht gefahren"* markiert. Er ist jetzt nicht
mehr hypothetisch, sondern liegt im Bestand.

### V-2 — Der Guard behandelt einen fehlenden `subagent_type` fail-OPEN; `MR-018` nennt diesen Ausgang nicht, und kein Fall bindet ihn

**Kategorie: blockierend (Träger von V-1).**

`.claude/hooks/pretooluse-agent-guard.sh:76` — `[ "$stype" = "ABSENT" ] && exit 0`, mit dem
Kommentar *„Kein Subagent-Typ -> kein Rollen-Aufruf"*. Zwölf Zeilen darunter, `:83-86`, steht die
umgekehrte Politik für den anderen fehlenden Schlüssel: *„Alles andere, auch ein FEHLENDER
Schalter, gilt als Hintergrund"*.

Die Asymmetrie ist nirgends ausgesprochen und nirgends bewacht:

- `harness/conventions.md` nennt `subagent_type` an vier Stellen (`:868`, `:890`, `:1000`,
  `:1003`) — keine davon sagt, was der Guard bei **Abwesenheit** des Schlüssels tut. Die
  Aufzählung „was er nicht deckt" (`:1196-1219`) führt diesen Ausgang nicht.
- `test/agent-guard.bats` führt 22 Fälle (11 `extract:`, 11 `guard:`). Der Fall
  `extract: kein Subagent-Typ -> zweimal ABSENT` (`:122`) prüft den **Extraktor**. **Kein**
  `guard:`-Fall fährt eine Payload ohne `subagent_type` durch den Guard.
- `test/mutations/` bindet drei Zusicherungen des Guards — `117` (Rollen-Prüfung), `118`
  (Ableitung statt Namensliste), `119` (fehlender Schalter fail-closed). **Keine** bindet
  `:76`.

Nach `AGENTS.md` §3.6 ist dieser Zweig damit **unbewacht** (*„wer keinen Fall in
`test/mutations/` hat, ist unbewacht"*), und er ist der einzige fail-open-Pfad des Guards.

### V-3 — „der Hook feuert beim **Start**" ist am eigenen Span-Bestand falsch; die Stelle wurde in diesem Prüfbereich zweimal geschrieben

**Kategorie: MEDIUM.**

Zwei Fundstellen, beide im Bereich entstanden:

- `harness/conventions.md:872` (Feldzeile `total_duration_ms`, geändert in `e59cec4` als
  Auflösung von Befund LOW-2): *„Die zwei Größen stammen aus **einem** Vordergrund-Aufruf:
  `duration_ms` trug dort 4 ms, weil der Hook beim **Start** feuert …"*
- `harness/conventions.md:978` (Start-Konvention, neu in `0738bc3`): *„sein Span trug
  `duration_ms: 3` — der Hook feuert beim **Start** — bei 4.184 ms …"*

**Gemessen** über alle 45 `Agent`-Spans des Bestands: **22 von 22** Spans, die `duration_ms`
**und** `total_duration_ms` tragen, zeigen `duration_ms` **größer** als `total_duration_ms`, um
1.450 bis 13.324 ms. Kleinster Wert im Satz: `duration_ms = 744794`. Es gibt im ganzen Bestand
**keinen** Span, in dem ein `duration_ms` in der Größenordnung 4 ms neben einem
`total_duration_ms` steht. Zweiter, unabhängiger Beleg für dieselbe Sache: bei jedem
Vordergrund-Rollen-Lauf endet der Unterstrom **vor** dem Zeitstempel des Eltern-Spans (Beispiel
oben, Architekt `13:29:22Z` gegen `13:30:14Z`). Der Hook feuert am **Ende** des Aufrufs.

Die Paarung, die `:872` beschreibt — 4 ms `duration_ms` neben einem `totalDurationMs` in
**einem** Vordergrund-Aufruf —, ist im Bestand nicht auffindbar. Das ist dieselbe Klasse, die
Befund LOW-2 an dieser Zeile beanstandet hatte (*„zwei Beobachtungen zu einer zu fügen ergäbe
eine Messung, die niemand gemacht hat"* — der Satz steht jetzt in derselben Zeile, die die
verbliebene Paarung trägt).

**Was davon unberührt bleibt:** die **Schlussfolgerung** an `:978` — der per @-Erwähnung
angeforderte Lauf war ein Hintergrund-Lauf — ist richtig und wird durch die korrekte Mechanik
sogar **stärker** getragen: feuerte der Hook beim Start, wäre `duration_ms: 3` bei jedem Lauf zu
erwarten und bewiese nichts; da er am Ende feuert, heißt 3 ms, dass der Aufruf sofort
zurückkam. Falsch ist die Begründung, nicht das Ergebnis.

### V-4 — „Beobachtet ist diese Zeile nicht" ist seit dem 2026-07-31T14:22:54Z überholt

**Kategorie: LOW.**

`harness/conventions.md:1204` — *„**Beobachtet ist diese Zeile nicht:** sie folgt aus der
Payload-Messung und aus dem Code, nicht aus einem Span — was sie entschiede, ist ein
`Agent`-Span aus einem Hintergrund-Lauf."* Genau dieser Span existiert jetzt (`seq 469`, oben)
und **bestätigt** die Zeile: von den neun Werten trägt er einen, und es ist `model_version`. Die
Selbstauskunft war zum Zeitpunkt ihrer Messung richtig (Report Runde 2, N-11, `2026-07-31`
vormittags) und ist es seit dem Nachmittag nicht mehr.

### V-5 — Die eingefrorene Zahl „fünf Treffer-Dateien" ist gealtert; die Aussage darüber hält

**Kategorie: LOW.**

`harness/conventions.md:1298` — *„alle Dateien in `open/`, `next/`, `in-progress/`, der
Welle-Plan und die Roadmap, auf *Token* durchsucht und die fünf Treffer-Dateien gelesen"*.
Nachgemessen: zum Stand `7fc86eb` waren es case-insensitiv **fünf** — die Zahl war richtig.
Am Arbeitsbaum sind es **neun** (`roadmap.md`, `slice-060`, `slice-066`, `slice-068`,
`slice-069`, `slice-071`, `slice-072`, `slice-073`, `welle-09-modul-15-konformitaet.md`); die
drei neuen Slices sind nach dem Commit entstanden.

**Die tragende Aussage habe ich selbst nachgemessen und sie hält:** keiner der drei neuen
Treffer führt die Bedingung „eine Quelle im Repo, die Haupt-Kontext-Token trägt".
`slice-071-cache-zaehler-getrennt.md` rechnet über dieselben `Agent`-Spans,
`slice-072`/`slice-073` treffen nur den `token:`-Modus von d-check, die Roadmap referenziert das
ADR. Zu beanstanden ist die eingefrorene **Zahl**, nicht der Schluss — und `MR-018` hat sich
diese Regel wenige hundert Zeilen weiter oben selbst gegeben (`:871`, Feldzeile `total_tokens`:
*„Die Probe gehört gefahren, nicht zitiert"*).

### V-6 — Offener LOW aus Runde 2, unverändert

`harness/conventions.md:1212` führt *„**drei** Artefakte"*, die im selbst deklarierten Umfang
(`test/**`, `Makefile`, `harness/tools/*.sh`, Go-Tests) die Verdrahtung einer `settings.json`
berühren. Selbst nachgemessen über denselben Umfang: `harness/tools/smoke.sh:85`,
`internal/emit/enforce_test.go:88`, `test/mutations/32-enforce-settings-wires-guard.sh` — **und**
`internal/emit/enforce_test.go:37` (`TestEnforce_EmitsAllMechanicFiles`), das die Datei fordert,
ohne zu prüfen, was sie verdrahtet. Unter dem Verb *„die Verdrahtung berühren"* ist drei
vertretbar, unter *„die `settings.json` berühren"* sind es vier. Das ist Befund `L-1` aus Runde 2
und ist nicht aufgelöst worden; ich führe ihn hier nur weiter, ich eskaliere ihn nicht.

---

## 4. Die Sensor-Frage: braucht DoD (3) einen Sensor?

**Mein Urteil: die Begründung trägt für die Abweichung als solche — und trägt nicht für die zwei
Zusagen, die im Innern der Abweichung stehen.**

**Trägt.** Eine Abweichung ist eine Aussage über eine **Lücke in einer fremden Payload**. Was sie
brechen würde, wäre ein Hintergrund-`Agent`-Lauf, dessen `tool_response` Zähler trägt — ein
Verhalten des Werkzeug-Herstellers, kein Code dieses Repos. Ein Wächter darüber hätte keinen
Prüfbereich in diesem Repo und wäre nach `AGENTS.md` §3.1 (kein halluzinierter Gate) genau der
Gate über leerem Prüfbereich. `ADR-0012` spricht dieselbe Prüfung für seine Festlegung 1
ausdrücklich aus (`docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:199-207`), und die
Begründung ist dort mit `AGENTS.md` §3.6 statt mit `LH-QA-01` unterlegt — das ist die korrekte
Norm für diesen Fall. Der Text selbst ist Markdown und liegt außerhalb von `comment-claims` (vier
Pfad-Muster, kein Markdown) und außerhalb dessen, was `d-check` prüft (Links, Anker, Kennungen,
Matrix, Codepfade, Spans — keine Sätze). Insoweit: **kein Sensor, und das ist eine Aussage, kein
Auslassen.**

**Trägt nicht.** Abweichung 5 enthält zwei Sätze, die keine Lücken-Aussagen sind, sondern
**Zusagen über Code dieses Repos**:

1. `:1187` — *„Vermeidbar? Für Rollen-Typen ja — und dieser Teil ist gelöst, nicht erklärt."*
2. `:990` (Start-Konvention, dieselbe Sache aus der anderen Richtung) — *„Bedingung 2 ist für
   Rollen-Typen erzwungen."*

Für diese gilt §3.6 unverkürzt, und `MR-018` nennt auch drei Sensoren (`test/agent-guard.bats`,
`test/mutations/117`, `118`, `119`). Alle drei existieren, laufen und sind in meinem
`make gates`-Lauf grün (bats-Fälle 12–22). **Nur decken sie die Zusage nicht:** sie messen die
**Entscheidungsfunktion** des Guards an synthetischen Payloads, nicht seine **Erreichbarkeit**
durch reale Aufrufe. Genau in dieser Differenz liegt V-1. Ein grüner Fall `119` belegt, dass ein
fehlender Schalter zu DENY führt — er belegt nicht, dass der Guard den Aufruf sieht.

Die richtige Antwort auf die Sensor-Frage ist deshalb nicht „ja" oder „nein", sondern eine
**Aufteilung**: für die Lücken-Aussage kein Sensor (begründet); für die Erzwingungs-Zusage
entweder ein Sensor, der die reale Aufrufform trifft, oder — der billigere und hier korrekte Weg
— **die Zusage auf das einschränken, was gemessen ist**. Der Bestand liefert die
Abdeckungs-Größe, die das entscheidet, bereits: **23 von 45** `Agent`-Spans tragen keinen der
Zähler; davon liegen **22** vor dem Landen der Positiv-Liste (letzter zählerloser Alt-Span
`2026-07-30T07:05:02Z`), und **einer** liegt danach — der aus V-1.

---

## 5. Plan gegen Code, in beide Richtungen

**Maßstab: die §3-Dateitabelle von `docs/plan/planning/in-progress/slice-060-rollen-achse.md`
(`:209-217`), verengt auf die zehn DoD-(3)/DoD-(1)-Rest-Commits.**

### Geplant und gebaut

| Plan-Zeile | Stand |
|---|---|
| `harness/conventions.md` — *„die zwei Abweichungen aus DoD (3)"* | gebaut (`a4199c9`, `ae33b40`, `e59cec4`, `7fc86eb`); Abweichungen 5 und 6, `:1172` und `:1238` |
| `harness/conventions.md` — *„die Start-Konvention (@-Erwähnung + Vordergrund + Guard)"* | gebaut (`0738bc3`), `:955-1020` |
| `ADR-0012` — *„die zweite Abweichung … ist nach dem Trichter aus Modul 7 permanent … Angelegt als Proposed"* | gebaut (`7fc86eb` + vier Nachträge); Status **Proposed**, Index-Eintrag `docs/plan/adr/README.md:20` |

### Gebaut, aber nicht in der Plan-Tabelle

| Artefakt | Einordnung |
|---|---|
| `docs/plan/adr/README.md` | **gedeckt außerhalb der Tabelle** — `AGENTS.md` §5 verlangt *„Neue ADRs aktualisieren den ADR-Index"*. Kein Befund |
| `docs/plan/planning/in-progress/slice-060-rollen-achse.md` (`e59cec4`, `7fc86eb`) | Selbst-Aktualisierung des Plans; `7fc86eb` trägt die `ADR-0012`-Zeile **in** §3 nach — die Tabelle wurde also der Realität angeglichen, nicht umgangen. Kein Befund, aber die Reihenfolge war Code-vor-Doc |
| `docs/plan/planning/open/slice-068-rollen-arbeit-laeuft-als-rolle.md` (`e59cec4`, `7fc86eb`) | **Nicht in der Tabelle.** Ein Nachbar-Slice in `open/` wird aus der Implementierung von slice-060 heraus umgeschnitten (DoD-Punkt abgegeben, Entfallens-Notiz). Sachlich begründet (keine zweite Wahrheit), aber es ist Planner-Arbeit in einem Implementierungs-Commit und in §3 nicht vorgesehen |
| `docs/reviews/*.md` (drei Reports, in `e59cec4`, `7fc86eb`, `111fcdd` mit-committet) | Prozess-Artefakte; nicht Plan-Gegenstand. **Anmerkung:** in `111fcdd` landen der Review-Report **und** die Auflösung seiner Befunde im selben Commit |

### Geplant, aber nicht gebaut

Für DoD (3) und den DoD-(1)-Rest: **keine offene Plan-Zeile.** Die übrigen Zeilen der §3-Tabelle
(`.claude/agents/`, `internal/span/`, `.claude/settings.json` + `.claude/hooks/`, `test/`,
`test/mutations/`) gehören zu DoD (1) und (2) und sind außerhalb dieser Verifikation.

---

## 6. Sensoren — nachgefahren statt übernommen

**`make gates`, voll, Arbeitsbaum auf `65e3b1c`, Exit 0:**

```
baseline-verify: v3.5.2 OK — 42 Dateien (Integritaet + Vollstaendigkeit, netzlos)
d-check: 268 Datei(en) geprüft, 0 Befund(e)
1..149            (bats: ok 1 … ok 149, keine not-ok-Zeile)
comment-claims: 38 Datei(en) geprueft, 0 Befund(e)
span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert
```

Go-Tests im gepinnten Image, alle sieben Pakete `ok`: `cmd/ai-harness-init`, `cmd/span-emit`,
`internal/emit`, `internal/fetch`, `internal/gen`, `internal/span`, `internal/wire`. Die vom
Implementer gemeldeten Zahlen sind damit **bestätigt** (268/0 · 38/0 · 149 bats · 7 Pakete).

**CI auf `65e3b1c` (= `HEAD`), Lauf `30642607568`:** vier Jobs, alle `success` (`gates`, `smoke`,
`full-smoke`, `mutate`). Schlusszeile des `mutate`-Jobs verbatim aus dem Log:

```
mutate: 134 ok, 0 Befund(e)
```

Gegengezählt: `ls test/mutations/*.sh | wc -l` = **134**. Die Fallzahl deckt sich, die
`make mutate`-Vertagung ist durch den CI-Lauf aufgelöst.

**Deckung, ausgesprochen:** der grüne `mutate`-Vollauf belegt, dass **kein gelisteter** Wächter
seine Zähne verloren hat. Er belegt nicht, dass DoD (3) einen hat — DoD (3) hat keinen und
braucht für seine Lücken-Aussage auch keinen (§4). Für die zwei Erzwingungs-Zusagen im Innern
sind Wächter gelistet (117/118/119), sie sind grün, und sie decken die Zusage trotzdem nicht
(V-1). Genau das ist die Differenz, die ein Gate-Lauf nicht sichtbar machen kann.

---

## 7. Die Zahlen, alle nachgezählt

| Aussage | Fundstelle | Nachzählung | Urteil |
|---|---|---|---|
| „**Sechs** erklärte Abweichungen" | `harness/conventions.md:1051` | Strukturscan über `:1051-1330`: Listenpunkte an `:1075`, `:1109`, `:1118`, `:1166`, `:1172`, `:1238` — kein siebter | **richtig** |
| „vier standen hier seit slice-059, die zwei letzten kamen am 2026-07-31 dazu" | `:1052-1053` | `git show ff1f1a1:harness/conventions.md` führt *„**Vier** erklärte Abweichungen"* mit den Punkten 1–4; 5 und 6 kamen mit `a4199c9` (2026-07-31) | **richtig** |
| Abweichung 5: „von den **neun** Werten … **höchstens einer**" / „die **acht** Werte an `usage`/`total*`/`agentType`" | `:1200-1203` | `responseKeys()` in `internal/span/response.go:65-77` führt neun Einträge über sechs Schlüssel; 4 `usage` + 3 `total*` + `agentType` = 8, Rest `resolvedModel` = 1 | **richtig** |
| Abweichung 5: die acht Schlüssel der Hintergrund-Antwort | `:1180-1183` | deckungsgleich mit `slice-060-rollen-achse.md:193` (§3 Zeile 2), acht Namen, gleiche Reihenfolge | **richtig** |
| Abweichung 5: „**drei** Artefakte" | `:1212` | vier unter dem weiteren Verb, drei unter dem engeren | **strittig**, V-6 |
| Abweichung 6: „die **vier** `usage`-Zähler und die **drei** `total*`-Werte" | `:1243-1244` | 4 + 3 = 7, deckt sich mit `responseKeys()` | **richtig** |
| Abweichung 6: „**Zwei** geprüft, beide zu" | `:1255` | Transkript (Abweichung 1) + `SubagentStart` = 2 | **richtig** |
| Abweichung 6: „über ihre ganze Länge … ausschließlich für die `tool_response` des `Agent`-Werkzeugs" | `:1263-1268` | `docs/user/claude-hooks-referenz.md`, 3.383 Zeilen: `usage`-Objekt und `totalTokens` nur `:1571`/`:1574`; übrige Treffer sind URL-Fragmente und `max_output_tokens` | **richtig** |
| Abweichung 6: „die **fünf** Treffer-Dateien" | `:1298` | fünf zum Stand `7fc86eb`, **neun** am Arbeitsbaum | **gealtert**, V-5 |
| Werkzeug-Tabelle: „**neun** Werte aus **sechs** Schlüsseln" | `:890` | `responseKeys()`: 9 Einträge, 6 verschiedene Top-Level-Schlüssel | **richtig** |
| Positiv-Liste Festlegung 1: „sechs Schlüssel, **neun** Blatt-Werte, oben in **sieben** Tabellenzeilen" | `:903-905` | Feldtabelle: `spawned_role` · `input_tokens, output_tokens` · `cache_creation…, cache_read…` · `total_tokens` · `total_duration_ms` · `total_tool_use_count` · `model_version` = 7 Zeilen | **richtig** |
| Fallzahl `make mutate` | CI-Log `65e3b1c` | 134 gemeldet, 134 Dateien im Verzeichnis | **richtig** |

**Ein Zählfehler ist nicht darunter.** Die zwei Beanstandungen sind eine strittige
Verb-Abgrenzung (V-6, aus Runde 2 übernommen) und eine gealterte Momentaufnahme (V-5).

---

## 8. Was ich nicht prüfen konnte

1. **Den rot gesehenen Lauf vom 2026-07-29** (`harness/conventions.md:991-996`). Ein vom Guard
   geblockter Aufruf hinterlässt **keinen** Span — `MR-018` sagt das selbst (`:1047-1049`). Es
   gibt im Repo kein Artefakt, an dem dieser Lauf nachvollziehbar wäre; er ist strukturell
   unbeobachtbar. Ich übernehme ihn als Behauptung des Implementers und markiere ihn als solche.
2. **Die Ursache des Durchschlupfs aus V-1.** Ich kann die `PreToolUse`-Payload jenes Aufrufs
   nicht rekonstruieren — sie wird nirgends protokolliert. Drei Hypothesen sind mit dem
   Beobachteten verträglich (Payload ohne `subagent_type` und damit `:76` fail-open; Hook feuert
   für diese Aufrufform nicht; ein dritter Weg). **Was entschiede:** eine Werte-Sonde auf
   `tool_input` im `Agent`-Zweig des `PreToolUse`-Hooks, die Schlüsselnamen protokolliert. Nicht
   gefahren — sie zu bauen ist Implementierung, nicht Verifikation.
3. **`make mutate` lokal** (Nutzer-Ausschluss, Host-Speicher). Der CI-Vollauf auf demselben
   Commit deckt es; einzelne Fälle habe ich nicht nachgefahren, weil die Fallzahl und das
   Ergebnis aus dem Log verbatim vorliegen.
4. **Die Annahme von `ADR-0012`.** Sie ist Architect-Entscheidung (Modul 8: *„ADR-Änderung:
   Architect schreibt; Reviewer prüft auf Konsistenz"*). Ich stelle nur fest, dass der Status
   *Proposed* ist und der letzte Review darüber `NICHT KONFORM` lautete.

---

## 9. Ist slice-060 closure-reif?

**Nein.** Der Closure-Trigger des Slice (`slice-060-rollen-achse.md:246-249`) verlangt fünf
Dinge; zwei liegen nicht vor.

**Was vorliegt:** `make gates` grün (selbst gefahren), `make mutate` grün auf frischem CI-Runner
(134/0), DoD (3) in seiner Substanz geliefert, der DoD-(1)-Rest in `MR-018` angekommen,
`ADR-0012` angelegt und indiziert.

**Was fehlt, in der Reihenfolge des Gewichts:**

1. **Die Erzwingungs-Zusage muss auf das eingeschränkt werden, was gemessen ist** — oder der
   Guard muss die reale Aufrufform treffen. Betroffen sind `harness/conventions.md:990` und
   `:1187`; dazu gehört der fail-open-Zweig `.claude/hooks/pretooluse-agent-guard.sh:76` in die
   Aufzählung „was er nicht deckt" (`:1196-1219`) und, nach `AGENTS.md` §3.6, ein Fall in
   `test/mutations/`, der ihn bindet. **Solange dieser Satz steht, wie er steht, ist DoD (1) in
   seiner letzten Zeile nicht erfüllt und Abweichung 5 schmaler beschrieben als die Lücke, die
   DoD (3) zu benennen verlangt.**
2. **Ein konformes Review-Verdikt.** Der letzte Review über den DoD-(3)-Bereich
   (`docs/reviews/2026-07-31-slice-060-dod3-review-runde-2.md`) lautet **NICHT KONFORM** (M-1,
   M-2); die Auflösung `7fc86eb` ist ungereviewt. Der letzte Review über `ADR-0012`
   (`docs/reviews/2026-07-31-adr-0012-proposed-review.md`) lautet **NICHT KONFORM** (ein HIGH,
   vier MEDIUM); die Auflösung `111fcdd` ist ungereviewt und liegt im selben Commit wie der
   Report. §5 des Slice verlangt *„Review konform (Modul 10) mit **ausgestelltem** Verdikt"* —
   das gibt es für den heutigen Stand nicht.
3. **Die Closure-Notiz mit Steering-Loop-Lerneintrag** (§7 des Plans ist leer) und der
   `git mv` nach `done/` — beides Planner-Closure, hier nur der Vollständigkeit halber genannt.
   **Ich setze keine DoD-Checkbox.**

**Nachrangig, nicht blockierend:** V-3 (zwei falsche Mechanik-Begründungen), V-4 (überholte
Selbstauskunft), V-5 (gealterte Zahl), V-6 (offener LOW aus Runde 2).

---

## 10. Steering-Loop-Beobachtung

Die Klasse, die diesen Slice geprägt hat — *„Aussage breiter als ihr Prüfbereich"* — tritt hier
zum ersten Mal **nicht** als Textbefund auf, sondern als **Messbefund**: nicht ein Satz, dessen
Prüfbereich enger ist als er selbst, sondern ein Satz, den der eigene Datenbestand widerlegt.
Der Unterschied ist operativ: die Textform findet ein Reviewer beim Lesen, die Messform nicht.
Sie wird nur sichtbar, wenn jemand den Bestand ausliest, den das Repo seit slice-059 selbst
erzeugt — und genau das ist die zweite Verteidigungslinie, die `slice-060` §6 und `slice-066`
DoD (1) als **Abdeckungszahl** angelegt haben. Der heutige Befund ist ihr erster echter Treffer,
angefallen zwei Wochen bevor der Slice läuft, der sie berechnen soll. Das ist ein Argument für
den Vorzug von `slice-066` und, wichtiger, dafür, die Abdeckungszahl **nicht** an „irgendein
erfasster Wert" zu hängen: der Span aus V-1 trägt einen erfassten Wert und ist trotzdem ein
zählerloser Lauf — die Definition, die `harness/conventions.md:1207-1210` verlangt, hätte ihn
sonst als gedeckt gezählt.
