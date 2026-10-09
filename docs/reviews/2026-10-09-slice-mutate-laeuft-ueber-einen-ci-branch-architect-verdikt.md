# Slice-Closure slice-mutate-laeuft-ueber-einen-ci-branch — Architect-Verdikt (3b)

- **Rolle:** Architect · **an:** Planner (3c) · **Eingang:** Verifikation
  `slice-mutate-laeuft-ueber-einen-ci-branch`, LOW-1 (`59c7a4ff`), behoben in `9106e745` ·
  **Bezug:** [ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md)
  Festlegung 1, [ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md),
  [`AGENTS.md`](../../AGENTS.md) §3.6/§3.8, Baseline-Regelwerk `v6.17.0`, `modul-06-roadmap.md`
  §Das Beobachtungs-Register
- **Ergebnis:** ein Eintrag *verkörpert*, Zielort ist ein Architect-Artefakt und im selben Commit
  geschrieben. Keine ADR, kein `MR`.

## `BEO-ALL/exit-zusage-aus-anderem-aufruf-abgeleitet` (3. Beleg)

**Verdikt: verkörpert.** Zielort `AGENTS.md §3.6`, neues Falsch/Richtig-Paar nach dem Paar zur
emittierten Abdeckungs-Aussage, Anker `· seit slice-mutate-laeuft-ueber-einen-ci-branch`.

LOW-1 gehört in die Klasse: Die Zeile zu `make mutate-auswahl` sagte Exit 10 zu, gemessen am
Skript. Alle drei Belege haben dieselbe Form, eine Exit-Zusage für `make <ziel>` vom
Skript-Aufruf abgeleitet. Prosa-Verkörperung ist bei der dritten Wiederholung der Regelfall
(`modul-06` Closure-Schritt 3). §3.6 passt als Zielort, denn das Paar ist dort der Fall *„rot
gesehen, aber am falschen Aufruf"*. Gemessen am Host-`make` (GNU Make 4.3):

```sh
printf '.PHONY: x y\nx:\n\t@exit 10\ny:\n\t@exit 1\n' > Mf
make -f Mf x; echo rc=$?   # make: *** [Mf:3: x] Fehler 10 — rc=2
make -f Mf y; echo rc=$?   # make: *** [Mf:5: y] Fehler 1  — rc=2
```

**Mechanischer Sensor: dynamisch nicht möglich, statisch nur teilweise. Der Teil wird nicht
gebaut.** Jedes `make X` aus einem Test heraus zu fahren geht nicht. Die Ziele brauchen Docker
oder Netz, oder sie pushen (`mutate-auswahl`, `tap-nachzug`). Und das Fehlschlag-Szenario einer
Zeile müsste erst hergestellt werden. Nötig ist der Lauf aber gar nicht: GNU Make endet nur mit
0, 1 (`-q`) oder 2. Eine Zeile, die für `make X` eine andere Zahl zusagt, ist also schon nach
ihrer Form falsch. Entscheidbar ist nur, *welchem Aufruf* eine Exit-Zahl gilt, und das geht
allein in den Tabellenzeilen von `harness/README.md`, wo eine Zeile genau einen `make`-Aufruf
nennt. In der Prosa von `harness/sensors/*.md` gilt die Zahl oft rechtmäßig dem Skript
(`mutate.md` §CI-Branch, `adr-immutable.md` §Sperren). Ein Muster darüber wäre ein Gate, das
*manchmal* rot sein darf (Modul 13). Von den drei Belegen hätte die Tabellen-Prüfung nur den
dritten gefangen, denn Beleg 1 steht in Sensor-Prosa und Beleg 2 in einer ADR-Fitness-Zeile.
**Akzeptiertes Negativ:** ein eigener Slice für einen Teil-Sensor, der einen von drei Fundorten
deckt, trägt nicht. Neu zu prüfen ist das beim **vierten** Beleg (`modul-06` Schritt 3: dann gilt
die Prosa als ausgeschöpft), und dann mit der Tabellen-Prüfung als Kandidat.

**Bestand, an den Planner übergeben (keine Architect-Datei):** `harness/README.md` §Werkzeuge,
Zeile `make doc-trace`, `make doc-complete`: *„`doc-complete` endet mit Exit 1 bei einer
Waise"*. Über `make` ist das Exit 2 (Rezept in `d-check.mk`, Hilfetext dort ebenso „Exit 1").
Vorgeschlagener Wortlaut: *„`doc-complete` endet bei einer Waise mit einem Fehlschlag (d-check
Exit 1, über `make` Exit 2)"*. Der Hilfetext in `d-check.mk` ist tool-generiert
([`MR-010`](../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) und
bleibt stehen. Das ist ein Fund, kein vierter Beleg: Er gehört zu keinem abgeschlossenen
Vorgang (benannt, nicht gezählt).

**`state.md` für den Planner:**

```markdown
**Stand:** verkörpert

Zielort: [`AGENTS.md`](../../../../../../AGENTS.md) §3.6, Falsch/Richtig-Paar *„eine Zeile zu
`make <ziel>`, die „Exit 1" oder „Exit 10" zusagt …"* · seit
slice-mutate-laeuft-ueber-einen-ci-branch. Ein Wächter besteht nicht. Eine Prüfung der
Tabellenzeilen in `harness/README.md` wäre baubar, hätte aber nur einen der drei Fundorte
gedeckt. Neu zu prüfen beim vierten Beleg (Verdikt
`2026-10-09-slice-mutate-laeuft-ueber-einen-ci-branch-architect-verdikt`).
```
