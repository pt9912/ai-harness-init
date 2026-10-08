# Welle welle-handbuch-zeigt-den-bestand: Das Handbuch zeigt den Bestand

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<Kennung>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** Planner. **Datum:** 2026-10-08.

---

## 1. Welle-Ziel

**Das Benutzerhandbuch nennt, was ein Bootstrap heute anlegt und was der Vertrag zusagt — den Baum
in §6 vollständig und gegen den Emitter gehalten, dazu die Fähigkeiten, die heute nur als Pfad oder
gar nicht vorkommen (Workflow-Commands, Skills, Pointer-Abschnitt der README, Erfassungsschicht); das
Formel-Skelett nennt seine eine Fassungs-Ausnahme.** Gegenstand ist der Vertrag aus
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), beschrieben am Ist-Zustand:
das Handbuch trägt keine Kennungen, keine Chronik und nichts Unimplementiertes.

## 2. Trigger (Welle startet)

- `welle-adopter-weg-im-ziel` liegt in `done/` — eingetreten
  ([Closure-Notiz](welle-adopter-weg-im-ziel-results.md)).

## 3. Closure-Trigger (Welle schließt)

- Alle vier Slices aus §4 liegen in `done/`.
- `make gates` **und** `make full-smoke` grün auf **demselben** Commit — das Mehr gegenüber den
  Slice-DoDs: `full-smoke` bootstrappt real, und erst dieser Bestand ist es, gegen den das Handbuch
  nach allen vier Slices zugleich stimmen muss.
- Closure-Notiz `welle-handbuch-zeigt-den-bestand-results.md` in `done/`.

## 4. Slices in dieser Welle

| Slice | Titel | Bezug |
|---|---|---|
| [slice-formel-skelett-nennt-die-fassungs-ausnahme](slice-formel-skelett-nennt-die-fassungs-ausnahme.md) | Das Formel-Skelett nennt die eine Fassungs-Ausnahme | [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md), [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) |
| [slice-195](slice-195-handbuch-nennt-die-zugesagten-faehigkeiten.md) | Das Handbuch nennt die zugesagten Fähigkeiten | [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-05`](../../../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2) |
| [slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md) | Das Handbuch zeigt den Bestand, den der Bootstrap anlegt | [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| [slice-111](slice-111-was-ein-bootstrap-anlegt-steht-in-der-nutzerdoku.md) | Was ein Bootstrap anlegt, steht in der Nutzer-Doku | [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

**Reihenfolge** (die Tabelle nennt sie): zuerst das Formel-Skelett — ein Satz, von der offenen
Frage zu 111/191 unabhängig; dann 195, das den Baum nicht anfasst; dann 191, das die Form von §6
entscheidet und hält; zuletzt 111, dessen Rest an dem Baum zu messen ist, den 191 hinterlässt.
111 und 191 laufen nicht parallel.

## 5. Abhängigkeiten

- Blockiert: keine Welle.
- Wird blockiert von: keiner — der Start-Trigger ist eingetreten. Innerhalb der Welle: 111 nach 191
  (§4); ob die beiden zu einem Slice zusammengehen, entscheidet der Auftraggeber.

## 6. Out-of-Scope für diese Welle

- **Der Generator.** Kein emittiertes Byte ändert sich; einzige Ausnahme ist der Wächter aus
  slice-191 DoD (2), ein Test über dem Emitter. — Schicht-Abgrenzung.
- **`spec/`.** Die Soll/Ist-Deltas (Sprachenliste, `CLAUDE.md` im Zielbild) beschreibt das Handbuch
  nicht, weder als vorhanden noch als geplant. — anderer Vorgang.
- **Veröffentlichte Release-Texte und Assets.** Kein Gate erreicht sie; der nächste Release-Schnitt
  trägt die Quellen hinein. — anderer Vorgang.
- **Die Zusammenlegung von 111 und 191** ohne Freigabe des Auftraggebers. — offene Entscheidung.

## 7. Closure-Notiz

Ergebnis: `welle-handbuch-zeigt-den-bestand-results.md`, Geschwister im Ruheort `done/` (geschrieben bei
der Closure).
Zähler: das Beobachtungs-Register, eine Ebene über dem Ruheort.
