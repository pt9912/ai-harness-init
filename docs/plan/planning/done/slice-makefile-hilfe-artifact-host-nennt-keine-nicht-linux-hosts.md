# Slice slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts: Die Makefile-Hilfe von `artifact-host` nennt keine Nicht-Linux-Hosts als Einsatz

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** ohne Welle

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), `AGENTS.md` §3.9 (Host der Host-Läufer ist Linux, macOS nicht getragen).

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-20.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Texte im `Makefile`, die `artifact-host`, `smoke-host` und `full-smoke-host` als Mittel für Nicht-Linux-Hosts anbieten, stehen nicht mehr in Spannung zur Norm in `AGENTS.md` §3.9: sie nennen den Umweg als Hilfe ohne Anspruch, wie `harness/sensors/artifact-host.md`. Der Zielname im Dateinamen nennt nur `artifact-host`; der Auftraggeber hat `full-smoke-host` (und mit ihm `smoke-host`) in diesen Slice genommen. Fundstellen (`git grep -nE 'Nicht-Linux|Devhost|macOS|Windows' -- Makefile`), nur Text:

- Z. 154–158, Kommentar über `artifact`: „auf macOS/Windows nicht … smoke/full-smoke sind dort nicht als grün zugesagt … Für einen lokal LAUFFAEHIGEN Smoke auf so einem Host: `artifact-host` + `smoke-host`/`full-smoke-host`".
- Z. 163–166, Kommentar über `artifact-host`: „(macOS, Windows, ein abweichendes CPU-Arch)".
- Z. 167, `## `-Hilfetext `artifact-host`: „für lokale Smokes auf Nicht-Linux-Hosts".
- Z. 220–223, Kommentar über `smoke-host`: „Host, dessen Kernel/Architektur … abweicht (macOS, Windows, abweichendes CPU-Arch)".
- Z. 224, `## `-Hilfetext `smoke-host`: „für Nicht-Linux-Devhosts".
- Z. 235, `## `-Hilfetext `full-smoke-host`: „für Nicht-Linux-Devhosts".
- Z. 493 (Kommentar „macOS-Host … `make gates` rot"): beschreibt `host-bin`, kein Angebot der drei Targets — Bestand, nicht Gegenstand.

Die Texte zeigen auf `AGENTS.md` §3.9 und schreiben die Norm nicht ab. Kein Test und kein Doku-Sensor hält den Wortlaut der `## `-Zeilen: `git grep` nach altem Wortlaut in `test/` und `harness/` findet nur Prosa in `harness/sensors/mutate.md` (Zeile 123, nicht die Hilfe); `harness/README.md` führt die Targets mit eigener Beschreibung, das `targets`-Modul prüft Existenz, nicht Hilfetext.

**Ausdrücklich NICHT in diesem Slice:**

- Änderung des Rezepts, des Zielnamens oder des Verhaltens von `artifact-host` und `full-smoke-host` — nur Text; ein anderer Vorgang.
- Die Norm selbst: `AGENTS.md` §3.9 schreibt der Architect; die Makefile-Texte zeigen darauf.
- Der Kommentar bei Z. 493 (`host-bin`): Bestand, beschreibt kein Angebot der drei Targets.
- Reparatur der Läufer auf macOS — verworfen mit der Entscheidung, die `AGENTS.md` §3.9 trägt.

## 2. Definition of Done

- [x] Hilfezeilen und Kommentare von `artifact-host`, `smoke-host` und `full-smoke-host` im `Makefile` (Fundstellen §1) zeigen auf `AGENTS.md` §3.9 und nennen keinen Nicht-Linux-Host als vorgesehenen Einsatz; die Zusage nennt, was kein Sensor hält (nach `AGENTS.md` §3.6/§3.7).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` | update | die sechs Textstellen aus §1 (Kommentare und `## `-Hilfetexte von `artifact`, `artifact-host`, `smoke-host`, `full-smoke-host`): Umweg ohne Anspruch, Zeiger auf `AGENTS.md` §3.9 statt „für Nicht-Linux-Hosts"; kein Rezept, kein Zielname, keine Variable |

Die `## `-Zeile ist der Text, den `make help` ausgibt.

## 4. Trigger

**Start** (`next` → `in-progress`): priorisiert, `Verantwortlich:` gesetzt.

- `in-progress` → `next`: die Änderung verlangt mehr als Text (Rezept oder Zielname) — dann zurück zur Zerlegung.
- `in-progress` → `open`: die Norm in `AGENTS.md` §3.9 entfällt (macOS wird getragen) — dann ist der Gegenstand entfallen.

## 5. Closure-Trigger

DoD vollständig, Review und Verifikation durchgeführt, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Hilfezeile ist Text ohne Wächter: kein Sensor hält `make help` gegen die Norm — **Ausgang:** weiter offen: → `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` im Register

## 7. Closure-Notiz

- **Gegenstand geliefert:** sechs Textstellen im `Makefile` (Kommentare über `artifact`, `artifact-host`, `smoke-host`; `## `-Hilfetexte von `artifact-host`, `smoke-host`, `full-smoke-host`) nennen den Umweg als *Hilfe ohne Anspruch* mit Zeiger auf `AGENTS.md` §3.9, keinen Nicht-Linux-Host als Einsatz (Commit `a0944093`, nur `Makefile`, 13+/14-, nur Text). Review: 0 HIGH, 0 MEDIUM, 0 LOW, 2 INFO ([Report](../../../reviews/2026-10-20-slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts.md)). Verifier: alle inhaltlichen DoD-Punkte bestätigt; `make -n` für sieben Ziele byte-gleich zur Basis, `make help` ändert nur die drei Hilfezeilen, `AGENTS.md` ohne Diff ([Report](../../../reviews/2026-10-20-slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts-verify.md)). `make gates` lokal grün.
- **Mutations-Probe: nicht gemessen.** Die 21 von `make mutate-auswahl` gewählten Fälle (Auswahl nach `# files: Makefile`, nicht nach Zeile; Exit 10, Schwelle 8) wurden nicht gefahren: der Diff berührt keine Anker-Rezepte (am Diff gelesen, gestützt durch byte-gleiche `make -n`-Ausgaben der sieben Ziele). `make mutate-greift` → 762/762 belegt nur, dass die Patches ihre Datei ändern, nicht dass die Wächter rot werden. Kein Beleg behauptet.
- **CI-Beleg ([`AGENTS.md`](../../../../AGENTS.md) §3.9):** der Beleg-Ort ist die CI auf frischem Klon nach dem Push; es liegt hier **kein** CI-Lauf vor, und diese Notiz behauptet keinen. Den Lauf liest der Hauptkontext und liefert ihn nach.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** keine Laufzeit- oder Kosten-Aussage.
- **Steering-Loop-Eintrag:** **benannte Lücke** — die Hilfetexte sind Deklarationen ohne Sensor: kein Sensor hält den Wortlaut der `## `-Zeilen oder der Makefile-Kommentare gegen die Norm (`make help` wird von keinem Test gelesen, das `targets`-Modul prüft Existenz, nicht Hilfetext); ein rotes Gegenbeispiel gibt es nicht. Träger ist der Lauf, der die Zeile schreibt. Kein `liegt in`: es ist keine neue Regel verkörpert, die Norm steht seit dem Vorgänger in `AGENTS.md` §3.9.
- **Zu den zwei INFO des Reviews (benannt, nicht behoben):** (1) der Kommentar über `artifact` wiederholt den Halbsatz der Norm („der Host der Host-Laeufer ist Linux") neben dem Zeiger; bei Änderung von §3.9 ist der Zeiger maßgeblich. (2) „kein Sensor haelt diesen Text" steht bei `artifact-host` und `smoke-host`, nicht bei `full-smoke-host`; die Zusage ist für alle drei gleich wahr. Kein Folge-Slice: [`AGENTS.md`](../../../../AGENTS.md) §3.7 Cutoff — der Bestand ist kein Arbeitsauftrag, und kein Auftreten-Zähler trägt einen; wer die Zeilen ohnehin anfasst, zieht sie nach.
- **Trigger-Audit:** der Absatz in `AGENTS.md` §3.9 trägt den Auflösungs-Trigger *macOS wird getragen, sobald eine macOS-CI die Läufer hält oder der Auftraggeber es entscheidet* — **nicht eingetreten**. `CO-001` und `CO-002` unberührt; kein bootstrap-aware Gate, keine ADR mit Re-Evaluierungs-Trigger berührt; die übrigen Hard Rules unverändert. Nichts fällig.
- **Rückbau-Fundstellen:** entfällt der Absatz, findet `git grep -nE 'Host Linux, macOS nicht getragen|Hilfe ohne Anspruch' -- harness/ docs/ Makefile ':!docs/reviews'` auch die Makefile-Zeilen (`artifact`-Kommentar, `artifact-host`, `smoke-host`, `full-smoke-host`; heute dazu `harness/README.md`, `harness/sensors/artifact-host.md`, `mutate.md`, `full-smoke.md`). Das Kommando des Vorgängers führt `Makefile` nicht; er ist ein Zeitdokument und bleibt unverändert, das Makefile ist neu dazugekommen. Gemessen am Stand dieser Closure, kein Erwartungswert.
- **Beobachtungs-Register (`../observations/`):** `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` (*verkörpert*, 7 Vorgänge) bekommt **keinen** Beleg und keine Änderung: dieser Slice vollzieht die Norm (zieht Texte an sie nach), er ist kein weiteres Auftreten der Fehlerklasse. Keine weitere Beobachtung angefallen.
- **Risiken aus §6:** das eine Risiko (*Hilfezeile ohne Wächter*) bleibt **weiter offen** mit Zeiger auf `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`; der Ausgang trägt: das Verzeichnis existiert, ist *verkörpert* und nennt die Grenze (Deklaration ohne Sensor) in seiner `state.md`.
- **Folge-Slices:** keine.
- **Archivierung ([`MR-078`](../../../../harness/conventions.md#mr-078)):** `archive-welle` bricht voraussichtlich an `[untergrenze]` (`ls docs/plan/planning/done/*/archiv.zip` findet keines, kein Erwartungswert); der Slice bleibt flach in `done/`, nicht gelaufen.
- **Drei Paarungen:** noch nicht geprüft; folgt nach dem `git mv`.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), eine Sub-Area, GF.

**Vorgelagert — offene Beobachtungen sichten:** Treffer `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` (7 Vorgänge, Schwelle erreicht; mit dem Vorgänger-Slice `slice-macos-als-host-plattform-wird-entschieden-und-vollzogen` verkörpert in `AGENTS.md` §3.9).

Alle berührten Sub-Areas GF.
