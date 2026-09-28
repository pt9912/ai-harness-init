# Slice slice-agent-watch-sh-wird-verankert: Der Melder harness/tools/agent-watch.sh bekommt seine Verankerung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle (Harness-Mechanik, wie beim Geber-Slice).

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Zusage nennt ihren
Sensor), `make comment-claims` (Prüfbereich `harness/tools/*.sh`),
`make shell-lint`.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-28.

---

## 1. Ziel und Abgrenzung

**Ziel:** `harness/tools/agent-watch.sh` — vorhanden seit slice-059 (entstanden
als ungeplantes Artefakt), bisher ohne Makefile-Ziel, ohne Eintrag in
`harness/README.md` §Werkzeuge und ohne Testabdeckung — bekommt eine
Verankerung: ein Makefile-Ziel (oder eine ausdrückliche Einordnung als
Nicht-Gate-Werkzeug mit Zeile in der Werkzeuge-Tabelle), damit der Melder
nicht länger unbewacht im Repo liegt.

**Übernimmt:** `slice-065-testlauf-ressourcendeckel` (Anteil:
Melder-Verankerung — der andere Anteil, der Ressourcen-Deckel selbst, geht an
`slice-go-testlauf-bekommt-einen-ressourcendeckel`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Ressourcen-Deckel für den Go-Testlauf.** Anderer Gegenstand (Deckel
  statt Melder) — eigener Slice
  `slice-go-testlauf-bekommt-einen-ressourcendeckel`, der den Punkt annimmt.
- **Änderung der Melder-Schwellenwerte.** Die Basislinie (~3 GB
  Normalbetrieb, 0,15 GB pro seriellem Agenten-Lauf) ist bereits gemessen und
  bleibt stehen; dieser Slice verankert den Melder, er kalibriert ihn nicht
  neu. *Bestand bleibt bewusst stehen.*
- **Ein neuer `MR`-Eintrag im Adaptions-Block**, falls die Verankerung eine
  Norm-Aussage über die Werkzeug-Landschaft würde. Das gehört dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8); trägt sich die Verankerung
  ohne eine solche Aussage (reines Wiring: Makefile-Ziel + README-Zeile),
  entfällt der Punkt ganz — zu entscheiden im Lauf, nicht vorab. *Es wäre ein
  anderer Vorgang, falls er eintritt.*

## 2. Definition of Done

**Ein Liefer-Punkt:**

- [x] **(1) `harness/tools/agent-watch.sh` ist verankert und Teil der
      geprüften Fläche.** Entweder trägt es ein `make`-Ziel (Gate oder
      Werkzeug, je nach Charakter) mit Zeile in
      [`harness/README.md`](../../../../harness/README.md) — Sensors- oder
      Werkzeuge-Tabelle, `kein Gate`-Marke falls zutreffend — oder es ist als
      Nicht-Gate-Werkzeug ausdrücklich eingetragen. In jedem Fall: das Skript
      ist von `make shell-lint` erfasst (Prüfbereich `harness/tools/*.sh`)
      und von `make comment-claims`, falls es dort Abdeckung behauptet.
      Belegt mit Kommando, nicht angenommen:
      `grep -rl 'agent-watch' Makefile test/ harness/README.md | wc -l` gibt
      danach mindestens **2** aus (heute: 0).
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues
      Verzeichnis oder weitere Datei in `evidence/`; keine Beobachtung
      angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen —
      dieser Slice ist wellenlos (`Welle:` `—`), also prüft sie diese
      Slice-Closure direkt (`modul-06-roadmap.md` §Wann Arbeit eine Welle
      braucht, Tabelle *Träger im Repo ohne Wellen*), nicht eine spätere
      Welle-Closure.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/agent-watch.sh` | gelesen, unverändert | Bestand geprüft: Dauerschleife ohne Exit-Code-Urteil über einen Repo-Zustand — kein Gate-Kandidat, Kopf trägt Zweck/Grenze bereits vollständig, kein Ergänzungsbedarf |
| `Makefile` | update (neues Ziel `agent-watch`, reines Werkzeug, `NICHT in gates`) | DoD (1) |
| [`harness/README.md`](../../../../harness/README.md) | update (eine Zeile, Werkzeuge-Tabelle, `kein Gate`-Marke) | DoD (1) |
| `.d-check.yml` | update (zwei Stellen: Kommentar-Aufzählung + `targets.exempt-targets`-Liste) | **Korrektur (Review-Report `docs/reviews/2026-09-28-slice-agent-watch-sh-wird-verankert.md`, F-1):** die ursprüngliche Begründung war falsch. Real mit `make docs-check` gemessen (drei Kombinationen): Richtung 2 (`gate-phantom`) prüft nur, ob das referenzierte Rezept im Makefile existiert — das ist hier unabhängig vom `.d-check.yml`-Eintrag trivial erfüllt, sobald das Ziel angelegt ist; der Eintrag schützt also **nicht** gegen Richtung 2. Richtung 1 (`gate-undocumented`) verlangt, dass jedes `.PHONY`-Rezept entweder als `make X`-Tabellenzeile in der `authority`-Datei (`harness/README.md`) oder in `exempt-targets` steht — die in diesem Commit ebenfalls hinzugefügte README-Zeile erfüllt diese Bedingung bereits allein, der `.d-check.yml`-Eintrag ist unter der real vorliegenden Bedingung redundant, aber nicht schädlich. Er trüge alleinig nur, würde die README-Zeile fehlen (dann liefe `docs-check` mit `gate-undocumented`/Richtung 1 rot). Der Eintrag folgt dem etablierten Gruppe-(a)-Doppel-Registrierungs-Muster (README + `exempt-targets`) aller Nicht-Gate-Werkzeuge dieser Liste und bleibt aus diesem Grund bestehen. |
| `test/` | entfällt | Charakter ist reines Werkzeug (kein Gate, kein funktionaler Wächter über Repo-Zustand) — kein DoD-Punkt verlangt hier einen Test; shell-lint und comment-claims erfassen das Skript bereits über ihre bestehenden Globs (`harness/tools/*.sh`), ohne Änderung dort |

**Reihenfolge:** erst das Skript lesen und seinen Charakter (Gate vs.
Werkzeug) feststellen, dann den Träger wählen, dann verankern. **Ergebnis:**
reines Werkzeug — das Skript läuft als Dauerschleife und trifft nie ein
Exit-Code-Urteil über einen Repo-Zustand; es beobachtet und meldet, es prüft
nicht (dieselbe Unterscheidung wie bei `slice-mv`/`hook-overhead`/`span-clean`
in derselben Werkzeuge-Tabelle). Die Verankerung selbst ist reines Wiring
(Makefile-Ziel + README-Zeile + `.d-check.yml`-Registrierung) ohne
Norm-Aussage über die Werkzeug-Landschaft — §1 Ausschluss 3 entfällt damit,
kein MR-Eintrag.

## 4. Trigger

**Start** (`next` → `in-progress`): keine externe Abhängigkeit, unabhängig von
`slice-go-testlauf-bekommt-einen-ressourcendeckel` (anderer Gegenstand, keine
gemeinsame Datei). WIP-Limit ist die einzige Bedingung.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls sich zeigt,
  dass der Melder einen funktionalen Wächter mit eigenem Testsatz braucht,
  der über eine Zeile Wiring hinausgeht.
- `in-progress` → `open` (blockiert — Carveout?): falls die Einordnung
  Gate-vs-Werkzeug eine Norm-Entscheidung des Architect voraussetzt, die noch
  nicht vorliegt.

## 5. Closure-Trigger

DoD vollständig; `make gates` grün; `git mv` nach `done/` (eigener
Move-Commit); Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Melder bleibt unbewacht, weil die Verankerung nur eine Zeile
  Prosa ist, kein Gate.** `harness/README.md` würde ihn nennen, aber niemand
  prüfte, ob die Nennung stimmt. — **Ausgang: weiter offen.** Die enge Lesart
  (stimmt die Nennung mit dem Bestand überein?) ist inzwischen mechanisch
  gedeckt — `make docs-check` prüft mit dem gepinnten `v0.79.0` beide
  Richtungen (`gate-undocumented`/`gate-phantom`), real mit drei Kombinationen
  gemessen (Review-Report F-1). Offen bleibt die weitere Lesart, die der
  Verifier benennt: die **funktionale** Korrektheit des Melders selbst (misst
  er Speicher richtig, schlägt er rechtzeitig an?) — dafür existiert kein
  Sensor, und der Plan schließt einen Test bewusst aus (§3). Wandert ins
  Beobachtungs-Register:
  `../observations/BEO-TOOLS/nicht-gate-werkzeug-ohne-funktionalen-waechter/`.
- **Die Einordnung Gate-vs-Werkzeug ist selbst ein Urteil**, das dieser Slice
  treffen muss, ohne dass eine Quelle es vorab entscheidet — siehe §1
  Ausschluss 3. — **Ausgang: entfallen.** Die Rückführungs-Bedingung aus §4
  (`in-progress` → `open`, falls die Einordnung eine noch fehlende
  Architect-Norm-Entscheidung voraussetzt) ist nicht eingetreten: Die
  Einordnung folgte dem etablierten Präzedenzfall (`hook-overhead`,
  `slice-mv` — Dauerschleife/Bewegung ohne Exit-Code-Urteil über einen
  Repo-Zustand, in derselben Werkzeuge-Tabelle) und wurde von Reviewer und
  Verifier unabhängig voneinander bestätigt, ohne dass eine offene
  Norm-Frage blieb.

## 7. Closure-Notiz

- **Was hat funktioniert:** Die Charakter-Feststellung aus §3 (Dauerschleife
  ohne Exit-Code-Urteil → reines Werkzeug, kein Gate) trug bis zum Schluss und
  wurde von Reviewer und Verifier unabhängig bestätigt — kein Rollen-Konflikt,
  keine Rückführung nötig.
- **Was ging anders als geplant:** Der erste Implementer-Commit
  (`81f749af`) und der ursprüngliche Plan-Nachtrag zur `.d-check.yml`-Zeile
  behaupteten eine falsche Kausalität — die Begründung, warum der Eintrag
  nötig sei, benannte die falsche Gate-Richtung (Review-Report
  `docs/reviews/2026-09-28-slice-agent-watch-sh-wird-verankert.md`, F-1,
  HIGH). Real mit `make docs-check` in drei Kombinationen gemessen, trägt die
  README-Zeile allein bereits Richtung 1 (`gate-undocumented`); der
  `.d-check.yml`-Eintrag ist unter der vorliegenden Bedingung redundant, aber
  nicht schädlich, und bleibt aus Konsistenz zum etablierten
  Doppel-Registrierungs-Muster stehen. Korrigiert in `5169e773`, bestätigt in
  `bf173d04`. Lehrstück für [`AGENTS.md`](../../../../AGENTS.md) §3.6: eine
  Zusage über *warum* ein Gate rot liefe, ohne den Gate-Lauf in den
  behaupteten Kombinationen gesehen zu haben — genau die Klasse, die §3.6
  bereits als „Falsch: Byte-Gleichheit belegt `make smoke`, ohne `smoke`
  gelesen zu haben" führt. Keine neue Regel nötig; die bestehende griff, weil
  der Reviewer sie anwandte — das Instrument hat gehalten.
- **Steering-Loop-Eintrag (benannte Spec-Lücke):** Kein Sensor deckt die
  **funktionale** Korrektheit eines als `kein Gate` deklarierten
  Nicht-Gate-Werkzeugs unter `harness/tools/` — nur seine Doku-Konsistenz ist
  bewacht (`docs-check`). Benannt in
  `../observations/BEO-TOOLS/nicht-gate-werkzeug-ohne-funktionalen-waechter/`
  (Erstauftreten, 1×) — noch nicht verkörpert, kein `liegt in`-Feld.
- **Beobachtungs-Register (`../observations/`):**
  `BEO-TOOLS/nicht-gate-werkzeug-ohne-funktionalen-waechter/` neu angelegt,
  Beleg `evidence/slice-agent-watch-sh-wird-verankert.md`.
- **Folge-Slices:** keine.
- **Risiken aus §6:** Risiko 1 (Melder unbewacht) → weiter offen, ins
  Beobachtungs-Register überführt. Risiko 2 (Gate-vs-Werkzeug-Einordnung ein
  Urteil) → entfallen, siehe §6.
- **Drei Paarungen** (wellenlos, direkt bei dieser Slice-Closure geprüft —
  `Welle:` dieses Slice ist `—`):
  - **Anker-Paarung:** kein Eintrag trägt `liegt in <Zielort>` — nichts wurde
    mit diesem Slice verkörpert, nichts zu paaren (vacuously grün).
  - **Folge-Slice-Paarung:** kein Folge-Slice genannt — nichts zu paaren
    (vacuously grün).
  - **Register-Paarung:** (a) die in dieser Closure zitierte Beobachtung
    existiert als Verzeichnis — ja. (b) jede Registerzeile trägt mindestens
    einen Beleg, geprüft über das **ganze** Register:
    `for d in docs/plan/planning/observations/BEO-*/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`
    findet **4** Verzeichnisse ohne Beleg — vorbestehend, nicht durch diesen
    Slice verursacht (Befund der Paarung nach
    [`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md),
    keine Ausnahme):
    `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/`,
    `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht/`,
    `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/`
    (Stand `gestrichen` — kein Beleg nötig),
    `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird/`. Die
    Hälfte gilt hier **nicht** als getragen für die drei offenen; dieser
    Slice hat sie nicht verursacht und behebt sie nicht.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Eine Sub-Area, `TOOLS`
(`harness/tools/`) — bereits deklariert in
[`harness/conventions.md`](../../../../harness/conventions.md) als
*„adoptierte Harness-Mechanik"*.

**Vorgelagert — offene Beobachtungen sichten:** wie beim Geber-Slice zu
wiederholen, vor Arbeitsbeginn (gemergter Stand). Bei Closure erneut geprüft
(`docs/plan/planning/observations/BEO-{ALL,TOOLS}/*/`, Zähler = Zahl der
`evidence/*.md`): kein Eintrag unter der 3×-Schwelle hat mit diesem Slice die
Schwelle erreicht — höchster offener Stand bleibt 2×.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.

### Sub-Area: `harness/tools/` (Kürzel `TOOLS`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — Ort und Form der Harness-Tools sind
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)/[`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)
  entschieden.
- **Phase-Reife:** Phase 3 für dieses konkrete Skript — es existiert, ist aber
  nicht verankert; Phase 5 für die Werkzeug-Fläche insgesamt.
- **Evidenz-/Diskrepanz-Risiko:** niedrig — der Bestand ist ein einzelnes,
  benanntes Skript.
- **Reconciliation-Aufwand:** keiner — GF; Graduation entfällt.
