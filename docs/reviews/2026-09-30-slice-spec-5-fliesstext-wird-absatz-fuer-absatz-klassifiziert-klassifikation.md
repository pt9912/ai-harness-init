# Klassifikation des Fließtexts von Spec §5 — slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert

**Art:** Bericht der Rolle Implementer (Eingabe für den Architect und den Planner). Kein Review-Report
und kein Norm-Text: die Tabelle ordnet zu und markiert Grenzfälle, sie entscheidet keine Klasse.

**Gegenstand:** `spec/spezifikation.md` Zeile 137 bis 718 (der Fließtext von §5 nach der
Werkzeug-Tabelle). **Stand:** `git rev-parse HEAD` → `3d926f6f9da93c0953edab060035a3e6098b8ed1`; letzte Änderung der Spec
`git log -1 --format=%h -- spec/spezifikation.md` → `ed4eedcf`. Alle Zeilennummern gelten für
diesen Stand.

**Bezug:** [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) · [ADR-0013](../plan/adr/0013-technik-stratum-als-zielort.md) · [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) · [ADR-0071](../plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md) · [MR-021](../../harness/conventions.md#mr-021) · [MR-025](../../harness/conventions.md#mr-025)

## 1. Messung

Die Zahlen stehen neben dem Kommando, das sie liefert ([MR-025](../../harness/conventions.md#mr-025)); sie sind keine Erwartungswerte.

```sh
sed -n '137,718p' spec/spezifikation.md | wc -c                                             # 45889
awk 'NR>=137&&NR<=718{if($0==""){n=0}else if(!n){c++;n=1}}END{print c}' spec/spezifikation.md   # 34  Blöcke
grep -c 'SPEC-[0-9]' spec/spezifikation.md                                                  # 34
grep -nE 'gemessen|20[0-9]{2}-[0-9]{2}-[0-9]{2}' spec/spezifikation.md | awk -F: '$1>=137&&$1<=718' | wc -l   # 35
grep -oE '`Test[A-Za-z0-9_]+`' spec/spezifikation.md | sort -u | wc -l                       # 24  Testnamen
grep -oE 'test/mutations/[0-9]+-[a-z0-9-]+\.sh' spec/spezifikation.md | sort -u | wc -l     # 26  Fall-Dateien
grep -rlE 'spec/spezifikation\.md' internal test cmd | wc -l                                 # 30  Dateien mit Zeiger
grep -rnE 'spezifikation\.md' internal test cmd harness/tools docs/plan/adr | wc -l          # 100  Zeiger-Stellen
```

**Einheit.** Der Absatz (durch Leerzeile getrennt); bei den nummerierten und Spiegelstrich-Listen der
Listenpunkt — bei der Erfassungs-Liste (1 bis 5), den Abweichungen 1 bis 6 (Abweichung 5 und 6 mit ihren
Unterpunkten) und bei `Bewacht` (dort auch die neun Unterpunkte der Erfassungs-Zusicherungen) als eigene
Einheit. Die 34 Blöcke ergeben **64** Einheiten (Zeilen `U01` bis `U64`) und **10** zweite
Zeilen für Einheiten, die zwei Klassen tragen (Nummer mit Suffix `b`, gleicher Zeilenbereich, Bytes
`0`). Der Zeilenbereich einer Einheit reicht bis zur Zeile vor der nächsten Einheit; die
Leerzeilen zählen zur davorstehenden Einheit, damit die Byte-Summe schließt.

**Klassen** (Arbeitshypothese des Slice-Plans, nicht entschieden): `a` Festlegung · `b` Begründung ·
`c` Messprotokoll · `d` Abweichung von der Baseline · `e` passt in keine. Die Spalte
*Aussageart* führt die feinere Beschreibung (Kopplung, Grenze, Herkunft, Prozess-Konvention,
Wächter-Zuordnung), ohne sie zur Klasse zu machen. *Sicherheit* ist `sicher` oder
`Grenzfall (x/y)` — die zweite Klasse ist die, mit der die Einheit ebenfalls verwechselt werden
kann.

## 2. Ergebnis in Zahlen

Bytes zählen in der ersten Zeile einer Einheit; zweite Zeilen tragen `0`. Die Spalte *Einheiten*
zählt alle Zeilen der Klasse (mit den zweiten Zeilen), *Grenzfälle* die davon markierten.

| Klasse | Einheiten | Grenzfälle | Bytes | Anteil an 45889 |
|---|---|---|---|---|
| a Festlegung | 21 | 6 | 10177 | 22.2 % |
| b Begründung | 10 | 5 | 3293 | 7.2 % |
| c Messprotokoll | 15 | 11 | 13508 | 29.4 % |
| d Abweichung | 12 | 1 | 8245 | 18.0 % |
| e passt in keine | 16 | 1 | 10666 | 23.2 % |

Die 35er-Obergrenze für Messprotokoll (Zeilen mit `gemessen` oder Datum, Kommando oben) verteilt sich
nach Klasse der Einheit, in der die Zeile steht:

```sh
grep -nE 'gemessen|20[0-9]{2}-[0-9]{2}-[0-9]{2}' spec/spezifikation.md | awk -F: '$1>=137&&$1<=718{print $1}'   # Zeilennummern
```

| Klasse der Einheit | a | b | c | d | e |
|---|---|---|---|---|---|
| Zeilen mit gemessen/Datum | 4 | 4 | 24 | 0 | 3 |

Von den 35 Zeilen stehen 24 in Einheiten der Klasse `c`; die übrigen stehen in
Einheiten anderer Klassen (Zusagen oder Begründungen, die das Wort benutzen oder ein Datum als Beleg
nennen).

### Vollständigkeit

```sh
F=docs/reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md
awk -F'|' '/^\| (U|T)/ {s+=$8} END{print s}' $F                       # Byte-Summe der Spalte
sed -n '137,718p' spec/spezifikation.md | wc -c                          # Soll
comm -23 <(grep -oE '`Test[A-Za-z0-9_]+`' spec/spezifikation.md | tr -d '`' | sort -u)          <(awk -F'|' '/^\| (U|T)/ {print $9}' $F | grep -oE 'Test[A-Z][A-Za-z0-9_]*' | sort -u)     # Testnamen im Text, nicht in der Tabelle
comm -23 <(grep -oE 'test/mutations/[0-9]+-[a-z0-9-]+\.sh' spec/spezifikation.md | sort -u)          <(awk -F'|' '/^\| (U|T)/ {print $9}' $F | grep -oE 'test/mutations/[0-9]+-[a-z0-9-]+\.sh' | sort -u)   # Fall-Dateien im Text, nicht in der Tabelle
```

Die Byte-Summe ist 45889 gegen 45889; beide `comm`-Differenzen sind leer. Die Zeile `T`
trägt die Wächter der Tabellenzeilen `SPEC-001` bis `SPEC-034` (Zeilen 59–60 und 99–135): 11 der
24 Testnamen stehen nur dort, nicht im Fließtext. Sie ist Träger, keine klassifizierte Einheit, und
zählt `0` Bytes.

## 3. Klassifikationstabelle

Spalten: Nr · Zeilen · Einheit · Klasse · Aussageart · Sicherheit · Bytes · gebundene Wächter ·
Sensor-Abhängigkeit. *Gebundene Wächter* sind die in der Einheit selbst genannten Tests, Fall-Dateien
(`Fall N` steht für `test/mutations/N-*.sh`), Test-Dateien, Hooks und `make`-Ziele; `—` heißt, die
Einheit nennt keinen. *Sensor-Abhängigkeit* nennt die Nummern aus dem Zeiger-Inventar (§5), die die
Einheit beim Namen nennen; `— (kein Zeiger)` heißt, keine Stelle in `internal/`, `test/`, `cmd/`,
`harness/tools/` oder `docs/plan/adr/` nennt sie.

| Nr | Zeilen | Einheit | Klasse | Aussageart | Sicherheit | Bytes | gebundene Wächter | Sensor-Abhängigkeit |
|---|---|---|---|---|---|---|---|---|
| U01 | 137–140 | Werkzeug-Achse ist der Name, nicht die Antwortgestalt | a | Festlegung, Kopplung | sicher | 269 | TestAgentGetsNoArgumentFields · TestOnlyAgentToolGetsResponseValues · Fall 133 · Fall 135 | — (kein Zeiger) |
| U02 | 141–148 | Erfassung aus tool_response ist eine Positiv-Liste (Lead) | a | Festlegung | sicher | 577 | — | — (kein Zeiger) |
| U02b | 141–148 | Lead: vier gemessene Freitext-Felder, zwei Erfassungs-Flächen | c | Messung | Grenzfall (c/a) | 0 | → U02 (gleicher Zeilenbereich) | — |
| U03 | 149–155 | Erfassungs-Liste 1: nur was responseKeys() nennt; Zählung 6/9/7 | a | Festlegung, Kopplung | sicher | 600 | internal/span/response.go | Z090 |
| U04 | 156–158 | Erfassungs-Liste 2: positiv statt negativ (vier Aufrufe, fünf Schlüssel gemessen) | b | Begründung | Grenzfall (b/c) | 261 | — | — (kein Zeiger) |
| U05 | 159–161 | Erfassungs-Liste 3: der Fehlschlag braucht keine Sonderregel (gemessen: tool_response fehlt) | a | Festlegung | Grenzfall (a/c) | 272 | — | — (kein Zeiger) |
| U06 | 162–166 | Erfassungs-Liste 4: model_version ist der einzige Rohstring, strukturelle Schranke | a | Festlegung | sicher | 343 | — | — (kein Zeiger) |
| U07 | 167–190 | Erfassungs-Liste 5: Zähler nur im Vordergrund; Vordergrund nicht mehr anforderbar (2026-07-29/08-15/08-21) | c | Messung, Grenze | Grenzfall (c/d) | 2014 | — | Z022, Z023, Z024 |
| U08 | 191–196 | Positiv-Liste ist bewacht (Wächter-Nennung) | e | Wächter-Zuordnung | sicher | 459 | TestFailedAgentCallCapturesNothing · TestNoResponseFreetextReachesSpan · TestUnlistedResponseKeyStaysOut · Fall 123 · Fall 124 · Fall 125 · Fall 126 · Fall 127 | — (kein Zeiger) |
| U09 | 197–200 | START-KONVENTION für Rollen-Läufe (Lead) | a | Prozess-Konvention | Grenzfall (a/e) | 265 | — | Z022, Z023, Z024 |
| U10 | 201–209 | Bedingung 1: unter dem Rollen-Typ per @-Erwähnung; Belegklasse fremde Doku | a | Prozess-Konvention, Herkunft | Grenzfall (a/e) | 646 | — | — (kein Zeiger) |
| U11 | 210–226 | Bedingung 2: Hintergrund als einzige Betriebsart (Ausgang gemessen 2026-08-10/15/21) | c | Messung | Grenzfall (c/a) | 1426 | — | Z022, Z023 |
| U11b | 210–226 | Schlusssatz: die Konvention hat nur noch Bedingung 1 | a | Festlegung | Grenzfall (a/c) | 0 | → U11 (gleicher Zeilenbereich) | — |
| U12 | 227–241 | Die zwei Bedingungen sind unabhängig (gemessen, 2026-08-15) | c | Messung | Grenzfall (c/b) | 1237 | — | — (kein Zeiger) |
| U12b | 227–241 | PostToolUse feuert nach dem Aufruf, kleine Dauer ist die Dauer des Aufrufs | b | Begründung | Grenzfall (b/c) | 0 | → U12 (gleicher Zeilenbereich) | — |
| U13 | 242–256 | Bedingung 2: kein Wächter, weil nichts zu bewachen ist; Guard entscheidet nur die Aufrufform | b | Begründung, Grenze | Grenzfall (b/a) | 1195 | .claude/hooks/pretooluse-agent-guard.sh | Z022, Z023, Z024 |
| U14 | 257–279 | Bedingung 1 ist nicht durchgesetzt; Freitext-Felder ungemessen | c | Messung, Grenze | Grenzfall (c/e) | 1919 | — | — (kein Zeiger) |
| U15 | 280–291 | DASS Rollen-Arbeit als Rolle läuft, ohne Wächter | a | Prozess-Regel, Grenze | Grenzfall (a/e) | 1020 | — | — (kein Zeiger) |
| U15b | 280–291 | konstruktiv nicht durchsetzbar: der Wächter sähe den unterbliebenen Aufruf nicht | b | Begründung | sicher | 0 | → U15 (gleicher Zeilenbereich) | — |
| U16 | 292–302 | Berichtsgröße: Sammelposten-Anteil zeigt eine Form von zweien | b | Begründung, Grenze | Grenzfall (b/a) | 907 | — | — (kein Zeiger) |
| U17 | 303–305 | Der Anteil steht im Bericht, nie als bestandene Schwelle | a | Festlegung, Begründung | sicher | 260 | — | — (kein Zeiger) |
| U18 | 306–310 | Gedeckt heißt Span mit Zählern | a | Festlegung | sicher | 346 | — | — (kein Zeiger) |
| U19 | 311–316 | Payload ist die Quelle; cwd, effort, prompt_id abgelehnt | a | Festlegung, Abgrenzung | sicher | 370 | — | — (kein Zeiger) |
| U20 | 317–322 | Erfasste Menge: drei verdrahtete Ereignisse, leerer Matcher | a | Festlegung | sicher | 429 | — | Z057 |
| U20b | 317–322 | belegt: live liegen Spans für sieben Werkzeuge vor | c | Messung | Grenzfall (c/a) | 0 | → U20 (gleicher Zeilenbereich) | — |
| U21 | 323–334 | SubagentStart erfasst den Start, Ablageort im Strom des Subagenten | a | Festlegung | sicher | 981 | — | — (kein Zeiger) |
| U21b | 323–334 | SubagentStart-Schlüsselmenge gemessen am 2026-08-08 | c | Messung | sicher | 0 | → U21 (gleicher Zeilenbereich) | Z063, Z067, Z098 |
| U22 | 335–339 | Der Hintergrund-Fall ist gemessen (Start-Span ohne Verbrauchs-Achse am Agent-Span) | c | Messung | sicher | 298 | — | — (kein Zeiger) |
| U23 | 340–345 | Nicht erfasst und nicht behauptet: geblockter Aufruf, SubagentStop | a | Festlegung, Grenze | sicher | 412 | — | — (kein Zeiger) |
| U24 | 346–354 | Der Strom ist (session, agent) — die Felder, nicht der Dateiname; zwei bindende Regeln | a | Festlegung | sicher | 663 | make span-clean | Z062 |
| U24b | 346–354 | Doppelvergabe von seq erzeugt keine Lücke | b | Begründung | sicher | 0 | → U24 (gleicher Zeilenbereich) | — |
| U25 | 355–358 | Sechs erklärte Abweichungen, drei Regelblöcke des Observability-Moduls | d | Abweichung | sicher | 246 | — | Z001, Z002 |
| U26 | 359–371 | Zuordnung der Abweichungen 1 bis 6 zu den Modul-Regeln | d | Abweichung | sicher | 699 | — | — (kein Zeiger) |
| U27 | 372–395 | Abweichung 1: Cache-Status unerreichbar | d | Abweichung | sicher | 1979 | — | Z024, Z026, Z027, Z085 |
| U28 | 396–404 | Abweichung 2: die PR-Nummer steht nicht im Span | d | Abweichung | sicher | 740 | — | Z080 |
| U29 | 405–414 | Abweichung 3: agent_role ist durchweg leer | d | Abweichung | sicher | 812 | — | — (kein Zeiger) |
| U30 | 415–420 | Kanonische Namen der Agenten-Typen (sechs Rollen-Namen, klein) | a | Festlegung | Grenzfall (a/d) | 401 | — | Z038, Z039 |
| U31 | 421–426 | Abweichung 3: was auch dann nicht abgedeckt ist | d | Abweichung | sicher | 395 | — | — (kein Zeiger) |
| U32 | 427–433 | Splitting-Regel: anteilig nach Tool-Calls, Rest weitergegeben | a | Festlegung | sicher | 556 | — | Z065, Z095, Z096 |
| U33 | 434–441 | Splitting-Ausnahme: keine Rolle trägt Tool-Calls, Sammelposten bleibt unverteilt | a | Festlegung | sicher | 651 | — | — (kein Zeiger) |
| U34 | 442–449 | Warum diese Splitting-Regel und nicht die andere | b | Begründung | sicher | 649 | — | Z095 |
| U35 | 450–453 | Was die Regel nicht ist: eine Messung | b | Begründung, Grenze | Grenzfall (b/d) | 281 | — | — (kein Zeiger) |
| U36 | 454–458 | Lesevorschrift: leeres agent_role heißt unbekannt, nie ohne Rolle | a | Festlegung | sicher | 298 | — | Z064, Z069, Z072, Z074, Z076, Z087 |
| U37 | 459–469 | Prüfreihenfolge: Splitting angewendet · Größe genannt · nie ungeteilt führen | a | Festlegung | sicher | 818 | — | Z066, Z072, Z074, Z087, Z093 |
| U38 | 470–472 | Nicht gemessen und deshalb offen: Nutzer-Aufruf | c | Grenze | Grenzfall (c/d) | 209 | — | — (kein Zeiger) |
| U39 | 473–477 | Abweichung 4: Altbestände werden nicht entfernt | d | Abweichung | sicher | 376 | make span-clean | Z028, Z030 |
| U40 | 478–481 | Abweichung 5 (Lead): Hintergrund-Lauf ohne Verbrauchs-Achse | d | Abweichung | sicher | 326 | — | — (kein Zeiger) |
| U41 | 482–488 | Abweichung 5.1: nicht ableitbar (gemessen) | c | Messung | sicher | 620 | — | — (kein Zeiger) |
| U42 | 489–503 | Abweichung 5.2: nicht vermeidbar; Guard entscheidet die Lesbarkeit der Aufrufform | d | Begründung, Abweichung | Grenzfall (d/a) | 1242 | Fall 139 · Fall 150 · test/agent-guard.bats · .claude/hooks/pretooluse-agent-guard.sh · make test | — (kein Zeiger) |
| U42b | 489–503 | bewacht von test/agent-guard.bats, Fälle 139 und 150 | e | Wächter-Zuordnung | sicher | 0 | → U42 (gleicher Zeilenbereich) | — |
| U43 | 504–518 | Abweichung 5.3 (a): Typ ohne Datei; der Bestand trägt den Span (2026-08-15) | c | Messung | Grenzfall (c/d) | 1353 | — | — (kein Zeiger) |
| U44 | 519–534 | Abweichung 5.3 (b): kein Sensor prüft die Verdrahtung; fünf Prüfstellen in drei Dateien | c | Messung, Grenze | Grenzfall (c/e) | 1417 | TestEnforce_EmitsAllMechanicFiles · TestEnforce_SettingsWiresBothHooks · Fall 32 · internal/emit/enforce_test.go · harness/tools/smoke.sh | Z031 |
| U45 | 535–549 | Abweichung 5.3 (c): Guard entscheidet den Start, nicht den Ausgang | c | Messung | Grenzfall (c/d) | 1238 | — | — (kein Zeiger) |
| U46 | 550–556 | Abweichung 5: die Abweichung selbst (Span ohne Zähler; Quelle nicht gepinnt) | d | Abweichung | sicher | 556 | — | Z022, Z023, Z024, Z094, Z097 |
| U47 | 557–561 | Abweichung 6 (Lead): der Haupt-Kontext hat keine Zahl | d | Abweichung | sicher | 390 | — | — (kein Zeiger) |
| U48 | 562–569 | Abweichung 6.1 und 6.2: Herkunft der Zähler gemessen, nicht ableitbar | c | Messung | sicher | 644 | — | — (kein Zeiger) |
| U49 | 570–583 | Abweichung 6.3: zwei Quellen geprüft; Rest gelesen statt gemessen | c | Messung, Grenze | Grenzfall (c/d) | 1133 | — | — (kein Zeiger) |
| U50 | 584–590 | Abweichung 6: die Abweichung selbst (Bilanz über Subagenten-Läufe) | d | Abweichung | sicher | 484 | — | Z001, Z003, Z004, Z005, Z006, Z007, Z008, Z010, Z026 |
| U51 | 591–612 | Bewacht (Lead) und Punkt 1: Eigenschaften des Emitters als Prozess (Fälle 107 bis 115) | e | Wächter-Zuordnung | sicher | 1735 | test/mutations/107-span-klemme-entfernt.sh · test/mutations/108-span-schema-offen.sh · test/mutations/109-span-folgenummer-eingefroren.sh · test/mutations/110-span-pflichtfeld-verschwindet.sh · test/mutations/111-span-korrelationsfeld-verschwindet.sh · test/mutations/112-span-stdout-geschwaetzig.sh · test/mutations/113-span-ablageort-getrackt.sh · test/mutations/114-span-lock-verzeichnis.sh · test/mutations/115-span-ergebnis-inhalt.sh · Fall 107 · cmd/ai-harness-init/span_emit_test.go · internal/span/span_test.go · make span-check | — (kein Zeiger) |
| U52 | 613–619 | Bewacht: der Einstiegspunkt selbst (drei Tests, Fall 154) | e | Wächter-Zuordnung | sicher | 597 | TestClampSurvivesBrokenPayload · TestEmitWritesSpanFromHook · TestSubkommandoRouting_ReportSchreibtBilanz · test/mutations/154-unterkommando-routing-vertauscht.sh | — (kein Zeiger) |
| U52b | 613–619 | warum der Fall nötig ist: kein eigenes Binär trennt mehr | b | Begründung | sicher | 0 | → U52 (gleicher Zeilenbereich) | — |
| U53 | 620–627 | Erfassung aus tool_response 1: keines der vier Freitext-Felder (Lead, Fälle 123 bis 126) | e | Wächter-Zuordnung | sicher | 501 | TestNoResponseFreetextReachesSpan · test/mutations/123-span-ergebnis-content.sh · test/mutations/124-span-ergebnis-prompt.sh · test/mutations/125-span-ergebnis-description.sh · test/mutations/126-span-ergebnis-outputfile.sh | — (kein Zeiger) |
| U54 | 628–632 | Erfassung 2: ungelisteter Schlüssel bleibt draußen (Fall 127 tragend) | e | Wächter-Zuordnung | sicher | 428 | TestUnlistedResponseKeyStaysOut · test/mutations/127-span-positivliste-negiert.sh | — (kein Zeiger) |
| U55 | 633–636 | Erfassung 3: Achse ist der Werkzeug-Name (Fall 133) | e | Wächter-Zuordnung | sicher | 319 | TestOnlyAgentToolGetsResponseValues · test/mutations/133-span-werkzeugachse-geweitet.sh | — (kein Zeiger) |
| U56 | 637–641 | Erfassung 4: B1, Rolle nie aus dem Argument (Fall 132) | e | Wächter-Zuordnung | sicher | 378 | TestAgentGetsNoArgumentFields · test/mutations/132-span-rolle-aus-argument.sh | — (kein Zeiger) |
| U57 | 642–645 | Erfassung 5: B2, Agent auf keiner Gattungszeile (Fall 135) | e | Wächter-Zuordnung | sicher | 266 | TestAgentGetsNoArgumentFields · test/mutations/135-span-agent-auf-gattungszeile.sh | — (kein Zeiger) |
| U58 | 646–650 | Erfassung 6: Normalisierung gegen die sechs Namen (Fall 128) | e | Wächter-Zuordnung | sicher | 340 | TestSpawnedRoleIsNormalised · test/mutations/128-span-rolle-unnormalisiert.sh | — (kein Zeiger) |
| U59 | 651–653 | Erfassung 7: Schranke verwirft statt zu kürzen (Fall 129) | e | Wächter-Zuordnung | sicher | 244 | TestResolvedModelIsStructurallyBounded · test/mutations/129-span-modellschranke-kuerzt.sh | — (kein Zeiger) |
| U60 | 654–677 | Erfassung 8: kein halber Span; drei von neun Einträgen gebunden, sechs nicht | e | Wächter-Zuordnung, Grenze | Grenzfall (e/c) | 2031 | TestFailedAgentCallCapturesNothing · test/mutations/134-span-zaehler-praesent-leer.sh · test/mutations/136-span-ausgabezaehler-praesent-leer.sh · test/mutations/137-span-rollenfeld-praesent-leer.sh · make mutate | Z075 |
| U61 | 678–680 | Erfassung 9: Gegenprobe tool=Agent (Fall 131) | e | Wächter-Zuordnung | sicher | 254 | TestAgentGetsNoArgumentFields · TestFailedAgentCallCapturesNothing · test/mutations/131-span-werkzeugname-leer.sh | — (kein Zeiger) |
| U62 | 681–697 | Draht-Form von spawned_role (Fälle 137, 138; Herkunfts-Achse ohne Zahn) | e | Wächter-Zuordnung | sicher | 1468 | TestAgentGetsNoArgumentFields · TestFailedAgentCallCapturesNothing · test/mutations/137-span-rollenfeld-praesent-leer.sh · test/mutations/138-span-rollenfeld-praesent-leer-erfolgsfall.sh | Z089, Z091, Z092 |
| U62b | 681–697 | warum zwei Einträge zwei Zähne brauchen | b | Begründung | sicher | 0 | → U62 (gleicher Zeilenbereich) | — |
| U63 | 698–707 | Voraussetzung der Gegenprobe: tool bleibt Pflicht, Agent erkennbar (Fälle 130, 131) | e | Wächter-Zuordnung | sicher | 789 | TestAgentGetsNoArgumentFields · TestFailedAgentCallCapturesNothing · TestMandatoryFieldsAlwaysPresent · test/mutations/130-span-werkzeugfeld-verschwindet.sh · test/mutations/131-span-werkzeugname-leer.sh | — (kein Zeiger) |
| U64 | 708–718 | Was hier keinen Zahn hat: die mustContain-Gegenproben | e | Wächter-Zuordnung, Grenze | sicher | 857 | Fall 123 · Fall 127 · make mutate · make test · make test-go | — (kein Zeiger) |
| T | 59–60, 99–135 | Tabellenzeilen SPEC-001 bis SPEC-034 (Bestand, nicht klassifiziert; nur Wächter-Träger) | — | — | — | 0 | TestAgentGetsNoArgumentFields · TestCommandArgcEndsWithItsSegment · TestCommandBackslashBeforeBlankIsAWord · TestCommandProgramBehindNavigationIsAPlainWord · TestCommandProgramFirstWordKeepsItsGluedRest · TestCommandProgramKeepsNavigationOnMultilineCommands · TestCommandProgramKeepsNavigationWhenItsEdgeIsUnsure · TestCommandProgramNamesAProgramNotAnOperator · TestCommandProgramNeverEmitsAssignmentValueFragments · TestCommandProgramSkipsNavigationSegments · TestCommandProgramWithholdsProgramForEachUnsureValueChar · TestCommandWordsSplitAtTab · TestFailedAgentCallCapturesNothing · TestMandatoryFieldsAlwaysPresent · TestResolvedModelIsStructurallyBounded · TestSpawnedRoleIsNormalised · Fall 110 · Fall 111 · Fall 128 · Fall 129 · Fall 130 · Fall 132 · Fall 134 · Fall 136 · Fall 137 · Fall 138 · Fall 404 · Fall 405 · Fall 406 · Fall 407 · Fall 408 · Fall 476 · Fall 477 · Fall 478 · Fall 479 · Fall 480 · Fall 481 · Fall 482 · Fall 483 · Fall 484 · Fall 485 · Fall 486 · Fall 487 · internal/span/span.go · internal/span/span_test.go · make gates | Z030, Z044, Z045, Z046, Z047, Z048, Z049, Z050, Z051, Z053, Z054, Z068, Z070, Z071, Z073, Z076, Z077, Z078, Z079, Z081, Z082, Z083, Z084, Z088, Z089, Z090, Z092, Z100 |

## 4. Grenzfälle und Übergaben an den Architect

Die Tabelle markiert **20** von 64 Einheiten und **4** der 10 zweiten Zeilen als
Grenzfall; die Klassenwahl entscheidet dieser Bericht nicht. Die folgenden Punkte sind die Fragen, die
sich an der gemessenen Menge stellen.

1. **Klasse `d` (Abweichung) gegen die Aufnahme-Regel.** Die Aufnahme-Regel (`spec/spezifikation.md`
   Zeilen 20–23) nennt unter *Nicht hierher gehören* „die **Abweichung** von der adoptierten Baseline
   (repo-lokales Konventionsdokument)“. [MR-021](../../harness/conventions.md#mr-021) weist dagegen ausdrücklich „die sechs erklärten
   Abweichungen“ und „die Wächter-Bindungen“ nach §5 (`technische Festlegung, die mit ihrem Gegenstand
   wächst`) und „Abweichung von der adoptierten Baseline“ in das Konventionsdokument. Das Wort trägt
   zwei Gegenstände: die Abweichung von den Regeln des Observability-Moduls (der Inhalt von §5) und die
   Abweichung einer Repo-Konvention von der Baseline (der Inhalt des Adaptions-Blocks). Die Tabelle
   führt die 12 Zeilen des ersten Gegenstands als `d` (8245 Bytes); ob `d` eine Klasse der Spec
   ist oder die Aufnahme-Regel und [MR-021](../../harness/conventions.md#mr-021) auseinanderlaufen, ist die Frage an den Architect.
2. **Wächter-Zuordnung passt in keine der vier Klassen.** 16 Zeilen der Klasse `e`, 10666 Bytes
   (23.2 % von 45889), sind Aufzählungen, welcher Test und welcher Fall welche Zusicherung bindet
   (`Bewacht`, Zeilen 591–718, und die zwei Sätze bei Positiv-Liste und Abweichung 5). Die Feldtabelle
   trägt dieselbe Aussage in ihrer Spalte *Sensor*. Ein Kandidat für eine eigene Klasse
   (*Kopplung / Wächter-Zuordnung*); zugleich sagt die Spec selbst, dass die Nennung unbewacht ist
   (Zeilen 82–91).
3. **Prozess-Konventionen gegen „etwas, gegen das gemessen werden kann“.** START-KONVENTION (U09,
   U10) und die Regel *DASS Rollen-Arbeit als Rolle läuft* (U15) legen Verhalten von Rollen fest, kein
   Wert, Feld oder Schranke; U15 und U13 nennen selbst, dass kein Wächter besteht. Als `a` geführt,
   als Grenzfall (a/e) markiert.
4. **Messprotokoll mischt vier Aussagearten.** Klasse `c` hat 15 Zeilen (13508 Bytes), davon 11
   Grenzfälle: datierte Messungen (U22, U41, U48), Messungen mit Folge für eine Festlegung (U07, U11),
   Nicht-Messungen und Grenzen (U14, U38, U49) und Zählungen des Bestands (U44). Von den 13508 Bytes
   stehen 6405 (47.4 %) in den Prüfschritten der Abweichungen 5 und 6 (U41, U43–U45, U48, U49), die
   selbst in einer Einheit der Klasse `d` liegen (2998 Bytes in U40, U42, U46, U47, U50). Die Frage:
   hängt die Klasse an der Abweichung als Ganzes oder wird der Prüfschritt abgetrennt?
5. **Die 35 Zeilen mit „gemessen“ oder Datum** (Risiko 3 des Slice-Plans): 24 stehen in Einheiten der
   Klasse `c`, 11 in anderen (Zusagen, Begründungen und Wächter-Zuordnungen, die das Wort benutzen oder
   ein Datum als Beleg nennen). Die Lesung *gemessen/Datum gleich Messprotokoll* trifft also für
   24 von 35 Zeilen zu.
6. **Ort der Messprotokolle.** [MR-021](../../harness/conventions.md#mr-021) nennt `docs/reviews/2026-08-02-span-schema-messreihen.md` als
   Ort für datierte Messungen; die Datei liegt im Repo. Ob §5-Messungen dorthin
   wandern, ist Sache der Klassen-Entscheidung.
7. **Einheit Absatz** (Risiko 1). 10 Einheiten tragen zwei Klassen und stehen als zweite Zeile; die
   zwei Blöcke über 6 KB sind in acht (ab Zeile 470: U38 bis U45) und vierzehn Einheiten (ab Zeile 591:
   U51 bis U64) geschnitten. Der Absatz allein hätte bei diesen 10 Einheiten je eine der zwei Klassen verfehlt.
8. **Einzelne Grenzfälle mit Frage.** U30 (kanonische Namen): der Text nennt den Wert selbst eine
   „technische Festlegung“, er steht aber innerhalb von Abweichung 3 · U60: die Grenze (drei von neun
   Listeneinträgen gebunden) steht in der Wächter-Zuordnung · U42: die Beschreibung des Guards steht im
   Prüfschritt einer Abweichung · U16 und U35: Grenz-Aussagen über eine Kennzahl bzw. über die Regel, die
   weder Festlegung noch Begründung sind.

## 5. Zeiger-Inventar

Kommando: `grep -rnE 'spezifikation\.md' internal test cmd harness/tools docs/plan/adr`, sortiert nach
Datei und Zeile, die Zuordnung stammt aus dem gelesenen Kontext der Stelle (bei den Pfadlisten und bei den Stellen in ADR-0016, ADR-0017 und ADR-0057 ist nur die Zeile selbst gelesen). Das Kommando nennt
**100** Stellen. Einheit `T` sind die Tabellenzeilen `SPEC-001` bis `SPEC-034` und der Kopf der
Tabelle, `K` der Vorspann von §5 (Zeilen 62–98, außerhalb der klassifizierten Zeilen), `P` eine
Pfadliste oder ein Fixture, das die Datei ohne Passage nennt, `—` eine Stelle, die die Datei oder §5
als Ganzes nennt und keine Einheit anspricht.

| Verteilung | Stellen |
|---|---|
| mit mindestens einer Einheit `U..` | 44 |
| nur Tabellenzeilen (`T`) | 23 |
| nur Vorspann (`K`) | 3 |
| Pfadliste / Fixture (`P`) | 7 |
| ohne zuordenbare Einheit (`—`) | 23 |
| Summe | 100 |
| davon Kommentare in Code, Skripten, Fällen | 44 |
| davon ADR-Text | 51 |
| davon Pfadliste / Fixture | 5 |

| Nr | Stelle | Einheit(en) | Art |
|---|---|---|---|
| Z001 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:24` | U25,U50 | ADR-Text (eingefroren) |
| Z002 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:41` | U25 | ADR-Text (eingefroren) |
| Z003 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:51` | U50 | ADR-Text (eingefroren) |
| Z004 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:70` | U50 | ADR-Text (eingefroren) |
| Z005 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:76` | U50 | ADR-Text (eingefroren) |
| Z006 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:145` | U50 | ADR-Text (eingefroren) |
| Z007 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:168` | U50 | ADR-Text (eingefroren) |
| Z008 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:185` | U50 | ADR-Text (eingefroren) |
| Z009 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:249` | K | ADR-Text (eingefroren) |
| Z010 | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:286` | U50 | ADR-Text (eingefroren) |
| Z011 | `docs/plan/adr/0013-technik-stratum-als-zielort.md:37` | — | ADR-Text (eingefroren) |
| Z012 | `docs/plan/adr/0013-technik-stratum-als-zielort.md:38` | — | ADR-Text (eingefroren) |
| Z013 | `docs/plan/adr/0013-technik-stratum-als-zielort.md:77` | — | ADR-Text (eingefroren) |
| Z014 | `docs/plan/adr/0013-technik-stratum-als-zielort.md:95` | — | ADR-Text (eingefroren) |
| Z015 | `docs/plan/adr/0013-technik-stratum-als-zielort.md:154` | — | ADR-Text (eingefroren) |
| Z016 | `docs/plan/adr/0013-technik-stratum-als-zielort.md:164` | — | ADR-Text (eingefroren) |
| Z017 | `docs/plan/adr/0013-technik-stratum-als-zielort.md:176` | — | ADR-Text (eingefroren) |
| Z018 | `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:57` | — | ADR-Text (eingefroren) |
| Z019 | `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:63` | — | ADR-Text (eingefroren) |
| Z020 | `docs/plan/adr/0016-verweis-traegt-tag-und-zitat.md:79` | — | ADR-Text (eingefroren) |
| Z021 | `docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md:107` | — | ADR-Text (eingefroren) |
| Z022 | `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:27` | U07,U09,U11,U13,U46 | ADR-Text (eingefroren) |
| Z023 | `docs/plan/adr/0019-agent-guard-prueft-die-aufrufform.md:368` | U07,U09,U11,U13,U46 | ADR-Text (eingefroren) |
| Z024 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:30` | U07,U09,U13,U27,U46 | ADR-Text (eingefroren) |
| Z025 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:72` | — | ADR-Text (eingefroren) |
| Z026 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:334` | U27,U50 | ADR-Text (eingefroren) |
| Z027 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:363` | U27 | ADR-Text (eingefroren) |
| Z028 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:374` | U39 | ADR-Text (eingefroren) |
| Z029 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:512` | — | ADR-Text (eingefroren) |
| Z030 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:569` | U39,T | ADR-Text (eingefroren) |
| Z031 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:593` | U44 | ADR-Text (eingefroren) |
| Z032 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:640` | — | ADR-Text (eingefroren) |
| Z033 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:641` | — | ADR-Text (eingefroren) |
| Z034 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:642` | — | ADR-Text (eingefroren) |
| Z035 | `docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md:652` | — | ADR-Text (eingefroren) |
| Z036 | `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:107` | K | ADR-Text (eingefroren) |
| Z037 | `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:660` | K | ADR-Text (eingefroren) |
| Z038 | `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:212` | U30 | ADR-Text (eingefroren) |
| Z039 | `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:293` | U30 | ADR-Text (eingefroren) |
| Z040 | `docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:307` | — | ADR-Text (eingefroren) |
| Z041 | `docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md:200` | — | ADR-Text (eingefroren) |
| Z042 | `docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md:24` | — | ADR-Text (eingefroren) |
| Z043 | `docs/plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md:25` | — | ADR-Text (eingefroren) |
| Z044 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:14` | T | ADR-Text (eingefroren) |
| Z045 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:20` | T | ADR-Text (eingefroren) |
| Z046 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:39` | T | ADR-Text (eingefroren) |
| Z047 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:47` | T | ADR-Text (eingefroren) |
| Z048 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:57` | T | ADR-Text (eingefroren) |
| Z049 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:61` | T | ADR-Text (eingefroren) |
| Z050 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:100` | T | ADR-Text (eingefroren) |
| Z051 | `docs/plan/adr/0071-kopplung-feldliste-spec-ist-existenz-abgleich.md:148` | T | ADR-Text (eingefroren) |
| Z052 | `harness/tools/full-smoke.sh:926` | — | Kommentar (Rang-Zeiger) |
| Z053 | `harness/tools/full-smoke.sh:1281` | T | Kommentar (Rang-Zeiger) |
| Z054 | `harness/tools/span-check.sh:114` | T | Kommentar (Rang-Zeiger) |
| Z055 | `internal/emit/baumaussage.go:97` | P | Pfadliste / Fixture |
| Z056 | `internal/emit/emit_test.go:76` | P | Pfadliste / Fixture |
| Z057 | `internal/emit/enforce_test.go:524` | U20 | Kommentar (Rang-Zeiger) |
| Z058 | `internal/emit/fieldlist.go:12` | P | Kommentar (nennt das Stratum, keine Passage) |
| Z059 | `internal/emit/templates/d-check.yml:79` | P | Kommentar (Rang-Zeiger) |
| Z060 | `internal/emit/templates_test.go:152` | P | Pfadliste / Fixture |
| Z061 | `internal/emit/templates_test.go:297` | P | Pfadliste / Fixture |
| Z062 | `internal/report/report.go:80` | U24 | Kommentar (Rang-Zeiger) |
| Z063 | `internal/report/report.go:154` | U21b | Kommentar (Rang-Zeiger) |
| Z064 | `internal/report/report.go:179` | U36 | Kommentar (Rang-Zeiger) |
| Z065 | `internal/report/report.go:190` | U32 | Kommentar (Rang-Zeiger) |
| Z066 | `internal/report/report_test.go:73` | U37 | Kommentar (Rang-Zeiger) |
| Z067 | `internal/report/report_test.go:404` | U21b | Kommentar (Rang-Zeiger) |
| Z068 | `internal/span/emit.go:39` | T | Kommentar (Rang-Zeiger) |
| Z069 | `internal/span/emit.go:176` | U36 | Kommentar (Rang-Zeiger) |
| Z070 | `internal/span/fieldlist_test.go:153` | T | Kommentar (Rang-Zeiger) |
| Z071 | `internal/span/response.go:22` | T | Kommentar (Rang-Zeiger) |
| Z072 | `internal/span/response.go:96` | U36,U37 | Kommentar (Rang-Zeiger) |
| Z073 | `internal/span/response.go:104` | T | Kommentar (Rang-Zeiger) |
| Z074 | `internal/span/response_test.go:231` | U36,U37 | Kommentar (Rang-Zeiger) |
| Z075 | `internal/span/response_test.go:322` | U60 | Kommentar (Rang-Zeiger) |
| Z076 | `internal/span/response_test.go:333` | U36,T | Kommentar (Rang-Zeiger) |
| Z077 | `internal/span/response_test.go:338` | T | Kommentar (Rang-Zeiger) |
| Z078 | `internal/span/span.go:206` | T | Kommentar (Rang-Zeiger) |
| Z079 | `internal/span/span.go:219` | T | Kommentar (Rang-Zeiger) |
| Z080 | `internal/span/span_test.go:1123` | U28 | Kommentar (Rang-Zeiger) |
| Z081 | `internal/span/span_test.go:1173` | T | Kommentar (Rang-Zeiger) |
| Z082 | `internal/span/span_test.go:1186` | T | Kommentar (Rang-Zeiger) |
| Z083 | `test/mutations/108-span-schema-offen.sh:6` | T | Kommentar (Rang-Zeiger) |
| Z084 | `test/mutations/110-span-pflichtfeld-verschwindet.sh:9` | T | Kommentar (Rang-Zeiger) |
| Z085 | `test/mutations/126-span-ergebnis-outputfile.sh:11` | U27 | Kommentar (Rang-Zeiger) |
| Z086 | `test/mutations/127-span-positivliste-negiert.sh:16` | — | Kommentar (Rang-Zeiger) |
| Z087 | `test/mutations/128-span-rolle-unnormalisiert.sh:8` | U36,U37 | Kommentar (Rang-Zeiger) |
| Z088 | `test/mutations/131-span-werkzeugname-leer.sh:10` | T | Kommentar (Rang-Zeiger) |
| Z089 | `test/mutations/134-span-zaehler-praesent-leer.sh:13` | T,U62 | Kommentar (Rang-Zeiger) |
| Z090 | `test/mutations/136-span-ausgabezaehler-praesent-leer.sh:11` | T,U03 | Kommentar (Rang-Zeiger) |
| Z091 | `test/mutations/136-span-ausgabezaehler-praesent-leer.sh:24` | U62 | Kommentar (Rang-Zeiger) |
| Z092 | `test/mutations/137-span-rollenfeld-praesent-leer.sh:9` | T,U62 | Kommentar (Rang-Zeiger) |
| Z093 | `test/mutations/141-report-sammelposten-anteil-entfernt.sh:10` | U37 | Kommentar (Rang-Zeiger) |
| Z094 | `test/mutations/142-report-abdeckung-entfernt.sh:11` | U46 | Kommentar (Rang-Zeiger) |
| Z095 | `test/mutations/144-report-splitting-gleichmaessig.sh:8` | U32,U34 | Kommentar (Rang-Zeiger) |
| Z096 | `test/mutations/145-report-rollenlose-im-nenner.sh:12` | U32 | Kommentar (Rang-Zeiger) |
| Z097 | `test/mutations/146-report-abdeckung-nur-mit-zaehlern.sh:10` | U46 | Kommentar (Rang-Zeiger) |
| Z098 | `test/mutations/147-report-spawn-als-toolcall.sh:9` | U21b | Kommentar (Rang-Zeiger) |
| Z099 | `test/mutations/297-emittierte-matrix-richtungspruefung-fehlt.sh:10` | P | Pfadliste / Fixture |
| Z100 | `test/mutations/488-feldliste-program-notiz-widerlegt.sh:8` | T | Kommentar (Rang-Zeiger) |

## 6. Lastenheft-Vorschlag

Kandidat ist ein Anforderungs-Eintrag des Lastenhefts; die Fundstelle nennt Kriterium und Zeile in
`spec/lastenheft.md`. *Bindung*: **einzeln** — das Lastenheft nennt den Gegenstand in eigenem Wortlaut ·
**pauschal** — nur der Oberbegriff · **nahe** — verwandte Aussage, anderer Gegenstand · **kein LH
gefunden** — eine **benannte Spec-Lücke**. Die Suche lief über `grep -nEi` auf Span, Token, Subagent,
Rolle, Report, Guard, Erfassung, Bilanz im Lastenheft: einziger Träger ist
[LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Zeilen 257–316), sonst nennen nur [LH-FA-11](../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren) und [LH-FA-12](../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren) den Träger als Nachbar (Zeilen 344, 391, 403, 437). **Ebene:**
[LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) fordert den Träger **im Zielrepo**; §5 beschreibt das Schema dieses Repos. Jede Bindung ist
ein Kandidat, dessen Ebenen-Passung der Architect prüft.

### 6.1 Einheiten der Klasse `a`

| Nr | Einheit | Kandidat und Fundstelle |
|---|---|---|
| U01 | Werkzeug-Achse ist der Name, nicht die Antwortgestalt | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Betrieb fail-open, Umfang fail-closed (Z. 291–292) — nahe (nennt Namens-Achse, nicht die Antwortgestalt) |
| U02 | Erfassung aus tool_response ist eine Positiv-Liste (Lead) | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Redaktion (Z. 293–298) — einzeln |
| U03 | Erfassungs-Liste 1: nur was responseKeys() nennt; Zählung 6/9/7 | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Redaktion (Z. 293–298) — einzeln (geschlossene Feldliste) · Zahlen 6/9/7: kein LH gefunden |
| U05 | Erfassungs-Liste 3: der Fehlschlag braucht keine Sonderregel (gemessen: tool_response fehlt) | kein LH gefunden |
| U06 | Erfassungs-Liste 4: model_version ist der einzige Rohstring, strukturelle Schranke | kein LH gefunden (X nur pauschal: kein Inhalt aus Argumenten) |
| U09 | START-KONVENTION für Rollen-Läufe (Lead) | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Rolle besetzt (Z. 289–290) — pauschal · [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Benannte Grenze (Z. 315–316) — nahe (Rollen-Achse ruht auf Adopter-Disziplin) |
| U10 | Bedingung 1: unter dem Rollen-Typ per @-Erwähnung; Belegklasse fremde Doku | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Rolle besetzt (Z. 289–290) — pauschal |
| U11b | Schlusssatz: die Konvention hat nur noch Bedingung 1 | kein LH gefunden |
| U15 | DASS Rollen-Arbeit als Rolle läuft, ohne Wächter | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Benannte Grenze (Z. 315–316) — einzeln (Emission führt keinen Wächter über die Aufrufform) |
| U17 | Der Anteil steht im Bericht, nie als bestandene Schwelle | kein LH gefunden |
| U18 | Gedeckt heißt Span mit Zählern | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Leser (Z. 303–306) — nahe (ohne Zähler keine Bilanz · nennt nicht den Span) |
| U19 | Payload ist die Quelle; cwd, effort, prompt_id abgelehnt | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Redaktion (Z. 293–298) — pauschal · die drei Ablehnungen: kein LH gefunden |
| U20 | Erfasste Menge: drei verdrahtete Ereignisse, leerer Matcher | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Happy Path (lastenheft.md Z. 287–288) — pauschal (Span je Werkzeug-Aufruf) · Ereignis-Liste: kein LH gefunden |
| U21 | SubagentStart erfasst den Start, Ablageort im Strom des Subagenten | kein LH gefunden |
| U23 | Nicht erfasst und nicht behauptet: geblockter Aufruf, SubagentStop | kein LH gefunden |
| U24 | Der Strom ist (session, agent) — die Felder, nicht der Dateiname; zwei bindende Regeln | kein LH gefunden |
| U30 | Kanonische Namen der Agenten-Typen (sechs Rollen-Namen, klein) | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Beschreibung (Z. 259–266) — nahe (nennt Rollen-Typen unter .claude/agents/, nicht die sechs Namen) |
| U32 | Splitting-Regel: anteilig nach Tool-Calls, Rest weitergegeben | kein LH gefunden |
| U33 | Splitting-Ausnahme: keine Rolle trägt Tool-Calls, Sammelposten bleibt unverteilt | kein LH gefunden |
| U36 | Lesevorschrift: leeres agent_role heißt unbekannt, nie ohne Rolle | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Rolle besetzt (Z. 289–290) — einzeln (wortgleich: leer heißt unbekannt, nie rollenlos) |
| U37 | Prüfreihenfolge: Splitting angewendet · Größe genannt · nie ungeteilt führen | kein LH gefunden (L nur pauschal) |

### 6.2 Tabellenzeilen `SPEC-001` bis `SPEC-034`

| Zeile | Feld / Werkzeug | Kandidat und Fundstelle |
|---|---|---|
| `SPEC-001` | `model_version` — Länge | kein LH gefunden |
| `SPEC-002` | `model_version` — Zeichensatz | kein LH gefunden |
| `SPEC-003` | `seq` | kein LH gefunden |
| `SPEC-004` | `ts` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Happy Path (lastenheft.md Z. 287–288) — pauschal (‚volle Pflicht-Spalte‘, das Feld steht nicht einzeln) |
| `SPEC-005` | `event` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Happy Path (lastenheft.md Z. 287–288) — pauschal (‚volle Pflicht-Spalte‘, das Feld steht nicht einzeln) |
| `SPEC-006` | `tool` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Happy Path (lastenheft.md Z. 287–288) — pauschal (‚volle Pflicht-Spalte‘, das Feld steht nicht einzeln) |
| `SPEC-007` | `tool_use_id` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Happy Path (lastenheft.md Z. 287–288) — pauschal (‚volle Pflicht-Spalte‘, das Feld steht nicht einzeln) |
| `SPEC-008` | `session`, `agent` | kein LH gefunden |
| `SPEC-009` | `agent_type` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Rolle besetzt (Z. 289–290) — pauschal |
| `SPEC-010` | `agent_role` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Rolle besetzt (Z. 289–290) — einzeln (‚leer heißt unbekannt‘) |
| `SPEC-011` | `slice` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Beschreibung (Z. 259–266) — einzeln (Korrelations-Achse Slice, Anforderung, Entscheidung) |
| `SPEC-012` | `requirement` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Beschreibung (Z. 259–266) — einzeln (Korrelations-Achse Slice, Anforderung, Entscheidung) |
| `SPEC-013` | `adr` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Beschreibung (Z. 259–266) — einzeln (Korrelations-Achse Slice, Anforderung, Entscheidung) |
| `SPEC-014` | `branch`, `commit` | kein LH gefunden |
| `SPEC-015` | `status` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Happy Path (lastenheft.md Z. 287–288) — pauschal (‚volle Pflicht-Spalte‘, das Feld steht nicht einzeln) |
| `SPEC-016` | `permission_mode` | kein LH gefunden |
| `SPEC-017` | `path` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Redaktion (Z. 293–298) — einzeln (Ableitung: Pfad, Länge, Fingerabdruck) |
| `SPEC-018` | `bytes`, `sha256_16` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Redaktion (Z. 293–298) — einzeln (Ableitung: Pfad, Länge, Fingerabdruck) |
| `SPEC-019` | `duration_ms` | kein LH gefunden |
| `SPEC-020` | `result_bytes` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Redaktion (Z. 293–298) — einzeln (Ableitung: Pfad, Länge, Fingerabdruck) |
| `SPEC-021` | `program`, `argc` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Redaktion (Z. 293–298) — pauschal (nie der Inhalt, eine Ableitung) |
| `SPEC-022` | `spawned_role` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Rolle besetzt (Z. 289–290) — pauschal |
| `SPEC-023` | `input_tokens`, `output_tokens` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Beschreibung (Z. 259–266) — pauschal (Token-Attribution) · [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Leser (Z. 303–306) — pauschal (Verbrauchs-Zähler) |
| `SPEC-024` | `cache_creation_input_tokens`, `cache_read_input_tokens` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Beschreibung (Z. 259–266) — pauschal (Block Cache-Counter) |
| `SPEC-025` | `total_tokens` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Beschreibung (Z. 259–266) — pauschal (Token-Attribution) · [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Leser (Z. 303–306) — pauschal (Verbrauchs-Zähler) |
| `SPEC-026` | `total_duration_ms` | kein LH gefunden |
| `SPEC-027` | `total_tool_use_count` | kein LH gefunden |
| `SPEC-028` | `model_version` | kein LH gefunden |
| `SPEC-029` | `Write`, `Edit`, `MultiEdit`, `NotebookEdit` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Betrieb fail-open, Umfang fail-closed (Z. 291–292) — pauschal (namentlich geführtes Werkzeug) |
| `SPEC-030` | `Read` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Betrieb fail-open, Umfang fail-closed (Z. 291–292) — pauschal (namentlich geführtes Werkzeug) |
| `SPEC-031` | `Bash` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Betrieb fail-open, Umfang fail-closed (Z. 291–292) — pauschal (namentlich geführtes Werkzeug) |
| `SPEC-032` | `BashOutput` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Betrieb fail-open, Umfang fail-closed (Z. 291–292) — pauschal (namentlich geführtes Werkzeug) |
| `SPEC-033` | `Agent` | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Betrieb fail-open, Umfang fail-closed (Z. 291–292) — pauschal (namentlich geführtes Werkzeug) |
| `SPEC-034` | **jedes andere** | [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) Betrieb fail-open, Umfang fail-closed (Z. 291–292) — einzeln (nicht namentlich geführtes Werkzeug gibt nur Name und Status preis) |

### 6.3 Benannte Spec-Lücken

Die Zeilen ohne Kandidaten sind eine benannte Spec-Lücke, kein stilles Weglassen:

- Klasse `a`: **13** von 21 Zeilen: U03 U05 U06 U11b U17 U19 U20 U21 U23 U24 U32 U33 U37 
- Tabellenzeilen: **10** von 34: SPEC-001 SPEC-002 SPEC-003 SPEC-008 SPEC-014 SPEC-016 SPEC-019 SPEC-026 SPEC-027 SPEC-028 

Die übrigen Zeilen tragen einen Kandidaten aus den Kriterien von [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren).

## 7. Beobachtungen am Rande und Grenzen dieses Berichts

- **Sensor-Lage.** In `.d-check.yml` nennt allein die Pfadliste der Matrix-Klasse `spec-straten` die
  Spec-Datei (`grep -n 'spezifikation' .d-check.yml` → Zeile 350); die 44 Kommentar-Zeiger nennen §5
  oder eine benannte Passage. Ein Umbau bricht damit keinen Test, er bricht Zeiger (Spalte
  *Sensor-Abhängigkeit* der Tabelle: die Nummern der Kommentare, die die Einheit nennen).
- **Zeiger ohne Gegenstück.** [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nennt an Zeile 214 eine Abweichung *„`implementer` statt
  Implementation“* „in derselben §5“: `grep -c 'statt Implementation' spec/spezifikation.md` → 0.
  [ADR-0021](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) erwartet an Zeile 72 und 652 sechs Zeilen mit `CO-002` in zwei Dateien:
  `grep -c 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` →
  spec/spezifikation.md:0 .claude/hooks/pretooluse-agent-guard.sh:1. Beide ADRs bleiben
  unverändert ([AGENTS.md](../../AGENTS.md) §3.4); die Zeilen stehen hier als Befund für den Umbau.
- **Grenzen der Zuordnung.** Die Klassifikation der 64 Einheiten und die Zuordnung der 100
  Zeiger stammen aus einem Lauf und einem Kontext; die Urteile über Grenzfälle sind ausdrücklich nicht
  entschieden. Die Byte-Summe und die Vollständigkeit der Testnamen und Fall-Dateien sind maschinell
  gedeckt (§2), die Klassen-Zuordnung nicht: kein Sensor hält eine Zeile der Tabelle gegen den Text.
  Bei den Zeigern ist ein Kontext von wenigen Zeilen gelesen; eine Stelle mit Einheit `T` oder `—` kann bei
  weiterem Kontext eine Einheit ansprechen.
- **Spec unverändert.** `git diff --stat -- spec/` liefert 0 Zeilen.
