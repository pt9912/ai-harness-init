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

- [ ] Hilfezeilen und Kommentare von `artifact-host`, `smoke-host` und `full-smoke-host` im `Makefile` (Fundstellen §1) zeigen auf `AGENTS.md` §3.9 und nennen keinen Nicht-Linux-Host als vorgesehenen Einsatz; die Zusage nennt, was kein Sensor hält (nach `AGENTS.md` §3.6/§3.7).
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

Noch nicht geschlossen.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), eine Sub-Area, GF.

**Vorgelagert — offene Beobachtungen sichten:** Treffer `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` (7 Vorgänge, Schwelle erreicht; mit dem Vorgänger-Slice `slice-macos-als-host-plattform-wird-entschieden-und-vollzogen` verkörpert in `AGENTS.md` §3.9).

Alle berührten Sub-Areas GF.
