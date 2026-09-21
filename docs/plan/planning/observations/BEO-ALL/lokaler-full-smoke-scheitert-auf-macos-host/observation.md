# Lokaler `full-smoke`/`mutate`-Lauf scheitert strukturell auf einem macOS-Devhost

**Sub-Area:** `*` (gesamtes Repo)

`make artifact` — die Basis, aus der `harness/tools/full-smoke.sh` und `harness/tools/smoke.sh`
ihr Prüf-Binary ziehen — baut über den plain `build`-Dockerfile-Stage **ohne**
`TARGET_OS`/`TARGET_ARCH`-Build-Args (anders als `make host-bin`, das den Fetch-Weg über
`traeger-fetch` nutzt). Das Ergebnis ist immer ein Linux-Binary. Auf einem macOS-Host führen die
beiden Skripte es direkt aus — unabhängig von der CPU-Architektur scheitert der Aufruf mit einem
Exec-Format-Fehler, weil der Host-Kernel ein ELF-Linux-Binary nicht laden kann. Reproduziert: sowohl
`make full-smoke` als auch `make smoke` scheitern auf einem unveränderten Baum identisch an dieser
Stelle.

Betroffen ist damit auch `make mutate`, sofern seine kuratierten Fälle denselben Träger-Pfad
durchlaufen: Ein lokaler Closure-Beleg über diesen Sensor ist auf einem macOS-Devhost nicht zu
erbringen; der Beleg läuft über CI (`workflow_dispatch` auf `.github/workflows/mutate.yml`,
~50 Minuten Laufzeit, [`harness/README.md`](../../../../../../harness/README.md) §Safety and scope
boundaries nennt dieselbe Zahl für den nächtlichen Lauf).

Dies ist keine Code-Regression und kein Docker-only-Verstoß (§3.9) — der Bau selbst läuft
gepinnt und containerisiert; die Grenze liegt darin, **was** gebaut wird (Linux-Ziel-Plattform)
gegenüber **wo** das gebaute Artefakt danach ausgeführt wird (Host-Plattform, außerhalb des
Containers).

## Benannt, nicht gezählt

Diese Beobachtung hat noch keinen **abgeschlossenen Vorgang**, an den ein Beleg unter `evidence/`
gebunden werden könnte — sie fiel während einer laufenden Rückführung
(`slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`, `in-progress` → `next`) auf, nicht
bei deren Closure. Nach der Register-Regel — [`README.md`](../../README.md) §Form: *„Ein
Vorkommen ohne abgeschlossenen Vorgang bekommt keine Datei unter `evidence/` und bewegt den
Zähler nicht"* — steht sie hier ohne Beleg-Datei; der erste Slice, der auf diese Randbedingung
stößt und schließt, trägt den ersten `evidence/`-Eintrag.
