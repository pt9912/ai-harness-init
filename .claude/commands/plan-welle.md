# Welle planen (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Planner**-Rolle für *eine* Welle (Modul 6 — Roadmap Engineering). Eine
Welle ist ein **Bündel von Slices**, das gemeinsam geplant und geschlossen wird. Seit Regelwerk v3.5.0
ist der Welle-Status die **Verzeichnis-Position**, **kein `Status:`-Feld**: die **eröffnete**
Welle liegt **flach** in `docs/plan/planning/<welle-id>.md`, bei Closure wandert sie per `git mv` nach
`done/` (das schließt `/close-welle`). Die Roadmap bleibt Sequenzierungs-Autorität für die
**Reihenfolge**; den Zustand sagt die Verzeichnis-Position.

**Dieser Command vollzieht die Eröffnung — und die verlangt den eingetretenen Start-Trigger.**
Solange eine Welle in der Vorschau *Nächste Wellen* steht, trägt sie **keine** Datei unter
`docs/plan/planning/` und **keinen** Zeiger unter *Offene Wellen*; ihre Kennung steht dort
**unverlinkt** ([ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
Festlegung 1). Ist der Trigger noch nicht eingetreten, endet die Arbeit bei dieser Vorschau-Zeile
(Welle · Trigger · wichtigste Slices · Aufwand) — Schritt 7, Schritt 8 und Schritt 9 laufen dann
nicht (Schritt 8 füllt die Datei, die erst Schritt 7 anlegt). Wer die Datei früher anlegt, färbt
`make docs-check` rot: `wave-preview-exists`, und ohne Zeiger unter *Offene Wellen* zusätzlich
`wave-drift` — geprüft ist dabei allein die Kopplung *Datei ⟺ Zeiger ⟺ nicht in der Vorschau*,
nicht der Start-Trigger selbst: Träger dieser Folgepflicht ist der Rollen-Wechsel und kein Sensor
([ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Fitness Function).

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

**Vor jedem neuen Slice-Plan: das Beobachtungs-Register sichten** (`docs/plan/planning/observations/README.md`)
— der **Sichtungs**-Schritt aus Modul 5, *Zwei Schritte vor der Modus-Begründung*, und für alles
**unter** 3× der einzige Leser: die Welle-Closure liest nur, was die Schwelle erreicht hat. Berührt
eine Sub-Area des neuen Slice einen Eintrag `BEO-<KUERZEL>/<slug>/`, gehört dessen **Zähler-Stand**
in das Kriterium *Evidenz-/Diskrepanz-Risiko* in §8 des Plans — abgelesen wird er nicht, er ist die
Zahl der Dateien unter dem `evidence/` des Eintrags. Erreicht der Eintrag **mit diesem Slice** 3×,
ist er keine Notiz mehr, sondern eine Lücke mit eigenem Folge-Slice. **Keine Treffer sind ebenfalls
eine Antwort** und werden in §8 notiert; trägt die Ablage nur ihre `README.md`, lautet die Antwort
genau das — nicht *„geprüft"* und nicht gar nichts. Gelesen wird der **gemergte** Stand: das
Register ist beim Lesen so alt wie der letzte Merge.

6. Existiert ein Slice der Welle noch nicht, ihn **per `cp` aus `slice.template.md`** anlegen
   (`docs/plan/planning/open/slice-<NN>-<titel>.md`), dann füllen. Nie hand-authoren.

## Einen Slice stilllegen (`open/` oder `next/` → `done/`)

Gilt, wenn ein Slice beim Bereitstellen seinen Gegenstand an einen anderen abgibt oder der
Gegenstand entfällt, etwa bei einer Gruppierung (Baseline-Regelwerk `modul-05-planning-harness.md`
§Ein Slice, dessen Gegenstand ein anderer übernimmt). Die Kante führt an `in-progress/` vorbei.
**Kein Wächter hält sie** ([`harness/sensors/slice-mv.md`](../../harness/sensors/slice-mv.md)
§Grenze). Die Prüfungen unten trägt darum dieser Lauf, bis `slice-mv-kanten-nach-done-sind-bewacht`
geschlossen ist.

- **Vorher, im Inhalts-Commit:**
  - Die Liefer-Punkte der DoD bleiben leer.
  - §7 trägt die Zeile `Gegenstand:` mit der Kennung des übernehmenden Slice oder mit dem Grund.
  - Jedes Risiko aus §6 trägt einen Ausgang. Kein Modul prüft das; die Adresse der Lücke ist
    `slice-risiko-ausgang-hat-einen-sensor`.
- **Die genannte Kennung löst auf:** `ls docs/plan/planning/*/<kennung>.md` nennt genau eine Datei.
  **Diese Prüfung ist ein Urteil dieses Laufs, kein Sensor.** Die Ziel-Fassung lässt *Urteil oder
  eigener Sensor* offen, und dieses Repo wählt das Urteil. Setzung des Planners vom 2026-09-17;
  sie ist neu zu entscheiden, sobald der gepinnte d-check die Auflösung prüft oder in `done/` eine
  Kennung steht, die nicht auflöst. Der Auftraggeber hat die Setzung am 2026-09-17 bestätigt und
  dem Planner zugewiesen. Die Zuständigkeit für eine Norm-Aussage ohne Original lässt
  [ADR-0028](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 2 offen; hier trägt darum die Entscheidung des Auftraggebers.
- **Der Wechsel:** `make slice-mv SLICE=<kennung> TO=done`, **je Slice einzeln**. Nach jedem
  Wechsel laufen drei Prüfungen, bevor der nächste beginnt:
  1. Der Exit-Code ist 0.
  2. Der Move-Commit ist ein reiner Rename: `git show --numstat --format= -M <commit>` gibt `0 0`
     aus. Der Move-Commit ist `HEAD~1`, wenn das Werkzeug einen Nachzug-Commit meldet, sonst
     `HEAD`.
  3. `make docs-check` meldet keinen Befund.

  **Fällt eine Prüfung, hält die Serie an.** Der Befund wird geklärt, bevor der nächste Slice
  wandert.
- **Den Nachzug-Commit lesen:** Hat er in `docs/reviews/**` einen Tree-Operanden (`<sha>:<pfad>`)
  umgeschrieben, nimmst du diese Hunks per Gegen-Commit zurück. Kein Gate sieht das; das Register
  führt die Klasse als `verweis-nachzug-bricht-tree-operand`.

## Welle-Plan per cp anlegen und füllen (der Kern-Schritt)

7. **`cp` aus `.harness/baseline/<tag>/templates/docs/plan/planning/welle.template.md` nach
   `docs/plan/planning/<welle-id>.md`** — flach in `planning/`, kein Lifecycle-Ordner. Provenienz mit
   `diff -q <template> <ziel>` belegen (byte-identisch, dann füllen).
8. **In-place füllen** (Edits, **kein** Voll-Überschreiben): den `> **Template-Hinweis.**`-Block
   strippen, alle Platzhalter ersetzen, die `<!-- -->`-Guidance-Kommentare entfernen. Die
   **`Lifecycle:`-Note der Vorlage behalten** (Zustand = Verzeichnis-Position, **kein `Status:`-Feld**
   — v3.5.0), Zielmeilenstein und Verantwortlich/Datum setzen. Die Abschnitte mit den drei
   Pflichtteilen aus Schritt 4 füllen; Kennungen als Anker-Links.

## Roadmap verdrahten und gaten

9. Roadmap fortschreiben — die zwei Wirkungen der Eröffnung, die dort landen: Die Welle-Zeile
   **verlässt** die Vorschau *Nächste Wellen*, und unter *Offene Wellen* erscheint der Zeiger auf
   die neue Plan-Datei. Beide gehören mit Schritt 7 in **einen** Commit: Datei, entfallende
   Vorschau-Zeile und Zeiger sind ein Vorgang, nicht drei
   ([ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1).
   Die Welle-Verweise der zugehörigen Slices auf die neue Plan-Datei ziehen.
10. `make gates` laufen lassen (grün). Beim **Anlegen** ist der Welle-Plan **Inhalt** → ein einzelner
    Commit, hier **kein `git mv`** (die neue Welle entsteht flach, und flach **ist** der Zustand
    *eröffnet*). Der `git mv` nach `done/` kommt erst bei der **Closure** (`/close-welle`).
    Commit via `-F`.

**Merke (Modul 6):** Eine Welle endet durch **Closure-Kriterien**, nicht durch ein Datum
(Welle ≠ Sprint). Ein Trigger ist eine beobachtbare Bedingung, kein Kalendertag. Die fertige Welle
schließt `/close-welle`.

Gates nicht überspringen. Keine Erfolgsmeldung ohne Command-Ausgabe.
