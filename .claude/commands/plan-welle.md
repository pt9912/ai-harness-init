# Welle planen (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Planner**-Rolle für *eine* Welle (Modul 6 — Roadmap Engineering). Eine
Welle ist ein **Bündel von Slices**, das gemeinsam geplant und geschlossen wird; ihr Status lebt in
der **Roadmap** (`Status:`-Feld + Roadmap-Abschnitte), **nicht** im Verzeichnis — die Lifecycle-Ordner
(`open/`·`next/`·`in-progress/`·`done/`) sind **slice-reserviert**. Der Welle-Plan liegt darum
**flach** in `docs/plan/planning/<welle-id>.md`, nie in einem Lifecycle-Ordner.

Kanonische Quellen (vendored Regelwerk, `.harness/baseline/<tag>/regelwerk/`): Modul 6 (Roadmap),
Modul 5 (Planning-Lifecycle), Modul 7 (Carveouts). Bei Konflikt gilt der Kurs.

## Repo-lokale Adaptionen, die du beachten MUSST (harness/conventions.md — MR-Block)

Lies den Adaptions-Block („MR-Block") in `harness/conventions.md`; die planungs-relevanten:

- **Neue Artefakte per `cp` aus den vendored Templates** (`.harness/baseline/<tag>/templates/…`),
  dann **in-place** ausfüllen — **keine handgeschriebenen Kopien und kein Modellieren auf ein
  bestehendes Artefakt.** Ein `cp` gefolgt von vollem Überschreiben (`Write`) ist derselbe Verstoß,
  weil der `cp` verworfen wird. Das gilt für den Welle-Plan (`welle.template.md`) **und** jeden neuen
  Slice (`slice.template.md`).
- **Strenges Doc-Gate (d-check).** Jede `LH-`/`ADR-`/`MR-`-Kennung in einer gescannten `.md` muss ein
  klickbarer Anker-Link sein (link-policy: always) — ein bares Kennungs-Token bricht `docs-check`. Der
  Welle-Plan wird gescannt.
- **Docker-only + Gate-Nachweis/Stop-Hook.** Nur `make`-Targets, nie Host-Toolchain. `make gates`
  endet mit `record-gates`; jede Inhaltsänderung nach einem Gate-Lauf (inkl. Commit) macht den Stempel
  ungültig → `make gates` erneut laufen.
- **Commit via Message-Datei** (`git commit -F <datei>`).

## Kontext lesen

1. `CLAUDE.md`, `harness/README.md`, `AGENTS.md`, `harness/conventions.md` lesen.
2. Den Regelwerk-Index (`.harness/baseline/<tag>/regelwerk/README.md`) und **Modul 6** on-demand lesen
   (Source Precedence). Nicht den ganzen Baum laden.
3. Die Roadmap (`docs/plan/planning/in-progress/roadmap.md`) lesen: steht die zu planende Welle schon
   als Zeile in *Nächste Wellen*? Liegen ihre Slices bereits in `open/`?

## Die drei Pflichtteile (Modul 6 — vor dem Schreiben benennen)

4. Eine Welle braucht **minimal drei Bestandteile**, sonst ist sie keine Welle:
   - **Slice-IDs** (der Inhalt) — welche Slices bündelt sie?
   - **Trigger** (Welle startet) — eine **beobachtbare Bedingung**, kein Datum. Beobachtbar heißt:
     *ein anderer Mensch kann ohne Rückfrage sagen, ob er eingetreten ist* (z. B. „Welle X done",
     „Replay grün"). „Sobald wir Zeit haben" scheitert daran.
   - **Closure-Kriterien** (Welle schließt) — Aktion, kein Termin (z. B. alle Slices in `done/`,
     `make gates` grün, ein benannter Smoke). Ein Datum darf als *Schätzung* erscheinen, triggert nie.
5. Berichten: Welle-ID · Zielmeilenstein · Slice-IDs · Trigger · Closure-Kriterien.

## Slices bereitstellen

6. Existiert ein Slice der Welle noch nicht, ihn **per `cp` aus `slice.template.md`** anlegen
   (`docs/plan/planning/open/slice-<NN>-<titel>.md`), dann füllen. Nie hand-authoren.

## Welle-Plan per cp anlegen und füllen (der Kern-Schritt)

7. **`cp` aus `.harness/baseline/<tag>/templates/docs/plan/planning/welle.template.md` nach
   `docs/plan/planning/<welle-id>.md`** — flach in `planning/`, kein Lifecycle-Ordner. Provenienz mit
   `diff -q <template> <ziel>` belegen (byte-identisch, dann füllen).
8. **In-place füllen** (Edits, **kein** Voll-Überschreiben): den `> **Template-Hinweis.**`-Block
   strippen, alle Platzhalter ersetzen, die `<!-- -->`-Guidance-Kommentare entfernen. `Status:` auf
   `open`/`in-progress` setzen (Verzeichnis-los), Zielmeilenstein und Verantwortlich/Datum. Die
   Abschnitte mit den drei Pflichtteilen aus Schritt 4 füllen; Kennungen als Anker-Links.

## Roadmap verdrahten und gaten

9. Roadmap fortschreiben: die Welle-Zeile in *Nächste Wellen* pflegen — **oder**, wenn ihr Trigger
   bereits erfüllt ist, sie in *Aktuelle Welle* heben (mit Slice-IDs · Trigger · Closure-Kriterien).
   Die Welle-Verweise der zugehörigen Slices auf die neue Plan-Datei ziehen.
10. `make gates` laufen lassen (grün). Der Welle-Plan ist **Inhalt** → ein einzelner Commit, **kein
    `git mv`** (Wellen bewegen sich nicht durch Ordner). Commit via `-F`.

**Merke (Modul 6):** Eine Welle endet durch **Closure-Kriterien**, nicht durch ein Datum
(Welle ≠ Sprint). Ein Trigger ist eine beobachtbare Bedingung, kein Kalendertag. Die fertige Welle
schließt `/close-welle`.

Gates nicht überspringen. Keine Erfolgsmeldung ohne Command-Ausgabe.
