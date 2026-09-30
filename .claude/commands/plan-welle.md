# Welle planen (Harness)

Argument: $ARGUMENTS

Dieser Command führt die **Planner**-Rolle für *eine* Welle (Modul 6). Der Zustand einer Welle ist
ihre **Verzeichnis-Position**, kein `Status:`-Feld: die **eröffnete** Welle liegt flach in
`docs/plan/planning/<welle-id>.md`, bei Closure wandert sie per `git mv` nach `done/`
(`/close-welle`). Die Roadmap sequenziert; den Zustand sagt die Position.

**Dieser Command vollzieht die Eröffnung — und die verlangt den eingetretenen Start-Trigger.**
Solange eine Welle in der Vorschau *Nächste Wellen* steht, trägt sie **keine** Datei unter
`docs/plan/planning/` und **keinen** Zeiger unter *Offene Wellen*; ihre Kennung steht dort
**unverlinkt** ([ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
Festlegung 1). Ist der Trigger noch nicht eingetreten, endet die Arbeit bei der Vorschau-Zeile
(Welle · Trigger · wichtigste Slices · Aufwand); Schritt 7 bis 9 laufen dann nicht. Wer die Datei früher
anlegt, färbt `make docs-check` rot (`wave-preview-exists`, ohne Zeiger zusätzlich `wave-drift`) —
geprüft ist nur die Kopplung *Datei ⟺ Zeiger ⟺ nicht in der Vorschau*, nicht der Start-Trigger: Träger
dieser Folgepflicht ist der Rollen-Wechsel
([ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Fitness Function).

Quellen: vendored Regelwerk `.harness/baseline/<tag>/regelwerk/`, Modul 6, 5, 7; bei Konflikt gilt
der Kurs.

## Repo-lokale Regeln (Adaptions-Block in `harness/conventions.md`)

- **`cp` aus dem vendored Template** (`.harness/baseline/<tag>/templates/…`), dann **in place** füllen
  (Edits). Ein `cp` mit anschließendem vollem `Write` ist derselbe Verstoß. Gilt für Welle-Plan
  (`welle.template.md`) und jeden Slice (`slice.template.md`).
- **Plan knapp halten.** Felder der Vorlage füllen; ihre Regel-Absätze („Regeln dieser Sektion"),
  `> **Template-Hinweis.**`-Blöcke und `<!-- -->`-Kommentare beim Füllen entfernen; nur, was der Slice
  trägt. Nach `sed`/`awk` über Plan-Dateien den Diff prüfen (kein Abschnitt geleert).
- **Doc-Gate:** jede `LH-`/`ADR-`/`MR-`-Kennung in einer gescannten `.md` ist ein klickbarer Anker-Link.
- **Docker-only; Gate-Nachweis:** nur `make`-Targets; jede Inhaltsänderung (auch Commit) nach
  `make gates` macht den Stempel ungültig.
- **Commit** via `git commit --only <pfade> -F <datei>`; Rolle „Planner" und eine Kennung in der Message.
- **Aufträge an andere Rollen** nennen nur die Quellen, die der Lauf braucht.

## Kontext lesen

1. `CLAUDE.md`, `harness/README.md`, `AGENTS.md`, `harness/conventions.md`; Regelwerk-Index und
   **Modul 6** on-demand (nicht den Baum).
2. Roadmap `docs/plan/planning/in-progress/roadmap.md`: steht die Welle als Zeile in *Nächste Wellen*?
   Liegen ihre Slices schon in `open/`?

## Die drei Pflichtteile (Modul 6 — vor dem Schreiben benennen)

3. Eine Welle braucht **Slice-IDs** · **Start-Trigger** (beobachtbar: ein anderer Mensch kann ohne
   Rückfrage sagen, ob er eingetreten ist; kein Datum; **kein Ergebnis dieser Welle** — steht er in
   ihrer Slice-Liste, ist er falsch platziert) · **Closure-Kriterien** (Aktion, kein Termin; ein Datum
   darf nur Schätzung sein).
4. Berichten: Welle-ID · Zielmeilenstein · Slice-IDs · Trigger · Closure-Kriterien.

## Slices bereitstellen

**Ein Befund aus Review, Verifikation oder Closure bekommt eine Plan-Datei in `open/` nur mit einem
Auslöser:** (1) Auftrag des Auftraggebers; (2) er blockiert oder verfälscht die laufende Arbeit;
(3) das Beobachtungs-Register hat ihn auf 3× gehoben; (4) ein bereits geplanter Slice nennt ihn mit
Kennung als Folge-Slice. **Ohne Auslöser** nimmt er einen der zwei anderen Ausgänge aus
`modul-06-roadmap.md` §Das Beobachtungs-Register: Register-Eintrag (`observation.md` und
`evidence/<vorgangs-id>.md`) oder ausdrückliche Ablehnung mit Grund in der Closure-Notiz. Eine
Plan-Datei „bis zur ersten Beanspruchung" ist kein Auslöser. **Grenze:** Ein Wächter existiert nicht —
ob ein Auslöser vorliegt, ist Urteil, und ein Sensor bräuchte ein Pflichtfeld im Slice-Kopf, das die
vendorte Vorlage nicht trägt
([`ADR-0076`](../../docs/plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md)
Festlegung 7). Die Regel bindet den Schnitt und ist keine Hard Rule. Erreicht die Klasse ein viertes Mal
die Schwelle, ist der neue Grund oder die neue Möglichkeit der Trigger.
· seit slice-spec-5-entscheidungen-nach-dem-umbau

**Vor jedem neuen Slice-Plan das Beobachtungs-Register sichten**
(`docs/plan/planning/observations/README.md`; Sichtungs-Schritt, Modul 5) — für alles **unter** 3× der
einzige Leser. Berührt eine Sub-Area des Slice einen Eintrag `BEO-<KUERZEL>/<slug>/`, gehört dessen
Zähler-Stand (Zahl der Dateien unter `evidence/`) in das Kriterium *Evidenz-/Diskrepanz-Risiko* in §8;
erreicht er mit diesem Slice 3×, braucht er einen eigenen Folge-Slice. **Keine Treffer sind eine
Antwort** und werden in §8 notiert; trägt die Ablage nur ihre `README.md`, lautet sie genau das.
Gelesen wird der gemergte Stand.

**Eine Bedingung, die ein Geber-Artefakt an einen Lauf richtet, der noch nicht existiert, steht im
Slice-Plan dieses Laufs** — gemeint: ein Punkt unter *„Ausdrücklich NICHT"* mit Folge-Schnitt, ein
Risiko-Ausgang, eine Übergabe eines Review- oder Verifikations-Berichts, eine Folgepflicht einer ADR.
Der Geber wandert bei seiner Closure nach `done/`; der Plan ist das Artefakt, das der Lauf liest — die
Bedingung steht in §1 oder §3 des Plans, der sie trägt. Ein Folge-Schnitt ohne Datei ist keine Adresse
(`modul-05-planning-harness.md` §Ziel-Form: Slice, Klasse 1): hängt eine Bedingung an ihm, legt der
Planner beim Schließen des Gebers die Datei in `open/` an (`cp` aus dem Template) und trägt sie dort
ein. **Grenze:** Ein Wächter existiert nicht — die Zeile ist Feedforward. Tritt die Klasse nach dieser
Zeile erneut ein, ist die Trägerschaft der Befund; die nächste Stufe ist dann eine Hard Rule
(Architect, `AGENTS.md` §3.8). · seit slice-tap-nachzug-sync-schreibt-die-formel-ins-tap

5. Existiert ein Slice der Welle noch nicht, ihn per `cp` aus `slice.template.md` nach
   `docs/plan/planning/open/slice-<kennung>-<titel>.md` anlegen und füllen. Nie hand-authoren.

## Einen Slice stilllegen (`open/` oder `next/` → `done/`)

Gilt, wenn ein Slice seinen Gegenstand an einen anderen abgibt oder der Gegenstand entfällt, etwa bei
einer Gruppierung (`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt).
Die Kante führt an `in-progress/` vorbei. **Kein Wächter hält sie**
([`harness/sensors/slice-mv.md`](../../harness/sensors/slice-mv.md) §Grenze); die Prüfungen unten trägt
dieser Lauf, bis `slice-mv-kanten-nach-done-sind-bewacht` geschlossen ist.

- **Vorher, im Inhalts-Commit:** Liefer-Punkte der DoD bleiben leer; §7 trägt die Zeile `Gegenstand:`
  mit der Kennung des übernehmenden Slice oder dem Grund; jedes Risiko aus §6 trägt einen Ausgang (kein
  Modul prüft das; Adresse der Lücke: `slice-risiko-ausgang-hat-einen-sensor`).
- **Die genannte Kennung löst auf:** `ls docs/plan/planning/*/<kennung>.md` nennt genau eine Datei.
  **Das ist ein Urteil dieses Laufs, kein Sensor** — Setzung des Planners vom 2026-09-17, vom
  Auftraggeber am selben Tag bestätigt und dem Planner zugewiesen
  ([ADR-0028](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 2
  lässt die Zuständigkeit offen). Neu zu entscheiden, sobald der gepinnte d-check die Auflösung prüft
  oder in `done/` eine Kennung steht, die nicht auflöst.
- **Der Wechsel:** `make slice-mv SLICE=<kennung> TO=done`, **je Slice einzeln**. Danach, vor dem
  nächsten: (1) Exit 0; (2) der Move-Commit ist ein reiner Rename —
  `git show --numstat --format= -M <commit>` gibt `0 0` (Move-Commit ist `HEAD~1`, wenn das Werkzeug
  einen Nachzug-Commit meldet, sonst `HEAD`); (3) `make docs-check` ohne Befund. Fällt eine Prüfung,
  hält die Serie an.
- **Den Nachzug-Commit lesen:** Hat er in `docs/reviews/**` einen Tree-Operanden (`<sha>:<pfad>`)
  umgeschrieben, nimmst du diese Hunks per Gegen-Commit zurück (Register-Klasse
  `verweis-nachzug-bricht-tree-operand`).

## Welle-Plan anlegen und füllen

6. **`cp`** `welle.template.md` nach `docs/plan/planning/<welle-id>.md` (flach, kein Lifecycle-Ordner);
   `diff -q <template> <ziel>` belegt die Provenienz.
7. **In place füllen:** Hinweis-Block und Guidance-Kommentare entfernen, Platzhalter ersetzen; die
   `Lifecycle:`-Note der Vorlage bleibt (kein `Status:`-Feld); Zielmeilenstein, Verantwortlich, Datum
   setzen; die drei Pflichtteile aus Schritt 3 füllen, Kennungen als Anker-Links.

## Roadmap verdrahten und gaten

8. Roadmap fortschreiben: die Welle-Zeile **verlässt** die Vorschau *Nächste Wellen*, unter *Offene
   Wellen* erscheint der Zeiger auf die Plan-Datei. Datei, entfallende Vorschau-Zeile und Zeiger sind
   **ein** Commit, ein Vorgang
   ([ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) Festlegung 1).
   Die Welle-Verweise der Slices auf die neue Plan-Datei ziehen.
9. `make gates` **einmal am Ende**. Die Neuanlage ist Inhalt, **kein `git mv`** (flach **ist** der
   Zustand *eröffnet*); den `git mv` nach `done/` macht `/close-welle`.

Eine Welle endet durch Closure-Kriterien, nicht durch ein Datum. Keine Erfolgsmeldung ohne
Command-Ausgabe.
