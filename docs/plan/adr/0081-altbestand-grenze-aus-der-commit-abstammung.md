# ADR-0081: Die Grenze des Altbestand-Laufs ist die jüngste Welle-Closure in der Commit-Abstammung — später geschlossene Slices bleiben liegen

**Status:** Proposed

**Datum:** 2026-10-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (Träger der Archivierung),
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Altbestand, Schlüssel `altbestand`),
[ADR-0077](0077-wellenlose-slices-archivieren-bei-der-slice-closure.md) (Slice-Closure-Archiv),
[ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (Accept-Beleg)

**Supersedes (teilweise):** [ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md)
Festlegung 3 — allein die Grenze *„jeder wellenlos geschlossene Slice, der zum Zeitpunkt des Laufs
flach in `done/` liegt"*, und allein dort, wo eine Welle-Closure dem Lauf vorausgeht. Festlegungen
1, 2, 4 und 5 bleiben; ohne Welle-Closure gilt Festlegung 3 unverändert.

**Schärft:** `—` — Prozess-Entscheidung ohne Spec-Stratum; sie bindet das Verhalten des
Unterkommandos `archive-welle` und damit Dogfood **und** emittiertes Ziel, die dasselbe Binär
fahren.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Die Grenze, die Schritt 4 setzt, lautet am adoptierten Stand `v6.16.0`
(`modul-06-roadmap.md` §Wellen-Closure-Prozedur): *„die wellenlosen, die seit der letzten Closure
geschlossen wurden"*, und: *„Diese Auswahl gehört in die Operation, nicht in ihren Aufrufer."*

```sh
grep -n 'der letzten Closure geschlossen\|in die Operation, nicht in ihren' \
  .harness/baseline/v6.16.0/regelwerk/modul-06-roadmap.md      # 313, 314
```

Das Werkzeug bestimmt die Klasse eines Slice allein am Kopf-Feld `Welle:` (`einordnen` in
`internal/archive/collect.go`) und die Grenze allein an der Existenz eines `done/*/archiv.zip`
(`untergrenze`, ebenda); für den Schlüssel `altbestand` ist die Sperre `[untergrenze]` aufgehoben
(`sperren` in `internal/archive/vorschau.go`). Folge, gemeldet von einem Adopter auf `v0.2.8`: In
einem Ziel mit geschlossener, aber unarchivierter Welle nimmt `archive-welle altbestand` auch die
Slices mit, die **nach** dieser Closure geschlossen wurden. Die gehören zur nächsten Welle-Closure.

ADR-0041 Festlegung 3 verwirft eine git-Rekonstruktion mit zwei Gründen, die beide nur unter einer
Annahme tragen: (a) *die Add-Zeit wandert mit dem Move* — die Grenze wird aber **vor** dem Move
berechnet, aus dem Stand, den der Lauf vorfindet; (b) *die Slices hatten keinen anderen
Adressaten* — das galt für dieses Repo zum Zeitpunkt jener Entscheidung; in einem Ziel mit
geschlossener, unarchivierter Welle ist der Adressat die nächste Welle-Closure. ADR-0041 band sich
an *„dieses Repo"*; der Träger aber läuft in jedem Ziel.

## Entscheidung

Wir wählen **die Grenze aus der Commit-Abstammung, berechnet vor dem Move.** Vier Festlegungen.

**1. Die Grenze ist die Menge der Commits, die eine `done/welle-*-results.md` hinzufügten.** Je
Ergebnisnotiz zählt der Commit, der ihren Pfad unter `done/` hinzufügte; in linearer Historie ist
die Grenze damit der jüngste davon.

**2. Ein wellenloser Slice gehört zum Altbestand, wenn der Commit, der ihn nach `done/` brachte —
der jüngste, der seinen Pfad dort hinzufügte —, Vorfahr oder gleich mindestens einem
Grenz-Commit ist** (`git merge-base --is-ancestor`). Später geschlossene bleiben flach liegen;
`--vorschau` zählt sie in einer eigenen Zeile *„bleibt liegen (nach der Grenze)"*. Liegt keine
Ergebnisnotiz in `done/`, gibt es keinen Schnitt, und der Lauf verhält sich wie bisher.

**3. Unauflösbare Historie sperrt fail-closed.** Ein flacher Klon, eine Ergebnisnotiz oder ein
eingesammelter Slice ohne auffindbaren Add-Commit ergibt eine Sperre mit eigener Kennung; der
schreibende Lauf bricht ab, die Vorschau nennt sie.

**4. `git` läuft im Aufrufer, die Auswahl in der Operation.** `cmd/ai-harness-init/archive_welle.go`
liest die Commits und die Abstammung und reicht sie als Werte herein (dieselbe Aufteilung wie bei
`git status --porcelain` und `git ls-files`); `internal/archive` entscheidet die Klasse. Der
Aufrufer wählt keine Slices aus — so bleibt Schritt 4 *„in der Operation"*.

**Grenze dieser Entscheidung.** Sie betrifft nur den Schlüssel `altbestand`. Die Welle-Läufe
behalten ihre `[untergrenze]`-Sperre; ein Datums-Vergleich findet nirgends statt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (ADR-0041 F3 bleibt) | kein Code | Altbestand entzieht der nächsten Welle-Closure ihre wellenlosen Slices; der Adopter-Befund bleibt |
| B — Option, Slices namentlich auszunehmen | klein, keine git-Lesung | widerspricht `v6.16.0` Schritt 4 (*„gehört in die Operation, nicht in ihren Aufrufer"*); Fehlerquelle je Lauf |
| C — Datums-Schnitt (Commit-Datum der Ergebnisnotiz) | einfach zu lesen | Datum ist bei Rebase/Cherry-Pick und parallelen Zweigen nicht ordnend; dieselbe zweite Grenz-Definition, die ADR-0041 F3 zu Recht verwarf |
| **D — Abstammung, vor dem Move (gewählt)** | ordnet nach dem, was die Closure tatsächlich gesehen hat; robust gegen Datums-Drift; ohne Ergebnisnotiz verhaltensgleich | braucht vollständige Historie (flacher Klon sperrt); zwei git-Lesungen mehr im Aufrufer |

## Konsequenzen

- Positiv: Der Altbestand-Lauf nimmt nur, was vor der letzten Welle-Closure geschlossen wurde; die
  nächste Welle-Closure behält ihre wellenlosen Slices. Dogfood und Ziel verhalten sich gleich.
- Negativ: Ein CI- oder Teil-Klon mit `--depth` kann den Lauf nicht fahren und muss die Historie
  vertiefen. In diesem Repo bleiben die nach der jüngsten Welle-Closure wellenlos geschlossenen
  Slices beim Altbestand-Lauf flach — Adressat ist die nächste Welle-Closure oder, für neu
  geschlossene, das Slice-Closure-Archiv aus ADR-0077.
- Folgepflicht (Planner schneidet den Slice): Code in `internal/archive` und
  `cmd/ai-harness-init/archive_welle.go`; Texte in
  `internal/emit/templates/commands/close-welle.md`,
  `internal/emit/templates/enforce/archivierung.mk` und
  [`docs/user/benutzerhandbuch.md`](../../user/benutzerhandbuch.md) (Zeile `make archive-welle`);
  bei `Accepted` die Index-Zeile von ADR-0041 mit dem Teil-Supersede.
- Akzeptiertes Negativ: Die Fitness-Zeile von ADR-0041 zu Festlegung 3 bleibt als eingefrorener
  Text stehen; sie beschreibt den Fall ohne Ergebnisnotiz weiterhin richtig.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `full-smoke`-Stufe der Archivierung im Ziel | Ziel mit geschlossener Welle (Ergebnisnotiz committet), danach ein wellenlos geschlossener Slice: `make archive-welle WELLE=altbestand` lässt ihn flach liegen, ein vorher geschlossener landet in `altbestand/archiv.zip`. Rot: den Abstammungs-Schnitt im Aufrufer überspringen ⇒ der späte Slice wandert ins Archiv | `make full-smoke` |
| Go-Test in `internal/archive` | Einordnung über injizierte Abstammungs-Werte: vor/gleich Grenze ⇒ Altbestand, danach ⇒ liegen; fehlender Add-Commit ⇒ Sperre. Rot: Vergleich umkehren | `make test` |

## Re-Evaluierungs-Trigger

1. Eine Kurs-Fassung definiert *„seit der letzten Closure"* selbst (Feld, Marke oder Verfahren).
2. Ein Adopter meldet, dass sein Workflow die Add-Commits nicht erhält (Squash der ganzen Historie,
   dauerhaft flache Klone) — dann ist ein Artefakt-Träger der Grenze neu zu wägen.
3. Der Altbestand-Lauf entfällt, weil jedes Ziel ab Bootstrap per Slice-Closure archiviert.

### Der Acceptance-Trigger

`Accepted`, wenn eine Reviewer-Runde die Datei gegen ADR-0041, ADR-0033 und die zitierte Stelle
von `v6.16.0` ohne blockierenden Befund geprüft hat; die Accept-Zeile nennt den Report als Kennung
(ADR-0040 Festlegung 1).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-07 | Proposed | Adopter-CR zu `v0.2.8` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-NNNN` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
