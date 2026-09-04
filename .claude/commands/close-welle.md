# Welle schließen (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Planner**-Rolle für die **Wellen-Closure** (Modul 6). Eine Welle schließt
**nicht** durch einen einzelnen Slice-Übergang, sondern durch einen geordneten Ablauf, der alle ihre
Slices bündelt — **sechs Schritte, jeder hinterlässt einen Beleg, keiner ein Datum.** Erst wenn alle
sechs Belege vorliegen, ist die Welle *auditierbar* geschlossen.

Seit Regelwerk v3.5.0 **wandert die Welle-Plan-Datei bei Closure per `git mv` nach `done/`** (neben
ihre Results-Notiz) — der Zustand ist die **Verzeichnis-Position, kein `Status:`-Feld** (wie beim
Slice). Die Closure erzeugt **zusätzlich** eine *separate* Results-Notiz (`done/<welle-id>-results.md`).

Kanonische Quellen (vendored Regelwerk, `.harness/baseline/<tag>/regelwerk/`): Modul 6 (Roadmap /
Wellen-Closure), Modul 7 (Carveouts), Modul 5 (Lifecycle). Bei Konflikt gilt der Kurs.

## Repo-lokale Adaptionen (harness/conventions.md — MR-Block)

- **Docker-only + Gate-Nachweis/Stop-Hook.** Nur `make`-Targets; `make gates` endet mit
  `record-gates`. Jede Inhaltsänderung nach einem Gate-Lauf (inkl. Commit) macht den Stempel ungültig →
  nach dem Wave-Self-Close-Commit `make gates` grün bestätigen.
- **Strenges Doc-Gate.** `LH-`/`ADR-`/`MR-`-Kennungen in gescannten `.md` als klickbare Anker-Links —
  die Results-Notiz und die Roadmap werden gescannt.
- **Neue Artefakte per `cp`** — die Results-Notiz entsteht seit slice-083 per `cp` aus dem vendored
  `.harness/baseline/v5.18.0/templates/docs/plan/planning/welle-results.template.md` und wird danach
  ausgefüllt; die Welle-Datei bleibt Quelle der Plan-Struktur für alles, was das Template offenlässt.
- **Commit via Message-Datei** (`git commit -F <datei>`).

## Vorbedingung: Kontext lesen

1. `CLAUDE.md`, `harness/README.md`, `AGENTS.md`, `harness/conventions.md`, **Modul 6** on-demand und
   die Welle-Plan-Datei (`docs/plan/planning/<welle-id>.md`, v. a. §3 Closure-Kriterien) lesen.

## Die sechs Schritte (Modul 6 — jeder mit Beleg, keiner mit Datum)

2. **Schritt 1 — Trigger prüfen.** Alle Slices der Welle liegen in `done/`; `make gates` grün; die
   welle-spezifischen Closure-Kriterien aus der Welle-Datei §3 sind erfüllt (z. B. ein benannter Smoke).
   Das ist die **beobachtbare** Bedingung, nicht der Kalendertag. Fehlt ein Beleg (ein Slice nicht
   `done`, ein Gate rot), **schließt die Welle nicht** — kein halbfertiges `done/`. Erzeuge die Belege
   **real** (Gate-Ausgabe, Smoke-Lauf), behaupte sie nicht.
3. **Schritt 2 — Carveout-Audit** (Modul 7). Jeden offenen Carveout prüfen: aufgelöst · verlängert
   (mit Folge-Slice) · permanent akzeptiert. Die Welle darf *mit* dokumentiertem Carveout schließen —
   **nie** mit einem stillen roten Gate. Keine Carveouts → eine belegte „0 offen"-Feststellung, kein
   Auslassen.
4. **Schritt 3 — Closure-Notiz `done/<welle-id>-results.md` schreiben** — per `cp` aus
   `.harness/baseline/v5.18.0/templates/docs/plan/planning/welle-results.template.md`, dann
   ausgefüllt. Hält fest, *was gelernt wurde*: geliefert · was funktionierte · was anders lief ·
   **Steering-Loop-Einträge** (geschärfte Regel / neuer Sensor / benannte Spec-Lücke) · Folge-Slices ·
   Verifikation (die Belege aus Schritt 1). **Ohne Lerneintrag ist die Welle nicht „fertig", nur
   „weg".** **Zugleich (v3.5.0): die Welle-Plan-Datei gehört per `git mv` nach `done/`** — wegen der
   repo-lokalen Hard Rule 3.3 (Move ≠ Inhalt) als **eigener reiner Move-Commit** (s. Schritt 5). Der
   Move bricht die Inbound-Links (Roadmap + die Welle-Verweise der Slices) **und** die eigenen
   `../`-Links der Datei (jetzt eine Ebene tiefer) → im selben Zug reconcilen, bis `docs-check` grün
   ist.
   **Der Lese-Schritt des Beobachtungs-Registers gehört hierher** (`docs/plan/planning/observations.md`,
   Modul 6): jede Zeile mit Zähler **≥ 3** wandert in die Steering-Loop-Einträge und wird zur
   **verkörperten Regel** mit Herkunfts-Anker (`seit welle-<NN>`). Die Zeile bleibt danach **im
   Register stehen**, mit Vermerk; still löschen macht sie ununterscheidbar von einer, die es nie
   gab — gestrichen wird nur in die Sektion *Gestrichene Einträge*, mit der Begründung, warum die
   Beobachtung nicht mehr auftreten kann. **Erreicht keine Zeile 3×**, ist *„keine Zeile über der
   Schwelle"* die Feststellung, die in die Results-Notiz gehört; bei leerer Tabelle lautet sie
   *„das Register trägt `— keine —`"*. Auslassen ist in beiden Fällen keine Antwort. Was **unter**
   3× steht, liest diese Closure **nicht** — dafür ist §8 des nächsten Slice-Plans zuständig
   (`/plan-welle`); wer nur den Lese-Schritt kennt, sieht alles darunter nie wieder an.
5. **Schritt 4 — Zeitdokumente der Welle archivieren.** Ihre Slice-Dateien, ihr Plan und die
   Review-Reports dieser Slices wandern nach `done/<welle-id>/archiv.zip`; an der Stelle von Slice
   und Plan bleibt je ein gekürzter Stub, die **Ergebnisnotiz bleibt vollständig und flach**,
   Review-Reports bekommen keinen. Eingesammelt wird nach der Welle, nicht nach dem Verzeichnis:
   die Slices, deren `Welle:` diese Welle nennt, **und** die wellenlosen seit der letzten Closure;
   Slices einer noch offenen Welle bleiben liegen.
   **Der Träger ist `make archive-welle WELLE=<welle-id>`, und von Hand archiviert niemand:** die
   Vollständigkeit des Archivs bezeugt allein der Archivierungs-Commit. Das Ziel hängt an
   `host-bin` und fährt das Unterkommando des Produkt-Binärs
   ([ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 1). Es
   setzt die **zwei Commits** (erst der reine `git mv`, dann Archiv, Stubs und Verweis-Nachzug mit
   explizitem Staging — Hard Rule 3.3), packt das Zip aus der Go-Standardbibliothek, zieht die
   Verweise auf die bewegten Dateien in **drei** Formen nach (mit Verzeichnis-Präfix,
   geschwister-relativ, aufsteigend) und schreibt **beide Stub-Arten aus den vendored Vorlagen** —
   fehlt eine, bricht es ab, statt eine Form zu erfinden (Festlegung 3). Das macht die
   `cp`-Regel der Adaptionen oben hier gegenstandslos: die Vorlage wird nicht von Hand kopiert,
   sondern vom Träger gelesen. Was derselbe Lauf **täte**, ohne zu schreiben, sagt
   `.harness/state/bin/ai-harness-init archive-welle --vorschau <welle-id>` (ein eigenes
   `make`-Ziel hat der Vorschau-Zweig nicht). Das Target ist **kein Gate** — es archiviert, es
   prüft nicht; der Beleg ist `make docs-check` vor und nach demselben Lauf. Die vollständige
   Beschreibung mit allen Sperren steht in `harness/README.md` §Sensors (Feedback-Gates).
   **Jeder Ausgang ist fail-closed, und einer davon greift in diesem Repo beim ersten Lauf:**
   solange kein `docs/plan/planning/done/*/archiv.zip` existiert, hat *wellenlos seit der letzten
   Closure* keine beobachtbare Untergrenze — der Lauf bricht ab, statt den gesamten Altbestand
   mitzunehmen (`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l`; keine
   Erwartungswerte). Die Archivierung des **Altbestands** ist dann ein eigener Vorgang, und sie
   braucht eine Entscheidung, die heute keine Quelle dieses Repos trägt: welche Welle die
   wellenlosen Slices einsammelt, die keiner angehören (Baseline-Regelwerk `modul-06-roadmap.md`
   §Wellen-Closure-Prozedur, Schritt 4 — die chronologisch nächste geschlossene Welle oder ein
   einzelnes Sammel-Archiv). Bricht der Lauf an einer Sperre, gehört **das** als Feststellung in
   die Results-Notiz und die Welle schließt ohne Schritt 4. Wellen, die vor dieser Adoption
   schlossen, bleiben frei.
   **Zwei repo-lokale Kopplungen im Stub:** Die ID-Link-Pflicht gilt auch dort, `Hervorgegangen:`
   trägt seine Kennungen als Anker-Links. Und der Geltungsbereich der Sensoren trägt die Stub-Ebene:
   `.d-check.yml` scannt ab `.`, und die `matrix`-Klasse `slice` greift über `**` auch
   `done/<welle-id>/slice-*.md`.
6. **Schritt 5 — Wave-Self-Close-Commit + Move.** Der **Self-Close-Commit** (Inhalt) trägt: die
   Results-Notiz + die Welle-Datei §7 (Verweis auf die Results-Notiz; **kein `Status:`-Feld** — der
   Zustand ist die Position) + die Roadmap-Fortschreibung (Schritt 6). **Danach** der reine
   **`git mv`-Commit** der Welle-Plan-Datei nach `done/` und der **Link-Reconciliation-Commit** (Schritt 3):
   Hard Rule 3.3 trennt Move und Inhalt, daher mehrere Commits statt des einen Baseline-Self-Close-Commits
   — die Bewegung bleibt beobachtbar (ein zusammenhängender Zug). Commits via `-F`.
7. **Schritt 6 — Roadmap fortschreiben** (`in-progress/roadmap.md`, im selben Commit): die Welle aus
   *Aktuelle Welle* in *Abgeschlossene Wellen* (mit Zeiger auf die Results-Notiz); die erste Zeile aus
   *Nächste Wellen* wird die neue *Aktuelle Welle*; den zugehörigen Meilenstein auf *erreicht* setzen,
   falls die Welle ihn erfüllt; löste ein Trigger eine Umplanung aus, bekommt *Historische
   Trigger-Verschiebungen* ihren Eintrag.

## Abschluss

8. `make gates` grün nach dem Commit bestätigen (der Stop-Hook-Stempel muss auf den aktuellen Tree
   passen). Erst wenn **alle sechs Belege** vorliegen — Trigger · Carveout-Audit · Results-Notiz ·
   Archivierung (oder ihre nicht eingetretene Start-Bedingung) · Self-Close-Commit ·
   fortgeschriebene Roadmap — ist die Welle auditierbar geschlossen.

**Merke (Modul 6):** Datum ist *Output*, nie *Trigger*. Wer die Welle am Kalendertag schließt, kappt
halbfertige Slices und produziert genau die Auditierbarkeits-Lücke, die der Harness verhindert.

Gates nicht überspringen. Keine Erfolgsmeldung ohne Command-Ausgabe.
