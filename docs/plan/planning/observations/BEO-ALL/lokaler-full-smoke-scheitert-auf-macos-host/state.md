**Stand:** verkörpert

Zielort: [`harness/sensors/mutate.md`](../../../../../../harness/sensors/mutate.md) §Lokaler Weg für `# verify: full-smoke`-Fälle auf macOS — der Aufruf `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=<voller Fallname> make mutate`, seine Voraussetzung (GNU-`sed` vor dem BSD-`sed` im `PATH`) und seine Grenzen. Herkunft: `seit slice-mutate-doku-nennt-den-lokalen-weg-auf-macos`.

**Was verkörpert ist, und was nicht.** Verkörpert ist der **Weg**, nicht die Behebung: Der Default-Lauf (`make full-smoke`, `make smoke`, `make mutate` ohne die Variable) scheitert auf einem macOS-Host weiter mit `Exec format error`; für die zwei ersten Ziele besteht `make full-smoke-host`/`make smoke-host`, für `make mutate` die Variable.

**Grenze der Verkörperung, benannt.** Der Herkunfts-Anker steht in dieser Datei und nicht an der Überschrift des Zielorts: Der Abschluss des Slice berührt `harness/sensors/mutate.md` nicht (`AGENTS.md` §3.10), und ein `liegt in`-Feld, das die Anker-Paarung auslöste, trägt die Closure-Notiz nicht. Kein Wächter hält die Aussage des Zielorts gegen den Treiber oder das `Makefile`; der Abschnitt sagt es selbst. Gemessen ist macOS mit Colima und Einzel-Fälle; Linux/arm64, Windows und Mehr-Fall-Läufe sind ungemessen. Träger ist der Lauf, der den Abschnitt schreibt.

**Zählregel:** 1 Beleg nach der Verkörperung (`slice-benutzerhandbuch-fuehrt-java-python-csharp`), greift nicht (Verdikt `2026-10-20-welle-sprachprofile-java-python-csharp-architect-verdikt`, V-3). Offen: Behebung (der Treiber wählt auf Darwin selbst `artifact-host`, Code-Änderung), beim Auftraggeber; kein Folge-Slice angelegt.
