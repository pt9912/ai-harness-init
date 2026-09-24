# Review-Report: slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset — Runde 2 — 2026-09-24

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der
Verifier).

**Gegenstand:** `git diff e887f9c6..HEAD` — drei Commits, 19 Dateien, 351 Zeilen hinzu, 47 entfernt:
`59eec470` (Rolle Planner: Abnahme-Wortlaut, Exit-Zeile), `cea9943b` (Rolle Implementer: Token-, Nutzlast-
und Tag-Form-Fälle binden ihre Zusage), `aa972660` (Rolle Implementer: Exit nur im Vergleich 1, Exit-Zeile).
Berührt: `harness/tools/tap-nachzug.sh`, `harness/tools/tap-nachzug-nutzlast.sh`, `test/tap-nachzug.bats`,
`test/mutations/` (412, 416, 418 bis 428), `Makefile`, `harness/README.md`, der Slice-Plan.

**Plan-Bezug:** Slice `slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset` (§1 Ziel und
Abgrenzung, §2 nur als Referenz für die Zusagen, §4, §6). Kennung, nicht Pfad: der Plan wandert mit dem
Lifecycle. **Vorlauf:** der Review-Report Runde 1 zum selben Slice (Befunde F-1 bis F-12, hier als
„Runde-1 F-<n>" zitiert).

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0064` (Accepted; Festlegung 2 und Fitness Function
gelesen) · `LH-QA-02` · `MR-071` · `AGENTS.md` §3 (v.a. §3.2, §3.4, §3.6, §3.7, §3.9, §3.11) · `v6.9.0` ·
`regelwerk/modul-08-agentenrollen.md` (Konflikt-Pfad), `modul-10-review-harness.md`,
`modul-11-verification.md`. Der Implementer-Bericht war Behauptung; Code, Tests und Sonden sind selbst
gelesen und gefahren.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt):

- `test/tap-nachzug.bats` einzeln im gepinnten bats-Image (Rezept `test-bats`): 32 von 32 ok.
- **Mutations-Fälle 412, 416, 418 bis 428 emuliert, nicht über `make mutate`:** je Fall eine frische Kopie
  der betroffenen Dateien im Scratchpad, das Skript des Falls dort angewandt (Anker ändert die Datei: bei
  allen 14 ja), `test/tap-nachzug.bats` gefahren. Jeder Fall färbt den Fall rot, den `# expect:` nennt; die
  Meldung des ersten roten `[`/`[[` ist gelesen (416: Zeile der Funktion `nirgends`, Fund im curl-Protokoll ·
  424, 425: `[ "$status" -eq 2 ]` · 427: `stderr_lines[-1] = "tap-check: Exit 1"` · 422: Meldung der
  Tag-Form fehlt, weil die Feldform-Stufe antwortet · 423: Exit 0 statt 2).
- **Gegenproben (grün heißt „bindet"):** 416 mit auf `if false` geschwächter Funktion `nirgends` → 32 von
  32 grün; 427 mit allen `stderr_lines[-1]`- und Zählzeilen des Exit-Zeilen-Falls auf `true` → 32 von 32
  grün. Zusatz-Mutanten (Zeile auch bei Exit 0; `trap - EXIT` entfernt → doppelte Zeile; Zeile nur bei
  Exit 2; Vorab- und Build-Feld der Tag-Form je einzeln gelockert; ein `jq`/`bash`/`git`/`gh`/`python3`-Aufruf
  in der Nutzlast): jeder färbt genau den Fall rot, der die Zusage trägt (Ausnahme: F-4).
- **Sonden am Skript, ohne Repo-Änderung:** stderr geschlossen und `/dev/full`; SIGTERM, SIGHUP, SIGKILL
  während des `docker`-Aufrufs (Stub); `docker`-Stub mit Exit 1, 3, 125, 126, 127; **reales `docker`
  (29.8.1) mit unerreichbarem Daemon**; TMPDIR nicht vorhanden und nur lesbar mit gesetztem Token; die
  Nutzlast im digest-gepinnten Bild bei fehlschlagendem `mktemp`. Für diese Sonde wurde das gepinnte Bild
  und `busybox` in den lokalen Docker-Bestand geladen (Netz an genau diesem Aufruf; nichts im Repo).
- `make shell-lint` Exit 0, keine Suppression im Diff (`grep -rn shellcheck` über die geänderten Skripte:
  0 Treffer, keine `.shellcheckrc`); `make comment-claims` → `76 Datei(en) geprueft, 0 Befund(e)`;
  `make docs-check` → `1863 Datei(en) geprüft, 0 Befund(e)` (vor diesem Report);
  `make tap-check TAG=v01.0.0` (make Exit 2, Zeile `tap-check: Exit 2`, `Fehler 2`), `TAG=v1.0.0-rc.1`
  (Exit 0, keine Zeile). `make gates` — siehe Ende.

---

## Status der Runde-1-Befunde

| Runde-1 | Status | Beleg dieses Laufs |
|---|---|---|
| F-1 HIGH (Token in Argumentliste, Negation mitten im Fall) | **behoben** | Die Funktion `nirgends` trägt den Status von `grep`; kein `!` mehr mitten in `test/tap-nachzug.bats` (`grep -nE '^\s+!'` → 0 Zeilen). 416 ergänzt jetzt einen zweiten Header und lässt die Kopfdatei stehen; das Rot kommt aus `nirgends` (Fund im curl-Protokoll), die Zeile `-H @` bleibt grün. Gegenprobe (`nirgends` geschwächt) → grün: der Zahn bindet die Argumentliste. |
| F-2 HIGH (`for`-Schleife, nur `python3` wirksam) | **behoben** | Der Fall ruft `return 1` im Fund-Zweig je Programm; `jq`, `bash`, `git`, `gh` und `python3` in der Nutzlast färben ihn je einzeln rot (Sonde). |
| F-3 MEDIUM (Exit-Vertrag über `make`) | **teilweise** | Wortlaut in Plan, Makefile-Kommentar, README, Skript-Kopf auf den Exit des Skripts gestellt, die Klasse trägt die Zeile `tap-<modus>: Exit <N>` (gemessen über `make`). `ADR-0064` ist unverändert, und in der Range steht kein Verdikt-Artefakt des Architect — siehe R2-2. Die Zeile trägt die Klasse außerdem falsch in einem Fall — siehe R2-1. |
| F-4 MEDIUM (Tag-Form ohne Gegenbeispiel) | **behoben** | 421 (Zeichenmenge), 422 (Anfangsanker), 423 (Endanker) färben den Fall „tag-form" rot; einzeln nur das Vorab- oder nur das Build-Feld gelockert färbt ihn ebenfalls. Die Tags des Falls enthalten die aus Plan und ADR genannten Shell-Formen im Vorab- und im Build-Feld. |
| F-5 MEDIUM (interner Fehler als Exit 1) | **behoben für die gemeldeten Pfade** (`mktemp`, `cmp` Status 2, Kommando des Skripts) | Fälle „interner fehler" (3) plus Mutationen 424 bis 426 (jede färbt ihren Fall am Status). Verbleibende Lücken: R2-1 (Exit 1 aus `docker`), R2-4 (`*)`-Arm ohne Zahn). |
| F-6 LOW (Wortlaut „Fehler N") | **behoben** | Makefile und README nennen die Skript-Zeile, nicht make's Meldung. |
| F-7 LOW (Programm-Liste der Nutzlast) | **behoben** | Kopf nennt `curl, cmp, sha256sum, awk, mktemp, sleep, rm`; der Code ruft genau diese. |
| F-8 LOW (Token-Fall koppelt Lesungen) | **behoben** | Der Fall prüft jede Kopfdatei (`grep -vcx` → 0, `-s` nicht leer); 412 färbt nur noch den Fall „sofort gleich" (emuliert: Fall 10). |
| F-9 INFO (schreibende Rolle der Roadmap-Zeile) | **unverändert offen** | kein Diff seit Runde 1; die Frage geht weiter an den Architect. |
| F-10 INFO (Fixture-Grenze, Real-Beleg) | **unverändert offen** | Real-Beleg trägt der Verifier. |
| F-11 INFO (`:` im Repo-Pfad des `-v`-Werts) | **nicht adressiert** | im Ermessen des Implementer. |
| F-12 INFO (Negation in anderen bats-Dateien) | **nicht adressiert** | `grep -nE '^\s+! ' test/*.bats \| grep -v tap-nachzug \| wc -l` → **46** (Stand des Laufs, kein Erwartungswert; nicht bewertet). |

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R2-1 | HIGH | Ein Exit 1 des `docker`-Aufrufs selbst wird als **Formel-Unterschied** gemeldet: das Host-Skript setzt bei `docker`-Status 1 `unterschied=ja`, endet mit Exit 1 und schreibt `tap-check: Exit 1`, ohne dass die Nutzlast gelaufen ist. Gemessen mit dem realen `docker` (29.8.1): `TAG=v0.2.3 DOCKER_HOST=tcp://127.0.0.1:9 bash harness/tools/tap-nachzug.sh check` → Ausgabe *„Cannot connect to the Docker daemon …"*, dann `tap-check: Exit 1`, Prozess-Exit 1 (Bild nicht auffindbar dagegen 125 → Exit 2). Ein nicht erreichbarer Daemon ist der nächstliegende Ausfall dieses Ausfallwegs. Skript-Kopf („1 endet nur aus dem Vergleich der Nutzlast"), der Kommentar am Schluss (*„Ein Ende ausserhalb von 0, 1 und 2 kommt nicht aus der Nutzlast"*) und `ADR-0064` Festlegung 2 (*„Ein Lesefehler ist damit nie 1 und nie 0"*, Exit 1 nennt beide Digests) halten das nicht; die vom Plan gewählte Prozedur-Zeile *„`tap-check` rot mit der Zeile `tap-check: Exit 1`"* trägt dann einen Nachzug ohne Unterschied. Kein Fall der Suite und kein Mutations-Fall deckt es: der Transport-Fall nutzt Status 125, der Stub gibt Status 1 nie zurück. | `ADR-0064` Festlegung 2 (Exit-Tabelle) · `AGENTS.md` §3.6 · Plan §1 (Ziel, Abgrenzung), Liefer-Punkt 1 | `harness/tools/tap-nachzug.sh` Zeilen 16 bis 17, 123 bis 124, 137 bis 140; `test/tap-nachzug.bats` Zeilen 408 bis 413 | ja — Sonde: `DOCKER_HOST=tcp://127.0.0.1:9 TAG=v0.2.3 bash harness/tools/tap-nachzug.sh check`, Exit und letzte Zeile ablesen | Exit 1 des Transports als Formel-Unterschied gemeldet |
| R2-2 | MEDIUM | **Rest von Runde-1 F-3, keine Verantwortung des Implementer:** Der Plan wurde vom Planner allein umgeschrieben, `ADR-0064` blieb unberührt (Commit-Text: *„ADR-0064 bleibt unberührt"*). Die Fitness-Function-Zeile des Rot-Belegs nennt weiter `make tap-check` gegen `v0.2.2` → Exit 1, Festlegung 2 nennt die Klassen *„an der Form erkennbar"*; der Plan sagt jetzt, über `make` ende jeder Fehlschlag mit 2, und führt einen Vertrag ein (Exit-Zeile `tap-<modus>: Exit <N>`), den die ADR nicht kennt. Ein Verdikt des Architect als Artefakt (Plan-Korrektur nach Verdikt 1 oder Folge-ADR mit `Supersedes ADR-0064`) liegt in der Range nicht vor; der Plan deutet eine Accepted-ADR um. Modul 8 Konflikt-Pfad: kein Pfeil ohne benennbares Artefakt. | `ADR-0064` (Festlegung 2, §Fitness Function, Rot-Beleg) · `AGENTS.md` §3.4 · `v6.9.0` · `regelwerk/modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz | Slice-Plan §1 (Ziel, Abgrenzung), §2 Liefer-Punkt 3 (b); `ADR-0064` §Fitness Function | ja — `git log --stat 59eec470..HEAD -- <ADR-0064>`: keine Berührung | Umdeutung einer Accepted-ADR im Plan ohne Verdikt-Artefakt |
| R2-3 | MEDIUM | Die Zusage *„bei **jedem** Ende mit Exit ungleich 0 ist die letzte stderr-Zeile `tap-<modus>: Exit <N>`"* (Skript-Kopf, Plan Liefer-Punkt 1) und *„ein Kommando dieses Skripts, das mit 1 scheitert, endet mit Exit 2"* halten an zwei Enden nicht: (a) **Signal:** `kill -TERM` (Prozess-Exit 143) und `kill -HUP` (129) des Host-Skripts während des `docker`-Aufrufs enden ohne Exit-Zeile (gemessen: leere stderr) und ohne Klasse 2; die Nutzlast hat dafür `trap 'exit 2' HUP INT TERM`, das Host-Skript nicht. (b) **stderr nicht schreibbar:** `bash tap-nachzug.sh check 2>&-` und `2>/dev/full` mit falschem Tag enden mit Prozess-Exit **1** (das `printf` in `fehler()` scheitert unter `set -e` vor `beende 2`), ohne Zeile — ein interner Fehler in Klasse 1. Kein Fall und keine Mutation deckt beides; die Zusage ist unbedingt formuliert. | `AGENTS.md` §3.6 (Zusage auf das einschränken, was der Code hält) · `ADR-0064` Festlegung 2 | `harness/tools/tap-nachzug.sh` Zeilen 16 bis 22, 46 bis 67, 70 bis 73 | ja — Sonde (a): `docker`-Stub mit `sleep 30`, `kill -TERM`, Exit 143, stderr leer; Sonde (b): `TAG=xx bash harness/tools/tap-nachzug.sh check 2>&-; echo $?` → 1 | Zusage „jedes Ende" ohne Signal- und Schreibfehler-Zweig |
| R2-4 | MEDIUM | Der `*)`-Arm von `beende` (Status ≥ 3 → Exit 2 und Meldung des internen Fehlers) hat in beiden Skripten keinen Zahn: `rc=2` dort durch `:` ersetzt (je Skript einzeln, Scratchpad-Kopie) → 32 von 32 Fällen grün. Die drei Fälle „interner fehler" laufen alle über Status 1 oder 2; ein Kommando, das mit anderem Status endet (etwa ein fehlendes Programm, Status 127), leckt bei dieser Änderung als Prozess-Exit 127 durch, während der Kopfkommentar *„jedes andere Ende ausserhalb von 0 und 2 ist ein interner Fehler und wird Exit 2"* zusagt. Es gibt dafür keinen Mutations-Fall unter den gelisteten. | `AGENTS.md` §3.6 · `MR-071` (Zahn je Zusage) | `harness/tools/tap-nachzug.sh` Zeilen 57 bis 61; `harness/tools/tap-nachzug-nutzlast.sh` Zeilen 48 bis 52 | ja — Sonde: `rc=2` im `*)`-Arm ersetzen, `test/tap-nachzug.bats` einzeln: 0 rote Fälle | Zusage einer Exit-Abbildung ohne Gegenbeispiel für Status ≥ 3 |
| R2-5 | INFO | Die Zähne „Zeile auch bei Exit 0" und „doppelte Zeile" (bei entferntem `trap - EXIT`) sind über den Fall „exit-zeile" gebunden (beide Zusatz-Mutanten färben ihn rot, emuliert), stehen aber nicht als Fall in `test/mutations/`; der einzige Nachweis der doppelten Zeile ist die Zählzeile für den Modus `sync`. `make mutate` meldet sie als unbewacht erst, wenn sie gelistet sind (`AGENTS.md` §3.6, Feedback-Absatz). | `AGENTS.md` §3.6 (gelistet = bewacht) | `test/mutations/` (kein Fall zu diesen zwei Zusagen); `test/tap-nachzug.bats` Zeile 459 | ja — `ls test/mutations/ \| grep -c exit-zeile` → 2 (427, 428) | Zusage mit Bats-Bindung, ohne gelisteten Mutations-Fall |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Token-Umgang nach dem Umbau von `beende`/`fehler()`: Datei 0600 unter `umask 077`, `curl -H @Datei`, `unset TAP_TOKEN`, Entfernung in `beende` (jeder Endezweig, auch Signal in der Nutzlast über `trap 'exit 2'`), kein `set -x`, keine Antwort der Schnittstelle in der Ausgabe | geprüft, ohne Befund |
| **Neue Sonde:** TMPDIR nicht vorhanden und TMPDIR nur lesbar, `TAP_TOKEN=TOKSENT-XYZ` gesetzt: Exit 2, Meldung des internen Fehlers (die `mktemp`-Meldung des Programms), Token in **keiner** Ausgabe (`grep -c` → 0 in stdout und stderr), keine Restdatei (Verzeichnis leer, `grep -rl` über `/tmp` ohne Fund); der Weg im gepinnten Bild (BusyBox) identisch | geprüft, ohne Befund |
| Exit-Zeile in den Endezweigen: `fehler()` (Aufruf, Pin, `TAP_WAIT`, Tag, Tag-Form, Feldform, `sync`), `docker` Exit 125, 126, 127 und 3 → Exit 2 mit Zeile, Ausfall von `printf` auf stdout (Vorab-Tag) → interner Fehler, Exit 2 mit Zeile, Exit 0 ohne Zeile, genau eine Zeile (`trap - EXIT` in `beende`), Modus `sync` → `tap-sync: Exit 2` | geprüft, ohne Befund (Ausnahmen: R2-1, R2-3) |
| `SC2329`-Umbau: `beende` wird über `trap 'beende "$?"' EXIT` und aus `fehler()` aufgerufen, `make shell-lint` Exit 0, keine `# shellcheck disable`, keine Lint-Config im Diff; kein Verhaltensunterschied gegenüber dem Stand vor dem Umbau erkennbar (Diff gelesen) | geprüft, ohne Befund (`AGENTS.md` §3.2) |
| Mutations-Fälle 412, 416, 418 bis 428 nach `MR-071`: jeder `sed`-Anker ändert die Datei am heutigen Bestand; die `# expect:`-Texte sind Präfixe der Fall-Namen; 418 und 420 setzen `unterschied=ja` und sind damit die Mutation, die sie behaupten (ohne es würde `beende` sie auf 2 abbilden) | geprüft, ohne Befund |
| Zustandsform der Kommentare (`AGENTS.md` §3.7) in Skripten, bats-Datei, Mutations-Fällen, Makefile, README: keine Befund-Kennung, keine Runden-Nennung, keine Slice-Nummer als Erzählung, keine verworfene Alternative (`grep` über die hinzugefügten Zeilen: 0 Treffer) | geprüft, ohne Befund (Aussage-Fehler im Kommentar: R2-1, R2-3) |
| Doku gegen Code: Makefile-Kommentar, Skript-Kopf und README-Zeile nennen die Exit-Zeile und stimmen untereinander und mit dem gemessenen Verhalten über `make` überein (Zeile `tap-check: Exit <N>`, `Error N`/`Fehler N` nicht mehr als Träger) | geprüft, ohne Befund |
| Abgrenzung (Plan §1): kein `sync`-Verhalten (nur die Absage mit Exit 2), kein Gate (Fall „kein gate" schlägt an, `tap-check` nicht in `gates`/`record-gates`), kein Adaptions-Eintrag, `harness/tools/traeger-fetch.sh` und Workflow unberührt | geprüft, ohne Befund |
| Größe und Schnitt: 351 Zeilen im Diff, davon 135 in der bats-Datei und 13 Mutations-Fälle (5 geändert, 8 neu) je 10 bis 12 Zeilen; drei Liefer-Punkte, zwei Schichten — in einer Sitzung prüfbar | geprüft, ohne Befund |
| Rollen-Grenze `AGENTS.md` §3.10: Plan §7 bleibt leer, kein Closure-Schritt im Diff; `AGENTS.md` §3.8: keine Hard-Rule- oder Adaptions-Änderung | geprüft, ohne Befund |
| Bats-Mechanik: `bats_require_minimum_version 1.5.0` (Image 1.11.0), `run --separate-stderr` und `stderr_lines[-1]` tragen; `nirgends` bricht bei Fund und bei `grep`-Fehler (Status 2); kein `!` mitten im Fall in `test/tap-nachzug.bats` | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 3 |
| LOW | 0 |
| INFO | 1 |

**Runde-1-Befunde:** F-1, F-2, F-4, F-5 (gemeldete Pfade), F-6, F-7, F-8 behoben · F-3 teilweise (R2-2) ·
F-9, F-10 unverändert offen · F-11, F-12 nicht adressiert (INFO).

**Finding-Klassen dieses Laufs:** Exit 1 des Transports als Formel-Unterschied gemeldet · Umdeutung einer
Accepted-ADR im Plan ohne Verdikt-Artefakt · Zusage „jedes Ende" ohne Signal- und Schreibfehler-Zweig ·
Zusage einer Exit-Abbildung ohne Gegenbeispiel für Status ≥ 3 · Zusage mit Bats-Bindung, ohne gelisteten
Mutations-Fall

## Verdikt

**Merge-blockierend:** ja — R2-1 ist HIGH (Verstoß gegen `ADR-0064` Festlegung 2: der Transport-Ausfall
*Daemon nicht erreichbar* endet als Klasse „Formel-Unterschied", und die in dieser Runde eingeführte Zeile
`tap-check: Exit 1` bestätigt es); R2-2 bis R2-4 sind MEDIUM und vor dem Merge zu klären.

**Übergabe:**

- **R2-1, R2-3, R2-4, R2-5 → Implementer.** Der Code des Token-Umgangs hält die Zusage; die Exit-Abbildung
  hält sie an drei Enden nicht (Transport-Status 1, Signal, unbeschreibbares stderr) und am `*)`-Arm nicht
  gebunden.
- **R2-2 → Architect (Verdikt) und Planner (Wortlaut); nicht der Implementer.** Konflikt-Pfad aus `v6.9.0` ·
  `regelwerk/modul-08-agentenrollen.md`: ein Verdikt als Artefakt (Plan-Korrektur nach Verdikt oder Folge-ADR
  mit `Supersedes ADR-0064`), nicht „herabstufen, weil der Plan es jetzt so sagt". Zusammen mit dem offenen
  Runde-1 F-9 (schreibende Rolle der Roadmap-Zeile) in einer Anfrage möglich.
- Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler (Runde 1 und
  Runde 2 zählen als je ein Vorgang **derselben** Closure, nicht als zwei). Dieser Report ist ein
  Lauf-Beleg und ersetzt keine Verifikation: DoD-Konformität, den realen Rot-Beleg und den Beleg der Fälle
  unter `make mutate` prüft der Verifier.
