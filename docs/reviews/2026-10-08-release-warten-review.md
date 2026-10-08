# Review: `make release-warten` vor `make full-smoke` im `ci`-Job

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-10-08.
**Gegenstand:** Commit `37cd8662` gegen den Slice-Plan
`slice-ci-wartet-die-publikation-des-gepinnten-releases-ab` (Stand `9c2b440b`) und das
Architect-Verdikt `docs/reviews/2026-10-08-ci-rennen-architect-verdikt.md`.
**Bezug:** [ADR-0058](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
[ADR-0059](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
[`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
[`AGENTS.md`](../../AGENTS.md) §3.1/§3.6/§3.7.

Bruchproben liefen in einer Kopie unter dem Scratchpad mit einem `docker`-Stub (Exit 22, optional
`sleep`); der Baum blieb unberührt.

## Findings

### F-1 — MEDIUM: ein einzelner Versuch ist zeitlich nicht begrenzt; „höchstens 15 Minuten" hält nicht

- `quelle`: Architect-Verdikt Festlegung 3 („höchstens **15 Minuten**"); Slice-Plan §1
- `pfad`: `harness/tools/release-warten.sh:67-69` (Payload), `:77-87` (Schleife)
- `befund`: Das Payload ruft `curl -fsSL -r 0-0` ohne `--max-time`/`--connect-timeout`, und die
  Grenze wird nur zwischen den Versuchen geprüft. Ein hängender Transfer (TLS-Stall am CDN, hängender
  Bild-Pull im `docker run`) hält den Schritt über die Grenze hinaus fest, bis zum Job-Timeout — der
  Job `full-smoke` in `ci.yml` setzt keines, es gilt der GitHub-Default von 360 Minuten. Dazu kommt
  ein Überlauf um bis zu ein Intervall, weil nach der letzten Prüfung unter der Grenze noch `sleep`
  und ein Versuch folgen. Der Kopfkommentar nennt die erste Hälfte („ein Versuch, der bei ihr läuft,
  wird zu Ende gefahren"); `harness/README.md` §Werkzeuge, der `ci.yml`-Kommentar und
  `docs/user/releasing.md` sagen „begrenzt" bzw. die Grenze ohne diese Einschränkung.
- Beleg (Bruchprobe, Stub schläft 6 s, Grenze 1 s):
  `TRAEGER_WARTEN_GRENZE=1 TRAEGER_WARTEN_INTERVALL=0 STUB_SCHLAF=6 bash release-warten.sh` →
  `… nach 6s und 1 Versuch(en) nicht abrufbar (Grenze 1s) …`, Exit 0, Dauer 6 s.
  `grep -n 'max-time\|connect-timeout' harness/tools/release-warten.sh` → kein Treffer.
- `verifizierbar`: nein — kein Gate fährt den Schritt gegen ein Netz.
- `klasse`: Zeitgrenze zwischen Versuchen statt je Versuch

### F-2 — MEDIUM: die Exit-2-Zusage für Grenze/Intervall und Bild-Pin hat keinen Test, und die Zahlenprüfung trägt das Terminieren

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6; Skill-MEDIUM „fehlende Negativtests bei neuem
  öffentlichen Vertrag"
- `pfad`: `harness/tools/release-warten.sh:11-13` (Zusage), `:39-45`, `:55-60`;
  `test/release-warten.bats` (nur der Fall „ohne TRAEGER_TAG")
- `befund`: Der Kopf sagt Exit 2 für „Bild nicht digest-gepinnt" und „Grenze oder Intervall keine
  Zahl" zu; kein Fall bindet die beiden. Die Zahlenprüfung ist nicht kosmetisch: ohne sie liefert
  `[ "$SECONDS" -ge "15m" ]` Status 2, die `if`-Bedingung ist falsch, und die Schleife endet nie —
  ein vertippter Wert in `ci.yml` hängt den Job bis zum Timeout, und `make gates` bleibt grün.
- Beleg (Bruchprobe, `case "$grenze$intervall"`-Block per `sed` entfernt, Stub scheitert):
  `TRAEGER_WARTEN_GRENZE=15m TRAEGER_WARTEN_INTERVALL=0 timeout 4 bash rw2.sh` → 643 × `[: 15m:
  Ganzzahliger Ausdruck erwartet.`, Exit 124 (Abbruch durch `timeout`). Das Original endet mit
  Exit 2 und der Meldung; ein Bild ohne Digest ebenso mit Exit 2 (beide Pfade real gefahren, nur
  nicht in der Suite).
- `verifizierbar`: ja — ein bats-Fall je Vorbedingung würde unter der Mutation rot.
- `klasse`: Vorbedingungs-Exit ohne Negativtest

### F-3 — INFO: kein Fall unter `test/mutations/` für die Zusagen des neuen Skripts

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6, Absatz *Feedback* (`make mutate`)
- `pfad`: `test/mutations/` — `ls test/mutations | grep -i warten` → leer
- `befund`: Die drei Rot-Gegenproben im Kopf von `test/release-warten.bats` (Grenz-Exit, beide URLs,
  Bild-Pin aus `traeger-fetch.sh`) sind beim Lesen der Zusicherungen schlüssig, stehen aber in keinem
  kuratierten Fall; nach der §3.6-Lesart sind die Zähne unbewacht. Der DoD verlangt keinen Fall.
- `verifizierbar`: nein
- `klasse`: Zusage ohne Mutations-Fall

### F-4 — INFO: die Grenz-Zeile nennt keine Ursache

- `quelle`: Maintainability
- `pfad`: `harness/tools/release-warten.sh:81`
- `befund`: `>/dev/null 2>&1` verwirft die curl-/docker-Meldung jedes Versuchs; 404 (nicht
  publiziert), 403 (Rate-Limit), DNS-Fehler und ein gescheiterter Bild-Pull ergeben dieselbe Zeile.
  Die Ursache sieht man erst im nachfolgenden `full-smoke`-Fetch, und auch dort nur, wenn der Fehler
  bis dahin anhält.
- `verifizierbar`: nein
- `klasse`: Wiederhol-Schleife verwirft die Fehlerursache

## Geprüft, ohne Befund

- **(a) Urteil:** Beide Ausgänge über die Abrufbarkeit enden mit Exit 0 (Erfolg und Grenze, im Code
  und in den Fällen `abrufbares Release`/`nach der Grenze` gebunden). Exit 2 nur bei den eigenen
  Vorbedingungen. Ein echter Fehler wird nicht verdeckt, denn `full-smoke` läuft danach unverändert
  und urteilt. Den Bild-Pin liest das Skript aus `traeger-fetch.sh:35`. Läuft dessen Form auseinander,
  ist das Bild leer (Exit 2) oder der Fall `das Bild ist der Pin von traeger-fetch.sh` wird rot (sein
  `sed` verlangt dieselbe `}"`-Endung).
- **(b) Platzierung:** Der Schritt steht nur im `ci`-Job `full-smoke`. Die anderen Jobs holen nichts:
  `release.yml` `start-smoke` prüft `dist/` aus `download-artifact`, und `gates`/`smoke` fahren kein
  `traeger-fetch` (`grep -n traeger-fetch Makefile harness/tools/*smoke*.sh`). Kein Job setzt
  `timeout-minutes`, also reichen die +15 min (nur im Regelfall, s. F-1).
- **(c) `exempt-targets`:** `release-warten` steht in Gruppe (a). Laut Kommentar in `.d-check.yml`
  ist das die Gruppe der Ziele, die *zusätzlich* in `harness/README.md` genannt sind. Die
  Einleitung von §Werkzeuge sagt dasselbe, die Regel „ohne Prosa-Erwähnung" gilt nur für Gruppe (b).
  Die Zahl „20 von 24" ist nachgezählt: 24 Namen, 20 mit `NICHT in gates` im `## `-Text.
- **(d) bats:** Der Test läuft hermetisch über Stubs, das Payload ist derselbe String wie im
  echten Lauf. Die drei Gegenproben im Kopf lassen sich an den Zusicherungen nachlesen (Status
  `-eq 0`, `lines[1]`, Bild-Gleichheit). Lücken stehen in F-2 und F-3.
- **(e) `releasing.md` Schritt 6:** Die Zeilen-Präfixe, Defaults, Asset-Namen und der Ablauf
  „Grenze überschritten → 404 → `AUSGANG LEITUNG`" stimmen mit dem Skript überein. „wartet an beiden
  Läufen" stimmt, weil die `concurrency`-Gruppe je Ref gilt (`ci-${{ github.event_name }}-${{ github.ref }}`).
  Re-Run als Ausgang nur bei überschrittener Grenze entspricht Verdikt Festlegung 5.
- **§3.7 Kommentare** in `release-warten.sh`, `Makefile` und `ci.yml` beschreiben Zustand und Grenze,
  keine Chronik. **§3.1:** Das Target existiert, die README-Zeile trägt `kein Gate`.
