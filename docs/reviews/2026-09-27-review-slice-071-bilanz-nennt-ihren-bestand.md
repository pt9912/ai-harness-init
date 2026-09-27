# Review: slice-071-bilanz-nennt-ihren-bestand

**Rolle:** Reviewer (Modul 10) · **Datum:** 2026-09-27 · **Diff:** `git diff 6df2729b~1..10e54f68`
(6 Commits: `6df2729b` Claim-Move, `a45540f4` Verweis-Nachzug, `06cb83c3` Ruhe-Marker + Beanspruchung,
`be0751b8` DoD (1)+(2)+(3), `289b4eb0` vier Mutations-Fälle, `10e54f68` full-smoke-Nachzug).

**Bezug:** [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md),
[`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md),
[`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`AGENTS.md`](../../AGENTS.md) §3.6.

Geprüft gegen den Plan
[`slice-071-bilanz-nennt-ihren-bestand.md`](../plan/planning/in-progress/slice-071-bilanz-nennt-ihren-bestand.md)
(§1 Ziel, §2 DoD, §3 Plan, §6 Risiken). Alle Formen wurden in einer isolierten Scratch-Kopie
(`git archive 10e54f68` + eigenes `git init`) gefahren, nie im Arbeitsbaum des Repos.

## Findings

### MEDIUM — DoD (1) Rot-Kriterium nicht vollständig eingelöst (Bezug-/Abdeckungslücke)

- **quelle:** Slice-Plan §2 DoD (1), Rot-Kriterium
- **pfad:** `cmd/ai-harness-init/span_report_test.go`
- **befund:** Der Plan verlangt für DoD (1) wörtlich „ein Go-Test über
  `internal/report/report.go` **und** `cmd/ai-harness-init/span_report.go` mit einem Pfad, den es
  nicht gibt". Umgesetzt wurden zwei neue Tests
  (`TestAggregiere_FehlenderAblageortWirdErkannt`,
  `TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer`), beide ausschließlich gegen
  `internal/report` (direkter Aufruf von `report.Aggregiere`/`report.Schreibe`). Kein Test in
  `cmd/ai-harness-init/span_report_test.go` ruft `spanReport([]string{<nicht existierender
  Pfad>}, …)` auf — genau das im Slice-§1 beschriebene Realrisiko („Der Ablageort ist ein
  Argument … ein Wert, den ein Aufrufer vertippen kann") bleibt auf der CLI-Eintrittsebene
  ungetestet. `TestSpanReport_LeererBestandIstKeinFehler` deckt nur den *vorhandenen, leeren*
  Ablageort (`t.TempDir()`), nicht den *fehlenden*.
- **verifizierbar:** ja — `go test ./cmd/ai-harness-init/...` mit einem neuen Testfall würde die
  Lücke schließen; heute liefert kein Lauf ein Rot, das genau diese Lücke zeigt.
  **Gegenprobe:** Der Rest von `cmd/ai-harness-init` bleibt unverändert und grün
  (`internal/report`-Verhalten ist über Komposition korrekt, aber die geforderte
  Rot-vor-Grün-Kette über den zweiten Pfad wurde nicht real gefahren).
- **klasse:** dod-rot-kriterium-nennt-zwei-pakete-implementierung-deckt-nur-eines

### LOW — Commit-Granularität `be0751b8`: DoD (3) war separierbar, wurde aber mitgeführt

- **quelle:** Maintainability / [`AGENTS.md`](../../AGENTS.md) §3.3 (Analogie: Trennbarkeit als
  Traceability-Frage, keine Move+Inhalt-Verletzung — DoD-Granularität ist laut Modul 5 Ermessen)
- **pfad:** `internal/report/report.go` (Commit `be0751b8`)
- **befund:** Der Commit begründet die Zusammenlegung aller drei DoD-Punkte mit einem „geteilten
  switch-Block/Doc-Kommentar". Das trifft für DoD (1)/(2) zu (dieselbe `switch`-Anweisung,
  dieselbe Fallunterscheidung, nicht sinnvoll trennbar, ohne einen Zwischenstand mit halb
  angelegten Fällen zu erzeugen). Für DoD (3) trifft es **nicht** zu: die Änderung sitzt in einem
  eigenen, nicht überlappenden Codeblock (die `if b.Sitzungen > 0 { … }`-Zeile vor dem `switch`),
  hat einen eigenen Test (`TestSchreibe_BestandsZeileNenntIhreBezugsmenge`) und einen eigenen
  Mutations-Fall (494), dessen Rot-Kriterium keinen der drei anderen Zweige berührt — bestätigt
  durch die eigene Rot-vor-Grün-Probe dieses Reviews (nur `TestSchreibe_BestandsZeileNenntIhreBezugsmenge`
  fällt, wenn ausschließlich der DoD-3-Wortlaut zurückgesetzt wird). Die beiden Änderungsstellen
  liegen im selben `git diff`-Hunk (Default-Kontext 3 Zeilen), ein sauberer Split hätte aber mit
  moderatem Aufwand (manuelles Hunk-Splitting via `git add -p` + `e`) funktioniert. Die
  pauschale Begründung „geteilter switch-Block" trägt also nur zwei Drittel des Commits.
- **verifizierbar:** ja — Betrachtung der Hunk-Grenzen in `git show be0751b8 -- internal/report/report.go`.
- **klasse:** commit-granularitaet-pauschalbegruendung-deckt-nicht-alle-zusammengelegten-punkte

## Verdikt: Commit-Granularität (be0751b8)

DoD (1) und (2) teilen tatsächlich denselben `switch`-Block und dieselbe Fallunterscheidung —
für diese zwei ist ein gemeinsamer Commit sachlich begründet, eine Trennung hätte künstliche
Zwischenzustände erzeugt. DoD (3) dagegen ist eine eigenständige, nicht überlappende Änderung mit
eigenem Test und eigenem Mutations-Fall und wäre git-technisch mit überschaubarem Aufwand als
eigener Commit führbar gewesen. Das ist kein Verstoß gegen eine Hard Rule (Modul 5 stellt die
DoD-Granularität pro Commit ausdrücklich ins Ermessen, §3.3 bindet nur Move+Inhalt), aber die im
Commit gegebene Begründung ist unpräzise, weil sie für alle drei Punkte gleichermaßen gilt, obwohl
nur zwei sie tragen. **LOW**, siehe Finding oben — kein Merge-Hindernis.

## Verdikt: Prozess-Fehler (Code vor Claim)

Eigenständig an der Git-Historie verifiziert: `git log --format='%H %ai %s' 6df2729b~1..10e54f68`
zeigt `6df2729b` (reiner Claim-Move) als **ersten** inhaltlichen Commit nach dem Vorzustand, mit
durchgehend aufsteigenden, plausiblen Zeitstempeln (18:17:35 → 18:24:43, alle am 2026-09-27, keine
Lücken, keine Rückdatierung). `git reflog` trägt keinen `stash@{}`-Eintrag und `git fsck
--unreachable` zeigt zahlreiche unerreichbare Objekte, die sich angesichts der langen,
mehrmonatigen Historie dieses Repos keinem einzelnen Vorgang zuordnen lassen und daher keinen
belastbaren Gegenbeleg liefern. **Kein Widerspruch gefunden** — die sichtbare Historie ist
konsistent mit der berichteten Korrektur (Claim zuerst, Code danach). Die Prüfung ist damit
notwendigerweise auf das beschränkt, was `git log`/`git reflog` heute zeigen; ob tatsächlich ein
`git stash` im Sinne des Wortes verwendet wurde, ist nicht mehr nachvollziehbar und für das
Ergebnis (korrekte Endsequenz) auch nicht entscheidend.

## Selbst gefahrene Formen (mit Ausgang)

Alle Formen in einer isolierten Scratch-Kopie (`git archive 10e54f68 | tar -x` +
`git init && git commit`), nie im Arbeitsbaum des Repos.

| # | Form | Ausgang |
|---|---|---|
| 1 | Rot-vor-Grün DoD (1): `AblageortFehlt`-Zweig deaktiviert (`case false && b.Zeilen==0 && b.AblageortFehlt:`) | `make test-go` → genau `TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer` fällt, alle anderen sieben Pakete ok. Danach `git checkout` → wieder grün. |
| 2 | Rot-vor-Grün DoD (2): `AgentLaeufe==0`-Zweig deaktiviert (`case false && b.AgentLaeufe == 0:`) | `make test-go` → genau `TestSchreibe_BestandOhneAgentLaufMeldetEigeneLage` fällt, Rest grün. Danach zurückgesetzt. |
| 3 | Rot-vor-Grün DoD (3): Bestandszeilen-Format auf den alten Wortlaut zurückgesetzt | `make test-go` → genau `TestSchreibe_BestandsZeileNenntIhreBezugsmenge` fällt, Rest grün. Danach zurückgesetzt. |
| 4 | Code-Lektüre DoD (1): beide neuen Leere-Meldungen (`leereDesAblageorts`, `leereDesBestands`) auf die zwei Träger-Ursachen-Sätze geprüft | `grep -c 'ein frischer Klon hat es nicht\|Aufraeum-Lauf nimmt es weg' internal/report/report.go` → **0** Treffer im gesamten Datei-Bestand — beide Sätze sind vollständig aus beiden Meldungen entfernt (nicht nur aus einer). |
| 5 | Code-Lektüre DoD (2): Substring-Kollisions-Risiko der Fallen-Beschreibung | `keineBilanzOhneAgentLauf` enthält „Mechanik des Agenten-Werkzeugs" (zur ausdrücklichen Verneinung), aber **nicht** die Test-geprüfte Phrase „der Normalfall und kein Defekt" — die Kollision, vor der der Testkommentar warnt, ist im Produktionscode real vermieden. |
| 6 | Code-Lektüre DoD (3): Wahrheitsbedingung der `Sitzungen`-Zählung | `sitzungen[s.Session]` wird nur innerhalb von `verarbeite(&b, s, …)` befüllt, aufgerufen nur nach erfolgreichem `json.Unmarshal` (Zeile `if json.Unmarshal(...) != nil { continue }`); nicht-parsende Zeilen erreichen die Stelle nicht — bestätigt am Code, nicht nur am Testnamen. |
| 7 | MR-071-Anker-Eindeutigkeit der vier neuen Mutations-Fälle | `grep -c` je Sed-Anker im Quell-Bestand (`case b.Zeilen == 0 && b.AblageortFehlt:`, `Werkzeug-Aufruf legt die erste Zeile an\.`, `case b.AgentLaeufe == 0:`, das Bestandszeilen-Format) → je **1**. |
| 8 | Teillauf `make mutate` (491–494) | `mutate: 4 ok, 0 Befund(e)`; alle vier binden an den benannten Test (491/492 → `TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer`, 493 → `TestSchreibe_BestandOhneAgentLaufMeldetEigeneLage`, 494 → `TestSchreibe_BestandsZeileNenntIhreBezugsmenge`). `mutate: TEILLAUF 4 von 482 — kein Beleg`, Beleg-Slot `.harness/state/mutate-passed.key` vor und nach dem Lauf nicht vorhanden. |
| 9 | Gegenprobe mit ausgeschriebener Polarität, Fall 491 | Mutation 491 angewandt, **nur** `TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer` per `t.Skip` übersprungen → `make test-go` **grün** (alle acht Pakete ok). Bindung ist real und exklusiv an diesem Test. |
| 10 | Gegenprobe mit ausgeschriebener Polarität, Fall 492 | Mutation 492 angewandt, derselbe Test übersprungen → `make test-go` **grün**. Kein anderer Test fängt 492 mit. **Kein gegenseitiges Mitfärben** zwischen 491 und 492: beide binden an denselben Testkörper, aber an unterschiedlichen, unabhängig auslösenden `if`-Zweigen desselben Tests (verifiziert über den unterschiedlich mutierten Text und die jeweils andere Assertion, die im ursprünglichen Teillauf fehlschlug). |
| 11 | Datei-Modus der vier neuen Fälle | `git ls-files -s test/mutations/49{1,2,3,4}*.sh` → `100755` (executable). Bestand ist gemischt (330× `100755`, 152× `100644`); kein Konventionsbruch. |
| 12 | `harness/tools/full-smoke.sh` Schritt (b)/(d) — **gelesen, nicht gefahren** (Anweisung: `make full-smoke` nicht wiederholen) | Schritt (b) sendet einen zweiten, echten Hook-Payload `{"hook_event_name":"PostToolUse","tool_name":"Agent","tool_use_id":"tu_fs_agent","session_id":"${kennung}agent"}` **ohne** `tool_response`-Schlüssel — erzeugt einen Agenten-Lauf ohne Zähler, genau die Lage, die DoD (2) abtrennt. Schritt (d) prüft nach `span-clean` zusätzlich auf `"existiert nicht"` statt nur auf das geteilte Literal `"Kein Bestand:"`. `test/mutations/176` bleibt unverändert an `grundDerZaehler` gebunden; ohne den Nachzug in Schritt (b) würde Schritt (b) neu in die (ab jetzt existierende) Lage „kein Agenten-Lauf" fallen und `176` liefe ins Leere — der Nachzug ist damit sachlich notwendig, nicht kosmetisch. |
| 13 | Bestehende Tests mit `AgentLaeufe: 1` ergänzt | Ohne die Ergänzung träfe `TestSchreibe_SammelpostenAnteilStehtDrin` und `TestSchreibe_UnverteilterSammelpostenStehtAusserhalb` den neuen `case b.AgentLaeufe == 0:`-Zweig und schlüge an der jeweiligen Assertion fehl (nicht nur ein Kompilierfähigkeits-Workaround, sondern eine notwendige Zustands-Korrektur; geprüft an den beiden `switch`-Zweigen, keine Aussagekraft der Tests eingebüßt). |
| 14 | `make docs-check` (Repo-Arbeitsbaum, einzeln gelesen) | Exit `0`, `d-check: 2055 Datei(en) geprüft, 0 Befund(e)`. |
| 15 | `make gates` (Repo-Arbeitsbaum, einzeln gelesen) | Exit `0` (siehe Task-Log `bg2elnalw`, letzte Zeile `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`). `git status --short` danach leer. |
| 16 | Stempel-Kontrolle nach `make gates` | `[ "$(cat .harness/state/gates-passed.diffsha)" = "$(bash harness/tools/working-tree-hash.sh)" ]` → **STEMPEL OK**. |

## Nur gelesen, nicht gefahren

- `harness/tools/full-smoke.sh` Schritt (b)/(d) selbst (kein Re-Run von `make full-smoke` — Weisung
  des Auftrags, bereits real vom Implementer gefahren, Exit 0, ~3 Minuten).
- `docs/user/e2e-abdeckung.md`-Diff — reine Zeilennummern-Verschiebung durch die neuen Zeilen in
  `full-smoke.sh`; als generiertes Artefakt (`make e2e-abdeckung`) nicht Gegenstand einer
  inhaltlichen Prüfung.
- `git reflog`/`git fsck --unreachable` als Gegenprobe zum Prozess-Fehler — Ergebnis unter
  „Verdikt: Prozess-Fehler" eingeordnet, keine tiefere Objekt-für-Objekt-Analyse der dutzenden
  unerreichbaren Objekte (unverhältnismäßig zum Finding-Ertrag).

## Negativbefund (geprüft, ohne Befund)

- **HIGH-Kategorien** (Hard-Rule-/ADR-Verstoß, Gate-Lockerung, stilles Grün, halluziniertes Gate,
  superseded-ADR-Referenz, Norm nur im Template-Kommentar, Kommentar ohne Kommentar-Klasse,
  Zustandsfeld mit Chronik): keiner der elf Fälle trifft zu. `make span-report` bleibt außerhalb
  von `gates:` (`grep -m1 '^gates:' Makefile | grep -c 'span-report'` → `0`). Kein Kommentar im
  Diff beschreibt eine verworfene Alternative oder bricht mitten im Satz ab — alle neuen
  Doc-Kommentare sind im Indikativ über den geltenden Zustand formuliert.
- **§3.6 (Zusage ohne rot gesehenes Gegenbeispiel):** alle drei DoD-Rot-Kriterien real
  nachvollzogen (Formen 1–3), keine Abweichung außer der unter MEDIUM genannten Lücke.
- **§3.7 (Kommentar-Klassen):** die `slice-071 DoD (n)`-Marker in den neuen Kommentaren folgen
  demselben, bereits vor diesem Diff etablierten Repo-Muster (`(slice-098)`, `(slice-099)` in
  `report.go`/`full-smoke.sh`) als Rang-Zeiger auf den bindenden Liefergegenstand, keine Chronik
  eines Vorgangs.
- **§3.9 (Docker-only):** kein Host-Toolchain-Aufruf; `python3` in der Scratch-Kopie wurde vom
  PreToolUse-Guard korrekt blockiert, alle Go-Läufe liefen über `make test-go`/`make mutate`.
  Zieldateien nur mit `sed`/`git` bearbeitet.
- **§3.10 (Slice-Abschluss ist Planner-Arbeit):** `git diff --stat` gegen `Makefile`,
  `spec/spezifikation.md`, `docs/plan/planning/observations/`, `docs/plan/adr/` ist leer; DoD-Häkchen
  im Slice-Plan bleiben alle uneingehakt (`[ ]`); keine Closure-Notiz geschrieben.
- **Mutations-Fälle 491–494:** Kopf-/Anker-Form entspricht den Nachbarn (490, 176); keine
  gegenseitige Mitfärbung zwischen 491 und 492 trotz gemeinsamem Test-Host (Formen 9/10).
- **`cmd/ai-harness-init/span_report.go`:** unverändert — legitime Design-Entscheidung laut
  Plan-§3 („Aggregiere stellt fest, Schreibe spricht aus"); die fehlende Test-Abdeckung dort ist
  gesondert als MEDIUM-Finding erfasst, nicht als HIGH (kein Hard-Rule-Verstoß, sondern eine
  Abdeckungslücke gegenüber dem eigenen Plan-Wortlaut).

## Gesamturteil

Kein HIGH. Ein MEDIUM (DoD (1) Rot-Kriterium nicht vollständig über beide im Plan genannten
Pakete eingelöst) und ein LOW (Commit-Granularität: pauschale Begründung deckt nicht alle drei
zusammengelegten DoD-Punkte). Beide Prozess-Selbstmeldungen des Implementers (Commit-Granularität,
Code-vor-Claim-Korrektur) wurden eigenständig nachgeprüft; die Git-Historie zeigt keinen
Widerspruch zur berichteten Korrektur. Nicht merge-blockierend aus Reviewer-Sicht; das MEDIUM
gehört vor Merge geklärt (Modul 10 §Klassifikation).
