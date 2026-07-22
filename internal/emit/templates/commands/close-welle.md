# Welle schließen (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Planner**-Rolle für die **Wellen-Closure** (Modul 6). Eine Welle schließt
**nicht** durch einen einzelnen Slice-Übergang, sondern durch einen geordneten Ablauf, der alle ihre
Slices bündelt — **fünf Schritte, jeder hinterlässt einen Beleg, keiner ein Datum.** Erst wenn alle
fünf Belege vorliegen, ist die Welle *auditierbar* geschlossen.

Seit Regelwerk v3.5.0 **wandert die Welle-Plan-Datei bei Closure per `git mv` nach `done/`** (neben
ihre Results-Notiz) — der Zustand ist die **Verzeichnis-Position, kein `Status:`-Feld** (wie beim
Slice). Die Closure erzeugt **zusätzlich** eine *separate* Results-Notiz (`done/<welle-id>-results.md`).

Kanonische Quellen (vendored Regelwerk, `.harness/baseline/<tag>/regelwerk/`): Modul 6 (Roadmap /
Wellen-Closure), Modul 7 (Carveouts), Modul 5 (Lifecycle). Bei Konflikt gilt der Kurs.

## Repo-lokale Adaptionen, die du beachten MUSST (ANPASSEN an dein Repo)

<!-- ANPASSEN: die Adaptionen DEINES Repos gegenüber der Baseline (dein
     `harness/conventions.md`, „MR-Block"). Die closure-relevanten aus der
     emittierten Schicht stehen unten; ergänze/streiche nach deinem Repo. -->

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

1. `CLAUDE.md` (falls vorhanden), `harness/README.md`, `AGENTS.md`, `harness/conventions.md`,
   **Modul 6** on-demand und die Welle-Plan-Datei (`docs/plan/planning/<welle-id>.md`, v. a. §3
   Closure-Kriterien) lesen.

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
   **Ohne Lerneintrag ist die Welle nicht „fertig", nur „weg".** **Zugleich (v3.5.0): die Welle-Plan-Datei
   gehört per `git mv` nach `done/`** — wegen der repo-lokalen Hard Rule 3.3 (Move ≠ Inhalt) als **eigener
   reiner Move-Commit** (s. Schritt 4). Der Move bricht die Inbound-Links (Roadmap + die Welle-Verweise
   der Slices) **und** die eigenen `../`-Links der Datei (jetzt eine Ebene tiefer) → im selben Zug
   reconcilen, bis `docs-check` grün ist.
5. **Schritt 4 — Wave-Self-Close-Commit + Move.** Der **Self-Close-Commit** (Inhalt) trägt: die
   Results-Notiz + die Welle-Datei §7 (Verweis auf die Results-Notiz; **kein `Status:`-Feld** — der
   Zustand ist die Position) + die Roadmap-Fortschreibung (Schritt 5). **Danach** der reine
   **`git mv`-Commit** der Welle-Plan-Datei nach `done/` und der **Link-Reconciliation-Commit** (Schritt 3):
   Hard Rule 3.3 trennt Move und Inhalt, daher mehrere Commits statt des einen Baseline-Self-Close-Commits
   — die Bewegung bleibt beobachtbar (ein zusammenhängender Zug). Commits via `-F`.
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
