# Review — slice-104 (Die Rollen-Namen haben eine Quelle)

**Rolle:** Reviewer · **Datum:** 2026-09-11 · **Runde:** 1
**Gegenstand:** `e5afeb36`, `61c45ba7`, `08b1aeeb` (die zwei `slice-mv`-Commits davor sind reine
Lifecycle-Bewegung und nicht Prüfgegenstand)
**Plan:** `slice-104` · **Bezug:** [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3,
[`AGENTS.md`](../../AGENTS.md) §3.6 · §3.7 · §3.9 · §3.10 · §3.11,
[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)

**Gefahrene Sensoren dieses Laufs:** keiner der verbotenen. Kein `make`-Ziel, kein
`docker build`, kein `docker run`. Alle Messungen unten mit `git`, `grep`, `sed`, `awk`, `cmp`,
`sha256sum` gegen den Arbeitsbaum bzw. gegen Kopien im Scratchpad außerhalb des Repos.
**`docker run`-Läufe gegen den gepinnten d-check-Digest: 0.**

---

## Findings

### HIGH-1 — Ein Mutations-Anker ist nach der Umbenennung tot

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `test/mutations/128-span-rolle-unnormalisiert.sh:27`
- **befund:** Der Anker `sed -i 's@roleFromAgentType(text(v))@text(v)@'` trifft nach der
  Umbenennung auf `RoleFromAgentType` nichts mehr. Der Fall ist ein **No-Op**; der von ihm
  benannte Wächter `TestSpawnedRoleIsNormalised` hat damit keinen wirksamen Zahn mehr.
  Gemessen über **alle** Fälle, je in einer Kopie außerhalb des Repos:

  ```sh
  # je Fall: nur die '# files:'-Ziele in ein leeres Verzeichnis kopieren, Fall dort fahren, cmp
  # -> greift: 291   NO-OP: 1   nicht probierbar: 0   Faelle gesamt: 292
  ls -1 test/mutations/*.sh | wc -l
  ```

  Einziger Treffer: `128`.
- **verifizierbar:** ja — `make mutate` meldet für `128`
  `Mutation hat nicht gegriffen bei: internal/span/response.go — Patch veraltet?`
  (Bedingung 2 des Treibers, `harness/tools/mutate.sh`). Der Fall ist damit **laut**, nicht still
  grün — er blockiert aber den Closure-Trigger *„`make mutate` grün"* aus §5 des Plans.
- **klasse:** Symbol-Umbenennung lässt Mutations-Fall zahnlos zurück

### HIGH-2 — Ein zweiter Mutations-Fall fügt das umbenannte Symbol ein und übersetzt nicht mehr

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `test/mutations/132-span-rolle-aus-argument.sh:53`
- **befund:** Der Fall **fügt** Code ein, der `roleFromAgentType(...)` aufruft. Dieses Symbol
  existiert nicht mehr — der mutierte Baum übersetzt nicht, und der erwartete Fehlschlag
  `--- FAIL: TestAgentGetsNoArgumentFields` kann nicht entstehen. Der No-Op-Sweep aus HIGH-1
  findet ihn **nicht**: die Datei ändert sich ja.

  ```sh
  git grep -n 'roleFromAgentType' -- 'internal/span/*.go'   # 0 Treffer
  git grep -n 'func RoleFromAgentType' -- 'internal/span/*.go'  # internal/span/emit.go:191
  grep -n 'roleFromAgentType' test/mutations/132-span-rolle-aus-argument.sh   # :37 (Kommentar), :53 (eingefuegter Aufruf)
  ```
- **verifizierbar:** ja — `make mutate` meldet für `132`
  `rot, aber 'TestAgentGetsNoArgumentFields' faellt nicht — falscher Grund`
  (Bedingung 4; die Fehlschlag-Form der `test`-Stufe ist `--- FAIL:|not ok [0-9]+`, ein
  Übersetzungsfehler trägt keine davon).
- **klasse:** Symbol-Umbenennung lässt Mutations-Fall zahnlos zurück

> **Die Anker-Sichtung hatte die falsche Bezugsmenge.** Gesucht wurde über die *berührten*
> Dateien; `132` nennt `internal/span/span.go`, das der Slice nicht anfasst. Die Menge der
> Fälle, die eine berührte Datei nennen, ist zudem **31**, nicht 20:
> ```sh
> for f in test/mutations/*.sh; do sed -n 's/^# files: //p' "$f"; done \
>   | tr ' ' '\n' | grep -cE '^(harness/tools/full-smoke\.sh|internal/(emit/agents(_test)?\.go|emit/rollen_kopplung_test\.go|span/(emit|fieldlist|response)\.go|span/response_test\.go))$'
> ```
> Die tragende Achse ist nicht *berührte Datei*, sondern *umbenanntes Symbol* — in beiden
> Richtungen, als Anker **und** als eingefügter Text.

### HIGH-3 — Neuer Kommentar beschreibt abwesenden Text

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7 (*„die frühere Fassung prüfte nur die Länge" —
  beschreibt abwesenden Text*), Cutoff 2026-08-30 — gebunden ist der Kommentar, der geschrieben wird
- **pfad:** `internal/span/fieldlist.go:131-132`
- **befund:** *„die Darstellungsform, die `limitAgentGuard` **bisher** als Literal trug"* —
  der Satz beschreibt den Text der Vorgänger-Fassung, nicht die geltende Zusage. Dieselbe Klasse
  in zwei neuen Skript-Kommentaren: `test/mutations/305-…:14-16` (*„Dieser Fall ist der erste Zahn
  ueber dieser Schleife ueberhaupt — bis hierher deckte sie kein test/mutations/-Fall"*, Chronik
  **und** sachlich strittig, s. MEDIUM-2) und `test/mutations/306-…:12-13` (*„Vor diesem Fall
  deckte kein test/mutations/-Fall diese Verdrahtung — make test blieb … gruen"*, Chronik im
  Perfekt). Fundmenge: **3** neu geschriebene Stellen.
- **Umformulieren, nicht ergänzen:** der Halbsatz über die Vorgänger-Fassung entfällt; was
  `backtickJoin` heute zusagt (Backtick + Komma, Liste aus `CanonicalRoles`), steht schon im
  Folgesatz.
- **verifizierbar:** nein — kein Gate liest das. `make comment-claims` prüft nur, ob ein
  *genannter Sensor* existiert, und `test/mutations/*.sh` liegt ohnehin außerhalb seines
  Prüfbereichs (`grep -n 'comment-claims.sh' Makefile` → vier Pfad-Muster, `test/` ist keines).
- **klasse:** Kommentar beschreibt abwesenden Text statt der geltenden Zusage

### MEDIUM-1 — Das Akzeptanz-Kommando von DoD (1) liefert 3, nicht 1

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan `slice-104` §2 DoD (1) / §1,
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **pfad:** `slice-104` §1 *Die Ausgangslage* und §2 DoD (1)
- **befund:** DoD (1) sagt zu: *„die Zahl aus §1 steht dann auf **1**, gemessen mit demselben
  Kommando."* Wortgetreu gefahren:

  ```sh
  grep -rn 'planner.*architect.*implementer' --include='*.go' --include='*.sh' . \
    | grep -v '_test.go' | cut -d: -f1 | sort | uniq -c
  #   1 internal/span/emit.go
  #   1 test/mutations/303-rollenachse-quelle-kuerzt.sh
  #   1 test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh
  ```

  Das Kommando nimmt nur `_test.go` aus, nicht `test/`; die zwei neuen Mutations-Fälle schreiben
  die sechs Literale in ihre `sed`-Muster. Die **Eigenschaft** hält (`… | sed 's|^\./||' | grep -v
  '^test/'` → **1**), die **Messmethode** nicht.
- **streichen oder umformulieren:** entweder das Kommando um `test/` verengen, oder die Zusage auf
  die Zahl **3** mit ihrer Zerlegung umstellen. Mildernd, und gemessen: ein veraltetes `sed`-Muster
  fällt laut auf (`harness/tools/mutate.sh`, Bedingung 2) — die Doppelung in `303`/`305` ist
  selbstmeldend, keine stille zweite Quelle.
- **verifizierbar:** ja — das Kommando oben.
- **klasse:** Akzeptanz-Kommando misst eine weitere Menge als die zugesagte Eigenschaft

### MEDIUM-2 — DoD (3) ist schon vor der Arbeit erfüllt und bindet den gelieferten Fall nicht

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan `slice-104` §2 DoD (3) / §1, [`AGENTS.md`](../../AGENTS.md) §3.10
  (*Übergabe-Artefakt statt Umschrift des eigenen Abnahmekriteriums*)
- **pfad:** `slice-104` §1 (*„→ **leer**"*) und §2 DoD (3) (*„heute **leer**"*)
- **befund:** Das genannte Kommando liefert drei Treffer, einer davon über genau der Datei, die
  der Punkt meint:

  ```sh
  grep -l '^# files:.*full-smoke' test/mutations/*.sh
  # test/mutations/187-ausgang-ohne-muster.sh          (harness/tools/full-smoke-ausgang.sh)
  # test/mutations/188-ausgang-immer-leitung.sh        (harness/tools/full-smoke-ausgang.sh)
  # test/mutations/190-abdeckung-einordnung-entfernt.sh (harness/tools/full-smoke.sh)
  git log --diff-filter=A --format=%ad --date=short -- test/mutations/190-*.sh   # 2026-08-27
  ```

  `190` liegt seit **2026-08-27** im Baum, also vor Beginn dieser Arbeit; DoD (3) war damit bereits
  erfüllt. Der gelieferte Fall `305` erscheint in dieser Messung **gar nicht** — sein
  `# files:` nennt `internal/span/emit.go`. Das Kriterium misst nicht, was der Slice liefert.
  **Substanziell** ist die Lücke trotzdem geschlossen: `190` mutiert `einordnen`, nicht
  `rollen_typen_im_ziel`, und `305` ist der erste Fall, dessen erwartetes Rot aus dieser Schleife
  kommt. Nur trägt der geschriebene Maßstab das nicht.
- **streichen oder umformulieren:** Die Aussage *„über seiner Schleife liegt kein Fall"* braucht ein
  Kommando, das die **Schleife** trifft, nicht die Datei — etwa
  `grep -l '^# expect:.*Rollen-Typ fehlt' test/mutations/*.sh`.
- **Rollen-Hälfte:** Das Nachziehen ist **nicht** Implementer-Arbeit — ein DoD-Punkt gehört als
  Übergabe-Artefakt an den Planner ([`AGENTS.md`](../../AGENTS.md) §3.10). Der Befund ist, dass die
  Drift **nicht gemeldet** wurde, während dieselbe Klasse bei Frage A (§3) ausdrücklich gemeldet
  wurde.
- **verifizierbar:** ja — die Kommandos oben.
- **klasse:** Akzeptanz-Kriterium misst nicht das gelieferte Artefakt

### LOW-1 — Zwei weitere überholte Messungen im lebenden Plan, eine davon unvollständig nachgezogen

- **kategorie:** LOW
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- **pfad:** `slice-104` §3 Plan-Tabelle, Zeilen zu `internal/span/emit.go` und
  `internal/emit/agents_test.go`
- **befund:** (a) Die Zeile trägt weiterhin *„`grep -rn 'ai-harness-init/internal/span'
  internal/emit/*.go | wc -l` → **0** … beide Richtungen sind offen"*; gemessen **2**
  (`internal/emit/fieldlist.go:4`, `internal/emit/agents.go:7`). Der hinzugefügte Block darunter
  korrigiert die Prämisse, die Zeile selbst bleibt stehen — zwei Messungen desselben Kommandos in
  einem Dokument. (b) Dieselbe Tabelle sagt für die Emissions-Menge *„gemessen **6**"*, der
  gelieferte Kommentar sagt **DREI**. Nachgemessen ist **3** für Inhaltsdateien unter
  `docs/plan/planning/` bzw. `docs/plan/adr/` (`planning/README.md`,
  `planning/in-progress/roadmap.md`, `planning/observations/README.md` — alle übrigen
  Baseline-Vorlagen fallen unter `isRecurring`/`isDerivativeIndex`/`isBrownfieldOnly`); der
  Kommentar nennt die **vier** zusätzlich emittierten `.gitkeep` nicht, die dasselbe Muster
  ebenfalls verbietet.
- **verifizierbar:** ja — die Kommandos in (a); für (b)
  `find .harness/baseline/v6.5.0/templates/docs/plan -type f` gegen
  `sed -n '/^func isRecurring/,/^}/p' internal/emit/templates.go`.
- **klasse:** Überholte Messung bleibt neben ihrer Korrektur im lebenden Artefakt stehen

### INFO-1 — Die dritte Option aus Frage A bleibt unbeschieden

- **kategorie:** INFO
- **quelle:** Slice-Plan `slice-104` §4 (Rückführung `in-progress → next`)
- **pfad:** `slice-104` §3, Antwortblock zu Frage A
- **befund:** §4 macht *„ein drittes, gemeinsames Paket"* zur Rückführungs-Bedingung. Der
  Antwortblock zeigt, dass von den **zwei Richtungen** nur eine übrig ist, verwirft die dritte
  Option aber nicht ausdrücklich. Das Ergebnis ist tragfähig (s. Negativbefund N-1) — die
  Rückführungs-Prüfung ist trotzdem nicht sichtbar gefahren.
- **verifizierbar:** nein — Plan-Lesung.
- **klasse:** Rückführungs-Bedingung nicht ausdrücklich beantwortet

---

## Negativbefunde (geprüft, ohne Befund)

**N-1 — Frage A: Messung stimmt, und es ist keine neue Architektur-Kante.**
`internal/emit/fieldlist.go:4` importiert `internal/span`; die Gegenrichtung wäre ein
Import-Zyklus und übersetzt nicht. Die Datei existierte am Plan-Datum noch nicht
(`git show e6160ca9:internal/emit/fieldlist.go` → `fatal: … befindet sich im Dateisystem, aber nicht in e6160ca9`), die Plan-Prämisse war also korrekt und ist
seither überholt. **Entscheidend für die Rollen-Frage:** die Kante `internal/emit → internal/span`
bestand bereits; `internal/emit/agents.go:7` fügt keine neue Paket-Abhängigkeit hinzu, sondern
nutzt eine bestehende. Es ist damit keine Architektur-**Entscheidung**, sondern die einzige
zyklenfreie Ausprägung einer schon getroffenen. Kein ADR geschuldet; die Gegenrichtung, die
[`ADR-0022`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a)
berührt hätte, ist gerade die verworfene. **Das Schreiben in §3 war zulässig:** der Plan führt die
drei Fragen selbst als *„Offen, vor dem Code zu entscheiden"* und macht ihre Beantwortung im Plan
zum Closure-Trigger (§5). Kein DoD-Punkt, kein Closure-Trigger, keine Out-of-Scope-Grenze wurde
dabei verschoben — [`AGENTS.md`](../../AGENTS.md) §3.10 ist nicht berührt.

**N-2 — Der emittierte Text ist byte-gleich, und eine Umbenennung fällt auf.**
`backtickJoin(CanonicalRoles())` erzeugt exakt die vorher literale Aufzählung; gegen den
Vorgänger-Commit gemessen:

```sh
git show 61c45ba7^:internal/span/fieldlist.go | sed -n 's/.*Rollen nennt — \(.*\)\. Wer.*/\1/p'
sed -n 's/.*return \[\]string{\(.*\)}.*/\1/p' internal/span/emit.go | head -1 | tr -d '"' | tr ',' '\n' \
  | sed 's/^ *//' | awk '{printf "%s`%s`", (NR>1?", ":""), $0} END{print ""}'
# beide: `planner`, `architect`, `implementer`, `reviewer`, `verifier`, `validator`  (sha256 6ae85387d802dc56)
```

Die übrigen fünf Zeilen des Satzes sind im Diff unverändert. **Wodurch eine Umbenennung bemerkt
wird:** nicht durch `TestFeldliste_LiegtVerbatimImZiel` — der hält Transport, beide Seiten kommen
aus derselben Funktion, und er sagt das selbst. Sie fällt **an der Quelle** auf, an drei
unabhängigen Stellen: `TestAgentRoleFromKnownTypes` und `TestSpawnedRoleIsNormalised`
(zwei Literal-Tabellen in `internal/span/response_test.go` bzw. `internal/span/span_test.go`,
beide vom Slice nicht abgeleitet) und `TestRollenAchseFolgtDerEinenQuelle`
(`emit.AgentFile(".claude/agents/<name>.md")` → `nil`, weil keine eingebettete Typ-Datei unter dem
neuen Namen liegt). Der emittierte Text selbst ist unverändert an **keine** zweite Literal-Liste
gebunden (`grep -c "planner" internal/span/fieldlist_test.go internal/emit/fieldlist_test.go` →
0 und 0) — das ist die notwendige Folge von DoD (1) und kein Mangel: eine zweite Liste dort wäre
genau der Fundort, den der Slice beseitigt. Die vorherige Lage, in der die Liste im Adopter-Repo
stehenblieb, besteht nicht mehr (`grep -c 'planner' internal/span/fieldlist.go` → 0).

**N-3 — DoD (2): die Stufe ist richtig gewählt, und sie hängt nicht am Nichts.**
`full-smoke` steht nicht in `make gates` (`sed -n '411p' Makefile`) — das ist richtig gemessen und
vom Plan §6 selbst als Eigenschaft der Stufe benannt. Die Zusage hängt trotzdem an einem
mechanischen Auslöser: `306` trägt `# verify: full-smoke`, der Treiber kennt diese Stufe
(`failure_form()` in `harness/tools/mutate.sh`, Fehlschlag-Form `full-smoke: FEHLER`), und CI fährt
`make mutate` pro Push. **Kein Streichen geboten** — die richtige Fassung ist die benannte Grenze,
die §6 des Plans schon trägt; sie gehört in die Closure-Notiz.

**N-4 — Die Erwartungs-Zeichenkette von `305`/`306` trifft wirklich.**
`FEHLER — Rollen-Typ fehlt` ist in Fall und Skript byte-gleich (Em-Dash `342 200 224`, `od -c`),
und `rollen_typen_im_ziel` läuft in `harness/tools/full-smoke.sh:220` **vor** dem `make gates` des
Ziels (`:236`) — kein früherer `full-smoke: FEHLER` kann den Grund verdecken. Der Anker von `306`
greift und entfernt genau den Drei-Zeilen-Block (`cmd/ai-harness-init/main.go:450-452`).

**N-5 — Der Nicht-Leer-Schutz in `rollen_typen_im_ziel` trägt.**
`shopt -s nullglob` (`:100`) sorgt dafür, dass ein Fehlgriff beim Pfad **null** Durchläufe statt
eines Literal-Durchlaufs ergibt; der Zähler `n` wird in der Schleife erhöht und **nach** ihr gegen
0 geprüft (`:115-118`, `exit 1`). `HIER` ist real definiert (`:21`, `cd $(dirname BASH_SOURCE) && pwd`),
die Quelle trägt sechs Dateien (`ls -1 internal/emit/templates/agents/*.md | wc -l` → 6). Der
Vergleich hängt an **zwei** verschiedenen Artefakten — Dateibestand der Vorlagen gegen
Ziel-Verzeichnis —, nicht an einem; das Zirkularitäts-Risiko aus §6 des Plans ist vermieden. Die
Erfolgszeile nennt `$n` statt einer festen 6.

**N-6 — Die Abdeckungs-Gleichung von `full-smoke.sh` ist unverändert.**
A−B−C über der A-Liste = **27**, `einordnen`-Zeilen − 2 = **27**, vor und nach dem Slice identisch
(Formeln aus `harness/README.md` §Nicht-Gate-Verify). Fall `190` greift weiterhin.

**N-7 — Die drei nachgezogenen Anker sind real repariert.**
Gegen eine Kopie außerhalb des Repos, je mit `sed` und `sha256sum`: alter Anker (aus `08b1aeeb^`)
**NO-OP**, neuer Anker **greift** — für `167`, `168` und `169` einzeln.

**N-8 — §3.11-Vormessung: die Berufung trägt.**
Der Verweis-Nachzug von `c4182efb` schrieb in drei eingefrorene Zeitdokumente unter
`docs/plan/planning/done/`. Der zitierte Register-Eintrag
`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt` steht auf `offen`, weist die
Norm-Frage ausdrücklich dem Architect zu und benennt bis dahin *„der Lauf, der den Move plant"* als
Träger — bei `next → in-progress` ist das der Implementer. Messen, melden, fortfahren war damit
gedeckt. Der Zähler steht bei **10**
(`ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/evidence/*.md | wc -l`,
kein Erwartungswert); der Beleg dieses Vorgangs gehört in die **Slice-Closure**, nicht in diesen
Lauf.

**N-9 — `AgentFile()` hat seinen Aufrufer.**
`grep -rn 'AgentFile' --include=*.go .` → Definition plus `internal/emit/rollen_kopplung_test.go:35`.
Der Doc-Kommentar *„(fuer Tests/Inspektion)"* trifft damit zu; der Posten aus §3 des Plans ist
eingelöst.

**N-10 — Jeder in einem neuen Kommentar genannte Sensor existiert.**
`TestAgentRoleFromKnownTypes`, `TestRollenAchseFolgtDerEinenQuelle`,
`TestAgents_KanonischeRollenLiegenImZiel`, `TestFeldliste_GrenzeAufrufform`,
`TestSpawnedRoleIsNormalised`, `TestFeldliste_LiegtVerbatimImZiel` — je genau eine Definition.

**N-11 — §3.9-Fußfehler: kein Code-Befund.**
Der selbst gemeldete Ad-hoc-`docker run` mit Host-Go-Image berührt kein Artefakt im Diff; die
Ergebnisse dieses Laufs sind alle über `make`-Ziele wiederholbar. Notiert, nicht gewertet.

**N-12 — Kein `_test.go`-Vertrag verwässert.**
`internal/span/response_test.go` ist entgegen der Plan-Zeile *„unverändert"* berührt — die Änderung
ist ein Bezeichner in einem Doc-Kommentar (`roleFromAgentType` → `RoleFromAgentType`). Die
Literal-Tabelle mit ihren 6 Erwartungen und 10 Verneinungen ist unangetastet; die Grenze aus §1
des Plans hält. Kein Befund.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 3 | Symbol-Umbenennung lässt Mutations-Fall zahnlos zurück (2×, **ein** Vorgang → ein Register-Beleg) · Kommentar beschreibt abwesenden Text |
| MEDIUM | 2 | Akzeptanz-Kommando misst eine weitere Menge als die zugesagte Eigenschaft · Akzeptanz-Kriterium misst nicht das gelieferte Artefakt |
| LOW | 1 | Überholte Messung bleibt neben ihrer Korrektur im lebenden Artefakt stehen |
| INFO | 1 | Rückführungs-Bedingung nicht ausdrücklich beantwortet |

**Wiederkehrende Klasse für den Steering Loop (Closure §7):** *Symbol-Umbenennung lässt
Mutations-Fall zahnlos zurück* — HIGH-1 und HIGH-2 sind **zwei Funde in einem Vorgang** und damit
**eine** Gelegenheit, kein zweites Auftreten.

## Verdikt

**Blockierend.** HIGH-1 und HIGH-2 sind Wächter ohne Zähne und färben den laufenden
`make mutate` rot; der Closure-Trigger aus §5 (*„`make mutate` grün mit den neuen Fällen"*) ist
damit nicht erreichbar. HIGH-3 ist eine Hard-Rule-Verletzung ohne Gate dahinter. MEDIUM-1 und
MEDIUM-2 sind Über-Zusagen im Abnahmemaßstab und vor Merge zu klären — MEDIUM-2 als
Übergabe-Artefakt an den Planner, nicht als Implementer-Korrektur.

**Der Kern des Slice trägt.** Die eine Quelle steht, die Ableitungs-Richtung ist die einzig
zyklenfreie, der emittierte Text ist byte-gleich und folgt jetzt der Quelle, der Voll-E2E-Sensor
führt keine eigene Liste mehr und ist gegen den Nulldurchlauf abgesichert. Was fällt, fällt an den
Rändern: an drei Mutations-Fällen und an drei Sätzen des Abnahmemaßstabs.
