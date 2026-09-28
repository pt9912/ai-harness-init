# Review-Report: slice-agent-watch-sh-wird-verankert — 2026-09-28

**Review-Art:** Code — gegen Plan
(`docs/plan/planning/in-progress/slice-agent-watch-sh-wird-verankert.md`) + Hard Rules.
**Nicht** gegen DoD/Spec (Verifier-Sache, Modul 11).

**Gegenstand:** Commit `81f749af` "Rolle Implementer: slice-agent-watch-sh-wird-verankert --
harness/tools/agent-watch.sh verankert: …". Betrachteter Diff: `27270397..81f749af`
(`.d-check.yml`, `Makefile`, `harness/README.md`, Slice-Plan §3-Nachtrag).
`harness/tools/agent-watch.sh` selbst wurde nicht verändert.

**Skill:** `.harness/skills/reviewer.md` v2.3.0 (2026-09-27) · **Modell:** claude-sonnet-5 ·
**Datum:** 2026-09-28.

**Eingangs-Kontext:**

- `docs/plan/planning/in-progress/slice-agent-watch-sh-wird-verankert.md` (§1 Ausschluss 3,
  §3 Plan-Tabelle inkl. Nachtrag, §6 Risiken)
- `AGENTS.md` §3.1, §3.6, §3.7, §3.8, §3.10
- Baseline-Regelwerk `modul-13-quality-gates.md` (Gate-Typ↔Fehlerbild, Hard Rule
  Doku-Disziplin, Werkzeug-Triade), `modul-05-planning-harness.md` (Lifecycle),
  `modul-08-agentenrollen.md` (Rollen-Trennung)
- `.d-check.yml` (Modul-Kommentar `targets`, Richtung 1 gate-undocumented / Richtung 2
  gate-phantom), `harness/README.md` §Sensors/§Werkzeuge, `harness/tools/agent-watch.sh`
  (Bestand, ungeändert), `harness/tools/hook-overhead.sh`, `harness/tools/slice-mv.sh`
  (Präzedenzfälle für Exit-Code-Verhalten bei "kein Gate"-Werkzeugen)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Commit-Message und Plan-§3-Nachtrag behaupten einen konkreten Rot-Mechanismus für den `.d-check.yml`-Eintrag: "exempt-targets-Eintrag in .d-check.yml (Gate-Phantom-Richtung sonst rot)" bzw. "ohne diesen Eintrag meldet `docs-check` das neue Makefile-Ziel als Gate-Phantom (Richtung 2)". Real nachgestellt (drei Kombinationen, `make docs-check` je frisch gefahren): (a) `.d-check.yml`-Eintrag entfernt, README-Zeile behalten → **grün**, 0 Befunde; (b) `.d-check.yml`-Eintrag UND README-Zeile entfernt → **rot**, aber mit `gate-undocumented` (Richtung 1), nicht `gate-phantom` (Richtung 2) — Meldung: `Makefile:444 agent-watch gate-undocumented Makefile-Regel "agent-watch" ohne Deklaration in der Autoritäts-Doku harness/README.md`; (c) `.d-check.yml`-Eintrag behalten, README-Zeile entfernt → ebenfalls **grün**. Der behauptete Rot-Beleg tritt unter der im Diff tatsächlich vorliegenden Bedingung ("ohne diesen [.d-check.yml-]Eintrag", README-Zeile bleibt Teil desselben Commits) nicht ein, und selbst der tatsächlich auslösbare Rot-Fall trägt die falsche Richtungs-Bezeichnung. `.d-check.yml`s eigener Modul-Kommentar bestätigt das: `exempt-targets` wird ausschließlich in der Beschreibung von Richtung 1 genannt, nicht in der von Richtung 2 (Richtung 2 prüft nur, ob das referenzierte Rezept im Makefile existiert — das ist hier trivial erfüllt, sobald das Ziel angelegt ist, unabhängig von exempt-targets). Der `.d-check.yml`-Eintrag selbst ist nicht schädlich und folgt dem Muster aller Gruppe-(a)-Einträge (doppelte Registrierung README + exempt-targets); der Befund betrifft die unbelegte, falsche Kausal-Zusage in einem unveränderlichen Commit-Text. | `AGENTS.md` §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel — und das Rot muss die *behauptete* Ursache tragen, nicht irgendeine) | Commit-Message `81f749af`; `docs/plan/planning/in-progress/slice-agent-watch-sh-wird-verankert.md:83` | ja — reale Wiederholung des Drei-Kombinationen-Tests mit `make docs-check` (dieser Report) | Rot-Beleg einer Zusage nennt die falsche Richtung/Bedingung, obwohl die reale Ursache eine andere ist |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Gate-vs-Werkzeug-Einordnung von `agent-watch.sh` (Plan §6 Risiko 2) | geprüft, ohne Befund — das Skript läuft als Endlosschleife (`while :; do … sleep; done`) und trifft mit dem einzigen `exit 1` (ABBRUCH-SCHWELLE) ein Urteil über den Host-Speicherzustand, nicht über einen Repo-Zustand; keine der Gate-Typ↔Fehlerbild-Klassen aus `modul-13-quality-gates.md` (Linter/Typecheck/Architekturtest/Security/Coverage/Replay/Integration/E2E) trifft zu. Ein Exit-Code ≠ 0 allein disqualifiziert ein Werkzeug nicht von der Werkzeug-Klasse — dieselbe Klasse (`hook-overhead.sh`, `slice-mv.sh`) exitet ebenfalls mit 1/2 bei Schwellen- bzw. Nutzungsfehlern und bleibt dennoch „kein Gate". Die Einordnung folgt etabliertem Präzedenzfall (Werkzeuge-Tabelle: `hook-overhead` misst eine Schwelle, meldet, kein Gate) statt eine neue Unterscheidung zu erfinden |
| Norm-Aussage über die Werkzeug-Landschaft / AGENTS.md §3.8 | geprüft, ohne Befund — die Verankerung wendet die bereits etablierte, im Repo mehrfach vorexerzierte Unterscheidung Gate/Werkzeug an (u. a. MR-047, bestehende Werkzeuge-Tabelle), ohne eine neue Norm zu setzen; die im Plan §1 Ausschluss 3 selbst antizipierte Bedingung ("trägt sich die Verankerung ohne eine solche Aussage … entfällt der Punkt ganz") ist erfüllt, kein MR-Eintrag fällig, kein Architect-Übergabepunkt ausgelassen |
| `.d-check.yml` exempt-targets-Eintrag: Gruppen-Zuordnung und Reihenfolge | geprüft, ohne Befund — Eintrag korrekt in Gruppe (a) (Nicht-Gate-Verifies, zusätzlich in `harness/README.md` genannt), Position in Kommentar-Aufzählung UND YAML-Liste konsistent zwischen `hook-overhead` und `slice-mv` eingefügt, deckungsgleich mit der Reihenfolge in `harness/README.md`s Werkzeuge-Tabelle (siehe F-1 für den unabhängigen Befund zur Begründung dieses Eintrags) |
| AGENTS.md §3.10 (Planner-Closure) | geprüft, ohne Befund — kein DoD-Häkchen gesetzt, §6-Risiko-Ausgänge weiterhin `<Ausgang zu setzen>`, §7-Closure-Notiz weiterhin Platzhalter; die Commit-Message benennt das ausdrücklich ("DoD-Häkchen bewusst nicht gesetzt, Planner-Closure-Sache"); DoD-Liefer-Punkt (1) selbst ist inhaltlich erfüllt (Makefile-Ziel + README-Zeile + `.d-check.yml`-Registrierung vorhanden), nur das Abhaken bleibt zu Recht aus |
| `shell-lint`-Abdeckung von `harness/tools/agent-watch.sh` | geprüft, ohne Befund — Rezept (`Makefile:207-209`) läuft gegen den Glob `harness/tools/*.sh`, `agent-watch.sh` liegt darunter, keine Änderung am Rezept nötig, Implementer-Behauptung bestätigt |
| `comment-claims`-Abdeckung von `harness/tools/agent-watch.sh` | geprüft, ohne Befund — Rezept (`Makefile:214-215`) sammelt `git ls-files 'harness/tools/*.sh' …`, `agent-watch.sh` liegt darunter, keine Änderung am Rezept nötig, Implementer-Behauptung bestätigt |
| AGENTS.md §3.7, Kommentar-Klassen (Makefile-Zielkommentar, `.d-check.yml`-Listen-Ergänzung) | geprüft, ohne Befund — der neue Makefile-Kommentar beschreibt im Indikativ, was das Ziel *ist* und *nicht kann* (Kopplung/Abgrenzung: "läuft als Dauerschleife …", "kann nichts abbrechen", "Grenze … stehen im Skriptkopf" als Rang-Zeiger); keine Befund-IDs, keine Prozess-Chronik, kein abgebrochener Satz. Die `.d-check.yml`-Änderung ist eine reine Namens-Ergänzung in einer bestehenden, bereits regelkonformen Aufzählungs-Prosa |
| DoD-Beleg-Kommando (`grep -rl 'agent-watch' Makefile test/ harness/README.md \| wc -l`) | geprüft, ohne Befund — real ausgeführt, Ergebnis **2** (Makefile, harness/README.md), deckt genau das, was das Kommando selbst zusagt (Existenz der Nennung an den zwei Stellen); die Sub-Zusagen "von shell-lint/comment-claims erfasst" sind separat über die Glob-Lektüre bestätigt (zwei Zeilen oben), nicht durch dieses Kommando — Plan formuliert das auch nicht anders |
| Variablennamen `WARN`/`ABBRUCH`/`INTERVALL` im neuen Makefile-Ziel | kein Konventions-Anker im Repo, der englische Namen verlangt — der Bestand ist bereits gemischt (`TRAEGER_TAG`, `TRAEGER_SHA256_*`, `TRAEGER_CARRIER` sind deutsch). Damit "Kein Stil-Polizist"-Klausel des Skills einschlägig: keine Finding-würdige Konventionsverletzung. **Ein echter, engerer Befund liegt aber daneben** und wird unten als eigenständige LOW geführt (Namens-Mismatch zum Skript selbst, nicht Deutsch-vs-Englisch) |

## Zusätzlicher Fund (Eskalation aus Prüfpunkt 6)

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-2 | LOW | Das Makefile-Ziel benennt seine zweiten und dritten Positionsargumente `ABBRUCH`/`INTERVALL` (deutsch), während `harness/tools/agent-watch.sh` dieselben Werte intern als `ABORT`/`INTERVAL` (englisch) führt — Kopfkommentar-Aufruf-Zeile `agent-watch.sh [warn-GB] [abbruch-GB] [intervall-s]` mischt beide Schreibweisen sogar innerhalb des Skripts selbst (`abbruch-GB` vs. Variable `ABORT`). Wer vom Makefile-Aufruf zum Skript wechselt (oder umgekehrt), muss `ABBRUCH`↔`ABORT` und `INTERVALL`↔`INTERVAL` gedanklich mappen — eine über die reine Deutsch/Englisch-Stilfrage hinausgehende, vermeidbare Vokabular-Lücke an einer dokumentierten Schnittstelle. Nicht vom Diff verursacht (Skript selbst unverändert), aber vom Diff in eine öffentlich sichtbare Tabellenzeile (`harness/README.md`) übernommen, ohne die Diskrepanz zu glätten. | Maintainability | `Makefile:443`, `harness/tools/agent-watch.sh:29,32-34`, `harness/README.md` (neue Zeile) | ja — Lesevergleich der drei Stellen | Positionsargument-Namen zwischen Aufrufer (Makefile/README) und Skript uneinheitlich (DE/EN gemischt) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** Rot-Beleg einer Zusage nennt die falsche Richtung/Bedingung,
obwohl die reale Ursache eine andere ist · Positionsargument-Namen zwischen Aufrufer und Skript
uneinheitlich (DE/EN gemischt)

## Verdikt

**Merge-blockierend:** ja, wegen F-1. Kein Rollen-Widerspruch — der Implementer widerspricht
keiner anderen Rolle, der Modul-8-Konflikt-Pfad ist nicht einschlägig: F-1 ist eine unbelegte
technische Zusage im eigenen Lauf, keine Meinungsverschiedenheit zwischen Rollen-Verdikten.
Betroffen ist ausschließlich der Begründungstext (Commit-Message und Plan-§3-Zeile); der
tatsächliche `.d-check.yml`-Eintrag selbst muss nicht zurückgenommen werden — er ist harmlos und
folgt dem etablierten Muster aller Gruppe-(a)-Werkzeuge. Korrektur gehört in einen
Folge-Commit: die falsche Kausal-Behauptung im Plan-§3-Nachtrag berichtigen (welche Richtung
tatsächlich greift, und nur unter welcher — vollständigeren — Bedingung); die Commit-Message
selbst ist unveränderlich (kein `git commit --amend` auf bereits gepushte Historie ohne
Prüfung, wessen Commit betroffen ist), die Korrektur der historischen Aussage läuft über die
Plan-Datei und ggf. eine erläuternde Zeile in der Closure-Notiz (§7), nicht über eine
nachträgliche Fälschung der Commit-Historie.

**Übergabe:** F-1 geht an den Implementer (Rückkante) zur Korrektur der Begründung in
Plan/Closure; F-2 ist nice-to-fix, kein Blocker. Beide Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Zähler des Beobachtungs-Registers. Dieser Report ist
Lauf-Beleg und wird über Läufe hinweg nicht erneut gelesen. Ersetzt keine Verifikation — DoD-/
Spec-Konformität prüft der Verifier separat (Modul 11).

## Nachtrag — Korrektur-Prüfung (2026-09-28, Commit `5169e773`)

Prüfung, ob die Korrektur F-1/F-2 trägt, ohne neuen Report (kurze Nachrunde, keine neue
Diff-Fläche außer den drei geänderten Dateien).

**F-1 — geprüft, trägt.** Die Plan-§3-Zeile
(`docs/plan/planning/in-progress/slice-agent-watch-sh-wird-verankert.md`) nennt jetzt die real
gemessene Ursache: Richtung 2 (`gate-phantom`) prüft nur die Rezept-Existenz im Makefile und ist
davon unabhängig trivial erfüllt; Richtung 1 (`gate-undocumented`) verlangt authority-Zeile ODER
`exempt-targets`-Eintrag, und die im selben Commit hinzugefügte README-Zeile erfüllt das bereits
allein — der `.d-check.yml`-Eintrag ist redundant, aber nicht schädlich (Gruppe-(a)-Muster). Das
deckt sich mit dem Modul-Kommentar in `.d-check.yml:135-147` selbst ("in der authority-Datei oder
in exempt-targets — eine dritte Antwort gibt es nicht") und mit den drei Kombinationen, die dieser
Report bereits real gefahren hat — keine neue Messung nötig, Textkonsistenz bestätigt. Die
Commit-Message `81f749af` bleibt wie vom Report empfohlen unangetastet; die Korrektur läuft
ausschließlich über die Plan-Datei, referenziert diesen Report per Pfad und benennt die alte
Aussage als falsch statt sie stillschweigend zu ersetzen.

**F-2 — geprüft, trägt.** `git show 5169e773` bestätigt die Angleichung an allen drei Stellen:
Makefile-Zielkommentar und -Aufruf (`$(ABBRUCH)`→`$(ABORT)`, `$(INTERVALL)`→`$(INTERVAL)`) sowie
die `harness/README.md`-Tabellenzeile. `harness/tools/agent-watch.sh` bleibt unverändert, wie
zugesagt — die interne Kopfkommentar-Mischform (`abbruch-GB` vs. `ABORT`) des Skripts selbst war
nicht Gegenstand des Findings und liegt weiterhin außerhalb des Slice-Scopes (Plan §1
Ausschluss 2 schließt Schwellenwert-Änderungen am Skript aus).

**Scope-Check.** Diff umfasst genau drei Dateien mit minimalen, punktgenauen Änderungen (4/4
Zeilen: 1 Plan-Zeile, 2×1 Zeile Makefile, 1 Zeile README). Kein neuer Abschnitt, keine
Wiedereröffnung des `.d-check.yml`-Eintrags selbst (zu Recht — er war nie der Gegenstand des
Befunds), keine neuen Findings sichtbar. `make gates` laut Commit-Beleg EXIT 0.

**Aktualisiertes Verdikt: Merge-blockierend — nein.** F-1 ist durch reale Messung gedeckt
korrigiert, F-2 vollzogen. Kein Rollen-Widerspruch, kein offener Punkt aus diesem Review.
