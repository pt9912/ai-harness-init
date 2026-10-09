# `make mutate` — Mutations-Sensor zu AGENTS.md §3.6

## Vertrag

Wendet ein kuratiertes Set von Mutationen an (Mutation → erwartet rot färbender Test) und
meldet jeden Wächter, der dabei **grün** bleibt — die Regel ist sonst nur im
Feedforward-Quadranten. Kein Gate ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6));
der Grund ist die Laufzeit: je Fall ein voller Sensor-Lauf.

Ohne `MUTATE_CASES` bricht der Lauf ab, bevor Entwertung, Isolationskopie oder ein Fall
läuft — ausgenommen der Beleg-Übersprung: ein gültiger Beleg entlastet den Aufruf, bevor
die Sperre fragt (§Grenze). Der lokale Vollauf braucht `MUTATE_FORCE=1` als ausdrückliche
Zustimmung, und der regelmäßige Vollsweep läuft als CI-Workflow (`gh workflow run
mutate.yml`), der `MUTATE_CASES` je Shard setzt.

## Grenze — was das Grün nicht abdeckt

**Vor dem Fall-Satz prüft der Lauf einen Beleg**
([`ADR-0035`](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)):
war der letzte Lauf über demselben Prüfgegenstand vollständig grün, gibt dieser Lauf diesen
Beleg aus statt den Fall-Satz erneut zu fahren — `MUTATE_FORCE=1` erzwingt den vollen Lauf.
Die Fälle laufen auf mehrere, dynamisch zugeteilte Worker verteilt (`MUTATE_JOBS`), jeder mit
einer eigenen isolierten Kopie außerhalb des Repos; das Verdikt hängt nicht an der
Worker-Zahl (Zeit-, keine Verdikt-Stellschraube). Der Lauf begrenzt seine eigene Stille
(`MUTATE_STALL_SECONDS`) und wird rot, wenn kein Worker mehr zieht oder abschließt.

**Was er nicht deckt, steht im Treiber:** beendet wird der Worker, nicht dessen Kinder, und
ein Hänger im Vorwärmlauf vor dem Fork liegt außerhalb. Ein Abbruch lässt im Arbeitsbaum kein
Residuum zurück; außerhalb bleiben ein Temp-Verzeichnis und, nach hartem Kill, das
Lock-Verzeichnis liegen (bewusst fail-closed). Isolation, Beleg-Mechanik, Bezugsmenge des
Schlüssels (`isolation_key_files`, **nicht** `harness/tools/working-tree-hash.sh`) und jede
weitere Bedingung stehen im Kopf von `harness/tools/mutate.sh`.

**Eine `# files:`-Angabe wird aufgelöst, nicht gelesen** (`resolve_file_spec` in
`harness/tools/mutate.sh`, benutzt sowohl von `mutation_targets`/`target_fingerprint` als auch
von `run_case`): ein Bash-Glob wie `.harness/baseline/*/templates/…` trifft gegen den jeweils
einen vendored Baum, ohne dessen Tag im Fall zu nennen — ein Baseline-Sprung zieht keinen
Nachzug nach sich, solange die Vorlage im neuen Satz unter demselben relativen Pfad liegt. Löst
die Angabe **nicht genau eine** Datei auf (kein Treffer, mehr als einer), nennt die Meldung den
Fall — `mutation_targets` bricht darauf den **ganzen** Lauf ab (vor jeder Isolationskopie),
`run_case` meldet einen Befund für **diesen** Fall, während die übrigen weiterlaufen. **Was die
Auflösung nicht deckt:** eine Angabe, die auf die **falsche**, aber existierende Datei zeigt,
bleibt still grün — Existenz und Eindeutigkeit sind geprüft, Richtigkeit ist es nicht.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | jeder Fall färbte seinen Wächter rot (`mutate: <n> ok, 0 Befund(e)`), oder ein Beleg über demselben Prüfgegenstand lag vor und kein Fall lief (`mutate: Beleg fuer Pruefgegenstand … liegt vor`), oder jeder gewählte Fall eines Teillaufs färbte seinen Wächter rot (`mutate: TEILLAUF <n> von <total> — kein Beleg …`) |
| 1 | mindestens ein Befund (`mutate: BEFUND  <fall>  <grund>` je Fund, Summe in `mutate: <n> ok, <m> Befund(e)`), oder eine Sperre griff |
| 130 | ein Signal beendete den Lauf; berichtet ist, was bis dahin gemessen war, gekennzeichnet `ABGEBROCHEN` |

Die Tabelle nennt den Exit des Skripts. Über `make mutate` endet ein Lauf, den das Skript mit 1
beendet, mit 2.

## Sperren

- `mutate: ABBRUCH — ein Lauf ist bereits aktiv (…)` — das Lock-Verzeichnis unter
  `.harness/state/` besteht → den anderen Lauf abwarten; ein verwaistes Lock von Hand entfernen.
- `mutate: ABBRUCH — ohne MUTATE_CASES faehrt hier kein Vollauf.` — der Lauf startet ohne
  Fall-Filter → gezielter Teillauf (`MUTATE_CASES='<fall> …'`), Vollsweep als CI-Workflow
  (`gh workflow run mutate.yml`) oder lokaler Vollauf mit `MUTATE_FORCE=1`.
- `mutate: ABBRUCH — MUTATE_JOBS ist keine Worker-Zahl >= 1` → eine ganze Zahl ab 1 setzen.
- `mutate: ABBRUCH — MUTATE_STALL_SECONDS ist keine Sekundenzahl >= 1` → eine ganze Zahl ab 1
  setzen.
- `mutate: ABBRUCH — MUTATE_CASES …` — ein leerer Wert (gesetzt, ohne Namen), ein unbekannter
  oder ein doppelt genannter Name → die Namen berichtigen (§Teillauf).
- `mutate: … fehlt` bzw. `mutate: keine Faelle in …` — `test/mutations/` fehlt oder ist leer; ein
  leeres Set ist kein grüner Lauf.
- `mutate: ABBRUCH — Fingerabdruck der Mutations-Ziele nicht berechenbar.` — unter anderem, wenn
  eine `# files:`-Angabe nicht genau eine Datei auflöst (§Grenze) → die Angabe berichtigen.
- `mutate: ABBRUCH — unbekannter '# verify: …'` — ein Fall nennt eine Prüfart ohne bekanntes
  Fehlschlag-Muster → den Fall berichtigen.
- `mutate: ABBRUCH — WORK …` — die Isolations-Wurzel ist leer, liegt im Repo oder ist kein
  Verzeichnis; ohne Isolation wird nicht mutiert.

Diese Sperren enden beim Direktaufruf mit 1, über `make mutate` mit 2, bevor ein Fall läuft
(`harness/tools/mutate.sh`, `main`). Die
folgende greift während des Laufs:

- Stille über `MUTATE_STALL_SECONDS` hinweg (kein Worker zieht oder schließt einen Fall ab) → Lauf
  bricht selbst ab und wird rot; ein hängender Sensor ist sonst von einem langsamen nicht zu
  unterscheiden.

**Die Sperre sitzt am Treiber, nicht am Rezept.** Die Rezept-Zeile von `make mutate` setzt
weder `MUTATE_CASES` noch `MUTATE_FORCE`; träte sie eines davon bei, disarmierte das die
Sperre für den Rezept-Weg lautlos — benannte Grenze, kein Wächter hält sie.

## Teillauf

`make mutate MUTATE_CASES='<fall> <fall> …'` fährt nur die genannten Fälle. Ein Name ist der
Fall-Name, wie ihn `mutate: BEFUND  <fall>` nennt, mehrere sind durch Leerzeichen getrennt; die
Reihenfolge der Ausgabe ist die sortierte des Verzeichnisses. Das Gegenstück ohne Filter — der
volle Lauf — ist lokal an `MUTATE_FORCE=1` gebunden; ohne beides bricht der Lauf an der
Vollauf-Sperre ab (§Sperren), sofern kein Beleg ihn entlastet. Ein leerer Wert (gesetzt, ohne
Namen), ein unbekannter und ein doppelt genannter Name enden mit
`mutate: ABBRUCH — MUTATE_CASES …` und dem Namen, bevor eine Isolationskopie entsteht
(Skript 1, über `make` 2; `select_cases` in `harness/tools/mutate.sh`). Die Vollständigkeits-Prüfung
gilt über der gewählten Menge.

**Der Beleg-Slot bleibt unberührt.** Der Slot trägt die Aussage „der letzte **volle** Lauf über
diesem Prüfgegenstand war grün"; nur ein voller Lauf schreibt sie, nur ein voller Lauf löscht sie.
Ein Teillauf fährt auch dann, wenn ein Beleg zum aktuellen Schlüssel steht (der Filter ist eine
ausdrückliche Anfrage), schreibt den Slot nie — auch bei grünem Ausgang nicht —, löscht ihn nie —
auch bei einem Befund nicht — und führt die Sofort-Entwertung nicht aus. Ein Befund im Teillauf
widerlegt den Slot nicht von selbst; er steht im Exit und in der Ausgabe dieses Laufs.

**Die Ausgabe sagt, was der Lauf nicht ist:** die Zeile `mutate: TEILLAUF <n> von <total> — kein
Beleg …` (auch bei einem Befund), der Prüfgegenstand-Schlüssel (`mutate: Pruefgegenstand <hash>`,
oder `nicht berechenbar`) und die Namen der `ok`-Fälle. Die Kosten des Teillaufs nennt sein eigener
Bericht (`report_times`); Isolationskopie und Grün-Vorlauf fallen je Worker an, gespart wird der
Fall-Anteil. Gehalten wird das von `test/mutate-driver.bats` (Blöcke „Teillauf: MUTATE_CASES") und
den Fällen 453 bis 458 in `test/mutations/`.

## Zwei Läufe, eine Aussage

Ein voller Lauf, der Bilder baut und Container startet, kann an der Infrastruktur enden
(Registry-Zeitüberschreitung, Daemon-Zustand), bevor der Fall urteilt. Ein Bericht darf dann die
Vereinigung der `ok`-Mengen zweier Läufe als Aussage tragen — Hauptlauf und Teillauf, oder zwei
volle Läufe am identischen Baum —, **nur wenn** alle drei Bedingungen gelten:

1. **Beide Läufe nennen denselben Prüfgegenstand-Schlüssel** (`mutate: Pruefgegenstand <hash>`).
   Ein Teillauf nennt die Zeile in seiner Ausgabe, ein voller Lauf nach seinem Bericht — auch
   mit Befund und auch dann, wenn ein Worker wegen eines roten Grün-Vorlaufs in seiner Kopie
   abbricht (`main` läuft danach bis zum Bericht weiter; kein Test hält die Zeile für diesen
   Zweig). Endet der volle Lauf vor seinem Bericht, steht keine Zeile da, und es gibt keinen
   Hauptlauf im Sinne dieser Regel: bei einer Sperre, beim Grün-Vorlauf vor dem Fork
   (`make test-go`) und bei einem Signal (der `ABGEBROCHEN`-Bericht nennt keinen Schlüssel; im
   Code gelesen, nicht gefahren). Nennt einer der Läufe keinen oder einen anderen Schlüssel,
   sind es zwei Aussagen über zwei Bäume.
2. **Jeder Fall, der in einem der beiden Läufe nicht `ok` ist, trägt dort eine gelesene Ursache,
   die nicht dem Fall entstammt, und ist im anderen Lauf `ok`.** Rot aus dem falschen Grund: die
   Fehler-Form passt nicht zum erwarteten Wächter, die Meldung nennt die Infrastruktur. Ein Fall,
   dessen Befund sein eigener ist (`blieb GRUEN`, `rot, aber … falscher Grund` am Wächter selbst,
   Mutation griff nicht), und ein Fall, der in keinem der beiden Läufe `ok` ist, gehören nicht in
   die Vereinigung.
3. **Die Aussage steht im Bericht, nie im Slot.** Der Slot bleibt ein Beleg des vollen Laufs;
   die Vereinigung schreibt ihn nicht.

**Grenze:** die Vereinigung sagt etwas über den Ausschnitt jedes der zwei Läufe und über die
Vereinigung ihrer `ok`-Mengen, nicht über einen einzelnen grünen Vollauf. Der Docker-Cache-Rest aus
[`ADR-0035`](../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4 gilt weiter (Cache-Zustand und Host-Werkzeuge deckt kein Schlüssel). Kein Doku-Modul
hält den Inhalt dieser Regel — sie ist Prosa; der Träger ist die Rolle, die den Beleg liest
(Verifier), und sie liest die Ausgabe beider Läufe, nicht den Slot.

## Greift-Modus (`make mutate-greift`, in `make gates`)

**Vertrag:** `harness/tools/mutate.sh --greift` fährt je Fall allein Bedingung 2 des Treibers
(*„Mutation hat nicht gegriffen"*): die Dateien aus `# files:` werden einzeln in ein frisches
Verzeichnis außerhalb des Repos kopiert, das Fall-Skript läuft dort, und jede Datei muss danach
einen anderen Inhalts-Hash tragen. Fehlt das bei einem Fall — oder löst seine `# files:`-Angabe
nicht auf genau eine Datei auf, oder scheitert sein Skript in der Kopie —, meldet eine Zeile
`mutate-greift: BEFUND <fall> — …`, und der Lauf endet mit Exit 1. Kein Grün-Vorlauf, kein
Sensor-Lauf, kein Lock, kein Beleg-Slot, kein Docker; `MUTATE_CASES` engt ein wie beim vollen
Lauf. Ein leeres Fall-Set ist ein Befund. Damit fällt ein Anker, den eine berechtigte Änderung
am Quellbestand verschoben hat, am Commit statt im Nacht-Lauf.

**Sensor:** `test/mutate-driver.bats`, Fälle „greift: …" — rot an den Fall-Fassungen 29 und 247
aus dem Stand `98bfab0b^` (Fixtures unter `test/fixtures/mutate-greift/`, byte-gleich zu
`git show 98bfab0b^:test/mutations/<fall>.sh`), grün an denselben Fällen im Bestand; die
Verdrahtung hält `test/gate-nachweis-kante.bats`. Den Zahn auf den Modus selbst trägt
`test/mutations/635-greift-modus-uebersieht-ungegriffenen-anker.sh`.

**Laufzeit:** Der Zuwachs von `make gates` ist die Differenz zweier Läufe in derselben Lage, einmal
mit dem Rezept `@true` an Stelle des Modus und einmal mit dem Modus:
`a0=$(date +%s.%N); make gates; a1=$(date +%s.%N)`, gemessen am 2026-10-09 auf einem Host mit 20
Kernen (`nproc`) bei warmem Docker-Cache. Ergebnis: 175,8 s gegen 194,0 s, also **18,2 s** Zuwachs.
Der Modus allein brauchte 18,2 s für 622 Fälle (`time bash harness/tools/mutate.sh --greift`,
user 7,1 s, sys 14,8 s). Den Preis trägt der Host-Kern, das heißt Prozessstarts und Dateisystem
für eine Kopie je Fall; Docker ist nicht beteiligt. **Kein Erwartungswert:** Die Zahl wächst mit
dem Fall-Bestand. Nicht gemessen ist die Laufzeit auf dem CI-Runner und bei kaltem Seiten-Cache.

**Grenze:**

- Grün heißt *der Anker trifft*, nicht *der Wächter wird rot* — das bleibt Sache des vollen
  Laufs (Nacht-Workflow). Ein Anker, der die falsche Stelle trifft — eine Zeilennummer, ein zu
  breites Muster —, geht durch.
- Ein Fall-Skript, das außer seinen `# files:` weitere Dateien liest, scheitert in der Kopie und
  wird als Befund gemeldet; der Modus setzt voraus, dass der Patch allein über die `# files:`
  wirkt.
- Die `# expect:`-Zeile liest der Modus nicht.
- Dass die Fixtures den Stand `98bfab0b^` tragen, hält kein Sensor — der bats-Container trägt
  kein git; Träger ist der Lauf, der sie anlegt.

## Bindung

[`AGENTS.md`](../../AGENTS.md) §3.6; slice-026; kein Gate-Versprechen. Mechanischer Auslöser
ist der **Nacht-Workflow** `mutate.yml` (`schedule` + `workflow_dispatch`), der den Fall-Satz
als **Matrix aus parallelen Shard-Jobs** fährt (deterministische, index-basierte Zuteilung über
`MUTATE_CASES`, `fail-fast: false`) statt eines Einzel-Jobs — die Klassifikation des Regelwerks
ordnet die Mutationstests der Stufe **Post-integration** zu (`grundlagen-klassifikation.md`
§Klassifikation: *„nach Merge : Mutation Tests"*, *„teurer, aber tolerierbar"*); die
Kostenmessung `49m54s` von `49m58s` eines Pushes
(`gh api "repos/pt9912/ai-harness-init/actions/jobs/<job-id>/logs"`) stammt aus der Zeit vor
der Matrix und begründet weiterhin, warum der Lauf nicht im Push-Pfad steht. Der erste reale
Matrix-Lauf deckte den vollen Fall-Satz in **~36 Minuten** Wall-Clock ab, fünf Shards zwischen
21 und 37 Minuten je Shard
(`gh run view 36375725927 --json jobs --jq '.jobs[] | {name,startedAt,completedAt}'`,
`workflow_dispatch`, 2026-09-28) — außerhalb des im Slice-Plan angepeilten Zielkorridors ~20–25
Minuten; Ursache ist die ungleiche Verteilung teurer `full-smoke`-Fälle über die Shards bei
reinem Index-Modulo-Round-Robin
(`docs/plan/planning/observations/BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor/`).
