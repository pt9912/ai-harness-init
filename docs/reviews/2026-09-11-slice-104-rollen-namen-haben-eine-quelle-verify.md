# Verifikation — slice-104 (Die Rollen-Namen haben eine Quelle)

**Rolle:** Verifier · **Datum:** 2026-09-11
**Gegenstand:** `9fa172a7` (Stand nach Review-Runde 1, HIGH-1/2/3 behoben) · Baseline für den
Plan-vs-Code-Diff: `c4182efb` (letzter Stand vor dem ersten Implementer-Code-Commit `61c45ba7`;
`e5afeb36` davor ist reiner Ruhe-Marker-Nachzug nach `slice-mv`).
**Plan:** `docs/plan/planning/done/slice-104-rollen-namen-haben-eine-quelle.md` ·
**Review:** `docs/reviews/2026-09-11-slice-104-rollen-namen-haben-eine-quelle.md` (3 HIGH · 2 MEDIUM
· 1 LOW · 1 INFO, HIGH in `9fa172a7` behoben) · **Bezug:**
[`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3,
[`AGENTS.md`](../../AGENTS.md) §3.6 · §3.10

**Baumstand am Start dieses Laufs:** `git status --porcelain` leer, HEAD `9fa172a7`. Kein anderer
Agent, kein laufendes `make`/`docker` (`pgrep -af '^make '` leer). Der Baum blieb während des
gesamten Laufs auf `9fa172a7`; kein DoD-Häkchen gesetzt.

---

## 1. Sensoren — selbst gefahren, nicht übernommen

| Sensor | Ergebnis | Wie geprüft |
|---|---|---|
| `make gates` | Exit 0, `1m14,553s` real | selbst gefahren (Docker) |
| `make docs-check` | `1109 Datei(en) geprüft, 0 Befund(e)` | selbst gefahren, deckt sich mit der Behauptung |
| `comment-claims` (Teil von `make gates`) | `57 Datei(en) geprueft, 0 Befund(e)` | in der `make gates`-Ausgabe gelesen |
| `make mutate` | `Beleg fuer Pruefgegenstand … liegt vor … seit dem letzten vollstaendig gruenen Lauf unveraendert. Kein Fall-Lauf.` | selbst gefahren; bestätigt, dass der Baum seit dem Beleg-Lauf (2026-09-11 13:11:30, Prüfgegenstand-Hash `28b9afe1…`) unverändert ist — der Beleg deckt genau `9fa172a7` |
| `make full-smoke` | vollständig durchgelaufen, **0** `FEHLER`-Zeilen, endet exakt an der letzten Zeile des Skripts (`harness/tools/full-smoke.sh:1462`), 16× `OK —` | selbst gefahren, kompletter Lauf (~10+ Minuten, alle Sprachen/Architekturen inkl. Rollen-Typen- und Feldlisten-Zahn) |

**Zum `make mutate`-Beleg:** Ich habe den Lauf nicht durch einen erzwungenen Voll-Lauf
(`MUTATE_FORCE=1`) wiederholt — das wäre bei der gemessenen Laufzeitklasse (`full-smoke`-Fälle
allein sind teuer) unverhältnismäßig, wenn der Beleg-Mechanismus selbst hält. Ich habe stattdessen
verifiziert, *dass* der Beleg über genau diesem Baum ausgestellt ist (Hash-Bindung, Kein-Fall-Lauf-
Meldung) und die neun tragenden Fälle (128, 132, 167, 168, 169, 303, 304, 305, 306) einzeln über
ihre Anker/Diffs gegen den echten Quellcode nachgemessen (§2). Die reale `make full-smoke`-Ausführung
deckt zusätzlich unabhängig, dass die Fälle 305/306 auf einem *lauffähigen* `full-smoke` aufsetzen.

## 2. DoD-Punkte einzeln gegen den Baum gemessen

### DoD (1) — Die Namen stehen einmal; die Abbildung des Trägers leitet ab

**Eigenschaft:** hält. `internal/span.CanonicalRoles()` ist die einzige Quelle;
`internal/emit.canonicalRoles()` liest sie (`return span.CanonicalRoles()`),
`internal/span.RoleFromAgentType()` normalisiert gegen dieselbe Liste. `grep -c 'planner'
internal/span/fieldlist.go` → **0** — der vierte Fundort (der emittierte Grenz-Satz) ist ebenfalls
angeschlossen (`backtickJoin(CanonicalRoles())`, package-intern, funktional identisch mit
`span.CanonicalRoles()` von außen).

**Wächter beide Richtungen:** `TestRollenAchseFolgtDerEinenQuelle`
(`internal/emit/rollen_kopplung_test.go`) prüft Länge **und** je Namen `RoleFromAgentType(role) ==
role` **und** einen Namen außerhalb (`general-purpose`) → leer — beide Richtungen, wie DoD (1)
verlangt. Mutations-Fälle `303` (kürzt Quelle) und `304` (kürzt nur Abbildung um denselben Namen)
zielen exakt auf diesen Wächter; ich habe beide Anker gegen eine Wegwerf-Kopie von
`internal/span/emit.go` angewendet — beide greifen (kein No-Op).

**Wortgetreue Messmethode — MEDIUM-1 bestätigt, nicht geglättet:**

```sh
grep -rn 'planner.*architect.*implementer' --include='*.go' --include='*.sh' . | grep -v '_test.go' \
  | cut -d: -f1 | sort | uniq -c
#   1 internal/span/emit.go
#   1 test/mutations/303-rollenachse-quelle-kuerzt.sh
#   1 test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh
```

**Ergebnis: 3, nicht 1.** Die Zusage aus §1/DoD (1) — *„die Zahl aus §1 steht dann auf 1, gemessen
mit demselben Kommando"* — ist mit dem im Plan genannten Kommando **wortgetreu nicht erfüllt**.
Verenge ich das Kommando um `test/` (die Eigenschaft, die MEDIUM-1 als tragend ausweist):

```sh
grep -rn 'planner.*architect.*implementer' --include='*.go' --include='*.sh' . | grep -v '_test.go' \
  | sed 's|^\./||' | grep -v '^test/' | cut -d: -f1 | sort | uniq -c
#   1 internal/span/emit.go
```

**→ 1.** Die **Eigenschaft** (ein Ort im Produktionsbestand) hält; die im Plan genannte
**Messmethode** liefert 3, weil sie `test/mutations/*.sh` nicht ausschließt. Das ist ein
Abnahmemaßstabs-Defekt, kein Code-Defekt — die zwei zusätzlichen Treffer sind selbstmeldende
Mutations-Fälle, keine zweite stille Quelle.

**Bewertung:** DoD (1) ist **in der Sache erfüllt, im Wortlaut nicht**. Beide Bestandteile —
Wächter beide Richtungen, ein Ort im Produktionsbestand — messen mit meinen eigenen Kommandos so,
wie der Reviewer es unter MEDIUM-1 protokolliert hat.

### DoD (2) — Der Bestand ist nachweislich nicht leer, die Verdrahtung hat ihren Zahn

`test/mutations/306-rollenachse-emit-aufruf-entfernt.sh` entfernt den `emit.Agents(targetDir)`-Aufruf
aus `cmd/ai-harness-init/main.go` und trägt `# verify: full-smoke` / `# expect: FEHLER — Rollen-Typ
fehlt`. Ich habe den Anker gegen den echten Aufrufer geprüft — die Zeile
`if err := emit.Agents(targetDir); err != nil {` existiert unverändert in
`cmd/ai-harness-init/main.go`; der `sed`-Range-Befehl (`/…/,+2d`) trifft genau den Drei-Zeilen-Block.
Dass `make test` (Go-Paket-Ebene) diese Mutation nicht sieht, weil `internal/emit` den Aufrufer in
`cmd/` nicht kennt, ist am Code nachvollziehbar (`cmd/ai-harness-init/main.go` ist das einzige
Vorkommen des Aufrufs, `grep -rn 'emit.Agents(' --include=*.go .` → ein Treffer außerhalb der
Test-Datei). Die Stufenwahl `full-smoke` ist damit nicht frei, sondern erzwungen — wie der Plan
selbst begründet und der Reviewer in N-3 bestätigt.

**Selbst gefahren:** `make full-smoke` läuft auf dem unmutierten Baum vollständig grün durch
(§1). Die eigentliche Rot-Probe für `306` läuft unter `make mutate`, dessen Beleg über diesem Baum
den Fall als `ok` führt (§1). Ich habe den Fall nicht isoliert nochmal manuell durch `full-smoke`
gejagt — das würde denselben Weg wie `make mutate` noch einmal von Hand nachbauen, ohne einen
zusätzlichen Erkenntnisgewinn zu liefern, da Anker, Aufrufer und Sensor-Kette einzeln bestätigt
sind.

**Bewertung:** DoD (2) ist **erfüllt** — Kommando, Fall und Grenze stimmen mit dem Plan überein.

### DoD (3) — Der Voll-E2E-Sensor führt keine eigene Namensliste, hat einen Fall

`harness/tools/full-smoke.sh`, Funktion `rollen_typen_im_ziel()`: die erwartete Rollen-Liste kommt
per `nullglob`-Schleife aus `internal/emit/templates/agents/*.md` (Quell-Baum), **nicht** aus einem
Literal und **nicht** aus dem gebootstrappten Ziel selbst (das wäre die in §1/§6 des Plans
ausdrücklich verworfene Zirkularität). Nicht-Leer-Schutz vorhanden (`n=0`-Zähler, Prüfung nach der
Schleife, `exit 1` bei leerem Fund). `test/mutations/305-…` entfernt eine Rolle aus
`CanonicalRoles()` (Quelle bleibt bei sechs Vorlagen-Dateien, das Ziel bekommt nur fünf) — genau die
Achse, die eine literale oder aus dem Ziel gelesene Erwartung nicht fangen würde.

**Kommando aus DoD (3), selbst gefahren:**

```sh
grep -l '^# files:.*full-smoke' test/mutations/*.sh
# (leer)
```

Wortgetreu weiterhin **leer** — aber das ist, wie MEDIUM-2 zeigt, ein Kriterium, das die falsche
Datei-Eigenschaft misst (`# files:` statt einer auf die Schleife zielenden Suche). Mit dem vom
Reviewer vorgeschlagenen, auf die Schleife zielenden Muster:

```sh
grep -l '^# expect:.*FEHLER — Rollen-Typ fehlt' test/mutations/*.sh
# test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh
# test/mutations/306-rollenachse-emit-aufruf-entfernt.sh
```

**→ zwei Treffer, `305` darunter.** Der Sensor selbst ist real vor jedem `make gates` des Ziels
aufgerufen (Zeile 220 vor Zeile 232 in `harness/tools/full-smoke.sh`, selbst gelesen), und mein
eigener `make full-smoke`-Lauf zeigt live: *„Rollen-Typen im Ziel (--lang go): 6 kanonische Typen…"*
in beiden Bootstrap-Varianten.

**Bewertung:** DoD (3) ist **in der Sache erfüllt** (Klausel iii hält, ein Fall existiert und trifft
die Schleife), **im Wortlaut des im Plan genannten Kommandos nicht** — dasselbe Muster wie DoD (1):
Eigenschaft ja, Messmethode nein. Zusätzlich, wie MEDIUM-2 anmerkt: der Maßstab war bereits vor
Beginn dieser Arbeit (durch `190`, seit 2026-08-27) im o. g. wortgetreuen Sinn nicht mehr
diskriminierend — das ändert nichts an der Bewertung von DoD (3) selbst, bestätigt aber, dass der
Abnahmemaßstab unabhängig vom Ergebnis dieses Slice zu korrigieren ist.

## 3. Emittierte Seite — der eigentliche Wert des Slice

- `grep -c 'planner' internal/span/fieldlist.go` → **0**, selbst gemessen — die Liste, die im
  Adopter-Repo stehenbliebe, existiert nicht mehr.
- Byte-Gleichheit über dem `const`→`func`-Umbau selbst nachgerechnet:
  `git show 61c45ba7^:internal/span/fieldlist.go | sed -n 's/.*Rollen nennt — \(.*\)\. Wer.*/\1/p'`
  und der neue `backtickJoin(CanonicalRoles())`-Ausdruck liefern denselben String, sha256-Präfix
  `6ae85387d802dc56` — **identisch**.
- `gochecknoglobals` steht in `.golangci.yml` (`grep -n gochecknoglobals` → Zeile 27) — die
  Begründung für `const`→`func` (kein package-level `var` mit Funktionsaufruf) ist damit nicht nur
  behauptet, sondern die Lint-Regel existiert real.
- `TestFeldliste_LiegtVerbatimImZiel` existiert (`internal/emit/fieldlist_test.go:56`) und ist Teil
  des grünen `make test`/`make gates`.
- Drei unabhängige Stellen, an denen eine künftige Umbenennung auffällt, real geprüft:
  `TestAgentRoleFromKnownTypes` (`internal/span/span_test.go`), `TestSpawnedRoleIsNormalised`
  (`internal/span/response_test.go`) — beide vom Slice nicht abgeleitet, Literal-Tabellen — und
  `TestRollenAchseFolgtDerEinenQuelle` (neu, `internal/emit/rollen_kopplung_test.go`), das zusätzlich
  `emit.AgentFile()` gegen jeden Quell-Namen hält.

Alle drei Punkte aus dem Prüfauftrag sind damit **selbst gemessen und bestätigt**, nicht aus dem
Review-Report übernommen.

## 4. ADR-/Hard-Rule-Konformität

**Paketkanten-Richtung (Frage A / N-1):** `internal/emit/fieldlist.go` importiert `internal/span`
bereits am Stand `c4182efb` (vor jedem Implementer-Commit dieses Slice) — nachgemessen mit
`git show c4182efb:internal/emit/fieldlist.go | head -10`, identisch mit dem heutigen Import.
`internal/span` importiert `internal/emit` an keiner Stelle (`grep -rn
'ai-harness-init/internal/emit' internal/span/*.go` → leer). Die Kante `emit → span` bestand also
bereits, `internal/emit/agents.go` (neuer Import in dieser Datei) nutzt eine bestehende Kante, fügt
keine neue Architektur-Entscheidung hinzu — die Messung des Reviewers ist bestätigt, die
Schlussfolgerung (kein ADR geschuldet, [`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 5(a) betrifft nur die verworfene Gegenrichtung) trägt.

**§3.7 (Kommentar beschreibt, was da ist):** Die drei in HIGH-3 gerügten Stellen sind in `9fa172a7`
umformuliert; ich habe alle drei Diffs gelesen (`internal/span/fieldlist.go`,
`test/mutations/305-…`, `test/mutations/306-…`) — die Chronik-Formulierungen sind entfernt, die
geltende Zusage steht im Indikativ. Kein Rest der gerügten Klasse in den drei Dateien gefunden.

**§3.10 (Abnahmemaßstab bleibt beim Planner):** MEDIUM-1 und MEDIUM-2 sind im Diff `9fa172a7`
**nicht** angefasst — der Implementer hat den DoD-Wortlaut nicht umgeschrieben, obwohl er die
Diskrepanz für DoD (1)/§1 selbst hätte glätten können. Konform.

## 5. Plan-vs-Code-Diff (Baseline `c4182efb`, vor jedem Implementer-Code-Commit)

`git diff --stat c4182efb HEAD` — 20 Dateien. Geprüft, was der Plan als „unverändert" bzw. „update"
zusagt:

- `internal/emit/agents.go`, `internal/span/emit.go`, `harness/tools/full-smoke.sh`,
  `internal/span/fieldlist.go` — alle vier wie geplant `update`, Diffs gelesen (§2/§3), decken sich
  mit Frage-A/B/C-Antworten aus §3 des Plans.
- `internal/span/response_test.go` — Plan sagt **unverändert** zu; real geändert ist ein
  Bezeichner in einem Doc-Kommentar (`roleFromAgentType` → `RoleFromAgentType`), die Literal-Tabelle
  selbst (6 Erwartungen + 10 Verneinungen) ist byte-identisch. Deckt sich mit N-12 des Reviews;
  keine Verwässerung des `_test.go`-Vertrags aus §Die Grenze.
- `internal/emit/agents_test.go` — als Nebenkorrektur aus der Closure von slice-097 angekündigt;
  real geändert ist die Emissions-Zahl-Zusage (jetzt „DREI", nachgemessen korrekt) und das
  `richtung`-Feld. Die im **Plan selbst** (§3-Tabelle) daneben stehende ältere Messung
  („gemessen 6") ist stehen geblieben — LOW-1 bestätigt, Plan-Artefakt, kein Code-Defekt.
- `test/mutations/` — sechs neue Fälle (303–306, plus die schon gezählten 128/132-Fixes und
  167–169-Fixes) an der im Plan vorgesehenen Nummer-Fortsetzung.
- `docs/plan/adr`, `docs/plan/planning/in-progress/roadmap.md` — wie zugesagt unverändert
  (Roadmap-Diff `c4182efb..HEAD` betrifft nur den `e5afeb36`-Ruhe-Marker-Nachzug, der bereits vor
  dem eigentlichen Code-Commit lag und Teil der Lifecycle-Bewegung ist, nicht des Plans §3).

**Gebautes ohne Plan-Eintrag:** keines gefunden — jede geänderte Datei hat eine Zeile in der
§3-Tabelle oder ist eine dort selbst angekündigte Nebenkorrektur.

**Frage A/B/C:** alle drei im Plan mit Kommando beantwortet (§3, Block „Entschieden"), dieser
Block selbst erst während der Implementer-Arbeit geschrieben (Commit `61c45ba7`, nicht in
`c4182efb`) — zulässig nach dem Bedienhinweis der Slice-Vorlage und N-1 des Reviews, hier
nachgemessen: `git diff c4182efb 61c45ba7 -- '*slice-104*'` zeigt ausschließlich den
„Entschieden"-Block als Hinzufügung, keine Verschiebung von DoD, Closure-Trigger oder
Out-of-Scope-Grenze.

## 6. Register-Beleg (§3.11-Vormessung, N-8 nachgemessen)

`ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/*.md
| wc -l` → **10** zum Zeitpunkt dieses Laufs (kein Erwartungswert). Der Eintrag steht auf `offen`,
Architect-Entscheidung aussteht — der Beleg für den `c4182efb`-Vorgang selbst gehört, wie der
Reviewer korrekt festhält, in die Slice-Closure, nicht in einen vorgelagerten Lauf. Kein Befund von
meiner Seite.

## 7. Was ich nicht zusätzlich verifiziert habe, und warum

- **Kein eigener `MUTATE_FORCE=1`-Volllauf.** Der bestehende Beleg ist über exakt diesem Baum
  ausgestellt (Hash-Bindung geprüft), und alle neun tragenden Fälle sind individuell durch
  Anker-Diff-Nachrechnung bestätigt (§2/§3). Ein erzwungener Volllauf hätte denselben Befund bei
  hohem Zeitaufwand reproduziert.
- **Keine isolierte manuelle Wiederholung von `305`/`306` unter `full-smoke`.** Die Sensor-Kette
  (Anker → Aufrufer → Skript-Logik) ist einzeln bestätigt, und der reale `full-smoke`-Lauf auf dem
  unmutierten Baum bestätigt, dass die Infrastruktur, in der diese Fälle laufen, tatsächlich
  funktioniert.

## Verdikt

**Ist die DoD erfüllt?** **Mit benannter Abweichung.** Alle drei schließenden Eigenschaften
(Klausel i/ii/iii) sind **in der Sache** erfüllt und mit eigenen Kommandos nachgemessen:

- DoD (1): Eigenschaft (ein Ort im Produktionsbestand, Wächter in beiden Richtungen) hält; das im
  Plan genannte Abnahme-Kommando liefert **3** statt der zugesagten **1** (MEDIUM-1, selbst
  reproduziert).
- DoD (2): erfüllt, Kommando und Fall stimmen mit dem Plan überein.
- DoD (3): Eigenschaft (kein eigenes Namensliteral im Sensor, Fall über der Schleife) hält; das im
  Plan genannte Abnahme-Kommando (`# files:`-Suche) war **bereits vor Beginn dieser Arbeit** durch
  einen fremden Fall (`190`, seit 2026-08-27) nicht mehr diskriminierend und bindet den gelieferten
  Fall `305` nicht (MEDIUM-2, selbst reproduziert).

Beide Abweichungen sind **Abnahmemaßstab**, nicht Code — nach [`AGENTS.md`](../../AGENTS.md) §3.10
liegt die Entscheidung, ob die DoD-Wortlaute nachgezogen oder die Zahlen/Kommandos als erfüllt
gelten, beim **Planner**, nicht bei mir und nicht beim Implementer. Ich benenne die Abweichung,
setze aber kein Häkchen.

`make gates`, `make full-smoke` und `make mutate` (Beleg) sind grün — alle drei selbst gefahren,
keine Behauptung übernommen. Kein Gebautes-ohne-Plan gefunden, keine Hard-Rule-Verletzung.

**Kann der Planner schließen?** **Ja, sobald er über MEDIUM-1 und MEDIUM-2 entschieden hat** —
entweder durch Nachziehen der beiden Kommandos/Zusagen im Plan (dann sind DoD (1) und (3) auch im
Wortlaut erfüllt) oder durch eine ausdrückliche Abnahme der Eigenschaft anstelle der Messmethode,
protokolliert in der Closure-Notiz. LOW-1 und INFO-1 sind unblockierend und können in derselben
Closure-Runde mit erledigt werden. Die drei HIGH aus Review-Runde 1 sind behoben und von mir
unabhängig nachgemessen (Anker greifen real, kein No-Op, kein Übersetzungsfehler-Risiko am
betroffenen Aufruferpfad).
