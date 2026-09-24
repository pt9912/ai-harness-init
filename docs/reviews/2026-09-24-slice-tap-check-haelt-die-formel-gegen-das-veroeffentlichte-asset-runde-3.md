# Review-Report: slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset — Runde 3 — 2026-09-24

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der
Verifier).

**Gegenstand:** `git diff c1ce82f9..HEAD` — vier Commits, 19 Dateien, 476 Zeilen hinzu, 74 entfernt:
`318f8e9d` (Rolle Architect: ADR-0066 `Proposed`, nur soweit sie die Umsetzung bindet), `cf0fca62`
(Rolle Planner: Abnahme-Wortlaut nach ADR-0066), `e3a34295` (Rolle Implementer: Status 10 der Nutzlast,
Abbildung im Host-Skript, Zähne 429 bis 434), `dc034c0b` (Rolle Implementer: Makefile-Kommentar,
README-Zeile). Berührt: `harness/tools/tap-nachzug.sh`, `harness/tools/tap-nachzug-nutzlast.sh`,
`test/tap-nachzug.bats`, `test/mutations/` (418, 420, 424, 427, 428 geändert; 429 bis 434 neu),
`Makefile`, `harness/README.md`, der Slice-Plan, `ADR-0066` samt Index-Zeile.

**Plan-Bezug:** Slice `slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset` (§1, Liefer-Punkte
1 bis 3, §4, §6) — Kennung, nicht Pfad: der Plan wandert mit dem Lifecycle. **Vorlauf:** Review-Reports
Runde 1 (F-1 bis F-12) und Runde 2 (R2-1 bis R2-5), hier als „Runde-2 R2-<n>" zitiert.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13)
**Modell:** Sonnet 5 · **Datum:** 2026-09-24

**Eingangs-Kontext:** Diff · Slice-Plan · `ADR-0064` (`Accepted`) · `ADR-0066` (`Proposed`, als Constraint
gelesen; ihr eigener Review ist ein getrennter Auftrag) · `LH-QA-02` · `MR-071` · `AGENTS.md` §3 (v.a.
§3.2, §3.4, §3.6, §3.7, §3.8, §3.9, §3.11) · `v6.9.0` `regelwerk/modul-08-agentenrollen.md`,
`modul-10-review-harness.md`, `modul-11-verification.md`. Der Implementer-Bericht war Behauptung; Code,
Tests und Sonden sind selbst gelesen und gefahren.

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt):

- `test/tap-nachzug.bats` einzeln im gepinnten bats-Image (Rezept `test-bats`): **37 von 37** ok.
- **Mutations-Fälle 418, 420, 424, 427 bis 434 emuliert, nicht über `make mutate`:** je Fall eine frische
  Kopie von `harness/`, `Makefile`, `.github/workflows/` und der bats-Datei im Scratchpad, das Skript des
  Falls dort angewandt (Anker ändert die Datei: bei allen 11 ja), `test/tap-nachzug.bats` gefahren; die
  Meldung des ersten roten `[`/`[[` gelesen (429 und 420: `docker Status 1: Exit 1` · 430: `Ziel /dev/full,
  Status 127: Exit 127` · 431: `mktemp Status 1: Exit 1`, Meldung des internen Fehlers der Nutzlast bleibt,
  der Status nicht · 432: Zeilenzahl bei Exit 0 · 433: Zeilenzahl 2 statt 1 · 434: `Ziel /dev/full,
  Tag-Form: Exit 1` · 424: `[ "$status" -eq 2 ]` in Fall 33 · 418: Fall 5). Jeder Fall färbt den Fall
  rot, den sein `# expect:` nennt.
- **Gegenproben (grün heißt „bindet"):** 433 mit allen `[ "$(exit_zeilen)" -eq 1 ]` auf `true` → 0 rote
  Fälle; 432 mit den `-eq 0`-Zeilen **und** den `!= *"Exit"*`-Zeilen auf `true` → 0 rote (mit nur einer der
  beiden Schwächungen bleibt Fall 29 rot: zwei unabhängige Träger); 424 mit Status-Assertion **und**
  Meldungs-Assertion auf `true` → 0 rote. **424 einzeln:** nur die Status-Assertion geschwächt → Fall 33
  bleibt rot (Meldung trägt); nur die Meldungs-Assertion geschwächt → Fall 33 bleibt rot (Status trägt). Die
  Angabe „424 bindet nur über eine zweite Assertion, ohne dass die erste allein rot wird" trifft **nicht**
  zu: jede der beiden ist für sich ein Träger.
- **Sonden am Skript, ohne Repo-Änderung** (Stubs und Kopien im Scratchpad):
  - **reales `docker` (29.8.1)** mit `DOCKER_HOST=tcp://127.0.0.1:9` → Meldung des Transports, Exit 2, Zeile
    `tap-check: Exit 2`;
  - `docker`-Stub mit Status 1, 3, 125, 127, 137, 143 → je Exit 2 mit Zeile; **Status 10 vom `docker`-Stub
    selbst → Exit 1, einzige Ausgabe `tap-check: Exit 1`, kein Digest, keine Meldung** (siehe R3-3);
  - **echtes gepinntes Bild** (`curlimages/curl@sha256:463eaf60…`, lokal vorhanden) mit einem `curl`-Stub im
    Bild über ein Shim-`docker`: Unterschied → Exit 1 mit beiden Digests und Zeile; Gleichheit → Exit 0;
    `TMPDIR=/nonexistent` → Exit 2 (Meldung des internen Fehlers, Nutzlast Status 1 auf 2 abgebildet);
    `SIGTERM` an PID 1 im Bild → Exit 2; mit `TAP_TOKEN=TOKSENT-XYZ` in jedem Lauf: Kopfdatei `-rw-------`,
    Token in **keiner** Ausgabe (`grep -c` → 0);
  - Token-Sonde mit nicht beschreibbarem stderr **im Bild** (Nutzlast-`sh` mit `2>/dev/full`) und Vergleich mit
    Unterschied: Token in keiner Ausgabe, keine Restdatei im `TMPDIR` (`ls -A` → 0); Host-stderr `/dev/full`
    ebenso;
  - reales `docker` mit Host-stderr `/dev/full` und `2>&-`, Container beendet mit 10 (Shim): Exit **2**,
    nicht 1 (siehe R3-1).
- `make shell-lint` Exit 0, keine `# shellcheck disable` im Diff (`grep -rn 'shellcheck disable'` über
  Skripte und bats-Datei → 0); `make comment-claims` → `76 Datei(en) geprueft, 0 Befund(e)`;
  `make docs-check` → `1865 Datei(en) geprüft, 0 Befund(e)` (vor diesem Report);
  `make tap-check TAG=v01.0.0` (make Exit 2, Zeile `tap-check: Exit 2` **vor** `make: *** … Fehler 2`),
  `TAG=v1.0.0-rc.1` (Exit 0, keine Zeile). `make gates` — siehe Ende.

---

## Status der Runde-2-Befunde

| Runde-2 | Status | Beleg dieses Laufs |
|---|---|---|
| R2-1 HIGH (Exit 1 des `docker`-Aufrufs als Formel-Unterschied) | **behoben** | reales `docker` bei unerreichbarem Daemon → Exit 2 mit der Meldung des Transports; Stub mit 1, 3, 125, 127, 137, 143 → Exit 2; Klasse 1 entsteht nur bei Status 10, den `docker` mit seinen eigenen Fehlern nicht belegt. Zähne 420 und 429 färben Fall 26 (`docker Status 1: Exit 1`) rot. **Rest:** Status 10 aus einer anderen Quelle als der Nutzlast trägt nicht — R3-3 (INFO). |
| R2-2 MEDIUM (Umdeutung einer `Accepted`-ADR ohne Verdikt-Artefakt) | **adressiert, Accept offen** | `ADR-0066` (`Proposed`, Teil-`Supersedes` auf vier wörtlich genannte Stellen von `ADR-0064`, Träger `tap-<modus>: Exit <N>`) ist das Architect-Artefakt; der Plan nennt sie als Constraint (§1, §5, §6). Der Zusatz an der Status-Zelle von `ADR-0064` folgt dem Accept (Folgepflicht 3 der ADR). Der Review der ADR ist ein getrennter Auftrag. |
| R2-3 MEDIUM (Zusage „jedes Ende") | **teilweise behoben** | Signal und nicht beschreibbares stderr sind in Plan (§1, §2, §3) und Skript-Kopf als „nicht zugesagt" benannt und stehen so in `ADR-0066` §Entscheidung; `melde()` fängt den Schreibfehler ab (Zahn 434, emuliert rot, Gegenprobe s.o.). **Der Skript-Kopf sagt darüber hinaus** „Eine stderr, die sich nicht beschreiben laesst, aendert den Exit nicht" — an der realen Verdrahtung falsch: R3-1. |
| R2-4 MEDIUM (`*)`-Arm ohne Zahn) | **behoben** | 430 (Host) und 431 (Nutzlast) färben Fall 37 bzw. 32 (und 30, 31) am Status; Meldung gelesen (`Exit 127`, `Exit 1`). |
| R2-5 INFO (Zähne „Zeile bei Exit 0", „doppelte Zeile" nicht gelistet) | **behoben** | 432 und 433 unter `test/mutations/`; jeder färbt Fall 29 (Zeilenzahl); Gegenprobe 0 rot. |
| Textangleichung (Makefile-Kommentar, README-Zeile, Kopf, Plan: „letzte stderr-Zeile **des Skripts**", über `make` die vorletzte der Ausgabe) | **behoben** | Wortlaut in vier Artefakten und `ADR-0066` stimmt überein; gemessen über `make`: Zeile des Skripts, danach `make: *** … Fehler 2`. |

**Runde-1-Reste** (nicht neu bewertet): F-9 (schreibende Rolle der Roadmap-Zeile) und F-10 (Real-Beleg trägt
der Verifier) unverändert offen; F-11, F-12 nicht adressiert (INFO).

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| R3-1 | MEDIUM | Die Zusage „**Eine stderr, die sich nicht beschreiben laesst, aendert den Exit nicht: die Zeile fehlt dann, die Klasse bleibt**" (Skript-Kopf, Fall-Name „der Exit bleibt die Klasse des Skripts") hält an der realen Verdrahtung nicht: der `docker`-Client kopiert die stderr des Containers auf die des Aufrufers, und bei nicht beschreibbarer stderr endet er mit Status 1 statt mit dem des Containers. Gemessen mit realem `docker`: Container `exit 10` bei stderr `/dev/full` → `docker` Status 1 (bei stderr geschlossen `docker` 10 direkt, im Skript-Lauf 1); das Skript endet danach mit **Exit 2** und der Meldung *„Transport im Bild ist nicht gelaufen (docker Exit 1) — es wurde nichts verglichen"*, obwohl der Vergleich gelaufen ist und einen Unterschied ergab. Die Richtung ist die sichere (2 statt 1), die Klasse bleibt aber nicht. `ADR-0066` und der Plan nehmen den Fall aus der Zusage; nur der Skript-Kopf verspricht mehr. Fall 30 fährt `docker` nur als Stub mit Status 125 und das Skript **nicht** bis in den Vergleich, deckt den Fall also nicht. | `AGENTS.md` §3.6 (Zusage auf das einschränken, was der Code hält) · `ADR-0066` §Entscheidung („Nicht zugesagt") · `ADR-0064` Festlegung 2 | `harness/tools/tap-nachzug.sh` Zeilen 27 bis 28; `test/tap-nachzug.bats` Zeilen 491 bis 511 | ja — Sonde: Shim-`docker` ruft das reale `docker run --rm busybox sh -c 'exit 10'`, `TAG=v0.2.3 bash harness/tools/tap-nachzug.sh check 2>/dev/full; echo $?` → 2 | Zusage „Klasse bleibt bei unbeschreibbarer stderr" ohne Gegenbeispiel an der Client-Verdrahtung |
| R3-2 | LOW | Die Meldung des `*)`-Arms im Host-Skript sagt für **jeden** Status außerhalb von 0, 2 und 10 *„der Transport im Bild ist nicht gelaufen — es wurde nichts verglichen"*. Für 137 (OOM, Kill im Bild), 143 und den Stream-Fehler aus R3-1 kann der Vergleich gelaufen sein; der Kommentar am `docker`-Aufruf nennt „Nutzlast abgebrochen" als Herkunft, die Meldung behauptet das Gegenteil. Die Klasse (Exit 2) ist damit richtig, der Text zu breit. | `AGENTS.md` §3.6 · `ADR-0064` Festlegung 2 (Meldung nennt die Ursache) | `harness/tools/tap-nachzug.sh` Zeilen 134 bis 156 | ja — `docker`-Stub mit Status 137 oder 143: Ausgabe *„… nicht gelaufen (docker Exit 137) — es wurde nichts verglichen"* | Meldung breiter als die Herkunftsmenge des Status |
| R3-3 | INFO | Der Status 10 ist ein **privates Protokoll** zwischen zwei Dateien des Repos. Ein `docker`-Aufruf, der selbst mit 10 endet (Stub, Wrapper, ein anderer Client), wird als Formel-Unterschied gemeldet: Exit 1, einzige Ausgabe `tap-check: Exit 1`, **ohne** Digests und erste abweichende Zeile (gemessen). Der Kopf nennt die Zusage („den docker mit seinen eigenen Fehlern (1, 125 bis 127) nicht belegt"), nicht diese Restmenge; das Host-Skript kann die Herkunft nicht prüfen. Die Kanal-Wahl liegt **unterhalb** von `ADR-0064` Festlegung 2 und 5 (sie ordnen dem Skript drei Klassen zu und nennen nicht, wie die Nutzlast das Ergebnis zurückgibt) und von `ADR-0066` (Ebene des Skripts): kein Widerspruch zu einer der beiden. Der Kanal wird beim `sync`-Schnitt weitere Ergebnisse tragen müssen (gleiche Nutzlast); ein Gegenlesen durch den Architect ist die Adresse dafür, kein Verdikt für diesen Slice. | `ADR-0064` Festlegung 2 („Ein Lesefehler ist damit nie 1"), Festlegung 5 · Maintainability | `harness/tools/tap-nachzug.sh` Zeilen 134 bis 156; `harness/tools/tap-nachzug-nutzlast.sh` Zeilen 11 bis 23, 40 bis 59 | ja — Sonde: `docker`-Stub `exit 10`, `TAG=v0.2.3 bash harness/tools/tap-nachzug.sh check` → Exit 1 | privater Status-Kanal ohne Herkunftsprüfung, Restmenge nicht benannt |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Trägt Status 10 die Klassen?** Kommandos der Nutzlast (`curl` über `|| code=000`, `cmp` über `cmp_rc`, `mktemp`, `sha256sum`, `awk`, `sleep`, `rm` über `|| :`): jedes Ende mit 10 ohne `unterschied=ja` wird im EXIT-Trap zu Exit 2 mit Meldung (Fall 33, Zahn 424 rot, Gegenprobe beide Träger); `unterschied=ja` steht unmittelbar vor `exit 10`, kein weiteres Kommando dazwischen. Ein Ende mit 1 oder ≥ 3 ohne `unterschied=ja` wird Exit 2 (Zähne 430, 431). Im Host: 0 → 0, 10 → 1, 2 → 2, alles andere → 2 mit Meldung; kein Kommando des Hosts kann 10 als Unterschied durchreichen (`*)` in `beende`). | geprüft, ohne Befund (Ausnahme: R3-3 für einen `docker`-Aufruf, der selbst mit 10 endet) |
| **ADR-0064 Festlegung 2, „Lesefehler nie 1, nie 0":** `DOCKER_HOST` unerreichbar, `docker`-Stub 1, 3, 125, 127, 137, 143, Nutzlast-Fehler im echten Bild (mktemp, Signal an PID 1), Tap 403/404/429/500/000, `cmp` mit Status 2 → immer 2 mit Zeile; keine Klasse 0 aus einem Fehler | geprüft, ohne Befund |
| **Signal-Status (137, 143):** über `docker`-Stub und im echten Bild (`kill -TERM 1` → die Nutzlast fängt es mit `trap 'exit 2'`, Exit 2) auf Exit 2 abgebildet; der Skript-Kopf nennt „jeder andere Status des docker-Aufrufs ausserhalb von 0, 2 und 10" ehrlich als Exit 2 — die Meldung dazu ist R3-2 | geprüft, ohne Befund (Aussage-Breite der Meldung: R3-2) |
| **Token-Umgang nach dem Umbau:** Datei `-rw-------` unter `umask 077`, `curl -H @Datei`, `unset TAP_TOKEN`, Entfernung im `beende` der Nutzlast (jeder Endezweig, auch `printf`-Fehler auf stderr), `-e TAP_TOKEN` ohne Wert in der Kommandozeile des Hosts, kein `set -x`; neue Sonde nicht beschreibbares stderr im Bild + Token + Vergleich mit Unterschied: Token in keiner Ausgabe (`grep -c` → 0), keine Restdatei im `TMPDIR`; echtes Bild dieselbe Lage ohne Befund. Bei nicht beschreibbarem stderr im Bild wird ein echter Unterschied als Exit 2 gemeldet — sichere Richtung, nicht durch `ADR-0064` verboten; als Aussage über den Host-Exit siehe R3-1 | geprüft, ohne Befund |
| **Fälle 429 bis 434 und 424, 418, 420, 427, 428 nach `MR-071` und §3.6:** jeder `sed`-Anker ändert die Datei am heutigen Bestand (11 von 11); jedes `# expect:` ist ein Präfix eines Fall-Namens; jeder Fall wird aus dem behaupteten Grund rot (Meldung gelesen); die Gegenprobe (Zusicherung geschwächt → grün) trägt für 424, 432, 433 | geprüft, ohne Befund |
| Zustandsform der Kommentare (`AGENTS.md` §3.7) in beiden Skripten, bats-Datei, sechs neuen Fällen, Makefile, README-Zeile: keine Befund-Kennung, keine Runden-Nennung, keine Slice-Nummer als Erzählung, keine verworfene Alternative (`grep` über die hinzugefügten Zeilen: 0 Treffer, bis auf einen Fall-Namen mit „ohne dass der Vergleich es gemeldet hat", der eine Bedingung nennt) | geprüft, ohne Befund |
| Doku gegen Code: Skript-Kopf, Makefile-Kommentar, README-Zeile, Plan §1/§2/§3, `ADR-0066` §Entscheidung stimmen in „letzte stderr-Zeile **des Skripts**, über `make` die vorletzte der Ausgabe" überein (gemessen über `make`); `ADR-0066` hält die Zeile bei Signal und nicht beschreibbarer stderr als nicht zugesagt | geprüft, ohne Befund (Überschuss im Skript-Kopf: R3-1) |
| Shell-Lint ohne Suppression (`AGENTS.md` §3.2): `make shell-lint` Exit 0, keine Lint-Config im Diff | geprüft, ohne Befund |
| Abgrenzung (Plan §1): kein `sync`-Verhalten, kein Gate (Fall „kein gate" grün, `tap-check` in keiner Prerequisite-Kette), kein Adaptions-Eintrag, `traeger-fetch.sh` und Workflow unberührt | geprüft, ohne Befund |
| Größe und Schnitt: 476 Zeilen im Diff (davon 195 `ADR-0066`, 105 bats, 6 neue Fälle je 10 bis 11 Zeilen); drei Liefer-Punkte, zwei Schichten — in einer Sitzung prüfbar | geprüft, ohne Befund |
| Rollen-Grenzen: `AGENTS.md` §3.8 (Architect-Commit berührt nur ADR und ADR-Index, Rolle in der Message), §3.10 (Plan §7 leer, kein Closure-Schritt im Diff), Planner-Commit nur Plan, Implementer-Commits nur Werkzeug/Test/Doku-Zeilen; `AGENTS.md` §3.11: der Plan und die ADR nennen bewegliche Artefakte über Kennung; ortsfeste Pfade (`docs/user/releasing.md`, `harness/sensors/adr-immutable.md`) als Pfad zulässig | geprüft, ohne Befund |
| `make gates`-Bindung der neuen Zähne: die Fälle laufen in `make test` (37 von 37 ok); `make mutate` nicht gefahren (Beleg hängt am Baum-Hash, Verifier) | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 1 |

**Runde-2-Befunde:** R2-1 (HIGH), R2-4, R2-5 und die Textangleichung behoben · R2-2 adressiert
(`ADR-0066` `Proposed`, Accept offen) · R2-3 teilweise (Rest: R3-1).

**Finding-Klassen dieses Laufs:** Zusage „Klasse bleibt bei unbeschreibbarer stderr" ohne Gegenbeispiel an der
Client-Verdrahtung · Meldung breiter als die Herkunftsmenge des Status · privater Status-Kanal ohne
Herkunftsprüfung, Restmenge nicht benannt

## Verdikt

**Merge-blockierend:** kein HIGH; R3-1 (MEDIUM) ist vor dem Merge zu klären — der Skript-Kopf und der
Fall-Name versprechen, was der Code an der realen `docker`-Verdrahtung nicht hält. R3-2 und R3-3 blockieren
nicht.

**Übergabe:**

- **R3-1, R3-2 → Implementer** (Wortlaut der Zusage im Kopf und im Fall-Namen; Meldung des `*)`-Arms).
- **R3-3 → Architect zum Gegenlesen** (Status-Kanal der Nutzlast unterhalb `ADR-0064` Festlegung 2 und 5 und
  `ADR-0066`; kein Verdikt für diesen Slice, Adresse für den `sync`-Schnitt). Der offene Runde-1 F-9 geht
  in derselben Anfrage mit.
- Die **Finding-Klassen** gehen zusätzlich in die Slice-Closure §7 und von dort in den Zähler (Runden 1 bis 3
  zählen als je ein Vorgang **derselben** Closure, nicht als drei). Dieser Report ist ein Lauf-Beleg und
  ersetzt keine Verifikation: DoD-Konformität, den realen Rot-Beleg und den Beleg der Fälle unter
  `make mutate` prüft der Verifier.
