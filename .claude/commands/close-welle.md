# Welle schließen (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Planner**-Rolle für die **Wellen-Closure** (Modul 6). Eine Welle schließt
**nicht** durch einen einzelnen Slice-Übergang, sondern durch einen geordneten Ablauf, der alle ihre
Slices bündelt — **fünf Schritte, jeder hinterlässt einen Beleg, keiner ein Datum.** Erst wenn alle
fünf Belege vorliegen, ist die Welle *auditierbar* geschlossen.

Die Welle-Plan-Datei bleibt dabei **flach in `planning/`** (`Status:` → `done`) — sie wandert **nie**
nach `done/` wie ein Slice; die Lifecycle-Ordner sind slice-reserviert. Die Closure erzeugt stattdessen
eine *separate* Results-Notiz.

Kanonische Quellen (vendored Regelwerk, `.harness/baseline/<tag>/regelwerk/`): Modul 6 (Roadmap /
Wellen-Closure), Modul 7 (Carveouts), Modul 5 (Lifecycle). Bei Konflikt gilt der Kurs.

## Repo-lokale Adaptionen (harness/conventions.md — MR-Block)

- **Docker-only + Gate-Nachweis/Stop-Hook.** Nur `make`-Targets; `make gates` endet mit
  `record-gates`. Jede Inhaltsänderung nach einem Gate-Lauf (inkl. Commit) macht den Stempel ungültig →
  nach dem Wave-Self-Close-Commit `make gates` grün bestätigen.
- **Strenges Doc-Gate.** `LH-`/`ADR-`/`MR-`-Kennungen in gescannten `.md` als klickbare Anker-Links —
  die Results-Notiz und die Roadmap werden gescannt.
- **Neue Artefakte per `cp`** — für die Results-Notiz existiert **kein** Template im Baum; sie wird frei
  nach der Modul-6-Struktur geschrieben (die Welle-Datei ist die Quelle der Plan-Struktur). Existiert
  je ein `welle-results`-Template, dann per `cp` daraus.
- **Commit via Message-Datei** (`git commit -F <datei>`).

## Vorbedingung: Kontext lesen

1. `CLAUDE.md`, `harness/README.md`, `AGENTS.md`, `harness/conventions.md`, **Modul 6** on-demand und
   die Welle-Plan-Datei (`docs/plan/planning/<welle-id>.md`, v. a. §3 Closure-Kriterien) lesen.

## Die fünf Schritte (Modul 6 — jeder mit Beleg, keiner mit Datum)

2. **Schritt 1 — Trigger prüfen.** Alle Slices der Welle liegen in `done/`; `make gates` grün; die
   welle-spezifischen Closure-Kriterien aus der Welle-Datei §3 sind erfüllt (z. B. ein benannter Smoke).
   Das ist die **beobachtbare** Bedingung, nicht der Kalendertag. Fehlt ein Beleg (ein Slice nicht
   `done`, ein Gate rot), **schließt die Welle nicht** — kein halbfertiges `done/`. Erzeuge die Belege
   **real** (Gate-Ausgabe, Smoke-Lauf), behaupte sie nicht.
3. **Schritt 2 — Carveout-Audit** (Modul 7). Jeden offenen Carveout prüfen: aufgelöst · verlängert
   (mit Folge-Slice) · permanent akzeptiert. Die Welle darf *mit* dokumentiertem Carveout schließen —
   **nie** mit einem stillen roten Gate. Keine Carveouts → eine belegte „0 offen"-Feststellung, kein
   Auslassen.
4. **Schritt 3 — Closure-Notiz `done/<welle-id>-results.md` schreiben.** Hält fest, *was gelernt
   wurde*: geliefert · was funktionierte · was anders lief · **Steering-Loop-Einträge** (geschärfte
   Regel / neuer Sensor / benannte Spec-Lücke) · Folge-Slices · Verifikation (die Belege aus Schritt 1).
   **Ohne Lerneintrag ist die Welle nicht „fertig", nur „weg".**
5. **Schritt 4 — Wave-Self-Close-Commit.** Ein **einzelner, beobachtbarer** Commit markiert den
   Abschluss. Sein Inhalt: die Results-Notiz + die Welle-Datei (`Status:` → `done`, §7 mit Verweis auf
   die Results-Notiz) + die Roadmap-Fortschreibung (Schritt 5). **Kein `git mv`** — die Welle-Datei
   bleibt flach in `planning/`. Commit via `-F`.
6. **Schritt 5 — Roadmap fortschreiben** (`in-progress/roadmap.md`, im selben Commit): die Welle aus
   *Aktuelle Welle* in *Abgeschlossene Wellen* (mit Zeiger auf die Results-Notiz); die erste Zeile aus
   *Nächste Wellen* wird die neue *Aktuelle Welle*; den zugehörigen Meilenstein auf *erreicht* setzen,
   falls die Welle ihn erfüllt; löste ein Trigger eine Umplanung aus, bekommt *Historische
   Trigger-Verschiebungen* ihren Eintrag.

## Abschluss

7. `make gates` grün nach dem Commit bestätigen (der Stop-Hook-Stempel muss auf den aktuellen Tree
   passen). Erst wenn **alle fünf Belege** vorliegen — Trigger · Carveout-Audit · Results-Notiz ·
   Self-Close-Commit · fortgeschriebene Roadmap — ist die Welle auditierbar geschlossen.

**Merke (Modul 6):** Datum ist *Output*, nie *Trigger*. Wer die Welle am Kalendertag schließt, kappt
halbfertige Slices und produziert genau die Auditierbarkeits-Lücke, die der Harness verhindert.

Gates nicht überspringen. Keine Erfolgsmeldung ohne Command-Ausgabe.
