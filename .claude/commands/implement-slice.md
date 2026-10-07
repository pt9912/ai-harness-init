# Slice implementieren (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Implementation**-Rolle (Modul 9) für *einen* Slice — innerhalb der
Rollen-Sequenz Planner → Architect → Implementation → Reviewer → Verifier → Validator →
Planner-Closure (Modul 8). **Rollen-Trennung ist Kontext-Trennung:** die nachgelagerten Rollen
(Review, Verifikation, Validation, Closure) laufen in **frischem Kontext** (Subagent / geleerter
Kontext), nie im Kontext, der den Code schrieb — sonst wiederholt sich derselbe blinde Fleck.
Keine Rolle springt rückwärts ohne Übergabe-Artefakt (Findings · Folge-ADR · Carveout, Modul 8).

Quellen: vendored Regelwerk `.harness/baseline/<tag>/regelwerk/` — Modul 9 (Implementierung), 5
(Lifecycle), 8 (Rollen), 10 (Review), 11 (Verifikation), on-demand.

## Repo-lokale Adaptionen (MR-Block in `harness/conventions.md`)

- **Docker-only** (`AGENTS.md` §3.9): nur `make`-Targets, nie eine Host-Toolchain; der
  PreToolUse-Guard blockt sie samt Sub-Shell-Strings.
- **Gate-Nachweis + Stop-Hook.** `make gates` endet mit `record-gates` (Content-Hash des Working
  Tree und HEAD-SHA). Der Stop-Hook bindet an den Commit: **ein Commit — auch der eines `git mv`
  — ohne frischen grünen Lauf über seinem Inhalt hält das Turn-Ende auf**; ohne neuen Commit geht
  es frei, sofern ein grüner Lauf HEAD gestempelt hat (Stempel `gates-passed.head` aus
  `record-gates`) — fehlt der Stempel (erster Turn nach dem Update, Klon vor dem ersten grünen
  Lauf), gilt der strenge Zweig. Streng, wenn `.harness/stop-gate-streng` liegt oder
  `STOP_GATE_STRENG=1` gesetzt ist
  ([ADR-0083](../../docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)).
- **Strenges Doc-Gate (d-check).** Jede `LH-`/`ADR-`/`MR-`-Kennung in einer gescannten `.md` ist
  ein Anker-Link (`id-unlinked`). Pfade in Inline-Code müssen existieren: *geplante* Datei →
  Inline-`d-check:ignore`, *bewusst entfernte* → `ignore-refs`. Spec verweist nie abwärts auf
  ADR/Slice. `docs/reviews/**` ist ausgenommen.
- **Neue Artefakte per `cp` aus dem vendored Template** (`.harness/baseline/<tag>/templates/…`),
  dann **in-place** füllen — nie handgeschrieben, keine repo-gepflegte Kopie.
- **Dateien ändern mit `Edit`**, nicht per `Write` komplett überschreiben (Diff bleibt klein,
  fremde Änderungen bleiben erhalten).
- **Commit via Message-Datei** (`git commit --only <pfade> -F <datei>`): der Guard scannt den
  Command-String, eine Inline-Message mit geblocktem Tool-Token würde blockiert.

## Kontext lesen (Modul 9, Schritte 1–3)

`CLAUDE.md` und `AGENTS.md` (§3, §6) sind im Kontext; darüber hinaus nur, was der Lauf braucht —
nicht pauschal alles:

1. Die Slice-Datei (Argument).
2. Die im Plan genannten ADRs, Anforderungen und Regeln, dazu die Dateien, die der Diff berührt.
3. `harness/README.md` §Sensors (welcher Sensor deckt was) und den MR-Block nur dort, wo der Plan
   ihn berührt; Regelwerk-Index plus das aufgabenrelevante Modul on-demand, nie den Baum.
4. Berichten (eine Zeile): Slice-ID · LH-/ADR-IDs · Komponenten · zu laufende Sensoren.

## Nach in-progress eintreten (Modul 5 Lifecycle + Modul 8 Übergabe)

5. Der Slice muss **in `in-progress/`** liegen (Modul 5/8). Liegt er in `open/`/`next/`:
   `make slice-mv SLICE=slice-<Kennung> TO=<next|in-progress>` — `git mv`, reiner Move als
   **eigener Commit** (`AGENTS.md` §3.3), danach Verweis-Nachzug als zweiter Commit, falls welche
   anfielen. Voraussetzung: sauberer Arbeitsbaum; Grenzen (Zustandssätze, Welle-Plan-Dateien,
   präfixlose Eingehend-Links nur aus flachen Geschwistern) und Rest-Nachzug per `make docs-check`
   stehen in [`harness/sensors/slice-mv.md`](../../harness/sensors/slice-mv.md).
6. WIP-Limit 1. Erweist sich der Slice als falsch, führt er zurück (Modul 5): zu groß →
   `in-progress → next`; blockiert → `in-progress → open` (Carveout, Modul 7) — Disziplin, kein
   Scheitern.

## Plan vor Code (Modul 9, Schritt 4)

7. **Ist-Zustand gegen den Slice-Plan messen, bevor du editierst** (`grep`/`diff`): Geschwister-
   Slices lassen Pläne altern. Drift zuerst abgleichen.
8. Kleinste Änderung gegen die DoD planen. Die Testdatei-Zeile zitiert die Kennung der Anforderung,
   deren Akzeptanzkriterien das Ergebnis messen — nicht ihren Text. Dieselbe Ursache über viele
   gleichrangige Dateien: eine Begründung, nicht eine je Datei. **Out-of-Scope** schreibt fort,
   was §1 des Plans ausschließt; nimmt der Lauf etwas mit, das §1 ausschließt, ist das
   Planner-Arbeit und Übergabe-Artefakt (`AGENTS.md` §3.10) — die Plan-Änderung geht dem Code
   voraus. Der Plan lebt in §3 des Slice-Plans (dort fortschreiben), nicht im Chat.

## Implementieren und gaten (Modul 9, Schritte 5–6)

9. Implementieren. Während der Arbeit nur der engste Sensor: `make test-bats BATS_TARGET=test/<datei>.bats`,
   `make mutate MUTATE_CASES=…`. Kein zusätzliches `make test` vor `make gates` (es enthält die
   Tests); `make gates` **einmal vor dem Handoff** (`AGENTS.md` §6 Schritt 5/6).
10. Ein roter Sensor oder rotes Gate führt zurück zum **Plan** (verfeinern, nicht den Kontext neu
    lesen); ein Rücksprung zur Kontext-Lektüre signalisiert einen Kontext-Defekt.

## Pre-completion-Checkliste (Modul 9, Schritt 8 — letzte Handlung der Implementation-Rolle)

11. Doku, ADR-Index und README aktualisieren, falls ein öffentlicher Vertrag berührt ist. **Gibt
    Prozedur- oder Nutzer-Doku den Vertrag eines Werkzeugs wieder — Exit-Klassen, Meldungs-
    Wortlaut, Zahl, Wartezeit, Reichweite einer Zusage —, zeigt jede Aussage auf die Quelle, die
    sie trägt (Skript, ADR-Festlegung, gefahrener Lauf), und geht nicht weiter als diese.** Die
    Quelle ist im selben Lauf zeilenweise gelesen: Aufzählungen nur abschließend, wo die Quelle
    es so führt; Regeln in der Form der Quelle; Ausnahmen der Quelle mitnennen; Gelesenes steht als
    gelesen, nicht als gefahren. Kein Gate hält die Prozedur gegen die Skript-Ausgabe
    (`AGENTS.md` §3.6) · seit slice-tap-nachzug-sync-schreibt-die-formel-ins-tap
12. **Sensor-Belege.** `make gates` einmal (siehe 9) **und die Nicht-Gate-Sensoren, die den Slice
    betreffen** (`make smoke`, wenn der Emit-Pfad berührt ist). Einen neuen oder geänderten
    Wächter belegst du **einzeln**: die Mutation von Hand fahren, den benannten Test fallen sehen,
    die Ausgabe lesen. Den repo-weiten `make mutate`-Satz fährst du nicht — er läuft nächtlich
    (`.github/workflows/mutate.yml`, Stufe Post-integration, `AGENTS.md` §3.6). Ein nicht
    gelaufener Sensor ist ein Befund: ihn wegzulassen braucht eine Begründung. Das ist die
    *Behauptung* der Rolle und die *Eingabe* des Verifiers, nicht das DoD-Urteil.
13. **Zu jedem neuen oder geänderten Wächter die rot färbende Mutation benennen** (`AGENTS.md`
    §3.6): welche Änderung am geprüften Code müsste den Test rot machen, und wurde sie gesehen?
    Dauerhaft interessant → Fall nach `test/mutations/`; einmalig → in den Bericht. Keine Antwort
    ist ein Befund.
    **Ein Sensor ist erst fertig, wenn er an der realen Quelle rot gesehen wurde** — nicht an
    einer nachgebauten Zeile oder Fixture. Trägt der Bestand kein reales Beispiel, steht das im
    Kopf des Sensors **und** im Bericht, statt nur eine erfundene Zeile zu zeigen.
14. **Jeden neu geschriebenen oder geänderten Kommentar** (Code, Konfiguration, Skripte, Workflows,
    Makefile, Skript-Köpfe) gegen `AGENTS.md` §3.7 prüfen: Ist-Zustand im Indikativ, Herkunft
    höchstens als ein auflösbares Feld (`LH-*`, `ADR-*`, `· seit welle-<Kennung>` bzw.
    `· seit slice-<Kennung>`); keine Slice-Nummer als Begründung, kein Konjunktiv über
    Verworfenes oder Künftiges. Vor der Übergabe umformulieren.

## Bericht und Handoff (Modul 8 → 10 → 11)

**Der Bericht ist knapp:** Diff-Übersicht · Sensoren mit Ausgabe · rot gesehene Gegenbeispiele ·
Grenzen und Übergaben. Kein zusätzliches Zeitdokument neben dem Handoff, außer der Plan verlangt
es. Hier endet die Implementation; die übrigen Rollen laufen in **getrennten Kontexten**
(Modul 8, kein Selbst-Review).

15. **→ Reviewer (Modul 10):** Diff + Plan-Verweis an einen **unabhängigen** Reviewer
    (`.harness/skills/reviewer.md`, frischer Kontext). Er prüft gegen Plan + ADR + Hard Rules und
    schreibt den Report unter `docs/reviews/`. HIGH/MEDIUM auflösen; ein HIGH mit Rollen-Konflikt
    folgt Modul 8 §Konflikt-Pfad, nie „herabstufen, weil der Implementer widerspricht".
16. **→ Verifier (Modul 11):** getrennter Kontext bestätigt DoD/Spec-Behauptung, Plan-vs-Code-Diff
    und ADR-Konformität.
17. **→ Validator (Modul 8):** nur bei End-Nutzer-Wert gegen den realen Bedarf; sonst „n/a" explizit
    sagen.

## Closure — Planner-Rolle (Modul 8 + Modul 5)

Die Closure schreibt nicht dieser Lauf (`AGENTS.md` §3.10), sie steht hier als Übergabe-Kontext.

18. Erst wenn der Review konform **und** die Verifikation die DoD bestätigt hat, schließt der
    **Planner**: Closure-Notiz mit **Steering-Loop-Eintrag** (geschärfte Regel · neuer Sensor ·
    benannte Spec-Lücke) committen, dann `make slice-mv SLICE=slice-<Kennung> TO=done` — reiner
    Move, danach getrennt der Verweis-Nachzug (§3.3; Grenzen wie in Schritt 5); `make docs-check`
    prüft den Rest. Ein rotes Gate erreicht `done/` nur mit dokumentiertem Carveout (Modul 7).
19. **Liegen Commits nach dem letzten Reviewer-Report vor** (Tests, Produktcode, Mutations-Fälle,
    Sensor-Doku), benennt die Closure-Notiz sie einzeln mit Hash und Kurzbeschreibung und
    entscheidet mit Begründung: weitere Reviewer-Runde über genau diesen Rest — oder begründet
    dagegen (etwa: der Verifier hat sie gemessen und gefahren, sie setzen nur einen vom Review
    benannten Schließungs-Vorschlag um). Ein Häkchen *Review durchgeführt* bestätigt nicht
    stillschweigend Commits danach; kein Gate fängt das (`AGENTS.md` §3.10) ·
    seit slice-204-das-programm-feld-nennt-das-programm
20. **Beobachtungs-Register fortschreiben** (`docs/plan/planning/observations/`, Modul 6) — Schreib-
    Schritt der Closure, **vor** dem `git mv`. Je Beobachtung aus §7: Klasse schon geführt → die
    Kennung `BEO-<KUERZEL>/<slug>` zitieren und eine Datei `evidence/slice-<Kennung>.md` anlegen
    (eine je Auftreten); sonst neues Verzeichnis mit `observation.md` und `state.md`, Kürzel aus der
    Modus-Deklaration in `harness/conventions.md` nachschlagen, nicht erfinden. Der Zähler folgt aus
    den Evidence-Dateien. Bei null Beobachtungen trägt §7 den Satz *keine Beobachtung angefallen*.
    Erreicht ein Eintrag 3×, wird er zur verkörperten Regel (Lese-Schritt der Welle-Closure,
    `/close-welle`; ohne Welle löst ihn diese Closure aus, Anker `seit slice-<Kennung>`).

Keine Erfolgsmeldung ohne Command-Ausgabe.
