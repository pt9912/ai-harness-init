# Architect-Verdikt — `BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht` bei der Closure von `slice-ziel-traegt-keine-kennung-dieses-repos`

**Eingang:** Zug Planner → Architect → Planner nach
[ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md) Festlegung 1.
Der dritte Beleg kommt aus Risiko R4 des Slice (Ziele bis `v0.5.0` behalten unsere Kennungen in
der skip-if-present angelegten `.d-check.yml`). Gelesen: `observation.md`, `state.md`, die Belege
`slice-190` und `slice-194`, [ADR-0054](../plan/adr/0054-emittierter-commit-traeger-skip-if-present.md),
[ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md), Handbuch §Ein Repository erneut
aufsetzen, `docs/user/releasing.md` Schritt 5.
**Rolleninhaber:** Architect-Lauf vom 2026-10-09.

## 1. Verdikt: **verkörpert**, unter einer Bedingung der Reihenfolge

Die drei Belege sind drei Fälle einer Klasse: ein neuer Ort (`slice-190`), ein neuer Register-Ort
(`slice-194`) und ein geänderter Inhalt (`.d-check.yml`, hier). Die Klasse kehrt mit jeder Änderung
an einer skip-if-present-Emission wieder. Die Idempotenz-Klasse selbst bleibt richtig
(ADR-0054 §Verglichene Alternativen, Option B). Was fehlt, ist ein Vorgang, der dem Bestand sagt,
was sich geändert hat. Das `state.md` nennt ihn „Migrationspfad“.

Der billigste Träger, der real trägt, ist der **Release-Text**. Jeder Adopter, der ein neues Programm
holt, kommt an ihm vorbei. Seine Gliederung ist schon festgelegt (`releasing.md` Schritt 5: Stand,
Assets, Grenze), und die Regel braucht dort einen Abschnitt mehr. Ein Unterkommando oder eine
Laufzeit-Meldung wäre stärker, verlangt aber einen neuen Slice (§3).

**Zielort:** `docs/user/releasing.md`, Schritt 5, direkt nach dem Satz, der die Gliederung des
Release-Texts nennt (*„… am Ende die Zeile *Full Changelog*.“*). Prüfform der Anker-Paarung: Datei
ohne Suffix, der Anker steht irgendwo in ihr.
**Rolle:** kein Architect-Artefakt (weder [`AGENTS.md`](../../AGENTS.md) §3.8 noch
[ADR-0024](../plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md) noch
[ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) geben ihn mir). Ich
schreibe ihn darum nicht. Zielort und Text gehen als Übergabe an den Planner.
**Text** (einzufügen, Wortlaut verbindlich bis auf die Aufruf-Form, die der Schreibende am Handbuch
§Aufruf-Optionen misst):

> **Bestand.** Ändert das Release den Inhalt einer Datei, die der Lauf nur bei fehlender Datei
> schreibt (die zweite Klasse unter
> `[Ein Repository erneut aufsetzen](benutzerhandbuch.md#ein-repository-erneut-aufsetzen-idempotent)`),
> erreicht ein Re-Lauf ein schon aufgesetztes Repository damit nicht. Der Release-Text trägt dann
> den Abschnitt **Bestand** mit den betroffenen Pfaden, dem ältesten Tag, dessen Fassung abweicht,
> und der Abhilfe: die eigene Datei gegen eine frische Emission in ein leeres Verzeichnis
> vergleichen. Die Pfade liefert der Vergleich zweier frischer Emissionen mit denselben Optionen,
> eine mit dem Träger des Vorgänger-Tags und eine mit dem des neuen Tags
> (`diff -rq <alt> <neu>`), beschränkt auf die zweite Klasse. Ändert das Release keine solche
> Datei, entfällt der Abschnitt. Ein Sensor existiert nicht; Träger ist der Schnitt
> · seit slice-ziel-traegt-keine-kennung-dieses-repos.

**Bedingung der Reihenfolge.** `verkörpert` heißt *„die Regel steht“*. Der Text muss darum
**vor** dem Closure-Commit landen, in einem eigenen Commit der Rolle, die `releasing.md` schreibt.
Unterbleibt das, gibt es keinen gültigen Ausgang. `geplant` verlangt einen bestehenden Slice, und
es gibt keinen Release-Schnitt-Slice in `open/`, `next/` oder `in-progress/`
(`grep -lE 'Release-Schnitt|v0\.6\.0' docs/plan/planning/{open,next}/*.md` → leer). Der Eintrag
bliebe dann über der Schwelle `offen`, und `make register-ausgang` meldet ihn
(ADR-0085 Festlegung 3).

## 2. Trägt der Handbuch-Hinweis des Release-Schnitts den Ausgang?

**Nein, er deckt nur diesen einen Fall ab:** eine Datei, `.d-check.yml`, für die Tags `v0.1.0` bis
`v0.5.0`. Die beiden früheren Belege bekommen nichts von ihm, und der nächste Fall ebenso wenig.
Der Hinweis ist die **erste Anwendung** der Regel oben, nicht ihr Ersatz. Im Release-Text des
kommenden Release steht er als Abschnitt **Bestand**. Ob das Handbuch ihn zusätzlich führt,
entscheidet der Schnitt nach der Ist-Zustand-Regel des Handbuchs. Ein versionsgebundener Satz ist
dort Chronik. Version-frei trägt das Handbuch die Abhilfe schon: Löschen und Re-Lauf, §Ein
Repository erneut aufsetzen, *Hinweise*.

## 3. Ist ein mechanischer Sensor möglich?

**Ja, baubar, aber nicht gebaut. Für jetzt bleibt er ein akzeptiertes Negativ.**

- **Gegenstand:** ein Werkzeug-Ziel im Release-Vorgang, gebaut wie `tap-check`. Es fährt zwei
  frische Emissionen (Vorgänger-Träger aus dem gepinnten Release, neuer Träger) und vergleicht sie
  über den skip-if-present-Pfaden. Die Pfadmenge kommt aus der Klassifikation des Emitters, nicht aus
  einer Liste. Das Ziel fällt, wenn der Release-Text (`gh release view <tag> --json body`) einen
  abweichenden Pfad nicht nennt. Rot herstellbar ist es: eine Zeile in
  `internal/emit/templates/d-check.yml` ändern und den Release-Text ohne Bestand lassen.
  **Grenze:** braucht Netz an genau diesem Aufruf; sieht nur Emissionen mit den gewählten Optionen
  (Sprache, `--arch`).
- **Stärkere Variante, Produkt statt Prozess:** Der Re-Lauf meldet eine abweichende
  skip-if-present-Datei mit dem Pfad der mitgelieferten Fassung, so wie er es für Skills unter
  `.harness/skills/` schon tut (`internal/emit/templates.go`, `skillWriter`). Das erreicht den
  Bestand direkt. Bei `.d-check.yml` meldet es aber jede gewollte Anpassung des Adopters mit. Der
  Slice hat eine Laufzeit-Meldung bewusst ausgeschlossen.
- **Warum jetzt keiner:** Ein neuer Slice braucht die Freigabe des Auftraggebers, und die 4×-Regel
  (`modul-06` Schritt 3) greift noch nicht. **Re-Evaluierung:** wenn ein vierter Beleg eintrifft
  oder ein Release-Text den Abschnitt Bestand nachweislich vergisst. Dann schlägt dieses Verdikt den
  ersten Spiegelstrich als Slice vor.

## 4. `state.md`-Zeile für den Planner

Gilt erst, wenn der Text aus §1 auf `main` liegt:

> **Stand:** verkörpert — Regel *Bestand im Release-Text* in `docs/user/releasing.md` Schritt 5,
> Anker `· seit slice-ziel-traegt-keine-kennung-dieses-repos`. Grenze: kein Sensor; Träger ist der
> Release-Schnitt, der zwei frische Emissionen vergleicht (Verdikt
> `2026-10-09-slice-ziel-traegt-keine-kennung-dieses-repos-architect-verdikt`).

Der übrige Rumpf des `state.md` sagt dann zu viel: „den beschreibt keine Quelle“ stimmt nicht mehr.
Er wird durch die Grenze oben ersetzt.
