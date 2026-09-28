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

- [ ] **(1) `harness/tools/agent-watch.sh` ist verankert und Teil der
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
- [ ] `make gates` grün.
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

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/agent-watch.sh` | gelesen, unverändert | Bestand geprüft: Dauerschleife ohne Exit-Code-Urteil über einen Repo-Zustand — kein Gate-Kandidat, Kopf trägt Zweck/Grenze bereits vollständig, kein Ergänzungsbedarf |
| `Makefile` | update (neues Ziel `agent-watch`, reines Werkzeug, `NICHT in gates`) | DoD (1) |
| [`harness/README.md`](../../../../harness/README.md) | update (eine Zeile, Werkzeuge-Tabelle, `kein Gate`-Marke) | DoD (1) |
| `.d-check.yml` | update (zwei Stellen: Kommentar-Aufzählung + `targets.exempt-targets`-Liste) | ohne diesen Eintrag meldet `docs-check` das neue Makefile-Ziel als Gate-Phantom (Richtung 2, §Prosa-Erwähnung ohne Vollständigkeits-Deckung) — in der ursprünglichen Plan-Tabelle nicht vorgesehen, ergibt sich aus der Werkzeug-Wahl |
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
  prüfte, ob die Nennung stimmt. — **Ausgang:** <eingetreten / entfallen /
  weiter offen — bei Closure zu setzen>
- **Die Einordnung Gate-vs-Werkzeug ist selbst ein Urteil**, das dieser Slice
  treffen muss, ohne dass eine Quelle es vorab entscheidet — siehe §1
  Ausschluss 3. — **Ausgang:** <…>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Eine Sub-Area, `TOOLS`
(`harness/tools/`) — bereits deklariert in
[`harness/conventions.md`](../../../../harness/conventions.md) als
*„adoptierte Harness-Mechanik"*.

**Vorgelagert — offene Beobachtungen sichten:** wie beim Geber-Slice zu
wiederholen, vor Arbeitsbeginn (gemergter Stand).

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
