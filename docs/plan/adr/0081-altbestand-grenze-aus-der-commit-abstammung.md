# ADR-0081: Die Grenze der Archiv-Läufe ist die Welle-Closure in der Commit-Abstammung — später geschlossene Slices bleiben liegen

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
flach in `done/` liegt"*, und allein dort, wo eine Ergebnisnotiz in `done/` liegt; ohne sie gilt
Festlegung 3 unverändert. **Und** Festlegung 5 — allein die Lesart, ein Welle-Lauf sammle jeden
flachen wellenlosen Slice ein; *„seither"* ist die Abstammungs-Spanne aus Festlegung 3 unten. Ihre
Untergrenze (das Sammel-Archiv) bleibt. Festlegungen 1, 2 und 4 bleiben; ADR-0041 bleibt
byte-gleich.

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
(`untergrenzeSperre` in `internal/archive/vorschau.go`); für den Schlüssel `altbestand` ist diese
Sperre aufgehoben (`sperren`, ebenda). Folge, gemeldet von einem Adopter auf `v0.2.8`: In einem
Ziel mit geschlossener, aber unarchivierter Welle nimmt `archive-welle altbestand` auch die Slices
mit, die **nach** dieser Closure geschlossen wurden — und ein danach gefahrener Welle-Lauf nimmt
sie ebenso, weil das Sammel-Archiv seine Untergrenzen-Sperre erfüllt.

ADR-0041 Festlegung 3 verwirft eine git-Rekonstruktion mit zwei Gründen, die beide nur unter einer
Annahme tragen: (a) *die Add-Zeit wandert mit dem Move* — die Grenze wird aber **vor** dem Move
berechnet, aus dem Stand, den der Lauf vorfindet; (b) *die Slices hatten keinen anderen
Adressaten* — das galt für dieses Repo zum Zeitpunkt jener Entscheidung; in einem Ziel mit
geschlossener, unarchivierter Welle ist der Adressat die nächste Welle-Closure. ADR-0041 band sich
an *„dieses Repo"*; der Träger aber läuft in jedem Ziel.

## Entscheidung

Wir wählen **die Grenze aus der Commit-Abstammung, berechnet vor dem Move.** Fünf Festlegungen.
*S ≤ G* heißt im Folgenden: S ist Vorfahr von G oder gleich G
(`git merge-base --is-ancestor S G`).

**1. Der Add-Commit eines Pfads ist der jüngste Commit, der ihn hinzufügte:**
`git log -1 --no-renames --diff-filter=A --format=%H -- <pfad>`, je Pfad einzeln. Ein `git mv`
nach `done/` zählt damit als Hinzufügen (gemessen: mit und ohne `--no-renames` liefert die
Einzelpfad-Abfrage den Move-Commit; `--no-renames` legt die Form unabhängig von der
Rename-Erkennung fest). Grenz-Commits sind die Add-Commits aller `done/welle-*-results.md`.

**2. Altbestand-Lauf:** Ein flacher wellenloser Slice mit Add-Commit S gehört zum Altbestand, wenn
S ≤ G für mindestens einen Grenz-Commit G. Später geschlossene bleiben liegen; `--vorschau` zählt
sie in einer eigenen Zeile *„bleibt liegen (nach der Grenze)"*. Gibt es keinen Grenz-Commit,
verhält sich der Lauf wie bisher.

**3. Welle-Lauf `welle-N`:** Sei O der Add-Commit von `done/welle-N-results.md`. Ein flacher
wellenloser Slice mit Add-Commit S gehört zu `welle-N`, wenn S ≤ O **und** kein anderer
Grenz-Commit G mit S ≤ G echter Vorfahr von O ist — er gehört also der **frühesten** Closure in
seiner Abstammung, nicht einer späteren. Was nicht dazugehört, bleibt flach liegen und wird in der
Vorschau mit derselben Zeile gezählt. Folgen: Ein nach O geschlossener Slice geht nie in
`welle-N`; liegt eine ältere Closure unarchiviert dazwischen, behält sie ihre Slices. Bei
**parallelen** Closures (zwei Grenz-Commits, keiner Vorfahr des anderen, beide mit S ≤ G) gehört S
beiden Läufen; der zuerst gefahrene nimmt ihn, danach liegt er nicht mehr flach. Die
`[untergrenze]`-Sperre bleibt unverändert: Sie hält den Welle-Lauf an, bis das Sammel-Archiv die
Slices vor jeder Grenze aufgenommen hat.

**4. Unauflösbare Historie sperrt fail-closed.** Zwei Bedingungen, je eine Sperre mit eigener
Kennung: (a) `git rev-parse --is-shallow-repository` liefert `true` — im flachen Klon erscheint
der Graft-Commit als Add-Commit jeder Datei, ein fehlender Add-Commit fällt dort also nicht auf;
(b) eine Ergebnisnotiz oder ein eingesammelter Slice hat keinen Add-Commit. Der schreibende Lauf
bricht ab, die Vorschau nennt die Sperre. Beide gelten nur, wo ein Grenz-Commit gebraucht wird
(eine Ergebnisnotiz liegt in `done/`).

**5. `git` läuft im Aufrufer, die Auswahl in der Operation.** `cmd/ai-harness-init/archive_welle.go`
liest Shallow-Status, Add-Commits und Abstammung und reicht sie als Werte herein (dieselbe
Aufteilung wie bei `git status --porcelain` und `git ls-files`); `internal/archive` entscheidet die
Klasse. Der Aufrufer wählt keine Slices aus — so bleibt Schritt 4 *„in der Operation"*. Ein
Datums-Vergleich findet nirgends statt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (ADR-0041 F3/F5 bleiben) | kein Code | Altbestand und nachgeholter Welle-Lauf ziehen Slices, die nach der Closure geschlossen wurden; der Adopter-Befund bleibt |
| B — Option, Slices namentlich auszunehmen | klein, keine git-Lesung | widerspricht `v6.16.0` Schritt 4 (*„gehört in die Operation, nicht in ihren Aufrufer"*); Fehlerquelle je Lauf |
| C — Datums-Schnitt (Commit-Datum der Ergebnisnotiz) | einfach zu lesen | Datum ist bei Rebase/Cherry-Pick und parallelen Zweigen nicht ordnend; dieselbe zweite Grenz-Definition, die ADR-0041 F3 zu Recht verwarf |
| D′ — Abstammung nur für `altbestand` | kleinerer Code-Pfad | verschiebt den Befund in den nächsten Welle-Lauf, statt ihn zu beheben |
| **D — Abstammung für beide Läufe, vor dem Move (gewählt)** | ordnet nach dem, was die Closure tatsächlich gesehen hat; robust gegen Datums-Drift; ohne Ergebnisnotiz verhaltensgleich | braucht vollständige Historie (flacher Klon sperrt); git-Lesungen je Pfad im Aufrufer |

## Konsequenzen

- Positiv: Kein Archiv-Lauf nimmt einen Slice, der nach der zugehörigen Closure geschlossen wurde;
  die nächste Welle-Closure behält ihre wellenlosen Slices, auch nach einem Altbestand-Lauf.
  Dogfood und Ziel verhalten sich gleich.
- Negativ: Ein CI- oder Teil-Klon mit `--depth` kann den Lauf nicht fahren und muss die Historie
  vertiefen.
- Akzeptiertes Negativ: Der Altbestand-Lauf nimmt auch die wellenlosen Slices vor einer
  unarchivierten Closure, die Schritt 4 dieser Closure zuweist — das Sammel-Archiv ist nach
  ADR-0041 Festlegung 1 genau der Ort für alles vor der Untergrenze; der Welle-Lauf findet danach
  keine eigenen Wellenlosen mehr vor. Ebenso akzeptiert: Bei parallelen Closures entscheidet die
  Lauf-Reihenfolge, welche einen gemeinsamen Slice archiviert — beide Zuordnungen erfüllen
  *„seit der letzten Closure"*.
- Akzeptiertes Negativ: Die Fitness-Zeile von ADR-0041 zu Festlegung 3 bleibt als eingefrorener
  Text stehen; sie beschreibt den Fall ohne Ergebnisnotiz weiterhin richtig.
- Folgepflicht (Planner schneidet den Slice): Code in `internal/archive` und
  `cmd/ai-harness-init/archive_welle.go`; Texte in
  `internal/emit/templates/commands/close-welle.md`,
  `internal/emit/templates/enforce/archivierung.mk` und
  [`docs/user/benutzerhandbuch.md`](../../user/benutzerhandbuch.md) (Zeile `make archive-welle`);
  bei `Accepted` die Index-Zeile von ADR-0041 mit dem Teil-Supersede (Festlegungen 3 und 5).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `full-smoke`-Stufe der Archivierung im Ziel | Ziel mit geschlossener, unarchivierter `welle-1` (Ergebnisnotiz committet), ein wellenloser Slice davor, einer danach: `archive-welle altbestand` nimmt nur den frühen, ein anschließendes `archive-welle welle-1` lässt den späten flach liegen. Rot: den Abstammungs-Schnitt im Aufrufer überspringen ⇒ der späte Slice wandert in ein Archiv | `make full-smoke` |
| `full-smoke`, realer flacher Klon | dasselbe Ziel per `git clone --depth 1 file://…` geklont: `archive-welle altbestand` bricht mit der Shallow-Sperre ab, `done/` unverändert. Rot: die `--is-shallow-repository`-Prüfung entfernen ⇒ der Lauf archiviert still beide Slices | `make full-smoke` |
| Go-Test in `internal/archive` | Einordnung über eingespeiste Abstammungs-Werte, einschließlich früheste-Closure-Regel und paralleler Grenz-Commits. Rot: Vergleich umkehren. Deckt die Logik, nicht die git-Quelle — die tragen die zwei Zeilen darüber | `make test` |

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
