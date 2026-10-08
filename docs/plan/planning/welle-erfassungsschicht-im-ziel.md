# Welle welle-erfassungsschicht-im-ziel: Erfassungsschicht im Ziel — Feldliste, Ereignisse und Fassung vollständig

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<Kennung>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug — setzt den erreichten M6
([`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)) auf den Stand von
Lastenheft 0.25.1 fort.

**Verantwortlich:** Planner. **Datum:** 2026-10-08.

---

## 1. Welle-Ziel

**Die emittierte Erfassungsschicht trägt Feldliste, Ereignisse und Fassung so, wie Lastenheft 0.25.1
sie verlangt:** ein unbekannter Wert trägt die Kennzeichnung *nicht bekannt*, `[]` heißt *keiner*
([`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans),
[`LH-FA-15`](../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung)); jede Zeile nennt die Fassung
ihrer Erfassungsregel; die emittierte Feldliste nennt Verfügbarkeit und Aufbewahrung; Fingerabdruck
und Ende-Ereignis tragen je einen entschiedenen Ausgang
([`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang)).

## 2. Trigger (Welle startet)

- §7 Historie von `spec/lastenheft.md` trägt den Change Request zu
  [`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)/[`LH-FA-15`](../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung)
  — eingetreten: Zeilen 0.25.0 und 0.25.1 (`grep -c '^| 0\.25\.[01] ' spec/lastenheft.md`).

## 3. Closure-Trigger (Welle schließt)

- Alle fünf Slices aus §4 liegen in `done/` (geliefert oder mit `Gegenstand:` stillgelegt).
- `make gates` **und** `make full-smoke` grün auf **demselben** Commit — das *Mehr*: die DoDs belegen je
  ihren Ausschnitt, erst der gemeinsame E2E-Lauf belegt das Zusammenspiel von Kennzeichnung, Fassung
  und Feldliste im gebootstrappten Ziel.
- Closure-Notiz in `welle-erfassungsschicht-im-ziel-results.md`.

## 4. Slices in dieser Welle

Reihenfolge = Zeilenfolge; Begründung in §5. Erster Slice:
`slice-span-traegt-die-fassung-seiner-erfassungsregel`.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-span-traegt-die-fassung-seiner-erfassungsregel](done/slice-span-traegt-die-fassung-seiner-erfassungsregel.md) | Der Span trägt die Fassung seiner Erfassungsregel | [`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) |
| [slice-agent-role-traegt-nicht-bekannt](done/slice-agent-role-traegt-nicht-bekannt.md) | Ein unbekannter Wert trägt die Kennzeichnung *nicht bekannt* | [`LH-FA-15`](../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung), [`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) |
| [slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung](in-progress/slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung.md) | Die emittierte Feldliste trägt Verfügbarkeit und Aufbewahrung | [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`LH-FA-13`](../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) |
| [slice-107](next/slice-107-inhalts-hash-traegt-eine-entscheidung.md) | Der Inhalts-Hash bekommt seinen Ausgang | [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang) |
| [slice-205](next/slice-205-der-strom-traegt-die-zug-grenze.md) | `SubagentStop` — verdrahtet oder mit Grund entfallen | [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang), [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

## 5. Abhängigkeiten

- **Fassung vor Kennzeichnung:** Die Umstellung leerer Werte auf *nicht bekannt* ist selbst ein
  Bedeutungswechsel (`BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe`); mit der Fassung
  zuerst trägt er seine Fassungs-Angabe, statt nachgetragen zu werden.
- **Kennzeichnung vor Feldliste:** Die Feldliste liest die Spec-Zeilen `SPEC-043`/`SPEC-056`/`SPEC-087`
  in ihrer neuen Fassung; davor schriebe sie den alten Wortlaut ab.
- **`slice-205` zuletzt und bedingt:** Das Kriterium *Erfassungs-Umfang* von
  [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang) schließt das Ende
  eines Laufs aus; verdrahtet wird erst nach einem Change Request des Auftraggebers
  ([`MR-015`](../../../harness/conventions.md#mr-015)). Lehnt er ab, geht der Slice mit
  `Gegenstand: entfallen` nach `done/`.
- Blockiert: keine Welle. Wird blockiert von: keiner Welle.

## 6. Out-of-Scope für diese Welle

- **Kein Change Request durch die Welle.** Rang 1 ändert der Auftraggeber; die Welle setzt 0.25.1 um
  und meldet Konflikte (`slice-205`, Ausgang (b) von `slice-107`) als Übergabe.
- **Keine Migration des Span-Bestands** — gitignored, maschinenlokal, append-only; alte Zeilen bleiben
  ohne Fassung und ohne Kennzeichnung, die Lesevorschrift deckt sie.
- **Keine Auswertung über die Lesevorschrift hinaus** — Aufteilung des Sammelpostens und Berichtsgröße
  ([`LH-FA-17`](../../../spec/lastenheft.md#lh-fa-17--auswertung-der-erfassung)) sind nicht geschnitten.
- **Kein Wächter über die Aufrufform des Agenten-Werkzeugs** — benannte Grenze von
  [`LH-FA-15`](../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung).
- **Kein Wortlaut-Sensor Feldliste ↔ Spec** — `slice-feldabdeckung-existenz-sensor` bleibt in `open/`.

## 7. Closure-Notiz

Ergebnis: <Zeiger auf `welle-erfassungsschicht-im-ziel-results.md`, Geschwister im Ruheort `done/`>
Zähler: <Zeiger aufs Beobachtungs-Register, eine Ebene über dem Ruheort>
