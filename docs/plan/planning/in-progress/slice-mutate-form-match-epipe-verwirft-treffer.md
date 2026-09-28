# Slice slice-mutate-form-match-epipe-verwirft-treffer: Die Fehlschlag-Form-Prüfung in `mutate.sh` verwirft bei Mehrfachtreffern den realen Treffer über EPIPE

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Wächter, der einen realen Treffer als „falscher Grund“ meldet, behauptet ein Urteil, das er
nicht hält — dieselbe Klasse wie ein halluziniertes Gate), [`AGENTS.md`](../../../../AGENTS.md)
§3.6 (`make mutate` ist der Sensor zu dieser Regel; der hier reparierte Matcher ist Bedingung 4
dieses Sensors selbst — derselbe Bezug wie bei den Vorgänger-Slices `slice-026`, `slice-047`,
`slice-056`, `slice-057`).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-27.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `harness/tools/mutate.sh` Zeile 808 wird so gehärtet, dass ein realer Treffer der
Fehlschlag-Form nicht mehr fälschlich als „falscher Grund“ gemeldet wird, wenn das geprüfte
`make <verify>`-Log **mehr als eine** zum Muster passende Fehlschlag-Zeile enthält; ein neuer
Test/Mutations-Zahn deckt genau diesen Mehrfachtreffer-Fall nach AGENTS.md §3.6 (real rot vor dem
Fix, grün danach).

**Befund, real beobachtet (CI-Lauf `mutate.yml`, run 36326682735,
`gh api "repos/pt9912/ai-harness-init/actions/jobs/108640691305/logs"`, ~16:24:47 UTC):** Der Fall
`test/mutations/476-span-program-navigation-nicht-uebersprungen.sh` (`# verify: test-go`,
`# expect: TestCommandProgramSkipsNavigationSegments`) färbte `make test-go` real und aus dem
richtigen Grund rot — das Log zeigt `--- FAIL: TestCommandProgramSkipsNavigationSegments/cd_x~y_&&_make`
mit der erwarteten Meldung. `mutate.sh` meldete trotzdem einen Befund: „rot, aber
'TestCommandProgramSkipsNavigationSegments' faellt nicht — falscher Grund“. Unmittelbar davor
steht im Log `grep: write error: Broken pipe`.

**Ursache.** Zeile 808 (unter `set -euo pipefail`, Zeile 144):

```sh
if ! grep -E -- "$form" "$out" | grep -qF -- "$expect"; then
```

`$form` ist für `test-go` das breite Muster `--- FAIL:` (`failure_form()`) und trifft in `$out`
(voller `go test`-Log) auf **mehrere** Zeilen, wenn eine Mutation mehrere Subtests derselben
Tabelle bricht — hier der Fall. `grep -qF` (quiet) beendet sich beim ersten Treffer und schließt
seine Lesepipe; der vorgelagerte `grep -E` erhält dabei SIGPIPE, während er noch weitere Treffer
schreiben will, und endet mit einem Nicht-Null-Exit. Unter `pipefail` zählt der rechteste
Nicht-Null-Exit der Pipe — hier der von `grep -E`, nicht die erfolgreiche 0 von `grep -qF`. Das
`if !` schlägt darum fälschlich an, obwohl der Treffer real vorhanden war. Reine
Pipe-Timing-Frage: Der Bug trifft jede Mutation, deren Log mehr als eine passende Fehlschlag-Zeile
enthält, nicht nur Fall 476.

Das Skript kennt diese Fehlerklasse bereits und hat sie an einer anderen Stelle korrekt gehärtet
(Zeile 1280–1283, Kommentar „Marker-Grep als Here-String, nicht `printf | grep -q`“). Zeile 808
trägt diese Härtung nicht; `grep -n '| grep -q' harness/tools/mutate.sh` zeigt sie als die
**einzige** verwundbare Stelle dieser Art im Skript (Stand dieses Plans — der Implementer prüft
das bei Umsetzung erneut, siehe §3).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein genereller Audit aller Pipe-Verkettungen in `harness/tools/` über `mutate.sh` hinaus** —
  wäre ein anderer Vorgang: Dieser Slice behebt den real beobachteten, belegten Fund an der einen
  gemessenen Stelle; ein Audit ohne konkreten Anlass ist Spekulation über eine Menge, die hier
  nicht gemessen wurde (`grep ist keine Messung`).
- **Die bereits gehärtete Stelle Zeile 1280–1283 bleibt unverändert** — Bestand, der bewusst
  stehen bleibt: Sie verwendet schon die Here-String-Form und ist nicht Gegenstand des Befunds.
- **`narrow_sensor()` und `failure_form()` selbst bleiben unverändert** — Schicht-Abgrenzung: Der
  Fund liegt in der **Auswertung** des Ergebnisses (Bedingung 4 des Matchers), nicht in der
  Definition der Muster oder der Sensor-Auswahl.
- **Kein ADR** — geprüft gegen `AGENTS.md` §3.5 (Gates nicht ohne ADR lockern): Dieser Slice senkt
  keine Schwelle und lockert kein Gate, er repariert einen Werkzeug-Defekt, der einen realen
  Wächter-Erfolg fälschlich als Befund meldete — eine Schärfung, keine Lockerung, und ohnehin kein
  Gate-Versprechen (`make mutate` ist keines, siehe `harness/sensors/mutate.md` §Vertrag).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] `harness/tools/mutate.sh` Zeile 808 gehärtet: der erste `grep -E` schreibt sein Ergebnis in
      eine Variable/einen Here-String statt live in die Pipe von `grep -qF` zu laufen (Muster wie
      Zeile 1280–1283) — Semantik bleibt erhalten: kein Treffer oder leeres `$out` bewertet die
      Bedingung weiterhin als „fällt nicht“. **Real rot gesehen** vor dem Fix (der CI-Befund oder
      eine gleichwertige lokale Nachstellung mit dem alten Code) und **grün** danach
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
      AGENTS.md §3.6).
- [ ] Ein Test/Mutations-Zahn deckt genau den Mehrfachtreffer-Fall: ein `$out` mit **mindestens
      zwei** zur Fehlschlag-Form passenden Zeilen, wobei `$expect` in einer davon steckt, wird
      nach dem Fix als Treffer gewertet. Träger ist der bestehende Rahmen für `mutate.sh` selbst
      (`test/mutate-driver.bats`, ggf. ergänzt um einen neuen `test/mutations/`-Fall) — der
      Implementer prüft zuerst, welcher Rahmen für diese konkrete Zusicherung trägt, bevor er
      wählt. Vor dem Fix real rot, danach grün (AGENTS.md §3.6).
- [ ] `harness/sensors/mutate.md` geprüft, ob die behobene Fehlerklasse oder ihre Grenze dort
      nachzutragen ist; entweder nachgezogen oder — falls kein bestehender Aussage-Satz betroffen
      ist — im Slice-Plan begründet, warum kein Nachzug nötig war.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis
      `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zähler wird
      gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice ist
      wellenlos, darum hier geprüft, nicht von einer Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Zeile 808 entkoppelt die Live-Pipe (Matcher von Bedingung 4, AGENTS.md §3.6) |
| `test/mutate-driver.bats` oder ein neuer Fall unter `test/mutations/` | neu / update | Deckt den Mehrfachtreffer-Fall — vor dem Fix real rot, danach grün (AGENTS.md §3.6) |
| `harness/sensors/mutate.md` | update, falls zutreffend | Nachzug der behobenen Fehlerklasse/Grenze prüfen |

**Ansatz:**

- Erste Amtshandlung des Implementer-Laufs: den realen Bug lokal nachstellen — entweder durch
  Ausführen des betroffenen Falls (`test/mutations/476-…`) gegen ein `$out`, das mehrere
  `--- FAIL:`-Zeilen für dasselbe Testtabellen-Präfix erzeugt, oder durch eine kleinere hermetische
  Reproduktion der Zeile 808 selbst (analog zu den `failure_form`-Tests in
  `test/mutate-driver.bats`, die die Funktion per `source` isoliert aufrufen). Ohne diese
  Reproduktion ist Bedingung 4 (AGENTS.md §3.6) nicht erfüllt.
- Die Härtung folgt dem bereits im Skript vorhandenen Muster (Zeile 1280–1283): erster `grep`
  schreibt in eine Variable, der zweite `grep -qF` liest per `<<<`. Exakte Form ist
  Implementer-Entscheidung, solange sie den Live-Pipe-Bruch vermeidet und die Semantik für den
  Leer-/Kein-Treffer-Fall erhält.
- Vor dem Härten von Zeile 808 prüft der Implementer erneut, ob sie tatsächlich die einzige
  verwundbare Stelle dieser Art ist (`grep -n '| grep -q' harness/tools/mutate.sh`), da sich der
  Bestand seit der Planung geändert haben könnte.

**Plan-Ausgabe (Schritt 4, umgesetzt):**

- Die Reproduktion lief hermetisch (kein `test/mutations/476-…`-Fall nötig): ein `$out` mit einer
  Zeile, die `$expect` sofort trifft, gefolgt von genug weiteren zur Fehlschlag-Form passenden
  Zeilen, um die Pipe-Kapazität zu überschreiten, macht die alte Live-Pipe-Form zuverlässig
  fälschlich „fällt nicht" — real gesehen vor der Härtung.
- Die Härtung wurde als eigene Funktion `form_matched()` neben `failure_form()`/`narrow_sensor()`
  gezogen, statt inline in `run_case()` zu bleiben — damit ist Bedingung 4 selbst per `source`
  isoliert testbar, im selben Muster wie die bestehenden Tests für `failure_form`.
  `grep -n '| grep -q' harness/tools/mutate.sh` bestätigt weiterhin genau einen Treffer (die
  gehärtete `matched="$(… || true)"`-Zeile selbst, kein Live-Pipe-Rest).
- `harness/sensors/mutate.md` geprüft: die Datei trägt keinen Aussage-Satz über die interne Form
  von Bedingung 4 (kein Treffer auf „grep“, „Pipe“, „EPIPE“ oder „Bedingung 4" mit Aussagegehalt zu
  diesem Matcher) — kein Nachzug nötig, da kein bestehender Satz falsch wird oder würde.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Sobald das WIP-Limit=1 für die Implementer-Rolle (pt9912)
frei wird — der laufende Slice
`slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen` ist geschlossen und liegt in
`done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Wenn sich beim Reproduzieren
  herausstellt, dass mehr als die eine Stelle in `mutate.sh` real verwundbar ist und eine breitere
  Pipe-Härtung nötig wird, als dieser Slice trägt (§1 grenzt den generellen Audit bewusst aus).
- `in-progress` → `open` (blockiert — Carveout?): Wenn sich die Reproduktion des realen Bugs
  (Bedingung 4, AGENTS.md §3.6) als unerwartet aufwändig erweist — etwa weil der bestehende
  Test-Rahmen für `mutate.sh` selbst keine hermetische Nachstellung einer Live-Pipe-EPIPE-Situation
  zulässt und dafür erst ein neues Test-Werkzeug gebaut werden müsste.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig (Fix in Zeile 808 mit rot-vor/grün-nach-Beleg, Test/Mutations-Zahn mit
rot-vor/grün-nach-Beleg, Sensor-Doc geprüft) **und** `make gates` grün **und** Review-Report unter
`docs/reviews/` vorliegend **und** Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- Der Fix ändert die Semantik von Bedingung 4 in einem Grenzfall, den der neue Zahn nicht direkt
  prüft (z. B. `$out` leer oder ganz ohne `--- FAIL:`-Treffer) — die Here-String-Form von
  `grep -qF -- "$expect" <<<"$matched"` muss für ein leeres `$matched` weiterhin „fällt nicht“
  liefern, nicht fälschlich „trifft“. **Ausgang:** <bei Closure zuweisen>
- Der EPIPE-Fehlurteil-Bug ist eine allgemeine Klasse (jede live verkettete `grep … | grep -q`-Pipe
  unter `pipefail` mit einem früh aussteigenden zweiten `grep`); dieser Slice behebt die eine
  gemessene Stelle, keine künftig neu entstehende. **Ausgang:** <bei Closure zuweisen>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <wird bei Closure gefüllt>
- **Was ging anders als geplant:** <wird bei Closure gefüllt>
- **Steering-Loop-Eintrag:** <wird bei Closure gefüllt>
- **Beobachtungs-Register (`../observations/`):** <wird bei Closure gefüllt>
- **Folge-Slices:** <wird bei Closure gefüllt>
- **Risiken aus §6:** <wird bei Closure gefüllt>
- **Drei Paarungen:** <wird bei Closure gefüllt>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist allein `harness/tools/` (Kürzel `TOOLS`,
Modus-Deklaration `harness/conventions.md` §Modus-Deklaration pro Sub-Area). Die Schwelle ≥ 2 von
3 Achsen ist erfüllt — dieselbe, bereits deklarierte Sub-Area, keine zu grobe Fassung
nötig.

**Vorgelagert — offene Beobachtungen sichten:** `docs/plan/planning/observations/` durchgegangen
(`grep -rniE "epipe|broken pipe|pipefail" docs/plan/planning/observations/`). **Ein Treffer**,
aber zu einer anderen Ursache: `BEO-ALL/gate-flaeche-haengt-am-arbeitsbaum` (Beleg `slice-177`)
beschreibt einen SIGPIPE/`pipefail`-Effekt bei `make comment-claims`, ausgelöst durch einen
parallelen Agenten-Worktree, der die von `docs-check` gescannte Dateimenge verdoppelt — ein
anderer Mechanismus (Verdopplung der Kandidatenmenge, nicht ein früh aussteigender zweiter `grep`
in einer Live-Pipe) und ein anderer Sensor (`make comment-claims`, nicht `make mutate`). Kein
Treffer zur hier behobenen Klasse (EPIPE durch `grep -qF` in einer `grep -E | grep -qF`-Pipe unter
`pipefail`); Zähler-Stand für diese Sub-Area zu dieser Klasse: 0 (dieser Slice wäre der erste
Beleg, falls er als Beobachtung eingetragen wird).

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF.

### Sub-Area: `harness/tools/`

- **Modus:** Greenfield.
- **Konventionen-Dichte:** `harness/conventions.md` §Modus-Deklaration pro Sub-Area deklariert
  `harness/tools/` als `TOOLS`, Greenfield, Begründung „adoptierte Harness-Mechanik
  (Adaptions-Block)“.
- **Phase-Reife:** Hohe Reife — `mutate.sh` ist seit `slice-026` produktiv, mehrfach gehärtet
  (`slice-047`, `slice-056`, `slice-057`, `slice-105`, `slice-117`) und trägt einen eigenen
  hermetischen Test-Rahmen (`test/mutate-driver.bats`).
- **Evidenz-/Diskrepanz-Risiko:** Niedrig — GF, Doc (dieser Plan) führt, der Fix folgt einem im
  selben Skript bereits vorhandenen, korrekten Muster.
- **Reconciliation-Aufwand:** Kein Trigger — GF-Sub-Area, keine BF/Hybrid-Konvergenz nötig.
