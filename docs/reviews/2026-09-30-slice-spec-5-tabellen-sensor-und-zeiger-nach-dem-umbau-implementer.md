# Implementer-Bericht — slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau

Rolle Implementer, 2026-09-30. Arbeitsstand: fünf Commits auf `main`, nicht gepusht. Der Slice ist nicht geschlossen
(kein Move, keine DoD-Häkchen, kein Self-Review).

## Diff-Übersicht je Stufe

| Stufe | Commit | Inhalt |
|---|---|---|
| 1 Sensor | `72ab4387` | `test/spec-tabellenform.bats` (2 Tests), Fälle 501 und 502 |
| 2 Zeiger | `6a022725` | `test/spec-zitate.bats`, Fall 503, Kommentar Fall 131, dazu Kommentare in 128 und 134 |
| 3 Sensor-Namen | `fe5a26c0` | 7 Zellen der Spalte `Sensor` tragen den Testnamen des Falls |
| 4 Nachzug | `a1599ed5`, `3ab9b2eb` | Fälle 502/503 shellcheck-clean; 19 `Lücke`-Zellen, 5 Zeilen verlassen die Spec, Kommentare |

## Liefer-Punkt 1 — der Sensor

`make mutate` führt für die bats-Stufe ein Fehlschlag-Muster (`failure_form` → `test-bats`: `not ok [0-9]+`); Fälle sind
anlegbar (`# verify: test-bats`). Kein Befund für den Planner.

- Test 1 „jede Tabelle mit SPEC-Zeilen trägt Präzisiert als letzte Spalte und umgekehrt": zählt je Tabelle (Block von
  `|`-Zeilen), ob sie eine `SPEC`-Zeile trägt und ob ihre Kopfzeile auf `| Präzisiert |` endet; verlangt
  `mit_spec == mit_praez == beides` und `mit_spec >= 1`. Schärfer als die Schranke der Fitness-Zeile (auch eine
  `Präzisiert`-Tabelle ohne `SPEC`-Zeile und eine versetzte Spalte werden rot).
- Test 2 „keine SPEC-Zeile trägt eine leere letzte Zelle": Zeile endet auf `| |`, außer nach `\`.
- Rot an der realen Quelle (`make mutate`, Bedingung 4 des Treibers: der benannte Test steht in der FAIL-Ausgabe):

```
mutate: ok      501-spec-praezisiert-spalte-gestrichen  -> jede Tabelle mit SPEC-Zeilen traegt Praezisiert als letzte Spalte und umgekehrt rot
mutate: ok      502-spec-praezisiert-zelle-leer         -> keine SPEC-Zeile traegt eine leere letzte Zelle rot
mutate: 3 ok, 0 Befund(e)    (Lauf mit 503, nach der Shellcheck-Korrektur)
```

501 streicht die Spalte in der Werkzeug-Tabelle (vier von fünf Kopfzeilen bleiben; der alte Zähler „mindestens 3" wäre
grün), 502 leert die Zelle von `SPEC-057` (`make docs-check` bleibt dabei grün). Jeder Fall trifft nur seinen Test:
501 ändert nur die Kopfzeile, 502 nur eine Zelle.
**Grenze, benannt:** der Sensor prüft Spalte und Nicht-Leere, nicht den Inhalt der Zelle (Anker-Link oder `Lücke`); den
Anker löst `make docs-check` auf. Kein Fall bindet die Selbst-Kalibrierung `mit_spec >= 1` einzeln.

## Liefer-Punkt 2 — der Zeiger

Fall 131 (Z. 9–13) nennt `SPEC-022` und `SPEC-082` statt eines Wortlauts; die Chronik-Halbsätze dort sind entfernt.
Das geschärfte Kommando lebt als `test/spec-zitate.bats` (ein Test, läuft in `make test`). Es verbindet die Zeilen eines
Kommentarblocks (`#` oder `//`), findet Zitate hinter `„` (Ende `“` oder ASCII-`"`), nimmt die im Umkreis von
250 Zeichen nach `spezifikation.md`, und hält sie whitespace-normalisiert gegen den Volltext der Spec (Groß-/Kleinschreibung
zählt). Ein Kommando, nicht mehrere (Rückführungs-Bedingung nicht eingetreten).
Rot gesehen: Fall 503 hängt an `internal/span/emit.go` ein zweizeiliges `//`-Zitat mit `„unterscheidbar bleibt es am
Pflichtfeld tool"` — `make mutate`: `ok … -> jedes woertliche Zitat der Spezifikation in einem Kommentar steht in
spec/spezifikation.md rot`. Das alte Kommando (`git grep -nE 'spezifikation\.md' …`) listet Stellen, die den Dateinamen
nennen, und urteilt nicht über ein Zitat; Fund am Bestand gab es nur durch den neuen Test.
**Erster Lauf war zu breit (Fehlalarm, Risiko 2):** ohne Umkreis-Regel meldete der Test 16 Zitate in den Fällen 127, 128, 131,
134 und `response_test.go`, die ihre eigenen Worte in `„…"` setzen. Mit Umkreis 250 blieben drei echte Treffer:
Fall 128 (`„eine Ergebniszeile …"`, `„einmal rot gesehen worden"`) und Fall 134 (`„nicht vorhanden"`). **Scope-Notiz:**
die drei sind Kommentarzeilen außerhalb der Plan-Liste; ich habe sie nachgezogen (Kennungen statt Wortlaut, Anführungszeichen
weg), weil der Test sonst auf dem Bestand rot geblieben wäre. Nur-Kommentar-Diff (`git diff -U0 … | grep -vE '^[+-][[:space:]]*(//|#)'`):
0 Zeilen.

## Liefer-Punkt 3 — zwei Zeilen-Bedingungen

(a) `SPEC-040` verlässt die Spec (Liefer-Punkt 4 c); die Sicht-Aussage über die Übernahme per Hook-Ausgabe steht im
Guard-Kopf bereits als „SICHT am Dialog … nicht nachpruefbar", die Betriebsart in `docs/user/rollen-laeufe.md`.
(b) Testnamen in `SPEC-058` (112), `059` (108), `060` (109), `062` (113), `063` (114), `064` (115), `065` (154). Bei
`SPEC-065` steht der Name (`TestClampSurvivesBrokenPayload`) schon in der Zelle; er ist nun auch hinter dem Fall genannt.
Wächter-Bilanz (Extraktion `Test…`/`test/…`/`Fälle …`/`make …`/`harness/tools/…`/`internal/…` aus `spec/spezifikation.md`,
Vorstand `7bc65747` gegen Stufe 3): `comm -3` zeigt nur Zuwachs (5 neue Testnamen), nichts verloren.

## Liefer-Punkt 4 — der Nachzug

- Elf Zeilen (`014 037 045 046 047 054 056 060 063 065 082`): Zelle `[LH-FA-10](lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)`
  (Form der vorhandenen Zellen). `SPEC-047` gekürzt auf Größe und Nicht-Schwelle.
- `SPEC-051/052/053`: derselbe Anker plus „Akzeptanzkriterium *Erfassungs-Umfang*" (das Kriterium ist ein Listenpunkt ohne
  eigenen Anker; Elementanker gewählt).
- Entfernt: `SPEC-040`, `041`, `084`, `085`, `086` (Kennungen bleiben frei). Träger: Grenzen und Verdrahtung im Kopf von
  `.claude/hooks/pretooluse-agent-guard.sh` (neuer Absatz GRENZEN, nennt `TestEnforce_SettingsWiresBothHooks`,
  `TestEnforce_EmitsAllMechanicFiles`, `harness/tools/smoke.sh`, Fall 32); Abweisung/Durchlass (Fälle 139, 150) in
  `test/agent-guard.bats`; am `mustContain`-Helfer (`internal/span/response_test.go`) entfällt der Zeiger auf „Zeile
  `SPEC-084`", die Grenze („Unbewacht ist der Wächter dieser Eigenschaft …", Fälle 123 und 127) stand dort schon.
- Neue Historie-Zeile in §7 (ohne ADR-Kennung, Formregel).
- Gegenprobe: `grep -E '\| Lücke \|$' spec/spezifikation.md | grep -oE '^\| \`SPEC-[0-9]+\`'` gibt **nichts** aus (Soll leer).
  `grep -c 'Lücke' spec/spezifikation.md` → **6** (Prosa: Spaltenbeschreibung, Aufnahme-Regel, Historie; kein Sensor).
- Rot gesehen: `SPEC-014` im Strom zurück auf `Lücke` → das Kommando listet die Zeile `SPEC-014`; ein Anker
  `#lh-fa-10--gibt-es-nicht` in `SPEC-014` → `make docs-check`: `anchor-missing … Anker entspricht keinem Heading-Slug und keinem
  HTML-Anker der Zieldatei` (1 Befund; Datei danach wiederhergestellt).
- Wächter-Bilanz über `spec` + Guard + `agent-guard.bats` + `response_test.go` gegen den Vorstand: `comm -23` nennt genau
  eine Differenz, die **benannte Verlagerung** `Fälle 123 und 127` (steht als `Faelle 123 und 127` in `response_test.go`).
- Nur-Kommentar-Diff außerhalb der Spec: 0 Nicht-Kommentarzeilen.

## Sensoren

`make docs-check` nach jeder Stufe: `d-check: 2178 Datei(en) geprüft, 0 Befund(e)`. `make test-bats`: 457 bats-Fälle, ok.
Erster `make gates` **rot** (`shell-lint`): `SC2016 (info): Expressions don't expand in single quotes` in
`test/mutations/502-…sh` Z. 11 und `503-…sh` Z. 13/14 (Backticks in Einzelquotes); behoben ohne Suppression (`.` statt Backtick
in der Regex, Zitat ohne Backticks), Fälle 501/502/503 danach erneut grün. Zweiter `make gates`: `GATES-EXIT 0`
(Stempel auf dem Stand vor diesem Bericht; nach dem Bericht-Commit ein dritter Lauf, s. Handoff).
`make mutate` nur mit `MUTATE_CASES` (501, 502, 503); der Vollsatz läuft nächtlich.

## Übergaben und verbleibende Risiken

- **Planner:** lebende Pläne nennen entfernte Adressen als Text der Spec: `slice-074-agent-vor-aufruf-protokoll` (`SPEC-041`),
  `slice-077-verlorener-lauf-sichtbar` und `slice-078-verdrahtung-hat-waechter` (`SPEC-086`; sie sprechen von „die Zeile"), alle in `open/`.
  Ihre Zeiger laufen ins Leere; Anpassung ist Planner-Arbeit.
- **Architect:** die Aufnahme-Regel der Spec sagt noch „eine Zeile über die Verdrahtung dieses Repos … trägt `Lücke`";
  mit dem Nachzug trägt keine Zeile mehr `Lücke`, und Verdrahtung, die nur dieses Repo trägt, verlässt die Spec. Norm-Text, nicht angefasst.
  `docs/user/rollen-laeufe.md` nicht berührt und nicht nötig: sie trägt die Betriebsart (Abschnitt „Die Betriebsart ist nicht zu wählen")
  und die Sichtbarkeit des Bruchs („Sichtbar wird ein Bruch nur teilweise") bereits — keine Lücke.
- **Risiko 1 (Tabellen falsch gezählt):** eine Tabelle ohne Kopfzeile bzw. mit `SPEC`-Zeile in einem Code-Zitat ist nicht gemessen; die Spec hat
  keine Fences. Bleibt offen.
- **Risiko 2 (Fehlalarme des Zeiger-Kommandos):** eingetreten und am Bestand gemessen (oben), mit Umkreis 250 behoben;
  die Grenze (Zitat weiter als 250 Zeichen vom Dateinamen, Zitat ohne Dateinamen nur über `SPEC-<NNN>`) ist im Kopf der Datei benannt.
- Neue Tabellenform-/Zitat-Wächter stehen nicht als Zeilen der Spec-Zusicherungen (kein Auftrag); die Spalte `Sensor` bleibt unbewacht.
- `docs/user` nennt die Spezifikation an drei Stellen (`grep -rn 'spezifikation' docs/user | wc -l` → 3), keine nennt eine entfernte
  Kennung; kein Nachzug.
