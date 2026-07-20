# Slice implementieren (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Implementation**-Rolle (Modul 9) für *einen* Slice — innerhalb der
Rollen-Sequenz Planner → Architect → Implementation → Reviewer → Verifier → Validator →
Planner-Closure (Modul 8). **Rollen-Trennung ist Kontext-Trennung:** die nachgelagerten Rollen
(Review, Verifikation, Validation, Closure) laufen in **frischem Kontext** (Subagent / geleerter
Kontext), nie im Kontext, der den Code schrieb — sonst wiederholt sich derselbe blinde Fleck.
Keine Rolle springt rückwärts ohne Übergabe-Artefakt (Findings · Folge-ADR · Carveout, Modul 8).

Kanonische Quellen (vendored Regelwerk, `.harness/baseline/<tag>/regelwerk/`): Modul 9
(Implementierung), Modul 5 (Lifecycle), Modul 8 (Rollen), Modul 10 (Review), Modul 11
(Verifikation).

## Repo-lokale Adaptionen, die du beachten MUSST (harness/conventions.md — MR-Block)

Über das Regelwerk hinaus trägt dieses Repo lokale Adaptionen gegenüber der Baseline. Lies den
Adaptions-Block („MR-Block") in `harness/conventions.md`; die workflow-relevanten:

- **Docker-only, kein Host-Toolchain.** Jeder Gate und jedes Tool läuft in einem gepinnten
  Docker-Image; der PreToolUse-Guard blockt Host-`go`/`pip`/`npm`/`golangci-lint` (und prüft
  Sub-Shell-Strings). Rufe nie einen Host-Toolchain auf — nur die `make`-Targets.
- **Gate-Nachweis + Stop-Hook.** `make gates` endet mit `record-gates`, das einen Content-Hash des
  Working Tree stempelt; der Stop-Hook verweigert den Abschluss, solange der aktuelle Tree nicht
  passt. **Jede Inhaltsänderung nach einem Gate-Lauf — inklusive jedes Commits und jedes `git mv`
  — macht den Stempel ungültig: `make gates` erneut laufen.** Ein Commit/Move ohne frischen
  Gate-Lauf lässt den Stop-Hook rot.
- **Strenges Doc-Gate (d-check).** Jede `LH-`/`ADR-`/`MR-`-Kennung in einer gescannten `.md` muss
  ein klickbarer Anker-Link sein (link-policy: always) — ein bares Kennungs-Token bricht
  `docs-check` (`id-unlinked`). `codepaths` verlangt, dass Pfade in Inline-Code existieren: eine
  *geplante* Datei braucht einen Inline-`d-check:ignore`-Marker, eine *bewusst entfernte* gehört in
  `ignore-refs`. Spec verweist nie abwärts auf ADR/Slice; ein Verweis auf eine superseded ADR nur
  via Inline-Code + `d-check:ignore`. `docs/reviews/**` ist ausgenommen (Zeitdokumente).
- **Neue Artefakte per `cp` aus den vendored Templates** (`.harness/baseline/<tag>/templates/…`),
  dann ausfüllen — keine handgeschriebenen oder repo-gepflegten Template-Kopien.
- **Commit via Message-Datei** (`git commit -F <datei>`): der Guard scannt den Command-String,
  also nie eine Commit-Message inline, die ein geblocktes Tool-Token enthält.

## Kontext lesen (Modul 9, Schritte 1–3)

1. `CLAUDE.md` lesen.
2. `harness/README.md` lesen.
3. `AGENTS.md` lesen.
4. `harness/conventions.md` lesen.
5. Den Regelwerk-Index (`.harness/baseline/<tag>/regelwerk/README.md`) und das aufgabenrelevante
   Modul **on-demand** lesen (Source Precedence, committet vendored Baseline). Nicht den ganzen
   Baum laden.
6. Die als Argument übergebene Slice-Datei lesen.
7. Alle referenzierten ADRs und Anforderungen lesen.
8. Berichten: Slice-ID · LH-IDs · ADR-IDs · betroffene Komponenten · zu laufende Gates.

## Nach in-progress eintreten (Modul 5 Lifecycle + Modul 8 Übergabe)

9. Die Implementation erhält den Slice **in `in-progress/`** (Planner→Implementation-Übergabe,
   Modul 8; `next → in-progress` = „Implementer beginnt", Modul 5). Liegt er noch in `open/`,
   zuerst dorthin verschieben (`open → next → in-progress`). Jedes `git mv` ist ein **reiner Move,
   getrennt vom Inhalt committet** (Hard Rule 3.3).
10. WIP-Limit = 1 pro Implementer (Modul 5): kein paralleles `in-progress/`.
11. Lifecycle-Rücksprungkanten (Modul 5), falls sich der Slice als falsch erweist: zu groß →
    `in-progress → next` (zurück zur Zerlegung); blockiert → `in-progress → open` (Carveout,
    Modul 7). Zurückführen ist Disziplin, kein Scheitern.

## Plan vor Code (Modul 9, Schritt 4 — nicht optional)

12. **Den Ist-Zustand gegen den Slice-Plan messen, bevor du editierst** (`grep`/`diff`, nicht
    `edit`) — Geschwister-Slices lassen Pläne altern (gelöschte Pfade, verschobene
    Lifecycle-Dateien). Drift zuerst abgleichen; keinen veralteten Plan blind abarbeiten.
13. Die kleinste sinnvolle Änderung gegen die DoD planen. Erst planen, dann coden.

## Implementieren und gaten (Modul 9, Schritte 5–6)

14. Die kleinste sinnvolle Änderung implementieren.
15. Zuerst den engsten nützlichen Gate laufen lassen (z. B. eine Testdatei / ein Gate).
16. `make gates` laufen lassen.

**Plan-Defekt-Rücksprungkanten (Modul 9):** ein roter Sensor (15) oder rotes Gate (16) führt
zurück zum **Plan** (13) — den Plan verfeinern, nicht den Kontext neu lesen. Ein Rücksprung zu
Schritt 1 signalisiert einen Kontext-Defekt. Ein struktureller Fehlschnitt (zu groß / blockiert)
ist eine Lifecycle-Rücksprungkante (11).

## Pre-completion-Checkliste (Modul 9, Schritt 8 — letzte Handlung der Implementation-Rolle)

17. Doku, ADR-Index und README aktualisieren, falls ein öffentlicher Vertrag berührt ist.
18. Die Pre-completion-Checkliste laufen: die DoD Punkt für Punkt **behaupten** und die
    **Sensor-Belege** anhängen (`make gates`-Ausgabe). Das ist die *Behauptung* der
    Implementation-Rolle und die *Eingabe* des Verifiers — **nicht** das finale DoD-Urteil
    (Modul 11: „Behauptung ohne Bestätigung ist die häufigste Verifier-Lücke"; eine DoD-Verletzung
    ist eine Verifier-only-Klasse, unsichtbar für Review und Tests). Ausgeführte Sensors +
    Restrisiken berichten.
19. **Zu jedem neuen oder geänderten Wächter die rot färbende Mutation benennen**
    (`AGENTS.md` §3.6). Ein grüner Gate-Lauf belegt nur, dass nichts *bricht* — nicht, dass
    der Wächter greift. Pro Zusage also: *welche Änderung am geprüften Code müsste diesen
    Test rot machen, und wurde sie einmal gesehen?* Wo die Antwort dauerhaft interessant
    ist, gehört sie als Fall nach `test/mutations/` (dann fährt `make mutate` sie künftig
    automatisch); wo sie einmalig ist, in den Bericht. **Keine Antwort ist ein Befund**, kein
    Formfehler — die Klasse „Zusage greift weiter als Abdeckung" hat vier Rollen-Durchgänge
    gekostet, bevor sie hier landete.

Hier endet die Implementation. Die übrigen Rollen laufen in **getrennten Kontexten** (Modul 8).

## Übergaben an nachgelagerte Rollen (Modul 8 → 10 → 11)

20. **→ Reviewer (Code-Review, Modul 10):** den Diff + Plan-Verweis an einen **unabhängigen**
    Reviewer übergeben (`.harness/skills/reviewer.md`, frischer Kontext — kein Selbst-Review). Er
    kategorisiert Findings (HIGH/MEDIUM/LOW/INFO) in einen Report unter `docs/reviews/` und prüft
    den Diff gegen **Plan + ADR + Hard Rules** (nicht die DoD). HIGH/MEDIUM auflösen; ein HIGH mit
    Rollen-Konflikt folgt Modul 8 §Konflikt-Pfad (Sequenz mit Übergabe-Artefakten, nie
    „herabstufen, weil der Implementer widerspricht").
21. **→ Verifier (Modul 11):** in getrenntem Kontext die DoD-/Spec-Behauptung und den
    Plan-vs-Code-Diff **bestätigen**, dazu ADR-Konformität. Das fängt, was Tests übersehen und der
    Reviewer nicht sieht (DoD-Verletzung).
22. **→ Validator (Modul 8):** falls der Slice End-Nutzer-Wert liefert, gegen den realen Bedarf
    validieren („das Richtige bauen"). Meist n/a bei interner Wartung — dann explizit sagen statt
    still überspringen.

## Closure — Planner-Rolle (Modul 8 + Modul 5)

23. Erst wenn der Review konform **und** die Verifikation die DoD bestätigt hat, schließt der
    **Planner**: die Closure-Notiz mit einem **Steering-Loop-Eintrag** schreiben (geschärfte Regel ·
    neuer Sensor · benannte Spec-Lücke — Modul 5: der `→ done`-Übergang verlangt einen Lerneintrag,
    nicht nur grüne Gates), dann den Slice `in-progress → done` verschieben (`git mv`, eigener
    Commit, getrennt vom Inhalt — Hard Rule 3.3). Ein rotes Gate erreicht `done/` **nur** mit
    dokumentiertem Carveout (Modul 7), nie als stilles Rot.

Gates nicht überspringen. Keine Erfolgsmeldung ohne Command-Ausgabe.
