# Slice slice-traeger-pins-werden-nach-der-publikation-gegen-die-sha256sums-gehalten: Ein Werkzeug hält alle sechs Träger-Pins nach der Publikation gegen die SHA256SUMS des Tags

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Pin ist die Quelle der Reproduzierbarkeit des Trägers),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die Zusage „Pin gegen Publikation gehalten" trägt einen Zahn an der realen Quelle),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) und [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (Pin und `SHA256SUMS` als Release-Asset).
Auslöser: Auftrag des Auftraggebers nach Verdikt V-1 ([`docs/reviews/2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt.md`](../../../reviews/2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt.md)).

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-20.

---

## 1. Ziel und Abgrenzung

**Ziel:** `make traeger-pins-check` holt die `SHA256SUMS` des Tags, paart je Plattform Dateiname und Digest und hält sie gegen alle sechs `TRAEGER_SHA256_*` des `Makefile` — heute hält `make traeger-fetch` nur die Plattform des Aufrufers, CI nur linux-amd64, die übrigen vier hält nichts (Verdikt V-1: vier Release-Schnitte in Folge fanden denselben Fund, die Prosa-Form ist ausgeschöpft).

**Ausgangslage (gemessen am Stand HEAD 0f5d67c0):** `Makefile` Zeilen 45–51 führen `TRAEGER_TAG` und sechs `TRAEGER_SHA256_*`; `docs/user/releasing.md` Schritt 2 sagt, `make traeger-fetch` belege „nach der Publikation" die Digests. Vor der Publikation existiert das Asset nicht; ein Vergleich vorher hielte den Pin gegen seine eigene Quelle.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kein Vergleich Bau gegen Bau — das Werkzeug hält Pin gegen Publikation und sagt nichts über den Bau selbst; die Menge der Assets gegen die Prüfsummen hält `release-sums.sh verify` in Schritt 3 der Prozedur, Reproduzierbarkeit des Baus ist ein anderer Gegenstand.
- Kein Gate, nicht in `make gates` — er braucht Netz und eine Release-Lage, die ein frischer Klon nicht garantiert; Werkzeug im Stil von `make tap-check`, Bindepunkt ist die Prozedur.
- Keine Zeile in `AGENTS.md` §3.6 — Hard Rules schreibt der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und eine Zeile über einen laufenden Sensor entsteht erst nach dem Lauf ([`AGENTS.md`](../../../../AGENTS.md) §3.1). Übergabe unten.
- Kein Warte-Schritt und kein Pin-Schreibweg — ein fehlendes Asset endet mit Klasse 2 (nicht ausführbar), nicht mit Warten; das Warten im Worker liegt bei `slice-mutate-branch-worker-wartet-die-publikation-ab`, den Pin zieht Schritt 2 der Prozedur von Hand.
- Kein Eingriff in `traeger-fetch` — er hält weiter die Plattform des Aufrufers; der neue Lauf ergänzt ihn, ersetzt ihn nicht.

**Hinweis für den Architect (Übergabe-Artefakt).** Nach dem Lauf des Sensors am echten `v0.10.0` verlangt die Klasse eine Zeile in [`AGENTS.md`](../../../../AGENTS.md) §3.6 (viertes Falsch/Richtig-Paar, Unterklasse *Pin des realen `Makefile` nach der Publikation*: Sensor `make traeger-pins-check`, Grenze *kein Bau-gegen-Bau*, Wächter-Lage). Sie entsteht in einem **eigenen Architect-Commit** nach der Closure dieses Slice; der Slice schreibt sie nicht.

## 2. Definition of Done

- [ ] **L1 — Werkzeug:** `make traeger-pins-check` (`TAG=<tag>`, Default `TRAEGER_TAG`) holt die `SHA256SUMS` über den Transport von `traeger-fetch` (gepinntes Bild, Netz an genau diesem Aufruf), paart je Plattform Dateiname und Digest und vergleicht gegen die sechs `TRAEGER_SHA256_*`. Exit des Skripts 0 gleich, 1 Unterschied (nennt die Plattform), 2 nicht ausführbar (auch: Asset nicht abrufbar, Zeile fehlt); über `make` endet jeder Fehlschlag mit 2, die Klasse des Skripts steht in der letzten stderr-Zeile `traeger-pins-check: Exit <N>` ([`AGENTS.md`](../../../../AGENTS.md) §3.6, letztes Paar — die Zusage ist an `make traeger-pins-check` gemessen).
- [ ] **L2 — Wächter über der Paarung:** `test/traeger-pins-check.bats` hält Paarung (Name gegen Digest, nicht Position) und die drei Exit-Klassen über einer Fixture-`SHA256SUMS`; `test/mutations/<nächste freie Nummer>-traeger-pins-paarung-nach-position.sh` paart nach Zeilenposition statt Name und färbt den Test rot; `make mutate-greift` grün, `MUTATE_CASES=<Nr>` einmal rot gesehen. Die Zusage nennt, was sie hält: die Paarungs-Logik, **nicht** den realen Pin — den hält L3.
- [ ] **L3 — Rot an der realen Quelle:** Lauf am echten Release `v0.10.0` unverfälscht Exit 0; in einem Probe-Klon eine **Nicht-Host-Plattform** des `Makefile` (nicht `darwin-arm64`) verfälscht, Lauf endet rot und nennt genau diese Plattform; beide Läufe samt Ausgabe in §7. Bindepunkt: `docs/user/releasing.md` nach Schritt 5 vor dem Bericht, Satz in Schritt 2 („belegt nach der Publikation `make traeger-fetch`") auf die Plattform des Aufrufers eingeschränkt, Zeile in der Werkzeuge-Tabelle von `harness/README.md` (`kein Gate`) und `harness/sensors/traeger-pins-check.md`. Der Rot-Beleg ist eine Handlung des Laufs, kein Sensor: kein Wächter hält den realen Lauf; Träger ist der Release-Schnitt, der die Prozedur fährt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/traeger-pins-check.sh` | neu | Holen, Paaren, Vergleichen; Transport und Bild-Pin wie `traeger-fetch.sh` gelesen, nicht zweimal geführt — L1 |
| `Makefile` | update | Ziel `traeger-pins-check` mit Kommentarblock (Exit-Aussage am `make`-Aufruf), Skript in die `shell-lint`-Liste — L1 |
| `test/traeger-pins-check.bats` | neu | Paarung, Exit 0/1/2, Plattformname in der Meldung — L2 |
| `test/mutations/<nächste freie Nummer>-traeger-pins-paarung-nach-position.sh` | neu | Paarung nach Position, Test wird rot — L2 |
| `docs/user/releasing.md`, `harness/README.md`, `harness/sensors/traeger-pins-check.md` | update / update / neu | Bindepunkt, Werkzeuge-Zeile, Vertrag und Grenze — L3 |

## 4. Trigger

**Start** (`next` → `in-progress`): keine Abhängigkeit; Reihenfolge nach Auftraggeber: nach `slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen`, vor `slice-mutate-branch-worker-wartet-die-publikation-ab`.

**Rückführungen:**

- `in-progress` → `next`: der Transport verlangt einen Eingriff in `traeger-fetch.sh` über das Lesen seines Pins hinaus (dritte Schicht oder mehr als drei Liefer-Punkte).
- `in-progress` → `open`: die Assets von `v0.10.0` sind nicht abrufbar — der Rot-Beleg an der realen Quelle (L3) ist dann unmöglich; Trigger für die Wiederaufnahme ist der nächste veröffentlichte Tag.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Review- und Verifier-Report liegen vor, Closure-Notiz mit Lerneintrag in Form eines neuen Sensors (Werkzeug); das Übergabe-Artefakt an den Architect (Zeile in `AGENTS.md` §3.6, §1) ist in §7 genannt.

## 6. Risiken und offene Punkte

- Der Rot-Beleg an `v0.10.0` hängt an Netz und an der Abrufbarkeit des Release — **Ausgang:** entfallen: Das Release ist der Pin-Gegenstand selbst (`TRAEGER_TAG`); wäre es nicht abrufbar, bräche `make traeger-fetch` und der Lauf wäre kein Slice mehr, sondern ein Rücksprung nach `open` (§4).
- Der Sensor deckt nur Pin gegen Publikation, nicht den Bau — **Ausgang:** entfallen: Die Grenze steht im Skriptkopf und im Sensor-Vertrag; Bau gegen Bau ist ausgeschlossen (§1), die Menge gegen die Prüfsummen hält Schritt 3 der Prozedur.
- Der Sensor läuft nur, wenn der Release-Schnitt ihn fährt (Werkzeug, kein Gate) — **Ausgang:** weiter offen → `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` im Register.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`, die einzige deklarierte Sub-Area der Beobachtungen); sie erfüllt die Schwelle.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen (`ls -d docs/plan/planning/observations/BEO-ALL/*/`, gelesen am Stand HEAD 0f5d67c0). Treffer: `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` (11 Belege, `verkörpert` — der Slice ist die benannte Unterklasse *Pin des realen `Makefile`*; sein Lauf-Zahn an der realen Quelle ist L3), `BEO-ALL/pin-digest-ohne-waechter` (8 Belege, `verkörpert`) und `BEO-ALL/aufruf-ohne-wirkung-am-pin-traegt-nur-eine-fixture` (1 Beleg, `offen` — berührt der Slice einen weiteren Pin-Aufruf mit nachgebauter Fixture, ist der Zähler bei 2; L2 benennt die Fixture-Grenze am Ort). Kein Eintrag erreicht mit diesem Slice 3× neu.

alle berührten Sub-Areas GF

