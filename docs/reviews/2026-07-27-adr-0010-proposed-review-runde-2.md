# Review-Report: ADR-0010 (Proposed, Runde 2) — 2026-07-27

**Review-Art:** **Design** — zweite Proposed-Runde. Prüfgegenstand ist **nicht** die ganze ADR
erneut, sondern **(a)** ob Runde 1 aufgelöst ist und **(b)** ob der Fix **neue** Probleme
eingeführt hat. Die Präzedenz ist ausdrücklich: bei ADR-0007 fing genau die zweite Runde eine
Regression, die der Fix selbst eingebaut hatte.

**Gegenstand:** [ADR-0010](../plan/adr/0010-hexagonal-arch-realisierung.md), Fassung Runde 2
(weiter *Proposed*).

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Eingangs-Kontext:** die überarbeitete ADR · Runde 1 (`2026-07-27-adr-0010-proposed-review.md`) ·
die `.a-check.yml` beider Referenz-Repos · unsere heutige hexslice-Config in
`internal/gen/golang.go` · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

---

## Findings

### N-1 — Der Fix öffnet einen ungedeckten Bereich unterhalb von `driving/`

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate über einer stillen Teilmenge)
- `pfad`: ADR §Entscheidung, Festlegung 1 (Tabelle + `composition_root`)
- `befund`: Die neue Fassung deckt genau **zwei** Pfade unterhalb von `internal/adapter/`:
  `driven/**` als Schicht `adapters`, `driving/cli/**` als Composition Root. Alles andere unter
  `driving/` — etwa ein späterer `driving/http/**` — fällt unter **keinen** Glob: weder Schicht
  noch Ausnahme. Solche Dateien sind für das Arch-Gate **unsichtbar**; ein Richtungs-Verstoß dort
  bleibt still.

  Das ist genau die Klasse, die Runde 1 an den Referenzen **vermutet und widerlegt** hat (F-3) —
  der Fix führt sie nun in unsere eigene emittierte Config ein. Gegenprobe an `hexslice`: dort
  deckt ein einziger Glob `internal/adapters/**` beide Richtungen (inbound und outbound) ab, die
  Lücke existiert dort **nicht**.
- `verifizierbar`: ja — die Globs der Festlegung gegen einen gedachten Pfad
  `internal/adapter/driving/http/x.go`; `grep -A2 "  adapters:" internal/gen/golang.go` für die
  hexslice-Gegenprobe.
- **Konsequenz:** die ADR muss den Bereich schließen — drei gangbare Wege mit verschiedenem
  Strenge-Grad: **(a)** `composition_root` auf `internal/adapter/driving/**` erweitern (einfach,
  befreit aber die ganze treibende Seite), **(b)** `driving/**` als **eigene Schicht** mit Kante
  `driving→ports` führen (strenger als beide Referenzen, näher an `hexslice`), **(c)** bei
  `driving/cli/**` bleiben **und** im Config-Kommentar sagen, dass weitere treibende Adapter vom
  Adopter einzutragen sind. Ohne Festlegung bleibt es ein stilles Loch.

### N-2 — Die Asymmetrie ist benannt, aber ohne Folgepflicht

- `kategorie`: LOW
- `quelle`: ADR §Konsequenzen (neuer Absatz „Preis der Familien-Treue")
- `pfad`: ADR §Konsequenzen
- `befund`: Der neue Absatz sagt korrekt, dass `hexagonal` die treibende Seite **schwächer** prüft
  als `hexslice`, und dass das „in die Nutzer-Doku gehört". Es gibt dafür aber **keine
  Folgepflicht** — die Liste führt vier, die Doku-Asymmetrie ist keine davon. Damit hängt sie an
  gutem Willen; das ist die Klasse, gegen die dieses Repo `comment-claims` gebaut hat.
- `verifizierbar`: ja — die Folgepflicht-Liste enthält sie nicht.

### N-3 — Runde 1 ist im Übrigen aufgelöst

- `kategorie`: INFO
- `befund`: **F-1** (treibende Seite) ist ergänzt, samt Offenlegung, dass die Familie hier
  uneinheitlich ist, und mit begründeter Wahl (`driving/cli`, weil *driving*/*driven* das Vokabular
  durchhält; `internal/cli` verworfen). **F-2** (`composition_root` zu eng) ist angeglichen — die
  Zeile entspricht jetzt exakt der des zweiten Referenz-Repos. **F-4** (Trigger ohne Sensor) ist
  ehrlich eingeordnet statt entfernt. **F-5** ist als Folgepflicht 4 aufgenommen. Die Geschichte
  führt Runde 2 mit Verweis auf den Review.
- `verifizierbar`: ja — Abschnitts-Vergleich beider Fassungen.

## Negativbefunde

- geprüft, ohne Befund: **keine Regression an Festlegung 2** — die Trennung der Layouts ist unberührt; die neue Tabelle fügt nur Zeilen hinzu.
- geprüft, ohne Befund: **die Aussage über `hexslice` stimmt** — dort ist der Inbound-Adapter eine echte Schicht (`internal/adapters/**`, Kante `adapters→app`); die beschriebene Asymmetrie ist real, nicht konstruiert.
- geprüft, ohne Befund: **beide Referenzen exempten die treibende CLI wirklich** — die eine über `internal/cli/**`, die andere über `internal/adapter/driving/cli/**`; die ADR gibt das korrekt wieder.
- geprüft, ohne Befund: **Status weiterhin *Proposed*** ([`AGENTS.md`](../../AGENTS.md) §3.4) — nichts vorzeitig eingefroren; die Geschichte dokumentiert die Überarbeitung, statt sie zu überschreiben.
- geprüft, ohne Befund: **`make docs-check`** — 221 Dateien / 0 Befunde nach der Überarbeitung.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

## Verdikt

**Merge-blockierend:** **ja**, aber knapp — N-1 ist MEDIUM und betrifft eine **still ungeprüfte
Fläche** in dem, was wir emittieren würden. Der Fix aus Runde 1 hat sie eingeführt: er hat die
treibende Seite benannt, aber nur ihren `cli`-Zweig abgedeckt.

**Das ist der erwartete Ertrag einer zweiten Runde** — dieselbe Mechanik wie bei ADR-0007, wo
Runde 2 die vom Fix eingebaute Regression fing. Der Befund ist billig zu schließen: er verlangt
eine Entscheidung zwischen drei benannten Strenge-Graden, keinen Umbau.

**Empfehlung:** N-1 entscheiden und in Festlegung 1 aufnehmen, N-2 als Folgepflicht 5 ergänzen —
danach ist die ADR aus Review-Sicht **akzeptierbar**; eine dritte Runde wäre nur bei einer erneut
substanziellen Änderung nötig.

**Übergabe:** an die Architektur-Rolle. Nichts wird akzeptiert, solange N-1 offen ist.
