# Review-Report: ADR-0010 (Proposed) — 2026-07-27

**Review-Art:** **Design** — geprüft wird der Lösungs-Schnitt gegen die Architektur, **bevor** die
Entscheidung eingefroren wird (Modul 10 §Drei Review-Arten). Kein Diff, keine DoD; Eingabe ist die
ADR im Status *Proposed*. Präzedenz: die Proposed-first-Runden zu ADR-0006/0007/0008/0009 — bei
0007 fing die erste Runde einen substanziellen Fehler, die zweite eine vom Fix selbst eingeführte
Regression.

**Gegenstand:** [ADR-0010](../plan/adr/0010-hexagonal-arch-realisierung.md) „Hexagonal als zweite
Layout-Realisierung der Architektur-Achse", Commit `769a3f1`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Eingangs-Kontext:**

- Die ADR im Status *Proposed* samt Index-Eintrag
- [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nach CR 0.17.0, [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- Aktive ADRs: [ADR-0008](../plan/adr/0008-arch-achse-emittiertes-skelett.md), [ADR-0009](../plan/adr/0009-hexslice-arch-realisierung.md)
- **Die Belege der ADR selbst, nachgemessen:** das `--print-config`-Gerüst des gepinnten Arch-Gates und die `.a-check.yml` **plus Verzeichnisbäume** der beiden Referenz-Repos
- Plan-Review zu slice-058 (`2026-07-27`), der diese ADR verlangt hat

---

## Findings

### F-1 — Die treibende Seite fehlt in der Festlegung

- `kategorie`: **HIGH**
- `quelle`: [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (das Skelett muss lauffähig sein) · ADR §Entscheidung, Festlegung 1
- `pfad`: `docs/plan/adr/0010-hexagonal-arch-realisierung.md` §Entscheidung
- `befund`: Festlegung 1 nennt drei Verzeichnisse — `hexagon/core`, `hexagon/port`,
  `adapter/driven` — und Composition Root `cmd/**`. Das ist die **getriebene** Seite. Ein
  lauffähiges Skelett braucht aber auch eine **treibende**: irgendetwas muss den Kern aufrufen.
  Unser `hexslice`-Skelett emittiert dafür `adapters/inbound`. Die ADR schweigt dazu — der
  Renderer hätte keine Vorgabe, und die Lücke fiele erst beim Bauen auf.

  Nachgemessen an beiden Referenzen: **beide haben eine treibende Seite, an verschiedenen
  Orten, und behandeln sie beide als Composition Root** —

  | Repo | Verzeichnisse | `composition_root` |
  |---|---|---|
  | erstes Referenz-Repo | `internal/adapter/driven`, `internal/cli` | `cmd/**`, `internal/cli/**` |
  | zweites Referenz-Repo | `internal/adapter/{driven,driving}` | `cmd/**`, `internal/adapter/driving/cli/**` |

  Die „gelebte Konvention", auf die sich Festlegung 1 beruft, ist an genau dieser Stelle **nicht
  einheitlich**. Die ADR muss wählen (und die Wahl begründen), statt die Uneinheitlichkeit zu
  verschweigen.
- `verifizierbar`: ja — Verzeichnisbäume und `composition_root`-Zeilen beider Referenz-Repos.
- **Konsequenz:** Festlegung 1 ergänzen: welches treibende Verzeichnis emittiert wird und dass es
  **Composition Root** ist (nicht Adapter-Schicht) — oder ausdrücklich ausklammern, mit Angabe,
  woher der Einstiegspunkt sonst kommt. **Blockierend**, weil der Renderer sonst raten müsste.

### F-2 — `composition_root: cmd/**` ist enger als beide Referenzen

- `kategorie`: MEDIUM
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate, das falsch rot färbt, ist so schädlich wie eines, das falsch grün bleibt)
- `pfad`: ADR §Entscheidung, Festlegung 1
- `befund`: Die ADR legt `cmd/**` als Composition Root fest. Beide Referenzen führen **zusätzlich**
  einen CLI-Pfad (`internal/cli/**` bzw. `internal/adapter/driving/cli/**`). Emittieren wir nur
  `cmd/**` und der Adopter folgt der Familien-Konvention — die die ADR ihm ja empfiehlt —, dann
  fällt sein CLI-Code unter **keine** Ausnahme und das Gate meldet Richtungs-Verstöße, die keine
  sind. `.a-check.yml` ist skip-if-present, er kann es reparieren; merken muss er es aber erst.
- `verifizierbar`: ja — beide `composition_root`-Zeilen.
- **Konsequenz:** die Festlegung an die Referenz angleichen oder die Verengung begründen.

### F-3 — REFUTED: „das zweite Referenz-Repo lässt `driving` ungeprüft"

- `kategorie`: INFO (widerlegt, mit Beleg)
- `pfad`: —
- `befund`: Beim Prüfen von F-1 lag die Vermutung nahe, das zweite Referenz-Repo lasse
  `internal/adapter/driving/**` unter **keinem** Glob — also einen stillen, ungeprüften Bereich,
  den wir bei „gelebte Konvention übernehmen" mit erben würden. **Widerlegt:** die Zeile
  `composition_root: ["cmd/**", "internal/adapter/driving/cli/**"]` deckt ihn ausdrücklich ab. Der
  Befund wird hier festgehalten, weil er sonst als Verdacht weiterlebt — REFUTED nur mit Beleg.
- `verifizierbar`: ja — `grep -n "driving" <repo>/.a-check.yml`.

### F-4 — Ein Re-Evaluierungs-Trigger, den kein Sensor feuern kann

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3 (eine Regel in nur einem Quadranten ist halb durchgesetzt) · Roadmap-Kandidat *Regeln ohne Feedback-Quadrant schließen*
- `pfad`: ADR §Re-Evaluierungs-Trigger
- `befund`: „Wenn ein Repo der Familie das Layout ändert" ist beobachtbar formuliert, aber
  **niemand beobachtet es**: die Referenz-Repos liegen außerhalb dieses Repos, kein Gate und kein
  Nachtlauf sieht sie. Der Trigger lebt rein im inferentiellen Quadranten. Das ist zulässig — aber
  es sollte dort stehen, statt den Eindruck einer Überwachung zu erwecken.
- `verifizierbar`: ja — kein Target referenziert die Referenz-Repos.

### F-5 — Die Abweichung vom Gerüst gehört in den emittierten Kommentar

- `kategorie`: INFO
- `quelle`: ADR §Konsequenzen („erklärungsbedürftig")
- `pfad`: künftige `.a-check.yml` des `hexagonal`-Layouts
- `befund`: Die ADR benennt die Abweichung vom `--print-config`-Gerüst als Konsequenz, ordnet sie
  aber keinem Ort zu. Der Adopter liest zuerst die emittierte Config — dort gehört ein Satz hin,
  warum die Pfade anders aussehen als im Gerüst. Sonst hält er es für einen Fehler des Werkzeugs.
- `verifizierbar`: nein — Doku-Urteil.

## Negativbefunde

- geprüft, ohne Befund: **Festlegung 2 trägt** — die Begründung „nicht sparsamer, sondern unbewachbar" ist am Code nachvollziehbar: die HexSlice-Regeln hängen an literalen Verzeichnis-Präfixen, ein gemeinsames Layout mit zwei Kanten-Mengen ließe sie inert werden.
- geprüft, ohne Befund: **Die Kante `adapters→core` ist belegt** — im ersten Referenz-Repo real geführt, im Gerüst nur auskommentiert; die ADR nennt beide Zustände korrekt.
- geprüft, ohne Befund: **Verhältnis zu ADR-0008/0009** — die ADR ergänzt, sie superseded nicht; ADR-0008 sieht mehrere Architekturen ausdrücklich vor, ADR-0009 bleibt für HexSlice unberührt. Der Index führt das so.
- geprüft, ohne Befund: **Die Annahme ist offen benannt und kippbar** („die gelebte Konvention ist die verlässlichere Referenz") — samt Trigger, der sie umwirft. Das ist die Form, die ADR-0007 etabliert hat.
- geprüft, ohne Befund: **Alternativen** — vier statt der geforderten drei, inklusive „gar nicht liefern"; Option B ist nicht am Aufwand, sondern an der Bewachbarkeit gescheitert (der stärkere Grund).
- geprüft, ohne Befund: **Folgepflicht 1 deckt den Plan-Review-HIGH** — die strukturelle Geschichtet-Erkennung steht als blockierende Folgepflicht drin, nicht als Nebensatz.
- geprüft, ohne Befund: **Fitness Functions sind Targets, keine Absichten** — jede Zeile nennt ein reales `make`-Ziel.
- geprüft, ohne Befund: **Immutabilität** ([`AGENTS.md`](../../AGENTS.md) §3.4) — Status ist *Proposed*, die Geschichte führt nur die Proposed-Zeile; nichts ist vorzeitig eingefroren.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 2 |

## Verdikt

**Merge-blockierend:** **ja** — F-1 ist HIGH. Die ADR beruft sich auf „die gelebte
Familien-Konvention", und genau an der treibenden Seite ist die Familie **nicht einheitlich**: die
beiden Referenzen lösen sie verschieden (`internal/cli` gegen `internal/adapter/driving/cli`), und
die ADR nennt keine von beiden. Ohne Ergänzung müsste der Renderer raten — und die Beweiskraft von
Festlegung 1 wäre für einen Teil ihres Gegenstands schwächer als behauptet.

**Empfehlung:** eine zweite Fassung mit ergänzter Festlegung 1 (treibende Seite: welches
Verzeichnis, und dass es Composition Root ist), angeglichenem `composition_root` (F-2) und der
Ehrlichkeitszeile zum Trigger (F-4). Danach **erneut Proposed-first prüfen**, bevor akzeptiert wird
— die Präzedenz aus ADR-0007 ist ausdrücklich, dass die zweite Runde die vom Fix eingeführten
Fehler fängt.

**Übergabe:** an die **Architektur-Rolle** (Rückkante Review → ADR-Entwurf). Nichts wird
akzeptiert, solange F-1 offen ist.
