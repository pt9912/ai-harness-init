# Slice slice-macos-als-host-plattform-wird-entschieden-und-vollzogen: macOS als Host-Plattform wird entschieden und vollzogen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** ohne Welle

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Host braucht nur `git`, `docker`, GNU `make`), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit), `AGENTS.md` §3.9.

**Berührte Spec-Stellen:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); der Anspruch an die Host-Plattform ist dort nicht ausdrücklich — Spec-Lücke, falls die Entscheidung *getragen* lautet.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-20.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Auftraggeber-Entscheidung, ob macOS eine getragene Host-Plattform ist, ist gefallen und vollzogen — im Code (A) oder in der Doku (B).

**Option A — die Läufer laufen auf macOS.** `mutate.sh` ohne Bash-4-Bruch, `mutate-auswahl.sh` ohne operandloses `paste`, die Fall-Skripte ohne GNU-`sed -i`, der Treiber wählt auf Darwin selbst `artifact-host`; dazu ein Wächter, der es hält. Vorteil: die Klasse verschwindet, lokale Closure-Belege ohne CI-Umweg (~50 Minuten). Nachteil: 762 Fall-Skripte und mehrere Läufer anfassen, ohne Mac-CI bleibt die Zusage ungewacht; jede neue GNU-Annahme bricht sie wieder.

**Option B — macOS ist ausdrücklich nicht getragen.** `harness/README.md` und `harness/sensors/mutate.md` nennen Linux als Host der Läufer und CI als Beleg-Ort; die Plattform-Aussage steht an einem Zielort (Hard Rule oder Spec-Stelle, Architect). Vorteil: klein, ehrlich, kein Code. Nachteil: der Dev-Host des Auftraggebers bleibt für die Läufer unbrauchbar, jeder Mutations-Beleg läuft über CI.

**Ausdrücklich NICHT in diesem Slice:**

- Die Norm-Änderung in `AGENTS.md` oder `harness/conventions*` — sie schreibt der Architect in eigenem Commit (`AGENTS.md` §3.8); dieser Slice liefert höchstens das Übergabe-Artefakt.
- Mount-Verzögerung und Host-Konfiguration (`BEO-ALL/bind-mount-sicht-auf-umgeschriebene-dateien-ist-unter-macos-verzoegert`, `BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus`) — anderer Mechanismus, eigener Eintrag.

## 2. Definition of Done

- [ ] Die Entscheidung (A oder B) des Auftraggebers steht als Zeile in §7.
- [ ] A: die vier Einzel-Befunde sind behoben und ein Wächter hält sie; B: die Plattform-Aussage steht an ihrem Zielort und in beiden Doku-Stellen.
- [ ] `make gates` grün.
- [ ] Review und Verifikation durchgeführt; Closure-Notiz mit Steering-Loop-Lerneintrag; Beobachtungs-Register fortgeschrieben (`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` auf *verkörpert*); die drei Paarungen getragen.

## 3. Plan (vor Code)

Wird nach der Entscheidung vom Implementer erweitert; die Dateiliste folgt der Option.

## 4. Trigger

**Start** (`next` → `in-progress`): die Auftraggeber-Entscheidung liegt vor.

- `in-progress` → `next`: Option A erweist sich als mehr als ein Review-Sitzungs-Umfang — dann in einen Slice je Läufer schneiden.
- `in-progress` → `open`: die Entscheidung wird zurückgenommen.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz mit Lerneintrag geschrieben, Register-Ausgang auf *verkörpert* mit Zielort.

## 6. Risiken und offene Punkte

- Option A bleibt ohne macOS-Lauf in CI ungewacht — **Ausgang:** weiter offen: → `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` im Register

## 7. Closure-Notiz

Noch nicht geschlossen.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), eine Sub-Area, GF.

**Vorgelagert — offene Beobachtungen sichten:** Treffer `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` (7 Vorgänge, über der Schwelle, Ausgang *geplant* auf diesen Slice) und die vier Einzel-Einträge.

Alle berührten Sub-Areas GF.
