# Verifikation: slice-071-bilanz-nennt-ihren-bestand

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-09-27 · **Diff:** `git diff 6df2729b~1..848f7bf0`
(9 Commits, Claim-Move bis Mutations-Fall 495 für die Nachrunde zum MEDIUM).

**Bezug:** [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md),
[`ADR-0012`](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md),
[`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`AGENTS.md`](../../AGENTS.md) §3.6.

Geprüft gegen den Slice-Plan
[`slice-071-bilanz-nennt-ihren-bestand.md`](../plan/planning/done/slice-071-bilanz-nennt-ihren-bestand.md)
(§2 DoD, drei Punkte mit Rot-Kriterium) und gegen den Review-Report
[`2026-09-27-review-slice-071-bilanz-nennt-ihren-bestand.md`](2026-09-27-review-slice-071-bilanz-nennt-ihren-bestand.md)
(Commit `f408950f`: 0 HIGH, 1 MEDIUM, 1 LOW). Alle Formen wurden in einer isolierten
Scratch-Kopie (`git archive 848f7bf0 | tar -x` + eigenes `git init`) gefahren, nie im
Arbeitsbaum des Repos — der Arbeitsbaum trägt nur die Lese-Läufe `make docs-check`/`make gates`
am Ende.

## Verdikt je DoD-Punkt

### DoD (1) — Jede Leere-Lage unterscheidbar, jede Begründung trifft ihren Fall — **bestätigt**

- **Rot-vor-Grün real gefahren:** `case b.Zeilen == 0 && b.AblageortFehlt:` auf
  `case false && b.AblageortFehlt:` gesetzt → `make test-go` fällt exakt mit
  `TestSpanReport_NichtExistierenderPfadAlsArgumentMeldetSichAlsFehlend` (cmd-Paket) **und**
  `TestSchreibe_FehlenderAblageortMeldetSichAndersAlsLeerer` (report-Paket), alle übrigen sieben
  Pakete grün. Nach Restore wieder grün (`diff` gegen Original-Datei leer).
- **Träger-Ursachen-Sätze:** `grep -c 'ein frischer Klon hat es nicht\|Aufraeum-Lauf nimmt es weg'
  internal/report/report.go` → **0** — selbst nachgezählt, beide Sätze sind aus beiden
  Leere-Meldungen entfernt. Sie stehen unverändert nur noch im (nicht bewachten) Fragment-Kommentar
  außerhalb dieses Slice.
- **CLI-Ebene (Nachrunde zum MEDIUM):** `cmd/ai-harness-init/span_report.go` selbst gelesen — kein
  `os.Stat`/Existenz-Zweig, kein `if` auf die Lage; `spanDir` reicht `args[0]` unverändert als Pfad
  durch, die Unterscheidung lebt vollständig in `internal/report.Aggregiere`. Die Implementer-Aussage
  „keine eigene existenzabhängige Verzweigung" ist **zutreffend** — direkt am Code geprüft, nicht nur
  an der Testabdeckung abgelesen.
- **Fall 495:** Anker `fmt.Fprint(out, report.Schreibe(b))` im Quell-Bestand `grep -c` = **1**, Kopf
  vollständig (`files`/`expect`/`verify`), Teillauf `make mutate MUTATE_JOBS=1 MUTATE_CASES=…` selbst
  gefahren → `mutate: 5 ok, 0 Befund(e)`, Beleg-Slot `.harness/state/mutate-passed.key` vor und nach
  dem Lauf nicht vorhanden (Teillauf-Disziplin gewahrt).

**MEDIUM aus dem Review geschlossen:** Der neue Test ruft `spanReport([]string{<nicht existierender
Pfad>}, …)` real auf und prüft `out.String()` auf `"existiert nicht"` — genau die im Review verlangte
CLI-Eintrittsebene. Rot-vor-Grün für diesen Test einzeln bestätigt (s. o.).

### DoD (2) — `Zeilen > 0 ∧ AgentLaeufe == 0` als eigene Lage, Mechanik-Grund exklusiv — **bestätigt**

- **Rot-vor-Grün real gefahren:** `case b.AgentLaeufe == 0:` auf `case false:` gesetzt → `make
  test-go` fällt exakt mit `TestSchreibe_BestandOhneAgentLaufMeldetEigeneLage`, Rest grün. Restore
  bestätigt.
- **Exklusivität des Mechanik-Grund-Satzes selbst gelesen:** `grundDerZaehler` (Zeile 295–298, endet
  „…Mechanik. Ein Bestand ohne Zaehler ist deshalb der Normalfall und kein Defekt.") ist nur in
  `leereDerZaehler()` verbaut (der Lage „Agent lief, aber ohne Zähler"). `keineBilanzOhneAgentLauf`
  (Zeile 336–338) trägt einen eigenen, disjunkten Satz („Es lief kein Agenten-Aufruf, dessen Zaehler
  fehlen koennten…") und reüst `grundDerZaehler` nicht mit — Exklusivität am Code, nicht nur am
  Testnamen bestätigt.
- **Fall 493:** Anker `case b.AgentLaeufe == 0:` im Quell-Bestand `grep -c` = **1**; Teillauf ok
  (s. o.).

### DoD (3) — Bestandszeile nennt ihre Bezugsmenge, keine zweite Zahl — **bestätigt**

- **Rot-vor-Grün real gefahren:** Format-String auf den alten Wortlaut ohne Bezugsmenge zurückgesetzt
  → `make test-go` fällt exakt mit `TestSchreibe_BestandsZeileNenntIhreBezugsmenge`, Rest grün.
  Restore bestätigt.
- **Wahrheitsbedingung der Zählung selbst am Code geprüft** (nicht nur am Testnamen): `sitzungen[s.Session]`
  wird ausschließlich in `verarbeite()` befüllt (Zeile 138–140), aufgerufen nur nach erfolgreichem
  `json.Unmarshal` — eine nicht parsende Zeile erreicht `verarbeite` nicht (`continue` bei Fehler,
  Zeile 121–123). `b.Sitzungen = len(sitzungen)` zählt also genau die verschiedenen `session`-Werte
  der lesbaren Zeilen, wie behauptet.
- **Keine zweite Zahl:** Der geänderte Format-String trägt nur `b.Sitzungen`, `b.Von`, `b.Bis` — kein
  zusätzliches Streuungsmaß.
- **Fall 494:** Anker (voller Bestandszeilen-String) im Quell-Bestand `grep -c` = **1**; Teillauf ok
  (s. o.).

### `make gates` grün, `make mutate` ohne Befund — **teilweise, wie zugesagt**

`make gates` auf dem realen Repo-Baum selbst gefahren: `make docs-check` EXIT 0 (`d-check: 2056
Datei(en) geprüft, 0 Befund(e)`), `make gates` EXIT 0, Stempel
`[ "$(cat .harness/state/gates-passed.diffsha)" = "$(bash harness/tools/working-tree-hash.sh)" ]`
→ OK, `git status --short` leer. `make mutate` **vollständig** ist laut Auftrag verboten und war nicht
Gegenstand dieser Verifikation — der Teillauf über die fünf neuen Fälle (491–495) ist grün, das ist
alles, was an dieser Stelle geprüft werden konnte und sollte. Dieser Teil der DoD-Zeile bleibt damit
für die volle Suite offen — konsistent mit den weiterhin uneingehakten `[ ]`-DoD-Häkchen im Slice-Plan
(Closure ist Planner-Arbeit, §3.10).

### `make gates` grün / Doku-Update / Closure-Notiz — außerhalb des Verifikations-Gegenstands

Doku-Update: kein öffentlicher Vertrag berührt (Makefile, `spec/spezifikation.md` unverändert,
`git diff --stat` bestätigt — beide Dateien kommen im gesamten Diff `6df2729b~1..848f7bf0` nicht vor).
Closure-Notiz (§7) bleibt leer — korrekt, das ist Planner-Arbeit nach `git mv` (§3.10), nicht Teil
dieser Verifikation.

## Nachrunde zum MEDIUM: eigenständig nachvollzogen

- **Fall 495 real gefahren** (Teillauf 491–495, s. o.): `mutate: ok 495-span-report-cli-ausgabe-falscher-writer
  -> TestSpanReport_NichtExistierenderPfadAlsArgumentMeldetSichAlsFehlend rot`.
- **Gegenprobe empirisch nachvollzogen, nicht nur gelesen.** Mutation 495 angewandt und in einer
  isolierten Kopie **nur** `TestSpanReport_SchreibtBilanzUndGibtNullZurueck` — ein **bereits vor
  diesem Slice bestehender**, nicht neuer Test — laufen lassen (alle anderen Testdateien des Pakets
  temporär entfernt, Original danach byte-identisch restauriert, `diff` bestätigt leer):
  - Ohne Mutation: `ok github.com/pt9912/ai-harness-init/cmd/ai-harness-init`.
  - Mit Mutation (`out`→`errOut`): `--- FAIL: TestSpanReport_SchreibtBilanzUndGibtNullZurueck`.

  Der bereits vorhandene Test bindet den Writer-Tausch **allein**, ohne den neuen Test oder Fall 495.
  Die Implementer-Meldung ist damit **bestätigt**: Fall 495 ist an dieser konkreten Mutation nicht
  exklusiv — `TestSubkommandoRouting_ReportSchreibtBilanz`, `TestSpanReport_SchreibtBilanzUndGibtNullZurueck`
  und `TestSpanReport_LeererBestandIstKeinFehler` teilen sich denselben Fehlerausschlag, weil alle drei
  `out.String()` (bzw. den echten Subprozess-`stdout`) auf einen Ausschnitt der Ausgabe prüfen und der
  Writer-Tausch diesen Ausschnitt für jeden von ihnen gleichermaßen leert.

## Redundanz-Verdikt zu Fall 495

**Keine Redundanz — die Implementer-Meldung ist eine ehrliche Klarstellung, kein Mangel.**

Zwei verschiedene Fragen sind hier zu trennen, und die Verwechslung wäre der eigentliche Fehler:

1. **Bindet der Sensor (Mutation 495 + `TestSpanReport_NichtExistierenderPfadAlsArgumentMeldetSichAlsFehlend`)
   die konkrete Mutation exklusiv?** Nein, empirisch widerlegt (s. o.) — drei ältere Tests fangen den
   Writer-Tausch mit. `make mutate` verlangt das aber nicht: Es prüft, ob der **genannte** Test unter
   der Mutation rot wird, nicht, ob er der **einzige** ist, der rot wird (`harness/tools/mutate.sh`:
   die `report_fail`-Pfade prüfen `grep -qF -- "$expect"` gegen die Fehlerausgabe, keine
   Exklusivitäts-Prüfung). Mechanisch ist Fall 495 damit korrekt verdrahtet und nicht falsch etikettiert.
2. **Ist der NEUE Test — und damit Fall 495 als Ganzes — redundant zu einem bereits bestehenden,
   ungezählten Test?** Nein. Kein vorhandener Test vor dieser Nachrunde ruft `spanReport` mit einem
   bewusst **nicht existierenden** Pfad als `args[0]` auf; `TestSpanReport_SchreibtBilanzUndGibtNullZurueck`
   prüft einen vorhandenen Bestand mit Daten, `TestSpanReport_LeererBestandIstKeinFehler` einen
   vorhandenen, leeren Bestand (`t.TempDir()`, existiert). Der neue Test ist die **einzige** Zusicherung,
   die den `args[0]`-Passthrough eines fehlenden Pfades **und** die Fehler-Wortwahl „existiert nicht"
   zusammen prüft — genau die Kombination, die das MEDIUM-Finding des Reviews als fehlend benannt hatte.
   Diese Bindung ist real und neu, unabhängig davon, dass der spezifische Mutations-Sed (Writer-Tausch)
   kollateral auch andere, ältere Tests trifft.

Die vom Implementer selbst gemeldete Einschränkung ist damit präzise: Fall 495 bindet den
`args[0]`-Passthrough-Weg über den fehlenden Ablageort **neu**; dass derselbe Mutations-Sed auch
älteren, thematisch andere Wege prüfenden Tests die Ausgabe leert, ist ein struktureller Nebeneffekt
der Codeform (`spanReport` hat nur eine `out`-Senke für alle Erfolgsfälle) und keine Falschbehauptung
des Falls. Kein Finding.

## LOW-Finding (Commit-Granularität `be0751b8`)

Nur zur Kenntnis genommen, wie im Auftrag vorgegeben — kein DoD-Verstoß laut Review-Verdikt, keine
eigene Nachprüfung, keine Nachbesserung angefordert.

## Was nur gelesen wurde

- `harness/tools/full-smoke.sh` Schritt (b)/(d) und der zugehörige Diff — gelesen, nicht erneut
  gefahren (Auftrag: `make full-smoke` nicht wiederholen; bereits real vom Implementer gefahren,
  Exit 0, ~3 Minuten, siehe Implementer- und Review-Bericht).
- `docs/user/e2e-abdeckung.md` — generiertes Artefakt, nur auf reine Zeilennummern-Verschiebung
  überflogen, keine inhaltliche Prüfung (deckt sich mit dem Review).
- ADR-0011/ADR-0012 Volltext — gelesen zur Bezugs-Prüfung (Festlegung 1 Punkt 4 bzw. Festlegung 2),
  nicht Gegenstand eigener Fitness-Function-Läufe in dieser Verifikation.
- Der Prozess-Fehler-Befund (Code vor Claim) aus dem Review — vom Reviewer bereits eigenständig an
  `git log`/`git reflog` nachgeprüft; nicht erneut nachvollzogen, da kein DoD-Bezug und außerhalb des
  Verifikations-Auftrags (DoD-/ADR-Konformität, nicht Prozess-Historie).

## Plan-vs-Code-Diff

Keine Abweichung zwischen Slice-Plan §3 (Datei-Tabelle) und dem tatsächlichen Diff `6df2729b~1..848f7bf0`:
`internal/report/report.go`, `cmd/ai-harness-init/span_report.go`, beide Testdateien, `test/mutations/`
(fünf statt der geplanten zwei Fälle — die drei zusätzlichen sind Fall 493 als eigener DoD-(2)-Fall,
laut Plan explizit vorgesehen, sowie 495 aus der Nachrunde zum Review-MEDIUM), `harness/tools/full-smoke.sh`
und `test/mutations/176-*` als Nachzug. `Makefile` und `spec/spezifikation.md` wie geplant unverändert.
Nichts wurde gebaut, das der Plan nicht nennt; nichts, was der Plan nennt, fehlt.

## Übergaben an den Planner

- **§6-Risiko-Ausgänge (Slice-Plan):** Alle drei im Slice-Plan §6 genannten Risiken sind unverändert
  offen und benannt (Zahn bindet nur den konstruierten Pfad, nicht den realen Mount-Fehlgriff; Streuung
  der Summe bleibt ungemessen; Cache-Rechnung/verlorener Lauf/Exit-Codes/Emission bleiben explizit
  außerhalb) — keiner ist während dieser Verifikation eingetreten oder entfallen; der Planner weist
  ihnen bei der Closure ihren Ausgang zu (Modul 5 §Offene Risiken).
- **Register-Kandidat:** Die in dieser Nachrunde empirisch bestätigte Beobachtung — ein Mutations-Fall
  kann korrekt verdrahtet sein (benannter Test wird rot) und trotzdem nicht exklusiv binden, weil
  `make mutate` keine Exklusivität prüft, nur Anwesenheit des benannten Fehlschlags — ist ein
  Kandidat für das Beobachtungs-Register (Sub-Area `TOOLS`, `harness/tools/mutate.sh`-Mechanik): Es ist
  hier **kein** Mangel (der neue Test bindet einen echten neuen Weg), aber die Lücke „mutate prüft keine
  Exklusivität" ist strukturell und könnte bei einem künftigen Fall, der wirklich nur einen bereits
  bestehenden Test dupliziert, unentdeckt bleiben. Der Planner entscheidet, ob dieser Vorgang als
  Erstauftreten zählt.
- **LOW-Übergabe (aus dem Review):** Commit-Granularität `be0751b8` — pauschale Begründung trägt nicht
  für alle drei zusammengelegten DoD-Punkte (Review-Verdikt: kein Hard-Rule-Verstoß, nicht
  merge-blockierend). Zur Kenntnis, keine Nachbesserung angefordert.
- **Lerneintrag-Vorschlag:** Die am Code bestätigte Erkenntnis „`span_report.go` trägt keine eigene
  existenzabhängige Verzweigung — die CLI-Ebene bekommt trotzdem einen eigenen Zahn, weil die
  Writer-Wahl (`out` vs. `errOut`) eine Eigenschaft dieser Datei allein ist, die `internal/report`
  nicht kennt" ist ein Kandidat für einen geschärften Grundsatz: Ein DoD-Rot-Kriterium, das zwei Pakete
  nennt, ist auch dann einzulösen, wenn die fachliche Fallunterscheidung nur in einem der beiden liegt
  — der zweite Test deckt dann die **Verdrahtung**, nicht die Logik. Dieser Slice hatte das im ersten
  Anlauf übersehen (MEDIUM) und in der Nachrunde korrekt nachgezogen.

## Gesamturteil

Kein HIGH, kein neues MEDIUM. Alle drei DoD-Rot-Kriterien real rot-vor-grün nachvollzogen, exakt mit
dem im Plan genannten Test. Das MEDIUM aus dem Review ist durch die Nachrunde (Commits `9fecf85a`,
`848f7bf0`) geschlossen — die CLI-Eintrittsebene aus dem Realrisiko des Slice-Plans §1 ist jetzt
getestet und durch einen eigenen, unabhängig gebundenen Mutations-Fall bewacht. Die vom Implementer
selbst gemeldete Nicht-Exklusivität von Fall 495 gegenüber drei älteren Tests ist empirisch bestätigt
und **kein Befund** — der neue Test bindet eine reale, vorher ungetestete Kombination
(`args[0]`-Passthrough eines fehlenden Pfades + Fehler-Wortwahl), auch wenn derselbe Mutations-Sed
kollateral älteren, andere Wege prüfenden Tests die Ausgabe leert. Das LOW-Finding zur
Commit-Granularität bleibt unverändert zur Kenntnis. `make docs-check` EXIT 0 (2056 Datei(en), 0
Befund(e)), `make gates` EXIT 0, Stempel bestätigt, Arbeitsbaum sauber.

**DoD-/ADR-Konformität: bestätigt.** Der Slice ist verifikationsseitig bereit für die Closure durch
den Planner.
