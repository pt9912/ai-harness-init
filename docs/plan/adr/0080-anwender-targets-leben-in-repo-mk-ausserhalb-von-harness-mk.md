# ADR-0080: Die eigenen Targets des Anwenders leben in `repo.mk` an der Wurzel des Ziels — harness/mk/ gehört allein dem Werkzeug

**Status:** Proposed

**Datum:** 2026-10-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0007](0007-bootstrap-phasen.md) (Datei-Klassen konvergent / skip-if-present),
[ADR-0067](0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md),
[ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md) (adoptierter Stand `v6.16.0`)

**Supersedes (teilweise):** [ADR-0007](0007-bootstrap-phasen.md) §Entscheidung, Klassen-Tabelle,
Zeile der konvergenten Infrastruktur — allein der Einschub *„Adopter-`local.mk` unberührt"*, der
harness/mk/ als Adopter-Fläche führt. Die Klasse der Tool-Fragmente bleibt.

**Schärft:** — Die Entscheidung betrifft allein die **emittierte** Ebene; dieses Repo führt sein
`Makefile` von Hand und ist nicht berührt.

## Kontext

Ein gebootstrapptes Ziel hat keinen regelkonformen Ort für eigene `make`-Targets. Der emittierte
Aggregator `Makefile` ist konvergent und wird bei jedem Lauf neu geschrieben, auch eine
eingetragene `include`-Zeile (`Makefile()` in `internal/emit/makefile.go`). Eingebunden wird
allein `include harness/mk/*.mk`. Eine eigene Datei dort überlebt den Re-Lauf, und der Code nennt
sie als Adopter-Ort (`SelbstpruefungVorgabeOrt = "harness/mk/vorgaben.mk"` in
`internal/emit/selbstpruefung.go`). Der adoptierte Kurs ordnet das Verzeichnis aber dem Werkzeug zu:

```sh
grep -n 'harness/mk/  ' .harness/baseline/v6.16.0/regelwerk/grundlagen-harness-dateien.md
# 25:harness/mk/                 # Make-Fragmente von Werkzeugen; <werkzeug>.md = der
```

Einen Ort für Targets des Repos nennt der Kurs nicht. Er sagt nur, wo sie **dokumentiert**
werden: *„Die Targets des Repos stehen weiter hier"* (`harness/README.md` §Sensors,
`grundlagen-harness-dateien.md` §harness/README.md als Einstiegspunkt). Seine `Makefile`-Vorlage
ist eine Repo-Datei; in einem Ziel, dessen `Makefile` das Werkzeug schreibt, bleibt die Frage
offen:

```sh
grep -rniE 'local\.mk|Makefile\.local|repo\.mk' .harness/baseline/v6.16.0/ | wc -l
# 0
```

Die Entscheidung füllt diese Lücke und weicht nicht vom Kurs ab; ein Adaptions-Eintrag folgt nicht.

## Entscheidung

**1. Ort und Name: eine Datei `repo.mk` an der Wurzel des Ziels.** Der Name nennt den Eigentümer.
Damit gilt eine eindeutige Grenze: harness/mk/ (Fragmente samt `<werkzeug>.md`) und `Makefile`
gehören dem Werkzeug, `repo.mk` gehört dem Repo. Wer mehrere Dateien will, bindet sie aus
`repo.mk` ein; das Werkzeug kennt nur diesen Einstieg.

**2. Klasse skip-if-present, mit Startinhalt.** Der Bootstrap legt `repo.mk` an einem freien Pfad
einmal an (Kopfkommentar: Eigentum, Einhängen in `make gates` über `GATE_CHECKS += <target>`,
Dokumentationspflicht in `harness/README.md` §Sensors, keine Targets) und fasst sie danach nie
wieder an — dieselbe Klasse wie der übrige Adopter-Boden ([ADR-0007](0007-bootstrap-phasen.md)).
Der Startinhalt ist nötig, weil die Datei sonst nicht dauerhaft existiert: d-check `targets`
endet bei einem leeren Glob in `makefiles:` mit Exit 2 (Pin
`v0.82.0`; eine fehlende Einzeldatei ist nicht gemessen). Mit einer festen Datei braucht das emittierte `.d-check.yml` keinen Glob für den
Repo-Teil.

**3. Der Aggregator bindet sie optional ein,** mit `-include repo.mk` direkt nach
`include harness/mk/*.mk` und vor der Zeile `record-gates: $(GATE_CHECKS)`. Damit erweitert
`GATE_CHECKS +=` in `repo.mk` das Gate; Vorgaben in `repo.mk` überschreiben die `?=`-Vorgaben der
Fragmente. Eine gelöschte `repo.mk` bricht `make` nicht; der nächste Lauf legt sie neu an.

**4. Der Vorgabe-Ort der Selbstprüfung zieht mit.** `SelbstpruefungVorgabeOrt` und die Köpfe,
die ihn nennen, zeigen auf `repo.mk`. Bestehende Ziele mit eigenen Dateien in harness/mk/
laufen unverändert weiter (der Glob nimmt sie mit, ein Lauf löscht nie). Regelkonform ist dieser
Ort ab hier nicht mehr. **Akzeptiertes Negativ:** Kein Sensor meldet eine Repo-Datei in
harness/mk/; das Handbuch nennt den Ort. Die skip-if-present-Klasse von
harness/mk/.gitattributes ([ADR-0067](0067-emittierte-zeilenenden-ein-attribut-je-verzeichnis-mit-interpreter-konsument.md))
bleibt; sie ist ohne Adopter-Fläche harmlos, und eine Reklassifikation lohnt keinen eigenen Vorgang.

**5. Reihenfolge: eigener Vorgänger-Slice, nicht Teil des `targets`-Slice.** Der `targets`-Slice
trägt schon drei Liefer-Punkte; ein vierter bräche die Größenregel. Der Vorgänger schließt den
Handbuch-Befund unabhängig von den externen Antworten, auf die der `targets`-Slice wartet. Seine
Liefer-Punkte: (a) Aggregator-Zeile, Startinhalt und Vorgabe-Ort; (b) eine `full-smoke`-Stufe
(Fitness 1–2); (c) die Handbuch-Stelle nennt `repo.mk`. Der `targets`-Slice nimmt danach
`repo.mk` in `makefiles:` auf und misst Fitness 3.

## Verglichene Alternativen

| Option | Für | Gegen |
|---|---|---|
| **A — `repo.mk` an der Wurzel (gewählt)** | Grenze auf Datei-Ebene eindeutig; eine feste Datei, kein leerer Glob in `makefiles:`; Name nennt den Eigentümer | ein zusätzlicher Startinhalt |
| B — `local.mk` / `Makefile.local` | gängige Namen | beide lesen sich als maschinen-lokal und oft gitignoriert; Repo-Targets sind committet und gelten für alle |
| C — Verzeichnis `mk/*.mk` neben harness/mk/ | mehrere Dateien ohne Einbinden von Hand | leerer Glob ⇒ d-check Exit 2, also doch eine Platzhalter-Datei; zwei `mk`-Verzeichnisse verwechseln sich leicht; mehrere Dateien gehen über A ebenso |
| D — Bestand: eigene Fragmente in harness/mk/ | kein Code-Eingriff | widerspricht der Zuordnung im Kurs `v6.16.0`; Werkzeug- und Repo-Dateien sind im selben Verzeichnis nur am Namen unterscheidbar |
| E — `Makefile` skip-if-present (Repo besitzt den Aggregator, wie die Kurs-Vorlage) | ein Ort für alles | der Aggregator trägt die Ordnungskante `record-gates` und heilt Drift nur als konvergente Datei; ein Adopter-`Makefile` würde den Gate-Anschluss blockieren |

## Konsequenzen

- Positiv: Der Re-Lauf, den das Handbuch als sicheren Weg empfiehlt, verliert keine Repo-Targets mehr. Die Eigentumsgrenze folgt dem Kurs.
- Negativ: Bestehende Ziele mit Repo-Fragmenten in harness/mk/ bleiben dort, bis sie selbst umziehen (Festlegung 4).
- Bei `Accepted` bekommt die Index-Zeile von [ADR-0007](0007-bootstrap-phasen.md) den Teil-Revisions-Vermerk.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `full-smoke`-Stufe im Ziel | Eine vorab geschriebene `repo.mk` mit Target `eigen` ist nach dem Re-Lauf byte-gleich (`cmp`), und `make eigen` läuft. Rot: Klasse auf konvergent stellen | `make full-smoke` |
| dieselbe Stufe | Ohne `repo.mk` läuft `make gates` grün, und der Lauf legt den Startinhalt an. Rot: `-include` → `include` und Datei löschen | `make full-smoke` |
| d-check `targets` im Ziel (Teil des `targets`-Slice) | Ein Target in `repo.mk` ohne Zeile in `harness/README.md` ⇒ `gate-undocumented`. Rot: `repo.mk` aus `makefiles:` streichen ⇒ das Gegenbeispiel bleibt grün | `make full-smoke` |

## Re-Evaluierungs-Trigger

1. Eine Kurs-Fassung nennt einen Ort für die Make-Targets des Repos.
2. Der Aggregator wird skip-if-present oder fällt weg.
3. d-check `targets` akzeptiert einen leeren Glob ohne Exit 2; dann ist Option C ohne Startinhalt neu zu wägen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-07 | Proposed | Review-Befund F-1 zum Handbuch-Ist-Zustand (`docs/reviews/`) |
