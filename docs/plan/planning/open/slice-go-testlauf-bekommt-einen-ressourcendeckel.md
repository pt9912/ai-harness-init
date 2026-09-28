# Slice slice-go-testlauf-bekommt-einen-ressourcendeckel: Der Go-Testlauf bekommt einen wirksamen Ressourcen-Deckel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle (Harness-Mechanik) — wie beim Geber-Slice: der Anlass
fiel in [welle-09](../welle-09-modul-15-konformitaet.md), der Inhalt gehört
nicht dorthin.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (rot gesehener Wächter für die neue
Grenze, die bestehende Cache-Zusage darf ihren nicht verlieren).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-28.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Go-Testlauf bekommt einen wirksamen Prozess- und Speicher-Deckel
ohne Host-Mount, der Deckel hat einen Wächter, der rot wird, wenn er fällt, und
die bestehende zweistufige Cache-Zusage überlebt den Umbau — inklusive des
Nachweises, dass `make mutate` den Deckel über `make test-go` erbt.

**Übernimmt:** `slice-065-testlauf-ressourcendeckel` (Anteil: Deckel + Wächter
+ Cache-Zusage + mutate-Vererbung; der zweite Anteil — Verankerung von
`harness/tools/agent-watch.sh` — geht an
`slice-agent-watch-sh-wird-verankert`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Verankerung von `harness/tools/agent-watch.sh`.** Anderer Gegenstand
  (Melder statt Deckel, andere Datei, anderer Wächter-Vertrag) — eigener
  Folge-Slice `slice-agent-watch-sh-wird-verankert`, der den Punkt annimmt.
  Genau diese Vermischung machte den Geber-Slice zu groß (5 statt ≤ 3
  Liefer-Punkte, siehe Trigger-Notiz des Gebers).
- **Eine Regel gegen die gefährliche Form** (ein `_test.go`, das sich selbst
  re-exec't, muss in `TestMain` abzweigen). Bereits im Geber-Slice als
  Folge-Slice-Kandidat benannt und dort bewusst nicht mitgenommen — *es wäre
  ein anderer Vorgang*: ein hermetischer Gate neben `make comment-claims`,
  nicht Teil des Ressourcen-Deckels.
- **Ein Zeit-Deckel je Mutationsfall** (`timeout`). Vom Auftraggeber im
  Geber-Slice bereits verworfen — wirkungslos gegen die Klasse, die diesen
  Slice auslöste. *Bestand bleibt bewusst stehen.*

## 2. Definition of Done

**Drei Liefer-Punkte** (gezählt wie im Geber-Slice vorgemacht: nur was mit dem
Umfang wächst).

- [ ] **(1) Der Testlauf läuft mit wirksamem Prozess- und Speicher-Deckel —
  und ohne Mount, und `make mutate` erbt ihn nachweislich.** Der Quellcode
  kommt wie heute per `COPY` **ins Image**; der Container bekommt kein `-v`.
  Belegt an einer Messung, nicht an einer Flag-Zeile: eine **feste** Last
  (nicht rekursiv, keine Bombe) muss unter dem Deckel scheitern und ohne ihn
  durchlaufen. Zusätzlich belegt: `make mutate` läuft über `make test-go` und
  erbt den Deckel dadurch strukturell — das ist zu zeigen (Aufruf-Kette), nicht
  anzunehmen.
- [ ] **(2) Die Grenze hat einen Wächter, der rot wird, wenn der Deckel
  fällt.** Ein Test, der eine feste Zahl gleichzeitiger Prozesse startet und
  deren **Scheitern erwartet**: mit Deckel grün, ohne Deckel rot. Er ist in
  beiden Zuständen ungefährlich, weil die Zahl fest ist
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **(3) Die bestehende Cache-Zusage überlebt den Umbau — umgeschrieben,
  nicht gelöscht.** Heute gilt sie auf zwei Ebenen: `--no-cache-filter test`
  erzwingt die Docker-Schicht neu, `-count=1` die Tests neu. Mit `docker run`
  entfällt die erste Ebene (ein Run wird nie gecacht) — die Zusage bleibt
  („jeder Lauf misst wirklich neu"), ihr Beleg muss auf die neue Mechanik
  zeigen. Bewacht von `test/dockerfile-teststufe.bats` und
  `test/mutations/98-teststufe-count.sh`.
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues
      Verzeichnis oder weitere Datei in `evidence/`; keine Beobachtung
      angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen —
      dieses Repo fährt Wellen-Betrieb, also prüft sie die nächste
      Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Die Ist-Messung aus dem Geber-Slice (sieben Zeilen: welche Docker-Flags
wirklich greifen) bleibt gültig — sie hängt nicht am Melder und ist hier
unverändert zu übernehmen, nicht neu zu erheben.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Dockerfile` | update | Eine Stage mit Quellcode, aber **ohne** `RUN go test`. Der Testlauf verlässt den Build |
| `Makefile` (`test-go`) | update | `docker run --rm --network none --pids-limit … --memory … <image> go test -count=1 ./...`. Kein `-v` |
| Wächter für die Grenze | neu | DoD (2). Wirkung messen, nicht Konfiguration lesen (§3.6) |
| `test/dockerfile-teststufe.bats` | update | DoD (3): Cache-Zusage auf neue Mechanik umschreiben |
| `test/mutations/98-teststufe-count.sh` | update | dito — Mutation muss weiter röten |
| Zahlenwahl (`pids-limit`, `memory`) | Entscheidung | aus realem Bedarf gemessen, mit Abstand darüber gesetzt |

## 4. Trigger

**Start** (`next` → `in-progress`): keine externe Abhängigkeit. Größen-Regel
erfüllt (3 Liefer-Punkte, siehe §2). WIP-Limit ist die einzige verbleibende
Bedingung (`ls docs/plan/planning/in-progress/slice-*.md | wc -l` → 0 am
2026-09-28, mitwandernd).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls sich beim
  Bauen zeigt, dass Deckel/Wächter und Cache-Zusage doch unabhängig
  voneinander scheitern können und getrennte Nachweis-Läufe brauchen, die
  sich nicht in einem Commit-Satz halten lassen.
- `in-progress` → `open` (blockiert — Carveout?): falls sich zeigt, dass der
  Deckel den Testlauf in der CI anders trifft als lokal (andere
  cgroup-Version, andere Limits). Dann ist erst die Umgebung zu klären.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10); Verifikation bestätigt die DoD
(Modul 11); `make gates` und `make mutate` grün; `git mv` nach `done/`
(eigener Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Ein Deckel, der nicht greift, ist schlimmer als keiner** — er behauptet
  Schutz. Deshalb verlangt DoD (1) die Messung, nicht die Flag-Zeile. —
  **Ausgang:** <eingetreten / entfallen / weiter offen — bei Closure zu
  setzen>
- **Der zu enge Deckel.** Der Go-Testlauf startet selbst Prozesse (Compiler,
  Testbinaries, der re-exec'ende Kind-Prozess). Ein knapper Wert macht den
  Gate flatterig. — **Ausgang:** <…>
- **Die Cache-Zusage ist der eigentliche Arbeitsanteil**, nicht der Deckel.
  Wer nur die Flags umstellt, lässt einen Wächter still ins Leere zeigen. —
  **Ausgang:** <…>
- **Der Wächter aus DoD (2) misst eine Umgebungs-Eigenschaft**, keine
  Code-Eigenschaft: er ist grün, weil der Aufrufer den Deckel setzt. —
  **Ausgang:** <…>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Eine Sub-Area, `*` (gesamtes Repo,
Kürzel `ALL`) — `Makefile`, `Dockerfile` und `test/` gehören zum
Greenfield-Bestand dieses Repos, Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md).

**Vorgelagert — offene Beobachtungen sichten:** wie beim Geber-Slice
zu wiederholen, vor Arbeitsbeginn (gemergter Stand).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — Docker-only ist
  [`ADR-0003`](../../adr/0003-go-native-binaries.md), die Test-Cache-Zusage ist
  zweifach bewacht (§2).
- **Phase-Reife:** Phase 5 (Betrieb) — `make test` läuft in `make gates` und
  in CI.
- **Evidenz-/Diskrepanz-Risiko:** niedrig — GF, kein Inventur-Fund.
- **Reconciliation-Aufwand:** keiner — GF; Graduation entfällt.
