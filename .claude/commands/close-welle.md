# Welle schließen (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Planner**-Rolle für die **Wellen-Closure** (Modul 6): sechs Schritte, jeder
hinterlässt einen Beleg, keiner ein Datum; erst mit allen sechs ist die Welle auditierbar geschlossen.
Die Closure ist Planner-Arbeit im **eigenen Kontext**, nicht im Kontext, der die Arbeit gebaut hat
(`AGENTS.md` §3.10). Die Welle-Plan-Datei wandert per `git mv` nach `done/` (Zustand = Position, kein
`Status:`-Feld); daneben entsteht die Results-Notiz `done/<welle-id>-results.md`.

Quellen: vendored Regelwerk `.harness/baseline/<tag>/regelwerk/`, Modul 6, 7, 5; bei Konflikt gilt der
Kurs.

## Repo-lokale Regeln (Adaptions-Block in `harness/conventions.md`)

- **Docker-only; Gate-Nachweis:** nur `make`-Targets; jede Inhaltsänderung (auch Commit) nach
  `make gates` macht den Stempel ungültig. **Gates einmal am Ende.**
- **Doc-Gate:** `LH-`/`ADR-`/`MR-`-Kennungen als klickbare Anker-Links (Results-Notiz und Roadmap
  werden gescannt).
- **`cp` aus dem vendored Template** `welle-results.template.md`, dann in place füllen; Regel-Absätze und
  Hinweis-Kommentare der Vorlage beim Füllen entfernen. Nach `sed`/`awk` über Plan-Dateien den Diff
  prüfen (kein Abschnitt geleert).
- **Knapp schließen:** DoD-Häkchen nur nach Verifikationsbericht; §7 trägt Zustand und Anker, keine
  Erzählung (`AGENTS.md` §3.7); jedes Risiko einen Ausgang in **einer** Zeile.
- **Commit** via `git commit --only <pfade> -F <datei>`; Rolle „Planner" und eine Kennung in der Message.
  Abschluss-Commits berühren nur Closure-Artefakte.

## Vorbedingung

1. `CLAUDE.md`, `harness/README.md`, `AGENTS.md`, `harness/conventions.md`, Modul 6 on-demand und die
   Welle-Plan-Datei (v. a. §3 Closure-Kriterien) lesen.

## Die sechs Schritte

2. **Schritt 1 — Trigger prüfen.** Alle Slices der Welle in `done/`; `make gates` grün; die Kriterien
   aus der Welle-Datei §3 erfüllt (z. B. ein benannter Smoke). Fehlt ein Beleg, **schließt die Welle
   nicht**. Belege **real** erzeugen, nicht behaupten.
3. **Schritt 2 — Carveout-Audit** (Modul 7). Jeden offenen Carveout: aufgelöst · verlängert (mit
   Folge-Slice) · permanent. Schließen *mit* dokumentiertem Carveout ist zulässig, **nie** mit stillem
   rotem Gate. Keine Carveouts → belegte „0 offen"-Feststellung.
4. **Schritt 3 — Results-Notiz** `done/<welle-id>-results.md` per `cp` aus dem Template: geliefert ·
   was funktionierte · was anders lief · **Steering-Loop-Einträge** (geschärfte Regel / neuer Sensor /
   benannte Spec-Lücke) · Folge-Slices · Verifikation aus Schritt 1. **Ohne Lerneintrag ist die Welle
   nicht „fertig", nur „weg".** Die Welle-Plan-Datei geht per `git mv` nach `done/` als **eigener reiner
   Move-Commit** (`AGENTS.md` §3.3); danach reconcilen (Inbound-Links aus Roadmap und Slices, eigene
   `../`-Links eine Ebene tiefer) bis `docs-check` grün ist.
   **Lese-Schritt des Beobachtungs-Registers** (`docs/plan/planning/observations/README.md`): jeder
   Eintrag mit **≥ 3** Dateien in `evidence/` wird Steering-Loop-Eintrag und **verkörperte Regel** mit
   Anker `seit welle-<Kennung>`; der Ausgang steht in seiner `state.md`, das Verzeichnis bleibt liegen
   (*gestrichen* mit Begründung, nie löschen). Erreicht keiner 3×, lautet die Feststellung *„kein
   Eintrag über der Schwelle"*, bei nur-`README.md` *„das Register führt keinen Eintrag"*; Auslassen ist
   keine Antwort. Was unter 3× steht, liest diese Closure nicht (§8 des nächsten Slice-Plans).
   **Zum Schluss die drei Paarungen, nach dem `git mv`** (Modul 6, Schritt 3): (a) *Anker* — wo ein
   Eintrag `liegt in <Zielort>` trägt, existiert der Zielort ab Repo-Wurzel und trägt
   `seit welle-<Kennung>` bzw. `seit slice-<Kennung>`; (b) *Folge-Slice* — jeder genannte existiert als
   Datei im Planning-Lifecycle; (c) *Register* — jede genannte `BEO-<KUERZEL>/<slug>` existiert als
   Verzeichnis, jedes Verzeichnis trägt ein nicht leeres `evidence/`. **Geprüft werden auch die Slices
   seit der letzten Welle-Closure, wellenlose eingeschlossen** (ihre DoD-Zeile *„Die drei Paarungen …
   sind getragen"* weist die Prüfung der Welle-Closure zu). Ergebnis in die Results-Notiz; rot heißt:
   etwas wurde versprochen und nicht angelegt.
   **Die zweite Hälfte von (c) gilt über das ganze Register, ohne Ausnahme**
   ([ADR-0069](../../docs/plan/adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
   Festlegung 2). Die Results-Notiz trägt die Zeile *„Register-Paarung (c), zweite Hälfte: N
   Verzeichnisse ohne Beleg, namentlich <Liste>; nicht als getragen behauptet."* — N und Namen liefert
   `for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`
   (keine Erwartungswerte; gezählt werden `evidence/*.md`). Nennen ist keine Tilgung: der Befund endet
   mit dem Beleg eines abgeschlossenen Vorgangs.
5. **Schritt 4 — Zeitdokumente archivieren.** Slice-Dateien der Welle, ihr Plan und die Review-Reports
   wandern nach `done/<welle-id>/archiv.zip`; Slice und Plan lassen je einen gekürzten Stub, die
   Results-Notiz bleibt vollständig und flach, Review-Reports bekommen keinen Stub. Eingesammelt wird
   nach der Welle: Slices mit `Welle:` = diese Welle **und** wellenlose seit der letzten Closure; Slices
   einer offenen Welle bleiben liegen.
   **Träger ist `make archive-welle WELLE=<welle-id>`; von Hand archiviert niemand** (nur der
   Archivierungs-Commit bezeugt Vollständigkeit;
   [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md) Festlegungen 1 und 3;
   Beschreibung und Sperren in `harness/README.md` §Werkzeuge und
   [`harness/sensors/archive-welle.md`](../../harness/sensors/archive-welle.md)). Die `cp`-Regel gilt
   hier nicht: der Träger liest die Stub-Vorlagen selbst. Ohne Schreiben zeigt
   `.harness/state/bin/ai-harness-init archive-welle --vorschau <welle-id>`, was der Lauf täte. Das
   Target ist **kein Gate**; Beleg ist `make docs-check` vor und nach dem Lauf.
   **Jeder Ausgang ist fail-closed:** solange kein `docs/plan/planning/done/*/archiv.zip` existiert
   (`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l`; kein Erwartungswert), hat *wellenlos
   seit der letzten Closure* keine Untergrenze und der Lauf bricht ab. Die Archivierung des Altbestands
   ist dann ein eigener Vorgang: `archive-welle altbestand` legt das Sammel-Archiv
   `done/altbestand/archiv.zip` an ([ADR-0041](../../docs/plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md);
   Sperren in `harness/sensors/archive-welle.md`, `[haenger]` bleibt Sperre). Bricht der Lauf an
   einer Sperre, gehört **das** als Feststellung in die Results-Notiz, und die Welle schließt ohne
   Schritt 4. Vor der Adoption geschlossene Wellen bleiben frei.
   **Im Stub:** `Hervorgegangen:` trägt seine Kennungen als Anker-Links; `.d-check.yml` scannt ab `.`,
   die `matrix`-Klasse `slice` greift über `**` auch `done/<welle-id>/slice-*.md`.
6. **Schritt 5 — Wave-Self-Close-Commit + Move.** Der Self-Close-Commit (Inhalt) trägt die Results-Notiz,
   Welle-Datei §7 (Verweis auf die Results-Notiz, kein `Status:`-Feld) und die Roadmap-Fortschreibung.
   Danach der reine `git mv`-Commit der Welle-Plan-Datei, dann der Link-Reconciliation-Commit
   (`AGENTS.md` §3.3: Move und Inhalt getrennt).
7. **Schritt 6 — Roadmap fortschreiben** (im Self-Close-Commit): Welle in *Abgeschlossene Wellen* mit
   Zeiger auf die Results-Notiz, ihr Zeiger verlässt *Offene Wellen*; Meilenstein auf *erreicht*, falls
   erfüllt; löste ein Trigger eine Umplanung aus, bekommt *Historische Trigger-Verschiebungen* den
   Eintrag.

## Abschluss

8. `make gates` **einmal** grün bestätigen (Stempel auf den aktuellen Tree). Die Welle ist auditierbar
   geschlossen, wenn alle sechs Belege vorliegen: Trigger · Carveout-Audit · Results-Notiz ·
   Archivierung (oder ihre nicht eingetretene Start-Bedingung) · Self-Close-Commit · fortgeschriebene
   Roadmap. Datum ist Output, nie Trigger. Keine Erfolgsmeldung ohne Command-Ausgabe.
